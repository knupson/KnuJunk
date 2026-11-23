local _, ns = ...

-- API oficial de Baganator: un widget KnuJunk para todas las marcas y dos IDs viejos inertes; Baganator gestiona esquina y autoinserción y no escribimos su configuración.
-- Un botón se marca solo si se prueba casilla viva de las bolsas 0-4 (o del banco vivo) del personaje actual: vistas guardadas, banco cerrado y hermandad, sin marca.
local Adapter = {}
ns.BaganatorAdapter = Adapter

local RESCAN_SECONDS = 2
-- Vistas de mochila ("<prefijo><skin>"): solo las skins que trae Baganator; la de otro addon no habilita la marca (fallo seguro).
local VIEW_PREFIXES = { 'Baganator_SingleViewBackpackViewFrame', 'Baganator_CategoryViewBackpackViewFrame' }
-- Vistas del banco: viva solo con el banco de Baganator activo (BANKFRAME_OPENED a _CLOSED) y mostrando al personaje actual.
local BANK_PREFIXES = { 'Baganator_SingleViewBankViewFrame', 'Baganator_CategoryViewBankViewFrame' }
local SKIN_KEYS = { 'blizzard', 'blizzard_black', 'dark', 'elvui', 'ellesmereui', 'gw2_ui', 'ndui' }

local JUNK_PLUGIN = { label = 'KnuJunk', id = 'knujunk' }
-- API/Main.lua admite defaultPosition; solicitar arriba a la derecha.
local WIDGETS = {
    { id = 'knujunk_icon', label = 'KnuJunk', position = { corner = 'top_right', priority = 1 }, accepts = function() return true end },
    -- IDs guardados por versiones anteriores: registrados, sin dibujo ni autoinserci?n.
    { id = 'knujunk_hammer', label = 'KnuJunk (' .. ns.L['Legacy widget'] .. ')', accepts = function() return false end },
    { id = 'knujunk_coin', label = 'KnuJunk (' .. ns.L['Legacy widget'] .. ')', accepts = function() return false end },
}

local done = {}          -- [id] = true: lo ya registrado en Baganator (no se duplica)
local views = {}         -- [nombre] = frame: vistas de mochila ya encontradas (no se destruyen)
local bankViews = {}     -- [nombre] = frame: vistas del banco ya encontradas
local lastScan           -- GetTime() de la ultima busqueda de las que faltan
local scanDirty = true   -- Refresh pide buscar de nuevo las que faltan (ventana creada tarde)
local waiting = {}       -- [itemID] = true: items cuyos datos esperamos para pedir un refresco

local function api()
    local root = rawget(_G, 'Baganator')
    if type(root) == 'table' and type(root.API) == 'table' then return root.API end
end

-- Vista de mochila viva

-- Busca por nombre (rawget, sin barrer _G) solo las vistas que aun no aparecieron.
local function scanInto(prefixes, found)
    for _, prefix in ipairs(prefixes) do
        for _, skin in ipairs(SKIN_KEYS) do
            local name = prefix .. skin
            if not found[name] then
                local frame = rawget(_G, name)
                if type(frame) == 'table' then found[name] = frame end
            end
        end
    end
end

local function scanViews()
    scanInto(VIEW_PREFIXES, views)
    scanInto(BANK_PREFIXES, bankViews)
    lastScan, scanDirty = GetTime(), false
end

local function currentCharacter()
    local syndicator = rawget(_G, 'Syndicator')
    if type(syndicator) == 'table' and type(syndicator.API) == 'table'
        and type(syndicator.API.GetCurrentCharacter) == 'function' then
        local success, name = pcall(syndicator.API.GetCurrentCharacter)
        if success then return name end
    end
end

-- true solo si hay al menos una vista de mochila visible y todas las visibles son la viva del
-- personaje actual. Un frame desconocido nunca habilita la marca: solo la bloquea.
local function liveBackpack()
    if scanDirty or not lastScan or GetTime() - lastScan >= RESCAN_SECONDS then scanViews() end
    local current = currentCharacter()
    local live = false
    for _, view in pairs(views) do
        local success, shown = pcall(view.IsShown, view)
        if success and shown then
            if view.isLive ~= true then return false end
            if current ~= nil and view.lastCharacter ~= nil and view.lastCharacter ~= current then return false end
            live = true
        end
    end
    return live
end

-- true solo con el banco vivo (ns.Bank), al menos una vista del banco visible y todas las visibles
-- con liveBankActive, la pestana actual viva y (si se sabe) del personaje actual.
local function liveBank()
    if not ns.Bank.IsLive() then return false end
    if scanDirty or not lastScan or GetTime() - lastScan >= RESCAN_SECONDS then scanViews() end
    local current = currentCharacter()
    local live = false
    for _, view in pairs(bankViews) do
        local success, shown = pcall(view.IsShown, view)
        if success and shown then
            if view.liveBankActive ~= true then return false end
            local tab = view.currentTab
            if type(tab) ~= 'table' or tab.isLive ~= true then return false end
            if current ~= nil and tab.lastCharacter ~= nil and tab.lastCharacter ~= current then return false end
            live = true
        end
    end
    return live
end

-- La vista viva que corresponde a la bolsa: la del banco para bolsas del banco, la mochila si no.
local function liveViewFor(bag)
    if ns.Bank.IsBankBag(bag) then return liveBank() end
    return liveBackpack()
end

-- Callbacks

-- Pide un refresco cuando lleguen los datos del item (el veredicto quedo pendiente).
local function await(itemID)
    if type(itemID) == 'number' then waiting[itemID] = true end
end

-- true si Baganator, con su criterio por defecto ('poor_quality': calidad Pobre y con valor de venta),
-- tambien lo llamaria basura. `item` es el leido por Marks.Verdict.
local function grayJunk(mark, item)
    return mark == 'coin' and type(item) == 'table' and item.quality == 0
        and type(item.price) == 'number' and item.price > 0
end

-- Solo grises con precio que siguen siendo moneda para nosotros: nunca saca de su categoria un item que Baganator no moveria por su cuenta.
local function junkCallback(bagID, slotID, itemID)
    if type(itemID) ~= 'number' or not liveViewFor(bagID) then return nil end
    local mark, pending, _, item = ns.Marks.Verdict(bagID, slotID, itemID)
    if pending then await(itemID) end
    return grayJunk(mark, item)
end

-- true si el junk plugin de KnuJunk esta activo en Baganator (ante un error, se supone que si).
local function junkPluginActive()
    local API = api()
    if not API or type(API.IsJunkPluginActive) ~= 'function' then return false end
    local success, result = pcall(API.IsJunkPluginActive, JUNK_PLUGIN.id)
    return not success or result == true
end

local function nativeJunkActive()
    if not junkPluginActive() then return false end
    local API = api()
    if type(API.IsCornerWidgetActive) ~= 'function' then return true end
    local success, active = pcall(API.IsCornerWidgetActive, 'junk')
    return not success or active == true
end

local function widgetCallback(accepts, isCoin)
    return function(texture, details)
        local button = type(texture) == 'table' and type(texture.GetParent) == 'function' and texture:GetParent() or nil
        if button then ns.Marks.UpdateLevel(button, nil) end
        if type(details) ~= 'table' or type(details.itemID) ~= 'number' then return false end
        local location = details.itemLocation
        if type(location) ~= 'table' or type(location.bagID) ~= 'number' or type(location.slotIndex) ~= 'number' then
            return false
        end
        -- Banco: ademas de itemLocation (solo en botones vivos), la vista del banco tiene que ser la viva.
        if ns.Bank.IsBankBag(location.bagID) and not liveBank() then return false end
        local mark, pending, _, item = ns.Marks.Verdict(location.bagID, location.slotIndex, details.itemID)
        if pending then await(details.itemID) end
        if button and item then ns.Marks.UpdateLevel(button, item) end
        -- Gris con el junk plugin de KnuJunk activo: la moneda nativa ya lo cubre (sin doble moneda).
        if grayJunk(mark, item) and nativeJunkActive() then return false end
        if mark and accepts(mark) and ns.Marks.Style(texture, mark) then return true end
        return false
    end
end

local function createWidget(itemButton)
    return ns.Marks.CreateWidget(itemButton)
end

-- Registro

-- true cuando el plugin, el widget único y los alias están registrados. Reintentable: registra solo lo que falta.
function Adapter.Install()
    local API = api()
    if not API or type(API.RegisterJunkPlugin) ~= 'function' or type(API.RegisterCornerWidget) ~= 'function' then
        return false
    end
    if not done[JUNK_PLUGIN.id] then
        done[JUNK_PLUGIN.id] = pcall(API.RegisterJunkPlugin, JUNK_PLUGIN.label, JUNK_PLUGIN.id, junkCallback)
    end
    for _, widget in ipairs(WIDGETS) do
        if not done[widget.id] then
            done[widget.id] = pcall(API.RegisterCornerWidget, widget.label, widget.id,
                widgetCallback(widget.accepts, widget.coin), createWidget, widget.position)
        end
    end
    return done[JUNK_PLUGIN.id] == true and done.knujunk_icon == true and done.knujunk_hammer == true and done.knujunk_coin == true
end

-- Repinta pidiendo a Baganator que reevalue sus botones, solo si algo nuestro esta activo y solo por cambios de veredicto (bagUpdates = false): Baganator ya redibuja cuando cambian las bolsas.
function Adapter.Refresh()
    scanDirty = true
    local API = api()
    if not API or type(API.RequestItemButtonsRefresh) ~= 'function' then return end
    local function active(name, id)
        if type(API[name]) ~= 'function' then return true end -- sin forma de saberlo: se pide igual
        local success, result = pcall(API[name], id)
        return not success or result == true
    end
    if active('IsJunkPluginActive', JUNK_PLUGIN.id) or active('IsCornerWidgetActive', 'knujunk_icon')
        or active('IsCornerWidgetActive', 'knujunk_coin') then
        local root = rawget(_G, 'Baganator')
        local reasons = type(root) == 'table' and type(root.Constants) == 'table' and root.Constants.RefreshReason
        local widgets = type(reasons) == 'table' and reasons.ItemWidgets
        local searches = type(reasons) == 'table' and reasons.Searches
        if type(widgets) == 'number' and type(searches) == 'number' then
            pcall(API.RequestItemButtonsRefresh, { widgets, searches })
        else
            pcall(API.RequestItemButtonsRefresh)
        end
    end
end

-- Solo para pruebas: deja el modulo como recien cargado (lo ya registrado en un Baganator falso se olvida).
function Adapter.ResetState()
    done, views, bankViews, lastScan, scanDirty, waiting = {}, {}, {}, nil, true, {}
end

local frame = CreateFrame('Frame')
pcall(frame.RegisterEvent, frame, 'GET_ITEM_INFO_RECEIVED')
frame:SetScript('OnEvent', function(_, _, itemID)
    if waiting[itemID] then
        waiting[itemID] = nil
        Adapter.Refresh()
    end
end)

ns.Bags.Register('Baganator', { addon = 'Baganator', install = Adapter.Install, refresh = Adapter.Refresh,
    bagUpdates = false, bank = true })
