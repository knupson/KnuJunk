# KnuJunk

Iconos en las bolsas y en el botín para ver qué se puede vender o tirar y qué material usa una profesión. Para **World of Warcraft: Forever** (1.60.1, `## Interface: 16001`).

**Estado:** 0.1.0-beta, sin publicar. Probado sólo con pruebas automáticas contra un cliente simulado (`luajit tests/run.lua`); nada probado todavía en el juego.

## Qué hace

- Monedita: items grises con precio de venta, items de misión que ninguna misión de tu diario pide, items que inician una misión ya hecha, y armaduras o armas que tu clase nunca puede equipar (según los datos de Forever 1.60.1.70959).
- Misiones: sólo protege una misión que está **ahora** en tu diario. Un item de misión (de clase Misión, o que QuestieDB conoce como objetivo, objetivo oculto, fuente o entrega) que ninguna misión de tu diario pide lleva monedita «Ninguna misión activa lo pide», aunque una misión futura, no tomada, ya hecha o repetible lo use. Los iniciadores tienen su regla: si no hiciste la misión que inician, no llevan monedita (tooltip «Inicia una misión que no hiciste: <misión>»); hecha y no repetible, monedita «Misión terminada: <misión>». Lo que pide una misión del diario lleva el signo de misión en el botín y el tooltip dice «Misión activa: <misión>» (o «Lo pide una misión activa»).
- Martillito: materiales de profesión. Verde si una profesión tuya lo usa, amarillo si es de una que no tenés (vendible). Si además lo pide una misión de tu diario, lleva igual el martillito en las bolsas y el tooltip suma «Misión activa: <misión>» (o «Lo pide una misión activa»); en el botín se ve el signo de misión.
- Ante la duda, sin marca. Lo que pide una misión del diario nunca lleva monedita. Un item con efecto de uso o de equipar o una pieza de set nunca llevan monedita automática (sólo con `/knu junk sell`). Si el diario no se puede leer entero (por ejemplo, encabezados plegados en combate después de aceptar una misión), no hay monedita automática hasta leerlo completo.
- Marcas sólo en las bolsas 0 a 4 del personaje y en la ventana de botín de Blizzard. Banco y vistas de otros personajes, sin marca.
- El tooltip dice el motivo de cada ícono; un item sin ícono no suma líneas, salvo «Marcado a mano: guardar» si lo marcaste con `keep`, «Misión activa: …» o «Inicia una misión que no hiciste: …». No vende ni borra nada.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <enlace o ID>`, `status`.
- Bolsas: Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag e Inventorian. Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory tienen adaptador por nombre de ventana pero **hoy no muestran ninguna marca** hasta verificar en el juego el nombre de su ventana. El hook genérico sólo marca botones dentro de contenedores declarados (hoy, las ventanas de bolsas de Blizzard). Cuáles existen para Forever y cuáles se revisaron contra su código: [docs/prueba-bolsas.md](docs/prueba-bolsas.md).
- Limitaciones conocidas: sin QuestieDB, un item que inicia una misión ya hecha lleva monedita aunque la misión sea repetible (no se sabe); las misiones imposibles para tu raza o clase no dan monedita (no implementado); los efectos de uso o de equipar se detectan con `GetItemSpell` y, si el cliente todavía no cargó los datos del hechizo, un item puede tratarse por un momento como si no tuviera efecto; que informe los efectos sólo de equipar no está verificado en Forever.

QuestieDB es opcional. Baganator: KnuJunk registra un plugin de basura (Baganator puede elegirlo solo si su opción actual no es un plugin) y nunca escribe la configuración de Baganator ni cambia sus categorías: su plugin de basura sólo marca los grises con precio de venta (lo mismo que Baganator por defecto), así que nada más termina en su categoría de basura. Las otras moneditas (misión terminada, tu clase no lo usa, a mano) aparecen como la monedita de KnuJunk arriba a la izquierda; el martillito se inserta arriba a la derecha.

## Documentos

- [Diseño](docs/superpowers/specs/2026-11-17-knujunk-design.md)
- [Plan de implementación](docs/superpowers/plans/2026-11-17-knujunk.md)
- [Prueba de bolsas](docs/prueba-bolsas.md)
- [Textos para CurseForge](docs/curseforge.md)

## English

Icons in your bags and loot window showing what you can sell or drop and which materials a profession uses. For **World of Warcraft: Forever** (1.60.1).

**Status:** 0.1.0-beta, unreleased. Tested only with automated tests against a simulated client (`luajit tests/run.lua`); not tested in game yet.

- Coin: grey items with a vendor price, quest items no quest in your log needs, items that start a quest you already finished, and armor or weapons your class can never equip (per Forever 1.60.1.70959 data).
- Quests: only a quest that is **in your log right now** protects an item. A quest item (item class Quest, or one QuestieDB knows as an objective, hidden objective, source or turn-in item) that no quest in your log needs gets a coin, "No active quest needs it", even if a future, untaken, finished or repeatable quest uses it. Quest starters have their own rule: if you haven't done the quest they start, no coin (tooltip "Starts a quest you haven't done: <quest>"); once done and not repeatable, coin "Quest finished: <quest>". Items a quest in your log needs get the quest sign in the loot window and the tooltip says "Active quest: <quest>" (or "Needed by an active quest").
- Hammer: profession materials. Green if one of your professions uses it, grey if it belongs to a profession you don't have. If a quest in your log also needs it, it keeps the hammer in your bags and the tooltip adds "Active quest: <quest>" (or "Needed by an active quest"); the loot window shows the quest sign.
- When in doubt, no icon. Items a quest in your log needs never get a coin. Items with a use or equip effect and set pieces never get an automatic coin (only with `/knu junk sell`). If the quest log can't be read in full (for example collapsed headers in combat after accepting a quest), there is no automatic coin until it is.
- Icons only on your character's bags 0 to 4, Blizzard's loot window and your character's bank **while it is open at a banker** (Blizzard, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags and Inventorian); closing the bank removes them. A closed or cached bank, the guild bank and cached views of other characters get none. Bank icons are not tested in game yet.
- The tooltip tells you why; items without an icon get no extra line, except "Marked by hand: keep" if you marked them with `keep`, "Active quest: ..." or "Starts a quest you haven't done: ...". KnuJunk never sells or deletes anything.
- `/knu junk`: `on|off`, `coin|hammer|loot on|off`, `keep|sell|clear <link or ID>`, `status`.
- Bags: Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag and Inventorian. Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI and RealUI_Inventory currently show **no icons at all** until their window names are verified in game. The generic hook only marks buttons inside declared containers (today, Blizzard's bag frames). See [docs/prueba-bolsas.md](docs/prueba-bolsas.md) (Spanish) for which exist for Forever and which were checked against their code.
- Known limitations: without QuestieDB, an item that starts a finished quest gets a coin even if the quest is repeatable (unknown); quests your race or class can't do give no coin (not implemented); equip and use effects are detected via `GetItemSpell`, and if the client hasn't loaded the spell data yet an item may briefly be treated as having no effect; whether it reports equip-only effects is not verified on Forever.

QuestieDB is optional. Baganator: KnuJunk registers a junk plugin (Baganator may select it on its own when its current option isn't a plugin) and never writes Baganator's settings nor changes its categories: its junk plugin only flags grey items with a vendor price (the same as Baganator's default), so nothing else ends up in Baganator's junk category. The other coins (finished quest, your class can't use it, by hand) show as KnuJunk's own coin in the top-left corner; the hammer is inserted in the top-right corner.

## Licencia

MIT. Código propio: no contiene código de otros addons de basura o de bolsas. KnuLib-1.0 va embebida.
