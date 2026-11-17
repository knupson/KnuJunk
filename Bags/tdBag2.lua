local _, ns = ...

-- tdBag2 por su sistema de plugins: tdBag2:RegisterPlugin({ key, text, type = 'Item', init, update }).
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: tdBag2 no esta instalado
-- aqui; se detecta por forma):
--   * init(boton) y update(boton) de un plugin de tipo 'Item': button.bag y button.slot.
--   * tdBag2 puede mostrar a otros personajes y bancos: button.meta debe ser un objeto con
--     meta:IsBag() y meta:IsSelf() verdaderos (bolsa del personaje actual); sin meta o con otra
--     respuesta, sin marca. Ademas Common.NonCarried descarta banco/hermandad/vault/cache.
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1157-1165 (y l.355-361 para meta).
local OWNER = 'tdBag2'
local Adapter = {}
ns.TdBag2Adapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local registered = false

local function reader(button)
    local meta = button.meta
    if type(meta) ~= 'table' or Common.Call(meta, 'IsBag') ~= true or Common.Call(meta, 'IsSelf') ~= true then
        return nil
    end
    if Common.NonCarried(button) then return nil end
    return button.bag, button.slot
end

local function onItem(button)
    pcall(function() tracker:Apply(button, reader) end)
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

ns.Bags.Register('tdBag2', { addon = 'tdBag2', install = Adapter.Install, refresh = Adapter.Refresh })
