local _, ns = ...
local KL = LibStub('KnuLib-1.0')
ns.KL = KL
ns.Defaults = { enabled = true, show = { coin = true, hammer = true, loot = true }, overrides = {} }
ns.Print = KL:NewPrinter('Junk')

-- Completa en target lo que falte según source, sin pisar valores del usuario.
local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' then
            if type(target[key]) ~= 'table' then target[key] = {} end
            merge(target[key], value)
        elseif target[key] == nil then target[key] = value end
    end
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
        merge(KnuJunkDB, ns.Defaults)
        ns.DB = KnuJunkDB
    elseif event == 'PLAYER_LOGIN' then
        loggedIn = true
        for _, fn in ipairs(loginHandlers) do fn() end
        loginHandlers = {}
    end
end)
