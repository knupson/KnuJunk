local ID, MISS = 990091, 'Not ranked for your class.'
local function item(fields)
    local value = { id = ID, link = 'item:' .. ID, quality = 2, price = 50,
        classID = 2, subclassID = 7, equipLoc = 'INVTYPE_WEAPON', isBound = true, reqLevel = 1 }
    for key, field in pairs(fields or {}) do value[key] = field end
    return value
end
local function context(fields)
    local value = { class = 'WARRIOR', level = 20, professions = {}, rules = ns.DB.rules }
    for key, field in pairs(fields or {}) do value[key] = field end
    return value
end
local function reason(result)
    for _, value in ipairs(result.reasons) do if value.kind == 'gear_not_ranked' then return value end end
end
local function gearQuest(text)
    GQ = { Data = {} }
    GQ.Data.GetEntriesByItemId = function() return { { pipelineScore = 1 } } end
    GQ.Data.EntryForItemLink = function() return nil end
    GQ.IsPreviewEnabled = function() return false end
    GQ.GetEffectiveLevel = function() return 20 end
    GQ.GetEffectiveClass = function() return 'WARRIOR' end
    GQ.Data.GearScoreMissText = function(self, link)
        eq(self, GQ.Data); eq(link, 'item:' .. ID)
        return text
    end
end
local function auction(price)
    Auctionator = { API = { v1 = { GetAuctionPriceByItemID = function() return price end } } }
end

test('GearQuest: regla activada por defecto y migración de DB', function()
    eq(ns.DB.rules.gearNotRanked, true)
    KnuJunkDB = { rules = { food = true, gearNotRanked = false } }
    FAKE.Fire('ADDON_LOADED', 'KnuJunk')
    eq(ns.DB.rules.gearNotRanked, false); eq(ns.DB.rules.food, true)
end)

for _, bound in ipairs({true, false}) do
    for _, price in ipairs({0, 50}) do
        local isBound, vendor = bound, price
        test('GearQuest: ligadura ' .. tostring(bound) .. ', venta ' .. price, function()
            gearQuest(MISS)
            local result = ns.Classify(item({isBound=isBound, price=vendor}), context())
            eq(result.mark, vendor > 0 and 'coin' or 'trash'); eq(reason(result).text, MISS)
        end)
    end
end

test('GearQuest: sin ligar puede ir a subasta incluso sin precio de venta', function()
    gearQuest(MISS); auction(500)
    for _, price in ipairs({0,50}) do
        eq(ns.Classify(item({isBound=false,price=price}),context()).mark,'auction')
    end
    eq(ns.Classify(item(),context()).mark,'coin')
end)

test('GearQuest: subasta respeta umbrales y tolera error de Auctionator', function()
    gearQuest(MISS); auction(99)
    eq(ns.Classify(item({isBound=false}),context()).mark,'coin')
    Auctionator.API.v1.GetAuctionPriceByItemID = function() error('sin datos') end
    eq(ns.Classify(item({isBound=false}),context()).mark,'coin')
end)

test('GearQuest: ausencia, API incompleta y errores conservan utilidad', function()
    eq(ns.Classify(item(),context()).mark,'useful')
    for _, root in ipairs({false, {}, {Data={}}, {Data=true}, {Data={GearScoreMissText=true}}}) do
        GQ = root; eq(ns.Classify(item(),context()).mark,'useful')
    end
    gearQuest(MISS); GQ.Data.GearScoreMissText = function() error('sin datos') end
    eq(ns.Classify(item(),context()).mark,'useful')
end)

test('GearQuest: nil, vacío y respuestas no textuales conservan utilidad', function()
    gearQuest(nil); eq(ns.Classify(item(),context()).mark,'useful')
    for _, text in ipairs({'', false, 123, {}}) do
        gearQuest(text); eq(ns.Classify(item(),context()).mark,'useful')
    end
end)

test('GearQuest: respeta nivel futuro, protección, misión y profesión', function()
    gearQuest(MISS)
    eq(ns.Classify(item({reqLevel=21}),context()).mark,'useful')
    eq(ns.Classify(item(),context({overrides={[ID]='keep'}})).mark,'protected')
    eq(ns.Classify(item(),context({questItemsInLog={[ID]=true}})).mark,'quest')
    local tool = item({id=6256,subclassID=20})
    eq(ns.Classify(tool,context({professions={[356]=true}})).mark,'hammer_mine')
end)

test('GearQuest: no consulta grises, pendientes, sin enlace o regla apagada', function()
    local calls=0
    gearQuest(MISS); GQ.Data.GearScoreMissText = function() calls=calls+1; return MISS end
    eq(ns.Classify(item({quality=0}),context()).mark,'coin')
    eq(ns.Classify(item({pending=true}),context()).pending,true)
    local value=item(); value.link=nil
    eq(ns.Classify(value,context()).mark,'useful')
    ns.DB.rules.gearNotRanked=false
    eq(ns.Classify(item(),context()).mark,'useful')
    eq(calls,0)
end)

for _, equipLoc in ipairs({'INVTYPE_TRINKET','INVTYPE_TABARD','INVTYPE_BODY','INVTYPE_BAG',''}) do
    local slot = equipLoc
    test('GearQuest: excluye ubicación ' .. slot, function()
        gearQuest(MISS)
        local result=ns.Classify(item({equipLoc=slot}),context())
        eq(result.mark,'useful'); eq(reason(result),nil)
    end)
end

test('GearQuest: admite anillos y armadura, excluye otras clases y sin ubicación', function()
    gearQuest(MISS)
    eq(ns.Classify(item({classID=4,subclassID=0,equipLoc='INVTYPE_FINGER'}),context()).mark,'coin')
    eq(ns.Classify(item({classID=4,subclassID=4,equipLoc='INVTYPE_CHEST'}),context()).mark,'coin')
    eq(ns.Classify(item({classID=15}),context()).mark,'useful')
    local value=item(); value.equipLoc=nil
    eq(ns.Classify(value,context()).mark,'useful')
end)

test('GearQuest: conjuntos modernos y piezas de set conservan utilidad', function()
    gearQuest(MISS)
    C_EquipmentSet = { GetEquipmentSetIDs=function() return {7} end,
        GetItemIDs=function(set) eq(set,7); return {[16]=ID} end }
    eq(ns.Classify(item(),context()).mark,'useful')
    C_EquipmentSet.GetItemIDs=function() return {[16]=123} end
    eq(ns.Classify(item(),context()).mark,'coin')
    eq(ns.Classify(item({isSetPiece=true}),context()).mark,'useful')
end)

test('GearQuest: conjuntos clásicos y API fallida conservan utilidad', function()
    gearQuest(MISS)
    GetNumEquipmentSets=function() return 1 end
    GetEquipmentSetInfo=function(index) eq(index,1); return 'Tanque' end
    GetEquipmentSetItemIDs=function(name) eq(name,'Tanque'); return {ID} end
    eq(ns.Classify(item(),context()).mark,'useful')
    GetEquipmentSetItemIDs=function() error('sin datos') end
    eq(ns.Classify(item(),context()).mark,'useful')
end)

test('GearQuest: sin enumeración disponible omite la consulta de conjuntos', function()
    gearQuest(MISS)
    GetEquipmentSetItemIDs=function() error('sin enumeración no debe llamarse') end
    eq(ns.Classify(item(),context()).mark,'coin')
end)

test('GearQuest: diario incompleto o efecto desconocido conservan utilidad', function()
    gearQuest(MISS)
    eq(ns.Classify(item(),context({questLogIncomplete=true})).mark,'useful')
    eq(ns.Classify(item({effect='unknown'}),context()).mark,'useful')
end)

test('GearQuest: ReadLink conserva el enlace y el tooltip muestra el motivo', function()
    gearQuest(MISS)
    FAKE.items[ID]={name='Espada',quality=2,price=50,classID=2,subclassID=7,equipLoc='INVTYPE_WEAPON'}
    local link=FAKE.linkOf(ID)
    eq(ns.Player.ReadLink(ID).link,link)
    eq(ns.Player.ReadLink('item:' .. ID .. ':0:0:0:0:0:123').link,'item:' .. ID .. ':0:0:0:0:0:123')
    GQ.Data.GearScoreMissText=function(self,value) eq(value,link); return MISS end
    -- El tooltip usa el contexto real del jugador simulado: GearQuest lo refleja sin simulación.
    local previousLevel = UnitLevel
    UnitLevel = function() return 20 end
    if ns.Player.Invalidate then ns.Player.Invalidate() end
    GQ.GetEffectiveLevel=function() return 20 end
    GQ.GetEffectiveClass=function() return select(2, UnitClass('player')) end
    local found=false
    for _, line in ipairs(ns.Tooltip.Lines(link,true)) do
        if line.text == ns.L['Not useful to you: %s']:format(MISS) then found=true end
    end
    UnitLevel = previousLevel
    if ns.Player.Invalidate then ns.Player.Invalidate() end
    ok(found,'falta motivo en tooltip')
end)

test('GearQuest: casilla y estado dentro de la pestaña Reglas', function()
    local panel=ns.Options.Build(); panel:SetSize(650,500); panel:Show()
    ok(panel.checks['rules.gearNotRanked']); eq(panel.checks['rules.gearNotRanked']:GetChecked(),true)
    local found=false
    for _, row in ipairs(ns.Options.TOGGLES) do
        if row.path=='rules.gearNotRanked' then eq(row.section,'Rules'); found=true end
    end
    ok(found)
    eq(panel.gearQuestStatus:GetText(),ns.L['GearQuest detected: %s']:format(ns.L['no']))
    gearQuest(MISS); ns.Options.Refresh()
    eq(panel.gearQuestStatus:GetText(),ns.L['GearQuest detected: %s']:format(ns.L['yes']))
end)

test('GearQuest: traducciones en castellano e inglés', function()
    local saved=ns.L
    for _, locale in ipairs({'esES','enUS'}) do
        FAKE.locale=locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk',ns)
        eq(ns.L['Not useful to you: %s'],locale=='enUS' and 'Not useful to you: %s' or 'No te sirve: %s')
    end
    ns.L=saved; FAKE.locale=nil
end)

test('GearQuest: sin filas para el ítem (base sin cargar o ítem desconocido) el texto no cuenta', function()
    gearQuest('GearQuest is not scoring this item for your class.')
    GQ.Data.GetEntriesByItemId = function() return {} end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.Data.GetEntriesByItemId = nil
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.Data.GetEntriesByItemId = function() error('sin base') end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ = nil
end)

test('GearQuest: fila puntuada para el enlace = te sirve, aunque haya texto de diagnóstico (revisión de release, crítico)', function()
    gearQuest(MISS)
    GQ.Data.EntryForItemLink = function() return { pipelineScore = 100 } end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.Data.EntryForItemLink = function() error('sin datos') end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.Data.EntryForItemLink = nil
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ = nil
end)

test('GearQuest: simulación activa o perfil distinto al personaje real no decide nada', function()
    gearQuest(MISS)
    GQ.IsPreviewEnabled = function() return true end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.IsPreviewEnabled = function() return false end
    GQ.GetEffectiveClass = function() return 'MAGE' end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.GetEffectiveClass = function() return 'WARRIOR' end
    GQ.GetEffectiveLevel = function() return 35 end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.GetEffectiveLevel = nil
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'useful')
    GQ.GetEffectiveLevel = function() return 20 end
    eq(ns.Classify(item({ isBound = true, price = 50 }), context()).mark, 'coin')
    GQ = nil
end)
