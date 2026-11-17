-- Ventana de botin: marcas en las filas de LootFrame (botones clasicos y lista moderna con filas recicladas).
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
    return base
end

-- Botin falso: FAKE.loot[slot] = itemID (sin entrada = slot de dinero, sin enlace).
local function installLoot()
    FAKE.loot = {}
    GetLootSlotLink = function(slot)
        local id = FAKE.loot[slot]
        return id and FAKE.linkOf(id) or nil
    end
end

local function visible(button) return button.KnuJunkMark ~= nil and button.KnuJunkMark:IsShown() == true end

-- Ventana clasica: LootFrame_Update y LootButton1..N con button.slot.
local function classicWindow(count)
    LootFrame = CreateFrame('Frame', 'LootFrame')
    LOOTFRAME_NUMBUTTONS = count
    LootFrame_Update = function() end
    local buttons = {}
    for index = 1, count do
        local button = CreateFrame('Button', 'LootButton' .. index, LootFrame)
        button.slot = index
        buttons[index] = button
    end
    return buttons
end

-- Lista moderna: LootFrame.ScrollBox con filas (row.Item es el icono, GetSlotIndex da el slot).
local function modernWindow(slots)
    LootFrame = CreateFrame('Frame', 'LootFrame')
    local rows = {}
    for index, slot in ipairs(slots) do
        local row = CreateFrame('Button', nil, LootFrame)
        row.slotIndex = slot
        row.Item = CreateFrame('Button', nil, row)
        function row:GetSlotIndex() return self.slotIndex end
        rows[index] = row
    end
    LootFrame.ScrollBox = { ForEachFrame = function(_, fn) for _, row in ipairs(rows) do fn(row) end end }
    return rows
end

local function withScrollUtil(fn)
    local callbacks = {}
    ScrollUtil = { AddInitializedFrameCallback = function(scrollBox, callback, owner, iterate)
        callbacks[#callbacks + 1] = { scrollBox = scrollBox, callback = callback, owner = owner, iterate = iterate }
    end }
    fn(callbacks)
end

local function open() FAKE.Fire('LOOT_OPENED') end

test('Loot: sin ninguna API de botin no se instala', function()
    ns.Bags.InstallAll()
    local installed = false
    for _, name in ipairs(ns.Bags.Installed()) do if name == 'Loot' then installed = true end end
    ok(not installed, 'nada que enganchar')
    ok(not ns.Loot.Hook(), 'Hook sin API devuelve false')
end)

test('Loot clasico: slot de oro (sin link) -> sin marca', function()
    installLoot()
    local buttons = classicWindow(4)
    FAKE.loot[2] = 100; addItem(100)
    open()
    ok(not visible(buttons[1]), 'slot de dinero: sin marca')
    ok(visible(buttons[2]), 'control: el slot con item si')
end)

test('Loot clasico: gris en botin -> coin y dueno Loot', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100, { quality = 0, price = 5 }); FAKE.loot[1] = 100
    open()
    ok(visible(buttons[1]))
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
    eq(buttons[1].KnuJunkOwner, 'Loot')
end)

test('Loot clasico: objetivo de mision activa -> quest', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(500, { name = 'Garra de lobo', quality = 0, price = 5 }); FAKE.loot[1] = 500
    FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } } }
    open()
    ok(visible(buttons[1]))
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
end)

test('Loot clasico: item de mision segun Questie -> quest', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(501, { name = 'Pieza rara', quality = 0, price = 5 }); FAKE.loot[501 - 500] = 501
    FAKE.InstallQuestie({ [77] = { objectives = { nil, nil, { { 501, 'Pieza rara' } } } } })
    ns.Questie.Uses(0)
    FAKE.Advance(5)
    open()
    ok(visible(buttons[1]))
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
end)

test('Loot clasico: fila reciclada a otro slot cambia la marca (LootFrame_Update)', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100, { quality = 0 }); addItem(500, { name = 'Garra de lobo', quality = 0 })
    FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } } }
    FAKE.loot[1] = 100; FAKE.loot[2] = 500
    ns.Bags.InstallAll()
    open()
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
    buttons[1].slot = 2                      -- Blizzard recicla el boton a otro slot
    LootFrame_Update()                       -- el hook sobre LootFrame_Update repinta
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
    buttons[1].slot = 3                      -- ahora un slot de dinero: sin marca
    LootFrame_Update()
    ok(not visible(buttons[1]), 'fila reciclada a dinero limpia la marca')
end)

test('Loot: show.loot = false -> sin marca', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); FAKE.loot[1] = 100
    ns.DB.show.loot = false
    open()
    ok(not visible(buttons[1]))
    ns.DB.show.loot = true
    open()
    ok(visible(buttons[1]), 'control: con show.loot = true marca')
end)

test('Loot: LOOT_CLOSED y LOOT_SLOT_CLEARED limpian', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); addItem(101); FAKE.loot[1] = 100; FAKE.loot[2] = 101
    open()
    ok(visible(buttons[1]) and visible(buttons[2]))
    FAKE.loot[1] = nil                       -- el jugador recogio el slot 1
    FAKE.Fire('LOOT_SLOT_CLEARED', 1)
    ok(not visible(buttons[1]), 'slot vaciado: sin marca')
    ok(visible(buttons[2]), 'el otro sigue')
    FAKE.Fire('LOOT_CLOSED')
    ok(not visible(buttons[2]), 'LOOT_CLOSED limpia')
    FAKE.Advance(1)
    ok(not visible(buttons[2]), 'y no reaparece')
end)

test('Loot: LOOT_SLOT_CHANGED repinta el slot', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); addItem(500, { name = 'Garra de lobo' })
    FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } } }
    FAKE.loot[1] = 100
    open()
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
    FAKE.loot[1] = 500
    FAKE.Fire('LOOT_SLOT_CHANGED', 1)
    eq(buttons[1].KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
end)

test('Loot: botones ocultos o ventana cerrada no se marcan', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); FAKE.loot[1] = 100
    buttons[1]:Hide()
    open()
    ok(not visible(buttons[1]), 'boton oculto')
    buttons[1]:Show(); LootFrame:Hide()
    open()
    ok(not visible(buttons[1]), 'LootFrame oculto')
end)

test('Loot: un error de GetLootSlotLink deja sin marca y no rompe', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); FAKE.loot[1] = 100
    open()
    ok(visible(buttons[1]))
    GetLootSlotLink = function() error('boom') end
    open()
    ok(not visible(buttons[1]), 'sin marca tras el error')
end)

test('Loot clasico: reintento por datos no cargados no marca una fila reciclada con otro item', function()
    installLoot()
    local buttons = classicWindow(4)
    FAKE.loot[1] = 300                       -- el cliente aun no conoce el item 300
    open()
    ok(not visible(buttons[1]), 'sin datos: sin marca')
    addItem(301, { quality = 0 }); FAKE.loot[2] = 301
    buttons[1].slot = 2                      -- la fila se recicla sin que pasemos por nuestro hook
    addItem(300, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 300, true)
    ok(not visible(buttons[1]), 'la fila ya muestra otro item: no recibe la marca del 300')
end)

test('Loot clasico: el reintento marca si la fila sigue mostrando el mismo item', function()
    installLoot()
    local buttons = classicWindow(4)
    FAKE.loot[1] = 300
    open()
    addItem(300, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 300, true)
    ok(visible(buttons[1]), 'control: mismo item, marca')
    eq(buttons[1].KnuJunkOwner, 'Loot')
end)

test('Loot: el reintento no marca si el botin se cerro', function()
    installLoot()
    local buttons = classicWindow(4)
    FAKE.loot[1] = 300
    open()
    LootFrame:Hide()
    addItem(300, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 300, true)
    ok(not visible(buttons[1]))
end)

test('Loot moderno: ScrollBox con filas recicladas; marca en row.Item', function()
    installLoot()
    withScrollUtil(function(callbacks)
        local rows = modernWindow({ 1, 2 })
        addItem(100); addItem(500, { name = 'Garra de lobo' })
        FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } } }
        FAKE.loot[1] = 100; FAKE.loot[2] = 500
        ns.Bags.InstallAll()
        eq(#callbacks, 1, 'engancha la lista una sola vez')
        eq(callbacks[1].scrollBox, LootFrame.ScrollBox)
        ok(callbacks[1].iterate, 'tambien las filas ya existentes')
        ns.Bags.InstallAll(); ns.Loot.Hook()
        eq(#callbacks, 1, 'idempotente')
        open()
        ok(visible(rows[1].Item) and rows[1].KnuJunkMark == nil, 'la marca va en el icono')
        eq(rows[1].Item.KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
        eq(rows[2].Item.KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
        -- la lista recicla la fila 1 a otro slot y llama al callback de inicializacion
        rows[1].slotIndex = 2
        callbacks[1].callback(callbacks[1].owner, rows[1], { slotIndex = 2 })
        eq(rows[1].Item.KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
        rows[1].slotIndex = 9                -- slot de dinero
        callbacks[1].callback(callbacks[1].owner, rows[1], { slotIndex = 9 })
        ok(not visible(rows[1].Item), 'fila reciclada a dinero: sin marca')
        FAKE.Fire('LOOT_CLOSED')
        ok(not visible(rows[2].Item), 'LOOT_CLOSED limpia la lista')
    end)
end)

test('Loot moderno: el slot sale de GetElementData si la fila no tiene GetSlotIndex', function()
    installLoot()
    withScrollUtil(function(callbacks)
        local rows = modernWindow({ 1 })
        rows[1].GetSlotIndex = nil
        rows[1].GetElementData = function() return { slotIndex = 1 } end
        addItem(100); FAKE.loot[1] = 100
        ns.Bags.InstallAll()
        open()
        ok(visible(rows[1].Item))
    end)
end)

test('Loot moderno: reintento por datos no cargados no marca una fila reciclada con otro item', function()
    installLoot()
    withScrollUtil(function()
        local rows = modernWindow({ 1 })
        FAKE.loot[1] = 300
        open()
        ok(not visible(rows[1].Item))
        addItem(301, { quality = 0 }); FAKE.loot[2] = 301
        rows[1].slotIndex = 2
        addItem(300, { quality = 0 })
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 300, true)
        ok(not visible(rows[1].Item), 'otra fila, otro item: sin marca')
    end)
end)

test('Loot moderno sin ScrollUtil: hook a Init del mixin de la fila', function()
    installLoot()
    LootFrameElementMixin = { Init = function() end }
    local rows = modernWindow({ 1 })
    addItem(100); FAKE.loot[1] = 100
    ns.Bags.InstallAll()
    local installed = false
    for _, name in ipairs(ns.Bags.Installed()) do if name == 'Loot' then installed = true end end
    ok(installed, 'instalado por el mixin')
    LootFrame:Hide(); LootFrame:Show()
    LootFrameElementMixin.Init(rows[1])
    ok(visible(rows[1].Item))
    FAKE.loot[1] = nil
    LootFrameElementMixin.Init(rows[1])
    ok(not visible(rows[1].Item))
end)

test('Loot: Bags.RefreshAll repinta la ventana abierta', function()
    installLoot()
    local buttons = classicWindow(4)
    addItem(100); FAKE.loot[1] = 100
    ns.Bags.InstallAll()
    FAKE.Advance(1)
    ok(visible(buttons[1]))
end)
