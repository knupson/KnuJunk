local _, ns = ...

-- /knu junk (alias /knu kj): activar/desactivar las marcas y fijar a mano que guardar o vender.
-- Subcomandos: (vacio) | options abre el panel de opciones | help ayuda | on | off | coin|hammer|loot on|off |
-- keep|sell|clear <enlace o itemID> | rules [food|ammo|knownrecipe] [on|off] | status.
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
        'By hand: /knu junk keep|sell|clear <item link or ID>',
        'Optional rules: /knu junk rules [food|ammo|knownrecipe] [on|off]',
        'Show state: /knu junk status',
    }) do ns.Print(L(line)) end
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
        onOff(db.show.hammer), onOff(db.show.loot))
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
        overrides[id] = nil
        changed()
        say('Manual mark removed from item %d', id)
        return
    end
    overrides[id] = action
    changed()
    say('Item %d: %s', id, L(action == 'keep' and 'Marked by hand: keep' or 'Marked by hand: sell'))
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
        setFlag(function(value) db.show[sub] = value end, state == 'on', 'Mark %s: %s', sub)
    elseif sub == 'keep' or sub == 'sell' or sub == 'clear' then
        manual(sub, rest)
    elseif sub == 'status' then
        Commands.Status()
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
            L('Junk marks: options panel, on/off, coin/hammer/loot, keep/sell/clear, rules, status'), { 'kj' })
    end
end

ns.OnLogin(function() pcall(Commands.Register) end)
