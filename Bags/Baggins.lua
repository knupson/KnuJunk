local _, ns = ...

-- Baggins por sus senales: Baggins:RegisterSignal(senal, callback, receptor).
-- Mecanismo de las referencias, escrito de cero (SIN VERIFICAR EN EL JUEGO: Baggins no esta
-- instalado aqui; se detecta por forma):
--   * 'Baggins_ItemButtonUpdated': el boton llega como ultimo argumento tabla del callback
--     (questjunksweeper lo recibe como tercer argumento).
--   * 'Baggins_BagOpened' (Peddler) + recorrido de Baggins.bagframes[i].sections[j].items[k]: repinta
--     todo al abrir; es lo que usa Refresh.
--   * bolsa = button:GetParent():GetID(), slot = button:GetID() (Peddler l.261-272).
--   * sin marca: banco/hermandad/vault/cache (Common.NonCarried); bolsas fuera de 0-4 las descarta Marks.
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1173-1175, peddler Peddler.lua
-- l.261-272 y 663-665.
local OWNER = 'Baggins'
local Adapter = {}
ns.BagginsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local receiver = {}
local registered = {}

local function reader(button)
    if Common.NonCarried(button) then return nil end
    return Common.Call(Common.Call(button, 'GetParent'), 'GetID'), Common.Call(button, 'GetID')
end

local function root()
    local baggins = rawget(_G, 'Baggins')
    if type(baggins) == 'table' then return baggins end
end

-- El boton es el ultimo argumento tabla con GetID que no sea Baggins ni nuestro receptor.
local function buttonFrom(...)
    local found
    local baggins = root()
    for index = 1, select('#', ...) do
        local value = select(index, ...)
        if type(value) == 'table' and value ~= receiver and value ~= baggins and type(value.GetID) == 'function' then
            found = value
        end
    end
    return found
end

local function onButtonUpdated(...)
    local button = buttonFrom(...)
    if button then pcall(function() tracker:Apply(button, reader) end) end
end

local function walk()
    local baggins = root()
    local frames = baggins and baggins.bagframes
    if type(frames) ~= 'table' then return end
    local count = 0
    for _, bag in ipairs(frames) do
        for _, section in ipairs(type(bag) == 'table' and bag.sections or {}) do
            for _, button in ipairs(type(section) == 'table' and section.items or {}) do
                count = count + 1
                if count > 2000 then return end
                if type(button) == 'table' and Common.Call(button, 'IsShown') ~= false then
                    pcall(function() tracker:Apply(button, reader) end)
                end
            end
        end
    end
end

local function onBagOpened() pcall(walk) end

-- true cuando 'Baggins_ItemButtonUpdated' esta registrada ('Baggins_BagOpened' es un extra).
-- Reintentable: registra solo lo que falta.
function Adapter.Install()
    local baggins = root()
    if not baggins or type(baggins.RegisterSignal) ~= 'function' then return false end
    if not registered.updated then
        registered.updated = pcall(baggins.RegisterSignal, baggins, 'Baggins_ItemButtonUpdated', onButtonUpdated, receiver)
    end
    if not registered.opened then
        registered.opened = pcall(baggins.RegisterSignal, baggins, 'Baggins_BagOpened', onBagOpened, receiver)
    end
    return registered.updated == true
end

function Adapter.Refresh()
    walk()
    tracker:Refresh()
end

function Adapter.ResetState() registered = {} end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('Baggins', { addon = 'Baggins', install = Adapter.Install, refresh = Adapter.Refresh })
