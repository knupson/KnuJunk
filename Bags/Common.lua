local _, ns = ...

-- Piezas compartidas por los adaptadores de bolsas con API propia (BetterBags, AdiBags, ArkInventory,
-- EllesmereUIBags, LiteBag, tdBag2, Baggins). Nada aqui toca el addon de bolsas: solo traduce
-- "este boton muestra la bolsa X, slot Y" a ns.Marks.Update y recuerda el boton para repintarlo.
-- Regla de oro: si no se puede PROBAR que el boton es una casilla viva de las bolsas 0-4 del
-- personaje actual, sin marca.
local Common = {}
ns.Bags.Common = Common

local resetters = {}

-- Un adaptador anota aqui como volver a su estado inicial (solo para pruebas).
function Common.OnReset(fn) resetters[#resetters + 1] = fn end
function Common.ResetState() for _, fn in ipairs(resetters) do fn() end end

-- Llama object:name(...) aislando errores; devuelve el primer valor o nil.
function Common.Call(object, name, ...)
    if type(object) ~= 'table' then return nil end
    local fn = object[name]
    if type(fn) ~= 'function' then return nil end
    local success, value = pcall(fn, object, ...)
    if success then return value end
end

-- Libreria de LibStub sin errores (silenciosa), o nil.
function Common.Library(name)
    local stub = rawget(_G, 'LibStub')
    if not stub then return nil end
    local success, library = pcall(stub, name, true)
    if success and type(library) == 'table' then return library end
end

-- ID del item que hay AHORA en un slot de bolsa (sin necesitar sus datos), o nil.
function Common.LiveItemID(bag, slot)
    if type(C_Container) == 'table' and type(C_Container.GetContainerItemInfo) == 'function' then
        local success, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
        if success and type(info) == 'table' then
            if type(info.itemID) == 'number' then return info.itemID end
            if type(info.hyperlink) == 'string' then return tonumber(info.hyperlink:match('item:(%d+)')) end
        end
    end
end

function Common.ItemIDOf(link)
    if type(link) == 'number' then return link end
    if type(link) == 'string' then return tonumber(link:match('item:(%d+)')) end
end

local NON_CARRIED_NAMES = { 'bank', 'guild', 'vault', 'voidstorage' }
local NON_CARRIED_FLAGS = { 'isguild', 'isGuild', 'isGuildBank', 'isVault', 'isBank', 'isCached', 'cached' }
local MAX_DEPTH = 16

-- true si el boton (o alguno de sus ancestros) es POSITIVAMENTE una vista no portada: banco,
-- hermandad, vault, vista cacheada. Si la ascendencia no se puede recorrer completa tambien
-- devuelve true (ante la duda, sin marca).
function Common.NonCarried(button)
    local object = button
    local seen = {}
    for _ = 1, MAX_DEPTH do
        if object == nil then return false end
        if type(object) ~= 'table' or seen[object] then return true end
        seen[object] = true
        local name = Common.Call(object, 'GetName')
        if type(name) == 'string' then
            name = name:lower()
            for _, word in ipairs(NON_CARRIED_NAMES) do
                if name:find(word, 1, true) then return true end
            end
        end
        for _, flag in ipairs(NON_CARRIED_FLAGS) do
            local value = object[flag]
            if value ~= nil and value ~= false and type(value) ~= 'function' then return true end
        end
        if Common.Call(object, 'IsCached') == true then return true end
        local frame = object.frame
        if type(frame) == 'table' then object = frame else object = Common.Call(object, 'GetParent') end
    end
    return true
end

-- Seguimiento de botones de UN adaptador: cada boton recuerda su "lector" (funcion que devuelve
-- bag, slot [, itemID esperado], o nil para "sin marca"), asi se repinta sin esperar al addon.
function Common.NewTracker(owner)
    local tracker = { owner = owner, readers = setmetatable({}, { __mode = 'k' }) }

    -- Lee y marca. El itemID esperado, si viene, tiene que ser el que hay ahora en el slot: si el
    -- addon aun no redibujo tras un cambio, queda sin marca hasta que lo haga.
    function tracker:Apply(button, reader)
        if type(button) ~= 'table' then return end
        self.readers[button] = reader
        local success, bag, slot, expected = pcall(reader, button)
        if not success or type(bag) ~= 'number' or type(slot) ~= 'number' then return ns.Marks.Clear(button) end
        if expected ~= nil and Common.LiveItemID(bag, slot) ~= expected then return ns.Marks.Clear(button) end
        ns.Marks.Update(button, bag, slot, self.owner)
    end

    function tracker:Release(button)
        if type(button) ~= 'table' then return end
        self.readers[button] = nil
        ns.Marks.Clear(button)
    end

    -- Repinta lo recordado; un boton oculto se deja (se repinta cuando el addon lo redibuje).
    function tracker:Refresh()
        for button, reader in pairs(self.readers) do
            local shown = Common.Call(button, 'IsShown')
            if shown ~= false then pcall(self.Apply, self, button, reader) end
        end
    end

    function tracker:Reset() self.readers = setmetatable({}, { __mode = 'k' }) end
    Common.OnReset(function() tracker:Reset() end)
    return tracker
end
