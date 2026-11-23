local ID = 991001

local function item(fields)
    local value = { id = ID, link = 'item:' .. ID, quality = 1, price = 25, classID = 15, subclassID = 0, isBound = true }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end

local function context(fields)
    local value = {
        class = 'WARRIOR',
        level = 40,
        professions = {},
        overrides = {},
        questItemsInLog = {},
        questInLog = function() return false end,
        isQuestDone = function() return false end,
        rules = { sellUnruled = true, food = false, ammo = false, knownRecipe = false, gearNotRanked = true },
    }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end

local function findReason(list, kind)
    for _, r in ipairs(list or {}) do
        if r.kind == kind then return r end
    end
end

test('venta por defecto: rules.sellUnruled activada por defecto y primera en pestaña Reglas', function()
    eq(ns.DB.rules.sellUnruled, true)
    local firstRule
    for _, row in ipairs(ns.Options.TOGGLES) do
        if row.section == 'Rules' then firstRule = row; break end
    end
    ok(firstRule, 'hay filas en Rules')
    eq(firstRule.path, 'rules.sellUnruled')
    eq(firstRule.label, 'Sell items with no rule')
    KnuJunkDB = { rules = { sellUnruled = false } }
    FAKE.Fire('ADDON_LOADED', 'KnuJunk')
    eq(ns.DB.rules.sellUnruled, false)
end)

test('venta por defecto: vende misceláneos comunes o poco comunes sin regla y con precio', function()
    for _, q in ipairs({ 1, 2 }) do
        local r = ns.Classify(item({ quality = q, price = 30 }), context())
        eq(r.mark, 'coin')
        eq(r.reasons[1].kind, 'no_keep_reason')
    end
    -- Con sellUnruled apagado vuelve a no_rule sin sufijo.
    local off = ns.Classify(item({ quality = 1, price = 30 }), context({ rules = { sellUnruled = false } }))
    eq(off.mark, 'useful')
    eq(off.reasons[1].kind, 'no_rule')
    eq(off.reasons[1].exception, nil)
    -- Sin precio de venta no puede venderse.
    local priceless = ns.Classify(item({ quality = 1, price = 0 }), context())
    eq(priceless.mark, 'useful')
    eq(priceless.reasons[1].kind, 'no_rule')
end)

test('venta por defecto: sin ligar con precio de subasta alto pasa a subasta', function()
    Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function() return 5000 end } } }
    local r = ns.Classify(item({ isBound = false, price = 25 }), context())
    eq(r.mark, 'auction')
    eq(r.reasons[1].kind, 'no_keep_reason')
    eq(r.auctionPrice, 5000)
    Auctionator = nil
end)

test('venta por defecto: respeta categorías excluidas, efecto, conjunto y vetos de duda', function()
    local cases = {
        { item = { classID = 1 }, exception = 'bag' },
        { item = { classID = 11 }, exception = 'bag' },
        { item = { classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', reqLevel = 35 }, exception = 'gear' },
        { item = { classID = 4, subclassID = 4, equipLoc = 'INVTYPE_CHEST', reqLevel = 35 }, exception = 'gear' },
        { item = { openable = true }, exception = 'openable' },
        { item = { quality = 3 }, exception = 'rare_or_epic' },
        { item = { quality = 4 }, exception = 'rare_or_epic' },
        { item = { classID = 6, subclassID = 2 }, exception = 'ammo' },
        { item = { classID = 9, subclassID = 0 }, exception = 'book' },
        { item = { classID = 12, subclassID = 0, effect = 'unknown' }, exception = 'quest' },
        { item = { classID = 13, subclassID = 0 }, kind = 'key' },
    }
    for _, case in ipairs(cases) do
        local r = ns.Classify(item(case.item), context())
        eq(r.mark, 'useful')
        if case.kind then
            eq(r.reasons[1].kind, case.kind)
        elseif case.exception then
            eq(r.reasons[1].kind, 'no_rule')
            eq(r.reasons[1].exception, case.exception)
        end
    end
    -- Efecto de uso/equipar confirmado conserva utilidad.
    local eff = ns.Classify(item({ effect = 'yes' }), context())
    eq(eff.mark, 'useful')
    eq(eff.reasons[1].kind, 'useful')
    -- Conjunto de equipamiento conserva utilidad.
    C_EquipmentSet = {
        GetEquipmentSetIDs = function() return { 1 } end,
        GetItemIDs = function() return { [1] = ID } end,
    }
    eq(ns.Classify(item(), context()).mark, 'useful')
    C_EquipmentSet = nil
    -- Vetos de duda impiden venta por defecto.
    eq(ns.Classify(item({ effect = 'unknown' }), context()).mark, 'useful')
    eq(ns.Classify(item(), context({ questLogIncomplete = true })).mark, 'useful')
    eq(ns.Classify(item({ pending = true }), context()).pending, true)
end)

test('venta por defecto: tabla ns.Data.openables poblada y excluye de venta por defecto', function()
    ok(type(ns.Data.openables) == 'table', 'tabla openables')
    ok(ns.Data.openables[5523], 'almeja 5523 en openables')
    local r = ns.Classify(item({ id = 5523, openable = false }), context())
    eq(r.mark, 'useful')
    eq(r.reasons[1].kind, 'no_rule')
    eq(r.reasons[1].exception, 'openable')
end)

test('venta por defecto: sufijos de excepción en tooltip en castellano e inglés', function()
    local savedL = ns.L
    local suffixes = {
        { exception = 'gear', es = 'Equipo: se guarda', en = 'Gear: kept' },
        { exception = 'bag', es = 'Bolsa: se guarda (equipala si es más grande que una tuya)', en = 'Bag: kept (equip it if it is bigger than one of yours)' },
        { exception = 'openable', es = 'Se abre: abrilo antes de venderlo', en = 'Openable: open it before selling it' },
        { exception = 'rare_or_epic', es = 'Raro o épico: se guarda (vale más que lo que paga el vendedor)', en = 'Rare or epic: kept (worth more than the vendor pays)' },
        { exception = 'ammo', es = 'Munición: se guarda', en = 'Ammunition: kept' },
        { exception = 'book', es = 'Libro o receta: se guarda', en = 'Book or recipe: kept' },
        { exception = 'quest', es = 'Objeto de misión: se guarda', en = 'Quest item: kept' },
        { exception = 'key', es = 'Llave: se guarda', en = 'Key: kept' },
    }
    local savedClassify = ns.Classify
    local success, err = pcall(function()
        FAKE.items[ID] = { name = 'Prueba', quality = 1, price = 10, classID = 15, subclassID = 0 }
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            for _, s in ipairs(suffixes) do
                ns.Classify = function()
                    return { mark = 'useful', reasons = { { kind = 'no_rule', exception = s.exception } } }
                end
                local lines = ns.Tooltip.Lines(FAKE.linkOf(ID))
                eq(lines[2].text, locale == 'enUS' and s.en or s.es)
            end
        end
    end)
    ns.Classify, ns.L, FAKE.locale = savedClassify, savedL, nil
    if not success then error(err, 0) end
end)

test('equipo superado: vende cuando reqLevel + 10 <= nivel y calidad <= 2', function()
    local g = item({ classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', quality = 2, reqLevel = 30, price = 100 })
    -- Nivel 39: todavía no superado (30 + 10 > 39).
    local r39 = ns.Classify(g, context({ level = 39 }))
    eq(r39.mark, 'useful')
    eq(r39.reasons[1].kind, 'no_rule')
    eq(r39.reasons[1].exception, 'gear')
    -- Nivel 40: superado (30 + 10 <= 40).
    local r40 = ns.Classify(g, context({ level = 40 }))
    eq(r40.mark, 'coin')
    eq(r40.reasons[1].kind, 'gear_outgrown')
    eq(r40.reasons[1].level, 30)
    -- Sin precio de venta da basura.
    local rTrash = ns.Classify(item({ classID = 4, subclassID = 4, equipLoc = 'INVTYPE_CHEST', quality = 1, reqLevel = 5, price = 0 }), context({ level = 40 }))
    eq(rTrash.mark, 'trash')
    eq(rTrash.reasons[1].kind, 'gear_outgrown')
    -- Raro (calidad 3) o sin reqLevel no se marca como superado.
    eq(ns.Classify(item({ classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', quality = 3, reqLevel = 5 }), context({ level = 60 })).mark, 'useful')
    eq(ns.Classify(item({ classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', quality = 2, reqLevel = 0 }), context({ level = 60 })).mark, 'useful')
    -- Pieza de set, conjunto de equipamiento o ranura excluida no se marca como superada.
    eq(ns.Classify(item({ classID = 4, subclassID = 4, equipLoc = 'INVTYPE_CHEST', quality = 2, reqLevel = 5, isSetPiece = true }), context({ level = 60 })).mark, 'useful')
    eq(ns.Classify(item({ classID = 4, subclassID = 0, equipLoc = 'INVTYPE_TRINKET', quality = 2, reqLevel = 5 }), context({ level = 60 })).mark, 'useful')
    -- Si GearQuest puntúa el ítem (EntryForItemLink no nulo), no se vende por nivel bajo.
    GQ = {
        Data = {
            GetEntriesByItemId = function() return { { pipelineScore = 10 } } end,
            EntryForItemLink = function() return { pipelineScore = 10 } end,
            GearScoreMissText = function() return nil end,
        },
        IsPreviewEnabled = function() return false end,
        GetEffectiveLevel = function() return 40 end,
        GetEffectiveClass = function() return 'WARRIOR' end,
    }
    eq(ns.Classify(g, context({ level = 40 })).mark, 'useful')
    GQ.Data.EntryForItemLink = function() return nil end
    eq(ns.Classify(g, context({ level = 40 })).mark, 'coin')
    -- GearQuest en simulación o con error: no se puede confiar, no se vende.
    GQ.IsPreviewEnabled = function() return true end
    eq(ns.Classify(g, context({ level = 40 })).mark, 'useful')
    GQ.IsPreviewEnabled = function() return false end
    GQ.Data.EntryForItemLink = function() error('fallo GQ') end
    eq(ns.Classify(g, context({ level = 40 })).mark, 'useful')
    GQ = nil
end)

test('libros de clase: máscara -1 o 0 vale para todas las clases', function()
    local savedBooks = ns.Data.classBooks
    local prev = IsPlayerSpell
    IsPlayerSpell = function() return false end
    for _, mask in ipairs({ -1, 0 }) do
        ns.Data.classBooks = { [ID] = { classMask = mask, spell = 10157 } }
        local r = ns.Classify(item({ classID = 9, subclassID = 0, price = 50 }), context())
        ok(r.mark ~= 'coin', 'máscara ' .. mask .. ' no vende')
        eq(r.reasons[1].kind, 'book_unknown')
    end
    IsPlayerSpell = prev
    ns.Data.classBooks = savedBooks
end)

test('equipo superado: tooltip en castellano e inglés y evidencia secundaria bajo protección', function()
    local savedL = ns.L
    local success, err = pcall(function()
        FAKE.items[ID] = { name = 'Espada vieja', quality = 2, price = 40, classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', reqLevel = 5 }
        local prevLevel = UnitLevel
        UnitLevel = function() return 30 end
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            ns.Player.Invalidate()
            local lines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            local expected = locale == 'enUS' and 'Level 5 gear: too low for you' or 'Equipo de nivel 5: muy bajo para vos'
            eq(lines[2].text:sub(-#expected), expected)
        end
        UnitLevel = prevLevel
        ns.Player.Invalidate()
    end)
    ns.L, FAKE.locale = savedL, nil
    if not success then error(err, 0) end
    -- Bajo override_keep aparece en otherReasons.
    local r = ns.Classify(item({ classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', quality = 2, reqLevel = 5 }), context({ level = 30, overrides = { [ID] = 'keep' } }))
    eq(r.mark, 'protected')
    ok(findReason(r.otherReasons, 'gear_outgrown'))
end)

test('libros de clase: tabla poblada, otra clase, ya aprendido y no aprendido', function()
    ok(type(ns.Data.classBooks) == 'table', 'tabla classBooks')
    local count = 0
    for _ in pairs(ns.Data.classBooks) do count = count + 1 end
    ok(count > 500, 'más de 500 libros de clase')

    local savedBooks = ns.Data.classBooks
    ns.Data.classBooks = { [ID] = { classMask = 128, spell = 10157 } } -- MAGE = bit 128
    local success, err = pcall(function()
        local book = item({ classID = 9, subclassID = 0, quality = 2, price = 50 })
        -- Otra clase ligado -> class_cannot_use (moneda o basura).
        local boundOther = ns.Classify(book, context({ class = 'WARRIOR' }))
        eq(boundOther.mark, 'coin')
        eq(boundOther.reasons[1].kind, 'class_cannot_use')
        eq(ns.Classify(item({ classID = 9, subclassID = 0, price = 0, isBound = true }), context({ class = 'WARRIOR' })).mark, 'trash')

        -- Otra clase sin ligar -> book_other_class (moneda, o subasta con Auctionator).
        local freeOther = ns.Classify(item({ classID = 9, subclassID = 0, isBound = false, price = 50 }), context({ class = 'WARRIOR' }))
        eq(freeOther.mark, 'coin')
        eq(freeOther.reasons[1].kind, 'book_other_class')
        Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function() return 5000 end } } }
        local aucOther = ns.Classify(item({ classID = 9, subclassID = 0, isBound = false, price = 50 }), context({ class = 'WARRIOR' }))
        eq(aucOther.mark, 'auction')
        eq(aucOther.reasons[1].kind, 'book_other_class')
        Auctionator = nil

        -- Tu clase, hechizo no aprendido -> book_unknown (se guarda).
        FAKE.spells = {}
        local unknownBook = ns.Classify(book, context({ class = 'MAGE' }))
        eq(unknownBook.mark, 'useful')
        eq(unknownBook.reasons[1].kind, 'book_unknown')

        -- Tu clase, hechizo ya aprendido -> book_known (se vende o subasta).
        FAKE.spells = { [10157] = true }
        local knownBook = ns.Classify(book, context({ class = 'MAGE' }))
        eq(knownBook.mark, 'coin')
        eq(knownBook.reasons[1].kind, 'book_known')
        Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function() return 5000 end } } }
        local aucKnown = ns.Classify(item({ classID = 9, subclassID = 0, isBound = false, price = 50 }), context({ class = 'MAGE' }))
        eq(aucKnown.mark, 'auction')
        eq(aucKnown.reasons[1].kind, 'book_known')
        Auctionator = nil

        -- Si IsPlayerSpell falla o no está, cae a no_rule (book) sin vender.
        local prevPlayerSpell, prevSpellKnown = IsPlayerSpell, IsSpellKnown
        IsPlayerSpell = function() error('fallo API') end
        IsSpellKnown = nil
        local fallback = ns.Classify(book, context({ class = 'MAGE' }))
        eq(fallback.mark, 'useful')
        eq(fallback.reasons[1].kind, 'no_rule')
        eq(fallback.reasons[1].exception, 'book')
        IsPlayerSpell, IsSpellKnown = prevPlayerSpell, prevSpellKnown
    end)
    ns.Data.classBooks = savedBooks
    if not success then error(err, 0) end
end)

test('libros de clase: tooltips en castellano e inglés', function()
    local savedBooks, savedL = ns.Data.classBooks, ns.L
    ns.Data.classBooks = { [ID] = { classMask = 128, spell = 10157 } }
    local success, err = pcall(function()
        FAKE.items[ID] = { name = 'Tomo arcano', quality = 2, price = 50, classID = 9, subclassID = 0 }
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale
            assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            -- Otra clase sin ligar.
            FAKE.class = 'WARRIOR'
            ns.Player.Invalidate()
            local otherLines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            local expectedOther = locale == 'enUS' and 'Book for another class' or 'Libro de otra clase'
            eq(otherLines[2].text:sub(-#expectedOther), expectedOther)
            -- Misma clase, no aprendido.
            FAKE.class = 'MAGE'
            FAKE.spells = {}
            ns.Player.Invalidate()
            local unlearnedLines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(unlearnedLines[2].text, locale == 'enUS' and 'Your class book, not learned' or 'Libro de tu clase que no aprendiste')
            -- Misma clase, ya aprendido.
            FAKE.spells = { [10157] = true }
            ns.Player.Invalidate()
            local learnedLines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            local expected = locale == 'enUS' and 'You already know this spell' or 'Ya aprendiste este hechizo'
            eq(learnedLines[2].text:sub(-#expected), expected)
        end
    end)
    ns.Data.classBooks, ns.L, FAKE.locale = savedBooks, savedL, nil
    if not success then error(err, 0) end
end)

test('auto-venta: lista enlaces vendidos y parte líneas de más de 255 caracteres', function()
    C_Container.UseContainerItem = function(bag, slot)
        FAKE.used[#FAKE.used + 1] = { bag, slot }
        FAKE.bags[bag .. ':' .. slot] = nil
    end
    for slot = 1, 10 do
        local id = 2000 + slot
        FAKE.items[id] = { name = string.rep('NombreLargo', 3) .. slot, quality = 0, price = 10, classID = 15, subclassID = 0 }
        FAKE.bags['0:' .. slot] = id
    end
    FAKE.Fire('MERCHANT_SHOW')
    FAKE.Advance(5)
    ok(#FAKE.messages >= 3, 'resumen más múltiples líneas de Vendido')
    local prefix = '|cffecd9bdKNU|r|cffffa82eJunk|r: '
    for i = 2, #FAKE.messages do
        local payload = FAKE.messages[i]:sub(#prefix + 1)
        ok(payload:find('^Vendido: '), 'empieza con Vendido: ' .. payload)
        ok(#payload <= 255, 'no supera 255 caracteres: ' .. #payload)
    end
end)
