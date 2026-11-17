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
local MINE_TINT = { 0.25, 0.85, 0.35 }
local OTHER_ALPHA = 0.7

-- [boton] = { id = itemID, bag =, slot = | link =, owner = }: botones esperando datos del item.
local pending = setmetatable({}, { __mode = 'k' })

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

-- mark = veredicto del clasificador; allowQuest solo en el botin.
local function paint(button, mark, allowQuest)
    local kind
    if mark == 'coin' then kind = 'coin'
    elseif mark == 'hammer_mine' or mark == 'hammer_other' then kind = 'hammer'
    elseif mark == 'quest' and allowQuest then kind = 'quest' end
    if not kind or not shows(kind == 'quest' and 'loot' or kind) then return hide(button) end
    local texture = ensureTexture(button)
    texture:SetTexture(TEXTURES[kind])
    if kind == 'hammer' then texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) else texture:SetTexCoord(0, 1, 0, 1) end
    -- Los botones se reciclan: cada dibujo parte de un estado limpio.
    texture:SetVertexColor(1, 1, 1)
    texture:SetAlpha(1)
    if texture.SetDesaturated then texture:SetDesaturated(false) end
    if mark == 'hammer_mine' then
        texture:SetVertexColor(MINE_TINT[1], MINE_TINT[2], MINE_TINT[3])
    elseif mark == 'hammer_other' then
        if texture.SetDesaturated then texture:SetDesaturated(true) end
        texture:SetAlpha(OTHER_ALPHA)
    end
    texture:Show()
end

local function verdict(item)
    local success, result = pcall(function() return ns.Classify(item, ns.Player.GetContext()) end)
    if success and type(result) == 'table' then return result.mark end
end

function Marks.Clear(button)
    if type(button) ~= 'table' then return end
    pending[button] = nil
    hide(button)
end

-- Marca el item de bolsa `bag`/`slot` (solo bolsas 0-4) en `button`. 'quest' no se dibuja aqui.
function Marks.Update(button, bag, slot, owner)
    if type(button) ~= 'table' then return end
    button.KnuJunkOwner = owner or 'generic'
    pending[button] = nil
    if not enabled() or type(bag) ~= 'number' or bag < 0 or bag > 4 or type(slot) ~= 'number' then
        return hide(button)
    end
    local id = slotItemID(bag, slot)
    if not id then return hide(button) end -- slot vacio
    local item = ns.Player.ReadItem(bag, slot)
    if not item then
        pending[button] = { id = id, bag = bag, slot = slot, owner = owner }
        return hide(button)
    end
    paint(button, verdict(item), false)
end

-- Marca un item por enlace (ventana de botin). Aqui si se dibuja 'quest'.
function Marks.UpdateLink(button, link, owner)
    if type(button) ~= 'table' then return end
    button.KnuJunkOwner = owner or 'generic'
    pending[button] = nil
    local id = itemIDOf(link)
    if not enabled() or not shows('loot') or not id then return hide(button) end
    local item = ns.Player.ReadLink(link)
    if not item then
        pending[button] = { id = id, link = link, owner = owner }
        return hide(button)
    end
    paint(button, verdict(item), true)
end

-- Solo para pruebas: deja el modulo como recien cargado.
function Marks.ResetState()
    pending = setmetatable({}, { __mode = 'k' })
end

-- Los datos del item llegaron: se vuelve a marcar solo lo que esperaba ESE item. Si el cliente
-- dice que no existe (success == false) se olvida la espera.
local frame = CreateFrame('Frame')
pcall(frame.RegisterEvent, frame, 'GET_ITEM_INFO_RECEIVED')
frame:SetScript('OnEvent', function(_, _, itemID, success)
    local ready = {}
    for button, entry in pairs(pending) do
        if entry.id == itemID then ready[#ready + 1] = { button = button, entry = entry } end
    end
    for _, job in ipairs(ready) do
        local button, entry = job.button, job.entry
        pending[button] = nil
        if success ~= false then
            if entry.link then Marks.UpdateLink(button, entry.link, entry.owner)
            else Marks.Update(button, entry.bag, entry.slot, entry.owner) end
        end
    end
end)
