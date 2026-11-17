local _, ns = ...

-- Piezas compartidas por los adaptadores de bolsas con API propia (BetterBags, AdiBags, ArkInventory,
-- EllesmereUIBags, LiteBag, tdBag2, Baggins). Nada aqui toca el addon de bolsas: solo traduce
-- "este boton muestra la bolsa X, slot Y" a ns.Marks.Update y recuerda el boton para repintarlo.
-- Regla de oro: si no se puede PROBAR que el boton es una casilla viva de las bolsas 0-4 del
-- personaje actual, sin marca.
local Common = {}
ns.Bags.Common = Common

local resetters = {}
Common.trackers = {}   -- los seguimientos creados (las pruebas inspeccionan sus lectores)

-- Un adaptador anota aqui como volver a su estado inicial (solo para pruebas).
function Common.OnReset(fn) resetters[#resetters + 1] = fn end
function Common.ResetState() for _, fn in ipairs(resetters) do fn() end end

-- Llama object:name(...) aislando errores; devuelve el primer valor o nil (un error y un nil se
-- confunden: donde importe la diferencia se usa TryCall).
function Common.Call(object, name, ...)
    local _, value = Common.TryCall(object, name, ...)
    return value
end

-- success, value: success es false si el metodo lanza error o object no es una tabla; true con
-- value nil si el metodo simplemente no existe.
function Common.TryCall(object, name, ...)
    if type(object) ~= 'table' then return false end
    local fn = object[name]
    if fn == nil then return true end
    if type(fn) ~= 'function' then return false end
    return pcall(fn, object, ...)
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
-- hermandad, vault, vista cacheada. Si la ascendencia no se puede recorrer completa (GetParent
-- ausente o que falla, IsCached/GetName que fallan, ciclo, mas de 16 niveles) tambien devuelve
-- true: ante la duda, sin marca. Solo llegar al final de la cadena (padre nil) prueba lo contrario.
function Common.NonCarried(button)
    local object = button
    local seen = {}
    for _ = 1, MAX_DEPTH do
        if object == nil then return false end
        if type(object) ~= 'table' or seen[object] then return true end
        seen[object] = true
        local named, name = Common.TryCall(object, 'GetName')
        if not named then return true end
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
        local checked, cached = Common.TryCall(object, 'IsCached')
        if not checked or cached == true then return true end
        local frame = object.frame
        if type(frame) == 'table' then
            object = frame
        else
            local walked, parent = Common.TryCall(object, 'GetParent')
            if not walked or (parent == nil and type(object.GetParent) ~= 'function') then return true end
            object = parent
        end
    end
    return true
end

-- Duenos "genericos": 'generic' es el dueno por defecto de Marks (llamada sin owner) y
-- 'GenericHook' el del adaptador generico por hook. Un adaptador dedicado puede tomar un boton que
-- tenga uno de ellos; los duenos dedicados de otros adaptadores nunca se pisan.
Common.GENERIC_OWNER = 'GenericHook'
function Common.MayTakeOver(button, owner)
    local current = button.KnuJunkOwner
    return current == nil or current == owner or current == 'generic' or current == Common.GENERIC_OWNER
end

local IDENTITY_NUMBERS = { 'itemID', 'itemId' }
local IDENTITY_LINKS = { 'itemLink', 'hyperlink', 'link' }
local IDENTITY_SOURCES = { 'info', 'BGR', 'details' }

-- ID del item que el boton MUESTRA segun su propia informacion (nunca lo que hay ahora en el slot):
-- campos itemID/itemId/itemLink/hyperlink/link del boton o de su tabla info/BGR/details, o
-- button:GetItemID(). Ninguno: nil. Campos invalidos o que se contradicen: nil, true (el boton dice
-- algo incoherente: sin marca).
-- Los campos y su orden salen de DisplayMatches de questjunksweeper (Bags.lua l.289-340).
function Common.DisplayedID(button)
    if type(button) ~= 'table' then return nil end
    local source = button
    for _, key in ipairs(IDENTITY_SOURCES) do
        if type(button[key]) == 'table' then source = button[key]; break end
    end
    local found
    local function add(id)
        if id == nil then return true end
        if found ~= nil and found ~= id then return false end
        found = id
        return true
    end
    for _, key in ipairs(IDENTITY_NUMBERS) do
        if source[key] ~= nil then
            if type(source[key]) ~= 'number' or not add(source[key]) then return nil, true end
        end
    end
    for _, key in ipairs(IDENTITY_LINKS) do
        if source[key] ~= nil then
            local id = Common.ItemIDOf(source[key])
            if not id or not add(id) then return nil, true end
        end
    end
    if found == nil then
        local success, id = Common.TryCall(button, 'GetItemID')
        if success and type(id) == 'number' then found = id end
    end
    return found
end

-- Para botones cuyo addon NO publica el item que dibuja (SIN VERIFICAR para LiteBag y tdBag2; real
-- en Baggins 5.9.9: UpdateItemButton guarda itemID/link solo en locales): la identidad se toma en
-- el CALLBACK de redibujado, que corre sincrono justo despues de que el addon dibujo ese slot,
-- asi que el slot vivo en ese instante es lo que el addon acaba de dibujar (Common.Capture).
-- En cualquier refresco posterior (sin callback) solo se vuelve a marcar si lo capturado sigue
-- siendo el item vivo del slot; si no, sin marca hasta el proximo callback. Un campo que el boton
-- SI exponga (Common.DisplayedID) manda sobre lo capturado.
-- locate(boton) -> bag, slot, o nil si el boton no es una casilla portada.
function Common.Capture(bag, slot)
    return { bag = bag, slot = slot, id = Common.LiveItemID(bag, slot) }
end

function Common.CapturingReader(locate)
    return function(button, context)
        local bag, slot = locate(button)
        if type(bag) ~= 'number' or type(slot) ~= 'number' then return nil end
        local shown, contradictory = Common.DisplayedID(button)
        if contradictory then return nil end
        if shown == nil then
            if type(context) ~= 'table' or context.bag ~= bag or context.slot ~= slot then return nil end
            shown = context.id
        end
        return bag, slot, shown
    end
end

-- Para botones cuyo addon SI publica el item que dibuja (Bagnon: button.info; ElvUI: slot.itemID y
-- slot.itemLink): la identidad es SOLO el campo expuesto, nunca el slot vivo. Sin campo, o con
-- campos que se contradicen, sin marca. identity(boton) -> itemID, contradictorio (opcional) reemplaza
-- a Common.DisplayedID cuando un addon deja campos viejos que no son de fiar (Inventorian).
function Common.ExposedReader(locate, identity)
    return function(button)
        local bag, slot = locate(button)
        if type(bag) ~= 'number' or type(slot) ~= 'number' then return nil end
        local shown, contradictory = (identity or Common.DisplayedID)(button)
        if contradictory or shown == nil then return nil end
        return bag, slot, shown
    end
end

-- Seguimiento de botones de UN adaptador. El lector es una funcion SIN capturas
-- reader(boton, contexto) -> bag, slot, itemID MOSTRADO (el que el propio addon de bolsas dice que
-- dibuja en el boton), o nil para "sin marca"; sin itemID mostrado no hay marca. Cada boton recuerda
-- su lector y un contexto minimo (escalares: nunca el propio boton), asi se repinta y se retoma una
-- marca pendiente sin esperar al addon, pero siempre volviendo a leer lo que el addon muestra y
-- contrastandolo con lo que hay AHORA en el slot.
function Common.NewTracker(owner)
    local tracker = { owner = owner, readers = setmetatable({}, { __mode = 'k' }), contexts = setmetatable({}, { __mode = 'k' }) }

    -- bag, slot, itemID mostrado de la lectura vigente, o nil. Nunca lanza.
    function tracker:Read(button)
        local reader = self.readers[button]
        if not reader then return nil end
        local success, bag, slot, shown = pcall(reader, button, self.contexts[button])
        if not success or type(bag) ~= 'number' or type(slot) ~= 'number' or type(shown) ~= 'number' then return nil end
        return bag, slot, shown
    end

    -- Lee y marca. Si el addon muestra un item distinto del que hay ahora en el slot (aun no
    -- redibujo tras un cambio) o no da identidad, queda sin marca hasta su proximo callback.
    function tracker:Apply(button, reader, context)
        if type(button) ~= 'table' then return end
        self.readers[button], self.contexts[button] = reader, context
        local bag, slot, shown = self:Read(button)
        if not bag or Common.LiveItemID(bag, slot) ~= shown then return ns.Marks.Clear(button) end
        ns.Marks.Update(button, bag, slot, self.owner)
    end

    function tracker:Release(button)
        if type(button) ~= 'table' then return end
        self.readers[button], self.contexts[button] = nil, nil
        ns.Marks.Clear(button)
    end

    -- Repinta lo recordado volviendo a leer; un boton oculto se deja (se repinta cuando el addon
    -- lo redibuje).
    function tracker:Refresh()
        for button, reader in pairs(self.readers) do
            if Common.Call(button, 'IsShown') ~= false then
                pcall(self.Apply, self, button, reader, self.contexts[button])
            end
        end
    end

    function tracker:Reset()
        self.readers = setmetatable({}, { __mode = 'k' })
        self.contexts = setmetatable({}, { __mode = 'k' })
    end
    Common.OnReset(function() tracker:Reset() end)
    Common.trackers[#Common.trackers + 1] = tracker
    return tracker
end
