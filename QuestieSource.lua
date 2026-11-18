local _, ns = ...

-- Fuente opcional de misiones: si el jugador tiene QuestieDB cargado, se le pregunta que
-- misiones usan cada item (objetivo, item fuente, item que inicia la mision) para que los
-- sobrantes de misiones hechas den moneda. QuestieDB NUNCA se incluye ni se copia (GPL-3.0):
-- se lee por su API publica (`LibQuestieDB`) en la maquina del jugador.
--
-- Contrato leido (2026-11-17) de los paquetes para Forever (Interface 16001):
--   Questie v12.10.0          Questie_Forever.toc: `X-QuestieDB-Contract: 4`
--   QuestieDB v1.1.2          QuestieDB_Forever.toc: `X-Contract-Version: 4`; src/api.lua define
--                             `LibQuestieDB.RequireContract(n)`: true si minSupportedContract <= n <= contractVersion.
-- Se exige el contrato 4 (el que declara Questie 12.10.0 y contra el que se leyeron los campos).
--
-- Campos usados (todos por `LibQuestieDB.Quest.Get(questID, 'campo')`; Types/Quest.t.lua y General.t.lua):
--   objectives          {[1]=criaturas, [2]=objetos, [3]={ {itemID, texto, cantidad}... }, [4]=rep,
--                        [5]=creditos, [6]={ {spellID, texto, itemID}... }}. Se toman los items de
--                        [3] (tambien si la entrada es un id suelto) y el itemID de [6] (item que
--                        se usa en un objetivo de hechizo).
--   requiredSourceItems { itemID... } items necesarios sin ser objetivo.
--   sourceItemId        item que entrega quien da la mision.
--   startedBy           {[1]=npcs, [2]=objetos, [3]={ itemID... }} items que inician la mision.
--   requiredRaces       mascara de razas (nil o 0 = sin restriccion). Bits de `Enum.raceMaskById[raceID]`
--                       (hay bits por encima de 2^31: se prueban con aritmetica, no con bit.*).
--   requiredClasses     mascara de clases (nil o 0 = sin restriccion). Bits de `Enum.classKeys[TOKEN]`.
--   specialFlags        bit 1 = REPEATABLE.
--   questFlags          DAILY 4096, WEEKLY 32768, MONTHLY 65536 (se tratan como repetibles).
-- Otros campos de LibQuestieDB: `Quest.GetAllIds()` (lista ascendente, compartida, solo lectura),
-- `Enum.factionRaceMasks.Alliance/Horde`. Con Questie presente se espera a `Questie.API.isReady`
-- (API publica estable, Public/RegisterOnReady.lua): hasta entonces Questie aun aplica sus
-- correcciones sobre la base y un indice armado antes podria quedar desactualizado.
--
-- Regla de oro: ante cualquier duda, nil. Uses nunca lanza error (Classify lo llama sin pcall)
-- y cualquier dato faltante conserva la mision (un item de mas "util" cuesta una monedita
-- menos; una monedita falsa es el peor fallo).

local Questie = {}
ns.Questie = Questie

local REQUIRED_CONTRACT = 4
local FLAG_REPEATABLE = 1                                   -- specialFlags
local FLAGS_RECURRING = { 4096, 32768, 65536 }              -- questFlags: DAILY, WEEKLY, MONTHLY
local MAX_PER_TICK, BUDGET_MS, TICK_SECONDS = 300, 4, 0.01

local state            -- nil | 'waiting' | 'building' | 'ready' | 'failed'
local index            -- [itemID] = { registro de mision, ... }; solo cuando state == 'ready'
local lib              -- LibQuestieDB ya validado (solo se guarda un exito)
local raceBit, classBit -- cada uno se guarda en cuanto se resuelve (no cambian durante la sesion)
local readyCallbacks = {}
local generation = 0   -- ResetState invalida los lotes y avisos pendientes

-- ---------------------------------------------------------------------------
-- Libreria
-- ---------------------------------------------------------------------------

-- Devuelve LibQuestieDB si existe y acepta el contrato; el fallo NO se cachea (el addon puede
-- cargarse mas tarde), el exito si.
local function getLib()
    if lib then return lib end
    local candidate = _G.LibQuestieDB
    if type(candidate) ~= 'table' or type(candidate.RequireContract) ~= 'function' then return nil end
    local quest = candidate.Quest
    if type(quest) ~= 'table' or type(quest.Get) ~= 'function' or type(quest.GetAllIds) ~= 'function' then return nil end
    local good, supported = pcall(candidate.RequireContract, REQUIRED_CONTRACT)
    if not good or supported ~= true then return nil end
    lib = candidate
    return lib
end

function Questie.Available() return getLib() ~= nil end

function Questie.IsReady() return state == 'ready' end

-- true mientras QuestieDB esta disponible pero su indice aun no esta listo (Uses da nil sin que
-- eso signifique "sin misiones"). Un fallo definitivo cuenta como "sin Questie".
function Questie.Pending()
    return getLib() ~= nil and state ~= 'ready' and state ~= 'failed'
end

-- fn() se llama (una vez) cuando el indice queda listo: las vistas pueden refrescarse.
function Questie.OnReady(fn)
    if type(fn) ~= 'function' then return end
    if state == 'ready' then pcall(fn) else readyCallbacks[#readyCallbacks + 1] = fn end
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Questie.ResetState()
    generation = generation + 1
    state, index, lib, raceBit, classBit, readyCallbacks = nil, nil, nil, nil, nil, {}
end

-- ---------------------------------------------------------------------------
-- Bits
-- ---------------------------------------------------------------------------

-- Prueba un bit con aritmetica: las mascaras de razas de Forever pasan de 2^31.
local function hasBit(value, bit)
    return type(value) == 'number' and type(bit) == 'number' and bit > 0 and value % (bit * 2) >= bit
end

-- true si las dos mascaras comparten alguna raza (cada valor de raceMaskById es un solo bit).
local function sharesRace(a, b, raceMasks)
    for _, bit in pairs(raceMasks) do
        if hasBit(a, bit) and hasBit(b, bit) then return true end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Personaje
-- ---------------------------------------------------------------------------

-- { raceBit=, classBit=, faction= }; cada dato en nil si no se sabe (esa mision no se filtra por el).
-- Raza y clase se cachean por separado: si una aun no esta disponible, la otra no se vuelve a leer.
local function playerInfo()
    local enum = lib and lib.Enum
    if type(enum) ~= 'table' then return {} end
    if not raceBit and type(UnitRace) == 'function' and type(enum.raceMaskById) == 'table' then
        local raceID = select(3, UnitRace('player'))
        if raceID ~= nil then raceBit = enum.raceMaskById[raceID] end
    end
    if not classBit and type(UnitClass) == 'function' and type(enum.classKeys) == 'table' then
        local token = select(2, UnitClass('player'))
        if type(token) == 'string' then
            -- El cliente dice DEATHKNIGHT; classKeys dice DEATH_KNIGHT.
            classBit = enum.classKeys[token] or enum.classKeys[(token:gsub('^DEATHKNIGHT$', 'DEATH_KNIGHT'))]
        end
    end
    local faction
    if type(UnitFactionGroup) == 'function' then faction = (UnitFactionGroup('player')) end
    return { raceBit = raceBit, classBit = classBit, faction = type(faction) == 'string' and faction or nil }
end

local function otherFaction(faction)
    if faction == 'Alliance' then return 'Horde' end
    if faction == 'Horde' then return 'Alliance' end
end

-- false solo si QuestieDB dice sin lugar a dudas que el personaje nunca podra hacerla.
local function canDo(record, info)
    local races, classes = record.races, record.classes
    if type(races) == 'number' and races > 0 then
        if info.raceBit then
            if not hasBit(races, info.raceBit) then return false end
        else
            -- Raza desconocida: solo por faccion, y solo si la mision es de la otra faccion.
            local masks = lib and lib.Enum and lib.Enum.factionRaceMasks
            local raceMasks = lib and lib.Enum and lib.Enum.raceMaskById
            local own = masks and info.faction and masks[info.faction]
            local other = masks and masks[otherFaction(info.faction)]
            if type(raceMasks) == 'table' and own and other
                and sharesRace(races, other, raceMasks) and not sharesRace(races, own, raceMasks) then
                return false
            end
        end
    end
    if type(classes) == 'number' and classes > 0 and info.classBit and not hasBit(classes, info.classBit) then
        return false
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Indice item -> misiones
-- ---------------------------------------------------------------------------

local function isRepeatable(special, flags)
    if hasBit(special, FLAG_REPEATABLE) then return true end
    for _, flag in ipairs(FLAGS_RECURRING) do
        if hasBit(flags, flag) then return true end
    end
    return false
end

local function validID(value) return type(value) == 'number' and value > 0 end

local function addItem(items, itemID, record)
    if not validID(itemID) then return end
    local list = items[itemID]
    if not list then items[itemID] = { record }; return end
    -- Una mision se procesa de una sola vez: basta mirar la ultima entrada para no duplicar.
    if list[#list] ~= record then list[#list + 1] = record end
end

local function indexQuest(source, items, questID)
    local get = source.Quest.Get
    local objectives = get(questID, 'objectives')
    local required = get(questID, 'requiredSourceItems')
    local sourceItem = get(questID, 'sourceItemId')
    local startedBy = get(questID, 'startedBy')

    local ids = {}
    if type(objectives) == 'table' then
        if type(objectives[3]) == 'table' then
            for _, entry in ipairs(objectives[3]) do ids[#ids + 1] = type(entry) == 'table' and entry[1] or entry end
        end
        if type(objectives[6]) == 'table' then
            for _, entry in ipairs(objectives[6]) do if type(entry) == 'table' then ids[#ids + 1] = entry[3] end end
        end
    end
    if type(required) == 'table' then for _, itemID in ipairs(required) do ids[#ids + 1] = itemID end end
    ids[#ids + 1] = sourceItem
    -- Los iniciadores van aparte (record con starter = true): su regla es otra (mision hecha o no).
    local starterIds = {}
    if type(startedBy) == 'table' and type(startedBy[3]) == 'table' then
        for _, itemID in ipairs(startedBy[3]) do starterIds[#starterIds + 1] = itemID end
    end
    -- Objetivos ocultos: { spawns?, icono, texto?, indice, { {'item'|'monster'|'object', id}, ... }? }.
    -- Cada entrada se lee aparte: una ilegible se saltea SOLA (sus ids no se agregan) y el resto de
    -- la mision y del indice sigue valiendo. Asi una referencia rota nunca degrada a "sin Questie".
    local extra = get(questID, 'extraObjectives')
    if type(extra) == 'table' then
        for _, objective in pairs(extra) do
            local found = {}
            local readable = pcall(function()
                if type(objective) ~= 'table' then error('entrada ilegible') end
                local refs = objective[5]
                if refs == nil then return end
                if type(refs) ~= 'table' then error('referencias ilegibles') end
                for _, ref in pairs(refs) do
                    if type(ref) ~= 'table' then error('referencia ilegible') end
                    if ref[1] == 'item' then
                        if not validID(ref[2]) then error('item ilegible') end
                        found[#found + 1] = ref[2]
                    end
                end
            end)
            if readable then
                for _, itemID in ipairs(found) do ids[#ids + 1] = itemID end
            end
        end
    end

    local base
    local function newRecord(starter)
        base = base or {
            races = get(questID, 'requiredRaces'),
            classes = get(questID, 'requiredClasses'),
            repeatable = isRepeatable(get(questID, 'specialFlags'), get(questID, 'questFlags')),
        }
        return { questID = questID, races = base.races, classes = base.classes, repeatable = base.repeatable,
            starter = starter or nil }
    end
    local record, starterRecord
    for _, itemID in ipairs(ids) do
        if validID(itemID) then
            record = record or newRecord(false)
            addItem(items, itemID, record)
        end
    end
    for _, itemID in ipairs(starterIds) do
        if validID(itemID) then
            starterRecord = starterRecord or newRecord(true)
            addItem(items, itemID, starterRecord)
        end
    end
end

local function finish(items)
    index, state = items, 'ready'
    -- Los contextos ya armados no tenian esta fuente: se reconstruyen en el proximo pedido.
    -- Y se reconstruye ya: asi Player.OnChanged se entera (questLogIncomplete pasa de true a nil)
    -- aunque nadie pida el contexto, y las vistas se refrescan.
    if ns.Player and ns.Player.Invalidate then
        pcall(ns.Player.Invalidate)
        if ns.Player.GetContext then pcall(ns.Player.GetContext) end
    end
    local callbacks = readyCallbacks
    readyCallbacks = {}
    for _, fn in ipairs(callbacks) do pcall(fn) end
end

local function startBuild(source)
    state = 'building'
    local good, ids = pcall(source.Quest.GetAllIds)
    if not good or type(ids) ~= 'table' then state = 'failed'; return end
    local items, position, total = {}, 1, #ids

    -- Procesa mientras haya misiones y presupuesto; devuelve false si LibQuestieDB fallo.
    local function work(limit)
        local started = type(debugprofilestop) == 'function' and debugprofilestop() or nil
        local count = 0
        while position <= total and count < limit do
            if not pcall(indexQuest, source, items, ids[position]) then return false end
            position, count = position + 1, count + 1
            if started and debugprofilestop() - started > BUDGET_MS then break end
        end
        return true
    end

    if not (C_Timer and C_Timer.After) then
        -- Sin temporizador: se arma de una vez, pero recien en el primer Uses.
        if work(total) then finish(items) else state = 'failed' end
        return
    end
    local mine = generation
    local function step()
        if mine ~= generation then return end
        if not work(MAX_PER_TICK) then state = 'failed'; return end
        if position > total then finish(items) else C_Timer.After(TICK_SECONDS, step) end
    end
    -- La primera tanda va en el proximo cuadro: el Uses que la dispara no se traba.
    C_Timer.After(0, step)
end

local function questieAPI()
    local global = _G.Questie
    local api = type(global) == 'table' and global.API or nil
    if type(api) == 'table' and type(api.RegisterOnReady) == 'function' then return api end
end

local function ensureBuilding()
    if state then return end
    local source = getLib()
    if not source then return end
    local api = questieAPI()
    if api and api.isReady ~= true then
        state = 'waiting'
        local mine = generation
        local registered = pcall(api.RegisterOnReady, function()
            if mine ~= generation or state ~= 'waiting' then return end
            state = nil
            pcall(ensureBuilding)
        end)
        if not registered then state = 'failed' end
        return
    end
    startBuild(source)
end

-- ---------------------------------------------------------------------------
-- Consulta
-- ---------------------------------------------------------------------------

local function usesFor(itemID)
    if type(itemID) ~= 'number' then return nil end
    if not getLib() then return nil end
    ensureBuilding()
    if state ~= 'ready' or not index then return nil end
    local records = index[itemID]
    if not records then return nil end
    local info = playerInfo()
    local uses
    for _, record in ipairs(records) do
        if canDo(record, info) then
            uses = uses or {}
            uses[#uses + 1] = { questID = record.questID, repeatable = record.repeatable, starter = record.starter }
        end
    end
    return uses
end

-- { {questID=, repeatable=bool, starter=true|nil}, ... } con las misiones (starter: el item la inicia) que podria hacer este personaje y que usan
-- el item, o nil (sin QuestieDB, indice aun sin terminar, item sin misiones o cualquier error).
-- Nunca lanza.
function Questie.Uses(itemID)
    local good, result = pcall(usesFor, itemID)
    if good then return result end
    return nil
end

-- Titulo de la mision segun QuestieDB (campo 'name' de Quest.Get), o nil. Nunca lanza.
function Questie.QuestName(questID)
    if type(questID) ~= 'number' then return nil end
    local good, name = pcall(function()
        local source = getLib()
        return source and source.Quest.Get(questID, 'name') or nil
    end)
    if good and type(name) == 'string' and name ~= '' then return name end
    return nil
end
