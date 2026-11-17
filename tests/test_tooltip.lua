-- Tooltip: motivo de la marca. Cada prueba arma su tooltip falso y sus items.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
    return base
end

-- Tooltip falso: registra las lineas que le agregan; GetItem devuelve el enlace puesto en .link.
local function newTooltip(id)
    local tooltip = CreateFrame('Tooltip')
    tooltip.lines = {}
    tooltip.link = id and FAKE.linkOf(id) or nil
    function tooltip:AddLine(text, r, g, b) self.lines[#self.lines + 1] = { text = text, r = r, g = g, b = b } end
    function tooltip:GetItem() if self.link then return 'Item', self.link end end
    return tooltip
end

-- Cliente moderno: TooltipDataProcessor registra el callback; se lo devuelve para dispararlo a mano.
local function withProcessor()
    local state = { calls = {} }
    Enum = { TooltipDataType = { Item = 0 } }
    TooltipDataProcessor = { AddTooltipPostCall = function(kind, fn) state.calls[#state.calls + 1] = { kind = kind, fn = fn } end }
    return state
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
    processor.calls[1].fn(tooltip, {})
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
    processor.calls[1].fn(tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: misiones (activa, iniciadora, diario incompleto) sin linea', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local saved = ns.Classify
    for _, case in ipairs({
        { mark = 'quest', reasons = { { kind = 'quest_active' } } },
        { mark = nil, reasons = { { kind = 'quest_starter', questID = 5 } } },
        { mark = nil, reasons = { { kind = 'quest_log_incomplete' } } },
    }) do
        ns.Classify = function() return case end
        local tooltip = newTooltip(100)
        processor.calls[1].fn(tooltip, {})
        eq(#tooltip.lines, 0)
    end
    ns.Classify = saved
end)

test('Tooltip: hammer_other lista dos profesiones en el orden del clasificador, en gris', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withReagents({ [100] = { 164, 186 } }, function()
        local tooltip = newTooltip(100)
        processor.calls[1].fn(tooltip, {})
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
        processor.calls[1].fn(tooltip, {})
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
    processor.calls[1].fn(keep, {}); processor.calls[1].fn(sell, {})
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
    processor.calls[1].fn(tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: moneda oculta en los ajustes -> sin linea de motivo', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    ns.DB.show.coin = false
    local tooltip = newTooltip(100)
    processor.calls[1].fn(tooltip, {})
    eq(#tooltip.lines, 0)
end)

test('Tooltip: quest_done usa el nombre si hay API y #id si no', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local saved = ns.Classify
    ns.Classify = function() return { mark = 'coin', reasons = { { kind = 'quest_done', questID = 77 } } } end
    local plain = newTooltip(100)
    processor.calls[1].fn(plain, {})
    line(plain, 1, 'Misión terminada: #77', { 1, 0.82, 0 })
    C_QuestLog.GetTitleForQuestID = function(id) return 'La caza ' .. id end
    local named = newTooltip(100)
    processor.calls[1].fn(named, {})
    line(named, 1, 'Misión terminada: La caza 77')
    C_QuestLog.GetTitleForQuestID = function() error('roto') end
    local broken = newTooltip(100)
    processor.calls[1].fn(broken, {})
    line(broken, 1, 'Misión terminada: #77')
    ns.Classify = saved
end)

test('Tooltip: class_cannot_use usa el nombre de la subclase o el numero', function()
    addItem(100, { quality = 1, classID = 4, subclassID = 4 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local saved = ns.Classify
    ns.Classify = function() return { mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 4, subclassID = 4 } } } end
    local plain = newTooltip(100)
    processor.calls[1].fn(plain, {})
    line(plain, 1, 'Tu clase no usa 4', { 1, 0.82, 0 })
    GetItemSubClassInfo = function() return 'Placas' end
    local named = newTooltip(100)
    processor.calls[1].fn(named, {})
    line(named, 1, 'Tu clase no usa Placas')
    ns.Classify = saved
end)

test('Tooltip: las siete claves en ingles tienen traduccion al castellano', function()
    local keys = { 'Junk: sells', 'Quest finished: %s', "Your class can't use %s", 'Your profession: %s',
        "Profession you don't have: %s", 'Marked by hand: keep', 'Marked by hand: sell' }
    for _, key in ipairs(keys) do ok(ns.L[key] ~= key, 'traduccion de ' .. key) end
end)

test('Tooltip: doble disparo para el mismo contenido -> lineas una sola vez', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    local tooltip = newTooltip(100)
    GameTooltip = tooltip
    ns.Tooltip.Hook()
    local data = {}
    processor.calls[1].fn(tooltip, data)
    processor.calls[1].fn(tooltip, data)
    eq(#tooltip.lines, 1)
    -- tras limpiarse el tooltip, un armado nuevo vuelve a agregarlas
    tooltip.scripts.OnTooltipCleared(tooltip)
    tooltip.lines = {}
    processor.calls[1].fn(tooltip, data)
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

test('Tooltip: un error del clasificador o del tooltip no lo rompe', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local saved = ns.Classify
    ns.Classify = function() error('roto') end
    local tooltip = newTooltip(100)
    processor.calls[1].fn(tooltip, {})
    ns.Classify = saved
    eq(#tooltip.lines, 0)
    local weird = newTooltip(100)
    weird.GetItem = function() error('roto') end
    processor.calls[1].fn(weird, {})
    eq(#weird.lines, 0)
end)

test('Tooltip: sin datos del item todavia -> sin lineas', function()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local tooltip = newTooltip(nil)
    tooltip.link = '|cffffffff|Hitem:999::::::::|h[Desconocido]|h|r'
    processor.calls[1].fn(tooltip, {})
    eq(#tooltip.lines, 0)
end)
