-- Adaptadores de bolsas con API propia: BetterBags, AdiBags, ArkInventory, EllesmereUIBags,
-- LiteBag, tdBag2 y Baggins. Cada uno con un falso minimo del addon (la forma, no el addon real).
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
end

-- Espia ns.Marks.Update / Clear durante fn (restaura siempre).
local function spy(fn)
    local updates, clears = {}, {}
    local savedUpdate, savedClear = ns.Marks.Update, ns.Marks.Clear
    ns.Marks.Update = function(button, bag, slot, owner)
        updates[#updates + 1] = { button = button, bag = bag, slot = slot, owner = owner }
    end
    ns.Marks.Clear = function(button) clears[#clears + 1] = button end
    local success, err = pcall(fn, updates, clears)
    ns.Marks.Update, ns.Marks.Clear = savedUpdate, savedClear
    if not success then error(err, 0) end
end

-- Prepara globales falsos, corre fn y los restaura aunque falle.
local function withGlobals(names, fn)
    local saved = {}
    for _, name in ipairs(names) do saved[name] = rawget(_G, name) end
    local success, err = pcall(fn)
    for _, name in ipairs(names) do _G[name] = saved[name] end
    if not success then error(err, 0) end
end

-- LibStub falso: libs = { ['AceAddon-3.0'] = tabla, ... }.
local function withLibs(libs, fn)
    withGlobals({ 'LibStub' }, function()
        LibStub = setmetatable({}, { __call = function(_, name) return libs[name] end })
        fn()
    end)
end

local function isInstalled(name)
    for _, installedName in ipairs(ns.Bags.Installed()) do
        if installedName == name then return true end
    end
    return false
end

-- Carga el addon de la bolsa (para el registro) e intenta instalar.
local function install(folder)
    FAKE.addons[folder] = true
    ns.Bags.InstallAll()
end

local function marked(button)
    local texture = button.KnuJunkMark
    return texture ~= nil and texture:IsShown() == true
end

-- Boton de bolsa que MUESTRA el item itemID (por defecto el 100) segun su propio campo itemID.
local function slotButton(name, parent, id, itemID)
    local button = CreateFrame('Button', name, parent)
    button.id = id
    button.itemID = itemID == nil and 100 or itemID
    return button
end

-- ---------------------------------------------------------------------------
-- BetterBags
-- ---------------------------------------------------------------------------

-- AceAddon falso con modulo Events (graba los callbacks) y modulo ItemFrame.
local function betterBags()
    local state = { handlers = {}, buttons = {} }
    local events = { RegisterMessage = function(_, message, fn) state.handlers[message] = fn end }
    local itemFrame = { buttonsBySlotkey = state.buttons }
    local addon = { GetModule = function(_, name)
        if name == 'Events' then return events end
        if name == 'ItemFrame' then return itemFrame end
    end }
    state.libs = { ['AceAddon-3.0'] = { GetAddon = function(_, name) if name == 'BetterBags' then return addon end end } }
    state.events = events
    return state
end

local function betterItem(bag, slot, itemID, extra)
    local item = { GetItemData = function() return { bagid = bag, slotid = slot, itemInfo = { itemID = itemID } } end }
    for key, value in pairs(extra or {}) do item[key] = value end
    return item
end

test('BetterBags: install registra los tres mensajes y Update recibe bag/slot/owner', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        ok(isInstalled('BetterBags'), 'instalado')
        ok(state.handlers['item/Updated'] and state.handlers['item/Clearing'] and state.handlers['item/NewButton'])
        addItem(100); FAKE.bags['0:3'] = 100
        local decoration = CreateFrame('Button')
        spy(function(updates)
            state.handlers['item/Updated'](nil, betterItem(0, 3, 100), decoration)
            eq(#updates, 1)
            eq(updates[1].button, decoration); eq(updates[1].bag, 0); eq(updates[1].slot, 3)
            eq(updates[1].owner, 'BetterBags')
            state.handlers['item/NewButton'](nil, betterItem(0, 3, 100), decoration)
            eq(#updates, 2, 'boton nuevo tambien pinta')
        end)
    end)
end)

test('BetterBags: pinta de verdad la moneda y item/Clearing la quita', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['1:2'] = 100
        local decoration = CreateFrame('Button')
        state.handlers['item/Updated'](nil, betterItem(1, 2, 100), decoration)
        ok(marked(decoration), 'gris = moneda')
        eq(decoration.KnuJunkOwner, 'BetterBags')
        state.handlers['item/Clearing'](nil, betterItem(1, 2, 100), decoration)
        ok(not marked(decoration), 'boton liberado sin marca')
    end)
end)

test('BetterBags: hueco libre, virtual, soltado o vacio -> sin marca', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100
        spy(function(updates, clears)
            local decoration = CreateFrame('Button')
            for _, flag in ipairs({ 'isFreeSlot', 'isVirtual', 'released', 'blank', 'staticData' }) do
                state.handlers['item/Updated'](nil, betterItem(0, 3, 100, { [flag] = true }), decoration)
            end
            state.handlers['item/Updated'](nil, { GetItemData = function() return { bagid = 0, slotid = 3, isItemEmpty = true, itemInfo = { itemID = 100 } } end }, decoration)
            state.handlers['item/Updated'](nil, { GetItemData = function() return nil end }, decoration)
            state.handlers['item/Updated'](nil, { GetItemData = function() return { bagid = 0, slotid = 3 } end }, decoration)
            state.handlers['item/Updated'](nil, { GetItemData = function() error('roto') end }, decoration)
            eq(#updates, 0, 'nunca Update')
            eq(#clears, 9, 'todo queda limpio')
        end)
    end)
end)

test('BetterBags: banco (bolsa fuera de 0-4) y slot con otro item -> sin marca', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); addItem(101)
        FAKE.bags['0:3'] = 101; FAKE.bags['6:1'] = 100
        spy(function(updates, clears)
            local decoration = CreateFrame('Button')
            state.handlers['item/Updated'](nil, betterItem(0, 3, 100), decoration)
            eq(#updates, 0, 'el slot ya tiene otro item')
        end)
        local bank = CreateFrame('Button')
        state.handlers['item/Updated'](nil, betterItem(6, 1, 100), bank)
        ok(not marked(bank), 'bolsa 6 no se marca')
    end)
end)

test('BetterBags: sin decoracion usa item.button; sin ninguno no hace nada', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100
        spy(function(updates)
            local button = CreateFrame('Button')
            state.handlers['item/Updated'](nil, betterItem(0, 3, 100, { button = button }), nil)
            eq(#updates, 1); eq(updates[1].button, button)
            state.handlers['item/Updated'](nil, betterItem(0, 3, 100), nil)
            eq(#updates, 1)
        end)
    end)
end)

test('BetterBags: el refresco repinta los botones que ya tiene ItemFrame', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100
        local decoration = CreateFrame('Button')
        state.buttons['0:3'] = betterItem(0, 3, 100, { _decoration = decoration })
        spy(function(updates)
            ns.Bags.RefreshAll(); FAKE.Advance(1)
            ok(#updates >= 1, 'repinta')
            eq(updates[1].button, decoration)
        end)
    end)
end)

test('BetterBags: sin AceAddon, sin el addon o sin Events -> install false y se reintenta', function()
    FAKE.addons.BetterBags = true
    ok(ns.BetterBagsAdapter.Install() == false, 'sin LibStub/AceAddon')
    local state = betterBags()
    state.libs['AceAddon-3.0'].GetAddon = function() return nil end
    withLibs(state.libs, function()
        ok(ns.BetterBagsAdapter.Install() == false, 'AceAddon sin BetterBags')
    end)
    local noEvents = betterBags()
    noEvents.events.RegisterMessage = nil
    withLibs(noEvents.libs, function()
        ok(ns.BetterBagsAdapter.Install() == false, 'Events sin RegisterMessage')
    end)
    ns.Bags.InstallAll()
    ok(not isInstalled('BetterBags'))
    local later = betterBags()
    withLibs(later.libs, function()
        ns.Bags.InstallAll()
        ok(isInstalled('BetterBags'), 'se instala cuando aparece')
    end)
end)

test('BetterBags: un registro que falla se reintenta sin duplicar el resto', function()
    local state = betterBags()
    local calls = 0
    state.events.RegisterMessage = function(_, message, fn)
        calls = calls + 1
        if message == 'item/Clearing' and calls <= 3 then error('roto') end
        state.handlers[message] = fn
    end
    withLibs(state.libs, function()
        FAKE.addons.BetterBags = true
        ok(ns.BetterBagsAdapter.Install() == false, 'falta el de Clearing')
        local before = calls
        ok(ns.BetterBagsAdapter.Install() == true, 'reintento correcto')
        eq(calls - before, 1, 'solo se reintenta lo que falto')
    end)
end)

-- ---------------------------------------------------------------------------
-- AdiBags
-- ---------------------------------------------------------------------------

local function adiBags()
    local state = { handlers = {}, receivers = {} }
    state.libs = { ['ABEvent-1.0'] = { RegisterMessage = function(receiver, message, fn)
        state.handlers[message] = fn; state.receivers[message] = receiver
    end } }
    return state
end

test('AdiBags: install registra los tres mensajes y UpdateButton llama Update con bag/slot/owner', function()
    local state = adiBags()
    withLibs(state.libs, function()
        install('AdiBags')
        ok(isInstalled('AdiBags'))
        for _, message in ipairs({ 'AdiBags_AcquireButton', 'AdiBags_UpdateButton', 'AdiBags_ReleaseButton' }) do
            ok(state.handlers[message], message)
        end
        addItem(100); FAKE.bags['2:5'] = 100
        local button = CreateFrame('Button')
        button.bag, button.slot, button.itemId = 2, 5, 100
        spy(function(updates)
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', button)
            eq(#updates, 1)
            eq(updates[1].button, button); eq(updates[1].bag, 2); eq(updates[1].slot, 5); eq(updates[1].owner, 'AdiBags')
        end)
    end)
end)

test('AdiBags: pinta la moneda; soltar o recibir un boton reciclado lo limpia', function()
    local state = adiBags()
    withLibs(state.libs, function()
        install('AdiBags')
        addItem(100); FAKE.bags['0:1'] = 100
        local button = CreateFrame('Button')
        button.bag, button.slot, button.itemId = 0, 1, 100
        state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', button)
        ok(marked(button), 'moneda')
        state.handlers.AdiBags_ReleaseButton('AdiBags_ReleaseButton', button)
        ok(not marked(button), 'soltado: sin marca')
        state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', button)
        ok(marked(button), 'vuelve a usarse')
        state.handlers.AdiBags_AcquireButton('AdiBags_AcquireButton', button)
        ok(not marked(button), 'reciclado: sin marca hasta el siguiente Update')
    end)
end)

test('AdiBags: banco, slot con otro item y datos incompletos -> sin marca', function()
    local state = adiBags()
    withLibs(state.libs, function()
        install('AdiBags')
        addItem(100); addItem(101)
        FAKE.bags['0:1'] = 101; FAKE.bags['-1:2'] = 100
        spy(function(updates, clears)
            local stale = CreateFrame('Button'); stale.bag, stale.slot, stale.itemId = 0, 1, 100
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', stale)
            local bank = CreateFrame('Button'); bank.bag, bank.slot, bank.itemId = -1, 2, 100
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', bank)
            local blank = CreateFrame('Button')
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', blank)
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', nil)
            eq(#updates, 1, 'solo el del banco llega a Update (Marks lo descarta)')
            eq(updates[1].button, bank)
        end)
        local bank = CreateFrame('Button'); bank.bag, bank.slot, bank.itemId = -1, 2, 100
        state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', bank)
        ok(not marked(bank), 'banco sin marca')
    end)
end)

test('AdiBags: sin ABEvent -> install false; se completa si un registro falla', function()
    FAKE.addons.AdiBags = true
    ok(ns.AdiBagsAdapter.Install() == false, 'sin LibStub')
    withLibs({}, function() ok(ns.AdiBagsAdapter.Install() == false, 'sin ABEvent') end)
    withLibs({ ['ABEvent-1.0'] = {} }, function() ok(ns.AdiBagsAdapter.Install() == false, 'sin RegisterMessage') end)
    ns.Bags.InstallAll()
    ok(not isInstalled('AdiBags'))
    local state, fail = adiBags(), true
    local register = state.libs['ABEvent-1.0'].RegisterMessage
    state.libs['ABEvent-1.0'].RegisterMessage = function(receiver, message, fn)
        if fail and message == 'AdiBags_ReleaseButton' then error('roto') end
        register(receiver, message, fn)
    end
    withLibs(state.libs, function()
        ok(ns.AdiBagsAdapter.Install() == false, 'falta el de Release')
        fail = false
        ok(ns.AdiBagsAdapter.Install() == true, 'reintento correcto')
    end)
end)

-- ---------------------------------------------------------------------------
-- ArkInventory
-- ---------------------------------------------------------------------------

local BAG_LOCATION, VAULT_LOCATION = 1, 4

local function ark()
    local state = { offline = {} }
    -- Contrato de ArkInventory 3.12.17: ArkInventoryConst.lua:1066 (Location), ArkInventoryAPI.lua:113
    -- (ItemFrameUpdated(frame, loc_id, bag_id, slot_id)) y :273 (LocationIsOffline: true/false/nil).
    ArkInventory = {
        Const = { Location = { Bag = BAG_LOCATION, Keyring = 2, Bank = 3, Vault = VAULT_LOCATION } },
        API = {
            ItemFrameUpdated = function() end,
            LocationIsOffline = function(location)
                if location ~= BAG_LOCATION and location ~= 2 and location ~= 3 and location ~= VAULT_LOCATION then return nil end
                return state.offline[location] == true
            end,
            ItemFrameItemTableGet = function(frame) return frame.item end,
        },
    }
    state.fire = function(frame, location) ArkInventory.API.ItemFrameUpdated(frame, location, frame.ARK_Data and frame.ARK_Data.bag_id, frame.ARK_Data and frame.ARK_Data.slot_id) end
    return state
end

local function arkFrame(bag, slot, itemID)
    local frame = CreateFrame('Button')
    frame.ARK_Data = { loc_id = BAG_LOCATION, bag_id = 1, blizzard_id = bag, slot_id = slot }
    frame.item = itemID and { h = FAKE.linkOf(itemID) } or nil
    return frame
end

test('ArkInventory: engancha ItemFrameUpdated y Update recibe bag/slot/owner', function()
    local state = ark()
    install('ArkInventory')
    ok(isInstalled('ArkInventory'))
    addItem(100); FAKE.bags['3:7'] = 100
    local frame = arkFrame(3, 7, 100)
    spy(function(updates)
        state.fire(frame, BAG_LOCATION)
        eq(#updates, 1)
        eq(updates[1].button, frame); eq(updates[1].bag, 3); eq(updates[1].slot, 7); eq(updates[1].owner, 'ArkInventory')
    end)
end)

test('ArkInventory: pinta de verdad la moneda', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); FAKE.bags['0:1'] = 100
    local frame = arkFrame(0, 1, 100)
    state.fire(frame, BAG_LOCATION)
    ok(marked(frame), 'moneda en bolsa viva')
end)

test('ArkInventory: vista offline (otro personaje o banco recordado) -> sin marca', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); FAKE.bags['0:1'] = 100
    local frame = arkFrame(0, 1, 100)
    state.fire(frame, BAG_LOCATION)
    ok(marked(frame), 'control: online se marca')
    state.offline[BAG_LOCATION] = true
    spy(function(updates, clears)
        state.fire(frame, BAG_LOCATION)
        eq(#updates, 0, 'offline: nunca Update')
        eq(#clears, 1, 'offline: se limpia el boton')
    end)
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'offline: sin marca de verdad')
end)

test('ArkInventory: ubicacion que no es la de bolsas, o sin constantes -> sin marca', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); FAKE.bags['2:1'] = 100
    local frame = arkFrame(2, 1, 100)
    state.fire(frame, VAULT_LOCATION)
    ok(not marked(frame), 'hermandad online no es una bolsa')
    ArkInventory.Const = nil
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'sin ArkInventory.Const no hay prueba')
    ArkInventory.Const = { Location = {} }
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'sin Location.Bag no hay prueba')
end)

test('ArkInventory: item mostrado distinto, sin item, sin datos o API que falla -> sin marca', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); addItem(101); FAKE.bags['0:1'] = 101
    spy(function(updates)
        state.fire(arkFrame(0, 1, 100), BAG_LOCATION)
        state.fire(arkFrame(0, 1, nil), BAG_LOCATION)
        local noData = arkFrame(0, 1, 100); noData.ARK_Data = nil
        state.fire(noData, BAG_LOCATION)
        ArkInventory.API.ItemFrameItemTableGet = function() error('roto') end
        state.fire(arkFrame(0, 1, 100), BAG_LOCATION)
        eq(#updates, 0)
    end)
    ArkInventory.API.LocationIsOffline = function() error('roto') end
    local frame = arkFrame(0, 1, 101)
    ArkInventory.API.ItemFrameItemTableGet = function(f) return f.item end
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'LocationIsOffline que falla = sin marca')
end)

test('ArkInventory: sin la API completa -> install false; no se engancha dos veces', function()
    FAKE.addons.ArkInventory = true
    ok(ns.ArkInventoryAdapter.Install() == false, 'sin ArkInventory')
    ArkInventory = { API = { ItemFrameUpdated = function() end } }
    ok(ns.ArkInventoryAdapter.Install() == false, 'API incompleta')
    ns.Bags.InstallAll()
    ok(not isInstalled('ArkInventory'))
    local state = ark()
    ok(ns.ArkInventoryAdapter.Install() == true)
    ok(ns.ArkInventoryAdapter.Install() == true, 'segunda llamada: ya esta')
    addItem(100); FAKE.bags['0:1'] = 100
    local frame = arkFrame(0, 1, 100)
    spy(function(updates)
        state.fire(frame, BAG_LOCATION)
        eq(#updates, 1, 'un solo hook')
    end)
end)

-- ---------------------------------------------------------------------------
-- EllesmereUIBags
-- ---------------------------------------------------------------------------

local function eui()
    local state = { calls = 0 }
    EUI_Bags = { RegisterItemOverlayIcon = function(name, fn)
        state.calls = state.calls + 1
        state.name, state.callback = name, fn
    end }
    return state
end

test('EllesmereUIBags: registra el overlay y Update recibe bag/slot/owner', function()
    local state = eui()
    install('EllesmereUIBags')
    ok(isInstalled('EllesmereUIBags'))
    eq(state.name, 'KnuJunk')
    addItem(100); FAKE.bags['0:2'] = 100
    local button = CreateFrame('Button')
    spy(function(updates)
        state.callback(button, { bag = 0, slot = 2, info = { itemID = 100 } })
        eq(#updates, 1)
        eq(updates[1].button, button); eq(updates[1].bag, 0); eq(updates[1].slot, 2); eq(updates[1].owner, 'EllesmereUIBags')
    end)
    ns.Bags.InstallAll(); ns.EllesmereUIAdapter.Install()
    eq(state.calls, 1, 'no se registra dos veces')
end)

test('EllesmereUIBags: pinta la moneda; usa itemLink si no hay info; banco y otro item -> sin marca', function()
    local state = eui()
    install('EllesmereUIBags')
    addItem(100); addItem(101)
    FAKE.bags['0:2'] = 100; FAKE.bags['1:1'] = 101; FAKE.bags['-1:3'] = 100
    local button = CreateFrame('Button')
    state.callback(button, { bag = 0, slot = 2, itemLink = FAKE.linkOf(100) })
    ok(marked(button), 'moneda por itemLink')
    state.callback(button, { bag = 1, slot = 1, info = { itemID = 100 } })
    ok(not marked(button), 'el slot tiene otro item')
    state.callback(button, { bag = 0, slot = 2, info = { itemID = 100 } })
    ok(marked(button))
    state.callback(button, { bag = -1, slot = 3, info = { itemID = 100 } })
    ok(not marked(button), 'banco')
    state.callback(button, { bag = 0, slot = 2, info = { itemID = 100 } })
    state.callback(button, nil)
    ok(not marked(button), 'sin data se limpia')
    state.callback(button, {})
    ok(not marked(button), 'data sin bag/slot')
    state.callback(nil, { bag = 0, slot = 2 })
end)

test('EllesmereUIBags: EUI recicla su tabla data -> el refresco usa los escalares copiados', function()
    local state = eui()
    install('EllesmereUIBags')
    addItem(100); FAKE.bags['0:2'] = 100
    local button, data = CreateFrame('Button'), { bag = 0, slot = 2, info = { itemID = 100 } }
    state.callback(button, data)
    data.bag, data.slot, data.info = nil, nil, nil
    spy(function(updates)
        ns.Bags.RefreshAll(); FAKE.Advance(1)
        ok(#updates >= 1)
        eq(updates[1].bag, 0); eq(updates[1].slot, 2)
    end)
end)

test('EllesmereUIBags: sin EUI_Bags o sin RegisterItemOverlayIcon -> install false', function()
    FAKE.addons.EllesmereUIBags = true
    ok(ns.EllesmereUIAdapter.Install() == false)
    EUI_Bags = {}
    ok(ns.EllesmereUIAdapter.Install() == false)
    EUI_Bags = { RegisterItemOverlayIcon = function() error('roto') end }
    ok(ns.EllesmereUIAdapter.Install() == false, 'registro que falla')
    ns.Bags.InstallAll()
    ok(not isInstalled('EllesmereUIBags'))
    eui()
    ok(ns.EllesmereUIAdapter.Install() == true, 'reintento correcto')
end)

-- ---------------------------------------------------------------------------
-- LiteBag
-- ---------------------------------------------------------------------------

local function liteBag()
    local state = {}
    LiteBag_RegisterHook = function(event, fn) state.event, state.callback, state.calls = event, fn, (state.calls or 0) + 1 end
    return state
end

test('LiteBag: registra el gancho y Update recibe bag (del padre), slot y owner', function()
    local state = liteBag()
    install('LiteBag')
    ok(isInstalled('LiteBag'))
    eq(state.event, 'LiteBagItemButton_Update')
    addItem(100); FAKE.bags['2:4'] = 100
    local panel = CreateFrame('Frame', 'LiteBagBackpackPanelBag3'); panel.id = 2
    local button = slotButton('LiteBagBackpackPanelBag3Item4', panel, 4)
    spy(function(updates)
        state.callback(button)
        eq(#updates, 1)
        eq(updates[1].button, button); eq(updates[1].bag, 2); eq(updates[1].slot, 4); eq(updates[1].owner, 'LiteBag')
    end)
    ns.LiteBagAdapter.Install()
    eq(state.calls, 1, 'no se registra dos veces')
end)

test('LiteBag: GetBagID del boton manda sobre el padre; pinta la moneda', function()
    local state = liteBag()
    install('LiteBag')
    addItem(100); FAKE.bags['1:6'] = 100
    local panel = CreateFrame('Frame', 'LiteBagBackpackPanel'); panel.id = 99
    local button = slotButton('LiteBagItemX', panel, 6)
    function button:GetBagID() return 1 end
    state.callback(button)
    ok(marked(button), 'moneda')
    eq(button.KnuJunkOwner, 'LiteBag')
end)

test('LiteBag: banco, hermandad, vista cacheada o ascendencia ilegible -> sin marca', function()
    local state = liteBag()
    install('LiteBag')
    addItem(100); FAKE.bags['0:1'] = 100
    local function trial(panelName, tweak)
        local panel = CreateFrame('Frame', panelName); panel.id = 0
        if tweak then tweak(panel) end
        local button = slotButton(nil, panel, 1)
        state.callback(button)
        return marked(button)
    end
    ok(trial('LiteBagBackpackPanelOk') == true, 'control: mochila viva')
    ok(trial('LiteBagBankPanel') == false, 'banco')
    ok(trial('LiteBagGuildBankPanel') == false, 'hermandad')
    ok(trial('LiteBagVaultPanel') == false, 'vault')
    ok(trial('LiteBagBackpackPanelCached', function(panel) panel.isCached = true end) == false, 'cache')
    ok(trial('LiteBagBackpackPanelCachedFn', function(panel) function panel:IsCached() return true end end) == false, 'IsCached()')
    local loop = CreateFrame('Frame', 'LiteBagLoop'); loop.id = 0; loop.parent = loop
    local button = slotButton(nil, loop, 1)
    state.callback(button)
    ok(not marked(button), 'ciclo de padres: no se puede probar')
end)

test('LiteBag: sin el gancho -> install false y se reintenta', function()
    FAKE.addons.LiteBag = true
    ok(ns.LiteBagAdapter.Install() == false)
    LiteBag_RegisterHook = function() error('roto') end
    ok(ns.LiteBagAdapter.Install() == false, 'registro que falla')
    ns.Bags.InstallAll()
    ok(not isInstalled('LiteBag'))
    liteBag()
    ns.Bags.InstallAll()
    ok(isInstalled('LiteBag'), 'se instala cuando aparece')
end)

-- ---------------------------------------------------------------------------
-- tdBag2
-- ---------------------------------------------------------------------------

local function tdBag2Fake()
    local state = { calls = 0 }
    tdBag2 = { RegisterPlugin = function(self, plugin)
        assert(self == tdBag2, 'se llama con dos puntos')
        state.calls = state.calls + 1
        state.plugin = plugin
    end }
    return state
end

local function meta(isBag, isSelf)
    return { IsBag = function() return isBag end, IsSelf = function() return isSelf end }
end

local function tdButton(bag, slot, buttonMeta)
    local frame = CreateFrame('Frame', 'tdBag2Frame1')
    local button = CreateFrame('Button', nil, frame)
    button.bag, button.slot, button.meta = bag, slot, buttonMeta
    button.itemID = 100
    return button
end

test('tdBag2: registra el plugin y Update recibe bag/slot/owner en init y update', function()
    local state = tdBag2Fake()
    install('tdBag2')
    ok(isInstalled('tdBag2'))
    eq(state.plugin.type, 'Item'); eq(state.plugin.key, 'KnuJunk')
    addItem(100); FAKE.bags['4:2'] = 100
    local button = tdButton(4, 2, meta(true, true))
    spy(function(updates)
        state.plugin.init(button)
        state.plugin.update(button)
        eq(#updates, 2)
        eq(updates[1].button, button); eq(updates[1].bag, 4); eq(updates[1].slot, 2); eq(updates[1].owner, 'tdBag2')
    end)
    ns.TdBag2Adapter.Install()
    eq(state.calls, 1, 'no se registra dos veces')
end)

test('tdBag2: otro personaje, banco o sin meta -> sin marca; el propio se pinta', function()
    local state = tdBag2Fake()
    install('tdBag2')
    addItem(100); FAKE.bags['0:1'] = 100
    local live = tdButton(0, 1, meta(true, true))
    state.plugin.update(live)
    ok(marked(live), 'bolsa propia')
    local other = tdButton(0, 1, meta(true, false))
    state.plugin.update(other)
    ok(not marked(other), 'otro personaje (IsSelf falso)')
    local bank = tdButton(0, 1, meta(false, true))
    state.plugin.update(bank)
    ok(not marked(bank), 'no es bolsa (IsBag falso)')
    local noMeta = tdButton(0, 1, nil)
    state.plugin.update(noMeta)
    ok(not marked(noMeta), 'sin meta no hay prueba')
    state.plugin.update(live)
    ok(marked(live))
    local noBag = tdButton(nil, 1, meta(true, true))
    state.plugin.update(noBag)
    ok(not marked(noBag), 'sin bolsa')
    local bankFrame = CreateFrame('Frame', 'tdBag2BankFrame')
    local inBank = CreateFrame('Button', nil, bankFrame)
    inBank.bag, inBank.slot, inBank.meta, inBank.itemID = 0, 1, meta(true, true), 100
    state.plugin.update(inBank)
    ok(not marked(inBank), 'colgado de un marco de banco')
end)

test('tdBag2: sin RegisterPlugin o con registro roto -> install false', function()
    FAKE.addons.tdBag2 = true
    ok(ns.TdBag2Adapter.Install() == false, 'sin tdBag2')
    tdBag2 = {}
    ok(ns.TdBag2Adapter.Install() == false, 'sin RegisterPlugin')
    tdBag2 = { RegisterPlugin = function() error('roto') end }
    ok(ns.TdBag2Adapter.Install() == false, 'registro que falla')
    ns.Bags.InstallAll()
    ok(not isInstalled('tdBag2'))
    tdBag2Fake()
    ok(ns.TdBag2Adapter.Install() == true, 'reintento correcto')
end)

-- ---------------------------------------------------------------------------
-- Baggins
-- ---------------------------------------------------------------------------

local function bagginsFake()
    local state = { signals = {}, calls = 0 }
    Baggins = {
        bagframes = {},
        RegisterSignal = function(self, signal, fn, receiver)
            assert(self == Baggins, 'se llama con dos puntos')
            state.calls = state.calls + 1
            state.signals[signal] = { fn = fn, receiver = receiver }
        end,
    }
    return state
end

local function bagginsButton(name, bag, slot, frameName)
    local bagFrame = CreateFrame('Frame', frameName or ('BagginsBag' .. bag .. name)); bagFrame.id = bag
    return slotButton(nil, bagFrame, slot)
end

test('Baggins: registra senales y ItemButtonUpdated llama Update con bag (del padre), slot y owner', function()
    local state = bagginsFake()
    install('Baggins')
    ok(isInstalled('Baggins'))
    ok(state.signals.Baggins_ItemButtonUpdated and state.signals.Baggins_BagOpened)
    addItem(100); FAKE.bags['0:5'] = 100
    local button = bagginsButton('a', 0, 5)
    local signal = state.signals.Baggins_ItemButtonUpdated
    spy(function(updates)
        signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', button)
        eq(#updates, 1)
        eq(updates[1].button, button); eq(updates[1].bag, 0); eq(updates[1].slot, 5); eq(updates[1].owner, 'Baggins')
        signal.fn(button) -- por si Baggins lo pasa como unico argumento
        eq(#updates, 2)
        signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated')
        eq(#updates, 2, 'sin boton no hace nada')
    end)
    ns.BagginsAdapter.Install()
    eq(state.calls, 2, 'no se registra dos veces')
end)

test('Baggins: pinta la moneda; banco, hermandad o vista cacheada -> sin marca', function()
    local state = bagginsFake()
    install('Baggins')
    addItem(100); FAKE.bags['0:5'] = 100; FAKE.bags['-1:5'] = 100
    local signal = state.signals.Baggins_ItemButtonUpdated
    local live = bagginsButton('live', 0, 5)
    signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', live)
    ok(marked(live), 'moneda')
    local bank = bagginsButton('bank', -1, 5)
    signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', bank)
    ok(not marked(bank), 'bolsa -1')
    local named = bagginsButton('named', 0, 5, 'BagginsBankFrame')
    signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', named)
    ok(not marked(named), 'marco de banco')
    local cached = bagginsButton('cached', 0, 5)
    cached.parent.isCached = true
    signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', cached)
    ok(not marked(cached), 'cache')
end)

test('Baggins: BagOpened y el refresco recorren bagframes[i].sections[j].items[k]', function()
    local state = bagginsFake()
    install('Baggins')
    addItem(100); FAKE.bags['0:1'] = 100; FAKE.bags['0:2'] = 100
    local first, second = bagginsButton('x', 0, 1), bagginsButton('y', 0, 2)
    local hidden = bagginsButton('z', 0, 3); hidden:Hide()
    Baggins.bagframes = { { sections = { { items = { first, second } }, { items = { hidden } } } }, {}, { sections = {} } }
    spy(function(updates)
        local opened = state.signals.Baggins_BagOpened
        opened.fn(opened.receiver)
        eq(#updates, 2, 'los dos visibles')
        eq(updates[1].button, first); eq(updates[2].button, second); eq(updates[2].slot, 2)
    end)
    spy(function(updates)
        ns.Bags.RefreshAll(); FAKE.Advance(1)
        ok(#updates >= 2, 'el refresco tambien recorre')
    end)
    Baggins.bagframes = 'roto'
    ns.Bags.RefreshAll(); FAKE.Advance(1) -- no lanza
end)

test('Baggins: sin RegisterSignal o con registro roto -> install false; BagOpened es opcional', function()
    FAKE.addons.Baggins = true
    ok(ns.BagginsAdapter.Install() == false, 'sin Baggins')
    Baggins = {}
    ok(ns.BagginsAdapter.Install() == false, 'sin RegisterSignal')
    Baggins = { RegisterSignal = function(_, signal) if signal == 'Baggins_ItemButtonUpdated' then error('roto') end end }
    ok(ns.BagginsAdapter.Install() == false, 'falla la senal del boton')
    ns.Bags.InstallAll()
    ok(not isInstalled('Baggins'))
    Baggins = { RegisterSignal = function(_, signal) if signal == 'Baggins_BagOpened' then error('roto') end end }
    ok(ns.BagginsAdapter.Install() == true, 'sin BagOpened alcanza con la del boton')
end)

-- ---------------------------------------------------------------------------
-- Comunes
-- ---------------------------------------------------------------------------

test('registro: las siete bolsas con API propia usan la carpeta de su addon', function()
    for _, folder in ipairs({ 'BetterBags', 'AdiBags', 'ArkInventory', 'EllesmereUIBags', 'LiteBag', 'tdBag2', 'Baggins' }) do
        ns.Bags.InstallAll()
        ok(not isInstalled(folder), folder .. ' no se instala sin su addon')
    end
    -- con la carpeta cargada pero sin su API tampoco
    for _, folder in ipairs({ 'BetterBags', 'AdiBags', 'ArkInventory', 'EllesmereUIBags', 'LiteBag', 'tdBag2', 'Baggins' }) do
        FAKE.addons[folder] = true
    end
    ns.Bags.InstallAll()
    for _, folder in ipairs({ 'BetterBags', 'AdiBags', 'ArkInventory', 'EllesmereUIBags', 'LiteBag', 'tdBag2', 'Baggins' }) do
        ok(not isInstalled(folder), folder .. ' sin API: sin instalar')
    end
end)

test('un fallo del lector o de Marks.Update no rompe al addon de bolsas', function()
    local state = adiBags()
    withLibs(state.libs, function()
        install('AdiBags')
        addItem(100); FAKE.bags['0:1'] = 100
        local button = CreateFrame('Button')
        button.bag, button.slot, button.itemId = 0, 1, 100
        local saved = ns.Marks.Update
        ns.Marks.Update = function() error('Marks roto') end
        local success = pcall(state.handlers.AdiBags_UpdateButton, 'AdiBags_UpdateButton', button)
        ns.Marks.Update = saved
        ok(success, 'el callback no propaga el error')
    end)
end)

-- ---------------------------------------------------------------------------
-- Ronda de arreglos 1: identidad del item mostrado, retomar sin pintar a ciegas, ascendencia
-- ---------------------------------------------------------------------------

-- Hace que Player.ReadItem no tenga datos durante fn (el cliente aun no conoce el item).
local function withoutItemData(fn)
    local saved = ns.Player.ReadItem
    ns.Player.ReadItem = function() return nil end
    local success, err = pcall(fn)
    ns.Player.ReadItem = saved
    if not success then error(err, 0) end
end

test('BetterBags: datos pendientes + el slot pasa a un gris sin redibujar -> sin moneda', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100, { quality = 1, classID = 2, subclassID = 0, spell = true }) -- util
        addItem(101)                                                              -- gris
        FAKE.bags['0:3'] = 100
        local decoration = CreateFrame('Button')
        withoutItemData(function()
            state.handlers['item/Updated'](nil, betterItem(0, 3, 100), decoration)
        end)
        ok(not marked(decoration), 'aun sin datos: sin marca')
        FAKE.bags['0:3'] = 101       -- el boton todavia dice 100
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
        ok(not marked(decoration), 'el addon sigue mostrando 100 pero el slot tiene otro item')
    end)
end)

test('BetterBags: control, datos pendientes que llegan con el mismo item -> se marca', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100
        local decoration = CreateFrame('Button')
        withoutItemData(function() state.handlers['item/Updated'](nil, betterItem(0, 3, 100), decoration) end)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
        ok(marked(decoration))
        eq(decoration.KnuJunkOwner, 'BetterBags')
    end)
end)

test('BetterBags: la vista pasa a hueco virtual o a banco antes de llegar los datos -> sin marca', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100; FAKE.bags['6:1'] = 100
        local virtual, bank = CreateFrame('Button'), CreateFrame('Button')
        local virtualItem = betterItem(0, 3, 100)
        local bankData = { bagid = 0, slotid = 3, itemInfo = { itemID = 100 } }
        local bankItem = { GetItemData = function() return bankData end }
        withoutItemData(function()
            state.handlers['item/Updated'](nil, virtualItem, virtual)
            state.handlers['item/Updated'](nil, bankItem, bank)
        end)
        virtualItem.isVirtual = true
        bankData.bagid, bankData.slotid = 6, 1
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
        ok(not marked(virtual), 'hueco virtual')
        ok(not marked(bank), 'banco')
    end)
end)

test('ArkInventory: la vista pasa a offline antes de llegar los datos -> sin marca', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); FAKE.bags['0:1'] = 100
    local frame = arkFrame(0, 1, 100)
    withoutItemData(function() state.fire(frame, BAG_LOCATION) end)
    state.offline[BAG_LOCATION] = true
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(not marked(frame), 'offline antes de que lleguen los datos')
end)

test('ArkInventory: LocationIsOffline nil (ubicacion invalida) o ARK_Data.loc_id distinto -> sin marca', function()
    local state = ark()
    install('ArkInventory')
    addItem(100); FAKE.bags['0:1'] = 100
    local frame = arkFrame(0, 1, 100)
    ArkInventory.API.LocationIsOffline = function() return nil end
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'nil = invalida, no online')
    ArkInventory.API.LocationIsOffline = function() return false end
    frame.ARK_Data.loc_id = VAULT_LOCATION
    state.fire(frame, BAG_LOCATION)
    ok(not marked(frame), 'el frame dice otra ubicacion')
    frame.ARK_Data.loc_id = BAG_LOCATION
    state.fire(frame, BAG_LOCATION)
    ok(marked(frame), 'control')
end)

test('ArkInventory: Location.Bag = 1 como en ArkInventoryConst.lua (la hermandad es la 4 y se rechaza)', function()
    local state = ark()
    install('ArkInventory')
    eq(ArkInventory.Const.Location.Bag, 1); eq(ArkInventory.Const.Location.Vault, 4)
    addItem(100); FAKE.bags['2:1'] = 100
    local vault = arkFrame(2, 1, 100)
    vault.ARK_Data.loc_id = VAULT_LOCATION
    state.fire(vault, VAULT_LOCATION)
    ok(not marked(vault), 'pestana de hermandad online no es una bolsa')
end)

test('EllesmereUIBags: callback sin info ni itemLink -> sin marca (no hay identidad)', function()
    local state = eui()
    install('EllesmereUIBags')
    addItem(100); FAKE.bags['0:1'] = 100
    local button = CreateFrame('Button')
    state.callback(button, { bag = 0, slot = 1 })
    ok(not marked(button), 'sin identidad no se pinta')
    state.callback(button, { bag = 0, slot = 1, info = {} })
    ok(not marked(button), 'info sin itemID')
    state.callback(button, { bag = 0, slot = 1, info = { itemID = 100 } })
    ok(marked(button), 'control')
end)

test('EllesmereUIBags: el refresco no marca si el slot cambio sin nuevo callback', function()
    local state = eui()
    install('EllesmereUIBags')
    addItem(100); addItem(101)
    FAKE.bags['0:1'] = 100
    local button = CreateFrame('Button')
    state.callback(button, { bag = 0, slot = 1, info = { itemID = 100 } })
    ok(marked(button))
    FAKE.bags['0:1'] = 101
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'el refresco limpia: el addon aun muestra 100')
end)

test('LiteBag: el slot pasa a un gris sin redibujar -> el refresco limpia, sin moneda', function()
    local state = liteBag()
    install('LiteBag')
    addItem(100, { quality = 1, classID = 2, subclassID = 0, spell = true }); addItem(101)
    FAKE.bags['0:1'] = 100
    local panel = CreateFrame('Frame', 'LiteBagBackpackPanel'); panel.id = 0
    local button = slotButton(nil, panel, 1, 100)
    state.callback(button)
    ok(not marked(button), 'el 100 es util')
    FAKE.bags['0:1'] = 101
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'el boton muestra 100: no se pinta la moneda del 101')
end)

test('LiteBag, tdBag2 y Baggins: sin itemID mostrado por el boton -> sin marca', function()
    local lite, td, bag = liteBag(), tdBag2Fake(), bagginsFake()
    FAKE.addons.LiteBag, FAKE.addons.tdBag2, FAKE.addons.Baggins = true, true, true
    ns.Bags.InstallAll()
    addItem(100); FAKE.bags['0:1'] = 100
    local panel = CreateFrame('Frame', 'LiteBagBackpackPanel'); panel.id = 0
    local liteButton = slotButton(nil, panel, 1, false)
    liteButton.itemID = nil
    lite.callback(liteButton)
    ok(not marked(liteButton), 'LiteBag')
    local tdb = tdButton(0, 1, meta(true, true)); tdb.itemID = nil
    td.plugin.update(tdb)
    ok(not marked(tdb), 'tdBag2')
    local signal = bag.signals.Baggins_ItemButtonUpdated
    local baggins = bagginsButton('n', 0, 1); baggins.itemID = nil
    signal.fn(signal.receiver, 'Baggins_ItemButtonUpdated', baggins)
    ok(not marked(baggins), 'Baggins')
    -- con identidad por itemLink, por info o por GetItemID si se marca
    local viaLink = slotButton(nil, panel, 1, false); viaLink.itemID = nil; viaLink.itemLink = FAKE.linkOf(100)
    lite.callback(viaLink); ok(marked(viaLink), 'itemLink')
    local viaInfo = slotButton(nil, panel, 1, false); viaInfo.itemID = nil; viaInfo.info = { itemID = 100 }
    lite.callback(viaInfo); ok(marked(viaInfo), 'info.itemID')
    local viaGetter = slotButton(nil, panel, 1, false); viaGetter.itemID = nil
    function viaGetter:GetItemID() return 100 end
    lite.callback(viaGetter); ok(marked(viaGetter), 'GetItemID')
    local conflict = slotButton(nil, panel, 1, false); conflict.itemID = 100; conflict.itemLink = FAKE.linkOf(101)
    lite.callback(conflict); ok(not marked(conflict), 'campos que no coinciden')
end)

test('AdiBags sin itemId no llama a Update', function()
    local state = adiBags()
    withLibs(state.libs, function()
        install('AdiBags')
        addItem(100); FAKE.bags['0:1'] = 100
        local button = CreateFrame('Button'); button.bag, button.slot = 0, 1
        spy(function(updates, clears)
            state.handlers.AdiBags_UpdateButton('AdiBags_UpdateButton', button)
            eq(#updates, 0); eq(#clears, 1)
        end)
    end)
end)

test('Common.NonCarried: GetParent, IsCached o GetName que fallan -> no probado como portado', function()
    local Common = ns.Bags.Common
    local function frameWith(fields)
        local panel = CreateFrame('Frame', 'PanelOk'); panel.id = 0
        for key, value in pairs(fields) do panel[key] = value end
        return slotButton(nil, panel, 1)
    end
    ok(Common.NonCarried(frameWith({})) == false, 'control')
    ok(Common.NonCarried(frameWith({ GetParent = function() error('roto') end })) == true, 'GetParent lanza')
    ok(Common.NonCarried(frameWith({ IsCached = function() error('roto') end })) == true, 'IsCached lanza')
    ok(Common.NonCarried(frameWith({ GetName = function() error('roto') end })) == true, 'GetName lanza')
    local bare = {}
    ok(Common.NonCarried(bare) == true, 'sin GetParent no se puede probar')
    local button = CreateFrame('Button')
    button.GetParent = function() error('roto') end
    ok(Common.NonCarried(button) == true, 'el propio boton falla')
end)

test('LiteBag: un padre cuyo GetParent falla deja el boton sin marca', function()
    local state = liteBag()
    install('LiteBag')
    addItem(100); FAKE.bags['0:1'] = 100
    local panel = CreateFrame('Frame', 'LiteBagBackpackPanelBroken'); panel.id = 0
    panel.GetParent = function() error('roto') end
    local button = slotButton(nil, panel, 1)
    state.callback(button)
    ok(not marked(button))
end)

test('los lectores de los seguimientos no capturan el boton', function()
    local state = betterBags()
    withLibs(state.libs, function()
        install('BetterBags')
        addItem(100); FAKE.bags['0:3'] = 100
        local decoration = CreateFrame('Button')
        state.handlers['item/Updated'](nil, betterItem(0, 3, 100), decoration)
    end)
    local euiState = eui()
    install('EllesmereUIBags')
    local button = CreateFrame('Button')
    euiState.callback(button, { bag = 0, slot = 1, info = { itemID = 100 } })
    local checked = 0
    for _, tracker in ipairs(ns.Bags.Common.trackers) do
        for key, reader in pairs(tracker.readers) do
            checked = checked + 1
            local index = 1
            while true do
                local name, value = debug.getupvalue(reader, index)
                if not name then break end
                ok(value ~= key, 'el lector captura el boton')
                index = index + 1
            end
            ok(tracker.contexts[key] ~= key, 'el contexto es el boton')
        end
    end
    ok(checked >= 2, 'se revisaron lectores')
end)
