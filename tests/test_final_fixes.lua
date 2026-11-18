-- Arreglos de la revisión final de la rama (diario sin datos, munición sin API, tooltips ajenos).
local function withObjectivesNil(ids, fn)
    local saved = C_QuestLog.GetQuestObjectives
    local requested = {}
    C_QuestLog.GetQuestObjectives = function(questID)
        if ids[questID] then return nil end
        return saved(questID)
    end
    local savedReq = C_QuestLog.RequestLoadQuestByID
    C_QuestLog.RequestLoadQuestByID = function(questID) requested[#requested + 1] = questID end
    local good, err = pcall(fn, requested)
    C_QuestLog.GetQuestObjectives, C_QuestLog.RequestLoadQuestByID = saved, savedReq
    if not good then error(err, 0) end
end

local function wolfLog(collapsed)
    FAKE.items[500] = { name = 'Garra de lobo', quality = 1, price = 10, classID = 12, subclassID = 0 }
    FAKE.questLog = {
        { title = 'Elwynn', isHeader = true, isCollapsed = collapsed or false },
        { title = 'Lobos', questID = 2, objectives = { { text = 'Garra de lobo: 2/8', type = 'item' } } },
    }
end

test('Diario: objetivos sin cargar dejan el diario incompleto y piden los datos', function()
    wolfLog(false)
    withObjectivesNil({ [2] = true }, function(requested)
        local ctx = ns.Player.GetContext()
        eq(ctx.questLogIncomplete, true)
        eq(requested[1], 2)
    end)
    ns.Player.Invalidate()
    local ctx = ns.Player.GetContext()
    eq(ctx.questLogIncomplete, nil); eq(ctx.questItemsInLog[500], true)
end)

test('Diario plegado: un escaneo con objetivos sin cargar no se reutiliza después', function()
    wolfLog(true)
    withObjectivesNil({ [2] = true }, function()
        eq(ns.Player.GetContext().questLogIncomplete, true)
    end)
    FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Advance(1)
    ns.Player.Invalidate()
    local ctx = ns.Player.GetContext()
    eq(ctx.questLogIncomplete, nil); eq(ctx.questItemsInLog[500], true)
end)

test('Diario: fila sin GetInfo deja el diario incompleto', function()
    wolfLog(false)
    local saved = C_QuestLog.GetInfo
    C_QuestLog.GetInfo = function(index) if index == 2 then return nil end return saved(index) end
    local good, err = pcall(function() eq(ns.Player.GetContext().questLogIncomplete, true) end)
    C_QuestLog.GetInfo = saved
    if not good then error(err, 0) end
end)

test('Diario: QUEST_DATA_LOAD_RESULT reconstruye y avisa', function()
    wolfLog(false)
    withObjectivesNil({ [2] = true }, function() ns.Player.GetContext() end)
    local changed = 0
    ns.Player.OnChanged(function() changed = changed + 1 end)
    FAKE.Fire('QUEST_DATA_LOAD_RESULT', 2, true); FAKE.Advance(1)
    ok(changed >= 1, 'avisa al cargar la misión')
    eq(ns.Player.GetContext().questLogIncomplete, nil)
end)

test('Munición: sin APIs de inventario EquippedAmmo da nil y el contexto no falla', function()
    local id, link = GetInventoryItemID, GetInventoryItemLink
    GetInventoryItemID, GetInventoryItemLink = nil, nil
    local good, err = pcall(function()
        eq(select('#', ns.Player.EquippedAmmo()), 1)
        eq(ns.Player.EquippedAmmo(), nil)
        ns.DB.rules.food = true; ns.Player.Invalidate()
        ns.Player.GetContext()
    end)
    GetInventoryItemID, GetInventoryItemLink = id, link
    ns.DB.rules.food = false
    if not good then error(err, 0) end
end)

test('Opcionales: tooltip ajeno o ítem sin relación no reescanean ni avisan', function()
    local good, err = pcall(function()
        ns.DB.rules.food = true; ns.Player.GetContext()
        local changed = 0
        ns.Player.OnChanged(function() changed = changed + 1 end)
        for _ = 1, 5 do FAKE.Fire('TOOLTIP_DATA_UPDATE', 987654); FAKE.Advance(0.25) end
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 999999, true); FAKE.Advance(1)
        eq(changed, 0)
    end)
    ns.DB.rules.food = false
    if not good then error(err, 0) end
end)

test('Opcionales: un ítem de munición no reescanea si sólo está encendida la comida', function()
    local good, err = pcall(function()
        ns.DB.rules.food = true; ns.DB.rules.ammo = false; ns.Player.GetContext()
        local ammoID = next(ns.Data.ammo)
        ok(ammoID, 'hay munición en los datos')
        local changed = 0
        ns.Player.OnChanged(function() changed = changed + 1 end)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', ammoID, true); FAKE.Advance(1)
        eq(changed, 0)
    end)
    ns.DB.rules.food = false
    if not good then error(err, 0) end
end)
