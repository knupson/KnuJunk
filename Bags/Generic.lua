local _, ns = ...

-- Adaptador generico: para cualquier bolsa que dibuje sus botones con las funciones de Blizzard.
-- Hook de SetItemButtonQuality(boton, calidad, itemIDOEnlace, ...): lo llaman, mientras redibujan
-- un slot, Bagnon (item.lua l.149), ElvUI (Bags.lua l.716) e Inventorian (Item.lua l.232), siempre
-- con el item que estan dibujando. Tambien se engancha el METODO homonimo de ItemButtonMixin y de
-- ContainerFrameItemButtonMixin si existen (los botones creados despues lo heredan: profession-mats
-- ProfessionMats.lua l.890-896, loot-triage Bags.lua l.139-179).
-- Se instala siempre (addon = nil) y es la ULTIMA red: reglas, todas de fallo seguro. Su dueno y su
-- spec se llaman 'GenericHook' (el 'generic' por defecto de Marks queda sin revalidador propio).
--   * PRUEBA POSITIVA: solo marca si la ascendencia del boton llega a un contenedor que algun adaptador
--     declaro como ventana viva del personaje actual (ns.Bags.DeclareLiveContainer; hoy lo hace el
--     adaptador de Blizzard con ContainerFrameN y ContainerFrameCombinedBags). Contenedor desconocido,
--     aunque los IDs y el item coincidan: sin marca (ni nombres ni IDs prueban de quien es una vista).
--   * Solo marca si el boton da GetBagID() y GetID() validos (bolsa 0-4, slot >= 1) Y hay identidad:
--     el item que el addon pasa a SetItemButtonQuality o los campos que el boton expone (Common.
--     DisplayedID). Sin identidad, sin marca: el slot vivo no prueba lo que se dibuja. Si el boton
--     dice una cosa y la llamada otra, sin marca.
--   * No dibuja sobre un boton que ya tiene dueno de otro adaptador (button.KnuJunkOwner ~= nil y
--     distinto de 'generic'/'GenericHook'); un adaptador dedicado SI puede tomar un boton nuestro (y
--     entonces dejamos de seguirlo); tampoco lo limpia ni lo repinta en los refrescos.
--   * Los botones de Baganator (llevan la tabla BGR, la fuente de identidad que Common.DisplayedID
--     ya reconoce) los cubre su adaptador oficial con sus propios iconos de esquina: aqui se dejan
--     para no duplicar la marca. SIN VERIFICAR que todos sus botones tengan BGR.
--   * Banco, hermandad, vault y cache: Common.NonCarried; fuera de 0-4: Marks.
-- SIN VERIFICAR EN EL JUEGO (solo contra los fuentes de Bagnon, ElvUI e Inventorian leidos y el
-- hook de la competencia).
local Adapter = {}
ns.GenericAdapter = Adapter

local Common = ns.Bags.Common
local OWNER = Common.GENERIC_OWNER
local tracker = Common.NewTracker(OWNER)
local hookedGlobal = false
local hookedMixins = {}
local MIXINS = { 'ItemButtonMixin', 'ContainerFrameItemButtonMixin' }

-- Dueno de OTRO adaptador dedicado ('generic', el valor por defecto de Marks, no cuenta como ajeno).
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
