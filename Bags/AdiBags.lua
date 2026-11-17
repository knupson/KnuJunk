local _, ns = ...

-- AdiBags por sus mensajes (ABEvent-1.0), sin hooks sobre su clase ItemButton.
-- Mecanismo de la referencia, escrito de cero (SIN VERIFICAR EN EL JUEGO: AdiBags no esta instalado
-- aqui; se detecta por forma):
--   * LibStub('ABEvent-1.0', true).RegisterMessage(receptor, mensaje, callback(mensaje, boton)) para
--     'AdiBags_AcquireButton' (boton reciclado: se limpia), 'AdiBags_UpdateButton' (se marca) y
--     'AdiBags_ReleaseButton' (se limpia).
--   * el boton trae button.bag, button.slot y button.itemId: ese es el slot que muestra.
--   * sin marca: boton soltado, o si el slot de bolsa 0-4 ya no tiene button.itemId. Los botones
--     del banco usan bolsas fuera de 0-4 (Marks los descarta); AdiBags no muestra otros personajes.
-- Alternativa de la referencia (no usada): hooksecurefunc al prototipo de su clase ItemButton.
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1137-1150, magic-eraser
-- Tint-Junk.lua l.322-345.
local OWNER = 'AdiBags'
local Adapter = {}
ns.AdiBagsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local receiver = {}      -- "self" con el que nos anotamos en ABEvent
local registered = {}    -- [mensaje] = true
local released = setmetatable({}, { __mode = 'k' })

local function reader(button)
    if released[button] then return nil end
    local expected = button.itemId
    if type(expected) ~= 'number' then expected = nil end
    return button.bag, button.slot, expected
end

local function onMessage(message, button)
    pcall(function()
        if type(button) ~= 'table' then return end
        if message == 'AdiBags_UpdateButton' then
            released[button] = nil
            tracker:Apply(button, reader)
        else
            released[button] = message == 'AdiBags_ReleaseButton' or nil
            tracker:Release(button)
        end
    end)
end

local MESSAGES = { 'AdiBags_AcquireButton', 'AdiBags_UpdateButton', 'AdiBags_ReleaseButton' }

-- true cuando los tres mensajes estan registrados. Reintentable: registra solo lo que falta.
function Adapter.Install()
    local events = Common.Library('ABEvent-1.0')
    if not events or type(events.RegisterMessage) ~= 'function' then return false end
    local all = true
    for _, message in ipairs(MESSAGES) do
        if not registered[message] then
            registered[message] = pcall(events.RegisterMessage, receiver, message, onMessage)
        end
        all = all and registered[message] == true
    end
    return all
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered, released = {}, setmetatable({}, { __mode = 'k' }) end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('AdiBags', { addon = 'AdiBags', install = Adapter.Install, refresh = Adapter.Refresh })
