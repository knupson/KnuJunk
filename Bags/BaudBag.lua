local _, ns = ...

-- BaudBag por su hook: hooksecurefunc(BaudBag, 'ItemSlot_Updated', ...); el boton llega como 6.o argumento.
-- Sin verificar en el juego ni contra su codigo (forma tomada de otros addons): solo cuenta la identidad que el boton exponga.
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
