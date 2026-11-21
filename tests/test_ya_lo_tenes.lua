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

test('ya lo tenés: tooltip de un enlace dice cuántos tenés; en las bolsas no', function()
    local savedL = ns.L
    FAKE.locale = 'esES'; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
    FAKE.items[ID] = { name = 'Anillo', quality = 2, price = 10, classID = 4, subclassID = 0, stack = 1 }
    counts(1, 2)
    local good, err = pcall(function()
        local text = {}
        for _, l in ipairs(ns.Tooltip.Lines(FAKE.linkOf(ID))) do text[#text + 1] = l.text end
        ok(table.concat(text, '\n'):find('Ya tenés 2 (bolsas 1, banco 1)', 1, true), 'línea en el enlace')
    end)
    GetItemCount = nil
    ns.L, FAKE.locale = savedL, nil
    if not good then error(err, 0) end
end)
