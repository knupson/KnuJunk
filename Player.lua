local _, ns = ...

-- Contexto del personaje para el clasificador y lectura de items de las bolsas.
-- Toda API del cliente se detecta antes de usarla: en Forever conviven nombres clasicos
-- y modernos (C_*) y no se asume ninguno.
local Player = {}
ns.Player = Player

local cache
local lastQuestNames -- {[nombre normalizado] = nombre} del ultimo escaneo COMPLETO del diario
local scanning = false -- true mientras se expanden/pliegan encabezados: sus eventos se ignoran
local selfChangeUntil = 0 -- los eventos que provocan esas expansiones llegan despues; se ignoran un rato
local SELF_EVENT_WINDOW = 2

function Player.Invalidate() cache = nil end

-- Solo para pruebas: deja el modulo como recien cargado.
function Player.ResetState()
    cache, lastQuestNames, scanning, selfChangeUntil = nil, nil, false, 0
end

local function now() return GetTime and GetTime() or 0 end
local function inCombat() return InCombatLockdown ~= nil and InCombatLockdown() == true end

-- Lee una lista con encabezados plegables (diario de misiones, habilidades). Si hay
-- encabezados plegados los expande (fuera de combate), llama scan() y los vuelve a plegar
-- exactamente igual. Devuelve true si scan() vio la lista completa.
--   count() -> n ; entry(i) -> title, isHeader, isCollapsed ; expand(i), collapse(i) pueden ser nil.
local function scanExpanded(count, entry, expand, collapse, scan, saveState, restoreState)
    local collapsedTitles, any = {}, false
    for index = 1, count() do
        local title, isHeader, isCollapsed = entry(index)
        if isHeader and isCollapsed then collapsedTitles[title] = true; any = true end
    end
    if not any then scan(); return true end
    if inCombat() or not expand or not collapse then scan(); return false end
    scanning = true
    local state = saveState and saveState()
    local scanned = pcall(function()
        -- De abajo hacia arriba: expandir un encabezado no mueve los indices de los de arriba.
        for index = count(), 1, -1 do
            local _, isHeader, isCollapsed = entry(index)
            if isHeader and isCollapsed then expand(index) end
        end
        scan()
    end)
    pcall(function()
        for index = count(), 1, -1 do
            local title, isHeader, isCollapsed = entry(index)
            if isHeader and not isCollapsed and collapsedTitles[title] then collapse(index) end
        end
    end)
    if restoreState then pcall(restoreState, state) end
    scanning = false
    selfChangeUntil = now() + SELF_EVENT_WINDOW
    return scanned
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
        -- Si no se puede expandir (combate o sin API) quedan las visibles: peor caso hammer_other.
        scanExpanded(function() return GetNumSkillLines() or 0 end, entry,
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
            end)
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

-- Lee el diario completo. Devuelve names ({[normalizado]=nombre} de items pedidos) y complete.
-- complete=false si quedaron misiones sin leer (encabezado plegado en combate, sin API para
-- expandir, o sin API de diario).
local function scanQuestLog()
    local names = {}
    local function add(text, kind)
        local name = objectiveItemName(text, kind)
        if name and name ~= '' then names[ns.NormalizeName(name)] = name end
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
        local save, restore
        if type(C_QuestLog.GetSelectedQuest) == 'function' and type(C_QuestLog.SetSelectedQuest) == 'function' then
            save = C_QuestLog.GetSelectedQuest
            restore = function(questID) if questID and questID ~= 0 then C_QuestLog.SetSelectedQuest(questID) end end
        end
        local complete = scanExpanded(count, entry, expand, collapse, function()
            for index = 1, count() do
                local info = C_QuestLog.GetInfo(index)
                if info and not info.isHeader and info.questID then
                    for _, objective in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                        add(objective.text, objective.type)
                    end
                end
            end
        end, save, restore)
        return names, complete
    elseif type(GetNumQuestLogEntries) == 'function' and type(GetQuestLogTitle) == 'function'
        and type(GetNumQuestLeaderBoards) == 'function' and type(GetQuestLogLeaderBoard) == 'function' then
        local function count() return (GetNumQuestLogEntries()) or 0 end
        local function entry(index)
            local title, _, _, isHeader, isCollapsed = GetQuestLogTitle(index)
            return title, isHeader, isCollapsed and isCollapsed ~= 0
        end
        local save, restore
        if type(GetQuestLogSelection) == 'function' and type(SelectQuestLogEntry) == 'function' then
            save = GetQuestLogSelection
            restore = function(selected) if selected and selected > 0 then SelectQuestLogEntry(selected) end end
        end
        local complete = scanExpanded(count, entry,
            type(ExpandQuestHeader) == 'function' and ExpandQuestHeader or nil,
            type(CollapseQuestHeader) == 'function' and CollapseQuestHeader or nil,
            function()
                for index = 1, count() do
                    local _, _, _, isHeader = GetQuestLogTitle(index)
                    if not isHeader then
                        for objective = 1, GetNumQuestLeaderBoards(index) or 0 do
                            local text, kind = GetQuestLogLeaderBoard(objective, index)
                            add(text, kind)
                        end
                    end
                end
            end, save, restore)
        return names, complete
    end
    return names, false
end

-- Devuelve questItemsInLog = {[itemID]=true} y si el diario quedo incompleto. Un escaneo
-- incompleto no reemplaza al ultimo completo: se unen (lo ya visto sigue valiendo). Sin
-- ningun escaneo completo previo, el contexto queda marcado questLogIncomplete.
-- Los objetivos traen el nombre, no el id: se resuelve con GetItemInfo(nombre) y, para lo
-- que no se pudo resolver, __index compara por el nombre del item consultado (un item de
-- mision gris no debe quedar con monedita por no haberse resuelto a tiempo).
local function buildQuestItems()
    local names, complete = scanQuestLog()
    local incomplete = false
    if complete then
        lastQuestNames = names
    elseif lastQuestNames then
        for key, name in pairs(lastQuestNames) do names[key] = names[key] or name end
    else
        incomplete = true
    end
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
    end }), incomplete
end

-- ---------------------------------------------------------------------------
-- Contexto
-- ---------------------------------------------------------------------------

local function buildContext()
    local class
    if type(UnitClass) == 'function' then class = select(2, UnitClass('player')) end
    local professions = readProfessions()
    local questItems, incomplete = buildQuestItems()
    return {
        class = class,
        professions = professions,
        isQuestDone = isQuestDone,
        questItemsInLog = questItems,
        questLogIncomplete = incomplete or nil,
        questieUses = ns.Questie and ns.Questie.Uses or nil,
        overrides = ns.DB and ns.DB.overrides or {},
    }
end

function Player.GetContext()
    -- ns.DB puede reemplazarse (primer login, pruebas): si cambio el origen, se reconstruye.
    local overrides = ns.DB and ns.DB.overrides
    if cache and overrides and cache.overrides ~= overrides then cache = nil end
    if not cache then cache = buildContext() end
    return cache
end

-- ---------------------------------------------------------------------------
-- Items
-- ---------------------------------------------------------------------------

-- Devuelve el spell del item, o false si el cliente no tiene ninguna API para preguntarlo.
local function spellOf(id)
    if C_Item and type(C_Item.GetItemSpell) == 'function' then return (C_Item.GetItemSpell(id)) end
    if type(GetItemSpell) == 'function' then return (GetItemSpell(id)) end
    return false
end

-- item = { id, quality, price, classID, subclassID, equipLoc, hasUseOrEquipSpell, isSetPiece };
-- nil si GetItemInfo aun no tiene los datos (reintentar con GET_ITEM_INFO_RECEIVED).
function Player.ReadLink(link)
    if link == nil or type(GetItemInfo) ~= 'function' then return nil end
    local id
    if type(link) == 'number' then id = link
    elseif type(link) == 'string' then id = tonumber(link:match('item:(%d+)')) end
    if not id then return nil end
    local _, _, quality, _, _, _, _, _, equipLoc, _, price, classID, subclassID, _, _, setID = GetItemInfo(link)
    if quality == nil then return nil end
    local spell = spellOf(id)
    -- Sin API de hechizos: conservador (true = nunca monedita por "clase no puede usarlo").
    local hasSpell = spell == false or spell ~= nil
    return {
        id = id,
        quality = quality,
        price = price or 0,
        classID = classID,
        subclassID = subclassID,
        equipLoc = equipLoc,
        hasUseOrEquipSpell = hasSpell,
        isSetPiece = setID ~= nil and setID ~= 0,
    }
end

function Player.ReadItem(bag, slot)
    local link, itemID
    if C_Container and type(C_Container.GetContainerItemInfo) == 'function' then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then link, itemID = info.hyperlink, info.itemID end
    elseif type(GetContainerItemLink) == 'function' then
        link = GetContainerItemLink(bag, slot)
    end
    local target = link or itemID
    if not target then return nil end
    return Player.ReadLink(target)
end

-- ---------------------------------------------------------------------------
-- Invalidacion
-- ---------------------------------------------------------------------------

local frame = CreateFrame('Frame')
-- Un evento que el cliente no conozca no debe romper la carga.
for _, event in ipairs({ 'SKILL_LINES_CHANGED', 'QUEST_LOG_UPDATE', 'QUEST_TURNED_IN', 'PLAYER_LEVEL_UP' }) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript('OnEvent', function(_, event)
    if scanning then return end
    -- Expandir/plegar encabezados dispara estos dos eventos (a veces un frame despues):
    -- no son un cambio real, y reaccionar armaria un bucle.
    if (event == 'QUEST_LOG_UPDATE' or event == 'SKILL_LINES_CHANGED') and now() < selfChangeUntil then return end
    Player.Invalidate()
end)
