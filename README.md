# KnuJunk

Iconos en las bolsas, el banco y el botín para ver qué se puede vender o tirar y qué material usa una profesión. Para **World of Warcraft: Forever** (1.60.1). Funciona solo: GearQuest, Pawn, QuestieDB, Auctionator y los addons de bolsas son opcionales y sólo suman información.

**Estado:** 0.1.4-beta. Probado en el juego: marcas en la mochila de Blizzard, en Baganator y en el banco, venta y reparación automáticas, venta de reactivos de otra clase, nivel que te falta en rojo y lectura de la especialización por talentos. Falta probar: la ventana de botín, la doble especialización (se obtiene a nivel 40) y los addons de bolsas que no son Blizzard ni Baganator.

## Qué hace

Cada ítem recibe un solo ícono, en este orden de prioridad:

| Ícono | Significa |
|---|---|
| Candado azul | Protegido: lo marcaste a mano y no se vende |
| Pergamino crema | Lo pide una misión que está ahora en tu diario |
| Martillo verde / naranja | Material o herramienta de una profesión tuya / de otra |
| Balanza violeta | Conviene subastarlo (necesita Auctionator) |
| Moneda dorada | Se vende |
| Tacho rojo | Se puede tirar: no tiene precio de venta |
| Tilde verde | Útil, se guarda |
| Signo de pregunta gris | El juego todavía no mandó los datos del ítem |

El tooltip dice el motivo de cada ícono. Ante la duda, se guarda: un diario de misiones incompleto, un estado de misión que no se pudo leer o un efecto desconocido nunca dan moneda ni tacho.

**Se vende:**
- Grises con precio de venta.
- Ítems de misión que ninguna misión de tu diario pide, aunque una misión futura o ya hecha los use (salvo entregas repetibles de reputación, según QuestieDB).
- Ítems que inician una misión que ya hiciste y que QuestieDB confirma que no se repite.
- Armas y armaduras que tu clase nunca puede usar, sólo si ese ejemplar ya está ligado. Sin ligar, el tooltip sugiere subastarlo o pasarlo a otro personaje.
- Armadura blanca o verde de un tipo inferior al que llevás puesto en esa ranura (tela, cuero o malla), sin tocar capas, anillos ni escudos. Con Encantamiento se guarda lo verde.
- Equipo superado por 10 o más niveles, y equipo que ni GearQuest ni Pawn piden para tu especialización.
- Reactivos de hechizos de otra clase.
- Lo que ninguna regla clasifica, salvo equipo, bolsas, cosas que se abren, munición, libros y recetas, misión, llaves y calidad rara o épica. Cada excepción explica en el tooltip qué hacer.

**Se guarda:**
- Lo que pide una misión de tu diario.
- Reactivos y herramientas de hechizos de tu clase.
- Recetas: martillo verde si tenés la profesión, naranja si no. El tooltip dice qué rango piden.
- Equipo que tu clase va a poder usar más adelante: en las bolsas se ve en rojo el nivel que pide y el tooltip dice «Podés usarlo desde nivel N».
- Llaves y cajas cerradas.
- Libros de biblioteca y cajones arrebatados de Forever. El tooltip dice a qué PNJ de tu facción entregarlos.

**En el vendedor:**
- Venta automática de lo que tiene moneda: una ranura cada 0,2 s, hasta 12 por visita, con un resumen en el chat. Opciones «Sólo grises» y límite por visita.
- Reparación automática, con fondos de hermandad opcionales. Mantené Shift para saltearla.
- Lo protegido queda bloqueado; clic derecho pide confirmación para venderlo una vez.
- KnuJunk nunca borra ítems.

**Botín:** la ventana de botín de Blizzard muestra los mismos íconos y «xN» si ya tenés ese ítem (sólo para lo que no se apila). Con la bolsa llena, mantené Shift para ver qué basura conviene tirar.

## Bolsas compatibles

Mochila y banco de Blizzard, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag e Inventorian. El banco se marca sólo mientras está abierto. El banco de hermandad y las vistas de otros personajes no llevan marcas.

En Baganator, KnuJunk es un ícono de esquina; la esquina se elige en las opciones de Baganator.

Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory todavía no muestran marcas: falta confirmar en el juego el nombre de su ventana.

## Opciones y comandos

Panel: Esc > Opciones > AddOns > KnuJunk, o `/knu junk`. Ahí elegís qué íconos ver, su tamaño, opacidad, esquina y color, las reglas de venta, la lista de ítems marcados a mano y una tecla para cambiar la marca del ítem bajo el mouse (Protegido / Automático). En combate el juego no deja abrir el panel con un comando: abrilo al salir de combate.

Comida y bebida superadas, munición superada y recetas ya aprendidas se venden por defecto; se pueden apagar en el panel o con `/knu junk rules`.

| Comando | Qué hace |
|---|---|
| `/knu junk` | Abre el panel de opciones |
| `/knu junk help` | Muestra la ayuda |
| `/knu junk on` / `off` | Prende o apaga todos los íconos |
| `/knu junk coin\|hammer\|loot on\|off` | Prende o apaga un tipo de ícono |
| `/knu junk keep\|clear <enlace o ID>` | Protege un ítem o le saca tu marca |
| `/knu junk rules` | Lista las reglas opcionales y su estado |
| `/knu junk status` | Datos, QuestieDB, adaptadores de bolsas y opciones |

## Limitaciones conocidas

- Sin QuestieDB, un ítem que inicia una misión ya hecha no lleva moneda: no se sabe si la misión se repite.
- Las misiones que tu raza o clase nunca puede hacer todavía no dan moneda.

## English

Icons on your bags, bank and loot window showing what you can sell or drop and which materials a profession uses. For **World of Warcraft: Forever** (1.60.1). Works on its own: GearQuest, Pawn, QuestieDB, Auctionator and bag addons are optional and only add information.

**Status:** 0.1.4-beta. Tested in game: icons on Blizzard's backpack, Baganator and the bank, automatic selling and repair, selling other classes' reagents, the missing level in red, and reading your specialization from talents. Not tested yet: the loot window, dual specialization (unlocked at level 40) and bag addons other than Blizzard and Baganator.

Each item gets one icon, by priority: blue lock (Protected, marked by you), cream scroll (a quest in your log needs it), green/orange hammer (material or tool for one of your professions / another one), purple scale (worth auctioning, needs Auctionator), gold coin (sell), red bin (drop, no vendor price), green tick (useful, keep) and grey question mark (the game has not sent the item data yet). The tooltip gives the reason. When in doubt, it keeps the item.

**Sold:** greys with a vendor price; quest items no quest in your log needs (except repeatable reputation turn-ins, per QuestieDB); starters of a finished quest QuestieDB confirms is not repeatable; weapons and armor your class can never use, only once that copy is bound; white or green armor of a lower type than the one you wear in that slot (cloth, leather or mail; not cloaks, rings or shields; greens kept with Enchanting); gear 10 or more levels below you and gear neither GearQuest nor Pawn wants for your spec; other classes' spell reagents; and anything no rule covers, except gear, bags, openable items, ammunition, books and recipes, quest items, keys and rare or epic quality.

**Kept:** what a quest in your log needs; your class's spell reagents and tools; recipes (green hammer if you have the profession); gear your class can use later (the required level shows in red on the icon and the tooltip says "Usable from level N"); keys and locked boxes; Forever's library books and waylaid crates (the tooltip names your faction's NPC).

**At the merchant:** coin items are sold automatically (one slot every 0.2 s, up to 12 per visit, with a chat summary); automatic repair with optional guild funds (hold Shift to skip); protected items are locked and right-click asks before selling one. KnuJunk never deletes items.

**Loot window:** the same icons, plus "xN" when you already carry that item (non-stacking items only). With full bags, hold Shift to see which junk is worth dropping.

**Bags:** Blizzard's backpack and bank, Baganator, BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag and Inventorian. The bank is marked only while it is open. Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI and RealUI_Inventory show no icons yet: their window names still have to be confirmed in game.

**Options:** Esc > Options > AddOns > KnuJunk, or `/knu junk`. Choose which icons to show, size, opacity, corner and color, the selling rules, your hand-marked items and a key that switches the hovered item between Protected and Automatic. Outleveled food and drink, outdamaged ammunition and already learned recipes are sold by default; turn them off in the panel or with `/knu junk rules`. Commands: `help`, `on|off`, `coin|hammer|loot on|off`, `keep|clear <link or ID>`, `rules`, `status`.

**Known limitations:** without QuestieDB, an item that starts a finished quest gets no coin (repeatability unknown); quests your race or class can never do don't give a coin yet.

**Feedback:**

- If KnuJunk helps you, add it to your favorites (the star) on [CurseForge](https://www.curseforge.com/wow/addons/knujunk) and leave a comment. That is how other Forever players find it.
- Found a bug? Open an issue at https://github.com/knupson/KnuJunk/issues or leave a comment with the error text (BugSack copies it) and what you were doing.
- Ideas and requests go in the comments or in an issue.

## Opiniones y errores

- Si KnuJunk te sirve, marcalo como favorito (la estrella) en [CurseForge](https://www.curseforge.com/wow/addons/knujunk) y dejá un comentario: así lo encuentran otros jugadores de Forever.
- Si encontrás un error, abrí un issue en https://github.com/knupson/KnuJunk/issues o dejá un comentario, con el texto del error (BugSack lo copia) y qué estabas haciendo.
- Las ideas y los pedidos, en los comentarios o como issue.

## Para desarrolladores

- Pruebas: `luajit tests/run.lua` (cliente simulado).
- Datos generados de wago.tools, build `1.60.1.70959`: recetas, llaves y cajas, reactivos de clase, comida, munición y objetos especiales en `Data/*.lua`. Se regeneran con `python -I tools/build_data.py --offline`.
- Auditoría de venta reproducible: `python -I tools/auditoria_venta.py --ambos` ([resultado](docs/auditoria-venta.md)).
- Otros addons pueden leer la marca de un ítem con `KnuJunkAPI.MarkFor(itemLink, bag, slot)`.
- Documentos: [diseño](docs/superpowers/specs/2026-11-17-knujunk-design.md), [plan](docs/superpowers/plans/2026-11-17-knujunk.md), [prueba de bolsas](docs/prueba-bolsas.md), [textos para CurseForge](docs/curseforge.md), [CHANGELOG](CHANGELOG.md).

## Licencia

MIT. Código propio: no contiene código de otros addons de basura o de bolsas. KnuLib-1.0 va embebida.
