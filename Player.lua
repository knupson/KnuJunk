local _, ns = ...

-- Contexto del personaje para el clasificador y lectura de items de las bolsas.
-- Toda API del cliente se detecta antes de usarla: en Forever conviven nombres clasicos
-- y modernos (C_*) y no se asume ninguno.
local Player = {}
ns.Player = Player

local cache

function Player.Invalidate() cache = nil end

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
        for index = 1, GetNumSkillLines() or 0 do
            local name, isHeader = GetSkillLineInfo(index)
            if not isHeader then
                local id = ns.ProfessionByName(name)
                if id and ns.PROFESSIONS[id] then professions[id] = true end
            end
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

-- Devuelve los nombres de item de los objetivos de tipo item de todo el diario.
local function questObjectiveItems()
    local names = {}
    local function add(text, kind)
        local name = objectiveItemName(text, kind)
        if name and name ~= '' then names[#names + 1] = name end
    end
    if C_QuestLog and type(C_QuestLog.GetNumQuestLogEntries) == 'function'
        and type(C_QuestLog.GetInfo) == 'function' and type(C_QuestLog.GetQuestObjectives) == 'function' then
        for index = 1, C_QuestLog.GetNumQuestLogEntries() or 0 do
            local info = C_QuestLog.GetInfo(index)
            if info and not info.isHeader and info.questID then
                for _, objective in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                    add(objective.text, objective.type)
                end
            end
        end
    elseif type(GetNumQuestLogEntries) == 'function' and type(GetQuestLogTitle) == 'function'
        and type(GetNumQuestLeaderBoards) == 'function' and type(GetQuestLogLeaderBoard) == 'function' then
        for index = 1, (GetNumQuestLogEntries()) or 0 do
            local _, _, _, isHeader = GetQuestLogTitle(index)
            if not isHeader then
                for objective = 1, GetNumQuestLeaderBoards(index) or 0 do
                    local text, kind = GetQuestLogLeaderBoard(objective, index)
                    add(text, kind)
                end
            end
        end
    end
    return names
end

-- {[itemID]=true} de los items que piden las misiones del diario. Los objetivos traen el
-- nombre, no el id: se resuelve con GetItemInfo(nombre) y, para lo que no se pudo
-- resolver, __index compara por nombre del item consultado (un item de mision gris no
-- puede quedar con monedita por no haberse resuelto a tiempo).
local function buildQuestItems()
    local ids, lowered = {}, {}
    for _, name in ipairs(questObjectiveItems()) do
        lowered[ns.NormalizeName(name)] = true
        if type(GetItemInfo) == 'function' then
            local _, link = GetItemInfo(name)
            local id = type(link) == 'string' and tonumber(link:match('item:(%d+)'))
            if id then ids[id] = true end
        end
    end
    return setmetatable(ids, { __index = function(_, id)
        if next(lowered) == nil or type(GetItemInfo) ~= 'function' then return nil end
        local name = GetItemInfo(id)
        if type(name) == 'string' and lowered[ns.NormalizeName(name)] then return true end
        return nil
    end })
end

-- ---------------------------------------------------------------------------
-- Contexto
-- ---------------------------------------------------------------------------

local function buildContext()
    local class
    if type(UnitClass) == 'function' then class = select(2, UnitClass('player')) end
    return {
        class = class,
        professions = readProfessions(),
        isQuestDone = isQuestDone,
        questItemsInLog = buildQuestItems(),
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
for _, event in ipairs({ 'SKILL_LINES_CHANGED', 'QUEST_LOG_UPDATE', 'QUEST_TURNED_IN', 'PLAYER_LEVEL_UP' }) do
    frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function() Player.Invalidate() end)
