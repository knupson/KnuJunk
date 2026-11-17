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


class ConsistencyTest(unittest.TestCase):
    def test_professions_match_core_lua(self):
        core = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Core.lua')
        with open(core, encoding='utf-8') as handle:
            ids = build_data.parse_core_professions(handle.read())
        self.assertEqual(ids, set(build_data.PROFESSIONS))


if __name__ == '__main__':
    unittest.main()
