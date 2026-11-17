local _, ns = ...

-- EllesmereUIBags por su API publica: EUI_Bags.RegisterItemOverlayIcon(nombre, callback).
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: EllesmereUIBags no esta
-- instalado aqui; se detecta por forma). Carpeta del addon: 'EllesmereUIBags' (catalogo de
-- questjunksweeper y OptionalDeps de bagmarks):
--   * callback(boton, data): data.bag y data.slot son el slot fisico pintado, data.info.itemID y
--     data.itemLink el item. EUI recicla su tabla `data`: solo se copian escalares.
--   * No se toca nada del boton de EUI salvo la marca propia (Marks); nunca se escriben hooks.
--   * identidad: data.info.itemID o, si no, el itemID de data.itemLink; sin ninguno no hay marca.
--   * sin marca: data sin bag/slot o sin identidad, o el slot de bolsa 0-4 ya no tiene el item
--     mostrado (tambien al retomar una marca pendiente o refrescar: revalidate).
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1120-1135.
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
