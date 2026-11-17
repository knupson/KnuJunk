local _, ns = ...

-- ArkInventory por su API publica: hooksecurefunc(ArkInventory.API, 'ItemFrameUpdated', ...).
-- Contrato VERIFICADO contra el codigo fuente de ArkInventory 3.12.17 (release de CurseForge, archivo
-- 9215808; leido en un directorio temporal, no se copia codigo). Citas (carpeta ArkInventory/Core/):
--   * ArkInventoryAPI.lua:113-125: ItemFrameUpdated(frame, loc_id, bag_id, slot_id), funcion vacia
--     "called after an item frame is updated", pensada para hooksecurefunc; la llaman
--     ArkInventory.lua:10642 y 10669 (tambien al cambiar solo el bloqueo del item).
--   * ArkInventoryAPI.lua:219-227: ItemFrameItemTableGet(frame) -> tabla del item mostrado (campo h =
--     enlace) o nil si no es un frame de ArkInventory.
--   * ArkInventoryAPI.lua:273-285: LocationIsOffline(loc_id) -> true offline, false online, NIL ubicacion
--     invalida (por eso solo `false` cuenta como online). ArkInventory.lua:4020-4052 la fija: offline
--     si la ventana muestra otro personaje, o banco/vault/correo/vacio sin estar abiertos.
--   * ArkInventoryConst.lua:1066-1090: Const.Location.Bag = 1 (Keyring 2, Bank 3, Vault 4, ... ReagentBag
--     21): la ventana de bolsas del personaje es la ubicacion 1. Vault usa blizzard_id 1000+tab
--     (ArkInventory.lua:2929) y las bolsas de banco/reagent ids fuera de 0-4: Marks los descarta.
--   * ArkInventory.lua:7581-7586: frame.ARK_Data = { loc_id, bag_id, blizzard_id, slot_id } con el
--     bag id de Blizzard y el slot (frame:GetID() = slot_id).
--   * Mecanismo y funciones de la referencia: magic-eraser Tint-Junk.lua l.397-420.
-- Sin marca: ubicacion distinta de Const.Location.Bag, ARK_Data.loc_id distinto de la ubicacion del
-- callback, LocationIsOffline distinto de false (offline, invalida o con error), item mostrado
-- ausente o distinto del que hay en el slot. SIN VERIFICAR EN EL JUEGO (solo contra el codigo).
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
    local location = type(ark.Const) == 'table' and type(ark.Const.Location) == 'table' and ark.Const.Location.Bag
    if type(location) ~= 'number' or locationId ~= location then return nil end
    local data = frame.ARK_Data
    if type(data) ~= 'table' or data.loc_id ~= locationId then return nil end
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
    revalidate = revalidate })
