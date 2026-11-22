local ID = 991500

local function counts(bags, all)
    GetItemCount = function(_, bank) return bank and all or bags end
end

test('ya lo tenés: cuenta bolsas y banco sólo para lo que no se apila', function()
    FAKE.items[ID] = { name = 'Anillo', quality = 2, price = 10, classID = 4, subclassID = 0, stack = 1 }
    counts(1, 3)
    local total, bags, bank = ns.Marks.OwnedCount(FAKE.linkOf(ID))
    eq(total, 3); eq(bags, 1); eq(bank, 2)
    FAKE.items[ID].stack = 20
    eq(ns.Marks.OwnedCount(FAKE.linkOf(ID)), nil)
    GetItemCount = nil
end)

test('ya lo tenés: el botón del botín muestra xN, se oculta con 0, opción apagada o al limpiar', function()
    FAKE.items[ID] = { name = 'Anillo', quality = 2, price = 10, classID = 4, subclassID = 0, stack = 1 }
    local button = CreateFrame('Button')
    counts(1, 1)
    ns.Marks.UpdateOwned(button, FAKE.linkOf(ID))
    ok(button.KnuJunkOwned and button.KnuJunkOwned:IsShown(), 'visible')
    eq(button.KnuJunkOwned:GetText(), 'x1')
    counts(0, 0)
    ns.Marks.UpdateOwned(button, FAKE.linkOf(ID))
    eq(button.KnuJunkOwned:IsShown(), false)
    counts(2, 2)
    ns.DB.show.owned = false
    ns.Marks.UpdateOwned(button, FAKE.linkOf(ID))
    eq(button.KnuJunkOwned:IsShown(), false)
    ns.DB.show.owned = true
    ns.Marks.UpdateOwned(button, FAKE.linkOf(ID))
    ok(button.KnuJunkOwned:IsShown(), 'otra vez visible')
    ns.Marks.Clear(button)
    eq(button.KnuJunkOwned:IsShown(), false)
    GetItemCount = nil
end)

test('ya lo tenés: la línea es sólo del botín (no aparece en Tooltip.Lines de las bolsas)', function()
    local savedL = ns.L
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    FAKE.items[ID] = { name = 'Anillo', quality = 2, price = 10, classID = 4, subclassID = 0, stack = 1 }
    counts(1, 2)
    local good, err = pcall(function()
        eq(ns.Tooltip.OwnedLine(FAKE.linkOf(ID)), 'Ya tenés 2 (bolsas 1, banco 1)')
        local text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(ID))) do text[#text + 1] = l.text end
        ok(not table.concat(text, '\n'):find('Ya tenés', 1, true), 'no en el tooltip general')
    end)
    GetItemCount = nil
    ns.L, FAKE.locale = savedL, nil
    if not good then error(err, 0) end
end)

test('nivel que te falta: rojo en el botón sólo para equipo que todavía no te podés poner', function()
    local button = CreateFrame('Button')
    local ring = { classID = 4, equipLoc = 'INVTYPE_FINGER', reqLevel = 32 }
    local savedGet = ns.Player.GetContext
    ns.Player.GetContext = function() return { level = 28 } end
    local good, err = pcall(function()
        eq(ns.Marks.LevelNeeded(ring), 32)
        ns.Marks.UpdateLevel(button, ring)
        ok(button.KnuJunkLevel:IsShown(), 'visible'); eq(button.KnuJunkLevel:GetText(), '32')
        eq(ns.Marks.LevelNeeded({ classID = 4, equipLoc = 'INVTYPE_FINGER', reqLevel = 28 }), nil, 'mismo nivel')
        eq(ns.Marks.LevelNeeded({ classID = 0, equipLoc = '', reqLevel = 40 }), nil, 'consumible')
        eq(ns.Marks.LevelNeeded({ classID = 4, equipLoc = '', reqLevel = 40 }), nil, 'sin ranura')
        ns.Marks.UpdateLevel(button, { classID = 4, equipLoc = 'INVTYPE_FINGER', reqLevel = 20 })
        eq(button.KnuJunkLevel:IsShown(), false, 'ya te lo podés poner')
        ns.Marks.UpdateLevel(button, ring); ok(button.KnuJunkLevel:IsShown(), 'otra vez')
        ns.DB.show.level = false
        ns.Marks.UpdateLevel(button, ring); eq(button.KnuJunkLevel:IsShown(), false, 'opción apagada')
        ns.DB.show.level = true
        ns.Marks.UpdateLevel(button, ring); ns.Marks.Clear(button)
        eq(button.KnuJunkLevel:IsShown(), false, 'al limpiar')
        ns.Marks.UpdateLevel(button, nil); eq(button.KnuJunkLevel:IsShown(), false, 'sin ítem')
    end)
    ns.Player.GetContext = savedGet
    if not good then error(err, 0) end
end)

test('nivel que te falta: el tooltip lo dice también para el equipo', function()
    local savedL = ns.L
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    FAKE.items[992010] = { name = 'Anillo de pantano', quality = 2, price = 2469, classID = 4, subclassID = 0,
        equipLoc = 'INVTYPE_FINGER', reqLevel = 32, itemLevel = 37 }
    local savedLevel = UnitLevel
    UnitLevel = function() return 28 end
    ns.Player.Invalidate()
    local good, err = pcall(function()
        local text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(992010))) do text[#text + 1] = l.text end
        local all = table.concat(text, '\n')
        ok(all:find('Podés usarlo desde nivel 32', 1, true), all)
        local _, count = all:gsub('desde nivel 32', '')
        eq(count, 1, 'una sola vez')
    end)
    UnitLevel = savedLevel; ns.Player.Invalidate()
    ns.L, FAKE.locale = savedL, nil
    if not good then error(err, 0) end
end)
