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
