local _, ns = ...

-- ElvUI por su hook de actualizacion: hooksecurefunc(ElvUI[1].Bags, 'UpdateSlot', ...). Contrato leido en ElvUI v16.01 (Game/Shared/Modules/Bags/Bags.lua).
-- Solo con las bolsas de ElvUI activas (B.Initialized); identidad = slot.itemID y slot.itemLink. Cuentan B.BagFrame y, con el banco vivo (ns.Bank), B.BankFrame; sin vista de otros personajes.
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

-- 'bag' para B.BagFrame, 'bank' para B.BankFrame con el banco vivo; nil para cualquier otro frame.
local function windowKind(bags, frame)
    if not bags or type(frame) ~= 'table' then return nil end
    if frame == bags.BagFrame and not frame.isBank then return 'bag' end
    if frame == bags.BankFrame and frame.isBank and ns.Bank.IsLive() then return 'bank' end
end

local function locate(button)
    if type(button) ~= 'table' then return nil end
    local kind = windowKind(bagsModule(), button.bagFrame)
    if not kind then return nil end
    if Common.NonCarried(button, kind == 'bank') then return nil end
    if kind == 'bank' and not ns.Bank.IsBankBag(button.BagID) then return nil end
    return button.BagID, button.SlotID
end

local reader = Common.ExposedReader(locate)

local function revalidate(button) return tracker:Read(button) end

-- Firma real al llamar B:UpdateSlot(frame, bagID, slotID): el hook recibe (B, frame, bagID, slotID).
local function onSlot(_, frame, bagID, slotID)
    pcall(function()
        if not windowKind(bagsModule(), frame) then return end
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

-- ElvUI inicializa sus modulos (E:OnEnable de AceAddon) en PLAYER_LOGIN y puede hacerlo despues de
-- nuestro PLAYER_LOGIN: un unico reintento en el primer PLAYER_ENTERING_WORLD.
local frame = CreateFrame('Frame')
pcall(frame.RegisterEvent, frame, 'PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function()
    if retried then return end
    retried = true
    if not hooked and ns.Bags.InstallAll then pcall(ns.Bags.InstallAll) end
end)

ns.Bags.Register('ElvUI', { addon = 'ElvUI', install = Adapter.Install, refresh = Adapter.Refresh,
    revalidate = revalidate, bank = true })
