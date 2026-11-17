local _, ns = ...

-- Baggins por sus senales: Baggins:RegisterSignal(senal, callback, receptor).
-- Contrato VERIFICADO contra el codigo fuente de Baggins Forever 5.9.9 (Baggins/Baggins.lua):
--   * l.280-293: RegisterSignal(name, handler, arg1) falla sin arg1 (usamos un receptor propio);
--     FireSignal llama handler(arg1, ...) con los argumentos de la senal.
--   * l.3357-3409 y 3643: UpdateItemButton lee el item del slot (itemInfo) y lo usa en variables
--     LOCALES (no guarda itemID/link en el boton), fija button:SetID(slot), cuelga el boton de un
--     marco con SetID(bag) (bagframe.bagparents[bag]) y al final dispara, sincronamente,
--     FireSignal('Baggins_ItemButtonUpdated', bagframe, button, bag, slot): el callback recibe
--     (receptor, bagframe, boton, bag, slot).
--   * l.2950: existe 'Baggins_BagOpened' (Peddler la usa; aqui solo revalida lo ya rastreado).
-- Identidad: Baggins no la publica en el boton, asi que se toma en el callback (Common.Capture): el
-- slot vivo en ese instante es lo que Baggins acaba de dibujar. Un refresco posterior solo remarca
-- si lo capturado sigue siendo el item vivo del slot (si no, sin marca hasta la proxima senal).
-- Sin marca ademas: banco/hermandad/vault/cache (Common.NonCarried), bag/slot de la senal distintos
-- de los del boton, bolsas fuera de 0-4 (Marks). SIN VERIFICAR EN EL JUEGO (solo contra el codigo).
-- Referencias leidas (competencia/): questjunksweeper Bags.lua l.1173-1175, peddler Peddler.lua
-- l.261-272 y 663-665.
local OWNER = 'Baggins'
local Adapter = {}
ns.BagginsAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local receiver = {}
local registered = {}

local function locate(button)
    if Common.NonCarried(button) then return nil end
    return Common.Call(Common.Call(button, 'GetParent'), 'GetID'), Common.Call(button, 'GetID')
end

local reader = Common.CapturingReader(locate)

local function revalidate(button) return tracker:Read(button) end

local function root()
    local baggins = rawget(_G, 'Baggins')
    if type(baggins) == 'table' then return baggins end
end

-- Firma real: (receptor, bagframe, boton, bag, slot).
local function onButtonUpdated(_, _, button, bag, slot)
    pcall(function()
        if type(button) ~= 'table' or type(button.GetID) ~= 'function' then return end
        local buttonBag, buttonSlot = locate(button)
        if type(buttonBag) ~= 'number' or type(buttonSlot) ~= 'number'
            or (bag ~= nil and bag ~= buttonBag) or (slot ~= nil and slot ~= buttonSlot) then
            return tracker:Release(button)
        end
        tracker:Apply(button, reader, Common.Capture(buttonBag, buttonSlot))
    end)
end

local function onBagOpened() pcall(tracker.Refresh, tracker) end

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

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() registered = {} end
Common.OnReset(Adapter.ResetState)

ns.Bags.Register('Baggins', { addon = 'Baggins', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
