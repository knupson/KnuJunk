local _, ns = ...

-- Dibuja (o esconde) la marca de un boton de item: moneda, martillo o signo de mision.
-- Regla de oro: ante cualquier duda, sin marca. Nada se marca fuera de las bolsas 0-4 ni con el
-- addon apagado, y un item cuyos datos el cliente aun no tiene queda sin marca hasta que lleguen.
-- Texturas: iconos del propio juego (no hace falta media binaria). Decision documentada:
--   coin   -> Interface\MoneyFrame\UI-GoldIcon           (la moneda de oro de la interfaz)
--   hammer -> Interface\Icons\Trade_BlackSmithing        (martillo de herreria; propio: tinte verde,
--                                                          ajeno: desaturado con alpha 0.7)
--   quest  -> Interface\GossipFrame\AvailableQuestIcon   (signo de mision; solo en el botin)
-- Si el arte final cambia, basta con tocar TEXTURES.
local Marks = {}
ns.Marks = Marks

local SIZE = 14
local TEXTURES = {
    coin = 'Interface\\MoneyFrame\\UI-GoldIcon',
    hammer = 'Interface\\Icons\\Trade_BlackSmithing',
    quest = 'Interface\\GossipFrame\\AvailableQuestIcon',
}
Marks.TEXTURES = TEXTURES -- las usa el tooltip para el icono en linea de cada motivo
local MINE_TINT = { 0.25, 0.85, 0.35 }
local OTHER_ALPHA = 0.7

-- [boton] = { id = itemID, bag =, slot = | link =, owner = }: botones esperando datos del item.
local pending = setmetatable({}, { __mode = 'k' })
-- [boton] = { bag =, slot =, id = | link =, id =, owner = }: botones protegidos que, en combate, no
-- tenian aun nuestra textura: no se crea ahora; se retoma (revalidando todo) al salir del combate.
local queued = setmetatable({}, { __mode = 'k' })

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
end

local function enabled()
    local db = ns.DB
    return type(db) == 'table' and db.enabled ~= false
end

local function shows(kind)
    local show = ns.DB and ns.DB.show
    return not (type(show) == 'table' and show[kind] == false)
end

local function ensureTexture(button)
    local texture = button.KnuJunkMark
    if texture then return texture end
    texture = button:CreateTexture(nil, 'OVERLAY', nil, 7)
    texture:SetSize(SIZE, SIZE)
    texture:SetPoint('TOPLEFT', button, 'TOPLEFT', 1, -1)
    button.KnuJunkMark = texture
    return texture
end

local function kindOf(mark, allowQuest)
    if mark == 'coin' then return 'coin' end
    if mark == 'hammer_mine' or mark == 'hammer_other' then return 'hammer' end
    if mark == 'quest' and allowQuest then return 'quest' end
end

-- Deja `texture` con el aspecto de la marca (textura, tinte, desaturado). Los botones se reciclan:
-- cada dibujo parte de un estado limpio. Tambien lo usan los adaptadores que dibujan en sus propias
-- esquinas (Baganator).
local function style(texture, kind, mark)
    texture:SetTexture(TEXTURES[kind])
    if kind == 'hammer' then texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) else texture:SetTexCoord(0, 1, 0, 1) end
    texture:SetVertexColor(1, 1, 1)
    texture:SetAlpha(1)
    if texture.SetDesaturated then texture:SetDesaturated(false) end
    if mark == 'hammer_mine' then
        texture:SetVertexColor(MINE_TINT[1], MINE_TINT[2], MINE_TINT[3])
    elseif mark == 'hammer_other' then
        if texture.SetDesaturated then texture:SetDesaturated(true) end
        texture:SetAlpha(OTHER_ALPHA)
    end
end

-- mark = veredicto del clasificador; allowQuest solo en el botin.
local function paint(button, mark, allowQuest)
    local kind = kindOf(mark, allowQuest)
    if not kind or not shows(kind == 'quest' and 'loot' or kind) then return hide(button) end
    local texture = ensureTexture(button)
    style(texture, kind, mark)
    texture:Show()
end

local function verdict(item)
    local success, result = pcall(function() return ns.Classify(item, ns.Player.GetContext()) end)
    if success and type(result) == 'table' then return result.mark end
end

function Marks.Clear(button)
    if type(button) ~= 'table' then return end
    pending[button] = nil
    queued[button] = nil
    hide(button)
end

-- Cuerpo de Update: puede lanzar error (lecturas del cliente); el llamador lo aisla con pcall.
local function updateSlot(button, bag, slot, owner)
    if not enabled() or type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then return end
    local id = slotItemID(bag, slot)
    if not id then return end -- slot vacio
    local item = ns.Player.ReadItem(bag, slot)
    if not item then
        pending[button] = { id = id, bag = bag, slot = slot, owner = owner }
        return
    end
    paint(button, verdict(item), false)
end

local function updateLinkBody(button, link, owner)
    local id = itemIDOf(link)
    if not enabled() or not shows('loot') or not id then return end
    local item = ns.Player.ReadLink(link)
    if not item then
        pending[button] = { id = id, link = link, owner = owner }
        return
    end
    paint(button, verdict(item), true)
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

local function defer(button, entry)
    pending[button] = nil
    queued[button] = nil
    if entry.link then
        entry.id = itemIDOf(entry.link)
    else
        local success, id = pcall(slotItemID, entry.bag, entry.slot)
        entry.id = success and id or nil
    end
    if entry.id then queued[button] = entry end
end

-- Marca el item de bolsa `bag`/`slot` (solo bolsas 0-4) en `button`. 'quest' no se dibuja aqui.
function Marks.Update(button, bag, slot, owner)
    if type(button) ~= 'table' then return end
    button.KnuJunkOwner = owner or 'generic'
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

-- Para adaptadores que dibujan por su cuenta: veredicto del slot de bolsa `bag`/`slot` (solo 0-4, del
-- personaje actual). Devuelve la marca ('coin', 'hammer_mine' o 'hammer_other') si hay que mostrarla,
-- nil si no; el 2.o valor es true cuando el cliente aun no tiene los datos del item (reintentar con
-- GET_ITEM_INFO_RECEIVED). Si expectedID viene, el slot tiene que contener ese item. Nunca lanza.
function Marks.Verdict(bag, slot, expectedID)
    local success, mark, waiting = pcall(function()
        if not enabled() or type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then return nil end
        local id = slotItemID(bag, slot)
        if not id or (expectedID ~= nil and id ~= expectedID) then return nil end
        local item = ns.Player.ReadItem(bag, slot)
        if not item then return nil, true end
        local found = verdict(item)
        local kind = kindOf(found, false)
        if kind and shows(kind) then return found end
    end)
    if success then return mark, waiting == true end
    return nil, false
end

-- ID del item vivo en el slot `bag`/`slot`, o nil (vacio o error). Para revalidadores.
function Marks.SlotItemID(bag, slot)
    local success, id = pcall(slotItemID, bag, slot)
    if success then return id end
end

-- Pinta `texture` (de una esquina ajena) con la marca; false si la marca no es dibujable.
function Marks.Style(texture, mark)
    local kind = kindOf(mark, false)
    if not kind then return false end
    return pcall(style, texture, kind, mark)
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Marks.ResetState()
    pending = setmetatable({}, { __mode = 'k' })
    queued = setmetatable({}, { __mode = 'k' })
end

-- Retoma lo que quedo esperando (datos del item o fin del combate) SIN confiar en lo guardado:
-- el slot tiene que seguir teniendo el item que se esperaba y, si el adaptador del dueno sabe
-- revalidar (spec.revalidate(boton) -> bag, slot, itemID mostrado), su vista tiene que seguir
-- siendo una casilla viva con ese mismo item. Si algo no coincide: sin marca.
local function resume(button, entry)
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
pcall(frame.RegisterEvent, frame, 'PLAYER_REGEN_ENABLED')
frame:SetScript('OnEvent', function(_, event, itemID, success)
    local ready = {}
    if event == 'PLAYER_REGEN_ENABLED' then
        for button, entry in pairs(queued) do ready[#ready + 1] = { button = button, entry = entry } end
        for _, job in ipairs(ready) do queued[job.button] = nil end
        for _, job in ipairs(ready) do pcall(resume, job.button, job.entry) end
        return
    end
    for button, entry in pairs(pending) do
        if entry.id == itemID then ready[#ready + 1] = { button = button, entry = entry } end
    end
    for _, job in ipairs(ready) do
        pending[job.button] = nil
        if success ~= false then pcall(resume, job.button, job.entry) end
    end
end)
