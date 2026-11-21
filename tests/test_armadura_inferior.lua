local ID = 2969 -- Jubón Vinculahechizo (tela verde, pecho, reqLevel 12)

local function item(fields)
    local value = {
        id = ID,
        link = 'item:' .. ID,
        quality = 2,
        price = 180,
        classID = 4,
        subclassID = 1,
        equipLoc = 'INVTYPE_CHEST',
        reqLevel = 12,
        isBound = true,
    }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end

local function context(fields)
    local value = {
        class = 'PALADIN',
        level = 18,
        professions = {},
        equippedArmor = { [5] = 3 }, -- malla en el pecho
        overrides = {},
        questItemsInLog = {},
        questInLog = function() return false end,
        isQuestDone = function() return false end,
        rules = { sellUnruled = true, armorBelow = true, food = false, ammo = false, knownRecipe = false, gearNotRanked = true },
    }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end

local function findReason(list, kind)
    for _, r in ipairs(list or {}) do
        if r.kind == kind then return r end
    end
end

test('armadura inferior: paladín con malla puesta vende tela y cuero, conserva malla y vende malla con placas', function()
    -- Caso real del dueño: ítem 2969 (tela verde req 12) para paladín nivel 18 con malla en pecho -> moneda.
    local cloth = ns.Classify(item({ subclassID = 1 }), context())
    eq(cloth.mark, 'coin')
    eq(cloth.reasons[1].kind, 'armor_below_equipped')
    eq(cloth.reasons[1].subclassID, 1)
    eq(cloth.reasons[1].equipped, 3)

    -- Cuero en bolsa con malla puesta -> moneda.
    local leather = ns.Classify(item({ subclassID = 2 }), context())
    eq(leather.mark, 'coin')
    eq(leather.reasons[1].kind, 'armor_below_equipped')
    eq(leather.reasons[1].subclassID, 2)
    eq(leather.reasons[1].equipped, 3)

    -- Malla en bolsa con malla puesta -> no aplica esta regla.
    local mail = ns.Classify(item({ subclassID = 3 }), context())
    eq(mail.mark, 'useful')
    eq(mail.reasons[1].kind, 'no_rule')
    eq(mail.reasons[1].exception, 'gear')

    -- Placas en bolsa con malla puesta (tipo superior) -> no aplica esta regla.
    local plateInBag = ns.Classify(item({ subclassID = 4 }), context())
    eq(plateInBag.mark, 'useful')
    eq(plateInBag.reasons[1].kind, 'no_rule')

    -- Placas puestas + malla en bolsa -> moneda.
    local mailBelowPlate = ns.Classify(item({ subclassID = 3 }), context({ equippedArmor = { [5] = 4 } }))
    eq(mailBelowPlate.mark, 'coin')
    eq(mailBelowPlate.reasons[1].kind, 'armor_below_equipped')
    eq(mailBelowPlate.reasons[1].subclassID, 3)
    eq(mailBelowPlate.reasons[1].equipped, 4)

    -- Sin ligar con precio de subasta alto pasa a auction.
    Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function() return 5000 end } } }
    local unbound = ns.Classify(item({ isBound = false }), context())
    eq(unbound.mark, 'auction')
    eq(unbound.reasons[1].kind, 'armor_below_equipped')
    Auctionator = nil
end)

test('armadura inferior: ranura vacía, info pendiente o equipada no armadura no deciden', function()
    FAKE.class = 'PALADIN'
    local prevLevel = UnitLevel
    UnitLevel = function() return 18 end
    local success, err = pcall(function()
        -- Ranura vacía. Sin la regla de equipo sin ranking, para ver sólo la de armadura.
        ns.DB.rules.gearNoRanking = false
        FAKE.equipped = {}
        ns.Player.Invalidate()
        local emptyCtx = ns.Player.GetContext()
        eq(emptyCtx.equippedArmor[5], false)
        local rEmpty = ns.Classify(item(), emptyCtx)
        eq(rEmpty.mark, 'useful')
        eq(rEmpty.reasons[1].kind, 'no_rule')

        -- Ítem equipado con info pendiente (no está en FAKE.items).
        FAKE.equipped = { [5] = 888001 }
        ns.Player.Invalidate()
        local pendingCtx = ns.Player.GetContext()
        eq(pendingCtx.equippedArmor[5], false)
        eq(ns.Classify(item(), pendingCtx).mark, 'useful')

        -- Ítem equipado es escudo (subclase 6) o misceláneo (subclase 0).
        FAKE.items[888002] = { name = 'Escudo', quality = 2, price = 100, classID = 4, subclassID = 6, equipLoc = 'INVTYPE_SHIELD' }
        FAKE.equipped = { [5] = 888002 }
        ns.Player.Invalidate()
        eq(ns.Player.GetContext().equippedArmor[5], false)
        eq(ns.Classify(item(), ns.Player.GetContext()).mark, 'useful')

        FAKE.items[888003] = { name = 'Camisa', quality = 1, price = 10, classID = 4, subclassID = 0, equipLoc = 'INVTYPE_CHEST' }
        FAKE.equipped = { [5] = 888003 }
        ns.Player.Invalidate()
        eq(ns.Player.GetContext().equippedArmor[5], false)
        eq(ns.Classify(item(), ns.Player.GetContext()).mark, 'useful')
    end)
    UnitLevel = prevLevel
    ns.Player.Invalidate()
    if not success then error(err, 0) end
end)

test('armadura inferior: capa nunca aplica; toga (INVTYPE_ROBE) usa la misma ranura 5 que pecho', function()
    -- Capa (INVTYPE_CLOAK es subclase 1 tela) con malla en pecho y capa puesta -> nunca aplica.
    local cloak = ns.Classify(item({ equipLoc = 'INVTYPE_CLOAK', subclassID = 1 }), context({ equippedArmor = { [5] = 3, [15] = 3 } }))
    eq(cloak.mark, 'useful')
    eq(cloak.reasons[1].kind, 'no_rule')
    eq(cloak.reasons[1].exception, 'gear')

    -- Otras ranuras excluidas (anillo, cuello, abalorio, camisa, tabardo, escudo, reliquia).
    for _, loc in ipairs({ 'INVTYPE_FINGER', 'INVTYPE_NECK', 'INVTYPE_TRINKET', 'INVTYPE_BODY', 'INVTYPE_TABARD', 'INVTYPE_HOLDABLE', 'INVTYPE_SHIELD', 'INVTYPE_RELIC' }) do
        local r = ns.Classify(item({ equipLoc = loc, subclassID = 1 }), context())
        eq(r.mark, 'useful', loc)
    end

    -- INVTYPE_ROBE en bolsas contra INVTYPE_CHEST (ranura 5) equipada -> aplica.
    local robe = ns.Classify(item({ equipLoc = 'INVTYPE_ROBE', subclassID = 1 }), context({ equippedArmor = { [5] = 3 } }))
    eq(robe.mark, 'coin')
    eq(robe.reasons[1].kind, 'armor_below_equipped')

    -- Todas las 8 ranuras de armadura válidas (1, 3, 5, 6, 7, 8, 9, 10).
    local slots = {
        INVTYPE_HEAD = 1, INVTYPE_SHOULDER = 3, INVTYPE_CHEST = 5, INVTYPE_ROBE = 5,
        INVTYPE_WAIST = 6, INVTYPE_LEGS = 7, INVTYPE_FEET = 8, INVTYPE_WRIST = 9, INVTYPE_HAND = 10,
    }
    for loc, slot in pairs(slots) do
        local r = ns.Classify(item({ equipLoc = loc, subclassID = 2 }), context({ equippedArmor = { [slot] = 4 } }))
        eq(r.mark, 'coin', loc)
        eq(r.reasons[1].kind, 'armor_below_equipped', loc)
    end
end)

test('armadura inferior: calidad >= 3 nunca se vende; gris conserva la regla de grises', function()
    for _, q in ipairs({ 3, 4, 5 }) do
        local r = ns.Classify(item({ quality = q }), context())
        eq(r.mark, 'useful')
        eq(r.reasons[1].kind, 'no_rule')
        eq(r.reasons[1].exception, 'gear')
    end
    local gray = ns.Classify(item({ quality = 0, price = 40 }), context())
    eq(gray.mark, 'coin')
    eq(gray.reasons[1].kind, 'gray')
end)

test('armadura inferior y equipo superado: Encantamiento (333) protege verdes pero vende blancos', function()
    local enchCtx = context({ professions = { [333] = true } })
    -- Encantamiento + verde + armadura inferior -> no decide (queda útil).
    local greenBelow = ns.Classify(item({ quality = 2, subclassID = 1 }), enchCtx)
    eq(greenBelow.mark, 'useful')
    eq(greenBelow.reasons[1].kind, 'no_rule')
    eq(findReason(greenBelow.otherReasons, 'armor_below_equipped'), nil)

    -- Encantamiento + blanco + armadura inferior -> moneda.
    local whiteBelow = ns.Classify(item({ quality = 1, subclassID = 1 }), enchCtx)
    eq(whiteBelow.mark, 'coin')
    eq(whiteBelow.reasons[1].kind, 'armor_below_equipped')

    -- Encantamiento + verde + gear_outgrown -> no se vende.
    local greenOutgrown = ns.Classify(item({ quality = 2, subclassID = 3, reqLevel = 5 }), context({ level = 30, professions = { [333] = true } }))
    eq(greenOutgrown.mark, 'useful')
    eq(greenOutgrown.reasons[1].kind, 'no_rule')
    eq(findReason(greenOutgrown.otherReasons, 'gear_outgrown'), nil)

    -- Encantamiento + blanco + gear_outgrown -> sí se vende.
    local whiteOutgrown = ns.Classify(item({ quality = 1, subclassID = 3, reqLevel = 5 }), context({ level = 30, professions = { [333] = true } }))
    eq(whiteOutgrown.mark, 'coin')
    eq(whiteOutgrown.reasons[1].kind, 'gear_outgrown')
end)

test('armadura inferior: respeta pieza de set, conjunto guardado, candado manual, GearQuest y vetos de duda', function()
    -- Pieza de set.
    eq(ns.Classify(item({ isSetPiece = true }), context()).mark, 'useful')

    -- Conjunto de equipamiento guardado.
    C_EquipmentSet = {
        GetEquipmentSetIDs = function() return { 1 } end,
        GetItemIDs = function() return { [1] = ID } end,
    }
    eq(ns.Classify(item(), context()).mark, 'useful')
    C_EquipmentSet = nil

    -- Candado manual (override_keep).
    local kept = ns.Classify(item(), context({ overrides = { [ID] = 'keep' } }))
    eq(kept.mark, 'protected')
    eq(kept.reasons[1].kind, 'override_keep')
    ok(findReason(kept.otherReasons, 'armor_below_equipped'))

    -- GearQuest lo puntúa -> se guarda.
    GQ = {
        Data = {
            EntryForItemLink = function() return { pipelineScore = 15 } end,
        },
        IsPreviewEnabled = function() return false end,
        GetEffectiveLevel = function() return 18 end,
        GetEffectiveClass = function() return 'PALADIN' end,
    }
    eq(ns.Classify(item(), context()).mark, 'useful')

    -- GearQuest no lo puntúa -> moneda.
    GQ.Data.EntryForItemLink = function() return nil end
    eq(ns.Classify(item(), context()).mark, 'coin')

    -- GearQuest en simulación (preview) -> se guarda.
    GQ.IsPreviewEnabled = function() return true end
    eq(ns.Classify(item(), context()).mark, 'useful')
    GQ = nil

    -- Vetos de duda: diario incompleto, efecto desconocido, datos pendientes.
    eq(ns.Classify(item(), context({ questLogIncomplete = true })).mark, 'useful')
    eq(ns.Classify(item({ effect = 'unknown' }), context()).mark, 'useful')
    eq(ns.Classify(item({ pending = true }), context()).pending, true)

    -- Precedencia con gear_outgrown: si aplican las dos, gana gear_outgrown y armor_below_equipped pasa a otherReasons.
    local both = ns.Classify(item({ reqLevel = 12, subclassID = 1 }), context({ level = 30 }))
    eq(both.mark, 'coin')
    eq(both.reasons[1].kind, 'gear_outgrown')
    local secondary = findReason(both.otherReasons, 'armor_below_equipped')
    ok(secondary, 'armor_below_equipped en otherReasons')
    eq(secondary.subclassID, 1)
    eq(secondary.equipped, 3)
end)

test('armadura inferior: rules.armorBelow = false conserva el veredicto anterior', function()
    local off = ns.Classify(item(), context({ rules = { sellUnruled = true, armorBelow = false } }))
    eq(off.mark, 'useful')
    eq(off.reasons[1].kind, 'no_rule')
    eq(off.reasons[1].exception, 'gear')
end)

test('armadura inferior: reemplaza también future_level cuando el tipo es inferior al puesto', function()
    -- Paladín nivel 30 con malla puesta y tela reqLevel 35 en bolsas -> moneda (y future_level pasa a otherReasons).
    local futureLower = ns.Classify(item({ subclassID = 1, reqLevel = 35 }), context({ level = 30, equippedArmor = { [5] = 3 } }))
    eq(futureLower.mark, 'coin')
    eq(futureLower.reasons[1].kind, 'armor_below_equipped')
    ok(findReason(futureLower.otherReasons, 'future_level'))
end)

test('armadura inferior: líneas de tooltip en ambos idiomas y fila en pestaña Reglas tras rules.sellUnruled', function()
    local savedL = ns.L
    local prevLevel = UnitLevel
    UnitLevel = function() return 18 end
    FAKE.class = 'PALADIN'
    FAKE.items[888010] = { name = 'Coraza de malla', quality = 2, price = 200, classID = 4, subclassID = 3, equipLoc = 'INVTYPE_CHEST' }
    FAKE.items[ID] = { name = 'Jubón Vinculahechizo', quality = 2, price = 180, classID = 4, subclassID = 1, equipLoc = 'INVTYPE_CHEST', reqLevel = 12 }
    FAKE.equipped = { [5] = 888010 }
    local success, err = pcall(function()
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            ns.Player.Invalidate()
            local lines = ns.Tooltip.Lines(FAKE.linkOf(ID), true)
            local expected = locale == 'enUS'
                and 'cloth armor: you wear mail there'
                or 'Armadura de tela: llevás puesto malla en ese lugar'
            eq(lines[2].text:sub(-#expected), expected)
        end
    end)
    UnitLevel, ns.L, FAKE.locale = prevLevel, savedL, nil
    ns.Player.Invalidate()
    if not success then error(err, 0) end

    -- Fila en pestaña Reglas justo después de rules.sellUnruled y alterna rules.armorBelow.
    eq(ns.DB.rules.armorBelow, true)
    local rulesRows = {}
    for _, row in ipairs(ns.Options.TOGGLES) do
        if row.section == 'Rules' then rulesRows[#rulesRows + 1] = row end
    end
    eq(rulesRows[1].path, 'rules.sellUnruled')
    eq(rulesRows[2].path, 'rules.armorBelow')
    eq(rulesRows[2].label, 'Armor below what you wear')

    local panel = ns.Options.Build()
    panel:SetSize(650, 500)
    panel:Show()
    local check = panel.checks['rules.armorBelow']
    ok(check, 'casilla rules.armorBelow en el panel')
    eq(check:GetChecked(), true)
    check:SetChecked(false)
    check.scripts.OnClick(check)
    eq(ns.DB.rules.armorBelow, false)
    check:SetChecked(true)
    check.scripts.OnClick(check)
    eq(ns.DB.rules.armorBelow, true)
end)

test('armadura inferior: el contexto se reconstruye y avisa al disparar PLAYER_EQUIPMENT_CHANGED', function()
    FAKE.class = 'PALADIN'
    FAKE.items[888020] = { name = 'Peto de cuero', quality = 2, price = 100, classID = 4, subclassID = 2, equipLoc = 'INVTYPE_CHEST' }
    FAKE.items[888021] = { name = 'Peto de malla', quality = 2, price = 200, classID = 4, subclassID = 3, equipLoc = 'INVTYPE_CHEST' }
    FAKE.equipped = { [5] = 888020 }
    ns.Player.Invalidate()
    local before = ns.Player.GetContext()
    eq(before.equippedArmor[5], 2)

    local changed = 0
    ns.Player.OnChanged(function() changed = changed + 1 end)
    FAKE.equipped = { [5] = 888021 }
    FAKE.Fire('PLAYER_EQUIPMENT_CHANGED', 5, true)
    FAKE.Advance(0.25)
    local after = ns.Player.GetContext()
    ok(after ~= before, 'contexto reconstruido')
    eq(after.equippedArmor[5], 3)
    eq(changed, 1, 'OnChanged notificado al cambiar armadura equipada')
end)
