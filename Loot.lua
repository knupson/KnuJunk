local _, ns = ...

-- Ventana de botin de Blizzard: las mismas marcas que en las bolsas mas el signo de mision.
-- Solo hooksecurefunc / callbacks de la lista: nunca se reemplaza ni se llama a funciones de Blizzard
-- ni se toca un frame protegido (Marks ya difiere lo que no se puede en combate).
-- Forever puede traer dos formas de dibujar el botin y se soportan las dos, detectando cada una
-- (el camino real NO esta verificado en el juego; se infiere de la API publica de Blizzard):
--   * moderna: LootFrame.ScrollBox con filas RECICLADAS (LootFrameElementMixin / LootFrameItemElementMixin).
--     Se engancha con ScrollUtil.AddInitializedFrameCallback(scrollBox, ...) (filas nuevas y las ya
--     existentes); si esa utilidad falta, con hooksecurefunc(<mixin>, 'Init'). El slot sale de
--     row:GetSlotIndex() o de row:GetElementData().slotIndex; el boton del icono es row.Item.
--   * clasica: la global LootFrame_Update y los botones LootButton1..LOOTFRAME_NUMBUTTONS con button.slot;
--     el boton es el propio icono.
-- Las filas se reciclan: cada actualizacion parte de limpio y marca desde el enlace ACTUAL del slot
-- (GetLootSlotLink(slot)); un slot sin enlace (dinero) o con otra cosa que un item queda sin marca.
local Loot = {}
ns.Loot = Loot

local OWNER = 'Loot'
local DEFAULT_BUTTONS = 4
local hookedRows = setmetatable({}, { __mode = 'k' })  -- filas con su Init enganchado (fallback por mixin)
local mixinInit                                        -- el Init del mixin ya enganchado
local closed = false                                   -- LOOT_CLOSED visto y aun no hay LOOT_OPENED
local ownerToken = {}                                  -- "dueno" de los callbacks de la lista
local hooked = { list = false, mixin = false, classic = false }
local rowOfMark = setmetatable({}, { __mode = 'k' })   -- [boton marcado] = fila que lo contiene
local seen = setmetatable({}, { __mode = 'k' })        -- filas/botones que alguna vez marcamos

local function field(object, key)
    if type(object) ~= 'table' then return nil end
    local success, value = pcall(function() return object[key] end)
    if success then return value end
end

-- Slot de botin de una fila: metodo de la fila, sus datos o el campo del boton clasico.
local function slotOf(row)
    if type(row.GetSlotIndex) == 'function' then
        local success, slot = pcall(row.GetSlotIndex, row)
        if success and type(slot) == 'number' then return slot end
    end
    if type(row.GetElementData) == 'function' then
        local success, data = pcall(row.GetElementData, row)
        if success and type(data) == 'table' and type(data.slotIndex) == 'number' then return data.slotIndex end
    end
    local slot = rawget(row, 'slot')
    if type(slot) == 'number' then return slot end
end

-- El boton donde se dibuja la marca: el icono de la fila moderna, o el boton clasico mismo.
local function markButtonOf(row)
    local item = rawget(row, 'Item')
    if type(item) == 'table' and type(item.CreateTexture) == 'function' then return item end
    return row
end

-- Enlace de item del slot ahora mismo; nil si no hay (dinero, otra cosa que un item, vacio).
local function currentLink(slot)
    if type(slot) ~= 'number' or type(GetLootSlotLink) ~= 'function' then return nil end
    local link = GetLootSlotLink(slot)
    if type(link) == 'string' and link:match('item:%d+') then return link end
end

local function lootShown()
    local frame = _G.LootFrame
    if closed or type(frame) ~= 'table' then return false end
    return type(frame.IsShown) ~= 'function' or (frame:IsShown() and true or false)
end

Loot.IsShown = lootShown

local function rowVisible(row)
    return type(row.IsShown) ~= 'function' or (row:IsShown() and true or false)
end

local function clearRow(row)
    ns.Marks.Clear(markButtonOf(row))
    ns.LootAdvisor.Hide(markButtonOf(row))
end

-- Limpia y vuelve a marcar una fila desde su slot actual. Nunca lanza.
local function updateRow(row)
    if type(row) ~= 'table' then return end
    local success = pcall(function()
        local button = markButtonOf(row)
        rowOfMark[button] = row
        seen[row] = true
        ns.LootAdvisor.Hide(button)
        if not lootShown() or not rowVisible(row) then return ns.Marks.Clear(button) end
        local link = currentLink(slotOf(row))
        if not link then return ns.Marks.Clear(button) end
        ns.Marks.UpdateLink(button, link, OWNER)
        ns.LootAdvisor.Update(button, slotOf(row))
    end)
    if not success then pcall(clearRow, row) end
end

-- fn(fila) para cada fila viva: la lista moderna o los botones clasicos.
local function eachRow(fn)
    local frame = _G.LootFrame
    if type(frame) ~= 'table' then return end
    local scrollBox = field(frame, 'ScrollBox')
    if type(scrollBox) == 'table' and type(scrollBox.ForEachFrame) == 'function' then
        pcall(scrollBox.ForEachFrame, scrollBox, function(row) fn(row) end)
    end
    for index = 1, _G.LOOTFRAME_NUMBUTTONS or DEFAULT_BUTTONS do
        local button = _G['LootButton' .. index]
        if type(button) ~= 'table' then break end
        fn(button)
    end
end

function Loot.Refresh()
    Loot.Hook()
    eachRow(updateRow)
end

-- Al cerrar el botin: todas las filas que marcamos quedan sin marca (aunque la lista ya no las liste).
function Loot.ClearAll()
    for row in pairs(seen) do pcall(clearRow, row) end
    eachRow(function(row) pcall(clearRow, row) end)
end

-- Fallback por mixin: las filas copian los metodos del mixin al crearse, asi que una fila creada ANTES
-- de enganchar conserva el Init original y reciclarla (row:Init()) no pasaria por el hook global.
-- Se engancha el Init efectivo de cada fila existente (una sola vez por fila). Las filas nacidas despues
-- ya copian el Init enganchado (mixinInit) y no se enganchan de nuevo.
local function hookRow(row)
    if type(row) ~= 'table' or hookedRows[row] then return end
    local init = rawget(row, 'Init')
    if type(init) ~= 'function' or init == mixinInit then return end
    hookedRows[row] = true
    if not pcall(hooksecurefunc, row, 'Init', updateRow) then hookedRows[row] = nil end
end

-- Engancha lo que exista y no este enganchado; true si hay algo enganchado. Idempotente.
function Loot.Hook()
    local frame = _G.LootFrame
    local scrollBox = field(frame, 'ScrollBox')
    if not hooked.list and type(scrollBox) == 'table' and type(_G.ScrollUtil) == 'table'
        and type(_G.ScrollUtil.AddInitializedFrameCallback) == 'function' then
        hooked.list = pcall(_G.ScrollUtil.AddInitializedFrameCallback, scrollBox,
            function(_, row) updateRow(row) end, ownerToken, true)
    end
    if not hooked.list and not hooked.mixin then
        local mixin = _G.LootFrameItemElementMixin or _G.LootFrameElementMixin
        if type(mixin) == 'table' and type(mixin.Init) == 'function' then
            hooksecurefunc(mixin, 'Init', updateRow)
            mixinInit = mixin.Init
            hooked.mixin = true
        end
    end
    if hooked.mixin then eachRow(hookRow) end
    if not hooked.classic and type(_G.LootFrame_Update) == 'function' then
        hooksecurefunc('LootFrame_Update', function() eachRow(updateRow) end)
        hooked.classic = true
    end
    return hooked.list or hooked.mixin or hooked.classic
end

-- Enlace que la fila de este boton muestra AHORA (Marks lo usa para retomar una marca que esperaba
-- datos del item): nil si el botin se cerro, la fila se oculto o su slot ya no tiene un item.
local function revalidate(button)
    local row = rowOfMark[button] or button
    if type(row) ~= 'table' or not lootShown() or not rowVisible(row) then return nil end
    return currentLink(slotOf(row))
end

local soonPending = false -- hay una pasada diferida agendada (ver refreshSoon)

function Loot.ResetState()
    hooked = { list = false, mixin = false, classic = false }
    closed = false
    mixinInit = nil
    hookedRows = setmetatable({}, { __mode = 'k' })
    rowOfMark = setmetatable({}, { __mode = 'k' })
    seen = setmetatable({}, { __mode = 'k' })
    soonPending = false
end

ns.Bags.Register(OWNER, { install = Loot.Hook, refresh = Loot.Refresh, revalidate = revalidate })

-- Eventos del botin: cerrar limpia; abrir/cambiar/vaciar repinta desde los slots actuales, en el acto y
-- otra vez al siguiente cuadro (cuando Blizzard ya dibujo las filas). La pasada diferida es una sola
-- por rafaga de eventos.
local function refreshSoon()
    if soonPending or not (C_Timer and C_Timer.After) then return end
    soonPending = true
    C_Timer.After(0, function()
        soonPending = false
        Loot.Refresh()
    end)
end

local frame = CreateFrame('Frame')
for _, event in ipairs({ 'LOOT_OPENED', 'LOOT_SLOT_CHANGED', 'LOOT_SLOT_CLEARED', 'LOOT_CLOSED', 'MODIFIER_STATE_CHANGED', 'BAG_UPDATE_DELAYED' }) do
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript('OnEvent', function(_, event)
    if event == 'LOOT_CLOSED' then
        closed = true                -- un repintado pendiente no debe revivir las marcas
        return pcall(Loot.ClearAll)
    end
    if event == 'LOOT_OPENED' then closed = false end
    if not lootShown() then return end
    pcall(Loot.Refresh)
    pcall(refreshSoon)
end)
