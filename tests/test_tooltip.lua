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

-- Regla del 2026-11-17: el tooltip dice por que un item de mision no lleva moneda (mision activa
-- o iniciador de una mision no hecha) y por que si la lleva (ninguna mision activa lo pide).
test('Tooltip: lineas de mision activa, iniciador y quest_not_active', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local cases = {
        { { mark = 'quest', reasons = { { kind = 'quest_active' } } }, 'Lo pide una misión activa', { 1, 1, 1 } },
        { { mark = 'quest', reasons = { { kind = 'quest_active', title = 'Los lobos' } } }, 'Misión activa: Los lobos', { 1, 1, 1 } },
        { { mark = 'quest', reasons = { { kind = 'quest_active', questID = 5 } } }, 'Misión activa: #5', { 1, 1, 1 } },
        { { mark = nil, reasons = { { kind = 'quest_starter', questID = 5 } } }, 'Inicia una misión que no hiciste: #5', { 1, 1, 1 } },
        { { mark = 'coin', reasons = { { kind = 'quest_not_active' } } }, 'Ninguna misión activa lo pide', { 1, 0.82, 0 } },
    }
    for _, case in ipairs(cases) do
        withClassify(function() return case[1] end, function()
            local tooltip = newTooltip(100)
            run(processor, tooltip, {})
            eq(#tooltip.lines, 1)
            line(tooltip, 1, case[2], case[3])
        end)
    end
    -- La linea de quest_not_active lleva el icono de la moneda; la de mision activa, el signo de mision.
    withClassify(function() return cases[5][1] end, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        ok(tooltip.lines[1].text:find('UI-GoldIcon', 1, true) or tooltip.lines[1].text:find('|A:', 1, true), 'icono de moneda')
    end)
    withClassify(function() return cases[1][1] end, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        ok(tooltip.lines[1].text:find('AvailableQuestIcon', 1, true), 'signo de mision')
    end)
end)

test('Tooltip: diario incompleto sin linea', function()
    addItem(100, { quality = 0, price = 5 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    for _, case in ipairs({
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
        local entry = line(tooltip, 1, 'Profesión que no tenés: Herrería, Minería', { 1, 0.85, 0.2 })
        ok(hasIcon(entry), 'icono'); ok(entry.text:find('media\\martillo:14:14:0:0:64:64:0:64:0:64:255:217:51|t ', 1, true), 'martillo ajeno gris: ' .. entry.text)
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

local function withTools(map, fn)
    local saved = ns.Data.tools
    ns.Data.tools = map
    local success, err = pcall(fn)
    ns.Data.tools = saved
    if not success then error(err, 0) end
end

test('Tooltip: herramienta de tu profesion en verde con martillo', function()
    addItem(100, { quality = 1 })
    FAKE.professions = { { name = 'Herrería', skillLine = 164 } }
    ns.Player.Invalidate()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withTools({ [100] = { 164, 202 } }, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        eq(#tooltip.lines, 1)
        local entry = line(tooltip, 1, 'Herramienta de tu profesión: Herrería', { 0.25, 0.85, 0.35 })
        ok(hasIcon(entry), 'icono')
    end)
end)

test('Tooltip: herramienta de una profesion que no tenes en gris con martillo', function()
    addItem(100, { quality = 1 })
    ns.Player.Invalidate()
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withTools({ [100] = { 186 } }, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        eq(#tooltip.lines, 1)
        local entry = line(tooltip, 1, 'Herramienta de profesión que no tenés: Minería', { 1, 0.85, 0.2 })
        ok(hasIcon(entry), 'icono')
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

test('Tooltip: class_cannot_use usa el subtipo que trae el motivo o el item, antes que GetItemSubClassInfo', function()
    addItem(100, { quality = 1, classID = 2, subclassID = 19, subType = 'Varita' })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local saved = GetItemSubClassInfo
    GetItemSubClassInfo = nil
    withClassify(function() return { mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 2, subclassID = 19, subclassName = 'Varita' } } } end, function()
        local tip = newTooltip(100)
        run(processor, tip, {})
        line(tip, 1, 'Tu clase no usa Varita')
    end)
    withClassify(function() return { mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 2, subclassID = 19 } } } end, function()
        local tip = newTooltip(100)
        run(processor, tip, {})
        line(tip, 1, 'Tu clase no usa Varita')
    end)
    GetItemSubClassInfo = function() return 'Placas' end
    withClassify(function() return { mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 2, subclassID = 19, subclassName = 'Varita' } } } end, function()
        local tip = newTooltip(100)
        run(processor, tip, {})
        line(tip, 1, 'Tu clase no usa Varita')
    end)
    GetItemSubClassInfo = saved
end)

test('Tooltip: las nueve claves en ingles tienen traduccion al castellano', function()
    local keys = { 'Junk: sells', 'Quest finished: %s', "Your class can't use %s", 'Your profession: %s',
        "Profession you don't have: %s", 'Marked by hand: keep', 'Marked by hand: sell',
        'Tool for your profession: %s', "Tool for a profession you don't have: %s" }
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

-- Reactivo util para una mision del diario: martillo + linea neutra de la mision (con su icono).
test('Tooltip: reactivo con mision activa de Questie -> linea de mision y martillo', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withReagents({ [100] = { 164 } }, function()
        local saved = ns.Questie.Uses
        ns.Questie.Uses = function(id) if id == 100 then return { { questID = 77, repeatable = false } } end end
        FAKE.questLog = { { questID = 77 } }
        local success, err = pcall(function()
            local plain = newTooltip(100)
            run(processor, plain, {})
            eq(#plain.lines, 2)
            local entry = line(plain, 1, 'Misión activa: #77', { 1, 1, 1 })
            ok(entry.text:find('GossipFrame\\AvailableQuestIcon', 1, true), 'icono de mision: ' .. entry.text)
            line(plain, 2, 'Profesión que no tenés: Herrería', { 1, 0.85, 0.2 })
            for _, l in ipairs(plain.lines) do ok(not l.text:find('UI-GoldIcon', 1, true), 'nunca moneda') end
            C_QuestLog.GetTitleForQuestID = function(id) return 'La caza ' .. id end
            local named = newTooltip(100)
            run(processor, named, {})
            line(named, 1, 'Misión activa: La caza 77')
        end)
        ns.Questie.Uses = saved
        C_QuestLog.GetTitleForQuestID = nil
        if not success then error(err, 0) end
    end)
end)

test('Tooltip: titulo de QuestieDB si el cliente no lo da', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    FAKE.InstallQuestie({ [78] = { name = 'Garras para el herrero' } })
    withClassify(function()
        return { mark = 'hammer_other', quest = true, reasons = { { kind = 'quest_active', questID = 78 }, { kind = 'profession', professions = { 164 } } } }
    end, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        line(tooltip, 1, 'Misión activa: Garras para el herrero')
    end)
    LibQuestieDB = nil
end)

test('Tooltip: reactivo del diario de misiones -> "Lo pide una misión activa"', function()
    addItem(500, { name = 'Garra afilada', quality = 1 })
    FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra afilada: 2/8', type = 'item' } } } }
    local processor = withProcessor()
    ns.Tooltip.Hook()
    withReagents({ [500] = { 164, 171 } }, function()
        local tooltip = newTooltip(500)
        run(processor, tooltip, {})
        eq(#tooltip.lines, 2)
        line(tooltip, 1, 'Lo pide una misión activa', { 1, 1, 1 })
        line(tooltip, 2, 'Profesión que no tenés: Herrería, Alquimia')
    end)
end)

test('Tooltip: aislamiento - el caso siguiente ve el GameTooltip limpio', function()
    ok(next(GameTooltip.scripts) == nil, 'sin scripts enganchados')
    eq(GameTooltip.lines, nil)
end)

-- Libros de biblioteca y cajones arrebatados: linea neutra (blanca, sin icono) con a quien
-- entregarlos; solo el PNJ de la faccion del jugador, los dos si no se sabe.
test('Tooltip: libro de biblioteca y cajon arrebatado segun la faccion', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    local book = { mark = nil, reasons = { { kind = 'library_book' } } }
    local crate = { mark = nil, reasons = { { kind = 'waylaid_crate' } } }
    local sealed = { mark = nil, reasons = { { kind = 'waylaid_crate', sealed = true } } }
    local cases = {
        { 'Horde', book, 'Libro de biblioteca: entregalo al bibliotecario (Owen Thadd en Entrañas)' },
        { 'Alliance', book, 'Libro de biblioteca: entregalo al bibliotecario (Garion Wendell en Ventormenta)' },
        { nil, book, 'Libro de biblioteca: entregalo al bibliotecario (Owen Thadd en Entrañas / Garion Wendell en Ventormenta)' },
        { 'Horde', crate, 'Cajón arrebatado: llenalo con una opción de la lista y entregalo a Dokimi (Encrucijada)' },
        { 'Alliance', crate, 'Cajón arrebatado: llenalo con una opción de la lista y entregalo a Marcy Baker (Crestagrana)' },
        { 'Neutral', crate, 'Cajón arrebatado: llenalo con una opción de la lista y entregalo a Dokimi (Encrucijada) / Marcy Baker (Crestagrana)' },
        { 'Alliance', sealed, 'Cajón arrebatado lleno: entregalo a Marcy Baker (Crestagrana)' },
    }
    for _, case in ipairs(cases) do
        FAKE.faction = case[1]
        withClassify(function() return case[2] end, function()
            local tooltip = newTooltip(100)
            run(processor, tooltip, {})
            eq(#tooltip.lines, 1)
            local entry = line(tooltip, 1, case[3], { 1, 1, 1 })
            eq(entry.text, case[3], 'sin icono')
        end)
    end
end)

test('Tooltip: libro sin UnitFactionGroup muestra los dos bibliotecarios', function()
    addItem(100, { quality = 1 })
    local processor = withProcessor()
    ns.Tooltip.Hook()
    UnitFactionGroup = nil
    withClassify(function() return { reasons = { { kind = 'library_book' } } } end, function()
        local tooltip = newTooltip(100)
        run(processor, tooltip, {})
        line(tooltip, 1, '(Owen Thadd en Entrañas / Garion Wendell en Ventormenta)')
    end)
end)

test('Tooltip: textos en ingles del libro y el cajon', function()
    local L = ns.L
    ok(rawget(L, 'Library book: turn it in to the librarian (%s)'), 'clave del libro')
    ok(rawget(L, 'Waylaid crate: fill it with one option from the list and turn it in to %s'), 'clave del cajon')
    ok(rawget(L, 'Sealed waylaid crate: turn it in to %s'), 'clave del cajon lleno')
    for _, key in ipairs({ 'Owen Thadd in Undercity', 'Garion Wendell in Stormwind', 'Dokimi (Crossroads)', 'Marcy Baker (Redridge)' }) do
        ok(rawget(L, key), 'clave ' .. key)
    end
end)
