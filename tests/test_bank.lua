-- Banco vivo del personaje actual (Bank.lua) y su uso en Marks y en los adaptadores que lo soportan.
-- Los numeros del Enum son FALSOS (solo pruebas): el codigo nunca los supone, los lee del Enum.
local BANK_TAB = 6     -- Enum.BagIndex.CharacterBankTab_1 en estas pruebas
local BANK_TAB_9 = 14

local function forever()
    local index = { Backpack = 0, Bag_1 = 1, Bag_2 = 2, Bag_3 = 3, Bag_4 = 4, ReagentBag = 5, Keyring = -2,
        Characterbanktab = -4, AccountBankTab_1 = 15 }
    for tab = 1, 9 do index['CharacterBankTab_' .. tab] = BANK_TAB + tab - 1 end
    Enum = { BagIndex = index, PlayerInteractionType = { Banker = 8, GuildBanker = 10, MailInfo = 17,
        AccountBanker = 68, CharacterBanker = 69 } }
end

local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
end

-- Item gris (moneda) `id` en `bag`/`slot`.
local function junk(id, bag, slot)
    addItem(id)
    FAKE.bags[bag .. ':' .. slot] = id
    return FAKE.linkOf(id)
end

local function marked(button)
    local texture = button.KnuJunkMark
    return texture ~= nil and texture:IsShown() == true
end

local function openBank() FAKE.Fire('BANKFRAME_OPENED') end
local function closeBank() FAKE.Fire('BANKFRAME_CLOSED') end

-- ---------------------------------------------------------------------------
-- Bank.lua
-- ---------------------------------------------------------------------------

test('Bank: IsBankBag solo para las pestanas del banco del personaje', function()
    ok(not ns.Bank.IsBankBag(BANK_TAB), 'sin Enum: nada es banco')
    forever()
    ok(ns.Bank.IsBankBag(BANK_TAB) and ns.Bank.IsBankBag(BANK_TAB_9), 'pestanas 1 y 9')
    for _, bag in ipairs({ 0, 1, 4, 5, -1, -2, -4, 15, BANK_TAB_9 + 1 }) do
        ok(not ns.Bank.IsBankBag(bag), 'no es banco: ' .. bag)
    end
    ok(not ns.Bank.IsBankBag(nil) and not ns.Bank.IsBankBag('6'), 'argumentos raros')
end)

test('Bank: BANKFRAME_OPENED/CLOSED y la interaccion con el banquero', function()
    forever()
    ok(not ns.Bank.IsLive(), 'arranca cerrado')
    openBank(); ok(ns.Bank.IsLive(), 'BANKFRAME_OPENED')
    closeBank(); ok(not ns.Bank.IsLive(), 'BANKFRAME_CLOSED')
    FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', Enum.PlayerInteractionType.Banker)
    ok(ns.Bank.IsLive(), 'interaccion Banker')
    FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', Enum.PlayerInteractionType.MailInfo)
    ok(ns.Bank.IsLive(), 'cerrar otra interaccion no cierra el banco')
    FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', Enum.PlayerInteractionType.Banker)
    ok(not ns.Bank.IsLive(), 'fin de la interaccion Banker (Forever puede no mandar BANKFRAME_CLOSED)')
    FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', Enum.PlayerInteractionType.CharacterBanker)
    ok(ns.Bank.IsLive(), 'interaccion CharacterBanker')
    FAKE.Fire('PLAYER_ENTERING_WORLD')
    ok(not ns.Bank.IsLive(), 'pantalla de carga: cerrado')
    for _, kind in ipairs({ 'GuildBanker', 'AccountBanker', 'MailInfo' }) do
        FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', Enum.PlayerInteractionType[kind])
        ok(not ns.Bank.IsLive(), kind .. ' no abre el banco del personaje')
    end
    Enum = nil
    FAKE.Fire('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', 8)
    ok(not ns.Bank.IsLive(), 'sin Enum la interaccion no prueba nada')
end)

test('Bank: un callback que falla no frena a los demas', function()
    local seen = {}
    ns.Bank.OnChanged(function() error('roto') end)
    ns.Bank.OnChanged(function(live) seen[#seen + 1] = live end)
    openBank(); openBank(); closeBank()
    eq(#seen, 2, 'solo cambios reales'); eq(seen[1], true); eq(seen[2], false)
end)

-- ---------------------------------------------------------------------------
-- Marks
-- ---------------------------------------------------------------------------

test('Marks: banco vivo marca solo para duenos que soportan banco', function()
    forever()
    junk(100, BANK_TAB, 1)
    local button = CreateFrame('Button')
    ns.Marks.Update(button, BANK_TAB, 1, 'blizzard')
    ok(not marked(button), 'banco cerrado: sin marca')
    openBank()
    ns.Marks.Update(button, BANK_TAB, 1, 'blizzard')
    ok(marked(button), 'banco abierto: moneda')
    for _, owner in ipairs({ 'generic', 'GenericHook', 'AdiBags', 'LiteBag', nil }) do
        local other = CreateFrame('Button')
        ns.Marks.Update(other, BANK_TAB, 1, owner)
        ok(not marked(other), 'dueno sin soporte de banco: ' .. tostring(owner))
    end
    local reagent = CreateFrame('Button')
    junk(101, 5, 1)
    ns.Marks.Update(reagent, 5, 1, 'blizzard')
    ok(not marked(reagent), 'bolsa de reactivos: nunca')
    local account = CreateFrame('Button')
    junk(102, 15, 1)
    ns.Marks.Update(account, 15, 1, 'blizzard')
    ok(not marked(account), 'banco de cuenta: nunca')
end)

test('Marks: al cerrar el banco se borran sus marcas y no se ponen nuevas', function()
    forever()
    junk(100, BANK_TAB, 1); junk(101, 0, 1)
    openBank()
    local bank, bag = CreateFrame('Button'), CreateFrame('Button')
    ns.Marks.Update(bank, BANK_TAB, 1, 'blizzard')
    ns.Marks.Update(bag, 0, 1, 'blizzard')
    ok(marked(bank) and marked(bag))
    closeBank()
    ok(not marked(bank), 'cierre: la marca del banco se va sin redibujo')
    ok(marked(bag), 'la bolsa no se toca')
    ns.Marks.Update(bank, BANK_TAB, 1, 'blizzard')
    ok(not marked(bank), 'cerrado: un redibujo no vuelve a marcar')
end)

test('Marks: datos que llegan despues del cierre no marcan el banco', function()
    forever()
    FAKE.bags[BANK_TAB .. ':1'] = 100 -- sin datos aun
    openBank()
    local button = CreateFrame('Button')
    ns.Marks.Update(button, BANK_TAB, 1, 'blizzard')
    ok(not marked(button), 'esperando datos')
    closeBank()
    addItem(100)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(not marked(button), 'los datos llegaron con el banco cerrado: sin marca')
end)

test('Marks: lo diferido por combate no se marca si el banco cerro', function()
    forever()
    junk(100, BANK_TAB, 1)
    openBank()
    local button = CreateFrame('Button')
    function button:IsProtected() return true end
    FAKE.inCombat = true
    ns.Marks.Update(button, BANK_TAB, 1, 'blizzard')
    ok(not marked(button), 'diferido')
    closeBank()
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    ok(not marked(button), 'fin del combate con el banco cerrado: sin marca')
end)

test('Marks.Verdict: banco solo vivo', function()
    forever()
    junk(100, BANK_TAB, 1)
    eq(ns.Marks.Verdict(BANK_TAB, 1, 100), nil, 'cerrado')
    openBank()
    eq(ns.Marks.Verdict(BANK_TAB, 1, 100), 'coin', 'abierto')
    eq(ns.Marks.Verdict(BANK_TAB, 1, 999), nil, 'otro item')
    closeBank()
    eq(ns.Marks.Verdict(BANK_TAB, 1, 100), nil, 'cerrado otra vez')
end)

test('Common.NonCarried: el banco solo se admite vivo y nunca la hermandad ni lo cacheado', function()
    forever()
    local Common = ns.Bags.Common
    local bankFrame = CreateFrame('Frame', 'AlgoBankFrame', UIParent)
    local button = CreateFrame('Button', nil, bankFrame)
    ok(Common.NonCarried(button, true), 'banco cerrado: no portado')
    openBank()
    ok(not Common.NonCarried(button, true), 'banco vivo: admitido')
    ok(Common.NonCarried(button), 'sin pedirlo, el banco sigue rechazado')
    local flagged = CreateFrame('Frame', nil, UIParent); flagged.isBank = true
    ok(not Common.NonCarried(CreateFrame('Button', nil, flagged), true), 'bandera isBank: admitida viva')
    local guild = CreateFrame('Frame', 'AlgoGuildBankFrame', UIParent)
    ok(Common.NonCarried(CreateFrame('Button', nil, guild), true), 'hermandad: nunca')
    local guildFlag = CreateFrame('Frame', nil, UIParent); guildFlag.isGuildBank = true
    ok(Common.NonCarried(CreateFrame('Button', nil, guildFlag), true), 'bandera de hermandad: nunca')
    local cached = CreateFrame('Button', nil, bankFrame)
    function cached:IsCached() return true end
    ok(Common.NonCarried(cached, true), 'vista cacheada del banco: nunca')
end)

-- ---------------------------------------------------------------------------
-- Blizzard: panel del banco (BankPanelItemButtonMixin / CamelotBankPanelItemButtonMixin)
-- ---------------------------------------------------------------------------

-- Boton del panel con la forma que leen las referencias: GetBankTabID() y GetContainerSlotID().
local function panelButton(mixin, tab, slot)
    local button = CreateFrame('Button', nil, UIParent)
    for key, value in pairs(mixin) do button[key] = value end -- el pool copia el mixin al crear
    function button:GetBankTabID() return tab end
    function button:GetContainerSlotID() return slot end
    return button
end

for _, name in ipairs({ 'BankPanelItemButtonMixin', 'CamelotBankPanelItemButtonMixin' }) do
    test('Blizzard: ' .. name .. '.Refresh marca el banco vivo', function()
        forever()
        _G[name] = { Refresh = function() end }
        ns.Bags.InstallAll()
        junk(100, BANK_TAB, 3)
        local button = panelButton(_G[name], BANK_TAB, 3)
        openBank()
        button:Refresh()
        ok(marked(button), 'banco abierto: moneda')
        eq(button.KnuJunkOwner, 'blizzard')
        closeBank()
        ok(not marked(button), 'cierre: sin marca')
        button:Refresh()
        ok(not marked(button), 'redibujo con el banco cerrado: sin marca')
    end)
end

test('Blizzard: el panel del banco repinta al abrir y revalida lo pendiente', function()
    forever()
    BankPanelItemButtonMixin = { Refresh = function() end }
    ns.Bags.InstallAll()
    junk(100, BANK_TAB, 3)
    local button = panelButton(BankPanelItemButtonMixin, BANK_TAB, 3)
    local active = { [button] = true }
    BankPanel = CreateFrame('Frame', 'BankPanel', UIParent)
    function BankPanel:EnumerateValidItems() return pairs(active) end
    openBank(); FAKE.Advance(1)
    ok(marked(button), 'al abrir el banco se repinta sin esperar a Refresh')
    -- Pendiente de datos y el banco cierra: el revalidador lo rechaza.
    FAKE.items[100] = nil
    local waiting = panelButton(BankPanelItemButtonMixin, BANK_TAB, 3)
    waiting:Refresh()
    ok(not marked(waiting), 'esperando datos')
    closeBank()
    addItem(100)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 100, true)
    ok(not marked(waiting), 'datos con el banco cerrado: sin marca')
end)

test('Blizzard: bolsa del banco en un ContainerFrame vivo marca solo con el banco abierto', function()
    forever()
    local frame = CreateFrame('Frame', 'ContainerFrame7', UIParent)
    frame.id = BANK_TAB
    local button = CreateFrame('Button', 'ContainerFrame7Item1', frame); button.id = 1
    function frame:UpdateItems() end
    ns.Bags.InstallAll()
    junk(100, BANK_TAB, 1)
    frame:UpdateItems()
    ok(not marked(button), 'cerrado')
    openBank()
    frame:UpdateItems()
    ok(marked(button), 'abierto')
end)

-- ---------------------------------------------------------------------------
-- Baganator: vista del banco viva vs guardada
-- ---------------------------------------------------------------------------

local function bagState()
    local state = FAKE.InstallBaganator()
    ns.Bags.InstallAll()
    return state
end

-- Vista del banco de Baganator (ViewManagement/Initialize.lua l.226-227; BankView.lua l.144-156:
-- liveBankActive; BankViewCharacterTabsView.lua l.469-485: Character.isLive y lastCharacter).
local function bankView(active, tabLive, character)
    local view = CreateFrame('Frame', 'Baganator_SingleViewBankViewFramedark')
    view.liveBankActive = active
    view.Character = { isLive = tabLive, lastCharacter = character }
    view.currentTab = view.Character
    return view
end

local function widget(state, id)
    local entry = state.widgets[id]
    local texture = entry.onInit(CreateFrame('Button'))
    return function(details) return entry.onUpdate(texture, details) end
end

local function location(bag, slot) return { bagID = bag, slotIndex = slot } end

test('Baganator: widget en el banco vivo dibuja; cerrado o guardado no', function()
    forever()
    local state = bagState()
    junk(100, BANK_TAB, 1)
    local update = widget(state, 'knujunk_icon')
    local view = bankView(true, true)
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), false, 'banco cerrado')
    openBank()
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), true, 'banco vivo')
    eq(update({ itemID = 100 }), false, 'sin itemLocation (boton guardado)')
    view.Character.isLive = false
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), false, 'vista del banco no viva')
    view.Character.isLive, view.liveBankActive = true, false
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), false, 'Baganator no tiene el banco activo')
    view.liveBankActive = true
    Syndicator = { API = { GetCurrentCharacter = function() return 'Yo-Reino' end } }
    view.Character.lastCharacter = 'Otro-Reino'
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), false, 'banco de otro personaje')
    view.Character.lastCharacter = 'Yo-Reino'
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), true, 'control: el propio')
    view:Hide()
    eq(update({ itemID = 100, itemLocation = location(BANK_TAB, 1) }), false, 'sin vista del banco visible')
    Syndicator = nil
end)

test('Baganator: junk plugin en el banco exige la vista del banco viva', function()
    forever()
    local state = bagState()
    junk(100, BANK_TAB, 1)
    local callback = state.junk.knujunk.callback
    local view = bankView(true, true)
    ok(not callback(BANK_TAB, 1, 100), 'banco cerrado')
    openBank()
    eq(callback(BANK_TAB, 1, 100), true, 'banco vivo')
    view.Character.isLive = false
    ok(not callback(BANK_TAB, 1, 100), 'vista guardada del banco')
    closeBank()
    view.Character.isLive = true
    ok(not callback(BANK_TAB, 1, 100), 'cerrado otra vez')
end)

-- ---------------------------------------------------------------------------
-- Bagnon, ElvUI, ArkInventory, BetterBags, Inventorian
-- ---------------------------------------------------------------------------

local function bagnonBank(windowID, bag, slot, offline)
    local window = CreateFrame('Frame', 'BagnonBankWindow', UIParent)
    window.id, window.offline = windowID, offline or false
    -- frames/bank/bank.lua l.93-102: IsCached(bag) = no estar en el banco, o dueno offline.
    function window:IsCached(b) if not ns.Bank.IsLive() then return true end; if b then return self.offline end end
    local button = CreateFrame('Button', nil, CreateFrame('Frame', nil, window))
    button.frame, button.bag, button.id = window, bag, slot
    function button:GetBag() return self.bag end
    function button:IsCached() return self.frame:IsCached(self.bag) end
    return button
end

test('Bagnon: ventana del banco viva marca; cerrada, cacheada u hermandad no', function()
    forever()
    local class = {}
    function class.Update(button, info) button.info = info or {} end
    Bagnon = { Item = class }
    FAKE.addons.Bagnon = true
    ns.Bags.InstallAll()
    junk(100, BANK_TAB, 2)
    local info = { itemID = 100, hyperlink = FAKE.linkOf(100) }
    local button = bagnonBank('bank', BANK_TAB, 2)
    class.Update(button, info)
    ok(not marked(button), 'banco cerrado (vista cacheada)')
    openBank()
    class.Update(button, info)
    ok(marked(button), 'banco vivo')
    local offline = bagnonBank('bank', BANK_TAB, 2, true)
    class.Update(offline, info)
    ok(not marked(offline), 'banco de otro personaje')
    local guild = bagnonBank('guild', BANK_TAB, 2)
    class.Update(guild, info)
    ok(not marked(guild), 'hermandad')
    closeBank()
    ok(not marked(button), 'cierre: sin marca')
end)

test('ElvUI: B.BankFrame vivo marca; cerrado no', function()
    forever()
    local B = { Initialized = true }
    function B:UpdateSlot(frame, bagID, slotID)
        local slot = frame.Bags[bagID] and frame.Bags[bagID][slotID]
        if not slot then return end
        local info = C_Container.GetContainerItemInfo(bagID, slotID)
        slot.itemID, slot.itemLink = info and info.itemID, info and info.hyperlink
    end
    B.BagFrame = CreateFrame('Frame', 'ElvUI_ContainerFrame', UIParent); B.BagFrame.Bags = {}
    B.BankFrame = CreateFrame('Frame', 'ElvUI_BankContainerFrame', UIParent)
    B.BankFrame.isBank, B.BankFrame.Bags = true, {}
    ElvUI = { { Bags = B } }
    FAKE.addons.ElvUI = true
    ns.Bags.InstallAll()
    junk(100, BANK_TAB, 3)
    B.BankFrame.Bags[BANK_TAB] = CreateFrame('Frame', nil, B.BankFrame)
    local button = CreateFrame('Button', nil, B.BankFrame.Bags[BANK_TAB])
    button.bagFrame, button.BagID, button.SlotID, button.id = B.BankFrame, BANK_TAB, 3, 3
    B.BankFrame.Bags[BANK_TAB][3] = button
    B:UpdateSlot(B.BankFrame, BANK_TAB, 3)
    ok(not marked(button), 'banco cerrado')
    openBank()
    B:UpdateSlot(B.BankFrame, BANK_TAB, 3)
    ok(marked(button), 'banco vivo')
    closeBank()
    ok(not marked(button), 'cierre')
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'refresco con el banco cerrado')
end)

test('ArkInventory: ubicacion Bank viva marca; offline no', function()
    forever()
    local offline = { [3] = true }
    local fire
    ArkInventory = {
        Const = { Location = { Bag = 1, Keyring = 2, Bank = 3, Vault = 4 } },
        API = {
            ItemFrameUpdated = function() end,
            LocationIsOffline = function(location) return offline[location] == true end,
            ItemFrameItemTableGet = function(frame) return frame.item end,
        },
    }
    FAKE.addons.ArkInventory = true
    ns.Bags.InstallAll()
    junk(100, BANK_TAB, 4)
    local frame = CreateFrame('Button')
    frame.ARK_Data = { loc_id = 3, bag_id = 1, blizzard_id = BANK_TAB, slot_id = 4 }
    frame.item = { h = FAKE.linkOf(100) }
    fire = function() ArkInventory.API.ItemFrameUpdated(frame, 3, 1, 4) end
    openBank()
    fire()
    ok(not marked(frame), 'ArkInventory dice offline')
    offline[3] = false
    fire()
    ok(marked(frame), 'banco vivo y online')
    closeBank()
    ok(not marked(frame), 'cierre')
    fire()
    ok(not marked(frame), 'cerrado aunque ArkInventory diga online')
end)

test('BetterBags: bolsa del banco viva marca; cerrada no', function()
    forever()
    local handlers = {}
    local events = { RegisterMessage = function(_, message, fn) handlers[message] = fn end }
    local addon = { GetModule = function(_, name) if name == 'Events' then return events end end }
    local saved = rawget(_G, 'LibStub')
    LibStub = setmetatable({}, { __call = function(_, name)
        if name == 'AceAddon-3.0' then return { GetAddon = function() return addon end } end
    end })
    local success, err = pcall(function()
        FAKE.addons.BetterBags = true
        ns.Bags.InstallAll()
        junk(100, BANK_TAB, 1)
        local item = { GetItemData = function() return { bagid = BANK_TAB, slotid = 1, itemInfo = { itemID = 100 } } end }
        local decoration = CreateFrame('Button')
        handlers['item/Updated'](nil, item, decoration)
        ok(not marked(decoration), 'cerrado')
        openBank()
        handlers['item/Updated'](nil, item, decoration)
        ok(marked(decoration), 'vivo')
        closeBank()
        ok(not marked(decoration), 'cierre')
    end)
    LibStub = saved
    if not success then error(err, 0) end
end)

test('Inventorian: ventana del banco viva marca; cacheada o cerrada no', function()
    forever()
    FAKE.addons.Inventorian = true
    local bagFrame = CreateFrame('Frame', 'InventorianBagFrame', UIParent)
    bagFrame.shown = false
    local bankFrame = CreateFrame('Frame', 'InventorianBankFrame', UIParent)
    local holder = CreateFrame('Frame', nil, bankFrame); holder.id = BANK_TAB
    local button = CreateFrame('Button', 'InventorianItemButton1', holder)
    button.id, button.bag, button.itemLink = 2, BANK_TAB, junk(100, BANK_TAB, 2)
    -- Item.lua l.373-375 + Frame.lua l.706-708: IsCached = otro personaje o banco sin abrir.
    function button:IsCached() return not ns.Bank.IsLive() end
    ns.Bags.InstallAll(); FAKE.Advance(1)
    ok(not marked(button), 'banco cerrado')
    openBank(); FAKE.Advance(1)
    ok(marked(button), 'banco vivo: se recorre la ventana del banco')
    closeBank()
    ok(not marked(button), 'cierre')
    openBank(); FAKE.Advance(1)
    ok(marked(button), 'otra vez abierto')
    function button:IsCached() return true end -- vista de otro personaje
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    ok(not marked(button), 'cacheada: sin marca')
end)
