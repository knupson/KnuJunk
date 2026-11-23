local _, ns = ...

-- Baggins por sus senales: Baggins:RegisterSignal(senal, callback, receptor). Contrato leido en Baggins Forever 5.9.9: 'Baggins_ItemButtonUpdated' se dispara sincrono y RegisterSignal falla sin receptor.
-- Baggins no publica el item en el boton: se captura el slot vivo dentro del callback (Common.Capture). Sin verificar en el juego (solo contra el codigo).
local OWNER = 'Baggins'
local Adapter = {}
ns.BagginsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local receiver = {}
local registered = {}

local function locate(button)
    if Common.NonCarried(button) then return nil end
    return Common.Call(Common.Call(button, 'GetParent'), 'GetID'), Common.Call(button, 'GetID')
end

local reader = Common.CapturingReader(locate)

local function revalidate(button) return tracker:Read(button) end

local function root()
    local baggins = rawget(_G, 'Baggins')
    if type(baggins) == 'table' then return baggins end
end

-- Firma real: (receptor, bagframe, boton, bag, slot).
local function onButtonUpdated(_, _, button, bag, slot)
    pcall(function()
        if type(button) ~= 'table' or type(button.GetID) ~= 'function' then return end
        local buttonBag, buttonSlot = locate(button)
        if type(buttonBag) ~= 'number' or type(buttonSlot) ~= 'number'
            or (bag ~= nil and bag ~= buttonBag) or (slot ~= nil and slot ~= buttonSlot) then
            return tracker:Release(button)
        end
        tracker:Apply(button, reader, Common.Capture(buttonBag, buttonSlot))
    end)
end

local function onBagOpened() pcall(tracker.Refresh, tracker) end

-- true cuando 'Baggins_ItemButtonUpdated' esta registrada ('Baggins_BagOpened' es un extra).
-- Reintentable: registra solo lo que falta.
function Adapter.Install()
    local baggins = root()
    if not baggins or type(baggins.RegisterSignal) ~= 'function' then return false end
    if not registered.updated then
        registered.updated = pcall(baggins.RegisterSignal, baggins, 'Baggins_ItemButtonUpdated', onButtonUpdated, receiver)
    end
    if not registered.opened then
        registered.opened = pcall(baggins.RegisterSignal, baggins, 'Baggins_BagOpened', onBagOpened, receiver)
    end
    return registered.updated == true
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered = {} end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('Baggins', { addon = 'Baggins', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
