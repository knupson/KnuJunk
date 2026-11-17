local _, ns = ...

-- Motivo de la marca en el tooltip de un item. Solo hay lineas si el item tiene marca (moneda o
-- martillo) o un override del usuario; un item sin marca no recibe nada (cero ruido). Los motivos
-- 'quest_starter', 'quest_active' y 'quest_log_incomplete' tampoco agregan lineas.
-- Hook: TooltipDataProcessor.AddTooltipPostCall si existe; si no, OnTooltipSetItem de GameTooltip
-- e ItemRefTooltip. Todo va en pcall: un fallo nuestro nunca rompe el tooltip. Solo se atienden GameTooltip e
-- ItemRefTooltip; no se repiten las lineas si el hook dispara dos veces (se miran las lineas ya puestas).
local Tooltip = {}
ns.Tooltip = Tooltip

local ICON_SIZE = 14
local GOLD = { 1, 0.82, 0 }
local GREEN = { 0.25, 0.85, 0.35 }
local GRAY = { 0.6, 0.6, 0.6 }
local WHITE = { 1, 1, 1 }

local hooked = false
local guard = setmetatable({}, { __mode = 'k' }) -- [tooltip] = enlace ya decorado (respaldo si no se leen sus lineas)

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

-- Enlace del item mostrado: GetItem, el hyperlink de los datos, TooltipUtil.GetDisplayedItem y, por
-- ultimo, el GUID de los datos (items modernos que solo traen guid). Todo detectado y en pcall.
local function tooltipLink(tooltip, data)
    if type(tooltip.GetItem) == 'function' then
        local success, _, link = pcall(tooltip.GetItem, tooltip)
        if success and type(link) == 'string' then return link end
    end
    if type(data) == 'table' and type(data.hyperlink) == 'string' then return data.hyperlink end
    local util = rawget(_G, 'TooltipUtil')
    if type(util) == 'table' and type(util.GetDisplayedItem) == 'function' then
        local success, _, link = pcall(util.GetDisplayedItem, tooltip)
        if success and type(link) == 'string' then return link end
    end
    if type(data) == 'table' and data.guid ~= nil and type(C_Item) == 'table'
        and type(C_Item.GetItemLinkByGUID) == 'function' then
        local success, link = pcall(C_Item.GetItemLinkByGUID, data.guid)
        if success and type(link) == 'string' then return link end
    end
end

-- Solo se atienden estos dos tooltips (muestran items de cualquier origen); cualquier otro se ignora.
local function supported(tooltip)
    return tooltip == rawget(_G, 'GameTooltip') or tooltip == rawget(_G, 'ItemRefTooltip')
end

-- ¿Ya tiene el tooltip alguna de nuestras lineas? Se leen sus lineas de la izquierda
-- (<nombre>TextLeft<i>); si no se pueden leer, se recurre al registro (tooltip -> enlace ya
-- decorado), que OnTooltipCleared borra.
local function alreadyDecorated(tooltip, link, lines)
    if type(tooltip.GetNumLines) == 'function' and type(tooltip.GetName) == 'function' then
        local success, count = pcall(tooltip.GetNumLines, tooltip)
        local name = success and tooltip:GetName()
        if success and type(count) == 'number' and type(name) == 'string' then
            local wanted = {}
            for _, line in ipairs(lines) do wanted[line.text] = true end
            local readable = count == 0
            for index = 1, count do
                local region = rawget(_G, name .. 'TextLeft' .. index)
                if type(region) == 'table' and type(region.GetText) == 'function' then
                    readable = true
                    local ok, text = pcall(region.GetText, region)
                    if ok and wanted[text] then return true end
                end
            end
            if readable then return false end
        end
    end
    return guard[tooltip] == link
end

local function decorate(tooltip, data)
    if type(tooltip) ~= 'table' or type(tooltip.AddLine) ~= 'function' or not supported(tooltip) then return end
    local link = tooltipLink(tooltip, data)
    if not link then return end
    local lines = Tooltip.Lines(link)
    if #lines == 0 or alreadyDecorated(tooltip, link, lines) then return end
    for _, line in ipairs(lines) do
        tooltip:AddLine(line.text, line.r, line.g, line.b)
    end
    guard[tooltip] = link -- solo tras agregar: un intento pendiente o fallido se reintenta
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
