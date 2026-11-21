local _, ns = ...
local KL = LibStub('KnuLib-1.0')
ns.KL = KL
ns.Defaults = { enabled = true, protectKeep = true, show = { coin = true, loot = true }, overrides = {} }
ns.Defaults.rules = { sellUnruled = true, gearNoRanking = true, armorBelow = true, food = true, ammo = true, knownRecipe = true, gearNotRanked = true }
ns.IconKinds = { 'protected', 'quest', 'hammer_mine', 'hammer_other', 'auction', 'coin', 'trash', 'useful', 'unruled' }
-- Paleta de 4 colores (decision del user 2026-11-18): el color dice que hacer, la forma por que.
-- Verde = te sirve, naranja = le sirve a otro, amarillo = plata, rojo = tirar; gris = sin regla.
local GREEN, ORANGE, YELLOW, RED, GREY = {111/255,211/255,106/255}, {1,154/255,60/255}, {1,210/255,60/255}, {232/255,90/255,74/255}, {160/255,160/255,160/255}
ns.IconColors = {
    protected = GREEN, quest = GREEN, hammer_mine = GREEN, useful = GREEN,
    hammer_other = ORANGE, auction = YELLOW, coin = YELLOW, trash = RED, unruled = GREY,
}
-- Colores por defecto de versiones anteriores: un color guardado identico a uno de estos se
-- considera "nunca tocado" y pasa al nuevo valor por defecto.
local OLD_DEFAULTS = {
    protected = {{111/255,179/255,1}}, quest = {{242/255,227/255,179/255}},
    hammer_mine = {{95/255,208/255,104/255}}, auction = {{194/255,123/255,1}},
    trash = {{224/255,106/255,90/255}}, useful = {{138/255,138/255,138/255}, {123/255,201/255,111/255}},
}
function ns.MigrateIconColors(colors)
    if type(colors) ~= 'table' then return end
    for kind, olds in pairs(OLD_DEFAULTS) do
        local saved = colors[kind]
        if type(saved) == 'table' then
            for _, old in ipairs(olds) do
                if math.abs((saved[1] or -1) - old[1]) < 0.002 and math.abs((saved[2] or -1) - old[2]) < 0.002
                    and math.abs((saved[3] or -1) - old[3]) < 0.002 then
                    local new = ns.IconColors[kind]
                    colors[kind] = { new[1], new[2], new[3] }
                    break
                end
            end
        end
    end
end
ns.Defaults.icons = { size = 14, opacity = 1, background = true, corner = 'TOPRIGHT', coinStyle = 'Blizzard', colors = ns.IconColors }
ns.Defaults.auction = { factor = 2, minCopper = 100 }
ns.Defaults.lootAdvisor = { enabled = true }
ns.Defaults.autoSell = { enabled = true, graysOnly = false, max = 12 }
ns.Defaults.autoRepair = { enabled = true, guild = false }
ns.Defaults.ui = { tab = 'General' }
for _, kind in ipairs(ns.IconKinds) do ns.Defaults.show[kind] = true end
ns.Defaults.show.owned = true
ns.Print = KL:NewPrinter('Junk')

-- Dinero legible: usa el formato del juego si existe; si no, sólo las unidades distintas de cero
-- («30p 48c», no «0o 30p 48c»; visto en el juego 2026-11-18).
function ns.FormatMoney(value)
    value = math.floor(tonumber(value) or 0)
    if type(GetCoinTextureString) == 'function' then
        local ok, text = pcall(GetCoinTextureString, value)
        if ok and type(text) == 'string' and text ~= '' then return text end
    end
    local gold, silver, copper = math.floor(value / 10000), math.floor(value / 100) % 100, value % 100
    local parts = {}
    if gold > 0 then parts[#parts + 1] = ns.L['%dg']:format(gold) end
    if silver > 0 then parts[#parts + 1] = ns.L['%ds']:format(silver) end
    if copper > 0 or #parts == 0 then parts[#parts + 1] = ns.L['%dc']:format(copper) end
    return table.concat(parts, ' ')
end
ns.Data = ns.Data or {}

-- SkillLine IDs de profesion de WoW Classic: [skillLineID] = true. Debe coincidir con
-- PROFESSIONS de tools/build_data.py (lo verifica tools/test_build_data.py).
ns.PROFESSIONS = {
    [164] = true, -- Herreria
    [165] = true, -- Peleteria
    [171] = true, -- Alquimia
    [182] = true, -- Herboristeria
    [186] = true, -- Mineria
    [197] = true, -- Sastreria
    [202] = true, -- Ingenieria
    [333] = true, -- Encantamiento
    [393] = true, -- Desuello
    [185] = true, -- Cocina
    [129] = true, -- Primeros Auxilios
    [356] = true, -- Pesca
}

-- Completa en target lo que falte según source, sin pisar valores del usuario.
local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' then
            if type(target[key]) ~= 'table' then target[key] = {} end
            merge(target[key], value)
        elseif target[key] == nil then target[key] = value end
    end
end

-- Cada cambio de enabled/show/rules/overrides (por comando o por el panel de opciones) pasa por aca:
-- ensucia el contexto del jugador, pide repintar las bolsas (Loot esta registrado en Bags, asi que la
-- ventana de botin abierta tambien se repinta) y, si el panel de opciones esta abierto, lo actualiza.
function ns.Changed()
    if ns.Merchant then pcall(ns.Merchant.Sync) end
    if ns.Player and ns.Player.Invalidate then ns.Player.Invalidate() end
    if ns.Bags and ns.Bags.RefreshAll then ns.Bags.RefreshAll() end
    if ns.Options and ns.Options.RefreshIfShown then ns.Options.RefreshIfShown() end
end

local loginHandlers, loggedIn = {}, false
-- Registra fn para PLAYER_LOGIN; si el login ya pasó, la corre en el acto.
function ns.OnLogin(fn)
    if loggedIn then fn() else loginHandlers[#loginHandlers + 1] = fn end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('ADDON_LOADED')
frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function(_, event, name)
    if event == 'ADDON_LOADED' then
        if name ~= 'KnuJunk' then return end
        if type(KnuJunkDB) ~= 'table' then KnuJunkDB = {} end
        -- Migrar antes de completar defaults; nunca pisar preferencias nuevas.
        local show = KnuJunkDB.show
        if type(show) == 'table' then
            if show.hammer_mine == nil then show.hammer_mine = show.hammer end
            if show.hammer_other == nil then show.hammer_other = show.hammer end
            show.hammer = nil
        end
        if type(KnuJunkDB.icons) == 'table' then ns.MigrateIconColors(KnuJunkDB.icons.colors) end
        -- Una sola vez: comida, munición y recetas aprendidas pasan a venderse por defecto
        -- (decisión del dueño: el default es monetizar). Después se respeta lo que elija.
        if (tonumber(KnuJunkDB.rulesVersion) or 0) < 2 then
            if type(KnuJunkDB.rules) == 'table' then
                KnuJunkDB.rules.food, KnuJunkDB.rules.ammo, KnuJunkDB.rules.knownRecipe = true, true, true
            end
            KnuJunkDB.rulesVersion = 2
        end
        merge(KnuJunkDB, ns.Defaults)
        ns.DB = KnuJunkDB
    elseif event == 'PLAYER_LOGIN' then
        loggedIn = true
        for _, fn in ipairs(loginHandlers) do fn() end
        loginHandlers = {}
    end
end)
