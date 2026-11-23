local _, ns = ...

-- Banco vivo del personaje actual, fuente unica de verdad: se marca solo mientras esta abierto en un banquero, nunca el de hermandad, el de cuenta ni vistas guardadas.
-- Abierto/cerrado por BANKFRAME_* y PLAYER_INTERACTION_MANAGER_FRAME_* (Banker/CharacterBanker), porque en Forever algunos *_CLOSED no llegan; las bolsas salen de Enum.BagIndex.CharacterBankTab_1..9, sin adivinar numeros.
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
