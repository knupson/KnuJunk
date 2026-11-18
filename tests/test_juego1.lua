local function addItem(id, price, quality, classID)
    FAKE.items[id] = { name = 'Prueba', price = price, quality = quality or 1,
        classID = classID or 12, subclassID = 0 }
    FAKE.bags['0:1'] = id
    FAKE.guids['0:1'] = 'juego1-' .. id
end

local function tooltip(id)
    local tip = GameTooltip
    tip.lines = {}
    function tip:GetItem() return 'Prueba', FAKE.linkOf(id) end
    function tip:GetBagItem() return 0, 1 end
    function tip:AddLine(text) self.lines[#self.lines + 1] = text end
    ns.Tooltip.Hook()
    return tip
end

test('juego1: Show reentra al hook sin repetir lineas ni recursar', function()
    addItem(900001, 10, 0, 15)
    local tip = tooltip(900001)
    local calls = 0
    function tip:Show()
        calls = calls + 1
        ok(calls < 3, 'Show recursivo')
        self:GetScript('OnTooltipSetItem')(self)
    end
    ns.Tooltip.Decorate(tip)
    eq(calls, 1); eq(#tip.lines, 2)
    ns.Tooltip.Decorate(tip)
    eq(calls, 1); eq(#tip.lines, 2)
end)

test('juego1: Show con error no propaga ni repite lineas', function()
    addItem(900001, 10, 0, 15)
    local tip = tooltip(900001)
    function tip:Show() error('fallo simulado') end
    ns.Tooltip.Decorate(tip); ns.Tooltip.Decorate(tip)
    eq(#tip.lines, 2)
end)

test('juego1: tooltip oculto no se abre al decorarlo', function()
    addItem(900001, 10, 0, 15)
    local tip = tooltip(900001)
    tip:Hide(); ns.Tooltip.Decorate(tip)
    eq(tip:IsShown(), false)
end)

test('juego1: tecla resuelve GetItem despues de OnTooltipCleared', function()
    addItem(900001, 10, 0, 15)
    local tip = tooltip(900001)
    ns.Tooltip.Decorate(tip)
    for _, expected in ipairs({ 'keep', 'auto', 'keep' }) do
        tip:GetScript('OnTooltipCleared')(tip)
        eq(ns.Overrides.hovered, nil)
        KnuJunk_CycleHovered()
        eq(ns.DB.overrides[900001] or 'auto', expected)
    end
end)

test('juego1: GetItem actual prevalece sobre hovered viejo', function()
    addItem(900001, 10)
    tooltip(900001)
    ns.Overrides.hovered = 900002
    KnuJunk_CycleHovered()
    eq(ns.DB.overrides[900001], 'keep'); eq(ns.DB.overrides[900002], nil)
end)

test('juego1: GetItem ausente fallido u oculto conserva fallback', function()
    addItem(900001, 10)
    ns.Overrides.hovered = 900001
    GameTooltip.GetItem = function() error('fallo simulado') end
    KnuJunk_CycleHovered(); eq(ns.DB.overrides[900001], 'keep')
    GameTooltip.GetItem = nil
    KnuJunk_CycleHovered(); eq(ns.DB.overrides[900001], nil)
    GameTooltip.GetItem = function() return 'Otro', 'item:900002' end
    GameTooltip:Hide()
    KnuJunk_CycleHovered(); eq(ns.DB.overrides[900001], 'keep')
    eq(ns.DB.overrides[900002], nil)
end)

test('juego1: cambiar override pide widgets y busquedas a Baganator', function()
    local state = FAKE.InstallBaganator()
    ns.Bags.InstallAll(); state.activeJunk = 'knujunk'
    FAKE.Advance(1)
    local before = state.refreshes
    ns.Overrides.Set(900001, 'keep'); FAKE.Advance(1)
    eq(state.refreshes, before + 1)
    eq(state.lastReason[1], 4); eq(state.lastReason[2], 16)
end)

test('juego1: sin APIs de foco no crea escudo ni interrumpe tooltip', function()
    addItem(900001, 10)
    ns.DB.overrides[900001] = 'keep'
    FAKE.Fire('MERCHANT_SHOW')
    eq(ns.Merchant.ShowHoveredShield(0, 1), nil)
    local tip = tooltip(900001)
    ns.Tooltip.Decorate(tip)
    eq(#tip.lines, 3)
end)

local function protected()
    addItem(900001, 10)
    ns.DB.overrides[900001] = 'keep'
    FAKE.Fire('MERCHANT_SHOW')
    local button = CreateFrame('Button')
    button:SetFrameLevel(9)
    GetMouseFoci = function() return { button } end
    local tip = tooltip(900001)
    ns.Tooltip.Decorate(tip)
    local shield = ns.Merchant.ShowHoveredShield(0, 1)
    ok(shield, 'escudo universal sin Marks.Update')
    return button, shield, tip
end

test('juego1: escudo universal confirma y vende una sola vez', function()
    local button, shield = protected()
    eq(button.KnuJunkShield, nil)
    eq(shield:GetParent(), button); eq(shield.allPoints, button)
    eq(shield:GetFrameLevel(), 10); eq(shield.passThrough[1], 'LeftButton')
    shield:GetScript('OnMouseUp')(shield, 'LeftButton'); eq(FAKE.popup, nil)
    shield:GetScript('OnMouseUp')(shield, 'RightButton')
    local popup = FAKE.popup
    ok(popup); eq(popup.data.bag, 0); eq(popup.data.slot, 1)
    popup.dialog.OnAccept(nil, popup.data)
    popup.dialog.OnAccept(nil, popup.data)
    eq(#FAKE.used, 1)
end)

test('juego1: escudo universal se reutiliza y usa GetMouseFocus clasico', function()
    local _, shield = protected()
    local second = CreateFrame('Button')
    GetMouseFoci = nil
    GetMouseFocus = function() return second end
    eq(ns.Merchant.ShowHoveredShield(0, 1), shield)
    eq(shield.allPoints, second)
    GetMouseFoci = function() return {} end
    eq(ns.Merchant.ShowHoveredShield(0, 1), shield)
    GetMouseFoci = function() return { second } end
    GetMouseFocus = function() error('no usar API antigua') end
    eq(ns.Merchant.ShowHoveredShield(0, 1), shield)
end)

test('juego1: reentrada sobre el escudo no provoca Hide ni Show adicionales', function()
    local _, shield, tip = protected()
    local shown, hidden = 0, 0
    shield:HookScript('OnShow', function() shown = shown + 1 end)
    shield:HookScript('OnHide', function() hidden = hidden + 1 end)
    GetMouseFoci = function() return { shield } end
    ns.Tooltip.Decorate(tip)
    eq(shown, 0); eq(hidden, 0); ok(shield:IsShown())
end)

test('juego1: Show conserva bolsa y slot del hook SetBagItem sin GetBagItem', function()
    local _, shield, tip = protected()
    tip.GetBagItem = nil
    tip:GetScript('OnTooltipCleared')(tip)
    tip.lines = {}
    function tip:Show() self:GetScript('OnTooltipSetItem')(self) end
    GetMouseFoci = function() return { shield } end
    ns.Tooltip.Decorate(tip, nil, 0, 1)
    ok(shield:IsShown()); eq(#tip.lines, 3)
end)

test('juego1: OnLeave reenvia al boton y despues oculta escudo', function()
    local button, shield = protected()
    local forwarded = false
    button:SetScript('OnLeave', function(self)
        eq(self, button); ok(shield:IsShown()); forwarded = true
    end)
    shield:GetScript('OnLeave')(shield)
    ok(forwarded); eq(shield:IsShown(), false)
end)

test('juego1: ocultar el tooltip NO oculta el escudo (evita el ciclo de parpadeo visto en el juego)', function()
    local _, shield, tip = protected()
    tip:Hide()
    eq(shield:IsShown(), true)
    shield:GetScript('OnLeave')(shield)
    eq(shield:IsShown(), false)
end)

for _, action in ipairs({ 'merchant', 'combat', 'protectKeep', 'enabled' }) do
    local current = action
    test('juego1: escudo se oculta al cambiar ' .. current, function()
        local _, shield, tip = protected()
        if current == 'merchant' then FAKE.Fire('MERCHANT_CLOSED')
        elseif current == 'combat' then FAKE.inCombat = true; FAKE.Fire('PLAYER_REGEN_DISABLED')
        else ns.Options.Set(current, false) end
        eq(shield:IsShown(), false)
    end)
end

test('juego1: escudo rechaza banco slot desconocido y falta de passthrough', function()
    local _, shield = protected()
    eq(ns.Merchant.ShowHoveredShield(-1, 1), nil); eq(shield:IsShown(), false)
    eq(ns.Merchant.ShowHoveredShield(0, nil), nil)
    local methods = getmetatable(CreateFrame('Frame')).__index
    local previous = methods.SetPassThroughButtons
    methods.SetPassThroughButtons = nil
    local result = ns.Merchant.ShowHoveredShield(0, 1)
    methods.SetPassThroughButtons = previous
    eq(result, nil)
end)

for _, count in ipairs({ 0, 3, 25 }) do
    local marks = count
    test('juego1: anclas sin superposicion con ' .. marks .. ' marcas', function()
        for i = 1, marks do ns.DB.overrides[900000 + i] = 'keep' end
        local panel = ns.Options.Build(); panel:SetSize(650, 300); panel:Show()
        ns.Options.SelectTab('Marks')
        local page = panel.tabs.Marks
        local bottom = 0
        for _, frame in ipairs(page.rows) do
            local top = -frame.points[1][5]
            ok(top >= bottom)
            bottom = top + frame:GetHeight()
            eq(frame.points[1][2], page.content)
        end
        ok(panel.list:GetHeight() > 0)
        eq(panel.empty:IsShown(), marks == 0)
        if marks > 6 then ok(panel.scroll:IsShown()); eq(panel.scroll.max, marks - 6) end
        page.viewport:GetScript('OnMouseWheel')(page.viewport, -100)
        eq(page.viewport:GetVerticalScroll(), page.limit)
        page.viewport:GetScript('OnMouseWheel')(page.viewport, 100)
        eq(page.viewport:GetVerticalScroll(), 0)
    end)
end

for _, price in ipairs({ 0, 10, 'unknown' }) do
    local value = price
    test('juego1: precio de moneda automatica y manual ' .. tostring(value), function()
        local item = { id = 900001, quality = 1, classID = 12 }
        if value ~= 'unknown' then item.price = value end
        local ctx = { overrides = {}, questItemsInLog = {}, questInLog = function() return false end }
        local result = ns.Classify(item, ctx)
        eq(result.mark, value == 10 and 'coin' or value == 0 and 'trash' or 'useful')
        local reasons = {}
        for _, reason in ipairs(result.reasons) do reasons[reason.kind] = true end
        ok(reasons.quest_not_active)
        eq(reasons.no_sell_price == true, value == 0)
        ctx.overrides[item.id] = 'sell'
        result = ns.Classify(item, ctx); eq(result.mark, 'coin')
        eq(result.reasons[#result.reasons].kind, value == 0 and 'no_sell_price' or 'override_sell')
    end)
end

test('juego1: tooltip sin precio automatico y venta manual en tres locales', function()
    local previous = ns.L
    local success, err = pcall(function()
        for _, locale in ipairs({ 'esES', 'esMX', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            addItem(900001, 0)
            for _, manual in ipairs({ false, true }) do
                ns.DB.overrides[900001] = manual and 'sell' or nil
                local lines = ns.Tooltip.Lines(FAKE.linkOf(900001))
                local expected = locale == 'enUS' and 'Cannot be sold (no vendor price)' or 'No se puede vender (sin precio)'
                eq(lines[#lines].text, expected)
                ok(not lines[#lines].text:find('|T', 1, true))
                if not manual then
                    eq(lines[2].text, ns.L['No active quest needs it'])
                    eq(lines[2].r, 1); eq(lines[2].g, 1); eq(lines[2].b, 1)
                end
            end
            ok(not ns.L['Hover an item in your bags or loot window and press the key to toggle Protected / Automatic.']:find('→', 1, true))
            ok(not ns.L['Press a key... (Esc cancels)']:find('…', 1, true))
        end
    end)
    ns.L, FAKE.locale = previous, nil
    if not success then error(err) end
end)
