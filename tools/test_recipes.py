import unittest

import build_data as b


class RecipesTest(unittest.TestCase):
    def compute(self, effects=None, spells=None, abilities=None, sparse=None, subclass=1):
        return b.compute_recipes(
            [{'ID': '2406', 'ClassID': '9', 'SubclassID': str(subclass)},
             {'ID': '99', 'ClassID': '2', 'SubclassID': '1'}],
            sparse or [], [{'ItemID': '2406', 'ItemEffectID': '10'}],
            effects or [], spells or [], abilities or [])

    def test_teaches_effect_links_to_profession_and_item_rank(self):
        result = self.compute(
            effects=[{'ID': '10', 'SpellID': '100', 'TriggerType': '0'}],
            spells=[{'SpellID': '100', 'Effect': '36', 'EffectTriggerSpell': '200'}],
            abilities=[{'Spell': '200', 'SkillLine': '165', 'MinSkillLineRank': '1'}],
            sparse=[{'ID': '2406', 'RequiredSkill': '165', 'RequiredSkillRank': '65'}])
        self.assertEqual(result, {2406: {'skillLine': 165, 'rank': 65}})

    def test_direct_learn_trigger_and_ability_rank_override_subclass(self):
        result = self.compute(
            effects=[{'ID': '10', 'SpellID': '200', 'TriggerType': '6'}],
            abilities=[{'Spell': '200', 'SkillLine': '171', 'MinSkillLineRank': '50'}])
        self.assertEqual(result[2406], {'skillLine': 171, 'rank': 50})

    def test_subclass_fallback_and_unknown_no_guessed_profession(self):
        self.assertEqual(self.compute()[2406], {'skillLine': 165})
        self.assertEqual(self.compute(subclass=0), {})
        self.assertNotIn(99, self.compute())

    def test_non_learn_effect_does_not_use_cast_spell_profession(self):
        result = self.compute(
            effects=[{'ID': '10', 'SpellID': '200', 'TriggerType': '0'}],
            abilities=[{'Spell': '200', 'SkillLine': '171'}])
        self.assertEqual(result[2406], {'skillLine': 165})

    def test_conflicting_professions_do_not_guess(self):
        self.assertEqual(self.compute(
            effects=[{'ID': '10', 'SpellID': '200', 'TriggerType': '6'}],
            abilities=[{'Spell': '200', 'SkillLine': '165'},
                       {'Spell': '200', 'SkillLine': '171'}]), {})

    def test_render_sorted_and_optional_rank(self):
        text = b.render_recipes_lua({2: {'skillLine': 165}, 1: {'skillLine': 171, 'rank': 50}}, 'test')
        self.assertIn('ns.Data.recipes', text)
        self.assertIn('[1] = { skillLine = 171, rank = 50 }', text)
        self.assertIn('[2] = { skillLine = 165 }', text)
        self.assertLess(text.index('[1]'), text.index('[2]'))

    def test_download_keeps_recipe_items_and_skill_requirements(self):
        self.assertIsNotNone(b.filtered_row('item', {'ID': '1', 'ClassID': '9', 'SubclassID': '1'}, ['ID', 'ClassID']))
        row = dict(ID='2406', StartQuestID='0', TotemCategoryID='0', RequiredSkill='165')
        self.assertIsNotNone(b.filtered_row('itemsparse', row, ['ID', 'RequiredSkill']))

    def test_class_books_teaches_class_spell_with_allowable_class(self):
        books = b.compute_class_books(
            [{'ID': '16384', 'ClassID': '9', 'SubclassID': '0'},
             {'ID': '2406', 'ClassID': '9', 'SubclassID': '1'}],
            [{'ID': '16384', 'AllowableClass': '31488'},
             {'ID': '2406', 'AllowableClass': '31488'}],
            [{'ItemID': '16384', 'ItemEffectID': '10'}],
            [{'ID': '10', 'SpellID': '100', 'TriggerType': '0'}],
            [{'SpellID': '100', 'Effect': '36', 'EffectTriggerSpell': '19478'}],
            [])
        self.assertEqual(books, {16384: {'spell': 19478, 'classMask': 31488}})
        text = b.render_recipes_lua({2406: {'skillLine': 165}}, 'test', books)
        self.assertIn('ns.Data.classBooks', text)
        self.assertIn('[16384] = { spell = 19478, classMask = 31488 },', text)


if __name__ == '__main__':
    unittest.main()
