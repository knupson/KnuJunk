"""Pruebas sin red: python -I tools/test_auditoria_venta.py."""
import csv
import importlib.util
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('auditoria', ROOT / 'tools/auditoria_venta.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class AuditoriaTests(unittest.TestCase):
    def setUp(self):
        folder = ROOT / 'data-raw/full'
        folder.mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='prueba-', dir=folder)
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)

    def write_table(self, table, rows):
        with (self.folder / (table + '.csv')).open('w', encoding='utf-8', newline='') as handle:
            writer = csv.DictWriter(handle, fieldnames=audit.TABLES[table], lineterminator='\n')
            writer.writeheader()
            for row in rows:
                writer.writerow({c: row.get(c, '0') for c in audit.TABLES[table]})

    def test_normaliza_efectos_uso_equipar_y_ausente_sin_filtrar_items(self):
        self.write_table('item', [{'ID': '1', 'ClassID': '2', 'SubclassID': '10'},
                                  {'ID': '2', 'ClassID': '15'}, {'ID': '3', 'ClassID': '12'}, {'ID': '4', 'ClassID': '4'}])
        self.write_table('itemsparse', [{'ID': str(i), 'Display_lang': 'Nombre, "dos"\nlíneas',
            'SellPrice': '50', 'OverallQualityID': '2', 'ItemSet': '3' if i == 1 else '0'} for i in (1, 2, 3)])
        self.write_table('itemeffect', [{'ID': '10', 'SpellID': '100', 'TriggerType': '0'},
                                       {'ID': '11', 'SpellID': '101', 'TriggerType': '1'},
                                       {'ID': '12', 'SpellID': '102', 'TriggerType': '6'}])
        self.write_table('itemxitemeffect', [{'ItemID': '1', 'ItemEffectID': '10'}, {'ItemID': '1', 'ItemEffectID': '11'},
            {'ItemID': '2', 'ItemEffectID': '12'}, {'ItemID': '3', 'ItemEffectID': '999'}])
        rows = list(audit.read_csv(audit.normalize(self.folder)))
        self.assertEqual(len(rows), 4)
        self.assertEqual((rows[0]['hasUseSpell'], rows[0]['hasEquipSpell'], rows[0]['effect']), ('1', '1', 'yes'))
        self.assertEqual(rows[0]['isSetPiece'], '1')
        self.assertEqual(rows[0]['name'], 'Nombre, "dos"\nlíneas')
        self.assertEqual(rows[1]['effect'], 'no')
        self.assertEqual(rows[2]['effect'], 'unknown')
        self.assertEqual((rows[3]['quality'], rows[3]['price']), ('', ''))

    def test_descarga_conserva_todas_las_filas_y_columnas(self):
        raw = b'ID,ClassID,SubclassID,Extra\n1,2,10,a\n2,15,0,b\n'
        with mock.patch.object(audit.build_data, '_open', return_value=io.BytesIO(raw)) as opened:
            metadata = audit.download('item', '1.60.1.70959', self.folder)
        self.assertEqual(metadata['rows'], 2)
        self.assertEqual(metadata['headers'], ['ID', 'ClassID', 'SubclassID', 'Extra'])
        self.assertEqual(list(audit.read_csv(self.folder / 'item.csv'))[1]['Extra'], 'b')
        url = opened.call_args.args[0]
        self.assertIn('product=wowf', url)
        self.assertIn('build=1.60.1.70959', url)
        self.assertFalse((self.folder / 'item.csv.part').exists())

    def test_sellprice_faltante_falla_sin_inventar_precios(self):
        columns = [c for c in audit.TABLES['itemsparse'] if c != 'SellPrice']
        raw = (','.join(columns) + '\n' + ','.join('0' for _ in columns) + '\n').encode()
        with mock.patch.object(audit.build_data, '_open', return_value=io.BytesIO(raw)):
            with self.assertRaisesRegex(ValueError, 'Falta SellPrice'):
                audit.download('itemsparse', '1.60.1.70959', self.folder)
        self.assertFalse((self.folder / 'itemsparse.csv').exists())
        self.assertFalse((self.folder / 'itemsparse.csv.part').exists())

    def test_fixture_ejecuta_lua_y_genera_csv_y_lista_completa(self):
        report = self.folder / 'reporte.md'
        subprocess.run(['python', '-I', str(ROOT / 'tools/auditoria_venta.py'), '--fixture',
            str(ROOT / 'tests/fixtures/auditoria_items.csv'), '--output-dir', str(self.folder),
            '--report', str(report), '--ambos'], cwd=ROOT, check=True, capture_output=True)
        rows = list(audit.read_csv(self.folder / 'auditoria.csv'))
        self.assertEqual(len(rows), 216)
        def result(id_, context):
            return next(r for r in rows if r['id'] == str(id_) and r['context'] == context)
        bound = result(990804, 'PALADIN:30:ligado')
        self.assertEqual((bound['mark'], bound['winner_reason']), ('coin', 'class_cannot_use'))
        self.assertIn('effect', bound['other_reasons'])
        self.assertEqual(result(990804, 'PALADIN:30:libre')['mark'], 'useful')
        self.assertEqual(result(990804, 'MAGE:30:ligado')['mark'], 'useful')
        self.assertEqual((result(990804, 'MAGE:60:ligado')['mark'], result(990804, 'MAGE:60:ligado')['winner_reason']), ('coin', 'gear_outgrown'))
        self.assertEqual((result(990801, 'PALADIN:30:libre')['mark'], result(990801, 'PALADIN:30:libre')['winner_reason']), ('coin', 'no_keep_reason'))
        self.assertEqual(result(990803, 'PALADIN:30:libre')['winner_reason'], 'quest_not_active')
        self.assertEqual(result(990807, 'PALADIN:30:libre')['mark'], 'pending')
        text = report.read_text(encoding='utf-8')
        self.assertIn('Fixture de prueba; no es la base completa.', text)
        self.assertIn('Ítems: 7. Con SellPrice > 0: 5. Contextos evaluados: 216.', text)
        self.assertIn('## Chequeo de fugas', text)
        self.assertIn('**0 filas**.', text)
        self.assertIn('## Se vende por defecto', text)
        self.assertIn('Lista completa: 1 ítems cuyo ganador es `no_keep_reason`.', text)
        self.assertIn('Lista completa: 1 ítems con ganador no_rule en al menos un contexto.', text)
        for id_ in (990801, 990806):
            self.assertIn('| %d |' % id_, text)
        self.assertNotIn('| 990802 |', text)


if __name__ == '__main__':
    unittest.main()
