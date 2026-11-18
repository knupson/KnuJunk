local _, ns = ...

-- Contexto del personaje para el clasificador y lectura de items de las bolsas.
-- Toda API del cliente se detecta antes de usarla: en Forever conviven nombres clasicos
-- y modernos (C_*) y no se asume ninguno.
local Player = {}
ns.Player = Player

local cache    -- contexto vigente (nil = sucio, se reconstruye en el proximo GetContext)
local previous -- ultimo contexto antes de ensuciarse: para avisar a OnChanged si cambio de contenido
local lastQuestFound -- {names=, titles=, ids=, idsKnown=} del ultimo escaneo COMPLETO del diario
local questMemo, skillMemo = {}, {} -- {fp=, data=}: resultado del ultimo escaneo con expansion
local scanning = false -- true mientras se expanden/pliegan encabezados: sus eventos sincronicos se ignoran
local pending = false -- hay una reconstruccion diferida programada
local changedCallbacks = {}
-- Efectos vistos en el tooltip (regla 30): [itemID] = true|false, solo lecturas completas.
local effectState = {} -- [itemID] = true|false|{pendiente}: ver resolveEffect
local scanTip -- GameTooltip oculto de respaldo (sin C_TooltipInfo), creado al primer uso
local retryAt -- momento del timer de reintento de efectos programado
local effectRevision = 0 -- sube cuando se resuelve un efecto pendiente: entra en la firma (OnChanged)
local signatures = setmetatable({}, { __mode = 'k' }) -- [ctx] = firma de contenido
-- Sube con cada alta, baja o entrega de mision: isQuestDone puede responder distinto aunque
-- el resto del contexto sea igual, y eso tiene que avisar por OnChanged. Los ecos de expandir
-- el diario (QUEST_LOG_UPDATE) no la tocan, asi que no reabren aquel bucle.
local questRevision = 0

local function markDirty()
    if cache then previous = cache end
    cache = nil
end

function Player.Invalidate() markDirty() end

-- fn(ctx) se llama tras una reconstruccion SOLO si el contenido del contexto cambio
-- (clase, profesiones, items de misiones, questLogIncomplete, revision de misiones).
function Player.OnChanged(fn) changedCallbacks[#changedCallbacks + 1] = fn end

-- Solo para pruebas: deja el modulo como recien cargado.
function Player.ResetState()
    cache, previous, lastQuestFound, scanning, pending = nil, nil, nil, false, false
    questMemo, skillMemo, changedCallbacks = {}, {}, {}
    effectState, scanTip, retryAt, effectRevision = {}, nil, nil, 0
end

local MIN_EXPAND_INTERVAL = 1 -- sin huella, no se expande mas de una vez por segundo
local function now() return GetTime and GetTime() or 0 end
local function inCombat() return InCombatLockdown ~= nil and InCombatLockdown() == true end

-- Lee una lista con encabezados plegables (diario de misiones, habilidades). Si hay
-- encabezados plegados los expande (fuera de combate), llama scan() y los vuelve a plegar
-- exactamente igual.
--   count() -> n ; entry(i) -> title, isHeader, isCollapsed ; expand(i), collapse(i) pueden ser nil.
--   fingerprint() -> string|nil describe lo visible; si coincide con la de la ultima expansion
--   (memo.fp) no se expande de nuevo: es lo que corta el bucle expandir -> evento -> reconstruir.
-- Devuelve complete, how: how = 'expanded' (scan() corrio con todo expandido), 'cached'
-- (memo.fp coincide: scan() NO corrio) o nil.
local function scanExpanded(count, entry, expand, collapse, scan, saveState, restoreState, fingerprint, memo)
    local collapsedTitles, any = {}, false
    for index = 1, count() do
        local title, isHeader, isCollapsed = entry(index)
        if isHeader and isCollapsed then
            any = true
            if title then collapsedTitles[title] = true end
        end
    end
    if not any then scan(); return true end
    -- La huella de la ultima expansion completa certifica lo escaneado aunque ahora no se
    -- pueda expandir (combate): mismo diario visible y mismo total. Aceptar, abandonar o
    -- entregar una mision borra memo.fp, asi que despues de esos eventos no certifica.
    local before = fingerprint and fingerprint()
    if before and memo and memo.fp == before then return true, 'cached' end
    if inCombat() or not expand or not collapse then scan(); return false end
    if not before and memo and memo.at and now() < memo.at + MIN_EXPAND_INTERVAL then
        -- Sin huella no se puede saber si algo cambio: se limita el ritmo de expansiones
        -- (acota el bucle expandir -> evento -> reconstruir) y mientras tanto se reusa lo ultimo.
        if memo.data then return true, 'cached' end
        return false
    end
    if memo then memo.at = now() end
    local complete, state = false, nil
    scanning = true
    pcall(function()
        state = saveState and saveState()
        -- De abajo hacia arriba: expandir un encabezado no mueve los indices de los de arriba.
        for index = count(), 1, -1 do
            local _, isHeader, isCollapsed = entry(index)
            if isHeader and isCollapsed then expand(index) end
        end
        local stillCollapsed = false
        for index = 1, count() do
            local _, isHeader, isCollapsed = entry(index)
            if isHeader and isCollapsed then stillCollapsed = true; break end
        end
        scan()
        complete = not stillCollapsed
    end)
    pcall(function()
        for index = count(), 1, -1 do
            local title, isHeader, isCollapsed = entry(index)
            if isHeader and not isCollapsed and title and collapsedTitles[title] then collapse(index) end
        end
    end)
    if restoreState then pcall(restoreState, state) end
    scanning = false
    if complete and memo and before then memo.fp = fingerprint() end
    return complete, complete and 'expanded' or nil
end

-- ---------------------------------------------------------------------------
-- Profesiones
-- ---------------------------------------------------------------------------

local function readProfessions()
    local professions = {}
    local viaModern = false
    if type(GetProfessions) == 'function' and type(GetProfessionInfo) == 'function' then
        local indexes = { GetProfessions() }
        -- GetProfessions devuelve hasta 6 posiciones; las vacias vienen en nil.
        for position = 1, 6 do
            local index = indexes[position]
            if index then
                viaModern = true
                local name, _, _, _, _, _, skillLine = GetProfessionInfo(index)
                local id = type(skillLine) == 'number' and ns.PROFESSIONS[skillLine] and skillLine
                    or ns.ProfessionByName(name)
                if id and ns.PROFESSIONS[id] then professions[id] = true end
            end
        end
    end
    if not viaModern and type(GetNumSkillLines) == 'function' and type(GetSkillLineInfo) == 'function' then
        local function entry(index)
            local name, isHeader, isExpanded = GetSkillLineInfo(index)
            -- Plegado solo si el cliente lo dice con false/0: ante un nil no se toca nada.
            return name, isHeader, isHeader and (isExpanded == false or isExpanded == 0)
        end
        local function fingerprint()
            local parts = { GetNumSkillLines() or 0 }
            for index = 1, parts[1] do
                local name, isHeader, isExpanded = GetSkillLineInfo(index)
                parts[#parts + 1] = tostring(name) .. ':' .. tostring(isHeader) .. ':' .. tostring(isExpanded)
            end
            return table.concat(parts, '|')
        end
        -- Si no se puede expandir (combate o sin API) quedan las visibles: peor caso hammer_other.
        local _, how = scanExpanded(function() return GetNumSkillLines() or 0 end, entry,
            type(ExpandSkillHeader) == 'function' and ExpandSkillHeader or nil,
            type(CollapseSkillHeader) == 'function' and CollapseSkillHeader or nil,
            function()
                for index = 1, GetNumSkillLines() or 0 do
                    local name, isHeader = GetSkillLineInfo(index)
                    if not isHeader then
                        local id = ns.ProfessionByName(name)
                        if id and ns.PROFESSIONS[id] then professions[id] = true end
                    end
                end
            end, nil, nil, fingerprint, skillMemo)
        if how == 'cached' then
            for id in pairs(skillMemo.data or {}) do professions[id] = true end
        elseif how == 'expanded' then
            skillMemo.data = {}
            for id in pairs(professions) do skillMemo.data[id] = true end
        end
    end
    return professions
end

-- ---------------------------------------------------------------------------
-- Misiones
-- ---------------------------------------------------------------------------

-- true/false segun el cliente; nil si no hay ninguna API de misiones completadas.
local function isQuestDone(questID)
    if questID == nil then return nil end
    if C_QuestLog and type(C_QuestLog.IsQuestFlaggedCompleted) == 'function' then
        return C_QuestLog.IsQuestFlaggedCompleted(questID) == true
    elseif type(IsQuestFlaggedCompleted) == 'function' then
        return IsQuestFlaggedCompleted(questID) == true
    end
    return nil
end

-- "Nombre del item: 3/5" -> "Nombre del item". Otros objetivos (muertes, etc.) no cuentan.
local function objectiveItemName(text, kind)
    if kind ~= nil and kind ~= 'item' then return nil end
    if type(text) ~= 'string' then return nil end
    return text:match('^(.-):%s*%d+%s*/%s*%d+%s*$')
end

-- Lee el diario completo. Devuelve found y complete:
--   found = { names = {[normalizado]=nombre} de items pedidos, titles = {[normalizado]=titulo de la
--   mision que lo pide}, ids = {[questID]=true} de las misiones del diario, idsKnown = true si todas
--   las misiones leidas trajeron su questID (si no, ids no alcanza para decir "no esta") }.
-- complete=false si quedaron misiones sin leer (encabezado plegado en combate, sin API para
-- expandir, o sin API de diario).
local function scanQuestLog()
    local found = { names = {}, titles = {}, ids = {}, idsKnown = true }
    local names = found.names
    local function add(text, kind, title)
        local name = objectiveItemName(text, kind)
        if name and name ~= '' then
            local key = ns.NormalizeName(name)
            names[key] = name
            if type(title) == 'string' and title ~= '' then found.titles[key] = title end
        end
    end
    local function quest(questID)
        if type(questID) == 'number' and questID > 0 then found.ids[questID] = true else found.idsKnown = false end
    end
    if C_QuestLog and type(C_QuestLog.GetNumQuestLogEntries) == 'function'
        and type(C_QuestLog.GetInfo) == 'function' and type(C_QuestLog.GetQuestObjectives) == 'function' then
        local expand = type(C_QuestLog.ExpandQuestHeader) == 'function' and C_QuestLog.ExpandQuestHeader
            or (type(ExpandQuestHeader) == 'function' and ExpandQuestHeader or nil)
        local collapse = type(C_QuestLog.CollapseQuestHeader) == 'function' and C_QuestLog.CollapseQuestHeader
            or (type(CollapseQuestHeader) == 'function' and CollapseQuestHeader or nil)
        local function count() return C_QuestLog.GetNumQuestLogEntries() or 0 end
        local function entry(index)
            local info = C_QuestLog.GetInfo(index)
            if not info then return nil end
            return info.title, info.isHeader, info.isCollapsed and info.isCollapsed ~= 0
        end
        local function fingerprint()
            local shown, total = C_QuestLog.GetNumQuestLogEntries()
            if total == nil then return nil end -- sin total no se detectan cambios ocultos
            local parts = { tostring(shown), tostring(total) }
            for index = 1, shown or 0 do
                local title, isHeader, isCollapsed = entry(index)
                parts[#parts + 1] = tostring(title) .. ':' .. tostring(isHeader) .. ':' .. tostring(isCollapsed)
            end
            return table.concat(parts, '|')
        end
        local save, restore
        if type(C_QuestLog.GetSelectedQuest) == 'function' and type(C_QuestLog.SetSelectedQuest) == 'function' then
            save = C_QuestLog.GetSelectedQuest
            restore = function(questID) if questID and questID ~= 0 then C_QuestLog.SetSelectedQuest(questID) end end
        end
        local complete, how = scanExpanded(count, entry, expand, collapse, function()
            for index = 1, count() do
                local info = C_QuestLog.GetInfo(index)
                if info and not info.isHeader then
                    quest(info.questID)
                    if info.questID then
                        for _, objective in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                            add(objective.text, objective.type, info.title)
                        end
                    end
                end
            end
        end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = found end
        return found, complete
    elseif type(GetNumQuestLogEntries) == 'function' and type(GetQuestLogTitle) == 'function'
        and type(GetNumQuestLeaderBoards) == 'function' and type(GetQuestLogLeaderBoard) == 'function' then
        local function count() return (GetNumQuestLogEntries()) or 0 end
        local function entry(index)
            local title, _, _, isHeader, isCollapsed = GetQuestLogTitle(index)
            return title, isHeader, isCollapsed and isCollapsed ~= 0
        end
        local function fingerprint()
            local shown, total = GetNumQuestLogEntries()
            if total == nil then return nil end
            local parts = { tostring(shown), tostring(total) }
            for index = 1, shown or 0 do
                local title, isHeader, isCollapsed = entry(index)
                parts[#parts + 1] = tostring(title) .. ':' .. tostring(isHeader) .. ':' .. tostring(isCollapsed)
            end
            return table.concat(parts, '|')
        end
        local save, restore
        if type(GetQuestLogSelection) == 'function' and type(SelectQuestLogEntry) == 'function' then
            save = GetQuestLogSelection
            restore = function(selected) if selected and selected > 0 then SelectQuestLogEntry(selected) end end
        end
        local complete, how = scanExpanded(count, entry,
            type(ExpandQuestHeader) == 'function' and ExpandQuestHeader or nil,
            type(CollapseQuestHeader) == 'function' and CollapseQuestHeader or nil,
            function()
                for index = 1, count() do
                    -- 8.o retorno: questID (si el cliente no lo da, idsKnown queda en false).
                    local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
                    if not isHeader then
                        quest(questID)
                        for objective = 1, GetNumQuestLeaderBoards(index) or 0 do
                            local text, kind = GetQuestLogLeaderBoard(objective, index)
                            add(text, kind, title)
                        end
                    end
                end
            end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = found end
        return found, complete
    end
    found.idsKnown = false
    return found, false
end

-- Devuelve questItemsInLog = {[itemID]=true} y si el diario quedo incompleto. Un escaneo
-- incompleto no reemplaza al ultimo completo: se unen (lo ya visto sigue protegiendo), pero
-- el contexto queda questLogIncomplete igual: el escaneo anterior no certifica misiones
-- nuevas que no se pudieron leer. Se certifica de nuevo solo con un escaneo completo.
-- Los objetivos traen el nombre, no el id: se resuelve con GetItemInfo(nombre) y, para lo
-- que no se pudo resolver, __index compara por el nombre del item consultado (un item de
-- mision gris no debe quedar con monedita por no haberse resuelto a tiempo).
local function buildQuestItems()
    local found, complete = scanQuestLog()
    local incomplete = not complete
    if complete then
        lastQuestFound = found
    elseif lastQuestFound then
        -- Copia: no se toca la tabla del memo ni la del ultimo escaneo completo.
        local merged = { names = {}, titles = {}, ids = {}, idsKnown = false }
        for _, source in ipairs({ lastQuestFound, found }) do
            for field in pairs({ names = true, titles = true, ids = true }) do
                for key, value in pairs(source[field]) do merged[field][key] = value end
            end
        end
        found = merged
    end
    local names = found.names
    local ids = {}
    for _, name in pairs(names) do
        if type(GetItemInfo) == 'function' then
            local _, link = GetItemInfo(name)
            local id = type(link) == 'string' and tonumber(link:match('item:(%d+)'))
            if id then ids[id] = true end
        end
    end
    return setmetatable(ids, { __index = function(_, id)
        if next(names) == nil or type(GetItemInfo) ~= 'function' then return nil end
        local name = GetItemInfo(id)
        if type(name) == 'string' and names[ns.NormalizeName(name)] then return true end
        return nil
    end }), incomplete, found
end

-- questInLog(questID): true si la mision esta en el diario; false si no (lo dicen los questID del
-- escaneo o C_QuestLog.IsOnQuest); nil si no se puede saber.
local function questInLogFor(found)
    return function(questID)
        if type(questID) ~= 'number' then return nil end
        if found.ids[questID] then return true end
        if found.idsKnown then return false end
        if C_QuestLog and type(C_QuestLog.IsOnQuest) == 'function' then
            local success, answer = pcall(C_QuestLog.IsOnQuest, questID)
            if success and (answer == true or answer == false) then return answer end
        end
        return nil
    end
end

-- questItemTitle(itemID): titulo de la mision del diario que pide el item, o nil.
local function questItemTitleFor(found)
    return function(itemID)
        if type(GetItemInfo) ~= 'function' or next(found.titles) == nil then return nil end
        local name = GetItemInfo(itemID)
        return type(name) == 'string' and found.titles[ns.NormalizeName(name)] or nil
    end
end

-- ---------------------------------------------------------------------------
-- Contexto
-- ---------------------------------------------------------------------------

local function sortedKeys(set)
    local list = {}
    for key in pairs(set) do list[#list + 1] = key end
    table.sort(list, function(x, y) return tostring(x) < tostring(y) end)
    return table.concat(list, ',')
end

local function buildContext()
    local class
    if type(UnitClass) == 'function' then class = select(2, UnitClass('player')) end
    local professions = readProfessions()
    local questItems, incomplete, found = buildQuestItems()
    -- QuestieDB disponible pero con el indice aun sin terminar: Uses da nil y no se sabe si el
    -- item es de una mision. Mismo trato que un diario sin leer: ninguna moneda.
    if ns.Questie and type(ns.Questie.Pending) == 'function' and ns.Questie.Pending() then incomplete = true end
    local ctx = {
        class = class,
        professions = professions,
        isQuestDone = isQuestDone,
        questInLog = questInLogFor(found),
        questItemsInLog = questItems,
        questItemTitle = questItemTitleFor(found),
        questLogIncomplete = incomplete or nil,
        questieUses = ns.Questie and ns.Questie.Uses or nil,
        overrides = ns.DB and ns.DB.overrides or {},
    }
    -- pairs ignora el __index de questItemsInLog: solo los ids ya resueltos.
    signatures[ctx] = table.concat({ tostring(class), tostring(incomplete), tostring(questRevision), tostring(effectRevision), sortedKeys(professions),
        sortedKeys(questItems), sortedKeys(found.names), sortedKeys(found.ids) }, '|')
    return ctx
end

function Player.GetContext()
    -- ns.DB puede reemplazarse (primer login, pruebas): si cambio el origen, se reconstruye.
    local overrides = ns.DB and ns.DB.overrides
    if cache and overrides and cache.overrides ~= overrides then markDirty() end
    if not cache then
        local old = previous
        previous = nil
        cache = buildContext()
        if old and signatures[old] ~= signatures[cache] then
            local fresh = cache
            for _, fn in ipairs(changedCallbacks) do pcall(fn, fresh) end
        end
    end
    return cache
end

-- ---------------------------------------------------------------------------
-- Items
-- ---------------------------------------------------------------------------

local function bare(text)
    if type(text) ~= 'string' then return nil end
    return (text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', ''):gsub('^%s+', ''))
end

-- Prefijos de las lineas de efecto: las globales del cliente (localizadas) y, por si faltan, ingles y
-- castellano. "Probabilidad al acertar" (proc de arma) tambien es un efecto.
local function triggers()
    local list = {}
    for _, global in ipairs({ 'ITEM_SPELL_TRIGGER_ONEQUIP', 'ITEM_SPELL_TRIGGER_ONUSE', 'ITEM_SPELL_TRIGGER_ONPROC' }) do
        local value = rawget(_G, global)
        if type(value) == 'string' and value ~= '' then list[#list + 1] = value end
    end
    for _, value in ipairs({ 'Equip:', 'Use:', 'Chance on hit:', 'Equipar:', 'Uso:', 'Probabilidad al acertar:' }) do
        list[#list + 1] = value
    end
    return list
end

-- Tipos de linea de C_TooltipInfo que pueden venir sin texto legitimamente (Blank, Separator).
local function blankLineType(kind)
    if type(kind) ~= 'number' then return false end
    local enum = type(Enum) == 'table' and type(Enum.TooltipDataLineType) == 'table' and Enum.TooltipDataLineType or nil
    local blank = enum and enum.Blank or 1
    local separator = enum and enum.Separator or 23
    return kind == blank or kind == separator
end

local function retrieving(text)
    local global = rawget(_G, 'RETRIEVING_ITEM_INFO')
    return type(global) == 'string' and global ~= '' and text == global
end

-- Lee el tooltip del item. Devuelve texts, how, instance:
--   how = 'complete' (todas las lineas con su texto), 'partial' (alguna linea sin texto todavia, o
--   "Recuperando informacion"), 'unavailable' (no hay forma de leerlo en este cliente).
--   instance = dataInstanceID de C_TooltipInfo, para cruzar con TOOLTIP_DATA_UPDATE.
-- C_TooltipInfo.GetHyperlink (leftText, o args sin "surface"); si no existe, un GameTooltip oculto.
local function tooltipTexts(id)
    local link = 'item:' .. id
    if type(C_TooltipInfo) == 'table' and type(C_TooltipInfo.GetHyperlink) == 'function' then
        local success, data = pcall(C_TooltipInfo.GetHyperlink, link)
        if not success or type(data) ~= 'table' or type(data.lines) ~= 'table' or #data.lines == 0 then
            return nil, 'partial'
        end
        local instance = data.dataInstanceID
        local texts, complete = {}, true
        for index, line in ipairs(data.lines) do
            local text = type(line) == 'table' and line.leftText or nil
            if text == nil and type(line) == 'table' and type(line.args) == 'table' then
                for _, arg in ipairs(line.args) do
                    if type(arg) == 'table' and arg.field == 'leftText' then text = arg.stringVal end
                end
            end
            if type(text) ~= 'string' or text == '' then
                if not (type(line) == 'table' and blankLineType(line.type)) then complete = false end
                text = ''
            elseif retrieving(text) then
                complete = false
            end
            texts[index] = text
        end
        if texts[1] == '' then complete = false end -- sin el nombre: el cliente aun no tiene el item
        return texts, complete and 'complete' or 'partial', instance
    end
    if type(CreateFrame) ~= 'function' then return nil, 'unavailable' end
    local success, texts, how = pcall(function()
        if not scanTip then
            scanTip = CreateFrame('GameTooltip', 'KnuJunkScanTooltip', nil, 'GameTooltipTemplate')
        end
        if type(scanTip.NumLines) ~= 'function' or type(scanTip.SetHyperlink) ~= 'function' then return nil, 'unavailable' end
        if type(scanTip.SetOwner) == 'function' then scanTip:SetOwner(rawget(_G, 'WorldFrame') or UIParent, 'ANCHOR_NONE') end
        if type(scanTip.ClearLines) == 'function' then scanTip:ClearLines() end
        scanTip:SetHyperlink(link)
        local count = scanTip:NumLines()
        if type(count) ~= 'number' or count == 0 then return nil, 'partial' end
        local list, complete = {}, true
        for index = 1, count do
            local region = rawget(_G, 'KnuJunkScanTooltipTextLeft' .. index)
            local text = type(region) == 'table' and type(region.GetText) == 'function' and region:GetText() or nil
            -- Sin tipos de linea no se distingue un blanco legitimo: texto ausente o vacio = parcial.
            if type(text) ~= 'string' or text == '' or retrieving(text) then complete = false; text = '' end
            list[index] = text
        end
        return list, complete and 'complete' or 'partial'
    end)
    if success then return texts, how end
    return nil, 'partial'
end

-- Busca una linea de efecto. true si aparece (aunque la lectura sea parcial: es evidencia); false solo
-- con lectura completa sin efecto; nil si no se sabe. second = how, instance.
local function scanEffect(id)
    local texts, how, instance = tooltipTexts(id)
    if texts then
        local prefixes = triggers()
        for index = 2, #texts do
            local text = bare(texts[index]) or ''
            for _, prefix in ipairs(prefixes) do
                if text ~= '' and text:sub(1, #prefix) == prefix then return true end
            end
        end
        if how == 'complete' then return false end
    end
    return nil, how, instance
end

-- Estado por itemID (regla 30): true / false definitivos, o una tabla pendiente
-- { attempts, nextAt, final, instance }. Un pendiente no se re-escanea en cada repintado: se reintenta
-- con espera creciente (EFFECT_BACKOFF * 2^n), antes si llega TOOLTIP_DATA_UPDATE (mismo
-- dataInstanceID) o GET_ITEM_INFO_RECEIVED del item, y como mucho MAX_EFFECT_ATTEMPTS veces; despues
-- queda "no se sabe" (sin moneda). Al resolverse se avisa una sola vez (agrupado) por OnChanged.
local MAX_EFFECT_ATTEMPTS, EFFECT_BACKOFF = 5, 0.5
local scheduleEffectRetry

local function resolveEffect(id, forced)
    local state = effectState[id]
    if state == true or state == false then return state end
    if type(state) == 'table' and (state.final or (not forced and now() < state.nextAt)) then return nil end
    local answer, how, instance = scanEffect(id)
    if answer ~= nil then
        effectState[id] = answer
        return answer
    end
    state = type(state) == 'table' and state or { attempts = 0 }
    state.attempts = state.attempts + 1
    state.instance = instance
    if how == 'unavailable' or state.attempts >= MAX_EFFECT_ATTEMPTS then
        state.final = true
    else
        state.nextAt = now() + EFFECT_BACKOFF * 2 ^ (state.attempts - 1)
        scheduleEffectRetry(state.nextAt)
    end
    effectState[id] = state
    return nil
end

local function retryEffects()
    local resolved, earliest = false, nil
    for id, state in pairs(effectState) do
        if type(state) == 'table' and not state.final and now() >= state.nextAt then
            if resolveEffect(id, true) ~= nil then resolved = true end
        end
    end
    for _, state in pairs(effectState) do
        if type(state) == 'table' and not state.final and (not earliest or state.nextAt < earliest) then earliest = state.nextAt end
    end
    if earliest then scheduleEffectRetry(earliest) end
    if resolved then
        effectRevision = effectRevision + 1
        markDirty()
        if #changedCallbacks > 0 then Player.GetContext() end
    end
end

-- Un solo timer, para el reintento mas proximo.
scheduleEffectRetry = function(at)
    if not (C_Timer and C_Timer.After) then return end
    if retryAt and retryAt <= at then return end
    retryAt = at
    C_Timer.After(math.max(0, at - now()), function()
        if retryAt ~= at then return end -- reemplazado por uno mas proximo
        retryAt = nil
        retryEffects()
    end)
end

-- Adelanta el reintento de los pendientes que cumplan match(id, state).
local function hurryEffects(match)
    local any = false
    for id, state in pairs(effectState) do
        if type(state) == 'table' and not state.final and match(id, state) then
            state.nextAt = now()
            any = true
        end
    end
    if any then scheduleEffectRetry(now()) end
end

-- true si el item tiene (o puede tener) efecto de uso/equipar; false solo si GetItemSpell respondio
-- sin nombre NI id Y el tooltip del item se leyo sin ninguna linea "Equipar:"/"Uso:"/"Probabilidad
-- al acertar:" (regla 30: los efectos pasivos de equipar no siempre los informa GetItemSpell). Se
-- conservan los dos retornos: el nombre puede llegar tarde y el id solo ya es evidencia. Sin API, si
-- la API falla o si el tooltip no se puede leer, no se sabe: true (conservador, ninguna moneda).
local function hasItemSpell(id)
    local api
    if C_Item and type(C_Item.GetItemSpell) == 'function' then api = C_Item.GetItemSpell
    elseif type(GetItemSpell) == 'function' then api = GetItemSpell end
    if not api then return true end
    local success, name, spellID = pcall(api, id)
    if not success then return true end
    if name ~= nil or spellID ~= nil then return true end
    local effect = resolveEffect(id, false)
    if effect == nil then return true end
    return effect
end

-- item = { id, quality, price, classID, subclassID, subclassName, equipLoc, hasUseOrEquipSpell, isSetPiece };
-- nil si GetItemInfo aun no tiene los datos (reintentar con GET_ITEM_INFO_RECEIVED). Sin ubicacion no
-- se sabe si esta ligado: isBound queda en nil (ReadItem lo completa).
function Player.ReadLink(link)
    if link == nil or type(GetItemInfo) ~= 'function' then return nil end
    local id
    if type(link) == 'number' then id = link
    elseif type(link) == 'string' then id = tonumber(link:match('item:(%d+)')) end
    if not id then return nil end
    local _, _, quality, _, _, _, subclassName, _, equipLoc, _, price, classID, subclassID, _, _, setID = GetItemInfo(link)
    if quality == nil then return nil end
    local hasSpell = hasItemSpell(id)
    return {
        id = id,
        quality = quality,
        price = price or 0,
        classID = classID,
        subclassID = subclassID,
        subclassName = subclassName,
        equipLoc = equipLoc,
        hasUseOrEquipSpell = hasSpell,
        isSetPiece = setID ~= nil and setID ~= 0,
    }
end

-- true/false si el cliente confirma si el ejemplar de bag/slot esta ligado; nil si no se sabe.
-- Primero C_Item.IsBound(ItemLocation); si falta, falla o no responde un booleano, el isBound de
-- C_Container.GetContainerItemInfo (info ya leida).
local function boundAt(bag, slot, info)
    if type(C_Item) == 'table' and type(C_Item.IsBound) == 'function'
        and type(ItemLocation) == 'table' and type(ItemLocation.CreateFromBagAndSlot) == 'function' then
        local success, answer = pcall(function()
            return C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot))
        end)
        if success and (answer == true or answer == false) then return answer end
    end
    if type(info) == 'table' and (info.isBound == true or info.isBound == false) then return info.isBound end
    return nil
end

-- Como ReadLink, mas isBound (regla 8: equipo de otra clase da moneda solo si esta ligado).
function Player.ReadItem(bag, slot)
    local link, itemID, info
    if C_Container and type(C_Container.GetContainerItemInfo) == 'function' then
        info = C_Container.GetContainerItemInfo(bag, slot)
        if info then link, itemID = info.hyperlink, info.itemID end
    elseif type(GetContainerItemLink) == 'function' then
        link = GetContainerItemLink(bag, slot)
    end
    local target = link or itemID
    if not target then return nil end
    local item = Player.ReadLink(target)
    if item then item.isBound = boundAt(bag, slot, info) end
    return item
end

-- ---------------------------------------------------------------------------
-- Invalidacion
-- ---------------------------------------------------------------------------

local frame = CreateFrame('Frame')
-- Todo evento que pueda cambiar el contexto lo ensucia; la reconstruccion es perezosa. Un
-- evento que el cliente no conozca no debe romper la carga.
for _, event in ipairs({ 'QUEST_LOG_UPDATE', 'SKILL_LINES_CHANGED', 'QUEST_ACCEPTED', 'QUEST_REMOVED',
    'QUEST_TURNED_IN', 'PLAYER_LEVEL_UP', 'PLAYER_REGEN_ENABLED' }) do
    pcall(frame.RegisterEvent, frame, event)
end

-- Una reconstruccion diferida (agrupada) para que OnChanged se entere de cambios reales aunque
-- nadie pida el contexto. Expandir encabezados provoca otro evento, pero esa segunda
-- reconstruccion no expande (misma huella) y no cambia el contenido: no avisa y se corta ahi.
local function scheduleCheck()
    if pending or #changedCallbacks == 0 or not (C_Timer and C_Timer.After) then return end
    pending = true
    C_Timer.After(0.2, function()
        pending = false
        if #changedCallbacks > 0 then Player.GetContext() end
    end)
end

pcall(frame.RegisterEvent, frame, 'TOOLTIP_DATA_UPDATE')
pcall(frame.RegisterEvent, frame, 'GET_ITEM_INFO_RECEIVED')

frame:SetScript('OnEvent', function(_, event, arg1)
    -- Datos de tooltip o de item que llegan: solo adelantan reintentos de efectos pendientes, sin
    -- ensuciar el contexto.
    if event == 'TOOLTIP_DATA_UPDATE' then
        hurryEffects(function(_, state) return arg1 == nil or state.instance == nil or state.instance == arg1 end)
        return
    elseif event == 'GET_ITEM_INFO_RECEIVED' then
        hurryEffects(function(id) return id == arg1 end)
        return
    end
    if scanning then return end -- eco sincronico de nuestra propia expansion
    -- Aceptar/abandonar/entregar una mision puede cambiar el diario sin cambiar la huella (mismo
    -- total bajo un encabezado plegado): se olvida lo escaneado. QUEST_LOG_UPDATE no, porque es
    -- tambien el eco de nuestra propia expansion.
    if event == 'QUEST_ACCEPTED' or event == 'QUEST_REMOVED' or event == 'QUEST_TURNED_IN' then
        questMemo.fp, questMemo.at = nil, nil
        questRevision = questRevision + 1
    end
    markDirty()
    scheduleCheck()
end)
