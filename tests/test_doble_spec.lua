local ns = _G.ns
local ID = 991420

local function talents(groups, active, signature, modern, other, points)
    FAKE.class = 'PALADIN'
    if groups ~= nil then GetNumTalentGroups = function() return groups end end
    GetActiveTalentGroup = function() return active or 1 end
    GetNumTalentTabs = function() return 3 end
    GetTalentTabInfo = function(tab, second, third, fourth)
        local group
        if second == nil then group = active or 1
        elseif signature == 'forever' then
            if type(second) ~= 'number' then error('firma de Forever') end
            group = second
        elseif signature == 'zero' and fourth ~= nil then
            return 'Sagrado', 'icon', 0
        elseif signature == 'zero' then group = second
        else
            eq(second, false); eq(third, false)
            group = fourth
        end
        local chosen = group == (active or 1) and 3 or (other or 1)
        local spent = tab == chosen and (group == (active or 1) and 19 or (points or 19)) or 0
        local label = ({ 'Sagrado', 'Protección', 'Reprensión' })[tab]
        if modern then return tab, label, 'Descripción', 'icon', spent end
        return label, 'icon', spent
    end
end

local function gear()
    return { id = ID, link = 'item:' .. ID, quality = 2, price = 500, classID = 4, subclassID = 2,
        equipLoc = 'INVTYPE_HAND', reqLevel = 22, itemLevel = 25, effect = 'no', isBound = true }
end

local function context()
    local c = ns.Player.GetContext()
    c.level = 28
    c.questLogIncomplete = nil
    c.equippedArmor = { [10] = 3 }
    c.equippedLevel = { [10] = 30 }
    c.rules = { sellUnruled = true, gearNotRanked = true, gearNoRanking = true, armorBelow = true }
    return c
end

local function gearquest(mode)
    local probing = false
    GearQuest = {
        GetEffectiveSpec = function() return 'ret' end,
        GetEffectiveLevel = function() return 28 end,
        GetEffectiveClass = function() return 'PALADIN' end,
        IsPreviewEnabled = function() return false end,
        Spec = { GetOptions = function(_, class)
            eq(class, 'PALADIN')
            return { { id = 'ret', label = 'Reprensión' }, { id = 'holy', label = 'SAGRADO' } }
        end },
        Log = { WithSpecProbe = function(_, spec, fn)
            eq(spec, 'holy')
            if mode == 'probe_error' then error('falló la consulta') end
            probing = true
            local good, answer = pcall(fn)
            probing = false
            if not good then error(answer) end
            return answer
        end },
        Data = {
            GetEntriesByItemId = function() return { { id = ID } } end,
            EntryForItemLink = function(_, link)
                eq(link, 'item:' .. ID)
                if probing and mode == 'entry_error' then error('sin fila') end
                return { id = ID }
            end,
            GearScoreTooltipLine = function()
                if probing and mode == 'line_error' then error('sin línea') end
                if probing and mode ~= 'no_rank' then return 'Puesto 13' end
            end,
            GearScoreMissText = function() return 'Sin puesto para Reprensión' end,
        },
    }
end

local function pawn(mode)
    PawnGetAllScalesEx = function()
        return { { Name = 'ret', LocalizedName = 'Paladín: Reprensión', IsVisible = true },
            { Name = 'holy', LocalizedName = 'Paladín: SAGRADO', IsVisible = mode ~= 'hidden' } }
    end
    PawnGetItemData = function() return {} end
    PawnGetItemDataForInventorySlot = function() return {}, true end
    PawnIsItemAnUpgrade = function()
        if mode == 'best' then return nil, nil, { holy = true }
        elseif mode == 'second' then return nil, nil, nil, { holy = true }
        elseif mode == 'no_upgrade' then return nil end
        return { { ScaleName = 'holy', LocalizedScaleName = 'Paladín: Sagrado', PercentUpgrade = 6.74 } }
    end
end

for _, signature in ipairs({ 'wrath', 'forever', 'zero' }) do
    for _, modern in ipairs({ false, true }) do
        for _, active in ipairs({ 1, 2 }) do
            test('doble spec: talentos ' .. signature .. ' moderno=' .. tostring(modern) .. ' activo=' .. active, function()
                talents(2, active, signature, modern); gearquest()
                local c = context()
                eq(c.specLabel, 'Reprensión'); eq(c.offSpecLabel, 'Sagrado'); eq(c.offSpecId, 'holy')
                eq(c.talentGroups, 2); eq(c.activeTalentGroup, active)
                local r = ns.Classify(gear(), c)
                eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'offspec_ranked'); eq(r.reasons[1].spec, 'Sagrado')
            end)
        end
    end
end

for _, groups in ipairs({ false, 1 }) do
    test('doble spec: Manijas de aceite sin doble spec, grupos=' .. tostring(groups), function()
        talents(groups or nil); gearquest(); pawn()
        local c = context()
        eq(c.offSpecLabel, nil); eq(c.offSpecId, nil)
        eq(ns.Classify(gear(), c).mark, 'coin')
        c.equippedArmor = {}
        eq(ns.Classify(gear(), c).mark, 'coin')
        GearQuest = nil
        eq(ns.Classify(gear(), c).mark, 'coin')
    end)
end

test('doble spec: recupera una pestaña sin puntos con la firma de Forever', function()
    talents(2)
    GetTalentTabInfo = function(tab, second, _, group)
        local label = ({ 'Sagrado', 'Protección', 'Reprensión' })[tab]
        if second == nil then return label, 'icon', tab == 3 and 19 or 0 end
        if group then return label, 'icon', tab == 2 and 5 or 0 end
        eq(second, 2)
        return tab, label, 'Descripción', 'icon', tab == 1 and 19 or 0
    end
    eq(context().offSpecLabel, 'Sagrado')
end)

for _, mode in ipairs({ 'same', 'zero_points', 'count_error', 'count_nil', 'talents_error', 'tabs_error' }) do
    test('doble spec: ignora ' .. mode, function()
        talents(2, 1, 'wrath', false, mode == 'same' and 3 or 1, mode == 'zero_points' and 0 or 19)
        if mode == 'count_error' then GetNumTalentGroups = function() error('sin API') end end
        if mode == 'count_nil' then GetNumTalentGroups = function() end end
        if mode == 'talents_error' then GetTalentTabInfo = function() error('sin datos') end end
        if mode == 'tabs_error' then GetNumTalentTabs = function() error('sin datos') end end
        gearquest(); pawn()
        local c = context()
        eq(c.offSpecLabel, nil); eq(c.offSpecId, nil); eq(ns.Classify(gear(), c).mark, 'coin')
    end)
end

for _, mode in ipairs({ 'missing', 'error' }) do
    test('doble spec: grupo activo por defecto, API ' .. mode, function()
        talents(2)
        if mode == 'missing' then GetActiveTalentGroup = nil
        else GetActiveTalentGroup = function() error('sin API') end end
        eq(context().activeTalentGroup, 1); eq(context().offSpecLabel, 'Sagrado')
    end)
end

for _, mode in ipairs({ 'upgrade', 'best', 'second' }) do
    test('doble spec: Pawn conserva cuero con malla, ' .. mode, function()
        talents(2); pawn(mode)
        local c = context()
        local r = ns.Classify(gear(), c)
        eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'pawn_upgrade'); eq(r.reasons[1].offspec, true)
        if mode == 'upgrade' then eq(r.reasons[1].percent, 6.74) else eq(r.reasons[1].best, true) end
        -- También veta equipo superado por nivel y funciona con «sin puesto» de GearQuest.
        local item = gear(); item.reqLevel = 10
        eq(ns.Classify(item, c).mark, 'useful')
        gearquest('no_rank')
        eq(ns.Classify(item, c).reasons[1].kind, 'pawn_upgrade')
    end)
end

for _, mode in ipairs({ 'hidden', 'no_upgrade' }) do
    test('doble spec: Pawn no conserva ' .. mode, function()
        talents(2); pawn(mode)
        eq(ns.Classify(gear(), context()).mark, 'coin')
    end)
end

test('doble spec: Pawn exige nombre localizado para la otra especialización', function()
    talents(2); pawn()
    PawnGetAllScalesEx = function() return { { Name = 'Sagrado', IsVisible = true } } end
    PawnIsItemAnUpgrade = function() return { { ScaleName = 'Sagrado', PercentUpgrade = 6.74 } } end
    eq(ns.Classify(gear(), context()).mark, 'coin')
end)

for _, mode in ipairs({ 'probe_error', 'entry_error', 'line_error', 'no_rank', 'no_probe', 'no_id' }) do
    test('doble spec: GearQuest sin decisión, ' .. mode, function()
        talents(2); gearquest(mode)
        if mode == 'no_probe' then GearQuest.Log.WithSpecProbe = nil end
        if mode == 'no_id' then GearQuest.Spec.GetOptions = function() return {} end end
        local c = context()
        local r = ns.Classify(gear(), c)
        eq(r.mark, 'coin'); eq(r.reasons[1].kind, 'armor_below_equipped')
        c.equippedArmor = {}
        r = ns.Classify(gear(), c)
        eq(r.mark, 'coin'); eq(r.reasons[#r.reasons].kind, 'gear_not_ranked')
    end)
end

test('doble spec: GearQuest veta equipo superado por nivel', function()
    talents(2); gearquest()
    local item = gear(); item.reqLevel = 10
    eq(ns.Classify(item, context()).reasons[1].kind, 'offspec_ranked')
end)

test('doble spec: mantiene precedencia de marcas manuales, misión y grises', function()
    talents(2); gearquest(); pawn()
    local c = context()
    c.overrides[ID] = 'sell'; eq(ns.Classify(gear(), c).mark, 'coin')
    c.overrides[ID] = 'keep'; eq(ns.Classify(gear(), c).mark, 'protected')
    c.overrides[ID] = nil; c.questItemsInLog[ID] = true
    eq(ns.Classify(gear(), c).mark, 'quest')
    c.questItemsInLog[ID] = nil
    local item = gear(); item.quality = 0; eq(ns.Classify(item, c).mark, 'coin')
end)

for _, event in ipairs({ 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'CHARACTER_POINTS_CHANGED' }) do
    test('doble spec: evento actualiza otra especialización y firma, ' .. event, function()
        talents(2); gearquest(); eq(context().offSpecLabel, 'Sagrado')
        local changes = 0; ns.Player.OnChanged(function() changes = changes + 1 end)
        talents(2, 1, 'wrath', false, 2)
        FAKE.Fire(event); FAKE.Advance(0.25)
        eq(ns.Player.GetContext().offSpecLabel, 'Protección'); eq(changes, 1)
    end)
end

test('doble spec: cambiar sólo el ID de GearQuest cambia la firma', function()
    talents(2); gearquest(); eq(context().offSpecId, 'holy')
    local changes = 0; ns.Player.OnChanged(function() changes = changes + 1 end)
    GearQuest.Spec.GetOptions = function() return { { id = 'holy2', label = 'Sagrado' } } end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().offSpecId, 'holy2'); eq(changes, 1)
end)

test('doble spec: cambiar de grupo activo reconstruye ambas especializaciones', function()
    talents(2)
    local active = 1
    GetActiveTalentGroup = function() return active end
    GetTalentTabInfo = function(tab, second, _, group)
        if type(second) == 'number' then error('firma de Wrath') end
        group = group or active
        return ({ 'Sagrado', 'Protección', 'Reprensión' })[tab], 'icon',
            ((group == 1 and tab == 3) or (group == 2 and tab == 1)) and 19 or 0
    end
    local c = context(); eq(c.specLabel, 'Reprensión'); eq(c.offSpecLabel, 'Sagrado')
    local changes = 0; ns.Player.OnChanged(function() changes = changes + 1 end)
    active = 2; FAKE.Fire('ACTIVE_TALENT_GROUP_CHANGED'); FAKE.Advance(0.25)
    c = ns.Player.GetContext()
    eq(c.specLabel, 'Sagrado'); eq(c.offSpecLabel, 'Reprensión'); eq(c.activeTalentGroup, 2); eq(changes, 1)
end)

test('doble spec: desactivar doble spec retira la protección', function()
    talents(2); gearquest(); pawn(); eq(ns.Classify(gear(), context()).mark, 'useful')
    GetNumTalentGroups = function() return 1 end
    FAKE.Fire('PLAYER_TALENT_UPDATE'); FAKE.Advance(0.25)
    local c = context(); eq(c.offSpecLabel, nil); eq(c.offSpecId, nil)
    eq(ns.Classify(gear(), c).mark, 'coin')
end)

test('doble spec: error de opciones de GearQuest permite conservar por Pawn', function()
    talents(2); gearquest(); pawn()
    GearQuest.Spec.GetOptions = function() error('sin opciones') end
    local c = context(); eq(c.offSpecLabel, 'Sagrado'); eq(c.offSpecId, nil)
    eq(ns.Classify(gear(), c).reasons[1].kind, 'pawn_upgrade')
end)

test('doble spec: no acepta la simulación de GearQuest como puesto real', function()
    talents(2); gearquest()
    GearQuest.IsPreviewEnabled = function() return true end
    local c = context()
    eq(ns.GearQuestOffSpecRanked(gear(), c), nil)
    local r = ns.Classify(gear(), c); eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'no_rule')
end)

test('doble spec: Pawn distingue mejoras de ambas especializaciones', function()
    talents(2); pawn()
    PawnIsItemAnUpgrade = function()
        return { { ScaleName = 'ret', PercentUpgrade = 0.1 }, { ScaleName = 'holy', PercentUpgrade = 6.74 } }
    end
    local c = context()
    local r = ns.Classify(gear(), c)
    eq(r.reasons[1].kind, 'pawn_upgrade'); eq(r.reasons[1].offspec, true); eq(r.reasons[1].percent, 6.74)
    local _, matches, count = ns.PawnScales(c)
    eq(matches.ret, true); eq(matches.holy, true); eq(count, 2)
end)

test('doble spec: especialización principal desconocida identifica la mejora de la otra', function()
    talents(2); pawn()
    local c = context(); c.specLabel = nil
    local r = ns.Classify(gear(), c)
    eq(r.reasons[1].kind, 'pawn_upgrade'); eq(r.reasons[1].offspec, true)
end)

test('doble spec: debug distingue sin puesto, sin mejora y error sin veredicto', function()
    talents(2); gearquest('no_rank'); pawn('no_upgrade'); context()
    FAKE.items[ID] = { name = 'Manijas de aceite', quality = 2, price = 500, classID = 4, equipLoc = 'INVTYPE_HAND' }
    eq(ns.GearQuestOffSpecRanked(gear(), context()), false)
    eq(ns.PawnOffSpecUpgrade(gear(), context()), false)
    local text = table.concat(ns.Player.DebugTooltip('item:' .. ID), '\n')
    ok(text:find(ns.L['Other spec GearQuest rank: %s']:format(ns.L['no']), 1, true))
    ok(text:find(ns.L['Other spec Pawn upgrade: %s']:format(ns.L['no']), 1, true))
    -- WithSpecProbe real captura errores internos y devuelve nil.
    GearQuest.Log.WithSpecProbe = function() return nil end
    eq(ns.GearQuestOffSpecRanked(gear(), context()), nil)
    text = table.concat(ns.Player.DebugTooltip('item:' .. ID), '\n')
    ok(text:find(ns.L['Other spec GearQuest rank: %s']:format(ns.L['no verdict']), 1, true))
end)

for _, locale in ipairs({ 'esES', 'enUS' }) do
    test('doble spec: tooltip y debug ' .. locale, function()
        local savedL = ns.L
        local good, err = pcall(function()
            FAKE.locale = locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            talents(2); gearquest(); pawn()
            FAKE.items[ID] = { name = 'Manijas de aceite', quality = 2, price = 500, classID = 4,
                subclassID = 2, equipLoc = 'INVTYPE_HAND', reqLevel = 22, itemLevel = 25 }
            local c = context()
            ns.Commands.Handle('debug item:' .. ID)
            local debug = table.concat(FAKE.messages, '\n')
            local spanish = locale == 'esES'
            for _, part in ipairs(spanish and {
                'Grupos de talentos: 2 | activo: 1', 'Otra especialización: Sagrado | ID de GearQuest: holy',
                'Puesto de GearQuest para tu otra especialización: sí', 'Mejora de Pawn para tu otra especialización: sí',
            } or {
                'Talent groups: 2 | active: 1', 'Other spec: Sagrado | GearQuest id: holy',
                'Other spec GearQuest rank: yes', 'Other spec Pawn upgrade: yes',
            }) do ok(debug:find(part, 1, true), part) end
            local function tooltip()
                local lines = {}
                for _, line in ipairs(ns.Tooltip.Lines('item:' .. ID)) do lines[#lines + 1] = line.text end
                return table.concat(lines, '\n')
            end
            ok(tooltip():find(spanish and 'Sirve para tu otra especialización (Sagrado): se guarda'
                or 'Useful for your other spec (Sagrado): keep it', 1, true))
            GearQuest = nil
            ok(tooltip():find(spanish and 'Pawn: mejora 674% para Paladín: Sagrado (tu otra especialización)'
                or 'Pawn: 674% upgrade for Paladín: Sagrado (your other spec)', 1, true))
            pawn('best')
            ok(tooltip():find(spanish and 'para holy (tu otra especialización)'
                or 'for holy (your other spec)', 1, true))
        end)
        ns.L, FAKE.locale = savedL, nil
        if not good then error(err, 0) end
    end)
end
