-- Panel de opciones: interruptores, lista de marcas manuales, registro en la API de opciones y /knu junk.
local realInvalidate, realRefresh = ns.Player.Invalidate, ns.Bags.RefreshAll

-- Cuenta las veces que se ensucia el contexto y se pide repintar; siempre restaura lo real.
local function withSpy(fn)
    local state = { invalidate = 0, refresh = 0 }
    ns.Player.Invalidate = function() state.invalidate = state.invalidate + 1 end
    ns.Bags.RefreshAll = function() state.refresh = state.refresh + 1 end
    local success, err = pcall(fn, state)
    ns.Player.Invalidate, ns.Bags.RefreshAll = realInvalidate, realRefresh
    if not success then error(err, 0) end
end

local function addItem(id, name)
    FAKE.items[id] = { name = name or ('Item' .. id), quality = 1, price = 10, classID = 15, subclassID = 0 }
end

local function withLocale(locale, fn)
    local realL = ns.L
    FAKE.locale = locale
    local success, err = pcall(function()
        assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
        fn()
    end)
    FAKE.locale = nil
    ns.L = realL
    if not success then error(err, 0) end
end

-- Panel construido y a la vista (el panel real nace oculto y lo muestra la ventana de opciones).
local function openPanel()
    local panel = ns.Options.Build()
    panel:Show()
    return panel
end

local PATHS = { 'enabled', 'show.coin', 'show.hammer', 'show.loot', 'rules.food', 'rules.ammo', 'rules.knownRecipe' }

local function lookup(path)
    local value = ns.DB
    for key in path:gmatch('[^.]+') do value = value[key] end
    return value
end

local function visibleRows(panel)
    local shown = {}
    for _, row in ipairs(panel.rows) do if row:IsShown() then shown[#shown + 1] = row end end
    return shown
end

test('los interruptores son los siete de la DB, en orden y con ayuda', function()
    eq(#ns.Options.TOGGLES, #PATHS)
    for index, path in ipairs(PATHS) do
        local toggle = ns.Options.TOGGLES[index]
        eq(toggle.path, path)
        ok(toggle.label and toggle.help, 'texto de ' .. path)
    end
end)

test('Get lee la DB y Set la cambia y refresca una sola vez', function()
    withSpy(function(state)
        for _, path in ipairs(PATHS) do
            local before = lookup(path)
            state.invalidate, state.refresh = 0, 0
            ns.Options.Set(path, not before)
            eq(lookup(path), not before, path)
            eq(ns.Options.Get(path), not before, path)
            eq(state.invalidate, 1, 'invalidate ' .. path); eq(state.refresh, 1, 'refresh ' .. path)
        end
    end)
end)

test('Set con el mismo valor o con una ruta desconocida no toca nada', function()
    withSpy(function(state)
        ns.Options.Set('show.coin', true)
        ns.Options.Set('show.nada', true)
        ns.Options.Set('foo', true)
        eq(state.invalidate, 0); eq(state.refresh, 0)
        eq(ns.DB.show.nada, nil); eq(ns.DB.foo, nil)
    end)
end)

test('las reglas opcionales arrancan apagadas en el panel', function()
    local panel = openPanel()
    for _, path in ipairs({ 'rules.food', 'rules.ammo', 'rules.knownRecipe' }) do
        eq(panel.checks[path]:GetChecked(), false, path)
    end
    for _, path in ipairs({ 'enabled', 'show.coin', 'show.hammer', 'show.loot' }) do
        eq(panel.checks[path]:GetChecked(), true, path)
    end
end)

test('Build es idempotente y crea una casilla por interruptor', function()
    local panel = ns.Options.Build()
    eq(ns.Options.Build(), panel)
    for _, path in ipairs(PATHS) do ok(panel.checks[path], 'casilla de ' .. path) end
end)

test('al mostrar el panel las casillas se leen de la DB', function()
    local panel = ns.Options.Build()
    ns.DB.show.hammer = false; ns.DB.rules.ammo = true
    panel.scripts.OnShow(panel)
    eq(panel.checks['show.hammer']:GetChecked(), false)
    eq(panel.checks['rules.ammo']:GetChecked(), true)
    eq(panel.checks['enabled']:GetChecked(), true)
end)

test('clic en una casilla cambia la DB y refresca una sola vez', function()
    local panel = openPanel()
    withSpy(function(state)
        for _, path in ipairs(PATHS) do
            local check = panel.checks[path]
            local before = lookup(path)
            state.invalidate, state.refresh = 0, 0
            check:SetChecked(not before) -- el cliente cambia la casilla antes de OnClick
            check.scripts.OnClick(check)
            eq(lookup(path), not before, path)
            eq(state.invalidate, 1, path); eq(state.refresh, 1, path)
            eq(check:GetChecked(), not before, path)
        end
    end)
end)

test('un cambio por comando se ve en el panel abierto', function()
    local panel = openPanel()
    ns.Commands.Handle('coin off')
    eq(panel.checks['show.coin']:GetChecked(), false)
    ns.Commands.Handle('rules food on')
    eq(panel.checks['rules.food']:GetChecked(), true)
end)

test('OverrideRows arma las filas desde la DB, ordenadas por itemID y sin claves raras', function()
    ns.DB.overrides[300] = 'sell'; ns.DB.overrides[7] = 'keep'; ns.DB.overrides[42] = 'sell'
    ns.DB.overrides.texto = 'keep'
    local rows = ns.Options.OverrideRows()
    eq(#rows, 3)
    eq(rows[1].id, 7); eq(rows[1].action, 'keep')
    eq(rows[2].id, 42); eq(rows[2].action, 'sell')
    eq(rows[3].id, 300); eq(rows[3].action, 'sell')
end)

test('la lista del panel muestra icono, nombre y accion de cada marca manual', function()
    addItem(7, 'Hierro'); addItem(42, 'Gema')
    ns.DB.overrides[7] = 'keep'; ns.DB.overrides[42] = 'sell'
    local panel = openPanel()
    local rows = visibleRows(panel)
    eq(#rows, 2)
    eq(rows[1].id, 7); eq(rows[1].name:GetText(), 'Hierro'); eq(rows[1].kind:GetText(), ns.L['Keep'])
    eq(rows[1].icon.texture, 'icon')
    eq(rows[2].id, 42); eq(rows[2].name:GetText(), 'Gema'); eq(rows[2].kind:GetText(), ns.L['Sell'])
    eq(panel.empty:IsShown(), false)
end)

test('un item que el cliente aun no conoce muestra su ID', function()
    ns.DB.overrides[999] = 'sell'
    local panel = openPanel()
    local row = visibleRows(panel)[1]
    eq(row.name:GetText(), string.format(ns.L['Item %d'], 999))
    ok(row.icon.texture ~= nil, 'icono de reemplazo')
end)

test('sin marcas manuales se ve el texto de lista vacia', function()
    local panel = openPanel()
    eq(#visibleRows(panel), 0)
    eq(panel.empty:IsShown(), true)
    eq(panel.empty:GetText(), ns.L['No manual marks yet. Assign a key above to change an item mark under the mouse.'])
    eq(panel.empty:GetText(), 'Todavía no hay marcas manuales. Asigná una tecla arriba para cambiar la marca del ítem bajo el mouse.')
end)

test('Quitar borra esa marca, refresca una vez y actualiza la lista', function()
    addItem(7, 'Hierro'); addItem(42, 'Gema')
    ns.DB.overrides[7] = 'keep'; ns.DB.overrides[42] = 'sell'
    local panel = openPanel()
    withSpy(function(state)
        local row = visibleRows(panel)[1]
        row.remove.scripts.OnClick(row.remove)
        eq(ns.DB.overrides[7], nil); eq(ns.DB.overrides[42], 'sell')
        eq(state.invalidate, 1); eq(state.refresh, 1)
    end)
    local rows = visibleRows(panel)
    eq(#rows, 1); eq(rows[1].id, 42)
    local last = rows[1]
    last.remove.scripts.OnClick(last.remove)
    eq(next(ns.DB.overrides), nil)
    eq(#visibleRows(panel), 0)
    eq(panel.empty:IsShown(), true)
end)

test('RemoveOverride de un item sin marca no refresca', function()
    withSpy(function(state)
        eq(ns.Options.RemoveOverride(555), false)
        eq(state.invalidate, 0); eq(state.refresh, 0)
    end)
end)

test('la lista scrollea: filas visibles segun el alto, rueda y barra', function()
    for id = 1, 10 do ns.DB.overrides[id] = 'sell' end
    local panel = openPanel()
    panel.list:SetHeight(24 * 4)
    ns.Options.Refresh()
    eq(#visibleRows(panel), 4)
    eq(visibleRows(panel)[1].id, 1)
    eq(panel.scroll.max, 6)
    eq(panel.scroll:IsShown(), true)
    panel.list.scripts.OnMouseWheel(panel.list, -1)
    eq(visibleRows(panel)[1].id, 2)
    panel.scroll:SetValue(6)
    eq(visibleRows(panel)[1].id, 7)
    eq(visibleRows(panel)[4].id, 10)
    panel.list.scripts.OnMouseWheel(panel.list, -1) -- tope
    eq(visibleRows(panel)[1].id, 7)
    panel.list.scripts.OnMouseWheel(panel.list, 5)
    eq(visibleRows(panel)[1].id, 6)
end)

test('al borrar marcas el scroll se acomoda y la barra se esconde si ya no hace falta', function()
    for id = 1, 6 do ns.DB.overrides[id] = 'keep' end
    local panel = openPanel()
    panel.list:SetHeight(24 * 4)
    ns.Options.Refresh()
    panel.scroll:SetValue(2)
    eq(visibleRows(panel)[1].id, 3)
    for id = 1, 4 do ns.Options.RemoveOverride(id) end
    eq(#visibleRows(panel), 2)
    eq(visibleRows(panel)[1].id, 5)
    eq(panel.scroll:IsShown(), false)
end)

test('VisibleRows acota el alto a un minimo, un maximo y un valor por defecto', function()
    eq(ns.Options.VisibleRows(0), 6)
    eq(ns.Options.VisibleRows(nil), 6)
    eq(ns.Options.VisibleRows(24 * 5), 5)
    eq(ns.Options.VisibleRows(24 * 5 + 10), 5)
    eq(ns.Options.VisibleRows(30), 1)
    eq(ns.Options.VisibleRows(10), 1)
    eq(ns.Options.VisibleRows(24 * 100), ns.Options.MAX_ROWS)
end)

test('GET_ITEM_INFO_RECEIVED rellena el nombre que faltaba mientras el panel esta abierto', function()
    ns.DB.overrides[500] = 'sell'
    local panel = openPanel()
    eq(visibleRows(panel)[1].name:GetText(), string.format(ns.L['Item %d'], 500))
    addItem(500, 'Cristal')
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 500, true)
    FAKE.Advance(1)
    eq(visibleRows(panel)[1].name:GetText(), 'Cristal')
end)

test('el pie muestra build de datos, QuestieDB y adaptadores como /knu junk status', function()
    local panel = openPanel()
    local info = ns.Options.StatusInfo()
    eq(info.build, tostring(ns.Data.build or '?'))
    eq(panel.footer[1]:GetText(), string.format(ns.L['Data build: %s'], info.build))
    eq(panel.footer[2]:GetText(), string.format(ns.L['QuestieDB: %s, index ready: %s'], ns.L['no'], ns.L['no']))
    eq(panel.footer[3]:GetText(), string.format(ns.L['Bag adapters: %s'], ns.L['none']))
    FAKE.InstallBaganator(); ns.Bags.InstallAll()
    ns.Options.Refresh()
    local adapters = table.concat(ns.Bags.Installed(), ', ')
    ok(#adapters > 0)
    eq(panel.footer[3]:GetText(), string.format(ns.L['Bag adapters: %s'], adapters))
end)

test('Status del comando usa los mismos datos que el panel', function()
    FAKE.messages = {}
    ns.Commands.Status()
    local text = table.concat(FAKE.messages, '\n')
    ok(text:find(string.format(ns.L['Data build: %s'], ns.Options.StatusInfo().build), 1, true))
end)

test('todos los textos del panel tienen traduccion al castellano', function()
    withLocale('esES', function()
        local keys = { 'Marks', 'Optional rules (off by default)', 'Manual marks', 'Keep', 'Sell', 'Remove',
            'Item %d', 'No manual marks yet. Assign a key above to change an item mark under the mouse.' }
        for _, toggle in ipairs(ns.Options.TOGGLES) do keys[#keys + 1] = toggle.label; keys[#keys + 1] = toggle.help end
        for _, key in ipairs(keys) do ok(ns.L[key] ~= key, 'sin traducir: ' .. key) end
        eq(ns.L['Marks'], 'Marcas'); eq(ns.L['Remove'], 'Quitar'); eq(ns.L['Keep'], 'Guardar'); eq(ns.L['Sell'], 'Vender')
    end)
    withLocale('enUS', function()
        eq(ns.L['Marks'], 'Marks'); eq(ns.L['Remove'], 'Remove')
        local panel = ns.Options.Build()
        eq(panel.title:GetText(), 'KnuJunk')
    end)
end)

test('el panel se construye con los textos del idioma del cliente', function()
    withLocale('esES', function()
        local panel = ns.Options.Build()
        eq(panel.checks['enabled'].label:GetText(), 'Activar KnuJunk')
        eq(panel.checks['show.coin'].label:GetText(), 'Monedita')
        eq(panel.checks['show.hammer'].label:GetText(), 'Martillito')
        eq(panel.checks['show.loot'].label:GetText(), 'Marcas en el botín')
        eq(panel.checks['rules.food'].label:GetText(), 'Comida y bebida superadas')
        eq(panel.checks['rules.ammo'].label:GetText(), 'Munición superada')
        eq(panel.checks['rules.knownRecipe'].label:GetText(), 'Recetas ya aprendidas')
    end)
end)

-- Registro en la API de opciones.

test('Register registra una categoria KnuJunk con la API moderna (Settings)', function()
    local category = ns.Options.Register()
    eq(#FAKE.settings.registered, 1)
    eq(FAKE.settings.registered[1].name, 'KnuJunk')
    eq(FAKE.settings.registered[1].panel, ns.Options.panel)
    eq(#FAKE.settings.added, 1)
    eq(FAKE.settings.added[1], category)
    eq(ns.Options.flavor, 'settings')
    eq(ns.Options.panel.name, 'KnuJunk')
end)

test('Register es idempotente', function()
    ns.Options.Register(); ns.Options.Register()
    eq(#FAKE.settings.registered, 1); eq(#FAKE.settings.added, 1)
end)

test('Register usa InterfaceOptions_AddCategory si no hay Settings', function()
    FAKE.InstallClassicOptions()
    ns.Options.Register()
    eq(#FAKE.interfaceOptions.added, 1)
    eq(FAKE.interfaceOptions.added[1], ns.Options.panel)
    eq(ns.Options.flavor, 'interface')
    eq(ns.Options.panel.name, 'KnuJunk')
end)

test('sin ninguna API de opciones no falla y avisa al abrir', function()
    FAKE.Remove('Settings')
    local category = ns.Options.Register()
    eq(category, nil); eq(ns.Options.flavor, nil)
    eq(ns.Options.Open(), false)
    ok(#FAKE.messages > 0, 'avisa')
end)

test('si la API de registro lanza error no se rompe nada', function()
    Settings.RegisterCanvasLayoutCategory = function() error('API rota') end
    local success = pcall(ns.Options.Register)
    ok(success)
    eq(ns.Options.category, nil)
end)

test('el login registra el panel', function()
    -- Se recarga Options.lua capturando ns.OnLogin y se corre el handler como lo haria PLAYER_LOGIN.
    local realOptions, realOnLogin = ns.Options, ns.OnLogin
    local captured = {}
    ns.OnLogin = function(fn) captured[#captured + 1] = fn end
    local success, err = pcall(function() assert(loadfile('Options.lua'))('KnuJunk', ns) end)
    ns.OnLogin = realOnLogin
    local fresh = ns.Options
    ns.Options = realOptions
    ok(success, tostring(err))
    eq(#captured, 1, 'un solo handler de login')
    eq(#FAKE.settings.registered, 0, 'nada registrado antes del login')
    captured[1]()
    eq(#FAKE.settings.registered, 1)
    eq(FAKE.settings.registered[1].name, 'KnuJunk')
    eq(fresh.flavor, 'settings')
end)

test('el panel trae los hooks de la API moderna y de la clasica', function()
    local panel = ns.Options.Build()
    for _, name in ipairs({ 'OnRefresh', 'OnCommit', 'OnDefault', 'refresh', 'okay', 'cancel', 'default' }) do
        eq(type(panel[name]), 'function', name)
    end
    ns.DB.show.loot = false
    panel.OnRefresh()
    eq(panel.checks['show.loot']:GetChecked(), false)
    ns.DB.show.loot = true
    panel.refresh()
    eq(panel.checks['show.loot']:GetChecked(), true)
end)

-- Abrir el panel.

test('Open abre la categoria con Settings.OpenToCategory', function()
    local category = ns.Options.Register()
    eq(ns.Options.Open(), true)
    eq(#FAKE.settings.opened, 1)
    eq(FAKE.settings.opened[1], category:GetID())
end)

test('Open registra el panel si todavia no estaba', function()
    eq(ns.Options.category, nil)
    eq(ns.Options.Open(), true)
    eq(#FAKE.settings.registered, 1)
    eq(#FAKE.settings.opened, 1)
end)

test('en combate Open no llama a Settings.OpenToCategory y avisa', function()
    ns.Options.Register()
    FAKE.inCombat = true
    FAKE.messages = {}
    eq(ns.Options.Open(), false)
    eq(#FAKE.settings.opened, 0)
    eq(#FAKE.messages, 1)
    eq(FAKE.messages[1], '|cffecd9bdKNU|r|cffffa82eJunk|r: ' .. ns.L['Options open after combat: Esc > Options > AddOns > KnuJunk'])
end)

test('con ForeverSettings se abre aunque haya combate', function()
    local opened = {}
    ForeverSettings = { OpenPage = function(id) opened[#opened + 1] = id; return true end }
    local category = ns.Options.Register()
    FAKE.inCombat = true
    eq(ns.Options.Open(), true)
    eq(opened[1], category:GetID())
    eq(#FAKE.settings.opened, 0)
end)

test('si ForeverSettings no abre la pagina se cae a Settings', function()
    ForeverSettings = { OpenPage = function() return false end }
    ns.Options.Register()
    eq(ns.Options.Open(), true)
    eq(#FAKE.settings.opened, 1)
end)

test('en el cliente clasico Open usa InterfaceOptionsFrame_OpenToCategory', function()
    FAKE.InstallClassicOptions()
    ns.Options.Register()
    eq(ns.Options.Open(), true)
    eq(#FAKE.interfaceOptions.opened, 2, 'dos llamadas: la primera solo abre la ventana')
    eq(FAKE.interfaceOptions.opened[1], ns.Options.panel)
end)

test('si OpenToCategory lanza error Open avisa y no rompe', function()
    ns.Options.Register()
    Settings.OpenToCategory = function() error('bloqueado') end
    FAKE.messages = {}
    local value
    local success = pcall(function() value = ns.Options.Open() end)
    ok(success)
    eq(value, false)
    ok(#FAKE.messages > 0)
end)

-- /knu junk

test('/knu junk sin argumentos abre el panel y no imprime la ayuda', function()
    ns.Options.Register()
    FAKE.messages = {}
    ns.Commands.Handle('')
    eq(#FAKE.settings.opened, 1)
    eq(#FAKE.messages, 0)
    ns.Commands.Handle('   ')
    eq(#FAKE.settings.opened, 2)
    ns.Commands.Handle(nil)
    eq(#FAKE.settings.opened, 3)
end)

test('/knu junk options tambien abre el panel', function()
    ns.Options.Register()
    ns.Commands.Handle('options')
    ns.Commands.Handle('OPCIONES')
    eq(#FAKE.settings.opened, 2)
end)

test('/knu junk help imprime la ayuda, con la linea del panel', function()
    FAKE.messages = {}
    ns.Commands.Handle('help')
    eq(#FAKE.messages, 6)
    eq(#FAKE.settings.opened, 0)
    local text = table.concat(FAKE.messages, '\n')
    ok(text:find(ns.L['Options panel: /knu junk'], 1, true), 'linea del panel')
    ok(text:find(ns.L['Show state: /knu junk status'], 1, true))
end)

test('el panel no llama a funciones protegidas ni usa plantillas seguras', function()
    local file = assert(io.open('Options.lua', 'r'))
    local source = file:read('*a'); file:close()
    for _, forbidden in ipairs({ 'Secure', 'SetAttribute', 'RegisterStateDriver', 'ClearTarget', 'UseContainerItem',
        'PickupContainerItem', 'CastSpellByName' }) do
        ok(not source:find(forbidden, 1, true), 'usa ' .. forbidden)
    end
end)

test('al cambiar el tema de KnuLib el panel se repinta', function()
    local KL = ns.KL
    local panel = openPanel()
    local before = panel.title.textColor[1]
    local previous = KL.themeKey
    KL:SetThemeKey('neon')
    local after = panel.title.textColor[1]
    local expected = KL.themes.neon.accent.r
    KL:SetThemeKey(previous)
    eq(after, expected)
    ok(before ~= after, 'el color cambio')
    eq(panel.title.textColor[1], KL.themes[previous].accent.r)
end)

test('el panel usa la fuente de KnuLib y los estilos de KnuLib', function()
    local panel = ns.Options.Build()
    eq(panel.title.font[1], ns.KL:GetFont())
    ok(panel.backdrop ~= nil, 'StylePanel puso el fondo')
    ok(panel.checks['enabled'].backdrop ~= nil, 'StyleCheck puso el fondo')
    ok(panel.rows[1].remove.backdrop ~= nil, 'StyleButton puso el fondo')
end)

test('Quitar y el panel siguen andando con una KnuLib vieja sin StyleCheck ni GetTheme', function()
    local KL = ns.KL
    local a, b, c, d = KL.StyleCheck, KL.StyleButton, KL.GetTheme, KL.GetFont
    KL.StyleCheck, KL.StyleButton, KL.GetTheme, KL.GetFont = nil, nil, nil, nil
    local success, err = pcall(function()
        local panel = openPanel()
        ns.DB.overrides[5] = 'sell'
        ns.Options.Refresh()
        eq(#visibleRows(panel), 1)
    end)
    KL.StyleCheck, KL.StyleButton, KL.GetTheme, KL.GetFont = a, b, c, d
    ok(success, tostring(err))
end)

test('API clasica: en combate no abre opciones y avisa', function()
    ns.Options.ResetState()
    FAKE.InstallClassicOptions()
    FAKE.inCombat = true
    local good, err = pcall(function()
        eq(ns.Options.Open(), false)
        eq(#FAKE.interfaceOptions.opened, 0)
    end)
    FAKE.inCombat = false
    ns.Options.ResetState()
    if not good then error(err, 0) end
end)

test('Lista baja: las filas visibles caben en el alto y el resto se recorre', function()
    ns.DB.overrides = {[1]='keep', [2]='sell', [3]='keep'}
    local panel = ns.Options.Build()
    panel.list:SetHeight(30)
    panel:Show()
    local count = 0
    for _, row in ipairs(panel.rows) do if row:IsShown() then count = count + 1 end end
    ok(count * 24 <= 30, 'filas caben')
    eq(panel.scroll.max, 2)
end)
