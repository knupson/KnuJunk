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

test('gris = basura como Leatrix', function()
    local cases = {
        { name = 'mision activa', context = { questItemsInLog = { [9000] = true } } },
        { name = 'mision activa de Questie', context = {
            questieUses = function() return { { questID = 123 } } end,
            questInLog = function() return true end } },
        { name = 'herramienta propia', data = { tools = { [9000] = { 164 } } },
            context = { professions = { [164] = true } } },
        { name = 'herramienta ajena', data = { tools = { [9000] = { 164 } } } },
        { name = 'iniciador pendiente', data = { starters = { [9000] = 123 } } },
        { name = 'llave', data = { keys = { [9000] = true } } },
        { name = 'receta', fields = { classID = 9 },
            data = { recipes = { [9000] = { skillLine = 164, rank = 1 } } } },
        { name = 'efecto confirmado', fields = { effect = 'yes', hasUseOrEquipSpell = true } },
        { name = 'efecto desconocido', fields = { effect = 'unknown', hasUseOrEquipSpell = true } },
        { name = 'diario incompleto', context = { questLogIncomplete = true } },
        { name = 'precio de subasta disponible', auction = true },
    }
    local fields = { 'reagents', 'starters', 'tools', 'keys', 'recipes' }
    local saved, savedAuctionator = {}, Auctionator
    for _, field in ipairs(fields) do saved[field] = ns.Data[field] end
    local success, err = pcall(function()
        for _, case in ipairs(cases) do
            for _, field in ipairs(fields) do ns.Data[field] = case.data and case.data[field] or {} end
            Auctionator = case.auction and { API = { v1 = { GetAuctionPriceByItemID = function(caller, id)
                eq(caller, 'KnuJunk'); eq(id, 9000); return 1000
            end } } } or nil
            local value, context = item(case.fields), ctx(case.context)
            value.quality, value.price = 0, 5
            local result = ns.Classify(value, context)
            eq(result.mark, 'coin', case.name)
            ok(hasReason(result, 'gray'), case.name .. ': motivo gris')
            eq(result.auctionPrice, nil, case.name .. ': sin prioridad de subasta')
            value.price = 0
            eq(ns.Classify(value, context).mark, 'trash', case.name .. ': sin valor de venta')
            for _, price in ipairs({ 0, 5 }) do
                value.price = price
                context.overrides = { [9000] = 'keep' }
                local kept = ns.Classify(value, context)
                eq(kept.mark, 'protected', case.name .. ': candado manual')
                ok(hasReason(kept, 'override_keep'), case.name .. ': motivo del candado')
            end
        end
    end)
    for _, field in ipairs(fields) do ns.Data[field] = saved[field] end
    Auctionator = savedAuctionator
    if not success then error(err, 0) end
end)

test('gris sin precio -> nil', function()
    withData({}, {}, function()
        eq(ns.Classify(item { quality = 0, price = 0 }, ctx()).mark, 'trash')
        local noPrice = item { quality = 0 }; noPrice.price = nil
        eq(ns.Classify(noPrice, ctx()).mark, 'useful')
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

test('herramienta gris con precio -> coin, tengas o no la profesion', function()
    withData({}, {}, function()
        local gray = item { quality = 0, price = 50 }
        local mine = ns.Classify(gray, ctx { professions = { [186] = true } })
        eq(mine.mark, 'coin'); ok(hasReason(mine, 'gray'), 'motivo gris')
        local other = ns.Classify(gray, ctx())
        eq(other.mark, 'coin'); ok(hasReason(other, 'gray'), 'motivo gris')
    end, { [9000] = { 186 } })
end)

test('herramienta: override sell da monedita, keep ninguna, mision activa -> martillo con quest', function()
    withData({}, {}, function()
        eq(ns.Classify(item(), ctx { overrides = { [9000] = 'sell' } }).mark, 'coin')
        eq(ns.Classify(item(), ctx { overrides = { [9000] = 'keep' } }).mark, 'protected')
        local quest = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(quest.mark, 'quest'); eq(quest.quest, true)
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

-- Tanda 1, regla 4: un iniciador con la mision hecha solo da moneda si QuestieDB confirma que NO es
-- repetible (repeatable == false explicito). Sin QuestieDB o sin saberlo: sin moneda, motivo propio.
test('iniciador con mision hecha y no repetible confirmada -> coin quest_done', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item(), ctx { isQuestDone = function(q) return q == 123 end,
            questieUses = function() return { { questID = 123, repeatable = false } } end })
        eq(result.mark, 'coin')
        eq(hasReason(result, 'quest_done').questID, 123)
    end)
end)

test('iniciador con mision hecha y repetibilidad desconocida -> sin moneda', function()
    withData({}, { [9000] = 123 }, function()
        local done = function(q) return q == 123 end
        for label, uses in pairs({
            sinQuestie = function() return nil end,
            sinEntrada = function() return { { questID = 5, repeatable = false } } end,
            repetibleNil = function() return { { questID = 123 } } end,
        }) do
            local result = ns.Classify(item { quality = 1, price = 5 }, ctx { isQuestDone = done, questieUses = uses })
            eq(result.mark, 'useful', label)
            eq(hasReason(result, 'quest_starter_done_unknown_repeat').questID, 123, label)
            ok(not hasReason(result, 'gray'), label .. ': sin motivo gris')
        end
        local noFn = ctx { isQuestDone = done }; noFn.questieUses = nil
        eq(ns.Classify(item(), noFn).mark, 'useful', 'sin questieUses')
        local sold = ns.Classify(item(), ctx { isQuestDone = done, overrides = { [9000] = 'sell' } })
        eq(sold.mark, 'coin', 'override_sell sigue valiendo')
    end)
end)

test('iniciador con isQuestDone nil -> nil', function()
    withData({}, { [9000] = 123 }, function()
        eq(ns.Classify(item(), ctx { isQuestDone = function() return nil end }).mark, 'useful')
        eq(ns.Classify(item(), ctx { isQuestDone = false }).mark, 'useful')
        local noFn = ctx(); noFn.isQuestDone = nil
        eq(ns.Classify(item(), noFn).mark, 'useful')
    end)
end)

test('gris iniciador de mision no hecha -> coin', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { isQuestDone = function() return false end })
        eq(result.mark, 'coin')
        eq(hasReason(result, 'quest_starter').questID, 123)
        ok(hasReason(result, 'gray'), 'motivo gris')
    end)
end)

test('gris iniciador con isQuestDone desconocido o ausente -> coin', function()
    withData({}, { [9000] = 123 }, function()
        local gray = item { quality = 0, price = 5 }
        eq(ns.Classify(gray, ctx { isQuestDone = function() return nil end }).mark, 'coin')
        local noFn = ctx(); noFn.isQuestDone = nil
        eq(ns.Classify(gray, noFn).mark, 'coin')
    end)
end)

test('gris iniciador con mision hecha y no repetible -> coin', function()
    withData({}, { [9000] = 123 }, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { isQuestDone = function() return true end,
            questieUses = function() return { { questID = 123, repeatable = false } } end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_done'), 'quest_done')
    end)
end)

test('placas en MAGE ligadas -> coin class_cannot_use', function()
    withData({}, {}, function()
        local result = ns.Classify(item { classID = 4, subclassID = 4, quality = 2, subclassName = 'Placas', isBound = true }, ctx { class = 'MAGE' })
        eq(result.mark, 'coin')
        local reason = hasReason(result, 'class_cannot_use')
        eq(reason.classID, 4); eq(reason.subclassID, 4); eq(reason.subclassName, 'Placas')
    end)
end)

test('placas en PALADIN -> nil', function()
    withData({}, {}, function()
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, ctx { class = 'PALADIN' }).mark, 'useful')
    end)
end)

test('placas con hechizo de uso en MAGE -> nil', function()
    withData({}, {}, function()
        local gear = item { classID = 4, subclassID = 4, quality = 2, hasUseOrEquipSpell = true }
        eq(ns.Classify(gear, ctx { class = 'MAGE' }).mark, 'useful')
        gear = item { classID = 4, subclassID = 4, quality = 2, isSetPiece = true }
        eq(ns.Classify(gear, ctx { class = 'MAGE' }).mark, 'useful')
    end)
end)

test('subclases fuera de la tabla o clase desconocida -> nunca coin', function()
    withData({}, {}, function()
        eq(ns.Classify(item { classID = 4, subclassID = 0, quality = 2 }, ctx()).mark, 'useful') -- misc (anillo)
        eq(ns.Classify(item { classID = 2, subclassID = 20, quality = 2 }, ctx()).mark, 'hammer_other') -- cania: herramienta de Pesca, nunca coin
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, ctx { class = 'DEATHKNIGHT' }).mark, 'useful')
        local noClass = ctx(); noClass.class = nil
        eq(ns.Classify(item { classID = 4, subclassID = 4, quality = 2 }, noClass).mark, 'useful')
    end)
end)

test('gris que esta en questItemsInLog -> coin', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_active'), 'reason quest_active'); ok(hasReason(result, 'gray'), 'motivo gris')
    end)
end)

test('override keep sobre gris -> nil', function()
    withData({}, {}, function()
        local result = ns.Classify(item { quality = 0, price = 5 }, ctx { overrides = { [9000] = 'keep' } })
        eq(result.mark, 'protected'); ok(hasReason(result, 'override_keep'), 'reason override_keep')
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
        local result = ns.Classify(item { quality = 1, price = 5 }, ctx {
            questieUses = uses, isQuestDone = function(q) return q == 1 end })
        eq(result.mark, 'coin'); ok(hasReason(result, 'quest_not_active'), 'reason quest_not_active')
        local active = ns.Classify(item { quality = 1, price = 5 }, ctx {
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
        eq(unknown.mark, 'useful', 'no se sabe si esta en el diario: nunca moneda')
        ok(hasReason(unknown, 'quest_log_incomplete'), 'quest_log_incomplete')
        local noFn = ctx { questieUses = function() return { { questID = 1 } } end }
        noFn.questInLog = nil
        eq(ns.Classify(item(), noFn).mark, 'useful', 'sin questInLog: nunca moneda')
    end)
end)

test('item de mision (clase 12) que ninguna mision activa pide -> coin quest_not_active', function()
    withData({}, {}, function()
        local quest = item { classID = 12, quality = 1, price = 10 }
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

test('item de mision: diario incompleto y reactivo protegen; efecto no protege', function()
    withData({}, {}, function()
        local quest = item { classID = 12, quality = 1 }
        local incomplete = ns.Classify(quest, ctx { questLogIncomplete = true,
            questieUses = function() return { { questID = 50 } } end })
        eq(incomplete.mark, 'useful'); ok(hasReason(incomplete, 'quest_log_incomplete'), 'diario incompleto')
        local useful = ns.Classify(item { classID = 12, quality = 1, hasUseOrEquipSpell = true }, ctx {
            questieUses = function() return { { questID = 50 } } end })
        eq(useful.mark, 'coin', 'con efecto de uso manda la misión')
    end)
    withData({ [9000] = { 171 } }, {}, function()
        local reagent = ns.Classify(item { classID = 12, quality = 1 }, ctx {
            questieUses = function() return { { questID = 50 } } end })
        eq(reagent.mark, 'hammer_other'); eq(reagent.quest, nil)
        local active = ns.Classify(item { classID = 12, quality = 1 }, ctx {
            questieUses = function() return { { questID = 50 } } end, questInLog = function(q) return q == 50 end })
        eq(active.mark, 'quest'); eq(active.quest, true)
    end)
end)

-- Tanda 1, regla 8: el equipo que tu clase no puede usar da moneda SOLO si el ejemplar esta ligado
-- (confirmado). Sin ligar o sin saberlo: sin moneda y un motivo neutro para el tooltip.
test('equipo de otra clase sin ligar o sin saberlo -> sin moneda, motivo class_cannot_use_tradeable', function()
    withData({}, {}, function()
        for label, bound in pairs({ libre = false, desconocido = 'nil' }) do
            local plate = item { classID = 4, subclassID = 4, quality = 2, subclassName = 'Placas' }
            if bound ~= 'nil' then plate.isBound = bound end
            local result = ns.Classify(plate, ctx { class = 'MAGE' })
            eq(result.mark, 'useful', label)
            ok(not hasReason(result, 'class_cannot_use'), label .. ': sin motivo de moneda')
            local reason = hasReason(result, 'class_cannot_use_tradeable')
            ok(reason, label .. ': motivo neutro')
            eq(reason.subclassName, 'Placas'); eq(reason.classID, 4); eq(reason.subclassID, 4)
        end
        -- Gris sin ligar: la moneda del gris sigue; el motivo neutro tambien queda.
        local gray = ns.Classify(item { classID = 4, subclassID = 4, quality = 0, price = 5 }, ctx { class = 'MAGE' })
        eq(gray.mark, 'coin'); ok(hasReason(gray, 'gray'), 'gris')
        ok(not hasReason(gray, 'class_cannot_use'), 'sin moneda por clase')
        -- Usable por la clase: ningun motivo de clase.
        local cloth = ns.Classify(item { classID = 4, subclassID = 1, quality = 2, isBound = true }, ctx { class = 'MAGE' })
        eq(cloth.mark, 'useful'); ok(hasReason(cloth, 'no_rule'))
    end)
end)

-- Tanda 1, regla 15: reactivos/herramientas de hechizos de clase (Data/ClassReagents.lua). Propia o
-- ajena: sin moneda y sin marca (nunca martillo); el motivo dice la clase y, si es la tuya, los hechizos.
local function withClassReagents(map, fn)
    local saved = ns.Data.classReagents
    ns.Data.classReagents = map
    local success, err = pcall(fn)
    ns.Data.classReagents = saved
    if not success then error(err, 0) end
end

test('reactivo de clase: propia se guarda, ajena se vende', function()
    withData({}, {}, function()
        withClassReagents({ [9000] = { 'MAGE', 'PRIEST', spells = { MAGE = { 130 }, PRIEST = { 1706 } } } }, function()
            local reagent = item { quality = 1, price = 5 }
            local own = ns.Classify(reagent, ctx { class = 'MAGE' })
            eq(own.mark, 'useful'); ok(not hasReason(own, 'gray'), 'sin motivo gris')
            local reason = hasReason(own, 'class_reagent')
            eq(reason.own, true); eq(reason.spells[1], 130); eq(reason.classes[1], 'MAGE')
            -- Otra clase: no te sirve, se vende (decision del user 2026-11-21).
            local other = ns.Classify(reagent, ctx { class = 'WARRIOR' })
            eq(other.mark, 'coin')
            local otherReason = hasReason(other, 'class_reagent_other')
            eq(otherReason.classes[1], 'MAGE'); eq(otherReason.classes[2], 'PRIEST')
            ok(not hasReason(other, 'class_reagent'), 'sin el motivo neutro')
            eq(ns.Classify(item { quality = 1, price = 0 }, ctx { class = 'WARRIOR' }).mark, 'useful', 'sin precio se guarda')
            eq(ns.Classify(reagent, ctx { class = nil }).mark, 'useful', 'clase desconocida se guarda')
            local unread = ns.Classify(reagent, ctx { class = 'WARRIOR', questLogIncomplete = true })
            eq(unread.mark, 'useful'); ok(hasReason(unread, 'quest_log_incomplete'), 'diario sin leer')
            local quest = ns.Classify(item { classID = 12 }, ctx { class = 'WARRIOR' })
            eq(quest.mark, 'useful', 'tampoco quest_not_active')
            local sold = ns.Classify(reagent, ctx { overrides = { [9000] = 'sell' } })
            eq(sold.mark, 'coin', 'override_sell sigue valiendo')
        end)
    end)
    -- Si ademas es reactivo de profesion manda el martillo (verde o amarillo), aunque sea de tu clase.
    withData({ [9000] = { 171 } }, {}, function()
        withClassReagents({ [9000] = { 'ROGUE', spells = { ROGUE = { 1 } } } }, function()
            eq(ns.Classify(item(), ctx { class = 'ROGUE', professions = { [171] = true } }).mark, 'hammer_mine', 'alquimista')
            local rogue = ns.Classify(item(), ctx { class = 'ROGUE' })
            eq(rogue.mark, 'hammer_other', 'picaro sin Alquimia: martillo amarillo igual')
            ok(not hasReason(rogue, 'class_reagent'), 'el martillo explica el item')
            eq(ns.Classify(item(), ctx { class = 'MAGE' }).mark, 'hammer_other', 'otra clase sin Alquimia')
        end)
    end)
end)

test('Data: reactivos de clase de ejemplo generados', function()
    local expected = { [17031] = 'MAGE', [17032] = 'MAGE', [17030] = 'SHAMAN', [5140] = 'ROGUE',
        [6265] = 'WARLOCK', [17056] = 'MAGE' }
    for id, class in pairs(expected) do
        local entry = ns.Data.classReagents[id]
        ok(entry, 'falta ' .. id)
        local found = false
        for _, name in ipairs(entry) do if name == class then found = true end end
        ok(found, class .. ' en ' .. id)
        ok(type(entry.spells[class]) == 'table', 'hechizos de ' .. class .. ' en ' .. id)
    end
end)

-- Efecto en tres estados: el gris siempre es basura; en no grises se conserva la proteccion.
-- La moneda por clase exige ligado y efecto conocido; la mision con efecto desconocido se conserva.
test('efecto confirmado o desconocido: gris -> coin; no gris conserva proteccion', function()
    withData({}, {}, function()
        local gray = function(effect) return item { quality = 0, price = 5, effect = effect, hasUseOrEquipSpell = effect ~= 'no' } end
        eq(ns.Classify(gray('yes'), ctx()).mark, 'coin', 'gris con efecto')
        local unknown = ns.Classify(gray('unknown'), ctx())
        eq(unknown.mark, 'coin', 'gris con efecto desconocido'); ok(hasReason(unknown, 'gray'), 'gray')
        eq(ns.Classify(gray('no'), ctx()).mark, 'coin')
        local plate = function(effect) return item { classID = 4, subclassID = 4, quality = 2, isBound = true,
            effect = effect, hasUseOrEquipSpell = effect ~= 'no' } end
        eq(ns.Classify(plate('no'), ctx { class = 'MAGE' }).mark, 'coin', 'ligado y sin efecto')
        local plateUnknown = ns.Classify(plate('unknown'), ctx { class = 'MAGE' })
        eq(plateUnknown.mark, 'useful', 'ligado con efecto desconocido')
        ok(not hasReason(plateUnknown, 'class_cannot_use'), 'sin motivo de moneda')
        eq(ns.Classify(plate('yes'), ctx { class = 'MAGE' }).mark, 'coin')
        -- Gris de otra clase, ligado, efecto desconocido: moneda solo por gris.
        local grayPlate = ns.Classify(item { classID = 4, subclassID = 4, quality = 0, price = 5, isBound = true,
            effect = 'unknown', hasUseOrEquipSpell = true }, ctx { class = 'MAGE' })
        eq(grayPlate.mark, 'coin'); ok(hasReason(grayPlate, 'gray'), 'gray')
        ok(not hasReason(grayPlate, 'class_cannot_use'), 'sin moneda por clase')
        -- Item de mision con efecto desconocido: sin moneda.
        eq(ns.Classify(item { classID = 12, effect = 'unknown', hasUseOrEquipSpell = true }, ctx()).mark, 'useful', 'mision')
    end)
end)

-- Correccion del user (2026-11-17): un iniciador cuya mision no hiciste es util aunque no este en
-- el diario; con la mision hecha (y no repetible) es basura.
test('iniciador de QuestieDB: no hecha -> quest_starter; hecha -> coin quest_done', function()
    withData({}, {}, function()
        local uses = function() return { { questID = 60, starter = true } } end
        local pending = ns.Classify(item { quality = 1, price = 5 }, ctx { questieUses = uses })
        eq(pending.mark, 'useful'); eq(hasReason(pending, 'quest_starter').questID, 60)
        local unknown = ns.Classify(item(), ctx { questieUses = uses, isQuestDone = function() return nil end })
        eq(unknown.mark, 'useful', 'no se sabe si esta hecha: util')
        local done = ns.Classify(item(), ctx { questieUses = function() return { { questID = 60, starter = true, repeatable = false } } end,
            isQuestDone = function() return true end })
        eq(done.mark, 'coin'); eq(hasReason(done, 'quest_done').questID, 60)
        local unknownRepeat = ns.Classify(item(), ctx { questieUses = uses, isQuestDone = function() return true end })
        eq(unknownRepeat.mark, 'useful', 'hecha sin repeatable: no se sabe')
        ok(hasReason(unknownRepeat, 'quest_starter_done_unknown_repeat'), 'motivo')
        ok(not hasReason(done, 'quest_not_active'), 'el iniciador no usa la regla del diario')
        local repeatable = ns.Classify(item(), ctx { questieUses = function() return { { questID = 60, starter = true, repeatable = true } } end,
            isQuestDone = function() return true end })
        eq(repeatable.mark, 'useful'); ok(hasReason(repeatable, 'quest_repeatable'), 'repetible')
    end)
    withData({}, { [9000] = 61 }, function()
        local notTaken = ns.Classify(item { classID = 12 }, ctx())
        eq(notTaken.mark, 'useful', 'iniciador de mision no tomada ni hecha: util')
        eq(hasReason(notTaken, 'quest_starter').questID, 61)
    end)
end)

test('item sin quality (datos no cargados) -> nil', function()
    withData({ [9000] = { 164 } }, { [9000] = 123 }, function()
        local unloaded = item { price = 5 }; unloaded.quality = nil
        eq(ns.Classify(unloaded, ctx { isQuestDone = function() return true end }).mark, nil)
    end)
end)

test('questLogIncomplete: no gris sin moneda salvo override_sell', function()
    withData({}, {}, function()
        local incomplete = ctx { questLogIncomplete = true }
        -- El item de mision blanco seria vendible si el diario estuviera completo.
        local quest = ns.Classify(item { quality = 1, price = 5, classID = 12 }, incomplete)
        eq(quest.mark, 'useful'); ok(hasReason(quest, 'quest_log_incomplete'), 'reason')
        ok(not hasReason(quest, 'gray'), 'sin reason gray')
        local armor = item { quality = 1, classID = 4, subclassID = 4, hasUseOrEquipSpell = false, isSetPiece = false, isBound = true }
        local second = ns.Classify(armor, incomplete)
        eq(second.mark, 'useful'); ok(hasReason(second, 'quest_log_incomplete'), 'class_cannot_use tampoco da moneda')
        -- Sin motivos de moneda se explica la conservación por falta de regla.
        ok(hasReason(ns.Classify(item { quality = 1 }, incomplete), 'no_rule'))
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
        eq(ns.Classify(axe, ctx { class = 'ROGUE' }).mark, 'useful')
    end)
end)

test('ClassGear: arma de asta en DRUID -> sin moneda', function()
    withData({}, {}, function()
        local polearm = item { classID = 2, subclassID = 6, quality = 2 }
        eq(ns.Classify(polearm, ctx { class = 'DRUID' }).mark, 'useful')
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
        eq(starter.mark, 'useful', 'iniciador de repetible')
        ok(not hasReason(starter, 'quest_done'), 'sin quest_done')
    end)
    -- Desde el 2026-11-17 una repetible que no esta en el diario ya no protege nada (no iniciador).
    withData({}, {}, function()
        local repeatable = function() return { { questID = 99001, repeatable = true } } end
        local done = function() return true end
        eq(ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = repeatable, isQuestDone = done }).mark, 'coin', 'gris')
        local plate = item { classID = 4, subclassID = 4, quality = 2, hasUseOrEquipSpell = false, isSetPiece = false, isBound = true }
        eq(ns.Classify(plate, ctx { class = 'MAGE', questieUses = repeatable, isQuestDone = done }).mark, 'coin', 'clase')
        local mixed = function() return { { questID = 1, repeatable = false }, { questID = 2, repeatable = true } } end
        eq(ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = mixed, isQuestDone = done }).mark, 'coin', 'mezcla')
        local active = ns.Classify(item { quality = 1, price = 5 }, ctx { questieUses = repeatable,
            questInLog = function(q) return q == 99001 end })
        eq(active.mark, 'quest', 'repetible tomada: protege')
        local sold = ns.Classify(item { quality = 0, price = 5 }, ctx { questieUses = repeatable, isQuestDone = done,
            overrides = { [9000] = 'sell' } })
        eq(sold.mark, 'coin', 'override_sell sigue valiendo')
    end)
end)

-- Efecto de uso/equipar o pieza de set: sin moneda automatica en no grises
-- (mision terminada incluida la de Questie, clase). override_sell sigue valiendo.
test('utilidad del item no gris precede a la moneda; gris con uso -> coin', function()
    withData({}, {}, function()
        local done = function() return true end
        local questie = function() return { { questID = 1, repeatable = false } } end
        -- Arma usable por el mago con efecto de uso y set, objetivo de una mision entregada.
        local weapon = item { classID = 2, subclassID = 7, quality = 2, hasUseOrEquipSpell = true, isSetPiece = true }
        eq(ns.Classify(weapon, ctx { questieUses = questie, isQuestDone = done }).mark, 'useful', 'arma usable')
        -- Consumible con efecto de uso, objetivo de una mision entregada.
        local potion = item { classID = 0, subclassID = 1, quality = 1, hasUseOrEquipSpell = true }
        eq(ns.Classify(potion, ctx { questieUses = questie, isQuestDone = done }).mark, 'useful', 'consumible')
        -- Pieza de set sin hechizo, mision entregada.
        local setPiece = item { classID = 4, subclassID = 1, quality = 2, isSetPiece = true }
        eq(ns.Classify(setPiece, ctx { questieUses = questie, isQuestDone = done }).mark, 'useful', 'set')
        -- Gris con efecto de uso.
        eq(ns.Classify(item { quality = 0, price = 5, hasUseOrEquipSpell = true }, ctx()).mark, 'coin', 'gris con uso')
        -- override_sell sobre un item util sigue dando moneda.
        local sold = ns.Classify(potion, ctx { overrides = { [9000] = 'sell' } })
        eq(sold.mark, 'coin', 'override_sell')
    end)
    withData({}, { [9000] = 123 }, function()
        local starter = item { hasUseOrEquipSpell = true }
        eq(ns.Classify(starter, ctx { isQuestDone = function() return true end }).mark, 'useful', 'iniciador con uso')
    end)
end)

test('caña de pescar: martillito de Pesca aunque no figure en spelltotems', function()
    withData({}, {}, function()
        local cana = item { id = 6256, classID = 2, subclassID = 20, quality = 1, price = 5 }
        local mine = ns.Classify(cana, ctx { professions = { [356] = true } })
        eq(mine.mark, 'hammer_mine'); eq(hasReason(mine, 'profession_tool').professions[1], 356)
        eq(ns.Classify(cana, ctx()).mark, 'hammer_other', 'sin Pesca: martillo de otra profesion, nunca moneda')
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
        eq(result.mark, 'quest'); eq(result.quest, true)
        eq(hasReason(result, 'quest_active').questID, 77)
        eq(hasReason(result, 'profession').professions[2], 171)
    end)
end)

test('reactivo propio en el diario de misiones -> hammer_mine con quest', function()
    withData({ [9000] = { 164 } }, {}, function()
        local result = ns.Classify(item(), ctx { professions = { [164] = true }, questItemsInLog = { [9000] = true } })
        eq(result.mark, 'quest'); eq(result.quest, true)
        ok(hasReason(result, 'quest_active'), 'quest_active')
        eq(hasReason(result, 'quest_active').questID, nil)
    end)
end)

test('herramienta con mision pendiente -> hammer con quest', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'quest'); eq(result.quest, true)
    end, { [9000] = { 186 } })
end)

test('item de mision que no es reactivo ni herramienta -> quest sin quest=true', function()
    withData({}, {}, function()
        local result = ns.Classify(item(), ctx { questItemsInLog = { [9000] = true } })
        eq(result.mark, 'quest'); eq(result.quest, nil)
    end)
end)

-- Libros de biblioteca y cajones arrebatados (2026-11-17): se guardan hasta entregarlos, asi que
-- los no grises no llevan moneda automatica (ni mision ni clase); /knu junk sell si.
local function withSpecial(books, crates, fn)
    local savedB, savedC = ns.Data.libraryBooks, ns.Data.waylaidCrates
    ns.Data.libraryBooks, ns.Data.waylaidCrates = books, crates
    local success, err = pcall(fn)
    ns.Data.libraryBooks, ns.Data.waylaidCrates = savedB, savedC
    if not success then error(err, 0) end
end

test('libro de biblioteca de clase Mision fuera del diario -> sin moneda, library_book', function()
    withData({}, {}, function()
        withSpecial({ [9000] = true }, {}, function()
            local result = ns.Classify(item { classID = 12, quality = 1, price = 5 }, ctx())
            eq(result.mark, 'useful'); ok(hasReason(result, 'library_book'), 'reason library_book')
            eq(hasReason(result, 'quest_not_active'), nil); eq(hasReason(result, 'gray'), nil)
        end)
    end)
end)

test('libro de biblioteca con uso de Questie fuera del diario -> sin moneda', function()
    withData({}, {}, function()
        withSpecial({ [9000] = true }, {}, function()
            local result = ns.Classify(item { classID = 12 }, ctx {
                questieUses = function() return { { questID = 7 } } end })
            eq(result.mark, 'useful'); ok(hasReason(result, 'library_book'), 'reason library_book')
        end)
    end)
end)

test('cajon arrebatado blanco o de armadura ajena -> sin moneda, waylaid_crate', function()
    withData({}, {}, function()
        withSpecial({}, { [9000] = true }, function()
            local result = ns.Classify(item { quality = 1, price = 5, classID = 12 }, ctx())
            eq(result.mark, 'useful')
            local reason = hasReason(result, 'waylaid_crate')
            ok(reason, 'reason waylaid_crate'); eq(reason.sealed, nil)
        end)
        withSpecial({}, { [9000] = 'sealed' }, function()
            local result = ns.Classify(item { classID = 4, subclassID = 4 }, ctx())
            eq(result.mark, 'useful'); eq(hasReason(result, 'waylaid_crate').sealed, true)
        end)
    end)
end)

test('libro o cajon con override sell -> coin; keep -> override_keep', function()
    withData({}, {}, function()
        withSpecial({ [9000] = true }, { [9000] = true }, function()
            local sell = ns.Classify(item(), ctx { overrides = { [9000] = 'sell' } })
            eq(sell.mark, 'coin'); ok(hasReason(sell, 'override_sell'), 'override_sell')
            local keep = ns.Classify(item(), ctx { overrides = { [9000] = 'keep' } })
            eq(keep.mark, 'protected'); ok(hasReason(keep, 'override_keep'), 'override_keep')
        end)
    end)
end)

test('libro sin datos de item cargados -> igual library_book (no depende del item)', function()
    withData({}, {}, function()
        withSpecial({ [9000] = true }, {}, function()
            local result = ns.Classify({ id = 9000 }, ctx())
            eq(result.mark, nil); eq(result.pending,true); ok(hasReason(result, 'library_book'), 'reason library_book')
        end)
    end)
end)
