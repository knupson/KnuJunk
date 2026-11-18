-- QuestieDB opcional como fuente de misiones. Los datos salen de un LibQuestieDB falso del stub.
local HUMAN, ORC = 1, 2
local ALLIANCE, HORDE = 1 + 4 + 8 + 64 + 1024, 2 + 16 + 32 + 128 + 512
local WARRIOR, MAGE = 1, 128

-- Instala la libreria falsa y deja terminar el indice (los lotes corren con C_Timer.After).
local function install(quests, opts)
    FAKE.InstallQuestie(quests, opts)
    ns.Questie.Uses(0)
    FAKE.Advance(5)
end

local function questIDs(uses)
    local list = {}
    for _, use in ipairs(uses or {}) do list[#list + 1] = use.questID end
    table.sort(list)
    return table.concat(list, ',')
end

test('sin LibQuestieDB: Available false y Uses nil', function()
    eq(LibQuestieDB, nil)
    eq(ns.Questie.Available(), false)
    eq(ns.Questie.Uses(500), nil)
    FAKE.Advance(5)
    eq(ns.Questie.Uses(500), nil)
end)

test('contrato no soportado: Available false y Uses nil', function()
    FAKE.InstallQuestie({ [1] = { objectives = { nil, nil, { { 500 } } } } }, { contract = 3 })
    eq(ns.Questie.Available(), false)
    eq(ns.Questie.Uses(500), nil)
    FAKE.Advance(5)
    eq(ns.Questie.Uses(500), nil)
end)

test('RequireContract que lanza error: Available false sin propagar', function()
    FAKE.InstallQuestie({}, { throwRequire = true })
    eq(ns.Questie.Available(), false)
    eq(ns.Questie.Uses(500), nil)
end)

test('LibQuestieDB que aparece despues se detecta (no se cachea el fallo)', function()
    eq(ns.Questie.Uses(500), nil)
    FAKE.InstallQuestie({ [1] = { objectives = { nil, nil, { { 500 } } } } })
    eq(ns.Questie.Available(), true)
    ns.Questie.Uses(500)
    FAKE.Advance(5)
    eq(questIDs(ns.Questie.Uses(500)), '1')
end)

test('item objetivo de dos misiones -> dos entradas', function()
    install({
        [10] = { objectives = { nil, nil, { { 500, 'Cuero' } } } },
        [20] = { objectives = { nil, nil, { { 500, 'Cuero', 3 }, { 501 } } } },
        [30] = { objectives = { nil, nil, { { 999 } } } },
    })
    local uses = ns.Questie.Uses(500)
    eq(uses[1].repeatable, nil, 'sin flags: no se sabe'); eq(uses[2].repeatable, nil)
    eq(uses[1].repeatable, false); eq(uses[2].repeatable, false)
    eq(questIDs(ns.Questie.Uses(501)), '20')
    eq(ns.Questie.Uses(12345), nil)
end)

test('antes de terminar el indice Uses devuelve nil sin trabar', function()
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    eq(ns.Questie.Uses(500), nil)
    eq(FAKE.questieCalls, 0, 'el primer Uses no construye nada a mano')
    FAKE.Advance(5)
    eq(questIDs(ns.Questie.Uses(500)), '10')
end)

test('el indice se arma en tandas, no de una', function()
    local quests = {}
    for i = 1, 1000 do quests[i] = { objectives = { nil, nil, { { 70000 + i } } } } end
    FAKE.InstallQuestie(quests)
    ns.Questie.Uses(70001)
    FAKE.Advance(0)
    local firstBatch = FAKE.questieCalls
    ok(firstBatch > 0, 'la primera tanda trabajo')
    ok(firstBatch < 1000 * 5, 'no leyo todo en una sola tanda: ' .. firstBatch)
    eq(ns.Questie.Uses(70001), nil, 'sin terminar sigue nil')
    FAKE.Advance(5)
    eq(questIDs(ns.Questie.Uses(70001)), '1')
    eq(questIDs(ns.Questie.Uses(71000)), '1000')
    local calls = FAKE.questieCalls
    ns.Questie.Uses(70001); FAKE.Advance(5)
    eq(FAKE.questieCalls, calls, 'no se vuelve a armar')
end)

-- El stub define C_Timer una sola vez (Reset no lo restaura): se devuelve siempre.
local function withoutTimer(fn)
    local saved = C_Timer
    C_Timer = nil
    local good, err = pcall(fn)
    C_Timer = saved
    if not good then error(err, 0) end
end

test('sin C_Timer: se arma sincrono en el primer Uses', function()
    withoutTimer(function()
        FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
        eq(FAKE.questieCalls, 0, 'nada se lee antes del primer Uses')
        eq(questIDs(ns.Questie.Uses(500)), '10')
    end)
end)

test('item fuente, requerido para empezar, de hechizo y que inicia la mision', function()
    install({
        [1] = { sourceItemId = 600 },
        [2] = { requiredSourceItems = { 601, 602 } },
        [3] = { objectives = { nil, nil, nil, nil, nil, { { 7000, 'Usar', 603 } } } },
        [4] = { startedBy = { { 1 }, nil, { 604 } } },
        [5] = { objectives = { nil, nil, { 605 } } }, -- id suelto en lugar de tupla
    })
    eq(questIDs(ns.Questie.Uses(600)), '1')
    eq(questIDs(ns.Questie.Uses(601)), '2'); eq(questIDs(ns.Questie.Uses(602)), '2')
    eq(questIDs(ns.Questie.Uses(603)), '3')
    eq(questIDs(ns.Questie.Uses(604)), '4')
    eq(questIDs(ns.Questie.Uses(605)), '5')
end)

test('un item repetido varias veces en una mision no se duplica', function()
    install({ [1] = { sourceItemId = 600, requiredSourceItems = { 600 },
        objectives = { nil, nil, { { 600 }, { 600 } } } } })
    eq(#ns.Questie.Uses(600), 1)
end)

test('mision repetible, diaria, semanal o mensual -> repeatable true', function()
    install({
        [1] = { sourceItemId = 600, specialFlags = 1 },
        [2] = { sourceItemId = 601, questFlags = 4096 },
        [3] = { sourceItemId = 602, questFlags = 32768 },
        [4] = { sourceItemId = 603, questFlags = 65536 },
        [5] = { sourceItemId = 604, questFlags = 8 + 512 + 1024, specialFlags = 0 },
    })
    for id = 600, 603 do eq(ns.Questie.Uses(id)[1].repeatable, true, 'item ' .. id) end
    eq(ns.Questie.Uses(604)[1].repeatable, false)
end)

-- Ronda de arreglos 1 (R4): repeatable = false SOLO con los dos campos presentes, numericos y sin
-- ningun bit de repeticion. Faltantes o invalidos -> nil (no se sabe); un bit valido -> true.
test('repeatable: nil con flags faltantes o invalidos; true si un flag valido lo confirma', function()
    install({
        [1] = { sourceItemId = 610 },
        [2] = { sourceItemId = 611, specialFlags = 0 },
        [3] = { sourceItemId = 612, questFlags = 0 },
        [4] = { sourceItemId = 613, specialFlags = '0', questFlags = '0' },
        [5] = { sourceItemId = 614, specialFlags = 0, questFlags = 0 / 0 },
        [6] = { sourceItemId = 615, questFlags = 4096 },
        [7] = { sourceItemId = 616, specialFlags = 1, questFlags = 'x' },
        [8] = { sourceItemId = 617, specialFlags = 0, questFlags = 8 },
    })
    for id = 610, 614 do eq(ns.Questie.Uses(id)[1].repeatable, nil, 'item ' .. id) end
    eq(ns.Questie.Uses(615)[1].repeatable, true)
    eq(ns.Questie.Uses(616)[1].repeatable, true)
    eq(ns.Questie.Uses(617)[1].repeatable, false)
end)

test('iniciador hecho con flags faltantes o invalidos en QuestieDB -> sin moneda (Uses -> Classify)', function()
    FAKE.items[620] = { name = 'Carta A', quality = 0, price = 5, classID = 12, subclassID = 0 }
    FAKE.items[621] = { name = 'Carta B', quality = 0, price = 5, classID = 12, subclassID = 0 }
    FAKE.items[622] = { name = 'Carta C', quality = 0, price = 5, classID = 12, subclassID = 0 }
    install({
        [50] = { startedBy = { nil, nil, { 620 } } },
        [51] = { startedBy = { nil, nil, { 621 } }, specialFlags = 'x', questFlags = {} },
        [52] = { startedBy = { nil, nil, { 622 } }, specialFlags = 0, questFlags = 0 },
    })
    FAKE.completed[50], FAKE.completed[51], FAKE.completed[52] = true, true, true
    ns.Player.Invalidate()
    local ctx = ns.Player.GetContext()
    for _, id in ipairs({ 620, 621 }) do
        local result = ns.Classify(ns.Player.ReadLink(FAKE.linkOf(id)), ctx)
        eq(result.mark, nil, 'item ' .. id)
        eq(result.reasons[1].kind, 'quest_starter_done_unknown_repeat', 'item ' .. id)
    end
    local confirmed = ns.Classify(ns.Player.ReadLink(FAKE.linkOf(622)), ctx)
    eq(confirmed.mark, 'coin', 'no repetible confirmado')
end)

test('mision de otra raza filtrada; sin restriccion o de la propia, no', function()
    FAKE.raceID = HUMAN
    install({
        [1] = { sourceItemId = 600, requiredRaces = HORDE },
        [2] = { sourceItemId = 600, requiredRaces = ALLIANCE },
        [3] = { sourceItemId = 600, requiredRaces = 0 },
        [4] = { sourceItemId = 600 },
        [5] = { sourceItemId = 600, requiredRaces = 2 + 1 },
        [6] = { sourceItemId = 601, requiredRaces = 2 },
    })
    eq(questIDs(ns.Questie.Uses(600)), '2,3,4,5')
    eq(ns.Questie.Uses(601), nil, 'si todas las misiones se filtran no queda nada')
end)

test('el filtro de raza sigue al personaje', function()
    FAKE.raceID = ORC; FAKE.faction = 'Horde'
    install({
        [1] = { sourceItemId = 600, requiredRaces = HORDE },
        [2] = { sourceItemId = 600, requiredRaces = ALLIANCE },
        [3] = { sourceItemId = 600, requiredRaces = 4 },
    })
    eq(questIDs(ns.Questie.Uses(600)), '1')
end)

test('raza desconocida: se filtra por facccion; sin datos de faccion, se conserva', function()
    FAKE.raceID = 99; FAKE.faction = 'Horde'
    install({
        [1] = { sourceItemId = 600, requiredRaces = ALLIANCE },
        [2] = { sourceItemId = 600, requiredRaces = HORDE },
        [3] = { sourceItemId = 600, requiredRaces = ALLIANCE + HORDE },
    })
    eq(questIDs(ns.Questie.Uses(600)), '2,3')
    FAKE.Reset(); FAKE.raceID = 99; FAKE.faction = nil
    install({ [1] = { sourceItemId = 600, requiredRaces = ALLIANCE } })
    eq(questIDs(ns.Questie.Uses(600)), '1', 'sin faccion no se puede descartar: se conserva')
end)

test('mision de otra clase filtrada', function()
    FAKE.class = 'MAGE'
    install({
        [1] = { sourceItemId = 600, requiredClasses = WARRIOR },
        [2] = { sourceItemId = 600, requiredClasses = MAGE },
        [3] = { sourceItemId = 600, requiredClasses = WARRIOR + MAGE },
        [4] = { sourceItemId = 600, requiredClasses = 0 },
    })
    eq(questIDs(ns.Questie.Uses(600)), '2,3,4')
end)

test('Caballero de la Muerte usa DEATH_KNIGHT de classKeys', function()
    FAKE.class = 'DEATHKNIGHT'
    install({
        [1] = { sourceItemId = 600, requiredClasses = 32 },
        [2] = { sourceItemId = 600, requiredClasses = WARRIOR },
    })
    eq(questIDs(ns.Questie.Uses(600)), '1')
end)

test('sin datos de raza o clase del personaje: se conservan las misiones', function()
    FAKE.Remove('UnitRace'); FAKE.Remove('UnitFactionGroup'); FAKE.Remove('UnitClass')
    install({ [1] = { sourceItemId = 600, requiredRaces = HORDE, requiredClasses = WARRIOR } })
    eq(questIDs(ns.Questie.Uses(600)), '1')
end)

test('error de LibQuestieDB durante el armado: Uses nil, sin lanzar', function()
    install({
        [10] = { objectives = { nil, nil, { { 500 } } } },
        [20] = { objectives = { nil, nil, { { 500 } } } },
    }, { throwOn = 20 })
    eq(ns.Questie.Uses(500), nil)
    FAKE.Advance(5)
    eq(ns.Questie.Uses(500), nil)
    eq(ns.Questie.Uses('no es un id'), nil)
end)

test('error de LibQuestieDB en el armado sincrono: Uses nil, sin lanzar', function()
    withoutTimer(function()
        FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } }, { throwOn = 10 })
        eq(ns.Questie.Uses(500), nil)
        eq(ns.Questie.Uses(500), nil)
    end)
end)

test('error al listar las misiones: Uses nil, sin lanzar', function()
    FAKE.InstallQuestie({})
    LibQuestieDB.Quest.GetAllIds = function() error('GetAllIds roto') end
    eq(ns.Questie.Uses(500), nil)
    FAKE.Advance(5)
    eq(ns.Questie.Uses(500), nil)
end)

test('con Questie presente, se espera a que este listo antes de armar', function()
    local waiting
    Questie = { API = { isReady = false, RegisterOnReady = function(fn) waiting = fn end } }
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    eq(ns.Questie.Uses(500), nil)
    FAKE.Advance(5)
    eq(FAKE.questieCalls, 0, 'Questie aun aplica sus correcciones: no se lee nada')
    ok(waiting ~= nil, 'se registro el aviso de Questie')
    eq(ns.Questie.Uses(500), nil)
    Questie.API.isReady = true
    waiting()
    FAKE.Advance(5)
    eq(questIDs(ns.Questie.Uses(500)), '10')
end)

test('con Questie ya listo, se arma de inmediato', function()
    Questie = { API = { isReady = true, RegisterOnReady = function() error('no deberia registrarse') end } }
    install({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    eq(questIDs(ns.Questie.Uses(500)), '10')
end)

test('al terminar el indice invalida el contexto y avisa a OnReady', function()
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    local before = ns.Player.GetContext()
    eq(ns.Player.GetContext(), before)
    local notified = 0
    ns.Questie.OnReady(function() notified = notified + 1 end)
    ns.Questie.OnReady(function() error('un aviso roto no frena al resto') end)
    ns.Questie.OnReady(function() notified = notified + 1 end)
    ns.Questie.Uses(500)
    eq(ns.Player.GetContext(), before, 'mientras arma, el contexto sigue siendo el mismo')
    FAKE.Advance(5)
    ok(ns.Player.GetContext() ~= before, 'el contexto se reconstruye al terminar')
    eq(notified, 2)
    eq(ns.Questie.IsReady(), true)
end)

test('el contexto del personaje usa Questie.Uses y el clasificador lo respeta', function()
    FAKE.items[500] = { name = 'Cuero', quality = 1, price = 10, classID = 15, subclassID = 0 }
    install({
        [10] = { objectives = { nil, nil, { { 500 } } } },
        [20] = { objectives = { nil, nil, { { 500 } } } },
        [30] = { objectives = { nil, nil, { { 500 } } }, requiredRaces = HORDE },
    })
    local item = ns.Player.ReadLink(FAKE.linkOf(500))
    FAKE.questLog = { { title = 'Veinte', questID = 20 } }
    ns.Player.Invalidate()
    local active = ns.Classify(item, ns.Player.GetContext())
    eq(active.mark, 'quest', 'la 20 esta en el diario')
    eq(active.reasons[1].questID, 20)
    -- Regla del 2026-11-17: fuera del diario (futura o hecha) ya no protege.
    FAKE.questLog = {}
    ns.Player.Invalidate()
    local idle = ns.Classify(item, ns.Player.GetContext())
    eq(idle.mark, 'coin', 'ninguna mision del diario la pide')
    eq(idle.reasons[1].kind, 'quest_not_active')
    -- La 30 es de la Horda: aunque figure en el diario de un aliado (imposible), no cuenta.
    FAKE.questLog = { { title = 'Treinta', questID = 30 } }
    ns.Player.Invalidate()
    eq(ns.Classify(item, ns.Player.GetContext()).mark, 'coin', 'la 30 no aplica')
end)

test('Pending: solo mientras QuestieDB esta disponible y el indice no termino', function()
    eq(ns.Questie.Pending(), false, 'sin LibQuestieDB')
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    eq(ns.Questie.Pending(), true, 'disponible, aun sin armar')
    ns.Questie.Uses(500)
    eq(ns.Questie.Pending(), true, 'armando')
    FAKE.Advance(5)
    eq(ns.Questie.Pending(), false, 'listo')
end)

test('Pending: esperando a Questie cuenta como pendiente; un fallo definitivo, no', function()
    local waiting
    Questie = { API = { isReady = false, RegisterOnReady = function(fn) waiting = fn end } }
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    ns.Questie.Uses(500)
    eq(ns.Questie.Pending(), true, 'esperando')
    FAKE.Reset()
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } }, { throwOn = 10 })
    ns.Questie.Uses(500); FAKE.Advance(5)
    eq(ns.Questie.Pending(), false, 'fallo definitivo = sin Questie')
end)

test('indice sin terminar: item gris de una mision sin hacer no da moneda; con el indice listo y la mision hecha, si', function()
    FAKE.items[500] = { name = 'Pelo', quality = 0, price = 5, classID = 15, subclassID = 0 }
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    local item = ns.Player.ReadLink(FAKE.linkOf(500))
    local before = ns.Classify(item, ns.Player.GetContext())
    eq(before.mark, nil, 'sin moneda antes de terminar el indice')
    eq(before.reasons[1].kind, 'quest_log_incomplete')
    FAKE.completed[10] = true
    FAKE.Advance(5)
    eq(ns.Classify(item, ns.Player.GetContext()).mark, 'coin', 'indice listo y mision hecha')
    FAKE.completed[10] = nil
    FAKE.questLog = { { title = 'Diez', questID = 10 } }
    ns.Player.Invalidate()
    eq(ns.Classify(item, ns.Player.GetContext()).mark, 'quest', 'indice listo y mision en el diario')
end)

test('item de clase que no puede usar tampoco da moneda mientras el indice esta pendiente', function()
    FAKE.class = 'MAGE'
    FAKE.items[501] = { name = 'Espadon', quality = 1, price = 5, classID = 2, subclassID = 8 }
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 501 } } } } })
    local item = ns.Player.ReadLink(FAKE.linkOf(501))
    item.hasUseOrEquipSpell = false
    eq(ns.Classify(item, ns.Player.GetContext()).mark, nil)
    FAKE.Advance(5)
    FAKE.completed[10] = true
    ns.Player.Invalidate()
    eq(ns.Classify(item, ns.Player.GetContext()).mark, 'coin')
end)

test('al terminar el indice OnChanged avisa (questLogIncomplete true -> nil) sin pedir el contexto', function()
    FAKE.InstallQuestie({ [10] = { objectives = { nil, nil, { { 500 } } } } })
    local seen = {}
    ns.Player.OnChanged(function(ctx) seen[#seen + 1] = ctx end)
    eq(ns.Player.GetContext().questLogIncomplete, true)
    eq(#seen, 0)
    ns.Questie.Uses(500)
    eq(#seen, 0, 'armando: aun no cambia nada')
    FAKE.Advance(5)
    eq(#seen, 1, 'OnChanged avisa una vez al terminar')
    eq(seen[1].questLogIncomplete, nil)
    eq(ns.Player.GetContext(), seen[1])
end)

test('playerInfo: raza y clase se cachean por separado', function()
    local calls = { race = 0, class = 0 }
    local raceID = nil
    UnitRace = function() calls.race = calls.race + 1; return 'x', 'x', raceID end
    UnitClass = function() calls.class = calls.class + 1; return 'Mago', 'MAGE' end
    install({ [1] = { sourceItemId = 600, requiredRaces = ORC, requiredClasses = MAGE } })
    local classBase, raceBase = calls.class, calls.race -- Player.GetContext tambien las lee al terminar el indice
    ns.Questie.Uses(600); ns.Questie.Uses(600)
    eq(calls.class, classBase + 1, 'la clase ya resuelta no se vuelve a leer')
    eq(calls.race, raceBase + 2, 'la raza sin resolver se reintenta')
    raceID = HUMAN
    eq(ns.Questie.Uses(600), nil, 'ya se sabe que es humano: mision de orcos filtrada')
    local race = calls.race
    ns.Questie.Uses(600)
    eq(calls.race, race, 'la raza resuelta se guarda')
    eq(calls.class, classBase + 1)
end)

-- Item 10 de la ola final: las referencias a items de extraObjectives tambien cuentan
-- (contrato QuestieDB: { spawns?, icono, texto?, indice, { {'item', itemID}, ... }? }).
test('extraObjectives: un item referenciado cuenta como uso de la mision', function()
    install({
        [10] = { objectives = { nil, nil, { { 500 } } } },
        [20] = { extraObjectives = { { nil, 5, 'Usar el cuerno', 1, { { 'item', 500 }, { 'monster', 77 } } } } },
        [30] = { extraObjectives = { { { [1] = {} }, 3, 'Sin referencias', 0 } } },
    })
    eq(questIDs(ns.Questie.Uses(500)), '10,20')
    eq(ns.Questie.Uses(77), nil, 'las referencias a criaturas no son items')
    -- Mision 20 (extra) en el diario: sin moneda, marca de mision. Fuera del diario: moneda.
    local ctx = { class = 'MAGE', professions = {}, overrides = {}, questItemsInLog = {},
        isQuestDone = function(q) return q == 10 end, questieUses = ns.Questie.Uses,
        questInLog = function(q) return q == 20 end }
    eq(ns.Classify({ id = 500, quality = 0, price = 5 }, ctx).mark, 'quest')
    ctx.questInLog = function() return false end
    eq(ns.Classify({ id = 500, quality = 0, price = 5 }, ctx).mark, 'coin')
end)

-- Re-revision: una referencia ilegible en extraObjectives se saltea SOLA; el indice queda listo y
-- los demas usos (otras misiones, iniciador repetible) siguen protegiendo.
test('extraObjectives ilegible: se saltea esa parte y el resto sigue protegiendo', function()
    FAKE.items[99012] = { name = 'Item99012', quality = 0, price = 10, classID = 15, subclassID = 0 }
    FAKE.items[99013] = { name = 'Item99013', quality = 1, price = 10, classID = 15, subclassID = 0 }
    FAKE.bags['0:1'] = 99012
    local savedStarters = ns.Data.starters
    ns.Data.starters = setmetatable({ [99013] = 30 }, { __index = savedStarters })
    FAKE.completed[30] = true
    local success, err = pcall(function()
        install({
            [10] = { objectives = { nil, nil, { { 99012 } } } },
            [20] = { extraObjectives = { { nil, 5, 'Ilegible', 1, { { 'item', 'x' } } }, 'basura' } },
            [30] = { startedBy = { nil, nil, { 99013 } }, specialFlags = 1 },
        })
        eq(ns.Questie.Pending(), false)
        eq(questIDs(ns.Questie.Uses(99012)), '10', 'el indice sigue listo')
        FAKE.questLog = { { title = 'Diez', questID = 10 } }
        FAKE.Fire('QUEST_LOG_UPDATE')
        local ctx = ns.Player.GetContext()
        local gray = ns.Classify(ns.Player.ReadLink(FAKE.linkOf(99012)), ctx)
        eq(gray.mark, 'quest'); eq(gray.reasons[1].kind, 'quest_active')
        local starter = ns.Classify(ns.Player.ReadLink(FAKE.linkOf(99013)), ctx)
        eq(starter.mark, nil); eq(starter.reasons[1].kind, 'quest_repeatable')
        local button = CreateFrame('Button', nil, UIParent)
        ns.Marks.Update(button, 0, 1)
        ok(not (button.KnuJunkMark and button.KnuJunkMark:IsShown()), 'sin moneda visible en 0:1')
    end)
    ns.Data.starters = savedStarters
    if not success then error(err, 0) end
end)

-- Correccion del user (2026-11-17): los iniciadores se distinguen (starter = true) porque siguen su
-- propia regla: mision no hecha -> util aunque no este en el diario; hecha -> moneda.
test('startedBy: el uso del iniciador lleva starter = true y protege mientras la mision no este hecha', function()
    FAKE.items[600] = { name = 'Carta vieja', quality = 1, price = 5, classID = 12, subclassID = 0 }
    install({
        [40] = { startedBy = { nil, nil, { 600 } }, specialFlags = 0, questFlags = 0 },
        [41] = { objectives = { nil, nil, { { 600 } } } },
    })
    local uses = ns.Questie.Uses(600)
    eq(questIDs(uses), '40,41')
    for _, use in ipairs(uses) do eq(use.starter, use.questID == 40 or nil, 'starter de ' .. use.questID) end
    local item = ns.Player.ReadLink(FAKE.linkOf(600))
    ns.Player.Invalidate()
    local pending = ns.Classify(item, ns.Player.GetContext())
    eq(pending.mark, nil); eq(pending.reasons[1].kind, 'quest_starter'); eq(pending.reasons[1].questID, 40)
    FAKE.completed[40] = true
    ns.Player.Invalidate()
    local done = ns.Classify(item, ns.Player.GetContext())
    eq(done.mark, 'coin'); eq(done.reasons[1].kind, 'quest_done')
end)
