local function reason(r, kind)
    for _, v in ipairs(r.reasons) do if v.kind == kind then return v end end
end
local function context(rule)
    return {level=40, class='MAGE', professions={}, rules={[rule]=true},
        bagStock={{id=117, usable=true}, {id=4540, usable=true},
            {id=2512, usable=true, bag=0, slot=1}, {id=2515, usable=true, bag=0, slot=2}}}
end
local function food() return {id=117,quality=1,price=5,classID=0,subclassID=5,effect='no',bag=0,slot=1} end
local function ammo() return {id=2512,quality=1,price=5,classID=6,subclassID=2,effect='no',bag=0,slot=1} end
local function recipe() return {id=2406,quality=1,price=5,classID=9,effect='no',knownRecipe=true,isBound=true} end

test('Tanda4: defaults y migración conservan preferencias', function()
    for _,k in ipairs({'food','ammo','knownRecipe'}) do eq(ns.Defaults.rules[k],true); eq(ns.DB.rules[k],true) end
    -- Instalación vieja (sin rulesVersion) con las reglas guardadas apagadas: se prenden una vez.
    KnuJunkDB={rules={food=false,ammo=false,knownRecipe=false},show={coin=false}}
    FAKE.Fire('ADDON_LOADED','KnuJunk')
    eq(ns.DB.rules.food,true); eq(ns.DB.rules.ammo,true); eq(ns.DB.rules.knownRecipe,true); eq(ns.DB.show.coin,false)
    eq(ns.DB.rulesVersion,2)
    -- Ya migrada: lo que apagó el jugador se respeta.
    KnuJunkDB={rulesVersion=2,rules={food=false}}
    FAKE.Fire('ADDON_LOADED','KnuJunk')
    eq(ns.DB.rules.food,false); eq(ns.DB.rules.ammo,true)
end)

local function inventory()
    FAKE.knownLine=nil
    FAKE.items[117]={name='Food',quality=1,price=5,classID=0,subclassID=5}
    FAKE.items[4541]={name='Better food',quality=1,price=5,classID=0,subclassID=5}
    FAKE.items[2406]={name='Recipe',quality=1,price=5,classID=9,subclassID=1}
    FAKE.items[2512]={name='Arrow',quality=1,price=5,classID=6,subclassID=2}
    FAKE.items[2515]={name='Better arrow',quality=1,price=5,classID=6,subclassID=2}
    FAKE.bags['0:1']=117; FAKE.bags['0:2']=4541; FAKE.bags['0:3']=2406
    FAKE.bags['0:4']=2512; FAKE.bags['0:5']=2515
    C_Container.GetContainerNumSlots=function(bag) return bag==0 and 5 or 0 end
    GetInventoryItemID=function() return nil end
    UnitLevel=function() return 40 end
    C_TooltipInfo.GetBagItem=function(bag,slot)
        local id=FAKE.bags[bag..':'..slot]
        if id~=2406 then return nil end
        return {lines={{leftText='Recipe'},{leftText=FAKE.knownLine or 'Already known'}}}
    end
end

test('Tanda4: eventos opcionales OFF no reconstruyen el contexto', function()
    local real=UnitClass
    local builds=0
    UnitClass=function(...) builds=builds+1; return real(...) end
    local saved={food=ns.DB.rules.food,ammo=ns.DB.rules.ammo,knownRecipe=ns.DB.rules.knownRecipe}
    ns.DB.rules.food,ns.DB.rules.ammo,ns.DB.rules.knownRecipe=false,false,false
    ns.Player.Invalidate()
    local good,err=pcall(function()
        ns.Player.GetContext(); eq(builds,1)
        for _,event in ipairs({'BAG_UPDATE_DELAYED','SPELLS_CHANGED','LEARNED_SPELL_IN_TAB',
            'PLAYER_EQUIPMENT_CHANGED','UNIT_INVENTORY_CHANGED','TOOLTIP_DATA_UPDATE','GET_ITEM_INFO_RECEIVED'}) do
            FAKE.Fire(event,'player'); FAKE.Advance(0.25); ns.Player.GetContext()
            eq(builds,1,event)
        end
        ns.DB.rules.food=true; ns.Player.Invalidate(); ns.Player.GetContext()
        local before=builds
        FAKE.Fire('UNIT_INVENTORY_CHANGED','pet'); FAKE.Advance(0.25); ns.Player.GetContext()
        eq(builds,before)
        FAKE.Fire('UNIT_INVENTORY_CHANGED','player'); FAKE.Advance(0.25); ns.Player.GetContext()
        eq(builds,before+1)
    end)
    UnitClass=real
    for k,v in pairs(saved) do ns.DB.rules[k]=v end
    if not good then error(err,0) end
end)

test('Tanda4: cada opción habilita los cinco eventos opcionales', function()
    for _,rule in ipairs({'food','ammo','knownRecipe'}) do
        ns.DB.rules={[rule]=true}; ns.Player.Invalidate()
        for _,event in ipairs({'BAG_UPDATE_DELAYED','SPELLS_CHANGED','LEARNED_SPELL_IN_TAB',
            'PLAYER_EQUIPMENT_CHANGED','UNIT_INVENTORY_CHANGED'}) do
            local before=ns.Player.GetContext()
            FAKE.Fire(event,'player'); FAKE.Advance(0.25)
            ok(ns.Player.GetContext()~=before,rule..' '..event)
        end
    end
end)

for _,event in ipairs({'TOOLTIP_DATA_UPDATE','GET_ITEM_INFO_RECEIVED'}) do
    test('Tanda4: '..event..' llega durante el escaneo', function()
        FAKE.items[990001]={name='Pendiente',quality=1,price=1,classID=0}
        local ready=false
        C_TooltipInfo.GetHyperlink=function()
            return {dataInstanceID=990001,lines={{leftText='Pendiente'}, {leftText=ready and 'Uso: efecto' or nil}}}
        end
        eq(ns.Player.ReadLink(990001).effect,'unknown')
        FAKE.questLog={{title='Zona',isHeader=true,isCollapsed=true}, {title='Misión',questID=7}}
        local expand=C_QuestLog.ExpandQuestHeader
        C_QuestLog.ExpandQuestHeader=function(...)
            ready=true; FAKE.Fire(event,990001); return expand(...)
        end
        ns.Player.GetContext(); FAKE.Advance(0.01)
        eq(ns.Player.ReadLink(990001).effect,'yes')
    end)
end

test('R9: cazadores conservan comida y bebida para sus mascotas', function()
    local i,c=food(),context('food'); c.class='HUNTER'
    c.bagStock={{id=4541,usable=true}}
    eq(ns.Classify(i,c).mark,'useful')
    i.id=5350; c.bagStock={{id=1205,usable=true}}
    eq(ns.Classify(i,c).mark,'useful')
end)

test('R9: sólo ejemplares en bolsas 0 a 4', function()
    local i,c=food(),context('food'); c.bagStock={{id=4541,usable=true}}
    for _,bag in ipairs({0,4}) do i.bag=bag; eq(ns.Classify(i,c).mark,'coin') end
    for _,bag in ipairs({-1,5}) do i.bag=bag; eq(ns.Classify(i,c).mark,'useful') end
    i.bag=nil; eq(ns.Classify(i,c).mark,'useful')
    i.bag=0; i.slot=nil; eq(ns.Classify(i,c).mark,'useful')
end)

test('R12/13: hechizo de enseñar permite moneda y conserva R14 sin condiciones', function()
    local level,inv,spell=UnitLevel,GetInventoryItemID,GetItemSpell
    local good,err=pcall(function()
        inventory(); ns.DB.rules.knownRecipe=true; FAKE.bound['0:3']=true
        GetItemSpell=function() return 'Teaches: Recipe',1234 end
        local i=ns.Player.ReadItem(0,3); eq(i.effect,'yes'); eq(i.knownRecipe,true)
        local c=context('knownRecipe')
        local r=ns.Classify(i,c); eq(r.mark,'coin'); eq(reason(r,'recipe'),nil)
        i.isBound=false; eq(ns.Classify(i,c).mark,'useful')
        i.isBound=true; i.price=0; eq(ns.Classify(i,c).mark,'trash')
        i.price=5; i.effect='unknown'; eq(ns.Classify(i,c).mark,'hammer_other')
        i.effect='yes'; c.questLogIncomplete=true
        r=ns.Classify(i,c); eq(r.mark,'hammer_other'); ok(reason(r,'recipe'))
        c.questLogIncomplete=nil; i.isSetPiece=true; eq(ns.Classify(i,c).mark,'hammer_other')
        c.professions[ns.Data.recipes[i.id].skillLine]=true
        eq(ns.Classify(i,c).mark,'hammer_mine')
        i.isSetPiece=nil; i.knownRecipe=nil; eq(ns.Classify(i,c).mark,'hammer_mine')
        i.knownRecipe=true; c.rules={}; eq(ns.Classify(i,c).mark,'hammer_mine')
    end)
    UnitLevel,GetInventoryItemID,GetItemSpell=level,inv,spell
    if not good then error(err,0) end
end)

test('R12/13: conocimiento por bolsa, global localizada, caché y evento de aprendizaje', function()
    local level,inv,global=UnitLevel,GetInventoryItemID,ITEM_SPELL_KNOWN
    local good,err=pcall(function()
        inventory(); ns.DB.rules.knownRecipe=true; FAKE.bound['0:3']=true
        for _,line in ipairs({'Already known','Ya conocido','Traducción del cliente'}) do
            ITEM_SPELL_KNOWN='Traducción del cliente'; FAKE.knownLine=line; ns.Player.Invalidate()
            local i=ns.Player.ReadItem(0,3); eq(i.knownRecipe,true); eq(i.isBound,true)
            eq(ns.Classify(i,ns.Player.GetContext()).mark,'coin')
            eq(ns.Player.ReadLink(2406).knownRecipe,nil)
        end
        FAKE.knownLine='Requires Leatherworking'; ns.Player.Invalidate()
        eq(ns.Player.ReadItem(0,3).knownRecipe,nil)
        FAKE.knownLine='Already known'; eq(ns.Player.ReadItem(0,3).knownRecipe,nil)
        FAKE.Fire('SPELLS_CHANGED'); FAKE.Advance(0.25)
        eq(ns.Player.ReadItem(0,3).knownRecipe,true)
        C_TooltipInfo.GetBagItem=nil; ns.Player.Invalidate()
        eq(ns.Player.ReadItem(0,3).knownRecipe,nil)
    end)
    UnitLevel,GetInventoryItemID,ITEM_SPELL_KNOWN=level,inv,global
    if not good then error(err,0) end
end)

test('R9/R16: bolsas reales, banco excluido y refresco al sacar alternativa', function()
    local level,inv=UnitLevel,GetInventoryItemID
    local good,err=pcall(function()
        inventory(); ns.DB.rules.food=true; ns.DB.rules.ammo=true
        FAKE.bags['5:1']=4541
        local c=ns.Player.GetContext(); eq(#c.bagStock,4)
        eq(ns.Classify(ns.Player.ReadItem(0,1),c).mark,'coin')
        eq(ns.Classify(ns.Player.ReadItem(0,4),c).mark,'coin')
        FAKE.bags['0:2']=nil; FAKE.bags['0:5']=nil
        FAKE.Fire('BAG_UPDATE_DELAYED'); FAKE.Advance(0.25)
        c=ns.Player.GetContext()
        eq(ns.Classify(ns.Player.ReadItem(0,1),c).mark,'useful')
        eq(ns.Classify(ns.Player.ReadItem(0,4),c).mark,'useful')
    end)
    UnitLevel,GetInventoryItemID=level,inv
    if not good then error(err,0) end
end)

test('Tanda4: eco del diario no notifica cambios con opcionales habilitadas', function()
    local level,inv=UnitLevel,GetInventoryItemID
    local good,err=pcall(function()
        inventory(); ns.DB.rules.food=true; ns.Player.GetContext()
        local changed=0; ns.Player.OnChanged(function() changed=changed+1 end)
        FAKE.Fire('QUEST_LOG_UPDATE'); FAKE.Advance(1)
        eq(changed,0)
    end)
    UnitLevel,GetInventoryItemID=level,inv
    if not good then error(err,0) end
end)

test('R9: sólo exceptúa restauración acreditada, cachea y conserva efectos extra', function()
    local spell,level,inv,modern=GetItemSpell,UnitLevel,GetInventoryItemID,C_Item
    local good,err=pcall(function()
        inventory(); ns.DB.rules.food=true
        GetItemSpell=function(id) return 'Food', id==117 and 433 or 434 end
        FAKE.items[117].tooltip={'Use: Restores health.'}
        local i=ns.Player.ReadItem(0,1); eq(i.effect,'yes'); eq(i.restorationOnly,true)
        local before=FAKE.tooltipCalls; ns.Player.ReadItem(0,1); eq(FAKE.tooltipCalls,before)
        local c=context('food'); c.bagStock={{id=4541,usable=true}}
        eq(ns.Classify(i,c).mark,'coin')
        C_Item={GetItemSpell=GetItemSpell}; GetItemSpell=nil; ns.Player.Invalidate()
        eq(ns.Player.ReadItem(0,1).restorationOnly,true)
        FAKE.items[117].tooltip={'Use: Restores health.','Equip: Other effect.'}; ns.Player.Invalidate()
        i=ns.Player.ReadItem(0,1); eq(i.restorationOnly,nil); eq(ns.Classify(i,c).mark,'useful')
    end)
    GetItemSpell,UnitLevel,GetInventoryItemID,C_Item=spell,level,inv,modern
    if not good then error(err,0) end
end)

test('R12: respaldo GameTooltip usa SetBagItem, nunca el enlace para conocimiento', function()
    local create,level,inv=CreateFrame,UnitLevel,GetInventoryItemID
    local good,err=pcall(function()
        inventory(); ns.DB.rules.knownRecipe=true; C_TooltipInfo.GetBagItem=nil
        CreateFrame=function(kind,name,...)
            local f=create(kind,name,...)
            if name=='KnuJunkScanTooltip' then
                f.NumLines=function() return 2 end
                f.SetBagItem=function(_,bag,slot) eq(bag,0); eq(slot,3) end
                _G.KnuJunkScanTooltipTextLeft1={GetText=function() return 'Recipe' end}
                _G.KnuJunkScanTooltipTextLeft2={GetText=function() return 'Ya conocido' end}
            end
            return f
        end
        eq(ns.Player.ReadItem(0,3).knownRecipe,true)
        eq(ns.Player.ReadLink(2406).knownRecipe,nil)
    end)
    CreateFrame,UnitLevel,GetInventoryItemID=create,level,inv
    _G.KnuJunkScanTooltipTextLeft1=nil; _G.KnuJunkScanTooltipTextLeft2=nil
    if not good then error(err,0) end
end)

test('R9: bebida superior y restauración doble deben cubrir el mismo recurso', function()
    local i,c=food(),context('food'); i.id=5350 -- agua conjurada: no es reactivo de profesión
    c.bagStock={{id=1205,usable=true}}; eq(ns.Classify(i,c).mark,'coin')
    local saved=ns.Data.food[990009]
    ns.Data.food[990009]={health=294,mana=294,reqLevel=0,spell=2639}
    local good,err=pcall(function()
        i.id=990009; c.bagStock={{id=1205,usable=true}}; eq(ns.Classify(i,c).mark,'useful')
        c.bagStock={{id=262433,usable=true}}; eq(ns.Classify(i,c).mark,'coin')
    end)
    ns.Data.food[990009]=saved
    if not good then error(err,0) end
end)

test('Tanda4: tooltip de ranura vacía o identidad distinta no usa el enlace viejo', function()
    local level,inv=UnitLevel,GetInventoryItemID
    local good,err=pcall(function()
        inventory(); ns.DB.rules.food=true
        eq(#ns.Tooltip.Lines(FAKE.linkOf(117),nil,0,99),0)
        eq(#ns.Tooltip.Lines(FAKE.linkOf(117),nil,0,2),0)
    end)
    UnitLevel,GetInventoryItemID=level,inv
    if not good then error(err,0) end
end)

test('Tanda4: tooltips en ambos idiomas para bolsas, sin conocimiento por enlace', function()
    local level,inv,locale,L=UnitLevel,GetInventoryItemID,GetLocale,ns.L
    local good,err=pcall(function()
        inventory(); ns.DB.rules={food=true,ammo=true,knownRecipe=true}; FAKE.bound['0:3']=true
        for _,lang in ipairs({'esES','enUS'}) do
            GetLocale=function() return lang end; assert(loadfile('Locales/Locales.lua'))('KnuJunk',ns)
            ns.Player.Invalidate()
            for _,case in ipairs({{117,1,'You have better food/drink for your level'},
                {2512,4,'You have compatible ammunition with higher damage'},
                {2406,3,'You already know this recipe'}}) do
                local lines=ns.Tooltip.Lines(FAKE.linkOf(case[1]),nil,0,case[2])
                ok(#lines>0); ok(lines[2].text:find(ns.L[case[3]],1,true))
            end
            FAKE.bound['0:3']=false
            local lines=ns.Tooltip.Lines(FAKE.linkOf(2406),nil,0,3)
            ok(lines[2].text:find(ns.L['You already know it; you can pass it on or auction it'],1,true))
            FAKE.bound['0:3']=true
            for _, line in ipairs(ns.Tooltip.Lines(FAKE.linkOf(2406))) do
                ok(not line.text:find(ns.L['You already know this recipe'],1,true))
            end
        end
    end)
    UnitLevel,GetInventoryItemID,GetLocale,ns.L=level,inv,locale,L
    if not good then error(err,0) end
end)

test('Tanda4: comandos validan, listan, invalidan y refrescan', function()
    local inv,refresh=ns.Player.Invalidate,ns.Bags.RefreshAll
    local n,m=0,0
    ns.Player.Invalidate=function() n=n+1 end; ns.Bags.RefreshAll=function() m=m+1 end
    local good,err=pcall(function()
        ns.Commands.Handle('rules'); eq(n,0)
        for _,k in ipairs({'food','ammo','knownrecipe'}) do ns.Commands.Handle('rules '..k..' on') end
        eq(ns.DB.rules.knownRecipe,true); eq(n,3); eq(m,3)
        ns.Commands.Handle('rules food off'); eq(ns.DB.rules.food,false); eq(n,4)
        for _,s in ipairs({'rules x on','rules food maybe','rules food on extra'}) do ns.Commands.Handle(s) end
        eq(n,4); ns.Commands.Status()
        ok(table.concat(FAKE.messages,'\n'):find('knownrecipe',1,true))
    end)
    ns.Player.Invalidate,ns.Bags.RefreshAll=inv,refresh
    if not good then error(err,0) end
end)

test('R9: alternativa del mismo tipo, umbral exacto y OFF sin cambio', function()
    local i,c=food(),context('food')
    -- 117 y 4540 tienen igual restauración; 4541 es superior.
    c.bagStock={{id=4541,usable=true}}
    c.level=ns.Data.food[117].reqLevel+15
    eq(ns.Classify(i,c).mark,'coin'); ok(reason(ns.Classify(i,c),'food_outgrown'))
    c.level=c.level-1; eq(ns.Classify(i,c).mark,'useful')
    c.level=40
    for _,stock in ipairs({{},{{id=4540,usable=true}},{{id=159,usable=true}},{{id=4541,usable=false}}}) do
        c.bagStock=stock; eq(ns.Classify(i,c).mark,'useful')
    end
    c.bagStock={{id=4541,usable=true}}; c.rules={}; eq(ns.Classify(i,c).mark,'useful')
    i.id=999999; c.rules.food=true; eq(ns.Classify(i,c).mark,'useful')
end)

test('R16: mismo subtipo, daño superior, usable, reserva y OFF', function()
    local i,c=ammo(),context('ammo')
    eq(ns.Classify(i,c).mark,'coin'); ok(reason(ns.Classify(i,c),'ammo_outgrown'))
    for _,stock in ipairs({{},{{id=2512,usable=true}},{{id=2516,usable=true}},{{id=2515,usable=false}}}) do
        c.bagStock=stock; eq(ns.Classify(i,c).mark,'useful')
    end
    c=context('ammo'); i.slot=nil; eq(ns.Classify(i,c).mark,'useful')
    i=ammo(); c.rules={}; eq(ns.Classify(i,c).mark,'useful')
    c.rules.ammo=true; i.equippedAmmo=true; eq(ns.Classify(i,c).mark,'useful')
end)

test('R16: conserva la mejor reserva, exige nivel y diferencia de ilvl', function()
    local i,c=ammo(),context('ammo')
    c.level=9; eq(ns.Classify(i,c).mark,'useful')
    c=context('ammo'); c.bagStock[4].id=2514; eq(ns.Classify(i,c).mark,'useful')
    c=context('ammo'); i.id=2515; i.slot=2
    eq(ns.Classify(i,c).mark,'useful')
    c=context('ammo'); i=ammo(); i.bag=-1; eq(ns.Classify(i,c).mark,'useful')
end)

test('Tanda4: efectos desconocidos y venta manual explícita', function()
    for _,case in ipairs({{food,'food'},{ammo,'ammo'},{recipe,'knownRecipe'}}) do
        local i,c=case[1](),context(case[2]); i.effect='unknown'
        ok(ns.Classify(i,c).mark~='coin')
        c.overrides={[i.id]='sell'}; eq(ns.Classify(i,c).mark,'coin')
    end
end)

test('Tanda4: OFF no escanea existencias ni conocimiento', function()
    FAKE.items[2406]={name='Recipe',quality=1,price=5,classID=9}
    FAKE.bags['0:1']=2406
    C_TooltipInfo.GetBagItem=function() error('No debe escanear conocimiento') end
    C_Container.GetContainerNumSlots=function() error('No debe escanear bolsas') end
    eq(ns.Player.ReadItem(0,1).knownRecipe,nil)
    eq(#ns.Player.GetContext().bagStock,0)
end)

test('R12/13: evidencia positiva, ligado, precio y OFF', function()
    local i,c=recipe(),context('knownRecipe')
    eq(ns.Classify(i,c).mark,'coin'); ok(reason(ns.Classify(i,c),'recipe_known'))
    i.isBound=false; local r=ns.Classify(i,c); eq(r.mark,'useful'); ok(reason(r,'recipe_known_tradeable'))
    i.isBound=nil; eq(ns.Classify(i,c).mark,'useful')
    i.isBound=true; i.price=0; eq(ns.Classify(i,c).mark,'trash')
    i.price=5; i.knownRecipe=nil; eq(ns.Classify(i,c).mark,'hammer_other')
    i.knownRecipe=true; c.rules={}; eq(ns.Classify(i,c).mark,'hammer_other')
end)

test('Tanda4: todas las protecciones prevalecen', function()
    for _,case in ipairs({{food,'food'},{ammo,'ammo'},{recipe,'knownRecipe'}}) do
        for _,protection in ipairs({'effect','set','quest','incomplete','keep','reagent','tool','key','special','starter'}) do
            local i,c=case[1](),context(case[2]); c.bagStock[2]={id=4541,usable=true}
            c.bagStock[3]={id=2512,usable=true,bag=0,slot=1}; c.bagStock[4]={id=2515,usable=true,bag=0,slot=2}
            local tables={'reagents','tools','keys','libraryBooks','starters'}; local saved={}
            for _,k in ipairs(tables) do saved[k]=ns.Data[k][i.id] end
            if protection=='effect' then i.effect=i.classID==9 and 'unknown' or 'yes'
            elseif protection=='set' then i.isSetPiece=true
            elseif protection=='quest' then c.questItemsInLog={[i.id]=true}
            elseif protection=='incomplete' then c.questLogIncomplete=true
            elseif protection=='keep' then c.overrides={[i.id]='keep'}
            elseif protection=='reagent' then ns.Data.reagents[i.id]={164}
            elseif protection=='tool' then ns.Data.tools[i.id]={164}
            elseif protection=='key' then ns.Data.keys[i.id]=true
            elseif protection=='special' then ns.Data.libraryBooks[i.id]=true
            elseif protection=='starter' then ns.Data.starters[i.id]=123 end
            local r=ns.Classify(i,c)
            for _,k in ipairs(tables) do ns.Data[k][i.id]=saved[k] end
            ok(r.mark~='coin',case[2]..' '..protection)
        end
    end
end)
