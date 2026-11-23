local _, ns = ...

-- EllesmereUIBags por su API publica: EUI_Bags.RegisterItemOverlayIcon(nombre, callback(boton, data)); EUI recicla `data`, asi que solo se copian escalares.
-- Sin verificar en el juego (no instalado aqui): identidad = data.info.itemID o el de data.itemLink; sin bag/slot o sin identidad, sin marca.
local OWNER = 'EllesmereUIBags'
local Adapter = {}
ns.EllesmereUIAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = false

-- Lector sin capturas: el contexto es una tabla propia de escalares copiados del callback.
local function reader(_, context)
    return context.bag, context.slot, context.id
end

local function revalidate(button) return tracker:Read(button) end

local function callback(button, data)
    pcall(function()
        if type(button) ~= 'table' then return end
        if type(data) ~= 'table' then return tracker:Release(button) end
        local info = data.info
        local shown = type(info) == 'table' and info.itemID or Common.ItemIDOf(data.itemLink)
        if type(shown) ~= 'number' then shown = nil end
        tracker:Apply(button, reader, { bag = data.bag, slot = data.slot, id = shown })
    end)
end

-- true cuando el callback esta registrado (idempotente).
function Adapter.Install()
    if registered then return true end
    local eui = rawget(_G, 'EUI_Bags')
    if type(eui) ~= 'table' or type(eui.RegisterItemOverlayIcon) ~= 'function' then return false end
    registered = pcall(eui.RegisterItemOverlayIcon, 'KnuJunk', callback)
    return registered
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered = false end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('EllesmereUIBags', { addon = 'EllesmereUIBags', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
