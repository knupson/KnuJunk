-- Clasificador: cada prueba fija sus propios datos (reactivos/iniciadores) y los restaura.
local function withData(reagents, starters, fn)
    local savedR, savedS = ns.Data.reagents, ns.Data.starters
    ns.Data.reagents, ns.Data.starters = reagents or {}, starters or {}
    local success, err = pcall(fn)
    ns.Data.reagents, ns.Data.starters = savedR, savedS
    if not success then error(err, 0) end
end

local function item(fields)
    local base = { id = 9000, quality = 1, classID = 15, subclassID = 0, price = 10 }
    for key, value in pairs(fields or {}) do base[key] = value end
    return base
end

local function ctx(fields)
    local base = { class = 'MAGE', professions = {}, overrides = {}, questItemsInLog = {},
        isQuestDone = function() return false end, questieUses = function() return nil end }
    for key, value in pairs(fields or {}) do base[key] = value end
    return base
end

local function hasReason(result, kind)
    for _, reason in ipairs(result.reasons) do if reason.kind == kind then return reason end end
end

test('gris vendible -> coin', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx())
        eq(result.mark, 'coin'); ok(hasReason(result, 'gray'), 'reason gray')
    end)
end)

test('gris sin precio -> nil', function()
    withData({}, {}, function()
        eq(ns.Classify(item { quality = 0, price = 0 }, ctx()).mark, nil)
        local noPrice = item { quality = 0 }; noPrice.price = nil
        eq(ns.Classify(noPrice, ctx()).mark, nil)
    end)
end)

test('reactivo de Herreria con Herreria -> hammer_mine con 164', function()
    withData({ [9000] = { 164, 202 } }, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [164] = true } })
        eq(result.mark, 'hammer_mine')
        local reason = hasReason(result, 'profession')
        ok(reason, 'reason profession')
        local found = false
        for _, line in ipairs(reason.professions) do if line == 164 then found = true end end
        ok(found, 'incluye 164')
    end)
end)

test('reactivo de Herreria sin profesiones -> hammer_other', function()
    withData({ [9000] = { 164 } }, {}, function()
        local result = ns.Classify(item(), ctx())
        eq(result.mark, 'hammer_other')
        eq(hasReason(result, 'profession').professions[1], 164)
    end)
end)

test('iniciador con mision hecha -> coin quest_done', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item(), ctx { isQuestDone = function(q) return q == 123 end })
        eq(result.mark, 'coin')
        eq(hasReason(result, 'quest_done').questID, 123)
    end)
end)

test('iniciador con isQuestDone nil -> nil', function()
    withData({}, { [9000] = 123 }, function()
        eq(ns.Classify(item(), ctx { isQuestDone = function() return nil end }).mark, nil)
        eq(ns.Classify(item(), ctx { isQuestDone = false }).mark, nil)
        local noFn = ctx(); noFn.isQuestDone = nil
        eq(ns.Classify(item(), noFn).mark, nil)
    end)
end)

test('gris iniciador de mision no hecha -> nil', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { isQuestDone = function() return false end })
        eq(result.mark, nil)
        eq(hasReason(result, 'quest_starter').questID, 123)
        ok(not hasReason(result, 'gray'), 'sin reason gray')
    end)
end)

test('gris iniciador con isQuestDone nil -> nil', function()
    withData({}, { [9000] = 123 }, function()
        local gray = item { quality = 0, price = 5 }
        eq(ns.Classify(gray, ctx { isQuestDone = function() return nil end }).mark, nil)
        local noFn = ctx(); noFn.isQuestDone = nil
        eq(ns.Classify(gray, noFn).mark, nil)
    end)
end)

test('gris iniciador con mision hecha -> coin', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { isQuestDone = function() return true end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_done'), 'quest_done')
    end)
end)

test('placas en MAGE -> coin class_cannot_use', function()
    withData({}, {}, function()
        local result = ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, ctx { class = 'MAGE' })
        eq(result.mark, 'coin')
        local reason = hasReason(result, 'class_cannot_use')
        eq(reason.classID, 4); eq(reason.subclassID, 4)
    end)
end)

test('placas en PALADIN -> nil', function()
    withData({}, {}, function()
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, ctx { class = 'PALADIN' }).mark, nil)
    end)
end)

test('placas con hechizo de uso en MAGE -> nil', function()
    withData({}, {}, function()
        local gear = item { classID = 4, subclassID = 4, quality = 2, hasUseOrEquipSpell = true }
        eq(ns.Classify(gear, ctx { class = 'MAGE' }).mark, nil)
        gear = item { classID = 4, subclassID = 4, quality = 2, isSetPiece = true }
        eq(ns.Classify(gear, ctx { class = 'MAGE' }).mark, nil)
    end)
end)

test('subclases fuera de la tabla o clase desconocida -> nunca coin', function()
    withData({}, {}, function()
        eq(ns.Classify(item { classID = 4, subclassID = 0, quality = 2 }, ctx()).mark, nil) -- misc (anillo)
        eq(ns.Classify(item { classID = 2, subclassID = 20, quality = 2 }, ctx()).mark, nil) -- cania
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, ctx { class = 'DEATHKNIGHT' }).mark, nil)
        local noClass = ctx(); noClass.class = nil
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, noClass).mark, nil)
    end)
end)

test('gris que esta en questItemsInLog -> quest, nunca coin', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'quest'); ok(hasReason(result, 'quest_active'), 'reason quest_active')
    end)
end)

test('override keep sobre gris -> nil', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { overrides = { [9000] = 'keep' } })
        eq(result.mark, nil); ok(hasReason(result, 'override_keep'), 'reason override_keep')
    end)
end)

test('override sell sobre reactivo -> coin', function()
    withData({ [9000] = { 164 } }, {}, function()
        local result = ns.Classify(item(), ctx { overrides = { [9000] = 'sell' } })
        eq(result.mark, 'coin'); ok(hasReason(result, 'override_sell'), 'reason override_sell')
    end)
end)

test('questie con una mision pendiente -> quest', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx {
            questieUses = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = false } } end,
            isQuestDone = function(q) return q == 1 end })
        eq(result.mark, 'quest')
    end)
end)

test('questie todas hechas -> coin', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = false } } end,
            isQuestDone = function() return true end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_done'), 'reason quest_done')
    end)
end)

test('questie con mision repetible o desconocida -> sin moneda', function()
    withData({}, {}, function()
        local repeatable = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = true } } end,
            isQuestDone = function() return true end })
        eq(repeatable.mark, nil)
        local unknown = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = false } } end,
            isQuestDone = function() return nil end })
        eq(unknown.mark, 'quest') -- no se sabe: cuenta como pendiente, nunca moneda
    end)
end)

test('item sin quality (datos no cargados) -> nil', function()
    withData({ [9000] = { 164 } }, { [9000] = 123 }, function()
        local unloaded = item { price = 5 }; unloaded.quality = nil
        eq(ns.Classify(unloaded, ctx { isQuestDone = function() return true end }).mark, nil)
    end)
end)

test('questLogIncomplete: ninguna moneda salvo override_sell', function()
    withData({}, {}, function()
        local incomplete = ctx { questLogIncomplete = true }
        local gray = ns.Classify(item { quality = 0, price = 5 }, incomplete)
        eq(gray.mark, nil); ok(hasReason(gray, 'quest_log_incomplete'), 'reason')
        ok(not hasReason(gray, 'gray'), 'sin reason gray')
        local armor = item { quality = 1, classID = 4, subclassID = 4, hasUseOrEquipSpell = false, isSetPiece = false }
        local second = ns.Classify(armor, incomplete)
        eq(second.mark, nil); ok(hasReason(second, 'quest_log_incomplete'), 'class_cannot_use tampoco da moneda')
        -- Sin motivos de moneda no se agrega nada.
        eq(#ns.Classify(item { quality = 1 }, incomplete).reasons, 0)
        -- override_sell sigue valiendo.
        local sold = ns.Classify(item { quality = 1, id = 77 }, ctx { questLogIncomplete = true, overrides = { [77] = 'sell' } })
        eq(sold.mark, 'coin'); ok(hasReason(sold, 'override_sell'), 'override_sell')
    end)
end)
