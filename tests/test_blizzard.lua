-- Bolsas de Blizzard: enganche a ContainerFrame_Update (clasico) y a UpdateItems (moderno).
local function addItem(id, fields)
    local base = { name = 'Item' .. id, quality = 0, price = 10, classID = 15, subclassID = 0 }
    for key, value in pairs(fields or {}) do base[key] = value end
    FAKE.items[id] = base
end

-- Prepara globales falsos, corre fn y los restaura aunque falle.
local function withGlobals(names, fn)
    local saved = {}
    for _, name in ipairs(names) do saved[name] = _G[name] end
    local success, err = pcall(fn)
    for _, name in ipairs(names) do _G[name] = saved[name] end
    if not success then error(err, 0) end
end

local function spyUpdate(fn)
    local calls, saved = {}, ns.Marks.Update
    ns.Marks.Update = function(button, bag, slot, owner) calls[#calls + 1] = { button = button, bag = bag, slot = slot, owner = owner } end
    local success, err = pcall(fn, calls)
    ns.Marks.Update = saved
    if not success then error(err, 0) end
end

local function installed()
    local set = {}
    for _, name in ipairs(ns.Bags.Installed()) do set[name] = true end
    return set
end

local function classicFrame(name, bag, slots)
    local frame = CreateFrame('Frame', name)
    frame.id, frame.size = bag, #slots
    local buttons = {}
    for index, slot in ipairs(slots) do
        local button = CreateFrame('Button', name .. 'Item' .. index, frame)
        button.id = slot
        buttons[index] = button
    end
    return frame, buttons
end

local function modernFrame(name, buttons)
    local frame = CreateFrame('Frame', name)
    frame.updated = 0
    function frame:UpdateItems() self.updated = self.updated + 1 end
    function frame:EnumerateValidItems()
        local index = 0
        return function() index = index + 1; if buttons[index] then return index, buttons[index] end end
    end
    return frame
end

local function modernButton(bag, slot)
    local button = CreateFrame('Button')
    button.id = slot
    function button:GetBagID() return bag end
    return button
end

test('Blizzard: sin ninguna API de bolsas no se instala y se reintenta despues', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrameCombinedBags', 'ContainerFrame1' }, function()
        ContainerFrame_Update, ContainerFrameCombinedBags, ContainerFrame1 = nil, nil, nil
        ns.Bags.InstallAll()
        ok(not installed().Blizzard, 'nada que enganchar')
        ContainerFrame_Update = function() end
        FAKE.Fire('ADDON_LOADED', 'Otro')
        ok(installed().Blizzard, 'se instala cuando aparece la API')
    end)
end)

test('Blizzard clasico: ContainerFrame_Update llama Update con bag/slot del boton', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrame1', 'ContainerFrame1Item1', 'ContainerFrame1Item2' }, function()
        local frame, buttons = classicFrame('ContainerFrame1', 2, { 7, 6 })
        ContainerFrame_Update = function() end
        ns.Bags.InstallAll()
        ok(installed().Blizzard, 'hook instalado')
        spyUpdate(function(calls)
            ContainerFrame_Update(frame)
            eq(#calls, 2)
            eq(calls[1].button, buttons[1]); eq(calls[1].bag, 2); eq(calls[1].slot, 7); eq(calls[1].owner, 'blizzard')
            eq(calls[2].button, buttons[2]); eq(calls[2].bag, 2); eq(calls[2].slot, 6)
        end)
    end)
end)

test('Blizzard clasico: pinta de verdad la moneda en el boton', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrame1', 'ContainerFrame1Item1' }, function()
        local frame, buttons = classicFrame('ContainerFrame1', 1, { 3 })
        addItem(100); FAKE.bags['1:3'] = 100
        ContainerFrame_Update = function() end
        ns.Bags.InstallAll()
        ContainerFrame_Update(frame)
        ok(buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown(), 'moneda en la bolsa 1')
        eq(buttons[1].KnuJunkOwner, 'blizzard')
    end)
end)

test('Blizzard moderno: UpdateItems del frame llama Update con GetBagID y GetID', function()
    withGlobals({ 'ContainerFrameCombinedBags', 'ContainerFrame2' }, function()
        local combined = { modernButton(0, 4), modernButton(3, 9) }
        local frame = modernFrame('ContainerFrameCombinedBags', combined)
        ContainerFrameCombinedBags = frame
        ns.Bags.InstallAll()
        ok(installed().Blizzard)
        spyUpdate(function(calls)
            frame:UpdateItems()
            eq(frame.updated, 1, 'la funcion original sigue corriendo')
            eq(#calls, 2)
            eq(calls[1].button, combined[1]); eq(calls[1].bag, 0); eq(calls[1].slot, 4); eq(calls[1].owner, 'blizzard')
            eq(calls[2].bag, 3); eq(calls[2].slot, 9)
        end)
    end)
end)

test('Blizzard moderno: ContainerFrameN individuales y frame.Items sin iterador', function()
    withGlobals({ 'ContainerFrame1', 'ContainerFrame3' }, function()
        local first = modernFrame('ContainerFrame1', { modernButton(1, 2) })
        ContainerFrame1 = first
        local third = CreateFrame('Frame', 'ContainerFrame3')
        third.UpdateItems = function() end
        third.Items = { modernButton(3, 5) }
        ContainerFrame3 = third
        ns.Bags.InstallAll()
        spyUpdate(function(calls)
            first:UpdateItems(); third:UpdateItems()
            eq(#calls, 2)
            eq(calls[1].bag, 1); eq(calls[1].slot, 2)
            eq(calls[2].bag, 3); eq(calls[2].slot, 5)
        end)
    end)
end)

test('Blizzard: boton oculto (reciclado sin usar) se limpia, no se marca', function()
    withGlobals({ 'ContainerFrame1' }, function()
        local hidden = modernButton(0, 1)
        hidden:Hide()
        local frame = modernFrame('ContainerFrame1', { hidden })
        ContainerFrame1 = frame
        addItem(100); FAKE.bags['0:1'] = 100
        ns.Bags.InstallAll()
        frame:UpdateItems()
        ok(not (hidden.KnuJunkMark and hidden.KnuJunkMark:IsShown()), 'oculto sin marca')
    end)
end)

test('Blizzard: un error dentro de Update no rompe el redibujado de Blizzard', function()
    withGlobals({ 'ContainerFrame1' }, function()
        local frame = modernFrame('ContainerFrame1', { modernButton(0, 1) })
        ContainerFrame1 = frame
        ns.Bags.InstallAll()
        spyUpdate(function()
            ns.Marks.Update = function() error('roto') end
            local success = pcall(frame.UpdateItems, frame)
            ok(success, 'el hook captura el error')
        end)
    end)
end)

test('Blizzard: un frame no se engancha dos veces', function()
    withGlobals({ 'ContainerFrame1' }, function()
        local frame = modernFrame('ContainerFrame1', { modernButton(0, 1) })
        ContainerFrame1 = frame
        ns.Bags.InstallAll()
        ns.Blizzard.Hook() -- reintento manual: no duplica
        spyUpdate(function(calls)
            frame:UpdateItems()
            eq(#calls, 1)
        end)
    end)
end)

test('Blizzard: el refresco agrupado repinta los frames visibles', function()
    withGlobals({ 'ContainerFrame1' }, function()
        local button = modernButton(0, 1)
        local frame = modernFrame('ContainerFrame1', { button })
        ContainerFrame1 = frame
        addItem(100); FAKE.bags['0:1'] = 100
        ns.Bags.InstallAll()
        ok(not (button.KnuJunkMark and button.KnuJunkMark:IsShown()))
        FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(0.2)
        ok(button.KnuJunkMark and button.KnuJunkMark:IsShown(), 'repintado sin llamar a UpdateItems')
        eq(frame.updated, 0, 'no se llama a funciones de Blizzard')
    end)
end)

test('Blizzard: un frame que nace despues se engancha en el siguiente refresco', function()
    withGlobals({ 'ContainerFrame1', 'ContainerFrame2' }, function()
        ContainerFrame1 = modernFrame('ContainerFrame1', {})
        ns.Bags.InstallAll()
        local late = modernFrame('ContainerFrame2', { modernButton(0, 1) })
        ContainerFrame2 = late
        FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(0.2)
        spyUpdate(function(calls)
            late:UpdateItems()
            eq(#calls, 1)
        end)
    end)
end)

test('Blizzard: un boton que falla no impide marcar los demas', function()
    withGlobals({ 'ContainerFrame1' }, function()
        local broken = modernButton(0, 1)
        function broken:GetID() error('boton roto') end
        local good = modernButton(0, 2)
        local frame = modernFrame('ContainerFrame1', { broken, good })
        ContainerFrame1 = frame
        addItem(100); FAKE.bags['0:2'] = 100
        ns.Bags.InstallAll()
        frame:UpdateItems()
        ok(good.KnuJunkMark and good.KnuJunkMark:IsShown(), 'el boton sano se marca')
        ok(not (broken.KnuJunkMark and broken.KnuJunkMark:IsShown()), 'el roto queda sin marca')
    end)
end)

-- Item 4 de la ola final: al retomar una marca pendiente (datos o combate) se revalida lo que
-- el boton muestra AHORA: bolsa del frame actual (0-4), slot actual, visible, y el item vivo.
test('Blizzard: boton que paso al banco mientras esperaba datos -> sin moneda', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrame1', 'ContainerFrame1Item1' }, function()
        local frame, buttons = classicFrame('ContainerFrame1', 0, { 1 })
        FAKE.bags['0:1'] = 200 -- sin datos todavia
        ContainerFrame_Update = function() end
        ns.Bags.InstallAll()
        ContainerFrame_Update(frame)
        ok(not (buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown()), 'sin datos: sin marca')
        -- El cliente recicla el frame para el banco y el boton para otro slot, sin redibujar aun.
        frame.id = -1; buttons[1].id = 2
        addItem(200)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
        ok(not (buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown()), 'boton del banco sin moneda')
    end)
end)

test('Blizzard: boton oculto u otro slot al retomar -> sin moneda; mismo boton vivo -> moneda', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrame1', 'ContainerFrame1Item1' }, function()
        local frame, buttons = classicFrame('ContainerFrame1', 0, { 1 })
        FAKE.bags['0:1'] = 200
        ContainerFrame_Update = function() end
        ns.Bags.InstallAll()
        ContainerFrame_Update(frame)
        -- Mismo bolsa, otro slot con otro item: no se marca.
        buttons[1].id = 3; FAKE.bags['0:3'] = 201; addItem(201)
        addItem(200)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
        ok(not (buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown()), 'otro slot')
        -- Boton oculto.
        buttons[1].id = 1; FAKE.items[200] = nil
        ContainerFrame_Update(frame)
        buttons[1]:Hide()
        addItem(200)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
        ok(not (buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown()), 'oculto')
        -- Visible, mismo slot y mismo item: si.
        buttons[1]:Show(); FAKE.items[200] = nil
        ContainerFrame_Update(frame)
        addItem(200)
        FAKE.Fire('GET_ITEM_INFO_RECEIVED', 200, true)
        ok(buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown(), 'vivo: moneda')
    end)
end)

test('Blizzard: cola de combate revalida bolsa actual del boton', function()
    withGlobals({ 'ContainerFrame_Update', 'ContainerFrame1', 'ContainerFrame1Item1' }, function()
        local frame, buttons = classicFrame('ContainerFrame1', 0, { 1 })
        buttons[1].IsProtected = function() return true end
        addItem(200); FAKE.bags['0:1'] = 200
        ContainerFrame_Update = function() end
        ns.Bags.InstallAll()
        FAKE.inCombat = true
        ContainerFrame_Update(frame)
        ok(buttons[1].KnuJunkMark == nil, 'diferido en combate')
        frame.id = -1 -- el frame pasa a mostrar el banco
        FAKE.inCombat = false
        FAKE.Fire('PLAYER_REGEN_ENABLED')
        ok(not (buttons[1].KnuJunkMark and buttons[1].KnuJunkMark:IsShown()), 'banco: sin moneda')
    end)
end)
