local _, ns = ...

-- Bolsas sin API de plugins, halladas por el NOMBRE GLOBAL de sus botones: Combuctor, OneBag3,
-- Inventorian, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory. Los
-- patrones salen de peddler Peddler.lua (l.291-304 Combuctor, 306-319 OneBag3, 374-396 Nivaya,
-- 398-413 m_Bags, 415-423 DerpyStuffing, 465-473 famBags, 475-483 LUI, 485-507 RealUI; rangos
-- corregidos en analisis/_auditoria-codex.md filas 22-25) y, para Inventorian, del codigo real
-- (Inventorian 12.1.5.1 Item.lua l.22: InventorianItemButton<n>; l.57-70: reusa ContainerFrame<c>Item<i>).
-- Escritos de cero; el recorrido NO copia el barrido de 1000/2000 globals de la referencia:
--   * solo con el addon cargado (Registry), solo si el CONTENEDOR del addon (entry.frame) existe y es
--     visible (IsVisible) antes de sondear nada, y solo botones visibles. Una entrada SIN contenedor
--     conocido NO recorre (decision del controlador, 2026-11-17): hoy solo Inventorian lo tiene
--     verificado (_G.InventorianBagFrame); las otras ocho conservan sus patrones y recorreran cuando se
--     verifique el nombre de su ventana en el juego (campo `frame`);
--   * acotado: cada serie de nombres se corta en el PRIMER indice que falta y hay un tope total de
--     sondeos por pasada (PROBE_CAP). Si un addon numera con huecos, lo que sigue al hueco no se ve
--     (sin marca: el fallo seguro).
-- El nombre solo DESCUBRE el boton; bolsa y slot salen del propio boton (GetBagID / button.bag / ID
-- del padre, que si coinciden entre si; slot = GetID()), nunca del nombre.
-- IDENTIDAD: no hay callback de redibujado en estos addons, asi que NO se captura el slot vivo:
-- solo cuenta lo que el boton EXPONE (Common.DisplayedID: itemID, itemLink, info.*, GetItemID) y
-- tiene que coincidir con el item vivo del slot. Boton sin campo expuesto: sin marca, "sin marca
-- hasta verificar en el juego" (salvo Inventorian, cuyo fuente real publica button.itemLink, l.130-133).
-- Inventorian: solo se mira itemLink (Item.lua l.130-133: SetItem fija item e itemLink en cada Update);
-- button.itemID (l.410 de GetInfo) nunca se limpia y puede estar viejo. Su IsCached() (l.373-375:
-- vista de otro personaje o banco sin abrir, Frame.lua l.707) lo ve Common.NonCarried; button.bag y SetBagID (l.85, 90)
-- tienen que coincidir con el ID del padre (bagContainers, l.353-366); la ventana de bolsas es
-- _G.InventorianBagFrame (Inventorian.lua l.81) y no se recorre mientras esta oculta. Banco VIVO (ns.Bank):
-- tambien se recorre _G.InventorianBankFrame (Inventorian.lua l.82) mientras esta visible, y un boton con
-- bolsa del banco se marca solo si su IsCached() es false (Frame.lua l.706-708: cacheado si es otro
-- personaje o el banco no esta abierto; Events.lua l.201-247 lo abre/cierra con BANKFRAME_* y
-- PLAYER_INTERACTION_MANAGER_FRAME_*). Las demas entradas no tienen banco: sin marca ahi.
-- Un boton con otro dueno dedicado (Marks.KnuJunkOwner de otro adaptador) no se toca; uno con dueno
-- generico ('generic' o 'GenericHook') se toma (Common.MayTakeOver) y el generico deja de seguirlo. Los refrescos llegan
-- por Registry (instalacion y BAG_UPDATE_DELAYED) y, con contenedor verificado, al abrir su ventana
-- (HookScript OnShow). Inventorian recicla botones en un pool: ver hookPooled.
-- SIN VERIFICAR EN EL JUEGO: ninguno de estos addons esta instalado aqui salvo lo leido de
-- Inventorian; los nombres son los de la competencia.
local Frames = {}
ns.Frames = Frames
Frames.probes = 0   -- sondeos de globals hechos en total (las pruebas comprueban que con la bolsa cerrada son 0)

local Common = ns.Bags.Common

local BAG_COUNT = 4          -- bolsas 0-4
local MAX_BAG_SLOTS = 42     -- tope por bolsa (ElvUI B.MAX_CONTAINER_ITEMS = 42)
local MAX_INDEX = 5 * MAX_BAG_SLOTS
local PROBE_CAP = 1000       -- sondeos de globals por pasada y addon (con el banco de Inventorian abierto
                             -- el pool crece: 13x36 ContainerFrame + InventorianItemButton, Item.lua l.17-24, 57-70)

local function inventorianLink(button) return Common.ItemIDOf(button.itemLink) end

-- scans: series de nombres. { from =, to =, name = function(outer, inner) } recorre outer
-- from..to e inner 1..max (corta inner al primer hueco); sin from/to: name(inner), inner 1..max.
local ENTRIES = {
    { name = 'Combuctor', addon = 'Combuctor', scans = {
        { from = 0, to = BAG_COUNT, max = 36, name = function(bag, slot) return 'ContainerFrame' .. (bag + 1) .. 'Item' .. slot end },
    } },
    { name = 'OneBag3', addon = 'OneBag3', scans = {
        { from = 0, to = BAG_COUNT, max = MAX_BAG_SLOTS, name = function(bag, slot) return 'OneBagFrameBag' .. bag .. 'Item' .. slot end },
    } },
    { name = 'Inventorian', addon = 'Inventorian', frame = 'InventorianBagFrame', bankFrame = 'InventorianBankFrame',
      identity = inventorianLink, pooled = true, scans = {
        { from = 1, to = NUM_CONTAINER_FRAMES or 13, max = 36, name = function(frame, slot) return 'ContainerFrame' .. frame .. 'Item' .. slot end },
        { max = MAX_INDEX, name = function(index) return 'InventorianItemButton' .. index end },
    } },
    { name = 'cargBags_Nivaya', addon = 'cargBags_Nivaya', scans = {
        { max = MAX_INDEX, name = function(index) return 'NivayaSlot' .. index end },
    } },
    { name = 'm_Bags', addon = 'm_Bags', scans = {
        { max = MAX_INDEX, name = function(index) return 'm_BagsSlot' .. index end },
    } },
    { name = 'DerpyStuffing', addon = 'DerpyStuffing', scans = {
        { from = 0, to = BAG_COUNT, max = MAX_BAG_SLOTS, name = function(bag, slot) return 'StuffingBag' .. bag .. '_' .. slot end },
    } },
    { name = 'famBags', addon = 'famBags', scans = {
        { from = 0, to = BAG_COUNT, max = MAX_BAG_SLOTS, name = function(bag, slot) return 'famBagsButton_' .. bag .. '_' .. slot end },
    } },
    { name = 'LUI', addon = 'LUI', scans = {
        { from = 0, to = BAG_COUNT, max = MAX_BAG_SLOTS, name = function(bag, slot) return 'LUIBags_Item' .. bag .. '_' .. slot end },
    } },
    { name = 'RealUI_Inventory', addon = 'RealUI_Inventory', scans = {
        { max = MAX_INDEX, name = function(index) return 'RealUIInventory_Slot' .. index end },
    } },
}
Frames.Entries = ENTRIES

-- Bolsa del boton: los datos que el boton da (GetBagID, button.bag, ID del padre) tienen que
-- coincidir entre si y hay al menos uno; slot = GetID().
local function bagOf(button)
    local found
    local function add(value)
        if value == nil then return true end
        if type(value) ~= 'number' or (found ~= nil and found ~= value) then return false end
        found = value
        return true
    end
    if not add(Common.Call(button, 'GetBagID')) or not add(button.bag) then return nil end
    if not add(Common.Call(Common.Call(button, 'GetParent'), 'GetID')) then return nil end
    return found
end

-- allowBank: la entrada soporta el banco (tiene bankFrame verificado). Una bolsa del banco solo se
-- acepta con el banco VIVO (ns.Bank) y si el boton dice explicitamente que NO es cache (Inventorian
-- Item.lua l.373-375 -> Frame.lua l.706-708: cacheado si es otro personaje o el banco no esta abierto).
local function locate(button, allowBank)
    if type(button) ~= 'table' then return nil end
    local bag = bagOf(button)
    if ns.Bank.IsBankBag(bag) then
        if not allowBank or not ns.Bank.IsLive() or Common.Call(button, 'IsCached') ~= false then return nil end
        if Common.NonCarried(button, true) then return nil end
        return bag, Common.Call(button, 'GetID')
    end
    if Common.NonCarried(button) then return nil end
    return bag, Common.Call(button, 'GetID')
end

local function visible(button)
    local value = Common.Call(button, 'IsVisible')
    if value == nil then value = Common.Call(button, 'IsShown') end
    return value == true
end

-- fn(boton) por cada boton global de las series de `entry`, sin repetir y con tope de sondeos.
local function eachButton(entry, fn)
    local probes, seen = 0, {}
    local function try(name)
        probes = probes + 1
        Frames.probes = Frames.probes + 1
        local button = rawget(_G, name)
        if button == nil then return false end
        if type(button) == 'table' and not seen[button] then
            seen[button] = true
            fn(button)
        end
        return true
    end
    for _, scan in ipairs(entry.scans) do
        local from, to = scan.from or 0, scan.to or 0
        for outer = from, to do
            for inner = 1, scan.max do
                if probes >= PROBE_CAP then return end
                local name = scan.from and scan.name(outer, inner) or scan.name(inner)
                if not try(name) then break end
            end
        end
    end
end

local function newAdapter(entry)
    local adapter = { entry = entry }
    local tracker = Common.NewTracker(entry.name)
    local allowBank = entry.bankFrame ~= nil
    local reader = Common.ExposedReader(function(button) return locate(button, allowBank) end, entry.identity and function(button)
        return entry.identity(button)
    end or nil)

    -- Sin contenedor conocido, inexistente u oculto: no se recorre. La ventana del banco (si la
    -- entrada la tiene verificada) cuenta solo con el banco vivo.
    local function shownFrame(name)
        local frame = name and rawget(_G, name)
        return type(frame) == 'table' and visible(frame)
    end
    local function frameOpen()
        if not entry.frame then return false end
        if shownFrame(entry.frame) then return true end
        return entry.bankFrame ~= nil and ns.Bank.IsLive() and shownFrame(entry.bankFrame)
    end

    local function paint(button)
        if not Common.MayTakeOver(button, entry.name) then return end
        if not visible(button) then return end
        pcall(tracker.Apply, tracker, button, reader)
    end

    -- Abrir la ventana del addon pide un refresco agrupado (HookScript, nunca SetScript). La
    -- ventana puede crearse despues de instalar: se reintenta en cada Refresh y unos segundos
    -- tras instalar.
    local hookedFrames = {} -- [nombre global] = ventana ya enganchada (si el global pasa a ser otra, se engancha esa)
    local function hookOne(name)
        local frame = rawget(_G, name)
        if frame == hookedFrames[name] then return frame ~= nil end
        if type(frame) ~= 'table' or type(frame.HookScript) ~= 'function' then return false end
        if pcall(frame.HookScript, frame, 'OnShow', function() ns.Bags.RefreshAll() end) then hookedFrames[name] = frame end
        return hookedFrames[name] == frame
    end
    -- true cuando la ventana de bolsas esta enganchada (la del banco se intenta, pero no se exige).
    local function hookShow()
        if not entry.frame then return true end
        if entry.bankFrame then hookOne(entry.bankFrame) end
        return hookOne(entry.frame)
    end

    -- Botones de un pool (Inventorian Item.lua l.73-97): Free los suelta (oculto, sin padre) y Set
    -- los reasigna a cualquier contenedor, banco incluido, y los redibuja con Update. Se engancha
    -- cada boton la primera vez que se lo ve (solo uno visto puede llevar nuestra marca): Free
    -- quita la marca; Set y Update vuelven a leer lo que muestra (banco, vista cacheada o bolsa
    -- fuera de 0-4: sin marca).
    local pooledHooks = setmetatable({}, { __mode = 'k' })
    local function release(button)
        if button.KnuJunkOwner == entry.name then tracker:Release(button) end
    end
    local function reread(button)
        if button.KnuJunkOwner ~= entry.name then return end
        if visible(button) then paint(button) else tracker:Release(button) end
    end
    local function hookPooled(button)
        if not entry.pooled or pooledHooks[button] then return end
        pooledHooks[button] = true
        if type(button.Free) == 'function' then pcall(hooksecurefunc, button, 'Free', release) end
        if type(button.Set) == 'function' then pcall(hooksecurefunc, button, 'Set', reread) end
        if type(button.Update) == 'function' then pcall(hooksecurefunc, button, 'Update', reread) end
    end

    local function visit(button)
        hookPooled(button)
        paint(button)
    end

    function adapter.Install()
        if not hookShow() and C_Timer and C_Timer.After then
            local tries = 0
            local function retry()
                tries = tries + 1
                if not hookShow() and tries < 10 then C_Timer.After(1, retry) end
            end
            C_Timer.After(1, retry)
        end
        return true
    end

    -- Recorre las series del addon (solo con su ventana visible) y repinta lo que encuentra.
    function adapter.Refresh()
        hookShow()
        if not frameOpen() then return end
        eachButton(entry, visit)
    end

    local function revalidate(button) return tracker:Read(button) end

    ns.Bags.Register(entry.name, { addon = entry.addon, install = adapter.Install, refresh = adapter.Refresh,
        revalidate = revalidate, bank = allowBank })
    return adapter
end

Frames.Adapters = {}
for _, entry in ipairs(ENTRIES) do Frames.Adapters[entry.name] = newAdapter(entry) end
