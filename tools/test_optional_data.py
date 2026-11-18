import unittest
import build_data as b


class OptionalDataTest(unittest.TestCase):
    def food(self, extra=None, subclass=5):
        return b.compute_food(
            [{'ID': '117', 'ClassID': '0', 'SubclassID': str(subclass)}],
            [{'ID': '117', 'RequiredLevel': '1'}],
            [{'ItemID': '117', 'ItemEffectID': '1'}],
            [{'ID': '1', 'SpellID': '433', 'TriggerType': '0'}],
            [{'SpellID': '433', 'Effect': '6', 'EffectAura': '84',
              'EffectBasePointsF': '17', 'EffectMiscValue_0': '0'}] + (extra or []),
            [{'SpellID': '433', 'DurationIndex': '1'}],
            [{'ID': '1', 'Duration': '18000'}])

    def test_plain_restore_amount_and_required_level(self):
        self.assertEqual(self.food()[117], {'reqLevel': 1, 'health': 61.2, 'spell': 433})

    def test_buff_pet_only_and_unknown_effect_excluded(self):
        for effect in ({'SpellID': '433', 'Effect': '6', 'EffectAura': '29'},
                       {'SpellID': '433', 'Effect': '64', 'EffectTriggerSpell': '999'},
                       {'SpellID': '433', 'Effect': '6', 'EffectAura': '85', 'EffectMiscValue_0': '1'}):
            self.assertEqual(self.food([effect]), {})
        self.assertEqual(self.food(subclass=0), {})

    def test_ammo_uses_confirmed_damage_by_quality_not_ilvl_guess(self):
        items = [{'ID': '2512', 'ClassID': '6', 'SubclassID': '2'},
                 {'ID': '9', 'ClassID': '6', 'SubclassID': '1'}]
        sparse = [{'ID': '2512', 'RequiredLevel': '1', 'ItemLevel': '5', 'OverallQualityID': '1'}]
        result = b.compute_ammo(items, sparse, [], [{'ItemLevel': '5', 'Quality_1': '1.5'}])
        self.assertEqual(result, {2512: {'reqLevel': 1, 'ilvl': 5, 'subclass': 2, 'dps': 1.5}})
        self.assertEqual(b.compute_ammo(items, sparse, [{'ItemID': '2512'}], []), {})

    def test_effect_filter_retains_all_effects_to_reject_buffs(self):
        row = {k: '0' for k in b.COLUMNS['spelleffect']}
        row.update(SpellID='433', Effect='6', EffectAura='29')
        self.assertIsNotNone(b.filtered_row('spelleffect', row, b.COLUMNS['spelleffect']))

    def test_scoped_filter_keeps_all_food_effects_and_recipe_learning(self):
        columns = ['SpellID', 'Effect', 'EffectAura']
        buff = dict(SpellID='433', Effect='6', EffectAura='29')
        self.assertEqual(b.filtered_row('spelleffect', buff, columns, retain_spells={433}), ['433', '6', '29'])
        self.assertIsNone(b.filtered_row('spelleffect', buff, columns, retain_spells={999}))
        buff['Effect'] = '36'
        self.assertIsNotNone(b.filtered_row('spelleffect', buff, columns, retain_spells={999}))

    def test_regeneration_needs_duration_and_rejects_scaling_and_pet_targets(self):
        for field, value in [('EffectRealPointsPerLevel', '1'), ('ScalingClass', '1'),
                             ('ImplicitTarget_0', '5'), ('EffectTriggerSpell', '99')]:
            bad = dict(SpellID='433', Effect='6', EffectAura='84', EffectBasePointsF='100')
            bad[field] = value
            self.assertEqual(self.food([bad]), {})

    def test_render_is_sorted_and_contains_restoration_and_ammo_fields(self):
        text = b.render_optional_lua({2: {'mana': 100, 'reqLevel': 5, 'spell': 1},
                                      1: {'health': 50, 'reqLevel': 1, 'spell': 2}}, 'food', 'test')
        self.assertIn('ns.Data.food', text)
        self.assertLess(text.index('[1]'), text.index('[2]'))
        self.assertIn('health = 50', text)

    def test_checked_in_data_regenerates_exactly(self):
        from pathlib import Path
        raw = lambda table: list(b.read_csv(str(Path(b.RAW_DIR, table + '.csv'))))
        build = Path(b.BUILD_FILE).read_text().strip()
        food = b.compute_food(raw('item'), raw('itemsparse'), raw('itemxitemeffect'), raw('itemeffect'),
                              raw('spelleffect'), raw('spellmisc'), raw('spellduration'))
        ammo = b.compute_ammo(raw('item'), raw('itemsparse'), raw('itemxitemeffect'), raw('itemdamageammo'))
        self.assertEqual(len(food), 131)
        self.assertEqual(len(ammo), 36)
        for data, name in [(food, 'Food'), (ammo, 'Ammo')]:
            self.assertEqual(Path(b.DATA_DIR, name + '.lua').read_text(encoding='utf-8'),
                             b.render_optional_lua(data, name.lower(), build))
