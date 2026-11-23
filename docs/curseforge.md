# CurseForge page

Text to paste into the CurseForge project. Status: 0.1.3-beta. Tested in game: icons on Blizzard's backpack, Baganator and the bank, automatic selling and repair, selling other classes' reagents, the missing level in red, and reading your specialization from talents. Not tested yet: the loot window, dual specialization (unlocked at level 40) and bag addons other than Blizzard and Baganator.

Summary (max one line):

> Sell junk, quest leftovers & profession mats: icons in your bags and loot

---

## Description

**KnuJunk** puts a small icon on the items in your bags and in the loot window so you can see at a glance what you can sell, what you can toss and which materials a profession uses. It is written for **World of Warcraft: Forever** (1.60.1). English and Spanish.

KnuJunk never deletes items.

### Features

- **At the merchant:** items with a coin are sold automatically, one slot every 0.2 s, up to 12 per visit, with a chat summary. The options include "grey items only" and a limit per visit. Automatic repair, with optional guild funds; hold Shift to skip it.

- **Merchant protection:** Protected items are locked while the merchant is open; right-click asks before selling that copy once, keeping the mark. Enabled by default and configurable. Without shield support, the lock remains. Restart the client after updating; not tested in game yet.

- **Manual mark key:** assign a key in options, then hover a bag or loot item to cycle Protected / Automatic. No default key; assignment is out of combat and reports replaced actions.

- **Recipes by profession:** green hammer if you have the profession, orange if you don't; tooltip "Recipe for {profession}, requires {rank}" (no requirement shown when it is unknown). A recipe you don't know yet, or whose rank you lack, gets no automatic coin. Recipes you already learned are sold by default (optional rule `knownrecipe`; it needs the item tooltip's "Already known" line). Data from Forever build 1.60.1.70959: 2083 recipes, 2060 with a rank; class recipes with no identified profession stay as Useful. Restart the client after updating.
- **Gear for a future level:** no automatic coin if your class can eventually use that subtype and the required level is above yours; tooltip "Usable from level {n}". In the bags the required level shows in red on the icon (Blizzard's backpack and Baganator; option "Level you need"). With an unknown required level nothing changes. Active quest and profession marks keep priority; your manual mark wins.
- **Keys and locked boxes:** no automatic coin; active quest and profession marks are kept and the tooltip explains the protection. Forever data, build 1.60.1.70959: 157 keys and openers (the Key item class plus Skeleton Keys 15869-15872 and items 4367, 4398 and 18594) and 29 locked boxes. Your manual mark wins. Restart the game after updating.
- **Repeatable reputation turn-ins.** An exception to the quest-log rule: an item objective of a repeatable quest with a positive reputation reward in QuestieDB is kept even when the quest is outside your log. No icon; "Turn in for reputation: <faction>" (localized name when available, otherwise faction ID). Profession and active-quest marks keep priority. Without QuestieDB there is no such protection: no Forever turn-in list could be derived from the game tables used. Manual sell still wins.
- **Coin** on items that are safe to sell or drop: grey items with a vendor price, quest items that no quest in your log needs, items that start a quest you have already finished when QuestieDB confirms it is not repeatable, and armor or weapons your class can never equip, only once that copy is soulbound (the class table comes from Forever's own data, build 1.60.1.70959). A copy that isn't bound yet, or one KnuJunk can't check (loot window, links), gets no coin; the tooltip says "Your class can't use Plate: you can auction it or pass it to another character". Items with a use or equip effect and set pieces never get an automatic coin. Effects come from `GetItemSpell`; when it reports nothing, KnuJunk reads the item's tooltip for "Equip:", "Use:" or "Chance on hit:" lines, if the tooltip can't be read yet the effect is "unknown": the item gets Useful, including greys. Slots without an armor or weapon type (rings, trinkets, cloaks, shirts, tabards) never get the "your class can't use" coin; a grey one with a vendor price still gets the junk coin.
- **Hammer** on profession materials. Green: one of your professions uses it. Orange: it belongs to a profession you don't have (sellable). Profession **tools** (Blacksmith Hammer, Mining Pick, Skinning Knife, Philosopher's Stone, Engineering wrenches, Enchanting rods, Flint and Tinder) get the same hammer, since you need them but never use them up; the tooltip says "Tool for your profession: ...". They never get an automatic coin, even when grey. Fishing poles are not listed as required tools in Forever's data, so KnuJunk marks them as Fishing tools by item type. Main professions and Cooking, First Aid and Fishing count. The material table was generated from wago.tools data for the Forever build 1.60.1.70959.
- **Class spell reagents.** Reagents and tools of class spells (Rune of Teleportation and Rune of Portals, Ankh, Flash Powder, Soul Shard, Light Feather, rogue poison reagents, shaman totems: 37 items generated from Forever's data, build 1.60.1.70959) never get a coin or a hammer, whether you know the spell yet or not. For your class the tooltip says "Mage reagent: <spell>" (or "Reagent for your class's spells"); for another class, "Rogue reagent". If it is also a profession material or tool it keeps its hammer (green or orange); the class only prevents the coin.
- **Only the quests in your log count.** An item a quest in your log needs never gets a coin, and the tooltip says "Active quest: ..." (or "Needed by an active quest"). The active-quest scroll takes priority over profession hammers in bags, bank and loot. A quest item that no quest in your log needs gets a coin, "No active quest needs it", even if a future, untaken, finished or repeatable quest uses it, except repeatable reputation turn-ins. An item that starts a quest you haven't done gets no coin ("Starts a quest you haven't done: ..."); once you've done it, it gets "Quest finished: ..." only if QuestieDB says the quest isn't repeatable; without that, no coin and the tooltip says "Quest turned in; unknown if it's repeatable". No coin either on any item when the game hasn't given the data yet. If the quest log can't be read in full (for example collapsed headers in combat after you accept a quest), no automatic coin is shown until it can. When there is doubt, the item gets Useful.
- **Tooltip legend.** One legend in the icon color, auction/vendor prices for Auction, followed by the existing reason lines.
- **Library books and waylaid crates.** Forever's library books (for the librarian) and waylaid crates (for the trade representative) never get an automatic coin, even when their item class is Quest and no quest in your log needs them. The tooltip tells you who takes them, only for your faction: library books go to Owen Thadd in Undercity (Horde) or Garion Wendell in Stormwind (Alliance); waylaid crates are filled with one of the options listed on the crate and go to Dokimi in the Crossroads (Horde) or Marcy Baker in Redridge (Alliance). The item list comes from Forever's own item data (wago.tools ItemSparse, build 1.60.1.70959): 40 library books and 46 crates. Sources for the turn-in NPCs: space4games.com "WoW Forever library books", wowcalc.net "Library books" wiki and mobalytics.gg "Waylaid crates explained".
- **Loot window.** The Blizzard loot window shows the same coin and hammer, plus a quest sign on items a quest in your log needs. With full bags, hold Shift to see which junk is worth dropping. With autoloot on there is no window, so nothing is marked.
- **Options panel.** Esc > Options > AddOns > KnuJunk or `/knu junk`: checkboxes for every icon and for the optional selling rules (on by default), the list of items you marked by hand with a "Remove" button for each, and at the bottom the data build, QuestieDB status and installed bag adapters. Changes apply right away. In combat KnuJunk asks you to open it after combat.
- **Your call wins.** The key toggles Protected / Automatic. Use `/knu junk keep <item>` to protect and `/knu junk clear <item>` to clear. Old sell overrides remain listed as "Sell (legacy mark)" with a Remove button.
- **Only your own bags.** Icons go on your character's bags 0 to 4, on the loot window and on your character's bank while it is open at a banker (Blizzard bags, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags and Inventorian). Closing the bank removes them. A closed or cached bank, the guild bank and cached views of other characters get no icon.

### Commands

- `/knu junk` opens the options panel (Esc > Options > AddOns > KnuJunk). `/knu junk help` shows the help.
- `/knu junk on` / `off` turns every icon on or off.
- `/knu junk coin|hammer|loot on|off` turns one kind of icon on or off.
- `/knu junk keep|clear <item link or ID>` sets your own mark for an item.
- `/knu junk status` shows the data build, whether QuestieDB is ready, which bag adapters are installed and your settings. `/knu kj` is a short alias when no other addon uses it.

### Supported bags

Blizzard's own bags and the loot window use public Blizzard functions. For other bag addons KnuJunk looks for the addon and attaches itself through the addon's own API or a hook. Anything it cannot prove to be one of your own bag slots stays unmarked.

Tested in game: Blizzard's own bags and bank, and Baganator 862.

Checked against the bag addon's code (the way the addon works was read in its source; not tested in game yet):

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

Some of these addons have no Forever version on CurseForge today (AdiBags, LiteBag, tdBag2, OneBag3, DerpyStuffing, famBags), and ElvUI is not on CurseForge. Those can't be tested.

### Baganator

KnuJunk registers one corner widget, auto-inserted at the top right. The earlier IDs stay as aliases with no drawing. The junk plugin only marks sellable greys and keeps the categories; the widget avoids duplicating its native coin. Choose the corner in Baganator's options.

KnuJunk never writes to Baganator's settings. Baganator may pick the KnuJunk plugin by itself when its current junk option is not one of the registered plugins. That comes from reading Baganator's code and has not been tested in game. You can change the choice in Baganator's options and Baganator remembers it. Baganator's live bank (open at a banker, your own character) gets icons; its saved bank view, views of other characters and the guild bank are left without icons.

### QuestieDB (optional)

KnuJunk works without Questie. Without it, your quest log alone decides: an item of the Quest class that no quest in your log needs gets a coin. An item that starts a quest you have already finished gets no coin without QuestieDB, since KnuJunk can't tell whether the quest is repeatable. With QuestieDB loaded, KnuJunk also reads quest objectives, hidden objectives, required items and turn-in items: any of those items gets a coin when no quest in your log needs it, whatever other quests use it. Items that start a quest follow their own rule (no coin until you've done the quest; after that, a coin only if QuestieDB says it is not repeatable). While QuestieDB is still building its index, no coin is shown at all, except the ones you set by hand. KnuJunk does not include or copy any QuestieDB code or data; it asks QuestieDB through its public API on your machine.

### Beta notes

This is a beta. Tested in game: see the status at the top. Besides that, the code has automated tests against simulated game APIs, and the code of six bag addons was read. Not covered yet:

- The loot window and dual specialization (unlocked at level 40).
- Every bag addon in the untested list, and in the checked list how it behaves with Forever's real client.
- The Baganator behavior described above (picking the KnuJunk plugin by itself).

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
- Source code and issues: https://github.com/knupson/KnuJunk. MIT license.

---

## Descripción (castellano)

**KnuJunk** pone un ícono chico en los items de tus bolsas y en la ventana de botín para que veas de un vistazo qué podés vender o tirar y qué materiales usa una profesión. Está hecho para **World of Warcraft: Forever** (1.60.1). Nunca borra ítems.

Cada ítem recibe un solo ícono, por prioridad: candado azul (Protegido), pergamino crema (misión activa), martillo verde/naranja (profesión propia/ajena), balanza violeta (Subastar), moneda dorada (Vender), tacho rojo (Tirar, sin precio de venta), tilde verde (Útil) o signo de pregunta gris (el juego todavía no mandó los datos del ítem). Subastar requiere Auctionator, ítem sin ligadura confirmada y precio al menos igual al mayor entre el doble del vendedor y 1 plata; factor y mínimo son configurables.

En «Íconos» podés elegir las ocho marcas, tamaño (10-32 px, predeterminado 14), opacidad (30-100%), fondo oscuro, esquina, color por marca y moneda Blizzard/KnuJunk. «Restaurar colores» vuelve a la paleta inicial. La tecla alterna Protegido / Automático y limpia marcas viejas de venta; esas marcas aparecen como «Vender (marca vieja)» con «Quitar». Los cambios se aplican al instante.

- **En el vendedor:** lo que tiene moneda se vende automáticamente, una ranura cada 0,2 s, hasta 12 por visita, con un resumen en el chat. Entre las opciones están «Sólo grises» y un límite por visita. Reparación automática, con fondos de hermandad opcionales; mantené Shift para saltearla.
- **Protección en el vendedor:** «Protegido» bloquea el ítem mientras está abierto; clic derecho pide confirmación para vender ese ejemplar una vez, sin borrar la marca. Activada por defecto y configurable. Sin API de escudos, queda el bloqueo. Reiniciá el cliente tras actualizar; todavía no se probó en el juego.
- **Tecla para marcas manuales:** asignala en el panel de opciones y apretala sobre un ítem de bolsas o botín: Protegido / Automático. Sin tecla predeterminada; se asigna fuera de combate y avisa si reemplaza otra acción.
- **Llaves y cajas cerradas:** sin moneda automática; misión activa y profesión conservan sus marcas y el tooltip explica la protección. Datos de Forever, build 1.60.1.70959: 157 llaves y abridores (la clase de ítem Llave más las Skeleton Keys 15869-15872 y los ítems 4367, 4398 y 18594) y 29 cajas cerradas. La venta manual prevalece. Reiniciá el juego tras actualizar.
- **Entregas repetibles de reputación:** excepción a la regla del diario. Objetivo de ítem de una misión repetible con recompensa positiva según QuestieDB: sin moneda aunque la misión no esté tomada; «Se entrega por reputación: {facción}». Profesión y misión activa mantienen su marca. Sin QuestieDB no hay esta protección ni lista generada de entregas. La venta manual prevalece.
- **Monedita** en lo que se puede vender o tirar: items grises con precio de venta, items de misión que ninguna misión de tu diario pide, items que inician una misión que ya hiciste si QuestieDB confirma que no es repetible, y armaduras o armas que tu clase nunca puede equipar, sólo si ese ejemplar ya está ligado (según los datos de Forever). Sin ligar, o sin poder saberlo (botín, enlaces), no hay monedita y el tooltip dice «Tu clase no puede usar Placas: podés subastarlo o pasarlo a otro personaje». Los items con efecto de uso o de equipar y las piezas de set nunca llevan monedita automática. Las ranuras sin tipo de arma o armadura (anillos, abalorios, capas, camisas, tabardos) nunca la llevan por «tu clase no puede usarlo»; si son grises con precio, sí por gris. Los efectos se detectan con `GetItemSpell` y, si no informa nada, con las líneas «Equipar:», «Uso:» o «Probabilidad al acertar:» del tooltip del item; si el tooltip no se puede leer todavía, el efecto queda «no se sabe»: el gris lleva igual su monedita, pero no la llevan el equipo de otra clase ni los items de misión.
- **Martillito** en los materiales de profesión: verde si una profesión tuya lo usa, naranja si es de una profesión que no tenés (vendible). También las **herramientas** de profesión (martillo de herrero, pico de minero, cuchillo de desuello, piedra filosofal, llaves de Ingeniería, varas de encantador, pedernal): se necesitan pero no se gastan, y el tooltip dice «Herramienta de tu profesión: …». Nunca llevan monedita automática, ni siendo grises. La caña de pescar no figura como herramienta en los datos de Forever: KnuJunk la marca como herramienta de Pesca por su tipo de item. Cuentan las principales y Cocina, Primeros auxilios y Pesca.
- **Reactivos de hechizos de clase** (runas de teletransporte y de portales, Ankh, Soul Shard, Flash Powder, Light Feather, reactivos de venenos del pícaro, tótems del chamán: 37 items de los datos de Forever): nunca llevan monedita ni martillito, aunque todavía no sepas el hechizo. Si son de tu clase, el tooltip dice «Reactivo de Mago: <hechizo>» (o «Reactivo de hechizos de tu clase»); de otra clase, «Reactivo de Pícaro». Si además es material o herramienta de profesión, lleva su martillito (verde o naranja); la clase sólo evita la monedita.
- **Sólo cuentan las misiones de tu diario.** Lo que pide una misión del diario nunca lleva monedita, y el tooltip dice «Misión activa: ...» (o «Lo pide una misión activa»); si además es material o herramienta de profesión, lleva el martillito en las bolsas. Un item de misión que ninguna misión del diario pide lleva monedita «Ninguna misión activa lo pide», aunque lo use una misión futura, no tomada, hecha o repetible. Lo que inicia una misión que no hiciste no lleva monedita («Inicia una misión que no hiciste: ...»); hecha, «Misión terminada: ...» sólo si QuestieDB dice que no es repetible; si no se sabe, sin monedita y tooltip «Misión entregada; no se sabe si es repetible». Tampoco lleva monedita nada cuyos datos el juego todavía no dio. Si el diario no se puede leer entero, no hay monedita automática hasta leerlo. Ante la duda, con ícono Útil.
- **Tooltip** con el motivo de cada ícono. Un item sin ícono no suma líneas, salvo «Protegido (a mano)» si elegiste conservarlo, «Misión activa: …», «Inicia una misión que no hiciste: …», «Misión entregada; no se sabe si es repetible», «Tu clase no puede usar …: podés subastarlo…» y las de reactivos de clase.
- **Ventana de botín** de Blizzard con las mismas marcas y un signo de misión para lo que pide una misión activa. Con autolooteo no hay ventana y no se marca nada. Con la bolsa llena, mantené Shift para ver qué basura conviene tirar.
- **Panel de opciones:** Esc > Opciones > AddOns > KnuJunk o `/knu junk`: casillas para cada marca y para las reglas de venta opcionales (prendidas por defecto), la lista de marcas manuales con un botón «Quitar» por item y, al pie, el build de datos, el estado de QuestieDB y los adaptadores de bolsas instalados. Los cambios se aplican al instante. En combate KnuJunk pide abrirla al salir.
- **Tu decisión manda:** la tecla alterna Protegido / Automático. `/knu junk keep <item>` protege y `/knu junk clear <item>` borra la marca. Las marcas viejas de venta siguen disponibles para quitar desde el panel.
- **Sólo tus bolsas:** bolsas 0 a 4 de tu personaje, el botín y el banco de tu personaje mientras está abierto en un banquero (bolsas de Blizzard, Baganator, Bagnon, Bagnonium, ElvUI, ArkInventory, BetterBags e Inventorian); al cerrarlo, los íconos del banco se van. El banco cerrado o guardado, el banco de hermandad y las vistas guardadas de otros personajes no llevan ícono.
- **QuestieDB opcional:** sin Questie decide sólo el diario: los items de clase Misión que ninguna misión del diario pide llevan monedita; los que inician una misión ya hecha, no (sin Questie no se sabe si es repetible). Con QuestieDB también cuentan objetivos, objetivos ocultos, fuentes y entregas: llevan monedita si ninguna misión del diario los pide. Un iniciador de una misión ya hecha lleva monedita sólo si QuestieDB dice que no es repetible.
- **Bolsas:** Blizzard y su ventana de botín, más Baganator (probados en el juego), ArkInventory, Baggins, Bagnon, ElvUI e Inventorian (revisados contra el código de cada addon, sin probar en el juego) y el resto de la lista en inglés (sin probar). Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory hoy no muestran ninguna marca hasta verificar en el juego el nombre de su ventana. En Baganator, KnuJunk registra un plugin de basura; Baganator puede elegirlo solo si su opción actual no es un plugin, y KnuJunk nunca escribe la configuración de Baganator. El widget único «KnuJunk» se autoinserta arriba a la derecha; lo ubicás en las opciones de Baganator.

Es una beta. Lo probado en el juego está en el estado de arriba. Si ves una monedita en algo que necesitabas, avisá qué item y qué bolsa usás. Código propio, licencia MIT.

---

### Opciones

Las tres reglas opcionales (comida y bebida, munición y recetas ya aprendidas) arrancan **prendidas**; las instalaciones anteriores se prendieron una sola vez al actualizar y después se respeta tu elección. `/knu junk rules` lista sus estados; `/knu junk status` también los muestra. Usá `/knu junk rules food|ammo|knownrecipe on|off` para cambiar una y refrescar las marcas.

- **food:** comida/bebida de restauración simple, nivel del personaje al menos 15 por encima del requerido y alternativa usable en bolsas que restaure más del mismo recurso. Sólo ejemplares en bolsas 0 a 4. Nunca se aplica a cazadores, porque sus mascotas comen comida común. Sin buffs, comida exclusiva de mascota ni otros efectos. Tooltip: «Tenés comida/bebida mejor para tu nivel».
- **ammo:** flechas o balas ordinarias con otra pila usable del mismo subtipo en bolsas, de mayor DPS confirmado y al menos 10 niveles de objeto más. Conserva la munición equipada y al menos una pila compatible; sólo marca ejemplares identificados en las bolsas del personaje. Tooltip: «Tenés munición compatible de mayor daño».
- **knownrecipe:** exige la línea exacta «Already known» / «Ya conocido» del tooltip de ese ejemplar en bolsa. Con ligadura confirmada y precio positivo: moneda, «Ya conocés esta receta». Sin ligadura confirmada: sin moneda, «Ya la conocés; podés pasarla o subastarla». Ausencia de la línea no demuestra conocimiento.

Misión activa, reactivos/herramientas, efectos adicionales o desconocidos, sets, llaves, objetos especiales y demás protecciones conservan precedencia; tus marcas manuales siguen mandando. Sólo la restauración simple identificada se exceptúa de su propio efecto de uso, nunca de otro efecto. Datos de Forever, build 1.60.1.70959: 131 comidas y bebidas y 35 municiones ordinarias (se excluye 19286, Fast Test Ammo). Reiniciá el cliente tras actualizar. Pendiente validar en Forever.

## Project settings

- Game version: **1.60.1** (Forever flavour)
- Category: Bags & Inventory
- License: MIT
- Avatar and banner: still to make
- Screenshots (to take after the in-game pass):
  1. Bags with coin and hammer icons.
  2. Tooltip with the reason line.
  3. Loot window with the quest sign.
  4. Baganator with the single KnuJunk corner widget.
