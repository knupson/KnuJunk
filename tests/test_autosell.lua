local function item(bag, slot, id, quality, price)
    id = id or (1000 + bag * 100 + slot)
    FAKE.items[id] = { name = 'Prueba' .. id, quality = quality or 0, price = price or 10, classID = 15, subclassID = 0 }
    FAKE.bags[bag .. ':' .. slot] = id
    ns.DB.overrides[id] = 'sell'
    return id
end

local function withVerdict(fn, body)
    local original = ns.Marks.Verdict
    ns.Marks.Verdict = fn
    local success, err = pcall(body)
    ns.Marks.Verdict = original
    if not success then error(err, 0) end
end

local function stack(name, backslash)
    local path = 'Interface/AddOns/' .. name .. '/Vender.lua:10'
    debugstack = function(level)
        eq(level, 2)
        return backslash and path:gsub('/', '\\') or path
    end
end

test('venta: defaults y una ranura por tick de 0,2 segundos', function()
    ok(ns.DB.autoSell.enabled); eq(ns.DB.autoSell.graysOnly, false); eq(ns.DB.autoSell.max, 12)
    item(0, 1); item(0, 2)
    FAKE.Fire('MERCHANT_SHOW'); eq(#FAKE.used, 0)
    FAKE.Advance(.19); eq(#FAKE.used, 0)
    FAKE.Advance(.02); eq(#FAKE.used, 1)
    FAKE.Advance(.2); eq(#FAKE.used, 2)
    FAKE.Advance(3); eq(#FAKE.used, 2)
end)

test('venta: cerrar cancela el ticker y resume sólo lo vendido', function()
    item(0, 1); item(0, 2)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(.21)
    FAKE.Fire('MERCHANT_CLOSED'); FAKE.Advance(3)
    eq(#FAKE.used, 1); eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find('KnuJunk vendió 1 ítems por 0o 0p 10c', 1, true))
end)

test('venta: límite predeterminado de doce y reinicio por visita', function()
    for bag = 0, 1 do for slot = 1, 8 do item(bag, slot) end end
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(5); eq(#FAKE.used, 12)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(5); eq(#FAKE.used, 12)
    FAKE.Fire('MERCHANT_CLOSED'); FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(5)
    eq(#FAKE.used, 24); eq(#FAKE.messages, 2)
end)

test('venta: respeta máximo configurable y límites de la opción', function()
    ok(ns.Options.SetValue('autoSell.max', 2)); item(0, 1); item(0, 2); item(0, 3)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(2); eq(#FAKE.used, 2)
    ns.Options.SetValue('autoSell.max', 99); eq(ns.DB.autoSell.max, 12)
    ns.Options.SetValue('autoSell.max', -1); eq(ns.DB.autoSell.max, 1)
    ns.Options.SetValue('autoSell.max', 2.8); eq(ns.DB.autoSell.max, 2)
end)

test('venta: sólo grises opcional', function()
    item(0, 1, 1001, 1); item(0, 2, 1002, 0)
    ns.DB.autoSell.graysOnly = true
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
    eq(#FAKE.used, 1); eq(FAKE.used[1][2], 2)
end)

test('venta: sin sólo grises vende moneditas de otra calidad', function()
    item(0, 1, 1001, 2)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 1)
end)

test('venta: excluye keep, bloqueos y precio cero', function()
    local id = item(0, 1); ns.DB.overrides[id] = 'keep'
    item(0, 2); FAKE.itemLocks['guid:0:2:1002'] = true
    item(0, 3, 1003, 0, 0)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(2)
    eq(#FAKE.used, 0); eq(#FAKE.messages, 0)
end)

for _, mark in ipairs({ 'protected', 'auction', 'useful', 'quest', 'hammer_mine', 'hammer_other', 'trash', 'none' }) do
    local kind = mark
    test('venta: no vende marca ' .. kind, function()
        item(0, 1)
        withVerdict(function() return kind, false, {}, { id=1001, price=10, quality=0 } end, function()
            FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 0)
        end)
    end)
end

test('venta: datos pendientes y precios desconocidos se omiten', function()
    item(0, 1)
    withVerdict(function() return 'coin', true, {}, { id=1001, price=10 } end, function()
        FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 0)
    end)
    FAKE.Fire('MERCHANT_CLOSED')
    withVerdict(function() return 'coin', false, {}, { id=1001 } end, function()
        FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 0)
    end)
end)

test('venta: no recorre bolsas del banco', function()
    item(-1, 1); item(5, 1); item(12, 1); item(4, 1)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(2)
    eq(#FAKE.used, 1); eq(FAKE.used[1][1], 4)
end)

test('venta: GUID cambiado entre apertura y tick se omite', function()
    item(0, 1); FAKE.Fire('MERCHANT_SHOW')
    FAKE.guids['0:1'] = 'reemplazo'; FAKE.Advance(1)
    eq(#FAKE.used, 0); eq(#FAKE.messages, 0)
end)

test('venta: revalida la monedita y bloqueos antes de vender', function()
    local id = item(0, 1); item(0, 2)
    FAKE.Fire('MERCHANT_SHOW')
    ns.DB.overrides[id] = 'keep'; FAKE.itemLocks['guid:0:2:1002'] = true
    FAKE.Advance(1); eq(#FAKE.used, 0)
end)

test('venta: combate al abrir espera hasta salir', function()
    item(0, 1); FAKE.inCombat = true
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 0)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED')
    FAKE.Advance(.21); eq(#FAKE.used, 1)
end)

test('venta: cerrar en combate descarta la venta diferida', function()
    item(0, 1); FAKE.inCombat = true; FAKE.Fire('MERCHANT_SHOW')
    FAKE.Fire('MERCHANT_CLOSED'); FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED'); FAKE.Advance(2); eq(#FAKE.used, 0)
end)

test('venta: combate a mitad de cola retoma sin repetir y conserva límite', function()
    item(0, 1); item(0, 2); item(0, 3); ns.DB.autoSell.max = 2
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(.21)
    FAKE.inCombat = true; FAKE.Advance(.3); eq(#FAKE.used, 1)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED'); FAKE.Advance(2)
    eq(#FAKE.used, 2); eq(FAKE.used[2][2], 2)
end)

test('venta: resumen usa dinero del juego y cantidad de la pila', function()
    item(0, 1, 1001, 0, 12345)
    local original = C_Container.GetContainerItemInfo
    C_Container.GetContainerItemInfo = function(bag, slot)
        local info = original(bag, slot)
        if info then info.stackCount = 3 end
        return info
    end
    GetCoinTextureString = function(money) eq(money, 37035); return 'monedas del juego' end
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
    eq(#FAKE.messages, 1); ok(FAKE.messages[1]:find('1 ítems por monedas del juego', 1, true))
    FAKE.Fire('MERCHANT_CLOSED'); eq(#FAKE.messages, 1)
end)

test('venta: nada vendido no imprime resumen', function()
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); FAKE.Fire('MERCHANT_CLOSED')
    eq(#FAKE.used, 0); eq(#FAKE.messages, 0)
end)

for _, path in ipairs({ 'autoSell.enabled', 'enabled' }) do
    local setting = path
    test('venta: apagar ' .. setting .. ' interrumpe la cola', function()
        item(0, 1); item(0, 2); FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(.21)
        ns.Options.Set(setting, false); FAKE.Advance(1); eq(#FAKE.used, 1)
    end)
end

test('venta: detección estática respeta on, off, ausente y valores malformados', function()
    eq(next(ns.AutoSell.OtherSellers()), nil)
    LeaPlusDB = { AutoSellJunk = 'On' }; ElvUI = { { db = { bags = { vendorGrays = { enable = true } } } } }
    local detected = ns.AutoSell.OtherSellers(); ok(detected.Leatrix_Plus); ok(detected.ElvUI)
    eq(LeaPlusDB.AutoSellJunk, 'On'); eq(ElvUI[1].db.bags.vendorGrays.enable, true)
    LeaPlusDB.AutoSellJunk = 'Off'; ElvUI[1].db.bags.vendorGrays.enable = false
    eq(next(ns.AutoSell.OtherSellers()), nil)
    LeaPlusDB, ElvUI = true, { { db = true } }; eq(next(ns.AutoSell.OtherSellers()), nil)
end)

test('venta: advertencias estáticas en General se actualizan sin cambiar ajustes', function()
    LeaPlusDB = { AutoSellJunk = 'On' }; ElvUI = { { db = { bags = { vendorGrays = { enable = true } } } } }
    local panel = ns.Options.Build(); panel:SetSize(500, 600); panel:Show(); ns.Options.Refresh()
    ok(panel.autoSellWarnings.Leatrix_Plus:GetText():find('Leatrix Plus', 1, true))
    ok(panel.autoSellWarnings.ElvUI:GetText():find('Bolsas > Vender grises', 1, true))
    eq(panel.controls['autoSell.max'].widget:GetValue(), 12)
    LeaPlusDB.AutoSellJunk = 'Off'; ElvUI[1].db.bags.vendorGrays.enable = false
    ns.Options.Refresh(); eq(panel.autoSellWarnings.ElvUI:GetText(), '')
    eq(panel.autoSellWarnings.Leatrix_Plus:GetText(), '')
end)

test('venta: llamadas propias nunca denuncian al addon en la pila', function()
    stack('Scrap'); item(0, 1); FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
    eq(#FAKE.messages, 1); ok(FAKE.messages[1]:find('KnuJunk vendió', 1, true))
end)

test('venta: clic aislado de bolsas no alerta, tres en un segundo sí y una vez', function()
    stack('Baganator'); FAKE.Fire('MERCHANT_SHOW')
    C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 0)
    FAKE.Advance(1.1); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 0)
    FAKE.Advance(.3); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 0)
    FAKE.Advance(.3); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
    C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find('Baganator está vendiendo ítems además de KnuJunk.', 1, true))
end)

test('venta: ventana deslizante de detección y contador por addon', function()
    FAKE.Fire('MERCHANT_SHOW'); stack('BolsasA')
    C_Container.UseContainerItem(0, 1); FAKE.Advance(.6); C_Container.UseContainerItem(0, 1)
    FAKE.Advance(.5); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 0)
    FAKE.Advance(.1); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
    stack('BolsasB'); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
end)

for _, name in ipairs({ 'Leatrix_Plus', 'ElvUI', 'Scrap', 'Peddler', 'Dejunk', 'Vendor', 'SellJunk', 'AutoVendor' }) do
    local seller = name
    test('venta: vendedor conocido ' .. seller .. ' alerta una vez por visita', function()
        stack(seller, true); FAKE.Fire('MERCHANT_SHOW')
        C_Container.UseContainerItem(0, 1); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
        FAKE.Fire('MERCHANT_CLOSED'); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 1)
        FAKE.Fire('MERCHANT_SHOW'); C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 2)
    end)
end

test('venta: omite KnuJunk y Blizzard y busca el primer addon externo', function()
    debugstack = function() return 'Interface/AddOns/KnuJunk/AutoSell.lua\nInterface/AddOns/Blizzard_Bags/Main.lua\nInterface/AddOns/Scrap/Main.lua' end
    FAKE.Fire('MERCHANT_SHOW'); C_Container.UseContainerItem(0, 1)
    eq(#FAKE.messages, 1); ok(FAKE.messages[1]:find('Scrap', 1, true))
end)

test('venta: clic manual sin addon y debugstack fallido no alertan', function()
    FAKE.Fire('MERCHANT_SHOW')
    for _, value in ipairs({ 'ContainerFrame.lua:15', 'Interface/AddOns/Blizzard_Bags/Main.lua' }) do
        debugstack = function() return value end
        for _ = 1, 4 do C_Container.UseContainerItem(0, 1) end
    end
    debugstack = function() error('sin pila') end
    C_Container.UseContainerItem(0, 1); eq(#FAKE.messages, 0)
end)

for _, path in ipairs({ 'C_Item', 'C_Item.GetItemGUID', 'ItemLocation', 'ItemLocation.CreateFromBagAndSlot',
    'C_Container', 'C_Container.UseContainerItem', 'C_Timer.NewTicker', 'hooksecurefunc', 'debugstack' }) do
    local missing = path
    test('venta: sin API ' .. missing .. ' no propaga errores', function()
        item(0, 1); FAKE.Remove(missing)
        FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); FAKE.Fire('MERCHANT_CLOSED')
        if missing ~= 'hooksecurefunc' and missing ~= 'debugstack' then eq(#FAKE.used, 0) end
    end)
end

test('venta: fallback global y error de venta no cuenta como vendido', function()
    item(0, 1); C_Container.UseContainerItem = nil
    UseContainerItem = function(bag, slot) FAKE.used[#FAKE.used + 1] = {bag, slot}; error('rechazado') end
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
    eq(#FAKE.used, 1); eq(#FAKE.messages, 0)
end)

test('venta: fallback global vende sin C_Container.UseContainerItem', function()
    item(0, 1); C_Container.UseContainerItem = nil
    UseContainerItem = function(bag, slot) FAKE.used[#FAKE.used + 1] = {bag, slot} end
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
    eq(#FAKE.used, 1); eq(#FAKE.messages, 1)
end)

test('venta: bloqueo propio prevalece aunque IsLocked diga falso', function()
    local id = item(0, 1)
    FAKE.Fire('MERCHANT_SHOW')
    ns.DB.overrides[id] = 'keep'; ns.Merchant.Sync()
    ok(ns.Merchant.IsLocked('guid:0:1:1001'))
    ns.DB.overrides[id] = 'sell'; C_Item.IsLocked = function() return false end
    -- La cola ya existe, pero el bloqueo propio todavía protege el ejemplar.
    withVerdict(function() return 'coin', false, {}, { id=id, price=10, quality=0 } end, function()
        FAKE.Advance(1); eq(#FAKE.used, 0)
    end)
end)

test('venta: revalida calidad, precio y pending antes de cada tick', function()
    for slot = 1, 3 do item(0, slot) end
    ns.DB.autoSell.graysOnly = true; FAKE.Fire('MERCHANT_SHOW')
    withVerdict(function(_, slot)
        return 'coin', slot == 3, {}, { id=1000+slot, quality=slot == 1 and 1 or 0, price=slot == 2 and 0 or 10 }
    end, function()
        FAKE.Advance(1); eq(#FAKE.used, 0); eq(#FAKE.messages, 0)
    end)
end)

test('venta: API de bloqueo o GUID que falla impide vender', function()
    item(0, 1); FAKE.Fire('MERCHANT_SHOW')
    C_Item.IsLocked = function() error('sin datos') end
    FAKE.Advance(1); eq(#FAKE.used, 0)
    FAKE.Fire('MERCHANT_CLOSED')
    C_Item.GetItemGUID = function() error('sin identidad') end
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1); eq(#FAKE.used, 0)
end)

test('venta: textos enUS y resumen sin texturas de moneda', function()
    local original, locale = ns.L, FAKE.locale
    local success, err = pcall(function()
        FAKE.locale = 'enUS'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
        eq(ns.L['Automatic selling'], 'Automatic selling')
        eq(ns.L['Maximum per visit'], 'Maximum per visit')
        item(0, 1, 1001, 0, 12345)
        FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(1)
        ok(FAKE.messages[1]:find('KnuJunk sold 1 items for 1g 23s 45c', 1, true))
    end)
    ns.L, FAKE.locale = original, locale
    if not success then error(err, 0) end
end)
