-- Invitación a opinar y reportar: una sola vez por cuenta y al pie de la ayuda.
local function printed() return table.concat(FAKE.messages, '\n') end

test('invitación: la primera vez imprime CurseForge e issues y deja el flag', function()
    local saved = ns.DB.invited
    ns.DB.invited = nil
    FAKE.messages = {}
    eq(ns.Commands.InviteOnce(), true)
    ok(printed():find(ns.Commands.CURSEFORGE, 1, true), 'link de CurseForge')
    ok(printed():find(ns.Commands.ISSUES, 1, true), 'link de issues')
    eq(ns.DB.invited, true)
    ns.DB.invited = saved
end)

test('invitación: con el flag puesto no se repite', function()
    local saved = ns.DB.invited
    ns.DB.invited = true
    FAKE.messages = {}
    eq(ns.Commands.InviteOnce(), false)
    eq(#FAKE.messages, 0)
    ns.DB.invited = saved
end)

test('invitación: el flag no viene de los defaults', function()
    eq(ns.Defaults.invited, nil)
end)

test('invitación: los links son los del proyecto', function()
    eq(ns.Commands.CURSEFORGE, 'https://www.curseforge.com/wow/addons/knujunk')
    eq(ns.Commands.ISSUES, 'https://github.com/knupson/KnuJunk/issues')
end)
