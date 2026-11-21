local ID = 990901
local function item(fields)
    local value = { id = ID, quality = 2, classID = 15, subclassID = 0, price = 10 }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end
local function context(fields)
    local value = { class = 'PALADIN', level = 30, professions = {}, overrides = {}, questItemsInLog = {},
        questInLog = function() return false end, isQuestDone = function() return false end }
    for k, v in pairs(fields or {}) do value[k] = v end
    return value
end
local function reason(reasons, kind)
    for _, r in ipairs(reasons or {}) do if r.kind == kind then return r end end
end

test('orden: bastón 16889 ligado para paladín vende aunque tenga efecto', function()
    local r = ns.Classify(item { id = 16889, classID = 2, subclassID = 10, isBound = true,
        effect = 'yes', hasUseOrEquipSpell = true }, context())
    eq(r.mark, 'coin'); ok(reason(r.reasons, 'class_cannot_use'))
    ok(reason(r.otherReasons, 'effect'))
end)

test('orden: bastón con efecto libre para paladín conserva motivo comerciable', function()
    local r = ns.Classify(item { classID = 2, subclassID = 10, isBound = false, effect = 'yes' }, context())
    eq(r.mark, 'useful'); ok(reason(r.reasons, 'class_cannot_use_tradeable'))
end)

test('orden: bastón con «Equipar:» ligado para mago no se guarda por el efecto (lo juzga la cadena de equipo)', function()
    local r = ns.Classify(item { classID = 2, subclassID = 10, isBound = true, effect = 'yes' }, context { class = 'MAGE' })
    eq(r.mark, 'useful'); eq(reason(r.reasons, 'useful'), nil)
end)

test('orden: misión con uso decide según diario, sin alterar vetos de duda', function()
    local v = item { classID = 12, effect = 'yes', hasUseOrEquipSpell = true }
    local r = ns.Classify(v, context())
    eq(r.mark, 'coin'); ok(reason(r.reasons, 'quest_not_active')); ok(reason(r.otherReasons, 'effect'))
    r = ns.Classify(v, context { questItemsInLog = { [ID] = true } })
    eq(r.mark, 'quest'); eq(reason(r.otherReasons, 'quest_not_active'), nil)
    r = ns.Classify(v, context { questLogIncomplete = true })
    eq(r.mark, 'useful'); eq(reason(r.otherReasons, 'quest_not_active'), nil)
    r = ns.Classify(v, context { questieUses = function() return {{questID=7}} end,
        questInLog = function() return nil end })
    eq(r.mark, 'useful'); eq(reason(r.otherReasons, 'quest_not_active'), nil)
    v.effect = 'unknown'; eq(ns.Classify(v, context()).mark, 'useful')
    v.pending = true; eq(ns.Classify(v, context()).mark, nil)
end)

test('orden: fallback sólo agrega no_rule cuando no hubo motivo decisor', function()
    for _, price in ipairs({0,10}) do
        local r = ns.Classify(item {price=price}, context())
        eq(r.mark, 'useful'); eq(r.reasons[1].kind, 'no_rule')
    end
    eq(reason(ns.Classify(item {effect='yes'}, context()).reasons, 'no_rule'), nil)
    eq(reason(ns.Classify(item(), context {overrides={[ID]='keep'}}).reasons, 'no_rule'), nil)
end)

test('orden: tooltip no_rule y También en ambos idiomas, sin icono en evidencia', function()
    local savedL = ns.L
    local success, err = pcall(function()
        for _, locale in ipairs({'esES','esMX','enUS'}) do
            FAKE.locale = locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk', ns)
            FAKE.items[ID] = {name='Prueba',quality=2,classID=15,subclassID=0,price=10}
            ns.DB.rules.sellUnruled = false
            ns.Player.Invalidate()
            local lines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(lines[2].text, locale == 'enUS' and 'No rule for this item: not sold by default' or 'Sin regla para este ítem: por defecto no se vende')
            ns.DB.rules.sellUnruled = true
            ns.Player.Invalidate()
            lines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            local soldText = locale == 'enUS' and 'No rule for this item: sold by default' or 'Sin regla para este ítem: por defecto se vende'
            eq(lines[2].text:sub(-#soldText), soldText)
            -- Override gana; diario vacío y efecto son evidencias inferiores.
            FAKE.items[ID].classID = 12; FAKE.items[ID].spell = true
            ns.DB.overrides[ID] = 'keep'; ns.Player.Invalidate()
            lines = ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(lines[2].text, ns.L['Protected (by hand)'])
            eq(lines[3].text, ns.L['Also: '] .. ns.L['No active quest needs it'])
            eq(lines[4].text, ns.L['Also: '] .. ns.L['Has a use or equip effect'])
            for i=3,4 do eq(lines[i].r,.6); eq(lines[i].g,.6); eq(lines[i].b,.6); eq(lines[i].text:find('|T',1,true),nil) end
            ns.DB.overrides[ID] = nil
        end
    end)
    ns.L, FAKE.locale = savedL, nil
    if not success then error(err) end
end)

test('orden: evidencia reúne clase, misión, gris, profesión, nivel y efecto sin mutar entradas', function()
    local savedR, savedT = ns.Data.reagents, ns.Data.tools
    ns.Data.reagents, ns.Data.tools = {[ID]={164}}, {[ID]={202}}
    local success, err = pcall(function()
        local v = item {quality=0,classID=2,subclassID=10,isBound=true,effect='yes'}
        local c = context {overrides={[ID]='keep'},questieUses=function() return {{questID=7}} end}
        local r = ns.Classify(v,c)
        eq(r.mark,'protected')
        for _, kind in ipairs({'class_cannot_use','quest_not_active','gray','profession','profession_tool','effect'}) do
            ok(reason(r.otherReasons,kind),'falta '..kind)
        end
        eq(v.effect,'yes'); eq(v.isBound,true); eq(c.overrides[ID],'keep'); eq(ns.Data.reagents[ID][1],164)
        v.quality=2; c.class='MAGE'; v.reqLevel=60
        r=ns.Classify(v,c); eq(r.mark,'protected'); eq(reason(r.otherReasons,'future_level').level,60)
    end)
    ns.Data.reagents, ns.Data.tools = savedR, savedT
    if not success then error(err) end
end)

test('orden: tooltip muestra primero el ganador de clase o gris, después el efecto', function()
    FAKE.class='PALADIN'
    FAKE.items[ID]={name='Bastón',quality=2,classID=2,subclassID=10,price=10,spell=true,subType='Bastón'}
    ns.Player.Invalidate()
    local lines=ns.Tooltip.Lines(FAKE.linkOf(ID),true)
    ok(lines[2].text:find(ns.L["Your class can't use %s"]:format('Bastón'),1,true))
    eq(lines[3].text,ns.L['Also: ']..ns.L['Has a use or equip effect'])
    FAKE.items[ID].quality=0; ns.Player.Invalidate()
    lines=ns.Tooltip.Lines(FAKE.linkOf(ID),true)
    ok(lines[2].text:find(ns.L['Junk: sells'],1,true))
end)

test('orden: segunda pasada no cambia ninguna marca en matriz de fixtures', function()
    local fixtures = {
        {}, {quality=0}, {price=0}, {classID=12,effect='yes'}, {classID=12,effect='unknown'},
        {classID=2,subclassID=10,isBound=true,effect='yes'}, {classID=2,subclassID=10,isBound=false,effect='yes'},
        {classID=4,subclassID=4,isBound=true,reqLevel=50}, {classID=4,subclassID=1,reqLevel=50},
        {classID=9}, {classID=13}, {isSetPiece=true}, {pending=true}, {id=17031}, {id=2589},
    }
    for _, class in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'}) do
        for _, level in ipairs({10,30,60}) do
            for _, fields in ipairs(fixtures) do
                for _, variant in ipairs({'normal','keep','sell','incomplete','active','auction'}) do
                    local v, c = item(fields), context {class=class,level=level}
                    if variant=='keep' or variant=='sell' then c.overrides[v.id]=variant end
                    c.questLogIncomplete = variant=='incomplete'
                    if variant=='active' then c.questItemsInLog[v.id]=true end
                    Auctionator = variant=='auction' and {API={v1={GetAuctionPriceByItemID=function() return 1000 end}}} or nil
                    local single, enriched = ns.Classify(v,c,false), ns.Classify(v,c)
                    eq(enriched.mark,single.mark,class..':'..level..':'..variant)
                    eq(enriched.pending,single.pending); eq(enriched.uncertain,single.uncertain)
                    eq(single.otherReasons,nil)
                    if not enriched.pending then ok(type(enriched.otherReasons)=='table') end
                    eq(#enriched.reasons,#single.reasons)
                    for i, r in ipairs(single.reasons) do eq(enriched.reasons[i].kind,r.kind) end
                end
            end
        end
    end
end)

test('auditoría: fixture CSV, descarga simulada y reporte completos', function()
    eq(os.execute('python -I tools/test_auditoria_venta.py'),0)
end)
