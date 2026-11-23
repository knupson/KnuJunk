local _, ns = ...

-- tdBag2 por su sistema de plugins: tdBag2:RegisterPlugin({ key, text, type = 'Item', init, update }); button.bag y button.slot.
-- Sin verificar en el juego (no instalado aqui): button.meta debe tener IsBag() e IsSelf() verdaderos (muestra otros personajes); identidad como LiteBag (DisplayedID o Common.Capture).
local OWNER = 'tdBag2'
local Adapter = {}
ns.TdBag2Adapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = false

local function locate(button)
    local meta = button.meta
    if type(meta) ~= 'table' or Common.Call(meta, 'IsBag') ~= true or Common.Call(meta, 'IsSelf') ~= true then
        return nil
    end
    if Common.NonCarried(button) then return nil end
    return button.bag, button.slot
end

local reader = Common.CapturingReader(locate)

local function revalidate(button) return tracker:Read(button) end

local function onItem(button)
    pcall(function()
        local bag, slot = locate(button)
        if type(bag) ~= 'number' or type(slot) ~= 'number' then return tracker:Release(button) end
        tracker:Apply(button, reader, Common.Capture(bag, slot))
    end)
end

-- true cuando el plugin esta registrado (idempotente).
function Adapter.Install()
    if registered then return true end
    local td = rawget(_G, 'tdBag2')
    if type(td) ~= 'table' or type(td.RegisterPlugin) ~= 'function' then return false end
    registered = pcall(td.RegisterPlugin, td, { key = 'KnuJunk', text = 'KnuJunk', type = 'Item', init = onItem, update = onItem })
    return registered
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered = false end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('tdBag2', { addon = 'tdBag2', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
