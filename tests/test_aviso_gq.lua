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
