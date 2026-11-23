local _, ns = ...

-- Bolsas de Blizzard: solo hooksecurefunc, nunca se reemplaza ni se llama a funciones de Blizzard. Se soportan las dos formas de dibujar de Forever: ContainerFrame_Update (clasica) y frame:UpdateItems() (moderna).
-- Panel del banco: se engancha Refresh de BankPanelItemButtonMixin y CamelotBankPanelItemButtonMixin (el que exista); forma tomada de otros addons, sin copia local del codigo de Blizzard.
local Blizzard = {}
ns.Blizzard = Blizzard

local OWNER = 'blizzard'
local MAX_CLASSIC_BUTTONS = 200
local hookedFrames = setmetatable({}, { __mode = 'k' })
local hookedGlobal = false
local hookedMixins = {}
local BANK_MIXINS = { 'BankPanelItemButtonMixin', 'CamelotBankPanelItemButtonMixin' }

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

-- Boton del panel del banco: bolsa y slot de sus propios metodos (nil si no los tiene).
local function bankSlotOf(button)
    if type(button.GetBankTabID) ~= 'function' or type(button.GetContainerSlotID) ~= 'function' then return nil end
    return button:GetBankTabID(), button:GetContainerSlotID()
end

local function paintBankButton(button)
    if type(button) ~= 'table' then return end
    if not pcall(function()
        if type(button.IsShown) == 'function' and not button:IsShown() then return ns.Marks.Clear(button) end
        local bag, slot = bankSlotOf(button)
        ns.Marks.Update(button, bag, slot, OWNER)
    end) then
        pcall(ns.Marks.Clear, button)
    end
end

local function bankPanel()
    local panel = rawget(_G, 'BankPanel')
    if type(panel) ~= 'table' then
        local frame = rawget(_G, 'BankFrame')
        panel = type(frame) == 'table' and frame.BankPanel or nil
    end
    if type(panel) == 'table' then return panel end
end

-- Recorre los botones activos del panel del banco (solo con el banco vivo y el panel visible).
-- El enumerador del pool da (boton, true); el de los contenedores (indice, boton): se aceptan ambos.
local function paintBankPanel()
    if not (ns.Bank and ns.Bank.IsLive()) then return end
    local panel = bankPanel()
    if not panel or type(panel.EnumerateValidItems) ~= 'function' then return end
    if type(panel.IsShown) == 'function' and not panel:IsShown() then return end
    pcall(function()
        for first, second in panel:EnumerateValidItems() do
            paintBankButton(type(first) == 'table' and first or second)
        end
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
    for _, name in ipairs(BANK_MIXINS) do
        local mixin = rawget(_G, name)
        if hookedMixins[name] == mixin and mixin ~= nil then any = true
        elseif type(mixin) == 'table' and type(mixin.Refresh) == 'function' then
            hooksecurefunc(mixin, 'Refresh', paintBankButton)
            hookedMixins[name] = mixin
            any = true
        end
    end
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
    paintBankPanel()
end

-- Al retomar una marca pendiente el boton pudo reciclarse: se relee lo que muestra ahora, que debe ser una bolsa 0-4 o del banco vivo (Marks.AllowedBag). Ante la duda, nil (sin marca).
local function revalidate(button)
    if type(button) ~= 'table' then return nil end
    if type(button.IsVisible) == 'function' then
        if not button:IsVisible() then return nil end
    elseif type(button.IsShown) == 'function' and not button:IsShown() then
        return nil
    end
    local bag, slot = bankSlotOf(button)
    if bag == nil then
        local frame = type(button.GetParent) == 'function' and button:GetParent() or nil
        if type(button.GetBagID) ~= 'function' and type(frame) ~= 'table' then return nil end
        bag = bagOf(button, frame or {})
        slot = type(button.GetID) == 'function' and button:GetID() or nil
    end
    if not ns.Marks.AllowedBag(bag) or type(slot) ~= 'number' then return nil end
    return bag, slot, ns.Marks.SlotItemID(bag, slot)
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Blizzard.ResetState()
    hookedFrames = setmetatable({}, { __mode = 'k' })
    hookedGlobal = false
    hookedMixins = {}
end

ns.Bags.Register('Blizzard', { install = Blizzard.Hook, refresh = Blizzard.Refresh,
    revalidate = revalidate, owner = OWNER, bank = true })
