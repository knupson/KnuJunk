local _, ns = ...

-- Bolsas de Blizzard. Solo hooksecurefunc: nunca se reemplaza ni se llama a funciones de Blizzard.
-- Forever convive con dos formas de dibujar bolsas y se soportan las dos, detectando cada una:
--   * clasica: la global ContainerFrame_Update(frame); botones ContainerFrameNItemM, bolsa = ID del frame.
--   * moderna: frame:UpdateItems() de ContainerFrame1..N y ContainerFrameCombinedBags; botones de
--     frame:EnumerateValidItems() (o frame.Items), bolsa = button:GetBagID().
-- El slot es siempre button:GetID(). Si ambas existieran, el doble pintado es idempotente.
local Blizzard = {}
ns.Blizzard = Blizzard

local OWNER = 'blizzard'
local MAX_CLASSIC_BUTTONS = 200
local hookedFrames = setmetatable({}, { __mode = 'k' })
local hookedGlobal = false

local function bagOf(button, frame)
    if type(button.GetBagID) == 'function' then return button:GetBagID() end
    if type(frame.GetID) == 'function' then return frame:GetID() end
end

local function paintButton(button, frame)
    if type(button) ~= 'table' then return end
    if type(button.IsShown) == 'function' and not button:IsShown() then return ns.Marks.Clear(button) end
    ns.Marks.Update(button, bagOf(button, frame), button:GetID(), OWNER)
end

local function eachButton(frame, fn)
    if type(frame.EnumerateValidItems) == 'function' then
        for _, button in frame:EnumerateValidItems() do fn(button) end
    elseif type(frame.Items) == 'table' then
        for _, button in ipairs(frame.Items) do fn(button) end
    else
        local name = type(frame.GetName) == 'function' and frame:GetName()
        if not name then return end
        for index = 1, MAX_CLASSIC_BUTTONS do
            local button = _G[name .. 'Item' .. index]
            if not button then break end
            fn(button)
        end
    end
end

-- Un error nuestro jamas debe romper el redibujado de Blizzard, ni un boton que falla frenar a los
-- demas: cada boton va aislado y, si falla, queda sin marca.
local function paintFrame(frame)
    if type(frame) ~= 'table' then return end
    pcall(eachButton, frame, function(button)
        if not pcall(paintButton, button, frame) then pcall(ns.Marks.Clear, button) end
    end)
end

local function knownFrames()
    local frames = {}
    if type(ContainerFrameCombinedBags) == 'table' then frames[#frames + 1] = ContainerFrameCombinedBags end
    for index = 1, NUM_CONTAINER_FRAMES or 13 do
        local frame = _G['ContainerFrame' .. index]
        if type(frame) == 'table' then frames[#frames + 1] = frame end
    end
    return frames
end

-- Engancha lo que exista y no este enganchado; true si hay algo enganchado. Idempotente.
function Blizzard.Hook()
    if not hookedGlobal and type(ContainerFrame_Update) == 'function' then
        hooksecurefunc('ContainerFrame_Update', paintFrame)
        hookedGlobal = true
    end
    local any = hookedGlobal
    for _, frame in ipairs(knownFrames()) do
        ns.Bags.DeclareLiveContainer(frame)   -- ventanas de bolsas de Blizzard: vivas, del personaje actual
        if hookedFrames[frame] then any = true
        elseif type(frame.UpdateItems) == 'function' then
            hooksecurefunc(frame, 'UpdateItems', paintFrame)
            hookedFrames[frame] = true
            any = true
        end
    end
    return any
end

-- Repinta los frames abiertos sin llamar a funciones de Blizzard; tambien engancha frames nacidos
-- despues de la instalacion.
function Blizzard.Refresh()
    Blizzard.Hook()
    for _, frame in ipairs(knownFrames()) do
        if type(frame.IsShown) ~= 'function' or frame:IsShown() then paintFrame(frame) end
    end
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Blizzard.ResetState()
    hookedFrames = setmetatable({}, { __mode = 'k' })
    hookedGlobal = false
end

ns.Bags.Register('Blizzard', { install = Blizzard.Hook, refresh = Blizzard.Refresh })
