local _, ns = ...

-- Baganator por su API oficial (Baganator.API): ni hooks ni frames propios sobre sus botones.
--   * junk plugin 'KnuJunk': Baganator pinta SU moneda de basura donde devolvemos true (solo 'coin').
--   * corner widgets 'KnuJunk: martillo' y 'KnuJunk: monedita': nuestra marca en una esquina del
--     boton (el martillo se autoinserta arriba a la derecha; la monedita queda a elegir del jugador).
--     Este adaptador nunca escribe la configuracion de Baganator: la autoinsercion es suya.
-- Regla de oro: si un boton no se puede PROBAR como una casilla viva de las bolsas 0-4 del personaje
-- actual (vistas guardadas de otros personajes, banco, hermandad), no se marca.
--   * Corner widget: Baganator pasa los detalles del boton; `itemLocation` solo lo fijan los botones
--     de contenedor VIVOS, asi que ahi esta la prueba (bolsa 0-4 + el item del slot coincide).
--   * Junk plugin: el callback solo recibe bagID/slotID/itemID (las vistas guardadas de otro personaje
--     llegan con los mismos numeros), asi que ademas se exige que la vista de mochila visible de
--     Baganator sea la viva (isLive) del personaje actual.
local Adapter = {}
ns.BaganatorAdapter = Adapter

local SIZE = 14
local RESCAN_SECONDS = 2
-- Vistas de mochila: "<prefijo><skin>" (ViewManagement/Initialize.lua l.150-151, frameGroup = clave
-- de skin, Skins/Initialize.lua l.43). Claves de las skins que trae Baganator (Skins/*.lua,
-- RegisterSkin). Una skin de otro addon no se conoce: su vista no habilita la marca (fallo seguro).
local VIEW_PREFIXES = { 'Baganator_SingleViewBackpackViewFrame', 'Baganator_CategoryViewBackpackViewFrame' }
local SKIN_KEYS = { 'blizzard', 'blizzard_black', 'dark', 'elvui', 'ellesmereui', 'gw2_ui', 'ndui' }

local JUNK_PLUGIN = { label = 'KnuJunk', id = 'knujunk' }
-- El martillo se autoinserta (una sola vez, lo gestiona Baganator) en la esquina superior derecha:
-- por defecto Baganator la deja vacia (arriba izquierda: junk + nivel; abajo: set y cantidad). La
-- monedita NO lleva posicion: la moneda nativa la da el junk plugin.
local HAMMER_POSITION = { corner = 'top_right', priority = 1 }
local WIDGETS = {
    { id = 'knujunk_hammer', label = 'KnuJunk: martillo', position = HAMMER_POSITION, accepts = function(mark) return mark == 'hammer_mine' or mark == 'hammer_other' end },
    { id = 'knujunk_coin', label = 'KnuJunk: monedita', coin = true, accepts = function(mark) return mark == 'coin' end },
}

local done = {}          -- [id] = true: lo ya registrado en Baganator (no se duplica)
local views = {}         -- [nombre] = frame: vistas de mochila ya encontradas (no se destruyen)
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
local function scanViews()
    for _, prefix in ipairs(VIEW_PREFIXES) do
        for _, skin in ipairs(SKIN_KEYS) do
            local name = prefix .. skin
            if not views[name] then
                local frame = rawget(_G, name)
                if type(frame) == 'table' then views[name] = frame end
            end
        end
    end
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

-- ---------------------------------------------------------------------------
-- Callbacks
-- ---------------------------------------------------------------------------

-- Pide un refresco cuando lleguen los datos del item (el veredicto quedo pendiente).
local function await(itemID)
    if type(itemID) == 'number' then waiting[itemID] = true end
end

local function junkCallback(bagID, slotID, itemID)
    if type(itemID) ~= 'number' or not liveBackpack() then return nil end
    local mark, pending = ns.Marks.Verdict(bagID, slotID, itemID)
    if pending then await(itemID) end
    return mark == 'coin'
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
        -- La moneda nativa del junk plugin ya cubre el item: el widget no dibuja otra.
        if isCoin and junkPluginActive() then return false end
        local location = details.itemLocation
        if type(location) ~= 'table' or type(location.bagID) ~= 'number' or type(location.slotIndex) ~= 'number' then
            return false
        end
        local mark, pending = ns.Marks.Verdict(location.bagID, location.slotIndex, details.itemID)
        if pending then await(details.itemID) end
        if mark and accepts(mark) and ns.Marks.Style(texture, mark) then return true end
        return false
    end
end

local function createWidget(itemButton)
    local texture = itemButton:CreateTexture(nil, 'OVERLAY', nil, 7)
    texture:SetSize(SIZE, SIZE)
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
-- Solo por cambios de veredicto (Registry: bagUpdates = false) y solo los widgets (sin Searches):
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
        if type(widgets) == 'number' then
            pcall(API.RequestItemButtonsRefresh, { widgets })
        else
            pcall(API.RequestItemButtonsRefresh)
        end
    end
end

-- Solo para pruebas: deja el modulo como recien cargado (lo ya registrado en un Baganator falso se olvida).
function Adapter.ResetState()
    done, views, lastScan, scanDirty, waiting = {}, {}, nil, true, {}
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
    bagUpdates = false })
