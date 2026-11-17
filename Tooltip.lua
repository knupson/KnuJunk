local _, ns = ...

-- Motivo de la marca en el tooltip de un item. Solo hay lineas si el item tiene marca (moneda o
-- martillo) o un override del usuario; un item sin marca no recibe nada (cero ruido). Los motivos
-- 'quest_starter', 'quest_active' y 'quest_log_incomplete' tampoco agregan lineas.
-- Hook: TooltipDataProcessor.AddTooltipPostCall si existe; si no, OnTooltipSetItem de GameTooltip
-- e ItemRefTooltip. Todo va en pcall: un fallo nuestro nunca rompe el tooltip. Un guard por tooltip
-- evita repetir las lineas si el hook dispara dos veces para el mismo contenido.
local Tooltip = {}
ns.Tooltip = Tooltip

local ICON_SIZE = 14
local GOLD = { 1, 0.82, 0 }
local GREEN = { 0.25, 0.85, 0.35 }
local GRAY = { 0.6, 0.6, 0.6 }
local WHITE = { 1, 1, 1 }

local hooked = false
local guard = setmetatable({}, { __mode = 'k' }) -- [tooltip] = token del contenido ya procesado

local function enabled()
    local db = ns.DB
    return type(db) == 'table' and db.enabled ~= false
end

local function shows(kind)
    local show = ns.DB and ns.DB.show
    return not (type(show) == 'table' and show[kind] == false)
end

-- Icono en linea con la misma textura que dibuja Marks (el martillo con el mismo recorte).
local function icon(kind)
    local textures = ns.Marks and ns.Marks.TEXTURES
    local path = type(textures) == 'table' and textures[kind]
    if type(path) ~= 'string' then return '' end
    if kind == 'hammer' then
        return '|T' .. path .. ':' .. ICON_SIZE .. ':' .. ICON_SIZE .. ':0:0:64:64:5:59:5:59|t '
    end
    return '|T' .. path .. ':' .. ICON_SIZE .. '|t '
end

local function questName(questID)
    if type(questID) ~= 'number' then return '?' end
    if C_QuestLog and type(C_QuestLog.GetTitleForQuestID) == 'function' then
        local success, title = pcall(C_QuestLog.GetTitleForQuestID, questID)
        if success and type(title) == 'string' and title ~= '' then return title end
    end
    if type(QuestUtils_GetQuestName) == 'function' then
        local success, title = pcall(QuestUtils_GetQuestName, questID)
        if success and type(title) == 'string' and title ~= '' then return title end
    end
    return '#' .. questID
end

local function subclassName(classID, subclassID)
    if type(GetItemSubClassInfo) == 'function' and type(classID) == 'number' and type(subclassID) == 'number' then
        local success, name = pcall(GetItemSubClassInfo, classID, subclassID)
        if success and type(name) == 'string' and name ~= '' then return name end
    end
    return tostring(subclassID)
end

local function professionList(ids)
    local names = {}
    for _, skillLine in ipairs(type(ids) == 'table' and ids or {}) do
        names[#names + 1] = ns.ProfessionName(skillLine) or ('#' .. tostring(skillLine))
    end
    return table.concat(names, ', ')
end

-- Lineas {text, r, g, b} de un enlace de item; vacio si no hay marca ni override.
function Tooltip.Lines(link)
    local lines = {}
    if not enabled() or not link then return lines end
    local item = ns.Player.ReadLink(link)
    if not item then return lines end
    local result = ns.Classify(item, ns.Player.GetContext())
    local mark = type(result) == 'table' and result.mark or nil
    local reasons = type(result) == 'table' and result.reasons or {}
    local L = ns.L

    local function add(text, color, kind)
        lines[#lines + 1] = { text = (kind and icon(kind) or '') .. text, r = color[1], g = color[2], b = color[3] }
    end

    for _, reason in ipairs(reasons) do
        local kind = reason.kind
        if kind == 'override_keep' then
            add(L['Marked by hand: keep'], WHITE)
        elseif kind == 'override_sell' then
            add(L['Marked by hand: sell'], WHITE, 'coin')
        elseif mark == 'coin' and shows('coin') then
            if kind == 'gray' then
                add(L['Junk: sells'], GOLD, 'coin')
            elseif kind == 'quest_done' then
                add(L['Quest finished: %s']:format(questName(reason.questID)), GOLD, 'coin')
            elseif kind == 'class_cannot_use' then
                add(L["Your class can't use %s"]:format(subclassName(reason.classID, reason.subclassID)), GOLD, 'coin')
            end
        elseif kind == 'profession' and shows('hammer') then
            if mark == 'hammer_mine' then
                add(L['Your profession: %s']:format(professionList(reason.professions)), GREEN, 'hammer')
            elseif mark == 'hammer_other' then
                add(L["Profession you don't have: %s"]:format(professionList(reason.professions)), GRAY, 'hammer')
            end
        end
    end
    return lines
end

local function tooltipLink(tooltip, data)
    if type(tooltip.GetItem) == 'function' then
        local success, _, link = pcall(tooltip.GetItem, tooltip)
        if success and type(link) == 'string' then return link end
    end
    if type(data) == 'table' and type(data.hyperlink) == 'string' then return data.hyperlink end
end

local function decorate(tooltip, data)
    if type(tooltip) ~= 'table' or type(tooltip.AddLine) ~= 'function' then return end
    local link = tooltipLink(tooltip, data)
    if not link then return end
    -- El token del contenido: los datos del tooltip si hay (tabla nueva por cada armado); si no, el enlace.
    local token = type(data) == 'table' and data or link
    if guard[tooltip] == token then return end
    guard[tooltip] = token
    for _, line in ipairs(Tooltip.Lines(link)) do
        tooltip:AddLine(line.text, line.r, line.g, line.b)
    end
end

-- Punto de entrada de los hooks: nunca lanza.
function Tooltip.Decorate(tooltip, data)
    pcall(decorate, tooltip, data)
end

local function hookTooltip(tooltip, withSetItem)
    if type(tooltip) ~= 'table' or type(tooltip.HookScript) ~= 'function' then return end
    pcall(tooltip.HookScript, tooltip, 'OnTooltipCleared', function(self) guard[self] = nil end)
    if withSetItem then
        pcall(tooltip.HookScript, tooltip, 'OnTooltipSetItem', function(self) Tooltip.Decorate(self) end)
    end
end

-- Engancha una sola vez. Devuelve true si quedo enganchado.
function Tooltip.Hook()
    if hooked then return true end
    local processor = rawget(_G, 'TooltipDataProcessor')
    local dataType = type(Enum) == 'table' and type(Enum.TooltipDataType) == 'table' and Enum.TooltipDataType.Item
    if type(processor) == 'table' and type(processor.AddTooltipPostCall) == 'function' and dataType then
        local success = pcall(processor.AddTooltipPostCall, dataType, function(tooltip, data) Tooltip.Decorate(tooltip, data) end)
        if success then
            hookTooltip(rawget(_G, 'GameTooltip'), false)
            hookTooltip(rawget(_G, 'ItemRefTooltip'), false)
            hooked = true
            return true
        end
    end
    local found = false
    for _, name in ipairs({ 'GameTooltip', 'ItemRefTooltip' }) do
        local tooltip = rawget(_G, name)
        if type(tooltip) == 'table' and type(tooltip.HookScript) == 'function' then
            hookTooltip(tooltip, true)
            found = true
        end
    end
    hooked = found
    return found
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Tooltip.ResetState()
    hooked = false
    guard = setmetatable({}, { __mode = 'k' })
end

ns.OnLogin(function() pcall(Tooltip.Hook) end)
