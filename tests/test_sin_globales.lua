-- Cliente de WoW Forever sin GearQuest: GetItemInfo y compañía sólo existen en C_Item
-- (GearQuest crea las globales; apagado, no están). Las marcas no pueden desaparecer.
local NAMES = { 'GetItemInfo', 'GetItemInfoInstant', 'GetItemSpell', 'GetItemCount' }

local function onlyCItem()
    local saved = {}
    for _, name in ipairs(NAMES) do
        saved[name] = rawget(_G, name)
        C_Item[name] = saved[name] or function() return 0 end
        _G[name] = nil
    end
    return function() for _, name in ipairs(NAMES) do _G[name] = saved[name] end end
end

test('sin globales de ítem: se leen por C_Item y el gris lleva moneda', function()
    local restore = onlyCItem()
    local good, err = pcall(function()
        FAKE.items[991700] = { name = 'Hacha de guerra de piedra', quality = 0, price = 1609, classID = 2, subclassID = 1,
            equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 27 }
        FAKE.bags['0:1'] = 991700
        ns.Player.Invalidate()
        local item = ns.Player.ReadLink('item:991700')
        ok(item, 'ReadLink lee el ítem'); eq(item.quality, 0); eq(item.itemLevel, 27)
        eq(ns.Marks.Verdict(0, 1, 991700), 'coin')
    end)
    restore()
    if not good then error(err, 0) end
end)

test('sin globales de ítem: la global, si existe, gana sobre C_Item', function()
    local saved = rawget(_G, 'GetItemCount')
    C_Item.GetItemCount = function() return 9 end
    GetItemCount = function() return 2 end
    eq(ns.API.GetItemCount(1), 2)
    GetItemCount = nil
    eq(ns.API.GetItemCount(1), 9)
    GetItemCount, C_Item.GetItemCount = saved, nil
end)
