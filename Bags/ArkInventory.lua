local _, ns = ...

-- ArkInventory por su API publica: hooksecurefunc(ArkInventory.API, 'ItemFrameUpdated', ...). Contrato leido en el codigo de ArkInventory 3.12.17 (CurseForge, archivo 9215808); no se copia codigo.
-- Solo cuenta la ubicacion Bag (o Bank con el banco vivo) con LocationIsOffline == false (nil es ubicacion invalida). Sin verificar en el juego.
local OWNER = 'ArkInventory'
local Adapter = {}
ns.ArkInventoryAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local hooked = false

local function root()
    local ark = rawget(_G, 'ArkInventory')
    if type(ark) == 'table' and type(ark.API) == 'table' then return ark, ark.API end
end

-- Lector sin capturas: el contexto es la ubicacion (numero) del ultimo callback.
local function reader(frame, locationId)
    local ark, api = root()
    if not api or type(locationId) ~= 'number' then return nil end
    local success, offline = pcall(api.LocationIsOffline, locationId)
    if not success or offline ~= false then return nil end
    local locations = type(ark.Const) == 'table' and type(ark.Const.Location) == 'table' and ark.Const.Location
    if not locations then return nil end
    local isBag = type(locations.Bag) == 'number' and locationId == locations.Bag
    local isBank = type(locations.Bank) == 'number' and locationId == locations.Bank and ns.Bank.IsLive()
    if not isBag and not isBank then return nil end
    local data = frame.ARK_Data
    if type(data) ~= 'table' or data.loc_id ~= locationId then return nil end
    if isBank and not ns.Bank.IsBankBag(data.blizzard_id) then return nil end
    local ok, item = pcall(api.ItemFrameItemTableGet, frame)
    local shown = ok and type(item) == 'table' and Common.ItemIDOf(item.h) or nil
    if not shown then return nil end
    return data.blizzard_id, data.slot_id, shown
end

local function revalidate(button) return tracker:Read(button) end

local function onUpdated(frame, locationId)
    pcall(function()
        if type(frame) == 'table' then tracker:Apply(frame, reader, locationId) end
    end)
end

-- true cuando el hook esta puesto (idempotente: no se engancha dos veces).
function Adapter.Install()
    if hooked then return true end
    local _, api = root()
    if not api or type(api.ItemFrameUpdated) ~= 'function' or type(api.LocationIsOffline) ~= 'function'
        or type(api.ItemFrameItemTableGet) ~= 'function' then
        return false
    end
    hooked = pcall(hooksecurefunc, api, 'ItemFrameUpdated', onUpdated)
    return hooked
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() hooked = false end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('ArkInventory', { addon = 'ArkInventory', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate, bank = true })
