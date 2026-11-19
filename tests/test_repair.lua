local function merchant(cost, money, guildFunds)
    local state = { cost = cost or 100, money = money or 1000, guild = guildFunds or 0, calls = {} }
    CanMerchantRepair = function() return true end
    GetRepairAllCost = function() return state.cost, state.cost > 0 end
    GetMoney = function() return state.money end
    IsInGuild = function() return true end
    CanGuildBankRepair = function() return true end
    RepairAllItems = function(guild)
        state.calls[#state.calls + 1] = guild and 'guild' or 'own'
        local paid = math.min(state.cost, guild and state.guild or state.money)
        state.cost = state.cost - paid
        if guild then state.guild = state.guild - paid else state.money = state.money - paid end
    end
    return state
end

local function sale(state)
    FAKE.items[1001] = { name = 'Basura', quality = 0, price = 100, classID = 15, subclassID = 0 }
    FAKE.bags['0:1'] = 1001
    ns.DB.overrides[1001] = 'sell'
    C_Container.UseContainerItem = function(bag, slot)
        FAKE.bags[bag .. ':' .. slot] = nil
        state.money = state.money + 100
    end
end

test('reparación: defaults, fondos propios y resumen confirmado', function()
    ok(ns.DB.autoRepair.enabled); eq(ns.DB.autoRepair.guild, false)
    local state = merchant(12345, 20000)
    FAKE.Fire('MERCHANT_SHOW')
    eq(state.cost, 0); eq(state.money, 7655); eq(#state.calls, 1); eq(state.calls[1], 'own')
    eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find('KnuJunk reparó todo por ' .. ns.FormatMoney(12345), 1, true))
    FAKE.Fire('MERCHANT_SHOW'); eq(#state.calls, 1)
end)

test('reparación: Shift saltea toda la visita incluso si se suelta en combate', function()
    local state = merchant()
    FAKE.shift, FAKE.inCombat = true, true
    FAKE.Fire('MERCHANT_SHOW'); FAKE.shift, FAKE.inCombat = false, false
    FAKE.Fire('PLAYER_REGEN_ENABLED'); FAKE.Advance(3)
    eq(#state.calls, 0); eq(#FAKE.messages, 0)
end)

for _, mode in ipairs({ 'no repara', 'costo cero', 'canRepair falso', 'opción apagada', 'addon apagado' }) do
    local setting = mode
    test('reparación: no actúa con ' .. setting, function()
        local state = merchant()
        if setting == 'no repara' then CanMerchantRepair = function() return false end
        elseif setting == 'costo cero' then state.cost = 0
        elseif setting == 'canRepair falso' then GetRepairAllCost = function() return 100, false end
        elseif setting == 'opción apagada' then ns.DB.autoRepair.enabled = false
        else ns.DB.enabled = false end
        FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(3)
        eq(#state.calls, 0); eq(#FAKE.messages, 0)
    end)
end

test('reparación: falta plata y reintenta una vez después del resumen de ventas', function()
    local state = merchant(100, 20); sale(state)
    FAKE.Fire('MERCHANT_SHOW')
    eq(#state.calls, 0); eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find('No te alcanza para reparar todo: cuesta ' .. ns.FormatMoney(100), 1, true))
    FAKE.Advance(.21); eq(state.money, 120); eq(#state.calls, 0)
    FAKE.Advance(2); eq(state.cost, 0); eq(state.money, 20); eq(#state.calls, 1)
    eq(#FAKE.messages, 4)
    ok(FAKE.messages[2]:find('KnuJunk vendió', 1, true))
    ok(FAKE.messages[3]:find('Vendido: ', 1, true))
    ok(FAKE.messages[4]:find('KnuJunk reparó', 1, true))
    FAKE.Advance(10); FAKE.Fire('PLAYER_REGEN_ENABLED'); eq(#state.calls, 1)
end)

test('reparación: reintento sin plata no se repite ante otros eventos', function()
    local state = merchant(200, 0); sale(state)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(3)
    eq(#state.calls, 0); eq(#FAKE.messages, 4)
    FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Fire('PLAYER_REGEN_ENABLED'); FAKE.Advance(3)
    eq(#FAKE.messages, 4)
end)

test('reparación: hermandad cubre todo y no toca plata propia', function()
    local state = merchant(100, 0, 100); ns.DB.autoRepair.guild = true
    FAKE.Fire('MERCHANT_SHOW')
    eq(state.cost, 0); eq(#state.calls, 1); eq(state.calls[1], 'guild')
    ok(FAKE.messages[1]:find('KnuJunk reparó todo por ' .. ns.FormatMoney(100) .. ' (fondos de la hermandad)', 1, true))
end)

test('reparación: límite de hermandad se completa con plata propia', function()
    local state = merchant(100, 1000, 40); ns.DB.autoRepair.guild = true
    FAKE.Fire('MERCHANT_SHOW')
    eq(state.cost, 0); eq(state.money, 940); eq(#state.calls, 2)
    eq(state.calls[1], 'guild'); eq(state.calls[2], 'own'); eq(#FAKE.messages, 1)
    ok(FAKE.messages[1]:find(ns.FormatMoney(40) .. ' de la hermandad y ' .. ns.FormatMoney(60) .. ' tuyos', 1, true))
end)

test('reparación: intento de hermandad sin reducción continúa con plata propia', function()
    local state = merchant(100, 1000, 0); ns.DB.autoRepair.guild = true
    FAKE.Fire('MERCHANT_SHOW')
    eq(state.cost, 0); eq(#state.calls, 2); eq(#FAKE.messages, 1)
    ok(not FAKE.messages[1]:find('hermandad', 1, true))
end)

for _, name in ipairs({ 'IsInGuild', 'CanGuildBankRepair' }) do
    local api = name
    test('reparación: error de ' .. api .. ' permite fondos propios', function()
        local state = merchant(); ns.DB.autoRepair.guild = true
        _G[api] = function() error('API fallida') end
        FAKE.Fire('MERCHANT_SHOW')
        eq(state.cost, 0); eq(#state.calls, 1); eq(state.calls[1], 'own')
    end)
end

for _, mode in ipairs({ 'opción apagada', 'sin hermandad', 'sin permiso', 'sin API de hermandad', 'sin API de permiso' }) do
    local setting = mode
    test('reparación: fondos propios con ' .. setting, function()
        local state = merchant(100, 1000, 100)
        ns.DB.autoRepair.guild = setting ~= 'opción apagada'
        if setting == 'sin hermandad' then IsInGuild = function() return false end
        elseif setting == 'sin permiso' then CanGuildBankRepair = function() return false end
        elseif setting == 'sin API de hermandad' then IsInGuild = nil
        elseif setting == 'sin API de permiso' then CanGuildBankRepair = nil end
        FAKE.Fire('MERCHANT_SHOW')
        eq(#state.calls, 1); eq(state.calls[1], 'own'); eq(state.guild, 100)
    end)
end

test('reparación: espera al fin del combate con venta desactivada', function()
    local state = merchant(); ns.DB.autoSell.enabled = false; FAKE.inCombat = true
    FAKE.Fire('MERCHANT_SHOW'); eq(#state.calls, 0)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED')
    eq(#state.calls, 1); FAKE.Fire('PLAYER_REGEN_ENABLED'); eq(#state.calls, 1)
end)

test('reparación: cerrar cancela reparación diferida y reintento tras ventas', function()
    local state = merchant(); FAKE.inCombat = true
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Fire('MERCHANT_CLOSED')
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED'); eq(#state.calls, 0)
    state.money = 0; sale(state)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(.21); FAKE.Fire('MERCHANT_CLOSED'); FAKE.Advance(3)
    eq(#state.calls, 0)
end)

test('reparación: reintento tras ventas espera si empezó un combate', function()
    local state = merchant(100, 0); sale(state)
    FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(.21); FAKE.inCombat = true; FAKE.Advance(3)
    eq(#state.calls, 0)
    FAKE.inCombat = false; FAKE.Fire('PLAYER_REGEN_ENABLED'); eq(#state.calls, 1)
end)

for _, name in ipairs({ 'CanMerchantRepair', 'GetRepairAllCost', 'RepairAllItems', 'GetMoney', 'IsShiftKeyDown', 'InCombatLockdown' }) do
    local api = name
    for _, mode in ipairs({ 'ausente', 'fallida' }) do
        local failure = mode
        test('reparación: API ' .. api .. ' ' .. failure .. ' es segura', function()
            local state = merchant()
            local original = _G[api]
            if failure == 'ausente' then _G[api] = nil else _G[api] = function() error('API fallida') end end
            local success, err = pcall(function()
                FAKE.Fire('MERCHANT_SHOW'); FAKE.Advance(3); FAKE.Fire('PLAYER_REGEN_ENABLED')
                eq(#state.calls, 0); eq(#FAKE.messages, 0)
            end)
            _G[api] = original
            if not success then error(err, 0) end
        end)
    end
end

test('reparación: sin reducción confirmada del costo no imprime éxito', function()
    merchant()
    RepairAllItems = function() end
    FAKE.Fire('MERCHANT_SHOW'); eq(#FAKE.messages, 0)
end)

test('reparación: lectura posterior fallida no imprime éxito', function()
    merchant()
    RepairAllItems = function() GetRepairAllCost = function() error('sin datos') end end
    FAKE.Fire('MERCHANT_SHOW'); eq(#FAKE.messages, 0)
end)

test('reparación: otros reparadores on, off, ausentes y malformados, sin cambiar ajustes', function()
    LeaPlusDB, ElvUI = nil, nil; eq(next(ns.AutoSell.OtherRepairers()), nil)
    LeaPlusDB = { AutoRepairGear = 'On' }; ElvUI = { { db = { general = { autoRepair = 'GUILD' } } } }
    local found = ns.AutoSell.OtherRepairers(); ok(found.Leatrix_Plus); ok(found.ElvUI)
    eq(LeaPlusDB.AutoRepairGear, 'On'); eq(ElvUI[1].db.general.autoRepair, 'GUILD')
    ElvUI[1].db.general.autoRepair = 'PLAYER'; ok(ns.AutoSell.OtherRepairers().ElvUI)
    LeaPlusDB.AutoRepairGear = 'Off'; ElvUI[1].db.general.autoRepair = 'NONE'
    eq(next(ns.AutoSell.OtherRepairers()), nil)
    LeaPlusDB, ElvUI = true, { { db = { general = {} } } }; eq(next(ns.AutoSell.OtherRepairers()), nil)
    ElvUI = { { db = true } }; eq(next(ns.AutoSell.OtherRepairers()), nil)
end)

test('reparación: opciones y advertencias medidas en General y refresco', function()
    LeaPlusDB = { AutoRepairGear = 'On' }; ElvUI = { { db = { general = { autoRepair = 'GUILD' } } } }
    local panel = ns.Options.Build(); panel:SetSize(360, 600); panel:Show(); ns.Options.Refresh()
    ok(panel.checks['autoRepair.enabled']); ok(panel.checks['autoRepair.guild'])
    eq(panel.checks['autoRepair.enabled'].label:GetText(), 'Reparación automática')
    eq(panel.checks['autoRepair.guild'].label:GetText(), 'Usar fondos de la hermandad')
    ok(panel.autoRepairWarnings.Leatrix_Plus:GetText():find('Leatrix Plus también repara', 1, true))
    ok(panel.autoRepairWarnings.ElvUI:GetText():find('General > Reparación automática', 1, true))
    local bottom = 0
    for _, row in ipairs(panel.tabs.General.rows) do
        local top = -row.points[1][5]
        ok(top >= bottom); ok(row:GetHeight() > 0)
        bottom = top + row:GetHeight()
        for _, text in ipairs(FAKE.frames) do
            if text.parent == row and text.kindType == 'FontString' then
                ok(-text.points[1][5] + text:GetHeight() <= row:GetHeight() + .001)
            end
        end
    end
    ok(ns.Options.Set('autoRepair.guild', true)); ok(ns.DB.autoRepair.guild)
    LeaPlusDB.AutoRepairGear = 'Off'; ElvUI[1].db.general.autoRepair = 'NONE'; ns.Options.Refresh()
    eq(panel.autoRepairWarnings.Leatrix_Plus:GetText(), ''); eq(panel.autoRepairWarnings.ElvUI:GetText(), '')
end)

test('reparación: textos enUS y dinero formateado', function()
    local original, locale = ns.L, FAKE.locale
    local success, err = pcall(function()
        FAKE.locale = 'enUS'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
        eq(ns.L['Automatic repairs'], 'Automatic repairs'); eq(ns.L['Use guild funds'], 'Use guild funds')
        merchant(); FAKE.Fire('MERCHANT_SHOW')
        ok(FAKE.messages[1]:find('KnuJunk repaired everything for ' .. ns.FormatMoney(100), 1, true))
    end)
    ns.L, FAKE.locale = original, locale
    if not success then error(err, 0) end
end)
