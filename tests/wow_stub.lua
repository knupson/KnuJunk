FAKE = { frames = {}, named = {} }
strmatch = string.match
STANDARD_TEXT_FONT = 'Fonts\\FRIZQT__.TTF'
local methods = {}
local unpack = unpack or table.unpack
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event, fn)
    self.hookCalls = self.hookCalls or {}
    self.hookCalls[event] = (self.hookCalls[event] or 0) + 1
    local previous = self.scripts[event]
    self.scripts[event] = function(...) if previous then previous(...) end; fn(...) end
end
function methods:Click(mouse)
    local onClick = self:GetScript('OnClick')
    if onClick then onClick(self, mouse or 'LeftButton') end
end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:EnableKeyboard(value) self.keyboard = value end
function methods:SetPropagateKeyboardInput(value) self.propagate = value end
function methods:IsShown() return self.shown end
function methods:IsVisible()
    if not self.shown then return false end
    if self.parent and self.parent.IsVisible then return self.parent:IsVisible() end
    return true
end
function methods:IsMouseOver() return self.mouseOver == true end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:SetText(text)
    self.text = text
    if self.Text then self.Text:SetText(text) end
    if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self, false) end
end
function methods:GetText() return self.text or '' end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:GetID() return self.id end
function methods:GetParent() return self.parent end
function methods:GetFrameLevel() return self.level or 1 end
function methods:SetPassThroughButtons(...) self.passThrough = {...} end
function methods:CreateFontString() return CreateFrame('FontString', nil, self) end
function methods:GetName() return self.name end
function methods:GetFontString() return self.Text end
function methods:SetAlpha(value) self.alpha = value end
function methods:SetBackdrop(value) self.backdrop = value end
function methods:SetBackdropColor(...) self.bg = {...} end
function methods:SetBackdropBorderColor(...) self.border = {...} end
function methods:SetVertexColor(...) self.vertex = {...} end
function methods:SetTexCoord(...) self.texCoord = {...} end
function methods:SetTextColor(...) self.textColor = {...} end
function methods:SetTexture(value) self.texture = value end
function methods:SetAtlas(value) self.atlas = value; self.texture = nil end
function methods:SetDesaturated(value) self.desaturated = value end
function methods:SetFont(...) self.font = {...} end
function methods:GetFont() return unpack(self.font or {STANDARD_TEXT_FONT, 12, ''}) end
function methods:Enable() self.enabled = true end
function methods:Disable() self.enabled = false end
function methods:SetEnabled(value) self.enabled = value end
function methods:IsEnabled() return self.enabled end
function methods:CreateTexture(name) return CreateFrame('Texture', name) end
function methods:GetCheckedTexture() return self.checkedTexture end
for _, part in ipairs({'Normal','Pushed','Highlight','Disabled'}) do
    methods['Get' .. part .. 'Texture'] = function(self) return self[part] end
end
for _, method in ipairs({'SetPoint','RegisterForClicks','EnableMouse','SetOwner','AddLine','SetHyperlink','HighlightText','SetCursorPosition','SetAutoFocus','ClearAllPoints','SetNormalTexture','SetHighlightTexture','SetDrawLayer'}) do methods[method] = function() end end
-- Tamanos guardados (el panel de opciones calcula filas segun el alto) y widgets de opciones.
function methods:SetSize(w, h)
    local changed = self.w ~= w or self.h ~= h
    self.w, self.h = w, h
    if changed and self.scripts.OnSizeChanged then self.scripts.OnSizeChanged(self, w, h) end
end
function methods:SetWidth(value) self:SetSize(value, self.h) end
function methods:SetHeight(value) self:SetSize(self.w, value) end
function methods:GetWidth() return self.w or 0 end
function methods:GetHeight() return self.h or 0 end
function methods:GetStringWidth()
    local text = self:GetText():gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
    return #text * (select(2, self:GetFont()) or 12) * .5
end
function methods:GetStringHeight()
    self.measuredWidth = self:GetWidth()
    local size = select(2, self:GetFont()) or 12
    return size * math.max(1, math.ceil(self:GetStringWidth() / math.max(1, self:GetWidth())))
end
function methods:SetMinMaxValues(min, max) self.min = min; self.max = max end
function methods:SetValue(value) self.value = value; if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end end
function methods:GetValue() return self.value or 0 end
function methods:SetColorTexture(...) self.colorTexture = {...} end
function methods:SetThumbTexture(value) self.thumbPath = value end
function methods:GetThumbTexture() self.thumb = self.thumb or CreateFrame('Texture'); return self.thumb end
for _, method in ipairs({'SetHitRectInsets','SetValueStep','SetObeyStepOnDrag','SetOrientation','EnableMouseWheel','SetJustifyH',
    'SetJustifyV','SetWordWrap','SetMaxLines','SetFrameLevel','SetAllPoints','SetClipsChildren','SetFontObject'}) do methods[method] = function() end end
function methods:SetPoint(...) self.points = self.points or {}; self.points[#self.points + 1] = {...} end
function methods:SetWordWrap(value) self.wordWrap = value end
function methods:SetJustifyH(value) self.justifyH = value end
function methods:ClearAllPoints() self.points = {} end
function methods:SetAllPoints(target) self.allPoints = target end
function methods:SetFrameLevel(level) self.level = level end
function methods:SetParent(parent) self.parent = parent end
function methods:SetScrollChild(child) self.scrollChild = child end
function methods:SetVerticalScroll(value) self.verticalScroll = value end
function methods:GetVerticalScroll() return self.verticalScroll or 0 end
function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({ scripts = {}, events = {}, shown = true, parent = parent,
        name = name, kindType = kind, template = template, enabled = true, alpha = 1 }, {__index = methods})
    FAKE.frames[#FAKE.frames + 1] = frame
    if name then _G[name] = frame; FAKE.named[name] = true end
    if template == 'UIPanelButtonTemplate' or template == 'UICheckButtonTemplate' then
        frame.Text = frame:CreateFontString()
        for _, part in ipairs({'Left','Middle','Right','Normal','Pushed','Highlight','Disabled'}) do
            frame[part] = frame:CreateTexture()
        end
        frame.checkedTexture = frame:CreateTexture()
    end
    return frame
end
UIParent = CreateFrame('Frame')
GameTooltip = CreateFrame('Tooltip')
function hooksecurefunc(target, key, hook)
    if type(target) == 'string' then hook = key; key = target; target = _G end
    local previous = target[key]
    target[key] = function(...) if previous then previous(...) end; hook(...) end
end
local secureHook = hooksecurefunc
function FAKE.Fire(event, ...)
    for _, frame in ipairs(FAKE.frames) do
        if frame.events[event] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame, event, ...) end
    end
end
function FAKE.Advance(seconds)
    local finish = FAKE.time + seconds
    while true do
        local index, due
        for i, timer in ipairs(FAKE.timers) do if not due or timer.at < due then index, due = i, timer.at end end
        if not due or due > finish then break end
        FAKE.time = due
        local timer = table.remove(FAKE.timers, index)
        if not timer.cancelled then timer.fn() end
    end
    FAKE.time = finish
end
C_Timer = {}
function C_Timer.NewTimer(delay, fn)
    local timer = { at = FAKE.time + delay, fn = fn }
    function timer:Cancel() self.cancelled = true end
    FAKE.timers[#FAKE.timers + 1] = timer
    return timer
end
function C_Timer.After(delay, fn) C_Timer.NewTimer(delay, fn) end
local function newTicker(delay, fn)
    local ticker = {}
    function ticker:Cancel()
        self.cancelled = true
        if self.timer then self.timer:Cancel() end
    end
    local function tick()
        if ticker.cancelled then return end
        fn(ticker)
        if not ticker.cancelled then ticker.timer = C_Timer.NewTimer(delay, tick) end
    end
    ticker.timer = C_Timer.NewTimer(delay, tick)
    return ticker
end
C_Timer.NewTicker = newTicker
function GetTime() return FAKE.time end
function GetLocale() return FAKE.locale or 'esES' end
function strtrim(text) return (text:gsub('^%s+', ''):gsub('%s+$', '')) end
SlashCmdList = setmetatable({}, {__index = {}}); hash_SlashCmdList = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) FAKE.messages[#FAKE.messages + 1] = message end}
-- Cliente simulado: estado en FAKE.* y APIs globales. Reset restaura TODO; las pruebas quitan
-- una API con FAKE.Remove('Nombre') o FAKE.Remove('C_Tabla.Nombre').
local function installClient()
    FAKE.class = 'MAGE'
    FAKE.professions = {}   -- GetProfessions: { {name=, skillLine=}, ... }
    FAKE.skillLines = {}    -- GetSkillLineInfo: { {name=, isHeader=}, ... }
    FAKE.completed = {}     -- [questID] = true
    FAKE.questLog = {}      -- { {questID=, isHeader=, objectives={ {text=, type=} } } }
    FAKE.items = {}         -- [id] = { name=, quality=, price=, classID=, subclassID=, equipLoc=, setID=, spell=, tooltip={textos} (sin tooltip: nombre + "Tipo") }
    FAKE.bags = {}          -- ['bag:slot'] = itemID
    FAKE.equipped = {}      -- [slot] = itemID
    FAKE.bound = {}         -- ['bag:slot'] = true|false (isBound de GetContainerItemInfo; nil = sin el campo)
    FAKE.addons = {}        -- [carpeta] = true si el addon esta cargado
    C_AddOns = { IsAddOnLoaded = function(name) return FAKE.addons[name] == true end }
    -- API de opciones: Settings (cliente moderno). FAKE.InstallClassicOptions() la cambia por InterfaceOptions.
    FAKE.settings = { registered = {}, added = {}, opened = {} }
    Settings = {
        RegisterCanvasLayoutCategory = function(panel, name)
            local category = { panel = panel, name = name, id = #FAKE.settings.registered + 1 }
            function category:GetID() return self.id end
            FAKE.settings.registered[#FAKE.settings.registered + 1] = category
            return category
        end,
        RegisterAddOnCategory = function(category) FAKE.settings.added[#FAKE.settings.added + 1] = category end,
        OpenToCategory = function(id) FAKE.settings.opened[#FAKE.settings.opened + 1] = id end,
    }
    local function itemOf(key)
        if type(key) == 'number' then return key, FAKE.items[key] end
        if type(key) == 'string' then
            local id = tonumber(key:match('item:(%d+)'))
            if id then return id, FAKE.items[id] end
            for itemID, data in pairs(FAKE.items) do if data.name == key then return itemID, data end end
        end
    end
    local function linkOf(id)
        return '|cffffffff|Hitem:' .. id .. '::::::::|h[' .. (FAKE.items[id] and FAKE.items[id].name or '?') .. ']|h|r'
    end
    FAKE.linkOf = linkOf
    UnitClass = function() return 'Mago', FAKE.class end
    FAKE.raceID = 1         -- UnitRace: 1 = humano
    FAKE.faction = 'Alliance'
    FAKE.spells = {}
    UnitRace = function() return 'Humano', 'Human', FAKE.raceID end
    UnitFactionGroup = function() return FAKE.faction, FAKE.faction end
    IsPlayerSpell = function(id) return FAKE.spells[id] == true end
    IsSpellKnown = function(id) return FAKE.spells[id] == true end
    LibQuestieDB, Questie = nil, nil
    GetProfessions = function()
        local indexes = {}
        for i = 1, #FAKE.professions do indexes[i] = i end
        return indexes[1], indexes[2], indexes[3], indexes[4], indexes[5], indexes[6]
    end
    GetProfessionInfo = function(index)
        local p = FAKE.professions[index]
        if not p then return nil end
        return p.name, 'icon', 1, 300, 0, 0, p.skillLine
    end
    -- Listas con encabezados plegables: lo plegado no se ve. skillLines usa isExpanded=false para
    -- plegar; questLog usa isCollapsed=true. Expandir/plegar dispara el evento como el cliente real.
    FAKE.inCombat = false
    FAKE.noTotal = false
    FAKE.calls = { expand = 0, collapse = 0 }
    FAKE.selected = nil
    local function visible(list, isCollapsed)
        local result, hidden = {}, false
        for _, entry in ipairs(list) do
            if entry.isHeader then hidden = isCollapsed(entry) end
            if entry.isHeader or not hidden then result[#result + 1] = entry end
        end
        return result
    end
    local function totalQuests()
        if FAKE.noTotal then return nil end -- cliente sin el 2.o retorno de GetNumQuestLogEntries
        local total = 0
        for _, entry in ipairs(FAKE.questLog) do if not entry.isHeader then total = total + 1 end end
        return total
    end
    local function skillCollapsed(entry) return entry.isExpanded == false end
    local function questCollapsed(entry) return entry.isCollapsed == true end
    local function setCollapsed(list, isCollapsed, index, collapsed, field, event, counter, inverse)
        local entry = visible(list, isCollapsed)[index]
        if not entry or not entry.isHeader then return end
        if inverse then entry[field] = not collapsed else entry[field] = collapsed end
        FAKE.calls[counter] = FAKE.calls[counter] + 1
        FAKE.selected = nil -- el cliente real tambien pierde la seleccion
        FAKE.Fire(event)
    end
    InCombatLockdown = function() return FAKE.inCombat end
    GetNumSkillLines = function() return #visible(FAKE.skillLines, skillCollapsed) end
    GetSkillLineInfo = function(index)
        local s = visible(FAKE.skillLines, skillCollapsed)[index]
        if not s then return nil end
        return s.name, s.isHeader, s.isExpanded
    end
    ExpandSkillHeader = function(index)
        setCollapsed(FAKE.skillLines, skillCollapsed, index, false, 'isExpanded', 'SKILL_LINES_CHANGED', 'expand', true)
    end
    CollapseSkillHeader = function(index)
        setCollapsed(FAKE.skillLines, skillCollapsed, index, true, 'isExpanded', 'SKILL_LINES_CHANGED', 'collapse', true)
    end
    local function expandQuest(index)
        setCollapsed(FAKE.questLog, questCollapsed, index, false, 'isCollapsed', 'QUEST_LOG_UPDATE', 'expand')
    end
    local function collapseQuest(index)
        setCollapsed(FAKE.questLog, questCollapsed, index, true, 'isCollapsed', 'QUEST_LOG_UPDATE', 'collapse')
    end
    ExpandQuestHeader, CollapseQuestHeader = expandQuest, collapseQuest
    C_QuestLog = {
        IsQuestFlaggedCompleted = function(questID) return FAKE.completed[questID] == true end,
        GetNumQuestLogEntries = function() return #visible(FAKE.questLog, questCollapsed), totalQuests() end,
        GetInfo = function(index) return visible(FAKE.questLog, questCollapsed)[index] end,
        GetQuestObjectives = function(questID)
            for _, q in ipairs(FAKE.questLog) do if q.questID == questID then return q.objectives or {} end end
            return {}
        end,
        ExpandQuestHeader = expandQuest,
        CollapseQuestHeader = collapseQuest,
        GetSelectedQuest = function() return FAKE.selected end,
        SetSelectedQuest = function(questID) FAKE.selected = questID end,
    }
    -- API clasica del diario (la usa el cliente cuando falta C_QuestLog.GetInfo).
    GetNumQuestLogEntries = function() return #visible(FAKE.questLog, questCollapsed), totalQuests() end
    GetQuestLogTitle = function(index)
        local q = visible(FAKE.questLog, questCollapsed)[index]
        if not q then return nil end
        return q.title, 1, '', q.isHeader, q.isCollapsed, nil, nil, q.questID
    end
    GetNumQuestLeaderBoards = function(index)
        local q = visible(FAKE.questLog, questCollapsed)[index]
        return q and q.objectives and #q.objectives or 0
    end
    GetQuestLogLeaderBoard = function(objective, index)
        local q = visible(FAKE.questLog, questCollapsed)[index]
        local o = q and q.objectives and q.objectives[objective]
        if o then return o.text, o.type, false end
    end
    GetQuestLogSelection = function() return FAKE.selected or 0 end
    SelectQuestLogEntry = function(index) FAKE.selected = index end
    IsQuestFlaggedCompleted = function(questID) return FAKE.completed[questID] == true end
    GetItemInfo = function(key)
        local id, d = itemOf(key)
        if not d then return nil end
        return d.name, linkOf(id), d.quality, d.itemLevel or 1, d.reqLevel or 1, 'Tipo', d.subType, 1, d.equipLoc or '', 'icon',
            d.price, d.classID, d.subclassID, 0, 0, d.setID, false
    end
    GetItemInfoInstant = function(key)
        local id, d = itemOf(key)
        if not d then return nil end
        return id, 'Tipo', d.subType, d.equipLoc or '', 'icon', d.classID, d.subclassID
    end
    GetInventoryItemID = function(unit, slot)
        if unit == 'player' then return FAKE.equipped[slot] end
    end
    GetInventoryItemLink = function(unit, slot)
        local id = unit == 'player' and FAKE.equipped[slot]
        if id then return linkOf(id) end
    end
    GetItemSpell = function(key)
        local _, d = itemOf(key)
        if d and d.spell then return 'Hechizo', 1234 end
    end
    -- Tooltip de un enlace: la primera linea es el nombre; despues FAKE.items[id].tooltip (textos).
    FAKE.tooltipCalls = 0
    C_TooltipInfo = {
        GetHyperlink = function(link)
            FAKE.tooltipCalls = FAKE.tooltipCalls + 1
            local _, d = itemOf(link)
            if not d then return nil end
            local lines = { { leftText = d.name } }
            for _, text in ipairs(d.tooltip or { d.typeLine or "Tipo" }) do lines[#lines + 1] = { leftText = text } end
            return { lines = lines }
        end,
    }
    C_Container = {
        GetContainerNumSlots = function(bag) return FAKE.bagSizes[bag] or 8 end,
        GetContainerItemID = function(bag, slot) return FAKE.bags[bag .. ':' .. slot] end,
        GetContainerItemLink = function(bag, slot)
            local id = FAKE.bags[bag .. ':' .. slot]
            return id and linkOf(id)
        end,
        UseContainerItem = function(bag, slot) FAKE.used[#FAKE.used + 1] = {bag, slot} end,
        GetContainerItemInfo = function(bag, slot)
            local id = FAKE.bags[bag .. ':' .. slot]
            if not id then return nil end
            return { itemID = id, hyperlink = FAKE.items[id] and linkOf(id) or nil, isBound = FAKE.bound[bag .. ':' .. slot] }
        end,
    }
    FAKE.guids, FAKE.bagSizes, FAKE.locks, FAKE.unlocks, FAKE.used, FAKE.itemLocks = {}, {}, {}, {}, {}, {}
    ItemLocation = { CreateFromBagAndSlot = function(_, bag, slot) return { bag = bag, slot = slot } end }
    C_Item = {
        GetItemGUID = function(loc)
            local key = loc.bag .. ':' .. loc.slot
            return FAKE.bags[key] and (FAKE.guids[key] or ('guid:' .. key .. ':' .. FAKE.bags[key]))
        end,
        LockItemByGUID = function(guid)
            FAKE.locks[#FAKE.locks + 1] = guid; FAKE.itemLocks[guid] = true
        end,
        UnlockItemByGUID = function(guid)
            FAKE.unlocks[#FAKE.unlocks + 1] = guid; FAKE.itemLocks[guid] = nil
        end,
        IsLocked = function(loc) return FAKE.itemLocks[C_Item.GetItemGUID(loc)] == true end,
    }
    StaticPopupDialogs = {}
    FAKE.popup = nil
    StaticPopup_Show = function(key, text, _, data)
        FAKE.popup = { key = key, text = text, data = data, dialog = StaticPopupDialogs[key] }
        return FAKE.popup
    end
end
-- Cliente clasico: sin Settings, con InterfaceOptions_AddCategory e InterfaceOptionsFrame_OpenToCategory.
function FAKE.InstallClassicOptions()
    Settings = nil
    FAKE.interfaceOptions = { added = {}, opened = {} }
    InterfaceOptions_AddCategory = function(panel) FAKE.interfaceOptions.added[#FAKE.interfaceOptions.added + 1] = panel end
    InterfaceOptionsFrame_OpenToCategory = function(panel) FAKE.interfaceOptions.opened[#FAKE.interfaceOptions.opened + 1] = panel end
end
function FAKE.Remove(path)
    local owner, key = path:match('^(.-)%.(.+)$')
    if owner then _G[owner][key] = nil else _G[path] = nil end
end
-- LibQuestieDB falso (solo pruebas). quests = { [questID] = { campo = valor } } con los nombres
-- de campo reales de Quest.Get. opts.contract = contrato maximo que dice soportar (por defecto 4),
-- opts.throwOn = questID para el que Quest.Get lanza error, opts.throwRequire = RequireContract lanza.
FAKE.questieCalls = 0
function FAKE.InstallQuestie(quests, opts)
    opts = opts or {}
    FAKE.questieCalls = 0
    local ids = {}
    for questID in pairs(quests) do ids[#ids + 1] = questID end
    table.sort(ids)
    LibQuestieDB = {
        RequireContract = function(required)
            if opts.throwRequire then error('RequireContract roto') end
            return required >= 1 and required <= (opts.contract or 4)
        end,
        Enum = {
            raceMaskById = { [1] = 1, [2] = 2, [3] = 4, [4] = 8, [5] = 16, [6] = 32, [7] = 64, [8] = 128,
                [9] = 256, [10] = 512, [11] = 1024 },
            factionRaceMasks = { Alliance = 1 + 4 + 8 + 64 + 1024, Horde = 2 + 16 + 32 + 128 + 512 },
            classKeys = { WARRIOR = 1, PALADIN = 2, HUNTER = 4, ROGUE = 8, PRIEST = 16, DEATH_KNIGHT = 32,
                SHAMAN = 64, MAGE = 128, WARLOCK = 256, MONK = 512, DRUID = 1024, ALL_CLASSES = 1503 },
        },
        Quest = {
            Get = function(questID, key)
                FAKE.questieCalls = FAKE.questieCalls + 1
                if opts.throwOn == questID then error('Quest.Get roto') end
                local quest = quests[questID]
                return quest and quest[key]
            end,
            GetAllIds = function() return ids end,
        },
    }
    return LibQuestieDB
end
-- Baganator falso (solo pruebas): graba lo que se registra y deja a la prueba invocar los callbacks.
-- FAKE.baganator = { junk = {label=, id=, callback=}, widgets = { [id] = {label=, onUpdate=, onInit=} },
-- refreshes = n, activeJunk = id|nil, activeWidgets = { [id] = true } }.
function FAKE.InstallBaganator()
    local state = { junk = {}, widgets = {}, refreshes = 0, activeWidgets = {} }
    FAKE.baganator = state
    FAKE.addons.Baganator = true
    Baganator = { API = {
        RegisterJunkPlugin = function(label, id, callback)
            if type(label) ~= 'string' or type(id) ~= 'string' or type(callback) ~= 'function' then error('Bad junk plugin arguments') end
            state.junk[id] = { label = label, id = id, callback = callback }
        end,
        RegisterCornerWidget = function(label, id, onUpdate, onInit, defaultPosition, isFast)
            assert(id and label and onUpdate and onInit and not state.widgets[id])
            if defaultPosition ~= nil and (type(defaultPosition) ~= 'table' or type(defaultPosition.priority) ~= 'number'
                or ({ top_left = 1, top_right = 1, bottom_left = 1, bottom_right = 1 })[defaultPosition.corner] == nil) then
                error('defaultPosition invalida')
            end
            state.widgets[id] = { label = label, onUpdate = onUpdate, onInit = onInit, defaultPosition = defaultPosition, isFast = isFast }
        end,
        RequestItemButtonsRefresh = function(reason) state.refreshes = state.refreshes + 1; state.lastReason = reason end,
        IsJunkPluginActive = function(id) return state.activeJunk == id end,
        IsCornerWidgetActive = function(id) return state.activeWidgets[id] == true end,
    }, Constants = { RefreshReason = { ItemWidgets = 4, Searches = 16 } } } -- valores de Baganator Core/Constants.lua
    return state
end
function FAKE.Reset()
    GearQuest, PawnGetAllScalesEx, PawnGetItemData, PawnIsItemAnUpgrade, PawnGetItemDataForInventorySlot = nil, nil, nil, nil, nil
    GetNumTalentTabs, GetTalentTabInfo = nil, nil
    CanMerchantRepair, GetRepairAllCost, RepairAllItems, GetMoney, IsInGuild, CanGuildBankRepair = nil, nil, nil, nil, nil, nil
    hooksecurefunc = secureHook
    C_Timer.NewTicker = newTicker
    LeaPlusDB, debugstack, GetCoinTextureString, UseContainerItem = nil, nil, nil, nil
    GQ, C_EquipmentSet, GetEquipmentSetItemIDs, GetNumEquipmentSets, GetEquipmentSetInfo = nil, nil, nil, nil, nil
    Auctionator, ColorPickerFrame = nil, nil
    FAKE.time = 0; FAKE.timers = {}; FAKE.messages = {}; FAKE.saleStub = nil
    FAKE.bindings = {}; FAKE.savedBindings = {}; FAKE.inCombat = false
    FAKE.shift, FAKE.ctrl, FAKE.alt = false, false, false
    IsShiftKeyDown = function() return FAKE.shift end
    IsControlKeyDown = function() return FAKE.ctrl end
    IsAltKeyDown = function() return FAKE.alt end
    GetBindingAction = function(key) return FAKE.bindings[key] or '' end
    GetBindingKey = function(action)
        for key, value in pairs(FAKE.bindings) do if value == action then return key end end
    end
    GetBindingText = function(key) return key end
    SetBinding = function(key, action) FAKE.bindings[key] = action; return true end
    SaveBindings = function(set) FAKE.savedBindings[#FAKE.savedBindings + 1] = set; return true end
    GetCurrentBindingSet = function() return 2 end
    for name in pairs(_G) do
        if type(name) == 'string' and name:sub(1, 9) == 'Baganator' then _G[name] = nil end
    end
    FAKE.baganator = nil
    for _, name in ipairs({ 'ArkInventory', 'EUI_Bags', 'LiteBag_RegisterHook', 'tdBag2', 'Baggins', 'Bagnon', 'Bagnonium',
        'ElvUI', 'BaudBag', 'SetItemButtonQuality', 'ItemButtonMixin', 'ContainerFrameItemButtonMixin',
        'LootFrame_Update', 'ScrollUtil', 'LootFrameElementMixin', 'LootFrameItemElementMixin', 'GetLootSlotLink', 'LOOTFRAME_NUMBUTTONS',
        'TooltipDataProcessor', 'Enum', 'GetItemSubClassInfo', 'QuestUtils_GetQuestName', 'ItemRefTooltip',
        'TooltipUtil', 'C_Item', 'Syndicator', 'BankPanelItemButtonMixin', 'CamelotBankPanelItemButtonMixin',
        'BankPanel', 'BankFrame', 'ItemLocation', 'ITEM_SPELL_TRIGGER_ONEQUIP', 'ITEM_SPELL_TRIGGER_ONUSE',
        'ITEM_SPELL_TRIGGER_ONPROC', 'ITEM_SOULBOUND', 'GetSpellInfo', 'C_Spell', 'LOCALIZED_CLASS_NAMES_MALE',
        'Settings', 'InterfaceOptions_AddCategory', 'InterfaceOptionsFrame_OpenToCategory', 'ForeverSettings',
        'ITEM_QUALITY_COLORS', 'GetMouseFoci', 'GetMouseFocus' }) do _G[name] = nil end
    for name in pairs(FAKE.named) do _G[name] = nil end
    FAKE.named = {}
    installClient()
    GameTooltip = CreateFrame('Tooltip') -- limpio: sin hooks, scripts ni lineas de la prueba anterior
    if ns and ns.Bank then ns.Bank.ResetState() end -- antes que Marks y Bags: ellos se vuelven a suscribir
    if ns and ns.Player then ns.Player.ResetState() end
    if ns and ns.Questie then ns.Questie.ResetState() end
    if ns and ns.Marks then ns.Marks.ResetState() end
    if ns and ns.Merchant then ns.Merchant.ResetState() end
    if ns and ns.AutoSell then ns.AutoSell.ResetState() end
    if ns and ns.Bags then ns.Bags.ResetState() end
    if ns and ns.Blizzard then ns.Blizzard.ResetState() end
    if ns and ns.Loot then ns.Loot.ResetState() end
    if ns and ns.Tooltip then ns.Tooltip.ResetState() end
    if ns and ns.Options then ns.Options.ResetState() end
    if ns and ns.BaganatorAdapter then ns.BaganatorAdapter.ResetState() end
    if ns and ns.Bags and ns.Bags.Common then ns.Bags.Common.ResetState() end
    KnuJunkDB = nil; FAKE.Fire('ADDON_LOADED', 'KnuJunk')
end
FAKE.Reset()
