-- Contexto del personaje y lectura de items.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 1, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
    return base
end

test('clase del personaje', function()
    FAKE.class = 'WARRIOR'
    eq(ns.Player.GetContext().class, 'WARRIOR')
end)

test('profesiones por GetProfessions', function()
    FAKE.professions = { { name = 'Blacksmithing', skillLine = 164 }, { name = 'Mining', skillLine = 186 } }
    local professions = ns.Player.GetContext().professions
    eq(professions[164], true); eq(professions[186], true); eq(professions[171], nil)
end)

test('GetProfessions: sin skillLine usa el nombre', function()
    FAKE.professions = { { name = 'Alquimia' } }
    eq(ns.Player.GetContext().professions[171], true)
end)

test('profesiones por GetSkillLineInfo en espanol', function()
    FAKE.Remove('GetProfessions'); FAKE.Remove('GetProfessionInfo')
    FAKE.skillLines = { { name = 'Profesiones', isHeader = true }, { name = 'Herrería' },
        { name = 'MINERÍA' }, { name = 'Espadas' } }
    local professions = ns.Player.GetContext().professions
    eq(professions[164], true); eq(professions[186], true)
    eq(professions[165], nil)
end)

test('profesiones por GetSkillLineInfo en ingles, sin mayusculas ni tildes', function()
    FAKE.Remove('GetProfessions')
    FAKE.skillLines = { { name = 'blacksmithing' }, { name = 'Primeros Auxilios' }, { name = 'Herreria' } }
    local professions = ns.Player.GetContext().professions
    eq(professions[164], true); eq(professions[129], true)
end)

test('un encabezado con nombre de profesion no cuenta', function()
    FAKE.Remove('GetProfessions')
    FAKE.skillLines = { { name = 'Herrería', isHeader = true } }
    eq(ns.Player.GetContext().professions[164], nil)
end)

test('nombres de profesion para los 12 SkillLine', function()
    for skillLine in pairs(ns.PROFESSIONS) do
        local name = ns.ProfessionName(skillLine)
        ok(name, 'nombre de ' .. skillLine)
        eq(ns.ProfessionByName(name), skillLine)
    end
    eq(ns.ProfessionName(164), 'Herrería')
    FAKE.locale = 'enUS'
    eq(ns.ProfessionName(164), 'Blacksmithing')
    FAKE.locale = nil
end)

test('isQuestDone con C_QuestLog', function()
    FAKE.completed[100] = true
    local ctx = ns.Player.GetContext()
    eq(ctx.isQuestDone(100), true); eq(ctx.isQuestDone(101), false)
end)

test('isQuestDone cae al global IsQuestFlaggedCompleted', function()
    FAKE.Remove('C_QuestLog.IsQuestFlaggedCompleted')
    FAKE.completed[100] = true
    local ctx = ns.Player.GetContext()
    eq(ctx.isQuestDone(100), true); eq(ctx.isQuestDone(101), false)
end)

test('sin API de misiones -> isQuestDone devuelve nil', function()
    FAKE.Remove('C_QuestLog.IsQuestFlaggedCompleted'); FAKE.Remove('IsQuestFlaggedCompleted')
    local ctx = ns.Player.GetContext()
    eq(type(ctx.isQuestDone), 'function')
    eq(ctx.isQuestDone(100), nil)
end)

test('items de misiones del diario por objetivos', function()
    addItem(500, { name = 'Garra de lobo', quality = 0 })
    addItem(501, { name = 'Otra cosa', quality = 0 })
    FAKE.questLog = {
        { questID = 1, isHeader = true },
        { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' },
            { text = 'Lobo muerto: 1/5', type = 'monster' } } },
    }
    local items = ns.Player.GetContext().questItemsInLog
    eq(items[500], true); eq(items[501], nil)
end)

test('item de mision no resuelto por nombre se reconoce igual al consultar', function()
    FAKE.questLog = { { questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } } }
    local items = ns.Player.GetContext().questItemsInLog
    eq(items[500], nil) -- el item aun no esta en el cache del cliente
    addItem(500, { name = 'Garra de lobo', quality = 0 })
    eq(items[500], true)
end)

test('ReadItem sin datos -> nil', function()
    FAKE.bags['0:1'] = 600 -- sin FAKE.items[600]: GetItemInfo devuelve nil
    eq(ns.Player.ReadItem(0, 1), nil)
    eq(ns.Player.ReadItem(0, 2), nil) -- slot vacio
    eq(ns.Player.ReadLink(nil), nil)
    eq(ns.Player.ReadLink(FAKE.linkOf(600)), nil)
end)

test('ReadItem devuelve la forma item', function()
    addItem(700, { quality = 2, price = 123, classID = 4, subclassID = 4, equipLoc = 'INVTYPE_CHEST' })
    FAKE.bags['0:1'] = 700
    local item = ns.Player.ReadItem(0, 1)
    eq(item.id, 700); eq(item.quality, 2); eq(item.price, 123)
    eq(item.classID, 4); eq(item.subclassID, 4); eq(item.equipLoc, 'INVTYPE_CHEST')
    eq(item.hasUseOrEquipSpell, false); eq(item.isSetPiece, false)
end)

test('hasUseOrEquipSpell e isSetPiece nunca son nil con datos cargados', function()
    addItem(701, { spell = true, setID = 55 })
    local item = ns.Player.ReadLink(FAKE.linkOf(701))
    eq(item.hasUseOrEquipSpell, true); eq(item.isSetPiece, true)
    addItem(702, {})
    item = ns.Player.ReadLink(FAKE.linkOf(702))
    eq(item.hasUseOrEquipSpell, false); eq(item.isSetPiece, false)
end)

test('sin GetItemSpell: hasUseOrEquipSpell = true (conservador)', function()
    FAKE.Remove('GetItemSpell')
    addItem(703, {})
    eq(ns.Player.ReadLink(FAKE.linkOf(703)).hasUseOrEquipSpell, true)
end)

test('ReadItem con GetContainerItemLink si no hay C_Container', function()
    FAKE.Remove('C_Container.GetContainerItemInfo')
    addItem(704, {})
    GetContainerItemLink = function() return FAKE.linkOf(704) end
    local item = ns.Player.ReadItem(0, 1)
    GetContainerItemLink = nil
    eq(item.id, 704)
end)

test('ctx usa ns.DB.overrides y ns.Questie.Uses si existen', function()
    eq(ns.Player.GetContext().overrides, ns.DB.overrides)
    eq(ns.Player.GetContext().questieUses, nil)
    ns.Questie = { Uses = function() return {} end }
    ns.Player.Invalidate()
    eq(ns.Player.GetContext().questieUses, ns.Questie.Uses)
    ns.Questie = nil
end)

test('el contexto se cachea', function()
    eq(ns.Player.GetContext(), ns.Player.GetContext())
end)

test('Invalidate tras QUEST_TURNED_IN recalcula', function()
    local before = ns.Player.GetContext()
    eq(before.professions[186], nil)
    FAKE.professions = { { name = 'Mining', skillLine = 186 } }
    eq(ns.Player.GetContext(), before) -- sigue cacheado
    FAKE.Fire('QUEST_TURNED_IN')
    local after = ns.Player.GetContext()
    ok(after ~= before, 'contexto nuevo')
    eq(after.professions[186], true)
end)

test('los otros eventos tambien invalidan', function()
    for _, event in ipairs({ 'SKILL_LINES_CHANGED', 'QUEST_LOG_UPDATE', 'PLAYER_LEVEL_UP', 'QUEST_ACCEPTED' }) do
        local before = ns.Player.GetContext()
        FAKE.Fire(event)
        ok(ns.Player.GetContext() ~= before, event)
    end
end)

test('Invalidate manual', function()
    local before = ns.Player.GetContext()
    ns.Player.Invalidate()
    ok(ns.Player.GetContext() ~= before)
end)

test('GetContext alimenta el clasificador de punta a punta', function()
    addItem(800, { quality = 0, price = 5 })
    FAKE.bags['0:1'] = 800
    local result = ns.Classify(ns.Player.ReadItem(0, 1), ns.Player.GetContext())
    eq(result.mark, 'coin')
end)

-- Diario con encabezados plegados.
local function collapsedLog()
    addItem(500, { name = 'Garra de lobo', quality = 0 })
    FAKE.questLog = {
        { title = 'Elwynn', isHeader = true, isCollapsed = true },
        { title = 'Lobos', questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } },
        { title = 'Westfall', isHeader = true, isCollapsed = false },
        { title = 'Cosecha', questID = 3, objectives = { { text = 'Maiz: 0/4', type = 'item' } } },
    }
end

test('diario con encabezado plegado: expande, lee objetivo y vuelve a plegar', function()
    collapsedLog()
    FAKE.selected = 3
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[500], true)
    eq(ctx.questLogIncomplete, nil)
    eq(FAKE.questLog[1].isCollapsed, true, 'Elwynn vuelve a plegado')
    eq(FAKE.questLog[3].isCollapsed, false, 'Westfall sigue expandido')
    eq(FAKE.calls.expand, 1); eq(FAKE.calls.collapse, 1)
    eq(FAKE.selected, 3, 'seleccion conservada')
end)

test('diario con encabezado plegado, API clasica', function()
    collapsedLog()
    FAKE.Remove('C_QuestLog.GetInfo')
    FAKE.selected = 2
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[500], true)
    eq(FAKE.questLog[1].isCollapsed, true); eq(FAKE.questLog[3].isCollapsed, false)
    eq(FAKE.calls.expand, 1); eq(FAKE.calls.collapse, 1)
    eq(FAKE.selected, 2)
end)

test('en combate con encabezado plegado usa el ultimo escaneo completo', function()
    collapsedLog()
    ns.Player.GetContext() -- escaneo completo (fuera de combate)
    FAKE.calls = { expand = 0, collapse = 0 }
    FAKE.inCombat = true
    ns.Player.Invalidate()
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[500], true, 'conserva lo del escaneo completo')
    eq(ctx.questLogIncomplete, nil)
    eq(FAKE.calls.expand, 0, 'no toca el diario en combate')
    eq(FAKE.questLog[1].isCollapsed, true)
end)

test('sin escaneo previo y plegado en combate -> questLogIncomplete y gris sin moneda', function()
    collapsedLog()
    FAKE.inCombat = true
    local ctx = ns.Player.GetContext()
    eq(ctx.questLogIncomplete, true)
    eq(FAKE.calls.expand, 0)
    addItem(900, { quality = 0, price = 5 })
    local result = ns.Classify(ns.Player.ReadLink(FAKE.linkOf(900)), ctx)
    eq(result.mark, nil)
    local found = false
    for _, reason in ipairs(result.reasons) do if reason.kind == 'quest_log_incomplete' then found = true end end
    ok(found, 'reason quest_log_incomplete')
end)

test('sin API para expandir: igual que en combate', function()
    collapsedLog()
    FAKE.Remove('C_QuestLog.ExpandQuestHeader'); FAKE.Remove('ExpandQuestHeader')
    eq(ns.Player.GetContext().questLogIncomplete, true)
end)

test('sin API de diario: questLogIncomplete', function()
    FAKE.Remove('C_QuestLog'); FAKE.Remove('GetNumQuestLogEntries')
    eq(ns.Player.GetContext().questLogIncomplete, true)
end)

test('diario completo y legible: no hay questLogIncomplete', function()
    eq(ns.Player.GetContext().questLogIncomplete, nil)
end)

test('no entra en bucle con QUEST_LOG_UPDATE al expandir', function()
    collapsedLog()
    local changes = 0
    ns.Player.OnChanged(function() changes = changes + 1 end)
    ns.Player.GetContext()
    eq(FAKE.calls.expand, 1)
    -- Ecos del propio expandir (llegan despues del escaneo), con reconstruccion diferida.
    for _ = 1, 5 do
        FAKE.Fire('QUEST_LOG_UPDATE')
        FAKE.Advance(1)
        ns.Player.GetContext()
    end
    eq(FAKE.calls.expand, 1, 'no vuelve a expandir')
    eq(FAKE.calls.collapse, 1)
    eq(changes, 0, 'el contenido no cambio: OnChanged no avisa')
    eq(#FAKE.timers, 0, 'no queda nada programado')
end)

test('una mision aceptada justo despues de expandir se detecta (sin ventana ciega)', function()
    collapsedLog()
    local fired = 0
    ns.Player.OnChanged(function() fired = fired + 1 end)
    ns.Player.GetContext()
    FAKE.Fire('QUEST_LOG_UPDATE') -- eco de la expansion
    FAKE.Advance(1)
    -- Sin pasar tiempo: el jugador acepta una mision bajo el encabezado plegado.
    addItem(501, { name = 'Piel de jabali', quality = 0 })
    table.insert(FAKE.questLog, 3, { title = 'Jabalies', questID = 4,
        objectives = { { text = 'Piel de jabali: 0/3', type = 'item' } } })
    FAKE.Fire('QUEST_ACCEPTED')
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[501], true, 'item de la mision nueva')
    eq(ctx.questItemsInLog[500], true)
    eq(FAKE.calls.expand, 2, 'reescaneo porque cambio el total de misiones')
    eq(fired, 1)
    eq(FAKE.questLog[1].isCollapsed, true)
    -- Y su propio eco tampoco entra en bucle.
    FAKE.Fire('QUEST_LOG_UPDATE')
    FAKE.Advance(1)
    ns.Player.GetContext()
    eq(FAKE.calls.expand, 2); eq(fired, 1)
end)

test('un cambio real avisa por OnChanged con la reconstruccion diferida', function()
    local fired, last = 0, nil
    ns.Player.OnChanged(function(ctx) fired = fired + 1; last = ctx end)
    ns.Player.GetContext()
    FAKE.professions = { { name = 'Mining', skillLine = 186 } }
    FAKE.Fire('SKILL_LINES_CHANGED')
    eq(fired, 0, 'todavia no: la reconstruccion es diferida')
    FAKE.Advance(1)
    eq(fired, 1)
    eq(last.professions[186], true)
    FAKE.Advance(1); eq(fired, 1)
end)

test('los eventos pendientes se agrupan en una sola reconstruccion diferida', function()
    ns.Player.OnChanged(function() end)
    ns.Player.GetContext()
    FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Fire('QUEST_ACCEPTED'); FAKE.Fire('QUEST_REMOVED')
    eq(#FAKE.timers, 1)
end)

test('QUEST_TURNED_IN y los demas eventos invalidan', function()
    collapsedLog()
    for _, event in ipairs({ 'QUEST_TURNED_IN', 'QUEST_ACCEPTED', 'QUEST_REMOVED', 'PLAYER_REGEN_ENABLED' }) do
        local ctx = ns.Player.GetContext()
        FAKE.Fire(event)
        ok(ns.Player.GetContext() ~= ctx, event)
    end
end)

test('si expandir no surte efecto, el diario queda incompleto y scanning no se traba', function()
    collapsedLog()
    FAKE.Remove('C_QuestLog.ExpandQuestHeader')
    C_QuestLog.ExpandQuestHeader = function() end -- no hace nada
    local ctx = ns.Player.GetContext()
    eq(ctx.questLogIncomplete, true)
    FAKE.Fire('QUEST_TURNED_IN') -- si scanning quedara en true, esto se ignoraria
    ok(ns.Player.GetContext() ~= ctx, 'scanning se libero')
end)

test('un encabezado plegado sin titulo no rompe el escaneo', function()
    addItem(500, { name = 'Garra de lobo', quality = 0 })
    FAKE.questLog = {
        { isHeader = true, isCollapsed = true },
        { title = 'Lobos', questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } },
    }
    eq(ns.Player.GetContext().questItemsInLog[500], true)
end)

-- Encabezados de habilidades plegados.
local function collapsedSkills()
    FAKE.Remove('GetProfessions')
    FAKE.skillLines = {
        { name = 'Habilidades de armas', isHeader = true, isExpanded = true },
        { name = 'Espadas' },
        { name = 'Profesiones', isHeader = true, isExpanded = false },
        { name = 'Herrería' },
    }
end

test('habilidades con encabezado plegado: expande, lee la profesion y vuelve a plegar', function()
    collapsedSkills()
    local professions = ns.Player.GetContext().professions
    eq(professions[164], true)
    eq(FAKE.skillLines[3].isExpanded, false, 'Profesiones vuelve a plegado')
    eq(FAKE.skillLines[1].isExpanded, true)
    eq(FAKE.calls.expand, 1); eq(FAKE.calls.collapse, 1)
    -- Eco del propio expandir: se reconstruye pero sin volver a expandir (misma huella).
    FAKE.Fire('SKILL_LINES_CHANGED')
    eq(ns.Player.GetContext().professions[164], true)
    eq(FAKE.calls.expand, 1)
end)

test('habilidades plegadas en combate: no toca nada y no hay profesion', function()
    collapsedSkills()
    FAKE.inCombat = true
    eq(ns.Player.GetContext().professions[164], nil)
    eq(FAKE.calls.expand, 0)
    eq(FAKE.skillLines[3].isExpanded, false)
end)
