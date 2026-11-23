local _, ns = ...

-- LiteBag por su gancho publico: LiteBag_RegisterHook('LiteBagItemButton_Update', callback(boton)); slot = GetID(), bolsa = GetBagID() o el GetID() del padre.
-- Sin verificar en el juego (no instalado aqui): identidad = Common.DisplayedID o, si no, el slot vivo capturado en el callback (Common.Capture).
local OWNER = 'LiteBag'
local Adapter = {}
ns.LiteBagAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = false

local function locate(button)
    if Common.NonCarried(button) then return nil end
    local slot = Common.Call(button, 'GetID')
    local bag = Common.Call(button, 'GetBagID')
    if type(bag) ~= 'number' then bag = Common.Call(Common.Call(button, 'GetParent'), 'GetID') end
    return bag, slot
end

local reader = Common.CapturingReader(locate)

local function revalidate(button) return tracker:Read(button) end

local function onUpdate(button)
    pcall(function()
        local bag, slot = locate(button)
        if type(bag) ~= 'number' or type(slot) ~= 'number' then return tracker:Release(button) end
        tracker:Apply(button, reader, Common.Capture(bag, slot))
    end)
end

-- true cuando el gancho esta registrado (idempotente).
function Adapter.Install()
    if registered then return true end
    local register = rawget(_G, 'LiteBag_RegisterHook')
    if type(register) ~= 'function' then return false end
    registered = pcall(register, 'LiteBagItemButton_Update', onUpdate)
    return registered
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered = false end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('LiteBag', { addon = 'LiteBag', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
