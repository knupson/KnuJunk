-- Generado por tools/build_data.py desde wago.tools wowf 1.60.1.70959. No editar.
local _, ns = ...
ns.Data = ns.Data or {}
ns.Data.build = "1.60.1.70959"
-- Lo que cada clase puede llegar a usar (aunque todavia no haya aprendido la habilidad),
-- por la ClassMask de SkillLineAbility. Subclases: ver GEAR_SPELLS en tools/build_data.py.
local function set(list)
    local result = {}
    for _, id in ipairs(list) do result[id] = true end
    return result
end
ns.ClassGear = {
    WARRIOR = { armor = set { 1, 2, 3, 4, 6 }, weapon = set { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 } },
    PALADIN = { armor = set { 1, 2, 3, 4, 6 }, weapon = set { 0, 1, 4, 5, 6, 7, 8 } },
    HUNTER = { armor = set { 1, 2, 3 }, weapon = set { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 16, 18 } },
    ROGUE = { armor = set { 1, 2 }, weapon = set { 0, 2, 3, 4, 7, 13, 15, 16, 18 } },
    PRIEST = { armor = set { 1 }, weapon = set { 4, 10, 15, 19 } },
    SHAMAN = { armor = set { 1, 2, 3, 6 }, weapon = set { 0, 1, 4, 5, 10, 13, 15 } },
    MAGE = { armor = set { 1 }, weapon = set { 7, 10, 15, 19 } },
    WARLOCK = { armor = set { 1 }, weapon = set { 7, 10, 15, 19 } },
    DRUID = { armor = set { 1, 2 }, weapon = set { 4, 5, 6, 10, 13, 15 } },
}
