local _, ns = ...

-- Baganator por su API oficial (Baganator.API): ni hooks ni frames propios sobre sus botones.
--   * junk plugin 'KnuJunk': Baganator pinta SU moneda de basura donde devolvemos true y, en la vista
--     de categorias, MUEVE esos items a su categoria de basura (CategoryViews/BagLayout.lua l.39-66,
--     ItemsPreparation.lua l.38-46). KnuJunk nunca recategoriza: devolvemos true SOLO donde Baganator
--     tambien diria basura con su opcion por defecto (gris con precio de venta, ItemButton.lua l.216)
--     y nuestras protecciones no lo salvan. Las demas monedas (mision terminada, clase, a mano...)
--     solo las dibuja la esquina 'KnuJunk: monedita'.
--   * corner widgets 'KnuJunk: martillo' y 'KnuJunk: monedita': nuestra marca en una esquina del
--     boton (el martillo se autoinserta arriba a la derecha; la monedita arriba a la izquierda, donde
--     Baganator pone su icono de basura). Este adaptador nunca escribe la configuracion de Baganator:
--     la autoinsercion es suya.
-- Regla de oro: si un boton no se puede PROBAR como una casilla viva de las bolsas 0-4 (o del banco
-- VIVO, ns.Bank) del personaje actual (vistas guardadas de otros personajes, banco cerrado, hermandad),
-- no se marca.
--   * Corner widget: Baganator pasa los detalles del boton; `itemLocation` solo lo fijan los botones
--     de contenedor VIVOS (ItemViewCommon/ItemButton.lua l.675-682, Layouts.lua l.885 y
--     CategoryViews/BagLayout.lua l.55-71 solo con isLive), asi que ahi esta la prueba (bolsa
--     0-4 o del banco + el item del slot coincide). Para el banco se exige ademas la vista del banco viva.
--   * Junk plugin: el callback solo recibe bagID/slotID/itemID (las vistas guardadas de otro personaje
--     llegan con los mismos numeros), asi que ademas se exige que la vista visible de Baganator que
--     corresponde (mochila para 0-4, banco para el banco) sea la viva del personaje actual.
local Adapter = {}
ns.BaganatorAdapter = Adapter

local SIZE = 20
local RESCAN_SECONDS = 2
-- Vistas de mochila: "<prefijo><skin>" (ViewManagement/Initialize.lua l.150-151, frameGroup = clave
-- de skin, Skins/Initialize.lua l.43). Claves de las skins que trae Baganator (Skins/*.lua,
-- RegisterSkin). Una skin de otro addon no se conoce: su vista no habilita la marca (fallo seguro).
local VIEW_PREFIXES = { 'Baganator_SingleViewBackpackViewFrame', 'Baganator_CategoryViewBackpackViewFrame' }
-- Vistas del banco (ViewManagement/Initialize.lua l.226-227). Viva solo si Baganator tiene el banco
-- activo (ItemViewCommon/BankView.lua l.144-156: liveBankActive entre BANKFRAME_OPENED y _CLOSED) y su
-- pestana actual es la viva (BankViewCharacterTabsView.lua l.469-485: isLive = liveBankActive y el
-- personaje mostrado es el vivo).
local BANK_PREFIXES = { 'Baganator_SingleViewBankViewFrame', 'Baganator_CategoryViewBankViewFrame' }
local SKIN_KEYS = { 'blizzard', 'blizzard_black', 'dark', 'elvui', 'ellesmereui', 'gw2_ui', 'ndui' }

local JUNK_PLUGIN = { label = 'KnuJunk', id = 'knujunk' }
-- Autoinsercion (una sola vez, la gestiona Baganator): el martillo arriba a la derecha (por defecto
-- vacia; abajo: set y cantidad) y la monedita arriba a la izquierda, junto al icono de basura de
-- Baganator: asi las monedas que no son basura para Baganator se ven sin configurar nada.
local HAMMER_POSITION = { corner = 'top_right', priority = 1 }
local COIN_POSITION = { corner = 'top_left', priority = 1 }
local WIDGETS = {
    { id = 'knujunk_hammer', label = 'KnuJunk: martillo', position = HAMMER_POSITION, accepts = function(mark) return mark == 'hammer_mine' or mark == 'hammer_other' end },
    { id = 'knujunk_coin', label = 'KnuJunk: monedita', coin = true, position = COIN_POSITION, accepts = function(mark) return mark == 'coin' end },
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

-- ---------------------------------------------------------------------------
-- Vista de mochila viva
-- ---------------------------------------------------------------------------

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

-- true solo si hay al menos una vista de mochila visible y TODAS las visibles son la viva del
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

-- true solo con el banco VIVO (ns.Bank), al menos una vista del banco visible y TODAS las visibles
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

-- ---------------------------------------------------------------------------
-- Callbacks
-- ---------------------------------------------------------------------------

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

-- Solo grises con precio que siguen siendo moneda para nosotros (override_keep, items utiles,
-- reactivos y misiones los salvan): KnuJunk nunca saca de su categoria un item que Baganator no
-- moveria por su cuenta.
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

local function widgetCallback(accepts, isCoin)
    return function(texture, details)
        if type(details) ~= 'table' or type(details.itemID) ~= 'number' then return false end
        local location = details.itemLocation
        if type(location) ~= 'table' or type(location.bagID) ~= 'number' or type(location.slotIndex) ~= 'number' then
            return false
        end
        -- Banco: ademas de itemLocation (solo en botones vivos), la vista del banco tiene que ser la viva.
        if ns.Bank.IsBankBag(location.bagID) and not liveBank() then return false end
        local mark, pending, _, item = ns.Marks.Verdict(location.bagID, location.slotIndex, details.itemID)
        if pending then await(details.itemID) end
        -- Gris con el junk plugin de KnuJunk activo: la moneda nativa ya lo cubre (sin doble moneda).
        if isCoin and grayJunk(mark, item) and junkPluginActive() then return false end
        if mark and accepts(mark) and ns.Marks.Style(texture, mark) then return true end
        return false
    end
end

local function createWidget(itemButton)
    local texture = itemButton:CreateTexture(nil, 'OVERLAY', nil, 7)
    texture:SetSize(SIZE, SIZE)
    -- pegada al borde de la esquina, igual que el JunkIcon de Baganator (API/ItemButton.lua:288)
    texture.padding = 0
    return texture
end

-- ---------------------------------------------------------------------------
-- Registro
-- ---------------------------------------------------------------------------

-- true cuando los tres elementos estan registrados. Reintentable: registra solo lo que falta.
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
    return done[JUNK_PLUGIN.id] == true and done.knujunk_hammer == true and done.knujunk_coin == true
end

-- Repinta: pide a Baganator que vuelva a evaluar sus botones, solo si algo nuestro esta activo.
-- Solo por cambios de veredicto (Registry: bagUpdates = false); widgets y busquedas:
-- Baganator ya redibuja sus botones cuando cambian las bolsas.
function Adapter.Refresh()
    scanDirty = true
    local API = api()
    if not API or type(API.RequestItemButtonsRefresh) ~= 'function' then return end
    local function active(name, id)
        if type(API[name]) ~= 'function' then return true end -- sin forma de saberlo: se pide igual
        local success, result = pcall(API[name], id)
        return not success or result == true
    end
    if active('IsJunkPluginActive', JUNK_PLUGIN.id) or active('IsCornerWidgetActive', 'knujunk_hammer')
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
