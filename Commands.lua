local _, ns = ...

-- /knu junk (alias /knu kj): activar/desactivar las marcas y fijar a mano que guardar o vender.
-- Subcomandos: (vacio) ayuda | on | off | coin|hammer|loot on|off | keep|sell|clear <enlace o itemID> | status.
-- Todo cambio ensucia el contexto del jugador y pide un repintado de las bolsas (Loot esta registrado
-- en Bags, asi que la ventana de botin abierta tambien se repinta).
local Commands = {}
ns.Commands = Commands

local KINDS = { coin = true, hammer = true, loot = true }
local RULES = { food = 'food', ammo = 'ammo', knownrecipe = 'knownRecipe' }

local function L(key) return ns.L[key] end
local function say(key, ...) ns.Print(string.format(L(key), ...)) end

local function onOff(value) return value and L('on') or L('off') end
local function yesNo(value) return value and L('yes') or L('no') end

-- Cada cambio de enabled/show/overrides pasa por aca.
local function changed()
    if ns.Player and ns.Player.Invalidate then ns.Player.Invalidate() end
    if ns.Bags and ns.Bags.RefreshAll then ns.Bags.RefreshAll() end
end

function Commands.Help()
    for _, line in ipairs({
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
    local questie, ready = ns.Questie, false
    local available = questie and questie.Available and questie.Available() or false
    if available then ready = questie.IsReady and questie.IsReady() or false end
    local adapters = ns.Bags and ns.Bags.Installed and ns.Bags.Installed() or {}
    local db = ns.DB
    local count = 0
    for _ in pairs(db.overrides) do count = count + 1 end
    say('Data build: %s', tostring(ns.Data and ns.Data.build or '?'))
    say('QuestieDB: %s, index ready: %s', yesNo(available), yesNo(ready))
    say('Bag adapters: %s', #adapters > 0 and table.concat(adapters, ', ') or L('none'))
    say('Marks: %s | coin: %s | hammer: %s | loot: %s', onOff(db.enabled), onOff(db.show.coin),
        onOff(db.show.hammer), onOff(db.show.loot))
    say('Manual marks: %d', count)
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
    if not sub then Commands.Help() return end
    sub = sub:lower()
    local db = ns.DB
    if sub == 'on' or sub == 'off' then
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
            L('Junk marks: on/off, coin/hammer/loot, keep/sell/clear, status'), { 'kj' })
    end
end

ns.OnLogin(function() pcall(Commands.Register) end)
