-- Cada consulta de estos escenarios representa un inventario reci?n actualizado.
local function freshAdvice(slot)
    ns.LootAdvisor.Invalidate()
    return ns.LootAdvisor.Advice(slot)
end

local function setup()
    LootFrame = CreateFrame('Frame', 'LootFrame')
    function LootFrame:GetRight() return 300 end
    LootFrame_Update = function() end
    LOOTFRAME_NUMBUTTONS = 1
    LootButton1 = CreateFrame('Button', 'LootButton1', LootFrame)
    LootButton1.slot = 1
    function LootButton1:GetRight() return 60 end
    FAKE.items[100] = { name = 'Botin', quality = 1, price = 20, classID = 15, subclassID = 0 }
    FAKE.items[200] = { name = 'Basura', quality = 0, price = 5, classID = 15, subclassID = 0 }
    FAKE.bags['0:1'] = 200
    FAKE.advisorQuantity, FAKE.advisorCount, FAKE.advisorStack = 1, 1, 20
    FAKE.advisorBind = nil
    GetLootSlotLink = function(slot) if slot == 1 then return FAKE.linkOf(100) end end
    GetLootSlotInfo = function() return 'icon', 'Botin', FAKE.advisorQuantity end
    local originalInfo = GetItemInfo
    GetItemInfo = function(link)
        local info = { originalInfo(link) }
        info[8], info[14] = FAKE.advisorStack, FAKE.advisorBind
        return unpack(info, 1, 17)
    end
    C_Container.GetContainerNumFreeSlots = function() return 0, 0 end
    local originalContainer = C_Container.GetContainerItemInfo
    C_Container.GetContainerItemInfo = function(bag, slot)
        local info = originalContainer(bag, slot)
        if info then info.stackCount = FAKE.advisorCount end
        return info
    end
    FAKE.Fire('LOOT_OPENED')
end

test('asesor: defaults y candidato más barato', function()
    setup(); ok(ns.DB.lootAdvisor.enabled)
    FAKE.items[201] = { name = 'Barato', quality = 0, price = 1, classID = 15 }
    FAKE.bags['0:2'] = 201
    local result = freshAdvice(1)
    eq(result.kind, 'drop'); eq(result.candidate.slot, 2); eq(result.value, 20)
end)

test('asesor: lugar libre, ventana cerrada y opción apagada', function()
    setup()
    C_Container.GetContainerNumFreeSlots = function() return 1, 0 end
    eq(freshAdvice(1), nil)
    C_Container.GetContainerNumFreeSlots = function() return 0, 0 end
    ns.DB.lootAdvisor.enabled = false; eq(freshAdvice(1), nil)
    ns.DB.lootAdvisor.enabled = true
    ns.DB.enabled = false; eq(freshAdvice(1), nil)
    ns.DB.enabled = true
    FAKE.Fire('LOOT_CLOSED'); eq(freshAdvice(1), nil)
end)

test('asesor: pila parcial con lugar para toda la cantidad', function()
    setup(); FAKE.bags['0:2'] = 100
    FAKE.advisorCount, FAKE.advisorQuantity = 18, 2
    eq(freshAdvice(1).kind, 'stack')
    FAKE.advisorQuantity = 3
    eq(freshAdvice(1).kind, 'skip')
end)

test('asesor: basura sin precio vale cero y cantidad multiplica', function()
    setup(); FAKE.items[200].price = 0; FAKE.advisorQuantity = 4
    local result = freshAdvice(1)
    eq(result.kind, 'drop'); eq(result.candidate.value, 0); eq(result.value, 80)
end)

test('asesor: candidato caro o igual no conviene', function()
    setup(); FAKE.items[200].price = 21
    eq(freshAdvice(1).kind, 'skip')
    FAKE.items[200].price = 20
    eq(freshAdvice(1).kind, 'skip')
end)

test('asesor: valor de pila candidata y subasta supera al vendedor', function()
    setup(); FAKE.advisorCount = 3
    local result = freshAdvice(1)
    eq(result.candidate.value, 15); eq(result.kind, 'drop')
    FAKE.advisorBind = 2
    Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function(_, id) if id == 200 then return 50 end end } } }
    -- Gris conserva la marca coin del clasificador, pero el valor del asesor incluye la subasta.
    result = freshAdvice(1)
    eq(result.candidate.value, 150); eq(result.kind, 'skip')
end)

test('asesor: sin candidato y marcas protegidas excluidas', function()
    setup()
    local classify = ns.Classify
    local success, err = pcall(function()
        for _, mark in ipairs({'protected', 'quest', 'hammer_mine', 'hammer_other', 'useful', 'auction'}) do
            ns.Classify = function() return { mark = mark } end
            eq(freshAdvice(1).candidate, nil, mark)
        end
        ns.Classify = function() return {mark = 'coin', quest = true} end
        eq(freshAdvice(1).candidate, nil)
    end)
    ns.Classify = classify
    if not success then error(err) end
    FAKE.bags = {}; eq(freshAdvice(1).kind, 'none')
end)

test('asesor: misión activa siempre recomienda lootear', function()
    setup(); FAKE.items[100].name = 'Garra'
    FAKE.questLog = {{questID = 1, objectives = {{text = 'Garra: 0/2', type = 'item'}}}}
    ns.Player.Invalidate(); FAKE.items[200].price = 100
    local result = freshAdvice(1)
    eq(result.kind, 'quest'); ok(result.good); ok(result.candidate)
    FAKE.bags = {}; eq(freshAdvice(1).kind, 'quest')
end)

test('asesor: Auctionator opcional, ligadura desconocida o al recoger', function()
    setup(); FAKE.items[200].price = 30
    Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function(_, id) if id == 100 then return 100 end end } } }
    eq(freshAdvice(1).value, 20)
    FAKE.advisorBind = 1; eq(freshAdvice(1).value, 20)
    FAKE.advisorBind = 2; eq(freshAdvice(1).value, 100)
    Auctionator.API.v1.GetAuctionPriceByItemID = function() error('sin base') end
    eq(freshAdvice(1).value, 20)
    Auctionator = nil; eq(freshAdvice(1).value, 20)
end)

test('asesor: familias de bolsas y datos desconocidos', function()
    setup()
    C_Container.GetContainerNumFreeSlots = function(bag) return bag == 1 and 2 or 0, bag == 1 and 32 or 0 end
    C_Item.GetItemFamily = function() return 16 end
    ok(freshAdvice(1))
    C_Item.GetItemFamily = function() return 32 end
    eq(freshAdvice(1), nil)
    C_Item.GetItemFamily = nil; GetItemFamily = function() return 32 end
    eq(freshAdvice(1), nil)
    GetItemFamily = nil; ok(freshAdvice(1))
    C_Container.GetContainerNumFreeSlots = function() return nil end
    eq(freshAdvice(1), nil)
end)

test('asesor: Shift muestra y oculta; cierre limpia', function()
    setup(); eq(LootButton1.KnuJunkAdvice, nil)
    FAKE.shift = true; FAKE.Fire('MODIFIER_STATE_CHANGED', 'LSHIFT', 1); FAKE.Advance(0)
    ok(LootButton1.KnuJunkAdvice:IsShown())
    FAKE.shift = false; FAKE.Fire('MODIFIER_STATE_CHANGED', 'LSHIFT', 0); FAKE.Advance(0)
    ok(not LootButton1.KnuJunkAdvice:IsShown())
    FAKE.shift = true; ns.Loot.Refresh()
    FAKE.Fire('LOOT_CLOSED'); ok(not LootButton1.KnuJunkAdvice:IsShown())
end)

test('asesor: tooltip de botín sin Shift', function()
    setup()
    GameTooltip = CreateFrame('Tooltip', 'GameTooltip')
    GameTooltip.SetLootItem = function() end
    local lines = {}
    function GameTooltip:AddLine(text) lines[#lines + 1] = text end
    ns.Tooltip.Hook(); GameTooltip:SetLootItem(1)
    eq(#lines, 1); eq(lines[1], freshAdvice(1).text)
    ns.DB.lootAdvisor.enabled = false; GameTooltip:SetLootItem(1); eq(#lines, 1)
end)

test('asesor: no crea texto en combate ni desborda el ancho disponible', function()
    setup(); FAKE.shift = true; FAKE.inCombat = true
    ns.Loot.Refresh(); eq(LootButton1.KnuJunkAdvice, nil)
    FAKE.inCombat = false; ns.Loot.Refresh()
    eq(LootButton1.KnuJunkAdvice:GetWidth(), 220)
    function LootButton1:GetRight() return 290 end
    ns.Loot.Refresh(); ok(not LootButton1.KnuJunkAdvice:IsShown())
end)

test('asesor: ScrollBox recicla filas sin texto viejo', function()
    setup(); LootButton1 = nil; FAKE.shift = true
    local row = CreateFrame('Button', nil, LootFrame)
    row.slotIndex = 1; row.Item = CreateFrame('Button', nil, row)
    function row:GetSlotIndex() return self.slotIndex end
    function row.Item:GetRight() return 60 end
    LootFrame.ScrollBox = {ForEachFrame = function(_, fn) fn(row) end}
    local callback
    ScrollUtil = {AddInitializedFrameCallback = function(_, fn) callback = fn end}
    ns.Loot.Refresh(); ok(row.Item.KnuJunkAdvice:IsShown())
    row.slotIndex = 2; callback(nil, row); ok(not row.Item.KnuJunkAdvice:IsShown())
    row.slotIndex = 1; callback(nil, row); ok(row.Item.KnuJunkAdvice:IsShown())
    row:Hide(); callback(nil, row); ok(not row.Item.KnuJunkAdvice:IsShown())
end)

test('regresión 3: no libera un carcaj para botín incompatible o de familia desconocida', function()
    setup()
    FAKE.bags = { ['1:1'] = 200 }
    C_Container.GetContainerNumFreeSlots = function(bag) return 0, bag == 1 and 1 or 0 end
    for _, family in ipairs({0, 2, false}) do
        C_Item.GetItemFamily = function() return family or nil end
        eq(freshAdvice(1).candidate, nil)
    end
    C_Item.GetItemFamily = function() return 1 end
    eq(freshAdvice(1).candidate.bag, 1)
    C_Container.GetContainerNumFreeSlots = function() return 0, nil end
    eq(freshAdvice(1).candidate, nil)
end)

test('regresión 4: suma la capacidad de dos pilas de 18/20 para tres unidades', function()
    setup()
    FAKE.bags['0:2'], FAKE.bags['0:3'] = 100, 100
    FAKE.advisorCount, FAKE.advisorQuantity = 18, 3
    eq(freshAdvice(1).kind, 'stack')
    FAKE.advisorQuantity = 5
    ok(freshAdvice(1).candidate)
end)

test('regresión 4: descuenta pilas parciales antes de calcular las ranuras necesarias', function()
    setup()
    FAKE.bags['0:2'], FAKE.bags['0:3'] = 100, 100
    FAKE.advisorCount, FAKE.advisorQuantity = 18, 24
    C_Container.GetContainerNumFreeSlots = function(bag) return bag == 0 and 1 or 0, 0 end
    eq(freshAdvice(1), nil)
    FAKE.advisorQuantity = 25
    ok(freshAdvice(1).candidate)
    FAKE.advisorQuantity = 45
    eq(freshAdvice(1).candidate, nil, 'un descarte no alcanza para dos ranuras')
end)

test('regresión 6: Ctrl y Alt no refrescan; Shift se agrupa por cuadro', function()
    setup(); FAKE.Advance(1)
    local original, calls = ns.Loot.Refresh, 0
    ns.Loot.Refresh = function(...) calls = calls + 1; return original(...) end
    local success, err = pcall(function()
        for _, key in ipairs({'LCTRL', 'RCTRL', 'LALT', 'RALT'}) do
            FAKE.Fire('MODIFIER_STATE_CHANGED', key, 1)
            FAKE.Fire('MODIFIER_STATE_CHANGED', key, 0)
        end
        FAKE.Advance(0); eq(calls, 0)
        FAKE.shift = true; FAKE.Fire('MODIFIER_STATE_CHANGED', 'LSHIFT', 1)
        FAKE.Fire('MODIFIER_STATE_CHANGED', 'RSHIFT', 1)
        FAKE.Fire('MODIFIER_STATE_CHANGED', 'LSHIFT', 1)
        eq(calls, 0); FAKE.Advance(0); eq(calls, 1)
        FAKE.Fire('MODIFIER_STATE_CHANGED', 'RSHIFT', 1)
        FAKE.Advance(0); eq(calls, 1)
        FAKE.shift = false; FAKE.Fire('MODIFIER_STATE_CHANGED', 'RSHIFT', 0)
        FAKE.Advance(0); eq(calls, 2)
    end)
    ns.Loot.Refresh = original
    if not success then error(err) end
end)

test('regresión 6: cuatro filas y tooltip comparten inventario hasta invalidarse', function()
    setup(); FAKE.Advance(1)
    for bag = 0, 4 do
        for slot = 1, 8 do FAKE.bags[bag .. ':' .. slot] = 200 end
    end
    LOOTFRAME_NUMBUTTONS = 4
    for index = 2, 4 do
        local button = CreateFrame('Button', 'LootButton' .. index, LootFrame)
        button.slot = index
        function button:GetRight() return 60 end
    end
    GetLootSlotLink = function() return FAKE.linkOf(100) end
    FAKE.shift = true
    GameTooltip = CreateFrame('Tooltip', 'GameTooltip')
    GameTooltip.SetLootItem = function() end
    function GameTooltip:AddLine() end
    ns.Tooltip.Hook()
    local read, classify = ns.Player.ReadItem, ns.Classify
    local reads, classifications = 0, 0
    ns.Player.ReadItem = function(...) reads = reads + 1; return read(...) end
    ns.Classify = function(item, ...)
        if item.id == 200 then classifications = classifications + 1 end
        return classify(item, ...)
    end
    local success, err = pcall(function()
        ns.LootAdvisor.Invalidate()
        ns.Loot.Refresh(); eq(reads, 40); eq(classifications, 40)
        GameTooltip:SetLootItem(1); ns.Loot.Refresh()
        eq(reads, 40); eq(classifications, 40)
        FAKE.Fire('MODIFIER_STATE_CHANGED', 'LCTRL', 1); FAKE.Advance(0)
        eq(reads, 40)
        FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(0)
        eq(reads, 80); GameTooltip:SetLootItem(1); eq(reads, 80)
        FAKE.Advance(.2); eq(reads, 80)
        FAKE.Fire('LOOT_SLOT_CHANGED', 1); FAKE.Advance(0); eq(reads, 120)
        ns.DB.overrides[200] = 'keep'; ns.Bags.RefreshAll()
        GameTooltip:SetLootItem(1); eq(reads, 160)
        eq(ns.LootAdvisor.Advice(1).candidate, nil)
    end)
    ns.Player.ReadItem, ns.Classify = read, classify
    if not success then error(err) end
end)

test('regresión 6: abrir con Shift apretado permite ocultar el consejo al soltarlo', function()
    setup(); FAKE.shift = true
    FAKE.Fire('LOOT_OPENED'); FAKE.Advance(0)
    ok(LootButton1.KnuJunkAdvice:IsShown())
    FAKE.shift = false; FAKE.Fire('MODIFIER_STATE_CHANGED', 'LSHIFT', 0)
    FAKE.Advance(0); ok(not LootButton1.KnuJunkAdvice:IsShown())
end)
