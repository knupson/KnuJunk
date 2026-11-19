"""Auditoría completa: python -I tools/auditoria_venta.py [--offline] [--ambos].

Sólo stdlib; descarga tablas completas, conserva encabezados originales y nunca
usa los CSV filtrados de build_data como si fueran la base completa.
"""
import argparse
import collections
import csv
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.parse

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('build_data', ROOT / 'tools/build_data.py')
build_data = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build_data)
TABLES = {
    'item': ['ID', 'ClassID', 'SubclassID'],
    'itemsparse': ['ID', 'Display_lang', 'OverallQualityID', 'SellPrice', 'RequiredLevel', 'Bonding', 'StartQuestID',
                   'ItemSet', 'InventoryType', 'Flags_0', 'AllowableClass'],
    'itemxitemeffect': ['ItemID', 'ItemEffectID'],
    'itemeffect': ['ID', 'SpellID', 'TriggerType'],
}
# Traducciones de ItemClass/ItemSubClass de wowf 1.60.1.70959 (wago.tools).
CLASSES = {0: 'Consumible', 1: 'Contenedor', 2: 'Arma', 3: 'Joyería (obsoleta)', 4: 'Armadura', 5: 'Componente',
           6: 'Proyectil', 7: 'Material', 8: 'Genérico (obsoleto)', 9: 'Receta', 10: 'Dinero (obsoleto)', 11: 'Carcaj',
           12: 'Misión', 13: 'Llave', 14: 'Permanente (obsoleto)', 15: 'Misceláneo', 18: 'Ficha de WoW'}
SUBCLASSES = {
    0: {0: 'Explosivo', 1: 'Poción', 2: 'Elixir', 3: 'Frasco', 4: 'Pergamino', 5: 'Comida y bebida', 6: 'Mejora permanente', 7: 'Venda', 8: 'Otro', 14: 'Dispositivo', 15: 'Mejora temporal'},
    1: {**dict(enumerate(['Bolsa', 'Bolsa de almas', 'Herboristería', 'Encantamiento', 'Ingeniería', 'Gemas', 'Minería', 'Peletería', 'Inscripción'])), 11: 'Bolsa de componentes', 12: 'Bolsa de abalorios'},
    2: {0: 'Hacha de una mano', 1: 'Hacha de dos manos', 2: 'Arco', 3: 'Arma de fuego', 4: 'Maza de una mano',
        5: 'Maza de dos manos', 6: 'Arma de asta', 7: 'Espada de una mano', 8: 'Espada de dos manos', 9: 'Guja',
        10: 'Bastón', 11: 'Exótica de una mano', 12: 'Exótica de dos manos', 13: 'Puño', 14: 'Miscelánea',
        15: 'Daga', 16: 'Arrojadiza', 17: 'Lanza', 18: 'Ballesta', 19: 'Varita', 20: 'Caña de pescar'},
    4: {0: 'Miscelánea', 1: 'Tela', 2: 'Cuero', 3: 'Malla', 4: 'Placas', 5: 'Cosmética', 6: 'Escudo',
        7: 'Tratado', 8: 'Ídolo', 9: 'Tótem', 10: 'Sigilo'},
    5: {0: 'Componente'},
    6: {0: 'Varita', 1: 'Descarga', 2: 'Flecha', 3: 'Bala', 4: 'Arrojadiza'},
    7: {0: 'Material', 1: 'Pieza', 2: 'Explosivo', 3: 'Dispositivo', 4: 'Joyería', 5: 'Tela', 6: 'Cuero',
        7: 'Metal y piedra', 8: 'Cocina', 9: 'Hierba', 10: 'Elemental', 11: 'Otro', 12: 'Encantamiento'},
    9: {0: 'Libro', 1: 'Peletería', 2: 'Sastrería', 3: 'Ingeniería', 4: 'Herrería', 5: 'Cocina',
        6: 'Alquimia', 7: 'Primeros auxilios', 8: 'Encantamiento', 9: 'Pesca'},
    11: {2: 'Carcaj', 3: 'Bolsa de munición'}, 12: {0: 'Misión'}, 13: {0: 'Llave', 1: 'Ganzúa'},
    15: {0: 'Chatarra', 1: 'Reactivo', 2: 'Mascota', 3: 'Festividad', 4: 'Otro', 5: 'Montura'},
    18: {0: 'Sin subclase declarada en ItemSubClass'},
}
NORMAL_COLUMNS = ['id', 'name', 'classID', 'subclassID', 'quality', 'price', 'reqLevel', 'bonding', 'startQuestID',
                  'isSetPiece', 'equipLoc', 'hasUseSpell', 'hasEquipSpell', 'effect', 'openable']


def read_csv(path):
    with open(path, encoding='utf-8-sig', newline='') as handle:
        yield from csv.DictReader(handle)


def download(table, build, folder):
    target = folder / (table + '.csv')
    temp = target.with_suffix('.csv.part')
    url = '%s/db2/%s/csv?%s' % (build_data.BASE, table, urllib.parse.urlencode({'product': 'wowf', 'build': build}))

    def attempt():
        try:
            with build_data._open(url) as response, temp.open('w', encoding='utf-8', newline='') as out:
                reader = csv.reader(io.TextIOWrapper(response, encoding='utf-8-sig', newline=''))
                writer = csv.writer(out, lineterminator='\n')
                header = next(reader, [])
                missing = sorted(set(TABLES[table]) - set(header))
                if missing:
                    raise ValueError('%s: faltan %s; encabezados reales: %s%s' % (
                        table, ', '.join(missing), ', '.join(header),
                        '. Falta SellPrice: no se puede medir venta sin inventar precios.' if 'SellPrice' in missing else ''))
                writer.writerow(header)
                count = 0
                for row in reader:
                    writer.writerow(row)
                    count += 1
                if not count:
                    raise ValueError('%s: tabla vacía' % table)
                return {'rows': count, 'headers': header, 'url': url}
        except OSError as err:
            raise build_data.TransientError(str(err)) from err

    try:
        metadata = build_data.with_retries(attempt)
        os.replace(temp, target)
    finally:
        temp.unlink(missing_ok=True)
    print('%s: %d filas completas' % (table, metadata['rows']), flush=True)
    return metadata


def normalize(folder):
    for table, columns in TABLES.items():
        with (folder / (table + '.csv')).open(encoding='utf-8-sig', newline='') as handle:
            header = next(csv.reader(handle), [])
        missing = set(columns) - set(header)
        if missing:
            raise ValueError('%s: faltan columnas %s; no se inventan datos' % (table, sorted(missing)))
    sparse = {r['ID']: r for r in read_csv(folder / 'itemsparse.csv')}
    effects = {r['ID']: r for r in read_csv(folder / 'itemeffect.csv')}
    kinds = collections.defaultdict(set)
    missing_effects = set()
    for row in read_csv(folder / 'itemxitemeffect.csv'):
        effect = effects.get(row['ItemEffectID'])
        if not effect:
            missing_effects.add(row['ItemID'])
            continue
        if int(effect['SpellID']) > 0 and effect['TriggerType'] in ('0', '1'):
            kinds[row['ItemID']].add(effect['TriggerType'])
    path = folder / 'items.csv'
    with path.open('w', encoding='utf-8', newline='') as out:
        writer = csv.DictWriter(out, fieldnames=NORMAL_COLUMNS, lineterminator='\n')
        writer.writeheader()
        seen = set()
        for row in read_csv(folder / 'item.csv'):
            id_ = row['ID']
            if id_ in seen:
                raise ValueError('ID duplicado en Item: %s' % id_)
            seen.add(id_)
            s = sparse.get(id_, {})
            writer.writerow(dict(zip(NORMAL_COLUMNS, [id_, s.get('Display_lang', ''), row['ClassID'], row['SubclassID'],
                s.get('OverallQualityID', ''), s.get('SellPrice', ''), s.get('RequiredLevel', ''), s.get('Bonding', ''),
                s.get('StartQuestID', ''), int(int(s.get('ItemSet', '0')) > 0), s.get('InventoryType', ''),
                int('0' in kinds[id_]), int('1' in kinds[id_]),
                'yes' if kinds[id_] else 'unknown' if id_ in missing_effects else 'no',
                int((int(s.get('Flags_0', '0') or '0') & 0x4) != 0)])))
    diagnostics = {'item_without_sparse': len(seen - set(sparse)), 'sparse_without_item': len(set(sparse) - seen),
                   'missing_effect_item_ids': sorted(map(int, missing_effects)),
                   'missing_effect_in_item': len(missing_effects & seen)}
    (folder / 'normalizacion.json').write_text(json.dumps(diagnostics, indent=2), encoding='utf-8')
    if missing_effects:
        print('Enlaces sin fila ItemEffect: %d ítems referenciados; se usa efecto desconocido si no hay otro confirmado.' % len(missing_effects), flush=True)
    return path


def group_name(key):
    class_, subclass = key
    return '%d/%d %s / %s' % (class_, subclass, CLASSES.get(class_, 'Clase %d' % class_),
        SUBCLASSES.get(class_, {}).get(subclass, 'Subclase %d (sin nombre verificado)' % subclass))


def md(text):
    return str(text).replace('|', '\\|').replace('\n', ' ').replace('\r', ' ')


def report(items_path, audit_path, report_path, build, both=False, fixture=False):
    items = {int(r['id']): r for r in read_csv(items_path)}
    states = {id_: {'marks': set(), 'no_rule': False, 'no_keep_reason': False,
                    'coin_winners': set(), 'contexts': set()} for id_ in items}
    contexts = 0
    for row in read_csv(audit_path):
        state = states[int(row['id'])]
        if row['context'] in state['contexts']:
            raise ValueError('Contexto duplicado para %s: %s' % (row['id'], row['context']))
        state['contexts'].add(row['context'])
        state['marks'].add(row['mark'])
        state['no_rule'] |= row['winner_reason'] == 'no_rule'
        state['no_keep_reason'] |= row['winner_reason'] == 'no_keep_reason'
        if row['mark'] == 'coin':
            state['coin_winners'].add(row['winner_reason'])
        contexts += 1
    totals, marks, groups, unruled = collections.Counter(), collections.Counter(), {}, collections.defaultdict(list)
    default_sold, leaks = [], []
    specific_sell = {'gray', 'class_cannot_use', 'book_other_class', 'book_known',
                     'quest_not_active', 'quest_done', 'gear_not_ranked'}
    keep_marks = {'useful', 'protected', 'quest', 'hammer_mine', 'hammer_other', 'auction'}
    for id_, item in items.items():
        state = states[id_]
        expected = 54 if both and item['classID'] in ('2', '4') else 27
        if len(state['contexts']) != expected:
            raise ValueError('Ítem %d: %d contextos, se esperaban %d' % (id_, len(state['contexts']), expected))
        m = state['marks']
        marks[next(iter(m)) if len(m) == 1 else 'mixed'] += 1
        category = ('coin' if m == {'coin'} else 'trash' if m == {'trash'} else 'pending' if m == {'pending'}
                    else ('no_rule' if state['no_rule'] else 'keep') if m <= keep_marks else 'mixed')
        totals[category] += 1
        key = int(item['classID']), int(item['subclassID'])
        groups.setdefault(key, collections.Counter())[category] += 1
        if state['no_rule']:
            unruled[key + (int(item['quality']),)].append(item)
        if state['no_keep_reason']:
            default_sold.append(item)
        if 'coin' in m:
            class_id = int(item['classID'])
            quality = int(item['quality']) if item['quality'] != '' else -1
            openable = item.get('openable') == '1'
            use_effect = class_id == 0 and item.get('effect') == 'yes'
            non_specific = bool(state['coin_winners'] - specific_sell)
            if non_specific and (class_id in (1, 6, 11, 12, 13) or openable or quality >= 3 or use_effect):
                leaks.append((item, sorted(state['coin_winners'])))
    positive = sum(bool(i['price']) and int(i['price']) > 0 for i in items.values())
    lines = ['# Auditoría de venta', '', 'Build: `%s` (wowf).%s' % (build, ' **Fixture de prueba; no es la base completa.**' if fixture else ''),
        '', 'Ítems: %d. Con SellPrice > 0: %d. Contextos evaluados: %d.' % (len(items), positive, contexts), '',
        'Nueve clases, niveles 10/30/60, sin profesiones, diario completo y vacío, misiones sin completar, '
        'sin QuestieDB, GearQuest ni Auctionator; reglas predeterminadas. Equipo %s.' % (
            'ligado y sin ligar en pasadas separadas' if both else 'sólo ligado; no se evaluó la pasada sin ligar'),
        '', 'Precios en cobre. Nombres de ítems de Display_lang (idioma provisto por wago.tools). '
        'Efectos: TriggerType 0 (uso) y 1 (equipar), con SpellID positivo; otros disparadores no se consideran. '
        'Piezas de set por ItemSet. Sin fila ItemSparse, el ítem queda pendiente. '
        'Enlaces sin fila ItemEffect se tratan como efecto desconocido si no hay otro efecto confirmado. '
        'Los CSV completos conservan los encabezados originales; no se usan los datos filtrados de build_data.py.', '',
        'La simulación usa efectos DB2, sin lectura del tooltip en el juego. No reproduce efectos que sólo '
        'aparezcan en ese tooltip, estado de recetas aprendidas, equipamiento guardado ni misiones de un personaje real.', '',
        '## Resultado agregado', '', 'Moneda en todos los contextos: %d. Guardado en todos: %d. '
        'Basura en todos: %d. Mixtos entre acciones: %d. Pendientes: %d.' % (
            totals['coin'], totals['keep'] + totals['no_rule'], totals['trash'], totals['mixed'], totals['pending']), '',
        '| Marca final uniforme (mixto si cambia la marca) | Ítems |', '| --- | ---: |']
    lines += ['| %s | %d |' % pair for pair in sorted(marks.items())]
    if not fixture:
        manifest = json.loads((items_path.parent / 'manifest.json').read_text(encoding='utf-8'))
        diagnostics = json.loads((items_path.parent / 'normalizacion.json').read_text(encoding='utf-8'))
        lines += ['', '## Cobertura y encabezados verificados', '',
            '| Tabla completa | Filas | Fuente |', '| --- | ---: | --- |']
        for table, data in manifest['tables'].items():
            lines.append('| %s | %d | [CSV de wago.tools](%s) |' % (table, data['rows'], data['url']))
        lines += ['', '`ItemSparse` trae `SellPrice`, `Display_lang`, `OverallQualityID`, `RequiredLevel`, '
            '`Bonding`, `StartQuestID`, `ItemSet`, `InventoryType`, `Flags_0` y `AllowableClass`. `Item` trae `ID`, `ClassID` y `SubclassID`. '
            '`ItemXItemEffect` trae `ItemID` e `ItemEffectID`; `ItemEffect` trae `ID`, `SpellID` y `TriggerType`.', '',
            'Filas Item sin ItemSparse: %d; se conservan como pendientes. Filas ItemSparse sin Item: %d. '
            'Ítems referenciados con enlace a ItemEffect ausente: %s; de ellos, %d están en Item.' % (
                diagnostics['item_without_sparse'], diagnostics['sparse_without_item'],
                ', '.join(map(str, diagnostics['missing_effect_item_ids'])) or 'ninguno', diagnostics['missing_effect_in_item']), '',
            'Nombres de clases y subclases traducidos de [ItemClass](https://wago.tools/db2/itemclass/csv?product=wowf&build=%s) '
            'e [ItemSubClass](https://wago.tools/db2/itemsubclass/csv?product=wowf&build=%s).' % (build, build)]
    lines += ['', '## Por clase y subclase', '',
        'Categorías excluyentes: no_rule significa guardado en todos los contextos y sin regla en al menos uno. '
        'Mixto significa que cambia la acción (vender, guardar o tirar). Guardado por motivo excluye no_rule.', '',
        '| Clase/subclase | Moneda | Guardado por motivo | no_rule | Basura | Mixto | Pendiente |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for key, counts in sorted(groups.items()):
        lines.append('| %s | %s |' % (group_name(key), ' | '.join(str(counts[c]) for c in ('coin', 'keep', 'no_rule', 'trash', 'mixed', 'pending'))))
    lines += ['', '## Chequeo de fugas', '',
        'Ítems que terminan en `coin` (en cualquier contexto) sin una regla específica de venta '
        '(`gray`, `class_cannot_use`, `book_other_class`, `book_known`, `quest_not_active`, `quest_done`, `gear_not_ranked`) '
        'y pertenecen a: clases 1, 6, 11, 12, 13; abribles (`Flags_0 & 0x4`); calidad >= 3; o consumibles (clase 0) con efecto de uso: '
        '**%d filas**.' % len(leaks)]
    if leaks:
        lines += ['', '| ID | Nombre | Clase/subclase | Calidad | Precio de venta | Ganador |',
            '| ---: | --- | --- | ---: | ---: | --- |']
        for item, winners in sorted(leaks, key=lambda pair: int(pair[0]['id'])):
            lines.append('| %s |' % ' | '.join(md(v) for v in (
                item['id'], item['name'], group_name((int(item['classID']), int(item['subclassID']))),
                item['quality'], item['price'], ', '.join(winners))))
    lines += ['', '## Se vende por defecto', '',
        'Lista completa: %d ítems cuyo ganador es `no_keep_reason`.' % len(default_sold), '',
        '| ID | Nombre | Clase/subclase | Calidad | Precio de venta |',
        '| ---: | --- | --- | ---: | ---: |']
    for item in sorted(default_sold, key=lambda r: int(r['id'])):
        lines.append('| %s |' % ' | '.join(md(v) for v in (
            item['id'], item['name'], group_name((int(item['classID']), int(item['subclassID']))),
            item['quality'], item['price'])))
    lines += ['', '## Sin regla (no_rule)', '', 'Lista completa: %d ítems con ganador no_rule en al menos un contexto.' % sum(map(len, unruled.values()))]
    for (class_, subclass, quality), entries in sorted(unruled.items()):
        lines += ['', '### %s, calidad %d' % (group_name((class_, subclass)), quality), '',
            '| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |',
            '| ---: | --- | ---: | ---: | ---: | --- | --- |']
        for item in sorted(entries, key=lambda r: int(r['id'])):
            lines.append('| %s |' % ' | '.join(md(v) for v in (item['id'], item['name'], item['quality'], item['price'], item['reqLevel'],
                'sí' if item['hasUseSpell'] == '1' else 'no', 'sí' if item['hasEquipSpell'] == '1' else 'no')))
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    summary = {'build': build, 'items': len(items), 'positive_price': positive, 'contexts': contexts,
               'categories': dict(totals), 'marks': dict(marks), 'no_keep_reason': len(default_sold),
               'leaks': len(leaks), 'no_rule': sum(map(len, unruled.values()))}
    print(json.dumps(summary, ensure_ascii=False), flush=True)
    return summary


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--offline', action='store_true')
    parser.add_argument('--ambos', action='store_true', help='Equipo ligado y sin ligar')
    parser.add_argument('--fixture', type=Path, help='CSV normalizado de prueba; no descarga')
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'data-raw/full')
    parser.add_argument('--report', type=Path, default=ROOT / 'docs/auditoria-venta.md')
    parser.add_argument('--luajit', default='luajit')
    args = parser.parse_args(argv)
    if args.fixture and args.report.resolve() == (ROOT / 'docs/auditoria-venta.md').resolve():
        parser.error('Una fixture requiere --report propio para no reemplazar la auditoría completa')
    build = (ROOT / 'data-raw/BUILD').read_text(encoding='utf-8').strip()
    folder = args.output_dir.resolve()
    folder.mkdir(parents=True, exist_ok=True)
    if args.fixture:
        items = args.fixture.resolve()
    else:
        manifest_path = folder / 'manifest.json'
        if not args.offline:
            manifest_path.unlink(missing_ok=True)
            metadata = {table: download(table, build, folder) for table in TABLES}
            manifest_path.write_text(json.dumps({'build': build, 'product': 'wowf', 'tables': metadata}, indent=2), encoding='utf-8')
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        if manifest['build'] != build or manifest['product'] != 'wowf':
            raise ValueError('La descarga no corresponde a wowf y data-raw/BUILD')
        items = normalize(folder)
    audit = folder / 'auditoria.csv'
    subprocess.run([args.luajit, str(ROOT / 'tools/auditoria_venta.lua'), str(items), str(audit),
                    'ambos' if args.ambos else 'ligado'], cwd=ROOT, check=True)
    return report(items, audit, args.report.resolve(), build, args.ambos, bool(args.fixture))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        sys.exit('No se completó la auditoría: %s' % error)
