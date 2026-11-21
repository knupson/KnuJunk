local ns = _G.ns

local function gear(weapon)
    return { id = weapon and 991310 or 17692, link = weapon and 'item:991310' or 'item:17692',
        quality = 2, price = 881, classID = weapon and 2 or 4, subclassID = weapon and 7 or 0,
        equipLoc = weapon and 'INVTYPE_WEAPON' or 'INVTYPE_FINGER', isBound = true,
        effect = 'no', itemLevel = 25 }
end

local function context()
    return { class = 'PALADIN', level = 28, professions = {}, overrides = {}, questItemsInLog = {},
        questInLog = function() return false end, isQuestDone = function() return false end,
        specLabel = 'Reprensión', specSource = 'talents',
        equippedLevel = { [11] = 30, [12] = 28, [16] = 30, [17] = 28 },
        rules = { sellUnruled = true, gearNotRanked = true, gearNoRanking = true, armorBelow = true } }
end

local function gq()
    GearQuest = {
        GetEffectiveSpec = function() return 'retribution' end,
        Spec = { GetOptions = function(_, class)
            eq(class, 'PALADIN')
            return { { id = 'retribution', label = 'Reprensión' } }
        end },
        Data = { GetEntriesByItemId = function() return {} end, GearScoreMissText = function() return 'Sin puesto' end },
        IsPreviewEnabled = function() return false end,
    }
end

local function pawn(info, best, second, noMatch)
    PawnGetAllScalesEx = function()
        return { { Name = 'prot', LocalizedName = 'Paladín: Protección', IsVisible = true },
            { Name = 'ret', LocalizedName = noMatch and 'Sagrado' or 'Paladín: REPRENSIÓN', IsVisible = true },
            { Name = 'hidden', LocalizedName = 'Reprensión', IsVisible = false } }
    end
    PawnGetItemData = function() return {} end
    PawnIsItemAnUpgrade = function() return info, nil, best, second end
    PawnGetItemDataForInventorySlot = function() return {}, true end
end

local function talents(modern, points)
    GetNumTalentTabs = function() return 3 end
    GetTalentTabInfo = function(tab)
        local name = ({ 'Sagrado', 'Protección', 'Reprensión' })[tab]
        local spent = points or (tab == 3 and 19 or 0)
        if modern then return tab, name, 'Descripción', 'icon', spent end
        return name, 'icon', spent, 'file'
    end
end

for _, weapon in ipairs({ false, true }) do
    for _, withGQ in ipairs({ false, true }) do
        for _, withPawn in ipairs({ false, true }) do
            test('cadena: ' .. (weapon and 'arma' or 'anillo') .. ' GQ=' .. tostring(withGQ) .. ' Pawn=' .. tostring(withPawn), function()
                FAKE.class = 'PALADIN'; talents(false)
                if withGQ then gq() end
                if withPawn then pawn({ { ScaleName = 'prot', LocalizedScaleName = 'Paladín: Protección', PercentUpgrade = 0.88 } }) end
                local c = context()
                local actual = ns.Player.GetContext()
                c.specLabel, c.specSource = actual.specLabel, actual.specSource
                eq(c.specLabel, 'Reprensión'); eq(c.specSource, withGQ and 'gearquest' or 'talents')
                local r = ns.Classify(gear(weapon), c)
                eq(r.mark, 'coin'); eq(r.doubt, nil)
                eq(r.reasons[1].kind, withPawn and 'gear_no_ranking' or 'gear_below_equipped')
            end)
        end
    end
end

for _, modern in ipairs({ false, true }) do
    test('cadena: talentos formato moderno=' .. tostring(modern), function()
        FAKE.class = 'PALADIN'; talents(modern)
        local c = ns.Player.GetContext()
        eq(c.specLabel, 'Reprensión'); eq(c.specSource, 'talents')
    end)
end

test('cadena: GearQuest sin especialización y errores permiten talentos', function()
    FAKE.class = 'PALADIN'; talents(false); gq()
    GearQuest.GetEffectiveSpec = function() return nil end
    eq(ns.Player.GetContext().specSource, 'talents')
    GearQuest.GetEffectiveSpec = function() error('sin datos') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specLabel, 'Reprensión')
    GearQuest.GetEffectiveSpec = function() return 'retribution' end
    GearQuest.Spec.GetOptions = function() error('sin datos') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specSource, 'talents')
end)

test('cadena: cero puntos o errores dejan especialización desconocida', function()
    talents(false, 0)
    eq(ns.Player.GetContext().specLabel, nil); eq(ns.Player.GetContext().specSource, nil)
    GetNumTalentTabs = function() error('sin API') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specLabel, nil)
    talents(true); GetTalentTabInfo = function() error('sin datos') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specLabel, nil)
end)

for _, event in ipairs({ 'PLAYER_TALENT_UPDATE', 'CHARACTER_POINTS_CHANGED' }) do
    test('cadena: ' .. event .. ' actualiza especialización y firma', function()
        talents(false); eq(ns.Player.GetContext().specLabel, 'Reprensión')
        local changes = 0
        ns.Player.OnChanged(function() changes = changes + 1 end)
        GetTalentTabInfo = function(tab) return 'Protección', 'icon', tab == 2 and 20 or 0 end
        FAKE.Fire(event); FAKE.Advance(0.25)
        eq(ns.Player.GetContext().specLabel, 'Protección'); eq(changes, 1)
    end)
end

test('cadena: cambio de origen de especialización cambia la firma', function()
    FAKE.class = 'PALADIN'; talents(false); ns.Player.GetContext()
    local changes = 0; ns.Player.OnChanged(function() changes = changes + 1 end)
    gq(); ns.Player.Invalidate(); eq(ns.Player.GetContext().specSource, 'gearquest'); eq(changes, 1)
end)

test('cadena: Pawn encuentra la escala actual después de una mejora ajena', function()
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 },
        { ScaleName = 'ret', LocalizedScaleName = 'Paladín: Reprensión', PercentUpgrade = 0.12 } })
    local r = ns.Classify(gear(), context())
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'pawn_upgrade')
    eq(r.reasons[1].percent, 0.12); eq(r.reasons[1].scale, 'Paladín: Reprensión')
end)

test('cadena: Pawn acepta nombre localizado sin nombre interno', function()
    pawn({ { LocalizedScaleName = 'Paladín: REPRENSIÓN', PercentUpgrade = 0.3 } })
    eq(ns.Classify(gear(), context()).reasons[1].kind, 'pawn_upgrade')
end)

for _, second in ipairs({ false, true }) do
    test('cadena: Pawn mejor objeto, segunda ranura=' .. tostring(second), function()
        pawn(nil, not second and { ret = true } or nil, second and { ret = true } or nil)
        local r = ns.Classify(gear(), context())
        eq(r.mark, 'useful'); eq(r.reasons[1].best, true)
    end)
end

test('cadena: Pawn mejor objeto ajeno y escala oculta no conservan', function()
    pawn({ { ScaleName = 'hidden' } }, { prot = true }, { hidden = true })
    eq(ns.Classify(gear(), context()).mark, 'coin')
end)

test('cadena: especialización desconocida acepta cualquier escala visible', function()
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 } })
    local c = context(); c.specLabel = nil
    eq(ns.Classify(gear(), c).reasons[1].kind, 'pawn_upgrade')
end)

test('cadena: sin escala coincidente pasa a niveles aunque Pawn tenga datos pendientes', function()
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 } }, nil, nil, true)
    PawnGetItemData = function() return nil end
    local r = ns.Classify(gear(), context())
    eq(r.mark, 'coin'); eq(r.reasons[1].kind, 'gear_below_equipped')
end)

test('cadena: fallo o ausencia de escalas visibles pasa a niveles', function()
    pawn(nil); PawnGetAllScalesEx = function() error('sin inicializar') end
    eq(ns.Classify(gear(), context()).reasons[1].kind, 'gear_below_equipped')
    PawnGetAllScalesEx = function() return {} end
    local c = context(); c.specLabel = nil
    eq(ns.Classify(gear(), c).reasons[1].kind, 'gear_below_equipped')
end)

test('cadena: Pawn sin escala aplicable conserva una mejora por nivel', function()
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 } }, nil, nil, true)
    local item = gear(); item.itemLevel = 40
    local r = ns.Classify(item, context())
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'gear_maybe_upgrade'); eq(r.doubt, nil)
end)

test('cadena: ranura vacía decide aunque falten datos de la otra', function()
    local c = context(); c.equippedLevel[11], c.equippedLevel[12] = nil, false
    local item = gear(); item.itemLevel = nil
    local r = ns.Classify(item, c)
    eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'gear_empty_slot'); eq(r.doubt, nil)
end)

test('cadena: Pawn pendiente en objeto, inventario o API conserva con duda', function()
    for _, mode in ipairs({ 'item', 'inventory', 'api' }) do
        pawn(nil)
        if mode == 'item' then PawnGetItemData = function() return nil end
        elseif mode == 'inventory' then PawnGetItemDataForInventorySlot = function() return nil, true end
        else PawnIsItemAnUpgrade = function() error('pendiente') end end
        local r = ns.Classify(gear(), context())
        eq(r.mark, 'useful'); eq(r.doubt, true); eq(ns.Marks.MarkOf(r), 'unruled')
    end
end)

for _, weapon in ipairs({ false, true }) do
    for _, mode in ipairs({ 'empty', 'lower', 'equal', 'higher', 'unknown_item', 'unknown_equipped', 'lower_second' }) do
        test('cadena: niveles ' .. mode .. ' arma=' .. tostring(weapon), function()
            local item, c = gear(weapon), context()
            -- Dos armas a la vez: sólo guerrero, pícaro o cazador (un paladín compara sólo la derecha).
            if weapon then c.class = 'WARRIOR' end
            local slots = ns.GearSlots[item.equipLoc]
            if mode == 'empty' then c.equippedLevel[slots[2]] = false; item.itemLevel = nil
            elseif mode == 'equal' then item.itemLevel = 28
            elseif mode == 'higher' then item.itemLevel = 29
            elseif mode == 'unknown_item' then item.itemLevel = nil
            elseif mode == 'unknown_equipped' then c.equippedLevel[slots[1]] = nil
            elseif mode == 'lower_second' then c.equippedLevel[slots[2]] = 20 end
            local r = ns.Classify(item, c)
            if mode:find('unknown', 1, true) then eq(r.doubt, true); eq(r.mark, 'useful')
            elseif mode == 'empty' then eq(r.reasons[1].kind, 'gear_empty_slot'); eq(r.mark, 'useful')
            elseif mode == 'higher' or mode == 'lower_second' then
                eq(r.reasons[1].kind, 'gear_maybe_upgrade'); eq(r.mark, 'useful')
                eq(r.reasons[1].equipped, mode == 'higher' and 28 or 20)
            else eq(r.mark, 'coin'); eq(r.reasons[1].kind, 'gear_below_equipped') end
        end)
    end
end

for _, withPawn in ipairs({ false, true }) do
    test('cadena: límites de venta Pawn=' .. tostring(withPawn), function()
        if withPawn then pawn(nil) end
        local item, c = gear(), context(); item.quality = 3
        local r = ns.Classify(item, c)
        eq(r.mark, 'useful'); eq(r.reasons[1].kind, withPawn and 'gear_no_ranking' or 'gear_below_equipped')
        item.quality = 2; c.rules.gearNoRanking = false
        eq(ns.Classify(item, c).mark, 'useful')
        c.rules.gearNoRanking = true
        for _, price in ipairs({ 0, false }) do
            item.price = price or nil; eq(ns.Classify(item, c).mark, 'useful')
        end
    end)
end

test('cadena: excluidos, reglas apagadas, conjuntos y simulación no entran', function()
    local item, c = gear(), context()
    for _, loc in ipairs({ 'INVTYPE_TRINKET', 'INVTYPE_TABARD', 'INVTYPE_BODY', 'INVTYPE_BAG' }) do
        item.equipLoc = loc; eq(ns.Classify(item, c).reasons[1].kind, 'no_rule')
    end
    item = gear(); c.rules.gearNotRanked = false
    eq(ns.Classify(item, c).reasons[1].kind, 'no_rule')
    c.rules.gearNotRanked = true
    C_EquipmentSet = { GetEquipmentSetIDs = function() return { 1 } end,
        GetItemIDs = function() return { [11] = 17692 } end }
    eq(ns.Classify(item, c).reasons[1].kind, 'no_rule'); C_EquipmentSet = nil
    gq(); GearQuest.IsPreviewEnabled = function() return true end
    eq(ns.Classify(item, c).reasons[1].kind, 'no_rule')
end)

test('cadena: mejora ajena no veta gear_outgrown pero la actual sí', function()
    local item, c = gear(true), context(); item.reqLevel = 5
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 } })
    eq(ns.Classify(item, c).reasons[1].kind, 'gear_outgrown')
    pawn({ { ScaleName = 'ret', PercentUpgrade = 0.1 } })
    eq(ns.Classify(item, c).reasons[1].kind, 'pawn_upgrade')
end)

test('cadena: mejora ajena no veta armadura inferior', function()
    local item, c = gear(), context()
    item.equipLoc, item.subclassID = 'INVTYPE_CHEST', 1
    c.equippedArmor = { [5] = 3 }; c.equippedLevel[5] = 28
    pawn({ { ScaleName = 'prot', PercentUpgrade = 0.88 } })
    eq(ns.Classify(item, c).reasons[1].kind, 'armor_below_equipped')
    pawn({ { ScaleName = 'ret', PercentUpgrade = 0.1 } })
    eq(ns.Classify(item, c).reasons[1].kind, 'pawn_upgrade')
end)

test('cadena: lectura de nivel y caché de equipo, eventos y firma', function()
    FAKE.items[17692] = { name = 'Anillo', quality = 2, classID = 4, equipLoc = 'INVTYPE_FINGER', itemLevel = 25 }
    eq(ns.Player.ReadLink('item:17692').itemLevel, 25)
    FAKE.equipped[11], FAKE.equipped[12] = 17692, 991311
    local c = ns.Player.GetContext()
    eq(c.equippedLevel[11], 25); eq(c.equippedLevel[12], nil); eq(c.equippedLevel[16], false)
    eq(c.equippedLevel[4], nil); eq(c.equippedLevel[19], nil)
    local changes = 0; ns.Player.OnChanged(function() changes = changes + 1 end)
    FAKE.items[991311] = { name = 'Equipado', quality = 2, itemLevel = 30 }
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 991311, true); FAKE.Advance(0.25)
    eq(ns.Player.GetContext().equippedLevel[12], 30); eq(changes, 1)
    ns.DB.rules = {}
    FAKE.equipped[12] = nil
    FAKE.Fire('PLAYER_EQUIPMENT_CHANGED', 12); FAKE.Advance(0.25)
    eq(ns.Player.GetContext().equippedLevel[12], false); eq(changes, 2)
    FAKE.equipped[12] = 991311
    FAKE.Fire('UNIT_INVENTORY_CHANGED', 'player'); FAKE.Advance(0.25)
    eq(ns.Player.GetContext().equippedLevel[12], 30); eq(changes, 3)
end)

test('cadena: errores al leer equipo conservan niveles desconocidos', function()
    GetInventoryItemLink = function() error('sin API') end
    eq(ns.Player.GetContext().equippedLevel[11], nil)
    GetInventoryItemLink = function() return 'item:17692' end
    GetItemInfo = function() error('sin datos') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().equippedLevel[11], nil)
end)

test('cadena: tooltip nuevo en castellano y en inglés, sin venta falsa', function()
    local savedL, savedClassify = ns.L, ns.Classify
    local good, err = pcall(function()
        FAKE.items[17692] = { name = 'Anillo', quality = 2, price = 10, classID = 4 }
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            for _, case in ipairs({
                { 'gear_empty_slot', 'Tenés ese lugar vacío: equipalo', 'That slot is empty: equip it' },
                { 'gear_below_equipped', 'Nivel de objeto 25: lo que tenés puesto es 28', 'Item level 25: what you wear is 28' },
                { 'gear_maybe_upgrade', 'Puede ser mejora: nivel de objeto 25 contra 28 puesto', 'Possible upgrade: item level 25 versus 28 equipped' },
                { 'gear_no_ranking', 'Pawn no lo marca como mejora para tu especialización: se guarda', 'Pawn does not mark it as an upgrade for your spec: keep it' },
            }) do
                ns.Classify = function() return { mark = 'useful', reasons = { { kind = case[1], level = 25, equipped = 28, pawn = true } } } end
                local lines = {}; for _, line in ipairs(ns.Tooltip.Lines('item:17692')) do lines[#lines + 1] = line.text end
                ok(table.concat(lines, '\n'):find(case[locale == 'esES' and 2 or 3], 1, true), case[1])
            end
        end
    end)
    ns.L, ns.Classify, FAKE.locale = savedL, savedClassify, nil
    if not good then error(err, 0) end
end)

test('cadena: debug imprime especialización, origen, escalas y niveles', function()
    local savedL = ns.L
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    local good, err = pcall(function()
        FAKE.class = 'PALADIN'; gq(); pawn(nil)
        FAKE.items[17692] = { name = 'Anillo de cuerno', quality = 2, price = 881,
            classID = 4, equipLoc = 'INVTYPE_FINGER', itemLevel = 25 }
        ns.Commands.Handle('debug |Hitem:17692::::|h[Anillo de cuerno]|h')
        local text = table.concat(FAKE.messages, '\n')
        for _, part in ipairs({ 'Especialización: Reprensión | origen: GearQuest', 'Escalas visibles de Pawn: 2',
            'Paladín: Protección | coincide: no', 'Paladín: REPRENSIÓN | coincide: sí',
            'Nivel de objeto: 25', 'Nivel equipado en ranura 11: vacío', 'Nivel equipado en ranura 12: vacío' }) do
            ok(text:find(part, 1, true), part)
        end
        GearQuest = nil; talents(false); ns.Player.Invalidate()
        text = table.concat(ns.Player.DebugTooltip('item:17692'), '\n')
        ok(text:find('origen: talentos', 1, true))
        talents(false, 0); ns.Player.Invalidate()
        text = table.concat(ns.Player.DebugTooltip('item:17692'), '\n')
        ok(text:find('origen: ninguna', 1, true) or text:find('origen: ninguno', 1, true))
    end)
    ns.L, FAKE.locale = savedL, nil
    if not good then error(err, 0) end
end)

test('cadena: arma de dos manos y arma de una mano de paladín se comparan sólo con la mano derecha', function()
    local ctx = { class = 'PALADIN', level = 28, professions = {}, overrides = {}, questItemsInLog = {},
        questInLog = function() return false end, isQuestDone = function() return false end,
        rules = { gearNoRanking = true }, equippedLevel = { [16] = 30, [17] = false } }
    for _, loc in ipairs({ 'INVTYPE_2HWEAPON', 'INVTYPE_WEAPON' }) do
        local weapon = { id = 991400, link = 'item:991400', quality = 2, price = 100, classID = 2,
            subclassID = loc == 'INVTYPE_2HWEAPON' and 1 or 0, equipLoc = loc, itemLevel = 25, isBound = true, effect = 'no' }
        local r = ns.Classify(weapon, ctx)
        eq(r.reasons[1].kind, 'gear_below_equipped', loc)
        eq(r.mark, 'coin', loc)
    end
end)
