#!/usr/bin/env python3
"""Genera Data/Reagents.lua, Data/Starters.lua y Data/ClassGear.lua desde las tablas DB2 de wago.tools (producto wowf).

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
    'itemsparse': ['ID', 'StartQuestID'],
}

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
                    if table == 'itemsparse' and _int(row['StartQuestID']) == 0:
                        continue
                    if table == 'spellreagents' and not any(_int(row[c]) for c in REAGENT_SLOTS):
                        continue
                    writer.writerow([row[c] for c in columns])
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
    gear, missing = compute_class_gear(raw('skilllineability'))
    if missing:
        sys.exit('skilllineability: faltan los hechizos de arma/armadura %s; no se genera ClassGear' % missing)
    write_lua('Reagents.lua', render_reagents_lua(reagents, build))
    write_lua('Starters.lua', render_starters_lua(starters, build))
    write_lua('ClassGear.lua', render_class_gear_lua(gear, build))
    print('build %s: %d reactivos, %d iniciadores de mision, %d clases con equipo'
          % (build, len(reagents), len(starters), len(gear)))


if __name__ == '__main__':
    main()
