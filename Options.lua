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
        help = 'Master switch: turns every icon off. KnuJunk never sells or deletes anything.' },
    { section = 'Marks', path = 'show.coin', label = 'Coin',
        help = 'What you can sell: greys, quest leftovers and gear your class never uses.' },
    { section = 'Marks', path = 'show.hammer', label = 'Hammer',
        help = "Profession materials: green for one of your professions, yellow for one you lack." },
    { section = 'Marks', path = 'show.loot', label = 'Marks in loot',
        help = 'The same icons in the loot window (with autoloot there is no window).' },
    { section = 'Rules', path = 'rules.food', label = 'Outleveled food and drink',
        help = 'Coin on simple food and drink 15 or more levels above the requirement when you carry a better one. Never for hunters.' },
    { section = 'Rules', path = 'rules.ammo', label = 'Outdamaged ammunition',
        help = 'Coin on ordinary arrows or bullets when you carry a usable stack of the same kind with more damage. Keeps the equipped one and a compatible stack.' },
    { section = 'Rules', path = 'rules.knownRecipe', label = 'Recipes already learned',
        help = 'Coin on recipes you already know, only if bound and with a sell price. Unbound: no coin; the tooltip says you can pass it on or auction it.' },
}

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

local function newLine(panel, parent, role, alpha)
    local line = parent:CreateTexture(nil, 'ARTWORK')
    line:SetHeight(1)
    track(panel, 'texture', line, role, nil, alpha)
    return line
end

-- Encabezado de seccion: titulo en el acento y una linea fina debajo. Devuelve la y siguiente.
local function section(panel, y, key)
    local title = newText(panel, panel, 13, 'accent')
    title:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y)
    title:SetText(L(key))
    local line = newLine(panel, panel, 'accentDim', 0.6)
    line:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y - 18)
    line:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -PAD, y - 18)
    panel.sections[#panel.sections + 1] = { text = title, key = key }
    return y - 24
end

local function toggleRow(panel, y, toggle, height)
    local check = CreateFrame('CheckButton', nil, panel, 'UICheckButtonTemplate')
    check:SetSize(22, 22)
    check:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y)
    check:SetHitRectInsets(0, -420, 0, 0) -- el texto tambien se puede clickear
    style('StyleCheck', check)
    local label = newText(panel, panel, 13, 'text')
    label:SetPoint('LEFT', check, 'RIGHT', 4, 0)
    label:SetText(L(toggle.label))
    check.label = label
    local help = newText(panel, panel, 11, 'muted')
    help:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD + 26, y - 22)
    help:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -PAD, y - 22)
    help:SetJustifyV('TOP')
    help:SetWordWrap(true)
    help:SetText(L(toggle.help))
    check.help = help
    check:SetScript('OnClick', function(self) Options.Set(toggle.path, self:GetChecked() and true or false) end)
    panel.checks[toggle.path] = check
    return y - height
end

local BINDING = 'KNUJUNK_CYCLE_HOVERED'
local MODIFIERS = { LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true }
local function refreshBinding(panel)
    local key = type(GetBindingKey) == 'function' and GetBindingKey(BINDING)
    panel.bindingKey:SetText(key and (type(GetBindingText) == 'function' and GetBindingText(key, 'KEY_') or key)
        or L('No key assigned'))
end

local function stopCapture(button)
    button.capturing = false
    button:EnableKeyboard(false)
    button:SetText(L('Assign key'))
end

local function combat()
    if type(InCombatLockdown) == 'function' and InCombatLockdown() then
        ns.Print(L('Not in combat'))
        return true
    end
end

local function bindingRow(panel, y)
    local label = newText(panel, panel, 13, 'text')
    label:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y)
    label:SetText(L('Change a mark with a key'))
    panel.bindingKey = newText(panel, panel, 12, 'accentHi')
    panel.bindingKey:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y - 22)
    local button = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
    panel.bindingButton = button
    button:SetSize(250, 24)
    button:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -PAD, y)
    style('StyleButton', button)
    stopCapture(button)
    button:SetScript('OnClick', function(self)
        if combat() then stopCapture(self) return end
        self.capturing = true
        self:SetText(L('Press a key... (Esc cancels)'))
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
    end)
    button:SetScript('OnHide', stopCapture)
    panel:SetScript('OnHide', function() stopCapture(button) end)
    local help = newText(panel, panel, 11, 'muted')
    help:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y - 42)
    help:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -PAD, y - 42)
    help:SetWordWrap(true)
    help:SetText(L('Hover an item in your bags or loot window and press the key: automatic → always keep → always sell → automatic.'))
    refreshBinding(panel)
    return y - 82
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
    row.kind:SetWidth(64)
    row.kind:SetPoint('RIGHT', row.remove, 'LEFT', -8, 0)
    row.name = newText(panel, row, 12, 'text')
    row.name:SetPoint('LEFT', row.icon, 'RIGHT', 8, 0)
    row.name:SetPoint('RIGHT', row.kind, 'LEFT', -8, 0)
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
    return row
end

local function refreshChecks(panel)
    for path, check in pairs(panel.checks) do check:SetChecked(Options.Get(path)) end
end

function refreshList(panel)
    local data = Options.OverrideRows()
    local visible = Options.VisibleRows(panel.list:GetHeight())
    local maxOffset = math.max(0, #data - visible)
    panel.offset = math.max(0, math.min(panel.offset or 0, maxOffset))
    panel.missing = false
    for index, row in ipairs(panel.rows) do
        local item = index <= visible and data[panel.offset + index] or nil
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
            row.kind:SetText(item.action == 'keep' and L('Keep') or item.action == 'sell' and L('Sell')
                or tostring(item.action))
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
    refreshBinding(panel)
    refreshChecks(panel)
    refreshList(panel)
    refreshFooter(panel)
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
end

local themeHooked
function Options.Build()
    if Options.panel then return Options.panel end
    local template = BackdropTemplateMixin and 'BackdropTemplate' or nil
    local panel = CreateFrame('Frame', nil, UIParent, template)
    panel.name = 'KnuJunk'
    panel.painted, panel.checks, panel.rows, panel.sections, panel.footer = {}, {}, {}, {}, {}
    panel.offset = 0
    style('StylePanel', panel)

    panel.title = newText(panel, panel, 20, 'accent')
    panel.title:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, -16)
    panel.title:SetText('KnuJunk')

    local y = -52
    local currentSection
    for _, toggle in ipairs(Options.TOGGLES) do
        if toggle.section ~= currentSection then
            currentSection = toggle.section
            y = section(panel, y, toggle.section == 'Marks' and 'Marks' or 'Optional rules (off by default)')
        end
        y = toggleRow(panel, y, toggle, toggle.section == 'Marks' and 36 or 52)
    end
    y = bindingRow(panel, y - 4)
    y = section(panel, y - 4, 'Manual marks')

    -- Pie: tres lineas de estado, pegadas abajo.
    for index = 1, 3 do
        local line = newText(panel, panel, 11, 'muted')
        line:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', PAD, PAD + (3 - index) * 14)
        panel.footer[index] = line
    end

    -- Lista con scroll propio (filas reutilizables + barra): el alto la define el espacio que queda.
    local list = CreateFrame('Frame', nil, panel, template)
    list:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD, y)
    list:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', -PAD - 16, PAD + 3 * 14 + 8)
    style('StylePanel', list)
    list:EnableMouseWheel(true)
    panel.list = list
    for index = 1, MAX_ROWS do panel.rows[index] = newRow(panel, index) end

    panel.empty = newText(panel, list, 12, 'muted')
    panel.empty:SetPoint('TOPLEFT', list, 'TOPLEFT', 12, -12)
    panel.empty:SetPoint('TOPRIGHT', list, 'TOPRIGHT', -12, -12)
    panel.empty:SetJustifyV('TOP')
    panel.empty:SetWordWrap(true)
    panel.empty:SetText(L('No manual marks yet. Assign a key above to change an item mark under the mouse.'))

    local scroll = CreateFrame('Slider', nil, panel)
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
    panel:SetScript('OnShow', function() refresh(panel) end)
    panel:SetScript('OnEvent', function(_, event)
        if event == 'UPDATE_BINDINGS' then refreshBinding(panel) return end
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
