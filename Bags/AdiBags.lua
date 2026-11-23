local _, ns = ...

-- AdiBags por sus mensajes (ABEvent-1.0: AdiBags_AcquireButton, _UpdateButton y _ReleaseButton), sin hooks sobre su clase ItemButton.
-- Sin verificar en el juego (addon no instalado aqui): sin button.itemId numerico o con el slot ya cambiado, sin marca.
local OWNER = 'AdiBags'
local Adapter = {}
ns.AdiBagsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local receiver = {}      -- "self" con el que nos anotamos en ABEvent
local registered = {}    -- [mensaje] = true
local released = setmetatable({}, { __mode = 'k' })

-- Sin itemId mostrado no hay identidad: sin marca.
local function reader(button)
    if released[button] then return nil end
    local shown = button.itemId
    if type(shown) ~= 'number' then return nil end
    return button.bag, button.slot, shown
end

local function revalidate(button) return tracker:Read(button) end

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

ns.Bags.Register('AdiBags', { addon = 'AdiBags', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
