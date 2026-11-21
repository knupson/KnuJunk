local _, ns = ...

-- Una marca configurable por ítem legible; datos pendientes, vistas guardadas y addon apagado no dibujan.
-- Sólo bolsas propias 0-4 y banco vivo con adaptador habilitado. Al cerrar el banco se limpia todo.
-- Siluetas propias en media/, martillo existente y moneda Blizzard opcional.
local Marks = {}
ns.Marks = Marks

local SIZE = 14
local COIN_ATLAS = 'bags-junkcoin'
Marks.COIN_ATLAS = COIN_ATLAS
local ROOT = 'Interface\\AddOns\\KnuJunk\\media\\'
local TEXTURES = { hammer = ROOT .. 'martillo' }
for _, kind in ipairs(ns.IconKinds) do
    TEXTURES[kind] = ROOT .. ((kind == 'hammer_mine' or kind == 'hammer_other') and 'martillo' or kind)
end
Marks.TEXTURES, Marks.TINTS = TEXTURES, ns.IconColors
function Marks.Color(mark)
    local colors = ns.DB and ns.DB.icons and ns.DB.icons.colors or ns.IconColors
    return colors[mark] or ns.IconColors[mark] or {1, 1, 1}
end

-- [boton] = { id = itemID, bag =, slot = | link =, owner = }: botones esperando datos del item.
local pending = setmetatable({}, { __mode = 'k' })
-- [boton] = { bag =, slot =, id = | link =, id =, owner = }: botones protegidos que, en combate, no
-- tenian aun nuestra textura: no se crea ahora; se retoma (revalidando todo) al salir del combate.
local queued = setmetatable({}, { __mode = 'k' })
-- [boton] = true: botones a los que se les pidio una bolsa del banco (se limpian al cerrarlo).
local bankButtons = setmetatable({}, { __mode = 'k' })

local function isBankBag(bag)
    local bank = ns.Bank
    return bank ~= nil and bank.IsBankBag(bag) == true
end

-- true si `bag` se puede marcar: bolsa 0-4, o bolsa del banco con el banco vivo (y, si se da
-- `owner`, un dueno que soporta banco).
local function allowedBag(bag, owner, checkOwner)
    if type(bag) ~= 'number' then return false end
    if bag >= 0 and bag <= 4 then return true end
    if not isBankBag(bag) or not ns.Bank.IsLive() then return false end
    if not checkOwner then return true end
    return ns.Bags ~= nil and type(ns.Bags.AllowsBank) == 'function' and ns.Bags.AllowsBank(owner) == true
end

local function itemIDOf(link)
    if type(link) == 'number' then return link end
    if type(link) == 'string' then return tonumber(link:match('item:(%d+)')) end
end

-- ID del item en un slot, aunque el cliente aun no tenga sus datos (GetItemInfo vacio).
local function slotItemID(bag, slot)
    if C_Container and type(C_Container.GetContainerItemInfo) == 'function' then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then return info.itemID or itemIDOf(info.hyperlink) end
        return nil
    end
    if type(GetContainerItemLink) == 'function' then return itemIDOf(GetContainerItemLink(bag, slot)) end
end

local function hide(button)
    local texture = button.KnuJunkMark
    if texture then texture:Hide() end
    if button.KnuJunkBackground then button.KnuJunkBackground:Hide() end
end

local function enabled()
    local db = ns.DB
    return type(db) == 'table' and db.enabled ~= false
end

local function shows(kind)
    local show = ns.DB and ns.DB.show
    if (kind == 'hammer_mine' or kind == 'hammer_other') and show and show.hammer == false then return false end
    return not (type(show) == 'table' and show[kind] == false)
end

local function background(parent, icon)
    local texture = parent:CreateTexture(nil, 'OVERLAY', nil, 6)
    texture:SetTexture(ROOT .. 'fondo')
    texture:SetAllPoints(icon)
    return texture
end

local function ensureTexture(button)
    local texture = button.KnuJunkMark
    if texture then return texture end
    texture = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    button.KnuJunkMark = texture
    button.KnuJunkBackground = background(button, texture)
    return texture
end

local function kindOf(mark)
    if TEXTURES[mark] and mark ~= 'hammer' then return mark end
end

local function style(texture, kind, mark)
    local settings = ns.DB and ns.DB.icons or ns.Defaults.icons
    local atlas = kind == 'coin' and settings.coinStyle ~= 'KnuJunk' and texture.SetAtlas
        and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(COIN_ATLAS) and COIN_ATLAS
    if atlas then texture:SetAtlas(atlas, false)
    else texture:SetTexture(kind == 'coin' and settings.coinStyle ~= 'KnuJunk'
        and 'Interface\\MoneyFrame\\UI-GoldIcon' or TEXTURES[kind]) end
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetSize(settings.size or SIZE, settings.size or SIZE)
    local color = Marks.Color(mark)
    texture:SetVertexColor(color[1], color[2], color[3])
    texture:SetAlpha(settings.opacity or 1)
    if texture.SetDesaturated then texture:SetDesaturated(false) end
end

local function paint(button, mark)
    local kind = kindOf(mark)
    if not kind or not shows(kind) then return hide(button) end
    local texture = ensureTexture(button)
    local settings = ns.DB and ns.DB.icons or ns.Defaults.icons
    local corner = settings.corner or 'TOPRIGHT'
    local left = corner == 'TOPLEFT' or corner == 'BOTTOMLEFT'
    local top = corner == 'TOPLEFT' or corner == 'TOPRIGHT'
    texture:ClearAllPoints()
    texture:SetPoint(corner, button, corner, left and 1 or -1, top and -1 or 1)
    style(texture, kind, mark)
    button.KnuJunkBackground:SetAlpha(settings.opacity or 1)
    button.KnuJunkBackground:SetShown(settings.background ~= false)
    texture:Show()
end

-- Resultado completo del clasificador (tabla) o nil si fallo.
local function classify(item)
    local success, result = pcall(function() return ns.Classify(item, ns.Player.GetContext()) end)
    if success and type(result) == 'table' then return result end
end

-- Misión activa tiene la misma prioridad en bolsas, banco y botín.
local function markOf(result, forLoot)
    if not result then return nil end
    if result.mark ~= 'protected' and result.quest == true then return 'quest' end
    local reasons = result.reasons
    if result.mark == 'useful' and result.doubt and type(reasons) == 'table' and reasons[1] and reasons[1].kind == 'no_rule' then
        return 'unruled'
    end
    return result.mark
end
Marks.MarkOf, Marks.markOf = markOf, markOf

-- Clave propia por botón para la cola de combate compartida de KnuLib (evita choques entre addons).
local function combatKey(button) return 'KnuJunk:Marks:' .. tostring(button) end

function Marks.Clear(button)
    if type(button) ~= 'table' then return end
    pending[button] = nil
    if queued[button] then ns.KL:CancelAfterCombat(combatKey(button)) end
    queued[button] = nil
    hide(button)
    if button.KnuJunkOwned then button.KnuJunkOwned:Hide() end
end

-- Cuántos tenés ya (bolsas y banco) de un ítem que no se apila; nil si se apila o no se sabe.
-- En lo que se apila (tela, hierbas) siempre tenés más y el número sería ruido.
function Marks.OwnedCount(link)
    if type(link) ~= 'string' then return nil end
    local id = tonumber(link:match('item:(%d+)'))
    if not id or type(ns.API.GetItemInfo) ~= 'function' or type(ns.API.GetItemCount) ~= 'function' then return nil end
    local ok, name, _, _, _, _, _, _, stack = pcall(ns.API.GetItemInfo, link)
    if not ok or not name or stack ~= 1 then return nil end
    local okBags, bags = pcall(ns.API.GetItemCount, id)
    local okAll, all = pcall(ns.API.GetItemCount, id, true)
    if not okBags or type(bags) ~= 'number' then return nil end
    if not okAll or type(all) ~= 'number' or all < bags then all = bags end
    return all, bags, all - bags
end

-- Botín: «xN» abajo a la izquierda si ya tenés ese ítem (pedido del dueño: saber si duplica).
function Marks.UpdateOwned(button, link)
    if type(button) ~= 'table' then return end
    local show = enabled() and not (ns.DB and type(ns.DB.show) == 'table' and ns.DB.show.owned == false)
    local count = show and Marks.OwnedCount(link)
    local text = button.KnuJunkOwned
    if not count or count <= 0 then
        if text then text:Hide() end
        return
    end
    if not text then
        if type(button.CreateFontString) ~= 'function' then return end
        text = button:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
        text:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 2, 2)
        button.KnuJunkOwned = text
    end
    text:SetText('x' .. count)
    text:SetTextColor(1, 210/255, 60/255)
    text:Show()
end

-- Cuerpo de Update: puede lanzar error (lecturas del cliente); el llamador lo aisla con pcall.
local function updateSlot(button, bag, slot, owner)
    if not enabled() or not allowedBag(bag, owner or 'generic', true) or type(slot) ~= 'number' then return end
    local id = slotItemID(bag, slot)
    if not id then return end -- slot vacio
    local item = ns.Player.ReadItem(bag, slot)
    if not item then
        pending[button] = { id = id, bag = bag, slot = slot, owner = owner }
        return
    end
    paint(button, markOf(classify(item), false), false)
end

local function updateLinkBody(button, link, owner)
    local id = itemIDOf(link)
    if not enabled() or not shows('loot') or not id then return end
    local item = ns.Player.ReadLink(link)
    if not item then
        pending[button] = { id = id, link = link, owner = owner }
        return
    end
    paint(button, markOf(classify(item), true), true)
end

-- Los botones se reciclan: la marca vieja se oculta ANTES de cualquier lectura, y si la lectura
-- falla el boton queda sin marca (una moneda falsa es el peor fallo).
local function safely(button, fn, ...)
    pending[button] = nil
    pcall(hide, button)
    if not pcall(fn, button, ...) then
        pending[button] = nil
        pcall(hide, button)
    end
end

-- En combate no se toca un boton protegido ajeno que aun no tiene nuestra textura (crearla y
-- anclarla seria una operacion sobre un frame protegido): se difiere hasta salir del combate.
-- Actualizar una textura nuestra ya creada si se permite. Un IsProtected que falla cuenta como
-- protegido (ante la duda, no se toca).
local function mustDefer(button)
    if button.KnuJunkMark then return false end
    if type(InCombatLockdown) ~= 'function' or not InCombatLockdown() then return false end
    if type(button.IsProtected) ~= 'function' then return false end
    local success, isProtected = pcall(button.IsProtected, button)
    return not success or (isProtected and true or false)
end

local resume -- definida más abajo; defer la usa al salir del combate

local function defer(button, entry)
    pending[button] = nil
    queued[button] = nil
    if entry.link then
        entry.id = itemIDOf(entry.link)
    else
        local success, id = pcall(slotItemID, entry.bag, entry.slot)
        entry.id = success and id or nil
    end
    if not entry.id then return end
    queued[button] = entry
    -- Al salir del combate se retoma lo diferido (KnuLib minor 5). La función lee queued en ese
    -- momento: si el botón se limpió o se reinició el módulo, no hace nada.
    ns.KL:AfterCombat(function()
        local waiting = queued[button]
        if not waiting then return end
        queued[button] = nil
        pcall(resume, button, waiting)
    end, combatKey(button))
end

-- Marca el item de bolsa `bag`/`slot` (bolsas 0-4, o el banco vivo si `owner` lo soporta) en
-- `button`, incluida misión activa.
function Marks.Update(button, bag, slot, owner)
    if type(button) ~= 'table' then return end
    button.KnuJunkOwner = owner or 'generic'
    bankButtons[button] = isBankBag(bag) or nil
    if mustDefer(button) then return defer(button, { bag = bag, slot = slot, owner = owner }) end
    safely(button, updateSlot, bag, slot, owner)
end

-- Marca un item por enlace (ventana de botin). Aqui si se dibuja 'quest'.
function Marks.UpdateLink(button, link, owner)
    if type(button) ~= 'table' then return end
    button.KnuJunkOwner = owner or 'generic'
    if mustDefer(button) then return defer(button, { link = link, owner = owner }) end
    safely(button, updateLinkBody, link, owner)
end

-- Para adaptadores que dibujan por su cuenta: veredicto del slot de bolsa `bag`/`slot` (0-4, o el
-- banco vivo: el que llama tiene que haber probado que su vista es la viva). Devuelve la marca ('coin', 'hammer_mine' o 'hammer_other') si hay que mostrarla,
-- nil si no; el 2.o valor es true cuando el cliente aun no tiene los datos del item (reintentar con
-- GET_ITEM_INFO_RECEIVED). Con marca, el 3.o valor es el resultado completo del clasificador (motivos)
-- y el 4.o el item leido (calidad, precio). Si expectedID viene, el slot tiene que contener ese item.
-- Nunca lanza.
function Marks.Verdict(bag, slot, expectedID)
    local success, mark, waiting, result, info = pcall(function()
        if not enabled() or not allowedBag(bag) or type(slot) ~= 'number' then return nil end
        local id = slotItemID(bag, slot)
        if not id or (expectedID ~= nil and id ~= expectedID) then return nil end
        local item = ns.Player.ReadItem(bag, slot)
        if not item then return nil, true end
        local result = classify(item)
        local found = markOf(result, false)
        local kind = kindOf(found, false)
        if kind and shows(kind) then return found, false, result, item end
    end)
    if success then return mark, waiting == true, mark and result or nil, mark and info or nil end
    return nil, false
end

-- true si `bag` se puede marcar ahora: 0-4, o del banco con el banco vivo. Para revalidadores (que
-- ademas son de un adaptador con bank = true).
function Marks.AllowedBag(bag) return allowedBag(bag) end

-- ID del item vivo en el slot `bag`/`slot`, o nil (vacio o error). Para revalidadores.
function Marks.SlotItemID(bag, slot)
    local success, id = pcall(slotItemID, bag, slot)
    if success then return id end
end

-- Pinta `texture` (de una esquina ajena) con la marca; false si la marca no es dibujable.
function Marks.Style(widget, mark)
    local kind = kindOf(mark)
    if not kind or not shows(kind) then return false end
    return pcall(function()
        local texture = widget.Icon or widget
        style(texture, kind, mark)
        if widget.Icon then
            local settings = ns.DB and ns.DB.icons or ns.Defaults.icons
            widget:SetSize(settings.size or SIZE, settings.size or SIZE)
            widget.Background:SetAlpha(settings.opacity or 1)
            widget.Background:SetShown(settings.background ~= false)
        end
    end)
end

function Marks.CreateWidget(button)
    local widget = CreateFrame('Frame', nil, button)
    widget:SetSize(SIZE, SIZE)
    widget.Icon = widget:CreateTexture(nil, 'OVERLAY', nil, 7)
    widget.Icon:SetAllPoints(widget)
    widget.Background = background(widget, widget.Icon)
    widget.padding = 0
    return widget
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Marks.ResetState()
    pending = setmetatable({}, { __mode = 'k' })
    queued = setmetatable({}, { __mode = 'k' })
    bankButtons = setmetatable({}, { __mode = 'k' })
    Marks.ConnectBank()
end

-- Al cerrarse el banco: fuera toda marca, espera o diferido de un boton que mostro el banco. (Un boton
-- reciclado a la bolsa se vuelve a marcar en el repintado que pide Registry.)
local function onBankChanged(live)
    if live then return end
    local list = {}
    for button in pairs(bankButtons) do list[#list + 1] = button end
    bankButtons = setmetatable({}, { __mode = 'k' })
    for _, button in ipairs(list) do pcall(Marks.Clear, button) end
end

function Marks.ConnectBank()
    if ns.Bank and ns.Bank.OnChanged then ns.Bank.OnChanged(onBankChanged) end
end
Marks.ConnectBank()

-- Retoma lo que quedo esperando (datos del item o fin del combate) SIN confiar en lo guardado:
-- el slot tiene que seguir teniendo el item que se esperaba y, si el adaptador del dueno sabe
-- revalidar (spec.revalidate(boton) -> bag, slot, itemID mostrado), su vista tiene que seguir
-- siendo una casilla viva con ese mismo item. Si algo no coincide: sin marca.
function resume(button, entry)
    if entry.link then
        -- Por enlace: si el dueno sabe revalidar, spec.revalidate(boton) devuelve el enlace que el
        -- boton muestra AHORA (la fila de botin pudo reciclarse a otro item mientras esperaba datos);
        -- tiene que ser el mismo item que se esperaba, y se marca con el enlace actual.
        local revalidate = ns.Bags and ns.Bags.Revalidator and ns.Bags.Revalidator(entry.owner or 'generic')
        if revalidate then
            local success, current = pcall(revalidate, button)
            if not success or itemIDOf(current) ~= entry.id then return Marks.Clear(button) end
            return Marks.UpdateLink(button, current, entry.owner)
        end
        return Marks.UpdateLink(button, entry.link, entry.owner)
    end
    local bag, slot = entry.bag, entry.slot
    local revalidate = ns.Bags and ns.Bags.Revalidator and ns.Bags.Revalidator(entry.owner or 'generic')
    if revalidate then
        local success, b, s, shown = pcall(revalidate, button)
        if not success or type(b) ~= 'number' or type(s) ~= 'number' or shown ~= entry.id then return Marks.Clear(button) end
        bag, slot = b, s
    end
    local success, live = pcall(slotItemID, bag, slot)
    if not success or live ~= entry.id then return Marks.Clear(button) end
    Marks.Update(button, bag, slot, entry.owner)
end

-- Los datos del item llegaron: se vuelve a marcar solo lo que esperaba ESE item. Si el cliente
-- dice que no existe (success == false) se olvida la espera. Al salir del combate se retoma lo
-- diferido.
local frame = CreateFrame('Frame')
pcall(frame.RegisterEvent, frame, 'GET_ITEM_INFO_RECEIVED')
frame:SetScript('OnEvent', function(_, event, itemID, success)
    local ready = {}
    for button, entry in pairs(pending) do
        if entry.id == itemID then ready[#ready + 1] = { button = button, entry = entry } end
    end
    for _, job in ipairs(ready) do
        pending[job.button] = nil
        if success ~= false then pcall(resume, job.button, job.entry) end
    end
end)
