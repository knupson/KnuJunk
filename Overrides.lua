local _, ns = ...
local Overrides = {}
ns.Overrides = Overrides
BINDING_HEADER_KNUJUNK = 'KnuJunk'
BINDING_NAME_KNUJUNK_CYCLE_HOVERED = ns.L['Change mark of item under mouse']

function Overrides.Set(id, action)
    ns.DB.overrides[id] = action
    ns.Changed()
end

function Overrides.Cycle(id)
    local old = ns.DB.overrides[id]
    local action
    if old == nil then action = 'keep' elseif old == 'keep' then action = 'sell' end
    Overrides.Set(id, action)
    return action
end

function KnuJunk_CycleHovered()
    local id = Overrides.hovered
    local tooltip = rawget(_G, 'GameTooltip')
    if tooltip and type(tooltip.IsShown) == 'function' and type(tooltip.GetItem) == 'function' then
        local shown, visible = pcall(tooltip.IsShown, tooltip)
        if shown and visible then
            local success, _, link = pcall(tooltip.GetItem, tooltip)
            if success and type(link) == 'string' then id = tonumber(link:match('item:(%d+)')) or id end
        end
    end
    if not id then
        ns.Print(ns.L['Hover an item first, then press the key'])
        return
    end
    local action = Overrides.Cycle(id)
    local api = type(GetItemInfo) == 'function' and GetItemInfo
        or (type(C_Item) == 'table' and C_Item.GetItemInfo)
    local link
    if type(api) == 'function' then
        local success, _, value = pcall(api, id)
        if success then link = value end
    end
    local label = link or string.format(ns.L['item %d'], id)
    local key = action == 'keep' and 'Always keep: %s (never a coin)'
        or action == 'sell' and 'Always sell: %s (always a coin)' or 'Automatic again: %s'
    ns.Print(string.format(ns.L[key], label))
end
