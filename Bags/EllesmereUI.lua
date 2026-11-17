local _, ns = ...

-- EllesmereUIBags por su API publica: EUI_Bags.RegisterItemOverlayIcon(nombre, callback).
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: EllesmereUIBags no esta
-- instalado aqui; se detecta por forma). Carpeta del addon: 'EllesmereUIBags' (catalogo de
-- questjunksweeper y OptionalDeps de bagmarks):
--   * callback(boton, data): data.bag y data.slot son el slot fisico pintado, data.info.itemID y
--     data.itemLink el item. EUI recicla su tabla `data`: solo se copian escalares.
--   * No se toca nada del boton de EUI salvo la marca propia (Marks); nunca se escriben hooks.
--   * sin marca: data sin bag/slot, o el slot de bolsa 0-4 ya no tiene el item mostrado.
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1120-1135.
local OWNER = 'EllesmereUIBags'
local Adapter = {}
ns.EllesmereUIAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = false

local function callback(button, data)
    pcall(function()
        if type(button) ~= 'table' then return end
        if type(data) ~= 'table' then return tracker:Release(button) end
        local bag, slot = data.bag, data.slot
        local info = data.info
        local expected = type(info) == 'table' and info.itemID or Common.ItemIDOf(data.itemLink)
        if type(expected) ~= 'number' then expected = nil end
        tracker:Apply(button, function() return bag, slot, expected end)
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

ns.Bags.Register('EllesmereUIBags', { addon = 'EllesmereUIBags', install = Adapter.Install, refresh = Adapter.Refresh })
