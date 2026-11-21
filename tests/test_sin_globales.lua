-- Cliente de WoW Forever sin GearQuest: GetItemInfo y compañía sólo existen en C_Item
-- (GearQuest crea las globales; apagado, no están). Las marcas no pueden desaparecer.
local NAMES = { 'GetItemInfo', 'GetItemInfoInstant', 'GetItemSpell', 'GetItemCount' }

local function onlyCItem()
    local saved = {}
    for _, name in ipairs(NAMES) do
        saved[name] = rawget(_G, name)
        C_Item[name] = saved[name] or function() return 0 end
        _G[name] = nil
    end
    return function() for _, name in ipairs(NAMES) do _G[name] = saved[name] end end
end

test('sin globales de ítem: se leen por C_Item y el gris lleva moneda', function()
    local restore = onlyCItem()
    local good, err = pcall(function()
        FAKE.items[991700] = { name = 'Hacha de guerra de piedra', quality = 0, price = 1609, classID = 2, subclassID = 1,
            equipLoc = 'INVTYPE_2HWEAPON', itemLevel = 27 }
        FAKE.bags['0:1'] = 991700
        ns.Player.Invalidate()
        local item = ns.Player.ReadLink('item:991700')
        ok(item, 'ReadLink lee el ítem'); eq(item.quality, 0); eq(item.itemLevel, 27)
        eq(ns.Marks.Verdict(0, 1, 991700), 'coin')
    end)
    restore()
    if not good then error(err, 0) end
end)

test('sin globales de ítem: la global, si existe, gana sobre C_Item', function()
    local saved = rawget(_G, 'GetItemCount')
    C_Item.GetItemCount = function() return 9 end
    GetItemCount = function() return 2 end
    eq(ns.API.GetItemCount(1), 2)
    GetItemCount = nil
    eq(ns.API.GetItemCount(1), 9)
    GetItemCount, C_Item.GetItemCount = saved, nil
end)

test('sin GearQuest: rama sin puntos en GetTalentTabInfo suma GetTalentInfo', function()
    GearQuest = nil
    GetNumTalentTabs = function() return 3 end
    GetTalentTabInfo = function(tab) return tab, ({ 'Sagrado', 'Protección', 'Reprensión' })[tab], 'desc', 'icon', 0 end
    GetNumTalents = function() return 2 end
    GetTalentInfo = function(tab, index) return 't', 'icon', 1, index, tab == 3 and 5 or 0, 5 end
    ns.Player.Invalidate()
    eq(ns.Player.GetContext().specLabel, 'Reprensión'); eq(ns.Player.GetContext().specSource, 'talents')
    GetNumTalentTabs, GetTalentTabInfo, GetNumTalents, GetTalentInfo = nil, nil, nil, nil
end)

test('sin GearQuest: al entrar al mundo se vuelve a leer la especialización', function()
    GearQuest = nil
    GetNumTalentTabs = function() return 3 end
    local points = 0
    GetTalentTabInfo = function(tab) return ({ 'Sagrado', 'Protección', 'Reprensión' })[tab], 'icon', tab == 3 and points or 0 end
    ns.Player.Invalidate()
    eq(ns.Player.GetContext().specLabel, nil)
    points = 19
    FAKE.Fire('PLAYER_ENTERING_WORLD')
    eq(ns.Player.GetContext().specLabel, 'Reprensión')
    GetNumTalentTabs, GetTalentTabInfo = nil, nil
end)

test('debug: muestra la lectura cruda de cada rama de talentos', function()
    FAKE.items[991701] = { name = 'Hacha', quality = 0, price = 10, classID = 2 }
    GetNumTalentTabs = function() return 1 end
    GetTalentTabInfo = function() return 'Reprensión', 'icon', 19 end
    local text = table.concat(ns.Player.DebugTooltip('item:991701'), '\n')
    ok(text:find('GetTalentTabInfo(1)=Reprensión, icon, 19', 1, true), text)
    ok(text:find('-> Reprensión 19', 1, true), 'resultado')
    GetNumTalentTabs, GetTalentTabInfo = nil, nil
end)

-- Cliente de Forever: sin GetNumTalentTabs; las ramas salen de C_Traits (como la ventana de talentos).
local function traits(spent)
    C_ClassTalents = { GetActiveConfigID = function() return 77 end }
    C_Traits = {
        GetConfigInfo = function(config) eq(config, 77); return { treeIDs = { 5 } } end,
        GetGroupDisplayInfoByTreeID = function(tree) eq(tree, 5); return { { groupID = 11 }, { groupID = 12 }, { groupID = 13 } } end,
        GetGroupCurrencyInfo = function(config, ids)
            local out = {}
            for i, id in ipairs(ids) do out[i] = { traitNodeGroupID = id, currencyInfos = { { spent = spent[i] } } } end
            return out
        end,
    }
end
local function clearTraits() C_ClassTalents, C_Traits, PawnCommon, PawnGetSpecializationInfoForClassID = nil, nil, nil, nil end

test('sin GearQuest ni GetNumTalentTabs: C_Traits da la rama con más puntos', function()
    GearQuest, GetNumTalentTabs = nil, nil
    traits({ 0, 2, 19 }); ns.Player.Invalidate()
    local c = ns.Player.GetContext()
    eq(c.specIndex, 3); eq(c.specSource, 'talents'); eq(c.specLabel, nil)
    PawnGetSpecializationInfoForClassID = function(classID, index) return index, ({ 'Sagrado', 'Protección', 'Reprensión' })[index] end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specLabel, 'Reprensión')
    traits({ 10, 10, 0 }); ns.Player.Invalidate(); eq(ns.Player.GetContext().specIndex, nil)
    traits({ 0, 0, 0 }); ns.Player.Invalidate(); eq(ns.Player.GetContext().specIndex, nil)
    C_Traits.GetGroupCurrencyInfo = function() error('sin datos') end
    ns.Player.Invalidate(); eq(ns.Player.GetContext().specIndex, nil)
    clearTraits()
end)

test('sin nombre de rama: Pawn coincide por SpecID y sólo cuenta la escala de tu rama', function()
    GearQuest, GetNumTalentTabs = nil, nil
    FAKE.class = 'PALADIN'
    local savedUnitClass = UnitClass
    UnitClass = function() return 'Paladín', 'PALADIN', 2 end
    traits({ 0, 2, 19 }); ns.Player.Invalidate()
    PawnCommon = { Scales = { prot = { ClassID = 2, SpecID = 2 }, ret = { ClassID = 2, SpecID = 3 }, holy = { ClassID = 2, SpecID = 1 } } }
    PawnGetAllScalesEx = function()
        return { { Name = 'prot', LocalizedName = 'Paladín: Protección', IsVisible = true },
            { Name = 'ret', LocalizedName = 'Paladín: Reprensión', IsVisible = true },
            { Name = 'holy', LocalizedName = 'Paladín: Sagrado', IsVisible = true } }
    end
    local visible, matches, count = ns.PawnScales(ns.Player.GetContext())
    eq(count, 1); ok(matches.ret, 'Reprensión'); ok(not matches.prot, 'no Protección'); eq(#visible, 3)
    UnitClass, PawnGetAllScalesEx = savedUnitClass, nil
    clearTraits()
end)

test('debug: muestra lo que lee C_Traits', function()
    FAKE.items[991702] = { name = 'Hacha', quality = 0, price = 10, classID = 2 }
    GetNumTalentTabs = nil
    traits({ 0, 2, 19 }); ns.Player.Invalidate()
    local text = table.concat(ns.Player.DebugTooltip('item:991702'), '\n')
    ok(text:find('C_Traits: rama=3 nombre=nil puntos=1=0 2=2 3=19', 1, true), text)
    ok(text:find('specIndex=3', 1, true), 'specIndex')
    clearTraits()
end)

test('reactivo de otra clase: el tooltip dice que se vende (esES y enUS)', function()
    local savedL = ns.L
    local good, err = pcall(function()
        FAKE.items[17058] = { name = 'Aceite de pescado', quality = 1, price = 42, classID = 7, subclassID = 11 }
        FAKE.class = 'PALADIN'
        for _, locale in ipairs({ 'esES', 'enUS' }) do
            FAKE.locale = locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            ns.Player.Invalidate()
            local text = {}
            for _, line in ipairs(ns.Tooltip.Lines(FAKE.linkOf(17058))) do text[#text + 1] = line.text end
            local expected = locale == 'enUS' and ' reagent: not your class, sold' or ': no es de tu clase, se vende'
            ok(table.concat(text, '\n'):find(expected, 1, true), table.concat(text, '\n'))
        end
        FAKE.class = 'SHAMAN'; ns.Player.Invalidate()
        local text = {}
        for _, line in ipairs(ns.Tooltip.Lines(FAKE.linkOf(17058))) do text[#text + 1] = line.text end
        ok(not table.concat(text, '\n'):find('se vende', 1, true) and not table.concat(text, '\n'):find('sold', 1, true), 'chamán lo guarda')
    end)
    ns.L, FAKE.locale = savedL, nil
    if not good then error(err, 0) end
end)
