local _, ns = ...

-- Panel de opciones de KnuJunk (Esc > Opciones > AddOns > KnuJunk, o /knu junk).
-- Interruptores de la DB (enabled, show.*, rules.*), lista de marcas manuales (overrides) con "Quitar" y
-- el estado de los datos. Todo son frames comunes (nada seguro, nada protegido); cada cambio pasa por
-- ns.Changed, el mismo camino que los comandos. Estilo de KnuLib (StylePanel, StyleCheck, StyleButton).
local Options = {}
ns.Options = Options

local PAD, ROW_H, MAX_ROWS, DEFAULT_ROWS = 16, 24, 14, 6

local function L(key) return ns.L[key] end

-- Cada interruptor: ruta en ns.DB, texto y ayuda de una linea (claves en ingles, ver Locales.lua).
Options.TOGGLES = {
    { section = 'Marks', path = 'enabled', label = 'Enable KnuJunk',
        help = 'Master switch: turns icons, merchant protection and automatic selling off.' },
    { section = 'Marks', path = 'protectKeep', label = 'Protect protected items at the merchant',
        help = 'Locks them while the merchant is open; right-click asks before selling.' },
    { section = 'Marks', path = 'show.loot', label = 'Marks in loot',
        help = 'The same icons in the loot window (with autoloot there is no window).' },
    { section = 'Rules', path = 'rules.sellUnruled', label = 'Sell items with no rule',
        help = 'What no rule classifies is sold, except gear, bags, openable items, ammunition, books, keys, quest items and rare or epic items.' },
    { section = 'Rules', path = 'rules.armorBelow', label = 'Armor below what you wear',
        help = 'Sells white or green cloth, leather or mail armor when you already wear a higher armor type in that slot. Ignores cloaks, rings and shields. Does not sell green items if you have Enchanting.' },
    { section = 'Rules', path = 'rules.gearNoRanking', label = 'Gear with no ranking (GearQuest, Pawn)',
        help = 'Gear that neither GearQuest nor Pawn (for your spec) needs and that does not beat what you wear is sold.' },
    { section = 'Rules', path = 'rules.food', label = 'Outleveled food and drink',
        help = 'Coin on simple food and drink 15 or more levels above the requirement when you carry a better one. Never for hunters.' },
    { section = 'Rules', path = 'rules.ammo', label = 'Outdamaged ammunition',
        help = 'Coin on ordinary arrows or bullets when you carry a usable stack of the same kind with more damage. Keeps the equipped one and a compatible stack.' },
    { section = 'Rules', path = 'rules.knownRecipe', label = 'Recipes already learned',
        help = 'Coin on recipes you already know, only if bound and with a sell price. Unbound: no coin; the tooltip says you can pass it on or auction it.' },
    { section = 'Rules', path = 'rules.gearNotRanked', label = 'Gear not useful to you (GearQuest)',
        help = 'Coin on weapons and armor GearQuest does not rank for your class, specialization or level. Does nothing without GearQuest.' },
}

local ICON_LABELS = { protected = 'Protected', quest = 'Active quest', hammer_mine = 'Your profession material',
    hammer_other = 'Other profession material', auction = 'Auction', coin = 'Coin', trash = 'Trash (cannot be sold)',
    useful = 'Useful', unruled = 'Missing data' }
local ICON_HELPS = {
    unruled = 'The game has not sent all the item data yet: it is not sold until it does. Hover to see what is missing.',
}
for index, kind in ipairs(ns.IconKinds) do
    table.insert(Options.TOGGLES, 3 + index, { section = 'Icons', path = 'show.' .. kind, label = ICON_LABELS[kind], help = ICON_HELPS[kind] })
end
table.insert(Options.TOGGLES, 3 + #ns.IconKinds + 1, { section = 'Icons', path = 'icons.background', label = 'Dark background behind the icon', help = 'Helps distinguish the icon from the item.' })
Options.TOGGLES[#Options.TOGGLES + 1] = { section = 'General', path = 'autoSell.enabled', label = 'Automatic selling',
    help = 'Opening a merchant sells only items with a coin icon. Never protected items.' }
Options.TOGGLES[#Options.TOGGLES + 1] = { section = 'General', path = 'autoSell.graysOnly', label = 'Grays only',
    help = 'Automatically sell only poor-quality items with a coin icon.' }
Options.TOGGLES[#Options.TOGGLES + 1] = { section = 'General', path = 'autoRepair.enabled', label = 'Automatic repairs',
    help = 'Opening a repair merchant repairs all your gear. Hold Shift when opening to skip repairs.' }
Options.TOGGLES[#Options.TOGGLES + 1] = { section = 'General', path = 'autoRepair.guild', label = 'Use guild funds',
    help = 'Use the guild bank first if allowed; pay the rest with your own money.' }

Options.TOGGLES[#Options.TOGGLES + 1] = { section = 'General', path = 'lootAdvisor.enabled', label = 'Loot advisor when bags are full',
    help = 'When bags are full, hold Shift in the loot window to see what to drop or whether looting is worth it.' }

-- Valor de una ruta de ns.DB ('show.coin'); nil si falta algun tramo.
local function lookup(path)
    local value = ns.DB
    for key in path:gmatch('[^.]+') do
        if type(value) ~= 'table' then return nil end
        value = value[key]
    end
    return value
end

local function known(path)
    for _, toggle in ipairs(Options.TOGGLES) do if toggle.path == path then return true end end
    return false
end

function Options.Get(path) return lookup(path) == true end

-- Cambia un interruptor y refresca (como los comandos). Ruta desconocida o mismo valor: nada.
function Options.Set(path, value)
    if not known(path) then return false end
    value = value and true or false
    if Options.Get(path) == value then return false end
    local target, last = ns.DB, nil
    for key in path:gmatch('[^.]+') do
        if last then
            if type(target[last]) ~= 'table' then target[last] = {} end
            target = target[last]
        end
        last = key
    end
    target[last] = value
    ns.Changed()
    return true
end

-- Filas de la lista de marcas manuales: { id =, action = 'keep'|'sell' }, por itemID.
function Options.OverrideRows()
    local rows = {}
    for id, action in pairs(ns.DB.overrides or {}) do
        if type(id) == 'number' then rows[#rows + 1] = { id = id, action = action } end
    end
    table.sort(rows, function(a, b) return a.id < b.id end)
    return rows
end

-- Quita la marca manual de un item (igual que /knu junk clear). false si no tenia.
function Options.RemoveOverride(id)
    local overrides = ns.DB.overrides
    if not overrides or overrides[id] == nil then return false end
    ns.Overrides.Set(id, nil)
    return true
end

-- Cuantas filas entran en un alto dado; sin alto todavia (0 o nil) se usa un valor por defecto.
function Options.VisibleRows(height)
    if type(height) ~= 'number' or height <= 0 then return DEFAULT_ROWS end
    -- Solo las filas que entran de verdad (al menos una); el resto se recorre con la barra.
    return math.max(1, math.min(MAX_ROWS, math.floor(height / ROW_H)))
end
Options.MAX_ROWS = MAX_ROWS

-- Los mismos datos que /knu junk status: build de datos, QuestieDB, adaptadores de bolsas y marcas manuales.
function Options.StatusInfo()
    local questie, ready = ns.Questie, false
    local available = questie and questie.Available and questie.Available() or false
    if available then ready = questie.IsReady and questie.IsReady() or false end
    local count = 0
    for _ in pairs(ns.DB.overrides or {}) do count = count + 1 end
    return {
        build = tostring(ns.Data and ns.Data.build or '?'),
        questie = available and true or false,
        ready = ready and true or false,
        adapters = ns.Bags and ns.Bags.Installed and ns.Bags.Installed() or {},
        overrides = count,
    }
end

-- Nombre, icono y calidad de un item; el nombre es nil si el cliente aun no lo tiene (se pide).
function Options.ItemInfo(id)
    local name, icon, quality
    local getInfo = (type(GetItemInfo) == 'function' and GetItemInfo)
        or (type(C_Item) == 'table' and C_Item.GetItemInfo) or nil
    if getInfo then
        local ok, n, _, q, _, _, _, _, _, _, i = pcall(getInfo, id)
        if ok then name, quality, icon = n, q, i end
    end
    if not icon then
        local getIcon = (type(C_Item) == 'table' and C_Item.GetItemIconByID) or GetItemIcon
        if type(getIcon) == 'function' then
            local ok, i = pcall(getIcon, id)
            if ok then icon = i end
        end
    end
    if not name and type(C_Item) == 'table' and type(C_Item.RequestLoadItemDataByID) == 'function' then
        pcall(C_Item.RequestLoadItemDataByID, id)
    end
    return name, icon, quality
end

-- Tema de KnuLib (con colores propios si la copia cargada no trae GetTheme).
local FALLBACK = {
    accent = { r = 1, g = 0.659, b = 0.18, a = 1 }, accentHi = { r = 1, g = 0.753, b = 0.416, a = 1 },
    accentDim = { r = 0.69, g = 0.455, b = 0.157, a = 1 }, text = { r = 0.925, g = 0.851, b = 0.741, a = 1 },
    muted = { r = 0.659, g = 0.561, b = 0.439, a = 1 }, border = { r = 0.2, g = 0.145, b = 0.102, a = 1 },
    backdrop = { r = 0.122, g = 0.086, b = 0.055, a = 1 },
}
local function theme()
    local KL = ns.KL
    if KL and KL.GetTheme then
        local ok, value = pcall(KL.GetTheme, KL)
        if ok and type(value) == 'table' then return value end
    end
    return FALLBACK
end
local function fontPath()
    local KL = ns.KL
    if KL and KL.GetFont then
        local ok, path = pcall(KL.GetFont, KL)
        if ok and path then return path end
    end
    return STANDARD_TEXT_FONT
end
local function style(method, frame)
    local KL = ns.KL
    if KL and KL[method] then pcall(KL[method], KL, frame) end
end

local function color(role, alpha)
    local c = theme()[role] or FALLBACK[role]
    return c.r, c.g, c.b, alpha or c.a or 1
end

-- Pinta (o repinta con otro tema) todo lo que el panel registro: textos, lineas y la barra de scroll.
local function paint(panel)
    for _, entry in ipairs(panel.painted) do
        local r, g, b, a = color(entry.role, entry.alpha)
        if entry.kind == 'text' then
            entry.target:SetFont(fontPath(), entry.size, '')
            entry.target:SetTextColor(r, g, b, a)
        elseif entry.target.SetColorTexture then
            entry.target:SetColorTexture(r, g, b, a)
        else
            entry.target:SetTexture('Interface\\Buttons\\WHITE8X8')
            entry.target:SetVertexColor(r, g, b, a)
        end
    end
    if panel.thumb then panel.thumb:SetVertexColor(color('accent', 0.8)) end
end

local function track(panel, kind, target, role, size, alpha)
    panel.painted[#panel.painted + 1] = { kind = kind, target = target, role = role, size = size, alpha = alpha }
    return target
end

local function newText(panel, parent, size, role)
    local text = parent:CreateFontString(nil, 'OVERLAY')
    text:SetJustifyH('LEFT')
    track(panel, 'text', text, role, size)
    local r, g, b, a = color(role)
    text:SetFont(fontPath(), size, '')
    text:SetTextColor(r, g, b, a)
    return text
end

-- Filas independientes: siempre usan el ancho de su propia columna.
local GAP, HEADER_GAP = 8, 16
local function row(panel, tab, layout, header)
    local page = panel.tabs[tab]
    local frame = CreateFrame('Frame', nil, page.content)
    frame.layout, frame.before = layout, header and HEADER_GAP or GAP
    page.rows[#page.rows + 1] = frame
    return frame
end

-- Medir despues de fijar texto y ancho. La sangria es relativa a la fila.
local function wrapped(text, parent, width, indent, right, y)
    indent, right, y = indent or 0, right or 0, y or 0
    text:ClearAllPoints()
    text:SetPoint('TOPLEFT', parent, 'TOPLEFT', indent, -y)
    text:SetWidth(math.max(1, width - indent - right))
    text:SetWordWrap(true)
    text:SetJustifyH('LEFT')
    text:SetJustifyV('TOP')
    local height = text:GetStringHeight()
    text:SetHeight(height)
    return height
end

local function controlLine(panel, tab, text, role)
    local label
    local frame = row(panel, tab, function(self, width) return wrapped(label, self, width) end)
    label = newText(panel, frame, 12, role or 'text')
    label:SetText(text)
    return label
end

local colorPicker
local function toggleRow(panel, toggle)
    local tab = toggle.section == 'Marks' and 'General' or toggle.section
    local frame = row(panel, tab)
    local check = CreateFrame('CheckButton', nil, frame, 'UICheckButtonTemplate')
    check:SetSize(22, 22)
    check:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
    style('StyleCheck', check)
    local label = newText(panel, frame, 13, 'text')
    label:SetText(L(toggle.label))
    check.label, check.row = label, frame
    if toggle.help then
        check.help = newText(panel, frame, 11, 'muted')
        check.help:SetText(L(toggle.help))
    end
    check:SetScript('OnClick', function(self) Options.Set(toggle.path, self:GetChecked() and true or false) end)
    local kind = toggle.path:match('^show%.(.+)$')
    local swatch
    if ICON_LABELS[kind] then
        local picker = rawget(_G, 'ColorPickerFrame')
        if picker and type(picker.GetColorRGB) == 'function'
            and (type(picker.SetupColorPickerAndShow) == 'function' or type(picker.SetColorRGB) == 'function') then
            swatch = CreateFrame('Button', nil, frame)
            swatch:SetSize(22, 22)
            swatch:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
            swatch.fill = swatch:CreateTexture(nil, 'ARTWORK')
            swatch.fill:SetAllPoints(swatch)
            swatch:SetScript('OnClick', function() colorPicker(kind) end)
            panel.swatches[kind] = swatch
        end
    end
    frame.layout = function(self, width)
        local right = swatch and 30 or 0
        local height = math.max(22, wrapped(label, self, width, 26, right))
        check:SetHitRectInsets(0, -(width - 22 - right), 0, 0)
        if check.help then height = height + 4 + wrapped(check.help, self, width, 26, 0, height + 4) end
        return height
    end
    panel.checks[toggle.path] = check
end

local LIMITS = { ['autoSell.max'] = {1,12}, ['icons.size'] = {10,32}, ['icons.opacity'] = {.3,1},
    ['auction.factor'] = {1.5,5}, ['auction.minCopper'] = {0,1000000} }
local CHOICES = { ['icons.corner'] = { TOPLEFT=true, TOPRIGHT=true, BOTTOMLEFT=true, BOTTOMRIGHT=true },
    ['icons.coinStyle'] = { Blizzard=true, KnuJunk=true } }
function Options.SetValue(path, value)
    if LIMITS[path] then
        if type(value) ~= 'number' or value ~= value then return false end
        value = math.max(LIMITS[path][1], math.min(LIMITS[path][2], value))
        if path == 'autoSell.max' then value = math.floor(value) end
    elseif not (CHOICES[path] and CHOICES[path][value]) then return false end
    local group, key = path:match('^([^.]+)%.([^.]+)$')
    if ns.DB[group][key] == value then return false end
    ns.DB[group][key] = value
    ns.Changed()
    return true
end

function Options.SetColor(kind, r, g, b)
    if not ICON_LABELS[kind] then return false end
    for _, value in ipairs({r,g,b}) do
        if type(value) ~= 'number' or value ~= value or value < 0 or value > 1 then return false end
    end
    if r == nil or g == nil or b == nil then return false end
    ns.DB.icons.colors[kind] = {r,g,b}
    ns.Changed()
    return true
end

function Options.RestoreColors()
    for kind, color in pairs(ns.IconColors) do ns.DB.icons.colors[kind] = {color[1],color[2],color[3]} end
    ns.Changed()
end

function colorPicker(kind)
    local picker = rawget(_G, 'ColorPickerFrame')
    if not picker or type(picker.GetColorRGB) ~= 'function' then return false end
    local color, old = ns.Marks.Color(kind), ns.Marks.Color(kind)
    old = {old[1], old[2], old[3]}
    local function apply() Options.SetColor(kind, picker:GetColorRGB()) end
    local function cancel() Options.SetColor(kind, old[1],old[2],old[3]) end
    if type(picker.SetupColorPickerAndShow) == 'function' then
        return pcall(picker.SetupColorPickerAndShow, picker, { r=color[1], g=color[2], b=color[3],
            hasOpacity=false, swatchFunc=apply, cancelFunc=cancel })
    elseif type(picker.SetColorRGB) == 'function' and type(picker.Show) == 'function' then
        return pcall(function()
            picker:Hide()
            picker.hasOpacity, picker.func, picker.cancelFunc = false, apply, cancel
            picker:SetColorRGB(color[1], color[2], color[3])
            picker:Show()
        end)
    end
    return false
end

local function sliderRow(panel, tab, path, title, low, high, step, scale)
    local frame = row(panel, tab)
    local label = newText(panel, frame, 12, 'text')
    local slider = CreateFrame('Slider', nil, frame)
    slider:SetHeight(18)
    slider:SetOrientation('HORIZONTAL')
    slider:SetMinMaxValues(low, high); slider:SetValueStep(step); slider:SetObeyStepOnDrag(true)
    slider:SetThumbTexture('Interface\\Buttons\\WHITE8X8')
    slider:GetThumbTexture():SetSize(12,18)
    local rail = slider:CreateTexture(nil, 'BACKGROUND')
    rail:SetAllPoints(slider); rail:SetColorTexture(.3,.3,.3,.6)
    local function refreshValue()
        panel.updatingControls = true
        slider:SetValue(lookup(path) / scale)
        label:SetText(L(title) .. ': ' .. string.format('%g', lookup(path) / scale))
        panel.updatingControls = false
    end
    slider:SetScript('OnValueChanged', function(_, value)
        if panel.updatingControls then return end
        value = math.floor(value / step + .5) * step
        Options.SetValue(path, value * scale)
        refreshValue()
    end)
    frame.layout = function(self, width)
        local height = wrapped(label, self, width)
        slider:ClearAllPoints()
        slider:SetPoint('TOPLEFT', self, 'TOPLEFT', 8, -height - GAP)
        slider:SetWidth(math.max(1, width - 16))
        return height + GAP + 18
    end
    panel.controls[path] = { widget=slider, label=label, row=frame, refresh=refreshValue }
end

local function choicesRow(panel, path, title, choices)
    local frame = row(panel, 'Icons', nil, true)
    local label = newText(panel, frame, 12, 'text')
    label:SetText(L(title))
    local buttons = {}
    for _, choice in ipairs(choices) do
        local button = CreateFrame('CheckButton', nil, frame, 'UICheckButtonTemplate')
        button:SetSize(22,22)
        style('StyleCheck', button)
        button.label = newText(panel, frame, 12, 'text')
        button.label:SetText(L(choice[2]))
        button:SetScript('OnClick',function() Options.SetValue(path, choice[1]) end)
        panel.controls[path .. choice[1]] = { widget=button, row=frame,
            refresh=function() button:SetChecked(lookup(path)==choice[1]) end }
        buttons[#buttons + 1] = button
    end
    frame.layout = function(self, width)
        local y = wrapped(label, self, width) + GAP
        local cell = (width - GAP) / 2
        for index = 1, #buttons, 2 do
            local height = 22
            for column = 0, 1 do
                local button = buttons[index + column]
                if button then
                    local x = column * (cell + GAP)
                    button:ClearAllPoints()
                    button:SetPoint('TOPLEFT', self, 'TOPLEFT', x, -y)
                    height = math.max(height, wrapped(button.label, self, width, x + 26, width - x - cell, y))
                    button:SetHitRectInsets(0, -(cell - 22), 0, 0)
                end
            end
            y = y + height + GAP
        end
        return y - GAP
    end
end

local function customization(panel)
    panel.gearQuestStatus = controlLine(panel,'Rules','', 'muted')
    sliderRow(panel,'Icons','icons.size','Icon size (px)',10,32,1,1)
    sliderRow(panel,'Icons','icons.opacity','Opacity (%)',30,100,1,.01)
    choicesRow(panel,'icons.corner','Icon corner',{{'TOPLEFT','Top left'},{'TOPRIGHT','Top right'},{'BOTTOMLEFT','Bottom left'},{'BOTTOMRIGHT','Bottom right'}})
    panel.baganatorNote = controlLine(panel,'Icons',L('With Baganator, choose the corner in its options: Corner icons.'))
    choicesRow(panel,'icons.coinStyle','Coin style',{{'Blizzard','Blizzard'},{'KnuJunk','KnuJunk'}})
    local frame = row(panel, 'Icons', nil, true)
    local restore = CreateFrame('Button',nil,frame,'UIPanelButtonTemplate')
    restore:SetText(L('Restore colors')); restore:SetScript('OnClick',Options.RestoreColors)
    style('StyleButton', restore)
    frame.layout = function(self, width)
        restore:ClearAllPoints()
        restore:SetSize(width, 24)
        restore:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
        return 24
    end
    panel.restoreColors = restore
    panel.auctionStatus = controlLine(panel,'Auction','', 'muted')
    sliderRow(panel,'Auction','auction.factor','Auction price factor',1.5,5,.1,1)
    sliderRow(panel,'Auction','auction.minCopper','Minimum price (silver)',0,10000,1,100)
    controlLine(panel,'Auction',L('Unbound items get an auction icon when their auction price meets both thresholds.'))
end

local BINDING = 'KNUJUNK_CYCLE_HOVERED'
local MODIFIERS = { LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true }
local function refreshBinding(panel)
    local key = type(GetBindingKey) == 'function' and GetBindingKey(BINDING)
    panel.bindingKey:SetText(key and (type(GetBindingText) == 'function' and GetBindingText(key, 'KEY_') or key)
        or L('No key assigned'))
end

local function stopCapture(button)
    local wasCapturing = button.capturing
    button.capturing = false
    button:EnableKeyboard(false)
    button:SetText(L('Assign key'))
    if wasCapturing and Options.Layout then Options.Layout() end
end

local function combat()
    if type(InCombatLockdown) == 'function' and InCombatLockdown() then
        ns.Print(L('Not in combat'))
        return true
    end
end

local function bindingRow(panel)
    local frame = row(panel, 'General', nil, true)
    local label = newText(panel, frame, 13, 'text')
    label:SetText(L('Key to protect / unprotect'))
    panel.bindingLabel = label
    panel.bindingKey = newText(panel, frame, 12, 'accentHi')
    local button = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    panel.bindingButton, panel.bindingRow = button, frame
    style('StyleButton', button)
    stopCapture(button)
    button:SetScript('OnClick', function(self)
        if combat() then stopCapture(self) return end
        self.capturing = true
        self:SetText(L('Press a key... (Esc cancels)'))
        Options.Layout()
        self:EnableKeyboard(true)
        if self.SetPropagateKeyboardInput then self:SetPropagateKeyboardInput(false) end
    end)
    button:SetScript('OnKeyDown', function(self, key)
        if not self.capturing then return end
        if key == 'ESCAPE' then stopCapture(self) return end
        if combat() then stopCapture(self) return end
        if MODIFIERS[key] then return end
        key = (IsShiftKeyDown and IsShiftKeyDown() and 'SHIFT-' or '')
            .. (IsControlKeyDown and IsControlKeyDown() and 'CTRL-' or '')
            .. (IsAltKeyDown and IsAltKeyDown() and 'ALT-' or '') .. key
        local previous = type(GetBindingAction) == 'function' and GetBindingAction(key)
        stopCapture(self)
        if type(SetBinding) ~= 'function' or type(SaveBindings) ~= 'function'
            or type(GetCurrentBindingSet) ~= 'function' then
            ns.Print(L('Could not assign key'))
            return
        end
        local old = { GetBindingKey(BINDING) }
        local success, assigned = pcall(SetBinding, key, BINDING)
        if not success or not assigned then ns.Print(L('Could not assign key')) return end
        -- La tecla anterior de esta accion queda libre: una sola tecla cambia marcas.
        for _, oldKey in ipairs(old) do
            if oldKey ~= key then pcall(SetBinding, oldKey) end
        end
        local gotSet, set = pcall(GetCurrentBindingSet)
        local saved, result
        if gotSet then saved, result = pcall(SaveBindings, set) end
        if not saved or result == false then ns.Print(L('Could not save key')) end
        if previous and previous ~= '' and previous ~= BINDING then
            local name = _G['BINDING_NAME_' .. previous] or previous
            ns.Print(string.format(L('%s was bound to %s; now it changes KnuJunk marks'), key, name))
        end
        refreshBinding(panel)
        Options.Layout()
    end)
    button:SetScript('OnHide', stopCapture)
    panel:SetScript('OnHide', function() stopCapture(button) end)
    local help = newText(panel, frame, 11, 'muted')
    help:SetText(L('Hover an item in your bags or loot window and press the key to toggle Protected / Automatic.'))
    panel.bindingHelp = help
    frame.layout = function(self, width)
        local buttonWidth = math.min(190, width * .34)
        local keyWidth = width * .20
        local labelHeight = wrapped(label, self, width, 0, buttonWidth + keyWidth + 2 * GAP)
        local keyHeight = wrapped(panel.bindingKey, self, width, width - buttonWidth - keyWidth - GAP, buttonWidth + GAP)
        local height = math.max(24, labelHeight, keyHeight)
        button:ClearAllPoints()
        button:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, 0)
        button:SetSize(buttonWidth, height)
        local text = button:GetFontString()
        if text then
            text:SetWidth(math.max(1, buttonWidth - 8))
            text:SetWordWrap(true)
            text:SetJustifyH('LEFT')
            height = math.max(height, text:GetStringHeight() + 8)
            button:SetHeight(height)
        end
        return height + GAP + wrapped(help, self, width, 0, 0, height + GAP)
    end
    refreshBinding(panel)
end

local refreshList

-- Desplaza la lista (rueda del mouse).
local function scrollBy(panel, delta)
    panel.offset = (panel.offset or 0) + delta
    refreshList(panel)
end

-- Una fila de la lista de marcas manuales: icono, nombre, accion y "Quitar".
local function newRow(panel, index)
    local list = panel.list
    local row = CreateFrame('Frame', nil, list)
    row:SetHeight(ROW_H)
    row:SetPoint('TOPLEFT', list, 'TOPLEFT', 0, -(index - 1) * ROW_H)
    row:SetPoint('TOPRIGHT', list, 'TOPRIGHT', 0, -(index - 1) * ROW_H)
    row:EnableMouse(true)
    local highlight = row:CreateTexture(nil, 'BACKGROUND')
    highlight:SetAllPoints(row)
    track(panel, 'texture', highlight, 'accent', nil, 0.12)
    highlight:Hide()
    row.highlight = highlight
    row.icon = row:CreateTexture(nil, 'ARTWORK')
    row.icon:SetSize(18, 18)
    row.icon:SetPoint('LEFT', row, 'LEFT', 6, 0)
    row.remove = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
    row.remove:SetSize(72, 20)
    row.remove:SetPoint('RIGHT', row, 'RIGHT', -4, 0)
    row.remove:SetText(L('Remove'))
    style('StyleButton', row.remove)
    row.kind = newText(panel, row, 12, 'accentHi')
    row.name = newText(panel, row, 12, 'text')
    row.remove:SetScript('OnClick', function()
        if row.id then Options.RemoveOverride(row.id) end
    end)
    row:SetScript('OnEnter', function(self)
        self.highlight:Show()
        if self.id and GameTooltip then
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            pcall(GameTooltip.SetHyperlink, GameTooltip, 'item:' .. self.id)
            GameTooltip:Show()
        end
    end)
    row:EnableMouseWheel(true)
    row:SetScript('OnMouseWheel', function(_, delta) scrollBy(panel, delta > 0 and -1 or 1) end)
    row:SetScript('OnLeave', function(self)
        self.highlight:Hide()
        if GameTooltip then GameTooltip:Hide() end
    end)
    row.layout = function(width)
        row:SetWidth(width)
        local kindWidth = math.min(142, width * .28)
        local right = 88 + kindWidth
        local height = math.max(ROW_H, wrapped(row.name, row, width, 32, right, 4) + 8,
            wrapped(row.kind, row, width, width - right + 8, 80, 4) + 8)
        row:SetHeight(height)
        return height
    end
    return row
end

local function refreshChecks(panel)
    for path, check in pairs(panel.checks) do check:SetChecked(Options.Get(path)) end
end

function refreshList(panel)
    local data = Options.OverrideRows()
    local visible = Options.VisibleRows(panel.list:GetHeight())
    -- Medir con el mismo widget y la misma fuente que se van a mostrar.
    local heights, width = {}, panel.list:GetWidth()
    if width > 0 then
        local probe = panel.rows[1]
        for index, item in ipairs(data) do
            local name = Options.ItemInfo(item.id)
            probe.name:SetText(name or string.format(L('Item %d'), item.id))
            probe.kind:SetText(item.action == 'keep' and L('Protected') or item.action == 'sell'
                and L('Sell (legacy mark)') or tostring(item.action))
            heights[index] = probe.layout(width)
        end
        local used, count = 0, 0
        for index = #data, 1, -1 do
            if count >= MAX_ROWS or used + heights[index] > panel.list:GetHeight() then break end
            used, count = used + heights[index], count + 1
        end
        visible = math.max(1, count)
    end
    local maxOffset = math.max(0, #data - visible)
    panel.offset = math.max(0, math.min(panel.offset or 0, maxOffset))
    panel.missing = false
    local cursor, full = 0, false
    for index, row in ipairs(panel.rows) do
        local itemIndex = panel.offset + index
        local height = heights[itemIndex] or ROW_H
        local item = not full and data[itemIndex] or nil
        if item and index > 1 and cursor + height > panel.list:GetHeight() then item, full = nil, true end
        if item then
            local name, icon, quality = Options.ItemInfo(item.id)
            if not name then panel.missing = true end
            row.id = item.id
            row.name:SetText(name or string.format(L('Item %d'), item.id))
            local colors = name and quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
            if colors then
                row.name:SetTextColor(colors.r, colors.g, colors.b, 1)
            else
                row.name:SetTextColor(color('text'))
            end
            row.icon:SetTexture(icon or 'Interface\\Icons\\INV_Misc_QuestionMark')
            row.kind:SetText(item.action == 'keep' and L('Protected') or item.action == 'sell' and L('Sell (legacy mark)')
                or tostring(item.action))
            if width > 0 then
                height = row.layout(width)
                row:ClearAllPoints()
                row:SetPoint('TOPLEFT', panel.list, 'TOPLEFT', 0, -cursor)
            end
            cursor = cursor + height
            row:Show()
        else
            row.id = nil
            row:Hide()
        end
    end
    panel.empty:SetShown(#data == 0)
    panel.updating = true
    panel.scroll:SetMinMaxValues(0, maxOffset)
    panel.scroll:SetValue(panel.offset)
    panel.updating = false
    panel.scroll:SetShown(maxOffset > 0)
    if cursor > panel.list:GetHeight() then
        panel.list:SetHeight(cursor)
        Options.Layout()
    end
end

local function refreshFooter(panel)
    local info = Options.StatusInfo()
    local function yesNo(value) return value and L('yes') or L('no') end
    panel.footer[1]:SetText(string.format(L('Data build: %s'), info.build))
    panel.footer[2]:SetText(string.format(L('QuestieDB: %s, index ready: %s'), yesNo(info.questie), yesNo(info.ready)))
    panel.footer[3]:SetText(string.format(L('Bag adapters: %s'),
        #info.adapters > 0 and table.concat(info.adapters, ', ') or L('none')))
end

local function refresh(panel)
    local sellers = ns.AutoSell.OtherSellers()
    panel.autoSellWarnings.Leatrix_Plus:SetText(sellers.Leatrix_Plus and L('Leatrix Plus also sells junk automatically: turn it off in its options so only KnuJunk coin items are sold.') or '')
    panel.autoSellWarnings.ElvUI:SetText(sellers.ElvUI and L('ElvUI also sells junk automatically: turn it off in Bags > Vendor Grays so only KnuJunk coin items are sold.') or '')
    local repairers = ns.AutoSell.OtherRepairers()
    panel.autoRepairWarnings.Leatrix_Plus:SetText(repairers.Leatrix_Plus and L('Leatrix Plus also repairs automatically: turn it off in its options so only KnuJunk repairs.') or '')
    panel.autoRepairWarnings.ElvUI:SetText(repairers.ElvUI and L('ElvUI also repairs automatically: turn it off in General > Auto Repair so only KnuJunk repairs.') or '')
    for _, control in pairs(panel.controls) do control.refresh() end
    for kind, swatch in pairs(panel.swatches) do
        local color = ns.Marks.Color(kind)
        swatch.fill:SetColorTexture(color[1],color[2],color[3],1)
    end
    local root = rawget(_G,'Auctionator')
    local detected = root and root.API and root.API.v1 and type(root.API.v1.GetAuctionPriceByItemID)=='function'
    panel.auctionStatus:SetText(L('Auctionator detected: %s'):format(L(detected and 'yes' or 'no')))
    local gearQuest = ns.GearQuestRoot and ns.GearQuestRoot()
    local gearDetected = type(gearQuest) == 'table' and type(gearQuest.Data) == 'table'
        and type(gearQuest.Data.GearScoreMissText) == 'function'
    panel.gearQuestStatus:SetText(L('GearQuest detected: %s'):format(L(gearDetected and 'yes' or 'no')))
    refreshBinding(panel)
    refreshChecks(panel)
    refreshList(panel)
    refreshFooter(panel)
    Options.Layout()
end

function Options.Refresh()
    if Options.panel then refresh(Options.panel) end
end

-- ns.Changed la llama tras cada cambio: solo trabaja si el panel esta a la vista.
function Options.RefreshIfShown()
    local panel = Options.panel
    if panel and panel:IsVisible() then refresh(panel) end
end

-- Vuelve a pintar los textos con los idiomas y el tema actuales.
local function retheme()
    local panel = Options.panel
    if not panel then return end
    paint(panel)
    refreshList(panel)
    Options.Layout()
end

local TAB_KEYS = { 'General', 'Icons', 'Rules', 'Auction', 'Marks' }
Options.TABS = TAB_KEYS

function Options.SelectTab(key)
    local panel = Options.panel
    if not panel or not panel.tabs[key] then return false end
    ns.DB.ui = ns.DB.ui or {}
    ns.DB.ui.tab = key
    panel.selectedTab = key
    if key ~= 'General' then stopCapture(panel.bindingButton) end
    for _, name in ipairs(TAB_KEYS) do
        local page = panel.tabs[name]
        page.viewport:SetShown(name == key)
        page.button.selected = name == key
        page.highlight:SetShown(name == key)
    end
    return true
end

function Options.Layout()
    local panel = Options.panel
    if not panel or panel.layingOut then return false end
    local width = panel:GetWidth()
    if width <= 0 then return false end
    panel.layingOut = true
    panel.layoutCount = (panel.layoutCount or 0) + 1
    local column = math.max(1, width - 2 * PAD)
    local titleHeight = wrapped(panel.title, panel, width, PAD, PAD, PAD)
    local tabWidth = (column - GAP * (#TAB_KEYS - 1)) / #TAB_KEYS
    local tabHeight = 24
    for _, key in ipairs(TAB_KEYS) do
        local text = panel.tabs[key].button:GetFontString()
        if text then
            text:SetWidth(math.max(1, tabWidth - 8))
            text:SetWordWrap(true)
            text:SetJustifyH('LEFT')
            tabHeight = math.max(tabHeight, text:GetStringHeight() + 8)
        end
    end
    local top = PAD + titleHeight + GAP
    for index, key in ipairs(TAB_KEYS) do
        local page = panel.tabs[key]
        page.button:ClearAllPoints()
        page.button:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD + (index - 1) * (tabWidth + GAP), -top)
        page.button:SetSize(math.max(1, tabWidth), tabHeight)
        page.viewport:ClearAllPoints()
        page.viewport:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, -top - tabHeight - GAP)
        page.viewport:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', -PAD, PAD)
        local available = math.max(1, panel:GetHeight() - top - tabHeight - GAP - PAD)
        page.viewport:SetSize(column, available)
        page.content:SetWidth(column)
        local cursor = 0
        for i, frame in ipairs(page.rows) do
            cursor = cursor + (i == 1 and 0 or frame.before)
            frame:ClearAllPoints()
            frame:SetPoint('TOPLEFT', page.content, 'TOPLEFT', 0, -cursor)
            frame:SetWidth(column)
            frame:SetHeight(frame.layout(frame, column))
            cursor = cursor + frame:GetHeight()
        end
        page.content:SetHeight(math.max(1, cursor))
        page.limit = math.max(0, cursor - available)
        page.viewport:SetVerticalScroll(math.min(page.viewport:GetVerticalScroll(), page.limit))
    end
    panel.layingOut = false
    return true
end

local themeHooked
function Options.Build()
    if Options.panel then return Options.panel end
    local template = BackdropTemplateMixin and 'BackdropTemplate' or nil
    local panel = CreateFrame('Frame', nil, UIParent, template)
    panel.name = 'KnuJunk'
    panel.painted, panel.checks, panel.rows, panel.footer = {}, {}, {}, {}
    panel.controls, panel.swatches, panel.tabs = {}, {}, {}
    panel.offset = 0
    style('StylePanel', panel)
    panel.title = newText(panel, panel, 20, 'accent')
    panel.title:SetText('KnuJunk')
    for _, key in ipairs(TAB_KEYS) do
        local page = { rows = {} }
        panel.tabs[key] = page
        page.button = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
        page.button:SetText(L(key == 'Auction' and 'Auctions' or key))
        style('StyleButton', page.button)
        page.highlight = page.button:CreateTexture(nil, 'OVERLAY')
        page.highlight:SetHeight(3)
        page.highlight:SetPoint('BOTTOMLEFT', page.button, 'BOTTOMLEFT', 0, 0)
        page.highlight:SetPoint('BOTTOMRIGHT', page.button, 'BOTTOMRIGHT', 0, 0)
        track(panel, 'texture', page.highlight, 'accent')
        page.button:SetScript('OnClick', function() Options.SelectTab(key); Options.Layout() end)
        page.viewport = CreateFrame('ScrollFrame', nil, panel)
        page.content = CreateFrame('Frame', nil, page.viewport)
        page.viewport:SetScrollChild(page.content)
        page.viewport:EnableMouseWheel(true)
        page.viewport:SetScript('OnMouseWheel', function(self, delta)
            self:SetVerticalScroll(math.max(0, math.min(page.limit or 0, self:GetVerticalScroll() - delta * ROW_H * 3)))
        end)
    end
    for _, toggle in ipairs(Options.TOGGLES) do toggleRow(panel, toggle) end
    sliderRow(panel, 'General', 'autoSell.max', 'Maximum per visit', 1, 12, 1, 1)
    panel.autoSellWarnings = {
        Leatrix_Plus = controlLine(panel, 'General', '', 'muted'),
        ElvUI = controlLine(panel, 'General', '', 'muted'),
    }
    panel.autoRepairWarnings = {
        Leatrix_Plus = controlLine(panel, 'General', '', 'muted'),
        ElvUI = controlLine(panel, 'General', '', 'muted'),
    }
    bindingRow(panel)
    customization(panel)

    local listFrame = row(panel, 'Marks')
    local list = CreateFrame('Frame', nil, listFrame, template)
    list:SetPoint('TOPLEFT', listFrame, 'TOPLEFT', 0, 0)
    list:SetHeight(DEFAULT_ROWS * ROW_H)
    style('StylePanel', list)
    list:EnableMouseWheel(true)
    panel.list = list
    for index = 1, MAX_ROWS do panel.rows[index] = newRow(panel, index) end
    panel.empty = newText(panel, list, 12, 'muted')
    panel.empty:SetText(L('No manual marks yet. Choose a key in General to change the mark under the mouse.'))
    listFrame.layout = function(_, width)
        list:SetWidth(math.max(1, width - 16))
        wrapped(panel.empty, list, list:GetWidth(), 12, 12, 12)
        refreshList(panel)
        return list:GetHeight()
    end
    for index = 1, 3 do panel.footer[index] = controlLine(panel, 'Marks', '', 'muted') end

    local scroll = CreateFrame('Slider', nil, listFrame)
    scroll:SetOrientation('VERTICAL')
    scroll:SetWidth(10)
    scroll:SetPoint('TOPLEFT', list, 'TOPRIGHT', 4, 0)
    scroll:SetPoint('BOTTOMLEFT', list, 'BOTTOMRIGHT', 4, 0)
    scroll:SetMinMaxValues(0, 0)
    scroll:SetValueStep(1)
    scroll:SetObeyStepOnDrag(true)
    scroll:SetThumbTexture('Interface\\Buttons\\WHITE8X8')
    panel.thumb = scroll:GetThumbTexture()
    panel.thumb:SetSize(10, 28)
    local rail = scroll:CreateTexture(nil, 'BACKGROUND')
    rail:SetAllPoints(scroll)
    track(panel, 'texture', rail, 'border', nil, 0.8)
    scroll:SetScript('OnValueChanged', function(_, value)
        if panel.updating then return end
        panel.offset = math.floor((value or 0) + 0.5)
        refreshList(panel)
    end)
    panel.scroll = scroll
    list:SetScript('OnMouseWheel', function(_, delta) scrollBy(panel, delta > 0 and -1 or 1) end)
    list:SetScript('OnSizeChanged', function() refreshList(panel) end)

    panel.refresh = function() refresh(panel) end
    panel.OnRefresh = panel.refresh
    panel.OnCommit, panel.OnDefault = function() end, function() end
    panel.okay, panel.cancel, panel.default = panel.OnCommit, panel.OnCommit, panel.OnDefault
    panel:SetScript('OnShow', function()
        refresh(panel)
        Options.SelectTab(ns.DB.ui and ns.DB.ui.tab or 'General')
    end)
    panel:SetScript('OnSizeChanged', function() Options.Layout() end)
    panel:SetScript('OnEvent', function(_, event)
        if event == 'UPDATE_BINDINGS' then refreshBinding(panel); Options.Layout(); return end
        if event ~= 'GET_ITEM_INFO_RECEIVED' or not panel.missing or panel.waiting or not panel:IsVisible() then return end
        panel.waiting = true -- varios nombres llegan juntos: se repinta una sola vez
        C_Timer.After(0.2, function()
            panel.waiting = false
            if panel:IsVisible() then refreshList(panel) end
        end)
    end)
    pcall(panel.RegisterEvent, panel, 'GET_ITEM_INFO_RECEIVED')
    pcall(panel.RegisterEvent, panel, 'UPDATE_BINDINGS')
    panel:Hide() -- lo muestra la ventana de opciones

    paint(panel)
    Options.panel = panel
    if not Options.SelectTab(ns.DB.ui and ns.DB.ui.tab or 'General') then Options.SelectTab('General') end
    if not themeHooked and ns.KL and ns.KL.RegisterCallback then
        themeHooked = true
        pcall(ns.KL.RegisterCallback, ns.KL, retheme)
    end
    return panel
end

-- Registra la categoria "KnuJunk": Settings (cliente moderno) o InterfaceOptions (clasico).
function Options.Register()
    if Options.category then return Options.category end
    local panel = Options.Build()
    local ok = pcall(function()
        if type(Settings) == 'table' and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
            local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            Settings.RegisterAddOnCategory(category)
            Options.category, Options.flavor = category, 'settings'
        elseif InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
            Options.category, Options.flavor = panel, 'interface'
        end
    end)
    if not ok then Options.category, Options.flavor = nil, nil end
    return Options.category
end

-- Abre el panel (/knu junk). Settings.OpenToCategory es una funcion restringida en combate: ahi se
-- avisa en vez de llamarla (ForeverSettings, si esta, abre su ventana tambien en combate).
function Options.Open()
    local category = Options.Register()
    local say = function(key) ns.Print(L(key)) end
    if not category then say('Options panel is not available in this client') return false end
    if Options.flavor == 'settings' then
        local id = category.GetID and category:GetID() or category.ID
        if type(ForeverSettings) == 'table' and type(ForeverSettings.OpenPage) == 'function' then
            local ok, opened = pcall(ForeverSettings.OpenPage, id)
            if ok and opened == true then return true end
        end
        if InCombatLockdown and InCombatLockdown() then
            say('Options open after combat: Esc > Options > AddOns > KnuJunk')
            return false
        end
        if type(Settings.OpenToCategory) == 'function' and pcall(Settings.OpenToCategory, id) then return true end
        say('Options panel is not available in this client')
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        say('Options open after combat: Esc > Options > AddOns > KnuJunk')
        return false
    end
    if type(InterfaceOptionsFrame_OpenToCategory) ~= 'function' then
        say('Options panel is not available in this client')
        return false
    end
    -- La primera llamada solo abre la ventana de opciones y la segunda elige la categoria (bug conocido de Blizzard).
    pcall(InterfaceOptionsFrame_OpenToCategory, category)
    pcall(InterfaceOptionsFrame_OpenToCategory, category)
    return true
end

-- Solo para las pruebas: olvida el panel y el registro (los frames viejos quedan sueltos).
function Options.ResetState()
    Options.panel, Options.category, Options.flavor = nil, nil, nil
end

ns.OnLogin(function() pcall(Options.Register) end)
