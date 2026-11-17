-- Tooltip: motivo de la marca. Cada prueba arma su tooltip falso y sus items.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
    return base
end

-- Tooltip falso con nombre (como los de Blizzard): AddLine crea <nombre>TextLeft<n>, GetNumLines
-- cuenta las lineas, GetItem devuelve el enlace puesto en .link y Clear dispara OnTooltipCleared.
local tooltipCount = 0
local function newTooltip(id)
    tooltipCount = tooltipCount + 1
    local tooltip = CreateFrame('Tooltip', 'KJTestTip' .. tooltipCount)
    tooltip.lines = {}
    tooltip.link = id and FAKE.linkOf(id) or nil
    function tooltip:AddLine(text, r, g, b)
        self.lines[#self.lines + 1] = { text = text, r = r, g = g, b = b }
        CreateFrame('FontString', self:GetName() .. 'TextLeft' .. #self.lines):SetText(text)
    end
    function tooltip:GetNumLines() return #self.lines end
    function tooltip:GetItem() if self.link then return 'Item', self.link end end
    function tooltip:Clear()
        self.lines = {}
        if self.scripts.OnTooltipCleared then self.scripts.OnTooltipCleared(self) end
    end
    return tooltip
end

-- Cliente moderno: TooltipDataProcessor registra el callback; se lo devuelve para dispararlo a mano.
local function withProcessor()
    local state = { calls = {} }
    Enum = { TooltipDataType = { Item = 0 } }
    TooltipDataProcessor = { AddTooltipPostCall = function(kind, fn) state.calls[#state.calls + 1] = { kind = kind, fn = fn } end }
    return state
end

-- Dispara el callback del procesador sobre `tooltip`, que pasa a ser el GameTooltip (el unico, con
-- ItemRefTooltip, que se atiende).
local function run(processor, tooltip, data)
    GameTooltip = tooltip
    processor.calls[1].fn(tooltip, data)
end

-- Cambia ns.Classify durante fn y lo restaura SIEMPRE, aunque fn falle.
local function withClassify(replacement, fn)
    local saved = ns.Classify
    ns.Classify = replacement
    local success, err = pcall(fn)
    ns.Classify = saved
    if not success then error(err, 0) end
end

local function withReagents(map, fn)
    local saved = ns.Data.reagents
    ns.Data.reagents = map
    local success, err = pcall(fn)
    ns.Data.reagents = saved
    if not success then error(err, 0) end
end

-- ¿La linea n termina en `text` y (si se pasa) tiene ese color?
local function line(tooltip, n, text, color)
    local entry = tooltip.lines[n]
    ok(entry, 'falta la linea ' .. n)
    eq(entry.text:sub(-#text), text, 'texto de la linea ' .. n .. ' (' .. entry.text .. ')')
    if color then
        eq(entry.r, color[1]); eq(entry.g, color[2]); eq(entry.b, color[3])
    end
    return entry
end

local function hasIcon(entry) return entry.text:sub(1, 2) == '|T' and entry.text:find('|t ', 1, true) ~= nil end

test('Tooltip: gris agrega una linea con moneda en dorado', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ok(ns.Tooltip.Hook(), 'engancha')
    eq(#processor.calls, 1); eq(processor.calls[1].kind, Enum.TooltipDataType.Item)
    local tooltip = newTooltip(100)
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
    local entry = line(tooltip, 1, 'Basura: se vende', { 1, 0.82, 0 })
    ok(hasIcon(entry), 'icono en linea')
    ok(entry.text:find('UI-GoldIcon', 1, true), 'misma textura que Marks')
end)

test('Tooltip: item sin marca no agrega nada', function()
    addItem(100, { quality = 1, price = 5 }) -- blanco: sin marca
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    run(processor, tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: misiones (activa, iniciadora, diario incompleto) sin linea', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    for _, case in ipairs({
        { mark = 'quest', reasons = { { kind = 'quest_active' } } },
        { mark = nil, reasons = { { kind = 'quest_starter', questID = 5 } } },
        { mark = nil, reasons = { { kind = 'quest_log_incomplete' } } },
    }) do
        withClassify(function() return case end, function()
            local tooltip = newTooltip(100)
            run(processor, tooltip, {})
            eq(#tooltip.lines, 0)
        end)
    end
end)

test('Tooltip: hammer_other lista dos profesiones en el orden del clasificador, en gris', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withReagents({ [100] = { 164, 186 } }, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        eq(#tooltip.lines, 1)
        local entry = line(tooltip, 1, 'Profesión que no tenés: Herrería, Minería', { 0.6, 0.6, 0.6 })
        ok(hasIcon(entry), 'icono'); ok(entry.text:find('Trade_BlackSmithing', 1, true), 'martillo')
    end)
end)

test('Tooltip: hammer_mine muestra tu profesion en verde', function()
    addItem(100, { quality = 1 })
    FAKE.professions = { { name = 'Herrería', skillLine = 164 } }
    ns.Player.Invalidate()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withReagents({ [100] = { 164, 186 } }, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        eq(#tooltip.lines, 1)
        line(tooltip, 1, 'Tu profesión: Herrería', { 0.25, 0.85, 0.35 })
    end)
end)

test('Tooltip: override visible (keep y sell), en blanco', function()
    addItem(100, { quality = 1 }); addItem(101, { quality = 1 })
    ns.DB.overrides[100] = 'keep'; ns.DB.overrides[101] = 'sell'
    ns.Player.Invalidate()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local keep, sell = newTooltip(100), newTooltip(101)
    run(processor, keep, {}); run(processor, sell, {})
    eq(#keep.lines, 1); line(keep, 1, 'Marcado a mano: guardar', { 1, 1, 1 })
    eq(#sell.lines, 1); line(sell, 1, 'Marcado a mano: vender', { 1, 1, 1 })
    ok(hasIcon(sell.lines[1]), 'vender lleva la moneda')
end)

test('Tooltip: addon apagado -> sin lineas', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    ns.DB.enabled = false
    local tooltip = newTooltip(100)
    run(processor, tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: moneda oculta en los ajustes -> sin linea de motivo', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    ns.DB.show.coin = false
    local tooltip = newTooltip(100)
    run(processor, tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: quest_done usa el nombre si hay API y #id si no', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withClassify(function() return { mark = 'coin', reasons = { { kind = 'quest_done', questID = 77 } } } end, function()
        local plain = newTooltip(100)
        run(processor, plain, {})
        line(plain, 1, 'Misión terminada: #77', { 1, 0.82, 0 })
        C_QuestLog.GetTitleForQuestID = function(id) return 'La caza ' .. id end
        local named = newTooltip(100)
        run(processor, named, {})
        line(named, 1, 'Misión terminada: La caza 77')
        C_QuestLog.GetTitleForQuestID = function() error('roto') end
        local broken = newTooltip(100)
        run(processor, broken, {})
        line(broken, 1, 'Misión terminada: #77')
    end)
end)

test('Tooltip: class_cannot_use usa el nombre de la subclase o el numero', function()
    addItem(100, { quality = 1, classID = 4, subclassID = 4 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withClassify(function() return { mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 4, subclassID = 4 } } } end, function()
        local plain = newTooltip(100)
        run(processor, plain, {})
        line(plain, 1, 'Tu clase no usa 4', { 1, 0.82, 0 })
        GetItemSubClassInfo = function() return 'Placas' end
        local named = newTooltip(100)
        run(processor, named, {})
        line(named, 1, 'Tu clase no usa Placas')
    end)
end)

test('Tooltip: las siete claves en ingles tienen traduccion al castellano', function()
    local keys = { 'Junk: sells', 'Quest finished: %s', "Your class can't use %s", 'Your profession: %s',
        "Profession you don't have: %s", 'Marked by hand: keep', 'Marked by hand: sell' }
    for _, key in ipairs(keys) do ok(ns.L[key] ~= key, 'traduccion de ' .. key) end
end)

test('Tooltip: doble callback con tablas equivalentes -> lineas una sola vez', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    run(processor, tooltip, { id = 100, dataInstanceID = 7 })
    run(processor, tooltip, { id = 100, dataInstanceID = 7 })
    run(processor, tooltip, nil)
    eq(#tooltip.lines, 1)
end)

test('Tooltip: cambio de item sin clear -> lineas del nuevo, sin repetir las anteriores', function()
    addItem(100, { quality = 0, price = 5 })
    addItem(101, { quality = 1 })
    ns.DB.overrides[101] = 'keep'
    ns.Player.Invalidate()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    local data = {}
    run(processor, tooltip, data)
    eq(#tooltip.lines, 1)
    tooltip.link = FAKE.linkOf(101)
    run(processor, tooltip, data)
    run(processor, tooltip, data)
    eq(#tooltip.lines, 2)
    line(tooltip, 1, 'Basura: se vende'); line(tooltip, 2, 'Marcado a mano: guardar')
end)

test('Tooltip: clear y rearmado del mismo item -> las lineas vuelven', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    local tooltip = newTooltip(100)
    GameTooltip = tooltip -- el frame probado es el que recibe los hooks (OnTooltipCleared)
    ns.Tooltip.Hook()
    ok(tooltip.scripts.OnTooltipCleared, 'hook de limpieza instalado en el frame probado')
    local data = {}
    run(processor, tooltip, data)
    eq(#tooltip.lines, 1)
    tooltip:Clear()
    eq(#tooltip.lines, 0)
    run(processor, tooltip, data)
    eq(#tooltip.lines, 1)
end)

test('Tooltip: sin poder leer las lineas, el respaldo por enlace evita repetir y Clear lo libera', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    local tooltip = newTooltip(100)
    tooltip.GetNumLines = nil
    GameTooltip = tooltip
    ns.Tooltip.Hook()
    run(processor, tooltip, {})
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
    tooltip:Clear()
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
end)

test('Tooltip: otros tooltips (ni GameTooltip ni ItemRefTooltip) se ignoran; ItemRefTooltip se atiende', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local other = newTooltip(100)
    processor.calls[1].fn(other, {})
    eq(#other.lines, 0)
    local ref = newTooltip(100)
    ItemRefTooltip = ref
    processor.calls[1].fn(ref, {})
    eq(#ref.lines, 1)
end)

test('Tooltip: item identificado solo por GUID (sin GetItem ni hyperlink) -> lineas', function()
    addItem(100, { quality = 0, price = 5 })
    C_Item = { GetItemLinkByGUID = function(guid) if guid == 'Item-1-2' then return FAKE.linkOf(100) end end }
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    tooltip.GetItem = nil
    run(processor, tooltip, { guid = 'Item-1-2' })
    eq(#tooltip.lines, 1)
    line(tooltip, 1, 'Basura: se vende')
    local unknown = newTooltip(100)
    unknown.GetItem = nil
    run(processor, unknown, { guid = 'otro' })
    eq(#unknown.lines, 0)
end)

test('Tooltip: TooltipUtil.GetDisplayedItem resuelve el enlace si GetItem y los datos no', function()
    addItem(100, { quality = 0, price = 5 })
    TooltipUtil = { GetDisplayedItem = function() return 'Item', FAKE.linkOf(100), 100 end }
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    tooltip.GetItem = nil
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
end)

test('Tooltip: sin TooltipDataProcessor engancha OnTooltipSetItem (una vez por armado)', function()
    addItem(100, { quality = 0, price = 5 })
    GameTooltip = newTooltip(100)
    ItemRefTooltip = newTooltip(100)
    ok(ns.Tooltip.Hook(), 'engancha')
    eq(ns.Tooltip.Hook(), true)
    GameTooltip.scripts.OnTooltipSetItem(GameTooltip)
    GameTooltip.scripts.OnTooltipSetItem(GameTooltip)
    eq(#GameTooltip.lines, 1)
    ItemRefTooltip.scripts.OnTooltipSetItem(ItemRefTooltip)
    eq(#ItemRefTooltip.lines, 1)
    line(ItemRefTooltip, 1, 'Basura: se vende')
end)

test('Tooltip: un error del clasificador o del tooltip no lo rompe y se recupera al reintentar', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    local data = {} -- la MISMA tabla en los dos intentos
    withClassify(function() error('roto') end, function()
        run(processor, tooltip, data)
        eq(#tooltip.lines, 0)
    end)
    run(processor, tooltip, data) -- mismo enlace y mismos datos: el intento fallido no cuenta como hecho
    eq(#tooltip.lines, 1)
    local weird = newTooltip(100)
    weird.GetItem = function() error('roto') end
    run(processor, weird, {})
    eq(#weird.lines, 0)
end)

test('Tooltip: sin datos del item todavia -> sin lineas y se reintenta cuando llegan', function()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(nil)
    tooltip.link = '|cffffffff|Hitem:999::::::::|h[Desconocido]|h|r'
    local data = {}
    run(processor, tooltip, data)
    eq(#tooltip.lines, 0)
    addItem(999, { quality = 0, price = 5 })
    run(processor, tooltip, data)
    eq(#tooltip.lines, 1)
    run(processor, tooltip, data)
    eq(#tooltip.lines, 1)
end)

test('Tooltip: decoracion parcial (la 2.a AddLine falla una vez) -> el reintento agrega solo la que falta', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    local tooltip = newTooltip(100)
    GameTooltip = tooltip
    ns.Tooltip.Hook()
    local original, calls = tooltip.AddLine, 0
    function tooltip:AddLine(...)
        calls = calls + 1
        if calls == 2 then error('fallo transitorio') end
        return original(self, ...)
    end
    local data = {}
    withClassify(function()
        return { mark = 'coin', reasons = { { kind = 'gray' }, { kind = 'quest_done', questID = 5 } } }
    end, function()
        run(processor, tooltip, data)
        eq(#tooltip.lines, 1)
        line(tooltip, 1, 'Basura: se vende')
        run(processor, tooltip, data)
        eq(#tooltip.lines, 2)
        line(tooltip, 1, 'Basura: se vende'); line(tooltip, 2, 'Misión terminada: #5')
        run(processor, tooltip, data)
        eq(#tooltip.lines, 2)
    end)
end)

test('Tooltip: parcial tambien con el tooltip ilegible (respaldo por registro)', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    local tooltip = newTooltip(100)
    tooltip.GetNumLines = nil
    GameTooltip = tooltip
    ns.Tooltip.Hook()
    local original, calls = tooltip.AddLine, 0
    function tooltip:AddLine(...)
        calls = calls + 1
        if calls == 2 then error('fallo transitorio') end
        return original(self, ...)
    end
    withClassify(function()
        return { mark = 'coin', reasons = { { kind = 'gray' }, { kind = 'quest_done', questID = 5 } } }
    end, function()
        run(processor, tooltip, {})
        run(processor, tooltip, {})
        run(processor, tooltip, {})
        eq(#tooltip.lines, 2)
        tooltip:Clear()
        run(processor, tooltip, {})
        eq(#tooltip.lines, 2)
    end)
end)

test('Tooltip: regiones legibles con el icono quitado por el cliente -> no se duplica', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    function tooltip:AddLine(text, r, g, b)
        self.lines[#self.lines + 1] = { text = text, r = r, g = g, b = b }
        local shown = text:gsub('|T.-|t', '') -- el cliente devuelve el texto sin el escape del icono
        CreateFrame('FontString', self:GetName() .. 'TextLeft' .. #self.lines):SetText(' ' .. shown)
    end
    run(processor, tooltip, {})
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
end)

test('Tooltip: regiones legibles con otro texto son la autoridad (no se cae al registro)', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(100)
    run(processor, tooltip, {})
    eq(#tooltip.lines, 1)
    -- el tooltip se rearmo con otro contenido sin avisar: las regiones ya no tienen nuestra linea
    CreateFrame('FontString', tooltip:GetName() .. 'TextLeft1'):SetText('Otra cosa')
    run(processor, tooltip, {})
    eq(#tooltip.lines, 2)
end)

test('Tooltip: aislamiento - un fallo dentro de withClassify no deja el clasificador falso', function()
    local original = ns.Classify
    local success = pcall(withClassify, function() return { mark = 'coin', reasons = {} } end, function() error('fallo deliberado') end)
    ok(not success, 'el fallo se propaga')
    eq(ns.Classify, original, 'clasificador restaurado')
end)

test('Tooltip: aislamiento - Reset deja GameTooltip limpio, sin hooks ni lineas', function()
    local dirty = newTooltip(100)
    dirty.scripts.OnTooltipSetItem = function() end
    GameTooltip = dirty
    ItemRefTooltip = newTooltip(100)
    FAKE.Reset()
    ok(GameTooltip ~= dirty, 'GameTooltip nuevo')
    ok(next(GameTooltip.scripts) == nil, 'sin scripts enganchados')
    eq(ItemRefTooltip, nil)
end)

test('Tooltip: aislamiento - el caso siguiente ve el GameTooltip limpio', function()
    ok(next(GameTooltip.scripts) == nil, 'sin scripts enganchados')
    eq(GameTooltip.lines, nil)
end)
