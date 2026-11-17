-- Marcas sobre botones de item y programador de refrescos. Cada prueba crea sus botones y sus datos.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
    return base
end

local function newButton() return CreateFrame('Button') end

-- Fija el veredicto del clasificador durante fn (restaura siempre).
local function withMark(mark, fn)
    local saved = ns.Classify
    ns.Classify = function() return { mark = mark, reasons = {} } end
    local success, err = pcall(fn)
    ns.Classify = saved
    if not success then error(err, 0) end
end

local function visible(button) return button.KnuJunkMark ~= nil and button.KnuJunkMark:IsShown() == true end

test('Update en bolsa 0 con gris: textura visible de moneda', function()
    addItem(100, { quality = 0, price = 5 })
    FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button), 'marca visible')
    eq(button.KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
    eq(button.KnuJunkOwner, 'generic')
end)

test('Update guarda el dueno del boton', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1, 'bagnon')
    eq(button.KnuJunkOwner, 'bagnon')
end)

test('Update en bolsa -1 (banco) no marca y limpia una marca previa', function()
    addItem(100); FAKE.bags['0:1'] = 100; FAKE.bags['-1:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button))
    ns.Marks.Update(button, -1, 1)
    ok(not visible(button), 'banco sin marca')
    local other = newButton()
    ns.Marks.Update(other, -1, 1)
    ok(not visible(other), 'banco sin textura visible')
    ns.Marks.Update(other, 5, 1)
    ok(not visible(other), 'bolsa 5 sin marca')
    ns.Marks.Update(other, nil, 1)
    ok(not visible(other), 'sin bolsa sin marca')
end)

test('boton reciclado a slot vacio oculta la textura', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button))
    ns.Marks.Update(button, 0, 2) -- vacio
    ok(not visible(button))
end)

test('item sin datos: sin marca y se marca al llegar GET_ITEM_INFO_RECEIVED', function()
    FAKE.bags['0:1'] = 200 -- el cliente aun no conoce el item
    local button = newButton()
    ns.Marks.Update(button, 0, 1, 'generic')
    ok(not visible(button), 'sin datos no hay marca')
    addItem(200, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(visible(button), 're-marcado al llegar los datos')
    eq(button.KnuJunkMark.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
end)

test('GET_ITEM_INFO_RECEIVED de otro item no marca', function()
    FAKE.bags['0:1'] = 200
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    addItem(200, { quality = 0 }); addItem(201)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 201, true)
    ok(not visible(button))
end)

test('boton reasignado antes de llegar los datos no recibe la marca vieja', function()
    FAKE.bags['0:1'] = 200
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ns.Marks.Update(button, 0, 2) -- ahora vacio
    addItem(200, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(button))
end)

test('show.coin = false oculta la moneda', function()
    addItem(100); FAKE.bags['0:1'] = 100
    ns.DB.show.coin = false
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(not visible(button))
end)

test('enabled = false limpia y no marca', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button))
    ns.DB.enabled = false
    ns.Marks.Update(button, 0, 1)
    ok(not visible(button))
end)

test('martillo propio: verde; ajeno: gris desaturado con alpha 0.7', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    withMark('hammer_mine', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button))
    eq(button.KnuJunkMark.texture, 'Interface\\Icons\\Trade_BlackSmithing')
    eq(button.KnuJunkMark.vertex[1], 0.25); eq(button.KnuJunkMark.vertex[2], 0.85); eq(button.KnuJunkMark.vertex[3], 0.35)
    ok(not button.KnuJunkMark.desaturated)
    withMark('hammer_other', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button))
    eq(button.KnuJunkMark.desaturated, true)
    eq(button.KnuJunkMark.alpha, 0.7)
    withMark('coin', function() ns.Marks.Update(button, 0, 1) end)
    ok(not button.KnuJunkMark.desaturated, 'la moneda no hereda la desaturacion')
    eq(button.KnuJunkMark.alpha, 1)
    eq(button.KnuJunkMark.vertex[1], 1)
end)

test('show.hammer = false oculta los dos martillos pero no la moneda', function()
    addItem(100); FAKE.bags['0:1'] = 100
    ns.DB.show.hammer = false
    local button = newButton()
    withMark('hammer_mine', function() ns.Marks.Update(button, 0, 1) end)
    ok(not visible(button))
    withMark('hammer_other', function() ns.Marks.Update(button, 0, 1) end)
    ok(not visible(button))
    withMark('coin', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button))
end)

test('quest no se dibuja en bolsas', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    withMark('quest', function() ns.Marks.Update(button, 0, 1) end)
    ok(not visible(button))
end)

test('UpdateLink dibuja moneda y quest (botin) y guarda el dueno', function()
    addItem(100)
    local button = newButton()
    ns.Marks.UpdateLink(button, FAKE.linkOf(100), 'loot')
    ok(visible(button)); eq(button.KnuJunkOwner, 'loot')
    withMark('quest', function() ns.Marks.UpdateLink(button, FAKE.linkOf(100)) end)
    ok(visible(button), 'quest se dibuja en botin')
    eq(button.KnuJunkMark.texture, 'Interface\\GossipFrame\\AvailableQuestIcon')
    eq(button.KnuJunkOwner, 'generic')
end)

test('UpdateLink: enabled = false, show.loot = false o link vacio limpian', function()
    addItem(100)
    local button = newButton()
    ns.Marks.UpdateLink(button, FAKE.linkOf(100))
    ok(visible(button))
    ns.Marks.UpdateLink(button, nil)
    ok(not visible(button), 'link vacio')
    ns.Marks.UpdateLink(button, FAKE.linkOf(100))
    ns.DB.show.loot = false
    ns.Marks.UpdateLink(button, FAKE.linkOf(100))
    ok(not visible(button), 'show.loot = false')
    ns.DB.show.loot = true
    ns.DB.enabled = false
    ns.Marks.UpdateLink(button, FAKE.linkOf(100))
    ok(not visible(button), 'enabled = false')
end)

test('UpdateLink con item sin datos se marca al llegar GET_ITEM_INFO_RECEIVED', function()
    local button = newButton()
    ns.Marks.UpdateLink(button, '|cffffffff|Hitem:300::::::::|h[X]|h|r', 'loot')
    ok(not visible(button))
    addItem(300, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 300, true)
    ok(visible(button))
    eq(button.KnuJunkOwner, 'loot')
end)

test('Clear oculta la marca y olvida lo pendiente', function()
    FAKE.bags['0:1'] = 200
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ns.Marks.Clear(button)
    addItem(200, { quality = 0 })
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(button))
    ns.Marks.Clear(newButton()) -- sin marca previa no falla
end)

test('un error del clasificador no rompe y deja sin marca', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button))
    local saved = ns.Classify
    ns.Classify = function() error('roto') end
    local success = pcall(ns.Marks.Update, button, 0, 1)
    ns.Classify = saved
    ok(success, 'Update no propaga el error')
    ok(not visible(button), 'ante la duda, sin marca')
end)

-- ---------------------------------------------------------------------------
-- Registro de adaptadores y refrescos
-- ---------------------------------------------------------------------------

local function counted(name, fields)
    local spec
    spec = { install = function() spec.installed = (spec.installed or 0) + 1; return true end,
        refresh = function() spec.refreshed = (spec.refreshed or 0) + 1 end }
    for key, value in pairs(fields or {}) do spec[key] = value end
    ns.Bags.Register(name, spec)
    return spec
end

test('diez BAG_UPDATE_DELAYED seguidos: un solo refresco agrupado', function()
    local spec = counted('t_burst')
    ns.Bags.InstallAll()
    for _ = 1, 10 do FAKE.Fire('BAG_UPDATE_DELAYED') end
    eq(spec.refreshed, nil, 'todavia no corrio')
    FAKE.Advance(0.2)
    eq(spec.refreshed, 1)
    FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(0.2)
    eq(spec.refreshed, 2, 'la siguiente rafaga vuelve a refrescar')
end)

test('RefreshAll agrupa llamadas directas en una sola pasada', function()
    local spec = counted('t_direct')
    ns.Bags.InstallAll()
    ns.Bags.RefreshAll(); ns.Bags.RefreshAll(); ns.Bags.RefreshAll()
    FAKE.Advance(0.2)
    eq(spec.refreshed, 1)
end)

test('un cambio real del contexto (Player.OnChanged) pide un refresco', function()
    local spec = counted('t_changed')
    ns.Bags.InstallAll(); FAKE.Advance(0.2); spec.refreshed = nil
    FAKE.professions = { { name = 'Alquimia', skillLine = 171 } }
    ns.Player.GetContext()
    FAKE.professions = { { name = 'Alquimia', skillLine = 171 }, { name = 'Mineria', skillLine = 186 } }
    FAKE.Fire('SKILL_LINES_CHANGED'); FAKE.Advance(1)
    eq(spec.refreshed, 1)
end)

test('Questie.OnReady pide un refresco', function()
    local spec = counted('t_questie')
    ns.Bags.InstallAll(); FAKE.Advance(0.2); spec.refreshed = nil
    FAKE.InstallQuestie({ [1] = { objectives = { nil, nil, { { 500 } } } } })
    ns.Questie.Uses(0)
    FAKE.Advance(5)
    ok(ns.Questie.IsReady(), 'indice listo')
    eq(spec.refreshed, 1)
end)

test('RefreshAll sin C_Timer corre en el acto', function()
    local spec = counted('t_notimer')
    ns.Bags.InstallAll()
    local saved = C_Timer
    C_Timer = nil
    ns.Bags.RefreshAll()
    C_Timer = saved
    eq(spec.refreshed, 1)
end)

test('Register + InstallAll: instala una vez; ADDON_LOADED instala el que faltaba', function()
    local plain = counted('t_plain')
    local needs = counted('t_needs', { addon = 'Bagnon' })
    ns.Bags.InstallAll()
    eq(plain.installed, 1); eq(needs.installed, nil, 'Bagnon no esta cargado')
    ns.Bags.InstallAll()
    eq(plain.installed, 1, 'una sola vez')
    FAKE.addons.Bagnon = true
    FAKE.Fire('ADDON_LOADED', 'Bagnon')
    eq(needs.installed, 1)
    FAKE.Fire('ADDON_LOADED', 'Otro')
    eq(needs.installed, 1)
    local names = ns.Bags.Installed()
    local set = {}
    for _, name in ipairs(names) do set[name] = true end
    ok(set.t_plain and set.t_needs, 'Installed lista los instalados')
end)

test('install que devuelve false se reintenta; que falla no rompe a los demas', function()
    local late = counted('t_late', { install = function() return false end })
    local calls = 0
    late.install = function() calls = calls + 1; return calls >= 2 end
    local broken = counted('t_broken', { install = function() error('roto') end })
    local fine = counted('t_fine')
    ns.Bags.InstallAll()
    eq(fine.installed, 1, 'el error de un adaptador no frena al resto')
    eq(calls, 1)
    FAKE.Fire('ADDON_LOADED', 'Cualquiera')
    eq(calls, 2)
    FAKE.Fire('ADDON_LOADED', 'Cualquiera')
    eq(calls, 2, 'una vez instalado no se repite')
    local installed = {}
    for _, name in ipairs(ns.Bags.Installed()) do installed[name] = true end
    ok(installed.t_late and installed.t_fine and not installed.t_broken)
end)

test('PLAYER_LOGIN instala los adaptadores registrados', function()
    local spec = counted('t_login')
    FAKE.Fire('PLAYER_LOGIN')
    eq(spec.installed, 1)
end)

test('un refresh que falla no rompe a los otros', function()
    local bad = counted('t_badrefresh', { refresh = function() error('roto') end })
    local good = counted('t_goodrefresh')
    ns.Bags.InstallAll()
    ns.Bags.RefreshAll(); FAKE.Advance(0.2)
    eq(good.refreshed, 1)
end)
