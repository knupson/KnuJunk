-- Adaptadores por hook de actualizacion y por nombres de frames: Bagnon/Bagnonium, ElvUI, BaudBag,
-- Frames (Combuctor, OneBag3, Inventorian, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI,
-- RealUI_Inventory) y el generico. Los falsos siguen la FORMA de los fuentes reales:
--   Bagnon (BagBrother 12.1.11): core/classes/item.lua l.123-141 (Item:Update fija self.info),
--     containerItem.lua l.62-63 y l.132-134 (Update llama Super(Item):Update; IsCached = frame:IsCached),
--     parented.lua l.9-12 (button.frame = ventana), api/frames.lua l.8-13 (ids 'inventory','bank',
--     'guild','vault'), classes/frameBase.lua l.222-224 (IsCached = owner.offline).
--   ElvUI v16.01 (Game/Shared/Modules/Bags/Bags.lua): l.703-711 (B:UpdateSlot(frame, bagID, slotID)
--     fija slot.itemID/slot.itemLink), l.2461-2466 (frame.isBank, frame.Bags), l.2798-2800
--     (slot.bagFrame, slot.BagID, slot.SlotID), l.3864 (B.Initialized solo con bolsas activas) y
--     General/Initialize.lua l.78 (E.Bags).
--   Inventorian 12.1.5.1 (Item.lua): l.22 (InventorianItemButton%d), l.57-70 (reusa ContainerFrame%dItem%d),
--     l.83-97 (Set: bag, slot, SetID, SetBagID), l.130-133 (SetItem fija item e itemLink), IsCached.
--   BaudBag y los demas: la forma sale de la competencia (questjunksweeper Bags.lua l.1166-1170,
--     peddler Peddler.lua l.261-594), no de su codigo: SIN VERIFICAR en el juego.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
end

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

local function isInstalled(name)
    for _, installedName in ipairs(ns.Bags.Installed()) do
        if installedName == name then return true end
    end
    return false
end

local function install(folder)
    FAKE.addons[folder] = true
    ns.Bags.InstallAll()
end

local function marked(button)
    local texture = button.KnuJunkMark
    return texture ~= nil and texture:IsShown() == true
end

-- Item gris (moneda) de id `id` en la bolsa `bag`, slot `slot`.
local function junk(id, bag, slot)
    addItem(id)
    FAKE.bags[bag .. ':' .. slot] = id
    return FAKE.linkOf(id)
end

-- ---------------------------------------------------------------------------
-- Bagnon / Bagnonium
-- ---------------------------------------------------------------------------

-- Clase Item del addon `folder` con la forma real: Item.Update(button, info) fija button.info.
local function fakeBagnon(folder)
    local class = {}
    function class.Update(button, info) button.info = info or {} end
    _G[folder] = { Item = class }
    return class
end

-- Boton de Bagnon: button.frame es la ventana (id), GetBag() la bolsa, IsCached() la de la ventana.
local windowCount = 0
local function bagnonButton(windowID, bag, slot, offline)
    windowCount = windowCount + 1
    local window = CreateFrame('Frame', 'BagnonWindow' .. windowCount, UIParent)
    window.id = windowID
    window.offline = offline or false
    function window:IsCached() return self.offline end
    local group = CreateFrame('Frame', nil, window)
    local button = CreateFrame('Button', nil, group)
    button.frame, button.bag, button.id = window, bag, slot
    function button:GetBag() return self.bag end
    function button:IsCached() return self.frame:IsCached(self.bag) end
    return button
end

local function infoOf(id)
    return { itemID = id, hyperlink = FAKE.linkOf(id) }
end

for _, folder in ipairs({ 'Bagnon', 'Bagnonium' }) do
    test(folder .. ': hook instalado en Item.Update y marca la moneda', function()
        local class = fakeBagnon(folder)
        local original = class.Update
        junk(100, 0, 3)
        install(folder)
        ok(isInstalled(folder), 'instalado')
        ok(class.Update ~= original, 'Update enganchado')
        local button = bagnonButton('inventory', 0, 3)
        class.Update(button, infoOf(100))
        ok(marked(button), 'moneda en el item gris')
        eq(button.KnuJunkOwner, folder)
    end)
end

test('Bagnon y Bagnonium: cada uno se engancha a su propio global', function()
    local bagnon, bagnonium = fakeBagnon('Bagnon'), fakeBagnon('Bagnonium')
    local u1, u2 = bagnon.Update, bagnonium.Update
    install('Bagnon')
    ok(bagnon.Update ~= u1 and bagnonium.Update == u2, 'solo Bagnon cargado')
    ok(isInstalled('Bagnon') and not isInstalled('Bagnonium'))
    install('Bagnonium')
    ok(bagnonium.Update ~= u2 and isInstalled('Bagnonium'))
end)

test('Bagnon: vista cacheada (otro personaje) -> sin marca', function()
    local class = fakeBagnon('Bagnon')
    junk(100, 0, 3)
    install('Bagnon')
    local cached = bagnonButton('inventory', 0, 3, true)
    class.Update(cached, infoOf(100))
    ok(not marked(cached), 'ventana offline')
    local live = bagnonButton('inventory', 0, 3)
    live.IsCached = function() return true end
    class.Update(live, infoOf(100))
    ok(not marked(live), 'IsCached del propio boton')
    local control = bagnonButton('inventory', 0, 3)
    class.Update(control, infoOf(100))
    ok(marked(control), 'control: el mismo boton sin cache marca')
end)

test('Bagnon: banco, hermandad y vault -> sin marca (aunque la bolsa sea 0-4)', function()
    local class = fakeBagnon('Bagnon')
    junk(100, 1, 2)
    install('Bagnon')
    for _, id in ipairs({ 'bank', 'guild', 'vault', 'otra' }) do
        local button = bagnonButton(id, 1, 2)
        class.Update(button, infoOf(100))
        ok(not marked(button), 'ventana ' .. id)
    end
end)

test('Bagnon: la ventana no es la del inventario o no es una tabla -> sin marca', function()
    local class = fakeBagnon('Bagnon')
    junk(100, 0, 3)
    install('Bagnon')
    local button = bagnonButton('inventory', 0, 3)
    button.frame = nil
    class.Update(button, infoOf(100))
    ok(not marked(button), 'sin ventana')
    local second = bagnonButton('inventory', 0, 3)
    second.frame.id = nil
    class.Update(second, infoOf(100))
    ok(not marked(second), 'ventana sin id')
end)

test('Bagnon: info vieja (otro item que el del slot), vacia o contradictoria -> sin marca', function()
    local class = fakeBagnon('Bagnon')
    junk(100, 0, 3); addItem(101)
    install('Bagnon')
    local stale = bagnonButton('inventory', 0, 3)
    class.Update(stale, infoOf(101))
    ok(not marked(stale), 'Bagnon dibujo 101 y el slot tiene 100')
    local empty = bagnonButton('inventory', 0, 3)
    class.Update(empty, {})
    ok(not marked(empty), 'info vacia (Addon.None): sin captura del slot vivo')
    local clash = bagnonButton('inventory', 0, 3)
    class.Update(clash, { itemID = 100, hyperlink = FAKE.linkOf(101) })
    ok(not marked(clash), 'itemID y enlace distintos')
end)

test('Bagnon: Item.Update ausente o roto -> install false', function()
    FAKE.addons.Bagnon = true
    ok(ns.BagnonAdapters.Bagnon.Install() == false, 'sin global')
    Bagnon = {}
    ok(ns.BagnonAdapters.Bagnon.Install() == false, 'sin Item')
    Bagnon = { Item = {} }
    ok(ns.BagnonAdapters.Bagnon.Install() == false, 'sin Update')
    ns.Bags.InstallAll()
    ok(not isInstalled('Bagnon'))
end)

test('Bagnon: un refresco vuelve a leer lo que Bagnon muestra', function()
    local class = fakeBagnon('Bagnon')
    junk(100, 0, 3)
    install('Bagnon')
    local button = bagnonButton('inventory', 0, 3)
    class.Update(button, infoOf(100))
    ok(marked(button))
    FAKE.bags['0:3'] = nil
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'el slot se vacio y Bagnon aun no redibujo: sin marca')
    FAKE.bags['0:3'] = 100
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(marked(button), 'vuelve el mismo item que Bagnon sigue mostrando')
end)

test('Bagnon: item sin datos queda pendiente y se retoma por su revalidacion', function()
    local class = fakeBagnon('Bagnon')
    FAKE.bags['0:3'] = 100
    install('Bagnon')
    local button = bagnonButton('inventory', 0, 3)
    class.Update(button, infoOf(100))
    ok(not marked(button), 'GetItemInfo aun vacio')
    addItem(100)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(marked(button), 'llegaron los datos y Bagnon sigue mostrando ese item')
end)

-- ---------------------------------------------------------------------------
-- ElvUI
-- ---------------------------------------------------------------------------

-- ElvUI[1].Bags con la forma real: UpdateSlot(B, frame, bagID, slotID) fija slot.itemID/itemLink.
local function fakeElvUI(initialized)
    local B = { Initialized = initialized }
    function B:UpdateSlot(frame, bagID, slotID)
        local slot = frame.Bags[bagID] and frame.Bags[bagID][slotID]
        if not slot then return end
        local info = C_Container.GetContainerItemInfo(bagID, slotID)
        slot.itemID, slot.itemLink = info and info.itemID, info and info.hyperlink
    end
    local function frame(name, isBank)
        local f = CreateFrame('Frame', name, UIParent)
        f.isBank, f.Bags = isBank, {}
        return f
    end
    B.BagFrame, B.BankFrame = frame('ElvUI_ContainerFrame', false), frame('ElvUI_BankContainerFrame', true)
    ElvUI = { { Bags = B } }
    return B
end

local function elvSlot(frame, bag, slot)
    frame.Bags[bag] = frame.Bags[bag] or CreateFrame('Frame', nil, frame)
    local button = CreateFrame('Button', nil, frame.Bags[bag])
    button.bagFrame, button.BagID, button.SlotID, button.id = frame, bag, slot, slot
    frame.Bags[bag][slot] = button
    return button
end

test('ElvUI sin Initialized -> no engancha', function()
    local B = fakeElvUI(nil)
    local original = B.UpdateSlot
    FAKE.addons.ElvUI = true
    ok(ns.ElvUIAdapter.Install() == false, 'bolsas de ElvUI apagadas')
    ns.Bags.InstallAll()
    ok(not isInstalled('ElvUI'))
    ok(B.UpdateSlot == original, 'UpdateSlot intacta')
    ElvUI = nil
    ok(ns.ElvUIAdapter.Install() == false, 'ElvUI sin motor')
    ElvUI = { {} }
    ok(ns.ElvUIAdapter.Install() == false, 'sin modulo Bags')
    ElvUI = { { Bags = { Initialized = true } } }
    ok(ns.ElvUIAdapter.Install() == false, 'sin UpdateSlot')
end)

test('ElvUI: UpdateSlot marca el slot de la bolsa del personaje', function()
    local B = fakeElvUI(true)
    local original = B.UpdateSlot
    junk(100, 0, 3)
    install('ElvUI')
    ok(isInstalled('ElvUI'), 'instalado')
    ok(B.UpdateSlot ~= original, 'enganchado')
    local button = elvSlot(B.BagFrame, 0, 3)
    B:UpdateSlot(B.BagFrame, 0, 3)
    ok(marked(button), 'moneda')
    eq(button.KnuJunkOwner, 'ElvUI')
end)

test('ElvUI: banco, hueco, item viejo o slot que no coincide -> sin marca', function()
    local B = fakeElvUI(true)
    junk(100, 0, 3); addItem(101)
    install('ElvUI')
    local bank = elvSlot(B.BankFrame, 0, 3)
    B:UpdateSlot(B.BankFrame, 0, 3)
    ok(not marked(bank), 'ventana del banco (isBank)')
    local otherFrame = CreateFrame('Frame', 'ElvUI_OtraVentana', UIParent)
    otherFrame.isBank, otherFrame.Bags = false, {}
    local stray = elvSlot(otherFrame, 0, 3)
    B:UpdateSlot(otherFrame, 0, 3)
    ok(not marked(stray), 'frame que no es el B.BagFrame')
    local button = elvSlot(B.BagFrame, 0, 3)
    B:UpdateSlot(B.BagFrame, 0, 3)
    ok(marked(button), 'control')
    button.itemID, button.itemLink = 101, FAKE.linkOf(101)
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'ElvUI muestra 101 y el slot tiene 100')
    local empty = elvSlot(B.BagFrame, 0, 4)
    B:UpdateSlot(B.BagFrame, 0, 4)
    ok(not marked(empty), 'hueco')
    junk(103, 1, 1)
    local wrong = elvSlot(B.BagFrame, 1, 1)
    wrong.BagID = 2
    spy(function(updates)
        B:UpdateSlot(B.BagFrame, 1, 1)
        eq(#updates, 0, 'el boton dice otra bolsa que los argumentos')
    end)
end)

-- ---------------------------------------------------------------------------
-- BaudBag
-- ---------------------------------------------------------------------------

-- BaudBag:ItemSlot_Updated(bagSet, containerId, subContainerId, slotId, button): el boton va 6.o con
-- self (questjunksweeper Bags.lua l.1166-1170); la bolsa es el ID del padre y el slot el del boton.
-- Identidad: solo la que el boton exponga (sin fuente de BaudBag no se captura el slot vivo).
local function baudButton(bag, slot, parentName, fields)
    local parent = CreateFrame('Frame', parentName or ('BaudBagSubBag' .. bag), UIParent)
    parent.id = bag
    local button = CreateFrame('Button', 'BaudBagSubBag' .. bag .. 'Item' .. slot, parent)
    button.id = slot
    for key, value in pairs(fields or {}) do button[key] = value end
    return button
end

test('BaudBag: hook de ItemSlot_Updated; la identidad es la que el boton expone', function()
    local baud = { ItemSlot_Updated = function() end }
    BaudBag = baud
    local original = baud.ItemSlot_Updated
    junk(100, 0, 3)
    install('BaudBag')
    ok(isInstalled('BaudBag') and baud.ItemSlot_Updated ~= original, 'hook instalado')
    local button = baudButton(0, 3, nil, { itemID = 100 })
    baud:ItemSlot_Updated(1, 0, 0, 3, button)
    ok(marked(button), 'marca')
    eq(button.KnuJunkOwner, 'BaudBag')
    FAKE.bags['0:3'] = nil
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'el slot se vacio y el boton sigue diciendo 100: sin marca')
end)

test('BaudBag sin identidad expuesta -> sin marca (no se captura el slot vivo)', function()
    BaudBag = { ItemSlot_Updated = function() end }
    junk(100, 0, 3)
    install('BaudBag')
    local button = baudButton(0, 3)
    spy(function(updates)
        BaudBag:ItemSlot_Updated(1, 0, 0, 3, button)
        eq(#updates, 0, 'nunca Update')
    end)
    ok(not marked(button))
end)

test('BaudBag: banco, bolsa fuera de 0-4, argumentos raros y campos contradictorios -> sin marca', function()
    BaudBag = { ItemSlot_Updated = function() end }
    junk(100, 0, 3); junk(101, 6, 1); junk(102, 1, 1); addItem(103)
    install('BaudBag')
    local bank = baudButton(6, 1, nil, { itemID = 101 })
    BaudBag:ItemSlot_Updated(1, 6, 0, 1, bank)
    ok(not marked(bank), 'bolsa 6')
    local named = baudButton(1, 1, 'BaudBagBankContainer', { itemID = 102 })
    BaudBag:ItemSlot_Updated(1, 1, 0, 1, named)
    ok(not marked(named), 'marco con nombre de banco')
    BaudBag:ItemSlot_Updated(1, 0, 0, 3)
    BaudBag:ItemSlot_Updated(1, 0, 0, 3, 'no soy un boton')
    BaudBag:ItemSlot_Updated(1, 0, 0, 3, {})
    local clash = baudButton(0, 3, nil, { itemID = 103 })
    BaudBag:ItemSlot_Updated(1, 0, 0, 3, clash)
    ok(not marked(clash), 'el boton dice 103 y el slot tiene 100')
    local ok1 = baudButton(0, 3, nil, { itemID = 100 })
    BaudBag:ItemSlot_Updated(1, 0, 0, 3, ok1)
    ok(marked(ok1), 'control')
end)

test('BaudBag sin ItemSlot_Updated -> install false', function()
    FAKE.addons.BaudBag = true
    ok(ns.BaudBagAdapter.Install() == false, 'sin global')
    BaudBag = {}
    ok(ns.BaudBagAdapter.Install() == false, 'sin la funcion')
end)

-- ---------------------------------------------------------------------------
-- Frames por nombres
-- ---------------------------------------------------------------------------

-- Boton con nombre global `name`, bolsa = ID del padre, slot = su ID, y campos expuestos opcionales.
local function namedButton(name, bag, slot, fields)
    local parent = CreateFrame('Frame', nil, UIParent)
    parent.id = bag
    local button = CreateFrame('Button', name, parent)
    button.id = slot
    for key, value in pairs(fields or {}) do button[key] = value end
    return button
end

local function walk()
    ns.Bags.InstallAll()
    ns.Bags.RefreshAll(); FAKE.Advance(1)
end

-- Las entradas sin contenedor conocido no recorren: para probar sus patrones se les asigna un
-- contenedor VISIBLE de prueba (simula un nombre verificado en el juego) y se restaura al terminar.
-- Inventorian ya trae el suyo (InventorianBagFrame, Inventorian.lua l.81), que tambien se crea.
local function withContainers(fn)
    local saved = {}
    for _, entry in ipairs(ns.Frames.Entries) do saved[entry] = entry.frame or false end
    local success, err = pcall(function()
        for _, entry in ipairs(ns.Frames.Entries) do
            entry.frame = entry.frame or ('KnuContenedor_' .. entry.name)
            CreateFrame('Frame', entry.frame, UIParent)
        end
        fn()
    end)
    for entry, frame in pairs(saved) do entry.frame = frame or nil end
    if not success then error(err, 0) end
end

local function ftest(name, fn) test(name, function() withContainers(fn) end) end

ftest('Frames: Combuctor encuentra ContainerFrame1Item1', function()
    local link = junk(100, 0, 3)
    local button = namedButton('ContainerFrame1Item1', 0, 3, { itemLink = link })
    FAKE.addons.Combuctor = true
    spy(function(updates)
        walk()
        eq(#updates, 1)
        eq(updates[1].button, button); eq(updates[1].bag, 0); eq(updates[1].slot, 3)
        eq(updates[1].owner, 'Combuctor')
    end)
    ok(isInstalled('Combuctor'))
end)

ftest('Frames: pinta de verdad la moneda del boton encontrado', function()
    junk(100, 0, 3)
    local button = namedButton('ContainerFrame1Item1', 0, 3, { itemID = 100 })
    FAKE.addons.Combuctor = true
    walk()
    ok(marked(button))
    eq(button.KnuJunkOwner, 'Combuctor')
end)

ftest('Frames: sin campo de identidad -> sin marca (no se captura sin callback)', function()
    junk(100, 0, 3)
    local button = namedButton('ContainerFrame1Item1', 0, 3)
    FAKE.addons.Combuctor = true
    spy(function(updates)
        walk()
        eq(#updates, 0, 'nunca Update')
    end)
    ok(not marked(button))
end)

ftest('Frames: identidad que no coincide con el slot, cacheada o de banco -> sin marca', function()
    junk(100, 0, 3); addItem(101); junk(102, 1, 1)
    local stale = namedButton('ContainerFrame1Item1', 0, 3, { itemID = 101 })
    local cached = namedButton('ContainerFrame2Item1', 1, 1, { itemID = 102, isCached = true })
    FAKE.addons.Combuctor = true
    walk()
    ok(not marked(stale), 'el boton muestra otro item')
    ok(not marked(cached), 'vista cacheada')
    local bankSlot = namedButton('ContainerFrame3Item1', 6, 1, { itemID = 100 })
    FAKE.bags['6:1'] = 100
    walk()
    ok(not marked(bankSlot), 'bolsa 6')
end)

ftest('Frames: boton oculto o con otro dueno no se toca', function()
    junk(100, 0, 3); junk(101, 0, 4)
    local hidden = namedButton('ContainerFrame1Item1', 0, 3, { itemID = 100 })
    hidden.shown = false
    local owned = namedButton('ContainerFrame1Item2', 0, 4, { itemID = 101 })
    owned.KnuJunkOwner = 'blizzard'
    FAKE.addons.Combuctor = true
    spy(function(updates, clears)
        walk()
        eq(#updates, 0)
        eq(#clears, 0, 'tampoco se limpia lo ajeno')
    end)
end)

ftest('Frames: recorrido acotado, se detiene en el primer indice que falta', function()
    FAKE.addons.cargBags_Nivaya = true
    junk(100, 0, 1); junk(101, 0, 2); junk(102, 0, 4)
    local a = namedButton('NivayaSlot1', 0, 1, { itemID = 100 })
    local b = namedButton('NivayaSlot2', 0, 2, { itemID = 101 })
    local gap = namedButton('NivayaSlot4', 0, 4, { itemID = 102 })
    walk()
    ok(marked(a) and marked(b), 'los contiguos')
    ok(not marked(gap), 'tras un hueco en la numeracion no se sigue buscando')
    -- sin boton alguno el recorrido no falla
    FAKE.addons.m_Bags = true
    walk()
end)

ftest('Frames: nombres de cada addon (Peddler.lua l.261-594, Inventorian Item.lua l.22 y l.57-70)', function()
    local cases = {
        { 'Combuctor', 'ContainerFrame1Item1' },
        { 'OneBag3', 'OneBagFrameBag0Item1' },
        { 'Inventorian', 'ContainerFrame1Item1' },
        { 'Inventorian', 'InventorianItemButton1' },
        { 'cargBags_Nivaya', 'NivayaSlot1' },
        { 'm_Bags', 'm_BagsSlot1' },
        { 'DerpyStuffing', 'StuffingBag0_1' },
        { 'famBags', 'famBagsButton_0_1' },
        { 'LUI', 'LUIBags_Item0_1' },
        { 'RealUI_Inventory', 'RealUIInventory_Slot1' },
    }
    for _, case in ipairs(cases) do
        FAKE.Reset()
        for _, entry in ipairs(ns.Frames.Entries) do CreateFrame('Frame', entry.frame, UIParent) end
        junk(100, 0, 3)
        local fields = case[1] == 'Inventorian' and { itemLink = FAKE.linkOf(100), bag = 0, slot = 3 } or { itemID = 100 }
        local button = namedButton(case[2], 0, 3, fields)
        FAKE.addons[case[1]] = true
        walk()
        ok(isInstalled(case[1]), case[1] .. ' instalado')
        ok(marked(button), case[1] .. ' encuentra ' .. case[2])
        eq(button.KnuJunkOwner, case[1])
    end
end)

ftest('Frames: sin su addon cargado no se busca nada', function()
    junk(100, 0, 3)
    local button = namedButton('ContainerFrame1Item1', 0, 3, { itemID = 100 })
    walk()
    ok(not marked(button))
    for _, name in ipairs({ 'Combuctor', 'OneBag3', 'Inventorian', 'cargBags_Nivaya', 'm_Bags', 'DerpyStuffing',
        'famBags', 'LUI', 'RealUI_Inventory' }) do
        ok(not isInstalled(name), name)
    end
end)

ftest('Frames: Inventorian usa solo itemLink (itemID viejo ignorado), bag/slot propios y su cache', function()
    FAKE.addons.Inventorian = true
    local link = junk(100, 0, 3); addItem(101)
    -- itemID viejo (Item.lua l.~: self.itemID nunca se limpia) no cuenta: manda itemLink
    local button = namedButton('InventorianItemButton1', 0, 3, { itemLink = link, itemID = 101, bag = 0, slot = 3 })
    walk()
    ok(marked(button), 'itemLink manda')
    local empty = namedButton('InventorianItemButton2', 0, 4, { itemID = 100, bag = 0, slot = 4 })
    FAKE.bags['0:4'] = 100
    walk()
    ok(not marked(empty), 'sin itemLink el itemID viejo no basta')
    -- vista cacheada de otro personaje: IsCached() del boton
    local cachedButton = namedButton('InventorianItemButton3', 0, 5, { itemLink = link, bag = 0, slot = 5 })
    cachedButton.IsCached = function() return true end
    FAKE.bags['0:5'] = 100
    walk()
    ok(not marked(cachedButton), 'cacheado')
    -- bag/slot propios que contradicen al padre
    local liar = namedButton('InventorianItemButton4', 0, 6, { itemLink = link, bag = 1, slot = 6 })
    FAKE.bags['0:6'] = 100
    walk()
    ok(not marked(liar), 'button.bag distinto del ID del padre')
end)

ftest('Frames: Inventorian con la ventana de bolsas oculta no se recorre (0 sondeos)', function()
    FAKE.addons.Inventorian = true
    local link = junk(100, 0, 3)
    local button = namedButton('InventorianItemButton1', 0, 3, { itemLink = link, bag = 0, slot = 3 })
    InventorianBagFrame.shown = false
    local before = ns.Frames.probes
    spy(function(updates) walk(); eq(#updates, 0, 'ventana oculta') end)
    eq(ns.Frames.probes, before, 'ni un sondeo con la bolsa cerrada')
    ok(not marked(button))
    InventorianBagFrame.shown = true
    walk()
    ok(marked(button), 'ventana visible')
    ok(ns.Frames.probes > before)
end)

test('Frames: entradas sin contenedor conocido no recorren (0 sondeos), aunque el addon y el boton esten', function()
    junk(100, 0, 3)
    local button = namedButton('ContainerFrame1Item1', 0, 3, { itemID = 100 })
    FAKE.addons.Combuctor = true
    local before = ns.Frames.probes
    walk()
    eq(ns.Frames.probes, before, 'sin sondeos')
    ok(not marked(button), 'sin marca hasta verificar el contenedor en el juego')
    for _, entry in ipairs(ns.Frames.Entries) do
        ok((entry.name == 'Inventorian') == (entry.frame ~= nil), entry.name .. ': solo Inventorian declara contenedor')
    end
end)

test('Frames: Inventorian toma el boton que Generic ya habia marcado y lo reciclado con itemID viejo se lee por itemLink', function()
    FAKE.addons.Inventorian = true
    CreateFrame('Frame', 'InventorianBagFrame', UIParent)
    SetItemButtonQuality = function() end
    local link100 = junk(100, 0, 3)
    local link101 = FAKE.linkOf(101); addItem(101)
    local live = CreateFrame('Frame', nil, UIParent)
    ns.Bags.DeclareLiveContainer(live)   -- contenedor que Generic acepta
    local parent = CreateFrame('Frame', nil, live); parent.id = 0
    local button = CreateFrame('Button', 'InventorianItemButton1', parent)
    button.id, button.bag, button.slot, button.itemLink, button.itemID = 3, 0, 3, link100, 100
    function button:GetBagID() return self.bag end
    ns.Bags.InstallAll()                                   -- instala Generic e Inventorian
    SetItemButtonQuality(button, 0, link100)               -- 1. hook global durante el redibujado
    eq(button.KnuJunkOwner, 'GenericHook'); ok(marked(button))
    walk()                                                 -- 2. barrido dedicado
    eq(button.KnuJunkOwner, 'Inventorian', 'el dedicado tomo el boton')
    ok(marked(button))
    -- 3. reciclado: link y slot pasan a 101 y queda el itemID=100 residual
    FAKE.bags['0:3'] = 101
    button.itemLink = link101
    SetItemButtonQuality(button, 0, link101)
    walk()
    ok(marked(button), 'el lector dedicado ignora el itemID viejo y marca el 101')
    eq(button.KnuJunkOwner, 'Inventorian')
    -- Generic ya no lo sigue: ni lo limpia ni lo repinta
    spy(function(updates, clears)
        SetItemButtonQuality(button, 0, link101)
        eq(#updates, 0); eq(#clears, 0)
    end)
    -- otro dueno dedicado sigue sin poder pisarlo desde Frames
    button.KnuJunkOwner = 'Bagnon'
    spy(function(updates) walk(); eq(#updates, 0, 'dueno dedicado ajeno') end)
end)

ftest('Frames: un refresco repinta y quita la marca si el slot cambio', function()
    junk(100, 0, 1)
    local button = namedButton('StuffingBag0_1', 0, 1, { itemID = 100 })
    FAKE.addons.DerpyStuffing = true
    walk()
    ok(marked(button))
    FAKE.bags['0:1'] = nil
    walk()
    ok(not marked(button), 'slot vacio')
end)

-- ---------------------------------------------------------------------------
-- Generico (adaptador 'GenericHook'; el dueno 'generic' es el valor por defecto de Marks)
-- ---------------------------------------------------------------------------

local GENERIC = 'GenericHook'

-- Contenedor declarado como ventana viva (lo que hace el adaptador de Blizzard con ContainerFrameN).
local function liveContainer()
    local container = CreateFrame('Frame', nil, UIParent)
    ns.Bags.DeclareLiveContainer(container)
    return container
end

-- Boton de bolsa de plantilla Blizzard: GetBagID() y GetID(), colgado de un contenedor vivo declarado
-- (o del `parent` que se pase).
local function genericButton(bag, slot, fields, parent)
    local button = CreateFrame('Button', nil, parent or liveContainer())
    button.id, button.bag = slot, bag
    function button:GetBagID() return self.bag end
    for key, value in pairs(fields or {}) do button[key] = value end
    return button
end

local function withQuality()
    SetItemButtonQuality = function() end
end

test('Generic: se instala siempre (sin addon) y engancha SetItemButtonQuality', function()
    withQuality()
    local original = SetItemButtonQuality
    ns.Bags.InstallAll()
    ok(isInstalled(GENERIC), 'instalado sin addon de bolsas')
    ok(SetItemButtonQuality ~= original, 'global enganchada')
end)

test('Generic: engancha tambien el metodo de ItemButtonMixin y de ContainerFrameItemButtonMixin si existen', function()
    withQuality()
    ItemButtonMixin = { SetItemButtonQuality = function() end }
    ContainerFrameItemButtonMixin = { SetItemButtonQuality = function() end }
    local a, b = ItemButtonMixin.SetItemButtonQuality, ContainerFrameItemButtonMixin.SetItemButtonQuality
    ns.Bags.InstallAll()
    ok(ItemButtonMixin.SetItemButtonQuality ~= a, 'ItemButtonMixin')
    ok(ContainerFrameItemButtonMixin.SetItemButtonQuality ~= b, 'ContainerFrameItemButtonMixin')
    local button = genericButton(0, 3)
    junk(100, 0, 3)
    ItemButtonMixin.SetItemButtonQuality(button, 0, FAKE.linkOf(100))
    ok(marked(button), 'el hook del metodo marca igual')
end)

test('Generic: sin ninguna API para enganchar -> install false', function()
    FAKE.Remove('SetItemButtonQuality')
    ns.Bags.InstallAll()
    ok(not isInstalled(GENERIC))
end)

test('Generic: marca con GetBagID/GetID validos y el item que el addon dice dibujar', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 2, 5)
    local button = genericButton(2, 5)
    SetItemButtonQuality(button, 0, link)
    ok(marked(button), 'moneda')
    eq(button.KnuJunkOwner, GENERIC)
    local byID = genericButton(2, 5)
    SetItemButtonQuality(byID, 0, 100)
    ok(marked(byID), 'tambien con itemID')
end)

test('Generic: contenedor desconocido (cache, hermandad, otro personaje) con IDs coincidentes -> sin marca', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3)
    spy(function(updates)
        for _, fields in ipairs({
            { isLive = false, lastCharacter = 'Otro' },   -- el caso de la revision: nombres neutros
            { owner = 'Otro-Reino' },
            { tab = 2 },
            {},
        }) do
            local view = CreateFrame('Frame', 'VistaDesconocida', UIParent)
            for key, value in pairs(fields) do view[key] = value end
            local button = genericButton(0, 3, nil, view)
            SetItemButtonQuality(button, 0, link)
        end
        -- tambien una vista que cuelga de otra desconocida
        local outer = CreateFrame('Frame', nil, UIParent)
        local inner = CreateFrame('Frame', nil, outer)
        SetItemButtonQuality(genericButton(0, 3, nil, inner), 0, link)
        eq(#updates, 0, 'ninguna marca: la ascendencia no llega a un contenedor declarado')
    end)
    local control = genericButton(0, 3)
    SetItemButtonQuality(control, 0, link)
    ok(marked(control), 'control: el mismo boton bajo un contenedor declarado marca')
    local nested = CreateFrame('Frame', nil, liveContainer())
    local deep = genericButton(0, 3, nil, CreateFrame('Frame', nil, nested))
    SetItemButtonQuality(deep, 0, link)
    ok(marked(deep), 'el contenedor declarado puede ser un ancestro lejano')
end)

test('Generic: el adaptador de Blizzard declara ContainerFrameN y ContainerFrameCombinedBags como vivos', function()
    withQuality()
    local numbered = CreateFrame('Frame', 'ContainerFrame1', UIParent)
    numbered.UpdateItems = function() end
    ContainerFrameCombinedBags = CreateFrame('Frame', nil, UIParent)
    ContainerFrameCombinedBags.UpdateItems = function() end
    ns.Bags.InstallAll()
    local link = junk(100, 0, 3)
    local a = genericButton(0, 3, nil, numbered)
    SetItemButtonQuality(a, 0, link)
    ok(marked(a), 'ContainerFrame1')
    local b = genericButton(0, 3, nil, ContainerFrameCombinedBags)
    SetItemButtonQuality(b, 0, link)
    ok(marked(b), 'ContainerFrameCombinedBags')
    ContainerFrameCombinedBags = nil
end)

test('Generic no pisa un boton con dueno', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3)
    local button = genericButton(0, 3)
    button.KnuJunkOwner = 'Bagnon'
    spy(function(updates, clears)
        SetItemButtonQuality(button, 0, link)
        eq(#updates, 0, 'no dibuja sobre el boton de otro adaptador')
        eq(#clears, 0, 'ni lo limpia')
    end)
    eq(button.KnuJunkOwner, 'Bagnon')
    for _, owner in ipairs({ GENERIC, 'generic' }) do
        local own = genericButton(0, 3)
        own.KnuJunkOwner = owner
        spy(function(updates) SetItemButtonQuality(own, 0, link); eq(#updates, 1, 'el dueno ' .. owner .. ' si') end)
    end
end)

test('Generic sin identidad -> sin marca', function()
    withQuality(); ns.Bags.InstallAll()
    junk(100, 0, 3)
    local button = genericButton(0, 3)
    spy(function(updates)
        SetItemButtonQuality(button, 0, nil)
        SetItemButtonQuality(button, 0, 'no es un enlace')
        eq(#updates, 0, 'el slot vivo no prueba lo que se dibuja')
    end)
    ok(not marked(button))
end)

test('Generic deja los botones de Baganator (tabla BGR) a su adaptador oficial', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3)
    local button = genericButton(0, 3, { BGR = { itemID = 100, itemLink = link } })
    spy(function(updates, clears)
        SetItemButtonQuality(button, 0, link)
        eq(#updates, 0); eq(#clears, 0)
    end)
end)

test('Generic: sin GetBagID/GetID validos, bolsa fuera de 0-4 o cache -> sin marca', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3); junk(101, 6, 1)
    spy(function(updates)
        local noBag = CreateFrame('Button', nil, liveContainer()); noBag.id = 3
        SetItemButtonQuality(noBag, 0, link)
        local noSlot = genericButton(0, nil)
        SetItemButtonQuality(noSlot, 0, link)
        local zero = genericButton(0, 0)
        SetItemButtonQuality(zero, 0, link)
        local bankBag = genericButton(6, 1)
        SetItemButtonQuality(bankBag, 0, FAKE.linkOf(101))
        local cached = genericButton(0, 3, { isCached = true })
        SetItemButtonQuality(cached, 0, link)
        local bankFrame = CreateFrame('Frame', 'ElvUI_BankContainerFrame', liveContainer())
        SetItemButtonQuality(genericButton(0, 3, nil, bankFrame), 0, link)
        SetItemButtonQuality(nil, 0, link)
        SetItemButtonQuality('x', 0, link)
        eq(#updates, 0)
    end)
end)

test('Generic: lo que el boton expone contradice al enlace -> sin marca; si coincide, marca', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3); addItem(101)
    local clash = genericButton(0, 3, { itemID = 101 })
    SetItemButtonQuality(clash, 0, link)
    ok(not marked(clash), 'campo 101 vs enlace 100')
    -- el boton expone 101 (que SI esta en el slot) pero el addon dice que dibuja 100: se contradicen
    FAKE.bags['0:3'] = 101
    local twisted = genericButton(0, 3, { itemID = 101 })
    SetItemButtonQuality(twisted, 0, link)
    ok(not marked(twisted), 'campo y enlace distintos aunque el campo coincida con el slot')
    FAKE.bags['0:3'] = 100
    local agree = genericButton(0, 3, { itemID = 100 })
    SetItemButtonQuality(agree, 0, link)
    ok(marked(agree), 'coinciden')
    -- sin enlace en la llamada, el campo expuesto alcanza
    local exposed = genericButton(0, 3, { info = { itemID = 100 } })
    SetItemButtonQuality(exposed, 0, nil)
    ok(marked(exposed), 'identidad expuesta')
end)

test('Generic: el slot que cambia se desmarca en el refresco y un boton que paso a otro dueno no se retoca', function()
    withQuality(); ns.Bags.InstallAll()
    local link = junk(100, 0, 3)
    local button = genericButton(0, 3)
    SetItemButtonQuality(button, 0, link)
    ok(marked(button))
    FAKE.bags['0:3'] = nil
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'slot vacio')
    FAKE.bags['0:3'] = 100
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(marked(button), 'vuelve el item que se dibujo')
    button.KnuJunkOwner = 'Baganator'
    spy(function(updates, clears)
        ns.Bags.RefreshAll(); FAKE.Advance(1)
        eq(#updates, 0, 'no repinta sobre otro dueno')
        eq(#clears, 0, 'ni limpia')
    end)
end)

test('Generic: item sin datos queda pendiente y se retoma por su revalidacion', function()
    withQuality(); ns.Bags.InstallAll()
    FAKE.bags['0:3'] = 100
    local button = genericButton(0, 3)
    SetItemButtonQuality(button, 0, FAKE.linkOf(100))
    ok(not marked(button))
    addItem(100)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(marked(button))
    eq(button.KnuJunkOwner, GENERIC)
end)

test('Generic: una espera de un boton administrado no se retoma si el boton ya muestra otra bolsa', function()
    withQuality(); ns.Bags.InstallAll()
    FAKE.bags['0:3'] = 100
    local button = genericButton(0, 3)
    SetItemButtonQuality(button, 0, FAKE.linkOf(100))
    addItem(100)
    button.bag = 1                       -- el addon reciclo el boton a otra bolsa sin avisar
    FAKE.bags['1:3'] = 100
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(not marked(button), 'revalidacion: el contexto era la bolsa 0')
end)

test('Marks: llamada SIN dueno (dueno por defecto generic) se reanuda por la regla del slot vivo aunque Generic exista', function()
    withQuality(); ns.Bags.InstallAll()
    FAKE.bags['0:1'] = 200
    local button = CreateFrame('Button', nil, UIParent)
    ns.Marks.Update(button, 0, 1)
    eq(button.KnuJunkOwner, 'generic')
    ok(not marked(button), 'sin datos')
    addItem(200)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(marked(button), 'sin revalidador propio: basta que el slot siga con ese item')
    ok(ns.Bags.Revalidator('generic') == nil, 'ningun adaptador se registra con el dueno por defecto')
end)

-- ---------------------------------------------------------------------------
-- Registro
-- ---------------------------------------------------------------------------

test('registro: ninguno de los nuevos se instala sin su addon, salvo el generico', function()
    withQuality()
    ns.Bags.InstallAll()
    for _, name in ipairs({ 'Bagnon', 'Bagnonium', 'ElvUI', 'BaudBag', 'Combuctor', 'OneBag3', 'Inventorian',
        'cargBags_Nivaya', 'm_Bags', 'DerpyStuffing', 'famBags', 'LUI', 'RealUI_Inventory' }) do
        ok(not isInstalled(name), name .. ' no se instala sin su addon')
    end
    ok(isInstalled('GenericHook'))
end)

-- Item 7 de la ola final: Inventorian. Abrir la ventana pide un refresco agrupado (HookScript
-- OnShow), y un boton del pool (Item.lua l.73-97: Free/Set) que pasa al banco o a una vista
-- cacheada pierde la marca sin esperar otro evento.
local function inventorianButton(index, bag, slot, link)
    local parent = CreateFrame('Frame', nil, InventorianBagFrame); parent.id = bag
    local button = CreateFrame('Button', 'InventorianItemButton' .. index, parent)
    button.id, button.bag, button.slot, button.itemLink = slot, bag, slot, link
    -- Imitacion minima del mixin de Inventorian (no es su codigo): Free/Set/Update en el boton.
    function button:Update() if self:IsVisible() then self.itemLink = FAKE.linkOf(FAKE.bags[self.bag .. ':' .. self.id]) end end
    function button:Free() self:Hide(); self.parent = nil; self.id = 0 end
    function button:Set(container, newBag, newSlot)
        local holder = CreateFrame('Frame', nil, container); holder.id = newBag
        self.bag, self.parent, self.id = newBag, holder, newSlot
        if self:IsVisible() then self:Update() else self:Show() end
    end
    button.scripts.OnShow = function(self) if self.parent then self:Update() end end
    return button
end

test('Inventorian: abrir la ventana cerrada marca sin otros eventos', function()
    FAKE.addons.Inventorian = true
    local frame = CreateFrame('Frame', 'InventorianBagFrame', UIParent)
    frame.shown = false
    local button = inventorianButton(1, 0, 3, junk(100, 0, 3))
    ns.Bags.InstallAll(); FAKE.Advance(1)
    ok(not marked(button), 'cerrada: sin marca')
    frame:Show()
    FAKE.Advance(1)
    ok(marked(button), 'al abrir: moneda sin BAG_UPDATE_DELAYED ni RefreshAll a mano')
end)

test('Inventorian: ventana creada despues de instalar tambien se engancha', function()
    FAKE.addons.Inventorian = true
    ns.Bags.InstallAll(); FAKE.Advance(1)
    local frame = CreateFrame('Frame', 'InventorianBagFrame', UIParent)
    frame.shown = false
    local button = inventorianButton(1, 0, 3, junk(100, 0, 3))
    FAKE.Advance(5) -- reintentos de enganche
    frame:Show()
    FAKE.Advance(1)
    ok(marked(button), 'moneda al abrir la ventana creada tarde')
end)

test('Inventorian: boton del pool que pasa al banco o a una vista cacheada pierde la marca', function()
    FAKE.addons.Inventorian = true
    CreateFrame('Frame', 'InventorianBagFrame', UIParent)
    local button = inventorianButton(1, 0, 3, junk(100, 0, 3))
    ns.Bags.InstallAll(); FAKE.Advance(1)
    ok(marked(button), 'marcado en la bolsa')
    local bank = CreateFrame('Frame', 'InventorianBankFrame', UIParent)
    junk(100, -1, 2)
    button:Free()
    button:Set(bank, -1, 2)
    ok(not marked(button), 'en el banco: sin moneda, sin refresco')
    -- De vuelta a la bolsa y luego a una vista cacheada de otro personaje.
    button:Free(); button:Set(InventorianBagFrame, 0, 3)
    FAKE.Advance(1); ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(marked(button), 'de nuevo en la bolsa')
    button.IsCached = function() return true end
    button:Free(); button:Set(InventorianBagFrame, 0, 3)
    ok(not marked(button), 'vista cacheada: sin moneda')
end)
