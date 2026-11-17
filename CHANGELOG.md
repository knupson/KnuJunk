# Changelog

## 0.1.0-beta (sin publicar)

- Monedita en lo que se puede vender o tirar: items grises con precio, items que inician una misión ya hecha (con QuestieDB, también objetivos, objetivos ocultos y entregas de misiones terminadas y no repetibles) y armas o armaduras que tu clase nunca puede equipar. La tabla de equipo por clase también sale de wago.tools (ClassMask de SkillLineAbility): los pícaros usan hachas de una mano y los druidas armas de asta.
- Martillito en los materiales de profesión: verde si una profesión tuya lo usa, gris si es de una que no tenés. Tablas generadas desde wago.tools para la build 1.60.1.70959.
- Sin marca ante la duda: lo que pide una misión del diario, los iniciadores de misiones sin hacer y los items sin datos cargados. Sin monedita automática de ningún tipo (sí con `/knu junk sell`): items con efecto de uso o de equipar (o sin poder saberlo), piezas de set, items de una misión repetible según Questie y todo mientras el diario no se pueda leer entero.
- Marcas sólo en las bolsas 0 a 4 del personaje y en la ventana de botín de Blizzard (con signo de misión). Banco, banco de hermandad y vistas guardadas de otros personajes, sin marca.
- Tooltip con el motivo de la marca. Un item sin marca no suma líneas, salvo la de `keep` cuando lo marcaste a mano.
- Bolsas: Blizzard, Baganator (plugin de basura y widgets de esquina; se le pide refresco sólo cuando cambia el veredicto), BetterBags, AdiBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, Baggins, Bagnon, Bagnonium, ElvUI, BaudBag e Inventorian (refresco al abrir la ventana y botones reciclados sin marca vieja). Combuctor, OneBag3, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI y RealUI_Inventory tienen adaptador por nombre de ventana pero **hoy no muestran ninguna marca** hasta verificar en el juego el nombre de su ventana. El hook genérico sólo marca botones dentro de contenedores declarados (hoy, las ventanas de bolsas de Blizzard).
- `/knu junk`: on/off, coin/hammer/loot on/off, keep/sell/clear por enlace o ID de item y status. Alias `/knu kj`.
- Textos en inglés y castellano.
- Sin probar en el juego: ver `docs/prueba-bolsas.md`.

### Limitaciones conocidas

- Sin QuestieDB, un item que inicia una misión ya hecha lleva monedita aunque la misión sea repetible: sin Questie no se sabe (decisión del 2026-11-17).
- Misiones imposibles para tu raza o clase: no dan monedita (no implementado; nunca da una monedita falsa).
- Que `GetItemSpell` informe los efectos sólo de equipar no está verificado en Forever; si la API falta o falla, el item se trata como si tuviera efecto (sin monedita automática).
- Nombres de ventana de cargBags_Nivaya, LUI y RealUI_Inventory (existen para Forever): pendientes de verificar en el juego; hasta entonces, sin marcas.
- Baganator: sólo se reconocen las vistas de mochila de sus skins incluidas; con una skin de otro addon, la moneda nativa no aparece. Que el refresco con `ItemWidgets` actualice también su categoría de basura no está verificado en el juego.
- Pendientes menores que pueden esperar (revisión final, triage): conteos de reactivos sin filtrar y descargas sin pruebas en `tools/build_data.py`; costo del `__index` por nombre del diario; encabezados con títulos repetidos que se vuelven a plegar de más; profesiones por nombre sólo en castellano e inglés por la vía `GetSkillLineInfo`; sin línea de `/knu junk status` para «diario incompleto»; reactivos de clase y venenos de pícaro sin modelar (sólo faltan martillos, nunca dan moneda).

## Esqueleto

- Opciones guardadas en `KnuJunkDB` con valores por defecto, textos en inglés y castellano y mensajes de chat con el prefijo de KNU.
