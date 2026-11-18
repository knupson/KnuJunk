-- Clasificador: cada prueba fija sus propios datos (reactivos/iniciadores) y los restaura.
local function withData(reagents, starters, fn, tools)
    local savedR, savedS, savedT = ns.Data.reagents, ns.Data.starters, ns.Data.tools
    ns.Data.reagents, ns.Data.starters, ns.Data.tools = reagents or {}, starters or {}, tools or {}
    local success, err = pcall(fn)
    ns.Data.reagents, ns.Data.starters, ns.Data.tools = savedR, savedS, savedT
    if not success then error(err, 0) end
end

local function item(fields)
    local base = { id = 9000, quality = 1, classID = 15, subclassID = 0, price = 10 }
    for key, value in pairs(fields or {}) do base[key] = value end
    return base
end

local function ctx(fields)
    local base = { class = 'MAGE', professions = {}, overrides = {}, questItemsInLog = {},
        isQuestDone = function() return false end, questieUses = function() return nil end,
        questInLog = function() return false end }
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

test('herramienta de tu profesion -> hammer_mine con profession_tool', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [164] = true } })
        eq(result.mark, 'hammer_mine')
        local reason = hasReason(result, 'profession_tool')
        ok(reason, 'reason profession_tool')
        eq(#reason.professions, 1); eq(reason.professions[1], 164)
    end, { [9000] = { 164, 202 } })
end)

test('herramienta de otra profesion -> hammer_other con todas sus profesiones', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [171] = true } })
        eq(result.mark, 'hammer_other')
        local reason = hasReason(result, 'profession_tool')
        eq(#reason.professions, 2); eq(reason.professions[1], 164); eq(reason.professions[2], 202)
    end, { [9000] = { 164, 202 } })
end)

test('herramienta gris con precio -> nunca monedita', function()
    withData({}, {}, function()
        local gray = item { quality = 0, price = 50 }
        local mine = ns.Classify(gray, ctx { professions = { [186] = true } })
        eq(mine.mark, 'hammer_mine'); ok(not hasReason(mine, 'gray'), 'sin motivo gris')
        local other = ns.Classify(gray, ctx())
        eq(other.mark, 'hammer_other'); ok(not hasReason(other, 'gray'), 'sin motivo gris')
    end, { [9000] = { 186 } })
end)

test('herramienta: override sell da monedita, keep ninguna, mision activa -> martillo con quest', function()
    withData({}, {}, function()
        eq(ns.Classify(item(), ctx { overrides = { [9000] = 'sell' } }).mark, 'coin')
        eq(ns.Classify(item(), ctx { overrides = { [9000] = 'keep' } }).mark, nil)
        local quest = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(quest.mark, 'hammer_other'); eq(quest.quest, true)
    end, { [9000] = { 164 } })
end)

test('item que es reactivo y herramienta: manda el reactivo; la herramienta cubre lo que el reactivo no', function()
    withData({ [9000] = { 171 } }, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [171] = true } })
        eq(result.mark, 'hammer_mine'); ok(hasReason(result, 'profession'), 'reactivo')
        local viaTool = ns.Classify(item(), ctx { professions = { [164] = true } })
        eq(viaTool.mark, 'hammer_mine'); ok(hasReason(viaTool, 'profession_tool'), 'herramienta')
        eq(hasReason(viaTool, 'profession_tool').professions[1], 164)
    end, { [9000] = { 164 } })
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
        local result = ns.Classify(item { classID = 4, subclassID = 4, quality = 2, subclassName = 'Placas' }, ctx { class = 'MAGE' })
        eq(result.mark, 'coin')
        local reason = hasReason(result, 'class_cannot_use')
        eq(reason.classID, 4); eq(reason.subclassID, 4); eq(reason.subclassName, 'Placas')
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
        eq(ns.Classify(item { classID = 2, subclassID = 20, quality = 2 }, ctx()).mark, 'hammer_other') -- cania: herramienta de Pesca, nunca coin
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

-- Regla del 2026-11-17: solo protege una mision que esta AHORA en el diario. Futuras, no tomadas,
-- hechas o repetibles no tomadas no protegen nada (los iniciadores tienen su propia regla).
test('questie: mision futura que no esta en el diario -> coin quest_not_active', function()
    withData({}, {}, function()
        local uses = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = false } } end
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx {
            questieUses = uses, isQuestDone = function(q) return q == 1 end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_not_active'), 'reason quest_not_active')
        local active = ns.Classify(item { quality = 0, price = 5 }, ctx {
            questieUses = uses, questInLog = function(q) return q == 2 end })
        eq(active.mark, 'quest'); eq(hasReason(active, 'quest_active').questID, 2)
    end)
end)

test('questie todas hechas -> coin quest_not_active', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = false } } end,
            isQuestDone = function() return true end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_not_active'), 'reason quest_not_active')
    end)
end)

test('questie: repetible no tomada -> coin; diario que no sabe (nil) -> sin moneda', function()
    withData({}, {}, function()
        local repeatable = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = true } } end,
            isQuestDone = function() return true end })
        eq(repeatable.mark, 'coin'); ok(hasReason(repeatable, 'quest_not_active'), 'quest_not_active')
        local unknown = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 1, repeatable = false } } end,
            questInLog = function() return nil end })
        eq(unknown.mark, nil, 'no se sabe si esta en el diario: nunca moneda')
        ok(hasReason(unknown, 'quest_log_incomplete'), 'quest_log_incomplete')
        local noFn = ctx { questieUses = function() return { { questID = 1 } } end }
        noFn.questInLog = nil
        eq(ns.Classify(item(), noFn).mark, nil, 'sin questInLog: nunca moneda')
    end)
end)

test('item de mision (clase 12) que ninguna mision activa pide -> coin quest_not_active', function()
    withData({}, {}, function()
        local quest = item { classID = 12, quality = 1, price = 0 }
        -- Sin QuestieDB: decide solo el diario.
        local alone = ns.Classify(quest, ctx { questieUses = nil })
        eq(alone.mark, 'coin'); ok(hasReason(alone, 'quest_not_active'), 'sin QuestieDB')
        -- QuestieDB dice que una mision futura lo usa: igual es basura.
        local future = ns.Classify(quest, ctx { questieUses = function() return { { questID = 50 } } end })
        eq(future.mark, 'coin'); ok(hasReason(future, 'quest_not_active'), 'mision futura')
        -- En el diario: marca de mision con el titulo que da el diario.
        local inLog = ns.Classify(quest, ctx { questItemsInLog = { [9000] = true },
            questItemTitle = function(id) return id == 9000 and 'Los lobos' or nil end })
        eq(inLog.mark, 'quest'); eq(hasReason(inLog, 'quest_active').title, 'Los lobos')
        ok(not hasReason(inLog, 'quest_not_active'), 'sin quest_not_active')
    end)
end)

test('item de mision: diario incompleto, reactivo o con efecto de uso -> sin moneda', function()
    withData({}, {}, function()
        local quest = item { classID = 12, quality = 1 }
        local incomplete = ns.Classify(quest, ctx { questLogIncomplete = true,
            questieUses = function() return { { questID = 50 } } end })
        eq(incomplete.mark, nil); ok(hasReason(incomplete, 'quest_log_incomplete'), 'diario incompleto')
        local useful = ns.Classify(item { classID = 12, quality = 1, hasUseOrEquipSpell = true }, ctx {
            questieUses = function() return { { questID = 50 } } end })
        eq(useful.mark, nil, 'con efecto de uso')
    end)
    withData({ [9000] = { 171 } }, {}, function()
        local reagent = ns.Classify(item { classID = 12, quality = 1 }, ctx {
            questieUses = function() return { { questID = 50 } } end })
        eq(reagent.mark, 'hammer_other'); eq(reagent.quest, nil)
        local active = ns.Classify(item { classID = 12, quality = 1 }, ctx {
            questieUses = function() return { { questID = 50 } } end, questInLog = function(q) return q == 50 end })
        eq(active.mark, 'hammer_other'); eq(active.quest, true)
    end)
end)

-- Correccion del user (2026-11-17): un iniciador cuya mision no hiciste es util aunque no este en
-- el diario; con la mision hecha (y no repetible) es basura.
test('iniciador de QuestieDB: no hecha -> quest_starter; hecha -> coin quest_done', function()
    withData({}, {}, function()
        local uses = function() return { { questID = 60, starter = true } } end
        local pending = ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = uses })
        eq(pending.mark, nil); eq(hasReason(pending, 'quest_starter').questID, 60)
        local unknown = ns.Classify(item(), ctx { questieUses = uses, isQuestDone = function() return nil end })
        eq(unknown.mark, nil, 'no se sabe si esta hecha: util')
        local done = ns.Classify(item(), ctx { questieUses = uses, isQuestDone = function() return true end })
        eq(done.mark, 'coin'); eq(hasReason(done, 'quest_done').questID, 60)
        ok(not hasReason(done, 'quest_not_active'), 'el iniciador no usa la regla del diario')
        local repeatable = ns.Classify(item(), ctx { questieUses = function() return { { questID = 60, starter = true, repeatable = true } } end,
            isQuestDone = function() return true end })
        eq(repeatable.mark, nil); ok(hasReason(repeatable, 'quest_repeatable'), 'repetible')
    end)
    withData({}, { [9000] = 61 }, function()
        local notTaken = ns.Classify(item { classID = 12 }, ctx())
        eq(notTaken.mark, nil, 'iniciador de mision no tomada ni hecha: util')
        eq(hasReason(notTaken, 'quest_starter').questID, 61)
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

-- Canarios de ClassGear contra los datos de Forever (SkillLineAbility ClassMask, build en
-- Data/ClassGear.lua): un picaro aprende hachas de una mano y un druida armas de asta.
test('ClassGear: hacha 1M en ROGUE -> sin moneda', function()
    withData({}, {}, function()
        local axe = item { classID = 2, subclassID = 0, quality = 2 }
        eq(ns.Classify(axe, ctx { class = 'ROGUE' }).mark, nil)
    end)
end)

test('ClassGear: arma de asta en DRUID -> sin moneda', function()
    withData({}, {}, function()
        local polearm = item { classID = 2, subclassID = 6, quality = 2 }
        eq(ns.Classify(polearm, ctx { class = 'DRUID' }).mark, nil)
    end)
end)

test('ClassGear: generado desde datos con build', function()
    ok(type(ns.Data.build) == 'string' and ns.Data.build ~= '', 'build')
    local file = assert(io.open('Data/ClassGear.lua', 'r'))
    local first = file:read('*l'); file:close()
    ok(first:find('Generado por tools/build_data.py', 1, true), 'cabecera generada: ' .. tostring(first))
end)

-- Item 2 de la ola final: un uso repetible conocido por Questie bloquea TODA moneda automatica.
test('iniciador repetible hecho sin moneda; repetible no tomada ya no protege', function()
    withData({}, { [9000] = 99001 }, function()
        local repeatable = function() return { { questID = 99001, repeatable = true } } end
        local done = function() return true end
        local starter = ns.Classify(item(), ctx { questieUses = repeatable, isQuestDone = done })
        eq(starter.mark, nil, 'iniciador de repetible')
        ok(not hasReason(starter, 'quest_done'), 'sin quest_done')
    end)
    -- Desde el 2026-11-17 una repetible que no esta en el diario ya no protege nada (no iniciador).
    withData({}, {}, function()
        local repeatable = function() return { { questID = 99001, repeatable = true } } end
        local done = function() return true end
        eq(ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = repeatable, isQuestDone = done }).mark, 'coin', 'gris')
        local plate = item { classID = 4, subclassID = 4, quality = 2, hasUseOrEquipSpell = false, isSetPiece = false }
        eq(ns.Classify(plate, ctx { class = 'MAGE', questieUses = repeatable, isQuestDone = done }).mark, 'coin', 'clase')
        local mixed = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = true } } end
        eq(ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = mixed, isQuestDone = done }).mark, 'coin', 'mezcla')
        local active = ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = repeatable,
            questInLog = function(q) return q == 99001 end })
        eq(active.mark, 'quest', 'repetible tomada: protege')
        local sold = ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = repeatable, isQuestDone = done,
            overrides = { [9000] = 'sell' } })
        eq(sold.mark, 'coin', 'override_sell sigue valiendo')
    end)
end)

-- Item 5: efecto de uso/equipar o pieza de set => ninguna moneda automatica (gris, mision
-- terminada incluida la de Questie, clase). override_sell sigue valiendo.
test('utilidad del item precede a toda moneda automatica', function()
    withData({}, {}, function()
        local done = function() return true end
        local questie = function() return { { questID = 1, repeatable = false } } end
        -- Arma usable por el mago con efecto de uso y set, objetivo de una mision entregada.
        local weapon = item { classID = 2, subclassID = 7, quality = 2, hasUseOrEquipSpell = true, isSetPiece = true }
        eq(ns.Classify(weapon, ctx { questieUses = questie, isQuestDone = done }).mark, nil, 'arma usable')
        -- Consumible con efecto de uso, objetivo de una mision entregada.
        local potion = item { classID = 0, subclassID = 1, quality = 1, hasUseOrEquipSpell = true }
        eq(ns.Classify(potion, ctx { questieUses = questie, isQuestDone = done }).mark, nil, 'consumible')
        -- Pieza de set sin hechizo, mision entregada.
        local setPiece = item { classID = 4, subclassID = 1, quality = 2, isSetPiece = true }
        eq(ns.Classify(setPiece, ctx { questieUses = questie, isQuestDone = done }).mark, nil, 'set')
        -- Gris con efecto de uso.
        eq(ns.Classify(item { quality = 0, price = 5, hasUseOrEquipSpell = true }, ctx()).mark, nil, 'gris con uso')
        -- override_sell sobre un item util sigue dando moneda.
        local sold = ns.Classify(potion, ctx { overrides = { [9000] = 'sell' } })
        eq(sold.mark, 'coin', 'override_sell')
    end)
    withData({}, { [9000] = 123 }, function()
        local starter = item { hasUseOrEquipSpell = true }
        eq(ns.Classify(starter, ctx { isQuestDone = function() return true end }).mark, nil, 'iniciador con uso')
    end)
end)

test('caña de pescar: martillito de Pesca aunque no figure en spelltotems', function()
    withData({}, {}, function()
        local cana = item { id = 6256, classID = 2, subclassID = 20, quality = 0, price = 5 }
        local mine = ns.Classify(cana, ctx { professions = { [356] = true } })
        eq(mine.mark, 'hammer_mine'); eq(hasReason(mine, 'profession_tool').professions[1], 356)
        eq(ns.Classify(cana, ctx()).mark, 'hammer_other', 'sin Pesca: martillo gris, nunca moneda')
    end)
end)

-- Util para una mision pendiente Y reactivo/herramienta: martillo (las bolsas lo dibujan), con
-- quest = true y los motivos de mision; el botin dibuja el signo de mision.
test('reactivo con mision activa de questie -> hammer_other con quest', function()
    withData({ [9000] = { 164, 171 } }, {}, function()
        local result = ns.Classify(item(), ctx {
            questieUses = function() return { { questID = 77, repeatable = false } } end,
            questInLog = function(q) return q == 77 end,
        })
        eq(result.mark, 'hammer_other'); eq(result.quest, true)
        eq(hasReason(result, 'quest_active').questID, 77)
        eq(hasReason(result, 'profession').professions[2], 171)
    end)
end)

test('reactivo propio en el diario de misiones -> hammer_mine con quest', function()
    withData({ [9000] = { 164 } }, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [164] = true }, questItemsInLog = { [9000] = true } })
        eq(result.mark, 'hammer_mine'); eq(result.quest, true)
        ok(hasReason(result, 'quest_active'), 'quest_active')
        eq(hasReason(result, 'quest_active').questID, nil)
    end)
end)

test('herramienta con mision pendiente -> hammer con quest', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'hammer_other'); eq(result.quest, true)
    end, { [9000] = { 186 } })
end)

test('item de mision que no es reactivo ni herramienta -> quest sin quest=true', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'quest'); eq(result.quest, nil)
    end)
end)
