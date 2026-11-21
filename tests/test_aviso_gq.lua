local ID = 991077

local function gearLines()
    FAKE.items[ID] = { name = 'Fajín', quality = 2, price = 918, classID = 4, subclassID = 3 }
    local savedClassify = ns.Classify
    ns.Classify = function()
        return { mark = 'useful', reasons = { { kind = 'no_rule', exception = 'gear' } } }
    end
    local good, lines = pcall(ns.Tooltip.Lines, FAKE.linkOf(ID))
    ns.Classify = savedClassify
    if not good then error(lines, 0) end
    local texts = {}
    for _, line in ipairs(lines) do texts[#texts + 1] = line.text end
    return table.concat(texts, '\n')
end

test('aviso GearQuest: con simulación prendida el tooltip del equipo dice cómo apagarla', function()
    GQ = { IsPreviewEnabled = function() return true end }
    local text = gearLines()
    GQ = nil
    ok(text:find('/gq set off', 1, true), 'menciona /gq set off')
end)

test('aviso GearQuest: sin simulación o sin GearQuest no hay aviso', function()
    GQ = { IsPreviewEnabled = function() return false end }
    ok(not gearLines():find('/gq set off', 1, true), 'simulación apagada')
    GQ = { IsPreviewEnabled = function() error('falla') end }
    ok(not gearLines():find('/gq set off', 1, true), 'API que falla')
    GQ = nil
    ok(not gearLines():find('/gq set off', 1, true), 'sin GearQuest')
end)

test('aviso GearQuest: mensaje en el chat sólo con simulación prendida', function()
    GQ = { IsPreviewEnabled = function() return true end }
    eq(ns.Tooltip.WarnGearQuestSimulation(), true)
    ok(FAKE.messages[#FAKE.messages]:find('/gq set off', 1, true), 'chat menciona /gq set off')
    GQ = { IsPreviewEnabled = function() return false end }
    local before = #FAKE.messages
    eq(ns.Tooltip.WarnGearQuestSimulation(), false)
    eq(#FAKE.messages, before)
    GQ = nil
end)

local function gqStub(fields)
    local stub = {
        Data = {
            GetEntriesByItemId = function() return { { pipelineScore = 10 } } end,
            EntryForItemLink = function() return { pipelineScore = 10 } end,
            GearScoreMissText = function() return 'Sin puesto a tu nivel.' end,
        },
        IsPreviewEnabled = function() return false end,
        GetEffectiveLevel = function() return 27 end,
        GetEffectiveClass = function() return 'PALADIN' end,
    }
    for k, v in pairs(fields or {}) do stub.Data[k] = v end
    return stub
end

local function belt()
    return { id = 15528, link = 'item:15528', quality = 2, price = 918, classID = 4, subclassID = 3,
        equipLoc = 'INVTYPE_WAIST', reqLevel = 21, isBound = true }
end

local function ctx27()
    return { class = 'PALADIN', level = 27, professions = {}, overrides = {}, questItemsInLog = {},
        questInLog = function() return false end, isQuestDone = function() return false end,
        rules = { sellUnruled = true, gearNotRanked = true, armorBelow = true } }
end

test('GearQuest puntúa el ítem: tilde verde con motivo gear_ranked, no «sin regla»', function()
    GQ = gqStub()
    local r = ns.Classify(belt(), ctx27())
    GQ = nil
    eq(r.mark, 'useful')
    eq(r.reasons[1].kind, 'gear_ranked')
end)

test('GearQuest sin filas del ítem: queda sin regla y anota el motivo', function()
    GQ = gqStub({ GetEntriesByItemId = function() return {} end })
    local r = ns.Classify(belt(), ctx27())
    GQ = nil
    eq(r.reasons[1].kind, 'no_rule')
    eq(r.gearQuest.state, 'unknown_item')
end)

test('GearQuest con otro nivel: anota el nivel que usa', function()
    GQ = gqStub({ EntryForItemLink = function() return nil end })
    GQ.GetEffectiveLevel = function() return 30 end
    local r = ns.Classify(belt(), ctx27())
    GQ = nil
    eq(r.gearQuest.state, 'level')
    eq(r.gearQuest.gqLevel, 30)
end)

test('GearQuest sin puesto y mismo personaje: monedita gear_not_ranked', function()
    GQ = gqStub({ EntryForItemLink = function() return nil end })
    local r = ns.Classify(belt(), ctx27())
    GQ = nil
    eq(r.mark, 'coin')
    eq(r.reasons[#r.reasons].kind, 'gear_not_ranked')
end)

test('debug: /knu junk debug lista las líneas del tooltip y marca la vacía', function()
    local saved = C_TooltipInfo.GetHyperlink
    C_TooltipInfo.GetHyperlink = function()
        return { lines = { { leftText = 'Fajín', type = 0 }, { leftText = '', type = 5 }, { leftText = 'Cintura', rightText = 'Malla', type = 0 } } }
    end
    local good, err = pcall(function()
        ns.Commands.Handle('debug |Hitem:15528::::|h[Fajín]|h')
        local text = table.concat(FAKE.messages, '\n')
        ok(text:find('INCOMPLETA', 1, true), 'marca la línea vacía')
        ok(text:find('Malla', 1, true), 'muestra el texto derecho')
        ok(text:find('lectura=', 1, true), 'resume la lectura')
    end)
    C_TooltipInfo.GetHyperlink = saved
    if not good then error(err, 0) end
end)

test('tooltip: la línea de precio de venta (tipo 11, sin texto) no deja la lectura incompleta', function()
    local saved = C_TooltipInfo.GetHyperlink
    C_TooltipInfo.GetHyperlink = function()
        return { lines = { { leftText = 'Anillo de cuerno', type = 22 }, { leftText = 'Se liga al recogerlo', type = 20 },
            { leftText = 'Dedo', type = 21 }, { leftText = '+3 Aguante', type = 0 }, { leftText = '+2 Espíritu', type = 0 },
            { leftText = '', type = 11 } } }
    end
    local good, err = pcall(function()
        local lines = ns.Player.DebugTooltip('item:17692')
        local text = table.concat(lines, '\n')
        ok(not text:find('INCOMPLETA', 1, true), 'sin líneas incompletas')
        ok(text:find('lectura=complete', 1, true), 'lectura completa')
    end)
    C_TooltipInfo.GetHyperlink = saved
    if not good then error(err, 0) end
end)

test('GearQuest publicado como _G.GearQuest (nombre real de GearQuestForever) también decide', function()
    GearQuest = gqStub({ EntryForItemLink = function() return nil end })
    local r = ns.Classify(belt(), ctx27())
    GearQuest = nil
    eq(r.mark, 'coin')
    eq(r.reasons[#r.reasons].kind, 'gear_not_ranked')
end)

test('GearQuest con fila pero sin línea de puesto (caso Fajín): monedita, no «lo puntúa»', function()
    GearQuest = gqStub()
    GearQuest.Data.GearScoreTooltipLine = function() return nil end
    local r = ns.Classify(belt(), ctx27())
    GearQuest = nil
    eq(r.mark, 'coin')
    eq(r.reasons[#r.reasons].kind, 'gear_not_ranked')
end)

test('GearQuest con fila y línea de puesto: se guarda', function()
    GearQuest = gqStub()
    GearQuest.Data.GearScoreTooltipLine = function() return 'Puesto n.º 9 para tu nivel' end
    local r = ns.Classify(belt(), ctx27())
    GearQuest = nil
    eq(r.reasons[1].kind, 'gear_ranked')
end)

local function ring()
    return { id = 17692, link = 'item:17692', quality = 2, price = 881, classID = 4, subclassID = 0,
        equipLoc = 'INVTYPE_FINGER', isBound = true, effect = 'no' }
end
local function ctxNR()
    local c = ctx27(); c.rules.gearNoRanking = true; return c
end
local function pawn(info, best)
    PawnGetItemData = function() return { Link = 'item:17692' } end
    PawnIsItemAnUpgrade = function() return info, nil, best end
end
local function noPawn() PawnGetItemData, PawnIsItemAnUpgrade = nil, nil end

test('sin dudas: anillo que GearQuest no conoce y Pawn marca como mejora se guarda con su motivo', function()
    GearQuest = gqStub({ GetEntriesByItemId = function() return {} end })
    pawn({ { ScaleName = 'p', LocalizedScaleName = 'Protección', PercentUpgrade = 0.88 } })
    local r = ns.Classify(ring(), ctxNR())
    GearQuest = nil; noPawn()
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'pawn_upgrade'); eq(r.reasons[1].scale, 'Protección')
    eq(ns.Marks.MarkOf(r), 'useful')
end)

test('sin dudas: Pawn dice que no es mejora => se vende (gear_no_ranking)', function()
    GearQuest = gqStub({ GetEntriesByItemId = function() return {} end })
    pawn(nil, nil)
    local r = ns.Classify(ring(), ctxNR())
    GearQuest = nil; noPawn()
    eq(r.mark, 'coin'); eq(r.reasons[1].kind, 'gear_no_ranking'); eq(r.reasons[1].pawn, true)
end)

test('sin dudas: Pawn sin datos todavía no deja vender; ya es lo mejor => se guarda', function()
    GearQuest = gqStub({ GetEntriesByItemId = function() return {} end })
    PawnGetItemData = function() return nil end; PawnIsItemAnUpgrade = function() return nil end
    eq(ns.Classify(ring(), ctxNR()).mark, 'useful')
    pawn(nil, { p = true })
    local r = ns.Classify(ring(), ctxNR())
    GearQuest = nil; noPawn()
    eq(r.reasons[1].kind, 'pawn_upgrade'); eq(r.reasons[1].best, true)
end)

test('sin dudas: raro, opción apagada, simulación o error de GearQuest no venden', function()
    GearQuest = gqStub({ GetEntriesByItemId = function() return {} end })
    local blue = ring(); blue.quality = 3
    eq(ns.Classify(blue, ctxNR()).mark, 'useful')
    local off = ctxNR(); off.rules.gearNoRanking = false
    eq(ns.Classify(ring(), off).mark, 'useful')
    GearQuest.IsPreviewEnabled = function() return true end
    eq(ns.Classify(ring(), ctxNR()).mark, 'useful')
    GearQuest = gqStub({ GetEntriesByItemId = function() error('x') end })
    eq(ns.Classify(ring(), ctxNR()).mark, 'useful')
    GearQuest = nil
end)

test('sin dudas: tooltip de la venta y de Pawn en castellano', function()
    local savedL = ns.L
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    local savedClassify = ns.Classify
    FAKE.items[17692] = { name = 'Anillo de cuerno', quality = 2, price = 881, classID = 4, subclassID = 0 }
    local good, err = pcall(function()
        ns.Classify = function() return { mark = 'coin', reasons = { { kind = 'gear_no_ranking', pawn = true } } } end
        local text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(17692))) do text[#text + 1] = l.text end
        text = table.concat(text, '\n')
        ok(text:find('Ningún ranking dice que te sirva: se vende', 1, true), 'línea de venta')
        ok(text:find('GearQuest no lo conoce y Pawn no lo marca como mejora', 1, true), 'línea de por qué')
        ns.Classify = function() return { mark = 'useful', reasons = { { kind = 'pawn_upgrade', scale = 'Protección', percent = 0.88 } } } end
        text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(17692))) do text[#text + 1] = l.text end
        ok(table.concat(text, '\n'):find('Pawn: mejora 88% para Protección', 1, true), 'línea de Pawn')
    end)
    ns.Classify, ns.L, FAKE.locale = savedClassify, savedL, nil
    if not good then error(err, 0) end
end)

test('sin dudas: Pawn sin datos de lo que tenés puesto no autoriza la venta y marca duda', function()
    GearQuest = gqStub({ GetEntriesByItemId = function() return {} end })
    pawn(nil, nil)
    PawnGetItemDataForInventorySlot = function() return nil, true end -- ranura ocupada, datos sin cargar
    local r = ns.Classify(ring(), ctxNR())
    PawnGetItemDataForInventorySlot = nil
    GearQuest = nil; noPawn()
    eq(r.mark, 'useful'); eq(r.doubt, true); eq(ns.Marks.MarkOf(r), 'unruled')
end)

test('sin dudas: Pawn «mejora» frena también el equipo de nivel bajo', function()
    pawn({ { LocalizedScaleName = 'Sagrado', PercentUpgrade = 0.2 } })
    local weapon = { id = 991300, link = 'item:991300', quality = 2, price = 100, classID = 2, subclassID = 7,
        equipLoc = 'INVTYPE_WEAPON', reqLevel = 5, isBound = true, effect = 'no' }
    local c = ctx27(); c.level = 20
    local r = ns.Classify(weapon, c)
    noPawn()
    ok(r.mark ~= 'coin', 'no se vende por nivel bajo')
    eq(r.reasons[1].kind, 'pawn_upgrade')
end)

local function rankedStub(arrow)
    local stub = gqStub()
    stub.Data.GearScoreTooltipLine = function() return 'Puesto n.º 22 para tu nivel' end
    stub.Data.GearScoreContext = function() return {} end
    stub.Data.GearScoreArrowDelta = function() return arrow end
    stub.Log = { RankListContext = function() return 'Waist' end }
    return stub
end

local function belt16659()
    return { id = 16659, link = 'item:16659', quality = 2, price = 835, classID = 4, subclassID = 2,
        equipLoc = 'INVTYPE_WAIST', reqLevel = 20, isBound = true, effect = 'yes', hasUseOrEquipSpell = true }
end

test('Cinturón de equilibrista: «Equipar:» no lo guarda; puesto peor que lo puesto (-9) se vende', function()
    GearQuest = rankedStub(-9)
    local r = ns.Classify(belt16659(), ctx27())
    GearQuest = nil
    eq(r.mark, 'coin'); eq(r.reasons[1].kind, 'gear_worse_than_equipped'); eq(r.reasons[1].delta, -9)
end)

test('GearQuest: puesto mejor que lo puesto se guarda con el delta; sin comparación, se guarda', function()
    GearQuest = rankedStub(5)
    local r = ns.Classify(belt16659(), ctx27())
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'gear_ranked'); eq(r.reasons[1].delta, 5)
    GearQuest = rankedStub(nil)
    r = ns.Classify(belt16659(), ctx27())
    GearQuest = nil
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'gear_ranked')
end)

test('GearQuest: tooltip de peor que lo puesto en castellano', function()
    local savedL, savedClassify = ns.L, ns.Classify
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    FAKE.items[16659] = { name = 'Cinturón de equilibrista', quality = 2, price = 835, classID = 4, subclassID = 2 }
    local good, err = pcall(function()
        ns.Classify = function() return { mark = 'coin', reasons = { { kind = 'gear_worse_than_equipped', delta = -9 } } } end
        local text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(16659))) do text[#text + 1] = l.text end
        ok(table.concat(text, '\n'):find('GearQuest: no supera lo que tenés puesto (-9): se vende', 1, true), 'línea')
    end)
    ns.Classify, ns.L, FAKE.locale = savedClassify, savedL, nil
    if not good then error(err, 0) end
end)

test('equipo: sin «También: tiene un efecto» en armas y armaduras', function()
    GearQuest = rankedStub(-9)
    local r = ns.Classify(belt16659(), ctx27())
    GearQuest = nil
    for _, o in ipairs(r.otherReasons or {}) do ok(o.kind ~= 'effect', 'sin motivo de efecto') end
end)
