-- Tanda 2: protecciones previas a cualquier moneda autom?tica.
local ID = 990001
local function item(class) return {id=ID, classID=class or 12, quality=0, price=10} end
local function context(uses)
    return {class='MAGE', professions={}, questieUses=function() return uses end,
        questInLog=function() return false end, isQuestDone=function() return true end}
end
local function reason(result, kind)
    for _, r in ipairs(result.reasons) do if r.kind == kind then return r end end
end
local function withLocks(keys, boxes, fn)
    local k,b = ns.Data.keys,ns.Data.lockboxes
    ns.Data.keys,ns.Data.lockboxes=keys,boxes
    local good,err=pcall(fn)
    ns.Data.keys,ns.Data.lockboxes=k,b
    if not good then error(err,0) end
end

test('R18: clase llave, abridor generado y caja cerrada nunca moneda', function()
    withLocks({[ID]=true},{},function()
        local r=ns.Classify(item(),context()); eq(r.mark,nil); ok(reason(r,'key'))
    end)
    withLocks({},{[ID]=true},function()
        local r=ns.Classify(item(),context()); eq(r.mark,nil); ok(reason(r,'lockbox'))
    end)
    withLocks({},{},function()
        local r=ns.Classify(item(13),context()); eq(r.mark,nil); ok(reason(r,'key'))
    end)
end)

test('R18: vender manual gana, incluso sin calidad cargada', function()
    withLocks({[ID]=true},{},function()
        local c=context(); c.overrides={[ID]='sell'}
        eq(ns.Classify({id=ID},c).mark,'coin')
    end)
end)

test('R20: objetivo repetible con reputación fuera del diario se conserva', function()
    FAKE.InstallQuestie({[100]={specialFlags=1,questFlags=0,
        objectives={[3]={{ID,'Entrega',5}}},reputationReward={{529,25},{87,-25}}}})
    ns.Questie.Uses(ID); FAKE.Advance(5)
    local uses=ns.Questie.Uses(ID)
    ok(uses and uses[1].reputationFactions, 'metadatos de reputación')
    eq(uses[1].reputationFactions[1],529)
    local r=ns.Classify(item(),context(uses))
    eq(r.mark,nil); eq(reason(r,'reputation_token').factionIDs[1],529)
    local c=context(uses); c.overrides={[ID]='sell'}
    eq(ns.Classify(item(),c).mark,'coin')
end)

test('R20: fuente, iniciador, hechizo y reputación negativa no son entregas', function()
    FAKE.InstallQuestie({
        [100]={specialFlags=1,questFlags=0,sourceItemId=ID,reputationReward={{529,25}}},
        [101]={specialFlags=1,questFlags=0,objectives={[3]={{ID+1}}},reputationReward={{529,-25}}},
        [102]={specialFlags=0,questFlags=0,objectives={[3]={{ID+2}}},reputationReward={{529,25}}},
        [103]={specialFlags=1,questFlags=0,objectives={[6]={{1,'Usar',ID+3}}},reputationReward={{529,25}}},
    })
    ns.Questie.Uses(ID); FAKE.Advance(5)
    for id=ID,ID+3 do
        local uses=ns.Questie.Uses(id)
        eq(uses[1].reputationFactions,nil)
        local i=item(); i.id=id
        eq(ns.Classify(i,context(uses)).mark,'coin')
    end
end)

test('R20: misión activa y profesión conservan sus marcas', function()
    local uses={{questID=1,repeatable=true,reputationFactions={529}}}
    local c=context(uses); c.questInLog=function() return true end
    eq(ns.Classify(item(),c).mark,'quest')
    local saved=ns.Data.reagents; ns.Data.reagents={[ID]={164}}
    local good,err=pcall(function()
        local r=ns.Classify(item(),c); eq(r.mark,'hammer_other'); eq(r.quest,true)
        c.questInLog=function() return false end
        eq(ns.Classify(item(),c).mark,'hammer_other')
    end)
    ns.Data.reagents=saved; if not good then error(err,0) end
end)

test('R20: sin QuestieDB ni tabla generada se mantiene moneda de misión',function()
    eq(ns.Classify(item(),context()).mark,'coin')
end)

test('R18/R20: tooltips neutros traducidos y sin ícono',function()
    FAKE.items[ID]={name='Prueba',quality=1,price=10,classID=15}
    local saved=ns.Classify
    local good,err=pcall(function()
        for _,pair in ipairs({{'key','Llave: abre una cerradura; conservala'},
            {'lockbox','Caja cerrada: abrila antes de venderla (ganzúa o llave)'},
            {'reputation_token','Se entrega por reputación: facción desconocida'}}) do
            ns.Classify=function() return {reasons={{kind=pair[1]}}} end
            local lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(#lines,1); eq(lines[1].text,pair[2])
        end
    end)
    ns.Classify=saved; if not good then error(err,0) end
end)

test('R18: llaves y cajas reales cargadas desde el toc',function()
    for _,id in ipairs({12382,7146,5396}) do
        ok(ns.Data.keys[id], 'llave generada '..id)
        local i=item(); i.id=id
        eq(ns.Classify(i,context()).mark,nil)
    end
    for _,id in ipairs({4632,4633,6354}) do
        ok(ns.Data.lockboxes[id], 'caja generada '..id)
        local i=item(); i.id=id
        eq(ns.Classify(i,context()).mark,nil)
    end
end)

test('R18/R20: textos ingleses sin ícono',function()
    local locale,L=FAKE.locale,ns.L
    FAKE.locale='enUS'
    ns.L=setmetatable({},{__index=function(_,key) return key end})
    FAKE.items[ID]={name='Prueba',quality=1,price=10,classID=15}
    local classify=ns.Classify
    local good,err=pcall(function()
        for _,pair in ipairs({{'key','Key: opens a lock; keep it'},
            {'lockbox','Locked box: open it before selling (lockpick or key)'},
            {'reputation_token','Turn in for reputation: unknown faction'}}) do
            ns.Classify=function() return {reasons={{kind=pair[1]}}} end
            local lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(#lines,1); eq(lines[1].text,pair[2])
        end
    end)
    ns.Classify,FAKE.locale,ns.L=classify,locale,L
    if not good then error(err,0) end
end)

test('R18: datos generados protegen aunque la calidad no haya cargado',function()
    withLocks({[ID]=true},{[ID+1]=true},function()
        eq(reason(ns.Classify({id=ID},context()),'key').kind,'key')
        eq(reason(ns.Classify({id=ID+1},context()),'lockbox').kind,'lockbox')
    end)
end)

test('R20: varias facciones, copias independientes y recompensa ilegible aislada',function()
    local lib=FAKE.InstallQuestie({
        [100]={specialFlags=1,questFlags=0,objectives={[3]={{ID}}},
            reputationReward={{529,25},{529,25},{87,10},{0,10},{1,0},'roto'}},
        [101]={specialFlags=1,questFlags=0,objectives={[3]={{ID+1}}}},
    })
    local get=lib.Quest.Get
    lib.Quest.Get=function(id,key)
        if id==101 and key=='reputationReward' then error('campo no disponible') end
        return get(id,key)
    end
    ns.Questie.Uses(ID); FAKE.Advance(5)
    ok(ns.Questie.IsReady())
    local uses=ns.Questie.Uses(ID)
    eq(#uses[1].reputationFactions,2); eq(uses[1].reputationFactions[2],87)
    uses[1].reputationFactions[1]=123
    eq(ns.Questie.Uses(ID)[1].reputationFactions[1],529)
    eq(ns.Questie.Uses(ID+1)[1].reputationFactions,nil)
end)

test('R20: facciones en tooltip con API clásica, moderna y ausente',function()
    FAKE.items[ID]={name='Prueba',quality=1,price=10,classID=15}
    local classify,classic,modern=ns.Classify,GetFactionInfoByID,C_Reputation
    local good,err=pcall(function()
        ns.Classify=function() return {reasons={{kind='reputation_token',factionIDs={529,87}}}} end
        GetFactionInfoByID=function(id) if id==529 then return 'El Alba Argenta' end end
        C_Reputation=nil
        eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[1].text,'Se entrega por reputación: El Alba Argenta, Facción #87')
        C_Reputation={GetFactionDataByID=function(id) return {name='Nombre '..id} end}
        eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[1].text,'Se entrega por reputación: Nombre 529, Nombre 87')
        C_Reputation={GetFactionDataByID=function() error('no disponible') end}
        GetFactionInfoByID=nil
        eq(ns.Tooltip.Lines(FAKE.linkOf(ID))[1].text,'Se entrega por reputación: Facción #529, Facción #87')
    end)
    ns.Classify,GetFactionInfoByID,C_Reputation=classify,classic,modern
    if not good then error(err,0) end
end)
