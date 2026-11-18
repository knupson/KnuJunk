# CurseForge page

Text to paste into the CurseForge project, checked against the code on 2026-11-18. Not yet tested in game: the bag lists below must be updated after the in-game pass (`docs/prueba-bolsas.md`).

Summary (max one line):

> Sell junk, quest leftovers & profession mats: icons in your bags and loot

---

## Description

**KnuJunk** puts a small icon on the items in your bags and in the loot window so you can see at a glance what you can sell, what you can toss and which materials a profession uses. It is written for **World of Warcraft: Forever** (1.60.1). English and Spanish.

It only shows icons. KnuJunk never sells, destroys or moves anything.

### Features

- **Recetas por profesión (R14):** martillo verde si tenés la profesión y amarillo si no; tooltip «Receta de {profesión}, requiere {rango}» / «Recipe for {profession}, requires {rank}», sin requisito si no se conoce. Nunca moneda automática, incluso si ya la aprendiste o no tenés el rango. Datos de wowf `1.60.1.70959`: 2083 recetas, 2060 con rango; recetas de clase 9 sin profesión identificada quedan sin marca. La detección de recetas ya conocidas queda para otra etapa. Reiniciá el cliente para cargar `Data/Recipes.lua`.
- **Equipo para nivel futuro (R24):** sin moneda automática si tu clase puede llegar a usar el subtipo y el nivel requerido es mayor al tuyo; tooltip «Podés usarlo desde nivel {n}» / «Usable from level {n}». Sin ícono nuevo. Con nivel requerido desconocido no cambia el comportamiento anterior. Misión activa y profesión mantienen sus marcas; venta manual prevalece. Pendiente validar en el juego, junto con bolsas, banco y botín.
- **Llaves y cajas cerradas (R18):** sin moneda automática; misión activa y profesión conservan sus marcas y el tooltip explica la protección. `Data/Locks.lua`: 157 llaves/abridores (clase Key (13) más Skeleton Keys 15869–15872 y seforio 4367, 4398, 18594) y 29 cajas (`ItemSparse.LockID > 0`), build 1.60.1.70959. Los requisitos genéricos de Lock no acreditan llaves. Venta manual prevalece. Reiniciá el juego para cargar el archivo nuevo del `.toc`.
- **Repeatable reputation turn-ins (R20).** An explicit owner exception to the quest-log rule: an item objective of a repeatable quest with a positive reputation reward in QuestieDB is kept even when the quest is outside your log. No icon; "Turn in for reputation: <faction>" (localized name when available, otherwise faction ID). Profession and active-quest marks keep priority. Without QuestieDB there is no R20 protection: no Forever turn-in list could be derived from the game tables used. Manual sell still wins.
- **Coin** on items that are safe to sell or drop: grey items with a vendor price, quest items that no quest in your log needs, items that start a quest you have already finished when QuestieDB confirms it is not repeatable, and armor or weapons your class can never equip, only once that copy is soulbound (the class table comes from Forever's own data, build 1.60.1.70959). A copy that isn't bound yet, or one KnuJunk can't check (loot window, links), gets no coin; the tooltip says "Your class can't use Plate: you can auction it or pass it to another character". Items with a use or equip effect and set pieces never get an automatic coin. Effects come from `GetItemSpell`; when it reports nothing, KnuJunk reads the item's tooltip for "Equip:", "Use:" or "Chance on hit:" lines, if the tooltip can't be read yet the effect is "unknown": a grey item still gets its coin, but gear for another class and quest items don't. Slots without an armor or weapon type (rings, trinkets, cloaks, shirts, tabards) never get the "your class can't use" coin; a grey one with a vendor price still gets the junk coin.
- **Hammer** on profession materials. Green: one of your professions uses it. Yellow: it belongs to a profession you don't have (sellable). Profession **tools** (Blacksmith Hammer, Mining Pick, Skinning Knife, Philosopher's Stone, Engineering wrenches, Enchanting rods, Flint and Tinder) get the same hammer, since you need them but never use them up; the tooltip says "Tool for your profession: ...". They never get an automatic coin, even when grey. Fishing poles are not listed as required tools in Forever's data, so KnuJunk marks them as Fishing tools by item type. Main professions and Cooking, First Aid and Fishing count. The material table was generated from wago.tools data for the Forever build 1.60.1.70959.
- **Class spell reagents.** Reagents and tools of class spells (Rune of Teleportation and Rune of Portals, Ankh, Flash Powder, Soul Shard, Light Feather, rogue poison reagents, shaman totems: 37 items generated from Forever's data, build 1.60.1.70959) never get a coin or a hammer, whether you know the spell yet or not. For your class the tooltip says "Mage reagent: <spell>" (or "Reagent for your class's spells"); for another class, "Rogue reagent". If it is also a profession material or tool it keeps its hammer (green or yellow); the class only prevents the coin.
- **Only the quests in your log count.** An item a quest in your log needs never gets a coin, and the tooltip says "Active quest: ..." (or "Needed by an active quest"). If it is also a profession material or tool, it keeps its hammer in your bags. A quest item that no quest in your log needs gets a coin, "No active quest needs it", even if a future, untaken, finished or repeatable quest uses it, except R20 reputation turn-ins. An item that starts a quest you haven't done gets no coin ("Starts a quest you haven't done: ..."); once you've done it, it gets "Quest finished: ..." only if QuestieDB says the quest isn't repeatable; without that, no coin and the tooltip says "Quest turned in; unknown if it's repeatable". No coin either on any item when the game hasn't given the data yet. If the quest log can't be read in full (for example collapsed headers in combat after you accept a quest), no automatic coin is shown until it can. When there is doubt, there is no icon.
- **Tooltip reason.** Hover a marked item and the tooltip tells you why: "Junk: sells", "No active quest needs it", "Quest finished: ...", "Your class can't use Plate", "Your profession: Mining", "Profession you don't have: Blacksmithing". Items without an icon get no extra line, except "Marked by hand: keep" when you chose to keep the item, "Active quest: ...", "Starts a quest you haven't done: ...", "Quest turned in; unknown if it's repeatable", "Your class can't use ...: you can auction it...", the class reagent lines and the library book, waylaid crate, key, locked box and reputation lines.
- **Library books and waylaid crates.** Forever's library books (for the librarian) and waylaid crates (for the trade representative) never get an automatic coin, even when their item class is Quest and no quest in your log needs them. The tooltip tells you who takes them, only for your faction: library books go to Owen Thadd in Undercity (Horde) or Garion Wendell in Stormwind (Alliance); waylaid crates are filled with one of the options listed on the crate and go to Dokimi in the Crossroads (Horde) or Marcy Baker in Redridge (Alliance). The item list comes from Forever's own item data (wago.tools ItemSparse, build 1.60.1.70959): 40 library books and 46 crates. Sources for the turn-in NPCs: space4games.com "WoW Forever library books", wowcalc.net "Library books" wiki and mobalytics.gg "Waylaid crates explained".
- **Loot window.** The Blizzard loot window shows the same coin and hammer, plus a quest sign on items a quest in your log needs. With autoloot on there is no window, so nothing is marked.
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

KnuJunk registers a junk plugin called "KnuJunk" in Baganator. KnuJunk never changes Baganator's categories: when that plugin is the active one it only flags grey items with a vendor price that KnuJunk doesn't protect, the same items Baganator calls junk by default, so Baganator draws its own junk coin on them and nothing else moves to its junk category. KnuJunk also registers a hammer and a coin as corner widgets, both with a default position, so Baganator adds them once: the hammer to the top-right corner and the coin to the top-left one, next to Baganator's junk icon. KnuJunk's coin shows every other coin (finished quest, your class can't use it, marked by hand to sell); on items Baganator already marks as junk it stays hidden, so there is never a double coin.

KnuJunk never writes to Baganator's settings. Baganator may pick the KnuJunk plugin by itself when its current junk option is not one of the registered plugins. That comes from reading Baganator's code and has not been tested in game. You can change the choice in Baganator's options and Baganator remembers it. Baganator's live bank (open at a banker, your own character) gets icons; its saved bank view, views of other characters and the guild bank are left without icons.

### QuestieDB (optional)

KnuJunk works without Questie. Without it, your quest log alone decides: an item of the Quest class that no quest in your log needs gets a coin. An item that starts a quest you have already finished gets no coin without QuestieDB, since KnuJunk can't tell whether the quest is repeatable. With QuestieDB loaded, KnuJunk also reads quest objectives, hidden objectives, required items and turn-in items: any of those items gets a coin when no quest in your log needs it, whatever other quests use it. Items that start a quest follow their own rule (no coin until you've done the quest; after that, a coin only if QuestieDB says it is not repeatable). While QuestieDB is still building its index, no coin is shown at all, except the ones you set by hand. KnuJunk does not include or copy any QuestieDB code or data; it asks QuestieDB through its public API on your machine.

### Beta notes

This is the first beta and nothing has been tested in game yet. What has been done: automated tests against simulated game APIs, and reading the code of six bag addons. What that does not cover:

- Which of the two bag drawing paths and loot window paths Forever uses (the code supports both and picks what exists).
- Every bag addon in the untested list, and in the checked list how it behaves with Forever's real client.
- How tooltip lines look in Forever.
- The Baganator behavior described above.

Known limitations:

- Without QuestieDB, an item that starts a quest you finished gets no coin: without Questie KnuJunk can't know whether it is repeatable.
- Quests your race or class can never do don't give a coin yet.
- Reading equip and use effects and the "Soulbound" line from item tooltips is not tested on Forever yet.
- Baganator: only the backpack views of the skins that ship with Baganator are recognized.

If you see a coin on something you needed, please tell us the item and the bag addon you use. A false coin is the one thing KnuJunk is built to avoid.

### Notes

- Settings and your manual marks are saved in `KnuJunkDB`.
- Written from scratch for Forever. It contains no code from other junk or bag addons.
- Requires nothing. Optional: QuestieDB, and any of the bag addons above.
- Source code and issues: TODO, repository URL not verified yet; fill it in before publishing. MIT license.

---

## Descripción (castellano)

- **Llaves y cajas cerradas (R18):** sin moneda automática; misión activa y profesión conservan sus marcas y el tooltip explica la protección. `Data/Locks.lua`: 157 llaves/abridores (clase Key (13) más Skeleton Keys 15869–15872 y seforio 4367, 4398, 18594) y 29 cajas (`ItemSparse.LockID > 0`), build 1.60.1.70959. Los requisitos genéricos de Lock no acreditan llaves. Venta manual prevalece. Reiniciá el juego para cargar el archivo nuevo del `.toc`.
- **Entregas repetibles de reputación:** excepción aprobada por el dueño a la regla del diario. Objetivo de ítem de una misión repetible con recompensa positiva según QuestieDB: sin moneda aunque la misión no esté tomada; «Se entrega por reputación: {facción}». Profesión y misión activa mantienen su marca. Sin QuestieDB no hay protección R20 ni lista generada de entregas. La venta manual prevalece.
**KnuJunk** pone un ícono chico en los items de tus bolsas y en la ventana de botín para que veas de un vistazo qué podés vender o tirar y qué materiales usa una profesión. Está hecho para **World of Warcraft: Forever** (1.60.1). Sólo muestra íconos: nunca vende, rompe ni mueve nada.

- **Monedita** en lo que se puede vender o tirar: items grises con precio de venta, items de misión que ninguna misión de tu diario pide, items que inician una misión que ya hiciste si QuestieDB confirma que no es repetible, y armaduras o armas que tu clase nunca puede equipar, sólo si ese ejemplar ya está ligado (según los datos de Forever). Sin ligar, o sin poder saberlo (botín, enlaces), no hay monedita y el tooltip dice «Tu clase no puede usar Placas: podés subastarlo o pasarlo a otro personaje». Los items con efecto de uso o de equipar y las piezas de set nunca llevan monedita automática. Las ranuras sin tipo de arma o armadura (anillos, abalorios, capas, camisas, tabardos) nunca la llevan por «tu clase no puede usarlo»; si son grises con precio, sí por gris. Los efectos se detectan con `GetItemSpell` y, si no informa nada, con las líneas «Equipar:», «Uso:» o «Probabilidad al acertar:» del tooltip del item; si el tooltip no se puede leer todavía, el efecto queda «no se sabe»: el gris lleva igual su monedita, pero no la llevan el equipo de otra clase ni los items de misión.
- **Martillito** en los materiales de profesión: verde si una profesión tuya lo usa, amarillo si es de una profesión que no tenés (vendible). También las **herramientas** de profesión (martillo de herrero, pico de minero, cuchillo de desuello, piedra filosofal, llaves de Ingeniería, varas de encantador, pedernal): se necesitan pero no se gastan, y el tooltip dice «Herramienta de tu profesión: …». Nunca llevan monedita automática, ni siendo grises. La caña de pescar no figura como herramienta en los datos de Forever: KnuJunk la marca como herramienta de Pesca por su tipo de item. Cuentan las principales y Cocina, Primeros auxilios y Pesca.
- **Reactivos de hechizos de clase** (runas de teletransporte y de portales, Ankh, Soul Shard, Flash Powder, Light Feather, reactivos de venenos del pícaro, tótems del chamán: 37 items de los datos de Forever): nunca llevan monedita ni martillito, aunque todavía no sepas el hechizo. Si son de tu clase, el tooltip dice «Reactivo de Mago: <hechizo>» (o «Reactivo de hechizos de tu clase»); de otra clase, «Reactivo de Pícaro». Si además es material o herramienta de profesión, lleva su martillito (verde o amarillo); la clase sólo evita la monedita.
- **Sólo cuentan las misiones de tu diario.** Lo que pide una misión del diario nunca lleva monedita, y el tooltip dice «Misión activa: ...» (o «Lo pide una misión activa»); si además es material o herramienta de profesión, lleva el martillito en las bolsas. Un item de misión que ninguna misión del diario pide lleva monedita «Ninguna misión activa lo pide», aunque lo use una misión futura, no tomada, hecha o repetible. Lo que inicia una misión que no hiciste no lleva monedita («Inicia una misión que no hiciste: ...»); hecha, «Misión terminada: ...» sólo si QuestieDB dice que no es repetible; si no se sabe, sin monedita y tooltip «Misión entregada; no se sabe si es repetible». Tampoco lleva monedita nada cuyos datos el juego todavía no dio. Si el diario no se puede leer entero, no hay monedita automática hasta leerlo. Ante la duda, sin ícono.
- **Tooltip** con el motivo de cada ícono. Un item sin ícono no suma líneas, salvo «Marcado a mano: guardar» si elegiste conservarlo, «Misión activa: …», «Inicia una misión que no hiciste: …», «Misión entregada; no se sabe si es repetible», «Tu clase no puede usar …: podés subastarlo…» y las de reactivos de clase.
- **Ventana de botín** de Blizzard con las mismas marcas y un signo de misión para lo que pide una misión activa. Con autolooteo no hay ventana y no se marca nada.
- **Tu decisión manda:** `/knu junk keep <item>`, `/knu junk sell <item>` y `/knu junk clear <item>` (enlace o ID). También `/knu junk on|off`, `/knu junk coin|hammer|loot on|off` y `/knu junk status`.
- **Sólo tus bolsas:** bolsas 0 a 4 de tu personaje, el botín y el banco de tu personaje mientras está abierto en un banquero (bolsas de Blizzard, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags e Inventorian); al cerrarlo, los íconos del banco se van. El banco cerrado o guardado, el banco de hermandad y las vistas guardadas de otros personajes no llevan ícono.
- **QuestieDB opcional:** sin Questie decide sólo el diario: los items de clase Misión que ninguna misión del diario pide llevan monedita; los que inician una misión ya hecha, no (sin Questie no se sabe si es repetible). Con QuestieDB también cuentan objetivos, objetivos ocultos, fuentes y entregas: llevan monedita si ninguna misión del diario los pide. Un iniciador de una misión ya hecha lleva monedita sólo si QuestieDB dice que no es repetible.
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
  4. Baganator with the hammer in the top-right corner and KnuJunk's coin in the top-left one.
