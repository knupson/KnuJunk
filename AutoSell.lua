local _, ns = ...
local AutoSell = {}
ns.AutoSell = AutoSell

local opened, ownCall, deferred = false, false, false
local ticker, queue, cursor, sold, total = nil, {}, 1, 0, 0
local reported, bursts = {}, {}
local hookedContainer
local attempts, pending = 0, nil

local function safe(fn, ...)
    if type(fn) ~= 'function' then return nil end
    local ok, value = pcall(fn, ...)
    if ok then return value end
end

local function api(name) return (C_Container and C_Container[name]) or _G[name] end
local function combat()
    if type(InCombatLockdown) ~= 'function' then return false end
    local ok, value = pcall(InCombatLockdown)
    return not ok or value == true
end
local function enabled()
    return ns.DB and ns.DB.enabled ~= false and ns.DB.autoSell and ns.DB.autoSell.enabled == true
end
local function maximum()
    local value = ns.DB and ns.DB.autoSell and ns.DB.autoSell.max
    if type(value) ~= 'number' or value ~= value then value = 12 end
    return math.max(1, math.min(12, math.floor(value)))
end

local function candidate(bag, slot)
    if bag < 0 or bag > 4 then return end
    local loc = safe(ItemLocation and ItemLocation.CreateFromBagAndSlot, ItemLocation, bag, slot)
    local guid = loc and safe(C_Item and C_Item.GetItemGUID, loc)
    if type(guid) ~= 'string' or guid == '' then return end
    if ns.Merchant and ns.Merchant.IsLocked(guid) then return end
    if C_Item and type(C_Item.IsLocked) == 'function' then
        if safe(C_Item.IsLocked, loc) ~= false then return end
    end
    local info = safe(api('GetContainerItemInfo'), bag, slot)
    if type(info) ~= 'table' or info.isLocked then return end
    local ok, mark, pending, _, item = pcall(ns.Marks.Verdict, bag, slot)
    if not ok or mark ~= 'coin' or pending or type(item) ~= 'table' then return end
    if ns.DB.overrides and ns.DB.overrides[item.id] == 'keep' then return end
    if type(item.price) ~= 'number' or item.price <= 0 or item.price ~= item.price then return end
    if ns.DB.autoSell.graysOnly and item.quality ~= 0 then return end
    local count = info.stackCount or 1
    if type(count) ~= 'number' or count < 1 then return end
    return guid, item.price, count
end

-- Cada pedido de venta queda anotado y se cuenta recién cuando el ítem ya no está en las bolsas.
-- El servidor tarda más que un tick en sacarlo: confirmar al tick siguiente descartaba ventas
-- reales y el resumen no salía (visto en el juego 2026-11-18).
local attempted, reportToken = {}, 0
local REPORT_DELAY = 1.5

local function guidAt(bag, slot)
    local loc = safe(ItemLocation and ItemLocation.CreateFromBagAndSlot, ItemLocation, bag, slot)
    if not loc or not (C_Item and type(C_Item.GetItemGUID) == 'function') then return nil, false end
    local ok, guid = pcall(C_Item.GetItemGUID, loc)
    if not ok then return nil, false end
    return guid, true
end

local function inBags(guid)
    for bag = 0, 4 do
        local slots = safe(api('GetContainerNumSlots'), bag)
        if type(slots) == 'number' then
            for slot = 1, slots do
                local value = guidAt(bag, slot)
                if value == guid then return true end
            end
        end
    end
    return false
end

local function confirm()
    for _, entry in ipairs(attempted) do
        if not entry.counted then
            local guid, readable = guidAt(entry.bag, entry.slot)
            if readable then
                local count
                if guid == entry.guid then
                    local info = safe(api('GetContainerItemInfo'), entry.bag, entry.slot)
                    local remaining = type(info) == 'table' and info.stackCount
                    if type(remaining) == 'number' and remaining >= 0 and remaining < entry.count then
                        count = entry.count - remaining
                    end
                elseif not inBags(entry.guid) then
                    count = entry.count
                end
                if count then
                    entry.counted = true
                    sold, total = sold + 1, total + entry.price * count
                end
            end
        end
    end
end

local function report()
    confirm()
    attempted = {}
    if sold > 0 then
        ns.Print(ns.L['KnuJunk sold %d items for %s']:format(sold, ns.FormatMoney(total)))
    end
    sold, total = 0, 0
end

-- Un solo resumen por visita, un rato después del último pedido.
local function scheduleReport()
    reportToken = reportToken + 1
    local token = reportToken
    if #attempted == 0 then sold, total = 0, 0; return end
    if C_Timer and type(C_Timer.After) == 'function' then
        C_Timer.After(REPORT_DELAY, function() if token == reportToken then report() end end)
    else
        report()
    end
end

local function finish()
    if ticker then ticker:Cancel(); ticker = nil end
    pending = nil
    scheduleReport()
end

local function tick()
    if not opened or not enabled() then deferred = false; finish(); return end
    if combat() then
        deferred = true
        if ticker then ticker:Cancel(); ticker = nil end
        return
    end
    local entry = queue[cursor]
    if not entry or attempts >= maximum() then finish(); return end
    cursor = cursor + 1
    local guid, price, count = candidate(entry.bag, entry.slot)
    if guid == entry.guid then
        local use = api('UseContainerItem')
        if type(use) == 'function' then
            ownCall = true
            attempts = attempts + 1
            local ok, value = pcall(use, entry.bag, entry.slot)
            ownCall = false
            if ok and value ~= false then
                attempted[#attempted + 1] = { bag = entry.bag, slot = entry.slot, guid = guid, price = price, count = count }
            end
        end
    end
    if cursor > #queue or attempts >= maximum() then finish() end
end

local function start()
    if not opened or not enabled() then return end
    if combat() then deferred = true; return end
    deferred = false
    queue, cursor = {}, 1
    for bag = 0, 4 do
        local slots = safe(api('GetContainerNumSlots'), bag)
        if type(slots) == 'number' then
            for slot = 1, slots do
                local guid = candidate(bag, slot)
                if guid then queue[#queue + 1] = { bag = bag, slot = slot, guid = guid } end
            end
        end
    end
    if #queue > 0 and C_Timer and type(C_Timer.NewTicker) == 'function' then
        ticker = safe(C_Timer.NewTicker, .2, tick)
    end
end

function AutoSell.OtherSellers()
    local found = {}
    -- LeaPlusLC es local en Leatrix (Leatrix_Plus.lua:16); lo visible es su SavedVariable LeaPlusDB
    -- (Leatrix_Plus.toc:8), donde guarda AutoSellJunk = "On" (visto en WTF/.../Leatrix_Plus.lua).
    local lea = rawget(_G, 'LeaPlusDB')
    if type(lea) == 'table' and lea.AutoSellJunk == 'On' then found.Leatrix_Plus = true end
    local e = type(ElvUI) == 'table' and ElvUI[1]
    local db = type(e) == 'table' and e.db
    local bags = type(db) == 'table' and db.bags
    local grays = type(bags) == 'table' and bags.vendorGrays
    if type(grays) == 'table' and grays.enable == true then found.ElvUI = true end
    return found
end

local known = { Leatrix_Plus=true, ElvUI=true, Scrap=true, Peddler=true, Dejunk=true,
    Vendor=true, SellJunk=true, AutoVendor=true }
local function observe()
    if not opened or ownCall then return end
    local stack = safe(debugstack, 2)
    if type(stack) ~= 'string' then return end
    local name
    for addon in stack:gsub('\\', '/'):gmatch('Interface/AddOns/([^/]+)/') do
        if addon ~= 'KnuJunk' and not addon:match('^Blizzard_') then name = addon; break end
    end
    if not name or reported[name] then return end
    if not known[name] then
        local now = safe(GetTime)
        if type(now) ~= 'number' then return end
        local recent = {}
        for _, time in ipairs(bursts[name] or {}) do
            if now - time <= 1 then recent[#recent + 1] = time end
        end
        recent[#recent + 1] = now
        bursts[name] = recent
        if #recent < 3 then return end
    end
    reported[name] = true
    ns.Print(ns.L['%s is selling items in addition to KnuJunk.']:format(name))
end

local function installHook()
    if type(C_Container) ~= 'table' or type(C_Container.UseContainerItem) ~= 'function'
        or type(hooksecurefunc) ~= 'function' or hookedContainer == C_Container then return end
    if pcall(hooksecurefunc, C_Container, 'UseContainerItem', observe) then hookedContainer = C_Container end
end

local frame = CreateFrame('Frame')
for _, event in ipairs({ 'MERCHANT_SHOW', 'MERCHANT_CLOSED', 'PLAYER_REGEN_ENABLED', 'PLAYER_LEAVING_WORLD', 'BAG_UPDATE_DELAYED' }) do
    frame:RegisterEvent(event)
end
frame:SetScript('OnEvent', function(_, event)
    if event == 'MERCHANT_SHOW' then
        if opened then return end
        opened, deferred = true, false
        queue, cursor = {}, 1
        sold, total, reported, bursts, attempts, pending = 0, 0, {}, {}, 0, nil
        attempted, reportToken = {}, reportToken + 1
        installHook()
        start()
    elseif event == 'BAG_UPDATE_DELAYED' then
        if #attempted > 0 then confirm() end
    elseif event == 'MERCHANT_CLOSED' or event == 'PLAYER_LEAVING_WORLD' then
        opened, deferred = false, false
        if ticker then finish() end
    elseif deferred and opened then
        -- Retomar la cola original sin volver a vender ranuras ya procesadas.
        deferred = false
        if #queue == 0 then start()
        elseif C_Timer and type(C_Timer.NewTicker) == 'function' then ticker = safe(C_Timer.NewTicker, .2, tick) end
    end
end)
installHook()

function AutoSell.ResetState()
    if ticker then ticker:Cancel() end
    opened, ownCall, deferred, ticker = false, false, false, nil
    queue, cursor, sold, total, reported, bursts = {}, 1, 0, 0, {}, {}
    attempts, pending = 0, nil
    attempted, reportToken = {}, reportToken + 1
    installHook()
end
