local _, ns = ...
ns.L = LibStub('KnuLib-1.0'):NewLocale({
    ['Junk: sells'] = 'Basura: se vende',
    ['Quest finished: %s'] = 'Misión terminada: %s',
    ["Your class can't use %s"] = 'Tu clase no usa %s',
    ['Your profession: %s'] = 'Tu profesión: %s',
    ["Profession you don't have: %s"] = 'Profesión que no tenés: %s',
    ['Tool for your profession: %s'] = 'Herramienta de tu profesión: %s',
    ["Tool for a profession you don't have: %s"] = "Herramienta de profesión que no tenés: %s",
    ['Marked by hand: keep'] = 'Marcado a mano: guardar',
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
