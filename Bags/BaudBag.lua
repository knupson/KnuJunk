local _, ns = ...

-- BaudBag por su hook: hooksecurefunc(BaudBag, 'ItemSlot_Updated', ...).
-- SIN VERIFICAR EN EL JUEGO NI CONTRA SU CODIGO: BaudBag no esta instalado aqui ni hay copia de su
-- fuente; la forma sale de la competencia (questjunksweeper Bags.lua l.1166-1170: el hook recibe
-- el boton como 6.o argumento, es decir (BaudBag, a, b, c, d, boton), y bolsa = ID del padre, slot =
-- ID del boton; peddler Peddler.lua l.321-329: botones BaudBagSubBag<bolsa>Item<slot>).
--   * identidad: SOLO la que el boton exponga (Common.DisplayedID, via Common.ExposedReader). No se
--     captura el slot vivo: sin fuente no se puede probar que el hook corra despues de dibujar ni
--     que la vista sea la viva. Boton sin campo expuesto: sin marca hasta verificar en el juego.
--   * sin marca: argumento que no es un boton, banco/hermandad/cache (Common.NonCarried) o bolsas
--     fuera de 0-4 (Marks).
local OWNER = 'BaudBag'
local Adapter = {}
ns.BaudBagAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local hooked = false

local function locate(button)
    if type(button) ~= 'table' then return nil end
    local slot = Common.Call(button, 'GetID')
    local bag = Common.Call(button, 'GetBagID')
    if type(bag) ~= 'number' then bag = Common.Call(Common.Call(button, 'GetParent'), 'GetID') end
    if Common.NonCarried(button) then return nil end
    return bag, slot
end

local reader = Common.ExposedReader(locate)

local function revalidate(button) return tracker:Read(button) end

local function onUpdated(...)
    local button = select(6, ...)
    pcall(function()
        if type(button) ~= 'table' or type(button.GetID) ~= 'function' or type(button.GetParent) ~= 'function' then return end
        local bag, slot = locate(button)
        if type(bag) ~= 'number' or type(slot) ~= 'number' then return tracker:Release(button) end
        tracker:Apply(button, reader)
    end)
end

-- true cuando el hook esta puesto (idempotente).
function Adapter.Install()
    if hooked then return true end
    local baud = rawget(_G, 'BaudBag')
    if type(baud) ~= 'table' or type(baud.ItemSlot_Updated) ~= 'function' then return false end
    hooked = pcall(hooksecurefunc, baud, 'ItemSlot_Updated', onUpdated)
    return hooked
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() hooked = false end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('BaudBag', { addon = 'BaudBag', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
