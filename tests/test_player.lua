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

-- Tanda 1, regla 8: ReadItem dice si el ejemplar esta ligado; ReadLink (sin ubicacion) nunca lo sabe.
test('ReadItem: isBound de GetContainerItemInfo; ReadLink sin ubicacion -> nil', function()
    addItem(720, { quality = 2, classID = 4, subclassID = 4 })
    FAKE.bags['0:1'] = 720; FAKE.bound['0:1'] = true
    FAKE.bags['0:2'] = 720; FAKE.bound['0:2'] = false
    FAKE.bags['0:3'] = 720
    eq(ns.Player.ReadItem(0, 1).isBound, true)
    eq(ns.Player.ReadItem(0, 2).isBound, false)
    eq(ns.Player.ReadItem(0, 3).isBound, nil, 'sin el campo: no se sabe')
    eq(ns.Player.ReadLink(FAKE.linkOf(720)).isBound, nil)
end)

test('ReadItem: C_Item.IsBound con ItemLocation gana; si falla, GetContainerItemInfo', function()
    addItem(721, { quality = 2, classID = 4, subclassID = 4 })
    FAKE.bags['1:4'] = 721; FAKE.bound['1:4'] = false
    local asked
    ItemLocation = { CreateFromBagAndSlot = function(_, bag, slot) return { bag = bag, slot = slot } end }
    C_Item = { IsBound = function(location) asked = location; return true end }
    eq(ns.Player.ReadItem(1, 4).isBound, true)
    eq(asked.bag, 1); eq(asked.slot, 4)
    C_Item = { IsBound = function() error('API rota') end }
    eq(ns.Player.ReadItem(1, 4).isBound, false, 'error: cae a GetContainerItemInfo')
    C_Item = { IsBound = function() return nil end }
    eq(ns.Player.ReadItem(1, 4).isBound, false, 'respuesta no booleana: cae a GetContainerItemInfo')
    C_Item = nil
end)

-- Tanda 1, regla 30: si GetItemSpell no informa nada, el tooltip del item decide: una linea
-- "Equipar:" / "Uso:" / "Probabilidad al acertar:" (o en ingles) es un efecto. Sin poder leerlo: no se
-- sabe (true, conservador). El resultado se guarda por itemID solo si se pudo leer.
test('efecto solo de equipar visto en el tooltip -> hasUseOrEquipSpell', function()
    addItem(730, { tooltip = { 'Placas', 'Equipar: Aumenta tu probabilidad de bloquear un 1%.' } })
    addItem(731, { tooltip = { 'Uso: Te teletransporta.' } })
    addItem(732, { tooltip = { '|cff00ff00Equip: Increases your armor by 10.|r' } })
    addItem(733, { tooltip = { 'Chance on hit: Hits for 10 damage.' } })
    addItem(734, { tooltip = { 'Durabilidad 30 / 30', 'Requiere nivel 10' } })
    for id = 730, 733 do eq(ns.Player.ReadLink(FAKE.linkOf(id)).hasUseOrEquipSpell, true, 'item ' .. id) end
    eq(ns.Player.ReadLink(FAKE.linkOf(734)).hasUseOrEquipSpell, false, 'sin efecto')
    -- Prefijo localizado por la global del cliente.
    ITEM_SPELL_TRIGGER_ONEQUIP = 'Equipado:'
    addItem(735, { tooltip = { 'Equipado: algo.' } })
    eq(ns.Player.ReadLink(FAKE.linkOf(735)).hasUseOrEquipSpell, true, 'global ITEM_SPELL_TRIGGER_ONEQUIP')
end)

test('tooltip del efecto: cache por itemID solo si se pudo leer; ilegible = no se sabe', function()
    addItem(740, {})
    local real = C_TooltipInfo.GetHyperlink
    C_TooltipInfo.GetHyperlink = function() FAKE.tooltipCalls = FAKE.tooltipCalls + 1; return nil end
    eq(ns.Player.ReadLink(FAKE.linkOf(740)).hasUseOrEquipSpell, true, 'sin datos del tooltip: conservador')
    C_TooltipInfo.GetHyperlink = function() error('roto') end
    eq(ns.Player.ReadLink(FAKE.linkOf(740)).hasUseOrEquipSpell, true, 'error: conservador')
    C_TooltipInfo.GetHyperlink = real
    FAKE.tooltipCalls = 0
    eq(ns.Player.ReadLink(FAKE.linkOf(740)).hasUseOrEquipSpell, false, 'legible y sin efecto')
    eq(ns.Player.ReadLink(FAKE.linkOf(740)).hasUseOrEquipSpell, false)
    eq(FAKE.tooltipCalls, 1, 'la segunda lectura sale de la cache')
    -- Con hechizo informado no se lee el tooltip.
    addItem(741, { spell = true })
    FAKE.tooltipCalls = 0
    eq(ns.Player.ReadLink(FAKE.linkOf(741)).hasUseOrEquipSpell, true)
    eq(FAKE.tooltipCalls, 0)
end)

test('sin C_TooltipInfo: GameTooltip oculto; si tampoco se puede leer -> conservador', function()
    FAKE.Remove('C_TooltipInfo')
    addItem(750, { tooltip = { 'Equipar: algo.' } })
    addItem(751, { tooltip = { 'Durabilidad 30 / 30' } })
    -- El GameTooltip del stub no tiene NumLines: ilegible.
    eq(ns.Player.ReadLink(FAKE.linkOf(751)).hasUseOrEquipSpell, true, 'ilegible')
    ns.Player.ResetState()
    local realCreate = CreateFrame
    CreateFrame = function(kind, name, parent, template)
        local frame = realCreate(kind, name, parent, template)
        if kind == 'GameTooltip' then
            frame.count = 0
            function frame:ClearLines() self.count = 0 end
            function frame:NumLines() return self.count end
            function frame:SetHyperlink(link)
                local id = tonumber(link:match('item:(%d+)'))
                local texts = { FAKE.items[id].name }
                for _, text in ipairs(FAKE.items[id].tooltip or {}) do texts[#texts + 1] = text end
                for index, text in ipairs(texts) do realCreate('FontString', name .. 'TextLeft' .. index):SetText(text) end
                self.count = #texts
            end
        end
        return frame
    end
    local success, err = pcall(function()
        eq(ns.Player.ReadLink(FAKE.linkOf(750)).hasUseOrEquipSpell, true, 'efecto por GameTooltip')
        eq(ns.Player.ReadLink(FAKE.linkOf(751)).hasUseOrEquipSpell, false, 'sin efecto por GameTooltip')
    end)
    CreateFrame = realCreate
    if not success then error(err, 0) end
end)

test('ReadItem y ReadLink devuelven subclassName (7mo valor de GetItemInfo)', function()
    addItem(710, { quality = 1, classID = 2, subclassID = 19, subType = 'Varita' })
    FAKE.bags['0:1'] = 710
    eq(ns.Player.ReadItem(0, 1).subclassName, 'Varita')
    eq(ns.Player.ReadLink(FAKE.linkOf(710)).subclassName, 'Varita')
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

-- Item 6 de la ola final: el ID del hechizo cuenta aunque el nombre no haya llegado, y un
-- error de la API es "no se sabe" (conservador).
test('GetItemSpell con nombre nil e ID -> hasUseOrEquipSpell = true', function()
    GetItemSpell = function() return nil, 99004 end
    addItem(705, { classID = 4, subclassID = 4, quality = 2 })
    local item = ns.Player.ReadLink(FAKE.linkOf(705))
    eq(item.hasUseOrEquipSpell, true)
    local ctx = { class = 'MAGE', professions = {}, overrides = {}, questItemsInLog = {},
        isQuestDone = function() return false end }
    eq(ns.Classify(item, ctx).mark, nil, 'placas con hechizo por ID: sin moneda')
end)

test('C_Item.GetItemSpell con ID solo o con error -> conservador', function()
    C_Item = { GetItemSpell = function() return nil, 99004 end }
    addItem(706, {})
    eq(ns.Player.ReadLink(FAKE.linkOf(706)).hasUseOrEquipSpell, true, 'solo ID')
    C_Item = { GetItemSpell = function() error('API rota') end }
    eq(ns.Player.ReadLink(FAKE.linkOf(706)).hasUseOrEquipSpell, true, 'error')
    C_Item = { GetItemSpell = function() return nil, nil end }
    eq(ns.Player.ReadLink(FAKE.linkOf(706)).hasUseOrEquipSpell, false, 'sin hechizo')
    C_Item = nil
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
    eq(ns.Player.GetContext().questieUses, ns.Questie.Uses) -- QuestieSource.lua ya esta cargado
    local saved = ns.Questie
    ns.Questie = nil
    ns.Player.Invalidate()
    eq(ns.Player.GetContext().questieUses, nil)
    ns.Questie = { Uses = function() return {} end }
    ns.Player.Invalidate()
    eq(ns.Player.GetContext().questieUses, ns.Questie.Uses)
    ns.Questie = saved
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

-- Item 3 de la ola final: un escaneo anterior no certifica un diario que cambio y no se
-- puede releer (combate). La certificacion vuelve solo con un escaneo completo.
test('mision aceptada en combate bajo encabezado plegado -> questLogIncomplete hasta reescanear', function()
    collapsedLog()
    ns.Player.GetContext() -- escaneo completo fuera de combate
    FAKE.inCombat = true
    addItem(502, { name = 'Colmillo nuevo', quality = 0, price = 5 })
    table.insert(FAKE.questLog, 2, { title = 'Colmillos', questID = 5,
        objectives = { { text = 'Colmillo nuevo: 0/3', type = 'item' } } })
    FAKE.Fire('QUEST_ACCEPTED')
    local ctx = ns.Player.GetContext()
    eq(ctx.questLogIncomplete, true, 'diario cambiado sin poder releerlo')
    eq(ctx.questItemsInLog[500], true, 'lo del ultimo escaneo sigue protegiendo')
    eq(ns.Classify(ns.Player.ReadLink(FAKE.linkOf(502)), ctx).mark, nil, 'gris nuevo sin moneda')
    eq(FAKE.calls.expand, 1, 'no expande en combate')
    -- Otro evento cualquiera en combate no devuelve la certificacion.
    FAKE.Fire('QUEST_LOG_UPDATE')
    eq(ns.Player.GetContext().questLogIncomplete, true, 'sigue sin certificar')
    -- Fuera de combate se reescanea completo y se recupera.
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    local after = ns.Player.GetContext()
    eq(after.questLogIncomplete, nil)
    eq(after.questItemsInLog[502], true)
end)

test('sin total y en combate: el escaneo anterior no certifica', function()
    collapsedLog()
    FAKE.noTotal = true
    ns.Player.GetContext()
    FAKE.inCombat = true
    FAKE.Fire('QUEST_ACCEPTED')
    eq(ns.Player.GetContext().questLogIncomplete, true)
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

test('abandonar una mision y aceptar otra bajo un encabezado plegado (mismo total) se detecta', function()
    collapsedLog()
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[500], true); eq(FAKE.calls.expand, 1)
    -- Misma cantidad de misiones: la huella no cambia.
    addItem(501, { name = 'Piel de jabali', quality = 0 })
    FAKE.questLog[2] = { title = 'Jabalies', questID = 4,
        objectives = { { text = 'Piel de jabali: 0/3', type = 'item' } } }
    FAKE.Fire('QUEST_REMOVED'); FAKE.Fire('QUEST_ACCEPTED')
    local after = ns.Player.GetContext()
    eq(FAKE.calls.expand, 2, 'reescaneo')
    eq(after.questItemsInLog[501], true, 'item de la mision nueva')
    eq(after.questItemsInLog[500], nil, 'item de la mision abandonada')
    eq(FAKE.questLog[1].isCollapsed, true)
end)

test('QUEST_TURNED_IN tambien fuerza el reescaneo del diario plegado', function()
    collapsedLog()
    ns.Player.GetContext()
    FAKE.Fire('QUEST_TURNED_IN')
    ns.Player.GetContext()
    eq(FAKE.calls.expand, 2)
end)

test('sin total en el cliente: los ecos no expanden sin limite (1 por segundo)', function()
    collapsedLog()
    FAKE.noTotal = true
    ns.Player.OnChanged(function() end)
    local ctx = ns.Player.GetContext()
    eq(ctx.questItemsInLog[500], true); eq(FAKE.calls.expand, 1)
    for _ = 1, 3 do
        FAKE.Fire('QUEST_LOG_UPDATE')
        FAKE.Advance(0.25)
        ns.Player.GetContext()
    end
    eq(FAKE.calls.expand, 1, 'dentro del intervalo se reusa lo ultimo')
    eq(ns.Player.GetContext().questItemsInLog[500], true)
    FAKE.Advance(1)
    FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Advance(0.25); ns.Player.GetContext()
    eq(FAKE.calls.expand, 2, 'pasado el intervalo reescanea una vez')
    for _ = 1, 3 do FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Advance(0.25); ns.Player.GetContext() end
    eq(FAKE.calls.expand, 2)
end)

test('sin total: una mision aceptada dentro del intervalo igual se detecta', function()
    collapsedLog()
    FAKE.noTotal = true
    ns.Player.GetContext()
    addItem(501, { name = 'Piel de jabali', quality = 0 })
    table.insert(FAKE.questLog, 3, { title = 'Jabalies', questID = 4,
        objectives = { { text = 'Piel de jabali: 0/3', type = 'item' } } })
    FAKE.Fire('QUEST_ACCEPTED')
    eq(ns.Player.GetContext().questItemsInLog[501], true)
    eq(FAKE.calls.expand, 2)
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

-- Item 8: cambiar solo el estado de una mision completada avisa por OnChanged.
test('QUEST_TURNED_IN que solo cambia misiones completadas avisa por OnChanged', function()
    local fired = 0
    ns.Player.OnChanged(function() fired = fired + 1 end)
    ns.Player.GetContext()
    FAKE.completed[100] = true
    FAKE.Fire('QUEST_TURNED_IN')
    FAKE.Advance(1)
    eq(fired, 1)
    -- Los ecos del diario sin cambios no vuelven a avisar.
    FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Advance(1)
    eq(fired, 1)
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

-- Regla del 2026-11-17: questInLog dice si una mision esta AHORA en el diario (true/false), o nil si
-- no se puede saber; questItemTitle da el titulo de la mision del diario que pide el item.
test('questInLog y questItemTitle desde el escaneo del diario', function()
    collapsedLog()
    local ctx = ns.Player.GetContext()
    eq(ctx.questInLog(2), true, 'mision bajo encabezado plegado')
    eq(ctx.questInLog(3), true)
    eq(ctx.questInLog(99), false, 'no esta en el diario')
    eq(ctx.questInLog(nil), nil)
    eq(ctx.questItemTitle(500), 'Lobos')
    eq(ctx.questItemTitle(12345), nil)
end)

test('questInLog con la API clasica (questID en el 8.o retorno)', function()
    collapsedLog()
    FAKE.Remove('C_QuestLog.GetInfo')
    local ctx = ns.Player.GetContext()
    eq(ctx.questInLog(2), true); eq(ctx.questInLog(99), false)
    eq(ctx.questItemTitle(500), 'Lobos')
end)

test('questInLog sin questID en el diario: IsOnQuest o nil', function()
    FAKE.questLog = { { title = 'Sin id', objectives = {} } }
    FAKE.Remove('C_QuestLog.GetInfo')
    local ctx = ns.Player.GetContext()
    eq(ctx.questInLog(7), nil, 'no se puede saber')
    C_QuestLog.IsOnQuest = function(questID) return questID == 7 end
    ns.Player.Invalidate()
    ctx = ns.Player.GetContext()
    eq(ctx.questInLog(7), true); eq(ctx.questInLog(8), false)
end)

test('diario vacio con C_QuestLog: ninguna mision esta en el diario', function()
    FAKE.questLog = {}
    eq(ns.Player.GetContext().questInLog(5), false)
end)
