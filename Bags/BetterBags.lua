local _, ns = ...

-- BetterBags (AceAddon 'BetterBags' -> modulo 'Events'), sin hooks propios sobre sus botones.
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: BetterBags no esta
-- instalado aqui; todo se detecta por forma y cada pieza ausente deja el boton sin marca):
--   * mensajes 'item/Updated' (item dibujado), 'item/NewButton' (boton nuevo) e 'item/Clearing'
--     (boton liberado) del modulo Events: callback(_, item, decoration). La marca va en la
--     decoracion (donde esta el icono); si no llega, en item.button.
--   * datos del slot: item:GetItemData() -> bagid, slotid, itemInfo.itemID (o item.currentData).
--   * sin marca: hueco libre/virtual/soltado/estatico (item.isFreeSlot, isVirtual, released, blank,
--     staticData), data.isItemEmpty, sin itemInfo.itemID (identidad del item mostrado), o si el slot
--     de bolsa 0-4 ya no tiene el item mostrado (tambien al retomar una marca pendiente: revalidate).
--     BetterBags no tiene vista de otros personajes; el banco usa bolsas fuera de 0-4, que Marks acepta
--     solo con el banco VIVO (ns.Bank) y si son del banco del personaje (bank = true en el registro).
-- Referencias leidas (competencia/): magic-eraser Tint-Junk.lua l.358-384, keep-or-toss-forever
-- BagMarks.lua l.225-238, questjunksweeper Bags.lua l.1051-1118.
local OWNER = 'BetterBags'
local Adapter = {}
ns.BetterBagsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = {}   -- [mensaje] = true
local items = setmetatable({}, { __mode = 'kv' })   -- [boton marcado] = item de BetterBags (ambos debiles)
local NOT_A_SLOT = { 'isFreeSlot', 'isVirtual', 'released', 'blank', 'staticData' }

local function eventsModule()
    local ace = Common.Library('AceAddon-3.0')
    if not ace or type(ace.GetAddon) ~= 'function' then return nil end
    local success, addon = pcall(ace.GetAddon, ace, 'BetterBags', true)
    if not success or type(addon) ~= 'table' or type(addon.GetModule) ~= 'function' then return nil end
    local ok, events = pcall(addon.GetModule, addon, 'Events', true)
    if ok and type(events) == 'table' and type(events.RegisterMessage) == 'function' then return events end
end

local function itemData(item)
    if type(item) ~= 'table' then return nil end
    for _, flag in ipairs(NOT_A_SLOT) do
        if item[flag] then return nil end
    end
    local data
    if type(item.GetItemData) == 'function' then
        local success, result = pcall(item.GetItemData, item)
        if success then data = result end
    else
        data = item.currentData
    end
    if type(data) ~= 'table' or data.isItemEmpty then return nil end
    return data
end

-- Lector sin capturas: el item de BetterBags se busca por el boton marcado.
local function reader(target)
    local data = itemData(items[target])
    if not data then return nil end
    local info = data.itemInfo
    if type(info) ~= 'table' or type(info.itemID) ~= 'number' then return nil end
    return data.bagid, data.slotid, info.itemID
end

local function revalidate(button) return tracker:Read(button) end

local function targetOf(item, decoration)
    if type(decoration) == 'table' then return decoration end
    if type(item) == 'table' and type(item.button) == 'table' then return item.button end
end

local function onUpdated(_, item, decoration)
    pcall(function()
        local target = targetOf(item, decoration)
        if target then
            items[target] = item
            tracker:Apply(target, reader)
        end
    end)
end

local function onClearing(_, item, decoration)
    pcall(function()
        local target = targetOf(item, decoration)
        if target then items[target] = nil end
        tracker:Release(target)
    end)
end

local HANDLERS = { ['item/Updated'] = onUpdated, ['item/NewButton'] = onUpdated, ['item/Clearing'] = onClearing }

-- true cuando 'item/Updated' e 'item/Clearing' estan registrados (el de boton nuevo es un extra).
-- Reintentable: registra solo lo que falta.
function Adapter.Install()
    local events = eventsModule()
    if not events then return false end
    for message, handler in pairs(HANDLERS) do
        if not registered[message] then
            registered[message] = pcall(events.RegisterMessage, events, message, handler)
        end
    end
    return registered['item/Updated'] == true and registered['item/Clearing'] == true
end

-- Repinta: recorre los botones que BetterBags ya tiene (modulo ItemFrame) y lo recordado.
function Adapter.Refresh()
    local ace = Common.Library('AceAddon-3.0')
    local addon = ace and Common.Call(ace, 'GetAddon', 'BetterBags', true)
    local frames = addon and Common.Call(addon, 'GetModule', 'ItemFrame', true)
    local buttons = type(frames) == 'table' and frames.buttonsBySlotkey
    if type(buttons) == 'table' then
        local count = 0
        for _, item in pairs(buttons) do
            count = count + 1
            if count > 2000 then break end
            if type(item) == 'table' then onUpdated(nil, item, item._decoration) end
        end
    end
    tracker:Refresh()
end

function Adapter.ResetState() registered, items = {}, setmetatable({}, { __mode = 'kv' }) end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('BetterBags', { addon = 'BetterBags', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate, bank = true })
