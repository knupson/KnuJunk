local _, ns = ...

-- LiteBag por su gancho publico: LiteBag_RegisterHook('LiteBagItemButton_Update', callback(boton)).
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: LiteBag no esta instalado
-- aqui; se detecta por forma):
--   * los botones de LiteBag son botones de contenedor con plantilla Blizzard: slot = button:GetID(),
--     bolsa = button:GetBagID() si existe o el GetID() de su padre (la "bolsa" de LiteBag).
--   * sin marca: boton que sea (o cuelgue de algo con nombre/banderas de) banco, hermandad, vault o
--     vista cacheada (Common.NonCarried); las bolsas fuera de 0-4 las descarta Marks.
--   * identidad: si el boton expone el item que muestra (Common.DisplayedID) manda; si no (SIN
--     VERIFICAR), el slot vivo leido DURANTE el callback de redibujado (Common.Capture), que es lo
--     que LiteBag acaba de dibujar; los refrescos posteriores solo remarcan si sigue igual.
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1152-1155 (y l.1007-1009 para el
-- slot por padre; peddler Peddler.lua l.452-463 para los nombres de botones de LiteBag).
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
