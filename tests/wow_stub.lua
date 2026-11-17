FAKE = { frames = {} }
strmatch = string.match
STANDARD_TEXT_FONT = 'Fonts\\FRIZQT__.TTF'
local methods = {}
local unpack = unpack or table.unpack
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event, fn)
    local previous = self.scripts[event]
    self.scripts[event] = function(...) if previous then previous(...) end; fn(...) end
end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:IsMouseOver() return self.mouseOver == true end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:SetText(text) self.text = text; if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self, false) end end
function methods:GetText() return self.text or '' end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:GetID() return self.id end
function methods:GetParent() return self.parent end
function methods:CreateFontString() return CreateFrame('FontString') end
function methods:GetName() return self.name end
function methods:GetFontString() return self.Text end
function methods:SetAlpha(value) self.alpha = value end
function methods:SetBackdrop(value) self.backdrop = value end
function methods:SetBackdropColor(...) self.bg = {...} end
function methods:SetBackdropBorderColor(...) self.border = {...} end
function methods:SetVertexColor(...) self.vertex = {...} end
function methods:SetTextColor(...) self.textColor = {...} end
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
for _, method in ipairs({'SetPoint','SetSize','SetWidth','SetHeight','RegisterForClicks','EnableMouse','SetOwner','AddLine','SetHyperlink','HighlightText','SetCursorPosition','SetAutoFocus','ClearAllPoints','SetNormalTexture','SetHighlightTexture'}) do methods[method] = function() end end
function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({ scripts = {}, events = {}, shown = true, parent = parent,
        name = name, enabled = true, alpha = 1 }, {__index = methods})
    FAKE.frames[#FAKE.frames + 1] = frame
    if name then _G[name] = frame end
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
function GetTime() return FAKE.time end
function GetLocale() return FAKE.locale or 'esES' end
function strtrim(text) return (text:gsub('^%s+', ''):gsub('%s+$', '')) end
SlashCmdList = setmetatable({}, {__index = {}}); hash_SlashCmdList = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) FAKE.messages[#FAKE.messages + 1] = message end}
function FAKE.Reset()
    FAKE.time = 0; FAKE.timers = {}; FAKE.messages = {}
    KnuJunkDB = nil; FAKE.Fire('ADDON_LOADED', 'KnuJunk')
end
FAKE.Reset()
