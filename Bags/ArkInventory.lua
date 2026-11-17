local _, ns = ...

-- ArkInventory por su API publica: hooksecurefunc(ArkInventory.API, 'ItemFrameUpdated', ...).
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: ArkInventory no esta
-- instalado aqui; se detecta por forma):
--   * ItemFrameUpdated(frame, locationId): funcion vacia que ArkInventory llama tras dibujar cada
--     boton, puesta para que otros addons la enganchen. frame.ARK_Data trae blizzard_id (bolsa) y
--     slot_id; API.ItemFrameItemTableGet(frame) el item mostrado (campo h = enlace).
--   * sin marca: API.LocationIsOffline(locationId) verdadero (otro personaje o banco recordado) o
--     si falla; ubicacion que no sea la de bolsas (ArkInventory.Const.Location.Bag, para no tomar
--     las pestanas de hermandad por bolsas 1-4; si la constante no existe, no se marca nada); item
--     mostrado distinto del que hay en el slot.
-- Referencias leidas (competencia/): magic-eraser Tint-Junk.lua l.397-420.
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

local function reader(frame, locationId)
    return function()
        local ark, api = root()
        if not api then return nil end
        local success, offline = pcall(api.LocationIsOffline, locationId)
        if not success or offline then return nil end
        local location = type(ark.Const) == 'table' and type(ark.Const.Location) == 'table' and ark.Const.Location.Bag
        if type(location) ~= 'number' or locationId ~= location then return nil end
        local data = frame.ARK_Data
        if type(data) ~= 'table' then return nil end
        local ok, item = pcall(api.ItemFrameItemTableGet, frame)
        local expected = ok and type(item) == 'table' and Common.ItemIDOf(item.h) or nil
        if not expected then return nil end
        return data.blizzard_id, data.slot_id, expected
    end
end

local function onUpdated(frame, locationId)
    pcall(function()
        if type(frame) == 'table' then tracker:Apply(frame, reader(frame, locationId)) end
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

ns.Bags.Register('ArkInventory', { addon = 'ArkInventory', install = Adapter.Install, refresh = Adapter.Refresh })
