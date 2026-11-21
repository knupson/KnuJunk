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
