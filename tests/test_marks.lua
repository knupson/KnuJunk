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

test('martillo propio: verde; ajeno: gris claro; textura propia sin recorte ni desaturado', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    withMark('hammer_mine', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button))
    eq(button.KnuJunkMark.texture, 'Interface\\AddOns\\KnuJunk\\media\\martillo')
    eq(button.KnuJunkMark.vertex[1], (111/255)); eq(button.KnuJunkMark.vertex[2], (211/255)); eq(button.KnuJunkMark.vertex[3], (106/255))
    ok(not button.KnuJunkMark.desaturated)
    eq(button.KnuJunkMark.alpha, 1)
    eq(table.concat(button.KnuJunkMark.texCoord, ','), '0,1,0,1')
    withMark('hammer_other', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button))
    ok(not button.KnuJunkMark.desaturated, 'el martillo ajeno ya no se desatura')
    eq(button.KnuJunkMark.alpha, 1)
    eq(button.KnuJunkMark.vertex[1], 1); eq(button.KnuJunkMark.vertex[2], (154/255)); eq(button.KnuJunkMark.vertex[3], (60/255))
    eq(table.concat(button.KnuJunkMark.texCoord, ','), '0,1,0,1')
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

test('quest se dibuja en bolsas', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    withMark('quest', function() ns.Marks.Update(button, 0, 1) end)
    ok(visible(button)); eq(button.KnuJunkMark.texture,ns.Marks.TEXTURES.quest)
end)

test('UpdateLink dibuja moneda y quest (botin) y guarda el dueno', function()
    addItem(100)
    local button = newButton()
    ns.Marks.UpdateLink(button, FAKE.linkOf(100), 'loot')
    ok(visible(button)); eq(button.KnuJunkOwner, 'loot')
    withMark('quest', function() ns.Marks.UpdateLink(button, FAKE.linkOf(100)) end)
    ok(visible(button), 'quest se dibuja en botin')
    eq(button.KnuJunkMark.texture, 'Interface\\AddOns\\KnuJunk\\media\\quest')
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

test('Update que lanza deja la marca oculta', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local button = newButton()
    ns.Marks.Update(button, 0, 1)
    ok(visible(button), 'parte con moneda')
    local saved = ns.Player.ReadItem
    ns.Player.ReadItem = function() error('lectura rota') end
    local success, err = pcall(ns.Marks.Update, button, 0, 1)
    ns.Player.ReadItem = saved
    ok(success, 'el error no se propaga: ' .. tostring(err))
    ok(not visible(button), 'la marca vieja no sobrevive a la lectura que falla')
    local link = newButton()
    ns.Marks.UpdateLink(link, FAKE.linkOf(100))
    ok(visible(link))
    local savedLink = ns.Player.ReadLink
    ns.Player.ReadLink = function() error('lectura rota') end
    success = pcall(ns.Marks.UpdateLink, link, FAKE.linkOf(100))
    ns.Player.ReadLink = savedLink
    ok(success and not visible(link), 'UpdateLink tambien queda oculto')
end)

test('Verdict: marca del slot, pendiente sin datos y nunca lanza', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local mark, waiting = ns.Marks.Verdict(0, 1, 100)
    eq(mark, 'coin'); eq(waiting, false)
    mark = ns.Marks.Verdict(0, 1, 999)
    eq(mark, nil, 'el slot tiene otro item')
    mark = ns.Marks.Verdict(-1, 1)
    eq(mark, nil, 'fuera de bolsas 0-4')
    FAKE.bags['0:2'] = 200 -- sin datos todavia
    mark, waiting = ns.Marks.Verdict(0, 2, 200)
    eq(mark, nil); eq(waiting, true)
    local saved = ns.Player.ReadItem
    ns.Player.ReadItem = function() error('roto') end
    local success, result = pcall(ns.Marks.Verdict, 0, 1, 100)
    ns.Player.ReadItem = saved
    ok(success and result == nil, 'un error devuelve nil')
end)

-- ---------------------------------------------------------------------------
-- Retomar lo pendiente sin pintar a ciegas, y combate sobre botones protegidos
-- ---------------------------------------------------------------------------

test('dato pendiente: si el slot cambia de item antes de llegar los datos, sin marca', function()
    addItem(200, { quality = 0 })              -- gris: moneda
    FAKE.bags['0:1'] = 200
    local saved = ns.Player.ReadItem
    ns.Player.ReadItem = function() return nil end -- el cliente aun no tiene los datos
    local button = newButton()
    ns.Marks.Update(button, 0, 1, 'generic')
    ns.Player.ReadItem = saved
    addItem(201, { quality = 0 })
    FAKE.bags['0:1'] = 201                     -- el slot cambia a otro gris
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(button), 'el item esperado ya no esta en el slot')
    FAKE.bags['0:1'] = 200
    ns.Player.ReadItem = function() return nil end
    ns.Marks.Update(button, 0, 1, 'generic')
    ns.Player.ReadItem = saved
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(visible(button), 'control: sin cambios se marca')
end)

test('adaptador con revalidate: la vista debe seguir mostrando el mismo item', function()
    addItem(200, { quality = 0 }); addItem(201, { quality = 0 })
    FAKE.bags['0:1'] = 200; FAKE.bags['0:2'] = 200; FAKE.bags['0:3'] = 200
    local view = { bag = 0, slot = 1, shown = 200 }
    ns.Bags.Register('Falso', { install = function() return true end, revalidate = function() return view.bag, view.slot, view.shown end })
    local function pend(button)
        local saved = ns.Player.ReadItem
        ns.Player.ReadItem = function() return nil end
        ns.Marks.Update(button, 0, 1, 'Falso')
        ns.Player.ReadItem = saved
    end
    local one = newButton(); pend(one)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(visible(one), 'control: la vista sigue igual')
    local offline = newButton(); pend(offline)
    view.bag = nil                                 -- la vista dejo de ser una casilla viva (offline/banco)
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(offline), 'vista sin casilla viva: sin marca')
    view.bag = 0
    local bank = newButton(); pend(bank)
    view.bag, view.slot = -1, 4                    -- ahora muestra el banco
    FAKE.bags['-1:4'] = 200
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(bank), 'banco: sin marca')
    view.bag, view.slot = 0, 1
    local other = newButton(); pend(other)
    view.shown = 201                               -- la vista dibuja otro item
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(other), 'la vista muestra otro item: sin marca')
    local boom = newButton(); view.shown = 200; pend(boom)
    ns.Bags.Revalidator('Falso') -- existe
    view.bag = 'roto'
    FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
    ok(not visible(boom), 'lectura invalida: sin marca')
end)

-- Boton protegido: crear la textura en combate falla como en el cliente (lo simulamos con un error).
local function protectedButton()
    local button = CreateFrame('Button')
    function button:IsProtected() return true end
    function button:CreateTexture(...)
        if FAKE.inCombat then error('accion bloqueada: CreateTexture en combate') end
        return CreateFrame('Texture', ...)
    end
    return button
end

test('combate: un boton protegido sin textura nuestra no se toca; se marca al salir revalidando', function()
    addItem(100, { quality = 0 }); FAKE.bags['0:1'] = 100
    local button = protectedButton()
    FAKE.inCombat = true
    ns.Marks.Update(button, 0, 1, 'generic')
    ok(button.KnuJunkMark == nil, 'no se creo la textura en combate')
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    ok(visible(button), 'marcado al salir del combate')
end)

test('combate: lo diferido se revalida (el slot cambio) y UpdateLink tambien se difiere', function()
    addItem(100, { quality = 0 }); addItem(101, { quality = 1, classID = 2, subclassID = 0, spell = true })
    FAKE.bags['0:1'] = 100
    local button = protectedButton()
    FAKE.inCombat = true
    ns.Marks.Update(button, 0, 1, 'generic')
    FAKE.bags['0:1'] = 101                      -- cambia durante el combate
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    ok(not visible(button), 'el item ya no es el que se difirio')
    local loot = protectedButton()
    FAKE.inCombat = true
    ns.Marks.UpdateLink(loot, FAKE.linkOf(100), 'loot')
    ok(loot.KnuJunkMark == nil, 'botin: sin textura en combate')
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    ok(visible(loot), 'botin marcado al salir')
end)

test('combate: una textura nuestra ya creada si se actualiza; botones sin proteger tambien', function()
    addItem(100, { quality = 0 }); FAKE.bags['0:1'] = 100
    local button = protectedButton()
    ns.Marks.Update(button, 0, 1, 'generic')    -- fuera de combate: se crea
    ok(visible(button))
    FAKE.inCombat = true
    ns.Marks.Update(button, 0, 2, 'generic')    -- slot vacio: se oculta sin crear nada
    ok(not visible(button), 'actualiza la textura existente')
    ns.Marks.Update(button, 0, 1, 'generic')
    ok(visible(button), 'y la vuelve a mostrar')
    local plain = newButton()
    ns.Marks.Update(plain, 0, 1, 'generic')
    ok(visible(plain), 'boton no protegido: se marca en combate')
    local failing = newButton()
    function failing:IsProtected() error('roto') end
    ns.Marks.Update(failing, 0, 1, 'generic')
    ok(failing.KnuJunkMark == nil, 'IsProtected que falla cuenta como protegido')
    FAKE.inCombat = false
end)

test('combate: Clear olvida lo diferido', function()
    addItem(100, { quality = 0 }); FAKE.bags['0:1'] = 100
    local button = protectedButton()
    FAKE.inCombat = true
    ns.Marks.Update(button, 0, 1, 'generic')
    ns.Marks.Clear(button)
    FAKE.inCombat = false
    FAKE.Fire('PLAYER_REGEN_ENABLED')
    ok(not visible(button))
end)

-- Reactivo/herramienta util para una mision (quest = true): bolsas -> martillo, botin -> mision.
test('martillo con quest = true: martillo en bolsas, signo de mision en el botin', function()
    addItem(100); FAKE.bags['0:1'] = 100
    local saved = ns.Classify
    ns.Classify = function() return { mark = 'hammer_other', quest = true, reasons = {} } end
    local success, err = pcall(function()
        local bag = newButton()
        ns.Marks.Update(bag, 0, 1)
        ok(visible(bag), 'martillo en bolsas')
        eq(bag.KnuJunkMark.texture, 'Interface\\AddOns\\KnuJunk\\media\\quest')
        eq(ns.Marks.Verdict(0, 1, 100), 'quest')
        local loot = newButton()
        ns.Marks.UpdateLink(loot, FAKE.linkOf(100), 'loot')
        ok(visible(loot), 'mision en botin')
        eq(loot.KnuJunkMark.texture, 'Interface\\AddOns\\KnuJunk\\media\\quest')
    end)
    ns.Classify = saved
    if not success then error(err, 0) end
end)

test('moneda: atlas de basura de Blizzard (bags-junkcoin) si el cliente lo tiene', function()
    local saved = C_Texture
    C_Texture = { GetAtlasInfo = function(name) if name == 'bags-junkcoin' then return { width = 16 } end end }
    local ok2, err = pcall(function()
        local button = CreateFrame('Button', nil, UIParent)
        local texture = button:CreateTexture()
        ns.Marks.Style(texture, 'coin')
        eq(texture.atlas, 'bags-junkcoin')
    end)
    C_Texture = saved
    if not ok2 then error(err, 0) end
end)
