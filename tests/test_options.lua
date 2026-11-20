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
    panel:SetSize(650, 500)
    panel:Show()
    return panel
end

local PATHS = { 'enabled','protectKeep','show.loot','show.protected','show.quest','show.hammer_mine','show.hammer_other','show.auction','show.coin','show.trash','show.useful','icons.background','rules.sellUnruled','rules.armorBelow','rules.food','rules.ammo','rules.knownRecipe','rules.gearNotRanked','autoSell.enabled','autoSell.graysOnly','autoRepair.enabled','autoRepair.guild','lootAdvisor.enabled' }

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

test('los interruptores incluyen protección del vendedor, en orden y con ayuda', function()
    eq(#ns.Options.TOGGLES, #PATHS)
    for index, path in ipairs(PATHS) do
        local toggle = ns.Options.TOGGLES[index]
        eq(toggle.path, path)
        ok(toggle.label, 'texto de ' .. path)
        if path:match('^show%.') and path ~= 'show.loot' then eq(toggle.help, nil)
        else ok(toggle.help, 'ayuda de ' .. path) end
    end
end)

test('pestañas: espera un ancho positivo y distribuye al mostrar por primera vez', function()
    local panel = ns.Options.Build()
    eq(panel:GetWidth(), 0)
    panel:Show()
    eq(panel.layoutCount, nil)
    for _, key in ipairs(ns.Options.TABS) do
        for _, frame in ipairs(panel.tabs[key].rows) do eq(frame:GetWidth(), 0) end
    end
    -- Simula que Settings le da tamaño antes del OnShow sin emitir OnSizeChanged.
    panel.w, panel.h = 650, 500
    panel:Show()
    ok(panel.layoutCount > 0)
    eq(panel.tabs.General.rows[1]:GetWidth(), 618)
end)

test('pestañas: recalcula ancho, alto medido y scroll cuando cambia el tamaño', function()
    local panel = ns.Options.Build()
    panel:SetSize(650, 500); panel:Show()
    local count = panel.layoutCount
    local help = panel.checks['rules.food'].help
    local height = help:GetHeight()
    panel:SetWidth(400)
    eq(panel.layoutCount, count + 1)
    eq(panel.tabs.Rules.rows[1]:GetWidth(), 368)
    eq(help:GetWidth(), 342)
    ok(help:GetHeight() > height)
    panel:SetHeight(220)
    ok(panel.tabs.Icons.limit > 0)
    local viewport = panel.tabs.Icons.viewport
    viewport:GetScript('OnMouseWheel')(viewport, -1000)
    eq(viewport:GetVerticalScroll(), panel.tabs.Icons.limit)
    panel:SetHeight(2000)
    eq(panel.tabs.Icons.limit, 0)
    eq(viewport:GetVerticalScroll(), 0)
    count = panel.layoutCount
    panel:SetWidth(0)
    eq(panel.layoutCount, count)
end)

test('pestañas: una sola página visible y selección persistente al reconstruir', function()
    local panel = ns.Options.Build(); panel:SetSize(650, 500); panel:Show()
    eq(ns.DB.ui.tab, 'General')
    for _, selected in ipairs(ns.Options.TABS) do
        panel.tabs[selected].button:GetScript('OnClick')()
        eq(ns.DB.ui.tab, selected)
        for _, key in ipairs(ns.Options.TABS) do
            eq(panel.tabs[key].viewport:IsVisible(), key == selected)
            eq(panel.tabs[key].highlight:IsShown(), key == selected)
        end
    end
    panel:Hide()
    ns.Options.ResetState()
    panel = ns.Options.Build(); panel:SetSize(650, 500); panel:Show()
    eq(panel.selectedTab, 'Marks')
    ns.DB.ui.tab = 'inexistente'
    ns.Options.ResetState()
    panel = ns.Options.Build(); panel:Show()
    eq(panel.selectedTab, 'General')
    eq(ns.Options.SelectTab('inexistente'), false)
end)

test('pestañas: anchos de texto explícitos y filas sin superposición en ambos idiomas', function()
    local realL = ns.L
    local success, err = pcall(function()
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            ns.Options.ResetState()
            local panel = ns.Options.Build()
            for _, width in ipairs({ 650, 400, 900 }) do
                panel:SetSize(width, 500); panel:Show()
                for _, key in ipairs(ns.Options.TABS) do
                    local page, bottom = panel.tabs[key], 0
                    for index, frame in ipairs(page.rows) do
                        local top = -frame.points[1][5]
                        eq(frame:GetWidth(), width - 32)
                        eq(frame.points[1][2], page.content)
                        eq(top, index == 1 and 0 or bottom + frame.before)
                        bottom = top + frame:GetHeight()
                        for _, text in ipairs(FAKE.frames) do
                            if text.parent == frame and text.kindType == 'FontString' then
                                ok(text.wordWrap)
                                eq(text.justifyH, 'LEFT')
                                ok(text:GetWidth() > 0)
                                eq(text.measuredWidth, text:GetWidth())
                                local x = text.points[1][4]
                                ok(x + text:GetWidth() <= frame:GetWidth() + .001)
                                ok(-text.points[1][5] + text:GetHeight() <= frame:GetHeight() + .001)
                            end
                        end
                    end
                    eq(page.content:GetHeight(), bottom)
                end
                for _, toggle in ipairs(ns.Options.TOGGLES) do
                    local check = panel.checks[toggle.path]
                    if check.help then eq(check.help:GetWidth(), width - 32 - 26) end
                end
                eq(panel.baganatorNote:GetWidth(), width - 32)
                for _, text in ipairs(panel.footer) do eq(text:GetWidth(), width - 32) end
            end
        end
    end)
    ns.L, FAKE.locale = realL, nil
    if not success then error(err, 0) end
end)

test('pestañas: tecla y colores comparten la fila con su etiqueta', function()
    ColorPickerFrame = { GetColorRGB = function() return 1, 1, 1 end, SetColorRGB = function() end }
    local panel = ns.Options.Build(); panel:SetSize(650, 500); panel:Show()
    eq(panel.bindingButton:GetParent(), panel.bindingRow)
    eq(panel.bindingLabel:GetParent(), panel.bindingRow)
    eq(panel.bindingKey:GetParent(), panel.bindingRow)
    eq(panel.bindingButton.points[1][2], panel.bindingRow)
    eq(panel.bindingButton.points[1][1], 'TOPRIGHT')
    eq(panel.bindingButton.points[1][5], panel.bindingLabel.points[1][5])
    for _, kind in ipairs(ns.IconKinds) do
        local check, swatch = panel.checks['show.' .. kind], panel.swatches[kind]
        eq(check.help, nil)
        eq(swatch:GetParent(), check.row)
        eq(check.label:GetParent(), check.row)
        eq(swatch.points[1][2], check.points[1][2])
        eq(swatch.points[1][5], check.points[1][5])
        eq(swatch.points[1][1], 'TOPRIGHT')
        eq(check.label:GetWidth(), check.row:GetWidth() - 26 - 30)
    end
    eq(panel.restoreColors.template, 'UIPanelButtonTemplate')
    eq(panel.restoreColors.bg[1], ns.KL:GetTheme().backdrop.r)
    local button = panel.bindingButton
    button:GetScript('OnClick')(button)
    ok(button.capturing)
    ns.Options.SelectTab('Rules')
    eq(button.capturing, false)
    eq(button.keyboard, false)
end)

test('pestañas: esquina en cuadrícula de dos por dos y controles a todo el ancho', function()
    local panel = ns.Options.Build(); panel:SetSize(650, 500); panel:Show()
    local controls = panel.controls
    local tl, tr = controls['icons.cornerTOPLEFT'].widget, controls['icons.cornerTOPRIGHT'].widget
    local bl, br = controls['icons.cornerBOTTOMLEFT'].widget, controls['icons.cornerBOTTOMRIGHT'].widget
    eq(tl.points[1][5], tr.points[1][5]); eq(bl.points[1][5], br.points[1][5])
    eq(tl.points[1][4], bl.points[1][4]); eq(tr.points[1][4], br.points[1][4])
    ok(bl.points[1][5] < tl.points[1][5])
    for _, path in ipairs({ 'icons.size', 'icons.opacity', 'auction.factor', 'auction.minCopper' }) do
        eq(controls[path].widget:GetWidth(), 650 - 32 - 16)
        eq(controls[path].label:GetWidth(), 650 - 32)
    end
    eq(panel.list:GetWidth(), 650 - 32 - 16)
end)

test('pestañas: nombres largos de marcas se envuelven sin tapar Quitar ni el pie', function()
    for id = 1, 12 do
        addItem(id, string.rep('Cristal de prueba ', id % 3 + 2))
        ns.DB.overrides[id] = 'sell'
    end
    local panel = ns.Options.Build(); panel:SetSize(400, 400); panel:Show()
    ns.Options.SelectTab('Marks')
    for offset = 0, panel.scroll.max do
        panel.scroll:SetValue(offset)
        local bottom = 0
        for _, frame in ipairs(panel.rows) do
            if frame:IsShown() then
                local top = -frame.points[1][5]
                ok(top >= bottom)
                ok(frame.name:GetHeight() + 8 <= frame:GetHeight())
                ok(frame.kind:GetHeight() + 8 <= frame:GetHeight())
                ok(frame.name:GetWidth() > 0)
                eq(frame.name.measuredWidth, frame.name:GetWidth())
                bottom = top + frame:GetHeight()
            end
        end
        ok(bottom <= panel.list:GetHeight())
    end
    local last
    for _, frame in ipairs(panel.rows) do if frame:IsShown() then last = frame.id end end
    eq(last, 12)
end)

test('pestañas: asignar una combinación larga vuelve a medir la fila de tecla', function()
    local panel = ns.Options.Build(); panel:SetSize(400, 500); panel:Show()
    local button = panel.bindingButton
    button:GetScript('OnClick')(button)
    FAKE.shift, FAKE.ctrl, FAKE.alt = true, true, true
    button:GetScript('OnKeyDown')(button, 'NUMPADDECIMAL')
    eq(panel.bindingKey:GetText(), 'SHIFT-CTRL-ALT-NUMPADDECIMAL')
    ok(panel.bindingKey:GetHeight() > 24)
    eq(panel.bindingKey:GetHeight(), panel.bindingKey:GetStringHeight())
    ok(panel.bindingKey:GetHeight() < -panel.bindingHelp.points[1][5])
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

test('las reglas de comida, munición y recetas arrancan prendidas en el panel', function()
    local panel = openPanel()
    for _, path in ipairs({ 'rules.food', 'rules.ammo', 'rules.knownRecipe' }) do
        eq(panel.checks[path]:GetChecked(), true, path)
    end
    for _, path in ipairs({ 'enabled', 'show.coin', 'show.hammer_mine', 'show.loot' }) do
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
    ns.DB.show.hammer_mine = false; ns.DB.rules.ammo = true
    panel.scripts.OnShow(panel)
    eq(panel.checks['show.hammer_mine']:GetChecked(), false)
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
    eq(rows[1].id, 7); eq(rows[1].name:GetText(), 'Hierro'); eq(rows[1].kind:GetText(), ns.L['Protected'])
    eq(rows[1].icon.texture, 'icon')
    eq(rows[2].id, 42); eq(rows[2].name:GetText(), 'Gema'); eq(rows[2].kind:GetText(), ns.L['Sell (legacy mark)'])
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
    eq(panel.empty:GetText(), ns.L['No manual marks yet. Choose a key in General to change the mark under the mouse.'])
    eq(panel.empty:GetText(), 'Todavía no hay marcas manuales. Asigná una tecla en General para cambiar la marca del ítem bajo el mouse.')
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
        local keys = { 'Marks', 'Optional rules (off by default)', 'Manual marks', 'Protected', 'Sell (legacy mark)', 'Remove',
            'Item %d', 'No manual marks yet. Choose a key in General to change the mark under the mouse.' }
        for _, toggle in ipairs(ns.Options.TOGGLES) do keys[#keys + 1] = toggle.label; keys[#keys + 1] = toggle.help end
        for _, key in ipairs(keys) do ok(ns.L[key] ~= key, 'sin traducir: ' .. key) end
        eq(ns.L['Marks'], 'Marcas'); eq(ns.L['Remove'], 'Quitar'); eq(ns.L['Protected'], 'Protegido'); eq(ns.L['Sell (legacy mark)'], 'Vender (marca vieja)')
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
        eq(panel.checks['show.hammer_mine'].label:GetText(), 'Material de tu profesión')
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
