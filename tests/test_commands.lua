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

test('help imprime la ayuda y no cambia nada', function()
    withSpy(function(state)
        run('help')
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

-- ---------------------------------------------------------------------------------------------
-- Registro con el despachador real de KnuLib, alias en conflicto, idiomas y argumentos vacios.
-- ---------------------------------------------------------------------------------------------

-- Corre fn con KL.commands / KL.commandAliases vacios y restaura lo anterior pase lo que pase.
local function withCleanDispatcher(fn)
    local KL = ns.KL
    local commands, aliases, default, legacy = KL.commands, KL.commandAliases, KL.defaultCommand, KL.legacySlash
    KL.commands, KL.commandAliases, KL.defaultCommand, KL.legacySlash = {}, {}, nil, nil
    local success, err = pcall(fn, KL)
    KL.commands, KL.commandAliases, KL.defaultCommand, KL.legacySlash = commands, aliases, default, legacy
    if not success then error(err, 0) end
end

-- Vuelve a cargar Commands.lua con ns.OnLogin capturado: devuelve las funciones que registro para el login.
-- Siempre restaura ns.OnLogin y ns.Commands (las otras pruebas usan los reales).
local function captureLoginHandlers()
    local realOnLogin, realCommands = ns.OnLogin, ns.Commands
    local captured = {}
    ns.OnLogin = function(fn) captured[#captured + 1] = fn end
    local success, err = pcall(function() assert(loadfile('Commands.lua'))('KnuJunk', ns) end)
    ns.OnLogin, ns.Commands = realOnLogin, realCommands
    if not success then error(err, 0) end
    return captured
end

test('Commands.lua registra su comando por ns.OnLogin y no al cargar el archivo', function()
    withCleanDispatcher(function(KL)
        local captured = captureLoginHandlers()
        eq(#captured, 1, 'una sola funcion de login')
        eq(next(KL.commands), nil, 'nada registrado antes del login')
        captured[1]()
        ok(KL.commands.junk, 'junk registrado tras el login')
        eq(KL.commandAliases.kj, 'junk')
        eq(KL.commands.junk.help, ns.L['Junk marks: options panel, on/off, coin/hammer/loot, keep/sell/clear, rules, status'])
        -- A traves del despachador real, con mayusculas y espacios de mas.
        KL:Dispatch('junk coin off')
        eq(ns.DB.show.coin, false)
        KL:Dispatch('  KJ   coin   on  ')
        eq(ns.DB.show.coin, true)
        KL:Dispatch('JUNK hammer off')
        eq(ns.DB.show.hammer, false)
    end)
end)

test('el login no falla si la KnuLib cargada no tiene RegisterCommand', function()
    withCleanDispatcher(function(KL)
        local captured = captureLoginHandlers()
        local real = KL.RegisterCommand
        KL.RegisterCommand = nil
        local success, err = pcall(captured[1])
        KL.RegisterCommand = real
        ok(success, tostring(err))
        eq(next(KL.commands), nil)
    end)
end)

test('si RegisterCommand lanza error el login no se rompe', function()
    withCleanDispatcher(function(KL)
        local captured = captureLoginHandlers()
        local real = KL.RegisterCommand
        KL.RegisterCommand = function() error('KnuLib rota') end
        local success, err = pcall(captured[1])
        KL.RegisterCommand = real
        ok(success, tostring(err))
    end)
end)

test('alias kj ya tomado por otro addon: junk no lo roba y sigue andando por su nombre', function()
    withCleanDispatcher(function(KL)
        local other = {}
        KL:RegisterCommand('otro', function(args) other[#other + 1] = args end, 'otro addon', { 'kj' })
        ns.Commands.Register()
        ok(KL.commands.junk, 'junk igual se registra')
        eq(KL.commandAliases.kj, 'otro', 'el alias sigue siendo del primero')
        eq(#KL.commands.junk.aliases, 0, 'junk no tiene alias')
        KL:Dispatch('kj coin off')
        eq(other[1], 'coin off', 'kj va al otro addon')
        eq(ns.DB.show.coin, true, 'y no toca KnuJunk')
        KL:Dispatch('junk coin off')
        eq(ns.DB.show.coin, false, 'junk por su nombre funciona')
        eq(#other, 1)
    end)
end)

test('kj ya registrado como nombre de comando de otro addon: junk no lo pisa', function()
    withCleanDispatcher(function(KL)
        local called = 0
        KL:RegisterCommand('kj', function() called = called + 1 end, 'otro')
        ns.Commands.Register()
        eq(KL.commandAliases.kj, nil)
        KL:Dispatch('kj coin off')
        eq(called, 1)
        eq(ns.DB.show.coin, true)
        KL:Dispatch('junk coin off')
        eq(ns.DB.show.coin, false)
    end)
end)

test('si junk se registro primero conserva kj y otro addon que lo pide despues no se lo saca', function()
    withCleanDispatcher(function(KL)
        ns.Commands.Register()
        local called = 0
        KL:RegisterCommand('otro', function() called = called + 1 end, nil, { 'kj' })
        eq(KL.commandAliases.kj, 'junk')
        KL:Dispatch('kj coin off')
        eq(called, 0)
        eq(ns.DB.show.coin, false)
    end)
end)

test('registrar dos veces no duplica ni rompe el alias', function()
    withCleanDispatcher(function(KL)
        ns.Commands.Register()
        ns.Commands.Register()
        eq(KL.commandAliases.kj, 'junk')
        eq(#KL.commands.junk.aliases, 1)
    end)
end)

-- Recarga Locales.lua con el idioma pedido (NewLocale real) y deja todo como estaba.
local function withLocale(locale, fn)
    local realL, realNormalize = ns.L, ns.NormalizeName
    local realName, realByName = ns.ProfessionName, ns.ProfessionByName
    FAKE.locale = locale
    local success, err = pcall(function()
        assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
        fn()
    end)
    FAKE.locale = nil
    ns.L, ns.NormalizeName, ns.ProfessionName, ns.ProfessionByName = realL, realNormalize, realName, realByName
    if not success then error(err, 0) end
end

local PREFIX = '|cffecd9bdKNU|r|cffffa82eJunk|r: '

test('ayuda en castellano (esES y esMX)', function()
    for _, locale in ipairs({ 'esES', 'esMX' }) do
        withLocale(locale, function()
            run('help')
            eq(printed(), table.concat({
                PREFIX .. 'Panel de opciones: /knu junk',
                PREFIX .. 'Activar o desactivar las marcas: /knu junk on | off',
                PREFIX .. 'Un solo tipo de marca: /knu junk coin|hammer|loot on|off',
                PREFIX .. 'A mano: /knu junk keep|sell|clear <enlace o ID de ítem>',
                PREFIX .. 'Reglas opcionales: /knu junk rules [food|ammo|knownrecipe] [on|off]',
                PREFIX .. 'Ver el estado: /knu junk status',
            }, '\n'), locale)
        end)
    end
end)

test('ayuda en ingles (enUS y cualquier otro idioma)', function()
    for _, locale in ipairs({ 'enUS', 'enGB', 'deDE' }) do
        withLocale(locale, function()
            run('help')
            eq(printed(), table.concat({
                PREFIX .. 'Options panel: /knu junk',
                PREFIX .. 'Marks on/off: /knu junk on | off',
                PREFIX .. 'One kind: /knu junk coin|hammer|loot on|off',
                PREFIX .. 'By hand: /knu junk keep|sell|clear <item link or ID>',
                PREFIX .. 'Optional rules: /knu junk rules [food|ammo|knownrecipe] [on|off]',
                PREFIX .. 'Show state: /knu junk status',
            }, '\n'), locale)
        end)
    end
end)

test('la ayuda de /knu usa el texto del idioma que tenia el cliente al cargar', function()
    withCleanDispatcher(function(KL)
        withLocale('esES', function()
            ns.Commands.Register()
            eq(KL.commands.junk.help, 'Marcas de basura: panel de opciones, on/off, coin/hammer/loot, keep/sell/clear, rules, status')
        end)
        withLocale('enUS', function()
            ns.Commands.Register()
            eq(KL.commands.junk.help, 'Junk marks: options panel, on/off, coin/hammer/loot, keep/sell/clear, rules, status')
        end)
    end)
end)

test('on/off en castellano concuerdan con cada mensaje', function()
    withLocale('esES', function()
        eq(ns.L['on'], 'activadas'); eq(ns.L['off'], 'desactivadas')
        run('off'); ok(hasText('Marcas: desactivadas'), printed())
        run('on'); ok(hasText('Marcas: activadas'), printed())
        run('coin off'); ok(hasText('Marcas de coin: desactivadas'), printed())
        run('status')
        ok(hasText('Marcas: activadas | coin: desactivadas | hammer: activadas | loot: activadas'), printed())
    end)
    withLocale('enUS', function()
        run('hammer off'); ok(hasText('Mark hammer: off'), printed())
        run('off'); ok(hasText('Marks: off'), printed())
    end)
end)

test('Locales.lua no repite claves dentro de la tabla de textos', function()
    local file = assert(io.open('Locales/Locales.lua', 'r'))
    local source = file:read('*a'); file:close()
    local block = source:match('NewLocale%(%{(.-)\n%}%)')
    ok(block, 'se encontro la tabla de textos')
    local seen, total = {}, 0
    for key in block:gmatch("%[(%b'')%]%s*=") do
        ok(not seen[key], 'clave repetida: ' .. key)
        seen[key] = true; total = total + 1
    end
    for key in block:gmatch('%[(%b"")%]%s*=') do
        ok(not seen[key], 'clave repetida: ' .. key)
        seen[key] = true; total = total + 1
    end
    ok(total > 25, 'se leyeron las claves: ' .. total)
end)

test('argumentos nil, vacios o en blanco abren el panel y no cambian nada', function()
    withSpy(function(state)
        local opened = 0
        local realOpen = ns.Options.Open
        ns.Options.Open = function() opened = opened + 1 end
        local success, err = pcall(function()
            for _, args in ipairs({ '', ' ', '   ', '	', ' 	 ' }) do
                run(args)
                eq(#FAKE.messages, 0, 'sin ayuda para ' .. string.format('%q', args))
            end
            ns.Commands.Handle(nil)
        end)
        ns.Options.Open = realOpen
        if not success then error(err, 0) end
        eq(opened, 6, 'abre el panel')
        eq(state.invalidate, 0); eq(state.refresh, 0)
        eq(ns.DB.enabled, true); eq(next(ns.DB.overrides), nil)
    end)
end)

test('subcomandos con el argumento en blanco piden el uso', function()
    withSpy(function(state)
        for _, text in ipairs({ 'keep ', 'sell   ', 'clear \t' }) do
            run(text)
            ok(hasText(string.format(ns.L['Usage: /knu junk %s <item link or ID>'], text:match('^%a+'))), text)
        end
        run('hammer   ')
        ok(hasText(string.format(ns.L['Usage: /knu junk %s on|off'], 'hammer')))
        eq(next(ns.DB.overrides), nil)
        eq(state.invalidate, 0); eq(state.refresh, 0)
    end)
end)

test('ParseItem devuelve nil con nil, vacio, numeros no enteros u otros tipos', function()
    for _, value in ipairs({ '', ' ', 'abc', '-5', '1.5', '0' }) do
        eq(ns.Commands.ParseItem(value), nil, string.format('%q', value))
    end
    eq(ns.Commands.ParseItem(nil), nil)
    eq(ns.Commands.ParseItem(123), nil)
    eq(ns.Commands.ParseItem({}), nil)
    eq(ns.Commands.ParseItem(' 4306 '), 4306)
end)

test('por el despachador real, junk sin argumentos y con blancos abre el panel y help imprime la ayuda', function()
    withCleanDispatcher(function(KL)
        ns.Commands.Register()
        FAKE.messages = {}
        KL:Dispatch('junk')
        eq(#FAKE.messages, 0)
        eq(#FAKE.settings.opened, 1)
        KL:Dispatch('kj    ')
        eq(#FAKE.settings.opened, 2)
        KL:Dispatch('junk help')
        eq(#FAKE.messages, 6)
    end)
end)
