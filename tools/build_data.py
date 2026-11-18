#!/usr/bin/env python3
"""Genera Data/Reagents.lua, Data/Starters.lua, Data/Tools.lua, Data/ClassGear.lua, Data/Special.lua y
Data/ClassReagents.lua desde las tablas DB2 de wago.tools (producto wowf).

Uso:
    python -I tools/build_data.py                  # build mas nueva de wowf, descarga y regenera
    python -I tools/build_data.py --build 1.60.1.70959
    python -I tools/build_data.py --offline        # regenera desde data-raw/ sin red

Solo stdlib. data-raw/ guarda unicamente las columnas usadas, para poder regenerar
sin red si wago.tools esta caido.
"""
import argparse
import csv
import io
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
RAW_DIR = os.path.join(ROOT, 'data-raw')
DATA_DIR = os.path.join(ROOT, 'Data')
BUILD_FILE = os.path.join(RAW_DIR, 'BUILD')
PRODUCT = 'wowf'
USER_AGENT = 'KnuJunk-build-data'
BASE = 'https://wago.tools'

# SkillLine ID -> nombre. Debe coincidir con ns.PROFESSIONS en Core.lua (hay un test que lo verifica).
PROFESSIONS = {
    164: 'Herreria', 165: 'Peleteria', 171: 'Alquimia', 182: 'Herboristeria',
    186: 'Mineria', 197: 'Sastreria', 202: 'Ingenieria', 333: 'Encantamiento',
    393: 'Desuello', 185: 'Cocina', 129: 'Primeros Auxilios', 356: 'Pesca',
}
REAGENT_SLOTS = ['Reagent_%d' % i for i in range(8)]
# tabla -> columnas que se conservan en data-raw/<tabla>.csv
COLUMNS = {
    'skilllineability': ['SkillLine', 'Spell', 'ClassMask'],
    'spellreagents': ['SpellID'] + REAGENT_SLOTS,
    'itemsparse': ['ID', 'StartQuestID', 'TotemCategoryID', 'Display_lang', 'Description_lang'],
    'spelltotems': ['SpellID', 'RequiredTotemCategoryID_0', 'RequiredTotemCategoryID_1', 'Totem_0', 'Totem_1'],
    'totemcategory': ['ID', 'Name_lang', 'TotemCategoryType', 'TotemCategoryMask'],
}
TOTEM_REQUIRED = ['RequiredTotemCategoryID_0', 'RequiredTotemCategoryID_1']
TOTEM_ITEMS = ['Totem_0', 'Totem_1']
# Textos de ItemSparse (enUS) que solo se guardan en data-raw para los items especiales.
ITEM_TEXTS = ['Display_lang', 'Description_lang']
# Libros de biblioteca de Forever: la descripcion termina en "A fine (o questionable) addition to
# any library's collection." (40 items en la build 1.60.1.70959).
LIBRARY_RE = re.compile(r"addition to any library's collection", re.I)
# Cajones arrebatados: "Waylaid Crate" vacio y "Waylaid Crate: <opcion>" (sin llenar), y los ya
# llenos "Sealed <rango> Crate" cuya descripcion pide entregarlos al representante de comercio.
# "Waylaid Supplies: ..." y "Sealed Crate" (Venture Company) son otras cosas: no entran.
CRATE_RE = re.compile(r'^Waylaid Crate(:|$)')
SEALED_RE = re.compile(r'completed crate.*trade representative', re.I)

# Hechizo de la habilidad de arma/armadura -> (tipo, subclase de item). Armadura (clase 4):
# 1 tela, 2 cuero, 3 malla, 4 placas, 6 escudo. Armas (clase 2): 0/1 hacha 1M/2M, 2 arco,
# 3 arma de fuego, 4/5 maza 1M/2M, 6 asta, 7/8 espada 1M/2M, 10 baston, 13 punio, 15 daga,
# 16 arrojadiza, 18 ballesta, 19 varita.
GEAR_SPELLS = {
    9078: ('armor', 1), 9077: ('armor', 2), 8737: ('armor', 3), 750: ('armor', 4), 9116: ('armor', 6),
    196: ('weapon', 0), 197: ('weapon', 1), 264: ('weapon', 2), 266: ('weapon', 3),
    198: ('weapon', 4), 199: ('weapon', 5), 200: ('weapon', 6), 201: ('weapon', 7),
    202: ('weapon', 8), 227: ('weapon', 10), 15590: ('weapon', 13), 1180: ('weapon', 15),
    2567: ('weapon', 16), 5011: ('weapon', 18), 5009: ('weapon', 19),
}
# ChrClasses ID -> token de UnitClass. El bit de ClassMask es 1 << (ID - 1).
GEAR_CLASSES = {
    1: 'WARRIOR', 2: 'PALADIN', 3: 'HUNTER', 4: 'ROGUE', 5: 'PRIEST',
    7: 'SHAMAN', 8: 'MAGE', 9: 'WARLOCK', 11: 'DRUID',
}


class TransientError(Exception):
    """Fallo de red recuperable (Cloudflare 520, 5xx, timeout)."""


def read_csv(path):
    with open(path, encoding='utf-8-sig', newline='') as handle:
        for row in csv.DictReader(handle):
            yield row


def _int(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0


def compute_reagents(ability_rows, reagent_rows):
    """item ID -> lista ordenada y sin repetidos de SkillLine de profesion que lo usan de reactivo."""
    spell_lines = {}
    for row in ability_rows:
        line = _int(row['SkillLine'])
        if line in PROFESSIONS:
            spell_lines.setdefault(_int(row['Spell']), set()).add(line)
    reagents = {}
    for row in reagent_rows:
        lines = spell_lines.get(_int(row['SpellID']))
        if not lines:
            continue
        for slot in REAGENT_SLOTS:
            item = _int(row.get(slot))
            if item > 0:
                reagents.setdefault(item, set()).update(lines)
    return {item: sorted(lines) for item, lines in reagents.items()}


def compute_starters(item_rows):
    """item ID -> questID para los items que inician una mision (StartQuestID != 0)."""
    starters = {}
    for row in item_rows:
        quest = _int(row['StartQuestID'])
        item = _int(row['ID'])
        if quest != 0 and item > 0:
            starters[item] = quest
    return starters


def _crate_kind(row):
    if CRATE_RE.match(row.get('Display_lang') or ''):
        return True
    if 'Crate' in (row.get('Display_lang') or '') and SEALED_RE.search(row.get('Description_lang') or ''):
        return 'sealed'
    return None


def _is_special(row):
    return bool(LIBRARY_RE.search(row.get('Description_lang') or '')) or _crate_kind(row) is not None


def compute_special(item_rows):
    """(libros, cajones): set de item IDs de libros de biblioteca y dict item ID -> True (cajon
    arrebatado por llenar) o 'sealed' (cajon lleno, listo para entregar)."""
    books, crates = set(), {}
    for row in item_rows:
        item = _int(row.get('ID'))
        if item <= 0:
            continue
        if LIBRARY_RE.search(row.get('Description_lang') or ''):
            books.add(item)
        kind = _crate_kind(row)
        if kind is not None:
            crates[item] = kind
    return books, crates


def _satisfies(categories, have, need):
    """La categoria de totem `have` de un item cumple la pedida `need`: la misma, o del mismo tipo y
    con mascara que cubre todos sus bits. Una categoria que falte solo se cumple con ella misma."""
    if have == need:
        return True
    if have not in categories or need not in categories:
        return False
    have_type, have_mask = categories[have]
    need_type, need_mask = categories[need]
    return have_type == need_type and (have_mask & need_mask) == need_mask


def compute_tools(ability_rows, totem_rows, category_rows, item_rows):
    """item ID -> lista ordenada de SkillLine de profesion para las que el item es HERRAMIENTA
    (requerida pero no consumida: martillo, pico, cuchillo de desuello, pedernal...).

    Se une SpellID de spelltotems con SkillLineAbility (solo lineas de PROFESSIONS). Cada hechizo
    pide hasta dos categorias de totem (RequiredTotemCategoryID_0/1) y/o hasta dos items concretos
    (Totem_0/1). Un item de ItemSparse con TotemCategoryID C cumple la categoria R pedida si es del
    mismo tipo (TotemCategoryType) y su mascara cubre todos los bits de la pedida:
    (mascara(C) & mascara(R)) == mascara(R), como lo resuelve el cliente. Asi la navaja gnomica
    (mascara 127) sirve de martillo, pico y cuchillo, y un martillo (4) no cumple una categoria 4|1.
    Una categoria que falte en totemcategory solo se cumple con ella misma."""
    spell_lines = {}
    for row in ability_rows:
        line = _int(row['SkillLine'])
        if line in PROFESSIONS:
            spell_lines.setdefault(_int(row['Spell']), set()).add(line)
    categories = {_int(row['ID']): (_int(row['TotemCategoryType']), _int(row['TotemCategoryMask']))
                  for row in category_rows}
    required = {}  # categoria pedida -> lineas que la piden
    tools = {}
    for row in totem_rows:
        lines = spell_lines.get(_int(row['SpellID']))
        if not lines:
            continue
        for slot in TOTEM_REQUIRED:
            category = _int(row.get(slot))
            if category > 0:
                required.setdefault(category, set()).update(lines)
        for slot in TOTEM_ITEMS:
            item = _int(row.get(slot))
            if item > 0:
                tools.setdefault(item, set()).update(lines)

    for row in item_rows:
        item = _int(row.get('ID'))
        have = _int(row.get('TotemCategoryID'))
        if item <= 0 or have <= 0:
            continue
        for need, lines in required.items():
            if _satisfies(categories, have, need):
                tools.setdefault(item, set()).update(lines)
    return {item: sorted(lines) for item, lines in tools.items()}


# Fragmento de alma: se agrega aunque no salga de los datos (reactivo historico del Brujo).
SOUL_SHARD = 6265
# SkillLine que no cuentan como hechizos de clase: 2851 Grabado (runas, solo piden Tinte azul).
EXCLUDED_CLASS_LINES = {2851}


def _class_bits(mask):
    """Tokens de UnitClass cuyas posiciones estan en la ClassMask (1 << (ID - 1))."""
    return [name for class_id, name in sorted(GEAR_CLASSES.items()) if mask & (1 << (class_id - 1))]


def compute_class_reagents(ability_rows, reagent_rows, totem_rows, category_rows, item_rows):
    """item ID -> {clase: [hechizos ordenados]} para los reactivos (SpellReagents) y herramientas
    (SpellTotems: Totem_0/1 o un item cuya categoria de totem cumple la pedida) de hechizos de CLASE.

    Union usada (verificada en la build 1.60.1.70959 de wowf): un hechizo es de clase si tiene una
    fila de SkillLineAbility con SkillLine fuera de PROFESSIONS y ClassMask con el bit de alguna clase
    de GEAR_CLASSES. Las lineas de clase (SkillLine.CategoryID 7: Arcano, Demonologia, Mejora...) y las
    de categoria 9 propias de una clase (Venenos, Abrir cerraduras del picaro) traen esa ClassMask;
    las de ClassMask 0 (Companeros, Supervivencia, pruebas) no son de ninguna clase y no entran.
    Se excluye Grabado (SkillLine 2851, "Engraving" en SkillLine): sus hechizos (119 filas de
    SpellReagents en la build 1.60.1.70959) solo piden
    Tinte azul (6260) y lo harian "reactivo" de seis clases. El Fragmento de alma (6265) se fuerza
    para el Brujo aunque no aparezca."""
    spell_classes = {}
    for row in ability_rows:
        if _int(row['SkillLine']) in PROFESSIONS or _int(row['SkillLine']) in EXCLUDED_CLASS_LINES:
            continue
        classes = _class_bits(_int(row.get('ClassMask')))
        if classes:
            spell_classes.setdefault(_int(row['Spell']), set()).update(classes)
    result = {}

    def add(item, spell):
        for name in spell_classes.get(spell, ()):
            result.setdefault(item, {}).setdefault(name, set()).add(spell)

    for row in reagent_rows:
        spell = _int(row['SpellID'])
        if spell not in spell_classes:
            continue
        for slot in REAGENT_SLOTS:
            item = _int(row.get(slot))
            if item > 0:
                add(item, spell)
    categories = {_int(row['ID']): (_int(row['TotemCategoryType']), _int(row['TotemCategoryMask']))
                  for row in category_rows}
    required = {}  # categoria pedida -> hechizos de clase que la piden
    for row in totem_rows:
        spell = _int(row['SpellID'])
        if spell not in spell_classes:
            continue
        for slot in TOTEM_ITEMS:
            item = _int(row.get(slot))
            if item > 0:
                add(item, spell)
        for slot in TOTEM_REQUIRED:
            category = _int(row.get(slot))
            if category > 0:
                required.setdefault(category, set()).add(spell)
    for row in item_rows:
        item = _int(row.get('ID'))
        have = _int(row.get('TotemCategoryID'))
        if item <= 0 or have <= 0:
            continue
        for need, spells in required.items():
            if _satisfies(categories, have, need):
                for spell in spells:
                    add(item, spell)
    result.setdefault(SOUL_SHARD, {}).setdefault('WARLOCK', set())
    return {item: {name: sorted(spells) for name, spells in by_class.items()}
            for item, by_class in result.items()}


def compute_class_gear(ability_rows):
    """Clase -> {'armor': set, 'weapon': set} de subclases que puede llegar a usar, segun la
    ClassMask de SkillLineAbility para el hechizo de cada habilidad de arma/armadura (union de
    filas). ClassMask 0 = cualquier clase (lo prudente: nunca agrega monedas). Devuelve tambien
    los hechizos de GEAR_SPELLS que no aparecieron, para fallar en vez de generar de menos."""
    gear = {name: {'armor': set(), 'weapon': set()} for name in GEAR_CLASSES.values()}
    seen = set()
    for row in ability_rows:
        spell = _int(row['Spell'])
        target = GEAR_SPELLS.get(spell)
        if not target:
            continue
        seen.add(spell)
        kind, subclass = target
        mask = _int(row.get('ClassMask'))
        for class_id, name in GEAR_CLASSES.items():
            if mask == 0 or mask & (1 << (class_id - 1)):
                gear[name][kind].add(subclass)
    missing = sorted(set(GEAR_SPELLS) - seen)
    return gear, missing


def _header(build):
    return ('-- Generado por tools/build_data.py desde wago.tools %s %s. No editar.\n'
            'local _, ns = ...\n'
            'ns.Data = ns.Data or {}\n'
            'ns.Data.build = "%s"\n') % (PRODUCT, build, build)


def render_reagents_lua(reagents, build):
    lines = [_header(build), 'ns.Data.reagents = {\n']
    for item in sorted(reagents):
        lines.append('    [%d] = { %s },\n' % (item, ', '.join(str(n) for n in reagents[item])))
    lines.append('}\n')
    return ''.join(lines)


def render_starters_lua(starters, build):
    lines = [_header(build), 'ns.Data.starters = {\n']
    for item in sorted(starters):
        lines.append('    [%d] = %d,\n' % (item, starters[item]))
    lines.append('}\n')
    return ''.join(lines)


def render_tools_lua(tools, build):
    lines = [_header(build),
             '-- Herramientas de profesion (requeridas, no consumidas): item -> SkillLines.\n',
             'ns.Data.tools = {\n']
    for item in sorted(tools):
        lines.append('    [%d] = { %s },\n' % (item, ', '.join(str(n) for n in tools[item])))
    lines.append('}\n')
    return ''.join(lines)


def _lua_set(values):
    return 'set { %s }' % ', '.join(str(n) for n in sorted(values)) if values else 'set { }'


def render_class_gear_lua(gear, build):
    lines = [_header(build),
             '-- Lo que cada clase PUEDE LLEGAR A usar (aunque todavia no haya aprendido la habilidad),\n'
             '-- por la ClassMask de SkillLineAbility. Subclases: ver GEAR_SPELLS en tools/build_data.py.\n'
             'local function set(list)\n'
             '    local result = {}\n'
             '    for _, id in ipairs(list) do result[id] = true end\n'
             '    return result\n'
             'end\n',
             'ns.ClassGear = {\n']
    for class_id in sorted(GEAR_CLASSES):
        name = GEAR_CLASSES[class_id]
        lines.append('    %s = { armor = %s, weapon = %s },\n'
                     % (name, _lua_set(gear[name]['armor']), _lua_set(gear[name]['weapon'])))
    lines.append('}\n')
    return ''.join(lines)


def render_class_reagents_lua(data, build):
    lines = [_header(build),
             '-- Reactivos y herramientas de hechizos de clase:\n'
             '-- item -> { clases..., spells = { CLASE = { hechizos } } }.\n',
             'ns.Data.classReagents = {\n']
    for item in sorted(data):
        by_class = data[item]
        names = sorted(by_class)
        spells = ', '.join('%s = { %s }' % (name, ', '.join(str(n) for n in by_class[name]))
                           if by_class[name] else '%s = { }' % name for name in names)
        lines.append('    [%d] = { %s, spells = { %s } },\n'
                     % (item, ', '.join('"%s"' % name for name in names), spells))
    lines.append('}\n')
    return ''.join(lines)


def render_special_lua(books, crates, build):
    lines = [_header(build),
             '-- Libros de biblioteca (se entregan al bibliotecario): item -> true.\n',
             'ns.Data.libraryBooks = {\n']
    for item in sorted(books):
        lines.append('    [%d] = true,\n' % item)
    lines.append('}\n')
    lines.append('-- Cajones arrebatados: item -> true (por llenar) o "sealed" (lleno, para entregar).\n')
    lines.append('ns.Data.waylaidCrates = {\n')
    for item in sorted(crates):
        value = 'true' if crates[item] is True else '"%s"' % crates[item]
        lines.append('    [%d] = %s,\n' % (item, value))
    lines.append('}\n')
    return ''.join(lines)


def parse_core_professions(core_lua):
    """IDs de ns.PROFESSIONS leidos del texto de Core.lua."""
    block = re.search(r'ns\.PROFESSIONS\s*=\s*\{(.*?)\n\}', core_lua, re.S)
    if not block:
        raise ValueError('No se encontro ns.PROFESSIONS en Core.lua')
    return {int(n) for n in re.findall(r'\[(\d+)\]\s*=', block.group(1))}


def with_retries(fn, attempts=5, sleep=time.sleep):
    delay = 2
    last = None
    for attempt in range(attempts):
        try:
            return fn()
        except TransientError as err:
            last = err
            if attempt < attempts - 1:
                sleep(delay)
                delay *= 2
    sys.exit('wago.tools no responde tras %d intentos (%s). Reintenta mas tarde o usa --offline '
             'para regenerar desde data-raw/.' % (attempts, last))


def _open(url):
    request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
    try:
        return urllib.request.urlopen(request, timeout=60)
    except urllib.error.HTTPError as err:
        if err.code >= 500 or err.code == 429:
            raise TransientError('HTTP %d en %s' % (err.code, url))
        sys.exit('HTTP %d en %s' % (err.code, url))
    except (urllib.error.URLError, OSError) as err:
        raise TransientError('%s en %s' % (err, url))


def latest_build():
    """Build mas nueva de wowf. /api/builds (lista completa) a veces no responde; este endpoint si."""
    def fetch():
        with _open('%s/api/builds/%s/latest' % (BASE, PRODUCT)) as response:
            try:
                return json.load(response)
            except OSError as err:
                raise TransientError(str(err))
    data = with_retries(fetch)
    version = data.get('version')
    if not version or data.get('product') != PRODUCT:
        sys.exit('api/builds/%s/latest no trae version: %r' % (PRODUCT, data))
    return version


def filtered_row(table, row, columns):
    """Fila a guardar en data-raw (solo `columns`) o None si la tabla no la usa. En itemsparse los
    textos (nombre, descripcion) solo se conservan en los libros y cajones."""
    if table == 'itemsparse':
        special = _is_special(row)
        if not special and _int(row['StartQuestID']) == 0 and _int(row['TotemCategoryID']) == 0:
            return None
        return [row[c] if special or c not in ITEM_TEXTS else '' for c in columns]
    if table == 'spellreagents' and not any(_int(row[c]) for c in REAGENT_SLOTS):
        return None
    if table == 'spelltotems' and not any(_int(row[c]) for c in TOTEM_REQUIRED + TOTEM_ITEMS):
        return None
    return [row[c] for c in columns]


def download_filtered(table, build):
    """Baja la tabla en streaming y guarda en data-raw/ solo las columnas usadas. Devuelve la ruta."""
    columns = COLUMNS[table]
    url = '%s/db2/%s/csv?product=%s&build=%s' % (BASE, table, PRODUCT, build)
    target = os.path.join(RAW_DIR, table + '.csv')
    os.makedirs(RAW_DIR, exist_ok=True)
    temp = target + '.part'

    def attempt():
        try:
            with _open(url) as response, open(temp, 'w', encoding='utf-8', newline='') as out:
                reader = csv.DictReader(io.TextIOWrapper(response, encoding='utf-8-sig', newline=''))
                missing = [c for c in columns if c not in (reader.fieldnames or [])]
                if missing:
                    sys.exit('%s: faltan columnas %s (hay %s)' % (table, missing, reader.fieldnames))
                writer = csv.writer(out, lineterminator='\n')
                writer.writerow(columns)
                count = 0
                for row in reader:
                    out = filtered_row(table, row, columns)
                    if out is not None:
                        writer.writerow(out)
                        count += 1
                return count
        except OSError as err:
            raise TransientError(str(err))

    try:
        count = with_retries(attempt)
        os.replace(temp, target)
    finally:
        if os.path.exists(temp):
            os.remove(temp)
    print('%s: %d filas -> %s' % (table, count, os.path.relpath(target, ROOT)))
    return target


def write_lua(name, text):
    os.makedirs(DATA_DIR, exist_ok=True)
    path = os.path.join(DATA_DIR, name)
    with open(path, 'w', encoding='utf-8', newline='\n') as handle:
        handle.write(text)
    print('escrito %s' % os.path.relpath(path, ROOT))


def main(argv=None):
    parser = argparse.ArgumentParser(description='Genera Data/*.lua desde wago.tools')
    parser.add_argument('--build', help='build de wowf (por defecto la mas nueva de api/builds)')
    parser.add_argument('--offline', action='store_true', help='regenerar desde data-raw/ sin red')
    args = parser.parse_args(argv)

    if args.offline:
        if not os.path.exists(BUILD_FILE):
            sys.exit('No hay data-raw/BUILD: corre una vez con red.')
        with open(BUILD_FILE, encoding='utf-8') as handle:
            build = handle.read().strip()
    else:
        build = args.build or latest_build()
        for table in COLUMNS:
            download_filtered(table, build)
        with open(BUILD_FILE, 'w', encoding='utf-8', newline='\n') as handle:
            handle.write(build + '\n')

    def raw(table):
        return read_csv(os.path.join(RAW_DIR, table + '.csv'))

    reagents = compute_reagents(raw('skilllineability'), raw('spellreagents'))
    starters = compute_starters(raw('itemsparse'))
    tools = compute_tools(raw('skilllineability'), raw('spelltotems'), raw('totemcategory'), raw('itemsparse'))
    gear, missing = compute_class_gear(raw('skilllineability'))
    books, crates = compute_special(raw('itemsparse'))
    class_reagents = compute_class_reagents(raw('skilllineability'), raw('spellreagents'), raw('spelltotems'),
                                            raw('totemcategory'), raw('itemsparse'))
    if missing:
        sys.exit('skilllineability: faltan los hechizos de arma/armadura %s; no se genera ClassGear' % missing)
    write_lua('Reagents.lua', render_reagents_lua(reagents, build))
    write_lua('Starters.lua', render_starters_lua(starters, build))
    write_lua('Tools.lua', render_tools_lua(tools, build))
    write_lua('ClassGear.lua', render_class_gear_lua(gear, build))
    write_lua('Special.lua', render_special_lua(books, crates, build))
    write_lua('ClassReagents.lua', render_class_reagents_lua(class_reagents, build))
    print('build %s: %d reactivos, %d iniciadores de mision, %d herramientas, %d clases con equipo, '
          '%d libros de biblioteca, %d cajones arrebatados (%d llenos), %d reactivos de clase'
          % (build, len(reagents), len(starters), len(tools), len(gear), len(books), len(crates),
             sum(1 for kind in crates.values() if kind == 'sealed'), len(class_reagents)))


if __name__ == '__main__':
    main()
