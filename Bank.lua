local _, ns = ...

-- Banco VIVO del personaje actual: fuente unica de verdad para todo el addon.
-- Regla (decision del controlador, 2026-11-17): el banco se marca SOLO mientras esta abierto en un
-- banquero; nunca el banco de hermandad, el banco de cuenta, vistas guardadas ni otros personajes.
--   * Abierto/cerrado: BANKFRAME_OPENED / BANKFRAME_CLOSED y, si el cliente los tiene,
--     PLAYER_INTERACTION_MANAGER_FRAME_SHOW / _HIDE con Enum.PlayerInteractionType.Banker o
--     CharacterBanker (nunca AccountBanker ni GuildBanker). Se escuchan los dos caminos porque en
--     Forever algunos *_CLOSED no llegan (CONVENCION.md, MAIL_CLOSED). Fuentes leidas: Syndicator
--     Tracking/BagCache.lua l.58-59 y l.160-175, ElvUI Bags.lua l.3934-3935 y Baganator
--     ItemViewCommon/BankView.lua l.144-156 usan BANKFRAME_*; Inventorian Events.lua l.235-247 usa
--     PLAYER_INTERACTION_MANAGER_FRAME_* con Banker/CharacterBanker. Cualquier cierre gana; una
--     pantalla de carga (PLAYER_ENTERING_WORLD) tambien cierra.
--   * Bolsas del banco: Enum.BagIndex.CharacterBankTab_1..9 (Syndicator Core/Constants.lua l.56-66 y
--     ElvUI Bags.lua l.183-207: "Forever has a base bank plus eight bank bags"). Sin ese Enum no hay
--     bolsas de banco reconocidas (sin marca): no se adivinan numeros.
local Bank = {}
ns.Bank = Bank

local live = false
local callbacks = {}

local function bagIndex()
    local enum = rawget(_G, 'Enum')
    local index = type(enum) == 'table' and enum.BagIndex
    if type(index) == 'table' then return index end
end

-- true si `bag` es una bolsa del banco del personaje (pestana 1..9). Las bolsas portadas (0-4), la
-- de reactivos, el llavero y el banco de cuenta nunca lo son.
function Bank.IsBankBag(bag)
    if type(bag) ~= 'number' or (bag >= 0 and bag <= 4) then return false end
    local index = bagIndex()
    if not index then return false end
    for tab = 1, 9 do
        if index['CharacterBankTab_' .. tab] == bag then return true end
    end
    return false
end

-- true solo entre la apertura del banco en un banquero y su cierre.
function Bank.IsLive() return live end

-- fn(live) en cada cambio real de estado. Un callback que falla no frena a los demas.
function Bank.OnChanged(fn)
    if type(fn) == 'function' then callbacks[#callbacks + 1] = fn end
end

local function set(value)
    if live == value then return end
    live = value
    for _, fn in ipairs(callbacks) do pcall(fn, live) end
end

local function isBanker(kind)
    local enum = rawget(_G, 'Enum')
    local types = type(enum) == 'table' and enum.PlayerInteractionType
    if type(types) ~= 'table' or kind == nil then return false end
    return kind == types.Banker or kind == types.CharacterBanker
end

-- Solo para pruebas: cerrado y sin callbacks (los modulos se vuelven a suscribir en su ResetState).
function Bank.ResetState()
    live = false
    callbacks = {}
end

local frame = CreateFrame('Frame')
for _, event in ipairs({ 'BANKFRAME_OPENED', 'BANKFRAME_CLOSED', 'PLAYER_INTERACTION_MANAGER_FRAME_SHOW',
    'PLAYER_INTERACTION_MANAGER_FRAME_HIDE', 'PLAYER_ENTERING_WORLD' }) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript('OnEvent', function(_, event, kind)
    if event == 'BANKFRAME_OPENED' then set(true)
    elseif event == 'BANKFRAME_CLOSED' or event == 'PLAYER_ENTERING_WORLD' then set(false)
    elseif event == 'PLAYER_INTERACTION_MANAGER_FRAME_SHOW' then if isBanker(kind) then set(true) end
    elseif event == 'PLAYER_INTERACTION_MANAGER_FRAME_HIDE' then if isBanker(kind) then set(false) end
    end
end)
