local _, ns = ...

-- Lo que cada clase de Classic PUEDE LLEGAR A usar (aunque todavia no haya aprendido la
-- habilidad). Armadura: 1 tela, 2 cuero, 3 malla, 4 placas, 6 escudo. Armas: 0/1 hacha 1M/2M,
-- 2 arco, 3 arma de fuego, 4/5 maza 1M/2M, 6 arma de asta, 7/8 espada 1M/2M, 10 baston,
-- 13 punio, 15 daga, 16 arrojadiza, 18 ballesta, 19 varita.
-- Regla de Classic: verificar en el juego antes de publicar y anotar diferencias de Forever.
local function set(list)
    local result = {}
    for _, id in ipairs(list) do result[id] = true end
    return result
end

ns.ClassGear = {
    WARRIOR = { armor = set { 1, 2, 3, 4, 6 }, weapon = set { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 } },
    PALADIN = { armor = set { 1, 2, 3, 4, 6 }, weapon = set { 0, 1, 4, 5, 6, 7, 8 } },
    HUNTER  = { armor = set { 1, 2, 3 },       weapon = set { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 16, 18 } },
    ROGUE   = { armor = set { 1, 2 },          weapon = set { 2, 3, 4, 7, 13, 15, 16, 18 } },
    PRIEST  = { armor = set { 1 },             weapon = set { 4, 10, 15, 19 } },
    SHAMAN  = { armor = set { 1, 2, 3, 6 },    weapon = set { 0, 1, 4, 5, 10, 13, 15 } },
    MAGE    = { armor = set { 1 },             weapon = set { 7, 10, 15, 19 } },
    WARLOCK = { armor = set { 1 },             weapon = set { 7, 10, 15, 19 } },
    DRUID   = { armor = set { 1, 2 },          weapon = set { 4, 5, 10, 13, 15 } },
}
