local _, ns = ...

-- Adaptador generico para cualquier bolsa que dibuje con funciones de Blizzard: hook de SetItemButtonQuality(boton, calidad, itemIDOEnlace, ...) y de ItemButtonMixin y ContainerFrameItemButtonMixin si existen.
-- Ultima red, de fallo seguro: solo marca bajo un contenedor declarado vivo (ns.Bags.DeclareLiveContainer), con GetBagID()/GetID() validos e identidad coherente, y no pisa botones de otro adaptador. Sin verificar en el juego.
local Adapter = {}
ns.GenericAdapter = Adapter

local Common = ns.Bags.Common
local OWNER = Common.GENERIC_OWNER
local tracker = Common.NewTracker(OWNER)
local hookedGlobal = false
local hookedMixins = {}
local MIXINS = { 'ItemButtonMixin', 'ContainerFrameItemButtonMixin' }

-- Dueno de otro adaptador dedicado ('generic', el valor por defecto de Marks, no cuenta como ajeno).
local function foreign(button)
    return not Common.MayTakeOver(button, OWNER)
end

local function locate(button)
    local bag = Common.Call(button, 'GetBagID')
    local slot = Common.Call(button, 'GetID')
    if type(bag) ~= 'number' or type(slot) ~= 'number' or bag < 0 or bag > 4 or slot < 1 then return nil end
    if Common.NonCarried(button) then return nil end
    if not ns.Bags.InLiveContainer(button) then return nil end
    return bag, slot
end

-- El contexto recuerda el item que el addon dijo dibujar; Common.DisplayedID manda sobre el.
local reader = Common.CapturingReader(locate)

local function revalidate(button)
    if type(button) ~= 'table' or foreign(button) then return nil end
    return tracker:Read(button)
end

local function onQuality(button, _, itemOrLink)
    if type(button) ~= 'table' or type(button.GetBagID) ~= 'function' or button.BGR ~= nil then return end
    pcall(function()
        if foreign(button) then return end
        local bag, slot = locate(button)
        if not bag then return tracker:Release(button) end
        local told = Common.ItemIDOf(itemOrLink)
        local shown, contradictory = Common.DisplayedID(button)
        if contradictory or (told ~= nil and shown ~= nil and told ~= shown) then return tracker:Release(button) end
        tracker:Apply(button, reader, { bag = bag, slot = slot, id = told })
    end)
end

-- true cuando hay algo enganchado (el registro reintenta hasta que lo haya).
function Adapter.Install()
    if not hookedGlobal and type(rawget(_G, 'SetItemButtonQuality')) == 'function' then
        hookedGlobal = pcall(hooksecurefunc, 'SetItemButtonQuality', onQuality)
    end
    for _, name in ipairs(MIXINS) do
        local mixin = rawget(_G, name)
        if not hookedMixins[name] and type(mixin) == 'table' and type(mixin.SetItemButtonQuality) == 'function' then
            hookedMixins[name] = pcall(hooksecurefunc, mixin, 'SetItemButtonQuality', onQuality)
        end
    end
    if hookedGlobal then return true end
    for _, name in ipairs(MIXINS) do if hookedMixins[name] then return true end end
    return false
end

-- Repinta lo recordado sin tocar los botones que pasaron a otro dueno.
function Adapter.Refresh()
    for button, reader_ in pairs(tracker.readers) do
        if foreign(button) then
            tracker.readers[button], tracker.contexts[button] = nil, nil
        elseif Common.Call(button, 'IsShown') ~= false then
            pcall(tracker.Apply, tracker, button, reader_, tracker.contexts[button])
        end
    end
end

function Adapter.ResetState() hookedGlobal, hookedMixins = false, {} end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register(OWNER, { install = Adapter.Install, refresh = Adapter.Refresh, revalidate = revalidate })
