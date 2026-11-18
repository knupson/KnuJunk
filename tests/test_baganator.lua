-- Adaptador de Baganator por su API oficial: junk plugin + dos corner widgets.
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
end

-- Fija el veredicto del clasificador durante fn (restaura siempre).
local function withMark(mark, fn)
    local saved = ns.Classify
    ns.Classify = function() return { mark = mark, reasons = {} } end
    local success, err = pcall(fn)
    ns.Classify = saved
    if not success then error(err, 0) end
end

-- Baganator cargado y adaptador instalado; devuelve el estado grabado.
local function installed()
    local state = FAKE.InstallBaganator()
    ns.Bags.InstallAll()
    return state
end

-- Vista de mochila de Baganator visible; live = lo que dice su campo isLive.
local function backpackView(live, character)
    local view = CreateFrame('Frame', 'Baganator_SingleViewBackpackViewFramedark')
    view.isLive, view.lastCharacter = live, character
    return view
end

local function location(bag, slot) return { bagID = bag, slotIndex = slot } end

local function junk(state) return state.junk.knujunk.callback end

test('registra junk plugin y dos widgets', function()
    local state = installed()
    eq(state.junk.knujunk.label, 'KnuJunk')
    eq(state.widgets.knujunk_hammer.label, 'KnuJunk: martillo')
    eq(state.widgets.knujunk_coin.label, 'KnuJunk: monedita')
    local position = state.widgets.knujunk_hammer.defaultPosition
    ok(position ~= nil, 'el martillo se autoinserta en una esquina')
    eq(position.corner, 'top_right'); eq(position.priority, 1)
    local names = {}
    for _, name in ipairs(ns.Bags.Installed()) do names[name] = true end
    ok(names.Baganator, 'el registro de bolsas lo da por instalado')
end)

test('sin Baganator cargado -> install devuelve false', function()
    ok(ns.BaganatorAdapter.Install() == false, 'sin la API no se instala')
    ns.Bags.InstallAll()
    for _, name in ipairs(ns.Bags.Installed()) do ok(name ~= 'Baganator') end
    Baganator = { API = {} } -- cargado pero la API aun no tiene las funciones
    ok(ns.BaganatorAdapter.Install() == false, 'API incompleta')
end)

test('el registro no se duplica y se completa si falto algo', function()
    local state = installed()
    ok(ns.BaganatorAdapter.Install() == true, 'segunda llamada: ya esta todo')
    -- un registro que falla se reintenta
    ns.BaganatorAdapter.ResetState()
    local registerWidget = Baganator.API.RegisterCornerWidget
    Baganator.API.RegisterCornerWidget = function() error('Baganator roto') end
    state.junk, state.widgets = {}, {}
    ok(ns.BaganatorAdapter.Install() == false, 'falla el widget: no esta completo')
    ok(state.junk.knujunk ~= nil, 'el junk plugin si quedo')
    Baganator.API.RegisterCornerWidget = registerWidget
    ok(ns.BaganatorAdapter.Install() == true, 'reintento correcto')
    ok(state.widgets.knujunk_hammer ~= nil and state.widgets.knujunk_coin ~= nil)
end)

test('junk callback true solo para coin', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    backpackView(true)
    eq(junk(state)(0, 1, 100, FAKE.linkOf(100)), true, 'gris = moneda')
    withMark('hammer_mine', function() eq(junk(state)(0, 1, 100), false, 'martillo no es basura') end)
    withMark('hammer_other', function() eq(junk(state)(0, 1, 100), false) end)
    withMark('quest', function() eq(junk(state)(0, 1, 100), false) end)
    withMark(nil, function() eq(junk(state)(0, 1, 100), false) end)
end)

test('junk callback: solo bolsas 0-4 con el mismo item en el slot', function()
    local state = installed()
    addItem(100); addItem(101)
    FAKE.bags['0:1'] = 100; FAKE.bags['-1:1'] = 100; FAKE.bags['5:1'] = 100
    backpackView(true)
    ok(not junk(state)(-1, 1, 100), 'banco')
    ok(not junk(state)(5, 1, 100), 'bolsa 5')
    ok(not junk(state)(nil, 1, 100), 'sin bolsa')
    ok(not junk(state)(0, nil, 100), 'sin slot')
    ok(not junk(state)(0, 2, 100), 'slot vacio')
    ok(not junk(state)(0, 1, 101), 'el slot tiene otro item')
    ok(not junk(state)(0, 1, nil), 'sin itemID no hay prueba')
    eq(junk(state)(0, 1, 100), true, 'control: bolsa 0 con el mismo item')
end)

test('junk callback sin vista viva del personaje actual -> sin marca', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    ok(not junk(state)(0, 1, 100), 'sin ninguna vista de Baganator conocida')
    local view = backpackView(false, 'Otro-Reino')
    ns.BaganatorAdapter.Refresh()
    ok(not junk(state)(0, 1, 100), 'vista de otro personaje (isLive = false)')
    view.isLive = nil
    ns.BaganatorAdapter.Refresh()
    ok(not junk(state)(0, 1, 100), 'isLive sin fijar')
    view.isLive, view.lastCharacter = true, 'Otro-Reino'
    Syndicator = { API = { GetCurrentCharacter = function() return 'Yo-Reino' end } }
    ns.BaganatorAdapter.Refresh()
    ok(not junk(state)(0, 1, 100), 'isLive pero la vista dice otro personaje')
    view.lastCharacter = 'Yo-Reino'
    eq(junk(state)(0, 1, 100), true, 'vista viva del personaje actual')
    view:Hide()
    ok(not junk(state)(0, 1, 100), 'vista oculta no prueba nada')
    Syndicator = nil
end)

test('junk callback: una vista no viva visible bloquea aunque haya otra viva', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    backpackView(true)
    local second = CreateFrame('Frame', 'Baganator_CategoryViewBackpackViewFramedark')
    second.isLive = false
    ns.BaganatorAdapter.Refresh()
    ok(not junk(state)(0, 1, 100))
end)

test('junk callback: respeta enabled y show.coin, y no lanza si la lectura falla', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    backpackView(true)
    ns.DB.show.coin = false
    eq(junk(state)(0, 1, 100), false, 'show.coin = false')
    ns.DB.show.coin = true
    ns.DB.enabled = false
    eq(junk(state)(0, 1, 100), false, 'enabled = false')
    ns.DB.enabled = true
    local saved = ns.Player.ReadItem
    ns.Player.ReadItem = function() error('lectura rota') end
    local success, result = pcall(junk(state), 0, 1, 100)
    ns.Player.ReadItem = saved
    ok(success, 'no propaga el error')
    ok(not result, 'sin marca')
end)

-- Corner widget de `id`: crea la textura con onInit y la actualiza con onUpdate.
local function widget(state, id)
    local entry = state.widgets[id]
    local button = CreateFrame('Button')
    local texture = entry.onInit(button)
    return texture, function(details) return entry.onUpdate(texture, details) end
end

test('widget de martillo devuelve true y textura verde para hammer_mine', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    local texture, update = widget(state, 'knujunk_hammer')
    withMark('hammer_mine', function()
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), true)
    end)
    eq(texture.texture, 'Interface\\AddOns\\KnuJunk\\media\\martillo')
    eq(texture.vertex[1], 0.25); eq(texture.vertex[2], 0.85); eq(texture.vertex[3], 0.35)
    ok(not texture.desaturated)
    withMark('hammer_other', function()
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), true)
    end)
    ok(not texture.desaturated); eq(texture.alpha, 1)
    eq(texture.vertex[1], 1); eq(texture.vertex[2], 0.85); eq(texture.vertex[3], 0.2)
    eq(table.concat(texture.texCoord, ','), '0,1,0,1')
    withMark('coin', function()
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), false, 'el martillo no muestra monedas')
    end)
end)

test('widget de monedita: true solo para coin', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    local texture, update = widget(state, 'knujunk_coin')
    eq(update({ itemID = 100, itemLocation = location(0, 1) }), true)
    eq(texture.texture, 'Interface\\MoneyFrame\\UI-GoldIcon')
    withMark('hammer_mine', function()
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), false)
    end)
    withMark('quest', function()
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), false)
    end)
end)

test('widget: sin itemLocation (vista guardada) o fuera de bolsas 0-4 no dibuja', function()
    local state = installed()
    addItem(100)
    FAKE.bags['0:1'] = 100; FAKE.bags['-1:1'] = 100; FAKE.bags['5:1'] = 100
    local texture, update = widget(state, 'knujunk_coin')
    eq(update({ itemID = 100 }), false, 'vista de otro personaje: sin itemLocation')
    eq(update({ itemID = 100, itemLocation = location(-1, 1) }), false, 'banco')
    eq(update({ itemID = 100, itemLocation = location(5, 1) }), false, 'bolsa 5')
    eq(update({ itemID = 100, itemLocation = { equipmentSlotIndex = 3 } }), false, 'ranura de equipo')
    eq(update({ itemID = 101, itemLocation = location(0, 1) }), false, 'el slot tiene otro item')
    eq(update({ itemLocation = location(0, 1) }), false, 'sin itemID')
    eq(update(nil), false, 'sin detalles')
    ok(texture.texture == nil, 'nunca se dibujo nada')
    eq(update({ itemID = 100, itemLocation = location(0, 1) }), true, 'control')
end)

test('widget: show.coin / show.hammer = false y enabled = false', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    local _, coin = widget(state, 'knujunk_coin')
    local _, hammer = widget(state, 'knujunk_hammer')
    local details = { itemID = 100, itemLocation = location(0, 1) }
    ns.DB.show.coin = false
    eq(coin(details), false)
    ns.DB.show.coin = true
    ns.DB.show.hammer = false
    withMark('hammer_mine', function() eq(hammer(details), false) end)
    ns.DB.show.hammer = true
    ns.DB.enabled = false
    eq(coin(details), false, 'addon apagado')
end)

test('widget: onInit crea la textura sobre el boton', function()
    local state = installed()
    local button = CreateFrame('Button')
    local created
    button.CreateTexture = function(_, ...) created = { ... }; return CreateFrame('Texture') end
    ok(state.widgets.knujunk_coin.onInit(button) ~= nil)
    eq(created[2], 'OVERLAY')
end)

test('item sin datos: el widget no dibuja y al llegar GET_ITEM_INFO_RECEIVED se pide refresco', function()
    local state = installed()
    state.activeWidgets.knujunk_coin = true
    FAKE.bags['0:1'] = 200 -- el cliente aun no conoce el item
    local _, update = widget(state, 'knujunk_coin')
    eq(update({ itemID = 200, itemLocation = location(0, 1) }), false, 'sin datos no hay marca (y no se reintenta cada cuadro)')
    local before = state.refreshes
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 201, true)
    eq(state.refreshes, before, 'otro item no pide nada')
    addItem(200)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    eq(state.refreshes, before + 1, 'llegaron los datos: Baganator re-evalua')
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    eq(state.refreshes, before + 1, 'una sola vez por espera')
    eq(update({ itemID = 200, itemLocation = location(0, 1) }), true)
end)

test('Refresh pide el repintado a Baganator solo si algo nuestro esta activo', function()
    local state = installed()
    local base = state.refreshes
    ns.BaganatorAdapter.Refresh()
    eq(state.refreshes, base, 'nada activo: no se molesta a Baganator')
    state.activeJunk = 'knujunk'
    ns.BaganatorAdapter.Refresh()
    eq(state.refreshes, base + 1, 'junk plugin activo')
    state.activeJunk = nil; state.activeWidgets.knujunk_hammer = true
    ns.BaganatorAdapter.Refresh()
    eq(state.refreshes, base + 2, 'widget activo')
    state.activeWidgets.knujunk_hammer = nil
    Baganator.API.IsJunkPluginActive, Baganator.API.IsCornerWidgetActive = nil, nil
    ns.BaganatorAdapter.Refresh()
    eq(state.refreshes, base + 3, 'sin forma de saberlo se pide igual')
end)

test('el registro de bolsas repinta Baganator', function()
    local state = installed()
    state.activeJunk = 'knujunk'
    local base = state.refreshes
    ns.Bags.RefreshAll(); FAKE.Advance(0.2)
    eq(state.refreshes, base + 1)
end)

test('un error de Baganator al pedir el refresco no se propaga', function()
    local state = installed()
    state.activeJunk = 'knujunk'
    Baganator.API.RequestItemButtonsRefresh = function() error('roto') end
    ns.Bags.RefreshAll(); FAKE.Advance(0.2)
    ok(true)
end)

-- Item 9 de la ola final: Baganator ya redibuja sus botones con cada cambio de bolsas; solo se le
-- pide refresco cuando cambia NUESTRO veredicto (contexto, Questie, opciones) y solo ItemWidgets.
test('BAG_UPDATE_DELAYED no pide refresco a Baganator; un cambio de contexto si, con ItemWidgets', function()
    local state = installed()
    state.activeJunk = 'knujunk'
    FAKE.Advance(1)
    local base = state.refreshes
    FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(1)
    eq(state.refreshes, base, 'cambio de bolsas: Baganator se arregla solo')
    ns.Bags.RefreshAll(); FAKE.Advance(1)
    eq(state.refreshes, base + 1, 'cambio de contexto')
    ok(type(state.lastReason) == 'table' and #state.lastReason == 1 and state.lastReason[1] == 4,
        'solo RefreshReason.ItemWidgets')
end)

test('una rafaga con BAG_UPDATE_DELAYED y un cambio de contexto si refresca Baganator', function()
    local state = installed()
    state.activeJunk = 'knujunk'
    FAKE.Advance(1)
    local base = state.refreshes
    FAKE.Fire('BAG_UPDATE_DELAYED'); ns.Bags.RefreshAll(); FAKE.Fire('BAG_UPDATE_DELAYED')
    FAKE.Advance(1)
    eq(state.refreshes, base + 1)
end)

test('vistas de Baganator solo por nombres conocidos (sin barrer _G)', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    local unknown = CreateFrame('Frame', 'Baganator_SingleViewBackpackViewFrameskin_desconocido')
    unknown.isLive = true
    ok(not junk(state)(0, 1, 100), 'un nombre fuera de las skins conocidas no habilita la marca')
    local category = CreateFrame('Frame', 'Baganator_CategoryViewBackpackViewFrameelvui')
    category.isLive = true
    FAKE.Advance(5)
    eq(junk(state)(0, 1, 100), true, 'vista de categorias de la skin elvui')
end)

-- Item 11: con el junk plugin de KnuJunk activo, el widget de monedita no dibuja (doble moneda).
test('widget de monedita: false si el junk plugin de KnuJunk esta activo', function()
    local state = installed()
    addItem(100); FAKE.bags['0:1'] = 100
    local _, update = widget(state, 'knujunk_coin')
    state.activeJunk = 'knujunk'
    eq(update({ itemID = 100, itemLocation = location(0, 1) }), false, 'la moneda nativa ya la dibuja Baganator')
    state.activeJunk = 'otro'
    eq(update({ itemID = 100, itemLocation = location(0, 1) }), true, 'otro junk plugin: el widget si')
end)

-- KnuJunk nunca recategoriza en Baganator: su junk plugin solo dice basura donde Baganator tambien lo
-- diria (gris con precio de venta); el resto de las monedas las dibuja nuestra esquina.
local function withResult(result, fn)
    local saved = ns.Classify
    ns.Classify = function() return result end
    local success, err = pcall(fn)
    ns.Classify = saved
    if not success then error(err, 0) end
end

test('la monedita se autoinserta arriba a la izquierda', function()
    local state = installed()
    local position = state.widgets.knujunk_coin.defaultPosition
    ok(position ~= nil, 'la monedita tiene posicion por defecto')
    eq(position.corner, 'top_left'); eq(position.priority, 1)
end)

test('mision terminada: el junk plugin no la manda a Chatarra; la esquina si la marca', function()
    local state = installed()
    addItem(100, { quality = 1, classID = 0 }); FAKE.bags['0:1'] = 100
    backpackView(true)
    local _, update = widget(state, 'knujunk_coin')
    state.activeJunk = 'knujunk'
    withResult({ mark = 'coin', reasons = { { kind = 'quest_done', questID = 5 } } }, function()
        eq(junk(state)(0, 1, 100), false, 'no es basura para Baganator')
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), true, 'esquina con moneda')
    end)
end)

test('gris: el junk plugin si; la esquina no (sin doble moneda)', function()
    local state = installed()
    addItem(100, { quality = 0, price = 5 }); FAKE.bags['0:1'] = 100
    backpackView(true)
    local _, update = widget(state, 'knujunk_coin')
    state.activeJunk = 'knujunk'
    eq(junk(state)(0, 1, 100), true, 'gris con precio = basura de Baganator')
    eq(update({ itemID = 100, itemLocation = location(0, 1) }), false, 'la moneda la pone Baganator')
end)

test('gris sin precio o protegido: ni basura ni moneda', function()
    local state = installed()
    addItem(100, { quality = 0, price = 0 }); FAKE.bags['0:1'] = 100
    backpackView(true)
    state.activeJunk = 'knujunk'
    withResult({ mark = 'coin', reasons = { { kind = 'override_sell' } } }, function()
        eq(junk(state)(0, 1, 100), false, 'sin precio: Baganator no lo llama basura')
    end)
    addItem(101, { quality = 0, price = 5 }); FAKE.bags['0:2'] = 101
    ns.DB.overrides[101] = 'keep'
    eq(junk(state)(0, 2, 101), false, 'override_keep')
    ns.DB.overrides[101] = nil
    withResult({ mark = nil, reasons = { { kind = 'useful' } } }, function()
        eq(junk(state)(0, 2, 101), false, 'item util')
    end)
end)

test('clase que no lo usa: el junk plugin no; la esquina si', function()
    local state = installed()
    addItem(100, { quality = 2, classID = 4, subclassID = 4 }); FAKE.bags['0:1'] = 100
    backpackView(true)
    local _, update = widget(state, 'knujunk_coin')
    state.activeJunk = 'knujunk'
    withResult({ mark = 'coin', reasons = { { kind = 'class_cannot_use', classID = 4, subclassID = 4 } } }, function()
        eq(junk(state)(0, 1, 100), false)
        eq(update({ itemID = 100, itemLocation = location(0, 1) }), true)
    end)
end)
