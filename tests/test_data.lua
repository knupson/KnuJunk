test('Data: build y reactivos generados', function()
    ok(ns.Data.build and ns.Data.build:match('^1%.60%.'), 'build de wowf')
    local professions = ns.Data.reagents[2840] -- Barra de cobre
    ok(professions, 'reagents[2840] existe')
    local set = {}
    for _, line in ipairs(professions) do set[line] = true end
    ok(set[164] and set[202], 'Herreria e Ingenieria usan la barra de cobre')
end)

test('Data: todo reactivo apunta a una profesion conocida', function()
    for item, lines in pairs(ns.Data.reagents) do
        for _, line in ipairs(lines) do ok(ns.PROFESSIONS[line], 'profesion desconocida ' .. line .. ' en ' .. item) end
    end
end)

test('Data: starters', function()
    eq(ns.Data.starters[1307], 123)
end)

test('Data: herramientas generadas (martillo, pico, cuchillo) y todas con profesion conocida', function()
    local function has(item, line)
        for _, value in ipairs(ns.Data.tools[item] or {}) do if value == line then return true end end
        return false
    end
    ok(has(5956, 164) and has(5956, 202), 'Martillo de herrero: Herreria e Ingenieria')
    ok(has(2901, 186), 'Pico de minero: Mineria')
    ok(has(7005, 393), 'Cuchillo de desuello: Desuello')
    for item, lines in pairs(ns.Data.tools) do
        for _, line in ipairs(lines) do ok(ns.PROFESSIONS[line], 'profesion desconocida ' .. line .. ' en ' .. item) end
    end
end)

test('Data: libros de biblioteca y cajones arrebatados', function()
    for _, id in ipairs({ 209851, 209847, 210177, 208800 }) do
        eq(ns.Data.libraryBooks[id], true, 'libro ' .. id)
    end
    eq(ns.Data.waylaidCrates[248684], true, 'Cajon arrebatado: Textiles de aprendiz')
    eq(ns.Data.waylaidCrates[248765], 'sealed', 'Cajon de aprendiz sellado')
    eq(ns.Data.waylaidCrates[211315], nil, 'Waylaid Supplies no es un cajon')
end)
