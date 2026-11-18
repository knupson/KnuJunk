local _, ns = ...
local Advisor = {}
ns.LootAdvisor = Advisor

local function safe(fn, ...)
    if type(fn) ~= 'function' then return end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function money(value)
    local text = safe(GetCoinTextureString, value)
    if type(text) == 'string' then return text end
    return ns.L['%dg %ds %dc']:format(math.floor(value / 10000), math.floor(value / 100) % 100, value % 100)
end

local function unitValue(item)
    local vendor = type(item.price) == 'number' and item.price or 0
    -- GetItemInfo: el campo 14 es bindType; nil no acredita que se pueda subastar.
    local ok, data = pcall(function() return { GetItemInfo(item.link or item.id) } end)
    local bind = ok and data[14]
    if type(bind) == 'number' and bind ~= 1 and item.isBound ~= true then
        return math.max(vendor, ns.AuctionPrice(item.id) or 0)
    end
    return vendor
end

local function accepts(family, itemFamily)
    if family == 0 then return true end
    if type(family) ~= 'number' or type(itemFamily) ~= 'number' then return false end
    -- Intersección de máscaras sin depender de bit/bit32 en Lua 5.1.
    while family > 0 and itemFamily > 0 do
        if family % 2 == 1 and itemFamily % 2 == 1 then return true end
        family, itemFamily = math.floor(family / 2), math.floor(itemFamily / 2)
    end
    return false
end

local function advice(slot)
    if not ns.DB or ns.DB.enabled == false or not ns.DB.lootAdvisor or ns.DB.lootAdvisor.enabled == false
        or not ns.Loot.IsShown() then return end
    local link = safe(GetLootSlotLink, slot)
    local item = link and ns.Player.ReadLink(link)
    if not item then return end
    local containers = C_Container or {}
    local freeAPI = containers.GetContainerNumFreeSlots or GetContainerNumFreeSlots
    if type(freeAPI) ~= 'function' then return end
    local family = safe(C_Item and C_Item.GetItemFamily or GetItemFamily, link)
    for bag = 0, 4 do
        local free, bagFamily = safe(freeAPI, bag)
        if type(free) ~= 'number' then return end -- no afirmar bolsa llena sin datos
        if free > 0 and accepts(bagFamily, family) then return end
    end
    local _, _, quantity = safe(GetLootSlotInfo, slot)
    quantity = type(quantity) == 'number' and quantity > 0 and quantity or 1
    local stackOK, stack = pcall(function() return select(8, GetItemInfo(link)) end)
    stack = stackOK and type(stack) == 'number' and stack or 1
    local context = ns.Player.GetContext()
    local cheapest
    for bag = 0, 4 do
        local size = safe(containers.GetContainerNumSlots or GetContainerNumSlots, bag) or 0
        for index = 1, size do
            local stock = ns.Player.ReadItem(bag, index)
            if stock then
                local info = safe(containers.GetContainerItemInfo, bag, index)
                local count = type(info) == 'table' and info.stackCount
                if not count then local _, legacyCount = safe(GetContainerItemInfo, bag, index); count = legacyCount end
                count = type(count) == 'number' and count or 1
                if stock.id == item.id and count < stack and stack - count >= quantity then
                    return { kind = 'stack', good = true, text = ns.L['Fits in a stack'], short = ns.L['Fits in a stack'] }
                end
                local verdict = ns.Classify(stock, context)
                if verdict and not verdict.pending and not verdict.uncertain and not verdict.quest
                    and (verdict.mark == 'trash' or verdict.mark == 'coin') then
                    local value = verdict.mark == 'trash' and 0 or unitValue(stock) * count
                    if not cheapest or value < cheapest.value then
                        cheapest = { link = stock.link or tostring(stock.id), value = value, bag = bag, slot = index }
                    end
                end
            end
        end
    end
    local value = unitValue(item) * quantity
    local verdict = ns.Classify(item, context)
    local quest = verdict and (verdict.mark == 'quest' or verdict.quest == true)
    local result = { candidate = cheapest, value = value, good = quest or (cheapest and cheapest.value < value) or false }
    if quest then
        result.kind, result.text, result.short = 'quest', ns.L['An active quest needs it: loot it'], ns.L['Quest: loot it']
        if cheapest then result.text = result.text .. '. ' .. ns.L['Drop %s (worth %s)']:format(cheapest.link, money(cheapest.value)) end
    elseif not cheapest then
        result.kind, result.text, result.short = 'none', ns.L['You have no junk to drop'], ns.L['No junk to drop']
    elseif cheapest.value < value then
        result.kind, result.text, result.short = 'drop', ns.L['Drop %s (worth %s) and loot it (worth %s)']:format(cheapest.link, money(cheapest.value), money(value)), ns.L['Loot it: drop junk']
    else
        result.kind, result.text, result.short = 'skip', ns.L['Not worth it: the cheapest item you can drop is worth %s and this is worth %s']:format(money(cheapest.value), money(value)), ns.L['Not worth looting']
    end
    return result
end

function Advisor.Advice(slot)
    local ok, result = pcall(advice, slot)
    if ok then return result end
end

function Advisor.Hide(button)
    if button.KnuJunkAdvice then button.KnuJunkAdvice:Hide() end
end

function Advisor.Update(button, slot)
    Advisor.Hide(button)
    if not safe(IsShiftKeyDown) then return end
    local result = Advisor.Advice(slot)
    if not result then return end
    if not button.KnuJunkAdvice then
        if safe(InCombatLockdown) then return end
        button.KnuJunkAdvice = LootFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    end
    local text = button.KnuJunkAdvice
    text:ClearAllPoints()
    local edge, right = safe(LootFrame.GetRight, LootFrame), safe(button.GetRight, button)
    if not edge or not right or edge - right <= 20 then return end
    text:SetPoint('LEFT', button, 'RIGHT', 4, 0)
    text:SetWidth(edge - right - 20)
    text:SetHeight(30)
    text:SetText(result.short)
    text:SetTextColor(result.good and 0.3 or 1, result.good and 1 or 0.3, 0.3)
    text:Show()
end
