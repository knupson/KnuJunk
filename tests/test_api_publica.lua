-- API pública KnuJunkAPI (pedido de WOWCompanion 2026-11-23): la marca de un objeto, sin efectos.

test('KnuJunkAPI: existe con Version 1 y MarkFor', function()
    eq(type(KnuJunkAPI), 'table'); eq(KnuJunkAPI.Version, 1); eq(type(KnuJunkAPI.MarkFor), 'function')
end)

test('KnuJunkAPI.MarkFor: gris por link y por casilla da coin', function()
    FAKE.items[991801] = { name = 'Hacha de prueba', quality = 0, price = 1609, classID = 2, subclassID = 1,
        equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 27 }
    FAKE.bags['0:2'] = 991801
    ns.Player.Invalidate()
    eq(KnuJunkAPI.MarkFor('item:991801'), 'coin')
    eq(KnuJunkAPI.MarkFor('item:991801', 0, 2), 'coin')
    eq(KnuJunkAPI.MarkFor(991801), 'coin')
end)

test('KnuJunkAPI.MarkFor: casilla con otro objeto cae al link', function()
    FAKE.items[991802] = { name = 'Hacha gris 2', quality = 0, price = 10, classID = 2, subclassID = 1,
        equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 5 }
    FAKE.bags['0:3'] = 991801
    ns.Player.Invalidate()
    eq(KnuJunkAPI.MarkFor('item:991802', 0, 3), 'coin')
end)

test('KnuJunkAPI.MarkFor: nil sin datos, con basura o con KnuJunk apagado', function()
    eq(KnuJunkAPI.MarkFor('item:991899'), nil)
    eq(KnuJunkAPI.MarkFor(nil), nil)
    eq(KnuJunkAPI.MarkFor({}), nil)
    eq(KnuJunkAPI.MarkFor('basura', 'x', {}), nil)
    FAKE.items[991803] = { name = 'Hacha gris 3', quality = 0, price = 10, classID = 2, subclassID = 1,
        equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 5 }
    ns.DB.enabled = false
    eq(KnuJunkAPI.MarkFor('item:991803'), nil)
    ns.DB.enabled = nil
    eq(KnuJunkAPI.MarkFor('item:991803'), 'coin')
end)

test('KnuJunkAPI.MarkFor: no marca botones ni toca la base', function()
    FAKE.items[991804] = { name = 'Hacha gris 4', quality = 0, price = 10, classID = 2, subclassID = 1,
        equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 5 }
    local before = 0
    for _ in pairs(ns.DB) do before = before + 1 end
    KnuJunkAPI.MarkFor('item:991804')
    local after = 0
    for _ in pairs(ns.DB) do after = after + 1 end
    eq(after, before)
end)
