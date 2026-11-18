local _, ns = ...
ns.L = LibStub('KnuLib-1.0'):NewLocale({
    ['You have better food/drink for your level'] = 'Tenés comida/bebida mejor para tu nivel',
    ['You have compatible ammunition with higher damage'] = 'Tenés munición compatible de mayor daño',
    ['You already know this recipe'] = 'Ya conocés esta receta',
    ['You already know it; you can pass it on or auction it'] = 'Ya la conocés; podés pasarla o subastarla',
    ['Optional rules: /knu junk rules [food|ammo|knownrecipe] [on|off]'] = 'Reglas opcionales: /knu junk rules [food|ammo|knownrecipe] [on|off]',
    ['Rules: food: %s | ammo: %s | knownrecipe: %s'] = 'Reglas: food: %s | ammo: %s | knownrecipe: %s',
    ['Rule %s: %s'] = 'Regla %s: %s',
    ['Recipe for %s'] = 'Receta de %s',
    [', requires %d'] = ', requiere %d',
    ['Usable from level %d'] = 'Podés usarlo desde nivel %d',
    ['Key: opens a lock; keep it'] = 'Llave: abre una cerradura; conservala',
    ['Locked box: open it before selling (lockpick or key)'] = 'Caja cerrada: abrila antes de venderla (ganzúa o llave)',
    ['Turn in for reputation: %s'] = 'Se entrega por reputación: %s',
    ['unknown faction'] = 'facción desconocida',
    ['Faction #%d'] = 'Facción #%d',
    ['Junk: sells'] = 'Basura: se vende',
    ['Quest finished: %s'] = 'Misión terminada: %s',
    ['Active quest: %s'] = 'Misión activa: %s',
    ['Needed by an active quest'] = 'Lo pide una misión activa',
    ['No active quest needs it'] = 'Ninguna misión activa lo pide',
    ["Starts a quest you haven't done: %s"] = 'Inicia una misión que no hiciste: %s',
    ["Your class can't use %s"] = 'Tu clase no usa %s',
    ["Your class can't use %s: you can auction it or pass it to another character"] = 'Tu clase no puede usar %s: podés subastarlo o pasarlo a otro personaje',
    ["Quest turned in; unknown if it's repeatable"] = 'Misión entregada; no se sabe si es repetible',
    ['Your profession: %s'] = 'Tu profesión: %s',
    ['%s reagent: %s'] = 'Reactivo de %s: %s',
    ['%s and %d more'] = '%s y %d más',
    ["Reagent for your class's spells"] = 'Reactivo de hechizos de tu clase',
    ['%s reagent'] = 'Reactivo de %s',
    ["Profession you don't have: %s"] = 'Profesión que no tenés: %s',
    ['Tool for your profession: %s'] = 'Herramienta de tu profesión: %s',
    ["Tool for a profession you don't have: %s"] = "Herramienta de profesión que no tenés: %s",
    ['Marked by hand: keep'] = 'Marcado a mano: guardar',
    ['Library book: turn it in to the librarian (%s)'] = 'Libro de biblioteca: entregalo al bibliotecario (%s)',
    ['Owen Thadd in Undercity'] = 'Owen Thadd en Entrañas',
    ['Garion Wendell in Stormwind'] = 'Garion Wendell en Ventormenta',
    ['Waylaid crate: fill it with one option from the list and turn it in to %s'] = 'Cajón arrebatado: llenalo con una opción de la lista y entregalo a %s',
    ['Sealed waylaid crate: turn it in to %s'] = 'Cajón arrebatado lleno: entregalo a %s',
    ['Dokimi (Crossroads)'] = 'Dokimi (Encrucijada)',
    ['Marcy Baker (Redridge)'] = 'Marcy Baker (Crestagrana)',
    ['Marked by hand: sell'] = 'Marcado a mano: vender',
    ['on'] = 'activadas', ['off'] = 'desactivadas', ['yes'] = 'sí', ['no'] = 'no', ['none'] = 'ninguno',
    ['Junk marks: on/off, coin/hammer/loot, keep/sell/clear, status'] = 'Marcas de basura: on/off, coin/hammer/loot, keep/sell/clear, status',
    ['Marks on/off: /knu junk on | off'] = 'Activar o desactivar las marcas: /knu junk on | off',
    ['One kind: /knu junk coin|hammer|loot on|off'] = 'Un solo tipo de marca: /knu junk coin|hammer|loot on|off',
    ['By hand: /knu junk keep|sell|clear <item link or ID>'] = 'A mano: /knu junk keep|sell|clear <enlace o ID de ítem>',
    ['Show state: /knu junk status'] = 'Ver el estado: /knu junk status',
    ['Usage: /knu junk %s <item link or ID>'] = 'Uso: /knu junk %s <enlace o ID de ítem>',
    ['Usage: /knu junk %s on|off'] = 'Uso: /knu junk %s on|off',
    ['Invalid item: %s'] = 'Ítem inválido: %s',
    ['Unknown option: %s'] = 'Opción desconocida: %s',
    ['No manual mark on item %d'] = 'El ítem %d no tiene marca manual',
    ['Manual mark removed from item %d'] = 'Marca manual quitada del ítem %d',
    ['Item %d: %s'] = 'Ítem %d: %s',
    ['Marks: %s'] = 'Marcas: %s',
    ['Mark %s: %s'] = 'Marcas de %s: %s',
    ['Data build: %s'] = 'Build de datos: %s',
    ['QuestieDB: %s, index ready: %s'] = 'QuestieDB: %s, índice listo: %s',
    ['Bag adapters: %s'] = 'Adaptadores de bolsas: %s',
    ['Marks: %s | coin: %s | hammer: %s | loot: %s'] = 'Marcas: %s | coin: %s | hammer: %s | loot: %s',
    ['Manual marks: %d'] = 'Marcas manuales: %d',
    ['Junk marks: options panel, on/off, coin/hammer/loot, keep/sell/clear, rules, status'] = 'Marcas de basura: panel de opciones, on/off, coin/hammer/loot, keep/sell/clear, rules, status',
    ['Options panel: /knu junk'] = 'Panel de opciones: /knu junk',
    ['Options panel is not available in this client'] = 'El panel de opciones no está disponible en este cliente',
    ['Options open after combat: Esc > Options > AddOns > KnuJunk'] = 'Las opciones se abren al salir de combate: Esc > Opciones > AddOns > KnuJunk',
    ['Marks'] = 'Marcas',
    ['Optional rules (off by default)'] = 'Reglas opcionales (apagadas por defecto)',
    ['Manual marks'] = 'Marcas manuales',
    ['Enable KnuJunk'] = 'Activar KnuJunk',
    ['Master switch: turns every icon off. KnuJunk never sells or deletes anything.'] = 'Interruptor general: apaga todas las marcas. KnuJunk nunca vende ni borra nada.',
    ['Coin'] = 'Monedita',
    ['What you can sell: greys, quest leftovers and gear your class never uses.'] = 'Lo que se puede vender: grises, sobrantes de misión y equipo que tu clase no usa.',
    ['Hammer'] = 'Martillito',
    ["Profession materials: green for one of your professions, yellow for one you lack."] = 'Materiales de profesión: verde si es de una tuya, amarillo si es de una que no tenés.',
    ['Marks in loot'] = 'Marcas en el botín',
    ['The same icons in the loot window (with autoloot there is no window).'] = 'Las mismas marcas en la ventana de botín (con autolooteo no hay ventana).',
    ['Outleveled food and drink'] = 'Comida y bebida superadas',
    ['Coin on simple food and drink 15 or more levels above the requirement when you carry a better one. Never for hunters.'] = 'Monedita en comida y bebida simples que ya te quedan chicas (15 niveles o más sobre el requerido) si llevás una mejor. Nunca para cazadores.',
    ['Outdamaged ammunition'] = 'Munición superada',
    ['Coin on ordinary arrows or bullets when you carry a usable stack of the same kind with more damage. Keeps the equipped one and a compatible stack.'] = 'Monedita en flechas o balas ordinarias si llevás otra pila usable del mismo tipo con más daño. Conserva la equipada y al menos una pila compatible.',
    ['Recipes already learned'] = 'Recetas ya aprendidas',
    ['Coin on recipes you already know, only if bound and with a sell price. Unbound: no coin; the tooltip says you can pass it on or auction it.'] = 'Monedita en recetas que ya conocés, sólo si están ligadas y tienen precio de venta. Sin ligar: sin monedita; el tooltip dice que la podés pasar o subastar.',
    ['Keep'] = 'Guardar',
    ['Sell'] = 'Vender',
    ['Remove'] = 'Quitar',
    ['Item %d'] = 'Ítem %d',
    ['You have not marked any item by hand. Use /knu junk keep or sell with the item link.'] = 'No marcaste ningún item a mano. Usá /knu junk keep o sell con el link del item.',
})

-- Nombres de las profesiones por SkillLine ID, en los dos idiomas. No dependen de
-- GetLocale: el idioma del cliente no esta verificado, asi que se aceptan ambos.
local NAMES = {
    [164] = { es = 'Herrería', en = 'Blacksmithing' },
    [165] = { es = 'Peletería', en = 'Leatherworking' },
    [171] = { es = 'Alquimia', en = 'Alchemy' },
    [182] = { es = 'Herboristería', en = 'Herbalism' },
    [186] = { es = 'Minería', en = 'Mining' },
    [197] = { es = 'Sastrería', en = 'Tailoring' },
    [202] = { es = 'Ingeniería', en = 'Engineering' },
    [333] = { es = 'Encantamiento', en = 'Enchanting' },
    [393] = { es = 'Desuello', en = 'Skinning' },
    [185] = { es = 'Cocina', en = 'Cooking' },
    [129] = { es = 'Primeros auxilios', en = 'First Aid' },
    [356] = { es = 'Pesca', en = 'Fishing' },
}

-- Nombres de las clases (token de UnitClass) para cuando el cliente no trae LOCALIZED_CLASS_NAMES_MALE.
local CLASS_NAMES = {
    WARRIOR = { es = 'Guerrero', en = 'Warrior' }, PALADIN = { es = 'Paladín', en = 'Paladin' },
    HUNTER = { es = 'Cazador', en = 'Hunter' }, ROGUE = { es = 'Pícaro', en = 'Rogue' },
    PRIEST = { es = 'Sacerdote', en = 'Priest' }, SHAMAN = { es = 'Chamán', en = 'Shaman' },
    MAGE = { es = 'Mago', en = 'Mage' }, WARLOCK = { es = 'Brujo', en = 'Warlock' },
    DRUID = { es = 'Druida', en = 'Druid' },
}

-- Nombre de la clase: el del cliente (LOCALIZED_CLASS_NAMES_MALE) o el propio en su idioma.
function ns.ClassName(token)
    local client = rawget(_G, 'LOCALIZED_CLASS_NAMES_MALE')
    if type(client) == 'table' and type(client[token]) == 'string' and client[token] ~= '' then return client[token] end
    local names = CLASS_NAMES[token]
    if not names then return tostring(token) end
    local locale = GetLocale and GetLocale() or 'enUS'
    if locale == 'esES' or locale == 'esMX' then return names.es end
    return names.en
end

-- Minusculas y sin tildes (UTF-8), para comparar sin importar mayusculas ni acentos.
local ACCENTS = {
    ['\195\129'] = 'a', ['\195\137'] = 'e', ['\195\141'] = 'i', ['\195\147'] = 'o',
    ['\195\154'] = 'u', ['\195\145'] = 'n', ['\195\156'] = 'u',
    ['\195\161'] = 'a', ['\195\169'] = 'e', ['\195\173'] = 'i', ['\195\179'] = 'o',
    ['\195\186'] = 'u', ['\195\177'] = 'n', ['\195\188'] = 'u',
}
local function normalize(text)
    return (text:gsub('\195[\128-\191]', ACCENTS):lower():gsub('^%s+', ''):gsub('%s+$', ''))
end
ns.NormalizeName = normalize

local byName = {}
for skillLine, names in pairs(NAMES) do
    byName[normalize(names.es)] = skillLine
    byName[normalize(names.en)] = skillLine
end

-- Nombre de la profesion en el idioma del cliente (ingles si no es es*).
function ns.ProfessionName(skillLine)
    local names = NAMES[skillLine]
    if not names then return nil end
    local locale = GetLocale and GetLocale() or 'enUS'
    if locale == 'esES' or locale == 'esMX' then return names.es end
    return names.en
end

-- Mapa inverso: nombre localizado (es o en, sin importar mayusculas/tildes) -> SkillLine ID.
function ns.ProfessionByName(name)
    if type(name) ~= 'string' then return nil end
    return byName[normalize(name)]
end
