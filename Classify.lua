local _, ns = ...

-- Clasificador de marcas: funcion pura. Regla de oro: ante cualquier duda, sin marca.
-- item = { id, quality, classID, subclassID, equipLoc, hasUseOrEquipSpell, isSetPiece, price, isBound }
--   isBound = true solo si la bolsa confirma que el ejemplar esta ligado; false/nil = no (o no se sabe).
--   hasUseOrEquipSpell = true tambien cuando no se puede saber (sin API de hechizos).
-- ctx  = { class, professions = {[skillLineID]=true}, isQuestDone(questID)->true|false|nil,
--          questInLog(questID)->true|false|nil, questItemsInLog = {[itemID]=true},
--          questItemTitle(itemID)->titulo|nil,
--          questieUses(itemID)->{ {questID=, repeatable=, starter=} }|nil,
--          overrides = {[itemID]='keep'|'sell'}, questLogIncomplete = true|nil }
-- result = { mark = 'coin'|'hammer_mine'|'hammer_other'|'quest'|nil, reasons = { {kind=...} } }
--   quest = true cuando el item lo pide una mision del diario Y es reactivo o herramienta: la marca
--   es el martillo (las bolsas lo dibujan) y el botin dibuja el signo de mision.
-- Misiones (decision del user, 2026-11-17): un item de mision solo es util si lo pide una mision que
-- esta AHORA en el diario; si no, monedita 'quest_not_active' (futuras, no tomadas, hechas y
-- repetibles no tomadas no protegen). Los iniciadores siguen su propia regla: mision no hecha (o
-- sin saberlo) -> util ('quest_starter'); hecha y no repetible CONFIRMADO por QuestieDB (repeatable =
-- false) -> monedita 'quest_done'; hecha sin saber si es repetible -> sin moneda
-- ('quest_starter_done_unknown_repeat').
-- Libros de biblioteca y cajones arrebatados (Data/Special.lua): sin marca y sin moneda automatica,
-- motivo 'library_book' o 'waylaid_crate' (sealed = true si el cajon ya esta lleno).

local ITEM_CLASS_WEAPON, ITEM_CLASS_ARMOR, ITEM_CLASS_QUEST = 2, 4, 12

-- Subclases que alguna clase puede usar. Las que no estan (armadura 0 miscelaneo,
-- arma 20 cania, libros, etc.) nunca dan monedita.
local knownSubclasses
local function isKnownSubclass(kind, subclassID)
    if not knownSubclasses then
        knownSubclasses = { armor = {}, weapon = {} }
        for _, gear in pairs(ns.ClassGear) do
            for id in pairs(gear.armor) do knownSubclasses.armor[id] = true end
            for id in pairs(gear.weapon) do knownSubclasses.weapon[id] = true end
        end
    end
    return knownSubclasses[kind][subclassID] == true
end

-- true solo si el cliente dice explicitamente true; false y nil (no se sabe) son "no".
local function questDone(ctx, questID)
    if type(ctx.isQuestDone) ~= 'function' or questID == nil then return false end
    return ctx.isQuestDone(questID) == true
end

-- true/false segun el diario; nil si no se puede saber (sin questInLog o el diario no lo sabe).
local function inLog(ctx, questID)
    if type(ctx.questInLog) ~= 'function' or questID == nil then return nil end
    local answer = ctx.questInLog(questID)
    if answer == true or answer == false then return answer end
    return nil
end

local function classCannotUse(item, ctx)
    local kind
    if item.classID == ITEM_CLASS_ARMOR then kind = 'armor'
    elseif item.classID == ITEM_CLASS_WEAPON then kind = 'weapon'
    else return false end
    local subclassID = item.subclassID
    if type(subclassID) ~= 'number' or not isKnownSubclass(kind, subclassID) then return false end
    local gear = ctx.class and ns.ClassGear[ctx.class]
    if not gear then return false end
    return gear[kind][subclassID] ~= true
end

function ns.Classify(item, ctx)
    local result = { mark = nil, reasons = {} }
    local reasons = result.reasons
    if type(item) ~= 'table' or type(ctx) ~= 'table' or item.id == nil then return result end
    local id = item.id

    -- 1. Overrides del usuario.
    local override = ctx.overrides and ctx.overrides[id]
    if override == 'keep' then
        reasons[#reasons + 1] = { kind = 'override_keep' }
        return result
    elseif override == 'sell' then
        result.mark = 'coin'
        reasons[#reasons + 1] = { kind = 'override_sell' }
        return result
    end

    -- Libros de biblioteca y cajones arrebatados de Forever (Data/Special.lua): se guardan hasta
    -- entregarlos al bibliotecario o al representante de comercio. Nunca moneda automatica, aunque
    -- sean de clase Mision y ninguna mision del diario los pida; sin marca, motivo para el tooltip.
    if ns.Data.libraryBooks and ns.Data.libraryBooks[id] then
        reasons[#reasons + 1] = { kind = 'library_book' }
        return result
    end
    local crate = ns.Data.waylaidCrates and ns.Data.waylaidCrates[id]
    if crate then
        reasons[#reasons + 1] = { kind = 'waylaid_crate', sealed = crate == 'sealed' or nil }
        return result
    end

    -- Datos del item sin cargar: no se decide nada.
    if item.quality == nil then return result end

    -- 2. Misiones. Iniciadores (Data.starters o QuestieDB con starter = true) aparte del resto.
    local uses = type(ctx.questieUses) == 'function' and ctx.questieUses(id) or nil
    local starterQuest = ns.Data.starters and ns.Data.starters[id]
    local starterPending, starterRepeatable
    if starterQuest and not questDone(ctx, starterQuest) then starterPending = starterQuest end
    local questUses, logUnknown = {}, false
    for _, use in ipairs(uses or {}) do
        if use.starter then
            starterQuest = starterQuest or use.questID
            if not starterPending and not questDone(ctx, use.questID) then starterPending = use.questID end
        else
            questUses[#questUses + 1] = use
        end
    end
    -- Repetibilidad del iniciador segun QuestieDB: true/false solo si alguna entrega de esa mision lo
    -- dice explicitamente; nil = no se sabe (sin QuestieDB, sin entrada o sin el dato).
    local starterRepeat
    for _, use in ipairs(uses or {}) do
        if starterQuest and use.questID == starterQuest then
            if use.repeatable == true then starterRepeat = true
            elseif use.repeatable == false and starterRepeat == nil then starterRepeat = false end
        end
    end
    if starterRepeat == true then starterRepeatable = starterQuest end
    -- Util para una mision del diario: sin monedita. Si ademas es reactivo o herramienta, manda el
    -- martillo (paso 3) con quest = true; si no, la marca es 'quest'.
    local questReasons = {}
    for _, use in ipairs(questUses) do
        local answer = inLog(ctx, use.questID)
        if answer == true then
            questReasons[1] = { kind = 'quest_active', questID = use.questID }
            break
        elseif answer == nil then
            logUnknown = true
        end
    end
    if #questReasons == 0 and ctx.questItemsInLog and ctx.questItemsInLog[id] then
        local title = type(ctx.questItemTitle) == 'function' and ctx.questItemTitle(id) or nil
        questReasons[1] = { kind = 'quest_active', title = type(title) == 'string' and title or nil }
    end
    for _, reason in ipairs(questReasons) do reasons[#reasons + 1] = reason end

    -- 3. Reactivo o herramienta de profesion (la herramienta se pide pero no se consume: martillo,
    -- pico, cuchillo). Mismo trato: martillito verde si es de una profesion tuya, gris si no; nunca
    -- monedita automatica, aunque sea gris. Si es las dos cosas, manda el reactivo salvo que solo la
    -- herramienta sea de una profesion tuya.
    local reagentLines = ns.Data.reagents and ns.Data.reagents[id]
    local toolLines = ns.Data.tools and ns.Data.tools[id]
    -- Las cañas de pescar no figuran en spelltotems de Forever (Pesca no las pide como herramienta),
    -- pero son la herramienta de Pesca: arma (classID 2) de subclase 20.
    if not toolLines and item.classID == 2 and item.subclassID == 20 then toolLines = { 356 } end
    local function mineOf(list)
        local mine = {}
        for _, line in ipairs(list or {}) do
            if ctx.professions and ctx.professions[line] then mine[#mine + 1] = line end
        end
        return mine
    end
    local function copy(list)
        local all = {}
        for i, line in ipairs(list) do all[i] = line end
        return all
    end
    local mineReagent, mineTool = mineOf(reagentLines), mineOf(toolLines)
    if #questReasons > 0 then
        if reagentLines or toolLines then result.quest = true else
            result.mark = 'quest'
            return result
        end
    end
    if #mineReagent > 0 then
        result.mark = 'hammer_mine'
        reasons[#reasons + 1] = { kind = 'profession', professions = mineReagent }
        return result
    elseif #mineTool > 0 then
        result.mark = 'hammer_mine'
        reasons[#reasons + 1] = { kind = 'profession_tool', professions = mineTool }
        return result
    end
    -- Reactivo o herramienta de un hechizo de clase (Data/ClassReagents.lua: runas del mago, ankh,
    -- fragmento de alma, venenos...). Sin moneda y sin marca (nunca martillo, que es de profesiones);
    -- no se exige que el hechizo ya este aprendido. Si ademas es material o herramienta de profesion,
    -- manda el martillo (verde o amarillo): la clase solo evita la moneda. spells solo para tu clase.
    local classReagent = ns.Data.classReagents and ns.Data.classReagents[id]
    local classReason
    if type(classReagent) == 'table' then
        local classes, own = {}, false
        for i, name in ipairs(classReagent) do
            classes[i] = name
            if name == ctx.class then own = true end
        end
        local spells = own and type(classReagent.spells) == 'table' and classReagent.spells[ctx.class] or nil
        classReason = { kind = 'class_reagent', own = own, classes = classes, class = own and ctx.class or nil,
            spells = own and (type(spells) == 'table' and spells or {}) or nil }
    end
    if reagentLines then
        result.mark = 'hammer_other'
        reasons[#reasons + 1] = { kind = 'profession', professions = copy(reagentLines) }
        return result
    elseif toolLines then
        result.mark = 'hammer_other'
        reasons[#reasons + 1] = { kind = 'profession_tool', professions = copy(toolLines) }
        return result
    end
    if classReason then
        reasons[#reasons + 1] = classReason
        return result
    end

    -- Iniciador de mision cuya mision no esta confirmada como hecha (false o nil): es util,
    -- sin marca y sin monedita aunque sea gris. Hecha pero repetible: tampoco hay moneda.
    if starterPending then
        reasons[#reasons + 1] = { kind = 'quest_starter', questID = starterPending }
        return result
    end
    if starterRepeatable then
        reasons[#reasons + 1] = { kind = 'quest_repeatable', questID = starterRepeatable }
        return result
    end
    -- Tanda 1, regla 4: mision hecha pero sin confirmar que NO es repetible (sin QuestieDB o sin el
    -- dato): no se sabe si el item vuelve a servir, asi que ninguna moneda automatica.
    if starterQuest and questDone(ctx, starterQuest) and starterRepeat ~= false then
        reasons[#reasons + 1] = { kind = 'quest_starter_done_unknown_repeat', questID = starterQuest }
        return result
    end

    -- Protecciones previas a TODA moneda automatica (gris, mision, clase): un item con efecto de
    -- uso/equipar (o sin poder saberlo: ver Player.ReadLink) o pieza de set conserva utilidad.
    if item.hasUseOrEquipSpell or item.isSetPiece then
        reasons[#reasons + 1] = { kind = 'useful' }
        return result
    end

    -- 4. Monedita: cada regla suma su motivo; basta una. Un nil de isQuestDone nunca la da.
    if item.quality == 0 and type(item.price) == 'number' and item.price > 0 then
        reasons[#reasons + 1] = { kind = 'gray' }
    end
    if starterQuest and questDone(ctx, starterQuest) then
        reasons[#reasons + 1] = { kind = 'quest_done', questID = starterQuest }
    elseif #questUses > 0 or item.classID == ITEM_CLASS_QUEST then
        -- Item de mision (objetivo, fuente o clase Mision) que ninguna mision del diario pide.
        reasons[#reasons + 1] = { kind = 'quest_not_active' }
    end
    -- Equipo que tu clase nunca puede usar: moneda SOLO si este ejemplar esta ligado (confirmado por
    -- la bolsa: item.isBound == true). Sin ligar (se puede subastar o pasar) o sin saberlo (botin,
    -- enlaces): sin moneda; motivo neutro 'class_cannot_use_tradeable' para el tooltip.
    local tradeable
    if classCannotUse(item, ctx) then
        local reason = { kind = 'class_cannot_use', classID = item.classID, subclassID = item.subclassID, subclassName = item.subclassName }
        if item.isBound == true then
            reasons[#reasons + 1] = reason
        else
            reason.kind = 'class_cannot_use_tradeable'
            tradeable = reason
        end
    end
    -- Diario con misiones sin leer (encabezado plegado en combate, sin API): el item podria ser
    -- un objetivo de mision, asi que no se da NINGUNA moneda (salvo override_sell, ya resuelto arriba).
    -- Lo mismo si el diario no supo decir si una mision que usa el item esta tomada.
    if #reasons > 0 and (ctx.questLogIncomplete or logUnknown) then
        result.reasons = { { kind = 'quest_log_incomplete' } }
        reasons = result.reasons
    elseif #reasons > 0 then
        result.mark = 'coin'
    end
    if tradeable then reasons[#reasons + 1] = tradeable end
    return result
end
