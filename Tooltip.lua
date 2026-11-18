local _, ns = ...

-- Motivo de la marca en el tooltip de un item. Hay lineas si el item tiene marca (moneda, martillo o
-- mision), un override del usuario o es iniciador de una mision no hecha; un item sin nada de eso no
-- recibe nada (cero ruido). 'quest_log_incomplete' no agrega lineas. 'quest_active' (lo pide una
-- mision del diario: marca 'quest', o martillo con result.quest) explica por que no hay moneda:
-- 'Mision activa: <titulo>' o, sin titulo ni questID, 'Lo pide una mision activa'.
-- 'quest_starter': 'Inicia una mision que no hiciste: <titulo>'. 'quest_starter_done_unknown_repeat'
-- (sin marca): 'Mision entregada; no se sabe si es repetible'. 'quest_not_active' (moneda):
-- 'Ninguna mision activa lo pide'. 'library_book' y 'waylaid_crate' (sin marca): linea neutra con el
-- PNJ de entrega de la faccion del jugador (los dos si no se sabe). 'class_cannot_use_tradeable' (sin
-- marca): 'Tu clase no puede usar <subtipo>: podes subastarlo o pasarlo a otro personaje', sin icono.
-- Hook: TooltipDataProcessor.AddTooltipPostCall si existe; si no, OnTooltipSetItem de GameTooltip
-- e ItemRefTooltip. Todo va en pcall: un fallo nuestro nunca rompe el tooltip. Solo se atienden GameTooltip e
-- ItemRefTooltip; no se repiten las lineas si el hook dispara dos veces (se miran las lineas ya puestas).
local Tooltip = {}
ns.Tooltip = Tooltip

local ICON_SIZE = 14
local GOLD = { 1, 0.82, 0 }
local GREEN = { 0.25, 0.85, 0.35 }
local GRAY = { 1, 0.85, 0.2 } -- amarillo, igual que el martillo ajeno
local WHITE = { 1, 1, 1 }

local hooked = false
local guard = setmetatable({}, { __mode = 'k' }) -- [tooltip] = { link, done[texto] } (respaldo si no se leen sus lineas)

local function enabled()
    local db = ns.DB
    return type(db) == 'table' and db.enabled ~= false
end

local function shows(kind)
    local show = ns.DB and ns.DB.show
    return not (type(show) == 'table' and show[kind] == false)
end

-- Icono en linea con la misma textura que dibuja Marks; el martillo lleva el mismo tinte que su
-- marca (|T ruta:alto:ancho:x:y:tamX:tamY:izq:der:arr:abj:r:g:b|t, con r/g/b en 0-255).
local function icon(kind, mark)
    local textures = ns.Marks and ns.Marks.TEXTURES
    local path = type(textures) == 'table' and textures[kind]
    if type(path) ~= 'string' then return '' end
    if kind == 'hammer' then
        local tints = ns.Marks.TINTS
        local tint = type(tints) == 'table' and tints[mark] or WHITE
        return '|T' .. path .. ':' .. ICON_SIZE .. ':' .. ICON_SIZE .. ':0:0:64:64:0:64:0:64:'
            .. math.floor(tint[1] * 255 + 0.5) .. ':' .. math.floor(tint[2] * 255 + 0.5) .. ':'
            .. math.floor(tint[3] * 255 + 0.5) .. '|t '
    end
    local atlas = kind == 'coin' and ns.Marks.COIN_ATLAS
    if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        return '|A:' .. atlas .. ':' .. ICON_SIZE .. ':' .. ICON_SIZE .. '|a '
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
    if ns.Questie and type(ns.Questie.QuestName) == 'function' then
        local success, title = pcall(ns.Questie.QuestName, questID)
        if success and type(title) == 'string' and title ~= '' then return title end
    end
    return '#' .. questID
end

-- El nombre ya localizado que trae el item (7mo valor de GetItemInfo) gana; despues
-- GetItemSubClassInfo; al final el numero.
local function subclassName(given, classID, subclassID)
    if type(given) == 'string' and given ~= '' then return given end
    if type(GetItemSubClassInfo) == 'function' and type(classID) == 'number' and type(subclassID) == 'number' then
        local success, name = pcall(GetItemSubClassInfo, classID, subclassID)
        if success and type(name) == 'string' and name ~= '' then return name end
    end
    return tostring(subclassID)
end

-- Nombre localizado de un hechizo (C_Spell.GetSpellName o GetSpellInfo), o nil.
local function spellName(spellID)
    local api
    if type(C_Spell) == 'table' and type(C_Spell.GetSpellName) == 'function' then api = C_Spell.GetSpellName
    elseif type(GetSpellInfo) == 'function' then api = GetSpellInfo end
    if not api then return nil end
    local success, name = pcall(api, spellID)
    if success and type(name) == 'string' and name ~= '' then return name end
end

local function classList(tokens)
    local names = {}
    for _, token in ipairs(type(tokens) == 'table' and tokens or {}) do names[#names + 1] = ns.ClassName(token) end
    return table.concat(names, ', ')
end

local function professionList(ids)
    local names = {}
    for _, skillLine in ipairs(type(ids) == 'table' and ids or {}) do
        names[#names + 1] = ns.ProfessionName(skillLine) or ('#' .. tostring(skillLine))
    end
    return table.concat(names, ', ')
end

-- PNJ que recibe el libro o el cajon segun la faccion del jugador; los dos si no se sabe.
local function byFaction(horde, alliance)
    local faction
    if type(UnitFactionGroup) == 'function' then
        local success, value = pcall(UnitFactionGroup, 'player')
        if success then faction = value end
    end
    if faction == 'Horde' then return horde end
    if faction == 'Alliance' then return alliance end
    return horde .. ' / ' .. alliance
end

local function reputationNames(ids)
    local names = {}
    for _, id in ipairs(ids or {}) do
        local name
        if type(C_Reputation) == 'table' and type(C_Reputation.GetFactionDataByID) == 'function' then
            local good, data = pcall(C_Reputation.GetFactionDataByID, id)
            if good and type(data) == 'table' then name = data.name end
        end
        if (type(name) ~= 'string' or name == '') and type(GetFactionInfoByID) == 'function' then
            local good, value = pcall(GetFactionInfoByID, id)
            if good then name = value end
        end
        names[#names + 1] = type(name) == 'string' and name ~= '' and name or ns.L['Faction #%d']:format(id)
    end
    return #names > 0 and table.concat(names, ', ') or ns.L['unknown faction']
end

-- Líneas {text, r, g, b}, incluidos motivos de protección sin marca. bound = true si el
-- propio tooltip confirma que el ejemplar está ligado (ver boundFromTooltip); nil = no se sabe.
function Tooltip.Lines(link, bound, bag, slot)
    local lines = {}
    if not enabled() or not link then return lines end
    local item
    if bag ~= nil then item = ns.Player.ReadItem(bag, slot) else item = ns.Player.ReadLink(link) end
    if not item then return lines end
    if bag ~= nil then
        local id = type(link) == 'string' and tonumber(link:match('item:(%d+)')) or link
        if item.id ~= id then return lines end
    end
    if bound == true then item.isBound = true end
    local result = ns.Classify(item, ns.Player.GetContext())
    local mark = type(result) == 'table' and result.mark or nil
    local reasons = type(result) == 'table' and result.reasons or {}
    local L = ns.L

    local function add(text, color, kind)
        lines[#lines + 1] = { text = (kind and icon(kind, mark) or '') .. text, r = color[1], g = color[2], b = color[3] }
    end

    for _, reason in ipairs(reasons) do
        local kind = reason.kind
        if kind == 'recipe_known_tradeable' and mark == nil then
            add(L['You already know it; you can pass it on or auction it'], WHITE)
        elseif kind == 'override_keep' then
            add(L['Marked by hand: keep'], WHITE)
        elseif kind == 'override_sell' then
            add(L['Marked by hand: sell'], WHITE, 'coin')
        elseif kind == 'key' then
            add(L['Key: opens a lock; keep it'], WHITE)
        elseif kind == 'lockbox' then
            add(L['Locked box: open it before selling (lockpick or key)'], WHITE)
        elseif kind == 'reputation_token' then
            add(L['Turn in for reputation: %s']:format(reputationNames(reason.factionIDs)), WHITE)
        elseif kind == 'library_book' then
            add(L['Library book: turn it in to the librarian (%s)']:format(
                byFaction(L['Owen Thadd in Undercity'], L['Garion Wendell in Stormwind'])), WHITE)
        elseif kind == 'waylaid_crate' then
            local npc = byFaction(L['Dokimi (Crossroads)'], L['Marcy Baker (Redridge)'])
            if reason.sealed then
                add(L['Sealed waylaid crate: turn it in to %s']:format(npc), WHITE)
            else
                add(L['Waylaid crate: fill it with one option from the list and turn it in to %s']:format(npc), WHITE)
            end
        elseif mark == 'coin' and shows('coin') then
            if kind == 'gray' then
                add(L['Junk: sells'], GOLD, 'coin')
            elseif kind == 'food_outgrown' then
                add(L['You have better food/drink for your level'], GOLD, 'coin')
            elseif kind == 'ammo_outgrown' then
                add(L['You have compatible ammunition with higher damage'], GOLD, 'coin')
            elseif kind == 'recipe_known' then
                add(L['You already know this recipe'], GOLD, 'coin')
            elseif kind == 'quest_done' then
                add(L['Quest finished: %s']:format(questName(reason.questID)), GOLD, 'coin')
            elseif kind == 'quest_not_active' then
                add(L['No active quest needs it'], GOLD, 'coin')
            elseif kind == 'class_cannot_use' then
                add(L["Your class can't use %s"]:format(subclassName(reason.subclassName or item.subclassName, reason.classID, reason.subclassID)), GOLD, 'coin')
            end
        elseif kind == 'class_reagent' and mark == nil then
            -- Reactivo de hechizo de clase: neutro y sin icono. Tu clase: el primer hechizo con nombre
            -- (y cuantos mas lo usan); sin nombre, generico. Otra clase: solo la clase.
            if reason.own then
                local spells = type(reason.spells) == 'table' and reason.spells or {}
                local name
                for _, spellID in ipairs(spells) do
                    name = spellName(spellID)
                    if name then break end
                end
                if name then
                    if #spells > 1 then name = L['%s and %d more']:format(name, #spells - 1) end
                    add(L['%s reagent: %s']:format(ns.ClassName(reason.class or (reason.classes or {})[1]), name), WHITE)
                else
                    add(L["Reagent for your class's spells"], WHITE)
                end
            else
                add(L['%s reagent']:format(classList(reason.classes)), WHITE)
            end
        elseif kind == 'class_cannot_use_tradeable' and mark == nil then
            -- Sin ligar o sin saberlo: no es basura, se puede vender en subasta o pasar (sin icono).
            add(L["Your class can't use %s: you can auction it or pass it to another character"]:format(
                subclassName(reason.subclassName or item.subclassName, reason.classID, reason.subclassID)), WHITE)
        elseif kind == 'quest_active' and (mark == 'quest' or (result.quest == true and shows('hammer'))) then
            -- Lo pide una mision del diario (marca de mision, o martillo si es reactivo/herramienta):
            -- se explica la mision en neutro, con su icono; nunca moneda.
            if reason.questID ~= nil then
                add(L['Active quest: %s']:format(questName(reason.questID)), WHITE, 'quest')
            elseif type(reason.title) == 'string' and reason.title ~= '' then
                add(L['Active quest: %s']:format(reason.title), WHITE, 'quest')
            else
                add(L['Needed by an active quest'], WHITE, 'quest')
            end
        elseif kind == 'quest_starter' and mark == nil then
            add(L["Starts a quest you haven't done: %s"]:format(questName(reason.questID)), WHITE, 'quest')
        elseif kind == 'quest_starter_done_unknown_repeat' and mark == nil then
            add(L["Quest turned in; unknown if it's repeatable"], WHITE)
        elseif kind == 'future_level' and mark == nil then
            add(L['Usable from level %d']:format(reason.level), WHITE)
        elseif kind == 'recipe' and shows('hammer') then
            local text = L['Recipe for %s']:format(professionList({ reason.skillLine }))
            if reason.rank then text = text .. L[', requires %d']:format(reason.rank) end
            add(text, mark == 'hammer_mine' and GREEN or GRAY, 'hammer')
        elseif kind == 'profession' and shows('hammer') then
            if mark == 'hammer_mine' then
                add(L['Your profession: %s']:format(professionList(reason.professions)), GREEN, 'hammer')
            elseif mark == 'hammer_other' then
                add(L["Profession you don't have: %s"]:format(professionList(reason.professions)), GRAY, 'hammer')
            end
        elseif kind == 'profession_tool' and shows('hammer') then
            if mark == 'hammer_mine' then
                add(L['Tool for your profession: %s']:format(professionList(reason.professions)), GREEN, 'hammer')
            elseif mark == 'hammer_other' then
                add(L["Tool for a profession you don't have: %s"]:format(professionList(reason.professions)), GRAY, 'hammer')
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

-- Texto sin el icono en linea (|T..|t) ni espacios de los bordes: el cliente podria devolver las
-- lineas sin el escape, y se compara igual.
local function plain(text)
    if type(text) ~= 'string' then return nil end
    text = text:gsub('|T.-|t', ''):gsub('^%s+', ''):gsub('%s+$', '')
    return text
end

-- Lineas de `lines` que el tooltip aun no tiene, linea por linea (una decoracion parcial se completa
-- al reintentar sin repetir las ya puestas). Las regiones <nombre>TextLeft<i> leibles son la
-- autoridad: si el tooltip las expone, se mira solo lo que dicen. Si no se pueden leer (sin
-- NumLines / nombre / regiones), se usa el registro propio: guard[tooltip] = { link, done[texto] },
-- que OnTooltipCleared borra.
local function missingLines(tooltip, link, lines)
    if type(tooltip.NumLines) == 'function' and type(tooltip.GetName) == 'function' then
        local success, count = pcall(tooltip.NumLines, tooltip)
        local name = success and tooltip:GetName()
        if success and type(count) == 'number' and type(name) == 'string' then
            local present, readable = {}, count == 0
            for index = 1, count do
                local region = rawget(_G, name .. 'TextLeft' .. index)
                if type(region) == 'table' and type(region.GetText) == 'function' then
                    local got, text = pcall(region.GetText, region)
                    if got and type(text) == 'string' then
                        readable = true
                        present[plain(text)] = true
                    end
                end
            end
            if readable then
                local missing = {}
                for _, line in ipairs(lines) do
                    if not present[plain(line.text)] then missing[#missing + 1] = line end
                end
                return missing
            end
        end
    end
    local record = guard[tooltip]
    if type(record) ~= 'table' or record.link ~= link then return lines end
    local missing = {}
    for _, line in ipairs(lines) do
        if not record.done[line.text] then missing[#missing + 1] = line end
    end
    return missing
end

-- Texto de linea sin codigos de color ni espacios de los bordes.
local function bare(text)
    if type(text) ~= 'string' then return nil end
    return (text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

-- true si el tooltip muestra la linea "Ligado" (ITEM_SOULBOUND; sin la global, ingles y castellano):
-- el cliente la pone en los items de la bolsa ya ligados ("Se liga al recogerlo" del botin o de un
-- enlace NO cuenta). nil si no aparece o no se puede leer (= no se sabe).
local function boundFromTooltip(tooltip, data)
    local wanted = {}
    local global = rawget(_G, 'ITEM_SOULBOUND')
    if type(global) == 'string' and global ~= '' then wanted[global] = true end
    wanted['Soulbound'], wanted['Ligado'] = true, true
    if type(data) == 'table' and type(data.lines) == 'table' then
        for _, entry in ipairs(data.lines) do
            if type(entry) == 'table' and wanted[bare(entry.leftText) or ''] then return true end
        end
    end
    if type(tooltip.NumLines) == 'function' and type(tooltip.GetName) == 'function' then
        local success, count = pcall(tooltip.NumLines, tooltip)
        local named, name = pcall(tooltip.GetName, tooltip)
        if success and type(count) == 'number' and named and type(name) == 'string' then
            for index = 1, count do
                local region = rawget(_G, name .. 'TextLeft' .. index)
                if type(region) == 'table' and type(region.GetText) == 'function' then
                    local got, text = pcall(region.GetText, region)
                    if got and wanted[bare(text) or ''] then return true end
                end
            end
        end
    end
    return nil
end

local function decorate(tooltip, data, bag, slot)
    if type(tooltip) ~= 'table' or type(tooltip.AddLine) ~= 'function' or not supported(tooltip) then return end
    local link = tooltipLink(tooltip, data)
    if tooltip == rawget(_G, 'GameTooltip') then
        ns.Overrides.hovered = type(link) == 'string' and tonumber(link:match('item:(%d+)')) or nil
    end
    if not link then return end
    if bag == nil and type(tooltip.GetBagItem) == 'function' then
        local good, b, s = pcall(tooltip.GetBagItem, tooltip)
        if good and type(b) == 'number' and type(s) == 'number' then bag, slot = b, s end
    end
    local lines = Tooltip.Lines(link, boundFromTooltip(tooltip, data), bag, slot)
    if #lines == 0 then return end
    local missing = missingLines(tooltip, link, lines)
    if #missing == 0 then return end
    local record = guard[tooltip]
    if type(record) ~= 'table' or record.link ~= link then
        record = { link = link, done = {} }
        guard[tooltip] = record
    end
    for _, line in ipairs(missing) do
        tooltip:AddLine(line.text, line.r, line.g, line.b)
        record.done[line.text] = true -- solo tras agregar: lo que falla se reintenta
    end
end

-- Punto de entrada de los hooks: nunca lanza.
function Tooltip.Decorate(tooltip, data, bag, slot)
    pcall(decorate, tooltip, data, bag, slot)
end

local function hookTooltip(tooltip, withSetItem)
    if type(tooltip) ~= 'table' or type(tooltip.HookScript) ~= 'function' then return end
    local function clear(self)
        guard[self] = nil
        if self == rawget(_G, 'GameTooltip') then ns.Overrides.hovered = nil end
    end
    pcall(tooltip.HookScript, tooltip, 'OnTooltipCleared', clear)
    pcall(tooltip.HookScript, tooltip, 'OnHide', clear)
    if type(tooltip.SetBagItem) == 'function' and type(hooksecurefunc) == 'function' then
        pcall(hooksecurefunc, tooltip, 'SetBagItem', function(self, bag, slot) Tooltip.Decorate(self, nil, bag, slot) end)
    end
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
    ns.Overrides.hovered = nil
    hooked = false
    guard = setmetatable({}, { __mode = 'k' })
end

ns.OnLogin(function() pcall(Tooltip.Hook) end)
