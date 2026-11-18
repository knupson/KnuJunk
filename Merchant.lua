local _, ns = ...
local Merchant = {}
ns.Merchant = Merchant

local opened, syncing = false, false
local locked, allowed = {}, {}
local buttons = setmetatable({}, { __mode = 'k' })
local hoveredShield, hoveredButton, hoveredBag, hoveredSlot

-- Toda API del cliente queda aislada; false explícito también indica fallo.
local function call(fn, ...)
    if type(fn) ~= 'function' then return false end
    local success, value = pcall(fn, ...)
    return success and value ~= false, value
end

local function combat()
    if type(InCombatLockdown) ~= 'function' then return false end
    local success, value = pcall(InCombatLockdown)
    return not success or value == true
end

local function enabled()
    return ns.DB and ns.DB.enabled ~= false and ns.DB.protectKeep ~= false
end

local function apiReady()
    return type(C_Item) == 'table' and type(C_Item.LockItemByGUID) == 'function'
        and type(C_Item.UnlockItemByGUID) == 'function' and type(C_Item.GetItemGUID) == 'function'
        and ItemLocation and type(ItemLocation.CreateFromBagAndSlot) == 'function'
end

local function container(name)
    return (C_Container and C_Container[name]) or _G[name]
end

local function location(bag, slot)
    if type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then return end
    if not apiReady() then return end
    local success, loc = call(ItemLocation.CreateFromBagAndSlot, ItemLocation, bag, slot)
    if success then return loc end
end

local function guidAt(bag, slot)
    local loc = location(bag, slot)
    if not loc then return end
    local success, guid = call(C_Item.GetItemGUID, loc)
    if success then return guid, loc end
end

local function keepAt(bag, slot)
    local success, id = call(container('GetContainerItemID'), bag, slot)
    return success and id and ns.DB and ns.DB.overrides and ns.DB.overrides[id] == 'keep'
end

local function unlock(guid)
    if not locked[guid] then return false end
    -- Retirar antes de la API: puede disparar eventos sincrónicos de bolsa.
    locked[guid] = nil
    if call(C_Item and C_Item.UnlockItemByGUID, guid) then
        return true
    end
    locked[guid] = true
    return false -- conservamos la propiedad para reintentar si falla el cliente
end

local frame = CreateFrame('Frame')
local function shieldsAvailable()
    return type(frame.SetPassThroughButtons) == 'function'
end

function Merchant.ProtectionText(bag, slot)
    if not opened or not enabled() then return end
    local guid = guidAt(bag, slot)
    if guid and locked[guid] then
        return shieldsAvailable() and 'Protected: right-click to sell' or 'Protected while the merchant is open'
    end
end

local function hide(button)
    local shield = button.KnuJunkShield
    if shield then call(shield.Hide, shield) end
end

local function accept(_, data)
    if not data or data.used or not opened or not enabled() or combat() then return end
    if guidAt(data.bag, data.slot) ~= data.guid or not keepAt(data.bag, data.slot) then return end
    local use = container('UseContainerItem')
    if type(use) ~= 'function' or not locked[data.guid] then return end
    data.used = true
    -- Permiso antes de desbloquear: los eventos de bolsa pueden llegar durante la llamada.
    allowed[data.guid] = true
    if not unlock(data.guid) then allowed[data.guid] = nil; return end
    if not call(use, data.bag, data.slot) then allowed[data.guid] = nil end
    Merchant.Sync()
end

local function popup(bag, slot)
    if not opened or not enabled() or combat() or not keepAt(bag, slot) then return end
    local guid = guidAt(bag, slot)
    if not guid or not locked[guid] then return end
    local success, link = call(container('GetContainerItemLink'), bag, slot)
    if not success or type(link) ~= 'string' then return end
    if type(StaticPopupDialogs) ~= 'table' then return end
    if not StaticPopupDialogs.KNUJUNK_CONFIRM_SELL then
        StaticPopupDialogs.KNUJUNK_CONFIRM_SELL = {
            text = ns.L['%s is protected. Sell it anyway?'],
            button1 = YES or ns.L['Yes'], button2 = NO or ns.L['No'],
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
            OnAccept = accept,
        }
    end
    call(StaticPopup_Show, 'KNUJUNK_CONFIRM_SELL', link, nil, { bag = bag, slot = slot, guid = guid })
end

-- Escudo compartido para bolsas que solo usan Verdict (por ejemplo Baganator).
function Merchant.HideHoveredShield()
    if hoveredShield then call(hoveredShield.Hide, hoveredShield) end
    hoveredButton, hoveredBag, hoveredSlot = nil, nil, nil
end

function Merchant.ShowHoveredShield(bag, slot)
    local function reject() Merchant.HideHoveredShield() end
    if not opened or not enabled() or combat() or not shieldsAvailable() then return reject() end
    if type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then return reject() end
    local guid = guidAt(bag, slot)
    if not guid or not locked[guid] or not keepAt(bag, slot) then return reject() end
    local success, focus
    if type(GetMouseFoci) == 'function' then
        local foci
        success, foci = call(GetMouseFoci)
        if success and type(foci) == 'table' then focus = foci[1] end
    end
    if not focus and type(GetMouseFocus) == 'function' then
        success, focus = call(GetMouseFocus)
        if not success then focus = nil end
    end
    -- Al reentrar por Show/OnEnter el foco puede ser nuestro propio escudo.
    if hoveredShield and focus == hoveredShield then focus = hoveredShield.target end
    if type(focus) ~= 'table' or focus == rawget(_G, 'GameTooltip') then return reject() end
    local gotLevel, level = call(focus.GetFrameLevel, focus)
    if not gotLevel or type(level) ~= 'number' then return reject() end
    if focus == hoveredButton and bag == hoveredBag and slot == hoveredSlot
        and hoveredShield and hoveredShield:IsShown() then return hoveredShield end
    Merchant.HideHoveredShield()
    if not hoveredShield then
        local created, shield = call(CreateFrame, 'Frame', nil, UIParent)
        if not created or not shield then return end
        call(shield.Hide, shield)
        if not call(shield.SetPassThroughButtons, shield, 'LeftButton') then return end
        hoveredShield = shield
        call(shield.EnableMouse, shield, true)
        shield:SetScript('OnMouseUp', function(_, mouse)
            if mouse == 'RightButton' and hoveredButton then pcall(popup, hoveredBag, hoveredSlot) end
        end)
        shield:SetScript('OnEnter', function()
            local button = hoveredButton
            if button then
                local got, fn = call(button.GetScript, button, 'OnEnter')
                if got then call(fn, button) end
            end
        end)
        shield:SetScript('OnLeave', function()
            local button = hoveredButton
            if button then
                local got, fn = call(button.GetScript, button, 'OnLeave')
                if got then call(fn, button) end
            end
            Merchant.HideHoveredShield()
        end)
    end
    call(hoveredShield.ClearAllPoints, hoveredShield)
    if not call(hoveredShield.SetParent, hoveredShield, focus)
        or not call(hoveredShield.SetAllPoints, hoveredShield, focus)
        or not call(hoveredShield.SetFrameLevel, hoveredShield, level + 1) then return end
    hoveredButton, hoveredBag, hoveredSlot = focus, bag, slot
    hoveredShield.target = focus
    call(hoveredShield.Show, hoveredShield)
    return hoveredShield
end

local function updateShield(button, entry)
    hide(button)
    if not opened or not enabled() or combat() or not shieldsAvailable() then return end
    local bag, slot = entry.bag, entry.slot
    if type(bag) ~= 'number' or bag < 0 or bag > 4 or not keepAt(bag, slot) then return end
    local guid = guidAt(bag, slot)
    if not guid or not locked[guid] then return end
    local shield = button.KnuJunkShield
    if not shield then
        local success
        success, shield = call(CreateFrame, 'Frame', nil, button)
        if not success or not shield then return end
        call(shield.Hide, shield)
        if not call(shield.SetPassThroughButtons, shield, 'LeftButton') then return end
        if not call(shield.SetAllPoints, shield, button) then return end
        local levelOK, level = call(button.GetFrameLevel, button)
        if not levelOK or type(level) ~= 'number' then return end
        if not call(shield.SetFrameLevel, shield, level + 1) then return end
        call(shield.EnableMouse, shield, true)
        shield:SetScript('OnMouseUp', function(_, mouse)
            local current = buttons[button]
            if mouse == 'RightButton' and current then pcall(popup, current.bag, current.slot) end
        end)
        for _, script in ipairs({ 'OnEnter', 'OnLeave' }) do
            local event = script
            shield:SetScript(event, function()
                local success, fn = call(button.GetScript, button, event)
                if success then call(fn, button) end
            end)
        end
        button.KnuJunkShield = shield
    end
    call(shield.Show, shield)
end

local function syncBody()
    -- Cualquier cambio puede reciclar el boton/slot o retirar el bloqueo.
    Merchant.HideHoveredShield()
    if not opened or not enabled() then
        for guid in pairs(locked) do unlock(guid) end
    elseif not combat() and apiReady() then
        local wanted = {}
        local complete = true
        for bag = 0, 4 do
            local success, slots = call(container('GetContainerNumSlots'), bag)
            if not success or type(slots) ~= 'number' then complete = false else
                for slot = 1, slots do
                    local readOK, id = call(container('GetContainerItemID'), bag, slot)
                    local guid, loc = guidAt(bag, slot)
                    if not readOK or (id and not guid) then complete = false end
                    if guid and id and ns.DB.overrides[id] == 'keep' and not allowed[guid] then
                        wanted[guid] = true
                        if not locked[guid] then
                            -- Si se puede consultar, jamás nos apropiamos de un bloqueo ajeno.
                            local free = true
                            if type(C_Item.IsLocked) == 'function' then
                                local success, busy = pcall(C_Item.IsLocked, loc)
                                free = success and not busy
                            end
                            if free and call(C_Item.LockItemByGUID, guid) then locked[guid] = true end
                        end
                    end
                end
            end
        end
        -- Un escaneo incompleto no autoriza a liberar protecciones existentes.
        if complete then
            for guid in pairs(locked) do if not wanted[guid] then unlock(guid) end end
        end
    end
    for button, entry in pairs(buttons) do pcall(updateShield, button, entry) end
end

function Merchant.Sync()
    if syncing then return end
    syncing = true
    pcall(syncBody)
    syncing = false
end

-- Un solo punto para todos los adaptadores, sin alterar su pintado ni propagar errores nuevos.
local update, clear, updateLink = ns.Marks.Update, ns.Marks.Clear, ns.Marks.UpdateLink
ns.Marks.Update = function(button, bag, slot, owner)
    update(button, bag, slot, owner)
    if type(button) ~= 'table' then return end
    local entry = { bag = bag, slot = slot, owner = owner }
    buttons[button] = entry
    pcall(updateShield, button, entry)
end
ns.Marks.Clear = function(button)
    clear(button)
    if type(button) ~= 'table' then return end
    buttons[button] = nil
    pcall(hide, button)
end
ns.Marks.UpdateLink = function(button, ...)
    if type(button) == 'table' then buttons[button] = nil; pcall(hide, button) end
    return updateLink(button, ...)
end

for _, event in ipairs({ 'MERCHANT_SHOW', 'MERCHANT_CLOSED', 'PLAYER_LEAVING_WORLD',
    'BAG_UPDATE_DELAYED', 'PLAYER_REGEN_ENABLED', 'PLAYER_REGEN_DISABLED' }) do
    call(frame.RegisterEvent, frame, event)
end
frame:SetScript('OnEvent', function(_, event)
    if event == 'MERCHANT_SHOW' then opened = true
    elseif event == 'MERCHANT_CLOSED' or event == 'PLAYER_LEAVING_WORLD' then
        opened = false
        allowed = {}
    end
    Merchant.Sync()
    if opened and not combat() and ns.Bags then call(ns.Bags.RefreshAll) end
end)

-- Solo pruebas: restaura el estado del módulo entre clientes simulados.
function Merchant.ResetState()
    opened, syncing = false, false
    Merchant.HideHoveredShield()
    for button in pairs(buttons) do pcall(hide, button) end
    locked, allowed = {}, {}
    buttons = setmetatable({}, { __mode = 'k' })
end
