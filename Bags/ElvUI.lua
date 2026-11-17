local _, ns = ...

-- ElvUI por su hook de actualizacion: hooksecurefunc(ElvUI[1].Bags, 'UpdateSlot', ...).
-- Contrato VERIFICADO contra el ElvUI v16.01 instalado (Game/Shared/Modules/Bags/Bags.lua):
--   * General/Initialize.lua l.78: E.Bags = E:NewModule('Bags'); ElvUI = { E, L, V, P, G }.
--   * l.3805-3864: B.Initialized = true solo cuando E.private.bags.enable; con las bolsas apagadas
--     (el caso del usuario) Initialize retorna antes: install devuelve false y no se engancha nada.
--   * l.703-711: B:UpdateSlot(frame, bagID, slotID) trabaja sobre frame.Bags[bagID][slotID], lee el
--     item vivo (C_Container) y fija slot.itemID y slot.itemLink: identidad EXPUESTA del item dibujado.
--   * l.2448-2466 y l.3862-3866: B.BagFrame = ConstructContainerFrame('ElvUI_ContainerFrame') y
--     B.BankFrame = ... ('ElvUI_BankContainerFrame', true); frame.isBank, frame.Bags.
--   * l.2798-2800: cada slot guarda slot.bagFrame, slot.BagID y slot.SlotID (su GetBagID se evita
--     a proposito por taint).
-- ElvUI no tiene vista de otros personajes; el banco es B.BankFrame (isBank) y se descarta ademas de
-- la regla 0-4 de Marks. Solo cuenta la ventana B.BagFrame. Sin marca si el item que dice el slot
-- no es el vivo. Referencia leida (competencia/): magic-eraser Tint-Junk.lua l.434-448.
local OWNER = 'ElvUI'
local Adapter = {}
ns.ElvUIAdapter = Adapter

local Common = ns.Bags.Common
local tracker = Common.NewTracker(OWNER)
local hooked = false
local retried = false

local function bagsModule()
    local elv = rawget(_G, 'ElvUI')
    local engine = type(elv) == 'table' and elv[1]
    local bags = type(engine) == 'table' and engine.Bags
    if type(bags) == 'table' then return bags end
end

local function locate(button)
    if type(button) ~= 'table' then return nil end
    local bags = bagsModule()
    local frame = button.bagFrame
    if not bags or type(frame) ~= 'table' or frame ~= bags.BagFrame or frame.isBank then return nil end
    if Common.NonCarried(button) then return nil end
    return button.BagID, button.SlotID
end

local reader = Common.ExposedReader(locate)

local function revalidate(button) return tracker:Read(button) end

-- Firma real al llamar B:UpdateSlot(frame, bagID, slotID): el hook recibe (B, frame, bagID, slotID).
local function onSlot(_, frame, bagID, slotID)
    pcall(function()
        local bags = bagsModule()
        if not bags or type(frame) ~= 'table' or frame ~= bags.BagFrame or frame.isBank then return end
        local bag = type(frame.Bags) == 'table' and frame.Bags[bagID]
        local button = type(bag) == 'table' and bag[slotID]
        if type(button) ~= 'table' then return end
        local buttonBag, buttonSlot = locate(button)
        if buttonBag ~= bagID or buttonSlot ~= slotID then return tracker:Release(button) end
        tracker:Apply(button, reader)
    end)
end

-- true cuando el hook esta puesto (idempotente). false si ElvUI no esta, sus bolsas estan apagadas
-- (Initialized ausente) o UpdateSlot no existe.
function Adapter.Install()
    if hooked then return true end
    local bags = bagsModule()
    if not bags or not bags.Initialized or type(bags.UpdateSlot) ~= 'function' then return false end
    hooked = pcall(hooksecurefunc, bags, 'UpdateSlot', onSlot)
    return hooked
end

function Adapter.Refresh() tracker:Refresh() end

function Adapter.ResetState() hooked, retried = false, false end
Common.OnReset(Adapter.ResetState)

-- ElvUI inicializa sus modulos (E:OnEnable de AceAddon) en PLAYER_LOGIN y puede hacerlo DESPUES de
-- nuestro PLAYER_LOGIN: un unico reintento en el primer PLAYER_ENTERING_WORLD.
local frame = CreateFrame('Frame')
pcall(frame.RegisterEvent, frame, 'PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function()
    if retried then return end
    retried = true
    if not hooked and ns.Bags.InstallAll then pcall(ns.Bags.InstallAll) end
end)

ns.Bags.Register('ElvUI', { addon = 'ElvUI', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate })
