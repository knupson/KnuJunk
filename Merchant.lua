local _, ns = ...
local Merchant = {}
ns.Merchant = Merchant

local opened, syncing = false, false
local locked, allowed = {}, {}
function Merchant.IsLocked(guid) return locked[guid] == true end
local buttons = setmetatable({}, { __mode = 'k' })

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

function Merchant.ProtectionText(bag, slot)
    if not opened or not enabled() then return end
    local guid = guidAt(bag, slot)
    if guid and locked[guid] then
        return 'Protected: right-click to sell'
    end
end

-- Ya no hay escudos: queda por compatibilidad con los envoltorios de Marks.
local function hide() end

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

-- Confirmación por clic derecho SIN capas encima del botón. Una capa que toma el mouse hace que la
-- bolsa reciba OnLeave y esconda el tooltip; con Baganator eso armó un ciclo de parpadeo en el juego
-- y el clic derecho nunca llegaba. Ahora enganchamos (HookScript, post-hook: no reemplaza nada) el
-- OnClick del propio botón: el botón intenta usar el ítem trabado (el juego no lo vende) y después
-- nuestro gancho pregunta «¿Lo vendés igual?».
local slotOf = setmetatable({}, { __mode = 'k' })   -- botón -> { bag =, slot = } visto por última vez
local hooked = setmetatable({}, { __mode = 'k' })

local function onClick(button, mouse)
    if mouse ~= 'RightButton' then return end
    local entry = slotOf[button] or buttons[button]
    if not entry or not opened or not enabled() or combat() then return end
    local guid = guidAt(entry.bag, entry.slot)
    if guid and locked[guid] then pcall(popup, entry.bag, entry.slot) end
end

local function watch(button, bag, slot)
    if type(button) ~= 'table' or type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then return end
    slotOf[button] = { bag = bag, slot = slot }
    if hooked[button] or combat() or type(button.HookScript) ~= 'function' then return end
    if call(button.HookScript, button, 'OnClick', onClick) then hooked[button] = true end
end

local function mouseFocus()
    local focus
    if type(GetMouseFoci) == 'function' then
        local ok, foci = call(GetMouseFoci)
        if ok and type(foci) == 'table' then focus = foci[1] end
    end
    if not focus and type(GetMouseFocus) == 'function' then
        local ok, value = call(GetMouseFocus)
        if ok then focus = value end
    end
    if type(focus) == 'table' and focus ~= rawget(_G, 'GameTooltip') then return focus end
end

-- Compatibilidad de nombres: Tooltip.lua llama a esto al decorar un ítem de bolsa.
function Merchant.HideHoveredShield() end
function Merchant.ShowHoveredShield(bag, slot)
    if not opened or not enabled() or combat() then return end
    local guid = guidAt(bag, slot)
    if not guid or not locked[guid] then return end
    local focus = mouseFocus()
    if focus then watch(focus, bag, slot) end
    return focus
end

local function updateShield(button, entry)
    if type(entry) == 'table' then watch(button, entry.bag, entry.slot) end
end

local function syncBody()
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
    -- Repintar sólo al abrir/cerrar: refrescar en cada BAG_UPDATE_DELAYED hace que Baganator
    -- esconda y vuelva a mostrar el tooltip del ítem bajo el mouse.
    if (event == 'MERCHANT_SHOW' or event == 'MERCHANT_CLOSED') and not combat() and ns.Bags then call(ns.Bags.RefreshAll) end
end)

-- Solo pruebas: restaura el estado del módulo entre clientes simulados.
function Merchant.ResetState()
    opened, syncing = false, false
    Merchant.HideHoveredShield()
    for button in pairs(buttons) do pcall(hide, button) end
    locked, allowed = {}, {}
    buttons = setmetatable({}, { __mode = 'k' })
end
