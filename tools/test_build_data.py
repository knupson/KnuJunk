import os
import unittest

import build_data

FIXTURES = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fixtures')


def rows(name):
    return list(build_data.read_csv(os.path.join(FIXTURES, name)))


class ReagentsTest(unittest.TestCase):
    def setUp(self):
        self.reagents = build_data.compute_reagents(
            rows('skilllineability.csv'), rows('spellreagents.csv'))

    def test_reagents_maps_item_to_professions(self):
        self.assertEqual(self.reagents[2840], [164, 202])

    def test_ignores_non_profession_skilllines(self):
        # El hechizo 100 es de SkillLine 6 (no profesión): 5000 no aparece.
        self.assertNotIn(5000, self.reagents)
        for professions in self.reagents.values():
            self.assertNotIn(6, professions)

    def test_no_duplicates_and_sorted(self):
        # 2447 aparece dos veces en el mismo hechizo; 2841 en 202 y en 164.
        self.assertEqual(self.reagents[2447], [171])
        self.assertEqual(self.reagents[2841], [164, 202])

    def test_spell_without_ability_is_ignored(self):
        # El hechizo 9999 usa 2840 pero no está en ninguna skilllineability.
        self.assertEqual(self.reagents[2840], [164, 202])

    def test_zero_reagent_slots_are_not_items(self):
        self.assertNotIn(0, self.reagents)


class StartersTest(unittest.TestCase):
    def test_starters(self):
        starters = build_data.compute_starters(rows('itemsparse.csv'))
        self.assertEqual(starters[1307], 123)
        self.assertEqual(starters[4500], 77)

    def test_zero_start_quest_is_omitted(self):
        starters = build_data.compute_starters(rows('itemsparse.csv'))
        self.assertNotIn(2840, starters)
        self.assertNotIn(3000, starters)


class ToolsTest(unittest.TestCase):
    def setUp(self):
        self.tools = build_data.compute_tools(
            rows('skilllineability.csv'), rows('spelltotems.csv'),
            rows('totemcategory.csv'), rows('itemsparse.csv'))

    def test_hammer_is_tool_of_blacksmithing_and_engineering(self):
        # Categoria 162 la piden el hechizo de Herreria (2663) y el de Ingenieria (3955).
        self.assertEqual(self.tools[5956], [164, 202])

    def test_gathering_tools(self):
        self.assertEqual(self.tools[2901], [186])
        self.assertEqual(self.tools[7005], [393])

    def test_second_required_category_counts(self):
        # 3955 pide 162 y 14: la llave (14) tambien es herramienta de Ingenieria.
        self.assertEqual(self.tools[6219], [202])

    def test_direct_totem_item(self):
        # Totem_0 es un item concreto (pedernal para Cocina).
        self.assertEqual(self.tools[4471], [185])

    def test_mask_superset_satisfies_each_requirement(self):
        # Navaja (mascara 127) cubre 4, 8, 16, 1 y 5: sirve de martillo, pico, cuchillo, llave y 380.
        self.assertEqual(self.tools[7000], [164, 171, 186, 202, 393])

    def test_mask_must_cover_every_required_bit(self):
        # 380 (mascara 5 = 4|1): un martillo solo (4) no la cumple, asi que 171 no esta en 5956.
        self.assertNotIn(171, self.tools[5956])
        # Un item de categoria 380 si cubre 162 (mascara 4) y a si misma.
        self.assertEqual(self.tools[7003], [164, 171, 202])

    def test_category_type_must_match(self):
        # Las varas (tipo 3, mascara 1) no cumplen la llave (tipo 24, mascara 1).
        self.assertNotIn(7001, self.tools)
        self.assertNotIn(7002, self.tools)

    def test_unknown_category_and_non_profession_spells_are_ignored(self):
        self.assertNotIn(7004, self.tools)
        for lines in self.tools.values():
            self.assertNotIn(6, lines)

    def test_fishing_without_totem_has_no_tool(self):
        for lines in self.tools.values():
            self.assertNotIn(356, lines)

    def test_no_item_zero_and_sorted_unique(self):
        self.assertNotIn(0, self.tools)
        for lines in self.tools.values():
            self.assertEqual(lines, sorted(set(lines)))

    def test_tools_lua_body(self):
        text = build_data.render_tools_lua({6219: [202], 5956: [164, 202]}, 'x')
        self.assertIn('ns.Data.tools = {', text)
        self.assertIn('[5956] = { 164, 202 },', text)
        self.assertLess(text.index('[5956]'), text.index('[6219]'))
        self.assertEqual(text.splitlines()[0],
                         '-- Generado por tools/build_data.py desde wago.tools wowf x. No editar.')


class LuaOutputTest(unittest.TestCase):
    def test_lua_output_header_has_build(self):
        build = '1.60.1.70959'
        header = '-- Generado por tools/build_data.py desde wago.tools wowf %s. No editar.' % build
        for text in (build_data.render_reagents_lua({2840: [164, 202]}, build),
                     build_data.render_starters_lua({1307: 123}, build)):
            self.assertEqual(text.splitlines()[0], header)
            self.assertIn('ns.Data.build = "%s"' % build, text)
            self.assertIn('ns.Data = ns.Data or {}', text)

    def test_reagents_lua_body(self):
        text = build_data.render_reagents_lua({2841: [164], 2840: [164, 202]}, 'x')
        self.assertIn('ns.Data.reagents = {', text)
        self.assertIn('[2840] = { 164, 202 },', text)
        self.assertLess(text.index('[2840]'), text.index('[2841]'))

    def test_starters_lua_body(self):
        text = build_data.render_starters_lua({4500: 77, 1307: 123}, 'x')
        self.assertIn('ns.Data.starters = {', text)
        self.assertIn('[1307] = 123,', text)
        self.assertLess(text.index('[1307]'), text.index('[4500]'))


class ClassGearTest(unittest.TestCase):
    def setUp(self):
        self.gear, self.missing = build_data.compute_class_gear(rows('skilllineability.csv'))

    def test_rogue_learns_one_handed_axes(self):
        # Hechizo 196 (Hachas de una mano) ClassMask 79 = guerrero, paladin, cazador, picaro, chaman.
        self.assertIn(0, self.gear['ROGUE']['weapon'])
        self.assertIn(0, self.gear['SHAMAN']['weapon'])
        self.assertNotIn(0, self.gear['MAGE']['weapon'])

    def test_druid_learns_polearms(self):
        # Hechizo 200 (Armas de asta) ClassMask 1031 = guerrero, paladin, cazador, druida.
        self.assertIn(6, self.gear['DRUID']['weapon'])
        self.assertNotIn(6, self.gear['ROGUE']['weapon'])

    def test_armor_and_union_of_rows(self):
        self.assertEqual(self.gear['WARRIOR']['armor'] & {4}, {4})
        self.assertNotIn(4, self.gear['MAGE']['armor'])
        for name in build_data.GEAR_CLASSES.values():
            self.assertIn(1, self.gear[name]['armor'])
        # Dos filas del mismo hechizo (varitas): se unen las mascaras 16 | 384.
        for name in ('PRIEST', 'MAGE', 'WARLOCK'):
            self.assertIn(19, self.gear[name]['weapon'])
        self.assertNotIn(19, self.gear['ROGUE']['weapon'])

    def test_non_gear_spells_ignored_and_missing_reported(self):
        # 1293712 (SkillLine 415, ClassMask 0) no es el hechizo de la habilidad: no da tela a nadie extra.
        self.assertIn(264, self.missing)  # arcos no esta en el fixture
        self.assertNotIn(196, self.missing)

    def test_zero_class_mask_means_every_class(self):
        gear, _ = build_data.compute_class_gear([{'SkillLine': '45', 'Spell': '264', 'ClassMask': '0'}])
        for name in build_data.GEAR_CLASSES.values():
            self.assertIn(2, gear[name]['weapon'])

    def test_class_gear_lua(self):
        text = build_data.render_class_gear_lua(self.gear, '1.60.1.70959')
        self.assertEqual(text.splitlines()[0],
                         '-- Generado por tools/build_data.py desde wago.tools wowf 1.60.1.70959. No editar.')
        self.assertIn('ns.ClassGear = {', text)
        self.assertIn('    ROGUE = { armor = set { 1 }, weapon = set { 0 } },', text)
        self.assertIn('    DRUID = { armor = set { 1 }, weapon = set { 6 } },', text)


class ClassReagentsTest(unittest.TestCase):
    """Tanda 1, regla 15: reactivos y herramientas de hechizos de CLASE (SkillLineAbility con ClassMask
    de una clase y SkillLine que no es profesion)."""

    def setUp(self):
        abilities = [
            {'SkillLine': '237', 'Spell': '3561', 'ClassMask': '128'},   # Mago: Teletransporte
            {'SkillLine': '237', 'Spell': '130', 'ClassMask': '128'},    # Mago: Caida lenta
            {'SkillLine': '613', 'Spell': '1706', 'ClassMask': '16'},    # Sacerdote: Levitar
            {'SkillLine': '354', 'Spell': '693', 'ClassMask': '256'},    # Brujo: Piedra de alma
            {'SkillLine': '373', 'Spell': '8071', 'ClassMask': '64'},    # Chaman: totem de tierra
            {'SkillLine': '633', 'Spell': '1804', 'ClassMask': '8'},     # Picaro: Abrir cerradura
            {'SkillLine': '778', 'Spell': '10721', 'ClassMask': '0'},    # Companeros: ninguna clase
            {'SkillLine': '164', 'Spell': '2663', 'ClassMask': '1'},     # Profesion: se ignora
            {'SkillLine': '999', 'Spell': '7000', 'ClassMask': '32'},    # Bit sin clase conocida
            {'SkillLine': '2851', 'Spell': '400080', 'ClassMask': '8'},  # Grabado: excluido
        ]
        reagents = [
            {'SpellID': '3561', 'Reagent_0': '17031'},
            {'SpellID': '130', 'Reagent_0': '17056'},
            {'SpellID': '1706', 'Reagent_0': '17056'},
            {'SpellID': '693', 'Reagent_0': '6265'},
            {'SpellID': '10721', 'Reagent_0': '8000'},
            {'SpellID': '2663', 'Reagent_0': '2840'},
            {'SpellID': '7000', 'Reagent_0': '8001'},
            {'SpellID': '400080', 'Reagent_0': '6260'},
        ]
        totems = [
            {'SpellID': '8071', 'RequiredTotemCategoryID_0': '2', 'RequiredTotemCategoryID_1': '0', 'Totem_0': '0', 'Totem_1': '0'},
            {'SpellID': '1804', 'RequiredTotemCategoryID_0': '0', 'RequiredTotemCategoryID_1': '0', 'Totem_0': '5060', 'Totem_1': '0'},
        ]
        categories = [{'ID': '2', 'Name_lang': 'Earth Totem', 'TotemCategoryType': '24', 'TotemCategoryMask': '1'}]
        items = [{'ID': '5175', 'StartQuestID': '0', 'TotemCategoryID': '2'}]
        self.data = build_data.compute_class_reagents(abilities, reagents, totems, categories, items)

    def test_mage_rune_and_shared_feather(self):
        self.assertEqual(self.data[17031], {'MAGE': [3561]})
        self.assertEqual(self.data[17056], {'MAGE': [130], 'PRIEST': [1706]})

    def test_soul_shard_and_tools(self):
        self.assertEqual(self.data[6265], {'WARLOCK': [693]})
        self.assertEqual(self.data[5175], {'SHAMAN': [8071]}, 'totem de tierra por categoria')
        self.assertEqual(self.data[5060], {'ROGUE': [1804]}, 'herramienta directa (Totem_0)')

    def test_non_class_spells_are_ignored(self):
        self.assertNotIn(8000, self.data, 'ClassMask 0')
        self.assertNotIn(2840, self.data, 'profesion')
        self.assertNotIn(8001, self.data, 'bit de una clase que no existe en Forever')
        self.assertNotIn(6260, self.data, 'Grabado (runas) no cuenta')

    def test_soul_shard_is_forced_if_not_derived(self):
        data = build_data.compute_class_reagents([], [], [], [], [])
        self.assertEqual(data[6265], {'WARLOCK': []})

    def test_class_reagents_lua(self):
        text = build_data.render_class_reagents_lua(self.data, '1.60.1.1')
        self.assertIn('ns.Data.classReagents = {', text)
        self.assertIn('[17056] = { "MAGE", "PRIEST", spells = { MAGE = { 130 }, PRIEST = { 1706 } } },', text)
        self.assertIn('[6265] = { "WARLOCK", spells = { WARLOCK = { 693 } } },', text)


class RetryTest(unittest.TestCase):
    def test_retries_then_succeeds(self):
        calls, waits = [], []

        def flaky():
            calls.append(1)
            if len(calls) < 3:
                raise build_data.TransientError('520')
            return 'ok'

        self.assertEqual(build_data.with_retries(flaky, attempts=4, sleep=waits.append), 'ok')
        self.assertEqual(len(calls), 3)
        self.assertEqual(len(waits), 2)

    def test_gives_up_with_offline_hint(self):
        def always():
            raise build_data.TransientError('520')

        with self.assertRaises(SystemExit) as ctx:
            build_data.with_retries(always, attempts=2, sleep=lambda s: None)
        self.assertIn('--offline', str(ctx.exception))


class SpecialTest(unittest.TestCase):
    def setUp(self):
        self.books, self.crates = build_data.compute_special(rows('itemsparse.csv'))

    def test_library_books_by_description(self):
        # Frase "addition to any library's collection", sin importar mayusculas ni el adjetivo.
        self.assertEqual(self.books, {208800, 203755})

    def test_other_library_text_is_not_a_book(self):
        self.assertNotIn(9100, self.books)

    def test_waylaid_crates_open_and_sealed(self):
        self.assertEqual(self.crates, {248549: True, 248684: True, 248765: 'sealed'})

    def test_other_crates_and_waylaid_supplies_are_not_crates(self):
        self.assertNotIn(6357, self.crates)
        self.assertNotIn(211315, self.crates)

    def test_special_lua(self):
        text = build_data.render_special_lua({208800, 203755}, {248765: 'sealed', 248684: True}, 'x')
        self.assertEqual(text.splitlines()[0],
                         '-- Generado por tools/build_data.py desde wago.tools wowf x. No editar.')
        self.assertIn('ns.Data.libraryBooks = {', text)
        self.assertIn('[203755] = true,', text)
        self.assertLess(text.index('[203755]'), text.index('[208800]'))
        self.assertIn('ns.Data.waylaidCrates = {', text)
        self.assertIn('[248684] = true,', text)
        self.assertIn('[248765] = "sealed",', text)


class FilterTest(unittest.TestCase):
    COLUMNS = build_data.COLUMNS['itemsparse']

    def row(self, **fields):
        base = {'ID': '1', 'StartQuestID': '0', 'TotemCategoryID': '0', 'Display_lang': 'Name',
                'Description_lang': 'Text', 'Other': 'x'}
        base.update(fields)
        return base

    def test_itemsparse_columns_include_texts(self):
        self.assertIn('Display_lang', self.COLUMNS)
        self.assertIn('Description_lang', self.COLUMNS)

    def test_plain_item_is_dropped(self):
        self.assertIsNone(build_data.filtered_row('itemsparse', self.row(), self.COLUMNS))

    def test_starter_keeps_row_without_texts(self):
        out = build_data.filtered_row('itemsparse', self.row(StartQuestID='5'), self.COLUMNS)
        self.assertEqual(dict(zip(self.COLUMNS, out)),
                         {'ID': '1', 'StartQuestID': '5', 'TotemCategoryID': '0',
                          'Display_lang': '', 'Description_lang': '', 'LockID': '0',
                          'RequiredSkill': '0', 'RequiredSkillRank': '0', 'RequiredLevel': '0',
                          'ItemLevel': '0', 'OverallQualityID': '0', 'AllowableClass': '0',
                          'AllowableRace_0': '0', 'RequiredAbility': '0', 'MinFactionID': '0',
                          'RequiredPVPRank': '0', 'RequiredHoliday': '0', 'Flags_0': '0'})

    def test_openable_sparse_row_survives_filter(self):
        out = build_data.filtered_row('itemsparse', self.row(Flags_0='4'), self.COLUMNS)
        self.assertIsNotNone(out)
        self.assertEqual(dict(zip(self.COLUMNS, out))['Flags_0'], '4')

    def test_special_items_keep_their_texts(self):
        book = self.row(Description_lang="A fine addition to any library's collection.")
        out = build_data.filtered_row('itemsparse', book, self.COLUMNS)
        self.assertEqual(out[self.COLUMNS.index('Description_lang')], book['Description_lang'])
        crate = self.row(Display_lang='Waylaid Crate: Expert Ore')
        out = build_data.filtered_row('itemsparse', crate, self.COLUMNS)
        self.assertEqual(out[self.COLUMNS.index('Display_lang')], 'Waylaid Crate: Expert Ore')


class ConsistencyTest(unittest.TestCase):
    def test_professions_match_core_lua(self):
        core = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Core.lua')
        with open(core, encoding='utf-8') as handle:
            ids = build_data.parse_core_professions(handle.read())
        self.assertEqual(ids, set(build_data.PROFESSIONS))


class LocksTest(unittest.TestCase):
    def test_keys_are_class_13_plus_curated_openers_not_lock_requirements(self):
        keys, boxes = build_data.compute_locks(
            [{'ID': '1', 'ClassID': '13'}, {'ID': '2', 'ClassID': '15'}],
            [{'ID': '3', 'LockID': '99'}, {'ID': '4', 'LockID': '0'}])
        self.assertEqual(keys, {1, 15869, 15870, 15871, 15872, 4367, 4398, 18594})
        self.assertEqual(boxes, {3})
        text = build_data.render_locks_lua(keys, boxes, 'x')
        self.assertIn('ns.Data.keys', text)
        self.assertIn('ns.Data.lockboxes', text)
        self.assertLess(text.index('[1]'), text.index('[4367]'))

    def test_linen_cloth_in_lock_3670_is_not_a_key(self):
        # Lock 3670 pide este material; Lock ya no es una fuente de llaves.
        keys, boxes = build_data.compute_locks([{'ID': '2589', 'ClassID': '7'}], [])
        self.assertNotIn(2589, keys)
        self.assertEqual(boxes, set())

    def test_locked_sparse_row_survives_filter(self):
        row = {c: '0' for c in build_data.COLUMNS['itemsparse']}
        row.update(ID='3', LockID='99', Display_lang='Box', Description_lang='')
        self.assertIsNotNone(build_data.filtered_row('itemsparse', row, build_data.COLUMNS['itemsparse']))

    def test_item_filter_only_keeps_keys(self):
        self.assertIsNone(build_data.filtered_row('item', {'ID': '2', 'ClassID': '15'}, ['ID', 'ClassID']))
        self.assertEqual(build_data.filtered_row('item', {'ID': '1', 'ClassID': '13'}, ['ID', 'ClassID']), ['1', '13'])

    def test_lock_filter_does_not_treat_skill_as_item(self):
        columns = build_data.COLUMNS['lock']
        row = {c: '0' for c in columns}
        row.update(ID='1', Type_0='2', _Index_0='633')
        self.assertIsNone(build_data.filtered_row('lock', row, columns))
        row.update(Type_7='1', _Index_7='12382')
        self.assertIsNotNone(build_data.filtered_row('lock', row, columns))

    def test_openables_from_flags_0_bit_4(self):
        openables = build_data.compute_openables([
            {'ID': '10', 'Flags_0': '4'},
            {'ID': '11', 'Flags_0': '12'},
            {'ID': '12', 'Flags_0': '2'},
        ])
        self.assertEqual(openables, {10, 11})
        text = build_data.render_locks_lua({1}, {3}, 'x', openables)
        self.assertIn('ns.Data.openables', text)
        self.assertIn('[10] = true,', text)
        self.assertIn('[11] = true,', text)


if __name__ == '__main__':
    unittest.main()
