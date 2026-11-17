# KnuJunk

Iconos en las bolsas y en el botín para ver qué se puede vender o tirar y qué material usa una profesión. Para **World of Warcraft: Forever** (1.60.1, `## Interface: 16001`).

**Estado:** 0.1.0-beta, sin publicar. Probado sólo con pruebas automáticas contra un cliente simulado (`luajit tests/run.lua`); nada probado todavía en el juego.

## Qué hace

- Monedita: items grises con precio de venta, items que inician una misión ya hecha, y armaduras o armas que tu clase nunca puede equipar. Con QuestieDB cargado, también los sobrantes de misiones terminadas.
- Martillito: materiales de profesión. Verde si una profesión tuya lo usa, gris si es de una que no tenés.
- Ante la duda, sin marca. Lo que pide una misión del diario nunca lleva monedita.
- Marcas sólo en las bolsas 0 a 4 del personaje y en la ventana de botín de Blizzard. Banco y vistas de otros personajes, sin marca.
- El tooltip dice el motivo. No vende ni borra nada.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <enlace o ID>`, `status`.
- Bolsas: Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag, Inventorian y otras 8 por nombre de ventana, más un hook genérico. Cuáles existen para Forever y cuáles se revisaron contra su código: [docs/prueba-bolsas.md](docs/prueba-bolsas.md).

QuestieDB es opcional. Baganator: KnuJunk registra un plugin de basura (Baganator puede elegirlo solo si su opción actual no es un plugin) y nunca escribe la configuración de Baganator; el martillito se inserta arriba a la derecha.

## Documentos

- [Diseño](docs/superpowers/specs/2026-11-17-knujunk-design.md)
- [Plan de implementación](docs/superpowers/plans/2026-11-17-knujunk.md)
- [Prueba de bolsas](docs/prueba-bolsas.md)
- [Textos para CurseForge](docs/curseforge.md)

## English

Icons in your bags and loot window showing what you can sell or drop and which materials a profession uses. For **World of Warcraft: Forever** (1.60.1).

**Status:** 0.1.0-beta, unreleased. Tested only with automated tests against a simulated client (`luajit tests/run.lua`); not tested in game yet.

- Coin: grey items with a vendor price, items that start a quest you already finished, and armor or weapons your class can never equip. With QuestieDB loaded, also leftovers of finished quests.
- Hammer: profession materials. Green if one of your professions uses it, grey if it belongs to a profession you don't have.
- When in doubt, no icon. Items a quest in your log needs never get a coin.
- Icons only on your character's bags 0 to 4 and Blizzard's loot window. The bank and cached views of other characters get none.
- The tooltip tells you why. KnuJunk never sells or deletes anything.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <link or ID>`, `status`.
- Bags: see [docs/prueba-bolsas.md](docs/prueba-bolsas.md) (Spanish) for which exist for Forever and which were checked against their code.

QuestieDB is optional. Baganator: KnuJunk registers a junk plugin (Baganator may select it on its own when its current option isn't a plugin) and never writes Baganator's settings; the hammer is inserted in the top-right corner.

## Licencia

MIT. Código propio: no contiene código de otros addons de basura o de bolsas. KnuLib-1.0 va embebida.
