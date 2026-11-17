-- /knu junk: subcomandos, parseo de enlaces e IDs, refresco y estado.
local function addItem(id)
    FAKE.items[id] = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
end

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

local function run(args)
    FAKE.messages = {}
    ns.Commands.Handle(args)
end
local function printed() return table.concat(FAKE.messages, '\n') end
local function hasText(text) return printed():find(text, 1, true) ~= nil end

test('keep con link guarda override y refresca', function()
    addItem(777)
    withSpy(function(state)
        run('keep ' .. FAKE.linkOf(777))
        eq(ns.DB.overrides[777], 'keep')
        eq(state.invalidate, 1); eq(state.refresh, 1)
    end)
end)

test('sell con link guarda override y refresca', function()
    addItem(778)
    withSpy(function(state)
        run('sell ' .. FAKE.linkOf(778))
        eq(ns.DB.overrides[778], 'sell')
        eq(state.invalidate, 1); eq(state.refresh, 1)
    end)
end)

test('clear borra el override y refresca', function()
    addItem(777)
    ns.DB.overrides[777] = 'keep'
    withSpy(function(state)
        run('clear ' .. FAKE.linkOf(777))
        eq(ns.DB.overrides[777], nil)
        eq(state.invalidate, 1); eq(state.refresh, 1)
    end)
end)

test('clear de un item sin override avisa y no toca nada', function()
    withSpy(function(state)
        run('clear 555')
        eq(ns.DB.overrides[555], nil)
        eq(state.invalidate, 0); eq(state.refresh, 0)
        ok(printed() ~= '')
    end)
end)

test('un itemID suelto se acepta', function()
    withSpy(function(state)
        run('keep 4306')
        eq(ns.DB.overrides[4306], 'keep')
        eq(state.refresh, 1)
        run('sell   4306  ')
        eq(ns.DB.overrides[4306], 'sell')
    end)
end)

test('un link con espacios en el nombre se acepta', function()
    run('keep |cffffffff|Hitem:2589::::::::|h[Pano de lino]|h|r')
    eq(ns.DB.overrides[2589], 'keep')
end)

test('link invalido imprime error sin romper', function()
    withSpy(function(state)
        for _, text in ipairs({ 'keep hola', 'sell [Algo]', 'keep 0', 'keep 12abc', 'clear |Hquest:5|h[Q]|h' }) do
            run(text)
            ok(hasText(string.format(ns.L['Invalid item: %s'], text:match('^%S+%s+(.*)$'))), text)
        end
        eq(next(ns.DB.overrides), nil)
        eq(state.invalidate, 0); eq(state.refresh, 0)
    end)
end)

test('keep sin argumento imprime el uso', function()
    run('keep')
    ok(hasText(string.format(ns.L['Usage: /knu junk %s <item link or ID>'], 'keep')))
    eq(next(ns.DB.overrides), nil)
end)

test('coin off apaga show.coin y refresca', function()
    withSpy(function(state)
        run('coin off')
        eq(ns.DB.show.coin, false)
        eq(state.invalidate, 1); eq(state.refresh, 1)
        run('coin on')
        eq(ns.DB.show.coin, true)
        eq(state.refresh, 2)
    end)
end)

test('hammer y loot cambian su propio flag', function()
    run('hammer off'); eq(ns.DB.show.hammer, false); eq(ns.DB.show.coin, true); eq(ns.DB.show.loot, true)
    run('loot off'); eq(ns.DB.show.loot, false)
    run('LOOT ON'); eq(ns.DB.show.loot, true)
end)

test('coin sin on/off imprime el uso y no cambia nada', function()
    withSpy(function(state)
        run('coin')
        ok(hasText(string.format(ns.L['Usage: /knu junk %s on|off'], 'coin')))
        run('coin quizas')
        eq(ns.DB.show.coin, true)
        eq(state.refresh, 0)
    end)
end)

test('on y off cambian enabled y refrescan', function()
    withSpy(function(state)
        run('off'); eq(ns.DB.enabled, false)
        run('on'); eq(ns.DB.enabled, true)
        eq(state.invalidate, 2); eq(state.refresh, 2)
    end)
end)

test('sin argumentos imprime la ayuda y no cambia nada', function()
    withSpy(function(state)
        run('')
        ok(#FAKE.messages >= 4, 'varias lineas de ayuda')
        ok(hasText(ns.L['Show state: /knu junk status']))
        eq(state.refresh, 0)
        eq(ns.DB.enabled, true)
    end)
end)

test('subcomando desconocido avisa y muestra la ayuda', function()
    run('xyz')
    ok(hasText(string.format(ns.L['Unknown option: %s'], 'xyz')))
    ok(hasText(ns.L['Show state: /knu junk status']))
end)

test('status lista adaptadores instalados', function()
    FAKE.InstallBaganator()
    ns.Bags.InstallAll()
    local installed = ns.Bags.Installed()
    ok(#installed >= 1, 'hay al menos un adaptador instalado')
    run('status')
    ok(hasText(table.concat(installed, ', ')))
    ok(hasText(ns.Data.build))
end)

test('status sin adaptadores, sin Questie y con overrides', function()
    ns.DB.overrides[1] = 'keep'; ns.DB.overrides[2] = 'sell'
    run('status')
    ok(hasText(string.format(ns.L['Bag adapters: %s'], ns.L['none'])))
    ok(hasText(string.format(ns.L['QuestieDB: %s, index ready: %s'], ns.L['no'], ns.L['no'])))
    ok(hasText(string.format(ns.L['Manual marks: %d'], 2)))
end)

test('status con QuestieDB disponible', function()
    FAKE.InstallQuestie({})
    run('status')
    ok(hasText(string.format(ns.L['QuestieDB: %s, index ready: %s'], ns.L['yes'], ns.L['no'])))
end)

test('status muestra los flags', function()
    ns.DB.enabled = false; ns.DB.show.hammer = false
    run('status')
    ok(hasText(string.format(ns.L['Marks: %s | coin: %s | hammer: %s | loot: %s'],
        ns.L['off'], ns.L['on'], ns.L['off'], ns.L['on'])))
end)

test('se registra como /knu junk con el alias kj', function()
    ns.Commands.Register()
    local KL = ns.KL
    ok(KL.commands.junk, 'comando junk registrado')
    eq(KL.commandAliases.kj, 'junk')
    KL:Dispatch('junk coin off')
    eq(ns.DB.show.coin, false)
    KL:Dispatch('kj coin on')
    eq(ns.DB.show.coin, true)
end)

test('el cambio repinta de verdad la bolsa registrada (Bags.RefreshAll real)', function()
    local refreshed = 0
    ns.Bags.Register('CmdTest', { install = function() return true end, refresh = function() refreshed = refreshed + 1 end })
    ns.Bags.InstallAll()
    FAKE.Advance(5)
    local before = refreshed
    run('keep 4306')
    FAKE.Advance(5)
    ok(refreshed > before, 'el adaptador se repinto')
end)
