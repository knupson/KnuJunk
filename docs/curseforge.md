# CurseForge page

Text to paste into the CurseForge project, checked against the code on 2026-11-17. Not yet tested in game: the bag lists below must be updated after the in-game pass (`docs/prueba-bolsas.md`).

Summary (max one line):

> Sell junk, quest leftovers & profession mats: icons in your bags and loot

---

## Description

**KnuJunk** puts a small icon on the items in your bags and in the loot window so you can see at a glance what you can sell, what you can toss and which materials a profession uses. It is written for **World of Warcraft: Forever** (1.60.1). English and Spanish.

It only shows icons. KnuJunk never sells, destroys or moves anything.

### Features

- **Coin** on items that are safe to sell or drop: grey items with a vendor price, items that start a quest you have already finished, and armor or weapons your class can never equip (the class table comes from Forever's own data, build 1.60.1.70959). Items with a use or equip effect and set pieces never get an automatic coin. Slots without an armor or weapon type (rings, trinkets, cloaks, shirts, tabards) never get the "your class can't use" coin; a grey one with a vendor price still gets the junk coin.
- **Hammer** on profession materials. Green: one of your professions uses it. Grey: it belongs to a profession you don't have. Profession **tools** (Blacksmith Hammer, Mining Pick, Skinning Knife, Philosopher's Stone, Engineering wrenches, Enchanting rods, Flint and Tinder) get the same hammer, since you need them but never use them up; the tooltip says "Tool for your profession: ...". They never get an automatic coin, even when grey. The fishing pole is not marked: Forever's data does not list it as a required tool. Main professions and Cooking, First Aid and Fishing count. The material table was generated from wago.tools data for the Forever build 1.60.1.70959.
- **Quest items are protected.** An item a quest in your log needs never gets a coin. Neither does an item that starts a quest you haven't finished, or any item when the game hasn't given the data yet. If the quest log can't be read in full (for example collapsed headers in combat after you accept a quest), no automatic coin is shown until it can. When there is doubt, there is no icon.
- **Tooltip reason.** Hover a marked item and the tooltip tells you why: "Junk: sells", "Quest finished: ...", "Your class can't use Plate", "Your profession: Mining", "Profession you don't have: Blacksmithing". Items without an icon get no extra line, except "Marked by hand: keep" when you chose to keep the item.
- **Loot window.** The Blizzard loot window shows the same coin and hammer, plus a quest sign on items a quest still needs (the quests in your log, and with QuestieDB any quest you haven't finished). With autoloot on there is no window, so nothing is marked.
- **Your call wins.** `/knu junk keep <item>` stops an item from getting a coin, `/knu junk sell <item>` forces one, `/knu junk clear <item>` removes your choice. The item can be a link or an item ID.
- **Only your own bags.** Icons go on your character's bags 0 to 4, on the loot window and on your character's bank while it is open at a banker (Blizzard bags, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags and Inventorian). Closing the bank removes them. A closed or cached bank, the guild bank and cached views of other characters get no icon.

### Commands

- `/knu junk` shows the help.
- `/knu junk on` / `off` turns every icon on or off.
- `/knu junk coin|hammer|loot on|off` turns one kind of icon on or off.
- `/knu junk keep|sell|clear <item link or ID>` sets your own mark for an item.
- `/knu junk status` shows the data build, whether QuestieDB is ready, which bag adapters are installed and your settings. `/knu kj` is a short alias when no other addon uses it.

### Supported bags

Blizzard's own bags and the loot window use public Blizzard functions. For other bag addons KnuJunk looks for the addon and attaches itself through the addon's own API or a hook. Anything it cannot prove to be one of your own bag slots stays unmarked.

Checked against the bag addon's code (the way the addon works was read in its source; not tested in game yet):

- Baganator 862
- ArkInventory 3.12.17
- Baggins (Forever 5.9.9)
- Bagnon (BagBrother 12.1.11)
- ElvUI 16.01
- Inventorian 12.1.5.1

Untested (no code read; written from how other addons describe them):

- BetterBags
- AdiBags
- EllesmereUIBags
- LiteBag
- tdBag2
- Bagnonium
- BaudBag
- Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI and RealUI_Inventory. For these eight, KnuJunk will stay silent until the window name of each addon has been checked in game.

Any other bag addon goes through a generic hook that only marks buttons inside declared containers, which today are only Blizzard's own bag frames. So in practice it adds nothing for third-party bags.

Some of these addons have no Forever version on CurseForge today (AdiBags, LiteBag, tdBag2, OneBag3, DerpyStuffing, famBags), and ElvUI is not on CurseForge. Those can't be tested. See `docs/prueba-bolsas.md` for the full table with links.

### Baganator

KnuJunk registers a junk plugin called "KnuJunk" in Baganator. When that plugin is the active one, Baganator draws its own junk coin on the items KnuJunk says are junk. KnuJunk also registers a hammer and a coin as corner widgets. The hammer comes with a default position, so Baganator adds it once to its top-right corner setting; the coin widget has no default position and is yours to place.

KnuJunk never writes to Baganator's settings. Baganator may pick the KnuJunk plugin by itself when its current junk option is not one of the registered plugins. That comes from reading Baganator's code and has not been tested in game. You can change the choice in Baganator's options and Baganator remembers it. Baganator's live bank (open at a banker, your own character) gets icons; its saved bank view, views of other characters and the guild bank are left without icons.

### QuestieDB (optional)

KnuJunk works without Questie. Without it, a coin on quest leftovers appears only on items that start a quest you have already finished. With QuestieDB loaded, KnuJunk also reads quest objectives, hidden objectives, required items and turn-in items, and gives a coin to leftovers of quests that are all finished. If any quest that uses the item is repeatable, the item gets no automatic coin of any kind. While QuestieDB is still building its index, no coin is shown at all, except the ones you set by hand. KnuJunk does not include or copy any QuestieDB code or data; it asks QuestieDB through its public API on your machine.

### Beta notes

This is the first beta and nothing has been tested in game yet. What has been done: automated tests against simulated game APIs, and reading the code of six bag addons. What that does not cover:

- Which of the two bag drawing paths and loot window paths Forever uses (the code supports both and picks what exists).
- Every bag addon in the untested list, and in the checked list how it behaves with Forever's real client.
- How tooltip lines look in Forever.
- The Baganator behavior described above.

Known limitations:

- Without QuestieDB, an item that starts a quest you finished gets a coin even if that quest is repeatable: without Questie KnuJunk can't know.
- Quests your race or class can never do don't give a coin yet.
- Equip and use effects are detected via `GetItemSpell`. If the client hasn't loaded the spell data yet, an item may briefly be treated as having no effect. Whether Forever reports equip-only effects is not verified either.
- Baganator: only the backpack views of the skins that ship with Baganator are recognized.

If you see a coin on something you needed, please tell us the item and the bag addon you use. A false coin is the one thing KnuJunk is built to avoid.

### Notes

- Settings and your manual marks are saved in `KnuJunkDB`.
- Written from scratch for Forever. It contains no code from other junk or bag addons.
- Requires nothing. Optional: QuestieDB, and any of the bag addons above.
- Source code and issues: TODO, repository URL not verified yet; fill it in before publishing. MIT license.

---

## Descripción (castellano)

**KnuJunk** pone un ícono chico en los items de tus bolsas y en la ventana de botín para que veas de un vistazo qué podés vender o tirar y qué materiales usa una profesión. Está hecho para **World of Warcraft: Forever** (1.60.1). Sólo muestra íconos: nunca vende, rompe ni mueve nada.

- **Monedita** en lo que se puede vender o tirar: items grises con precio de venta, items que inician una misión que ya hiciste y armaduras o armas que tu clase nunca puede equipar (según los datos de Forever). Los items con efecto de uso o de equipar y las piezas de set nunca llevan monedita automática. Las ranuras sin tipo de arma o armadura (anillos, abalorios, capas, camisas, tabardos) nunca la llevan por «tu clase no puede usarlo»; si son grises con precio, sí por gris. Los efectos se detectan con `GetItemSpell`: si el cliente todavía no cargó los datos del hechizo, un item puede tratarse por un momento como si no tuviera efecto.
- **Martillito** en los materiales de profesión: verde si una profesión tuya lo usa, gris si es de una profesión que no tenés. También las **herramientas** de profesión (martillo de herrero, pico de minero, cuchillo de desuello, piedra filosofal, llaves de Ingeniería, varas de encantador, pedernal): se necesitan pero no se gastan, y el tooltip dice «Herramienta de tu profesión: …». Nunca llevan monedita automática, ni siendo grises. La caña de pescar no se marca: los datos de Forever no la listan como herramienta requerida. Cuentan las principales y Cocina, Primeros auxilios y Pesca.
- **Lo que necesita una misión nunca lleva monedita.** Tampoco lo que inicia una misión sin terminar, ni nada cuyos datos el juego todavía no dio. Si el diario no se puede leer entero, no hay monedita automática hasta leerlo. Ante la duda, sin ícono.
- **Tooltip** con el motivo de cada ícono. Un item sin ícono no suma líneas, salvo «Marcado a mano: guardar» si elegiste conservarlo.
- **Ventana de botín** de Blizzard con las mismas marcas y un signo de misión para lo que pide una misión activa. Con autolooteo no hay ventana y no se marca nada.
- **Tu decisión manda:** `/knu junk keep <item>`, `/knu junk sell <item>` y `/knu junk clear <item>` (enlace o ID). También `/knu junk on|off`, `/knu junk coin|hammer|loot on|off` y `/knu junk status`.
- **Sólo tus bolsas:** bolsas 0 a 4 de tu personaje, el botín y el banco de tu personaje mientras está abierto en un banquero (bolsas de Blizzard, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags e Inventorian); al cerrarlo, los íconos del banco se van. El banco cerrado o guardado, el banco de hermandad y las vistas guardadas de otros personajes no llevan ícono.
- **QuestieDB opcional:** sin Questie, la monedita en sobrantes de misión sólo sale en items que inician una misión ya hecha (aunque sea repetible: sin Questie no se sabe). Con QuestieDB también cuenta objetivos, objetivos ocultos y entregas, y un item de una misión repetible no lleva monedita automática.
- **Bolsas:** Blizzard y su ventana de botín, más Baganator, ArkInventory, Baggins, Bagnon, ElvUI e Inventorian (revisadas contra el código de cada addon, sin probar en el juego) y el resto de la lista en inglés (sin probar). Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory hoy no muestran ninguna marca hasta verificar en el juego el nombre de su ventana. En Baganator, KnuJunk registra un plugin de basura; Baganator puede elegirlo solo si su opción actual no es un plugin, y KnuJunk nunca escribe la configuración de Baganator. El martillito se ubica solo arriba a la derecha.

Es la primera beta y todavía no se probó en el juego. Si ves una monedita en algo que necesitabas, avisá qué item y qué bolsa usás. Código propio, licencia MIT.

---

## Project settings

- Game version: **1.60.1** (Forever flavour)
- Category: Bags & Inventory
- License: MIT
- Avatar and banner: still to make
- Screenshots (to take after the in-game pass):
  1. Bags with coin and hammer icons.
  2. Tooltip with the reason line.
  3. Loot window with the quest sign.
  4. Baganator with the hammer in the top-right corner.
