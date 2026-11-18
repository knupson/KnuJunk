local function item(bag, slot, id, guid, action)
    FAKE.items[id] = { name = 'Item' .. id, quality = 1, price = 10, classID = 15, subclassID = 0 }
    FAKE.bags[bag .. ':' .. slot] = id
    FAKE.guids[bag .. ':' .. slot] = guid
    ns.DB.overrides[id] = action
end
local function setup()
    item(0, 1, 100, 'keep-a', 'keep')
    FAKE.Fire('MERCHANT_SHOW')
    local button = CreateFrame('Button')
    ns.Marks.Update(button, 0, 1, 'generic')
    return button
end
local function ask(button)
    button:Click('RightButton')
    return FAKE.popup
end
local function accept(popup)
    popup.dialog.OnAccept(nil, popup.data)
end

test('vendedor: default activo, sólo keep en bolsas 0 a 4', function()
    eq(ns.DB.protectKeep, true)
    item(0, 1, 100, 'a', 'keep'); item(4, 1, 100, 'b', 'keep')
    item(1, 1, 101, 'sell', 'sell'); item(2, 1, 102, 'auto')
    item(5, 1, 100, 'bank', 'keep'); item(-1, 1, 100, 'bank2', 'keep')
    FAKE.Fire('MERCHANT_SHOW')
    eq(#FAKE.locks, 2); ok(FAKE.itemLocks.a); ok(FAKE.itemLocks.b)
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.locks, 2)
end)

test('vendedor: cerrar sólo libera bloqueos propios', function()
    item(0, 1, 100, 'ours', 'keep'); item(0, 2, 100, 'theirs', 'keep')
    FAKE.itemLocks.theirs = true
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Fire('MERCHANT_CLOSED')
    eq(#FAKE.unlocks, 1); eq(FAKE.unlocks[1], 'ours'); ok(FAKE.itemLocks.theirs)
end)

test('vendedor: Set y Cycle sincronizan marcas sin tocar callers', function()
    item(0, 1, 100, 'a')
    FAKE.Fire('MERCHANT_SHOW'); eq(#FAKE.locks, 0)
    ns.Overrides.Set(100, 'keep'); eq(FAKE.locks[1], 'a')
    ns.Overrides.Cycle(100); eq(FAKE.unlocks[1], 'a')
    ns.Overrides.Set(100, 'keep'); eq(#FAKE.locks, 2)
    ns.Overrides.Set(100, nil); eq(#FAKE.unlocks, 2)
end)

test('vendedor: mover conserva el GUID y retirar libera el antiguo', function()
    setup()
    FAKE.bags['0:1'] = nil; item(3, 2, 100, 'keep-a', 'keep')
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.locks, 1); eq(#FAKE.unlocks, 0)
    FAKE.bags['3:2'] = nil
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(FAKE.unlocks[1], 'keep-a')
    item(0, 1, 100, 'new', 'keep')
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(FAKE.locks[2], 'new')
end)

test('vendedor: apagar libera y reactivar sincroniza enseguida', function()
    local button = setup(); ok(ask(button)); FAKE.popup = nil
    ns.Options.Set('protectKeep', false)
    eq(#FAKE.unlocks, 1); eq(ask(button), nil)
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.locks, 1)
    ns.Options.Set('protectKeep', true); eq(#FAKE.locks, 2); ok(ask(button)); FAKE.popup = nil
    ns.Options.Set('enabled', false); eq(#FAKE.unlocks, 2); eq(ask(button), nil)
end)

test('vendedor: apagado antes de abrir no bloquea ni confirma', function()
    ns.DB.protectKeep = false
    local button = setup(); eq(#FAKE.locks, 0); eq(button.KnuJunkShield, nil)
end)

test('vendedor: combate difiere bloqueos y hook hasta REGEN_ENABLED', function()
    FAKE.inCombat = true
    local button = setup(); eq(#FAKE.locks, 0); eq(button:GetScript('OnClick'), nil)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED')
    eq(#FAKE.locks, 1); eq(button.hookCalls.OnClick, 1); ok(ask(button)); FAKE.popup = nil
    FAKE.inCombat = true; FAKE.Fire('PLAYER_REGEN_DISABLED'); eq(ask(button), nil)
end)

test('vendedor: cerrar en combate no deja bloqueos ni trabajo diferido', function()
    local button = setup(); FAKE.inCombat = true
    FAKE.Fire('MERCHANT_CLOSED'); eq(#FAKE.unlocks, 1); eq(ask(button), nil)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED'); eq(#FAKE.locks, 1)
end)

for _, path in ipairs({ 'C_Item', 'C_Item.LockItemByGUID', 'C_Item.UnlockItemByGUID',
    'C_Item.GetItemGUID', 'ItemLocation', 'ItemLocation.CreateFromBagAndSlot' }) do
    local missing = path
    test('vendedor: sin ' .. missing .. ' no lanza ni bloquea', function()
        FAKE.Remove(missing)
        local button = setup(); eq(#FAKE.locks, 0); eq(button.KnuJunkShield, nil)
        FAKE.Fire('MERCHANT_CLOSED')
    end)
end

test('vendedor: APIs que fallan no propagan errores ni inventan bloqueos', function()
    C_Item.LockItemByGUID = function() error('fallo simulado') end
    local button = setup(); eq(button.KnuJunkShield, nil)
    eq(ns.Merchant.ProtectionText(0, 1), nil)
end)

test('vendedor: un escaneo fallido conserva la protección', function()
    setup()
    C_Container.GetContainerItemID = function() error('lectura fallida') end
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.unlocks, 0)
    FAKE.Fire('MERCHANT_CLOSED'); eq(#FAKE.unlocks, 1)
end)

test('vendedor: botón reciclado usa el último slot y engancha una sola vez', function()
    local button = setup()
    item(2, 3, 100, 'keep-b', 'keep'); FAKE.Fire('BAG_UPDATE_DELAYED')
    for _ = 1, 10 do ns.Marks.Update(button, 2, 3) end
    eq(button.hookCalls.OnClick, 1)
    local popup = ask(button)
    eq(popup.data.bag, 2); eq(popup.data.slot, 3); eq(popup.data.guid, 'keep-b')
    FAKE.popup = nil; ns.Marks.Update(button, 0, 2); eq(ask(button), nil)
    ns.Marks.Update(button, 0, 1)
    eq(ask(button).data.guid, 'keep-a'); eq(button.hookCalls.OnClick, 1)
end)

test('vendedor: sin HookScript conserva bloqueo y texto de protección', function()
    item(0, 1, 100, 'keep-a', 'keep'); FAKE.Fire('MERCHANT_SHOW')
    local button = CreateFrame('Button'); button.HookScript = false
    ns.Marks.Update(button, 0, 1)
    eq(button:GetScript('OnClick'), nil); eq(#FAKE.locks, 1)
    eq(ns.Merchant.ProtectionText(0, 1), 'Protected: right-click to sell')
end)

test('vendedor: sólo clic derecho abre popup con link y configuración requerida', function()
    local button = setup()
    button:Click('LeftButton'); eq(FAKE.popup, nil)
    local popup = ask(button)
    eq(popup.key, 'KNUJUNK_CONFIRM_SELL'); eq(popup.text, FAKE.linkOf(100))
    eq(popup.data.bag, 0); eq(popup.data.slot, 1); eq(popup.data.guid, 'keep-a')
    eq(popup.dialog.timeout, 0); eq(popup.dialog.whileDead, true)
    eq(popup.dialog.hideOnEscape, true); eq(popup.dialog.preferredIndex, 3)
    eq(popup.dialog.button1, YES or ns.L.Yes); eq(popup.dialog.button2, NO or ns.L.No)
    eq(#FAKE.used, 0)
end)

test('vendedor: OnClick original corre antes de la confirmación', function()
    item(0, 1, 100, 'keep-a', 'keep'); FAKE.Fire('MERCHANT_SHOW')
    local button = CreateFrame('Button'); local calls = 0
    button:SetScript('OnClick', function(self, mouse)
        eq(self, button); eq(FAKE.popup, nil); ok(FAKE.itemLocks['keep-a'])
        eq(mouse, calls == 0 and 'LeftButton' or 'RightButton'); calls = calls + 1
    end)
    ns.Marks.Update(button, 0, 1)
    button:Click('LeftButton'); eq(FAKE.popup, nil)
    ok(ask(button)); eq(calls, 2)
end)

for _, scenario in ipairs({ 'cerrado', 'apagado', 'deshabilitado', 'combate', 'sin bloqueo', 'otro GUID', 'bloqueo ajeno' }) do
    local state = scenario
    test('vendedor: clic derecho con ' .. state .. ' no confirma', function()
        local button = setup()
        if state == 'cerrado' then FAKE.Fire('MERCHANT_CLOSED')
        elseif state == 'apagado' then ns.Options.Set('protectKeep', false)
        elseif state == 'deshabilitado' then ns.Options.Set('enabled', false)
        elseif state == 'combate' then FAKE.inCombat = true
        elseif state == 'sin bloqueo' then ns.Overrides.Set(100, nil)
        else
            FAKE.guids['0:1'] = 'replacement'
            if state == 'bloqueo ajeno' then FAKE.itemLocks.replacement = true; FAKE.Fire('BAG_UPDATE_DELAYED') end
        end
        eq(ask(button), nil); eq(#FAKE.used, 0)
    end)
end

test('vendedor: aceptar sólo libera el GUID confirmado', function()
    local button = setup()
    item(0, 2, 100, 'keep-b', 'keep'); item(0, 3, 100, 'foreign', 'keep')
    FAKE.itemLocks.foreign = true; FAKE.Fire('BAG_UPDATE_DELAYED')
    accept(ask(button))
    eq(#FAKE.used, 1); eq(#FAKE.unlocks, 1); eq(FAKE.unlocks[1], 'keep-a')
    ok(FAKE.itemLocks['keep-b']); ok(FAKE.itemLocks.foreign)
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.locks, 2); eq(ns.DB.overrides[100], 'keep')
end)

test('vendedor: sólo abrir y cerrar refrescan las bolsas', function()
    -- Registry también escucha BAG_UPDATE_DELAYED: aislar el manejador de Merchant.
    local merchant
    for _, frame in ipairs(FAKE.frames) do
        if frame.events.MERCHANT_SHOW and frame.events.BAG_UPDATE_DELAYED
            and frame.events.PLAYER_REGEN_DISABLED then merchant = frame end
    end
    ok(merchant)
    local function fire(event) merchant:GetScript('OnEvent')(merchant, event) end
    local refresh, count = ns.Bags.RefreshAll, 0
    ns.Bags.RefreshAll = function() count = count + 1 end
    local success, err = pcall(function()
        item(0, 1, 100, 'keep-a', 'keep'); fire('MERCHANT_SHOW'); eq(count, 1)
        item(0, 2, 100, 'keep-b', 'keep')
        for _ = 1, 10 do fire('BAG_UPDATE_DELAYED') end
        eq(count, 1); eq(#FAKE.locks, 2)
        fire('PLAYER_REGEN_ENABLED'); eq(count, 1)
        fire('MERCHANT_CLOSED'); eq(count, 2)
        fire('BAG_UPDATE_DELAYED'); eq(count, 2)
    end)
    ns.Bags.RefreshAll = refresh
    if not success then error(err) end
end)

test('vendedor: aceptar vende una vez sin cambiar keep ni rebloquear GUID', function()
    local button = setup(); local popup = ask(button)
    accept(popup); accept(popup)
    eq(#FAKE.unlocks, 1); eq(FAKE.unlocks[1], 'keep-a')
    eq(#FAKE.used, 1); eq(FAKE.used[1][1], 0); eq(FAKE.used[1][2], 1)
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.locks, 1)
    eq(ns.DB.overrides[100], 'keep'); eq(ask(button), popup)
    FAKE.Fire('MERCHANT_CLOSED'); FAKE.Fire('MERCHANT_SHOW'); eq(#FAKE.locks, 2)
end)

for _, scenario in ipairs({ 'cerrado', 'otro GUID', 'combate', 'apagado' }) do
    local state = scenario
    test('vendedor: aceptar con ' .. state .. ' no vende', function()
        local button = setup(); local popup = ask(button)
        if state == 'cerrado' then FAKE.Fire('MERCHANT_CLOSED')
        elseif state == 'otro GUID' then FAKE.guids['0:1'] = 'replacement'
        elseif state == 'combate' then FAKE.inCombat = true
        else ns.Options.Set('protectKeep', false) end
        accept(popup); eq(#FAKE.used, 0)
    end)
end

test('vendedor: salir del mundo libera e impide confirmar', function()
    local button = setup(); FAKE.Fire('PLAYER_LEAVING_WORLD')
    eq(#FAKE.unlocks, 1); eq(ask(button), nil)
end)

test('vendedor: fallback global sin C_Container funciona para bloqueo y venta', function()
    local old = C_Container
    C_Container = nil
    for _, key in ipairs({ 'GetContainerNumSlots', 'GetContainerItemID', 'GetContainerItemLink', 'UseContainerItem' }) do
        _G[key] = old[key]
    end
    local success, err = pcall(function()
        local button = setup(); accept(ask(button)); eq(#FAKE.used, 1)
    end)
    for _, key in ipairs({ 'GetContainerNumSlots', 'GetContainerItemID', 'GetContainerItemLink', 'UseContainerItem' }) do _G[key] = nil end
    C_Container = old
    if not success then error(err) end
end)

test('vendedor: tooltip agrega una sola línea mientras hay bloqueo propio', function()
    setup()
    local lines = ns.Tooltip.Lines(FAKE.linkOf(100), nil, 0, 1)
    local matches = 0
    for _, line in ipairs(lines) do if line.text == ns.L['Protected: right-click to sell'] then matches = matches + 1 end end
    eq(matches, 1)
    FAKE.Fire('MERCHANT_CLOSED')
    lines = ns.Tooltip.Lines(FAKE.linkOf(100), nil, 0, 1)
    for _, line in ipairs(lines) do ok(line.text ~= ns.L['Protected: right-click to sell']) end
end)

test('vendedor: una venta con eventos sincrónicos no rebloquea el GUID', function()
    local button = setup(); local popup = ask(button)
    local release = C_Item.UnlockItemByGUID
    C_Item.UnlockItemByGUID = function(guid)
        release(guid)
        FAKE.Fire('BAG_UPDATE_DELAYED')
    end
    accept(popup)
    eq(#FAKE.used, 1); eq(#FAKE.locks, 1); eq(#FAKE.unlocks, 1)
end)

test('vendedor: una venta fallida retira el permiso y vuelve a proteger', function()
    local button = setup()
    C_Container.UseContainerItem = function() error('venta fallida') end
    accept(ask(button))
    eq(#FAKE.locks, 2); eq(#FAKE.used, 0)
    eq(ns.Merchant.ProtectionText(0, 1), 'Protected: right-click to sell')
    FAKE.popup = nil; ok(ask(button))
end)

test('vendedor: desbloqueo fallido impide vender y se reintenta al cerrar', function()
    local button = setup(); local release = C_Item.UnlockItemByGUID
    C_Item.UnlockItemByGUID = function() error('no se pudo liberar') end
    accept(ask(button)); eq(#FAKE.used, 0)
    C_Item.UnlockItemByGUID = release
    FAKE.Fire('MERCHANT_CLOSED'); eq(#FAKE.unlocks, 1)
end)

for _, path in ipairs({ 'GetItemGUID', 'IsLocked' }) do
    local api = path
    test('vendedor: error en ' .. api .. ' no bloquea ni reclama protección', function()
        C_Item[api] = function() error('API fallida') end
        local button = setup(); eq(#FAKE.locks, 0); eq(button.KnuJunkShield, nil)
    end)
end

test('vendedor: sin consulta opcional IsLocked se usan las APIs requeridas', function()
    C_Item.IsLocked = nil
    setup(); eq(#FAKE.locks, 1)
    FAKE.Fire('MERCHANT_CLOSED'); eq(#FAKE.unlocks, 1)
end)

test('vendedor: tooltip no reclama protección de un bloqueo ajeno', function()
    item(0, 1, 100, 'theirs', 'keep'); FAKE.itemLocks.theirs = true
    FAKE.Fire('MERCHANT_SHOW')
    eq(ns.Merchant.ProtectionText(0, 1), nil)
end)

test('vendedor: sin bloqueo efectivo no hay línea de protección', function()
    setup()
    C_Item.GetItemGUID = function() error('lectura fallida') end
    FAKE.Fire('BAG_UPDATE_DELAYED'); eq(#FAKE.unlocks, 0)
    eq(ns.Merchant.ProtectionText(0, 1), nil)
end)

test('vendedor: textos nuevos disponibles en esES, esMX y enUS', function()
    local previous, locale = ns.L, FAKE.locale
    local keys = {
        '%s is protected. Sell it anyway?',
        'Protect protected items at the merchant',
        'Locks them while the merchant is open; right-click asks before selling.',
        'Protected: right-click to sell', 'Protected while the merchant is open', 'Yes', 'No',
    }
    local success, err = pcall(function()
        for _, language in ipairs({ 'esES', 'esMX', 'enUS' }) do
            FAKE.locale = language
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            for _, key in ipairs(keys) do
                if language == 'enUS' or key == 'No' then eq(ns.L[key], key) else ok(ns.L[key] ~= key) end
            end
        end
    end)
    ns.L, FAKE.locale = previous, locale
    if not success then error(err) end
end)
