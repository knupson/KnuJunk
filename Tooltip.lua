local _, ns = ...

-- Leyenda de la marca con su color y precios de subasta; conserva los motivos anteriores.
-- Sólo GameTooltip e ItemRefTooltip, callbacks protegidos y líneas sin duplicación al reentrar.
local Tooltip = {}
ns.Tooltip = Tooltip

local ICON_SIZE = 14
local GOLD = { 1, 0.82, 0 }
local GREEN = ns.IconColors.hammer_mine
local GRAY = ns.IconColors.hammer_other
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
    if kind == 'coin' and ns.DB.icons.coinStyle ~= 'KnuJunk' then path = 'Interface\\MoneyFrame\\UI-GoldIcon' end
    if type(path) ~= 'string' then return '' end
    if kind == 'hammer' then
        local tint = ns.Marks.Color(mark)
        return '|T' .. path .. ':' .. ICON_SIZE .. ':' .. ICON_SIZE .. ':0:0:64:64:0:64:0:64:'
            .. math.floor(tint[1] * 255 + 0.5) .. ':' .. math.floor(tint[2] * 255 + 0.5) .. ':'
            .. math.floor(tint[3] * 255 + 0.5) .. '|t '
    end
    local atlas = kind == 'coin' and ns.DB.icons.coinStyle ~= 'KnuJunk' and ns.Marks.COIN_ATLAS
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
-- Sólo para el botín (gancho de SetLootItem): en las bolsas el ítem se contaría a sí mismo.
function Tooltip.OwnedLine(link)
    if not enabled() or (ns.DB and type(ns.DB.show) == 'table' and ns.DB.show.owned == false) then return nil end
    local total, inBags, inBank = ns.Marks.OwnedCount(link)
    if not total or total <= 0 then return nil end
    return ns.L['You already have %d (bags %d, bank %d)']:format(total, inBags, inBank)
end

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

    local saleReasons = { gray = true, food_outgrown = true, ammo_outgrown = true,
        recipe_known = true, quest_done = true, quest_not_active = true, class_cannot_use = true,
        no_keep_reason = true, gear_outgrown = true, armor_below_equipped = true, book_other_class = true, book_known = true }
    local armorTypes = { [1] = 'cloth', [2] = 'leather', [3] = 'mail', [4] = 'plate' }
    local noRuleKeys = {
        gear = 'Gear: kept',
        bag = 'Bag: kept (equip it if it is bigger than one of yours)',
        openable = 'Openable: open it before selling it',
        rare_or_epic = 'Rare or epic: kept (worth more than the vendor pays)',
        ammo = 'Ammunition: kept',
        book = 'Book or recipe: kept',
        quest = 'Quest item: kept',
        key = 'Key: kept',
    }
    local neutral = (mark == nil or mark == 'useful' or mark == 'trash' or mark == 'auction')
    local noPrice = not (type(item.price) == 'number' and item.price > 0)
    local informational = false
    local function add(text, color, kind)
        if informational then
            text, color, kind = L['Also: '] .. text, { 0.6, 0.6, 0.6 }, nil
        end
        if kind == 'coin' and neutral and noPrice then color, kind = WHITE, nil end
        lines[#lines + 1] = { text = (kind and icon(kind, mark) or '') .. text, r = color[1], g = color[2], b = color[3] }
    end

    local names = {
        protected = 'Protected', quest = 'Active quest', hammer_mine = 'Your profession material',
        hammer_other = 'Other profession material', auction = 'Auction', coin = 'Sell',
        trash = 'Trash (cannot be sold)', useful = 'Useful', unruled = 'Missing data',
    }
    local function money(value)
        if type(value) ~= 'number' then return L['unknown price'] end
        value = math.floor(value)
        return string.format(L['%dg %ds %dc'], math.floor(value / 10000), math.floor(value / 100) % 100, value % 100)
    end
    local iconMark = ns.Marks and ns.Marks.MarkOf and ns.Marks.MarkOf(result) or mark
    if iconMark and names[iconMark] then
        local label = L[names[iconMark]]
        if iconMark == 'auction' then label = L['Auction (auction %s, vendor %s)']:format(money(result.auctionPrice), money(item.price)) end
        add(L['Icon: %s']:format(label), ns.Marks.Color(iconMark))
    end


    if mark == 'quest' and (result.reasonMark == 'hammer_mine' or result.reasonMark == 'hammer_other') then
        mark = result.reasonMark
    end
    if ns.Merchant then
        local key = ns.Merchant.ProtectionText(bag, slot)
        if key then add(L[key], WHITE) end
    end

    local function renderReason(reason)
        local kind = reason.kind
        local neutral = informational or neutral
        if kind == 'no_rule' then
            local key = reason.exception and noRuleKeys[reason.exception] or 'No rule for this item: not sold by default'
            if result.doubt then key = 'The game has not sent all the data for this item yet: not decided' end
            add(L[key], WHITE)
            -- Con GearQuest simulando otro personaje KnuJunk no usa su ranking: decirlo y cómo salir.
            if reason.exception == 'gear' and not informational and ns.GearQuestSimulating() then
                add(L['GearQuest is simulating another character: type /gq set off so KnuJunk can judge your gear'], { 1, 0.82, 0.24 })
            elseif reason.exception == 'gear' and not informational and result.gearQuest then
                local gqs = result.gearQuest
                local why = gqs.state == 'unknown_item' and L['GearQuest has no data for this item']
                    or gqs.state == 'level' and L['GearQuest uses level %s, you are %s']:format(tostring(gqs.gqLevel), tostring(ns.Player and ns.Player.GetContext and ns.Player.GetContext().level))
                    or gqs.state == 'class' and L['GearQuest uses another class (%s)']:format(tostring(gqs.gqClass))
                    or gqs.state == 'error' and L['GearQuest gave an error']
                    or gqs.state == 'rule_off' and L['the GearQuest rule is off in Options']
                    or gqs.state == 'uncertain' and L['item data is still loading']
                    or gqs.state == 'quest_log' and L['the quest log could not be read']
                    or gqs.state == 'set_piece' and L['it is part of an item set']
                    or gqs.state == 'no_link' and L['the item has no link']
                    or gqs.state == 'slot' and L['slot not judged (%s)']:format(tostring(item.equipLoc))
                    or gqs.state == 'future' and L['you cannot wear it yet']
                    or gqs.state == 'no_gearquest' and L['GearQuest is not loaded']
                    or gqs.state == 'equipment_set' and L['it is in one of your equipment sets']
                    or L['GearQuest gave no verdict']
                add(L['Why GearQuest did not decide: %s']:format(why), { 0.6, 0.6, 0.6 })
            end
        elseif kind == 'gear_ranked' then
            add(L['GearQuest ranks it for you: keep it'], WHITE)
        elseif kind == 'pawn_upgrade' then
            if reason.best then add(L['Pawn: already one of your best items'], WHITE)
            else
                local pct = type(reason.percent) == 'number' and string.format('%d%%', math.floor(reason.percent * 100 + 0.5)) or '?'
                add(L['Pawn: %s upgrade for %s']:format(pct, tostring(reason.scale)), WHITE)
            end
        elseif kind == 'gear_no_ranking' then
            add(L[result.mark == 'coin' and 'No ranking says you need it: sold' or 'Pawn does not mark it as an upgrade for your spec: keep it'], WHITE,
                result.mark == 'coin' and 'coin' or nil)
            add(L[reason.pawn and 'GearQuest does not know it and Pawn does not mark it as an upgrade' or 'GearQuest does not know it'], { 0.6, 0.6, 0.6 })
        elseif kind == 'gear_empty_slot' then
            add(L['That slot is empty: equip it'], WHITE)
        elseif kind == 'gear_below_equipped' then
            add(L['Item level %d: what you wear is %d']:format(reason.level, reason.equipped), WHITE,
                result.mark == 'coin' and 'coin' or nil)
        elseif kind == 'gear_maybe_upgrade' then
            add(L['Possible upgrade: item level %d versus %d equipped']:format(reason.level, reason.equipped), WHITE)
        elseif kind == 'book_unknown' and neutral then
            add(L['Your class book, not learned'], WHITE)
        elseif kind == 'quest_log_incomplete' then
            add(L['The quest log could not be read completely'], WHITE)
        elseif kind == 'quest_repeatable' then
            add(L['Repeatable quest: %s']:format(questName(reason.questID)), WHITE, 'quest')
        elseif kind == 'effect' or kind == 'useful' then
            add(L[reason.setPiece and 'Part of an item set' or 'Has a use or equip effect'], WHITE)
        elseif kind == 'no_sell_price' then
            add(L['Cannot be sold (no vendor price)'], WHITE)
        elseif kind == 'gear_not_ranked' then
            add(L['Not useful to you: %s']:format(reason.text), WHITE)
        elseif kind == 'recipe_known_tradeable' and neutral then
            add(L['You already know it; you can pass it on or auction it'], WHITE)
        elseif kind == 'override_keep' then
            add(L['Protected (by hand)'], WHITE)
        elseif kind == 'override_sell' then
            add(L['Sell (legacy mark)'], WHITE, 'coin')
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
        elseif saleReasons[kind] and (informational or ((mark == 'coin' or mark == 'auction') and shows('coin')) or (neutral and noPrice)) then
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
            elseif kind == 'no_keep_reason' then
                add(L['No rule for this item: sold by default'], GOLD, 'coin')
            elseif kind == 'gear_outgrown' then
                add(L['Level %d gear: too low for you']:format(reason.level or item.reqLevel or 0), GOLD, 'coin')
            elseif kind == 'armor_below_equipped' then
                local itemType = L[armorTypes[reason.subclassID or item.subclassID] or ''] or tostring(reason.subclassID or item.subclassID)
                local wornType = L[armorTypes[reason.equipped] or ''] or tostring(reason.equipped)
                add(L['%s armor: you wear %s there']:format(itemType, wornType), GOLD, 'coin')
            elseif kind == 'book_other_class' then
                add(L['Book for another class'], GOLD, 'coin')
            elseif kind == 'book_known' then
                add(L['You already know this spell'], GOLD, 'coin')
            end
        elseif kind == 'class_reagent' and neutral then
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
        elseif kind == 'class_cannot_use_tradeable' and neutral then
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
        elseif kind == 'quest_starter' and neutral then
            add(L["Starts a quest you haven't done: %s"]:format(questName(reason.questID)), WHITE, 'quest')
        elseif kind == 'quest_starter_done_unknown_repeat' and neutral then
            add(L["Quest turned in; unknown if it's repeatable"], WHITE)
        elseif kind == 'future_level' and neutral then
            add(L['Usable from level %d']:format(reason.level), WHITE)
        elseif kind == 'recipe' and shows('hammer') then
            local text = L['Recipe for %s']:format(professionList({ reason.skillLine }))
            if reason.rank then text = text .. L[', requires %d']:format(reason.rank) end
            add(text, mark == 'hammer_mine' and GREEN or GRAY, 'hammer')
        elseif kind == 'profession' and (informational or shows('hammer')) then
            if mark == 'hammer_mine' and not reason.other then
                add(L['Your profession: %s']:format(professionList(reason.professions)), GREEN, 'hammer')
            elseif mark == 'hammer_other' or informational then
                add(L["Profession you don't have: %s"]:format(professionList(reason.professions)), GRAY, 'hammer')
            end
        elseif kind == 'profession_tool' and (informational or shows('hammer')) then
            if mark == 'hammer_mine' and not reason.other then
                add(L['Tool for your profession: %s']:format(professionList(reason.professions)), GREEN, 'hammer')
            elseif mark == 'hammer_other' or informational then
                add(L["Tool for a profession you don't have: %s"]:format(professionList(reason.professions)), GRAY, 'hammer')
            end
        end
    end
    -- El gris y GearQuest pueden reemplazar al ganador del núcleo en el wrapper.
    local winner
    local winningKind = mark == 'protected' and 'override_keep'
        or (item.quality == 0 and (mark == 'coin' or mark == 'trash') and 'gray')
        or (mark == 'quest' and 'quest_active')
    for i, reason in ipairs(reasons) do
        if reason.kind == 'gear_not_ranked' or reason.kind == 'gear_outgrown' or reason.kind == 'armor_below_equipped' or (winningKind and reason.kind == winningKind) then winner = i end
    end
    if winner then renderReason(reasons[winner]) end
    for i, reason in ipairs(reasons) do if i ~= winner then renderReason(reason) end end
    informational = true
    for _, reason in ipairs(result.otherReasons or {}) do renderReason(reason) end
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
    if not link then
        if tooltip == rawget(_G, 'GameTooltip') and ns.Merchant then ns.Merchant.HideHoveredShield() end
        return
    end
    if bag == nil and type(tooltip.GetBagItem) == 'function' then
        local good, b, s = pcall(tooltip.GetBagItem, tooltip)
        if good and type(b) == 'number' and type(s) == 'number' then bag, slot = b, s end
    end
    local previous = guard[tooltip]
    if bag == nil and previous and previous.link == link then bag, slot = previous.bag, previous.slot end
    local lines = Tooltip.Lines(link, boundFromTooltip(tooltip, data), bag, slot)
    if #lines == 0 then
        if tooltip == rawget(_G, 'GameTooltip') and ns.Merchant then ns.Merchant.HideHoveredShield() end
        return
    end
    if tooltip == rawget(_G, 'GameTooltip') and ns.Merchant then
        ns.Merchant.ShowHoveredShield(bag, slot)
    end
    local missing = missingLines(tooltip, link, lines)
    if #missing == 0 then return end
    local record = guard[tooltip]
    if type(record) ~= 'table' or record.link ~= link then
        record = { link = link, done = {} }
        guard[tooltip] = record
    end
    record.bag, record.slot = bag, slot
    for _, line in ipairs(missing) do
        tooltip:AddLine(line.text, line.r, line.g, line.b)
        record.done[line.text] = true -- solo tras agregar: lo que falla se reintenta
    end
    -- El registro ya esta completo antes de Show, que puede volver a disparar el hook.
    if type(tooltip.Show) == 'function' then
        local visible = true
        if type(tooltip.IsShown) == 'function' then
            local success, shown = pcall(tooltip.IsShown, tooltip)
            visible = success and shown
        end
        if visible then pcall(tooltip.Show, tooltip) end
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
    -- El escudo del vendedor NO se oculta con el tooltip: al aparecer, el botón recibe OnLeave
    -- (el mouse quedó sobre el escudo), la bolsa oculta el tooltip y ocultar el escudo ahí armaba
    -- un ciclo de parpadeo (visto en el juego con Baganator). El escudo se va con su propio OnLeave.
    pcall(tooltip.HookScript, tooltip, 'OnHide', clear)
    if type(tooltip.SetBagItem) == 'function' and type(hooksecurefunc) == 'function' then
        pcall(hooksecurefunc, tooltip, 'SetBagItem', function(self, bag, slot) Tooltip.Decorate(self, nil, bag, slot) end)
    end
    if type(tooltip.SetLootItem) == 'function' then
        pcall(hooksecurefunc, tooltip, 'SetLootItem', function(self, slot)
            local result = ns.LootAdvisor.Advice(slot)
            if result then
                self:AddLine(result.text, result.good and 0.3 or 1, result.good and 1 or 0.3, 0.3, true)
            end
            local okLink, link = pcall(GetLootSlotLink, slot)
            local owned = okLink and Tooltip.OwnedLine(link)
            if owned then
                self:AddLine(owned, 1, 210/255, 60/255)
                if type(self.Show) == 'function' then self:Show() end
            end
        end)
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

-- Aviso al entrar: con la simulación de GearQuest prendida, el equipo de tu tipo y nivel queda sin
-- decidir. Se espera unos segundos para que GearQuest cargue su configuración.
function Tooltip.WarnGearQuestSimulation()
    if ns.GearQuestSimulating() then
        ns.Print(ns.L['GearQuest is in simulation mode, so KnuJunk does not sell gear by its ranking. Type /gq set off to use your real character.'])
        return true
    end
    return false
end
ns.OnLogin(function()
    if C_Timer and type(C_Timer.After) == 'function' then
        C_Timer.After(10, function() pcall(Tooltip.WarnGearQuestSimulation) end)
    end
end)
