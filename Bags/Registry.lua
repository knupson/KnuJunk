local _, ns = ...

-- Registro de adaptadores de bolsas. Cada adaptador (Blizzard, Bagnon, ...) se registra con
--   spec = { addon = 'Carpeta'|nil, install = function() -> bool, refresh = function()|nil,
--            revalidate = function(boton) -> bag, slot, itemID mostrado | nil (opcional) }
-- install se llama (hasta tener exito una vez) cuando su addon esta cargado: en PLAYER_LOGIN y en
-- cada ADDON_LOADED; devuelve false si aun no puede engancharse y se reintenta. refresh repinta.
local Bags = {}
ns.Bags = Bags

local REFRESH_DELAY = 0.1
local specs = {}       -- lista ordenada de { name =, spec = }
local installed = {}   -- [name] = true
local installedList = {}
local refreshPending = false
local baseline         -- cantidad de adaptadores propios del addon (para ResetState)

local function find(name)
    for _, entry in ipairs(specs) do if entry.name == name then return entry end end
end

function Bags.Register(name, spec)
    if type(name) ~= 'string' or type(spec) ~= 'table' or type(spec.install) ~= 'function' then return false end
    local entry = find(name)
    if entry then entry.spec = spec else specs[#specs + 1] = { name = name, spec = spec } end
    return true
end

local function addonLoaded(addon)
    if not addon then return true end
    if C_AddOns and type(C_AddOns.IsAddOnLoaded) == 'function' then return (C_AddOns.IsAddOnLoaded(addon)) and true or false end
    if type(IsAddOnLoaded) == 'function' then return (IsAddOnLoaded(addon)) and true or false end
    return false
end

-- Instala los adaptadores cuyo addon ya esta cargado. Un adaptador que falla o devuelve false se
-- reintenta en la proxima llamada; el error de uno no frena a los demas.
function Bags.InstallAll()
    local added = false
    for _, entry in ipairs(specs) do
        if not installed[entry.name] and addonLoaded(entry.spec.addon) then
            local success, result = pcall(entry.spec.install)
            if success and result then
                installed[entry.name] = true
                installedList[#installedList + 1] = entry.name
                added = true
            end
        end
    end
    if added then Bags.RefreshAll() end
end

-- spec.revalidate(boton) -> bag, slot, itemID mostrado | nil: lo usa Marks para retomar una marca
-- que quedo esperando (datos del item, combate) sin saltarse la lectura del adaptador.
function Bags.Revalidator(name)
    local entry = find(name)
    if entry and type(entry.spec.revalidate) == 'function' then return entry.spec.revalidate end
end

function Bags.Installed()
    local list = {}
    for index, name in ipairs(installedList) do list[index] = name end
    return list
end

local function refreshNow()
    refreshPending = false
    for _, entry in ipairs(specs) do
        if installed[entry.name] and type(entry.spec.refresh) == 'function' then pcall(entry.spec.refresh) end
    end
end

-- Repinta todos los adaptadores instalados: una sola pasada por rafaga de pedidos.
function Bags.RefreshAll()
    if not (C_Timer and C_Timer.After) then return refreshNow() end
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(REFRESH_DELAY, refreshNow)
end

-- Cambios reales de contexto y fin del indice de Questie piden un repintado.
local function connectSources()
    if ns.Player and ns.Player.OnChanged then ns.Player.OnChanged(function() Bags.RefreshAll() end) end
    if ns.Questie and ns.Questie.OnReady then ns.Questie.OnReady(function() Bags.RefreshAll() end) end
end
connectSources()

-- Solo para pruebas: deja el modulo como recien cargado (los adaptadores registrados despues de
-- la carga se descartan; los propios del addon quedan).
function Bags.ResetState()
    if baseline == nil then baseline = #specs end
    for index = #specs, baseline + 1, -1 do specs[index] = nil end
    installed, installedList, refreshPending = {}, {}, false
    connectSources()
end

local frame = CreateFrame('Frame')
for _, event in ipairs({ 'PLAYER_LOGIN', 'ADDON_LOADED', 'BAG_UPDATE_DELAYED' }) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript('OnEvent', function(_, event)
    if event == 'BAG_UPDATE_DELAYED' then Bags.RefreshAll() else Bags.InstallAll() end
end)
