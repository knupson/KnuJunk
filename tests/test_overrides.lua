local ACTION = 'KNUJUNK_CYCLE_HOVERED'
local function capture()
    local panel = ns.Options.Build()
    panel:Show()
    local button = panel.bindingButton
    button:GetScript('OnClick')(button)
    return button, panel
end
local function key(button, value) button:GetScript('OnKeyDown')(button, value) end

test('ciclo automatico guardar vender automatico con un Changed por paso', function()
    local real, calls = ns.Changed, 0
    ns.Changed = function() calls = calls + 1 end
    local success, err = pcall(function()
        eq(ns.Overrides.Cycle(123), 'keep'); eq(calls, 1)
        eq(ns.Overrides.Cycle(123), nil); eq(calls, 2)
        ns.DB.overrides[123] = 'sell'
        eq(ns.Overrides.Cycle(123), nil); eq(calls, 3)
        eq(ns.DB.overrides[123], nil)
    end)
    ns.Changed = real
    if not success then error(err) end
end)

test('sin hover avisa sin cambiar marcas', function()
    KnuJunk_CycleHovered()
    eq(next(ns.DB.overrides), nil)
    eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find(ns.L['Hover an item first, then press the key'], 1, true))
end)

test('con hover informa cada estado y usa fallback sin cache', function()
    ns.Overrides.hovered = 123
    for _, text in ipairs({ 'Protected: %s', 'Automatic: %s', 'Protected: %s' }) do
        KnuJunk_CycleHovered()
        ok(FAKE.messages[#FAKE.messages]:find(string.format(ns.L[text], string.format(ns.L['item %d'], 123)), 1, true))
    end
end)

test('hover usa enlace cuando el item esta cargado', function()
    FAKE.items[123] = { name = 'Prueba', quality = 1, price = 1 }
    ns.Overrides.hovered = 123
    KnuJunk_CycleHovered()
    local _, link = GetItemInfo(123)
    ok(FAKE.messages[1]:find(link, 1, true))
end)

test('tooltip registra solo GameTooltip y limpia hide y cleared', function()
    ItemRefTooltip = CreateFrame('Tooltip')
    ns.Tooltip.Hook()
    ns.Tooltip.Decorate(ItemRefTooltip, { hyperlink = 'item:456' })
    eq(ns.Overrides.hovered, nil)
    ns.Tooltip.Decorate(GameTooltip, { hyperlink = 'item:123' })
    eq(ns.Overrides.hovered, 123)
    ns.Tooltip.Decorate(ItemRefTooltip, { hyperlink = 'item:456' })
    eq(ns.Overrides.hovered, 123)
    ItemRefTooltip:Hide(); eq(ns.Overrides.hovered, 123)
    GameTooltip:Hide(); eq(ns.Overrides.hovered, nil)
    ns.Tooltip.Decorate(GameTooltip, { hyperlink = 'item:456' })
    GameTooltip:GetScript('OnTooltipCleared')(GameTooltip)
    eq(ns.Overrides.hovered, nil)
end)

test('comandos y quitar en opciones usan setter compartido', function()
    local real, calls = ns.Overrides.Set, 0
    ns.Overrides.Set = function(id, value) calls = calls + 1; real(id, value) end
    local success, err = pcall(function()
        ns.Commands.Handle('keep 123'); eq(ns.DB.overrides[123], 'keep')
        ns.Commands.Handle('sell 123'); eq(ns.DB.overrides[123], 'sell')
        ns.Commands.Handle('clear 123'); eq(ns.DB.overrides[123], nil)
        ns.Commands.Handle('keep 123'); ns.Options.RemoveOverride(123)
        eq(ns.DB.overrides[123], nil); eq(calls, 5)
    end)
    ns.Overrides.Set = real
    if not success then error(err) end
end)

test('captura ignora modificadores y asigna SHIFT-K y guarda conjunto', function()
    local button, panel = capture()
    for _, modifier in ipairs({ 'LSHIFT', 'RSHIFT', 'LCTRL', 'RCTRL', 'LALT', 'RALT' }) do
        key(button, modifier); ok(button.capturing); eq(next(FAKE.bindings), nil)
    end
    FAKE.shift = true
    key(button, 'K')
    eq(FAKE.bindings['SHIFT-K'], ACTION); eq(FAKE.savedBindings[1], 2)
    eq(#FAKE.savedBindings, 1); eq(button.keyboard, false)
    eq(panel.bindingKey:GetText(), 'SHIFT-K')
end)

test('captura incluye todos los modificadores en orden', function()
    local button = capture()
    FAKE.shift, FAKE.ctrl, FAKE.alt = true, true, true
    key(button, 'K'); eq(FAKE.bindings['SHIFT-CTRL-ALT-K'], ACTION)
end)

test('Escape cancela captura y no asigna', function()
    local button = capture()
    key(button, 'ESCAPE'); eq(button.capturing, false); eq(button.keyboard, false)
    eq(next(FAKE.bindings), nil); eq(#FAKE.savedBindings, 0)
    key(button, 'K'); eq(next(FAKE.bindings), nil)
end)

test('combate rechaza al iniciar y al terminar captura', function()
    FAKE.inCombat = true
    local button = capture(); eq(button.capturing, false)
    FAKE.inCombat = false
    button:GetScript('OnClick')(button)
    FAKE.inCombat = true
    key(button, 'K'); eq(button.capturing, false)
    eq(next(FAKE.bindings), nil); eq(#FAKE.savedBindings, 0)
    ok(FAKE.messages[#FAKE.messages]:find(ns.L['Not in combat'], 1, true))
end)

test('conflicto informa accion anterior', function()
    FAKE.bindings.K = 'JUMP'
    local button = capture(); key(button, 'K')
    eq(FAKE.bindings.K, ACTION)
    ok(FAKE.messages[1]:find('JUMP', 1, true))
    ok(FAKE.messages[1]:find('K', 1, true))
end)

test('ocultar panel cancela captura', function()
    local button, panel = capture(); panel:Hide()
    eq(button.capturing, false); eq(button.keyboard, false)
end)

test('panel muestra tecla actual y actualiza ante UPDATE_BINDINGS', function()
    local panel = ns.Options.Build(); panel:Show()
    eq(panel.bindingKey:GetText(), ns.L['No key assigned'])
    FAKE.bindings.K = ACTION; FAKE.Fire('UPDATE_BINDINGS')
    eq(panel.bindingKey:GetText(), 'K')
end)

test('APIs ausentes o con error no lanzan y terminan captura', function()
    for _, api in ipairs({ 'SetBinding', 'SaveBindings', 'GetCurrentBindingSet' }) do
        local real = _G[api]
        _G[api] = nil
        local button = capture(); key(button, 'K'); eq(button.capturing, false)
        _G[api] = function() error('fallo simulado') end
        button = capture(); key(button, 'K'); eq(button.capturing, false)
        _G[api] = real
    end
end)

test('binding XML llama al global y no esta en el toc', function()
    local file = assert(io.open('Bindings.xml', 'r'))
    local xml = file:read('*a'); file:close()
    ok(xml:find('name="' .. ACTION .. '"', 1, true))
    ok(xml:find('header="KNUJUNK"', 1, true))
    ok(xml:find('KnuJunk_CycleHovered()', 1, true))
    file = assert(io.open('KnuJunk.toc', 'r'))
    local toc = file:read('*a'); file:close()
    eq(toc:find('Bindings.xml', 1, true), nil)
    eq(BINDING_HEADER_KNUJUNK, 'KnuJunk')
    eq(BINDING_NAME_KNUJUNK_CYCLE_HOVERED, ns.L['Protect / unprotect the item under the mouse'])
end)

test('hover moderno funciona sin lineas y sin marcas activadas', function()
    local callback
    Enum = { TooltipDataType = { Item = 0 } }
    TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) callback = fn end }
    ns.Tooltip.Hook()
    ns.DB.enabled = false
    callback(GameTooltip, { hyperlink = 'item:123' })
    eq(ns.Overrides.hovered, 123)
    callback(CreateFrame('Tooltip'), { hyperlink = 'item:456' })
    eq(ns.Overrides.hovered, 123)
    GameTooltip:Hide(); eq(ns.Overrides.hovered, nil)
end)

test('tecla asignada no agrega pistas al tooltip automatico', function()
    FAKE.items[123] = { name = 'Prueba', quality = 1, price = 1, classID = 15, subclassID = 0 }
    local _, link = GetItemInfo(123)
    local before = ns.Tooltip.Lines(link)
    FAKE.bindings.K = ACTION
    local after = ns.Tooltip.Lines(link)
    eq(#after, #before)
    for i, line in ipairs(before) do eq(after[i].text, line.text) end
end)

test('fallo al asignar no guarda ni anuncia conflicto', function()
    FAKE.bindings.K = 'JUMP'
    SetBinding = function() return false end
    local button = capture(); key(button, 'K')
    eq(FAKE.bindings.K, 'JUMP'); eq(#FAKE.savedBindings, 0)
    eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find(ns.L['Could not assign key'], 1, true))
end)

test('traducciones nuevas cubren esES esMX y enUS', function()
    local realL = ns.L
    local success, err = pcall(function()
        for _, locale in ipairs({ 'esES', 'esMX', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            eq(ns.L['Protect / unprotect the item under the mouse'], locale == 'enUS'
                and 'Protect / unprotect the item under the mouse' or 'Proteger / desproteger el ítem bajo el mouse')
            eq(ns.L['Hover an item first, then press the key'], locale == 'enUS'
                and 'Hover an item first, then press the key' or 'Pasá el mouse por un ítem y apretá la tecla')
            eq(ns.L['Press a key... (Esc cancels)'], locale == 'enUS'
                and 'Press a key... (Esc cancels)' or 'Apretá una tecla... (Esc cancela)')
        end
    end)
    ns.L, FAKE.locale = realL, nil
    if not success then error(err) end
end)

test('Asignar una tecla nueva libera la anterior de la misma accion', function()
    FAKE.bindings.K = 'KNUJUNK_CYCLE_HOVERED'
    local panel = ns.Options.Build(); panel:Show()
    local button = panel.bindingButton
    button.scripts.OnClick(button)
    button.scripts.OnKeyDown(button, 'J')
    eq(FAKE.bindings.J, 'KNUJUNK_CYCLE_HOVERED'); eq(FAKE.bindings.K, nil)
end)
