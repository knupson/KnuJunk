local ID = 990101
local function item(fields)
    local value = { id=ID, quality=1, classID=15, subclassID=0, price=10 }
    for k,v in pairs(fields or {}) do value[k]=v end
    return value
end
local function context(fields)
    local value = {class='MAGE', professions={}, overrides={}, questItemsInLog={}, questInLog=function() return false end}
    for k,v in pairs(fields or {}) do value[k]=v end
    return value
end
local function auction(price)
    Auctionator = {API={v1={GetAuctionPriceByItemID=function(caller,id)
        eq(caller,'KnuJunk'); eq(id,ID); return price
    end}}}
end
local function withMaterial(fn)
    local old=ns.Data.reagents
    ns.Data.reagents={[ID]={164}}
    local success,err=pcall(fn)
    ns.Data.reagents=old
    if not success then error(err) end
end
local function bag(fields)
    FAKE.items[ID] = item(fields); FAKE.items[ID].name='Prueba'
    FAKE.bags['0:1']=ID
    return CreateFrame('Button')
end

test('íconos: tecla alterna protegido y automático y limpia vender viejo',function()
    eq(ns.Overrides.Cycle(ID),'keep')
    eq(ns.Classify(item(),context{overrides=ns.DB.overrides}).mark,'protected')
    eq(ns.Overrides.Cycle(ID),nil)
    ns.DB.overrides[ID]='sell'; eq(ns.Overrides.Cycle(ID),nil)
end)

test('íconos: prioridad protegido, misión, profesión, subasta, moneda',function()
    auction(1000)
    withMaterial(function()
        local c=context{professions={[164]=true},questItemsInLog={[ID]=true},overrides={[ID]='keep'}}
        eq(ns.Classify(item{quality=0},c).mark,'protected')
        c.overrides={}; eq(ns.Classify(item{quality=0},c).mark,'quest')
        c.questItemsInLog={}; eq(ns.Classify(item{quality=0},c).mark,'hammer_mine')
        c.professions={}; eq(ns.Classify(item{quality=0},c).mark,'hammer_other')
    end)
    eq(ns.Classify(item{quality=0},context()).mark,'auction')
    Auctionator=nil; eq(ns.Classify(item{quality=0},context()).mark,'coin')
end)

for _, kind in ipairs(ns.IconKinds) do
    test('íconos: interruptor independiente de '..kind,function()
        local texture=CreateFrame('Texture')
        for _, other in ipairs(ns.IconKinds) do ns.DB.show[other]=true end
        ok(ns.Marks.Style(texture,kind))
        ns.Options.Set('show.'..kind,false)
        eq(ns.Marks.Style(texture,kind),false)
        for _, other in ipairs(ns.IconKinds) do
            if other ~= kind then ok(ns.Marks.Style(texture,other),other..' sigue visible') end
        end
    end)
end

for _, quality in ipairs({0,1,2,3,4,5}) do
    test('íconos: ítem legible de calidad '..quality..' siempre tiene marca',function()
        ok(ns.Classify(item{quality=quality},context()).mark)
    end)
end

test('íconos: pendientes y sin identidad no reciben marca',function()
    eq(ns.Classify(item{pending=true},context()).mark,nil)
    local unloaded=item(); unloaded.quality=nil
    local result=ns.Classify(unloaded,context()); eq(result.mark,nil); eq(result.pending,true)
    eq(ns.Classify({},context()).mark,nil)
end)

test('íconos: gris o misión sin precio distingue cero de desconocido',function()
    for _, class in ipairs({12,15}) do
        local value=item{classID=class,quality=0,price=0}
        eq(ns.Classify(value,context()).mark,'trash')
        value.price=nil; eq(ns.Classify(value,context()).mark,'useful')
        value.price=1; eq(ns.Classify(value,context()).mark,'coin')
    end
    eq(ns.Classify(item{price=0},context()).mark,'useful')
end)

for _, price in ipairs({0,10}) do
    test('íconos: regla de oro impide basura y moneda con precio '..price,function()
        local value=item{quality=0,price=price}
        eq(ns.Classify(value,context{questLogIncomplete=true}).mark,'useful')
        eq(ns.Classify(value,context{questieUses=function() return {{questID=1}} end,questInLog=function() return nil end}).mark,'useful')
        value.effect='unknown'; eq(ns.Classify(value,context()).mark,'useful')
    end)
end

test('subasta: ausente, API incompleta, error y valores inválidos',function()
    for _, root in ipairs({{}, {API={}}, {API={v1={}}}}) do
        Auctionator=root; eq(ns.Classify(item(),context()).mark,'useful')
    end
    Auctionator={API={v1={GetAuctionPriceByItemID=function() error('simulado') end}}}
    eq(ns.Classify(item(),context()).mark,'useful')
    for _, value in ipairs({'100',false,-1,0/0,math.huge}) do
        auction(value); eq(ns.Classify(item(),context()).mark,'useful')
    end
    auction(nil); eq(ns.Classify(item(),context()).mark,'useful')
end)

test('subasta: umbrales inclusivos, factor, mínimo y ligadura',function()
    auction(99); eq(ns.Classify(item{price=50},context()).mark,'useful')
    auction(100); eq(ns.Classify(item{price=50},context()).mark,'auction')
    eq(ns.Classify(item{price=51},context()).mark,'useful')
    eq(ns.Classify(item{isBound=true},context()).mark,'useful')
    eq(ns.Classify(item{isBound=false},context()).mark,'auction')
    ns.DB.auction.factor=3
    eq(ns.Classify(item{price=50},context()).mark,'useful')
    auction(150); eq(ns.Classify(item{price=50},context()).mark,'auction')
    ns.DB.auction.minCopper=151; eq(ns.Classify(item{price=50},context()).mark,'useful')
end)

test('subasta: equipo de otra clase comerciable, ligado y override viejo',function()
    auction(1000)
    local value=item{quality=2,classID=4,subclassID=4,isBound=false}
    eq(ns.Classify(value,context()).mark,'auction')
    value.isBound=true; eq(ns.Classify(value,context()).mark,'coin')
    value.isBound=false
    eq(ns.Classify(value,context{overrides={[ID]='sell'}}).mark,'coin')
end)

test('íconos: migración vieja respeta moneda, martillos y botín',function()
    KnuJunkDB={show={coin=false,hammer=false,loot=false}}
    FAKE.Fire('ADDON_LOADED','KnuJunk')
    eq(ns.DB.show.coin,false); eq(ns.DB.show.hammer_mine,false); eq(ns.DB.show.hammer_other,false)
    eq(ns.DB.show.loot,false); eq(ns.DB.show.quest,true)
    ns.DB.show.hammer_mine=true; FAKE.Fire('ADDON_LOADED','KnuJunk')
    eq(ns.DB.show.hammer_mine,true); eq(ns.DB.show.hammer_other,false)
    eq(ns.DB.show.hammer,nil)
end)

test('íconos: valores nuevos ganan sobre martillo viejo',function()
    KnuJunkDB={show={hammer=false,hammer_mine=true}}
    FAKE.Fire('ADDON_LOADED','KnuJunk')
    eq(ns.DB.show.hammer_mine,true); eq(ns.DB.show.hammer_other,false)
end)

test('íconos: tamaño, alfa, esquinas y fondo sobre textura de bolsa',function()
    local button=bag()
    for _, corner in ipairs({'TOPLEFT','TOPRIGHT','BOTTOMLEFT','BOTTOMRIGHT'}) do
        ns.Options.SetValue('icons.corner',corner)
        ns.Options.SetValue('icons.size',32); ns.Options.SetValue('icons.opacity',.3)
        ns.Marks.Update(button,0,1)
        eq(button.KnuJunkMark.w,32); eq(button.KnuJunkMark.h,32); eq(button.KnuJunkMark.alpha,.3)
        eq(button.KnuJunkMark.points[1][1],corner); eq(#button.KnuJunkMark.points,1)
        ok(button.KnuJunkBackground:IsShown()); eq(button.KnuJunkBackground.alpha,.3)
    end
    ns.Options.Set('icons.background',false); ns.Marks.Update(button,0,1)
    eq(button.KnuJunkBackground:IsShown(),false)
    ns.Marks.Clear(button); eq(button.KnuJunkMark:IsShown(),false)
end)

test('íconos: tamaño, alfa, fondo y color en widget de esquina',function()
    local widget=ns.Marks.CreateWidget(CreateFrame('Button'))
    ns.Options.SetValue('icons.size',23); ns.Options.SetValue('icons.opacity',.7)
    ns.Options.SetColor('protected',.1,.2,.3)
    ok(ns.Marks.Style(widget,'protected'))
    eq(widget.w,23); eq(widget.Icon.w,23); eq(widget.Icon.alpha,.7)
    eq(widget.Icon.vertex[1],.1); eq(widget.Icon.vertex[2],.2); eq(widget.Icon.vertex[3],.3)
    eq(widget.Background:IsShown(),true)
    ns.Options.Set('icons.background',false); ns.Marks.Style(widget,'useful')
    eq(widget.Background:IsShown(),false)
    ns.Options.RestoreColors(); eq(ns.DB.icons.colors.protected[1],111/255)
    eq(ns.IconColors.protected[1],111/255)
end)

test('íconos: controles numéricos validan y aplican límites',function()
    ns.Options.SetValue('icons.size',100); eq(ns.DB.icons.size,32)
    ns.Options.SetValue('icons.opacity',0); eq(ns.DB.icons.opacity,.3)
    eq(ns.Options.SetValue('icons.corner','INVALID'),false)
    eq(ns.Options.SetValue('auction.factor',0/0),false)
    eq(ns.Options.SetValue('icons.size','12'),false)
    eq(ns.Options.SetColor('coin',nil,1,1),false)
    eq(ns.Options.SetColor('coin',1,2,1),false)
end)

test('íconos: estilo de moneda propio y atlas Blizzard',function()
    local texture=CreateFrame('Texture')
    ns.Options.SetValue('icons.coinStyle','KnuJunk'); ns.Marks.Style(texture,'coin')
    eq(texture.texture,ns.Marks.TEXTURES.coin)
    local old=C_Texture
    C_Texture={GetAtlasInfo=function() return {} end}
    ns.Options.SetValue('icons.coinStyle','Blizzard'); ns.Marks.Style(texture,'coin')
    eq(texture.atlas,ns.Marks.COIN_ATLAS); eq(texture.w,14)
    C_Texture=old
end)

test('Baganator: un widget visible y alias viejos inertes sin autoinserción',function()
    local state=FAKE.InstallBaganator(); ns.Bags.InstallAll()
    eq(state.widgets.knujunk_icon.label,'KnuJunk')
    eq(state.widgets.knujunk_icon.defaultPosition.corner,'top_right')
    for _, id in ipairs({'knujunk_coin','knujunk_hammer'}) do
        eq(state.widgets[id].defaultPosition,nil)
        eq(state.widgets[id].onUpdate(CreateFrame('Texture'),{}),false)
    end
end)

test('íconos: leyendas y colores en ambos idiomas',function()
    local savedL=ns.L
    local success,err=pcall(function()
        for _, locale in ipairs({'esES','esMX','enUS'}) do
            FAKE.locale=locale; assert(loadfile('Locales/Locales.lua'))('KnuJunk',ns)
            bag(); ns.DB.overrides[ID]='keep'
            ns.Options.SetColor('protected',.1,.2,.3)
            local lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(lines[1].text,ns.L['Icon: %s']:format(ns.L['Protected']))
            eq(lines[1].r,.1); eq(lines[1].g,.2); eq(lines[1].b,.3)
            eq(ns.L['Protected: %s'],locale=='enUS' and 'Protected: %s' or 'Protegido: %s')
            eq(ns.L['Automatic: %s'],locale=='enUS' and 'Automatic: %s' or 'Automático: %s')
            ns.DB.overrides[ID]=nil
            auction(120); lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            ok(lines[1].text:find(ns.L['%dg %ds %dc']:format(0,1,20),1,true)); ok(lines[1].text:find(ns.L['%dg %ds %dc']:format(0,0,10),1,true))
            eq(lines[1].r,194/255)
        end
    end)
    ns.L,FAKE.locale=savedL,nil
    if not success then error(err) end
end)

test('íconos: generador entrega TGA 32x32 RGBA sin compresión',function()
    for _, kind in ipairs({'protected','quest','auction','coin','trash','useful','fondo'}) do
        local file=assert(io.open('media/'..kind..'.tga','rb'))
        local data=file:read('*a'); file:close()
        eq(#data,18+32*32*4)
        local h={data:byte(1,18)}
        eq(h[1],0); eq(h[2],0); eq(h[3],2)
        eq(h[13]+256*h[14],32); eq(h[15]+256*h[16],32)
        eq(h[17],32); eq(h[18],40)
    end
end)

test('íconos: leyenda de cada marca y motivos conservados',function()
    local labels={protected='Protected',quest='Active quest',hammer_mine='Your profession material',
        hammer_other='Other profession material',coin='Sell',trash='Trash (cannot be sold)',useful='Useful'}
    bag()
    local saved=ns.Classify
    local success,err=pcall(function()
        for mark,label in pairs(labels) do
            ns.Classify=function() return {mark=mark,reasons={{kind='key'}}} end
            local lines=ns.Tooltip.Lines(FAKE.linkOf(ID))
            eq(#lines,2); eq(lines[1].text,ns.L['Icon: %s']:format(ns.L[label]))
            eq(lines[1].r,ns.Marks.Color(mark)[1]); eq(lines[2].text,ns.L['Key: opens a lock; keep it'])
        end
    end)
    ns.Classify=saved
    if not success then error(err) end
end)

test('íconos: prioridad misión activa sobre libro especial',function()
    local saved=ns.Data.libraryBooks
    ns.Data.libraryBooks={[ID]=true}
    local success,err=pcall(function()
        eq(ns.Classify(item(),context{questItemsInLog={[ID]=true}}).mark,'quest')
        eq(ns.Classify(item(),context()).mark,'useful')
    end)
    ns.Data.libraryBooks=saved
    if not success then error(err) end
end)

test('subasta: regla de oro conserva útil aunque haya cotización',function()
    auction(10000)
    eq(ns.Classify(item{effect='unknown'},context()).mark,'useful')
    eq(ns.Classify(item(),context{questLogIncomplete=true}).mark,'useful')
    eq(ns.Classify(item(),context{questieUses=function() return {{questID=1}} end,
        questInLog=function() return nil end}).mark,'useful')
end)

test('íconos: sliders y radios aplican inmediatamente sin superponer anclas',function()
    local panel=ns.Options.Build(); panel:Show()
    panel.controls['icons.size'].widget:SetValue(19)
    eq(ns.DB.icons.size,19)
    panel.controls['icons.opacity'].widget:SetValue(65)
    eq(ns.DB.icons.opacity,.65)
    panel.controls['auction.factor'].widget:SetValue(2.5)
    eq(ns.DB.auction.factor,2.5)
    panel.controls['auction.minCopper'].widget:SetValue(3)
    eq(ns.DB.auction.minCopper,300)
    local radio=panel.controls['icons.cornerBOTTOMLEFT'].widget
    radio:GetScript('OnClick')(radio); eq(ns.DB.icons.corner,'BOTTOMLEFT')
    ok(radio:GetChecked())
    ok(panel.controls['icons.size'].widget.points[1][2] ~= panel.title)
    ok(panel.viewport.scrollChild == panel.content)
end)

test('íconos: selector moderno aplica y cancela color sin compartir defaults',function()
    local options
    ColorPickerFrame={SetupColorPickerAndShow=function(_,value) options=value end,
        GetColorRGB=function() return .1,.2,.3 end}
    local panel=ns.Options.Build(); panel:Show()
    local swatch=panel.swatches.protected
    ok(swatch); swatch:GetScript('OnClick')(swatch)
    eq(options.hasOpacity,false); eq(options.r,111/255)
    options.swatchFunc(); eq(ns.DB.icons.colors.protected[1],.1)
    eq(ns.IconColors.protected[1],111/255)
    options.cancelFunc(); eq(ns.DB.icons.colors.protected[1],111/255)
    panel.restoreColors:GetScript('OnClick')()
end)

test('íconos: selector clásico y API ausente',function()
    local shown=0
    ColorPickerFrame={GetColorRGB=function() return .4,.5,.6 end,SetColorRGB=function() end,
        Show=function() shown=shown+1 end,Hide=function() end}
    local panel=ns.Options.Build()
    panel.swatches.quest:GetScript('OnClick')()
    eq(shown,1); ColorPickerFrame.func(); eq(ns.DB.icons.colors.quest[1],.4)
    ColorPickerFrame.cancelFunc(); eq(ns.DB.icons.colors.quest[1],242/255)
    ns.Options.ResetState(); ColorPickerFrame={}
    panel=ns.Options.Build(); eq(next(panel.swatches),nil)
end)

test('íconos: defaults completos y color propio del martillo ajeno',function()
    eq(ns.DB.icons.size,14); eq(ns.DB.icons.opacity,1); eq(ns.DB.icons.corner,'TOPRIGHT')
    eq(ns.DB.icons.background,true); eq(ns.DB.auction.factor,2); eq(ns.DB.auction.minCopper,100)
    for _, kind in ipairs(ns.IconKinds) do eq(ns.DB.show[kind],true) end
    eq(ns.DB.icons.colors.hammer_other[2],154/255)
    ns.DB.icons.colors.coin[1]=.2; eq(ns.IconColors.coin[1],1)
end)

test('íconos: ocultar botín no oculta misión en bolsa',function()
    local button=bag(); ns.DB.show.loot=false
    ns.DB.overrides[ID]='keep'
    ns.Marks.Update(button,0,1); ok(button.KnuJunkMark:IsShown())
    ns.Marks.UpdateLink(button,FAKE.linkOf(ID)); eq(button.KnuJunkMark:IsShown(),false)
    eq(button.KnuJunkBackground:IsShown(),false)
end)

test('Baganator: gris usa widget propio si la moneda nativa está desactivada',function()
    local state=FAKE.InstallBaganator(); ns.Bags.InstallAll()
    bag{quality=0}; state.activeJunk='knujunk'; state.activeWidgets.junk=false
    local entry=state.widgets.knujunk_icon
    local widget=entry.onInit(CreateFrame('Button'))
    local details={itemID=ID,itemLocation={bagID=0,slotIndex=1}}
    eq(entry.onUpdate(widget,details),true)
    state.activeWidgets.junk=true
    eq(entry.onUpdate(widget,details),false)
end)
