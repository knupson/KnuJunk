local ID = 990003
local function reason(r, kind)
    for _, v in ipairs(r.reasons) do if v.kind == kind then return v end end
end
local function item(class, sub)
    return {id=ID, quality=0, price=10, classID=class, subclassID=sub, isBound=true, reqLevel=40}
end
local function whiteItem(...)
    local value = item(...)
    value.quality = 1
    return value
end

local function ctx() return {class='WARRIOR', level=20, professions={}} end

test('R14: receta propia o ajena nunca moneda, blanca y fuera del diario', function()
    local saved=ns.Data.recipes
    ns.Data.recipes={[ID]={skillLine=165,rank=65}}
    local good,err=pcall(function()
        for _,own in ipairs({false,true}) do
            local c=ctx(); c.professions=own and {[165]=true} or {}
            c.questieUses=function() return {{questID=1}} end
            c.questInLog=function() return false end
            local r=ns.Classify(whiteItem(9),c)
            eq(r.mark,own and 'hammer_mine' or 'hammer_other')
            eq(reason(r,'recipe').skillLine,165); eq(reason(r,'recipe').rank,65)
            c.questInLog=function() return true end
            r=ns.Classify(whiteItem(9),c); eq(r.mark,'quest'); eq(r.quest,true)
            c.overrides={[ID]='sell'}; eq(ns.Classify(whiteItem(9),c).mark,'coin')
        end
    end)
    ns.Data.recipes=saved; if not good then error(err,0) end
end)

test('R14: receta sin profesión identificada tampoco recibe moneda', function()
    local r=ns.Classify(whiteItem(9),ctx()); eq(r.mark,'useful')
end)

test('R24: equipo futuro usable por clase (no gris) se protege sin sumar icono', function()
    for _,spec in ipairs({{4,4},{2,8}}) do
        local i=item(spec[1],spec[2]); i.quality=2; i.effect='no'
        local r=ns.Classify(i,ctx())
        eq(r.mark,'useful'); eq(reason(r,'future_level').level,40)
    end
end)

test('R24: un gris de nivel futuro sigue siendo basura (decisión del dueño: gris = basura)', function()
    local r=ns.Classify(item(4,4),ctx())
    eq(r.mark,'coin'); ok(reason(r,'gray'), 'motivo gray')
end)

test('R24: no protege basura presente, subtipos desconocidos ni otra clase', function()
    for _,level in ipairs({20,40,50}) do
        local c=ctx(); c.level=level
        local i=item(4,4); if level==20 then i.reqLevel=nil end
        eq(ns.Classify(i,c).mark,'coin')
    end
    local c=ctx(); c.class='MAGE'
    eq(ns.Classify(item(4,4),c).mark,'coin')
    eq(ns.Classify(item(4,99),ctx()).mark,'coin')
    eq(ns.Classify(item(15),ctx()).mark,'coin')
    c=ctx(); c.level=nil; eq(ns.Classify(item(4,4),c).mark,'coin')
end)

test('R24: override y misión activa conservan precedencia', function()
    local c=ctx(); c.overrides={[ID]='sell'}
    eq(ns.Classify(whiteItem(4,4),c).mark,'coin')
    c.overrides={}; c.questItemsInLog={[ID]=true}
    eq(ns.Classify(whiteItem(4,4),c).mark,'quest')
end)

test('R24: ReadLink y ReadItem leen el quinto retorno de GetItemInfo', function()
    FAKE.items[ID]={name='Futuro',quality=1,price=10,classID=4,subclassID=4}
    local saved=GetItemInfo
    GetItemInfo=function(key)
        local values={saved(key)}; values[5]=40; return unpack(values,1,17)
    end
    local good,err=pcall(function()
        eq(ns.Player.ReadLink(ID).reqLevel,40)
        FAKE.bags['0:1']=ID
        eq(ns.Player.ReadItem(0,1).reqLevel,40)
    end)
    GetItemInfo=saved; if not good then error(err,0) end
end)

test('R24: nivel del contexto cambia y avisa al subir de nivel', function()
    local saved=UnitLevel; UnitLevel=function(unit) eq(unit,'player'); return FAKE.level end
    local good,err=pcall(function()
        FAKE.level=20; eq(ns.Player.GetContext().level,20)
        local changed=0; ns.Player.OnChanged(function() changed=changed+1 end)
        FAKE.level=40; FAKE.Fire('PLAYER_LEVEL_UP',40); FAKE.Advance(0.25)
        eq(ns.Player.GetContext().level,40); eq(changed,1)
    end)
    UnitLevel=saved; if not good then error(err,0) end
end)

test('R14: ejemplos reales del archivo generado y amarillo ajeno', function()
    for _,example in ipairs({{2406,165,65},{2553,171,50}}) do
        local id,line,rank=unpack(example)
        eq(ns.Data.recipes[id].skillLine,line); eq(ns.Data.recipes[id].rank,rank)
        local i=whiteItem(9); i.id=id
        local c=ctx(); eq(ns.Classify(i,c).mark,'hammer_other')
        c.professions={[line]=true}; eq(ns.Classify(i,c).mark,'hammer_mine')
    end
end)

test('R24: nivel del jugador ausente o API fallida queda desconocido', function()
    local saved=UnitLevel
    local good,err=pcall(function()
        UnitLevel=nil; ns.Player.Invalidate(); eq(ns.Player.GetContext().level,nil)
        UnitLevel=function() error('sin dato') end
        ns.Player.Invalidate(); eq(ns.Player.GetContext().level,nil)
    end)
    UnitLevel=saved; if not good then error(err,0) end
end)

test('R14/R24: tooltip real en inglés y español, protección con martillo oculto', function()
    local locale,L,unitLevel=GetLocale,ns.L,UnitLevel
    local good,err=pcall(function()
        GetLocale=function() return 'enUS' end
        assert(loadfile('Locales/Locales.lua'))('KnuJunk',ns)
        FAKE.items[2406]={name='Pattern',quality=1,price=10,classID=9}
        local lines=ns.Tooltip.Lines(FAKE.linkOf(2406))
        eq(#lines,2); ok(lines[2].text:find('Recipe for Leatherworking, requires 65',1,true))
        ns.DB.show.hammer=false
        eq(#ns.Tooltip.Lines(FAKE.linkOf(2406)),1)
        eq(ns.Classify(ns.Player.ReadLink(2406),ns.Player.GetContext()).mark,'hammer_other')
        FAKE.class='MAGE'; UnitLevel=function() return 20 end; ns.Player.Invalidate()
        FAKE.items[ID]={name='Futuro',quality=1,price=10,classID=4,subclassID=1}
        local info=GetItemInfo
        GetItemInfo=function(key)
            local v={info(key)}; v[5]=40; return unpack(v,1,17)
        end
        local good2,err2=pcall(function()
            eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[2].text,'Usable from level 40')
            GetLocale=function() return 'esMX' end
            assert(loadfile('Locales/Locales.lua'))('KnuJunk',ns)
            eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[2].text,'Podés usarlo desde nivel 40')
        end)
        GetItemInfo=info; if not good2 then error(err2,0) end
    end)
    GetLocale,ns.L,UnitLevel=locale,L,unitLevel
    if not good then error(err,0) end
end)

test('R14/R24: tooltip localizado, requisito opcional y colores', function()
    local saved=ns.Classify
    FAKE.items[ID]={name='Prueba',quality=1,price=10,classID=9}
    local good,err=pcall(function()
        for _,mark in ipairs({'hammer_mine','hammer_other'}) do
            ns.Classify=function() return {mark=mark,reasons={{kind='recipe',skillLine=165,rank=65}}} end
            local lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(#lines,2); ok(lines[2].text:find('Receta de ',1,true)); ok(lines[2].text:find(', requiere 65',1,true))
            eq(lines[2].r,mark=="hammer_mine" and (111/255) or 1)
            eq(lines[2].g,mark=="hammer_mine" and 211/255 or 154/255)
        end
        ns.Classify=function() return {reasons={{kind='recipe',skillLine=165}},mark='hammer_other'} end
        ok(not ns.Tooltip.Lines(FAKE.linkOf(ID))[2].text:find('requiere',1,true))
        ns.Classify=function() return {reasons={{kind='future_level',level=40}}} end
        eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[1].text,'Podés usarlo desde nivel 40')
    end)
    ns.Classify=saved; if not good then error(err,0) end
end)
