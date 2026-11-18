# KnuJunk

Iconos en las bolsas y en el botín para ver qué se puede vender o tirar y qué material usa una profesión. Para **World of Warcraft: Forever** (1.60.1, `## Interface: 16001`).

**Estado:** 0.1.0-beta, sin publicar. Probado sólo con pruebas automáticas contra un cliente simulado (`luajit tests/run.lua`); nada probado todavía en el juego.

## Qué hace

- Monedita: items grises con precio de venta, items que inician una misión ya hecha, y armaduras o armas que tu clase nunca puede equipar (según los datos de Forever 1.60.1.70959). Con QuestieDB cargado, también los sobrantes de misiones terminadas y no repetibles.
- Martillito: materiales de profesión. Verde si una profesión tuya lo usa, amarillo si es de una que no tenés (vendible).
- Ante la duda, sin marca. Lo que pide una misión del diario nunca lleva monedita. Un item con efecto de uso o de equipar, una pieza de set o un item que Questie conoce de una misión repetible nunca llevan monedita automática (sólo con `/knu junk sell`). Si el diario no se puede leer entero (por ejemplo, encabezados plegados en combate después de aceptar una misión), no hay monedita automática hasta leerlo completo.
- Marcas sólo en las bolsas 0 a 4 del personaje y en la ventana de botín de Blizzard. Banco y vistas de otros personajes, sin marca.
- El tooltip dice el motivo de cada ícono; un item sin ícono no suma líneas, salvo «Marcado a mano: guardar» si lo marcaste con `keep`. No vende ni borra nada.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <enlace o ID>`, `status`.
- Bolsas: Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag e Inventorian. Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory tienen adaptador por nombre de ventana pero **hoy no muestran ninguna marca** hasta verificar en el juego el nombre de su ventana. El hook genérico sólo marca botones dentro de contenedores declarados (hoy, las ventanas de bolsas de Blizzard). Cuáles existen para Forever y cuáles se revisaron contra su código: [docs/prueba-bolsas.md](docs/prueba-bolsas.md).
- Limitaciones conocidas: sin QuestieDB, un item que inicia una misión ya hecha lleva monedita aunque la misión sea repetible (no se sabe); las misiones imposibles para tu raza o clase no dan monedita (no implementado); los efectos de uso o de equipar se detectan con `GetItemSpell` y, si el cliente todavía no cargó los datos del hechizo, un item puede tratarse por un momento como si no tuviera efecto; que informe los efectos sólo de equipar no está verificado en Forever.

QuestieDB es opcional. Baganator: KnuJunk registra un plugin de basura (Baganator puede elegirlo solo si su opción actual no es un plugin) y nunca escribe la configuración de Baganator; el martillito se inserta arriba a la derecha.

## Documentos

- [Diseño](docs/superpowers/specs/2026-11-17-knujunk-design.md)
- [Plan de implementación](docs/superpowers/plans/2026-11-17-knujunk.md)
- [Prueba de bolsas](docs/prueba-bolsas.md)
- [Textos para CurseForge](docs/curseforge.md)

## English

Icons in your bags and loot window showing what you can sell or drop and which materials a profession uses. For **World of Warcraft: Forever** (1.60.1).

**Status:** 0.1.0-beta, unreleased. Tested only with automated tests against a simulated client (`luajit tests/run.lua`); not tested in game yet.

- Coin: grey items with a vendor price, items that start a quest you already finished, and armor or weapons your class can never equip (per Forever 1.60.1.70959 data). With QuestieDB loaded, also leftovers of finished, non-repeatable quests.
- Hammer: profession materials. Green if one of your professions uses it, grey if it belongs to a profession you don't have.
- When in doubt, no icon. Items a quest in your log needs never get a coin. Items with a use or equip effect, set pieces and items Questie knows from a repeatable quest never get an automatic coin (only with `/knu junk sell`). If the quest log can't be read in full (for example collapsed headers in combat after accepting a quest), there is no automatic coin until it is.
- Icons only on your character's bags 0 to 4, Blizzard's loot window and your character's bank **while it is open at a banker** (Blizzard, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags and Inventorian); closing the bank removes them. A closed or cached bank, the guild bank and cached views of other characters get none. Bank icons are not tested in game yet.
- The tooltip tells you why; items without an icon get no extra line, except "Marked by hand: keep" if you marked them with `keep`. KnuJunk never sells or deletes anything.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <link or ID>`, `status`.
- Bags: Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag and Inventorian. Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI and RealUI_Inventory currently show **no icons at all** until their window names are verified in game. The generic hook only marks buttons inside declared containers (today, Blizzard's bag frames). See [docs/prueba-bolsas.md](docs/prueba-bolsas.md) (Spanish) for which exist for Forever and which were checked against their code.
- Known limitations: without QuestieDB, an item that starts a finished quest gets a coin even if the quest is repeatable (unknown); quests your race or class can't do give no coin (not implemented); equip and use effects are detected via `GetItemSpell`, and if the client hasn't loaded the spell data yet an item may briefly be treated as having no effect; whether it reports equip-only effects is not verified on Forever.

QuestieDB is optional. Baganator: KnuJunk registers a junk plugin (Baganator may select it on its own when its current option isn't a plugin) and never writes Baganator's settings; the hammer is inserted in the top-right corner.

## Licencia

MIT. Código propio: no contiene código de otros addons de basura o de bolsas. KnuLib-1.0 va embebida.
