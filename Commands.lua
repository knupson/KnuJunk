local _, ns = ...

-- /knu junk (alias /knu kj): activa o desactiva las marcas y fija a mano que guardar o vender. Subcomandos: options | help | on | off | coin|hammer|loot on|off | keep|sell|clear <enlace o itemID> | rules [food|ammo|knownrecipe] [on|off] | status.
-- Todo cambio pasa por ns.Changed (Core.lua): ensucia el contexto del jugador y pide el repintado.
local Commands = {}
ns.Commands = Commands

local KINDS = { coin = true, hammer = true, loot = true }
local RULES = { food = 'food', ammo = 'ammo', knownrecipe = 'knownRecipe' }

local function L(key) return ns.L[key] end
local function say(key, ...) ns.Print(string.format(L(key), ...)) end

local function onOff(value) return value and L('on') or L('off') end
local function yesNo(value) return value and L('yes') or L('no') end

local function changed() ns.Changed() end

function Commands.Help()
    for _, line in ipairs({
        'Options panel: /knu junk',
        'Marks on/off: /knu junk on | off',
        'One kind: /knu junk coin|hammer|loot on|off',
        'By hand: /knu junk keep|clear <item link or ID>',
        'Optional rules: /knu junk rules [food|ammo|knownrecipe] [on|off]',
        'Show state: /knu junk status',
    }) do ns.Print(L(line)) end
    say('Other KNU addons: KnuCompanion, your bags, bank, map and quests on your other monitor (%s). All: %s', Commands.COMPANION, Commands.KNU_PROJECTS)
    Commands.Invite()
end

Commands.CURSEFORGE = 'https://www.curseforge.com/wow/addons/knujunk'
Commands.COMPANION = 'https://companion.knunet.com'
Commands.KNU_PROJECTS = 'https://www.curseforge.com/members/knupwns/projects'
Commands.ISSUES = 'https://github.com/knupson/KnuJunk/issues'

-- Invitación a dejar favorito y comentario y a reportar errores; va al pie de la ayuda.
function Commands.Invite()
    say('If KnuJunk helps you, a favorite and a comment on CurseForge help other Forever players find it: %s', Commands.CURSEFORGE)
    say('Found a bug? Open an issue with the error text (BugSack copies it) and what you were doing: %s', Commands.ISSUES)
end

-- Una sola vez por cuenta: KnuJunkDB es SavedVariables de cuenta y el flag no está en los defaults.
function Commands.InviteOnce()
    local db = ns.DB
    if type(db) ~= 'table' or db.invited then return false end
    db.invited = true
    Commands.Invite()
    return true
end

-- itemID de un enlace de item (|Hitem:123:...) o de un numero suelto; nil si no es ninguno.
function Commands.ParseItem(text)
    if type(text) ~= 'string' then return nil end
    local id = text:match('|Hitem:(%d+)') or text:match('^%s*(%d+)%s*$')
    id = tonumber(id)
    if id and id > 0 then return id end
end

function Commands.Status()
    local info, db = ns.Options.StatusInfo(), ns.DB
    say('Data build: %s', info.build)
    say('QuestieDB: %s, index ready: %s', yesNo(info.questie), yesNo(info.ready))
    say('Bag adapters: %s', #info.adapters > 0 and table.concat(info.adapters, ', ') or L('none'))
    say('Marks: %s | coin: %s | hammer: %s | loot: %s', onOff(db.enabled), onOff(db.show.coin),
        onOff(db.show.hammer_mine and db.show.hammer_other), onOff(db.show.loot))
    say('Manual marks: %d', info.overrides)
    Commands.RulesStatus()
end

function Commands.RulesStatus()
    local rules = ns.DB.rules or {}
    say('Rules: food: %s | ammo: %s | knownrecipe: %s', onOff(rules.food), onOff(rules.ammo), onOff(rules.knownRecipe))
end

local function setFlag(setter, value, label, kind)
    setter(value)
    changed()
    if kind then say(label, kind, onOff(value)) else say(label, onOff(value)) end
end

local function manual(action, rest)
    if rest == '' then say('Usage: /knu junk %s <item link or ID>', action) return end
    local id = Commands.ParseItem(rest)
    if not id then say('Invalid item: %s', rest) return end
    local overrides = ns.DB.overrides
    if action == 'clear' then
        if overrides[id] == nil then say('No manual mark on item %d', id) return end
        ns.Overrides.Set(id, nil)
        say('Manual mark removed from item %d', id)
        return
    end
    ns.Overrides.Set(id, action)
    say('Item %d: %s', id, L(action == 'keep' and 'Protected (by hand)' or 'Sell (legacy mark)'))
end

function Commands.Handle(args)
    local sub, rest = strtrim(args or ''):match('^(%S+)%s*(.*)$')
    if not sub then ns.Options.Open() return end
    sub = sub:lower()
    local db = ns.DB
    if sub == 'options' or sub == 'opciones' then
        ns.Options.Open()
    elseif sub == 'help' or sub == 'ayuda' then
        Commands.Help()
    elseif sub == 'on' or sub == 'off' then
        setFlag(function(value) db.enabled = value end, sub == 'on', 'Marks: %s')
    elseif KINDS[sub] then
        local state = rest:lower()
        if state ~= 'on' and state ~= 'off' then say('Usage: /knu junk %s on|off', sub) return end
        setFlag(function(value) if sub == 'hammer' then db.show.hammer_mine, db.show.hammer_other = value, value else db.show[sub] = value end end, state == 'on', 'Mark %s: %s', sub)
    elseif sub == 'keep' or sub == 'sell' or sub == 'clear' then
        manual(sub, rest)
    elseif sub == 'status' then
        Commands.Status()
    elseif sub == 'debug' and rest:lower() == 'venta' then
        local v = ns.AutoSell.LastVisit or {}
        local api = C_Item and type(C_Item.GetItemGUID) == 'function'
        ns.Print(string.format('Última venta: pedidos=%s contados=%s ilegibles=%s vendidos=%s total=%s | GetItemGUID=%s DoesItemExist=%s',
            tostring(v.attempted), tostring(v.counted), tostring(v.unreadable), tostring(v.sold), tostring(v.total),
            tostring(api), tostring(C_Item and type(C_Item.DoesItemExist) == 'function')))
    elseif sub == 'debug' then
        local lines = ns.Player.DebugTooltip(rest)
        if not lines then say('Usage: /knu junk debug [item link]') return end
        for _, line in ipairs(lines) do ns.Print(line) end
    elseif sub == 'rules' then
        if rest == '' then Commands.RulesStatus() return end
        local name, state = rest:lower():match('^(%S+)%s+(%S+)$')
        local key = name and RULES[name]
        if not key or (state ~= 'on' and state ~= 'off') then
            say('Optional rules: /knu junk rules [food|ammo|knownrecipe] [on|off]')
            return
        end
        setFlag(function(value) db.rules[key] = value end, state == 'on', 'Rule %s: %s', name)
    else
        say('Unknown option: %s', sub)
        Commands.Help()
    end
end

-- Se registra en el login, nunca al cargar el archivo: una copia vieja de KnuLib puede seguir activa.
function Commands.Register()
    local KL = LibStub('KnuLib-1.0')
    if KL.RegisterCommand then
        KL:RegisterCommand('junk', function(args) Commands.Handle(args) end,
            L('Junk marks: options panel, on/off, coin/hammer/loot, keep/clear, rules, status'), { 'kj' })
    end
end

ns.OnLogin(function()
    pcall(Commands.Register)
    if C_Timer and type(C_Timer.After) == 'function' then
        C_Timer.After(15, function() pcall(Commands.InviteOnce) end)
    end
end)
