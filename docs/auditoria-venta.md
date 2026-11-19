# Auditoría de venta

Build: `1.60.1.70959` (wowf).

Ítems: 32008. Con SellPrice > 0: 11967. Contextos evaluados: 1379349.

Nueve clases, niveles 10/30/60, sin profesiones, diario completo y vacío, misiones sin completar, sin QuestieDB, GearQuest ni Auctionator; reglas predeterminadas. Equipo ligado y sin ligar en pasadas separadas.

Precios en cobre. Nombres de ítems de Display_lang (idioma provisto por wago.tools). Efectos: TriggerType 0 (uso) y 1 (equipar), con SpellID positivo; otros disparadores no se consideran. Piezas de set por ItemSet. Sin fila ItemSparse, el ítem queda pendiente. Enlaces sin fila ItemEffect se tratan como efecto desconocido si no hay otro efecto confirmado. Los CSV completos conservan los encabezados originales; no se usan los datos filtrados de build_data.py.

La simulación usa efectos DB2, sin lectura del tooltip en el juego. No reproduce efectos que sólo aparezcan en ese tooltip, estado de recetas aprendidas, equipamiento guardado ni misiones de un personaje real.

## Resultado agregado

Moneda en todos los contextos: 1683. Guardado en todos: 10895. Basura en todos: 3383. Mixtos entre acciones: 3365. Pendientes: 12682.

| Marca final uniforme (mixto si cambia la marca) | Ítems |
| --- | ---: |
| coin | 1683 |
| hammer_other | 2446 |
| mixed | 3365 |
| pending | 12682 |
| trash | 3383 |
| useful | 8449 |

## Cobertura y encabezados verificados

| Tabla completa | Filas | Fuente |
| --- | ---: | --- |
| item | 32008 | [CSV de wago.tools](https://wago.tools/db2/item/csv?product=wowf&build=1.60.1.70959) |
| itemsparse | 19326 | [CSV de wago.tools](https://wago.tools/db2/itemsparse/csv?product=wowf&build=1.60.1.70959) |
| itemxitemeffect | 12682 | [CSV de wago.tools](https://wago.tools/db2/itemxitemeffect/csv?product=wowf&build=1.60.1.70959) |
| itemeffect | 12696 | [CSV de wago.tools](https://wago.tools/db2/itemeffect/csv?product=wowf&build=1.60.1.70959) |

`ItemSparse` trae `SellPrice`, `Display_lang`, `OverallQualityID`, `RequiredLevel`, `Bonding`, `StartQuestID`, `ItemSet` e `InventoryType`. `Item` trae `ID`, `ClassID` y `SubclassID`. `ItemXItemEffect` trae `ItemID` e `ItemEffectID`; `ItemEffect` trae `ID`, `SpellID` y `TriggerType`.

Filas Item sin ItemSparse: 12682; se conservan como pendientes. Filas ItemSparse sin Item: 0. Ítems referenciados con enlace a ItemEffect ausente: 167648; de ellos, 0 están en Item.

Nombres de clases y subclases traducidos de [ItemClass](https://wago.tools/db2/itemclass/csv?product=wowf&build=1.60.1.70959) e [ItemSubClass](https://wago.tools/db2/itemsubclass/csv?product=wowf&build=1.60.1.70959).

## Por clase y subclase

Categorías excluyentes: no_rule significa guardado en todos los contextos y sin regla en al menos uno. Mixto significa que cambia la acción (vender, guardar o tirar). Guardado por motivo excluye no_rule.

| Clase/subclase | Moneda | Guardado por motivo | no_rule | Basura | Mixto | Pendiente |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0/0 Consumible / Explosivo | 0 | 46 | 0 | 0 | 0 | 9 |
| 0/1 Consumible / Poción | 0 | 108 | 1 | 0 | 0 | 2 |
| 0/2 Consumible / Elixir | 0 | 83 | 0 | 0 | 0 | 2 |
| 0/3 Consumible / Frasco | 0 | 9 | 0 | 0 | 0 | 0 |
| 0/4 Consumible / Pergamino | 0 | 51 | 17 | 0 | 0 | 0 |
| 0/5 Consumible / Comida y bebida | 0 | 318 | 0 | 0 | 0 | 23 |
| 0/6 Consumible / Mejora permanente | 0 | 201 | 1 | 0 | 0 | 11 |
| 0/7 Consumible / Venda | 0 | 27 | 0 | 0 | 0 | 0 |
| 0/8 Consumible / Otro | 0 | 926 | 153 | 1 | 0 | 451 |
| 0/14 Consumible / Dispositivo | 0 | 32 | 2 | 0 | 0 | 5 |
| 0/15 Consumible / Mejora temporal | 0 | 3 | 0 | 0 | 0 | 1 |
| 1/0 Contenedor / Bolsa | 0 | 0 | 101 | 0 | 0 | 19 |
| 1/1 Contenedor / Bolsa de almas | 0 | 0 | 10 | 0 | 0 | 1 |
| 1/2 Contenedor / Herboristería | 0 | 0 | 5 | 0 | 0 | 0 |
| 1/3 Contenedor / Encantamiento | 0 | 0 | 3 | 0 | 0 | 0 |
| 1/6 Contenedor / Minería | 0 | 0 | 1 | 0 | 0 | 0 |
| 1/7 Contenedor / Peletería | 0 | 0 | 1 | 0 | 0 | 0 |
| 1/11 Contenedor / Bolsa de componentes | 0 | 0 | 10 | 0 | 0 | 1 |
| 1/12 Contenedor / Bolsa de abalorios | 0 | 0 | 0 | 0 | 0 | 4 |
| 2/0 Arma / Hacha de una mano | 56 | 2 | 0 | 0 | 70 | 123 |
| 2/1 Arma / Hacha de dos manos | 35 | 2 | 0 | 0 | 77 | 141 |
| 2/2 Arma / Arco | 21 | 0 | 0 | 1 | 73 | 95 |
| 2/3 Arma / Arma de fuego | 18 | 0 | 0 | 0 | 63 | 77 |
| 2/4 Arma / Maza de una mano | 75 | 4 | 0 | 3 | 119 | 221 |
| 2/5 Arma / Maza de dos manos | 45 | 1 | 0 | 0 | 76 | 159 |
| 2/6 Arma / Arma de asta | 28 | 0 | 0 | 0 | 31 | 86 |
| 2/7 Arma / Espada de una mano | 70 | 3 | 0 | 1 | 151 | 253 |
| 2/8 Arma / Espada de dos manos | 40 | 1 | 0 | 1 | 65 | 176 |
| 2/9 Arma / Guja | 2 | 0 | 0 | 0 | 0 | 0 |
| 2/10 Arma / Bastón | 79 | 0 | 0 | 1 | 124 | 216 |
| 2/11 Arma / Exótica de una mano | 0 | 0 | 0 | 0 | 0 | 2 |
| 2/13 Arma / Puño | 10 | 0 | 0 | 0 | 27 | 61 |
| 2/14 Arma / Miscelánea | 72 | 9 | 3 | 0 | 0 | 5 |
| 2/15 Arma / Daga | 39 | 3 | 0 | 0 | 144 | 270 |
| 2/16 Arma / Arrojadiza | 5 | 2 | 0 | 0 | 27 | 41 |
| 2/17 Arma / Lanza | 3 | 0 | 0 | 0 | 0 | 0 |
| 2/18 Arma / Ballesta | 4 | 0 | 0 | 0 | 12 | 35 |
| 2/19 Arma / Varita | 13 | 0 | 0 | 0 | 68 | 122 |
| 2/20 Arma / Caña de pescar | 0 | 6 | 0 | 0 | 0 | 3 |
| 4/0 Armadura / Miscelánea | 34 | 301 | 807 | 24 | 0 | 1149 |
| 4/1 Armadura / Tela | 183 | 303 | 1147 | 0 | 0 | 2586 |
| 4/2 Armadura / Cuero | 102 | 198 | 0 | 6 | 976 | 1947 |
| 4/3 Armadura / Malla | 96 | 191 | 0 | 1 | 742 | 1830 |
| 4/4 Armadura / Placas | 8 | 167 | 0 | 6 | 377 | 1274 |
| 4/5 Armadura / Cosmética | 0 | 1 | 120 | 1 | 0 | 11 |
| 4/6 Armadura / Escudo | 63 | 1 | 0 | 1 | 143 | 280 |
| 4/7 Armadura / Tratado | 0 | 17 | 1 | 0 | 0 | 22 |
| 4/8 Armadura / Ídolo | 0 | 22 | 0 | 0 | 0 | 23 |
| 4/9 Armadura / Tótem | 0 | 25 | 0 | 0 | 0 | 22 |
| 5/0 Componente / Componente | 0 | 41 | 5 | 0 | 0 | 4 |
| 6/2 Proyectil / Flecha | 0 | 1 | 14 | 0 | 0 | 5 |
| 6/3 Proyectil / Bala | 1 | 0 | 20 | 0 | 0 | 5 |
| 7/0 Material / Material | 0 | 0 | 3 | 0 | 0 | 1 |
| 7/1 Material / Pieza | 0 | 46 | 2 | 0 | 0 | 5 |
| 7/2 Material / Explosivo | 0 | 1 | 0 | 0 | 0 | 4 |
| 7/5 Material / Tela | 0 | 23 | 0 | 0 | 0 | 2 |
| 7/6 Material / Cuero | 0 | 62 | 1 | 0 | 0 | 5 |
| 7/7 Material / Metal y piedra | 1 | 48 | 6 | 0 | 0 | 8 |
| 7/8 Material / Cocina | 0 | 73 | 1 | 0 | 0 | 7 |
| 7/9 Material / Hierba | 0 | 42 | 1 | 0 | 0 | 2 |
| 7/10 Material / Elemental | 0 | 16 | 0 | 0 | 0 | 0 |
| 7/11 Material / Otro | 2 | 200 | 41 | 0 | 0 | 19 |
| 7/12 Material / Encantamiento | 0 | 39 | 3 | 0 | 0 | 0 |
| 9/0 Receta / Libro | 0 | 6 | 873 | 0 | 0 | 21 |
| 9/1 Receta / Peletería | 0 | 491 | 0 | 0 | 0 | 43 |
| 9/2 Receta / Sastrería | 0 | 356 | 0 | 0 | 0 | 27 |
| 9/3 Receta / Ingeniería | 0 | 168 | 0 | 0 | 0 | 36 |
| 9/4 Receta / Herrería | 0 | 376 | 0 | 0 | 0 | 50 |
| 9/5 Receta / Cocina | 0 | 120 | 0 | 0 | 0 | 8 |
| 9/6 Receta / Alquimia | 0 | 140 | 0 | 0 | 0 | 30 |
| 9/7 Receta / Primeros auxilios | 0 | 18 | 0 | 0 | 0 | 3 |
| 9/8 Receta / Encantamiento | 0 | 176 | 0 | 0 | 0 | 28 |
| 9/9 Receta / Pesca | 0 | 3 | 0 | 0 | 0 | 2 |
| 11/2 Carcaj / Carcaj | 0 | 12 | 2 | 0 | 0 | 14 |
| 11/3 Carcaj / Bolsa de munición | 0 | 9 | 0 | 0 | 0 | 4 |
| 12/0 Misión / Misión | 188 | 372 | 0 | 3319 | 0 | 189 |
| 13/0 Llave / Llave | 0 | 110 | 0 | 0 | 0 | 34 |
| 13/1 Llave / Ganzúa | 0 | 6 | 0 | 0 | 0 | 0 |
| 15/0 Misceláneo / Chatarra | 388 | 351 | 704 | 17 | 0 | 311 |
| 15/1 Misceláneo / Reactivo | 2 | 40 | 12 | 0 | 0 | 0 |
| 15/2 Misceláneo / Mascota | 0 | 73 | 0 | 0 | 0 | 19 |
| 15/3 Misceláneo / Festividad | 0 | 88 | 38 | 0 | 0 | 1 |
| 15/4 Misceláneo / Otro | 0 | 61 | 42 | 0 | 0 | 21 |
| 15/5 Misceláneo / Montura | 0 | 111 | 0 | 0 | 0 | 15 |
| 18/0 Ficha de WoW / Sin subclase declarada en ItemSubClass | 0 | 0 | 2 | 0 | 0 | 0 |

## Sin regla (no_rule)

Lista completa: 7333 ítems con ganador no_rule en al menos un contexto.

### 0/1 Consumible / Poción, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 23698 | [PH] Nature Resist Potion [DEP] | 1 | 0 | 1 | no | no |

### 0/4 Consumible / Pergamino, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 211780 | Scroll: KWYJIBO | 1 | 15 | 1 | no | no |
| 211784 | Scroll: WUBBA WUBBA | 1 | 15 | 1 | no | no |
| 211785 | Scroll: CWAL | 1 | 15 | 1 | no | no |
| 211786 | Scroll: CHAP BALK WELLES | 1 | 15 | 1 | no | no |
| 211787 | Scroll: LOWER PING WHOMEVER | 1 | 15 | 1 | no | no |
| 211853 | Scroll: VOCE WELL | 1 | 15 | 1 | no | no |
| 211854 | Scroll: OMIT KESA | 1 | 15 | 1 | no | no |
| 211855 | Scroll: STHENIC LUNATE | 1 | 15 | 1 | no | no |
| 213543 | Scroll: UPDOG | 1 | 15 | 1 | no | no |
| 213544 | Scroll: TOPAZ YORAK | 1 | 15 | 1 | no | no |
| 213545 | Scroll: PEATCHY ATTAX | 1 | 15 | 1 | no | no |
| 213546 | Scroll: SHOOBEEDOOP | 1 | 15 | 1 | no | no |
| 213547 | Scroll: THAW WORDS | 1 | 15 | 1 | no | no |
| 281015 | Scroll: DOST OREM | 1 | 15 | 1 | no | no |
| 281016 | Scroll: FORGOT HOOF THUD | 1 | 15 | 1 | no | no |
| 281017 | Scroll: KEEP CLEF FOCI | 1 | 15 | 1 | no | no |
| 281018 | Scroll: RARE SERVICHI RADAR | 1 | 15 | 1 | no | no |

### 0/6 Consumible / Mejora permanente, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 273455 | Template Vellum [DNT] | 1 | 0 | 1 | no | no |

### 0/8 Consumible / Otro, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 836 | Deprecated Heavy Net | 1 | 312 | 5 | no | no |
| 951 | Tome of Whirlwind (TEST) | 1 | 0 | 1 | no | no |
| 1128 | Deprecated [PH] Redridge Rye | 1 | 21 | 0 | no | no |
| 1199 | Charged Soulstone | 1 | 0 | 0 | no | no |
| 1269 | Deprecated Skin of Sweet Rum | 1 | 0 | 0 | no | no |
| 1533 | Deprecated Bloodscalp Idol | 1 | 62 | 27 | no | no |
| 1649 | Deprecated Ham Sandwich | 1 | 126 | 30 | no | no |
| 2688 | Squirrel Nut | 1 | 12 | 0 | no | no |
| 4842 | test | 1 | 0 | 0 | no | no |
| 5014 | Wrapping Paper (PT) | 1 | 0 | 0 | no | no |
| 5015 | Wrapped Item (PT) | 1 | 0 | 0 | no | no |
| 5041 | TEST Translation: Taurahe | 1 | 0 | 0 | no | no |
| 5042 | Red Ribboned Wrapping Paper | 1 | 12 | 0 | no | no |
| 5043 | Red Ribboned Gift | 1 | 0 | 0 | no | no |
| 5044 | Blue Ribboned Gift | 1 | 0 | 0 | no | no |
| 5045 | Skull Gift | 1 | 0 | 35 | no | no |
| 5047 | Skull Wrapping Paper | 1 | 1250 | 40 | no | no |
| 5048 | Blue Ribboned Wrapping Paper | 1 | 12 | 0 | no | no |
| 5049 | Self-locking Ironpaper | 1 | 12 | 0 | no | no |
| 5223 | Empty Mana Gem | 1 | 0 | 0 | no | no |
| 5227 | Empty Mana Jewel | 1 | 0 | 0 | no | no |
| 5228 | Deprecated Empty Bloodstone | 1 | 0 | 0 | no | no |
| 5229 | Empty Greater Bloodstone | 1 | 0 | 0 | no | no |
| 5378 | Shane Test (DELETE ME) | 1 | 1 | 1 | no | no |
| 5406 | Empty Minor Bloodstone | 1 | 0 | 0 | no | no |
| 5407 | Deprecated Empty Lesser Bloodstone | 1 | 0 | 0 | no | no |
| 6244 | ggggfg | 1 | 0 | 0 | no | no |
| 6464 | Wailing Essence | 1 | 0 | 0 | no | no |
| 6486 | Singed Scale | 1 | 0 | 0 | no | no |
| 6781 | Bartleby's Mug | 1 | 0 | 0 | no | no |
| 6782 | Marshal Haggard's Badge | 1 | 0 | 0 | no | no |
| 6812 | Case of Elunite | 1 | 0 | 0 | no | no |
| 6841 | Vial of Phlogiston | 1 | 0 | 0 | no | no |
| 6842 | Furen's Instructions | 1 | 0 | 0 | no | no |
| 6851 | Essence of the Exile | 1 | 0 | 0 | no | no |
| 6852 | Eternal Eye | 1 | 0 | 0 | no | no |
| 6926 | Furen's Notes | 1 | 0 | 0 | no | no |
| 6927 | Big Will's Ear | 1 | 0 | 0 | no | no |
| 6929 | Bath'rah's Parchment | 1 | 0 | 0 | no | no |
| 7127 | Powdered Azurite | 1 | 0 | 0 | no | no |
| 7227 | Balnir Snapdragons | 1 | 0 | 0 | no | no |
| 7266 | Ur's Treatise on Shadow Magic | 1 | 0 | 0 | no | no |
| 7516 | Tabetha's Instructions | 1 | 0 | 0 | no | no |
| 7627 | Dolanaar Delivery | 1 | 0 | 0 | no | no |
| 7629 | Ukor's Burden | 1 | 0 | 0 | no | no |
| 8048 | Emerald Dreamcatcher | 1 | 0 | 0 | no | no |
| 8164 | Test Stationery | 1 | 2 | 0 | no | no |
| 8548 | Divino-matic Rod | 1 | 0 | 0 | no | no |
| 9311 | Default Stationery | 1 | 0 | 0 | no | no |
| 9546 | Simple Scroll | 1 | 0 | 0 | no | no |
| 9569 | Hallowed Scroll | 1 | 0 | 0 | no | no |
| 11405 | Giant Silver Vein | 1 | 0 | 0 | no | no |
| 11413 | Nagmara's Filled Vial | 1 | 0 | 0 | no | no |
| 11443 | Deprecated Grim Guzzler Boar | 1 | 0 | 0 | no | no |
| 11616 | DEBUG Samophlange Manual Page | 1 | 0 | 0 | no | no |
| 12385 | test | 1 | 0 | 0 | no | no |
| 12533 | Roughshod Pike | 1 | 0 | 0 | no | no |
| 12712 | Warosh's Mojo | 1 | 0 | 0 | no | no |
| 12884 | Arnak's Hoof | 1 | 0 | 0 | no | no |
| 12885 | Pamela's Doll | 1 | 0 | 0 | no | no |
| 12894 | Joseph's Wedding Ring | 1 | 0 | 0 | no | no |
| 12924 | Ritual Candle | 1 | 0 | 0 | no | no |
| 13149 | Eldarathian Tome of Summoning Vol. 1 | 1 | 0 | 0 | no | no |
| 13151 | The Mystic Studies of Hor'ank | 1 | 0 | 0 | no | no |
| 13152 | The Story With No Conclusion | 1 | 0 | 0 | no | no |
| 13153 | Tome of Mal'cin Vorail | 1 | 0 | 0 | no | no |
| 13154 | Jael'marin's Studies of the Arcane | 1 | 0 | 0 | no | no |
| 13155 | Resonating Skull | 1 | 0 | 0 | no | no |
| 13562 | Remains of Trey Lightforge | 1 | 0 | 0 | no | no |
| 13703 | Kodo Bone | 1 | 0 | 0 | no | no |
| 13761 | Frozen Eggs | 1 | 0 | 0 | no | no |
| 14542 | Kravel's Crate | 1 | 0 | 0 | no | no |
| 15314 | Bundle of Relics | 1 | 0 | 0 | no | no |
| 16282 | Bundle of Hides | 1 | 0 | 0 | no | no |
| 17163 | Eric Test Item B | 1 | 0 | 1 | no | no |
| 17302 | Blue Ribboned Holiday Gift | 1 | 0 | 0 | no | no |
| 17303 | Blue Ribboned Wrapping Paper | 1 | 2 | 0 | no | no |
| 17304 | Green Ribboned Wrapping Paper | 1 | 2 | 0 | no | no |
| 17305 | Green Ribboned Holiday Gift | 1 | 0 | 0 | no | no |
| 17307 | Purple Ribboned Wrapping Paper | 1 | 2 | 0 | no | no |
| 17308 | Purple Ribboned Holiday Gift | 1 | 0 | 0 | no | no |
| 18105 | PVP TEST Alliance Ear | 1 | 0 | 0 | no | no |
| 18106 | PVP TEST Horde Ear | 1 | 0 | 0 | no | no |
| 18154 | Blizzard Stationery | 1 | 0 | 0 | no | no |
| 19150 | Sentinel Basic Care Package | 1 | 0 | 0 | no | no |
| 19151 | Sentinel Standard Care Package | 1 | 0 | 0 | no | no |
| 19152 | Sentinel Advanced Care Package | 1 | 0 | 0 | no | no |
| 19153 | Outrider Advanced Care Package | 1 | 0 | 0 | no | no |
| 19154 | Outrider Basic Care Package | 1 | 0 | 0 | no | no |
| 19155 | Outrider Standard Care Package | 1 | 0 | 0 | no | no |
| 20228 | Defiler's Advanced Care Package | 1 | 0 | 0 | no | no |
| 20229 | Defiler's Basic Care Package | 1 | 0 | 0 | no | no |
| 20230 | Defiler's Standard Care Package | 1 | 0 | 0 | no | no |
| 20231 | Arathor Advanced Care Package | 1 | 0 | 0 | no | no |
| 20233 | Arathor Basic Care Package | 1 | 0 | 0 | no | no |
| 20236 | Arathor Standard Care Package | 1 | 0 | 0 | no | no |
| 20337 | Gnome Head on a Stick | 1 | 85357 | 0 | no | no |
| 21140 | Auction Stationery | 1 | 0 | 0 | no | no |
| 21746 | Lucky Red Envelope | 1 | 0 | 0 | no | no |
| 21815 | Love Token | 1 | 0 | 0 | no | no |
| 22260 | Friendship Bracelet | 1 | 1 | 0 | no | no |
| 23224 | Summer Gift Package | 1 | 0 | 0 | no | no |
| 23245 | [PH] Everburning Elixir | 1 | 0 | 0 | no | no |
| 23656 | Promotion Test Item | 1 | 0 | 0 | no | no |
| 23699 | [PH] Light Consumable [DEP] | 1 | 0 | 1 | no | no |
| 23700 | [PH] Glorious Standard of the Alliance [DEP] | 1 | 0 | 1 | no | no |
| 23701 | [PH] Victorious Standard of the Horde [DEP] | 1 | 0 | 1 | no | no |
| 210138 | Dark Iron Ordinance | 1 | 0 | 1 | no | no |
| 210146 | Shredder Turbocharger | 1 | 0 | 1 | no | no |
| 213549 | Scroll of Arcane Angling | 1 | 37 | 12 | no | no |
| 213551 | Scroll of Controlled Displacement | 1 | 37 | 12 | no | no |
| 216491 | Shipment of Stranglethorn Lumber | 1 | 0 | 0 | no | no |
| 238681 | Dusty Bag | 1 | 0 | 60 | no | no |
| 239292 | Forgewright's Notes | 1 | 0 | 0 | no | no |
| 260236 | Scribbled Directions to Sulfur Vents | 1 | 0 | 1 | no | no |
| 276637 | Currency Wallet | 1 | 0 | 1 | no | no |
| 280567 | Small Sack of Gems | 1 | 0 | 1 | no | no |
| 285168 | Theramore Basic Care Package | 1 | 0 | 0 | no | no |
| 285169 | Theramore Standard Care Package | 1 | 0 | 0 | no | no |
| 285170 | Theramore Advanced Care Package | 1 | 0 | 0 | no | no |
| 285171 | Darkspear Basic Care Package | 1 | 0 | 0 | no | no |
| 285172 | Darkspear Standard Care Package | 1 | 0 | 0 | no | no |
| 285173 | Darkspear Advanced Care Package | 1 | 0 | 0 | no | no |

### 0/8 Consumible / Otro, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18595 | Blood Opal | 2 | 25000 | 0 | no | no |
| 19296 | Greater Darkmoon Prize | 2 | 250 | 45 | no | no |
| 19297 | Lesser Darkmoon Prize | 2 | 110 | 30 | no | no |
| 19298 | Minor Darkmoon Prize | 2 | 50 | 15 | no | no |
| 19425 | Mysterious Lockbox | 2 | 0 | 0 | no | no |
| 20558 | Warsong Gulch Mark of Honor | 2 | 0 | 0 | no | no |
| 20559 | Arathi Basin Mark of Honor | 2 | 0 | 0 | no | no |
| 20560 | Alterac Valley Mark of Honor | 2 | 0 | 0 | no | no |
| 191249 | Greater Deathstone | 2 | 0 | 1 | no | no |
| 217014 | Supply Bag | 2 | 0 | 0 | no | no |
| 220446 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 221491 | Shadowtooth Bag | 2 | 0 | 0 | no | no |
| 223148 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 223149 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 223150 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 223151 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 224836 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 224848 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 224849 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 224850 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 224851 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 228615 | Otherworldly Treasure | 2 | 0 | 0 | no | no |
| 237263 | Supply Bag | 2 | 0 | 0 | no | no |
| 242266 | World of Wardcraft | 2 | 0 | 1 | no | no |
| 242267 | From Arcanist to Archmage | 2 | 0 | 1 | no | no |
| 242268 | If You Give a Crusader an Enchant | 2 | 0 | 1 | no | no |
| 242363 | Who, What, Where, When, and Die! Five Keys to a Good Inquisition | 2 | 0 | 1 | no | no |
| 274895 | Darkspear Islands Mark of Honor | 2 | 0 | 0 | no | no |

### 0/8 Consumible / Otro, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 241613 | No Longer Used | 3 | 0 | 1 | no | no |

### 0/8 Consumible / Otro, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 191656 | Death's Essence | 4 | 0 | 1 | no | no |

### 0/14 Consumible / Dispositivo, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6715 | Ruined Jumper Cables | 1 | 21 | 0 | no | no |
| 18636 | Ruined Jumper Cables XL | 1 | 100 | 0 | no | no |

### 1/0 Contenedor / Bolsa, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 184 | Deprecated Small Brown Pouch | 1 | 125 | 0 | no | no |
| 804 | Large Blue Sack | 1 | 2500 | 0 | no | no |
| 805 | Small Red Pouch | 1 | 250 | 0 | no | no |
| 806 | Deprecated Brown Leather Satchel | 1 | 625 | 0 | no | no |
| 828 | Small Blue Pouch | 1 | 250 | 0 | no | no |
| 855 | Deprecated White Leather Satchel | 1 | 625 | 0 | no | no |
| 856 | Blue Leather Bag | 1 | 875 | 0 | no | no |
| 857 | Large Red Sack | 1 | 2500 | 0 | no | no |
| 918 | Deviate Hide Pack | 1 | 1250 | 0 | no | no |
| 930 | Deprecated Deep Pocket Pouch | 1 | 2500 | 0 | no | no |
| 931 | Deprecated Heavy Brown Sack | 1 | 2500 | 0 | no | no |
| 933 | Large Rucksack | 1 | 2500 | 0 | no | no |
| 965 | Deprecated Red Linen Sack | 1 | 75 | 0 | no | no |
| 1470 | Murloc Skin Bag | 1 | 875 | 0 | no | no |
| 1537 | Old Blanchy's Feed Pouch | 1 | 62 | 0 | no | no |
| 1623 | Raptor Skin Pouch | 1 | 5000 | 0 | no | no |
| 1652 | Sturdy Lunchbox | 1 | 5000 | 0 | no | no |
| 1685 | Troll-hide Bag | 1 | 6250 | 0 | no | no |
| 1724 | Deprecated Jungle Trail Pack | 1 | 2500 | 0 | no | no |
| 1725 | Large Knapsack | 1 | 5000 | 0 | no | no |
| 1729 | Gunnysack of the Night Watch | 1 | 500 | 0 | no | no |
| 1977 | 20-slot Bag | 1 | 0 | 0 | no | no |
| 2082 | Wizbang's Gunnysack | 1 | 250 | 0 | no | no |
| 2115 | Deprecated Small White Pouch | 1 | 125 | 0 | no | no |
| 2657 | Red Leather Bag | 1 | 875 | 0 | no | no |
| 3233 | Gnoll Hide Sack | 1 | 212 | 0 | no | no |
| 3298 | Deprecated Grizzled Bearskin Pouch | 1 | 75 | 0 | no | no |
| 3343 | Captain Sander's Booty Bag | 1 | 450 | 0 | no | no |
| 3352 | Ooze-covered Bag | 1 | 1250 | 0 | no | no |
| 3568 | Deprecated Oslow's Toolbox | 1 | 250 | 0 | no | no |
| 3762 | Librarian's Satchel | 1 | 1000 | 0 | no | no |
| 3914 | Journeyman's Backpack | 1 | 6250 | 0 | no | no |
| 4238 | Linen Bag | 1 | 200 | 0 | no | no |
| 4240 | Woolen Bag | 1 | 300 | 0 | no | no |
| 4241 | Green Woolen Bag | 1 | 450 | 0 | no | no |
| 4245 | Small Silk Pack | 1 | 2000 | 0 | no | no |
| 4496 | Small Brown Pouch | 1 | 125 | 0 | no | no |
| 4497 | Heavy Brown Bag | 1 | 5000 | 0 | no | no |
| 4498 | Brown Leather Satchel | 1 | 625 | 0 | no | no |
| 4499 | Huge Brown Sack | 1 | 25000 | 0 | no | no |
| 4501 | Deprecated Brown Wayfarer's Knapsack | 1 | 10000 | 0 | no | no |
| 4930 | Handmade Leather Bag | 1 | 250 | 0 | no | no |
| 4957 | Old Moneybag | 1 | 250 | 0 | no | no |
| 4981 | Agmond's Belt Pouch | 1 | 5000 | 0 | no | no |
| 5081 | Kodo Hide Bag | 1 | 250 | 0 | no | no |
| 5571 | Small Black Pouch | 1 | 250 | 0 | no | no |
| 5572 | Small Green Pouch | 1 | 250 | 0 | no | no |
| 5573 | Green Leather Bag | 1 | 875 | 0 | no | no |
| 5574 | White Leather Bag | 1 | 875 | 0 | no | no |
| 5575 | Large Green Sack | 1 | 2500 | 0 | no | no |
| 5576 | Large Brown Sack | 1 | 2500 | 0 | no | no |
| 5603 | Wizbang's Gunnysack | 1 | 300 | 0 | no | no |
| 5762 | Red Linen Bag | 1 | 250 | 0 | no | no |
| 5763 | Red Woolen Bag | 1 | 700 | 0 | no | no |
| 5764 | Green Silk Pack | 1 | 3000 | 0 | no | no |
| 5765 | Black Silk Pack | 1 | 4000 | 0 | no | no |
| 6754 | Large Moneybag | 1 | 500 | 0 | no | no |
| 6756 | Jewelry Box | 1 | 1375 | 0 | no | no |
| 9587 | Thawpelt Sack | 1 | 6250 | 0 | no | no |
| 10050 | Mageweave Bag | 1 | 2500 | 0 | no | no |
| 10051 | Red Mageweave Bag | 1 | 2500 | 0 | no | no |
| 10683 | Explorer's Knapsack | 1 | 8750 | 0 | no | no |
| 11324 | Explorer's Knapsack | 1 | 6250 | 0 | no | no |
| 11845 | Handmade Leather Bag | 1 | 62 | 0 | no | no |
| 13330 | Dereks Radish Bag | 1 | 0 | 1 | no | no |
| 14046 | Runecloth Bag | 1 | 5000 | 0 | no | no |
| 16057 | Explorer's Knapsack | 1 | 5000 | 0 | no | no |
| 19291 | Darkmoon Storage Box | 1 | 25000 | 0 | no | no |
| 23162 | A Very Large Bag | 1 | 0 | 1 | no | no |
| 221498 | Old Toolbox | 1 | 5000 | 0 | no | no |
| 253391 | Test Reagent Bag | 1 | 5000 | 0 | no | no |
| 256935 | Simple Leather Satchel | 1 | 250 | 0 | no | no |
| 260307 | Hyjal Postal Satchel | 1 | 5000 | 0 | no | no |
| 269504 | Smoking Satchel | 1 | 5000 | 0 | no | no |
| 277200 | Scorched Leather Pouch | 1 | 62 | 0 | no | no |
| 277332 | Scuffed Shipping Crate | 1 | 375 | 0 | no | no |
| 277845 | A Reasonably Large Bag | 1 | 0 | 1 | no | no |
| 277977 | Canvas Latchbag | 1 | 62 | 0 | no | no |
| 279936 | Book Bag | 1 | 62 | 0 | no | no |
| 279939 | Collecting Basket | 1 | 62 | 0 | no | no |
| 280088 | Soft Saber Sack | 1 | 62 | 0 | no | no |
| 282015 | Restored Small Brown Pouch | 1 | 1 | 0 | no | no |
| 282016 | Restored Brown Leather Satchel | 1 | 1 | 0 | no | no |
| 282017 | Restored Heavy Brown Bag | 1 | 1 | 0 | no | no |
| 287971 | Woolen Bag | 1 | 300 | 1 | no | no |

### 1/0 Contenedor / Bolsa, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4500 | Traveler's Backpack | 2 | 8750 | 0 | no | no |
| 10959 | Demon Hide Sack | 2 | 8750 | 0 | no | no |
| 14155 | Mooncloth Bag | 2 | 20000 | 0 | no | no |
| 17966 | Onyxia Hide Backpack | 2 | 8750 | 0 | no | no |
| 20400 | Pumpkin Bag | 2 | 20000 | 0 | no | no |
| 22233 | Zigris' Footlocker | 2 | 5837 | 0 | no | no |
| 262801 | Barkskin Satchel | 2 | 6575 | 0 | no | no |
| 267283 | Test Gear Bag | 2 | 10000 | 0 | no | no |
| 270017 | Hunting Satchel | 2 | 500 | 0 | no | no |
| 276891 | Spidersilk Pouch | 2 | 2500 | 0 | no | no |

### 1/0 Contenedor / Bolsa, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 14156 | Bottomless Bag | 3 | 40000 | 0 | no | no |
| 19914 | Panther Hide Sack | 3 | 8750 | 0 | no | no |
| 22679 | Supply Bag | 3 | 8750 | 0 | no | no |
| 227844 | Leather-Reinforced Runecloth Bag | 3 | 40000 | 0 | no | no |
| 239147 | Crusader's Knapsack | 3 | 0 | 1 | no | no |

### 1/0 Contenedor / Bolsa, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 239148 | Crimson Dawnwoven Bag | 4 | 0 | 1 | no | no |

### 1/1 Contenedor / Bolsa de almas, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21340 | Soul Pouch | 2 | 5000 | 0 | no | no |
| 22243 | Small Soul Pouch | 2 | 250 | 0 | no | no |
| 22244 | Box of Souls | 2 | 1000 | 0 | no | no |

### 1/1 Contenedor / Bolsa de almas, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21193 | D'Sak's Sack | 3 | 40000 | 0 | no | no |
| 21194 | D'Sak's Big Sack | 3 | 40000 | 0 | no | no |
| 21195 | D'Sak's Sacktastic | 3 | 40000 | 0 | no | no |
| 21313 | D'Sak's Small bag | 3 | 40000 | 0 | no | no |
| 21341 | Felcloth Bag | 3 | 20000 | 0 | no | no |

### 1/1 Contenedor / Bolsa de almas, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21342 | Core Felcloth Bag | 4 | 80000 | 0 | no | no |
| 279271 | Felblood Soul Bag | 4 | 80000 | 60 | no | no |

### 1/2 Contenedor / Herboristería, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 277113 | Apprentice's Herb Pouch | 1 | 6 | 0 | no | no |

### 1/2 Contenedor / Herboristería, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21857 | Test Herb Bag | 2 | 5000 | 0 | no | no |
| 22250 | Herb Pouch | 2 | 250 | 0 | no | no |
| 22251 | Cenarion Herb Bag | 2 | 10000 | 0 | no | no |
| 22252 | Satchel of Cenarius | 2 | 30000 | 0 | no | no |

### 1/3 Contenedor / Encantamiento, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 22246 | Enchanted Mageweave Pouch | 2 | 2500 | 0 | no | no |
| 22248 | Enchanted Runecloth Bag | 2 | 10000 | 0 | no | no |
| 22249 | Big Bag of Enchantment | 2 | 30000 | 0 | no | no |

### 1/6 Contenedor / Minería, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 277115 | Apprentice's Mining Pack | 1 | 6 | 0 | no | no |

### 1/7 Contenedor / Peletería, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 277114 | Apprentice's Skinning Satchel | 1 | 6 | 0 | no | no |

### 1/11 Contenedor / Bolsa de componentes, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 253664 | Linen Reagent Bag | 1 | 200 | 0 | no | no |
| 253667 | Woolen Reagent Bag | 1 | 1250 | 0 | no | no |
| 253973 | Silk Reagent Bag | 1 | 200 | 0 | no | no |
| 254035 | Mageweave Reagent Bag | 1 | 200 | 0 | no | no |
| 254079 | Runecloth Reagent Bag | 1 | 200 | 0 | no | no |
| 254133 | Mooncloth Reagent Bag | 1 | 200 | 0 | no | no |
| 254139 | Bottomless Reagent Bag | 1 | 200 | 0 | no | no |
| 277715 | Light Leather Reagent Bag | 1 | 100 | 0 | no | no |
| 282286 | Shipwright's Satchel | 1 | 200 | 0 | no | no |

### 1/11 Contenedor / Bolsa de componentes, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 276892 | Spidersilk Sack | 2 | 2500 | 0 | no | no |

### 2/0 Arma / Hacha de una mano, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 37 | Worn Axe | 1 | 7 | 1 | no | no |
| 768 | Lumberjack Axe | 1 | 113 | 4 | no | no |
| 778 | Kobold Excavation Pick | 1 | 55 | 2 | no | no |
| 853 | Hatchet | 1 | 481 | 11 | no | no |
| 927 | Double Axe | 1 | 1390 | 19 | no | no |
| 1011 | Sharp Axe | 1 | 80 | 0 | no | no |
| 1383 | Stone Tomahawk | 1 | 25 | 0 | no | no |
| 1719 | Deprecated Flint Troll Axe | 1 | 3 | 1 | no | no |
| 2029 | Cleaver | 1 | 883 | 15 | no | no |
| 2047 | Anvilmar Hand Axe | 1 | 25 | 0 | no | no |
| 2054 | Trogg Hand Axe | 1 | 16 | 1 | no | no |
| 2066 | Skull Hatchet | 1 | 81 | 3 | no | no |
| 2134 | Hand Axe | 1 | 16 | 1 | no | no |
| 2260 | Frostmane Hand Axe | 1 | 106 | 4 | no | no |
| 2482 | Inferior Tomahawk | 1 | 11 | 1 | no | no |
| 2490 | Tomahawk | 1 | 108 | 4 | no | no |
| 2498 | Small Tomahawk | 1 | 81 | 3 | no | no |
| 2522 | Crescent Axe | 1 | 4509 | 30 | no | no |
| 2530 | Francisca | 1 | 10443 | 41 | no | no |
| 2845 | Copper Axe | 1 | 109 | 4 | no | no |
| 3071 | Striking Hatchet | 1 | 231 | 0 | no | no |
| 3293 | Deadman Cleaver | 1 | 11 | 1 | no | no |
| 3443 | Ceremonial Tomahawk | 1 | 138 | 0 | no | no |
| 4923 | Primitive Hatchet | 1 | 25 | 0 | no | no |
| 4965 | Bloodhoof Hand Axe | 1 | 149 | 0 | no | no |

### 2/0 Arma / Hacha de una mano, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2044 | Crescent of Forlorn Spirits | 2 | 7357 | 0 | no | no |
| 2849 | Bronze Axe | 2 | 917 | 18 | no | no |
| 3154 | Thelsamar Axe | 2 | 1094 | 0 | no | no |
| 3489 | Thick War Axe | 2 | 715 | 12 | no | no |
| 3755 | Fish Gutter | 2 | 5447 | 0 | no | no |
| 4126 | Guerrilla Cleaver | 2 | 6396 | 0 | no | no |
| 4568 | Grunt Axe | 2 | 1694 | 16 | no | no |
| 4824 | Blurred Axe | 2 | 3371 | 22 | no | no |
| 4825 | Callous Axe | 2 | 4094 | 24 | no | no |
| 4826 | Marauder Axe | 2 | 3087 | 21 | no | no |
| 5344 | Pointed Axe | 2 | 562 | 0 | no | no |
| 5459 | Defender Axe | 2 | 472 | 0 | no | no |
| 6194 | Barreling Reaper | 2 | 5308 | 0 | no | no |
| 6738 | Bleeding Crescent | 2 | 7040 | 0 | no | no |
| 6966 | Elunite Axe | 2 | 693 | 0 | no | no |
| 6978 | Umbral Axe | 2 | 672 | 0 | no | no |
| 6979 | Haggard's Axe | 2 | 675 | 0 | no | no |
| 7115 | Heirloom Axe | 2 | 683 | 0 | no | no |
| 7326 | Thun'grim's Axe | 2 | 696 | 0 | no | no |
| 7941 | Heavy Mithril Axe | 2 | 12520 | 37 | no | no |
| 7942 | Blue Glittering Axe | 2 | 14659 | 39 | no | no |
| 9684 | Force of the Hippogryph | 2 | 25729 | 0 | no | no |
| 10744 | Axe of the Ebon Drake | 2 | 24159 | 0 | no | no |
| 12773 | Ornate Thorium Handaxe | 2 | 33079 | 50 | no | no |
| 15862 | Blitzcleaver | 2 | 28789 | 0 | no | no |
| 17002 | Ichor Spitter | 2 | 44825 | 0 | no | no |
| 17046 | Gutterblade | 2 | 4796 | 0 | no | no |
| 17704 | Edge of Winter | 2 | 9178 | 33 | no | no |
| 20723 | Brann's Trusty Pick | 2 | 46934 | 0 | no | no |
| 271664 | Hornbeam Heft | 2 | 16 | 0 | no | no |
| 274928 | Curly's Chopper | 2 | 11101 | 0 | no | no |
| 277288 | Pathfinder's Clearway | 2 | 0 | 1 | no | no |
| 281720 | Restored Chopper | 2 | 1 | 1 | no | no |

### 2/0 Arma / Hacha de una mano, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 12774 | Dawn's Edge | 3 | 36044 | 50 | no | no |
| 12798 | Annihilator | 3 | 57150 | 58 | no | no |
| 12990 | Razor's Edge | 3 | 2589 | 18 | no | no |
| 17016 | Dark Iron Destroyer | 3 | 63973 | 60 | no | no |
| 19103 | Frostbite | 3 | 63999 | 60 | no | no |
| 277243 | Silverbane Slicer | 3 | 0 | 40 | no | no |

### 2/0 Arma / Hacha de una mano, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18827 | Grand Marshal's Handaxe | 4 | 50048 | 60 | no | no |
| 18828 | High Warlord's Cleaver | 4 | 50225 | 60 | no | no |
| 21242 | Blessed Qiraji War Axe | 4 | 164024 | 60 | no | no |
| 272592 | Premier High Warlord's Cleaver | 4 | 0 | 60 | no | no |
| 272839 | Premier Grand Marshal's Handaxe | 4 | 0 | 60 | no | no |

### 2/0 Arma / Hacha de una mano, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3895 | TEST Legendary | 5 | 10287 | 25 | no | no |

### 2/1 Arma / Hacha de dos manos, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 926 | Battle Axe | 1 | 1956 | 20 | no | no |
| 1196 | Tabar | 1 | 442 | 9 | no | no |
| 1386 | Thistlewood Axe | 1 | 32 | 0 | no | no |
| 2025 | Bearded Axe | 1 | 1060 | 15 | no | no |
| 2479 | Broad Axe | 1 | 21 | 1 | no | no |
| 2483 | Rough Broad Axe | 1 | 14 | 1 | no | no |
| 2491 | Large Axe | 1 | 96 | 3 | no | no |
| 2499 | Double-bladed Axe | 1 | 143 | 4 | no | no |
| 2523 | Bullova | 1 | 5657 | 30 | no | no |
| 2531 | Great Axe | 1 | 11233 | 39 | no | no |
| 3189 | Wood Chopper | 1 | 99 | 3 | no | no |
| 3325 | Vile Fin Battle Axe | 1 | 140 | 4 | no | no |
| 5777 | Brave's Axe | 1 | 30 | 0 | no | no |
| 12282 | Worn Battleaxe | 1 | 8 | 1 | no | no |

### 2/1 Arma / Hacha de dos manos, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1893 | Miner's Revenge | 2 | 1775 | 0 | no | no |
| 2907 | Dwarven Tree Chopper | 2 | 1755 | 0 | no | no |
| 3488 | Copper Battle Axe | 2 | 480 | 8 | no | no |
| 3586 | Logsplitter | 2 | 1034 | 0 | no | no |
| 3855 | Massive Iron Axe | 2 | 11248 | 32 | no | no |
| 3856 | Shadow Crescent Axe | 2 | 10386 | 35 | no | no |
| 5318 | Zhovur Axe | 2 | 1789 | 0 | no | no |
| 5626 | Skullchipper | 2 | 1717 | 0 | no | no |
| 7958 | Bronze Battle Axe | 2 | 2435 | 22 | no | no |
| 9521 | Skullsplitter | 2 | 14382 | 0 | no | no |
| 9679 | Tok'kar's Murloc Chopper | 2 | 17550 | 0 | no | no |
| 9685 | Will of the Mountain Giant | 2 | 32277 | 46 | no | no |
| 10652 | Will of the Mountain Giant | 2 | 30308 | 0 | no | no |
| 11907 | Beastslayer | 2 | 41050 | 0 | no | no |
| 12249 | Merciless Axe | 2 | 6039 | 26 | no | no |
| 12250 | Midnight Axe | 2 | 8068 | 29 | no | no |
| 12775 | Huge Thorium Battleaxe | 2 | 39949 | 51 | no | no |
| 20238 | 90 Green Warrior Axe | 2 | 213369 | 60 | no | no |
| 20280 | 63 Green Warrior Axe | 2 | 57576 | 58 | no | no |
| 241090 | Scarlet Great Axe | 2 | 4443 | 23 | no | no |
| 250612 | Charged Mithril Battleaxe | 2 | 10273 | 43 | no | no |
| 251960 | Yngwe's Axe | 2 | 298 | 5 | no | no |
| 274929 | Hurley's Felling Axe | 2 | 13927 | 0 | no | no |
| 277286 | Encroacher's Claim | 2 | 0 | 1 | no | no |
| 281253 | Mountaineer's Greataxe | 2 | 0 | 0 | no | no |
| 281721 | Restored Cleaver | 2 | 1 | 1 | no | no |

### 2/1 Arma / Hacha de dos manos, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6975 | Whirlwind Axe | 3 | 16766 | 0 | no | no |
| 11607 | Dark Iron Sunderer | 3 | 51225 | 52 | no | no |
| 12769 | Bleakwood Hew | 3 | 46154 | 49 | no | no |
| 19184 | 3800 Test 2h Axe 63 blue | 3 | 74691 | 58 | no | no |
| 19185 | 2100 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19186 | 2700 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19187 | 3200 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19188 | 2200 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19189 | 2300 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19190 | 2400 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19191 | 2500 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19192 | 2600 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19193 | 2800 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19194 | 2900 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19195 | 3000 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19196 | 3100 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19197 | 3300 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19198 | 3400 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19199 | 3500 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19200 | 3600 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19201 | 3700 Test 2h Axe 63 blue | 3 | 68652 | 58 | no | no |
| 19809 | 2500 Test 2h Axe 60 blue | 3 | 59920 | 58 | no | no |
| 19811 | 2500 Test 2h Axe 60 blue (bear) | 3 | 59304 | 58 | no | no |
| 250617 | Stormcarver | 3 | 74598 | 58 | no | no |
| 271801 | Abandoned Ferocity | 3 | 18693 | 35 | no | no |
| 275824 | Wardcleaver | 3 | 0 | 1 | no | no |

### 2/1 Arma / Hacha de dos manos, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18830 | Grand Marshal's Sunderer | 4 | 57227 | 60 | no | no |
| 18831 | High Warlord's Battle Axe | 4 | 57448 | 60 | no | no |
| 19169 | Nightfall | 4 | 129112 | 60 | no | no |
| 19455 | 3500 Test 2h Axe 70 purple | 4 | 132637 | 60 | no | no |
| 19662 | 3500 Test 2h Axe 80 purple | 4 | 209804 | 60 | no | no |
| 20149 | 90 Epic Warrior Axe | 4 | 346622 | 60 | no | no |
| 21134 | Dark Edge of Insanity | 4 | 266569 | 60 | no | no |
| 272593 | Premier High Warlord's Battle Axe | 4 | 0 | 60 | no | no |
| 272840 | Premier Grand Marshal's Sunderer | 4 | 0 | 60 | no | no |
| 279260 | Forest Defender's Axe | 4 | 5062 | 60 | no | no |

### 2/2 Arma / Arco, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2504 | Worn Shortbow | 1 | 5 | 1 | no | no |
| 2505 | Polished Shortbow | 1 | 12 | 1 | no | no |
| 2506 | Hornwood Recurve Bow | 1 | 57 | 3 | no | no |
| 2507 | Laminated Recurve Bow | 1 | 350 | 11 | no | no |
| 3026 | Reinforced Bow | 1 | 762 | 16 | no | no |
| 3027 | Heavy Recurve Bow | 1 | 1269 | 20 | no | no |
| 3028 | Longbow | 1 | 3086 | 29 | no | no |
| 4931 | Hickory Shortbow | 1 | 134 | 0 | no | no |
| 5596 | Ashwood Bow | 1 | 141 | 0 | no | no |
| 8179 | Cadet's Bow | 1 | 28 | 1 | no | no |
| 12447 | Thistlewood Bow | 1 | 19 | 0 | no | no |
| 12449 | Primitive Bow | 1 | 19 | 0 | no | no |
| 14394 | Durability Bow | 1 | 2 | 0 | no | no |
| 273877 | Windswept Shortbow | 1 | 141 | 0 | no | no |
| 273879 | Refined Shortbow | 1 | 141 | 0 | no | no |
| 276686 | Junior's Hunting Bow | 1 | 374 | 0 | no | no |
| 277110 | Zephrali Bow | 1 | 269 | 9 | no | no |
| 282719 | Monster - Bow, Skyborne (Gray) | 1 | 1 | 1 | no | no |

### 2/2 Arma / Arco, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2903 | Daryl's Hunting Bow | 2 | 515 | 0 | no | no |
| 3493 | Raptor's End | 2 | 3426 | 0 | no | no |
| 3742 | Bow of Plunder | 2 | 2862 | 0 | no | no |
| 4110 | Master Hunter's Bow | 2 | 11999 | 0 | no | no |
| 4763 | Blackwood Recurve Bow | 2 | 135 | 4 | no | no |
| 5346 | Orcish Battle Bow | 2 | 425 | 0 | no | no |
| 5817 | Lunaris Bow | 2 | 3226 | 0 | no | no |
| 6739 | Cliffrunner's Aim | 2 | 2991 | 0 | no | no |
| 11303 | Fine Shortbow | 2 | 636 | 11 | no | no |
| 11304 | Fine Longbow | 2 | 972 | 14 | no | no |
| 11305 | Dense Shortbow | 2 | 5162 | 30 | no | no |
| 11306 | Sturdy Recurve | 2 | 3893 | 27 | no | no |
| 11307 | Massive Longbow | 2 | 13590 | 42 | no | no |
| 11308 | Sylvan Shortbow | 2 | 15765 | 44 | no | no |
| 16622 | Thornflinger | 2 | 27307 | 0 | no | no |
| 17686 | Master Hunter's Bow | 2 | 9937 | 0 | no | no |
| 19114 | Highland Bow | 2 | 17887 | 0 | no | no |
| 20299 | 90 Green Rogue Bow | 2 | 128465 | 60 | no | no |
| 20313 | 63 Green Rogue Bow | 2 | 37212 | 58 | no | no |
| 20646 | Sandstrider's Mark | 2 | 29963 | 0 | no | no |
| 217315 | Precision Bow | 2 | 2426 | 23 | no | no |
| 263404 | Bow of Hours | 2 | 141 | 0 | no | no |
| 270107 | Bloodstained Longbow | 2 | 19591 | 0 | no | no |
| 275439 | Blunderflame Bone Bow | 2 | 30469 | 0 | no | no |
| 275441 | Cremation Longbow | 2 | 30689 | 0 | no | no |
| 276685 | Militia Bow | 2 | 264 | 0 | no | no |
| 276695 | Harvester's Pestslayer | 2 | 1269 | 0 | no | no |
| 276902 | Youngster's First Bow | 2 | 0 | 1 | no | no |
| 281264 | Ghastly Bow | 2 | 0 | 0 | no | no |
| 281732 | Restored Bow | 2 | 1 | 1 | no | no |

### 2/2 Arma / Arco, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 16996 | Gorewood Bow | 3 | 41451 | 0 | no | no |
| 19490 | 2800 Test Bow 63 Blue | 3 | 41191 | 60 | no | no |
| 19558 | Outrider's Bow | 3 | 44011 | 58 | no | no |
| 19559 | Outrider's Bow | 3 | 24117 | 48 | no | no |
| 19560 | Outrider's Bow | 3 | 11924 | 38 | no | no |
| 19561 | Outrider's Bow | 3 | 5132 | 28 | no | no |
| 19562 | Outrunner's Bow | 3 | 41191 | 58 | no | no |
| 19563 | Outrunner's Bow | 3 | 24117 | 48 | no | no |
| 19564 | Outrunner's Bow | 3 | 11924 | 38 | no | no |
| 19565 | Outrunner's Bow | 3 | 5132 | 28 | no | no |
| 19966 | Thrice Strung Longbow DEPRECATED | 3 | 55377 | 60 | no | no |
| 20368 | Bland Bow of Steadiness | 3 | 35582 | 60 | no | no |
| 20437 | Outrider's Bow | 3 | 1825 | 18 | no | no |
| 20438 | Outrunner's Bow | 3 | 1825 | 18 | no | no |
| 277254 | Truthseeker's Bow | 3 | 0 | 40 | no | no |

### 2/2 Arma / Arco, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18713 | Rhok'delar, Longbow of the Ancient Keepers | 4 | 0 | 60 | no | no |
| 18833 | Grand Marshal's Bullseye | 4 | 34731 | 60 | no | no |
| 18835 | High Warlord's Recurve | 4 | 34997 | 60 | no | no |
| 19868 | Mandokir's Sting DEPRECATED | 4 | 65739 | 60 | no | no |
| 20278 | 90 Epic Rogue Bow | 4 | 204791 | 60 | no | no |
| 20488 | Rhok'delar, Longbow of the Ancient Keepers DEP | 4 | 0 | 60 | no | no |
| 21616 | Huhuran's Stinger | 4 | 114921 | 60 | no | no |
| 272594 | Premier High Warlord's Recurve | 4 | 0 | 60 | no | no |
| 272841 | Premier Grand Marshal's Bullseye | 4 | 0 | 60 | no | no |
| 289303 | Rhok'delar, Longbow of the Ancient Keepers | 4 | 0 | 1 | no | no |

### 2/3 Arma / Arma de fuego, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1046 | Deprecated Light Blunderbuss | 1 | 2 | 1 | no | no |
| 1047 | Deprecated Heavy Blunderbuss | 1 | 2 | 1 | no | no |
| 2508 | Old Blunderbuss | 1 | 5 | 1 | no | no |
| 2509 | Ornate Blunderbuss | 1 | 82 | 4 | no | no |
| 2510 | Solid Blunderbuss | 1 | 8 | 1 | no | no |
| 2511 | Hunter's Boomstick | 1 | 264 | 9 | no | no |
| 3023 | Large Bore Blunderbuss | 1 | 754 | 16 | no | no |
| 3024 | BKP 2700 "Enforcer" | 1 | 1419 | 21 | no | no |
| 3025 | BKP 42 "Ultra" | 1 | 3695 | 31 | no | no |
| 8181 | Hunting Rifle | 1 | 79 | 4 | no | no |
| 8182 | Pellet Rifle | 1 | 40 | 2 | no | no |
| 12446 | Anvilmar Musket | 1 | 19 | 0 | no | no |
| 12448 | Light Hunting Rifle | 1 | 19 | 0 | no | no |
| 240994 | Tim's Test Ranged Weapon 2 | 1 | 5 | 1 | no | no |

### 2/3 Arma / Arma de fuego, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2904 | Daryl's Hunting Rifle | 2 | 595 | 0 | no | no |
| 3041 | "Mage-Eye" Blunderbuss | 2 | 3769 | 26 | no | no |
| 3079 | Skorn's Rifle | 2 | 297 | 0 | no | no |
| 3567 | Dwarven Fishing Pole | 2 | 922 | 0 | no | no |
| 4086 | Flash Rifle | 2 | 6386 | 0 | no | no |
| 4111 | Master Hunter's Rifle | 2 | 12042 | 0 | no | no |
| 4127 | Shrapnel Blaster | 2 | 8073 | 0 | no | no |
| 4362 | Rough Boomstick | 2 | 187 | 5 | no | no |
| 4369 | Deadly Blunderbuss | 2 | 790 | 16 | no | no |
| 4372 | Lovingly Crafted Boomstick | 2 | 1800 | 19 | no | no |
| 4379 | Silver-plated Shotgun | 2 | 2357 | 21 | no | no |
| 4383 | Moonsight Rifle | 2 | 3183 | 24 | no | no |
| 5309 | Privateer Musket | 2 | 1038 | 0 | no | no |
| 6798 | Blasting Hackbut | 2 | 6386 | 0 | no | no |
| 10508 | Mithril Blunderbuss | 2 | 8958 | 36 | no | no |
| 10510 | Mithril Heavy-bore Rifle | 2 | 11369 | 39 | no | no |
| 13474 | Farmer Dalson's Shotgun | 2 | 24724 | 0 | no | no |
| 15205 | Owlsight Rifle | 2 | 1063 | 0 | no | no |
| 15324 | Burnside Rifle | 2 | 25565 | 51 | no | no |
| 15691 | Sidegunner Shottie | 2 | 6909 | 0 | no | no |
| 15995 | Thorium Rifle | 2 | 19739 | 47 | no | no |
| 16992 | Smokey's Explosive Launcher | 2 | 30874 | 0 | no | no |
| 17687 | Master Hunter's Rifle | 2 | 9937 | 0 | no | no |
| 18763 | TEST GUN Alliance20  | 2 | 19966 | 47 | no | no |
| 18764 | TEST GUN Raid | 2 | 20039 | 47 | no | no |
| 18765 | TEST GUN Horde50 | 2 | 20113 | 47 | no | no |
| 20245 | 90 Green Warrior Gun | 2 | 131474 | 60 | no | no |
| 20285 | 63 Green Warrior Gun | 2 | 36161 | 58 | no | no |
| 217314 | Moonsight Rifle | 2 | 3183 | 23 | no | no |
| 259891 | Berdun's Trusty Rifle | 2 | 11026 | 45 | no | no |
| 269742 | Walton's Second-Favorite Gun | 2 | 1179 | 0 | no | no |
| 275296 | Deadwood Boomstick | 2 | 4729 | 0 | no | no |
| 276694 | Captain Sander's Lucky Shooter | 2 | 187 | 0 | no | no |
| 277255 | Misplaced Shooter | 2 | 0 | 0 | no | no |
| 290333 | Berdun's Trusty Rifle | 2 | 11026 | 0 | no | no |

### 2/3 Arma / Arma de fuego, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 16004 | Dark Iron Rifle | 3 | 29152 | 50 | no | no |
| 16007 | Flawless Arcanite Rifle | 3 | 40625 | 56 | no | no |
| 274748 | Booty Bay Bruiser's Buckshot | 3 | 6217 | 30 | no | no |

### 2/3 Arma / Arma de fuego, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18282 | Core Marksman Rifle | 4 | 66347 | 60 | no | no |
| 18855 | Grand Marshal's Hand Cannon | 4 | 35945 | 60 | no | no |
| 18860 | High Warlord's Street Sweeper | 4 | 36602 | 60 | no | no |
| 20146 | 90 Epic Warrior Gun | 4 | 205608 | 60 | no | no |
| 21272 | Blessed Qiraji Musket | 4 | 130949 | 60 | no | no |
| 22656 | The Purifier | 4 | 47443 | 0 | no | no |
| 23557 | Larvae of the Great Worm | 4 | 132177 | 60 | no | no |
| 272599 | Premier High Warlord's Street Sweeper | 4 | 0 | 60 | no | no |
| 272846 | Premier Grand Marshal's Hand Cannon | 4 | 0 | 60 | no | no |
| 279273 | Hyper Deluxe Sniper Rifle Mk XVII | 4 | 66347 | 60 | no | no |

### 2/4 Arma / Maza de una mano, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 36 | Worn Mace | 1 | 7 | 1 | no | no |
| 766 | Flanged Mace | 1 | 57 | 2 | no | no |
| 781 | Stone Gnoll Hammer | 1 | 110 | 4 | no | no |
| 852 | Mace | 1 | 347 | 9 | no | no |
| 925 | Flail | 1 | 1559 | 20 | no | no |
| 1158 | Solid Metal Club | 1 | 146 | 0 | no | no |
| 1382 | Rock Mace | 1 | 24 | 0 | no | no |
| 1389 | Kobold Mining Mallet | 1 | 58 | 2 | no | no |
| 2028 | Hammer | 1 | 1013 | 16 | no | no |
| 2048 | Anvilmar Hammer | 1 | 25 | 0 | no | no |
| 2055 | Small Wooden Hammer | 1 | 16 | 1 | no | no |
| 2064 | Trogg Club | 1 | 191 | 6 | no | no |
| 2130 | Club | 1 | 10 | 1 | no | no |
| 2259 | Frostmane Club | 1 | 75 | 3 | no | no |
| 2485 | Splintered Board | 1 | 10 | 1 | no | no |
| 2492 | Cudgel | 1 | 56 | 2 | no | no |
| 2500 | Light Hammer | 1 | 58 | 2 | no | no |
| 2524 | Truncheon | 1 | 3838 | 29 | no | no |
| 2532 | Morning Star | 1 | 10521 | 41 | no | no |
| 2844 | Copper Mace | 1 | 106 | 4 | no | no |
| 3262 | Putrid Wooden Hammer | 1 | 10 | 1 | no | no |
| 3269 | Forsaken Maul | 1 | 25 | 0 | no | no |
| 3294 | Deadman Club | 1 | 11 | 1 | no | no |
| 3329 | Spiked Wooden Plank | 1 | 179 | 6 | no | no |
| 4563 | Billy Club | 1 | 110 | 4 | no | no |
| 4924 | Primitive Club | 1 | 25 | 0 | no | no |
| 5580 | Militia Hammer | 1 | 25 | 0 | no | no |
| 6651 | Broken Wine Bottle | 1 | 234 | 7 | no | no |
| 10544 | Thistlewood Maul | 1 | 25 | 0 | no | no |
| 19292 | Last Month's Mutton | 1 | 4022 | 29 | no | no |
| 19293 | Last Year's Mutton | 1 | 19376 | 50 | no | no |
| 257276 | Peacekeeper's Pickhammer | 1 | 25 | 0 | no | no |
| 257337 | Solid Copper Club | 1 | 146 | 0 | no | no |
| 277107 | Zephrali Bludgeon | 1 | 345 | 9 | no | no |
| 280400 | Worn Bludgeon | 1 | 7 | 1 | no | no |

### 2/4 Arma / Maza de una mano, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1009 | Compact Hammer | 2 | 490 | 0 | no | no |
| 1480 | Fist of the People's Militia | 2 | 954 | 0 | no | no |
| 1913 | Studded Blackjack | 2 | 148 | 7 | no | no |
| 2848 | Bronze Mace | 2 | 898 | 17 | no | no |
| 3491 | Heavy Bronze Mace | 2 | 2741 | 20 | no | no |
| 3492 | Mighty Iron Hammer | 2 | 4552 | 25 | no | no |
| 3570 | Bonegrinding Pestle | 2 | 839 | 0 | no | no |
| 4122 | Bookmaker's Scepter | 2 | 8384 | 0 | no | no |
| 4511 | Black Water Hammer | 2 | 11256 | 0 | no | no |
| 4948 | Stinging Mace | 2 | 326 | 0 | no | no |
| 4971 | Skorn's Hammer | 2 | 383 | 0 | no | no |
| 4978 | Ryedol's Hammer | 2 | 7976 | 0 | no | no |
| 5324 | Engineer's Hammer | 2 | 776 | 0 | no | no |
| 5541 | Iridescent Hammer | 2 | 3693 | 23 | no | no |
| 5587 | Thornroot Club | 2 | 512 | 0 | no | no |
| 5757 | Hardwood Cudgel | 2 | 1363 | 0 | no | no |
| 6360 | Steelscale Crushfish | 2 | 2581 | 20 | no | no |
| 6968 | Elunite Hammer | 2 | 698 | 0 | no | no |
| 6982 | Umbral Mace | 2 | 683 | 0 | no | no |
| 6983 | Haggard's Hammer | 2 | 685 | 0 | no | no |
| 7117 | Heirloom Hammer | 2 | 688 | 0 | no | no |
| 7328 | Thun'grim's Mace | 2 | 701 | 0 | no | no |
| 7945 | Big Black Mace | 2 | 17291 | 41 | no | no |
| 7946 | Runed Mithril Hammer | 2 | 14460 | 44 | no | no |
| 9651 | Gryphon Rider's Stormhammer | 2 | 26828 | 0 | no | no |
| 9686 | Spirit of the Faerie Dragon | 2 | 25914 | 0 | no | no |
| 11120 | Belgrom's Hammer | 2 | 30144 | 0 | no | no |
| 11906 | Beastsmasher | 2 | 32723 | 0 | no | no |
| 12792 | Volcanic Hammer | 2 | 39255 | 53 | no | no |
| 15224 | Battlesmasher | 2 | 2695 | 20 | no | no |
| 15863 | Grave Scepter | 2 | 28896 | 0 | no | no |
| 16769 | Furbolg Medicine Totem | 2 | 26616 | 47 | no | no |
| 16792 | Giant Club | 2 | 8886 | 32 | no | no |
| 17003 | Skullstone Hammer | 2 | 44982 | 0 | no | no |
| 246164 | Skullthumper | 2 | 326 | 0 | no | no |
| 250606 | Iron Morningstar | 2 | 9416 | 33 | no | no |
| 260209 | Truesong's Hammer | 2 | 30144 | 0 | no | no |
| 263313 | Trusty Wrench | 2 | 3 | 0 | no | no |
| 263314 | Roofing Hammer | 2 | 25 | 0 | no | no |
| 263329 | Flutterfly Swatter | 2 | 3 | 0 | no | no |
| 270048 | Uthil's Cudgel | 2 | 5096 | 0 | no | no |
| 270088 | Thane's Hammer | 2 | 13877 | 0 | no | no |
| 275293 | Barkskin Scepter | 2 | 38673 | 0 | no | no |
| 275698 | Yaely's Mending Tool | 2 | 37714 | 0 | no | no |
| 275700 | Glaive Thrower Muffler | 2 | 37992 | 0 | no | no |
| 277247 | Mug of Muddled Memories | 2 | 0 | 0 | no | no |
| 277979 | Mauler's Mutton | 2 | 0 | 1 | no | no |
| 278002 | Valley Cosh | 2 | 326 | 0 | no | no |
| 281254 | Invader's Mace | 2 | 0 | 0 | no | no |
| 281723 | Restored Basher | 2 | 1 | 1 | no | no |

### 2/4 Arma / Maza de una mano, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2194 | Diamond Hammer | 3 | 3276 | 20 | no | no |
| 7954 | The Shatterer | 3 | 23159 | 42 | no | no |
| 12781 | Serenity | 3 | 42721 | 52 | no | no |
| 17733 | Fist of Stone | 3 | 34735 | 48 | no | no |
| 19104 | Stormstrike Hammer | 3 | 64227 | 60 | no | no |
| 20648 | Cold Forged Hammer | 3 | 58693 | 0 | no | no |
| 22380 | Simone's Cultivating Hammer | 3 | 65675 | 0 | no | no |
| 271802 | Bludgeon of Betrayed Virtues | 3 | 15012 | 35 | no | no |
| 271804 | Soulsplatter Mace | 3 | 15126 | 35 | no | no |
| 274744 | Barrens Basher | 3 | 3303 | 20 | no | no |
| 277245 | Swampspine Crusher | 3 | 0 | 40 | no | no |
| 281586 | Elderwild Construction Hammer | 3 | 0 | 1 | no | no |

### 2/4 Arma / Maza de una mano, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 810 | Hammer of the Northern Wind | 4 | 45267 | 49 | no | no |
| 8708 | Hammer of Expertise | 4 | 0 | 40 | no | no |
| 18800 | TEST 1H Amberseal Keeper | 4 | 92678 | 60 | no | no |
| 18865 | Grand Marshal's Punisher | 4 | 49684 | 60 | no | no |
| 18866 | High Warlord's Bludgeon | 4 | 49861 | 60 | no | no |
| 19170 | Ebon Hand | 4 | 103689 | 60 | no | no |
| 20580 | Hammer of Bestial Fury | 4 | 109327 | 60 | no | no |
| 21127 | Ahn'Qiraj Mace [PH] | 4 | 133922 | 60 | no | no |
| 21268 | Blessed Qiraji War Hammer | 4 | 172135 | 60 | no | no |
| 21839 | Scepter of the False Prophet | 4 | 224399 | 60 | no | no |
| 22384 | Persuader | 4 | 80554 | 58 | no | no |
| 23454 | Grand Marshal's Warhammer | 4 | 45671 | 60 | no | no |
| 23464 | High Warlord's Battle Mace | 4 | 45671 | 60 | no | no |
| 272600 | Premier High Warlord's Bludgeon | 4 | 0 | 60 | no | no |
| 272681 | Premier High Warlord's Battle Mace | 4 | 0 | 60 | no | no |
| 272847 | Premier Grand Marshal's Punisher | 4 | 0 | 60 | no | no |
| 272857 | Premier Grand Marshal's Warhammer | 4 | 0 | 60 | no | no |
| 279261 | Greenhammer | 4 | 53222 | 60 | no | no |
| 289292 | Hammer of Bestial Fury | 4 | 109327 | 1 | no | no |

### 2/5 Arma / Maza de dos manos, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 924 | Maul | 1 | 2194 | 21 | no | no |
| 1195 | Kobold Mining Shovel | 1 | 47 | 3 | no | no |
| 1197 | Giant Mace | 1 | 533 | 10 | no | no |
| 2026 | Rock Hammer | 1 | 1257 | 16 | no | no |
| 2361 | Battleworn Hammer | 1 | 9 | 1 | no | no |
| 2480 | Large Club | 1 | 14 | 1 | no | no |
| 2486 | Large Stone Mace | 1 | 13 | 1 | no | no |
| 2493 | Wooden Mallet | 1 | 140 | 4 | no | no |
| 2501 | Wooden Warhammer | 1 | 144 | 4 | no | no |
| 2525 | War Hammer | 1 | 5297 | 30 | no | no |
| 2533 | War Maul | 1 | 12221 | 40 | no | no |
| 2814 | Deprecated Lightforge Hammer | 1 | 3104 | 0 | no | no |
| 3190 | Beatstick | 1 | 99 | 3 | no | no |
| 4943 | Torka's Egg Cracker [UNUSED] | 1 | 101 | 0 | no | no |
| 5579 | Militia Warhammer | 1 | 32 | 0 | no | no |
| 5595 | Thicket Hammer | 1 | 235 | 0 | no | no |
| 5761 | Anvilmar Sledge | 1 | 30 | 0 | no | no |
| 277106 | Zephrali Smasher | 1 | 430 | 9 | no | no |

### 2/5 Arma / Maza de dos manos, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3103 | Coldridge Hammer | 2 | 466 | 0 | no | no |
| 3440 | Bonecracker | 2 | 640 | 0 | no | no |
| 3851 | Solid Iron Maul | 2 | 6258 | 26 | no | no |
| 3852 | Golden Iron Destroyer | 2 | 8360 | 29 | no | no |
| 4128 | Silver Spade | 2 | 14587 | 0 | no | no |
| 4548 | Servomechanic Sledgehammer | 2 | 15028 | 0 | no | no |
| 4777 | Ironwood Maul | 2 | 1408 | 13 | no | no |
| 4778 | Heavy Spiked Mace | 2 | 1470 | 14 | no | no |
| 4964 | Goblin Smasher | 2 | 503 | 0 | no | no |
| 4983 | Rock Pulverizer | 2 | 16837 | 0 | no | no |
| 5322 | Demolition Hammer | 2 | 4016 | 0 | no | no |
| 5345 | Stonewood Hammer | 2 | 705 | 0 | no | no |
| 5815 | Glacial Stone | 2 | 5871 | 0 | no | no |
| 6093 | Orc Crusher | 2 | 4418 | 0 | no | no |
| 6214 | Heavy Copper Maul | 2 | 466 | 11 | no | no |
| 7956 | Bronze Warhammer | 2 | 1544 | 20 | no | no |
| 9678 | Tok'kar's Murloc Basher | 2 | 17485 | 0 | no | no |
| 12772 | Inlaid Thorium Hammer | 2 | 38871 | 49 | no | no |
| 15464 | Brute Hammer | 2 | 4504 | 0 | no | no |
| 246165 | Driftwood Smasher | 2 | 235 | 0 | no | no |
| 248005 | Northshire Hammer | 2 | 466 | 0 | no | no |
| 250608 | Mithril Warhammer | 2 | 4356 | 38 | no | no |
| 257345 | Honed Greathammer | 2 | 235 | 0 | no | no |
| 260166 | Rageroar's Best Club | 2 | 37833 | 0 | no | no |
| 263312 | Planting Shovel | 2 | 68 | 0 | no | no |
| 270071 | Dark Hearted Hammer | 2 | 13530 | 0 | no | no |
| 270108 | Bloodied Longmace | 2 | 28889 | 0 | no | no |
| 271667 | Ironwood Destroyer | 2 | 6340 | 0 | no | no |
| 276887 | Big Bad Basher | 2 | 0 | 1 | no | no |
| 281724 | Restored Smasher | 2 | 1 | 1 | no | no |

### 2/5 Arma / Maza de dos manos, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6953 | Verigan's Fist | 3 | 7459 | 0 | no | no |
| 6976 | Whirlwind Warhammer | 3 | 17264 | 0 | no | no |
| 11265 | Cragwood Maul | 3 | 16484 | 0 | no | no |
| 11608 | Dark Iron Pulverizer | 3 | 45760 | 50 | no | no |
| 12776 | Enchanted Battlehammer | 3 | 48124 | 51 | no | no |
| 22348 | Doomulus Prime | 3 | 76507 | 0 | no | no |
| 221518 | Whisper | 3 | 44863 | 0 | no | no |
| 250613 | Thorium Greatmace | 3 | 48384 | 50 | no | no |
| 271766 | Heavehammer | 3 | 3103 | 0 | no | no |
| 277250 | The Skullcracker | 3 | 0 | 40 | no | no |

### 2/5 Arma / Maza de dos manos, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 17073 | Earthshaker | 4 | 113631 | 60 | no | no |
| 17193 | Sulfuron Hammer | 4 | 122311 | 60 | no | no |
| 18867 | Grand Marshal's Battle Hammer | 4 | 62542 | 60 | no | no |
| 18868 | High Warlord's Pulverizer | 4 | 62763 | 60 | no | no |
| 19323 | The Unstoppable Force | 4 | 312980 | 55 | no | no |
| 21188 | Fist of Cenarius | 4 | 111220 | 60 | no | no |
| 23455 | Grand Marshal's Demolisher | 4 | 57053 | 60 | no | no |
| 23465 | High Warlord's Destroyer | 4 | 57089 | 60 | no | no |
| 272601 | Premier High Warlord's Pulverizer | 4 | 0 | 60 | no | no |
| 272682 | Premier High Warlord's Destroyer | 4 | 0 | 60 | no | no |
| 272848 | Premier Grand Marshal's Battle Hammer | 4 | 0 | 60 | no | no |
| 272858 | Premier Grand Marshal's Demolisher | 4 | 0 | 60 | no | no |
| 288900 | Earthshaker | 4 | 113631 | 1 | no | no |

### 2/6 Arma / Arma de asta, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 15810 | Short Spear | 1 | 2029 | 20 | no | no |
| 15811 | Heavy Spear | 1 | 5426 | 30 | no | no |

### 2/6 Arma / Arma de asta, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 11864 | White Bone Spear | 2 | 34108 | 0 | no | no |
| 250603 | Bronze Dory | 2 | 488 | 20 | no | no |
| 250605 | Steel Spear | 2 | 2501 | 32 | no | no |
| 271794 | Centaur Spear | 2 | 12329 | 35 | no | no |
| 274940 | Unbalanced Fighting Stick | 2 | 15711 | 0 | no | no |
| 274944 | Bloodsnout Striker | 2 | 15947 | 0 | no | no |
| 274963 | Rot-Covered Harpoon | 2 | 17157 | 0 | no | no |
| 275645 | Reforged Spear | 2 | 49485 | 0 | no | no |
| 275742 | Demonbane Blade | 2 | 28348 | 0 | no | no |
| 281296 | Knight's Lance | 2 | 0 | 0 | no | no |
| 281725 | Restored Spear | 2 | 1 | 1 | no | no |

### 2/6 Arma / Arma de asta, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 7959 | Blight | 3 | 33857 | 45 | no | no |
| 19106 | Ice Barbed Spear | 3 | 73353 | 0 | no | no |
| 211941 | Windwalker's Yari | 3 | 74346 | 58 | no | no |
| 250615 | Thorium Poleaxe | 3 | 54752 | 52 | no | no |
| 250619 | Legionite Glaive | 3 | 75130 | 58 | no | no |
| 271800 | Scavenged Magram Armament | 3 | 18624 | 35 | no | no |
| 274419 | Bear Poking Stick | 3 | 55923 | 53 | no | no |
| 276203 | Primitive Fishing Pole | 3 | 18922 | 40 | no | no |
| 281588 | Nature's Cull | 3 | 0 | 1 | no | no |

### 2/6 Arma / Arma de asta, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18869 | Grand Marshal's Glaive | 4 | 56993 | 60 | no | no |
| 18871 | High Warlord's Pig Sticker | 4 | 59017 | 60 | no | no |
| 19167 | Blackfury | 4 | 116531 | 60 | no | no |
| 22817 | Naxxramas Polearm [PH] | 4 | 181237 | 60 | no | no |
| 272602 | Premier High Warlord's Pig Sticker | 4 | 0 | 60 | no | no |
| 272849 | Premier Grand Marshal's Glaive | 4 | 0 | 60 | no | no |

### 2/7 Arma / Espada de una mano, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 25 | Worn Shortsword | 1 | 7 | 1 | no | no |
| 788 | Test Fire Sword | 1 | 3 | 0 | no | no |
| 851 | Cutlass | 1 | 404 | 10 | no | no |
| 923 | Longsword | 1 | 1748 | 21 | no | no |
| 945 | Shadow Sword | 1 | 3 | 1 | no | no |
| 948 | Nature Sword | 1 | 3 | 1 | no | no |
| 997 | Fire Sword of Crippling | 1 | 3 | 1 | no | no |
| 1008 | Well-used Sword | 1 | 144 | 0 | no | no |
| 1018 | Chows Blade of DOOM! (Test) | 1 | 3 | 1 | no | no |
| 1161 | Militia Shortsword | 1 | 25 | 0 | no | no |
| 1384 | Dull Blade | 1 | 11 | 1 | no | no |
| 2027 | Scimitar | 1 | 763 | 14 | no | no |
| 2057 | Pitted Defias Shortsword | 1 | 16 | 1 | no | no |
| 2065 | Rockjaw Blade | 1 | 113 | 4 | no | no |
| 2131 | Shortsword | 1 | 10 | 1 | no | no |
| 2258 | Frostmane Shortsword | 1 | 83 | 3 | no | no |
| 2268 | Stonesplinter Blade | 1 | 146 | 5 | no | no |
| 2282 | Rodentia Shortsword | 1 | 139 | 5 | no | no |
| 2481 | Peon Sword | 1 | 17 | 1 | no | no |
| 2488 | Gladius | 1 | 107 | 4 | no | no |
| 2496 | Raider Shortsword | 1 | 80 | 3 | no | no |
| 2520 | Broadsword | 1 | 4925 | 31 | no | no |
| 2528 | Falchion | 1 | 10367 | 41 | no | no |
| 3267 | Forsaken Shortsword | 1 | 25 | 0 | no | no |
| 3295 | Deadman Blade | 1 | 10 | 1 | no | no |
| 3319 | Short Sabre | 1 | 110 | 4 | no | no |
| 3455 | Deathstalker Shortsword | 1 | 188 | 0 | no | no |
| 3935 | Smotts' Cutlass | 1 | 0 | 20 | no | no |
| 4560 | Fine Scimitar | 1 | 37 | 1 | no | no |
| 4932 | Harpy Wing Clipper | 1 | 179 | 0 | no | no |
| 5586 | Thistlewood Blade | 1 | 26 | 0 | no | no |
| 5953 | TEST SWORD | 1 | 24751 | 0 | no | no |
| 5954 | TEST SWORD 2 | 1 | 24843 | 0 | no | no |
| 7171 | TWAIN TEST ITEM VISUAL SWORD | 1 | 3 | 1 | no | no |
| 12971 | JEFF TEST SWORD | 1 | 14281 | 0 | no | no |
| 12972 | JEFF TEST SWORD II | 1 | 14333 | 0 | no | no |
| 14391 | Durability Sword | 1 | 3 | 0 | no | no |
| 14883 | Test Glaive A | 1 | 24 | 1 | no | no |
| 14884 | Test Glaive B | 1 | 24 | 1 | no | no |
| 14885 | Test Glaive C | 1 | 25 | 1 | no | no |
| 14886 | Test Glaive D | 1 | 25 | 1 | no | no |
| 14887 | Test Glaive E | 1 | 25 | 1 | no | no |
| 14888 | Test Glaive F | 1 | 25 | 1 | no | no |
| 14889 | Test Glaive G | 1 | 25 | 1 | no | no |
| 14890 | Test Glaive H | 1 | 25 | 1 | no | no |
| 14891 | Test Glaive I | 1 | 25 | 1 | no | no |
| 14892 | Test Glaive J | 1 | 25 | 1 | no | no |
| 16212 | TEST SWORD 3 | 1 | 23721 | 0 | no | no |
| 17342 | JYoo Random Item Test | 1 | 3 | 1 | no | no |
| 257333 | Curved Scimitar | 1 | 144 | 0 | no | no |
| 277105 | Zephrali Blade | 1 | 342 | 9 | no | no |
| 279505 | Jagged Orcish Sword | 1 | 0 | 22 | no | no |
| 280399 | Damaged Scimitar | 1 | 7 | 1 | no | no |

### 2/7 Arma / Espada de una mano, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 864 | Knightly Longsword | 2 | 9716 | 33 | no | no |
| 2263 | Phytoblade | 2 | 2619 | 0 | no | no |
| 2847 | Copper Shortsword | 2 | 110 | 4 | no | no |
| 2850 | Bronze Shortsword | 2 | 1136 | 19 | no | no |
| 3462 | Talonstrike | 2 | 2283 | 0 | no | no |
| 3572 | Daryl's Shortsword | 2 | 972 | 0 | no | no |
| 3849 | Hardened Iron Shortsword | 2 | 5468 | 27 | no | no |
| 3850 | Jade Serpentblade | 2 | 7304 | 30 | no | no |
| 4765 | Enamelled Broadsword | 2 | 575 | 9 | no | no |
| 4766 | Feral Blade | 2 | 481 | 8 | no | no |
| 4977 | Sword of Hammerfall | 2 | 11893 | 0 | no | no |
| 4987 | Dwarf Captain's Sword | 2 | 15584 | 0 | no | no |
| 5321 | Elegant Shortsword | 2 | 1484 | 0 | no | no |
| 6967 | Elunite Sword | 2 | 696 | 0 | no | no |
| 6984 | Umbral Sword | 2 | 688 | 0 | no | no |
| 6985 | Haggard's Sword | 2 | 690 | 0 | no | no |
| 7118 | Heirloom Sword | 2 | 690 | 0 | no | no |
| 7329 | Thun'grim's Sword | 2 | 703 | 0 | no | no |
| 7943 | Wicked Mithril Blade | 2 | 15891 | 40 | no | no |
| 7944 | Dazzling Mithril Rapier | 2 | 14671 | 43 | no | no |
| 15211 | Militant Shortsword | 2 | 1916 | 17 | no | no |
| 15335 | Briarsteel Shortsword | 2 | 580 | 0 | no | no |
| 15705 | Tidecrest Blade | 2 | 33830 | 0 | no | no |
| 15782 | Beaststalker Blade | 2 | 43142 | 0 | no | no |
| 15800 | Intrepid Shortsword | 2 | 36082 | 0 | no | no |
| 15801 | Valiant Shortsword | 2 | 35860 | 0 | no | no |
| 15814 | Hameya's Slayer | 2 | 41911 | 0 | no | no |
| 16890 | Slatemetal Cutlass | 2 | 2483 | 0 | no | no |
| 16891 | Claystone Shortsword | 2 | 1697 | 0 | no | no |
| 18957 | Brushwood Blade | 2 | 250 | 0 | no | no |
| 19040 | Zorbin's Mega-Slicer | 2 | 19468 | 0 | no | no |
| 236760 | [TMP] Satyrbane | 2 | 33830 | 0 | no | no |
| 248006 | Militia Sword | 2 | 326 | 0 | no | no |
| 254779 | A'sharahm, the Roiling Tempest | 2 | 326 | 0 | no | no |
| 270092 | Blackwater Scimitar | 2 | 13979 | 0 | no | no |
| 271796 | Blade of the Magram Clan | 2 | 8987 | 35 | no | no |
| 272180 | Spectral Magister's Commission | 2 | 13205 | 1 | no | no |
| 274920 | Twilight Carver | 2 | 10484 | 0 | no | no |
| 276886 | Chol'aruk's Trophy Sword | 2 | 0 | 1 | no | no |
| 281293 | Weathered Deathstalker's Blade | 2 | 0 | 0 | no | no |
| 281728 | Restored Shortsword | 2 | 1 | 1 | no | no |

### 2/7 Arma / Espada de una mano, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 935 | Night Watch Shortsword | 3 | 1742 | 15 | no | no |
| 3933 | Deprecated Moon Glaive | 3 | 2670 | 18 | no | no |
| 7961 | Phantom Blade | 3 | 25508 | 44 | no | no |
| 9718 | Reforged Blade of Heroes | 3 | 11421 | 33 | no | no |
| 12777 | Blazing Rapier | 3 | 38648 | 51 | no | no |
| 12976 | Ironpatch Blade | 3 | 1770 | 15 | no | no |
| 17015 | Dark Iron Reaver | 3 | 63738 | 60 | no | no |
| 19427 | 1500 Test sword 63 blue | 3 | 54922 | 58 | no | no |
| 19428 | 2900 Test sword 63 blue | 3 | 54922 | 58 | no | no |
| 19502 | 2200 Test sword 63 blue | 3 | 54922 | 58 | no | no |
| 19550 | Legionnaire's Sword | 3 | 54922 | 58 | no | no |
| 19551 | Legionnaire's Sword | 3 | 32156 | 48 | no | no |
| 19552 | Legionnaire's Sword | 3 | 15899 | 38 | no | no |
| 19553 | Legionnaire's Sword | 3 | 6843 | 28 | no | no |
| 19554 | Protector's Sword | 3 | 54922 | 58 | no | no |
| 19555 | Protector's Sword | 3 | 32156 | 48 | no | no |
| 19556 | Protector's Sword | 3 | 15899 | 38 | no | no |
| 19557 | Protector's Sword | 3 | 7285 | 28 | no | no |
| 20430 | Legionnaire's Sword | 3 | 2433 | 18 | no | no |
| 20440 | Protector's Sword | 3 | 2582 | 18 | no | no |
| 21782 | 2000 Test sword 63 blue | 3 | 54922 | 58 | no | no |
| 22378 | Ravenholdt Slicer | 3 | 65211 | 0 | no | no |
| 239618 | Monster - Sword 1H - Vanquisher's Sword (Alt) | 3 | 17796 | 0 | no | no |
| 239688 | Monster - Spear 2H - Scarlet Cavalry - Spear | 3 | 17796 | 0 | no | no |
| 277246 | Ruby-Adorned Blade | 3 | 0 | 0 | no | no |
| 279392 | Glimmer | 3 | 3 | 0 | no | no |
| 279393 | Frostfall | 3 | 3 | 0 | no | no |
| 281587 | Greatflank Flayer | 3 | 0 | 1 | no | no |
| 281628 | Blade of Bandarion | 3 | 0 | 0 | no | no |

### 2/7 Arma / Espada de una mano, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 12584 | Grand Marshal's Longsword | 4 | 49636 | 60 | no | no |
| 16345 | High Warlord's Blade | 4 | 49483 | 60 | no | no |
| 19168 | Blackguard | 4 | 102890 | 60 | no | no |
| 19456 | 2900 Test sword 80 purple | 4 | 167843 | 60 | no | no |
| 19457 | 1500 Test sword 80 purple | 4 | 167843 | 60 | no | no |
| 19503 | 2200 Test sword 80 purple | 4 | 167843 | 58 | no | no |
| 19504 | 2200 Test sword 70 purple | 4 | 103041 | 58 | no | no |
| 21520 | Ravencrest's Legacy | 4 | 151868 | 60 | no | no |
| 21521 | Runesword of the Red | 4 | 137911 | 60 | no | no |
| 21622 | Sharpened Silithid Femur | 4 | 160986 | 60 | no | no |
| 21650 | Ancient Qiraji Ripper | 4 | 146570 | 60 | no | no |
| 22383 | Sageblade | 4 | 84291 | 59 | no | no |
| 22805 | Naxxramas Sword 1H 1 [PH] | 4 | 149352 | 60 | no | no |
| 23456 | Grand Marshal's Swiftblade | 4 | 45671 | 60 | no | no |
| 23467 | High Warlord's Quickblade | 4 | 45671 | 60 | no | no |
| 272452 | Premier High Warlord's Blade | 4 | 0 | 60 | no | no |
| 272684 | Premier High Warlord's Quickblade | 4 | 0 | 60 | no | no |
| 272693 | Premier Grand Marshal's Longsword | 4 | 0 | 60 | no | no |
| 272859 | Premier Grand Marshal's Swiftblade | 4 | 0 | 60 | no | no |
| 279259 | Ironwood Blade | 4 | 10484 | 60 | no | no |

### 2/7 Arma / Espada de una mano, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 19019 | Thunderfury, Blessed Blade of the Windseeker | 5 | 255355 | 60 | no | no |
| 289294 | Thunderfury, Blessed Blade of the Windseeker | 5 | 255355 | 1 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 922 | Dacian Falx | 1 | 2407 | 21 | no | no |
| 1194 | Bastard Sword | 1 | 20 | 1 | no | no |
| 1198 | Claymore | 1 | 535 | 10 | no | no |
| 2024 | Espadon | 1 | 1215 | 16 | no | no |
| 2128 | Scratched Claymore | 1 | 20 | 1 | no | no |
| 2489 | Two-handed Sword | 1 | 68 | 2 | no | no |
| 2497 | Rusted Claymore | 1 | 142 | 4 | no | no |
| 2521 | Flamberge | 1 | 6179 | 31 | no | no |
| 2529 | Zweihander | 1 | 13006 | 41 | no | no |
| 2754 | Tarnished Bastard Sword | 1 | 13 | 1 | no | no |
| 5779 | Forsaken Bastard Sword | 1 | 30 | 0 | no | no |
| 6741 | Orcish War Sword | 1 | 3014 | 0 | no | no |
| 8177 | Practice Sword | 1 | 71 | 2 | no | no |
| 12755 | Monster - Sword2H, Blackblade of Shahram | 1 | 4 | 1 | no | no |
| 22596 | Monster - Sword2H, Horde A02 | 1 | 4 | 0 | no | no |
| 257273 | Worn Greatblade | 1 | 32 | 0 | no | no |
| 258882 | Worn Greatsword | 1 | 20 | 1 | no | no |
| 277104 | Zephrali Greatsword | 1 | 427 | 9 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1566 | Edge of the People's Militia | 2 | 1132 | 0 | no | no |
| 2000 | Archeus | 2 | 8827 | 0 | no | no |
| 3209 | Ancient War Sword | 2 | 6783 | 0 | no | no |
| 3487 | Heavy Copper Broadsword | 2 | 1135 | 14 | no | no |
| 3822 | Runic Darkblade | 2 | 6481 | 0 | no | no |
| 3853 | Moonsteel Broadsword | 2 | 8615 | 31 | no | no |
| 3854 | Frost Tiger Blade | 2 | 8860 | 35 | no | no |
| 4817 | Blessed Claymore | 2 | 2462 | 17 | no | no |
| 4818 | Executioner's Sword | 2 | 2854 | 19 | no | no |
| 4939 | Steady Bastard Sword | 2 | 395 | 0 | no | no |
| 5614 | Seraph's Strike | 2 | 6147 | 0 | no | no |
| 5615 | Woodsman Sword | 2 | 1776 | 0 | no | no |
| 5813 | Emil's Brand | 2 | 7087 | 0 | no | no |
| 6186 | Trogg Slicer | 2 | 1372 | 0 | no | no |
| 7955 | Copper Claymore | 2 | 241 | 6 | no | no |
| 7957 | Bronze Greatsword | 2 | 2205 | 21 | no | no |
| 9602 | Brushwood Blade | 2 | 301 | 0 | no | no |
| 11854 | Samophlange Screwdriver | 2 | 1494 | 0 | no | no |
| 12764 | Thorium Greatsword | 2 | 23534 | 47 | no | no |
| 250610 | Mithril Claymore | 2 | 20470 | 40 | no | no |
| 260186 | Darkblade | 2 | 35584 | 0 | no | no |
| 263407 | Empyrean Greatsword | 2 | 495 | 0 | no | no |
| 268484 | Moonsilver Blade | 2 | 7459 | 0 | no | no |
| 269717 | Wildgore Greatsword | 2 | 30 | 0 | no | no |
| 270085 | Master Hunter's Spellsword | 2 | 17685 | 0 | no | no |
| 271795 | Wanderer's Broadsword | 2 | 12373 | 35 | no | no |
| 272179 | Greatsword of Great Pasts | 2 | 18180 | 1 | no | no |
| 276102 | Bladewind | 2 | 16843 | 0 | no | no |
| 276335 | Polished Doomguard Edge | 2 | 50426 | 0 | no | no |
| 281308 | Jameson's Backup Sword | 2 | 0 | 0 | no | no |
| 281729 | Restored Longsword | 2 | 1 | 1 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3934 | Deprecated Warden Blade | 3 | 2739 | 19 | no | no |
| 6977 | Whirlwind Sword | 3 | 17325 | 0 | no | no |
| 7960 | Truesilver Champion | 3 | 38548 | 47 | no | no |
| 12782 | Corruption | 3 | 56808 | 53 | no | no |
| 215235 | 2hander Animation as 1hander test copy | 3 | 6121 | 40 | no | no |
| 281313 | Trusty Sword | 3 | 0 | 0 | no | no |
| 287648 | Gilded Blademaster's Greatsword | 3 | 12 | 1 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18876 | Grand Marshal's Claymore | 4 | 60118 | 60 | no | no |
| 18877 | High Warlord's Greatsword | 4 | 60339 | 60 | no | no |
| 18882 | TEST Level 80 Epic | 4 | 209804 | 60 | no | no |
| 22814 | Naxxramas Sword 2H 2 [PH] | 4 | 220295 | 60 | no | no |
| 272604 | Premier High Warlord's Greatsword | 4 | 0 | 60 | no | no |
| 272851 | Premier Grand Marshal's Claymore | 4 | 0 | 60 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 13262 | Ashbringer | 5 | 261407 | 60 | no | no |

### 2/8 Arma / Espada de dos manos, calidad 6

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3687 | Deprecated Unholy Avenger | 6 | 57718 | 35 | no | no |

### 2/10 Arma / Bastón, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 35 | Bent Staff | 1 | 9 | 1 | no | no |
| 767 | Long Bo Staff | 1 | 100 | 3 | no | no |
| 854 | Quarter Staff | 1 | 604 | 11 | no | no |
| 928 | Long Staff | 1 | 1972 | 20 | no | no |
| 1010 | Gnarled Short Staff | 1 | 99 | 0 | no | no |
| 1159 | Militia Quarterstaff | 1 | 32 | 0 | no | no |
| 1388 | Crooked Staff | 1 | 14 | 1 | no | no |
| 2030 | Gnarled Staff | 1 | 1108 | 15 | no | no |
| 2067 | Frostbit Staff | 1 | 186 | 5 | no | no |
| 2132 | Short Staff | 1 | 20 | 1 | no | no |
| 2257 | Frostmane Staff | 1 | 188 | 5 | no | no |
| 2487 | Acolyte Staff | 1 | 20 | 1 | no | no |
| 2495 | Walking Stick | 1 | 100 | 3 | no | no |
| 2503 | Adept Short Staff | 1 | 103 | 3 | no | no |
| 2527 | Battle Staff | 1 | 5871 | 31 | no | no |
| 2535 | War Staff | 1 | 12311 | 40 | no | no |
| 2811 | Deprecated Lightforge Staff | 1 | 2989 | 0 | no | no |
| 3277 | Executor Staff | 1 | 30 | 0 | no | no |
| 3327 | Vile Fin Oracle Staff | 1 | 141 | 4 | no | no |
| 3335 | Farmer's Broom | 1 | 46 | 3 | no | no |
| 3661 | Handcrafted Staff | 1 | 9 | 1 | no | no |
| 4938 | Blemished Wooden Staff | 1 | 236 | 0 | no | no |
| 4961 | Dreamwatcher Staff | 1 | 183 | 0 | no | no |
| 5393 | Thistlewood Staff | 1 | 32 | 0 | no | no |
| 5581 | Smooth Walking Staff | 1 | 32 | 0 | no | no |
| 5776 | Elder's Cane | 1 | 30 | 0 | no | no |
| 5778 | Primitive Walking Stick | 1 | 30 | 0 | no | no |
| 7094 | Driftwood Branch | 1 | 174 | 5 | no | no |
| 14083 | Tyrande's Staff | 1 | 20 | 1 | no | no |
| 14392 | Durability Staff | 1 | 4 | 0 | no | no |
| 240132 | Test Staff | 1 | 9 | 1 | no | no |
| 257282 | Novice's Quarterstaff | 1 | 32 | 0 | no | no |
| 277109 | Zephrali Greatstaff | 1 | 435 | 9 | no | no |

### 2/10 Arma / Bastón, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2950 | Icicle Rod | 2 | 3476 | 0 | no | no |
| 3446 | Darkwood Staff | 2 | 592 | 0 | no | no |
| 3452 | Ceranium Rod | 2 | 2322 | 0 | no | no |
| 3738 | Brewing Rod | 2 | 3439 | 0 | no | no |
| 4134 | Nimboya's Mystical Staff | 2 | 22495 | 0 | no | no |
| 5306 | Wind Rider Staff | 2 | 1710 | 0 | no | no |
| 5340 | Cauldron Stirrer | 2 | 919 | 0 | no | no |
| 6215 | Balanced Fighting Stick | 2 | 601 | 0 | no | no |
| 9513 | Ley Staff | 2 | 305 | 0 | no | no |
| 9514 | Arcane Staff | 2 | 306 | 0 | no | no |
| 9603 | Gritroot Staff | 2 | 302 | 0 | no | no |
| 9683 | Strength of the Treant | 2 | 29952 | 0 | no | no |
| 10826 | Staff of Lore | 2 | 25501 | 0 | no | no |
| 11857 | Sanctimonial Rod | 2 | 21377 | 0 | no | no |
| 12251 | Big Stick | 2 | 10779 | 32 | no | no |
| 12252 | Staff of Protection | 2 | 12619 | 34 | no | no |
| 15105 | Staff of Noh'Orahil | 2 | 14397 | 0 | no | no |
| 15106 | Staff of Dar'Orahil | 2 | 14447 | 0 | no | no |
| 15397 | Oakthrush Staff | 2 | 731 | 0 | no | no |
| 16889 | Polished Walking Staff | 2 | 3093 | 0 | no | no |
| 16894 | Clear Crystal Rod | 2 | 1993 | 0 | no | no |
| 17004 | Sarah's Guide | 2 | 56429 | 0 | no | no |
| 20349 | 90 Green Frost Staff | 2 | 234151 | 60 | no | no |
| 20362 | 63 Green Frost Staff | 2 | 59573 | 58 | no | no |
| 20724 | Corrupted Blackwood Staff | 2 | 58873 | 0 | no | no |
| 236759 | [TMP] Furbolg Ritual Stave | 2 | 29952 | 0 | no | no |
| 248008 | Apprentice's Spellstaff | 2 | 601 | 0 | no | no |
| 257343 | Balanced Quarterstaff | 2 | 601 | 0 | no | no |
| 260207 | Staff of Archmage Selwyn | 2 | 31666 | 0 | no | no |
| 263434 | Winged Beast Staff | 2 | 302 | 0 | no | no |
| 270049 | Mavoris's Warstaff | 2 | 8088 | 0 | no | no |
| 271797 | Staff of Revelations | 2 | 11276 | 35 | no | no |
| 275291 | Staff of the Deeproar | 2 | 47998 | 0 | no | no |
| 275648 | Purified Gnarlybark Staff | 2 | 51335 | 0 | no | no |
| 275701 | Copper Plated Pipe | 2 | 47664 | 0 | no | no |
| 277253 | Staff of Brutal Cunning | 2 | 0 | 0 | no | no |
| 281274 | Makeshift Stormcaller | 2 | 0 | 0 | no | no |
| 281727 | Restored Greatstaff | 2 | 1 | 1 | no | no |

### 2/10 Arma / Bastón, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 9517 | Celestial Stave | 3 | 15737 | 0 | no | no |
| 15109 | Staff of Soran'ruk | 3 | 3344 | 0 | no | no |
| 19101 | Whiteout Staff | 3 | 79411 | 60 | no | no |
| 19102 | Crackling Staff | 3 | 79705 | 60 | no | no |
| 19566 | Advisor's Gnarled Staff | 3 | 70171 | 58 | no | no |
| 19567 | Advisor's Gnarled Staff | 3 | 40195 | 48 | no | no |
| 19568 | Advisor's Gnarled Staff | 3 | 19874 | 38 | no | no |
| 19569 | Advisor's Gnarled Staff | 3 | 8554 | 28 | no | no |
| 19570 | Lorekeeper's Staff | 3 | 71229 | 58 | no | no |
| 19571 | Lorekeeper's Staff | 3 | 41856 | 48 | no | no |
| 19572 | Lorekeeper's Staff | 3 | 20772 | 38 | no | no |
| 19573 | Lorekeeper's Staff | 3 | 8974 | 28 | no | no |
| 20425 | Advisor's Gnarled Staff | 3 | 3042 | 18 | no | no |
| 20434 | Lorekeeper's Staff | 3 | 3042 | 18 | no | no |
| 20522 | Feral Staff | 3 | 41554 | 0 | no | no |
| 21101 | Staff of Spell Penetration - Fire (TEST) | 3 | 73633 | 58 | no | no |
| 21102 | Staff of Spell Penetration - Frost (TEST) | 3 | 68652 | 58 | no | no |
| 22391 | Monster - Staff, Lord Valthalak | 3 | 68652 | 58 | no | no |
| 249392 | Glimmering Staff | 3 | 601 | 25 | no | no |
| 249393 | Soulstaff | 3 | 601 | 25 | no | no |
| 249453 | Radiant Staff | 3 | 601 | 45 | no | no |
| 249454 | Dreamstaff | 3 | 601 | 45 | no | no |
| 271767 | Healer's Staff | 3 | 16 | 0 | no | no |
| 271803 | Greatstaff of the Necrokhans | 3 | 18836 | 35 | no | no |
| 274420 | Wisepaw Totem | 3 | 56131 | 53 | no | no |
| 281312 | Fallen Dragon's Scepter | 3 | 0 | 0 | no | no |

### 2/10 Arma / Bastón, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18715 | Lok'delar, Stave of the Ancient Keepers | 4 | 0 | 60 | no | no |
| 18873 | Grand Marshal's Stave | 4 | 59459 | 60 | no | no |
| 18874 | High Warlord's War Staff | 4 | 59681 | 60 | no | no |
| 19884 | Jin'do's Judgement | 4 | 107909 | 60 | no | no |
| 20069 | Ironbark Staff | 4 | 110199 | 55 | no | no |
| 20220 | Ironbark Staff | 4 | 100919 | 55 | no | no |
| 20334 | 90 Epic Frost Staff | 4 | 345404 | 60 | no | no |
| 20487 | Lok'delar, Stave of the Ancient Keepers DEP | 4 | 166093 | 60 | no | no |
| 21125 | Ahn'Qiraj Staff [PH] | 4 | 166145 | 60 | no | no |
| 21273 | Blessed Qiraji Acolyte Staff | 4 | 219003 | 60 | no | no |
| 21275 | Blessed Qiraji Augur Staff | 4 | 199583 | 60 | no | no |
| 21276 | Blessed Qiraji Naturalist Staff UNUSED | 4 | 210376 | 60 | no | no |
| 272603 | Premier High Warlord's War Staff | 4 | 0 | 60 | no | no |
| 272850 | Premier Grand Marshal's Stave | 4 | 0 | 60 | no | no |

### 2/13 Arma / Puño, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 15903 | Right-Handed Claw | 1 | 1623 | 20 | no | no |
| 15904 | Right-Handed Blades | 1 | 4341 | 30 | no | no |
| 15905 | Right-Handed Brass Knuckles | 1 | 426 | 10 | no | no |
| 15906 | Left-Handed Brass Knuckles | 1 | 427 | 10 | no | no |
| 15907 | Left-Handed Claw | 1 | 1647 | 20 | no | no |
| 15909 | Left-Handed Blades | 1 | 4421 | 30 | no | no |

### 2/13 Arma / Puño, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 11863 | White Bone Shredder | 2 | 27191 | 0 | no | no |
| 250602 | Brass Knuckles | 2 | 1562 | 16 | no | no |
| 250604 | Iron Fists | 2 | 4754 | 26 | no | no |
| 250609 | Mithril Claws | 2 | 4079 | 40 | no | no |
| 276338 | Claw of Shalla'kal | 2 | 54793 | 0 | no | no |

### 2/13 Arma / Puño, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 12795 | Blood Talon | 3 | 48821 | 55 | no | no |
| 20003 | Devilsaur Claws | 3 | 31596 | 0 | no | no |
| 250614 | Thorium Cestus | 3 | 38843 | 50 | no | no |
| 250618 | Bagh Nakh | 3 | 59891 | 58 | no | no |
| 277244 | Guardian's Maulers | 3 | 0 | 40 | no | no |

### 2/13 Arma / Puño, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18843 | Grand Marshal's Right Hand Blade | 4 | 49339 | 60 | no | no |
| 18844 | High Warlord's Right Claw | 4 | 49516 | 60 | no | no |
| 18847 | Grand Marshal's Left Hand Blade | 4 | 50043 | 60 | no | no |
| 18848 | High Warlord's Left Claw | 4 | 50215 | 60 | no | no |
| 272597 | Premier High Warlord's Right Claw | 4 | 0 | 60 | no | no |
| 272598 | Premier High Warlord's Left Claw | 4 | 0 | 60 | no | no |
| 272844 | Premier Grand Marshal's Right Hand Blade | 4 | 0 | 60 | no | no |
| 272845 | Premier Grand Marshal's Left Hand Blade | 4 | 0 | 60 | no | no |

### 2/14 Arma / Miscelánea, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4616 | Ryedol's Lucky Pick | 1 | 3 | 0 | no | no |
| 280317 | Frying Pan | 1 | 2 | 1 | no | no |

### 2/14 Arma / Miscelánea, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 278423 | Monster - Mining Pick | 2 | 2 | 1 | no | no |

### 2/15 Arma / Daga, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2092 | Worn Dagger | 1 | 7 | 1 | no | no |
| 2137 | Whittling Knife | 1 | 24 | 0 | no | no |
| 2139 | Dirk | 1 | 11 | 1 | no | no |
| 2195 | Anvilmar Knife | 1 | 25 | 0 | no | no |
| 2207 | Jambiya | 1 | 478 | 11 | no | no |
| 2208 | Poniard | 1 | 730 | 14 | no | no |
| 2209 | Kris | 1 | 1423 | 19 | no | no |
| 2224 | Militia Dagger | 1 | 24 | 0 | no | no |
| 2225 | Sharp Kitchen Knife | 1 | 183 | 0 | no | no |
| 2484 | Small Knife | 1 | 17 | 1 | no | no |
| 2494 | Stiletto | 1 | 80 | 3 | no | no |
| 2502 | Scuffed Dagger | 1 | 59 | 2 | no | no |
| 2526 | Main Gauche | 1 | 3867 | 29 | no | no |
| 2534 | Rondel | 1 | 9086 | 39 | no | no |
| 2787 | Trogg Dagger | 1 | 10 | 1 | no | no |
| 2812 | Deprecated Lightforge Dagger | 1 | 2400 | 0 | no | no |
| 3145 | Off Hand Test Dagger | 1 | 3 | 1 | no | no |
| 3268 | Forsaken Dagger | 1 | 25 | 0 | no | no |
| 3296 | Deadman Dagger | 1 | 10 | 1 | no | no |
| 3445 | Ceremonial Knife | 1 | 226 | 0 | no | no |
| 3865 | Test Offhand Weapon | 1 | 7 | 1 | no | no |
| 4565 | Simple Dagger | 1 | 38 | 1 | no | no |
| 4840 | Long Bayonet | 1 | 142 | 0 | no | no |
| 4925 | Primitive Hand Blade | 1 | 25 | 0 | no | no |
| 5040 | Shadow Hunter Knife | 1 | 0 | 27 | no | no |
| 5093 | Razormane Backstabber | 1 | 247 | 16 | no | no |
| 5392 | Thistlewood Dagger | 1 | 25 | 0 | no | no |
| 5605 | Pruning Knife | 1 | 150 | 0 | no | no |
| 10547 | Camping Knife | 1 | 81 | 0 | no | no |
| 257283 | Scout Ranger's Dagger | 1 | 24 | 0 | no | no |
| 257332 | Stained Ritual Dagger | 1 | 142 | 0 | no | no |
| 277108 | Zephrali Knife | 1 | 346 | 9 | no | no |
| 279507 | Curved Orcish Dagger | 1 | 0 | 22 | no | no |
| 280402 | Rusty Dagger | 1 | 7 | 1 | no | no |

### 2/15 Arma / Daga, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2218 | Craftsman's Dagger | 2 | 501 | 0 | no | no |
| 2908 | Thornblade | 2 | 1409 | 0 | no | no |
| 3184 | Hook Dagger | 2 | 1394 | 15 | no | no |
| 3225 | Bloodstained Knife | 2 | 109 | 6 | no | no |
| 3490 | Deadly Bronze Poniard | 2 | 2044 | 20 | no | no |
| 3581 | Serrated Knife | 2 | 1046 | 0 | no | no |
| 3848 | Big Bronze Knife | 2 | 915 | 15 | no | no |
| 4302 | Small Green Dagger | 2 | 146 | 7 | no | no |
| 4947 | Jagged Dagger | 2 | 325 | 0 | no | no |
| 4974 | Compact Fighting Knife | 2 | 388 | 0 | no | no |
| 5279 | Harpy Skinner | 2 | 1436 | 0 | no | no |
| 5540 | Pearl-handled Dagger | 2 | 2107 | 18 | no | no |
| 5627 | Relic Blade | 2 | 1379 | 0 | no | no |
| 6969 | Elunite Dagger | 2 | 701 | 0 | no | no |
| 6980 | Haggard's Dagger | 2 | 677 | 0 | no | no |
| 6981 | Umbral Dagger | 2 | 680 | 0 | no | no |
| 7116 | Heirloom Dagger | 2 | 685 | 0 | no | no |
| 7166 | Copper Dagger | 2 | 194 | 6 | no | no |
| 7298 | Blade of Cunning | 2 | 468 | 0 | no | no |
| 7327 | Thun'grim's Dagger | 2 | 698 | 0 | no | no |
| 7947 | Ebon Shiv | 2 | 24892 | 46 | no | no |
| 9520 | Silent Hunter | 2 | 11461 | 0 | no | no |
| 9680 | Tok'kar's Murloc Shanker | 2 | 14090 | 0 | no | no |
| 10049 | Diabolist's Blade | 2 | 2653 | 0 | no | no |
| 10703 | Fiendish Skiv | 2 | 16792 | 0 | no | no |
| 11856 | Ceremonial Elven Blade | 2 | 15775 | 0 | no | no |
| 12247 | Broad Bladed Knife | 2 | 5674 | 27 | no | no |
| 12248 | Daring Dirk | 2 | 6405 | 29 | no | no |
| 12259 | Glinting Steel Dagger | 2 | 8072 | 31 | no | no |
| 12260 | Searing Golden Blade | 2 | 8165 | 34 | no | no |
| 15396 | Curvewood Dagger | 2 | 582 | 0 | no | no |
| 15706 | Hunt Tracker Blade | 2 | 33830 | 0 | no | no |
| 15783 | Beasthunter Dagger | 2 | 43292 | 0 | no | no |
| 20303 | 90 Green Rogue Dagger | 2 | 178668 | 60 | no | no |
| 20317 | 63 Green Rogue Dagger | 2 | 46790 | 58 | no | no |
| 20647 | Black Crystal Dagger | 2 | 40097 | 0 | no | no |
| 241089 | Scarlet Dagger | 2 | 251 | 5 | no | no |
| 248007 | Militia Shortblade | 2 | 468 | 0 | no | no |
| 250607 | Mithril Shortsword | 2 | 11906 | 36 | no | no |
| 250611 | Mithril Stiletto | 2 | 4133 | 42 | no | no |
| 250616 | Bold Dirk | 2 | 40772 | 52 | no | no |
| 251485 | Edward's Knife | 2 | 2285 | 0 | no | no |
| 257346 | Quickblade's Dagger | 2 | 501 | 0 | no | no |
| 260172 | Assassin's Dagger | 2 | 35315 | 0 | no | no |
| 260180 | Scout's Dagger | 2 | 35315 | 0 | no | no |
| 263432 | Skulker's Shiv | 2 | 142 | 0 | no | no |
| 270069 | Mindslicer | 2 | 9824 | 0 | no | no |
| 270070 | Madman's Blade | 2 | 9824 | 0 | no | no |
| 271799 | Desert Crawler's Claw | 2 | 9091 | 35 | no | no |
| 272181 | Phantasmal Shiv | 2 | 13358 | 0 | no | no |
| 274383 | Kanai's Knife | 2 | 37846 | 0 | no | no |
| 274948 | Bottle of Powderfuse Port | 2 | 12947 | 0 | no | no |
| 275836 | Acolyte Blade | 2 | 36228 | 0 | no | no |
| 276888 | Quilboar Toothpick | 2 | 0 | 1 | no | no |
| 276903 | Shimmerwine Shanker | 2 | 0 | 1 | no | no |
| 277515 | Dagger of Deals | 2 | 0 | 1 | no | no |
| 277988 | Hoof-Holstered Blade | 2 | 325 | 0 | no | no |
| 281257 | Daggerfang's Daggerfang | 2 | 0 | 0 | no | no |
| 281297 | Royal Dagger | 2 | 0 | 0 | no | no |
| 281722 | Restored Dagger | 2 | 1 | 1 | no | no |
| 282064 | Tim's Lost Rib | 2 | 0 | 0 | no | no |
| 282284 | Webwood Slicer | 2 | 0 | 1 | no | no |

### 2/15 Arma / Daga, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2236 | Blackfang | 3 | 3386 | 20 | no | no |
| 12783 | Heartseeker | 3 | 58215 | 58 | no | no |
| 19099 | Glacial Blade | 3 | 63065 | 60 | no | no |
| 19100 | Electrified Dagger | 3 | 63300 | 60 | no | no |
| 19313 | 1300 Test Dagger 63 blue | 3 | 58901 | 58 | no | no |
| 19314 | 2000 Test Dagger 63 blue | 3 | 59114 | 58 | no | no |
| 19542 | Scout's Blade | 3 | 59534 | 58 | no | no |
| 19543 | Scout's Blade | 3 | 34982 | 48 | no | no |
| 19544 | Scout's Blade | 3 | 17358 | 38 | no | no |
| 19545 | Scout's Blade | 3 | 6969 | 28 | no | no |
| 19546 | Sentinel's Blade | 3 | 56143 | 58 | no | no |
| 19547 | Sentinel's Blade | 3 | 32996 | 48 | no | no |
| 19548 | Sentinel's Blade | 3 | 16376 | 38 | no | no |
| 19549 | Sentinel's Blade | 3 | 7074 | 28 | no | no |
| 19622 | 1800 Test Dagger 63 blue | 3 | 54922 | 58 | no | no |
| 19810 | 1000 Test dagger 60 blue | 3 | 48120 | 58 | no | no |
| 20441 | Scout's Blade | 3 | 2433 | 18 | no | no |
| 20443 | Sentinel's Blade | 3 | 2610 | 18 | no | no |
| 21516 | Dagger of Spell Penetration - Fire 150 Resist (TEST) | 3 | 59557 | 58 | no | no |
| 21518 | Dagger of Spell Penetration - Frost 150 Resist (TEST) | 3 | 59978 | 58 | no | no |
| 22377 | The Thunderwood Poker | 3 | 64976 | 0 | no | no |
| 22379 | Shivsprocket's Shiv | 3 | 65446 | 0 | no | no |
| 22688 | Verimonde's Last Resort | 3 | 64512 | 0 | no | no |
| 24071 | Bland Dagger | 3 | 78694 | 0 | no | no |
| 231887 | Test Dagger | 3 | 39411 | 50 | no | no |
| 274753 | Jhordy's Misplaced Screwdriver | 3 | 18922 | 40 | no | no |
| 277248 | Notched Ritual Rib | 3 | 0 | 40 | no | no |
| 281314 | Subdued Dragon's Fang | 3 | 0 | 0 | no | no |

### 2/15 Arma / Daga, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18838 | Grand Marshal's Dirk | 4 | 48458 | 60 | no | no |
| 18840 | High Warlord's Razor | 4 | 48812 | 60 | no | no |
| 19166 | Black Amnesty | 4 | 92896 | 60 | no | no |
| 19324 | The Lobotomizer | 4 | 251323 | 55 | no | no |
| 20070 | Sageclaw | 4 | 88472 | 55 | no | no |
| 20214 | Mindfang | 4 | 85653 | 55 | no | no |
| 20279 | 90 Epic Rogue Dagger | 4 | 274087 | 60 | no | no |
| 21126 | Death's Sting | 4 | 206967 | 60 | no | no |
| 21244 | Blessed Qiraji Pugio | 4 | 165247 | 60 | no | no |
| 21522 | Shadowsong's Sorrow | 4 | 142269 | 60 | no | no |
| 21523 | Fang of Korialstrasz | 4 | 142805 | 60 | no | no |
| 23451 | Grand Marshal's Mageblade | 4 | 45671 | 60 | no | no |
| 23466 | High Warlord's Spellblade | 4 | 45671 | 60 | no | no |
| 272596 | Premier High Warlord's Razor | 4 | 0 | 60 | no | no |
| 272683 | Premier High Warlord's Spellblade | 4 | 0 | 60 | no | no |
| 272843 | Premier Grand Marshal's Dirk | 4 | 0 | 60 | no | no |
| 272856 | Premier Grand Marshal's Mageblade | 4 | 0 | 60 | no | no |

### 2/16 Arma / Arrojadiza, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2945 | (OLD)Medium Throwing Knife | 1 | 0 | 1 | no | no |
| 2946 | Balanced Throwing Dagger | 1 | 59 | 3 | no | no |
| 2947 | Small Throwing Knife | 1 | 8 | 1 | no | no |
| 3107 | Keen Throwing Knife | 1 | 366 | 11 | no | no |
| 3108 | Heavy Throwing Dagger | 1 | 1518 | 22 | no | no |
| 3109 | (OLD)Wicked Throwing Dagger | 1 | 0 | 21 | no | no |
| 3111 | Crude Throwing Axe | 1 | 8 | 1 | no | no |
| 3128 | (OLD)Medium Throwing Axe | 1 | 0 | 1 | no | no |
| 3131 | Weighted Throwing Axe | 1 | 59 | 3 | no | no |
| 3135 | Sharp Throwing Axe | 1 | 366 | 11 | no | no |
| 3136 | (OLD)Heavy Throwing Axe | 1 | 1 | 14 | no | no |
| 3137 | Deadly Throwing Axe | 1 | 1518 | 22 | no | no |
| 4959 | Throwing Tomahawk | 1 | 1 | 0 | no | no |
| 5559 | Fast Test Thrown | 1 | 1 | 1 | no | no |
| 15326 | Gleaming Throwing Axe | 1 | 4962 | 35 | no | no |
| 15327 | Wicked Throwing Dagger | 1 | 4962 | 35 | no | no |
| 20814 | Master's Throwing Dagger | 1 | 23806 | 60 | no | no |

### 2/16 Arma / Arrojadiza, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3463 | Silver Star | 2 | 5426 | 0 | no | no |
| 20086 | Dusksteel Throwing Knife | 2 | 19878 | 0 | no | no |
| 270106 | Vicious Throwing Stars | 2 | 17526 | 0 | no | no |
| 281660 | Iron Star | 2 | 2531 | 0 | no | no |
| 285279 | Cracked Blacksmith Hammer | 2 | 1411 | 17 | no | no |

### 2/16 Arma / Arrojadiza, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21135 | Assassin's Throwing Axe | 3 | 43186 | 58 | no | no |

### 2/18 Arma / Ballesta, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 15807 | Light Crossbow | 1 | 58 | 3 | no | no |
| 15808 | Fine Light Crossbow | 1 | 728 | 16 | no | no |
| 15809 | Heavy Crossbow | 1 | 2938 | 29 | no | no |
| 277111 | Zephrali Crossbow | 1 | 270 | 9 | no | no |

### 2/18 Arma / Ballesta, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 276332 | Abigail's Hope | 2 | 29913 | 0 | no | no |

### 2/18 Arma / Ballesta, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 19107 | Bloodseeker | 3 | 44171 | 0 | no | no |
| 19489 | 3300 Test Crossbow 63 blue | 3 | 41191 | 60 | no | no |
| 22347 | Fahrad's Reloading Repeater | 3 | 45728 | 0 | no | no |

### 2/18 Arma / Ballesta, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18836 | Grand Marshal's Repeater | 4 | 35130 | 60 | no | no |
| 18837 | High Warlord's Crossbow | 4 | 35259 | 60 | no | no |
| 272595 | Premier High Warlord's Crossbow | 4 | 0 | 60 | no | no |
| 272842 | Premier Grand Marshal's Repeater | 4 | 0 | 60 | no | no |

### 2/19 Arma / Varita, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4902 | Deprecated Apprentice Wand | 1 | 2 | 1 | no | no |
| 5092 | Charred Razormane Wand | 1 | 240 | 18 | no | no |
| 5208 | Smoldering Wand | 1 | 668 | 15 | no | no |
| 5209 | Gloom Wand | 1 | 771 | 16 | no | no |
| 5210 | Burning Wand | 1 | 1161 | 20 | no | no |
| 5211 | Dusk Wand | 1 | 1166 | 20 | no | no |
| 5235 | Alchemist's Wand | 1 | 41 | 0 | no | no |
| 5236 | Combustible Wand | 1 | 2878 | 29 | no | no |
| 5238 | Pitchwood Wand | 1 | 7145 | 40 | no | no |
| 5239 | Blackbone Wand | 1 | 7746 | 41 | no | no |
| 5347 | Pestilent Wand | 1 | 3142 | 30 | no | no |
| 247789 | Novice's Practice Wand | 1 | 5 | 1 | no | no |
| 263428 | Dowsing Rod | 1 | 1 | 0 | no | no |

### 2/19 Arma / Varita, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4547 | Gnomish Zapper | 2 | 8319 | 0 | no | no |
| 5240 | Torchlight Wand | 2 | 1244 | 0 | no | no |
| 5241 | Dwarven Flamestick | 2 | 821 | 0 | no | no |
| 5242 | Cinder Wand | 2 | 623 | 0 | no | no |
| 5244 | Consecrated Wand | 2 | 3465 | 0 | no | no |
| 5246 | Excavation Rod | 2 | 3490 | 0 | no | no |
| 5247 | Rod of Sorrow | 2 | 7961 | 0 | no | no |
| 5248 | Flash Wand | 2 | 6849 | 0 | no | no |
| 5249 | Burning Sliver | 2 | 8658 | 0 | no | no |
| 5250 | Charred Wand | 2 | 2646 | 0 | no | no |
| 5252 | Wand of Decay | 2 | 1175 | 0 | no | no |
| 5253 | Goblin Igniter | 2 | 7952 | 0 | no | no |
| 5326 | Flaring Baton | 2 | 776 | 0 | no | no |
| 5356 | Branding Rod | 2 | 2594 | 0 | no | no |
| 5604 | Elven Wand | 2 | 380 | 0 | no | no |
| 5818 | Moonbeam Wand | 2 | 3239 | 0 | no | no |
| 6677 | Spellcrafter Wand | 2 | 2401 | 0 | no | no |
| 6729 | Fizzle's Zippy Lighter | 2 | 7187 | 0 | no | no |
| 6797 | Eyepoker | 2 | 6362 | 0 | no | no |
| 9654 | Cairnstone Sliver | 2 | 16928 | 0 | no | no |
| 10704 | Chillnail Splinter | 2 | 13649 | 0 | no | no |
| 11287 | Lesser Magic Wand | 2 | 110 | 5 | no | no |
| 11288 | Greater Magic Wand | 2 | 200 | 13 | no | no |
| 11289 | Lesser Mystic Wand | 2 | 450 | 26 | no | no |
| 11860 | Charged Lightning Rod | 2 | 12970 | 0 | no | no |
| 12296 | Spark of the People's Militia | 2 | 722 | 0 | no | no |
| 15204 | Moonstone Wand | 2 | 779 | 0 | no | no |
| 15465 | Stingshot Wand | 2 | 2713 | 0 | no | no |
| 15692 | Kodo Brander | 2 | 6935 | 0 | no | no |
| 16789 | Captain Rackmore's Tiller | 2 | 5992 | 0 | no | no |
| 16993 | Smokey's Fireshooter | 2 | 30989 | 0 | no | no |
| 19118 | Nature's Breath | 2 | 17344 | 0 | no | no |
| 20350 | 90 Green Frost Wand | 2 | 140987 | 60 | no | no |
| 20363 | 63 Green Frost Wand | 2 | 35877 | 58 | no | no |
| 217287 | Greater Mystic Wand | 2 | 600 | 30 | no | no |
| 249144 | Twisted Nether Wand | 2 | 1000 | 37 | no | no |
| 249232 | Lesser Eternal Wand | 2 | 2000 | 49 | no | no |
| 249234 | Dreambough Wand | 2 | 1500 | 43 | no | no |
| 249237 | Greater Eternal Wand | 2 | 2500 | 55 | no | no |
| 263430 | Windbough Wand | 2 | 1 | 0 | no | no |
| 270084 | Master Hunter's Wand | 2 | 5263 | 0 | no | no |
| 274919 | Neophyte's Wand | 2 | 8660 | 0 | no | no |
| 275837 | Felflick's Fire Flicker | 2 | 28906 | 0 | no | no |
| 277256 | Dudd's Second-Favorite Wand | 2 | 0 | 40 | no | no |
| 281263 | Wicked Lich's Finger | 2 | 0 | 0 | no | no |
| 281733 | Restored Wand | 2 | 1 | 1 | no | no |

### 2/19 Arma / Varita, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 7513 | Ragefire Wand | 3 | 9805 | 0 | no | no |
| 7514 | Icefury Wand | 3 | 9842 | 0 | no | no |
| 11263 | Nether Force Wand | 3 | 10103 | 0 | no | no |
| 16997 | Stormrager | 3 | 41603 | 0 | no | no |
| 19108 | Wand of Biting Cold | 3 | 44327 | 0 | no | no |
| 249385 | Brilliant Wand | 3 | 5263 | 55 | no | no |

### 2/19 Arma / Varita, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 20335 | 90 Epic Frost Wand | 4 | 208038 | 60 | no | no |
| 21124 | Ahn'Qiraj Wand [PH] | 4 | 99304 | 60 | no | no |
| 279246 | Torch of Light | 4 | 13687 | 60 | no | no |

### 4/0 Armadura / Miscelánea, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 38 | Recruit's Shirt | 1 | 1 | 0 | no | no |
| 41 | OLDRecruit's Belt | 1 | 1 | 1 | no | no |
| 42 | OLDSquire's Belt | 1 | 1 | 1 | no | no |
| 45 | Squire's Shirt | 1 | 1 | 0 | no | no |
| 46 | OLDFootpad's Belt | 1 | 1 | 1 | no | no |
| 49 | Footpad's Shirt | 1 | 1 | 0 | no | no |
| 50 | OLDInitiate's Belt | 1 | 1 | 1 | no | no |
| 53 | Neophyte's Shirt | 1 | 1 | 0 | no | no |
| 54 | OLDNovice's Belt | 1 | 1 | 1 | no | no |
| 58 | OLDAcolyte's Belt | 1 | 1 | 1 | no | no |
| 86 | Deprecated Old Belt | 1 | 1 | 0 | no | no |
| 87 | Deprecated Old Boots | 1 | 1 | 0 | no | no |
| 89 | OLDThick Trapper's Shirt | 1 | 1 | 0 | no | no |
| 90 | OLDDwarven Initiate's Belt | 1 | 1 | 1 | no | no |
| 92 | OLDDwarven Initiate's Boots | 1 | 1 | 1 | no | no |
| 93 | OLDDwarven Initiate's Shirt | 1 | 1 | 0 | no | no |
| 94 | Deprecated Dwarven Novice's Belt | 1 | 1 | 1 | no | no |
| 95 | Deprecated Dwarven Novice's Boots | 1 | 1 | 1 | no | no |
| 98 | Deprecated Dwarven Squire's Belt | 1 | 1 | 1 | no | no |
| 99 | Deprecated Dwarven Squire's Boots | 1 | 1 | 1 | no | no |
| 101 | Deprecated Dwarven Squire's Shirt | 1 | 1 | 0 | no | no |
| 102 | Deprecated Dwarven Recruit's Belt | 1 | 1 | 1 | no | no |
| 103 | Deprecated Dwarven Recruit's Boots | 1 | 1 | 1 | no | no |
| 105 | Deprecated Dwarven Recruit's Shirt | 1 | 1 | 0 | no | no |
| 114 | Deprecated Dwarven Apprentice Boots | 1 | 1 | 1 | no | no |
| 115 | Deprecated Dwarven Apprentice Belt | 1 | 1 | 1 | no | no |
| 119 | Deprecated Rogue's Vest | 1 | 1 | 0 | no | no |
| 122 | OLDThug Belt | 1 | 1 | 1 | no | no |
| 123 | Deprecated Orc Apprentice Shirt | 1 | 1 | 0 | no | no |
| 125 | Deprecated Orc Apprentice Boots | 1 | 1 | 1 | no | no |
| 126 | Deprecated Orc Apprentice Belt | 1 | 1 | 1 | no | no |
| 127 | Trapper's Shirt | 1 | 1 | 0 | no | no |
| 130 | Deprecated Tauren Trapper's Belt | 1 | 1 | 1 | no | no |
| 131 | Deprecated Orc Acolyte's Belt | 1 | 1 | 1 | no | no |
| 132 | Deprecated Orc Acolyte's Boots | 1 | 1 | 1 | no | no |
| 133 | Deprecated Orc Acolyte's Shirt | 1 | 1 | 0 | no | no |
| 134 | Deprecated Stiff Leather Shirt | 1 | 1 | 0 | no | no |
| 136 | Deprecated Old Leather Boots | 1 | 1 | 0 | no | no |
| 137 | OLDNeophyte's Belt | 1 | 1 | 1 | no | no |
| 138 | Deprecated War Harness | 1 | 1 | 0 | no | no |
| 141 | OLDBrawler's Belt | 1 | 1 | 1 | no | no |
| 146 | OLDRugged Trapper's Belt | 1 | 1 | 1 | no | no |
| 148 | Rugged Trapper's Shirt | 1 | 1 | 0 | no | no |
| 149 | Deprecated Tauren Apprentice Belt | 1 | 1 | 0 | no | no |
| 151 | Deprecated Tauren Apprentice Shirt | 1 | 1 | 0 | no | no |
| 152 | OLDPrimitive Leather Belt | 1 | 1 | 1 | no | no |
| 154 | Primitive Mantle | 1 | 1 | 0 | no | no |
| 155 | Deprecated Tauren Recruit's Belt | 1 | 1 | 1 | no | no |
| 157 | Deprecated Tauren Recruit's Shirt | 1 | 1 | 0 | no | no |
| 746 | Lord Brandon's Tabard (Test) | 1 | 18 | 1 | no | no |
| 859 | Fine Cloth Shirt | 1 | 87 | 0 | no | no |
| 964 | Deprecated Red Linen Shirt | 1 | 12 | 0 | no | no |
| 2105 | Thug Shirt | 1 | 1 | 0 | no | no |
| 2410 | Smoky Torch | 1 | 1 | 0 | no | no |
| 2562 | Bouquet of Scarlet Begonias | 1 | 575 | 0 | no | no |
| 2575 | Red Linen Shirt | 1 | 25 | 0 | no | no |
| 2576 | White Linen Shirt | 1 | 75 | 0 | no | no |
| 2577 | Blue Linen Shirt | 1 | 75 | 0 | no | no |
| 2579 | Green Linen Shirt | 1 | 37 | 0 | no | no |
| 2587 | Gray Woolen Shirt | 1 | 200 | 0 | no | no |
| 2804 | Deprecated Freezing Talisman | 1 | 2125 | 35 | no | no |
| 2919 | Relic of the Ancients | 1 | 1000 | 25 | no | no |
| 2920 | Sacred Relic | 1 | 50 | 5 | no | no |
| 2921 | Blessed Relic | 1 | 125 | 10 | no | no |
| 2922 | Spirit Relic | 1 | 250 | 15 | no | no |
| 2923 | Relic of Righteousness | 1 | 500 | 20 | no | no |
| 3001 | Deprecated Medivh's Folly | 1 | 250 | 15 | no | no |
| 3002 | Relic Horn of Justice | 1 | 1000 | 25 | no | no |
| 3003 | Relic of the Eye | 1 | 50 | 5 | no | no |
| 3004 | Relic of the Dead | 1 | 125 | 10 | no | no |
| 3005 | Relic of Truth | 1 | 250 | 15 | no | no |
| 3006 | Holy Relic Shard | 1 | 500 | 20 | no | no |
| 3147 | Deprecated Tattered Shirt | 1 | 1 | 0 | no | no |
| 3148 | Deprecated Work Shirt | 1 | 1 | 0 | no | no |
| 3149 | Deprecated Ripped Vest | 1 | 1 | 0 | no | no |
| 3342 | Captain Sander's Shirt | 1 | 137 | 0 | no | no |
| 3360 | Stitches' Femur | 1 | 625 | 25 | no | no |
| 3419 | Red Rose | 1 | 125 | 0 | no | no |
| 3420 | Black Rose | 1 | 1250 | 0 | no | no |
| 3421 | Simple Wildflowers | 1 | 50 | 0 | no | no |
| 3422 | Beautiful Wildflowers | 1 | 500 | 0 | no | no |
| 3423 | Bouquet of White Roses | 1 | 5000 | 0 | no | no |
| 3424 | Bouquet of Black Roses | 1 | 125000 | 0 | no | no |
| 3426 | Bold Yellow Shirt | 1 | 1000 | 0 | no | no |
| 3427 | Stylish Black Shirt | 1 | 1500 | 0 | no | no |
| 3428 | Common Gray Shirt | 1 | 100 | 0 | no | no |
| 3788 | Soul Crystal Relic | 1 | 3000 | 35 | no | no |
| 3789 | Relic Stone of Piety | 1 | 2000 | 30 | no | no |
| 3790 | Consecrated Relic Parchment | 1 | 2000 | 30 | no | no |
| 3791 | Relic of the Light | 1 | 3000 | 35 | no | no |
| 4030 | Holy Relic Water | 1 | 4000 | 40 | no | no |
| 4031 | Hallowed Relic Charm | 1 | 4000 | 40 | no | no |
| 4032 | Radiant Relic Hammer | 1 | 5000 | 45 | no | no |
| 4033 | Dawn's Glow | 1 | 5000 | 45 | no | no |
| 4330 | Stylish Red Shirt | 1 | 250 | 0 | no | no |
| 4332 | Bright Yellow Shirt | 1 | 500 | 0 | no | no |
| 4333 | Dark Silk Shirt | 1 | 1200 | 0 | no | no |
| 4334 | Formal White Shirt | 1 | 550 | 0 | no | no |
| 4335 | Rich Purple Silk Shirt | 1 | 1500 | 0 | no | no |
| 4336 | Black Swashbuckler's Shirt | 1 | 1500 | 0 | no | no |
| 4344 | Brown Linen Shirt | 1 | 11 | 0 | no | no |
| 5090 | Deprecated Torn Shirt | 1 | 1 | 0 | no | no |
| 5107 | Deckhand's Shirt | 1 | 139 | 0 | no | no |
| 5222 | Deprecated Mana Gem | 1 | 0 | 23 | no | no |
| 5226 | Deprecated Conjured Mana Jewel | 1 | 0 | 32 | no | no |
| 5976 | Guild Tabard | 1 | 2500 | 0 | no | no |
| 6096 | Apprentice's Shirt | 1 | 1 | 0 | no | no |
| 6097 | Acolyte's Shirt | 1 | 1 | 0 | no | no |
| 6117 | Squire's Shirt | 1 | 1 | 0 | no | no |
| 6120 | Recruit's Shirt | 1 | 1 | 0 | no | no |
| 6125 | Brawler's Harness | 1 | 1 | 0 | no | no |
| 6130 | Trapper's Shirt | 1 | 1 | 0 | no | no |
| 6134 | Primitive Mantle | 1 | 1 | 0 | no | no |
| 6136 | Thug Shirt | 1 | 1 | 0 | no | no |
| 6384 | Stylish Blue Shirt | 1 | 250 | 0 | no | no |
| 6385 | Stylish Green Shirt | 1 | 250 | 0 | no | no |
| 6786 | Simple Dress | 1 | 59 | 0 | no | no |
| 6795 | White Swashbuckler's Shirt | 1 | 500 | 0 | no | no |
| 6796 | Red Swashbuckler's Shirt | 1 | 750 | 0 | no | no |
| 6837 | Wedding Dress | 1 | 1 | 0 | no | no |
| 7337 | The Rock | 1 | 250000 | 0 | no | no |
| 7338 | Mood Ring | 1 | 2500 | 0 | no | no |
| 7339 | Miniscule Diamond Ring | 1 | 62500 | 0 | no | no |
| 7340 | Flawless Diamond Solitaire | 1 | 125000 | 0 | no | no |
| 7341 | Cubic Zirconia Ring | 1 | 12500 | 0 | no | no |
| 7342 | Silver Piffeny Band | 1 | 25000 | 0 | no | no |
| 7725 | Tabard of the Scarlet Crusade DEPRECATED | 1 | 7143 | 0 | no | no |
| 7809 | Easter Dress | 1 | 1024 | 0 | no | no |
| 8624 | Red Sparkler | 1 | 250 | 0 | no | no |
| 8625 | White Sparkler | 1 | 250 | 0 | no | no |
| 8626 | Blue Sparkler | 1 | 250 | 0 | no | no |
| 10034 | Tuxedo Shirt | 1 | 2000 | 0 | no | no |
| 10052 | Orange Martial Shirt | 1 | 1500 | 0 | no | no |
| 10053 | Simple Black Dress | 1 | 4499 | 0 | no | no |
| 10054 | Lavender Mageweave Shirt | 1 | 3000 | 0 | no | no |
| 10055 | Pink Mageweave Shirt | 1 | 3000 | 0 | no | no |
| 10056 | Orange Mageweave Shirt | 1 | 1500 | 0 | no | no |
| 10555 | Resist Test Item | 1 | 1632 | 0 | no | no |
| 11364 | Tabard of Stormwind | 1 | 0 | 0 | no | no |
| 11840 | Master Builder's Shirt | 1 | 7137 | 0 | no | no |
| 12442 | Charm Pouch (DND) | 1 | 11463 | 0 | no | no |
| 13895 | Formal Dangui | 1 | 101324 | 0 | no | no |
| 13896 | Dark Green Wedding Hanbok | 1 | 11020 | 0 | no | no |
| 13897 | White Traditional Hanbok | 1 | 595 | 0 | no | no |
| 13898 | Royal Dangui | 1 | 57739 | 0 | no | no |
| 13899 | Red Traditional Hanbok | 1 | 3528 | 0 | no | no |
| 13900 | Green Wedding Hanbok | 1 | 27442 | 0 | no | no |
| 14617 | Sawbones Shirt | 1 | 6250 | 0 | no | no |
| 15196 | Private's Tabard | 1 | 2500 | 0 | no | no |
| 15197 | Scout's Tabard | 1 | 2500 | 0 | no | no |
| 15198 | Knight's Colors | 1 | 10000 | 0 | no | no |
| 15199 | Stone Guard's Herald | 1 | 10000 | 0 | no | no |
| 16034 | PVP Plate Cloak Alliance | 1 | 7116 | 0 | no | no |
| 16036 | PVP Cloth Robe Horde | 1 | 9488 | 0 | no | no |
| 16037 | PVP Cloth Legs Horde | 1 | 9488 | 0 | no | no |
| 16059 | Common Brown Shirt | 1 | 100 | 0 | no | no |
| 16060 | Common White Shirt | 1 | 100 | 0 | no | no |
| 17723 | Green Holiday Shirt | 1 | 750 | 0 | no | no |
| 19031 | Frostwolf Battle Tabard | 1 | 2500 | 0 | no | no |
| 19032 | Stormpike Battle Tabard | 1 | 2500 | 0 | no | no |
| 19160 | Contest Winner's Tabard | 1 | 0 | 0 | no | no |
| 19295 | Darkmoon Flower | 1 | 750 | 0 | no | no |
| 19505 | Warsong Battle Tabard | 1 | 12500 | 0 | no | no |
| 19506 | Silverwing Battle Tabard | 1 | 12500 | 0 | no | no |
| 20131 | Battle Tabard of the Defilers | 1 | 12500 | 0 | no | no |
| 20132 | Arathor Battle Tabard | 1 | 12500 | 0 | no | no |
| 20391 | Flimsy Male Gnome Mask | 1 | 1 | 0 | no | no |
| 20392 | Flimsy Female Gnome Mask | 1 | 1 | 0 | no | no |
| 20561 | Flimsy Male Dwarf Mask | 1 | 1 | 0 | no | no |
| 20562 | Flimsy Female Dwarf Mask | 1 | 1 | 0 | no | no |
| 20563 | Flimsy Female Night Elf Mask | 1 | 1 | 0 | no | no |
| 20564 | Flimsy Male Night Elf Mask | 1 | 1 | 0 | no | no |
| 20565 | Flimsy Female Human Mask | 1 | 1 | 0 | no | no |
| 20566 | Flimsy Male Human Mask | 1 | 1 | 0 | no | no |
| 20567 | Flimsy Female Troll Mask | 1 | 1 | 0 | no | no |
| 20568 | Flimsy Male Troll Mask | 1 | 1 | 0 | no | no |
| 20569 | Flimsy Female Orc Mask | 1 | 1 | 0 | no | no |
| 20570 | Flimsy Male Orc Mask | 1 | 1 | 0 | no | no |
| 20571 | Flimsy Female Tauren Mask | 1 | 1 | 0 | no | no |
| 20572 | Flimsy Male Tauren Mask | 1 | 1 | 0 | no | no |
| 20573 | Flimsy Male Undead Mask | 1 | 1 | 0 | no | no |
| 20574 | Flimsy Female Undead Mask | 1 | 1 | 0 | no | no |
| 21040 | Narain's Robe | 1 | 1 | 0 | no | no |
| 21419 | AHNQIRAJ TEST ITEM A CLOTH LEGS | 1 | 1 | 0 | no | no |
| 21420 | AHNQIRAJ TEST ITEM B LEATHER CHEST | 1 | 1 | 0 | no | no |
| 21421 | AHNQIRAJ TEST ITEM C MAIL CHEST | 1 | 1 | 0 | no | no |
| 21422 | AHNQIRAJ TEST ITEM D PLATE CHEST | 1 | 1 | 0 | no | no |
| 21423 | AHNQIRAJ TEST ITEM B LEATHER PANTS | 1 | 1 | 0 | no | no |
| 21424 | AHNQIRAJ TEST ITEM B LEATHER SHOULDER | 1 | 1 | 0 | no | no |
| 21425 | AHNQIRAJ TEST ITEM B LEATHER BELT | 1 | 1 | 0 | no | no |
| 21426 | AHNQIRAJ TEST ITEM B LEATHER HELM | 1 | 1 | 0 | no | no |
| 21427 | AHNQIRAJ TEST ITEM B LEATHER BOOTS | 1 | 1 | 0 | no | no |
| 21428 | AHNQIRAJ TEST ITEM B LEATHER GAUNTLETS | 1 | 1 | 0 | no | no |
| 21429 | AHNQIRAJ TEST ITEM A CLOTH BELT | 1 | 1 | 0 | no | no |
| 21430 | AHNQIRAJ TEST ITEM A CLOTH ROBE | 1 | 1 | 0 | no | no |
| 21431 | AHNQIRAJ TEST ITEM A CLOTH FEET | 1 | 1 | 0 | no | no |
| 21432 | AHNQIRAJ TEST ITEM B LEATHER BRACER | 1 | 1 | 0 | no | no |
| 21433 | AHNQIRAJ TEST ITEM A CLOTH BRACER | 1 | 1 | 0 | no | no |
| 21434 | AHNQIRAJ TEST ITEM A CLOTH HELM | 1 | 1 | 0 | no | no |
| 21435 | AHNQIRAJ TEST ITEM A CLOTH SHOULDERS | 1 | 1 | 0 | no | no |
| 21437 | AHNQIRAJ TEST ITEM A CLOTH GLOVES | 1 | 1 | 0 | no | no |
| 21439 | AHNQIRAJ TEST ITEM D PLATE HELM | 1 | 1 | 0 | no | no |
| 21440 | AHNQIRAJ TEST ITEM D PLATE LEGS | 1 | 1 | 0 | no | no |
| 21441 | AHNQIRAJ TEST ITEM D PLATE BELT | 1 | 1 | 0 | no | no |
| 21442 | AHNQIRAJ TEST ITEM D PLATE BOOTS | 1 | 1 | 0 | no | no |
| 21443 | AHNQIRAJ TEST ITEM D PLATE SHOULDERS | 1 | 1 | 0 | no | no |
| 21444 | AHNQIRAJ TEST ITEM D PLATE GLOVES | 1 | 1 | 0 | no | no |
| 21445 | AHNQIRAJ TEST ITEM D PLATE BRACER | 1 | 1 | 0 | no | no |
| 21446 | AHNQIRAJ TEST ITEM C MAIL HELM | 1 | 1 | 0 | no | no |
| 21447 | AHNQIRAJ TEST ITEM C MAIL SHOULDERS | 1 | 1 | 0 | no | no |
| 21448 | AHNQIRAJ TEST ITEM C MAIL LEGS | 1 | 1 | 0 | no | no |
| 21449 | AHNQIRAJ TEST ITEM C MAIL BOOTS | 1 | 1 | 0 | no | no |
| 21450 | AHNQIRAJ TEST ITEM C MAIL GLOVES | 1 | 1 | 0 | no | no |
| 21451 | AHNQIRAJ TEST ITEM C MAIL BELT | 1 | 1 | 0 | no | no |
| 22276 | Lovely Red Dress | 1 | 1 | 0 | no | no |
| 22277 | Red Dinner Suit | 1 | 1 | 0 | no | no |
| 22278 | Lovely Blue Dress | 1 | 1 | 0 | no | no |
| 22279 | Lovely Black Dress | 1 | 1 | 0 | no | no |
| 22280 | Lovely Purple Dress | 1 | 1 | 0 | no | no |
| 22281 | Blue Dinner Suit | 1 | 1 | 0 | no | no |
| 22282 | Purple Dinner Suit | 1 | 1 | 0 | no | no |
| 22999 | Tabard of the Argent Dawn | 1 | 2500 | 0 | no | no |
| 210250 | Engraved Gold Ring | 1 | 0 | 1 | no | no |
| 210251 | Engraved Silver Ring | 1 | 0 | 1 | no | no |
| 215450 | Tabard Project (Aidan) | 1 | 12500 | 0 | no | no |
| 223323 | Shirt | 1 | 7137 | 0 | no | no |
| 262764 | Durotar Supply and Logistics Tabard | 1 | 12500 | 0 | no | no |
| 262765 | Azeroth Commerce Authority Tabard | 1 | 12500 | 0 | no | no |
| 264908 | Ancient Heirloom | 1 | 0 | 0 | no | no |
| 270334 | Sweat-Stained Shirt | 1 | 5500 | 0 | no | no |
| 271618 | Rejected Roses | 1 | 125 | 0 | no | no |
| 271655 | Thendal Apprentice's Shirt | 1 | 1 | 0 | no | no |
| 271663 | Thendal Novice's Shirt | 1 | 1 | 0 | no | no |
| 271668 | Thendal Survivalist's Shirt | 1 | 1 | 0 | no | no |
| 271669 | Thendal Warrior's Shirt | 1 | 1 | 0 | no | no |
| 271675 | Grove Scoundrel's Shirt | 1 | 1 | 0 | no | no |
| 272449 | Scout's Tabard | 1 | 2500 | 0 | no | no |
| 272450 | Stone Guard's Herald | 1 | 10000 | 0 | no | no |
| 272694 | Private's Tabard | 1 | 2500 | 0 | no | no |
| 272695 | Knight's Colors | 1 | 10000 | 0 | no | no |
| 273812 | Airy Magister's Shirt | 1 | 162 | 0 | no | no |
| 273813 | Airy Peacekeeper's Shirt | 1 | 162 | 0 | no | no |
| 273814 | Airy Skyseer's Shirt | 1 | 162 | 0 | no | no |
| 273815 | Airy Windseeker's Shirt | 1 | 162 | 0 | no | no |
| 274025 | Guardians of Hyjal Tabard | 1 | 0 | 1 | no | no |
| 275042 | Farholde Keep Tabard | 1 | 12500 | 0 | no | no |
| 276502 | Darkspear Battle Tabard | 1 | 12500 | 0 | no | no |
| 276504 | Theramore Battle Tabard | 1 | 12500 | 0 | no | no |
| 280449 | Skyborne Tabard | 1 | 12500 | 0 | no | no |
| 281268 | Depleted Ritual Band | 1 | 0 | 0 | no | no |
| 281631 | Collector's Edition Tabard | 1 | 0 | 0 | no | no |
| 282294 | Guild Tabard | 1 | 2500 | 0 | no | no |
| 285327 | Kirin Tor Tabard | 1 | 0 | 1 | no | no |
| 286737 | Avala's Binding | 1 | 0 | 0 | no | no |
| 287090 | Letter Opener | 1 | 170 | 2 | no | no |

### 4/0 Armadura / Miscelánea, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1077 | Defias Mage Ring | 2 | 25 | 21 | no | no |
| 1116 | Ring of Pure Silver | 2 | 1250 | 0 | no | no |
| 1172 | Grayson's Torch | 2 | 968 | 0 | no | no |
| 1189 | Overseer's Ring | 2 | 625 | 15 | no | no |
| 1319 | Ring of Iron Will | 2 | 462 | 0 | no | no |
| 1449 | Minor Channeling Ring | 2 | 1875 | 0 | no | no |
| 1462 | Ring of the Shadow | 2 | 1306 | 20 | no | no |
| 1993 | Ogremind Ring | 2 | 2100 | 31 | no | no |
| 1996 | Voodoo Band | 2 | 1720 | 32 | no | no |
| 2043 | Ring of Forlorn Spirits | 2 | 1500 | 0 | no | no |
| 2917 | Tranquil Ring | 2 | 665 | 0 | no | no |
| 2943 | Eye of Paleth | 2 | 537 | 0 | no | no |
| 2944 | Cursed Eye of Paleth | 2 | 0 | 26 | no | no |
| 3235 | Ring of Scorn | 2 | 412 | 0 | no | no |
| 3451 | Nightglow Concoction | 2 | 607 | 0 | no | no |
| 3739 | Skull Ring | 2 | 1250 | 0 | no | no |
| 3760 | Band of the Undercity | 2 | 1500 | 0 | no | no |
| 4112 | Choker of the High Shaman | 2 | 4182 | 0 | no | no |
| 4125 | Tranquil Orb | 2 | 3142 | 0 | no | no |
| 4135 | Bloodbone Band | 2 | 1130 | 0 | no | no |
| 4430 | Ethereal Talisman | 2 | 4307 | 0 | no | no |
| 4535 | Ironforge Memorial Ring | 2 | 882 | 0 | no | no |
| 4549 | Seafire Band | 2 | 2092 | 0 | no | no |
| 4550 | Coldwater Ring | 2 | 2092 | 0 | no | no |
| 4743 | Pulsating Crystalline Shard | 2 | 5430 | 0 | no | no |
| 4836 | Fireproof Orb | 2 | 2000 | 23 | no | no |
| 4837 | Strength of Will | 2 | 2000 | 25 | no | no |
| 4838 | Orb of Power | 2 | 2000 | 21 | no | no |
| 4988 | Burning Obsidian Band | 2 | 3657 | 0 | no | no |
| 5000 | Coral Band | 2 | 962 | 21 | no | no |
| 5008 | Quicksilver Ring | 2 | 1546 | 31 | no | no |
| 5029 | Talisman of the Naga Lord | 2 | 5282 | 42 | no | no |
| 5313 | Totemic Clan Ring | 2 | 650 | 0 | no | no |
| 5351 | Bounty Hunter's Ring | 2 | 403 | 0 | no | no |
| 5611 | Tear of Grief | 2 | 452 | 0 | no | no |
| 5622 | Clergy Ring | 2 | 556 | 0 | no | no |
| 5743 | Prismstone Ring | 2 | 1803 | 35 | no | no |
| 6589 | Viridian Band | 2 | 1056 | 21 | no | no |
| 6669 | Sacred Band | 2 | 1378 | 0 | no | no |
| 6678 | Band of Elven Grace | 2 | 677 | 0 | no | no |
| 6757 | Jaina's Signet Ring | 2 | 4630 | 0 | no | no |
| 6774 | Traitor's Finger | 2 | 2885 | 35 | no | no |
| 6790 | Ring of Calm | 2 | 1540 | 0 | no | no |
| 7426 | Cerulean Ring | 2 | 1243 | 25 | no | no |
| 7427 | Cerulean Talisman | 2 | 3788 | 26 | no | no |
| 7466 | Vermilion Band | 2 | 1921 | 32 | no | no |
| 7467 | Vermilion Necklace | 2 | 5658 | 30 | no | no |
| 7497 | Ivory Band | 2 | 1983 | 35 | no | no |
| 7547 | Onyx Ring | 2 | 3092 | 41 | no | no |
| 7548 | Onyx Choker | 2 | 6507 | 41 | no | no |
| 7554 | Willow Branch | 2 | 1039 | 14 | no | no |
| 7555 | Regal Star | 2 | 7123 | 40 | no | no |
| 7556 | Twilight Orb | 2 | 5387 | 35 | no | no |
| 7558 | Shimmering Stave | 2 | 1609 | 20 | no | no |
| 7608 | Seer's Fine Stein | 2 | 1106 | 16 | no | no |
| 7609 | Elder's Amber Stave | 2 | 4210 | 30 | no | no |
| 7610 | Aurora Sphere | 2 | 5811 | 36 | no | no |
| 8663 | Mithril Insignia | 2 | 0 | 0 | no | no |
| 9362 | Brilliant Gold Ring | 2 | 0 | 0 | no | no |
| 9622 | Reedknot Ring | 2 | 5665 | 0 | no | no |
| 9642 | Band of the Great Tortoise | 2 | 2092 | 0 | no | no |
| 9644 | Thermotastic Egg Timer | 2 | 9885 | 0 | no | no |
| 9655 | Seedtime Hoop | 2 | 7092 | 0 | no | no |
| 9769 | Greenweave Branch | 2 | 1637 | 22 | no | no |
| 9800 | Ivy Orb | 2 | 2027 | 24 | no | no |
| 9882 | Sorcerer Sphere | 2 | 6209 | 38 | no | no |
| 9914 | Royal Scepter | 2 | 7557 | 43 | no | no |
| 10298 | Gnomeregan Band | 2 | 1243 | 25 | no | no |
| 10299 | Gnomeregan Amulet | 2 | 3778 | 26 | no | no |
| 10659 | Shard of the Splithooves | 2 | 4662 | 0 | no | no |
| 10708 | Skullspell Orb | 2 | 8982 | 0 | no | no |
| 10709 | Pyrestone Orb | 2 | 10953 | 0 | no | no |
| 10739 | Ring of Fortitude | 2 | 5292 | 0 | no | no |
| 10778 | Necklace of Sanctuary | 2 | 16930 | 0 | no | no |
| 10779 | Demon's Blood | 2 | 16580 | 0 | no | no |
| 11196 | Mindburst Medallion | 2 | 16875 | 0 | no | no |
| 11855 | Tork Wrench | 2 | 782 | 0 | no | no |
| 11859 | Jademoon Orb | 2 | 7135 | 0 | no | no |
| 11862 | White Bone Band | 2 | 7042 | 0 | no | no |
| 11868 | Choking Band | 2 | 6542 | 0 | no | no |
| 11869 | Sha'ni's Ring | 2 | 6542 | 0 | no | no |
| 11870 | Oblivion Orb | 2 | 10287 | 0 | no | no |
| 11945 | Dark Iron Ring | 2 | 6592 | 48 | no | no |
| 11946 | Fire Opal Necklace | 2 | 7912 | 47 | no | no |
| 12102 | Ring of the Aristocrat | 2 | 9042 | 0 | no | no |
| 13371 | Father Flame | 2 | 6657 | 0 | no | no |
| 13473 | Felstone Good Luck Charm | 2 | 7164 | 0 | no | no |
| 13475 | Dalson Family Wedding Ring | 2 | 8109 | 0 | no | no |
| 13811 | Necklace of the Dawn | 2 | 8988 | 0 | no | no |
| 13812 | Ring of the Dawn | 2 | 8303 | 0 | no | no |
| 15206 | Jadefinger Baton | 2 | 857 | 0 | no | no |
| 15467 | Inventor's League Ring | 2 | 8630 | 0 | no | no |
| 15689 | Trader's Ring | 2 | 4040 | 0 | no | no |
| 15690 | Kodobone Necklace | 2 | 4912 | 0 | no | no |
| 15702 | Chemist's Ring | 2 | 7396 | 0 | no | no |
| 15704 | Hunter's Insignia Medal | 2 | 6145 | 0 | no | no |
| 15799 | Heroic Commendation Medal | 2 | 7108 | 0 | no | no |
| 15912 | Buccaneer's Orb | 2 | 1148 | 18 | no | no |
| 15918 | Conjurer's Sphere | 2 | 4848 | 33 | no | no |
| 15925 | Journeyman's Stave | 2 | 439 | 5 | no | no |
| 15926 | Spellbinder Orb | 2 | 802 | 12 | no | no |
| 15927 | Bright Sphere | 2 | 1864 | 22 | no | no |
| 15928 | Silver-thread Rod | 2 | 2387 | 26 | no | no |
| 15929 | Nightsky Orb | 2 | 4396 | 32 | no | no |
| 15930 | Imperial Red Scepter | 2 | 9146 | 51 | no | no |
| 15931 | Arcane Star | 2 | 10646 | 56 | no | no |
| 15932 | Disciple's Stein | 2 | 527 | 7 | no | no |
| 15933 | Simple Branch | 2 | 620 | 10 | no | no |
| 15934 | Sage's Stave | 2 | 2596 | 27 | no | no |
| 15935 | Durable Rod | 2 | 3323 | 29 | no | no |
| 15936 | Duskwoven Branch | 2 | 8950 | 50 | no | no |
| 15937 | Hibernal Sphere | 2 | 7922 | 46 | no | no |
| 15938 | Mystical Orb | 2 | 9550 | 53 | no | no |
| 15939 | Councillor's Scepter | 2 | 10455 | 54 | no | no |
| 15940 | Elegant Scepter | 2 | 10957 | 57 | no | no |
| 15941 | High Councillor's Scepter | 2 | 12345 | 59 | no | no |
| 15942 | Master's Rod | 2 | 12757 | 60 | no | no |
| 15944 | Ancestral Orb | 2 | 512 | 7 | no | no |
| 15945 | Runic Stave | 2 | 837 | 13 | no | no |
| 15946 | Mystic's Sphere | 2 | 802 | 18 | no | no |
| 15947 | Sanguine Star | 2 | 1887 | 23 | no | no |
| 15962 | Satyr's Rod | 2 | 2716 | 28 | no | no |
| 15963 | Stonecloth Branch | 2 | 4887 | 34 | no | no |
| 15964 | Silksand Star | 2 | 6364 | 39 | no | no |
| 15966 | Venomshroud Orb | 2 | 9137 | 49 | no | no |
| 15967 | Highborne Star | 2 | 10304 | 54 | no | no |
| 15968 | Elunarian Sphere | 2 | 802 | 59 | no | no |
| 15969 | Beaded Orb | 2 | 425 | 5 | no | no |
| 15970 | Native Branch | 2 | 587 | 10 | no | no |
| 15971 | Aboriginal Rod | 2 | 1064 | 15 | no | no |
| 15972 | Ritual Stein | 2 | 1171 | 19 | no | no |
| 15973 | Watcher's Star | 2 | 2313 | 25 | no | no |
| 15974 | Pagan Rod | 2 | 1461 | 21 | no | no |
| 15975 | Raincaller Scepter | 2 | 2421 | 26 | no | no |
| 15976 | Thistlefur Branch | 2 | 4146 | 31 | no | no |
| 15977 | Vital Orb | 2 | 4614 | 32 | no | no |
| 15978 | Geomancer's Rod | 2 | 5385 | 36 | no | no |
| 15979 | Embersilk Stave | 2 | 7215 | 37 | no | no |
| 15980 | Darkmist Orb | 2 | 7469 | 41 | no | no |
| 15981 | Lunar Sphere | 2 | 7215 | 42 | no | no |
| 15982 | Bloodwoven Rod | 2 | 8142 | 46 | no | no |
| 15983 | Gaea's Scepter | 2 | 8387 | 47 | no | no |
| 15984 | Opulent Scepter | 2 | 9614 | 51 | no | no |
| 15985 | Arachnidian Branch | 2 | 9887 | 52 | no | no |
| 15986 | Bonecaster's Star | 2 | 10813 | 55 | no | no |
| 15987 | Astral Orb | 2 | 10996 | 56 | no | no |
| 15988 | Resplendent Orb | 2 | 12471 | 58 | no | no |
| 15989 | Eternal Rod | 2 | 12498 | 60 | no | no |
| 16123 | Test Nature Res Neck | 2 | 5395 | 30 | no | no |
| 16124 | Test Frost Res Neck | 2 | 5395 | 30 | no | no |
| 16125 | Test Arcane Res Neck | 2 | 5395 | 30 | no | no |
| 16623 | Opaline Medallion | 2 | 7783 | 0 | no | no |
| 17000 | Band of the Wraith | 2 | 10314 | 0 | no | no |
| 17692 | Horn Ring | 2 | 881 | 0 | no | no |
| 18400 | Ring of Living Stone | 2 | 14853 | 0 | no | no |
| 18402 | Glowing Crystal Ring | 2 | 18662 | 0 | no | no |
| 19038 | Ring of Subtlety | 2 | 11145 | 0 | no | no |
| 19115 | Flask of Forest Mojo | 2 | 11003 | 0 | no | no |
| 19574 | Strength of Mugamba | 2 | 0 | 0 | no | no |
| 19579 | Heathen's Brand | 2 | 0 | 0 | no | no |
| 19591 | The Eye of Zuldazar | 2 | 0 | 0 | no | no |
| 19598 | Pebble of Kajaro | 2 | 0 | 0 | no | no |
| 19602 | Kezan's Taint | 2 | 0 | 0 | no | no |
| 19606 | Vision of Voodress | 2 | 0 | 0 | no | no |
| 19610 | Enchanted South Seas Kelp | 2 | 0 | 0 | no | no |
| 19614 | Zandalarian Shadow Talisman | 2 | 0 | 0 | no | no |
| 19618 | Maelstrom's Tendril | 2 | 0 | 0 | no | no |
| 20248 | 90 Green Warrior Neck | 2 | 7108 | 60 | no | no |
| 20250 | 90 Green Warrior Ring | 2 | 7888 | 0 | no | no |
| 20288 | 63 Green Warrior Neck | 2 | 7108 | 58 | no | no |
| 20290 | 63 Green Warrior Ring | 2 | 7888 | 58 | no | no |
| 20305 | 90 Green Rogue Neck | 2 | 15038 | 60 | no | no |
| 20307 | 90 Green Rogue Ring | 2 | 7102 | 60 | no | no |
| 20319 | 63 Green Rogue Neck | 2 | 15038 | 58 | no | no |
| 20321 | 63 Green Rogue Ring | 2 | 7102 | 58 | no | no |
| 20345 | 90 Green Frost Neck | 2 | 12157 | 60 | no | no |
| 20346 | 90 Green Frost Ring | 2 | 15457 | 60 | no | no |
| 20358 | 63 Green Frost Neck | 2 | 12157 | 58 | no | no |
| 20359 | 63 Green Frost Ring | 2 | 15457 | 58 | no | no |
| 20645 | Nature's Whisper | 2 | 21785 | 0 | no | no |
| 20649 | Sunprism Pendant | 2 | 22425 | 0 | no | no |
| 20692 | Multicolored Band | 2 | 13362 | 55 | no | no |
| 259892 | Feardred's Cleansed Amulet | 2 | 5396 | 0 | no | no |
| 260171 | Timbermaw Prayer Beads | 2 | 5396 | 0 | no | no |
| 260201 | Highborne Memory Crystal | 2 | 8982 | 0 | no | no |
| 260208 | Prelate's Orb | 2 | 8982 | 0 | no | no |
| 270050 | Fury Ring | 2 | 1713 | 0 | no | no |
| 270051 | Ladimore Heirloom Ring | 2 | 2144 | 0 | no | no |
| 270052 | Swamp Ring | 2 | 2144 | 0 | no | no |
| 270053 | Ring of Ruin | 2 | 2144 | 0 | no | no |
| 270109 | Smotts' Pinky Ring | 2 | 7092 | 0 | no | no |
| 270112 | Gryphon Rider's Crop | 2 | 8142 | 0 | no | no |
| 271670 | Curl of Life | 2 | 10709 | 0 | no | no |
| 271806 | Survivor's Amulet | 2 | 5633 | 1 | no | no |
| 271807 | Weathered Necklace | 2 | 5653 | 1 | no | no |
| 271808 | Scavenger's Ring | 2 | 5674 | 1 | no | no |
| 271809 | Desolate Band | 2 | 5694 | 1 | no | no |
| 272184 | Amulet of Vengeance | 2 | 5653 | 1 | no | no |
| 272185 | Amulet of Forgiveness | 2 | 5653 | 1 | no | no |
| 273800 | Thomas's Ring | 2 | 15251 | 0 | no | no |
| 274384 | Illegible Dogtags | 2 | 15192 | 0 | no | no |
| 274746 | Sea Giant's Toe Ring | 2 | 2955 | 30 | no | no |
| 274915 | Sacristan Band | 2 | 4554 | 0 | no | no |
| 274955 | Clobrok's Block Rock | 2 | 5736 | 0 | no | no |
| 274961 | Brute Slayer Band | 2 | 4325 | 0 | no | no |
| 275685 | Stormwind Intelligence Seal | 2 | 15475 | 0 | no | no |
| 275831 | Highfeather Bangle | 2 | 15084 | 0 | no | no |
| 275838 | Dirtwalker Pendant | 2 | 15470 | 0 | no | no |
| 276202 | Disengagement Ring | 2 | 4713 | 40 | no | no |
| 276333 | Sawyer Family Seal | 2 | 16015 | 0 | no | no |
| 276336 | Yashiro's Spirit Bead | 2 | 16197 | 0 | no | no |
| 276900 | Denric's Dog Tags | 2 | 0 | 1 | no | no |
| 276904 | Shimmerwine Spirits | 2 | 0 | 1 | no | no |
| 277203 | Scholarly Pendant | 2 | 0 | 0 | no | no |
| 277204 | Erudite's Amulet | 2 | 0 | 0 | no | no |
| 277208 | Determined Band | 2 | 0 | 0 | no | no |
| 277209 | Ponderous Loop | 2 | 0 | 0 | no | no |
| 277980 | Ogre Bone | 2 | 0 | 1 | no | no |
| 277981 | Souvenir Ogre Tooth | 2 | 0 | 1 | no | no |
| 278017 | Refunded Ring | 2 | 0 | 1 | no | no |
| 278018 | Renegotiated Ring | 2 | 0 | 1 | no | no |
| 278019 | Apology Ring | 2 | 0 | 1 | no | no |
| 281252 | Harpy Claw Ring | 2 | 0 | 0 | no | no |
| 281258 | Essene's Hope | 2 | 0 | 0 | no | no |
| 281265 | Roadwatcher's Confidence | 2 | 0 | 0 | no | no |
| 281281 | Frost's Whisper Pendant | 2 | 0 | 0 | no | no |
| 281286 | High Order Pendant | 2 | 0 | 0 | no | no |
| 281287 | Windshaper Pendant | 2 | 0 | 0 | no | no |
| 281288 | Shen'dorei Signet | 2 | 0 | 0 | no | no |
| 281290 | Replica Crescent Necklace | 2 | 0 | 0 | no | no |
| 281294 | Expended Apothecary Vial | 2 | 0 | 0 | no | no |
| 281302 | Whelpscale Necklace | 2 | 0 | 0 | no | no |
| 281304 | Prospector's Signet | 2 | 0 | 0 | no | no |
| 281306 | Flamescarred Spellbook | 2 | 0 | 0 | no | no |
| 281318 | Bouquet of Auberdine Flowers | 2 | 0 | 0 | no | no |
| 281673 | Loop of Sacrifice | 2 | 0 | 0 | no | no |
| 281718 | Restored Ring | 2 | 1 | 1 | no | no |
| 281719 | Restored Necklace | 2 | 1 | 1 | no | no |
| 281730 | Restored Bauble | 2 | 1 | 1 | no | no |
| 281927 | Boulderheart Band | 2 | 903 | 22 | no | no |
| 282026 | Unyielding Battle Signet | 2 | 1875 | 53 | no | no |

### 4/0 Armadura / Miscelánea, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2933 | Seal of Wrynn | 3 | 3750 | 0 | no | no |
| 9417 | Archaedic Shard | 3 | 10795 | 42 | no | no |
| 15200 | Senior Sergeant's Insignia | 3 | 5000 | 30 | no | no |
| 15855 | Ring of Protection | 3 | 7888 | 0 | no | no |
| 15856 | Archlight Talisman | 3 | 8788 | 0 | no | no |
| 15857 | Magebane Scion | 3 | 15335 | 0 | no | no |
| 16067 | Test Fire Res Ring | 3 | 0 | 0 | no | no |
| 16309 | Drakefire Amulet | 3 | 0 | 50 | no | no |
| 16335 | Senior Sergeant's Insignia | 3 | 10000 | 58 | no | no |
| 16999 | Royal Seal of Alexis | 3 | 10709 | 54 | no | no |
| 18023 | Blood Ruby Pendant | 3 | 15538 | 54 | no | no |
| 18398 | Tidal Loop | 3 | 27103 | 0 | no | no |
| 18399 | Ocean's Breeze | 3 | 27103 | 0 | no | no |
| 18428 | Senior Sergeant's Insignia | 3 | 7500 | 45 | no | no |
| 18442 | Master Sergeant's Insignia | 3 | 5000 | 30 | no | no |
| 18443 | Master Sergeant's Insignia | 3 | 10000 | 58 | no | no |
| 18444 | Master Sergeant's Insignia | 3 | 7500 | 45 | no | no |
| 18585 | Band of Allegiance | 3 | 14853 | 0 | no | no |
| 18586 | Lonetree's Circle | 3 | 14853 | 0 | no | no |
| 18602 | Tome of Sacrifice | 3 | 0 | 0 | no | no |
| 18760 | Necromantic Band | 3 | 30866 | 57 | no | no |
| 18762 | Shard of the Green Flame | 3 | 27631 | 0 | no | no |
| 19065 | Emerald Circle | 3 | 17831 | 0 | no | no |
| 19095 | Frostwolf Legionnaire's Pendant | 3 | 17912 | 55 | no | no |
| 19096 | Frostwolf Advisor's Pendant | 3 | 17912 | 55 | no | no |
| 19097 | Stormpike Soldier's Pendant | 3 | 17912 | 55 | no | no |
| 19098 | Stormpike Sage's Pendant | 3 | 17912 | 55 | no | no |
| 19109 | Deep Rooted Ring | 3 | 33920 | 58 | no | no |
| 19122 | Woven Ivy Necklace DEPRECATED | 3 | 21141 | 0 | no | no |
| 19159 | Woven Ivy Necklace | 3 | 21141 | 0 | no | no |
| 19302 | Darkmoon Ring | 3 | 12500 | 50 | no | no |
| 19303 | Darkmoon Necklace | 3 | 12500 | 50 | no | no |
| 19510 | Legionnaire's Band | 3 | 18750 | 58 | no | no |
| 19511 | Legionnaire's Band | 3 | 15000 | 48 | no | no |
| 19512 | Legionnaire's Band | 3 | 11250 | 38 | no | no |
| 19513 | Legionnaire's Band | 3 | 5000 | 28 | no | no |
| 19514 | Protector's Band | 3 | 18750 | 58 | no | no |
| 19515 | Protector's Band | 3 | 11250 | 38 | no | no |
| 19516 | Protector's Band | 3 | 15000 | 48 | no | no |
| 19517 | Protector's Band | 3 | 5000 | 28 | no | no |
| 19518 | Advisor's Ring | 3 | 18750 | 58 | no | no |
| 19519 | Advisor's Ring | 3 | 15000 | 48 | no | no |
| 19520 | Advisor's Ring | 3 | 11250 | 38 | no | no |
| 19521 | Advisor's Ring | 3 | 5000 | 28 | no | no |
| 19522 | Lorekeeper's Ring | 3 | 18750 | 58 | no | no |
| 19523 | Lorekeeper's Ring | 3 | 15000 | 48 | no | no |
| 19524 | Lorekeeper's Ring | 3 | 11250 | 38 | no | no |
| 19525 | Lorekeeper's Ring | 3 | 5000 | 28 | no | no |
| 19534 | Scout's Medallion | 3 | 18750 | 58 | no | no |
| 19535 | Scout's Medallion | 3 | 15000 | 48 | no | no |
| 19536 | Scout's Medallion | 3 | 11250 | 38 | no | no |
| 19537 | Scout's Medallion | 3 | 5000 | 28 | no | no |
| 19538 | Sentinel's Medallion | 3 | 18750 | 58 | no | no |
| 19539 | Sentinel's Medallion | 3 | 15000 | 48 | no | no |
| 19540 | Sentinel's Medallion | 3 | 11250 | 38 | no | no |
| 19541 | Sentinel's Medallion | 3 | 5000 | 28 | no | no |
| 19575 | Strength of Mugamba | 3 | 0 | 0 | no | no |
| 19576 | Strength of Mugamba | 3 | 0 | 0 | no | no |
| 19585 | Heathen's Brand | 3 | 0 | 0 | no | no |
| 19586 | Heathen's Brand | 3 | 0 | 0 | no | no |
| 19592 | The Eye of Zuldazar | 3 | 0 | 0 | no | no |
| 19593 | The Eye of Zuldazar | 3 | 0 | 0 | no | no |
| 19599 | Pebble of Kajaro | 3 | 0 | 0 | no | no |
| 19600 | Pebble of Kajaro | 3 | 0 | 0 | no | no |
| 19603 | Kezan's Taint | 3 | 0 | 0 | no | no |
| 19604 | Kezan's Taint | 3 | 0 | 0 | no | no |
| 19607 | Vision of Voodress | 3 | 0 | 0 | no | no |
| 19608 | Vision of Voodress | 3 | 0 | 0 | no | no |
| 19611 | Enchanted South Seas Kelp | 3 | 0 | 0 | no | no |
| 19612 | Enchanted South Seas Kelp | 3 | 0 | 0 | no | no |
| 19615 | Zandalarian Shadow Talisman | 3 | 0 | 0 | no | no |
| 19616 | Zandalarian Shadow Talisman | 3 | 0 | 0 | no | no |
| 19619 | Maelstrom's Tendril | 3 | 0 | 0 | no | no |
| 19620 | Maelstrom's Tendril | 3 | 0 | 0 | no | no |
| 19989 | Tome of Devouring Shadows | 3 | 0 | 0 | no | no |
| 20426 | Advisor's Ring | 3 | 5000 | 18 | no | no |
| 20429 | Legionnaire's Band | 3 | 5000 | 18 | no | no |
| 20431 | Lorekeeper's Ring | 3 | 5000 | 18 | no | no |
| 20439 | Protector's Band | 3 | 5000 | 18 | no | no |
| 20442 | Scout's Medallion | 3 | 5000 | 18 | no | no |
| 20444 | Sentinel's Medallion | 3 | 5000 | 18 | no | no |
| 20445 | Test Defense Ring +120 | 3 | 7888 | 0 | no | no |
| 20446 | Test Defense Ring +80 | 3 | 7888 | 0 | no | no |
| 20695 | Abyssal War Beads | 3 | 36253 | 58 | no | no |
| 20721 | Band of the Cultist | 3 | 38790 | 60 | no | no |
| 21179 | Band of Earthen Wrath | 3 | 10709 | 0 | no | no |
| 21182 | Band of Earthen Might | 3 | 10709 | 0 | no | no |
| 21477 | Ring of Fury | 3 | 88503 | 60 | no | no |
| 21483 | Ring of the Desert Winds | 3 | 75303 | 60 | no | no |
| 21809 | Fury of the Forgotten Swarm | 3 | 48655 | 60 | no | no |
| 22149 | Beads of Ogre Mojo | 3 | 10283 | 0 | no | no |
| 22150 | Beads of Ogre Might | 3 | 10283 | 0 | no | no |
| 22680 | Band of Resolution | 3 | 10709 | 0 | no | no |
| 22681 | Band of Piety | 3 | 10709 | 0 | no | no |
| 22725 | Band of Cenarius | 3 | 38790 | 0 | no | no |
| 23125 | Chains of the Lich | 3 | 41953 | 55 | no | no |
| 23169 | Scorn's Icy Choker | 3 | 3482 | 30 | no | no |
| 221344 | Personal Spellbook | 3 | 0 | 0 | no | no |
| 249394 | Orb of Mystic Insight | 3 | 499 | 25 | no | no |
| 249395 | Orb of Souls | 3 | 496 | 25 | no | no |
| 249455 | Truesilver Conduit | 3 | 2156 | 45 | no | no |
| 249456 | Twisting Essence Jar | 3 | 2156 | 45 | no | no |
| 271805 | Thrice-Damned Effigy | 3 | 6072 | 35 | no | no |
| 271908 | Theramore Signet | 3 | 24115 | 58 | no | no |
| 271909 | Theramore Signet | 3 | 12819 | 48 | no | no |
| 271910 | Theramore Signet | 3 | 6362 | 38 | no | no |
| 271911 | Theramore Signet | 3 | 2749 | 28 | no | no |
| 271913 | Militant's Band | 3 | 22233 | 58 | no | no |
| 271914 | Militant's Band | 3 | 13066 | 48 | no | no |
| 271915 | Militant's Band | 3 | 6485 | 38 | no | no |
| 271916 | Militant's Band | 3 | 2802 | 28 | no | no |
| 271917 | Seal of the Expedition | 3 | 22572 | 58 | no | no |
| 271918 | Seal of the Expedition | 3 | 13264 | 48 | no | no |
| 271919 | Seal of the Expedition | 3 | 6760 | 38 | no | no |
| 271920 | Seal of the Expedition | 3 | 2920 | 28 | no | no |
| 272064 | Insurgent's Band | 3 | 24115 | 58 | no | no |
| 272065 | Insurgent's Band | 3 | 12819 | 48 | no | no |
| 272066 | Insurgent's Band | 3 | 6362 | 38 | no | no |
| 272067 | Insurgent's Band | 3 | 2749 | 28 | no | no |
| 272068 | Darkspear Signet | 3 | 22233 | 58 | no | no |
| 272069 | Darkspear Signet | 3 | 13066 | 48 | no | no |
| 272070 | Darkspear Signet | 3 | 6485 | 38 | no | no |
| 272071 | Darkspear Signet | 3 | 2802 | 28 | no | no |
| 272072 | Darkspear Warding Pendant | 3 | 22572 | 58 | no | no |
| 272073 | Darkspear Warding Pendant | 3 | 13264 | 48 | no | no |
| 272074 | Darkspear Warding Pendant | 3 | 6760 | 38 | no | no |
| 272075 | Darkspear Warding Pendant | 3 | 2920 | 28 | no | no |
| 272406 | Channeler's Ring | 3 | 23961 | 60 | no | no |
| 272407 | Blessed Band of Light | 3 | 23961 | 60 | no | no |
| 272408 | Cutthroat's Signet | 3 | 23961 | 60 | no | no |
| 272409 | Ring of Awareness | 3 | 23961 | 60 | no | no |
| 274417 | Barkskin Baubles | 3 | 164835 | 53 | no | no |
| 274743 | Defective Samophlange | 3 | 1316 | 20 | no | no |
| 274749 | Souvenir Sea Shell | 3 | 3328 | 30 | no | no |
| 274754 | Suspicious Spare Part | 3 | 7597 | 40 | no | no |
| 274968 | Premier Senior Sergeant's Insignia | 3 | 0 | 55 | no | no |
| 274969 | Premier Master Sergeant's Insignia | 3 | 0 | 55 | no | no |
| 275043 | Bloodmaster's Ring | 3 | 7886 | 0 | no | no |
| 275044 | Bloodsport Band | 3 | 7915 | 0 | no | no |
| 275045 | Ogre Horn Ring | 3 | 7943 | 0 | no | no |
| 275736 | Horn of Ve'han | 3 | 20797 | 0 | no | no |
| 275738 | Jereman's Bauble | 3 | 20952 | 0 | no | no |
| 275740 | Ring of Nature's Cycles | 3 | 21104 | 0 | no | no |
| 275968 | Initiate's Signet of Ferocity | 3 | 0 | 60 | no | no |
| 275969 | Initiate's Signet of Brilliance | 3 | 0 | 60 | no | no |
| 275970 | Initiate's Signet of Resolve | 3 | 0 | 60 | no | no |
| 275971 | Initiate's Signet of Vigilance | 3 | 0 | 60 | no | no |
| 275972 | Tracker's Signet of Ferocity | 3 | 0 | 60 | no | no |
| 275973 | Tracker's Signet of Brilliance | 3 | 0 | 60 | no | no |
| 275974 | Tracker's Signet of Resolve | 3 | 0 | 60 | no | no |
| 275975 | Tracker's Signet of Vigilance | 3 | 0 | 60 | no | no |
| 276273 | Empty Fish Bucket | 3 | 0 | 1 | no | no |
| 276897 | A Lesson in Destruction | 3 | 0 | 1 | no | no |
| 276898 | Salve and Salvation | 3 | 0 | 1 | no | no |
| 276899 | Knucklebound Thimble | 3 | 0 | 1 | no | no |
| 277202 | Artifact Seeker's Pendant | 3 | 0 | 0 | no | no |
| 277210 | Pyrewood Signet Ring | 3 | 0 | 0 | no | no |
| 277259 | Fermented Restoration Potion | 3 | 0 | 40 | no | no |
| 277260 | Researcher's Night Light | 3 | 0 | 40 | no | no |
| 277717 | Spectral Bear Tabard | 3 | 0 | 0 | no | no |
| 281291 | Mathystra Channeling Orb | 3 | 0 | 0 | no | no |
| 281292 | Onu's Patience | 3 | 0 | 0 | no | no |
| 281320 | Rune-Etched Ring | 3 | 0 | 0 | no | no |
| 281321 | Giantstone Medallion | 3 | 0 | 0 | no | no |
| 281634 | Field Researcher's Loop | 3 | 0 | 0 | no | no |
| 281635 | Philanthropist's Ring | 3 | 0 | 0 | no | no |
| 281636 | Museum Keeper's Chain | 3 | 0 | 0 | no | no |
| 281657 | Corrupted Riverglades Pendant | 3 | 4912 | 36 | no | no |
| 282283 | Malignant Root | 3 | 0 | 1 | no | no |

### 4/0 Armadura / Miscelánea, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18403 | Dragonslayer's Signet | 4 | 49060 | 0 | no | no |
| 18404 | Onyxia Tooth Pendant | 4 | 6714 | 0 | no | no |
| 18543 | Ring of Entropy | 4 | 63728 | 60 | no | no |
| 18665 | The Eye of Shadow | 4 | 0 | 60 | no | no |
| 18814 | Choker of the Fire Lord | 4 | 89135 | 60 | no | no |
| 18821 | Quick Strike Ring | 4 | 64030 | 60 | no | no |
| 18879 | Heavy Dark Iron Ring | 4 | 53364 | 60 | no | no |
| 18968 | Ring of Critical Testing | 4 | 56012 | 0 | no | no |
| 18970 | Ring of Critical Testing 2 | 4 | 56012 | 0 | no | no |
| 18982 | Ring of Critical Testing 4 | 4 | 56012 | 0 | no | no |
| 19138 | Band of Sulfuras | 4 | 79853 | 60 | no | no |
| 19140 | Cauterizing Band | 4 | 60256 | 60 | no | no |
| 19147 | Ring of Spell Power | 4 | 91453 | 60 | no | no |
| 19308 | Tome of Arcane Domination | 4 | 125000 | 55 | no | no |
| 19309 | Tome of Shadow Force | 4 | 125000 | 55 | no | no |
| 19310 | Tome of the Ice Lord | 4 | 125000 | 55 | no | no |
| 19311 | Tome of Fiery Arcana | 4 | 125000 | 55 | no | no |
| 19312 | Lei of the Lifegiver | 4 | 125000 | 55 | no | no |
| 19315 | Therazane's Touch | 4 | 125000 | 55 | no | no |
| 19325 | Don Julio's Band | 4 | 188888 | 55 | no | no |
| 19366 | Master Dragonslayer's Orb | 4 | 203059 | 60 | no | no |
| 19371 | Pendant of the Fallen Dragon | 4 | 88355 | 60 | no | no |
| 19376 | Archimtiros' Ring of Reckoning | 4 | 111528 | 60 | no | no |
| 19377 | Prestor's Talisman of Connivery | 4 | 105328 | 60 | no | no |
| 19379 | Neltharion's Tear | 4 | 205863 | 60 | no | no |
| 19382 | Pure Elementium Band | 4 | 128280 | 60 | no | no |
| 19383 | Master Dragonslayer's Medallion | 4 | 128862 | 60 | no | no |
| 19384 | Master Dragonslayer's Ring | 4 | 130616 | 60 | no | no |
| 19395 | Rejuvenating Gem | 4 | 103103 | 60 | no | no |
| 19397 | Ring of Blackrock | 4 | 107438 | 60 | no | no |
| 19403 | Band of Forced Concentration | 4 | 105328 | 60 | no | no |
| 19406 | Drake Fang Talisman | 4 | 91160 | 60 | no | no |
| 19426 | Orb of the Darkmoon | 4 | 25000 | 60 | no | no |
| 19431 | Styleen's Impeding Scarab | 4 | 103117 | 60 | no | no |
| 19432 | Circle of Applied Force | 4 | 147286 | 60 | no | no |
| 19434 | Band of Dark Dominion | 4 | 80863 | 60 | no | no |
| 19491 | Amulet of the Darkmoon | 4 | 25000 | 60 | no | no |
| 20143 | 90 Epic Warrior Neck | 4 | 7108 | 0 | no | no |
| 20144 | 90 Epic Warrior Ring | 4 | 7888 | 0 | no | no |
| 20275 | 90 Epic Rogue Neck | 4 | 15038 | 60 | no | no |
| 20277 | 90 Epic Rogue Ring | 4 | 7102 | 60 | no | no |
| 20332 | 90 Epic Frost Neck | 4 | 12157 | 60 | no | no |
| 20333 | 90 Epic Frost Ring | 4 | 15457 | 60 | no | no |
| 20600 | Malfurion's Signet Ring | 4 | 98660 | 60 | no | no |
| 20622 | Dragonheart Necklace | 4 | 114103 | 60 | no | no |
| 20624 | Ring of the Unliving | 4 | 143303 | 60 | no | no |
| 20632 | Mindtear Band | 4 | 101281 | 60 | no | no |
| 20682 | Elemental Focus Band | 4 | 73553 | 60 | no | no |
| 20685 | Wavefront Necklace | 4 | 61617 | 60 | no | no |
| 21185 | Earthcalm Orb | 4 | 10452 | 0 | no | no |
| 21189 | Might of Cenarius | 4 | 188888 | 0 | no | no |
| 21196 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21197 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21198 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21199 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21200 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21201 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21202 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21203 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21204 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21205 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21206 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21207 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21208 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21209 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21210 | Signet Ring of the Bronze Dragonflight | 4 | 0 | 60 | no | no |
| 21504 | Charm of the Shifting Sands | 4 | 111628 | 60 | no | no |
| 21505 | Choker of the Shifting Sands | 4 | 111628 | 60 | no | no |
| 21506 | Pendant of the Shifting Sands | 4 | 111628 | 60 | no | no |
| 21507 | Amulet of the Shifting Sands | 4 | 111628 | 60 | no | no |
| 21529 | Amulet of Shadow Shielding | 4 | 90788 | 60 | no | no |
| 21531 | Drake Tooth Necklace | 4 | 103030 | 60 | no | no |
| 21563 | Don Rodrigo's Band | 4 | 188888 | 60 | no | no |
| 21596 | Ring of the Godslayer | 4 | 89033 | 60 | no | no |
| 21597 | Royal Scepter of Vek'lor | 4 | 72651 | 60 | no | no |
| 21601 | Ring of Emperor Vek'lor | 4 | 79025 | 60 | no | no |
| 21608 | Amulet of Vek'nilash | 4 | 102777 | 60 | no | no |
| 21620 | Ring of the Martyr | 4 | 88661 | 60 | no | no |
| 21664 | Barbed Choker | 4 | 86443 | 60 | no | no |
| 21677 | Ring of the Qiraji Fury | 4 | 96853 | 60 | no | no |
| 21678 | Necklace of Purity | 4 | 99641 | 60 | no | no |
| 21681 | Ring of the Devoured | 4 | 91369 | 60 | no | no |
| 21687 | Ukko's Ring of Darkness | 4 | 102995 | 60 | no | no |
| 21690 | Angelista's Charm | 4 | 73749 | 60 | no | no |
| 21695 | Angelista's Touch | 4 | 90277 | 60 | no | no |
| 21700 | Pendant of the Qiraji Guardian | 4 | 90535 | 60 | no | no |
| 21702 | Amulet of Foul Warding | 4 | 78630 | 60 | no | no |
| 21707 | Ring of Swarming Thought | 4 | 85399 | 60 | no | no |
| 21709 | Ring of the Fallen God | 4 | 113642 | 60 | no | no |
| 21712 | Amulet of the Fallen God | 4 | 115200 | 60 | no | no |
| 21836 | Ritssyn's Ring of Chaos | 4 | 96853 | 60 | no | no |
| 22657 | Amulet of the Dawn | 4 | 33625 | 0 | no | no |
| 22659 | Medallion of the Dawn | 4 | 33625 | 0 | no | no |
| 22707 | Ramaladni's Icy Grasp | 4 | 98660 | 0 | no | no |
| 22732 | Mark of C'Thun | 4 | 86443 | 60 | no | no |
| 22935 | Touch of Frost | 4 | 88355 | 60 | no | no |
| 22939 | Band of Unanswered Prayers | 4 | 60256 | 60 | no | no |
| 22943 | Malice Stone Pendant | 4 | 102777 | 60 | no | no |
| 22947 | Pendant of Forgotten Names | 4 | 88355 | 60 | no | no |
| 22961 | Band of Reanimation | 4 | 113642 | 60 | no | no |
| 22981 | Gluth's Missing Collar | 4 | 128862 | 60 | no | no |
| 23018 | Signet of the Fallen Defender | 4 | 60256 | 60 | no | no |
| 23023 | Sadist's Collar | 4 | 86443 | 60 | no | no |
| 23025 | Seal of the Damned | 4 | 60256 | 60 | no | no |
| 23028 | Hailstone Band | 4 | 98660 | 60 | no | no |
| 23031 | Band of the Inevitable | 4 | 60256 | 60 | no | no |
| 23036 | Necklace of Necropsy | 4 | 88355 | 60 | no | no |
| 23037 | Ring of Spiritual Fervor | 4 | 60256 | 60 | no | no |
| 23038 | Band of Unnatural Forces | 4 | 60256 | 60 | no | no |
| 23053 | Stormrage's Talisman of Seething | 4 | 86443 | 60 | no | no |
| 23057 | Gem of Trapped Innocents | 4 | 102777 | 60 | no | no |
| 23058 | Life Channeling Necklace | 4 | 88355 | 60 | no | no |
| 23206 | Mark of the Champion | 4 | 0 | 0 | no | no |
| 23207 | Mark of the Champion | 4 | 0 | 0 | no | no |
| 23237 | Ring of the Eternal Flame | 4 | 60256 | 60 | no | no |
| 23452 | Grand Marshal's Tome of Power | 4 | 75452 | 60 | no | no |
| 23453 | Grand Marshal's Tome of Restoration | 4 | 75452 | 60 | no | no |
| 23468 | High Warlord's Tome of Destruction | 4 | 75452 | 60 | no | no |
| 23469 | High Warlord's Tome of Mending | 4 | 75452 | 60 | no | no |
| 24358 | QATest +1000 Spell Dmg Ring | 4 | 91453 | 1 | no | no |
| 191481 | Tabard of Mastery | 4 | 0 | 0 | no | no |
| 272685 | Premier High Warlord's Tome of Destruction | 4 | 0 | 60 | no | no |
| 272686 | Premier High Warlord's Tome of Mending | 4 | 0 | 60 | no | no |
| 274683 | QA Tabard of Weighted Dice | 4 | 0 | 1 | no | no |
| 275976 | Watcher's Signet of Ferocity | 4 | 0 | 60 | no | no |
| 275977 | Watcher's Signet of Brilliance | 4 | 0 | 60 | no | no |
| 275979 | Watcher's Signet of Resolve | 4 | 0 | 60 | no | no |
| 275980 | Watcher's Signet of Vigilance | 4 | 0 | 60 | no | no |
| 275981 | Warden's Signet of Ferocity | 4 | 0 | 60 | no | no |
| 275982 | Warden's Signet of Brilliance | 4 | 0 | 60 | no | no |
| 275983 | Warden's Signet of Resolve | 4 | 0 | 60 | no | no |
| 275984 | Warden's Signet of Vigilance | 4 | 0 | 60 | no | no |
| 278157 | Premier Grand Marshal's Tome of Restoration | 4 | 0 | 60 | no | no |
| 278158 | Premier Grand Marshal's Tome of Power | 4 | 0 | 60 | no | no |
| 288926 | Choker of the Fire Lord | 4 | 89135 | 1 | no | no |
| 288927 | Quick Strike Ring | 4 | 64030 | 1 | no | no |
| 288928 | Heavy Dark Iron Ring | 4 | 53364 | 1 | no | no |
| 288929 | Band of Sulfuras | 4 | 79853 | 1 | no | no |
| 288930 | Cauterizing Band | 4 | 60256 | 1 | no | no |
| 288931 | Ring of Spell Power | 4 | 91453 | 1 | no | no |

### 4/0 Armadura / Miscelánea, calidad 6

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 5828 | Ring of Uber Resists (TEST) | 6 | 837 | 1 | no | no |
| 12947 | Alex's Ring of Audacity | 6 | 0 | 0 | no | no |

### 4/1 Armadura / Tela, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 40 | Recruit's Boots | 1 | 1 | 0 | no | no |
| 43 | Squire's Boots | 1 | 1 | 0 | no | no |
| 47 | Footpad's Shoes | 1 | 1 | 0 | no | no |
| 51 | Neophyte's Boots | 1 | 1 | 0 | no | no |
| 55 | Apprentice's Boots | 1 | 1 | 0 | no | no |
| 59 | Acolyte's Shoes | 1 | 1 | 0 | no | no |
| 77 | Deprecated Outfitter Cloth Armor | 1 | 6 | 0 | no | no |
| 79 | Dwarven Cloth Britches | 1 | 10 | 0 | no | no |
| 80 | Soft Fur-lined Shoes | 1 | 7 | 0 | no | no |
| 121 | Thug Boots | 1 | 1 | 0 | no | no |
| 129 | Rugged Trapper's Boots | 1 | 1 | 0 | no | no |
| 140 | Brawler's Boots | 1 | 1 | 0 | no | no |
| 193 | Tattered Cloth Vest | 1 | 9 | 1 | no | no |
| 194 | Tattered Cloth Pants | 1 | 9 | 1 | no | no |
| 195 | Tattered Cloth Boots | 1 | 7 | 1 | no | no |
| 200 | Thick Cloth Vest | 1 | 454 | 17 | no | no |
| 201 | Thick Cloth Pants | 1 | 455 | 17 | no | no |
| 202 | Thick Cloth Shoes | 1 | 342 | 17 | no | no |
| 203 | Thick Cloth Gloves | 1 | 229 | 17 | no | no |
| 710 | Bracers of the People's Militia | 1 | 72 | 0 | no | no |
| 711 | Tattered Cloth Gloves | 1 | 5 | 1 | no | no |
| 719 | Rabbit Handler Gloves | 1 | 4 | 0 | no | no |
| 792 | Knitted Sandals | 1 | 41 | 5 | no | no |
| 793 | Knitted Gloves | 1 | 27 | 5 | no | no |
| 794 | Knitted Pants | 1 | 55 | 5 | no | no |
| 795 | Knitted Tunic | 1 | 56 | 5 | no | no |
| 837 | Heavy Weave Armor | 1 | 224 | 12 | no | no |
| 838 | Heavy Weave Pants | 1 | 225 | 12 | no | no |
| 839 | Heavy Weave Gloves | 1 | 113 | 12 | no | no |
| 840 | Heavy Weave Shoes | 1 | 170 | 12 | no | no |
| 860 | Cavalier's Boots | 1 | 89 | 0 | no | no |
| 906 | Tan Leather Shoulderpads (Test) | 1 | 1 | 1 | no | no |
| 908 | Plate Shoulderpad (Test) | 1 | 1 | 1 | no | no |
| 909 | Silver Mail Shoulderpads (Test) | 1 | 1 | 1 | no | no |
| 983 | Red Linen Sash | 1 | 21 | 0 | no | no |
| 1162 | Pirates Patch (Test) | 1 | 44 | 5 | no | no |
| 1163 | Dwarven Explorer's Monocle (Test) | 1 | 44 | 5 | no | no |
| 1171 | Well-stitched Robe | 1 | 55 | 0 | no | no |
| 1183 | Elastic Wristguards | 1 | 29 | 0 | no | no |
| 1354 | Deprecated Homespun Shawl | 1 | 24 | 0 | no | no |
| 1479 | Salma's Oven Mitts | 1 | 47 | 0 | no | no |
| 2110 | Light Magesmith Robe | 1 | 6 | 1 | no | no |
| 2114 | Snowy Robe | 1 | 31 | 3 | no | no |
| 2117 | Thin Cloth Shoes | 1 | 7 | 1 | no | no |
| 2119 | Thin Cloth Gloves | 1 | 4 | 1 | no | no |
| 2120 | Thin Cloth Pants | 1 | 10 | 1 | no | no |
| 2121 | Thin Cloth Armor | 1 | 10 | 1 | no | no |
| 2156 | Padded Boots | 1 | 615 | 22 | no | no |
| 2158 | Padded Gloves | 1 | 413 | 22 | no | no |
| 2159 | Padded Pants | 1 | 829 | 22 | no | no |
| 2160 | Padded Armor | 1 | 832 | 22 | no | no |
| 2165 | Old Blanchy's Blanket | 1 | 45 | 0 | no | no |
| 2238 | Urchin's Pants | 1 | 60 | 0 | no | no |
| 2240 | Rugged Cape | 1 | 151 | 0 | no | no |
| 2326 | Ivy-weave Bracers | 1 | 29 | 0 | no | no |
| 2364 | Woven Vest | 1 | 59 | 5 | no | no |
| 2366 | Woven Pants | 1 | 59 | 5 | no | no |
| 2367 | Woven Boots | 1 | 44 | 5 | no | no |
| 2369 | Woven Gloves | 1 | 30 | 5 | no | no |
| 2429 | Russet Vest | 1 | 2027 | 32 | no | no |
| 2431 | Russet Pants | 1 | 2043 | 32 | no | no |
| 2432 | Russet Boots | 1 | 1538 | 32 | no | no |
| 2434 | Russet Gloves | 1 | 1033 | 32 | no | no |
| 2435 | Embroidered Armor | 1 | 5536 | 45 | no | no |
| 2437 | Embroidered Pants | 1 | 5578 | 45 | no | no |
| 2438 | Embroidered Boots | 1 | 4199 | 45 | no | no |
| 2440 | Embroidered Gloves | 1 | 2819 | 45 | no | no |
| 2568 | Brown Linen Vest | 1 | 31 | 3 | no | no |
| 2571 | Viny Wrappings | 1 | 16 | 0 | no | no |
| 2586 | Gamemaster's Robe | 1 | 1 | 0 | no | no |
| 2612 | Plain Robe | 1 | 32 | 3 | no | no |
| 2613 | Double-Stitched Robes | 1 | 121 | 8 | no | no |
| 2614 | Robe of Apprenticeship | 1 | 232 | 12 | no | no |
| 2615 | Chromatic Robe | 1 | 1018 | 24 | no | no |
| 2616 | Shimmering Silk Robes | 1 | 531 | 18 | no | no |
| 2617 | Burning Robes | 1 | 2198 | 32 | no | no |
| 2618 | Silver Dress Robes | 1 | 5327 | 45 | no | no |
| 2905 | Goat Fur Cloak | 1 | 53 | 0 | no | no |
| 2959 | Journeyman's Boots | 1 | 32 | 4 | no | no |
| 2960 | Journeyman's Gloves | 1 | 21 | 4 | no | no |
| 2971 | Spellbinder Boots | 1 | 108 | 9 | no | no |
| 2972 | Spellbinder Gloves | 1 | 72 | 9 | no | no |
| 3070 | Ensign Cloak | 1 | 11 | 0 | no | no |
| 3153 | Oil-stained Cloak | 1 | 33 | 0 | no | no |
| 3216 | Warm Winter Robe | 1 | 55 | 0 | no | no |
| 3260 | Scarlet Initiate Robes | 1 | 6 | 1 | no | no |
| 3261 | Webbed Cloak | 1 | 7 | 1 | no | no |
| 3263 | Webbed Pants | 1 | 4 | 1 | no | no |
| 3270 | Flax Vest | 1 | 10 | 0 | no | no |
| 3271 | Deprecated Flax Mantle | 1 | 5 | 0 | no | no |
| 3274 | Flax Boots | 1 | 7 | 0 | no | no |
| 3275 | Flax Gloves | 1 | 5 | 0 | no | no |
| 3289 | Ancestral Boots | 1 | 57 | 6 | no | no |
| 3290 | Ancestral Gloves | 1 | 48 | 7 | no | no |
| 3320 | Bonecaster Sash | 1 | 22 | 4 | no | no |
| 3328 | Spider Web Robe | 1 | 46 | 4 | no | no |
| 3331 | Melrache's Cape | 1 | 101 | 7 | no | no |
| 3436 | Deprecated Quilted Mantle | 1 | 23 | 0 | no | no |
| 3442 | Apprentice Sash | 1 | 44 | 0 | no | no |
| 3453 | Quilted Bracers | 1 | 46 | 0 | no | no |
| 3454 | Reconnaissance Boots | 1 | 105 | 0 | no | no |
| 3587 | Embroidered Belt | 1 | 2862 | 45 | no | no |
| 3588 | Embroidered Bracers | 1 | 2873 | 45 | no | no |
| 3589 | Heavy Weave Belt | 1 | 115 | 12 | no | no |
| 3590 | Heavy Weave Bracers | 1 | 115 | 12 | no | no |
| 3591 | Padded Belt | 1 | 419 | 22 | no | no |
| 3592 | Padded Bracers | 1 | 420 | 22 | no | no |
| 3593 | Russet Belt | 1 | 1095 | 32 | no | no |
| 3594 | Russet Bracers | 1 | 1099 | 32 | no | no |
| 3595 | Tattered Cloth Belt | 1 | 4 | 1 | no | no |
| 3596 | Tattered Cloth Bracers | 1 | 4 | 1 | no | no |
| 3597 | Thick Cloth Belt | 1 | 216 | 17 | no | no |
| 3598 | Thick Cloth Bracers | 1 | 217 | 17 | no | no |
| 3599 | Thin Cloth Belt | 1 | 4 | 1 | no | no |
| 3600 | Thin Cloth Bracers | 1 | 4 | 1 | no | no |
| 3602 | Knitted Belt | 1 | 29 | 5 | no | no |
| 3603 | Knitted Bracers | 1 | 29 | 5 | no | no |
| 3606 | Woven Belt | 1 | 29 | 5 | no | no |
| 3607 | Woven Bracers | 1 | 29 | 5 | no | no |
| 3641 | Journeyman's Bracers | 1 | 15 | 3 | no | no |
| 3642 | Ancestral Bracers | 1 | 22 | 4 | no | no |
| 3643 | Spellbinder Bracers | 1 | 71 | 9 | no | no |
| 3644 | Barbaric Cloth Bracers | 1 | 47 | 7 | no | no |
| 3732 | Hooded Cowl | 1 | 801 | 0 | no | no |
| 3833 | Adept's Cloak | 1 | 24 | 0 | no | no |
| 3834 | Sturdy Cloth Trousers | 1 | 32 | 0 | no | no |
| 3883 | Deprecated Thick Cloth Hat | 1 | 333 | 17 | no | no |
| 3886 | Deprecated Padded Cloth Hat | 1 | 604 | 22 | no | no |
| 3889 | Russet Hat | 1 | 1584 | 32 | no | no |
| 3892 | Embroidered Hat | 1 | 4388 | 45 | no | no |
| 4658 | Warrior's Cloak | 1 | 23 | 3 | no | no |
| 4662 | Journeyman's Cloak | 1 | 24 | 3 | no | no |
| 4663 | Journeyman's Belt | 1 | 23 | 4 | no | no |
| 4665 | Burnt Cloak | 1 | 22 | 3 | no | no |
| 4668 | Battle Chain Cloak | 1 | 32 | 4 | no | no |
| 4670 | Deprecated Ancestral Mantle | 1 | 85 | 8 | no | no |
| 4671 | Ancestral Cloak | 1 | 32 | 4 | no | no |
| 4672 | Ancestral Belt | 1 | 28 | 5 | no | no |
| 4674 | Tribal Cloak | 1 | 32 | 4 | no | no |
| 4677 | Veteran Cloak | 1 | 70 | 7 | no | no |
| 4680 | Brackwater Cloak | 1 | 91 | 8 | no | no |
| 4683 | Spellbinder Cloak | 1 | 92 | 8 | no | no |
| 4684 | Spellbinder Belt | 1 | 61 | 8 | no | no |
| 4686 | Barbaric Cloth Cloak | 1 | 67 | 7 | no | no |
| 4687 | Barbaric Cloth Belt | 1 | 67 | 9 | no | no |
| 4689 | Hunting Cloak | 1 | 106 | 8 | no | no |
| 4692 | Ceremonial Cloak | 1 | 68 | 7 | no | no |
| 4698 | Seer's Mantle | 1 | 301 | 16 | no | no |
| 4915 | Soft Wool Boots | 1 | 7 | 0 | no | no |
| 4916 | Soft Wool Vest | 1 | 9 | 0 | no | no |
| 4919 | Soft Wool Belt | 1 | 5 | 0 | no | no |
| 4920 | Battleworn Cape | 1 | 7 | 0 | no | no |
| 4933 | Seasoned Fighter's Cloak | 1 | 48 | 0 | no | no |
| 4934 | Deprecated Heavy Cord Shoulderpads | 1 | 22 | 0 | no | no |
| 4936 | Dirt-trodden Boots | 1 | 23 | 0 | no | no |
| 4944 | Handsewn Cloak | 1 | 72 | 0 | no | no |
| 4958 | Sun-beaten Cloak | 1 | 36 | 0 | no | no |
| 4963 | Thunderhorn Cloak | 1 | 30 | 0 | no | no |
| 5109 | Stonesplinter Rags | 1 | 223 | 12 | no | no |
| 5110 | Dalaran Wizard's Robe | 1 | 257 | 13 | no | no |
| 5405 | Draped Cloak | 1 | 7 | 0 | no | no |
| 5458 | Dirtwood Belt | 1 | 27 | 0 | no | no |
| 5590 | Cord Bracers | 1 | 35 | 0 | no | no |
| 5591 | Rain-spotted Cape | 1 | 67 | 0 | no | no |
| 5606 | Gardening Gloves | 1 | 23 | 0 | no | no |
| 5618 | Scout's Cloak | 1 | 86 | 0 | no | no |
| 5767 | Violet Robes | 1 | 44 | 4 | no | no |
| 6060 | Flax Bracers | 1 | 4 | 0 | no | no |
| 6062 | Heavy Cord Bracers | 1 | 28 | 0 | no | no |
| 6076 | Tapered Pants | 1 | 9 | 0 | no | no |
| 6122 | Recruit's Boots | 1 | 1 | 0 | no | no |
| 6127 | Trapper's Boots | 1 | 1 | 0 | no | no |
| 6138 | Thug Boots | 1 | 1 | 0 | no | no |
| 6148 | Web-covered Boots | 1 | 44 | 5 | no | no |
| 6173 | Snow Boots | 1 | 7 | 0 | no | no |
| 6185 | Bear Shawl | 1 | 9 | 0 | no | no |
| 6508 | Infantry Cloak | 1 | 34 | 4 | no | no |
| 6513 | Disciple's Sash | 1 | 28 | 5 | no | no |
| 6514 | Disciple's Cloak | 1 | 42 | 5 | no | no |
| 6515 | Disciple's Gloves | 1 | 37 | 6 | no | no |
| 6520 | Pioneer Cloak | 1 | 41 | 4 | no | no |
| 6549 | Soldier's Cloak | 1 | 101 | 9 | no | no |
| 6555 | Bard's Cloak | 1 | 130 | 9 | no | no |
| 6566 | Shimmering Amice | 1 | 411 | 19 | no | no |
| 6713 | Ripped Pants | 1 | 10 | 0 | no | no |
| 6834 | Black Tuxedo | 1 | 1 | 0 | no | no |
| 6836 | Dress Shoes | 1 | 1 | 0 | no | no |
| 7026 | Linen Belt | 1 | 22 | 4 | no | no |
| 7066 | Exotic Silk Dress | 1 | 815 | 22 | no | no |
| 7095 | Bog Boots | 1 | 32 | 4 | no | no |
| 7248 | Twain TEST Cloak | 1 | 68 | 7 | no | no |
| 7276 | Handstitched Leather Cloak | 1 | 34 | 4 | no | no |
| 7350 | Disciple's Bracers | 1 | 29 | 5 | no | no |
| 7351 | Disciple's Boots | 1 | 58 | 6 | no | no |
| 7996 | Worn Fishing Hat | 1 | 244 | 15 | no | no |
| 9600 | Lace Pants | 1 | 93 | 0 | no | no |
| 9742 | Simple Cord | 1 | 49 | 7 | no | no |
| 9743 | Simple Shoes | 1 | 67 | 7 | no | no |
| 9744 | Simple Bands | 1 | 44 | 7 | no | no |
| 9745 | Simple Cape | 1 | 54 | 6 | no | no |
| 9746 | Simple Gloves | 1 | 56 | 8 | no | no |
| 9754 | Nomad Cloak | 1 | 70 | 6 | no | no |
| 9761 | Cadet Cloak | 1 | 58 | 6 | no | no |
| 10035 | Tuxedo Pants | 1 | 1735 | 30 | no | no |
| 10040 | White Wedding Dress | 1 | 1767 | 30 | no | no |
| 10045 | Simple Linen Pants | 1 | 23 | 2 | no | no |
| 10046 | Simple Linen Boots | 1 | 32 | 4 | no | no |
| 10550 | Wooly Mittens | 1 | 48 | 0 | no | no |
| 10655 | Sedgeweed Britches | 1 | 9 | 0 | no | no |
| 11187 | Stemleaf Bracers | 1 | 5 | 0 | no | no |
| 11189 | Woodland Robes | 1 | 10 | 0 | no | no |
| 11190 | Viny Gloves | 1 | 5 | 0 | no | no |
| 11191 | Farmer's Boots | 1 | 45 | 0 | no | no |
| 11192 | Outfitter Gloves | 1 | 4 | 0 | no | no |
| 11475 | Wine-stained Cloak | 1 | 7 | 0 | no | no |
| 11508 | Gamemaster's Slippers | 1 | 1 | 0 | no | no |
| 11847 | Battered Cloak | 1 | 7 | 0 | no | no |
| 11848 | Flax Belt | 1 | 5 | 0 | no | no |
| 11850 | Short Duskbat Cape | 1 | 7 | 0 | no | no |
| 12064 | Gamemaster Hood | 1 | 1 | 0 | no | no |
| 12299 | Netted Gloves | 1 | 16 | 0 | no | no |
| 13726 | [PH] Rising Dawn Gloves | 1 | 1 | 1 | no | no |
| 13787 | [PH] Rising Dawn Hat | 1 | 1 | 1 | no | no |
| 14086 | Beaded Sandals | 1 | 45 | 5 | no | no |
| 14087 | Beaded Cuffs | 1 | 16 | 3 | no | no |
| 14088 | Beaded Cloak | 1 | 24 | 3 | no | no |
| 14089 | Beaded Gloves | 1 | 30 | 5 | no | no |
| 14093 | Beaded Cord | 1 | 21 | 4 | no | no |
| 14095 | Native Bands | 1 | 36 | 6 | no | no |
| 14098 | Native Cloak | 1 | 43 | 5 | no | no |
| 14099 | Native Sash | 1 | 47 | 7 | no | no |
| 14102 | Native Handwraps | 1 | 60 | 8 | no | no |
| 14110 | Native Sandals | 1 | 84 | 8 | no | no |
| 14115 | Aboriginal Bands | 1 | 70 | 9 | no | no |
| 14116 | Aboriginal Cape | 1 | 106 | 9 | no | no |
| 14126 | Ritual Amice | 1 | 396 | 18 | no | no |
| 14157 | Pagan Mantle | 1 | 433 | 19 | no | no |
| 14169 | Aboriginal Shoulder Pads | 1 | 286 | 16 | no | no |
| 14170 | Buccaneer's Mantle | 1 | 331 | 17 | no | no |
| 14368 | Mystic's Shoulder Pads | 1 | 346 | 17 | no | no |
| 14382 | Durability Chestpiece | 1 | 1 | 0 | no | no |
| 14383 | Durability Bracers | 1 | 1 | 0 | no | no |
| 14384 | Durability Boots | 1 | 1 | 0 | no | no |
| 14385 | Durability Cloak | 1 | 1 | 0 | no | no |
| 14386 | Durability Hat | 1 | 1 | 0 | no | no |
| 14387 | Durability Gloves | 1 | 1 | 0 | no | no |
| 14388 | Durability Leggings | 1 | 1 | 0 | no | no |
| 14390 | Durability Belt | 1 | 1 | 0 | no | no |
| 15007 | Primal Cape | 1 | 24 | 3 | no | no |
| 15015 | Lupine Cloak | 1 | 86 | 8 | no | no |
| 15299 | Grizzly Cape | 1 | 42 | 5 | no | no |
| 15398 | Sandcomber Boots | 1 | 108 | 0 | no | no |
| 15475 | Charger's Cloak | 1 | 24 | 3 | no | no |
| 15483 | War Torn Cape | 1 | 41 | 5 | no | no |
| 15490 | Bloodspattered Cloak | 1 | 105 | 9 | no | no |
| 17343 | Test Random Chest | 1 | 1 | 1 | no | no |
| 23323 | Crown of the Fire Festival | 1 | 1 | 0 | no | no |
| 23324 | Mantle of the Fire Festival | 1 | 1 | 0 | no | no |
| 257264 | Thendal Ranger's Gloves | 1 | 4 | 0 | no | no |
| 257275 | Ranger-Apprentice Cape | 1 | 11 | 0 | no | no |
| 257277 | Windblown Short Cloak | 1 | 7 | 0 | no | no |
| 257278 | Plain Skirt | 1 | 9 | 0 | no | no |
| 257281 | Fur-Lined Shoes | 1 | 7 | 0 | no | no |
| 257329 | Smooth Waistband | 1 | 21 | 0 | no | no |
| 257330 | Homestitched Robe | 1 | 55 | 0 | no | no |
| 257335 | Windblown Kilt | 1 | 60 | 0 | no | no |
| 257339 | Skysilk Wristguards | 1 | 29 | 0 | no | no |
| 257340 | Farmer's Field Boots | 1 | 45 | 0 | no | no |
| 263409 | Gardening Pants | 1 | 1 | 0 | no | no |
| 263417 | Adventurer's Cloak | 1 | 24 | 0 | no | no |
| 263422 | Patchwork Leggings | 1 | 23 | 0 | no | no |
| 263425 | Elegant Cuffs | 1 | 15 | 0 | no | no |
| 271659 | Thendal Apprentice's Boots | 1 | 1 | 0 | no | no |
| 271661 | Thendal Novice's Boots | 1 | 1 | 0 | no | no |
| 271665 | Thendal Survivalist's Boots | 1 | 1 | 0 | no | no |
| 271671 | Thendal Warrior's Boots | 1 | 1 | 0 | no | no |
| 271673 | Grove Scoundrel's Boots | 1 | 1 | 0 | no | no |
| 273816 | Apprentice's Blouse | 1 | 55 | 0 | no | no |
| 277098 | Zephrali Vest | 1 | 147 | 9 | no | no |
| 277099 | Zephrali Cuffs | 1 | 74 | 9 | no | no |
| 277100 | Zephrali Handwraps | 1 | 67 | 9 | no | no |
| 277101 | Zephrali Cord | 1 | 67 | 9 | no | no |
| 277102 | Zephrali Leggings | 1 | 135 | 9 | no | no |
| 277103 | Zephrali Shoes | 1 | 102 | 9 | no | no |
| 279391 | Taurajo Headband | 1 | 999 | 0 | no | no |

### 4/1 Armadura / Tela, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1270 | Finely Woven Cloak | 2 | 213 | 0 | no | no |
| 1304 | Riding Gloves | 2 | 279 | 0 | no | no |
| 1561 | Harvester's Robe | 2 | 268 | 0 | no | no |
| 1832 | Lucky Trousers | 2 | 362 | 0 | no | no |
| 2032 | Gallan Cuffs | 2 | 1665 | 0 | no | no |
| 2231 | Inferno Robe | 2 | 4386 | 0 | no | no |
| 2308 | Fine Leather Cloak | 2 | 267 | 10 | no | no |
| 2310 | Embossed Leather Cloak | 2 | 112 | 8 | no | no |
| 2316 | Dark Leather Cloak | 2 | 408 | 17 | no | no |
| 2569 | Linen Boots | 2 | 87 | 8 | no | no |
| 2572 | Red Linen Robe | 2 | 99 | 5 | no | no |
| 2578 | Barbaric Linen Vest | 2 | 224 | 9 | no | no |
| 2580 | Reinforced Linen Cape | 2 | 67 | 7 | no | no |
| 2582 | Green Woolen Vest | 2 | 216 | 12 | no | no |
| 2583 | Woolen Boots | 2 | 359 | 14 | no | no |
| 2584 | Woolen Cape | 2 | 142 | 11 | no | no |
| 2585 | Gray Woolen Robe | 2 | 638 | 16 | no | no |
| 2805 | Yeti Fur Cloak | 2 | 2352 | 0 | no | no |
| 2902 | Cloak of the Faith | 2 | 1305 | 0 | no | no |
| 2913 | Silk Mantle of Gamn | 2 | 1153 | 0 | no | no |
| 2953 | Watch Master's Cloak | 2 | 2321 | 0 | no | no |
| 2954 | Night Watch Pantaloons | 2 | 2485 | 0 | no | no |
| 3008 | Wendigo Fur Cloak | 2 | 43 | 6 | no | no |
| 3068 | Deprecated Silver-thread Cowl | 2 | 1700 | 27 | no | no |
| 3161 | Robe of the Keeper | 2 | 294 | 0 | no | no |
| 3217 | Foreman Belt | 2 | 134 | 0 | no | no |
| 3224 | Silver-lined Bracers | 2 | 28 | 7 | no | no |
| 3322 | Wispy Cloak | 2 | 11 | 5 | no | no |
| 3323 | Ghostly Bracers | 2 | 15 | 5 | no | no |
| 3344 | Captain Sander's Sash | 2 | 145 | 0 | no | no |
| 3449 | Mystic Shawl | 2 | 207 | 0 | no | no |
| 3457 | Stamped Trousers | 2 | 444 | 0 | no | no |
| 3461 | High Robe of the Adjudicator | 2 | 1005 | 0 | no | no |
| 3511 | Cloak of the People's Militia | 2 | 267 | 0 | no | no |
| 3555 | Robe of Solomon | 2 | 1032 | 0 | no | no |
| 3556 | Dread Mage Hat | 2 | 1285 | 0 | no | no |
| 3558 | Fen Keeper Robe | 2 | 1044 | 0 | no | no |
| 3560 | Mantle of Honor | 2 | 2102 | 0 | no | no |
| 3561 | Resilient Poncho | 2 | 895 | 0 | no | no |
| 3565 | Beerstained Gloves | 2 | 280 | 0 | no | no |
| 3582 | Acidproof Cloak | 2 | 474 | 0 | no | no |
| 3719 | Hillman's Cloak | 2 | 1027 | 25 | no | no |
| 3749 | High Apothecary Cloak | 2 | 1320 | 0 | no | no |
| 3752 | Grunt Vest | 2 | 745 | 0 | no | no |
| 3759 | Insulated Sage Gloves | 2 | 1216 | 0 | no | no |
| 3764 | Mantis Boots | 2 | 3181 | 0 | no | no |
| 4113 | Medicine Blanket | 2 | 4853 | 0 | no | no |
| 4114 | Darktide Cape | 2 | 5826 | 0 | no | no |
| 4117 | Scorching Sash | 2 | 3119 | 0 | no | no |
| 4120 | Robe of Crystal Waters | 2 | 4192 | 0 | no | no |
| 4121 | Gemmed Gloves | 2 | 1380 | 0 | no | no |
| 4133 | Darkspear Cuffs | 2 | 1794 | 0 | no | no |
| 4137 | Darkspear Shoes | 2 | 4010 | 0 | no | no |
| 4139 | Junglewalker Sandals | 2 | 2749 | 0 | no | no |
| 4140 | Palm Frond Mantle | 2 | 1875 | 0 | no | no |
| 4261 | Solliden's Trousers | 2 | 31 | 5 | no | no |
| 4307 | Heavy Linen Gloves | 2 | 29 | 5 | no | no |
| 4308 | Green Linen Bracers | 2 | 45 | 7 | no | no |
| 4309 | Handstitched Linen Britches | 2 | 226 | 9 | no | no |
| 4310 | Heavy Woolen Gloves | 2 | 180 | 12 | no | no |
| 4311 | Heavy Woolen Cloak | 2 | 475 | 16 | no | no |
| 4312 | Soft-soled Linen Boots | 2 | 237 | 11 | no | no |
| 4313 | Red Woolen Boots | 2 | 416 | 15 | no | no |
| 4314 | Double-Stitched Woolen Shoulders | 2 | 331 | 17 | no | no |
| 4315 | Reinforced Woolen Shoulders | 2 | 425 | 19 | no | no |
| 4316 | Heavy Woolen Pants | 2 | 743 | 17 | no | no |
| 4317 | Phoenix Pants | 2 | 1076 | 20 | no | no |
| 4318 | Gloves of Meditation | 2 | 610 | 21 | no | no |
| 4319 | Azure Silk Gloves | 2 | 815 | 24 | no | no |
| 4321 | Spider Silk Slippers | 2 | 1120 | 23 | no | no |
| 4322 | Enchanter's Cowl | 2 | 1810 | 28 | no | no |
| 4323 | Shadow Hood | 2 | 1999 | 29 | no | no |
| 4324 | Azure Silk Vest | 2 | 1874 | 25 | no | no |
| 4325 | Boots of the Enchanter | 2 | 2272 | 30 | no | no |
| 4326 | Long Silken Cloak | 2 | 2496 | 32 | no | no |
| 4329 | Star Belt | 2 | 2120 | 35 | no | no |
| 4331 | Phoenix Gloves | 2 | 526 | 20 | no | no |
| 4343 | Brown Linen Pants | 2 | 60 | 5 | no | no |
| 4373 | Shadow Goggles | 2 | 722 | 0 | no | no |
| 4393 | Craftsman's Monocle | 2 | 2632 | 32 | no | no |
| 4504 | Dwarven Guard Cloak | 2 | 2222 | 0 | no | no |
| 4505 | Swampland Trousers | 2 | 1974 | 0 | no | no |
| 4545 | Radiant Silver Bracers | 2 | 2202 | 0 | no | no |
| 4744 | Arcane Runed Bracers | 2 | 1986 | 0 | no | no |
| 4781 | Whispering Vest | 2 | 547 | 15 | no | no |
| 4782 | Solstice Robe | 2 | 415 | 13 | no | no |
| 4786 | Wise Man's Belt | 2 | 278 | 15 | no | no |
| 4790 | Inferno Cloak | 2 | 831 | 20 | no | no |
| 4792 | Spirit Cloak | 2 | 655 | 18 | no | no |
| 4793 | Sylvan Cloak | 2 | 744 | 19 | no | no |
| 4797 | Fiery Cloak | 2 | 852 | 20 | no | no |
| 4798 | Heavy Runed Cloak | 2 | 1166 | 20 | no | no |
| 4799 | Antiquated Cloak | 2 | 608 | 18 | no | no |
| 4827 | Wizard's Belt | 2 | 749 | 23 | no | no |
| 4828 | Nightwind Belt | 2 | 684 | 22 | no | no |
| 4829 | Dreamer's Belt | 2 | 830 | 24 | no | no |
| 4979 | Enchanted Stonecloth Bracers | 2 | 2587 | 0 | no | no |
| 4989 | Mage Dragon Robe | 2 | 9058 | 0 | no | no |
| 5016 | Artisan's Trousers | 2 | 2955 | 0 | no | no |
| 5274 | Rose Mantle | 2 | 1003 | 0 | no | no |
| 5310 | Sea Dog Britches | 2 | 555 | 0 | no | no |
| 5314 | Boar Hunter's Cape | 2 | 528 | 0 | no | no |
| 5315 | Timberland Armguards | 2 | 213 | 0 | no | no |
| 5337 | Wayfaring Gloves | 2 | 167 | 0 | no | no |
| 5343 | Barkeeper's Cloak | 2 | 462 | 0 | no | no |
| 5420 | Banshee Armor | 2 | 227 | 0 | no | no |
| 5542 | Pearl-clasped Cloak | 2 | 370 | 14 | no | no |
| 5610 | Gustweald Cloak | 2 | 208 | 0 | no | no |
| 5766 | Lesser Wizard's Robe | 2 | 1338 | 22 | no | no |
| 5770 | Robes of Arcana | 2 | 1807 | 25 | no | no |
| 5812 | Robes of Antiquity | 2 | 1129 | 0 | no | no |
| 5820 | Faerie Mantle | 2 | 1622 | 0 | no | no |
| 5965 | Guardian Cloak | 2 | 2536 | 32 | no | no |
| 6095 | Wandering Boots | 2 | 688 | 0 | no | no |
| 6191 | Kimbra Boots | 2 | 615 | 0 | no | no |
| 6202 | Fingerless Gloves | 2 | 35 | 8 | no | no |
| 6238 | Brown Linen Robe | 2 | 98 | 5 | no | no |
| 6239 | Red Linen Vest | 2 | 160 | 7 | no | no |
| 6240 | Blue Linen Vest | 2 | 161 | 7 | no | no |
| 6241 | White Linen Robe | 2 | 99 | 5 | no | no |
| 6242 | Blue Linen Robe | 2 | 243 | 9 | no | no |
| 6243 | Green Woolen Robe | 2 | 445 | 13 | no | no |
| 6263 | Blue Overalls | 2 | 589 | 15 | no | no |
| 6264 | Greater Adept's Robe | 2 | 884 | 18 | no | no |
| 6282 | Sacred Burial Trousers | 2 | 2243 | 0 | no | no |
| 6466 | Deviate Scale Cloak | 2 | 413 | 13 | no | no |
| 6477 | Grassland Sash | 2 | 274 | 0 | no | no |
| 6478 | Rat Stompers | 2 | 634 | 0 | no | no |
| 6482 | Firewalker Boots | 2 | 728 | 0 | no | no |
| 6503 | Harlequin Robes | 2 | 762 | 0 | no | no |
| 6659 | Scarab Trousers | 2 | 541 | 0 | no | no |
| 6664 | Voodoo Mantle | 2 | 892 | 0 | no | no |
| 6667 | Engineer's Cloak | 2 | 992 | 0 | no | no |
| 6726 | Razzeric's Customized Seatbelt | 2 | 2388 | 0 | no | no |
| 6737 | Dryleaf Pants | 2 | 2805 | 0 | no | no |
| 6744 | Gloves of Kapelan | 2 | 1190 | 0 | no | no |
| 6745 | Swiftrunner Cape | 2 | 2239 | 0 | no | no |
| 6780 | Lilac Sash | 2 | 1560 | 0 | no | no |
| 6787 | White Woolen Dress | 2 | 466 | 17 | no | no |
| 6789 | Ceremonial Centaur Blanket | 2 | 4012 | 35 | no | no |
| 6791 | Hellion Boots | 2 | 3464 | 0 | no | no |
| 6801 | Baroque Apron | 2 | 4456 | 0 | no | no |
| 7027 | Boots of Darkness | 2 | 1125 | 23 | no | no |
| 7046 | Azure Silk Pants | 2 | 1494 | 23 | no | no |
| 7047 | Hands of Darkness | 2 | 824 | 24 | no | no |
| 7048 | Azure Silk Hood | 2 | 745 | 24 | no | no |
| 7049 | Truefaith Gloves | 2 | 914 | 25 | no | no |
| 7050 | Silk Headband | 2 | 999 | 27 | no | no |
| 7051 | Earthen Vest | 2 | 2696 | 29 | no | no |
| 7053 | Azure Silk Cloak | 2 | 2240 | 30 | no | no |
| 7055 | Crimson Silk Belt | 2 | 1503 | 30 | no | no |
| 7056 | Crimson Silk Cloak | 2 | 2314 | 31 | no | no |
| 7057 | Green Silken Shoulders | 2 | 2323 | 31 | no | no |
| 7058 | Crimson Silk Vest | 2 | 2052 | 32 | no | no |
| 7059 | Crimson Silk Shoulders | 2 | 2781 | 33 | no | no |
| 7060 | Azure Shoulders | 2 | 2791 | 33 | no | no |
| 7061 | Earthen Silk Belt | 2 | 2017 | 34 | no | no |
| 7062 | Crimson Silk Pantaloons | 2 | 2430 | 34 | no | no |
| 7063 | Crimson Silk Robe | 2 | 4741 | 36 | no | no |
| 7064 | Crimson Silk Gloves | 2 | 2569 | 37 | no | no |
| 7065 | Green Silk Armor | 2 | 2398 | 28 | no | no |
| 7106 | Zodiac Gloves | 2 | 1234 | 0 | no | no |
| 7283 | Black Whelp Cloak | 2 | 519 | 15 | no | no |
| 7334 | Efflorescent Robe | 2 | 1544 | 0 | no | no |
| 7377 | Frost Leather Cloak | 2 | 2269 | 31 | no | no |
| 7509 | Manaweave Robe | 2 | 553 | 0 | no | no |
| 7510 | Lesser Spellfire Robes | 2 | 556 | 0 | no | no |
| 7511 | Astral Knot Robe | 2 | 1938 | 0 | no | no |
| 7512 | Nether-lace Robe | 2 | 1945 | 0 | no | no |
| 7738 | Evergreen Gloves | 2 | 211 | 0 | no | no |
| 7739 | Timberland Cape | 2 | 480 | 0 | no | no |
| 8195 | Nightscape Cloak | 2 | 5263 | 41 | no | no |
| 8215 | Wild Leather Cloak | 2 | 9017 | 45 | no | no |
| 8216 | Big Voodoo Cloak | 2 | 6323 | 43 | no | no |
| 9515 | Nether-lace Tunic | 2 | 2011 | 0 | no | no |
| 9516 | Astral Knot Blouse | 2 | 2071 | 0 | no | no |
| 9519 | Durtfeet Stompers | 2 | 2288 | 0 | no | no |
| 9598 | Sleeping Robes | 2 | 94 | 0 | no | no |
| 9634 | Skilled Handling Gloves | 2 | 3381 | 0 | no | no |
| 9635 | Master Apothecary Cape | 2 | 4713 | 0 | no | no |
| 9636 | Swashbuckler Sash | 2 | 3154 | 0 | no | no |
| 9645 | Gnomish Inventor Boots | 2 | 6768 | 0 | no | no |
| 9648 | Chainlink Towel | 2 | 6392 | 0 | no | no |
| 9649 | Royal Highmark Vestments | 2 | 13229 | 0 | no | no |
| 9653 | Speedy Racer Goggles | 2 | 6745 | 0 | no | no |
| 9658 | Boots of the Maharishi | 2 | 4086 | 0 | no | no |
| 9660 | Stargazer Cloak | 2 | 4227 | 0 | no | no |
| 9665 | Wingcrest Gloves | 2 | 4826 | 0 | no | no |
| 9699 | Garrison Cloak | 2 | 1812 | 0 | no | no |
| 9703 | Scorched Cape | 2 | 4272 | 0 | no | no |
| 9998 | Black Mageweave Vest | 2 | 4815 | 36 | no | no |
| 9999 | Black Mageweave Leggings | 2 | 4832 | 36 | no | no |
| 10001 | Black Mageweave Robe | 2 | 5257 | 37 | no | no |
| 10002 | Shadoweave Pants | 2 | 5276 | 37 | no | no |
| 10003 | Black Mageweave Gloves | 2 | 2859 | 38 | no | no |
| 10004 | Shadoweave Robe | 2 | 5738 | 38 | no | no |
| 10007 | Red Mageweave Vest | 2 | 5799 | 38 | no | no |
| 10008 | White Bandit Mask | 2 | 3492 | 38 | no | no |
| 10009 | Red Mageweave Pants | 2 | 5284 | 38 | no | no |
| 10018 | Red Mageweave Gloves | 2 | 3275 | 40 | no | no |
| 10023 | Shadoweave Gloves | 2 | 3334 | 40 | no | no |
| 10024 | Black Mageweave Headband | 2 | 5421 | 41 | no | no |
| 10025 | Shadoweave Mask | 2 | 6790 | 44 | no | no |
| 10027 | Black Mageweave Shoulders | 2 | 5479 | 41 | no | no |
| 10028 | Shadoweave Shoulders | 2 | 5938 | 42 | no | no |
| 10029 | Red Mageweave Shoulders | 2 | 5391 | 42 | no | no |
| 10031 | Shadoweave Boots | 2 | 6030 | 43 | no | no |
| 10033 | Red Mageweave Headband | 2 | 6075 | 43 | no | no |
| 10037 | DEPRECATED | 2 | 6249 | 44 | no | no |
| 10042 | Cindercloth Robe | 2 | 6644 | 40 | no | no |
| 10043 | Pious Legwraps | 2 | 2033 | 0 | no | no |
| 10044 | Cindercloth Boots | 2 | 6765 | 44 | no | no |
| 10047 | Simple Kilt | 2 | 164 | 10 | no | no |
| 10048 | Colorful Kilt | 2 | 935 | 14 | no | no |
| 10143 | High Councillor's Robe | 2 | 19772 | 59 | no | no |
| 10249 | Master's Cloak | 2 | 13435 | 56 | no | no |
| 10461 | Shadowy Bracers | 2 | 3082 | 0 | no | no |
| 10462 | Shadowy Belt | 2 | 3608 | 0 | no | no |
| 10499 | Bright-Eye Goggles | 2 | 2105 | 0 | no | no |
| 10503 | Rose Colored Goggles | 2 | 5169 | 0 | no | no |
| 10545 | Gnomish Goggles | 2 | 3929 | 0 | no | no |
| 10549 | Rancher's Trousers | 2 | 162 | 0 | no | no |
| 10637 | Brewer's Gloves | 2 | 139 | 0 | no | no |
| 10638 | Long Draping Cape | 2 | 210 | 0 | no | no |
| 10654 | Jutebraid Gloves | 2 | 965 | 0 | no | no |
| 10700 | Encarmine Boots | 2 | 4983 | 0 | no | no |
| 10705 | Firwillow Wristbands | 2 | 3666 | 0 | no | no |
| 10742 | Dragonflight Leggings | 2 | 9589 | 0 | no | no |
| 10747 | Teacher's Sash | 2 | 2327 | 0 | no | no |
| 10820 | Jackseed Belt | 2 | 138 | 0 | no | no |
| 10821 | Sower's Cloak | 2 | 208 | 0 | no | no |
| 11469 | Bloodband Bracers | 2 | 3563 | 0 | no | no |
| 11858 | Battlehard Cape | 2 | 4768 | 0 | no | no |
| 11873 | Ethereal Mist Cape | 2 | 9661 | 0 | no | no |
| 11875 | Breezecloud Bracers | 2 | 5776 | 0 | no | no |
| 11884 | Moonlit Amice | 2 | 1846 | 0 | no | no |
| 11888 | Quintis' Research Gloves | 2 | 4879 | 0 | no | no |
| 11908 | Archaeologist's Quarry Boots | 2 | 9886 | 0 | no | no |
| 11911 | Treetop Leggings | 2 | 12392 | 0 | no | no |
| 11917 | Shizzle's Nozzle Wiper | 2 | 6334 | 0 | no | no |
| 11936 | Relic Hunter Belt | 2 | 284 | 0 | no | no |
| 12050 | Hazecover Boots | 2 | 8963 | 0 | no | no |
| 12107 | Whispersilk Leggings | 2 | 16885 | 0 | no | no |
| 12253 | Brilliant Red Cloak | 2 | 3545 | 36 | no | no |
| 12254 | Well Oiled Cloak | 2 | 4483 | 39 | no | no |
| 12255 | Pale Leggings | 2 | 6997 | 41 | no | no |
| 12256 | Cindercloth Leggings | 2 | 8765 | 44 | no | no |
| 12295 | Leggings of the People's Militia | 2 | 282 | 0 | no | no |
| 13856 | Runecloth Belt | 2 | 5112 | 46 | no | no |
| 13857 | Runecloth Tunic | 2 | 10878 | 47 | no | no |
| 13858 | Runecloth Robe | 2 | 10917 | 47 | no | no |
| 13860 | Runecloth Cloak | 2 | 8741 | 48 | no | no |
| 13863 | Runecloth Gloves | 2 | 6617 | 50 | no | no |
| 13864 | Runecloth Boots | 2 | 9553 | 51 | no | no |
| 13865 | Runecloth Pants | 2 | 13555 | 52 | no | no |
| 13866 | Runecloth Headband | 2 | 11358 | 54 | no | no |
| 13867 | Runecloth Shoulders | 2 | 12570 | 56 | no | no |
| 13868 | Frostweave Robe | 2 | 9665 | 46 | no | no |
| 13869 | Frostweave Tunic | 2 | 9702 | 46 | no | no |
| 13870 | Frostweave Gloves | 2 | 5471 | 47 | no | no |
| 13871 | Frostweave Pants | 2 | 13436 | 51 | no | no |
| 14042 | Cindercloth Vest | 2 | 10561 | 47 | no | no |
| 14043 | Cindercloth Gloves | 2 | 5955 | 49 | no | no |
| 14045 | Cindercloth Pants | 2 | 13480 | 51 | no | no |
| 14100 | Brightcloth Robe | 2 | 12089 | 49 | no | no |
| 14101 | Brightcloth Gloves | 2 | 6066 | 49 | no | no |
| 14103 | Brightcloth Cloak | 2 | 9716 | 50 | no | no |
| 14104 | Brightcloth Pants | 2 | 15484 | 53 | no | no |
| 14106 | Felcloth Robe | 2 | 18053 | 56 | no | no |
| 14107 | Felcloth Pants | 2 | 13140 | 50 | no | no |
| 14108 | Felcloth Boots | 2 | 11112 | 52 | no | no |
| 14111 | Felcloth Hood | 2 | 10775 | 53 | no | no |
| 14112 | Felcloth Shoulders | 2 | 13509 | 57 | no | no |
| 14128 | Wizardweave Robe | 2 | 16093 | 55 | no | no |
| 14130 | Wizardweave Turban | 2 | 12768 | 56 | no | no |
| 14132 | Wizardweave Leggings | 2 | 12441 | 50 | no | no |
| 14141 | Ghostweave Vest | 2 | 12859 | 50 | no | no |
| 14142 | Ghostweave Gloves | 2 | 6087 | 49 | no | no |
| 14143 | Ghostweave Belt | 2 | 5763 | 48 | no | no |
| 14144 | Ghostweave Pants | 2 | 14374 | 53 | no | no |
| 14158 | Pagan Vest | 2 | 1236 | 21 | no | no |
| 14363 | Deprecated Runic Cloth Pants | 2 | 326 | 11 | no | no |
| 15104 | Wingborne Boots | 2 | 3188 | 0 | no | no |
| 15401 | Welldrip Gloves | 2 | 72 | 0 | no | no |
| 15455 | Dustfall Robes | 2 | 3541 | 0 | no | no |
| 15457 | Desert Shoulders | 2 | 1134 | 0 | no | no |
| 15461 | Lightheel Boots | 2 | 841 | 0 | no | no |
| 15468 | Windsong Drape | 2 | 1207 | 0 | no | no |
| 15585 | Pardoc Grips | 2 | 1446 | 0 | no | no |
| 15697 | Kodo Rustler Boots | 2 | 2825 | 0 | no | no |
| 15703 | Chemist's Smock | 2 | 9032 | 0 | no | no |
| 15707 | Brantwood Sash | 2 | 7215 | 0 | no | no |
| 15784 | Crystal Breeze Mantle | 2 | 11541 | 0 | no | no |
| 15789 | Deep River Cloak | 2 | 9574 | 0 | no | no |
| 15791 | Turquoise Sash | 2 | 7172 | 0 | no | no |
| 15804 | Cerise Drape | 2 | 9574 | 0 | no | no |
| 15812 | Orchid Amice | 2 | 9574 | 0 | no | no |
| 15815 | Hameya's Cloak | 2 | 11860 | 0 | no | no |
| 15864 | Condor Bracers | 2 | 1947 | 0 | no | no |
| 15999 | Spellpower Goggles Xtreme Plus | 2 | 9002 | 0 | no | no |
| 16008 | Master Engineer's Goggles | 2 | 11739 | 0 | no | no |
| 16121 | Test Nature Res Head Cloth | 2 | 2070 | 30 | no | no |
| 16604 | Moon Robes of Elune | 2 | 17 | 0 | no | no |
| 16605 | Friar's Robes of the Light | 2 | 17 | 0 | no | no |
| 16606 | Juju Hex Robes | 2 | 17 | 0 | no | no |
| 16607 | Acolyte's Sacrificial Robes | 2 | 16 | 0 | no | no |
| 16658 | Wildhunter Cloak | 2 | 1649 | 0 | no | no |
| 16661 | Soft Willow Cape | 2 | 965 | 0 | no | no |
| 16738 | Witherseed Gloves | 2 | 3893 | 0 | no | no |
| 16740 | Shredder Operating Gloves | 2 | 942 | 0 | no | no |
| 16791 | Silkstream Cuffs | 2 | 1912 | 0 | no | no |
| 16981 | Owlbeard Bracers | 2 | 271 | 0 | no | no |
| 16985 | Windseeker Boots | 2 | 847 | 0 | no | no |
| 16990 | Spritekin Cloak | 2 | 998 | 0 | no | no |
| 17047 | Luminescent Amice | 2 | 1313 | 0 | no | no |
| 17523 | Smokey's Drape | 2 | 10758 | 0 | no | no |
| 19116 | Greenleaf Handwraps | 2 | 4590 | 0 | no | no |
| 19123 | Everwarm Handwraps | 2 | 4114 | 0 | no | no |
| 19129 | Everglowing Robe | 2 | 8355 | 0 | no | no |
| 19969 | Nat Pagle's Extreme Anglin' Boots | 2 | 3360 | 0 | no | no |
| 19972 | Lucky Fishing Hat | 2 | 3396 | 0 | no | no |
| 20241 | 90 Green Warrior Cloak | 2 | 25902 | 60 | no | no |
| 20283 | 63 Green Warrior Cloak | 2 | 6988 | 58 | no | no |
| 20302 | 90 Green Rogue Cloak | 2 | 53401 | 60 | no | no |
| 20316 | 63 Green Rogue Cloak | 2 | 13985 | 58 | no | no |
| 20338 | 90 Green Frost Belt | 2 | 35067 | 60 | no | no |
| 20339 | 90 Green Frost Bindings | 2 | 35199 | 60 | no | no |
| 20340 | 90 Green Frost Boots | 2 | 52993 | 60 | no | no |
| 20341 | 90 Green Frost Crown | 2 | 53191 | 60 | no | no |
| 20342 | 90 Green Frost Gloves | 2 | 35593 | 60 | no | no |
| 20343 | 90 Green Frost Leggings | 2 | 71445 | 60 | no | no |
| 20344 | 90 Green Frost Mantle | 2 | 53783 | 60 | no | no |
| 20347 | 90 Green Frost Robes | 2 | 72499 | 60 | no | no |
| 20348 | 90 Green Frost Shroud | 2 | 54573 | 60 | no | no |
| 20351 | 63 Green Frost Belt | 2 | 9144 | 58 | no | no |
| 20352 | 63 Green Frost Bindings | 2 | 9179 | 58 | no | no |
| 20353 | 63 Green Frost Boots | 2 | 13822 | 58 | no | no |
| 20354 | 63 Green Frost Crown | 2 | 13875 | 58 | no | no |
| 20355 | 63 Green Frost Gloves | 2 | 9285 | 58 | no | no |
| 20356 | 63 Green Frost Leggings | 2 | 18641 | 58 | no | no |
| 20357 | 63 Green Frost Mantle | 2 | 14034 | 58 | no | no |
| 20360 | 63 Green Frost Robes | 2 | 18923 | 58 | no | no |
| 20361 | 63 Green Frost Shroud | 2 | 14245 | 58 | no | no |
| 20641 | Southsea Mojo Boots | 2 | 4829 | 0 | no | no |
| 20642 | Antiquated Nobleman's Tunic | 2 | 7539 | 0 | no | no |
| 21311 | Earth Warder's Vest | 2 | 8473 | 0 | no | no |
| 21318 | Earth Warder's Gloves | 2 | 7444 | 0 | no | no |
| 215365 | Invoker's Mantle | 2 | 1371 | 25 | no | no |
| 215366 | Invoker's Cord | 2 | 864 | 25 | no | no |
| 251486 | Tabitha's Cuffs | 2 | 458 | 0 | no | no |
| 253884 | Template Item | 2 | 12623 | 50 | no | no |
| 253999 | Earthen Leggings | 2 | 2990 | 30 | no | no |
| 254013 | Earthen Silk Slippers | 2 | 2351 | 31 | no | no |
| 254015 | Earthen Silk Hood | 2 | 2675 | 32 | no | no |
| 254017 | Earthen Silk Gloves | 2 | 2095 | 34 | no | no |
| 254019 | Earthen Silk Cuffs | 2 | 2279 | 35 | no | no |
| 254033 | Earthen Silk Shoulders | 2 | 3613 | 36 | no | no |
| 254073 | Ghostweave Cord | 2 | 5359 | 47 | no | no |
| 254075 | Earthenweave Gloves | 2 | 5398 | 47 | no | no |
| 254077 | Earthenweave Cord | 2 | 5437 | 47 | no | no |
| 254093 | Earthenweave Boots | 2 | 9030 | 49 | no | no |
| 254119 | Earthenweave Mantle | 2 | 10205 | 52 | no | no |
| 254121 | Earthenweave Vest | 2 | 15262 | 54 | no | no |
| 254123 | Runecloth Cuffs | 2 | 7688 | 52 | no | no |
| 254125 | Earthenweave Leggings | 2 | 14756 | 53 | no | no |
| 254127 | Ghostweave Mantle | 2 | 12020 | 54 | no | no |
| 254129 | Ghostweave Boots | 2 | 12714 | 55 | no | no |
| 254131 | Earthenweave Cuffs | 2 | 8536 | 55 | no | no |
| 254135 | Ghostweave Hood | 2 | 13637 | 56 | no | no |
| 254137 | Earthenweave Crown | 2 | 12426 | 56 | no | no |
| 257943 | Hunter's Simple Cloak | 2 | 53 | 0 | no | no |
| 260168 | Mourner's Shroud | 2 | 9978 | 0 | no | no |
| 260169 | Amice of Sorrow | 2 | 7568 | 0 | no | no |
| 260195 | Headdress of the Damned | 2 | 8664 | 0 | no | no |
| 263307 | Shadowgale Pants | 2 | 119 | 0 | no | no |
| 263310 | Sorrowsong Gloves | 2 | 35 | 0 | no | no |
| 263332 | Elder's Tunic | 2 | 121 | 0 | no | no |
| 263336 | Windsong Bangles | 2 | 36 | 0 | no | no |
| 263339 | Windswept Slippers | 2 | 57 | 0 | no | no |
| 263402 | Sash of Sorrow | 2 | 29 | 0 | no | no |
| 263406 | Empyrean Shoes | 2 | 67 | 0 | no | no |
| 269501 | Elven Chain Wristguards | 2 | 12212 | 55 | no | no |
| 270000 | Apprentice Wizard's Gown | 2 | 205 | 0 | no | no |
| 270007 | Worn Miner's Waistcord | 2 | 281 | 0 | no | no |
| 270011 | Embroidered Leggings | 2 | 738 | 0 | no | no |
| 270012 | Miner's Workgloves | 2 | 275 | 0 | no | no |
| 270022 | Archaeologist's Gown | 2 | 847 | 0 | no | no |
| 270028 | Harpy Bangles | 2 | 744 | 0 | no | no |
| 270035 | Reclaimer's Robes | 2 | 1644 | 0 | no | no |
| 270046 | Ethereal Mantle | 2 | 1371 | 0 | no | no |
| 270056 | Stromgarde Librarian Leggings | 2 | 3524 | 0 | no | no |
| 270079 | Witchdoctor's Dress | 2 | 4620 | 0 | no | no |
| 270082 | Ceremonial Gown | 2 | 5801 | 0 | no | no |
| 270086 | Oversized Ogre's Mittens | 2 | 2455 | 0 | no | no |
| 270090 | Beggar's Leggings | 2 | 6284 | 0 | no | no |
| 270093 | Blackwater Cap | 2 | 5091 | 0 | no | no |
| 270113 | Singed Cloth Robe | 2 | 9372 | 0 | no | no |
| 271740 | Knife-Polishing Rag | 2 | 1216 | 0 | no | no |
| 271769 | Daewyn's Girdle | 2 | 1000 | 0 | no | no |
| 273654 | Crystal Thread Cloak | 2 | 1322 | 0 | no | no |
| 273876 | Broken Cultist Gloves | 2 | 4 | 0 | no | no |
| 274035 | Staghide Drape | 2 | 11142 | 0 | no | no |
| 274721 | Tattered Sandals | 2 | 11312 | 0 | no | no |
| 274740 | Quilted Cloak | 2 | 813 | 20 | no | no |
| 274741 | Rumpled Kilt | 2 | 1089 | 20 | no | no |
| 274752 | Sandstorm Cover | 2 | 4713 | 40 | no | no |
| 274755 | Steamwheedle Grips | 2 | 6191 | 50 | no | no |
| 274941 | Bristle Hills Mystic Robe | 2 | 5046 | 0 | no | no |
| 274946 | Gnollblood Robe | 2 | 5140 | 0 | no | no |
| 275028 | Twilight Mine Light | 2 | 5018 | 0 | no | no |
| 275046 | Twilight Overlord Drape | 2 | 5381 | 0 | no | no |
| 275050 | Cloak of the Cult | 2 | 5458 | 0 | no | no |
| 275390 | Shallow Bindings | 2 | 7292 | 0 | no | no |
| 275668 | Summit Drape | 2 | 12318 | 0 | no | no |
| 275715 | Rocket Pilot Gloves | 2 | 7459 | 0 | no | no |
| 275827 | Wool-Stitched Waistband | 2 | 7431 | 0 | no | no |
| 276901 | Uncle's Heroism | 2 | 0 | 1 | no | no |
| 277010 | Cloudy Stormsewn Vest | 2 | 0 | 7 | no | no |
| 277011 | Cloudy Stormsewn Cuffs | 2 | 0 | 5 | no | no |
| 277012 | Cloudy Stormsewn Handwraps | 2 | 0 | 6 | no | no |
| 277013 | Cloudy Stormsewn Cord | 2 | 0 | 5 | no | no |
| 277014 | Cloudy Stormsewn Leggings | 2 | 0 | 7 | no | no |
| 277015 | Cloudy Stormsewn Shoes | 2 | 0 | 6 | no | no |
| 277034 | Azure Stormsewn Vest | 2 | 0 | 7 | no | no |
| 277035 | Azure Stormsewn Cuffs | 2 | 0 | 5 | no | no |
| 277036 | Azure Stormsewn Handwraps | 2 | 0 | 6 | no | no |
| 277037 | Azure Stormsewn Cord | 2 | 0 | 5 | no | no |
| 277038 | Azure Stormsewn Leggings | 2 | 0 | 7 | no | no |
| 277039 | Azure Stormsewn Shoes | 2 | 0 | 6 | no | no |
| 277046 | Cloudy Stormsewn Cowl | 2 | 0 | 30 | no | no |
| 277047 | Cloudy Stormsewn Epaulets | 2 | 0 | 30 | no | no |
| 277054 | Azure Stormsewn Cowl | 2 | 0 | 30 | no | no |
| 277055 | Azure Stormsewn Epaulets | 2 | 0 | 30 | no | no |
| 277206 | Brilliant Cloak | 2 | 0 | 0 | no | no |
| 277207 | Well-Weathered Cloak | 2 | 0 | 0 | no | no |
| 277211 | Dudd's Thinkin' Cap | 2 | 0 | 0 | no | no |
| 277212 | Soulwoven Epaulets | 2 | 0 | 40 | no | no |
| 277214 | Crusty Cuffs | 2 | 0 | 0 | no | no |
| 277215 | Plain Handwraps | 2 | 0 | 0 | no | no |
| 277216 | Cross-Stitched Cord | 2 | 0 | 40 | no | no |
| 277217 | Patchy Pants | 2 | 0 | 40 | no | no |
| 277218 | Incinerator's Boots | 2 | 0 | 0 | no | no |
| 277289 | Traveler's Shawl | 2 | 0 | 1 | no | no |
| 277514 | Aka'rai's Tattered Vestments | 2 | 0 | 1 | no | no |
| 280306 | Whimsical Waistwrap | 2 | 1710 | 30 | no | no |
| 281250 | Forest Oracle's Cloak | 2 | 0 | 0 | no | no |
| 281256 | Repurposed Hair Band | 2 | 0 | 0 | no | no |
| 281260 | Ancestral Waistcord | 2 | 0 | 0 | no | no |
| 281269 | Mogra's Friendship Bracelet | 2 | 0 | 0 | no | no |
| 281275 | Mantle of Scaleslaying | 2 | 0 | 0 | no | no |
| 281283 | Patchwing Pants | 2 | 1 | 0 | no | no |
| 281289 | Swordfeather Cloak | 2 | 0 | 0 | no | no |
| 281298 | Ti'ik's Tattered Trousers | 2 | 0 | 0 | no | no |
| 281305 | Excavation Cloak | 2 | 0 | 0 | no | no |
| 281315 | Foulfur Gloves | 2 | 0 | 0 | no | no |
| 281324 | Sailing Tunic | 2 | 0 | 0 | no | no |
| 281539 | Bear Fur Cowl | 2 | 0 | 0 | no | no |
| 281675 | Lakeshire Firefighter's Headband | 2 | 0 | 0 | no | no |
| 281685 | Restored Cloth Helm | 2 | 1 | 1 | no | no |
| 281686 | Restored Cloth Shoulders | 2 | 1 | 1 | no | no |
| 281687 | Restored Cloth Vest | 2 | 1 | 1 | no | no |
| 281688 | Restored Cloth Bracers | 2 | 1 | 1 | no | no |
| 281689 | Restored Cloth Handwraps | 2 | 1 | 1 | no | no |
| 281690 | Restored Cloth Belt | 2 | 1 | 1 | no | no |
| 281691 | Restored Cloth Pants | 2 | 1 | 1 | no | no |
| 281692 | Restored Cloth Shoes | 2 | 1 | 1 | no | no |
| 281717 | Restored Cloak | 2 | 1 | 1 | no | no |
| 286426 | Honorbound Cloak | 2 | 213 | 0 | no | no |
| 286427 | Cloak of the Honored Guest | 2 | 213 | 0 | no | no |

### 4/1 Armadura / Tela, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4327 | Icy Cloak | 3 | 3788 | 35 | no | no |
| 6832 | Cloak of Blight | 3 | 3769 | 0 | no | no |
| 6900 | Enchanted Gold Bloodrobe | 3 | 4685 | 0 | no | no |
| 7054 | Robe of Power | 3 | 4700 | 33 | no | no |
| 10019 | Dreamweave Gloves | 3 | 3944 | 40 | no | no |
| 10021 | Dreamweave Vest | 3 | 7946 | 40 | no | no |
| 10041 | Dreamweave Circlet | 3 | 8593 | 45 | no | no |
| 10504 | Green Lens | 3 | 7770 | 0 | no | no |
| 13080 | Widow's Clutch | 3 | 22512 | 58 | no | no |
| 13936 | Deprecated Dreadmaster's Shroud | 3 | 17248 | 57 | no | no |
| 14136 | Robe of Winter Night | 3 | 17025 | 52 | no | no |
| 14137 | Mooncloth Leggings | 3 | 18113 | 53 | no | no |
| 14138 | Mooncloth Vest | 3 | 20042 | 55 | no | no |
| 14139 | Mooncloth Shoulders | 3 | 15840 | 56 | no | no |
| 14140 | Mooncloth Circlet | 3 | 16693 | 57 | no | no |
| 14389 | Durability Shoulderpads | 3 | 2 | 0 | no | no |
| 15802 | Mooncloth Boots | 3 | 11648 | 51 | no | no |
| 16315 | Sergeant Major's Cape | 3 | 805 | 25 | no | no |
| 16336 | Sergeant Major's Cape | 3 | 2917 | 40 | no | no |
| 16337 | Sergeant Major's Cape | 3 | 7491 | 55 | no | no |
| 16341 | Sergeant's Cloak | 3 | 4285 | 45 | no | no |
| 16342 | Sergeant's Cape | 3 | 8830 | 58 | no | no |
| 16367 | Knight-Captain's Silk Sash | 3 | 4810 | 55 | no | no |
| 16369 | Knight-Lieutenant's Silk Boots | 3 | 8416 | 58 | no | no |
| 16370 | Knight-Captain's Silk Cuffs | 3 | 4865 | 55 | no | no |
| 16413 | Knight-Captain's Silk Raiment | 3 | 11692 | 58 | no | no |
| 16414 | Knight-Captain's Silk Leggings | 3 | 11735 | 58 | no | no |
| 16415 | Lieutenant Commander's Silk Spaulders | 3 | 8833 | 58 | no | no |
| 16416 | Lieutenant Commander's Crown | 3 | 8864 | 58 | no | no |
| 16486 | First Sergeant's Silk Cuffs | 3 | 5695 | 58 | no | no |
| 16488 | Legionnaire's Silk Belt | 3 | 4956 | 55 | no | no |
| 16975 | Warsong Sash | 3 | 813 | 0 | no | no |
| 17562 | Knight-Lieutenant's Dreadweave Boots | 3 | 8736 | 58 | no | no |
| 17563 | Knight-Captain's Dreadweave Bracers | 3 | 5049 | 55 | no | no |
| 17565 | Knight-Captain's Dreadweave Belt | 3 | 4744 | 55 | no | no |
| 17566 | Lieutenant Commander's Headguard | 3 | 8863 | 58 | no | no |
| 17567 | Knight-Captain's Dreadweave Leggings | 3 | 11860 | 58 | no | no |
| 17568 | Knight-Captain's Dreadweave Robe | 3 | 11054 | 58 | no | no |
| 17569 | Lieutenant Commander's Dreadweave Mantle | 3 | 8322 | 58 | no | no |
| 17570 | Champion's Dreadweave Hood | 3 | 8354 | 58 | no | no |
| 17571 | Legionnaire's Dreadweave Leggings | 3 | 11182 | 58 | no | no |
| 17572 | Legionnaire's Dreadweave Robe | 3 | 11223 | 58 | no | no |
| 17573 | Champion's Dreadweave Shoulders | 3 | 8449 | 58 | no | no |
| 17574 | Legionnaire's Dreadweave Belt | 3 | 4744 | 55 | no | no |
| 17575 | Legionnaire's Dreadweave Bracers | 3 | 4744 | 55 | no | no |
| 17576 | Blood Guard's Dreadweave Boots | 3 | 8544 | 58 | no | no |
| 17594 | Knight-Lieutenant's Satin Boots | 3 | 8481 | 58 | no | no |
| 17595 | Knight-Captain's Satin Cuffs | 3 | 4744 | 55 | no | no |
| 17597 | Knight-Captain's Satin Cord | 3 | 4744 | 55 | no | no |
| 17598 | Lieutenant Commander's Diadem | 3 | 8607 | 58 | no | no |
| 17599 | Knight-Captain's Satin Leggings | 3 | 11518 | 58 | no | no |
| 17600 | Knight-Captain's Satin Robes | 3 | 11866 | 58 | no | no |
| 17601 | Lieutenant Commander's Satin Amice | 3 | 8931 | 58 | no | no |
| 17614 | Legionnaire's Satin Sash | 3 | 4744 | 55 | no | no |
| 17615 | Legionnaire's Satin Cuffs | 3 | 4744 | 55 | no | no |
| 18407 | Felcloth Gloves | 3 | 11139 | 57 | no | no |
| 18408 | Inferno Gloves | 3 | 11178 | 57 | no | no |
| 18409 | Mooncloth Gloves | 3 | 11219 | 57 | no | no |
| 18413 | Cloak of Warding | 3 | 17070 | 57 | no | no |
| 18427 | Sergeant's Cloak | 3 | 1322 | 30 | no | no |
| 18437 | First Sergeant's Silk Cuffs | 3 | 2744 | 45 | no | no |
| 18440 | Sergeant's Cape | 3 | 1288 | 30 | no | no |
| 18441 | Sergeant's Cape | 3 | 4178 | 45 | no | no |
| 18456 | Sergeant Major's Silk Cuffs | 3 | 5613 | 58 | no | no |
| 18457 | Sergeant Major's Silk Cuffs | 3 | 2674 | 45 | no | no |
| 18461 | Sergeant's Cloak | 3 | 8577 | 58 | no | no |
| 18486 | Mooncloth Robe | 3 | 21683 | 56 | no | no |
| 18747 | Item Properties Test | 3 | 8238 | 58 | no | no |
| 19047 | Wisdom of the Timbermaw | 3 | 9232 | 53 | no | no |
| 19050 | Mantle of the Timbermaw | 3 | 18758 | 56 | no | no |
| 19056 | Argent Boots | 3 | 12941 | 53 | no | no |
| 19059 | Argent Shoulders | 3 | 17541 | 56 | no | no |
| 19083 | Frostwolf Legionnaire's Cloak | 3 | 15044 | 55 | no | no |
| 19084 | Stormpike Soldier's Cloak | 3 | 15100 | 55 | no | no |
| 19085 | Frostwolf Advisor's Cloak | 3 | 15155 | 55 | no | no |
| 19086 | Stormpike Sage's Cloak | 3 | 15209 | 55 | no | no |
| 19090 | Frostwolf Cloth Belt | 3 | 10285 | 55 | no | no |
| 19094 | Stormpike Cloth Girdle | 3 | 9488 | 55 | no | no |
| 19121 | Deep Woodlands Cloak | 3 | 8585 | 0 | no | no |
| 19526 | Battle Healer's Cloak | 3 | 18116 | 58 | no | no |
| 19527 | Battle Healer's Cloak | 3 | 9631 | 48 | no | no |
| 19528 | Battle Healer's Cloak | 3 | 4780 | 38 | no | no |
| 19529 | Battle Healer's Cloak | 3 | 2122 | 28 | no | no |
| 19530 | Caretaker's Cape | 3 | 17098 | 58 | no | no |
| 19531 | Caretaker's Cape | 3 | 10048 | 48 | no | no |
| 19532 | Caretaker's Cape | 3 | 4986 | 38 | no | no |
| 19533 | Caretaker's Cape | 3 | 2154 | 28 | no | no |
| 19999 | Bloodvine Goggles | 3 | 18639 | 60 | no | no |
| 20097 | Highlander's Cloth Girdle | 3 | 6723 | 48 | no | no |
| 20098 | Highlander's Cloth Girdle | 3 | 3336 | 38 | no | no |
| 20099 | Highlander's Cloth Girdle | 3 | 1441 | 28 | no | no |
| 20164 | Defiler's Cloth Girdle | 3 | 1505 | 28 | no | no |
| 20165 | Defiler's Cloth Girdle | 3 | 6423 | 48 | no | no |
| 20166 | Defiler's Cloth Girdle | 3 | 3187 | 38 | no | no |
| 20217 | Belt of Tiny Heads | 3 | 16575 | 0 | no | no |
| 20218 | Faded Hakkari Cloak | 3 | 14590 | 0 | no | no |
| 20219 | Tattered Hakkari Cape | 3 | 14641 | 0 | no | no |
| 20427 | Battle Healer's Cloak | 3 | 730 | 18 | no | no |
| 20428 | Caretaker's Cape | 3 | 730 | 18 | no | no |
| 20537 | Runed Stygian Boots | 3 | 17736 | 58 | no | no |
| 20538 | Runed Stygian Leggings | 3 | 23733 | 58 | no | no |
| 20539 | Runed Stygian Belt | 3 | 11908 | 58 | no | no |
| 20705 | Cenarion Reservist's Pants | 3 | 21968 | 0 | no | no |
| 20706 | Cenarion Reservist's Pants | 3 | 21968 | 0 | no | no |
| 20707 | Cenarion Reservist's Pants | 3 | 21968 | 0 | no | no |
| 20716 | Sandworm Skin Gloves | 3 | 11225 | 0 | no | no |
| 20717 | Desert Bloom Gloves | 3 | 10984 | 0 | no | no |
| 21183 | Earthpower Vest | 3 | 25495 | 0 | no | no |
| 21187 | Earthweave Cloak | 3 | 16409 | 0 | no | no |
| 22230 | Frightmaw Hide | 3 | 9978 | 0 | no | no |
| 22660 | Gaea's Embrace | 3 | 24601 | 60 | no | no |
| 22756 | Sylvan Vest | 3 | 33164 | 60 | no | no |
| 22757 | Sylvan Crown | 3 | 24961 | 60 | no | no |
| 22758 | Sylvan Shoulders | 3 | 25051 | 60 | no | no |
| 23289 | Knight-Lieutenant's Satin Walkers | 3 | 9526 | 60 | no | no |
| 23291 | Knight-Lieutenant's Silk Walkers | 3 | 9865 | 60 | no | no |
| 23302 | Knight-Captain's Satin Legguards | 3 | 15096 | 60 | no | no |
| 23303 | Knight-Captain's Satin Tunic | 3 | 15149 | 60 | no | no |
| 23304 | Knight-Captain's Silk Legguards | 3 | 15203 | 60 | no | no |
| 23305 | Knight-Captain's Silk Tunic | 3 | 15258 | 60 | no | no |
| 23316 | Lieutenant Commander's Satin Hood | 3 | 12823 | 60 | no | no |
| 23317 | Lieutenant Commander's Satin Mantle | 3 | 12871 | 60 | no | no |
| 23318 | Lieutenant Commander's Silk Cowl | 3 | 12917 | 60 | no | no |
| 23319 | Lieutenant Commander's Silk Mantle | 3 | 12964 | 60 | no | no |
| 210781 | Phoenix Bindings | 3 | 744 | 25 | no | no |
| 215112 | UNUSED - Cloak of Arcane Insulation | 3 | 3788 | 35 | no | no |
| 253885 | Novice Arcanist's Sash | 3 | 174 | 10 | no | no |
| 253887 | Novice Ardent's Sash | 3 | 176 | 10 | no | no |
| 253889 | Pristine Boots | 3 | 351 | 12 | no | no |
| 253891 | Silky Boots | 3 | 320 | 12 | no | no |
| 253893 | Flame Boots | 3 | 323 | 12 | no | no |
| 253895 | Shadow Boots | 3 | 325 | 12 | no | no |
| 253897 | Pearly Boots | 3 | 328 | 12 | no | no |
| 253899 | Shining Boots | 3 | 330 | 12 | no | no |
| 253901 | Filigreed Pristine Gown | 3 | 354 | 15 | no | no |
| 253903 | Filigreed Silky Gown | 3 | 342 | 15 | no | no |
| 253905 | Filigreed Flame Gown | 3 | 345 | 15 | no | no |
| 253907 | Filigreed Shadow Gown | 3 | 347 | 15 | no | no |
| 253909 | Filigreed Pearly Gown | 3 | 353 | 15 | no | no |
| 253911 | Filigreed Shining Gown | 3 | 332 | 15 | no | no |
| 253913 | Pristine Gloves | 3 | 327 | 15 | no | no |
| 253915 | Silky Gloves | 3 | 330 | 15 | no | no |
| 253917 | Flame Gloves | 3 | 341 | 15 | no | no |
| 253919 | Shadow Gloves | 3 | 344 | 15 | no | no |
| 253921 | Pearly Gloves | 3 | 346 | 15 | no | no |
| 253923 | Shining Gloves | 3 | 349 | 15 | no | no |
| 253925 | Pristine Sash | 3 | 465 | 17 | no | no |
| 253927 | Silky Sash | 3 | 468 | 17 | no | no |
| 253929 | Flame Sash | 3 | 471 | 17 | no | no |
| 253931 | Shadow Sash | 3 | 429 | 17 | no | no |
| 253933 | Pearly Sash | 3 | 445 | 17 | no | no |
| 253935 | Shining Sash | 3 | 448 | 17 | no | no |
| 253937 | Filigreed Pristine Leggings | 3 | 658 | 20 | no | no |
| 253939 | Filigreed Silky Leggings | 3 | 650 | 20 | no | no |
| 253941 | Filigreed Flame Leggings | 3 | 674 | 20 | no | no |
| 253943 | Filigreed Shadow Leggings | 3 | 659 | 20 | no | no |
| 253945 | Filigreed Pearly Leggings | 3 | 684 | 20 | no | no |
| 253947 | Filigreed Shining Leggings | 3 | 682 | 20 | no | no |
| 253949 | Pristine Circlet | 3 | 948 | 20 | no | no |
| 253951 | Silky Circlet | 3 | 955 | 20 | no | no |
| 253953 | Flame Circlet | 3 | 962 | 20 | no | no |
| 253955 | Shadow Circlet | 3 | 970 | 20 | no | no |
| 253957 | Pearly Circlet | 3 | 977 | 20 | no | no |
| 253959 | Shining Circlet | 3 | 984 | 20 | no | no |
| 253961 | Pristine Gown | 3 | 1643 | 22 | no | no |
| 253963 | Silky Gown | 3 | 1655 | 22 | no | no |
| 253965 | Flame Gown | 3 | 1548 | 22 | no | no |
| 253967 | Shadow Gown | 3 | 1560 | 22 | no | no |
| 253969 | Pearly Gown | 3 | 1572 | 22 | no | no |
| 253971 | Shining Gown | 3 | 1584 | 22 | no | no |
| 253975 | Filigreed Pristine Circlet | 3 | 803 | 25 | no | no |
| 253977 | Filigreed Silky Circlet | 3 | 792 | 25 | no | no |
| 253979 | Filigreed Flame Circlet | 3 | 806 | 25 | no | no |
| 253981 | Filigreed Shadow Circlet | 3 | 837 | 25 | no | no |
| 253983 | Filigreed Pearly Circlet | 3 | 848 | 25 | no | no |
| 253985 | Filigreed Shining Circlet | 3 | 788 | 25 | no | no |
| 253987 | Pristine Leggings | 3 | 2076 | 25 | no | no |
| 253989 | Silky Leggings | 3 | 2092 | 25 | no | no |
| 253991 | Flame Leggings | 3 | 2108 | 25 | no | no |
| 253993 | Shadow Leggings | 3 | 2124 | 25 | no | no |
| 253995 | Pearly Leggings | 3 | 2139 | 25 | no | no |
| 253997 | Shining Leggings | 3 | 2155 | 25 | no | no |
| 254001 | Gilded Slippers | 3 | 1356 | 30 | no | no |
| 254003 | Frothing Slippers | 3 | 1365 | 30 | no | no |
| 254005 | Fiery Slippers | 3 | 1244 | 30 | no | no |
| 254007 | Black Slippers | 3 | 1254 | 30 | no | no |
| 254009 | Golden Slippers | 3 | 1263 | 30 | no | no |
| 254011 | Radiant Slippers | 3 | 1273 | 30 | no | no |
| 254021 | Gilded Handwraps | 3 | 2754 | 35 | no | no |
| 254023 | Frothing Handwraps | 3 | 2773 | 35 | no | no |
| 254025 | Fiery Handwraps | 3 | 2528 | 35 | no | no |
| 254027 | Black Handwraps | 3 | 0 | 35 | no | no |
| 254029 | Golden Handwraps | 3 | 2567 | 35 | no | no |
| 254031 | Radiant Handwraps | 3 | 2656 | 35 | no | no |
| 254037 | Gilded Cord | 3 | 1995 | 40 | no | no |
| 254039 | Frothing Cord | 3 | 2009 | 40 | no | no |
| 254041 | Fiery Cord | 3 | 2023 | 40 | no | no |
| 254043 | Black Cord | 3 | 2038 | 40 | no | no |
| 254045 | Golden Cord | 3 | 1857 | 40 | no | no |
| 254047 | Radiant Cord | 3 | 1923 | 40 | no | no |
| 254049 | Nethergeld Shoulders | 3 | 6779 | 42 | no | no |
| 254051 | Netherfroth Shoulders | 3 | 6828 | 42 | no | no |
| 254053 | Netherflame Shoulders | 3 | 6879 | 42 | no | no |
| 254055 | Netherpearl Shoulders | 3 | 6928 | 42 | no | no |
| 254057 | Nethershine Shoulders | 3 | 6979 | 42 | no | no |
| 254059 | Netherlight Shoulders | 3 | 7028 | 42 | no | no |
| 254061 | Nethergeld Cuffs | 3 | 5835 | 45 | no | no |
| 254063 | Netherfroth Cuffs | 3 | 5463 | 45 | no | no |
| 254065 | Netherflame Cuffs | 3 | 5505 | 45 | no | no |
| 254067 | Netherpearl Cuffs | 3 | 5546 | 45 | no | no |
| 254069 | Nethershine Cuffs | 3 | 5587 | 45 | no | no |
| 254071 | Netherlight Cuffs | 3 | 5628 | 45 | no | no |
| 254081 | Gilded Waistcord | 3 | 6149 | 47 | no | no |
| 254083 | Frothing Waistcord | 3 | 6196 | 47 | no | no |
| 254085 | Fiery Waistcord | 3 | 6242 | 47 | no | no |
| 254087 | Black Waistcord | 3 | 6289 | 47 | no | no |
| 254089 | Golden Waistcord | 3 | 6336 | 47 | no | no |
| 254091 | Radiant Waistcord | 3 | 6383 | 47 | no | no |
| 254095 | Gilded Gloves | 3 | 3958 | 50 | no | no |
| 254097 | Frothing Gloves | 3 | 3606 | 50 | no | no |
| 254099 | Fiery Gloves | 3 | 3634 | 50 | no | no |
| 254101 | Black Gloves | 3 | 3662 | 50 | no | no |
| 254103 | Golden Gloves | 3 | 3690 | 50 | no | no |
| 254105 | Radiant Gloves | 3 | 3717 | 50 | no | no |
| 254107 | Gilded Sandals | 3 | 11236 | 50 | no | no |
| 254109 | Frothing Sandals | 3 | 11319 | 50 | no | no |
| 254111 | Fiery Sandals | 3 | 11704 | 50 | no | no |
| 254113 | Black Sandals | 3 | 11787 | 50 | no | no |
| 254115 | Golden Sandals | 3 | 11870 | 50 | no | no |
| 254117 | Radiant Sandals | 3 | 10816 | 50 | no | no |
| 260212 | Bad Hat | 3 | 8664 | 0 | no | no |
| 270118 | Cindercloth Gown | 3 | 11396 | 0 | no | no |
| 271716 | Explorer's League Dustcover | 3 | 805 | 0 | no | no |
| 271719 | Furs of the Earthen Ring | 3 | 805 | 0 | no | no |
| 271720 | Crocolisk Skin Gaiter | 3 | 2122 | 25 | no | no |
| 271810 | Corpsefeeder's Shedding | 3 | 5143 | 1 | no | no |
| 271812 | Discarded Circlet | 3 | 5180 | 1 | no | no |
| 272413 | Drape of Recovery | 3 | 16409 | 60 | no | no |
| 272451 | Sergeant's Cloak | 3 | 4285 | 45 | no | no |
| 272454 | Premier Magus Cuffs | 3 | 0 | 55 | no | no |
| 272456 | Premier Magus Belt | 3 | 0 | 55 | no | no |
| 272550 | Premier Felweave Belt | 3 | 0 | 55 | no | no |
| 272551 | Premier Felweave Bracers | 3 | 0 | 55 | no | no |
| 272566 | Premier Satin Sash | 3 | 0 | 55 | no | no |
| 272567 | Premier Satin Cuffs | 3 | 0 | 55 | no | no |
| 272578 | Premier Sergeant's Cloak | 3 | 0 | 55 | no | no |
| 272589 | Premier Sergeant's Cape | 3 | 0 | 55 | no | no |
| 272698 | Premier Sergeant's Cloak | 3 | 0 | 55 | no | no |
| 272699 | Premier Sergeant's Cape | 3 | 0 | 55 | no | no |
| 272700 | Premier Silk Sash | 3 | 0 | 55 | no | no |
| 272702 | Premier Silk Cuffs | 3 | 0 | 55 | no | no |
| 272795 | Premier Dreadweave Bracers | 3 | 0 | 55 | no | no |
| 272797 | Premier Dreadweave Belt | 3 | 0 | 55 | no | no |
| 272811 | Premier Voidcloth Cuffs | 3 | 0 | 55 | no | no |
| 272813 | Premier Voidcloth Cord | 3 | 0 | 55 | no | no |
| 273444 | Premier Mooncloth Cuffs | 3 | 0 | 55 | no | no |
| 273449 | Premier Mooncloth Cord | 3 | 0 | 55 | no | no |
| 273450 | Premier Silken Cuffs | 3 | 0 | 55 | no | no |
| 275437 | Premier Silken Sash | 3 | 0 | 55 | no | no |
| 275604 | Venomspew Gloves | 3 | 9017 | 53 | no | no |
| 275605 | Venomspew Cord | 3 | 9050 | 53 | no | no |
| 275606 | Venomspew Footpads | 3 | 13626 | 53 | no | no |
| 275607 | Swarmtender's Gloves | 3 | 9117 | 53 | no | no |
| 275608 | Swarmtender's Cord | 3 | 9149 | 53 | no | no |
| 275609 | Swarmtender's Footpads | 3 | 13774 | 53 | no | no |
| 275711 | Chimaera Wing Cape | 3 | 14897 | 0 | no | no |
| 277205 | Cloak of the Divine Storm | 3 | 0 | 0 | no | no |
| 281319 | Golem War Cloak | 3 | 0 | 0 | no | no |

### 4/1 Armadura / Tela, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 14146 | Gloves of Spell Mastery | 4 | 14084 | 57 | no | no |
| 16437 | Marshal's Silk Footwraps | 4 | 17523 | 60 | no | no |
| 16438 | Marshal's Silk Bracers | 4 | 8749 | 60 | no | no |
| 16439 | Marshal's Silk Sash | 4 | 8779 | 60 | no | no |
| 16441 | Field Marshal's Coronet | 4 | 20575 | 60 | no | no |
| 16442 | Marshal's Silk Leggings | 4 | 23780 | 60 | no | no |
| 16443 | Field Marshal's Silk Vestments | 4 | 25692 | 60 | no | no |
| 16444 | Field Marshal's Silk Spaulders | 4 | 19342 | 60 | no | no |
| 16533 | Warlord's Silk Cowl | 4 | 20504 | 60 | no | no |
| 16534 | General's Silk Trousers | 4 | 23700 | 60 | no | no |
| 16535 | Warlord's Silk Raiment | 4 | 27533 | 60 | no | no |
| 16536 | Warlord's Silk Amice | 4 | 18751 | 60 | no | no |
| 16537 | General's Silk Sash | 4 | 8088 | 60 | no | no |
| 16538 | General's Silk Cuffs | 4 | 8120 | 60 | no | no |
| 16539 | General's Silk Boots | 4 | 16836 | 60 | no | no |
| 16979 | Flarecore Gloves | 4 | 14902 | 57 | no | no |
| 16980 | Flarecore Mantle | 4 | 21365 | 56 | no | no |
| 17578 | Field Marshal's Coronal | 4 | 19632 | 60 | no | no |
| 17579 | Marshal's Dreadweave Leggings | 4 | 22695 | 60 | no | no |
| 17580 | Field Marshal's Dreadweave Shoulders | 4 | 19775 | 60 | no | no |
| 17581 | Field Marshal's Dreadweave Robe | 4 | 26465 | 60 | no | no |
| 17582 | Marshal's Dreadweave Cuffs | 4 | 8561 | 60 | no | no |
| 17583 | Marshal's Dreadweave Boots | 4 | 17270 | 60 | no | no |
| 17585 | Marshal's Dreadweave Sash | 4 | 8878 | 60 | no | no |
| 17586 | General's Dreadweave Boots | 4 | 16206 | 60 | no | no |
| 17587 | General's Dreadweave Bracers | 4 | 8093 | 60 | no | no |
| 17589 | General's Dreadweave Belt | 4 | 8155 | 60 | no | no |
| 17590 | Warlord's Dreadweave Mantle | 4 | 19051 | 60 | no | no |
| 17591 | Warlord's Dreadweave Hood | 4 | 19121 | 60 | no | no |
| 17592 | Warlord's Dreadweave Robe | 4 | 25593 | 60 | no | no |
| 17593 | General's Dreadweave Pants | 4 | 22192 | 60 | no | no |
| 17602 | Field Marshal's Headdress | 4 | 20439 | 60 | no | no |
| 17603 | Marshal's Satin Pants | 4 | 23626 | 60 | no | no |
| 17604 | Field Marshal's Satin Mantle | 4 | 20585 | 60 | no | no |
| 17605 | Field Marshal's Satin Vestments | 4 | 27544 | 60 | no | no |
| 17606 | Marshal's Satin Bracers | 4 | 8060 | 60 | no | no |
| 17607 | Marshal's Satin Sandals | 4 | 16266 | 60 | no | no |
| 17609 | Marshal's Satin Sash | 4 | 8154 | 60 | no | no |
| 17618 | General's Satin Boots | 4 | 17404 | 60 | no | no |
| 17619 | General's Satin Bracers | 4 | 8689 | 60 | no | no |
| 17621 | General's Satin Cinch | 4 | 8751 | 60 | no | no |
| 17622 | Warlord's Satin Mantle | 4 | 20437 | 60 | no | no |
| 17623 | Warlord's Satin Cowl | 4 | 20510 | 60 | no | no |
| 17624 | Warlord's Satin Robes | 4 | 27444 | 60 | no | no |
| 17625 | General's Satin Leggings | 4 | 23789 | 60 | no | no |
| 18263 | Flarecore Wraps | 4 | 16911 | 60 | no | no |
| 18405 | Belt of the Archmage | 4 | 14744 | 57 | no | no |
| 18509 | Chromatic Cloak | 4 | 23006 | 57 | no | no |
| 18510 | Hide of the Wild | 4 | 20889 | 57 | no | no |
| 18511 | Shifting Cloak | 4 | 20971 | 57 | no | no |
| 19156 | Flarecore Robe | 4 | 34911 | 60 | no | no |
| 19165 | Flarecore Leggings | 4 | 45006 | 60 | no | no |
| 19595 | Dryad's Wrist Bindings | 4 | 17509 | 60 | no | no |
| 19596 | Dryad's Wrist Bindings | 4 | 10485 | 50 | no | no |
| 19597 | Dryad's Wrist Bindings | 4 | 5401 | 40 | no | no |
| 19844 | Zandalar Illusionist's Robe DEPRECATED | 4 | 35388 | 0 | no | no |
| 19847 | Zandalar Demoniac's Robe DEPRECATED | 4 | 32372 | 0 | no | no |
| 19926 | Flowing Ritual Robes DEPRECATED | 4 | 30047 | 60 | no | no |
| 20068 | Deathguard's Cloak | 4 | 26353 | 60 | no | no |
| 20073 | Cloak of the Honor Guard | 4 | 24279 | 60 | no | no |
| 20145 | 90 Epic Warrior Cloak | 4 | 40962 | 60 | no | no |
| 20276 | 90 Epic Rogue Cloak | 4 | 89888 | 60 | no | no |
| 20324 | 90 Epic Frost Belt | 4 | 57374 | 60 | no | no |
| 20325 | 90 Epic Frost Bindings | 4 | 57586 | 60 | no | no |
| 20326 | 90 Epic Frost Boots | 4 | 86697 | 60 | no | no |
| 20327 | 90 Epic Frost Crown | 4 | 87016 | 60 | no | no |
| 20328 | 90 Epic Frost Gloves | 4 | 58217 | 60 | no | no |
| 20329 | 90 Epic Frost Leggings | 4 | 116858 | 60 | no | no |
| 20330 | 90 Epic Frost Mantle | 4 | 87962 | 60 | no | no |
| 20331 | 90 Epic Frost Robes | 4 | 117706 | 60 | no | no |
| 20336 | 90 Epic Frost Shroud | 4 | 83524 | 60 | no | no |
| 21186 | Rockfury Bracers | 4 | 14533 | 0 | no | no |
| 21339 | Doomcaller's Handwraps [PH] | 4 | 31715 | 60 | no | no |
| 21527 | Darkwater Robes | 4 | 60872 | 60 | no | no |
| 21582 | Grasp of the Old God | 4 | 51078 | 60 | no | no |
| 21583 | Cloak of Clarity | 4 | 76906 | 60 | no | no |
| 21585 | Dark Storm Gauntlets | 4 | 51655 | 60 | no | no |
| 21600 | Boots of Epiphany | 4 | 54040 | 60 | no | no |
| 21604 | Bracelets of Royal Redemption | 4 | 37549 | 60 | no | no |
| 21611 | Burrower Bracers | 4 | 38499 | 60 | no | no |
| 21615 | Don Rigoberto's Lost Hat | 4 | 53014 | 60 | no | no |
| 21619 | Gloves of the Messiah | 4 | 31846 | 60 | no | no |
| 21648 | Recomposed Boots | 4 | 44756 | 60 | no | no |
| 21663 | Robes of the Guardian Saint | 4 | 61534 | 60 | no | no |
| 21694 | Ternary Mantle | 4 | 40482 | 60 | no | no |
| 21710 | Cloak of the Fallen God | 4 | 75174 | 60 | no | no |
| 21888 | Gloves of the Immortal | 4 | 22875 | 60 | no | no |
| 22652 | Glacial Vest | 4 | 69171 | 60 | no | no |
| 22654 | Glacial Gloves | 4 | 34846 | 60 | no | no |
| 22655 | Glacial Wrists | 4 | 34973 | 60 | no | no |
| 22658 | Glacial Cloak | 4 | 53045 | 60 | no | no |
| 22667 | Bracers of Hope | 4 | 12789 | 0 | no | no |
| 22700 | Glacial Leggings | 4 | 73085 | 0 | no | no |
| 22747 | Outrider's Silk Leggings | 4 | 33526 | 60 | no | no |
| 22752 | Sentinel's Silk Leggings | 4 | 34149 | 60 | no | no |
| 22968 | Glacial Mantle | 4 | 59390 | 0 | no | no |
| 23032 | Glacial Headdress | 4 | 60264 | 60 | no | no |
| 271945 | Theramore Handwraps | 4 | 13150 | 60 | no | no |
| 271946 | Theramore Handwraps | 4 | 7874 | 50 | no | no |
| 272097 | Raider Handwraps | 4 | 13150 | 60 | no | no |
| 272098 | Raider Handwraps | 4 | 7874 | 50 | no | no |
| 272394 | Penitent's Cinch | 4 | 50000 | 60 | no | no |
| 272502 | Premier Legionnaire's Magus Sash | 4 | 0 | 60 | no | no |
| 272503 | Premier Legionnaire's Magus Cuffs | 4 | 0 | 60 | no | no |
| 272555 | Premier Legionnaire's Felweave Bracers | 4 | 0 | 60 | no | no |
| 272557 | Premier Legionnaire's Felweave Belt | 4 | 0 | 60 | no | no |
| 272571 | Premier Legionnaire's Satin Bracers | 4 | 0 | 60 | no | no |
| 272573 | Premier Legionnaire's Satin Cinch | 4 | 0 | 60 | no | no |
| 272747 | Premier Knight-Captain's Silk Bracers | 4 | 0 | 60 | no | no |
| 272748 | Premier Knight-Captain's Silk Sash | 4 | 0 | 60 | no | no |
| 272806 | Premier Knight-Captain's Dreadweave Cuffs | 4 | 0 | 60 | no | no |
| 272809 | Premier Knight-Captain's Dreadweave Sash | 4 | 0 | 60 | no | no |
| 272822 | Premier Knight-Captain's Voidcloth Bracers | 4 | 0 | 60 | no | no |
| 272825 | Premier Knight-Captain's Voidcloth Sash | 4 | 0 | 60 | no | no |
| 273425 | Premier Knight-Captain's Mooncloth Bracers | 4 | 0 | 60 | no | no |
| 273428 | Premier Knight-Captain's Mooncloth Sash | 4 | 0 | 60 | no | no |
| 273430 | Premier Legionnaire's Silken Bracers | 4 | 0 | 60 | no | no |
| 273432 | Premier Legionnaire's Silken Cinch | 4 | 0 | 60 | no | no |
| 273878 | [DNT] Crafted Tier Piece Placeholder | 4 | 0 | 60 | no | no |
| 274027 | Placeholder | 4 | 0 | 60 | no | no |
| 279266 | Robes of Fiery Devastation | 4 | 21117 | 60 | no | no |
| 279267 | Mana-infused Cord | 4 | 3262 | 60 | no | no |
| 279268 | Rime-encrusted Boots | 4 | 17158 | 60 | no | no |
| 279269 | Fel Cape | 4 | 9999 | 60 | no | no |
| 279270 | Cloak of Earth and Sky | 4 | 9999 | 60 | no | no |

### 4/2 Armadura / Cuero, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 60 | Layered Tunic | 1 | 12 | 0 | no | no |
| 61 | Dwarven Leather Pants | 1 | 12 | 0 | no | no |
| 85 | Dirty Leather Vest | 1 | 12 | 1 | no | no |
| 209 | Dirty Leather Pants | 1 | 12 | 1 | no | no |
| 210 | Dirty Leather Boots | 1 | 9 | 1 | no | no |
| 236 | Cured Leather Armor | 1 | 559 | 17 | no | no |
| 237 | Cured Leather Pants | 1 | 561 | 17 | no | no |
| 238 | Cured Leather Boots | 1 | 422 | 17 | no | no |
| 239 | Cured Leather Gloves | 1 | 282 | 17 | no | no |
| 714 | Dirty Leather Gloves | 1 | 6 | 1 | no | no |
| 796 | Rough Leather Boots | 1 | 52 | 5 | no | no |
| 797 | Rough Leather Gloves | 1 | 35 | 5 | no | no |
| 798 | Rough Leather Pants | 1 | 70 | 5 | no | no |
| 799 | Rough Leather Vest | 1 | 71 | 5 | no | no |
| 843 | Tanned Leather Boots | 1 | 215 | 12 | no | no |
| 844 | Tanned Leather Gloves | 1 | 144 | 12 | no | no |
| 845 | Tanned Leather Pants | 1 | 289 | 12 | no | no |
| 846 | Tanned Leather Jerkin | 1 | 290 | 12 | no | no |
| 1020 | Leather Helmet D (Test) | 1 | 1 | 1 | no | no |
| 1021 | Leather Helmet A (test) | 1 | 1 | 1 | no | no |
| 1022 | Mail Helmet D (test) | 1 | 1 | 1 | no | no |
| 1023 | Mail Helmet C (test) | 1 | 1 | 1 | no | no |
| 1024 | Plate Helmet D2 (test) | 1 | 1 | 1 | no | no |
| 1025 | Plate Helmet D1 (Test) | 1 | 1 | 1 | no | no |
| 1026 | Plate Helmet D3 (test) | 1 | 1 | 1 | no | no |
| 1027 | Mail Helmet A (Test) | 1 | 1 | 1 | no | no |
| 1170 | Deprecated Brown Leather Vest | 1 | 37 | 0 | no | no |
| 1173 | Weather-worn Boots | 1 | 52 | 0 | no | no |
| 1213 | Gnoll Kindred Bracers | 1 | 87 | 9 | no | no |
| 1359 | Lion-stamped Gloves | 1 | 19 | 0 | no | no |
| 1835 | Dirty Leather Belt | 1 | 6 | 1 | no | no |
| 1836 | Dirty Leather Bracers | 1 | 6 | 1 | no | no |
| 1839 | Rough Leather Belt | 1 | 36 | 5 | no | no |
| 1840 | Rough Leather Bracers | 1 | 37 | 5 | no | no |
| 1843 | Tanned Leather Belt | 1 | 145 | 12 | no | no |
| 1844 | Tanned Leather Bracers | 1 | 145 | 12 | no | no |
| 1849 | Cured Leather Belt | 1 | 277 | 17 | no | no |
| 1850 | Cured Leather Bracers | 1 | 278 | 17 | no | no |
| 2108 | Frostmane Leather Vest | 1 | 8 | 1 | no | no |
| 2112 | Lumberjack Jerkin | 1 | 54 | 4 | no | no |
| 2122 | Cracked Leather Belt | 1 | 6 | 1 | no | no |
| 2123 | Cracked Leather Boots | 1 | 9 | 1 | no | no |
| 2124 | Cracked Leather Bracers | 1 | 6 | 1 | no | no |
| 2125 | Cracked Leather Gloves | 1 | 6 | 1 | no | no |
| 2126 | Cracked Leather Pants | 1 | 11 | 1 | no | no |
| 2127 | Cracked Leather Vest | 1 | 12 | 1 | no | no |
| 2141 | Cuirboulli Vest | 1 | 1044 | 22 | no | no |
| 2142 | Cuirboulli Belt | 1 | 524 | 22 | no | no |
| 2143 | Cuirboulli Boots | 1 | 788 | 22 | no | no |
| 2144 | Cuirboulli Bracers | 1 | 527 | 22 | no | no |
| 2145 | Cuirboulli Gloves | 1 | 529 | 22 | no | no |
| 2146 | Cuirboulli Pants | 1 | 961 | 22 | no | no |
| 2173 | Old Leather Belt | 1 | 6 | 0 | no | no |
| 2186 | Outfitter Belt | 1 | 6 | 0 | no | no |
| 2237 | Patched Pants | 1 | 75 | 0 | no | no |
| 2302 | Handstitched Leather Boots | 1 | 29 | 3 | no | no |
| 2327 | Sturdy Leather Bracers | 1 | 36 | 5 | no | no |
| 2370 | Battered Leather Harness | 1 | 75 | 5 | no | no |
| 2371 | Battered Leather Belt | 1 | 37 | 5 | no | no |
| 2372 | Battered Leather Pants | 1 | 68 | 5 | no | no |
| 2373 | Battered Leather Boots | 1 | 51 | 5 | no | no |
| 2374 | Battered Leather Bracers | 1 | 34 | 5 | no | no |
| 2375 | Battered Leather Gloves | 1 | 34 | 5 | no | no |
| 2463 | Studded Doublet | 1 | 2739 | 32 | no | no |
| 2464 | Studded Belt | 1 | 1374 | 32 | no | no |
| 2465 | Studded Pants | 1 | 2495 | 32 | no | no |
| 2467 | Studded Boots | 1 | 1886 | 32 | no | no |
| 2468 | Studded Bracers | 1 | 1262 | 32 | no | no |
| 2469 | Studded Gloves | 1 | 1266 | 32 | no | no |
| 2470 | Reinforced Leather Vest | 1 | 6790 | 45 | no | no |
| 2471 | Reinforced Leather Belt | 1 | 3408 | 45 | no | no |
| 2472 | Reinforced Leather Pants | 1 | 6842 | 45 | no | no |
| 2473 | Reinforced Leather Boots | 1 | 5150 | 45 | no | no |
| 2474 | Reinforced Leather Bracers | 1 | 3446 | 45 | no | no |
| 2475 | Reinforced Leather Gloves | 1 | 3459 | 45 | no | no |
| 2588 | Deprecated Red Leather Mask | 1 | 324 | 15 | no | no |
| 2963 | Burnt Leather Boots | 1 | 41 | 4 | no | no |
| 2964 | Burnt Leather Gloves | 1 | 36 | 5 | no | no |
| 2975 | Hunting Boots | 1 | 128 | 9 | no | no |
| 3152 | Driving Gloves | 1 | 28 | 0 | no | no |
| 3158 | Burnt Hide Bracers | 1 | 60 | 0 | no | no |
| 3200 | Burnt Leather Bracers | 1 | 19 | 3 | no | no |
| 3207 | Hunting Bracers | 1 | 87 | 9 | no | no |
| 3272 | Zombie Skin Leggings | 1 | 13 | 0 | no | no |
| 3284 | Tribal Boots | 1 | 88 | 7 | no | no |
| 3285 | Tribal Bracers | 1 | 36 | 5 | no | no |
| 3286 | Tribal Gloves | 1 | 59 | 7 | no | no |
| 3311 | Ceremonial Leather Ankleguards | 1 | 152 | 10 | no | no |
| 3312 | Ceremonial Leather Bracers | 1 | 70 | 8 | no | no |
| 3321 | Gray Fur Booties | 1 | 41 | 4 | no | no |
| 3435 | Zombie Skin Bracers | 1 | 19 | 0 | no | no |
| 3439 | Zombie Skin Boots | 1 | 30 | 0 | no | no |
| 3444 | Tiller's Vest | 1 | 90 | 0 | no | no |
| 3528 | Red Leather C03 Breastplate | 1 | 1 | 1 | no | no |
| 3532 | Unused Red Leather C03 Pants | 1 | 1 | 1 | no | no |
| 3533 | Red Leather C03 Boots | 1 | 1 | 1 | no | no |
| 3534 | Unused Red Leather C03 Gloves | 1 | 1 | 1 | no | no |
| 3535 | Red Leather C03 Bracers | 1 | 1 | 1 | no | no |
| 3537 | Black Leather D02 Breastplate | 1 | 1 | 1 | no | no |
| 3538 | Gray Leather D02 Breastplate | 1 | 1 | 1 | no | no |
| 3539 | Unused Black Leather D02 Pants | 1 | 1 | 1 | no | no |
| 3540 | Unused Gray Leather D02 Pants | 1 | 1 | 1 | no | no |
| 3541 | Black Leather D02 Boots | 1 | 1 | 1 | no | no |
| 3542 | Gray Leather D02 Boots | 1 | 1 | 1 | no | no |
| 3543 | Unused Black Leather D02 Gloves | 1 | 1 | 1 | no | no |
| 3544 | Unused Gray Leather D02 Gloves | 1 | 1 | 1 | no | no |
| 3545 | Black Leather D02 Bracers | 1 | 1 | 1 | no | no |
| 3546 | Gray Leather D02 Bracers | 1 | 1 | 1 | no | no |
| 3547 | White Leather D03 Breastplate | 1 | 1 | 1 | no | no |
| 3548 | Unused White Leather D03 Pants | 1 | 1 | 1 | no | no |
| 3549 | Unused White Leather D03 Gloves | 1 | 1 | 1 | no | no |
| 3583 | Weathered Belt | 1 | 57 | 0 | no | no |
| 3884 | Deprecated Cured Leather Cap | 1 | 418 | 17 | no | no |
| 3887 | Deprecated Cuirboulli Cap | 1 | 757 | 22 | no | no |
| 3890 | Studded Hat | 1 | 2040 | 32 | no | no |
| 3893 | Reinforced Leather Cap | 1 | 5504 | 45 | no | no |
| 4190 | Feathered Armor | 1 | 1025 | 22 | no | no |
| 4191 | Unused Feathered Leggings | 1 | 1029 | 22 | no | no |
| 4192 | Unused Feathered Gauntlets | 1 | 516 | 22 | no | no |
| 4193 | Deprecated Feathered Helm | 1 | 777 | 22 | no | no |
| 4194 | Feathered Bracers | 1 | 520 | 22 | no | no |
| 4195 | Feathered Boots | 1 | 727 | 22 | no | no |
| 4664 | Deprecated Burnt Leather Shoulderpads | 1 | 73 | 6 | no | no |
| 4666 | Burnt Leather Belt | 1 | 26 | 4 | no | no |
| 4673 | Deprecated Tribal Mantle | 1 | 86 | 7 | no | no |
| 4675 | Tribal Belt | 1 | 35 | 5 | no | no |
| 4690 | Hunting Belt | 1 | 71 | 8 | no | no |
| 4693 | Ceremonial Leather Belt | 1 | 86 | 9 | no | no |
| 4700 | Inscribed Leather Spaulders | 1 | 379 | 16 | no | no |
| 4853 | TEST QUEST HELM | 1 | 9 | 5 | no | no |
| 4906 | Rainwalker Boots | 1 | 21 | 0 | no | no |
| 4907 | Woodland Tunic | 1 | 13 | 0 | no | no |
| 4908 | Nomadic Bracers | 1 | 6 | 0 | no | no |
| 4914 | Battleworn Leather Gloves | 1 | 5 | 0 | no | no |
| 4921 | Dust-covered Leggings | 1 | 12 | 0 | no | no |
| 4928 | Sandrunner Wristguards | 1 | 20 | 0 | no | no |
| 4929 | Light Scorpid Armor | 1 | 58 | 0 | no | no |
| 4940 | Veiled Grips | 1 | 36 | 0 | no | no |
| 4942 | Tiger Hide Boots | 1 | 89 | 0 | no | no |
| 4951 | Squealer's Belt | 1 | 13 | 1 | no | no |
| 4954 | Nomadic Belt | 1 | 6 | 0 | no | no |
| 4955 | Deprecated Nomadic Shoulderpads | 1 | 6 | 0 | no | no |
| 4962 | Double-layered Gloves | 1 | 20 | 0 | no | no |
| 4968 | Bound Harness | 1 | 90 | 0 | no | no |
| 4970 | Rough-hewn Kodo Leggings | 1 | 54 | 0 | no | no |
| 4973 | Plains Hunter Wristguards | 1 | 35 | 0 | no | no |
| 5108 | Dark Iron Leather | 1 | 1616 | 27 | no | no |
| 5294 | Deprecated Hands of the New Moon | 1 | 0 | 0 | no | no |
| 5295 | Deprecated Hands of the Crescent Moon | 1 | 0 | 0 | no | no |
| 5296 | Deprecated Hands of the Quarter Moon | 1 | 0 | 0 | no | no |
| 5297 | Deprecated Hands of the Gibbous Moon | 1 | 0 | 0 | no | no |
| 5298 | Deprecated Hands of the Full Moon | 1 | 0 | 0 | no | no |
| 5319 | Bashing Pauldrons | 1 | 323 | 15 | no | no |
| 5394 | Archery Training Gloves | 1 | 6 | 0 | no | no |
| 5398 | Canopy Leggings | 1 | 13 | 0 | no | no |
| 5419 | Feral Bracers | 1 | 13 | 0 | no | no |
| 5612 | Ivy Cuffs | 1 | 72 | 0 | no | no |
| 5936 | Animal Skin Belt | 1 | 19 | 0 | no | no |
| 5939 | Sewing Gloves | 1 | 20 | 0 | no | no |
| 6058 | Blackened Leather Belt | 1 | 6 | 0 | no | no |
| 6059 | Nomadic Vest | 1 | 13 | 0 | no | no |
| 6070 | Wolfskin Bracers | 1 | 6 | 0 | no | no |
| 6171 | Wolf Handler Gloves | 1 | 6 | 0 | no | no |
| 6517 | Pioneer Belt | 1 | 35 | 5 | no | no |
| 6518 | Pioneer Boots | 1 | 70 | 6 | no | no |
| 6519 | Pioneer Bracers | 1 | 36 | 5 | no | no |
| 6521 | Pioneer Gloves | 1 | 47 | 6 | no | no |
| 6523 | Buckled Harness | 1 | 284 | 12 | no | no |
| 6524 | Studded Leather Harness | 1 | 574 | 17 | no | no |
| 6525 | Grunt's Harness | 1 | 1033 | 22 | no | no |
| 6526 | Battle Harness | 1 | 2497 | 32 | no | no |
| 6588 | Scouting Spaulders | 1 | 458 | 18 | no | no |
| 7277 | Handstitched Leather Bracers | 1 | 28 | 4 | no | no |
| 9601 | Cushioned Boots | 1 | 87 | 0 | no | no |
| 9750 | Nomad Sash | 1 | 57 | 7 | no | no |
| 9751 | Nomad Sandals | 1 | 86 | 7 | no | no |
| 9752 | Nomad Bands | 1 | 57 | 7 | no | no |
| 9755 | Nomad Gloves | 1 | 73 | 8 | no | no |
| 10405 | Bandit Shoulders | 1 | 409 | 17 | no | no |
| 10636 | Nomadic Gloves | 1 | 6 | 0 | no | no |
| 11851 | Scavenger Tunic | 1 | 12 | 0 | no | no |
| 12962 | JEFF TEST GLOVES | 1 | 1 | 0 | no | no |
| 13732 | [PH] Rising Dawn Mitts | 1 | 1 | 1 | no | no |
| 13790 | [PH] Rising Dawn Cap | 1 | 1 | 1 | no | no |
| 15003 | Primal Belt | 1 | 20 | 3 | no | no |
| 15004 | Primal Boots | 1 | 42 | 4 | no | no |
| 15005 | Primal Bands | 1 | 28 | 4 | no | no |
| 15008 | Primal Mitts | 1 | 37 | 5 | no | no |
| 15013 | Lupine Cuffs | 1 | 86 | 9 | no | no |
| 15019 | Lupine Mantle | 1 | 366 | 16 | no | no |
| 15297 | Grizzly Bracers | 1 | 45 | 6 | no | no |
| 15300 | Grizzly Gloves | 1 | 86 | 9 | no | no |
| 15301 | Grizzly Slippers | 1 | 108 | 8 | no | no |
| 15302 | Grizzly Belt | 1 | 47 | 6 | no | no |
| 15313 | Feral Shoulder Pads | 1 | 514 | 19 | no | no |
| 257263 | Thendal Ranger's Belt | 1 | 6 | 0 | no | no |
| 257274 | Flowing Tunic | 1 | 12 | 0 | no | no |
| 257280 | Vuldren Hide Bracers | 1 | 6 | 0 | no | no |
| 257328 | Highlander Gloves | 1 | 19 | 0 | no | no |
| 257334 | Well-Worn Pants | 1 | 75 | 0 | no | no |
| 257341 | Wind-Worn Boots | 1 | 52 | 0 | no | no |
| 257879 | Prideclaw Hide Armor | 1 | 58 | 0 | no | no |
| 263408 | Exterminator's Vest | 1 | 12 | 2 | no | no |
| 263414 | Traveler's Wraps | 1 | 20 | 0 | no | no |
| 263421 | Bandit's Jerkin | 1 | 37 | 0 | no | no |
| 263424 | Wolfhide Belt | 1 | 19 | 0 | no | no |
| 277086 | Zephrali Harness | 1 | 172 | 9 | no | no |
| 277087 | Zephrali Bracers | 1 | 87 | 9 | no | no |
| 277088 | Zephrali Gloves | 1 | 87 | 9 | no | no |
| 277089 | Zephrali Belt | 1 | 87 | 9 | no | no |
| 277090 | Zephrali Trousers | 1 | 174 | 9 | no | no |
| 277091 | Zephrali Boots | 1 | 131 | 9 | no | no |
| 277092 | Zephrali Jerkin | 1 | 176 | 9 | no | no |
| 277093 | Zephrali Armguards | 1 | 89 | 9 | no | no |
| 277094 | Zephrali Mitts | 1 | 91 | 9 | no | no |
| 277095 | Zephrali Strap | 1 | 92 | 9 | no | no |
| 277096 | Zephrali Pants | 1 | 183 | 9 | no | no |
| 277097 | Zephrali Footwraps | 1 | 138 | 9 | no | no |
| 281266 | Furred Belt | 1 | 0 | 0 | no | no |
| 281322 | Frosthowl's Footwarmers | 1 | 0 | 0 | no | no |

### 4/2 Armadura / Cuero, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 763 | Ice-covered Bracers | 2 | 58 | 7 | no | no |
| 1302 | Black Whelp Gloves | 2 | 262 | 0 | no | no |
| 1306 | Wolfmane Wristguards | 2 | 352 | 0 | no | no |
| 1310 | Smith's Trousers | 2 | 715 | 0 | no | no |
| 1436 | Frontier Britches | 2 | 458 | 0 | no | no |
| 2036 | Dusty Mining Gloves | 2 | 258 | 0 | no | no |
| 2300 | Embossed Leather Vest | 2 | 192 | 7 | no | no |
| 2303 | Handstitched Leather Pants | 2 | 71 | 5 | no | no |
| 2307 | Fine Leather Boots | 2 | 195 | 13 | no | no |
| 2309 | Embossed Leather Boots | 2 | 217 | 10 | no | no |
| 2311 | White Leather Jerkin | 2 | 150 | 8 | no | no |
| 2314 | Toughened Leather Armor | 2 | 743 | 19 | no | no |
| 2315 | Gray Leather Boots | 2 | 307 | 15 | no | no |
| 2317 | Dark Leather Tunic | 2 | 689 | 15 | no | no |
| 2817 | Soft Leather Tunic | 2 | 201 | 0 | no | no |
| 2818 | Stretched Leather Trousers | 2 | 363 | 0 | no | no |
| 2949 | Mariner Boots | 2 | 1039 | 0 | no | no |
| 3431 | Bone-studded Leather | 2 | 1335 | 0 | no | no |
| 3566 | Raptorbane Armor | 2 | 2023 | 0 | no | no |
| 3578 | Harvester's Pants | 2 | 339 | 0 | no | no |
| 3585 | Camouflaged Tunic | 2 | 953 | 0 | no | no |
| 3741 | Stomping Boots | 2 | 922 | 0 | no | no |
| 3747 | Meditative Sash | 2 | 1092 | 0 | no | no |
| 3750 | Ribbed Breastplate | 2 | 2209 | 0 | no | no |
| 3753 | Shepherd's Girdle | 2 | 1635 | 0 | no | no |
| 3754 | Shepherd's Gloves | 2 | 1492 | 0 | no | no |
| 4107 | Tiger Hunter Gloves | 2 | 2136 | 0 | no | no |
| 4108 | Panther Hunter Leggings | 2 | 5403 | 0 | no | no |
| 4109 | Excelsior Boots | 2 | 4393 | 0 | no | no |
| 4119 | Raptor Hunter Tunic | 2 | 7271 | 0 | no | no |
| 4124 | Cap of Harmony | 2 | 3991 | 0 | no | no |
| 4131 | Belt of Corruption | 2 | 3815 | 0 | no | no |
| 4237 | Handstitched Leather Belt | 2 | 34 | 5 | no | no |
| 4239 | Embossed Leather Gloves | 2 | 71 | 8 | no | no |
| 4242 | Embossed Leather Pants | 2 | 347 | 10 | no | no |
| 4244 | Hillman's Leather Vest | 2 | 723 | 15 | no | no |
| 4247 | Hillman's Leather Gloves | 2 | 1049 | 24 | no | no |
| 4249 | Dark Leather Belt | 2 | 703 | 20 | no | no |
| 4250 | Hillman's Belt | 2 | 705 | 20 | no | no |
| 4251 | Hillman's Shoulders | 2 | 659 | 21 | no | no |
| 4252 | Dark Leather Shoulders | 2 | 1457 | 23 | no | no |
| 4254 | Barbaric Gloves | 2 | 1071 | 25 | no | no |
| 4256 | Guardian Armor | 2 | 3477 | 30 | no | no |
| 4257 | Green Leather Belt | 2 | 1311 | 27 | no | no |
| 4258 | Guardian Belt | 2 | 1592 | 29 | no | no |
| 4259 | Green Leather Bracers | 2 | 1934 | 31 | no | no |
| 4260 | Guardian Leather Bracers | 2 | 2559 | 34 | no | no |
| 4455 | Raptor Hide Harness | 2 | 3096 | 28 | no | no |
| 4456 | Raptor Hide Belt | 2 | 1553 | 28 | no | no |
| 4509 | Seawolf Gloves | 2 | 2794 | 0 | no | no |
| 4543 | White Drakeskin Cap | 2 | 4098 | 0 | no | no |
| 4788 | Agile Boots | 2 | 526 | 15 | no | no |
| 4789 | Stable Boots | 2 | 399 | 13 | no | no |
| 4794 | Wolf Bracers | 2 | 703 | 20 | no | no |
| 4795 | Bear Bracers | 2 | 705 | 20 | no | no |
| 4796 | Owl Bracers | 2 | 708 | 20 | no | no |
| 4830 | Saber Leggings | 2 | 1894 | 23 | no | no |
| 4831 | Stalking Pants | 2 | 1571 | 21 | no | no |
| 4832 | Mystic Sarong | 2 | 2099 | 24 | no | no |
| 4909 | Kodo Hunter's Leggings | 2 | 368 | 0 | no | no |
| 4976 | Mistspray Kilt | 2 | 5486 | 0 | no | no |
| 5275 | Binding Girdle | 2 | 175 | 0 | no | no |
| 5299 | Gloves of the Moon | 2 | 359 | 0 | no | no |
| 5311 | Buckled Boots | 2 | 601 | 0 | no | no |
| 5316 | Barkshell Tunic | 2 | 1355 | 0 | no | no |
| 5317 | Dry Moss Tunic | 2 | 1360 | 0 | no | no |
| 5327 | Greasy Tinker's Pants | 2 | 519 | 0 | no | no |
| 5341 | Spore-covered Tunic | 2 | 368 | 0 | no | no |
| 5355 | Beastmaster's Girdle | 2 | 947 | 0 | no | no |
| 5609 | Steadfast Cinch | 2 | 447 | 0 | no | no |
| 5617 | Vagabond Leggings | 2 | 247 | 0 | no | no |
| 5629 | Hammerfist Gloves | 2 | 347 | 0 | no | no |
| 5630 | Windfelt Gloves | 2 | 348 | 0 | no | no |
| 5739 | Barbaric Harness | 2 | 2738 | 33 | no | no |
| 5780 | Murloc Scale Belt | 2 | 260 | 13 | no | no |
| 5781 | Murloc Scale Breastplate | 2 | 601 | 14 | no | no |
| 5782 | Thick Murloc Armor | 2 | 3211 | 29 | no | no |
| 5783 | Murloc Scale Bracers | 2 | 2316 | 33 | no | no |
| 5814 | Snapbrook Armor | 2 | 2351 | 0 | no | no |
| 5821 | Darkstalker Boots | 2 | 900 | 0 | no | no |
| 5957 | Handstitched Leather Vest | 2 | 40 | 3 | no | no |
| 5958 | Fine Leather Pants | 2 | 829 | 16 | no | no |
| 5961 | Dark Leather Pants | 2 | 1089 | 18 | no | no |
| 5962 | Guardian Pants | 2 | 2794 | 27 | no | no |
| 5963 | Barbaric Leggings | 2 | 3151 | 29 | no | no |
| 5964 | Barbaric Shoulders | 2 | 2609 | 30 | no | no |
| 6085 | Footman Tunic | 2 | 243 | 0 | no | no |
| 6092 | Black Whelp Boots | 2 | 420 | 0 | no | no |
| 6147 | Ratty Old Belt | 2 | 37 | 7 | no | no |
| 6201 | Lithe Boots | 2 | 54 | 7 | no | no |
| 6467 | Deviate Scale Gloves | 2 | 420 | 16 | no | no |
| 6668 | Draftsman Boots | 2 | 1245 | 0 | no | no |
| 6670 | Panther Armor | 2 | 1672 | 0 | no | no |
| 6709 | Moonglow Vest | 2 | 545 | 13 | no | no |
| 6719 | Windborne Belt | 2 | 1097 | 0 | no | no |
| 6720 | Spirit Hunter Headdress | 2 | 3218 | 0 | no | no |
| 6727 | Razzeric's Racing Grips | 2 | 2996 | 0 | no | no |
| 6732 | Gnomish Mechanic's Gloves | 2 | 2421 | 0 | no | no |
| 6740 | Azure Sash | 2 | 1000 | 0 | no | no |
| 6784 | Braced Handguards | 2 | 2031 | 0 | no | no |
| 6788 | Kolkar Hunter's Belt | 2 | 3331 | 35 | no | no |
| 6794 | Stormfire Gauntlets | 2 | 2641 | 0 | no | no |
| 7280 | Rugged Leather Pants | 2 | 162 | 6 | no | no |
| 7281 | Light Leather Bracers | 2 | 84 | 9 | no | no |
| 7282 | Light Leather Pants | 2 | 599 | 14 | no | no |
| 7285 | Nimble Leather Gloves | 2 | 588 | 19 | no | no |
| 7335 | Grizzly Tunic | 2 | 1937 | 0 | no | no |
| 7348 | Fletcher's Gloves | 2 | 690 | 20 | no | no |
| 7349 | Herbalist's Gloves | 2 | 861 | 22 | no | no |
| 7352 | Earthen Leather Shoulders | 2 | 1306 | 22 | no | no |
| 7358 | Pilferer's Gloves | 2 | 885 | 23 | no | no |
| 7359 | Heavy Earthen Gloves | 2 | 978 | 24 | no | no |
| 7373 | Dusky Leather Leggings | 2 | 3097 | 28 | no | no |
| 7374 | Dusky Leather Armor | 2 | 3760 | 30 | no | no |
| 7378 | Dusky Bracers | 2 | 2146 | 32 | no | no |
| 7386 | Green Whelp Bracers | 2 | 2387 | 33 | no | no |
| 7390 | Dusky Boots | 2 | 4237 | 35 | no | no |
| 8174 | Comfortable Leather Hat | 2 | 4131 | 35 | no | no |
| 8175 | Nightscape Tunic | 2 | 3881 | 36 | no | no |
| 8176 | Nightscape Headband | 2 | 2922 | 36 | no | no |
| 8192 | Nightscape Shoulders | 2 | 4782 | 37 | no | no |
| 8193 | Nightscape Pants | 2 | 8708 | 41 | no | no |
| 8200 | Big Voodoo Robe | 2 | 7275 | 38 | no | no |
| 8201 | Big Voodoo Mask | 2 | 5350 | 39 | no | no |
| 8202 | Big Voodoo Pants | 2 | 9022 | 42 | no | no |
| 8210 | Wild Leather Shoulders | 2 | 5537 | 39 | no | no |
| 8211 | Wild Leather Vest | 2 | 8002 | 40 | no | no |
| 8212 | Wild Leather Leggings | 2 | 11585 | 45 | no | no |
| 8213 | Wild Leather Boots | 2 | 8150 | 44 | no | no |
| 8214 | Wild Leather Helmet | 2 | 6230 | 40 | no | no |
| 9518 | Mud's Crushers | 2 | 1899 | 0 | no | no |
| 9630 | Pratt's Handcrafted Boots | 2 | 5780 | 0 | no | no |
| 9631 | Pratt's Handcrafted Gloves | 2 | 3868 | 0 | no | no |
| 9632 | Jangdor's Handcrafted Gloves | 2 | 3883 | 0 | no | no |
| 9633 | Jangdor's Handcrafted Boots | 2 | 5847 | 0 | no | no |
| 9647 | Failed Flying Experiment | 2 | 7962 | 0 | no | no |
| 9652 | Gryphon Rider's Leggings | 2 | 13466 | 0 | no | no |
| 9657 | Vinehedge Cinch | 2 | 5333 | 0 | no | no |
| 9682 | Leather Chef's Belt | 2 | 3831 | 0 | no | no |
| 9687 | Grappler's Belt | 2 | 1554 | 0 | no | no |
| 9698 | Gloves of Insight | 2 | 1504 | 0 | no | no |
| 9704 | Rustler Gloves | 2 | 3573 | 0 | no | no |
| 9705 | Tharg's Shoelace | 2 | 3586 | 0 | no | no |
| 10264 | Adventurer's Tunic | 2 | 26729 | 60 | no | no |
| 10653 | Trailblazer Boots | 2 | 1639 | 0 | no | no |
| 10702 | Enormous Ogre Boots | 2 | 5379 | 0 | no | no |
| 10741 | Lordrec Helmet | 2 | 10063 | 0 | no | no |
| 10745 | Kaylari Shoulders | 2 | 8498 | 0 | no | no |
| 10748 | Wanderlust Boots | 2 | 4380 | 0 | no | no |
| 10827 | Surveyor's Tunic | 2 | 10238 | 0 | no | no |
| 11193 | Blazewind Breastplate | 2 | 16938 | 0 | no | no |
| 11502 | Loreskin Shoulders | 2 | 6510 | 0 | no | no |
| 11853 | Rambling Boots | 2 | 388 | 0 | no | no |
| 11871 | Snarkshaw Spaulders | 2 | 10666 | 0 | no | no |
| 11874 | Clouddrift Mantle | 2 | 12124 | 0 | no | no |
| 11876 | Plainstalker Tunic | 2 | 16287 | 0 | no | no |
| 11909 | Excavator's Utility Belt | 2 | 8267 | 0 | no | no |
| 11916 | Shizzle's Muzzle | 2 | 11834 | 0 | no | no |
| 12104 | Brindlethorn Tunic | 2 | 20879 | 0 | no | no |
| 12522 | Bingles' Flying Gloves | 2 | 182 | 0 | no | no |
| 13242 | Deprecated Stormrage Boots | 2 | 16114 | 55 | no | no |
| 14652 | Scorpashi Sash | 2 | 4215 | 40 | no | no |
| 14661 | Keeper's Cord | 2 | 5461 | 44 | no | no |
| 14674 | Pridelord Girdle | 2 | 8270 | 50 | no | no |
| 15068 | Frostsaber Tunic | 2 | 21835 | 57 | no | no |
| 15069 | Frostsaber Leggings | 2 | 17012 | 52 | no | no |
| 15070 | Frostsaber Gloves | 2 | 9504 | 54 | no | no |
| 15071 | Frostsaber Boots | 2 | 11443 | 50 | no | no |
| 15072 | Chimeric Leggings | 2 | 16233 | 51 | no | no |
| 15073 | Chimeric Boots | 2 | 11530 | 50 | no | no |
| 15074 | Chimeric Gloves | 2 | 6867 | 48 | no | no |
| 15075 | Chimeric Vest | 2 | 18449 | 53 | no | no |
| 15083 | Wicked Leather Gauntlets | 2 | 6872 | 47 | no | no |
| 15084 | Wicked Leather Bracers | 2 | 7311 | 48 | no | no |
| 15085 | Wicked Leather Armor | 2 | 22732 | 56 | no | no |
| 15086 | Wicked Leather Headband | 2 | 13154 | 51 | no | no |
| 15087 | Wicked Leather Pants | 2 | 17892 | 53 | no | no |
| 15088 | Wicked Leather Belt | 2 | 9901 | 55 | no | no |
| 15090 | Runic Leather Armor | 2 | 22002 | 57 | no | no |
| 15091 | Runic Leather Gauntlets | 2 | 7195 | 49 | no | no |
| 15092 | Runic Leather Bracers | 2 | 7656 | 50 | no | no |
| 15093 | Runic Leather Belt | 2 | 8368 | 51 | no | no |
| 15094 | Runic Leather Headband | 2 | 14155 | 53 | no | no |
| 15095 | Runic Leather Pants | 2 | 20885 | 55 | no | no |
| 15096 | Runic Leather Shoulders | 2 | 17332 | 57 | no | no |
| 15180 | Praetorian Girdle | 2 | 6686 | 48 | no | no |
| 15202 | Wildkeeper Leggings | 2 | 515 | 0 | no | no |
| 15388 | Jadefire Belt | 2 | 6357 | 47 | no | no |
| 15399 | Dryweed Belt | 2 | 151 | 0 | no | no |
| 15403 | Ridgeback Bracers | 2 | 279 | 0 | no | no |
| 15405 | Shucking Gloves | 2 | 245 | 0 | no | no |
| 15456 | Lightstep Leggings | 2 | 4442 | 0 | no | no |
| 15458 | Tundra Boots | 2 | 1423 | 0 | no | no |
| 15462 | Loamflake Bracers | 2 | 653 | 0 | no | no |
| 15469 | Windsong Cinch | 2 | 1009 | 0 | no | no |
| 15471 | Brawnhide Armor | 2 | 2034 | 0 | no | no |
| 15587 | Ringtail Girdle | 2 | 1822 | 0 | no | no |
| 15708 | Blight Leather Gloves | 2 | 8965 | 0 | no | no |
| 15786 | Fernpulse Jerkin | 2 | 18826 | 0 | no | no |
| 15792 | Plow Wood Spaulders | 2 | 14154 | 0 | no | no |
| 15822 | Shadowskin Spaulders | 2 | 11290 | 0 | no | no |
| 16608 | Aquarius Belt | 2 | 193 | 0 | no | no |
| 16659 | Deftkin Belt | 2 | 856 | 0 | no | no |
| 16739 | Rugwood Mantle | 2 | 7300 | 0 | no | no |
| 16741 | Oilrag Handwraps | 2 | 1178 | 0 | no | no |
| 16873 | Braidfur Gloves | 2 | 2254 | 0 | no | no |
| 16987 | Screecher Belt | 2 | 884 | 0 | no | no |
| 16994 | Duskwing Gloves | 2 | 9884 | 0 | no | no |
| 16995 | Duskwing Mantle | 2 | 14826 | 0 | no | no |
| 17005 | Boorguard Tunic | 2 | 1632 | 0 | no | no |
| 17721 | Gloves of the Greatfather | 2 | 2268 | 33 | no | no |
| 19039 | Zorbin's Water Resistant Hat | 2 | 7403 | 0 | no | no |
| 19041 | Pratt's Handcrafted Tunic | 2 | 9946 | 0 | no | no |
| 19042 | Jangdor's Handcrafted Tunic | 2 | 9984 | 0 | no | no |
| 19119 | Owlbeast Hide Gloves | 2 | 5803 | 0 | no | no |
| 19127 | Charred Leather Tunic | 2 | 12258 | 0 | no | no |
| 19743 | Cloaked Hood TEST | 2 | 3381 | 33 | no | no |
| 20297 | 90 Green Rogue Belt | 2 | 46978 | 60 | no | no |
| 20298 | 90 Green Rogue Boots | 2 | 63984 | 60 | no | no |
| 20300 | 90 Green Rogue Bracers | 2 | 44174 | 60 | no | no |
| 20301 | 90 Green Rogue Cap | 2 | 66510 | 60 | no | no |
| 20304 | 90 Green Rogue Gloves | 2 | 44832 | 60 | no | no |
| 20306 | 90 Green Rogue Pants | 2 | 90319 | 60 | no | no |
| 20308 | 90 Green Rogue Spaulders | 2 | 68236 | 60 | no | no |
| 20309 | 90 Green Rogue Tunic | 2 | 91304 | 60 | no | no |
| 20311 | 63 Green Rogue Belt | 2 | 12316 | 58 | no | no |
| 20312 | 63 Green Rogue Boots | 2 | 18541 | 58 | no | no |
| 20314 | 63 Green Rogue Bracers | 2 | 12448 | 58 | no | no |
| 20315 | 63 Green Rogue Cap | 2 | 18739 | 58 | no | no |
| 20318 | 63 Green Rogue Gloves | 2 | 11742 | 58 | no | no |
| 20320 | 63 Green Rogue Pants | 2 | 23661 | 58 | no | no |
| 20322 | 63 Green Rogue Spaulders | 2 | 17877 | 58 | no | no |
| 20323 | 63 Green Rogue Tunic | 2 | 23925 | 58 | no | no |
| 20575 | Black Whelp Tunic | 2 | 743 | 15 | no | no |
| 20643 | Undercity Reservist's Cap | 2 | 7094 | 0 | no | no |
| 21317 | Helm of the Pathfinder | 2 | 11675 | 0 | no | no |
| 21319 | Gloves of the Pathfinder | 2 | 9339 | 0 | no | no |
| 215113 | UNUSED - Razor-Lined Shoulderpads | 2 | 4320 | 35 | no | no |
| 236755 | [TMP] Funerary Headdress | 2 | 8467 | 45 | no | no |
| 252449 | Hillman's Leather Boots | 2 | 0 | 22 | no | no |
| 252467 | Blue Suede Shoes | 2 | 0 | 47 | no | no |
| 252478 | Blue Suede Pants | 2 | 0 | 51 | no | no |
| 252479 | Wicked Leather Boots | 2 | 0 | 52 | no | no |
| 252480 | Blue Suede Armor | 2 | 0 | 53 | no | no |
| 252481 | Blue Suede Belt | 2 | 0 | 54 | no | no |
| 252482 | Blue Suede Hat | 2 | 0 | 56 | no | no |
| 252544 | Tooled Leather Belt | 2 | 0 | 47 | no | no |
| 252545 | Tooled Leather Boots | 2 | 0 | 48 | no | no |
| 252546 | Blue Suede Gloves | 2 | 0 | 48 | no | no |
| 252552 | Tooled Leather Armor | 2 | 0 | 51 | no | no |
| 252553 | Tooled Leather Gauntlets | 2 | 0 | 52 | no | no |
| 252554 | Blue Suede Shoulders | 2 | 0 | 52 | no | no |
| 252555 | Tooled Leather Crown | 2 | 0 | 53 | no | no |
| 252556 | Wicked Leather Shoulders | 2 | 0 | 54 | no | no |
| 252557 | Tooled Leather Bracers | 2 | 0 | 54 | no | no |
| 252558 | Tooled Leather Epaulets | 2 | 0 | 55 | no | no |
| 252559 | Blue Suede Bracers | 2 | 0 | 55 | no | no |
| 252560 | Tooled Leather Pants | 2 | 0 | 56 | no | no |
| 257344 | Skywatcher's Vestments | 2 | 243 | 0 | no | no |
| 260167 | Adventurer's Lost Boots | 2 | 4200 | 0 | no | no |
| 260179 | Barkwoven Belt | 2 | 6010 | 0 | no | no |
| 260182 | Elunar Belt | 2 | 6010 | 0 | no | no |
| 260196 | Belt of Shadows | 2 | 6010 | 0 | no | no |
| 263306 | Nightclaw Gloves | 2 | 47 | 0 | no | no |
| 263309 | Freedom Walkers | 2 | 70 | 0 | no | no |
| 263330 | Tracker's Pants | 2 | 162 | 0 | no | no |
| 263335 | Hunter's Cord | 2 | 47 | 0 | no | no |
| 263338 | Defender's Bracers | 2 | 32 | 0 | no | no |
| 263401 | Martyr's Armor | 2 | 59 | 0 | no | no |
| 263405 | Belt of Blades | 2 | 57 | 0 | no | no |
| 269503 | Poacher Boots | 2 | 5979 | 56 | no | no |
| 270004 | Murloc-hide Gloves | 2 | 229 | 0 | no | no |
| 270006 | Boots of the People's Militia | 2 | 302 | 0 | no | no |
| 270013 | Miner's Workboots | 2 | 547 | 0 | no | no |
| 270014 | Deerhide Pants | 2 | 982 | 0 | no | no |
| 270019 | Loch Walkers | 2 | 731 | 0 | no | no |
| 270020 | Gnollhide Pants | 2 | 1146 | 0 | no | no |
| 270033 | Demonhide Bracers | 2 | 1020 | 0 | no | no |
| 270037 | Smouldering Leggings | 2 | 1848 | 0 | no | no |
| 270039 | Raptorclaw Shoulders | 2 | 1484 | 0 | no | no |
| 270044 | Darkshire Shoulderguards | 2 | 1484 | 0 | no | no |
| 270057 | Stromgarde Operative Pants | 2 | 4260 | 0 | no | no |
| 270066 | Tower Boots | 2 | 4179 | 0 | no | no |
| 270067 | Wild Headdress | 2 | 4240 | 0 | no | no |
| 270072 | Alterac Assassin's Gloves | 2 | 2857 | 0 | no | no |
| 270076 | Tidal Bracers | 2 | 3062 | 0 | no | no |
| 270080 | Arathi Armbands | 2 | 3062 | 0 | no | no |
| 270083 | Blooded Pants | 2 | 6991 | 0 | no | no |
| 270089 | Ironforge Agent's Gloves | 2 | 3721 | 0 | no | no |
| 270091 | Seadog's Battered Cuffs | 2 | 3789 | 0 | no | no |
| 270094 | Black Whelp Boots | 2 | 5519 | 0 | no | no |
| 270100 | Freebooter's Armband | 2 | 4855 | 0 | no | no |
| 270101 | Gnomish Floatation Device | 2 | 6434 | 0 | no | no |
| 270102 | Projectile Redirectors | 2 | 4855 | 0 | no | no |
| 270104 | Stonewalker's Slippers | 2 | 8365 | 0 | no | no |
| 270111 | Forest Troll Leggings | 2 | 9894 | 0 | no | no |
| 270114 | Dragonscale Pants | 2 | 12125 | 0 | no | no |
| 270122 | Yesterday's Pants | 2 | 16717 | 0 | no | no |
| 271732 | Dirt-Heavy Bracers | 2 | 1216 | 0 | no | no |
| 273875 | Empyrean Treads | 2 | 67 | 0 | no | no |
| 274490 | Centaur Hoofwarmers | 2 | 7110 | 35 | no | no |
| 274719 | Forgotten Trompers | 2 | 14073 | 0 | no | no |
| 274742 | Ratchet Wristwraps | 2 | 688 | 20 | no | no |
| 274751 | Sunburn Spaulders | 2 | 5884 | 40 | no | no |
| 274756 | Impractical Headwarmer | 2 | 11683 | 50 | no | no |
| 274938 | Gnollhide Tunic | 2 | 6710 | 0 | no | no |
| 274942 | Bristlepelt Vest | 2 | 6331 | 0 | no | no |
| 274957 | Lumber Luggers | 2 | 3381 | 0 | no | no |
| 275666 | Whitemane's Plateau | 2 | 15330 | 0 | no | no |
| 275669 | Punchy's Punchers | 2 | 9889 | 0 | no | no |
| 275832 | Crowfeather Tunic | 2 | 18925 | 0 | no | no |
| 276105 | Scoutmaster's Eyepatch | 2 | 5006 | 0 | no | no |
| 276339 | Cured Staghide Leggings | 2 | 21024 | 0 | no | no |
| 276340 | Blademaster Hakama | 2 | 21101 | 0 | no | no |
| 276998 | Cloudy Gustwoven Harness | 2 | 0 | 7 | no | no |
| 276999 | Cloudy Gustwoven Bracers | 2 | 0 | 5 | no | no |
| 277000 | Cloudy Gustwoven Gloves | 2 | 0 | 6 | no | no |
| 277001 | Cloudy Gustwoven Belt | 2 | 0 | 5 | no | no |
| 277002 | Cloudy Gustwoven Trousers | 2 | 0 | 7 | no | no |
| 277003 | Cloudy Gustwoven Boots | 2 | 0 | 6 | no | no |
| 277004 | Cloudy Windraveled Jerkin | 2 | 0 | 7 | no | no |
| 277005 | Cloudy Windraveled Armguards | 2 | 0 | 5 | no | no |
| 277006 | Cloudy Windraveled Mitts | 2 | 0 | 6 | no | no |
| 277007 | Cloudy Windraveled Strap | 2 | 0 | 5 | no | no |
| 277008 | Cloudy Windraveled Pants | 2 | 0 | 7 | no | no |
| 277009 | Cloudy Windraveled Footwraps | 2 | 0 | 6 | no | no |
| 277022 | Azure Gustwoven Harness | 2 | 0 | 7 | no | no |
| 277023 | Azure Gustwoven Bracers | 2 | 0 | 5 | no | no |
| 277024 | Azure Gustwoven Gloves | 2 | 0 | 6 | no | no |
| 277025 | Azure Gustwoven Belt | 2 | 0 | 5 | no | no |
| 277026 | Azure Gustwoven Trousers | 2 | 0 | 7 | no | no |
| 277027 | Azure Gustwoven Boots | 2 | 0 | 6 | no | no |
| 277028 | Azure Windraveled Jerkin | 2 | 0 | 7 | no | no |
| 277029 | Azure Windraveled Armguards | 2 | 0 | 5 | no | no |
| 277030 | Azure Windraveled Mitts | 2 | 0 | 6 | no | no |
| 277031 | Azure Windraveled Strap | 2 | 0 | 5 | no | no |
| 277032 | Azure Windraveled Pants | 2 | 0 | 7 | no | no |
| 277033 | Azure Windraveled Footwraps | 2 | 0 | 6 | no | no |
| 277042 | Cloudy Gustwoven Hood | 2 | 0 | 30 | no | no |
| 277043 | Cloudy Gustwoven Spaulders | 2 | 0 | 30 | no | no |
| 277044 | Cloudy Windraveled Cover | 2 | 0 | 30 | no | no |
| 277045 | Cloudy Windraveled Drapes | 2 | 0 | 30 | no | no |
| 277050 | Azure Gustwoven Hood | 2 | 0 | 30 | no | no |
| 277051 | Azure Gustwoven Spaulders | 2 | 0 | 30 | no | no |
| 277052 | Azure Windraveled Cover | 2 | 0 | 30 | no | no |
| 277053 | Azure Windraveled Drapes | 2 | 0 | 30 | no | no |
| 277219 | Solomon's Comfortable Hat | 2 | 0 | 0 | no | no |
| 277220 | Shabby Spaulders | 2 | 0 | 0 | no | no |
| 277221 | Grimtotem Naturalist's Tunic | 2 | 0 | 0 | no | no |
| 277222 | War Painted Cuffs | 2 | 0 | 0 | no | no |
| 277223 | Traveled Gloves | 2 | 0 | 0 | no | no |
| 277224 | Kurzen Headshrinker's Cinch | 2 | 0 | 0 | no | no |
| 277225 | Feathered Leggings | 2 | 0 | 40 | no | no |
| 277226 | Disjointed Shoes | 2 | 0 | 0 | no | no |
| 280307 | Gizmo Girdle | 2 | 1716 | 30 | no | no |
| 281251 | Courier's Wristguards | 2 | 0 | 0 | no | no |
| 281261 | Crystal-flecked Cord | 2 | 0 | 0 | no | no |
| 281270 | Thra's Friendship Bracelet | 2 | 0 | 0 | no | no |
| 281271 | Puk's Friendship Bracelet | 2 | 0 | 0 | no | no |
| 281276 | Pauldrons of Scaleslaying | 2 | 0 | 0 | no | no |
| 281284 | Howlhide Vest | 2 | 1 | 0 | no | no |
| 281295 | Pelt Pants | 2 | 0 | 0 | no | no |
| 281299 | Profane Ritual Robes | 2 | 0 | 0 | no | no |
| 281309 | Razormaw Shorts | 2 | 0 | 0 | no | no |
| 281310 | Carnage Trousers | 2 | 0 | 0 | no | no |
| 281538 | Matriarch's Mantle | 2 | 0 | 0 | no | no |
| 281693 | Restored Leather Hood | 2 | 1 | 1 | no | no |
| 281694 | Restored Leather Spaulders | 2 | 1 | 1 | no | no |
| 281695 | Restored Leather Tunic | 2 | 1 | 1 | no | no |
| 281696 | Restored Leather Wristcuffs | 2 | 1 | 1 | no | no |
| 281697 | Restored Leather Gloves | 2 | 1 | 1 | no | no |
| 281698 | Restored Leather Strap | 2 | 1 | 1 | no | no |
| 281699 | Restored Leather Chaps | 2 | 1 | 1 | no | no |
| 281700 | Restored Leather Boots | 2 | 1 | 1 | no | no |

### 4/2 Armadura / Cuero, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4196 | Feathered Mantle | 3 | 1944 | 25 | no | no |
| 6468 | Deviate Scale Belt | 3 | 658 | 18 | no | no |
| 8349 | Feathered Breastplate | 3 | 14478 | 45 | no | no |
| 12041 | Windshear Leggings | 3 | 14446 | 0 | no | no |
| 13092 | Deprecated Dragonstalker Tunic | 3 | 30173 | 58 | no | no |
| 15059 | Living Breastplate | 3 | 24776 | 55 | no | no |
| 15060 | Living Leggings | 3 | 21277 | 52 | no | no |
| 15061 | Living Shoulders | 3 | 13803 | 49 | no | no |
| 15064 | Warbear Harness | 3 | 19717 | 50 | no | no |
| 15065 | Warbear Woolies | 3 | 22233 | 52 | no | no |
| 16393 | Knight-Lieutenant's Dragonhide Footwraps | 3 | 10676 | 58 | no | no |
| 16394 | Knight-Captain's Leather Bracers | 3 | 6171 | 55 | no | no |
| 16395 | Knight-Captain's Dragonhide Armsplints | 3 | 6359 | 55 | no | no |
| 16396 | Knight-Lieutenant's Leather Gauntlets | 3 | 7388 | 58 | no | no |
| 16398 | Knight-Captain's Leather Belt | 3 | 6427 | 55 | no | no |
| 16399 | Knight-Captain's Dragonhide Girdle | 3 | 6450 | 55 | no | no |
| 16417 | Knight-Captain's Leather Armor | 3 | 14827 | 58 | no | no |
| 16418 | Lieutenant Commander's Leather Veil | 3 | 11160 | 58 | no | no |
| 16419 | Knight-Captain's Leather Legguards | 3 | 14934 | 58 | no | no |
| 16420 | Lieutenant Commander's Leather Spaulders | 3 | 11239 | 58 | no | no |
| 16421 | Knight-Captain's Dragonhide Tunic | 3 | 15039 | 58 | no | no |
| 16422 | Knight-Captain's Dragonhide Leggings | 3 | 15092 | 58 | no | no |
| 16423 | Lieutenant Commander's Dragonhide Epaulets | 3 | 10278 | 58 | no | no |
| 16424 | Lieutenant Commander's Dragonhide Shroud | 3 | 10317 | 58 | no | no |
| 16493 | Legionnaire's Dragonhide Armguards | 3 | 6474 | 55 | no | no |
| 16494 | Blood Guard's Dragonhide Boots | 3 | 11282 | 58 | no | no |
| 16495 | Legionnaire's Dragonhide Waistband | 3 | 6519 | 55 | no | no |
| 16497 | First Sergeant's Leather Armguards | 3 | 6880 | 58 | no | no |
| 16500 | Legionnaire's Leather Girdle | 3 | 6011 | 55 | no | no |
| 16501 | Champion's Dragonhide Spaulders | 3 | 10479 | 58 | no | no |
| 16502 | Legionnaire's Dragonhide Trousers | 3 | 14025 | 58 | no | no |
| 16503 | Champion's Dragonhide Helm | 3 | 10558 | 58 | no | no |
| 16504 | Legionnaire's Dragonhide Breastplate | 3 | 14130 | 58 | no | no |
| 16977 | Warsong Boots | 3 | 1448 | 0 | no | no |
| 18238 | Shadowskin Gloves | 3 | 3321 | 35 | no | no |
| 18434 | First Sergeant's Dragonhide Armguards | 3 | 7493 | 58 | no | no |
| 18435 | First Sergeant's Leather Armguards | 3 | 3662 | 45 | no | no |
| 18436 | First Sergeant's Dragonhide Armguards | 3 | 3417 | 45 | no | no |
| 18452 | Sergeant Major's Leather Armsplints | 3 | 6910 | 58 | no | no |
| 18453 | Sergeant Major's Leather Armsplints | 3 | 3378 | 45 | no | no |
| 18454 | Sergeant Major's Dragonhide Armsplints | 3 | 6963 | 58 | no | no |
| 18455 | Sergeant Major's Dragonhide Armsplints | 3 | 3404 | 45 | no | no |
| 18504 | Girdle of Insight | 3 | 14126 | 57 | no | no |
| 18506 | Mongoose Boots | 3 | 21340 | 57 | no | no |
| 18948 | Barbaric Bracers | 3 | 1589 | 27 | no | no |
| 19044 | Might of the Timbermaw | 3 | 11116 | 53 | no | no |
| 19049 | Timbermaw Brawlers | 3 | 15576 | 56 | no | no |
| 19052 | Dawn Treaders | 3 | 17621 | 53 | no | no |
| 19058 | Golden Mantle of the Dawn | 3 | 21845 | 56 | no | no |
| 19089 | Frostwolf Leather Belt | 3 | 11860 | 55 | no | no |
| 19093 | Stormpike Leather Girdle | 3 | 11860 | 55 | no | no |
| 19742 | Earthborn Kilt TEST | 3 | 23721 | 55 | no | no |
| 19837 | Test Ranged Slot | 3 | 48542 | 0 | no | no |
| 20090 | Highlander's Chain Girdle | 3 | 1874 | 28 | no | no |
| 20103 | Highlander's Lizardhide Girdle | 3 | 8590 | 48 | no | no |
| 20104 | Highlander's Lizardhide Girdle | 3 | 4262 | 38 | no | no |
| 20105 | Highlander's Lizardhide Girdle | 3 | 1841 | 28 | no | no |
| 20115 | Highlander's Leather Girdle | 3 | 8341 | 48 | no | no |
| 20116 | Highlander's Leather Girdle | 3 | 4139 | 38 | no | no |
| 20117 | Highlander's Leather Girdle | 3 | 1788 | 28 | no | no |
| 20120 | Highlander's Mail Girdle | 3 | 1808 | 28 | no | no |
| 20152 | Defiler's Chain Girdle | 3 | 1754 | 28 | no | no |
| 20172 | Defiler's Lizardhide Girdle | 3 | 1802 | 28 | no | no |
| 20173 | Defiler's Lizardhide Girdle | 3 | 4202 | 38 | no | no |
| 20174 | Defiler's Lizardhide Girdle | 3 | 8530 | 48 | no | no |
| 20191 | Defiler's Leather Girdle | 3 | 1795 | 28 | no | no |
| 20192 | Defiler's Leather Girdle | 3 | 4187 | 38 | no | no |
| 20193 | Defiler's Leather Girdle | 3 | 8498 | 48 | no | no |
| 20197 | Defiler's Mail Girdle | 3 | 1834 | 28 | no | no |
| 20216 | Belt of Preserved Heads | 3 | 20645 | 0 | no | no |
| 20524 | Shadowhide Leggings | 3 | 15146 | 0 | no | no |
| 20703 | Cenarion Reservist's Leggings | 3 | 29571 | 0 | no | no |
| 20704 | Cenarion Reservist's Leggings | 3 | 27461 | 0 | no | no |
| 20714 | Sandstorm Boots | 3 | 20595 | 0 | no | no |
| 20715 | Dunestalker's Boots | 3 | 20969 | 0 | no | no |
| 21178 | Gloves of Earthen Power | 3 | 14231 | 0 | no | no |
| 22273 | Moonshadow Hood | 3 | 11408 | 0 | no | no |
| 22689 | Sanctified Leather Helm | 3 | 24282 | 0 | no | no |
| 22759 | Bramblewood Helm | 3 | 29190 | 60 | no | no |
| 22760 | Bramblewood Boots | 3 | 29302 | 60 | no | no |
| 22761 | Bramblewood Belt | 3 | 19607 | 60 | no | no |
| 22852 | Blood Guard's Dragonhide Treads | 3 | 11921 | 60 | no | no |
| 22864 | Blood Guard's Leather Grips | 3 | 8373 | 60 | no | no |
| 22877 | Legionnaire's Dragonhide Chestpiece | 3 | 17987 | 60 | no | no |
| 22878 | Legionnaire's Dragonhide Leggings | 3 | 18055 | 60 | no | no |
| 22879 | Legionnaire's Leather Chestpiece | 3 | 18123 | 60 | no | no |
| 22880 | Legionnaire's Leather Legguards | 3 | 18191 | 60 | no | no |
| 23253 | Champion's Dragonhide Headguard | 3 | 15438 | 60 | no | no |
| 23254 | Champion's Dragonhide Shoulders | 3 | 15495 | 60 | no | no |
| 23257 | Champion's Leather Helm | 3 | 15672 | 60 | no | no |
| 23258 | Champion's Leather Shoulders | 3 | 16152 | 60 | no | no |
| 23281 | Knight-Lieutenant's Dragonhide Treads | 3 | 12792 | 60 | no | no |
| 23294 | Knight-Captain's Dragonhide Chestpiece | 3 | 18330 | 60 | no | no |
| 23295 | Knight-Captain's Dragonhide Leggings | 3 | 18396 | 60 | no | no |
| 23308 | Lieutenant Commander's Dragonhide Headguard | 3 | 15560 | 60 | no | no |
| 23309 | Lieutenant Commander's Dragonhide Shoulders | 3 | 15619 | 60 | no | no |
| 252424 | Black Whelp Slippers | 3 | 150 | 10 | no | no |
| 252425 | Dark Leather Boots | 3 | 157 | 10 | no | no |
| 252426 | Murloc Scale Shoes | 3 | 158 | 10 | no | no |
| 252427 | Moonglow Boots | 3 | 158 | 10 | no | no |
| 252428 | Brawler's Leather Belt | 3 | 0 | 12 | no | no |
| 252429 | Trapper's Leather Belt | 3 | 0 | 12 | no | no |
| 252430 | Defender's Leather Belt | 3 | 0 | 12 | no | no |
| 252431 | Totemic Leather Belt | 3 | 0 | 12 | no | no |
| 252432 | Stormrider's Leather Belt | 3 | 0 | 12 | no | no |
| 252433 | Wisdom's Leather Belt | 3 | 0 | 12 | no | no |
| 252434 | Defender's Leather Armor | 3 | 430 | 15 | no | no |
| 252435 | Totemic Leather Armor | 3 | 426 | 15 | no | no |
| 252439 | Brawler's Leather Boots | 3 | 0 | 17 | no | no |
| 252440 | Trapper's Leather Boots | 3 | 0 | 17 | no | no |
| 252441 | Defender's Leather Boots | 3 | 0 | 17 | no | no |
| 252442 | Totemic Leather Boots | 3 | 0 | 17 | no | no |
| 252443 | Stormrider's Leather Boots | 3 | 0 | 17 | no | no |
| 252444 | Wisdom's Leather Boots | 3 | 0 | 17 | no | no |
| 252445 | Defender's Leather Pants | 3 | 834 | 20 | no | no |
| 252446 | Totemic Leather Pants | 3 | 843 | 20 | no | no |
| 252447 | Defender's Leather Hood | 3 | 0 | 20 | no | no |
| 252448 | Totemic Leather Hood | 3 | 0 | 20 | no | no |
| 252450 | Defender's Leather Tunic | 3 | 0 | 22 | no | no |
| 252451 | Totemic Leather Tunic | 3 | 0 | 22 | no | no |
| 252455 | Defender's Leather Helm | 3 | 1038 | 25 | no | no |
| 252456 | Totemic Leather Helm | 3 | 1049 | 25 | no | no |
| 252457 | Defender's Leather Kilt | 3 | 0 | 25 | no | no |
| 252458 | Totemic Leather Leggings | 3 | 0 | 25 | no | no |
| 252459 | Prowler's Leather Belt | 3 | 1073 | 30 | no | no |
| 252460 | Warden's Leather Belt | 3 | 1073 | 30 | no | no |
| 252461 | Skirmisher's Leather Belt | 3 | 1073 | 30 | no | no |
| 252465 | Prowler's Leather Shoes | 3 | 3759 | 40 | no | no |
| 252466 | Warden's Leather Shoes | 3 | 3684 | 40 | no | no |
| 252468 | Prowler's Leather Boots | 3 | 0 | 47 | no | no |
| 252469 | Skulker's Leather Boots | 3 | 0 | 47 | no | no |
| 252470 | Warden's Leather Boots | 3 | 0 | 47 | no | no |
| 252471 | Skycaller's Leather Boots | 3 | 0 | 47 | no | no |
| 252472 | Mender's Leather Boots | 3 | 0 | 47 | no | no |
| 252473 | Prowler's Leather Waistguard | 3 | 0 | 50 | no | no |
| 252474 | Skulker's Leather Waistguard | 3 | 0 | 50 | no | no |
| 252475 | Warden's Leather Waistguard | 3 | 0 | 50 | no | no |
| 252476 | Skycaller's Leather Waistguard | 3 | 0 | 50 | no | no |
| 252477 | Mender's Leather Waistguard | 3 | 0 | 50 | no | no |
| 252490 | Brawler's Leather Armor | 3 | 426 | 15 | no | no |
| 252491 | Trapper's Leather Armor | 3 | 426 | 15 | no | no |
| 252492 | Stormrider's Leather Armor | 3 | 426 | 15 | no | no |
| 252493 | Wisdom's Leather Armor | 3 | 434 | 15 | no | no |
| 252494 | Brawler's Leather Gloves | 3 | 0 | 15 | no | no |
| 252495 | Trapper's Leather Gloves | 3 | 0 | 15 | no | no |
| 252496 | Defender's Leather Gloves | 3 | 0 | 15 | no | no |
| 252497 | Totemic Leather Gloves | 3 | 0 | 15 | no | no |
| 252498 | Stormrider's Leather Gloves | 3 | 0 | 15 | no | no |
| 252499 | Wisdom's Leather Gloves | 3 | 0 | 15 | no | no |
| 252500 | Brawler's Leather Pants | 3 | 868 | 20 | no | no |
| 252501 | Trapper's Leather Pants | 3 | 834 | 20 | no | no |
| 252502 | Stormrider's Leather Pants | 3 | 834 | 20 | no | no |
| 252503 | Wisdom's Leather Pants | 3 | 868 | 20 | no | no |
| 252504 | Brawler's Leather Hood | 3 | 0 | 20 | no | no |
| 252505 | Trapper's Leather Hood | 3 | 0 | 20 | no | no |
| 252506 | Stormrider's Leather Hood | 3 | 0 | 20 | no | no |
| 252507 | Wisdom's Leather Hood | 3 | 0 | 20 | no | no |
| 252508 | Brawler's Leather Tunic | 3 | 0 | 22 | no | no |
| 252509 | Trapper's Leather Tunic | 3 | 0 | 22 | no | no |
| 252510 | Stormrider's Leather Tunic | 3 | 0 | 22 | no | no |
| 252511 | Wisdom's Leather Tunic | 3 | 0 | 22 | no | no |
| 252512 | Brawler's Leather Helm | 3 | 1008 | 25 | no | no |
| 252513 | Trapper's Leather Helm | 3 | 1008 | 25 | no | no |
| 252514 | Stormrider's Leather Helm | 3 | 1018 | 25 | no | no |
| 252515 | Wisdom's Leather Helm | 3 | 1049 | 25 | no | no |
| 252516 | Brawler's Leather Legguards | 3 | 0 | 25 | no | no |
| 252517 | Trapper's Leather Legguards | 3 | 0 | 25 | no | no |
| 252518 | Stormrider's Leather Kilt | 3 | 0 | 25 | no | no |
| 252519 | Wisdom's Leather Leggings | 3 | 0 | 25 | no | no |
| 252520 | Skulker's Leather Belt | 3 | 1095 | 30 | no | no |
| 252521 | Stalker's Leather Belt | 3 | 1063 | 30 | no | no |
| 252522 | Skycaller's Leather Belt | 3 | 1084 | 30 | no | no |
| 252523 | Mender's Leather Belt | 3 | 1052 | 30 | no | no |
| 252524 | Prowler's Leather Gloves | 3 | 0 | 35 | no | no |
| 252525 | Skulker's Leather Gloves | 3 | 0 | 35 | no | no |
| 252526 | Stalker's Leather Gloves | 3 | 0 | 35 | no | no |
| 252527 | Warden's Leather Gloves | 3 | 0 | 35 | no | no |
| 252528 | Skirmisher's Leather Gloves | 3 | 0 | 35 | no | no |
| 252529 | Skycaller's Leather Gloves | 3 | 0 | 35 | no | no |
| 252530 | Mender's Leather Gloves | 3 | 0 | 35 | no | no |
| 252531 | Skulker's Leather Shoes | 3 | 3721 | 40 | no | no |
| 252532 | Skycaller's Leather Shoes | 3 | 3684 | 40 | no | no |
| 252533 | Mender's Leather Shoes | 3 | 3721 | 40 | no | no |
| 252534 | Prowler's Leather Shoulders | 3 | 0 | 42 | no | no |
| 252535 | Skulker's Leather Shoulder | 3 | 0 | 42 | no | no |
| 252536 | Warden's Leather Shoulders | 3 | 0 | 42 | no | no |
| 252537 | Skycaller's Leather Shoulders | 3 | 0 | 42 | no | no |
| 252538 | Mender's Leather Shoulders | 3 | 0 | 42 | no | no |
| 252539 | Prowler's Leather Bracers | 3 | 0 | 45 | no | no |
| 252540 | Skulker's Leather Bracers | 3 | 0 | 45 | no | no |
| 252541 | Warden's Leather Bracers | 3 | 0 | 45 | no | no |
| 252542 | Skycaller's Leather Bracers | 3 | 0 | 45 | no | no |
| 252543 | Mender's Leather Bracers | 3 | 0 | 45 | no | no |
| 252547 | Prowler's Leather Gauntlets | 3 | 5049 | 50 | no | no |
| 252548 | Skulker's Leather Gauntlets | 3 | 4901 | 50 | no | no |
| 252549 | Warden's Leather Gauntlets | 3 | 4901 | 50 | no | no |
| 252550 | Skycaller's Leather Gauntlets | 3 | 4851 | 50 | no | no |
| 252551 | Mender's Leather Gauntlets | 3 | 5000 | 50 | no | no |
| 260183 | Sacred Bangle | 3 | 7988 | 0 | no | no |
| 260211 | Panic Hands | 3 | 7947 | 0 | no | no |
| 272186 | Overgrown Cuffs | 3 | 7777 | 1 | no | no |
| 272461 | Premier Kodohide Armguards | 3 | 0 | 55 | no | no |
| 272463 | Premier Dragonhide Waistband | 3 | 0 | 55 | no | no |
| 272465 | Premier Shadowhide Armguards | 3 | 0 | 55 | no | no |
| 272468 | Premier Shadowhide Girdle | 3 | 0 | 55 | no | no |
| 272582 | Premier Dragonhide Armguards | 3 | 0 | 55 | no | no |
| 272706 | Premier Leather Bracers | 3 | 0 | 55 | no | no |
| 272707 | Premier Beasthide Armsplints | 3 | 0 | 55 | no | no |
| 272710 | Premier Leather Belt | 3 | 0 | 55 | no | no |
| 272711 | Premier Beasthide Girdle | 3 | 0 | 55 | no | no |
| 272834 | Premier Dreamhide Armsplints | 3 | 0 | 55 | no | no |
| 272835 | Premier Lunarhide Armsplints | 3 | 0 | 55 | no | no |
| 273367 | Premier Kodohide Waistband | 3 | 0 | 55 | no | no |
| 273369 | Premier Lunarhide Girdle | 3 | 0 | 55 | no | no |
| 273378 | Premier Dreamhide Girdle | 3 | 0 | 55 | no | no |
| 273381 | Premier Wyrmhide Armguards | 3 | 0 | 55 | no | no |
| 273388 | Premier Wyrmhide Waistband | 3 | 0 | 55 | no | no |
| 275610 | Bileblister Claws | 3 | 11612 | 53 | no | no |
| 275611 | Bileblister Girdle | 3 | 11655 | 53 | no | no |
| 275612 | Bileblister Boots | 3 | 17451 | 53 | no | no |
| 275613 | Hivethrasher's Claws | 3 | 11738 | 53 | no | no |
| 275614 | Hivethrasher's Girdle | 3 | 11780 | 53 | no | no |
| 275615 | Hivethrasher's Boots | 3 | 16390 | 53 | no | no |
| 275708 | Ghansurok Hide Tunic | 3 | 27156 | 0 | no | no |
| 275739 | Wild Wristguards | 3 | 13248 | 0 | no | no |

### 4/2 Armadura / Cuero, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 14550 | Bladebane Armguards | 4 | 8802 | 44 | no | no |
| 16445 | Marshal's Dragonhide Bracers | 4 | 10429 | 60 | no | no |
| 16447 | Marshal's Dragonhide Waistguard | 4 | 10506 | 60 | no | no |
| 16449 | Field Marshal's Dragonhide Spaulders | 4 | 24631 | 60 | no | no |
| 16450 | Marshal's Dragonhide Legguards | 4 | 28472 | 60 | no | no |
| 16451 | Field Marshal's Dragonhide Helmet | 4 | 24811 | 60 | no | no |
| 16452 | Field Marshal's Dragonhide Breastplate | 4 | 33202 | 60 | no | no |
| 16453 | Field Marshal's Leather Chestpiece | 4 | 33324 | 60 | no | no |
| 16454 | Marshal's Leather Handgrips | 4 | 14444 | 60 | no | no |
| 16455 | Field Marshal's Leather Mask | 4 | 25172 | 60 | no | no |
| 16456 | Marshal's Leather Leggings | 4 | 29098 | 60 | no | no |
| 16457 | Field Marshal's Leather Epaulets | 4 | 25352 | 60 | no | no |
| 16458 | Marshal's Leather Cinch | 4 | 10934 | 60 | no | no |
| 16459 | Marshal's Dragonhide Boots | 4 | 20492 | 60 | no | no |
| 16460 | Marshal's Leather Armsplints | 4 | 10233 | 60 | no | no |
| 16549 | Warlord's Dragonhide Hauberk | 4 | 33688 | 60 | no | no |
| 16550 | Warlord's Dragonhide Helmet | 4 | 25357 | 60 | no | no |
| 16551 | Warlord's Dragonhide Epaulets | 4 | 25448 | 60 | no | no |
| 16552 | General's Dragonhide Leggings | 4 | 29413 | 60 | no | no |
| 16553 | General's Dragonhide Bracers | 4 | 11013 | 60 | no | no |
| 16554 | General's Dragonhide Boots | 4 | 22217 | 60 | no | no |
| 16556 | General's Dragonhide Belt | 4 | 10351 | 60 | no | no |
| 16557 | General's Leather Girdle | 4 | 10390 | 60 | no | no |
| 16559 | General's Leather Armsplints | 4 | 10467 | 60 | no | no |
| 16560 | General's Leather Mitts | 4 | 14080 | 60 | no | no |
| 16561 | Warlord's Leather Helm | 4 | 24540 | 60 | no | no |
| 16562 | Warlord's Leather Spaulders | 4 | 24631 | 60 | no | no |
| 16563 | Warlord's Leather Breastplate | 4 | 32959 | 60 | no | no |
| 16564 | General's Leather Legguards | 4 | 28576 | 60 | no | no |
| 16982 | Corehound Boots | 4 | 24397 | 54 | no | no |
| 16983 | Molten Helm | 4 | 25709 | 55 | no | no |
| 19149 | Lava Belt | 4 | 21248 | 60 | no | no |
| 19162 | Corehound Belt | 4 | 27831 | 60 | no | no |
| 19163 | Molten Belt | 4 | 27931 | 60 | no | no |
| 19587 | Forest Stalker's Bracers | 4 | 20183 | 60 | no | no |
| 19589 | Forest Stalker's Bracers | 4 | 12043 | 50 | no | no |
| 19590 | Forest Stalker's Bracers | 4 | 6181 | 40 | no | no |
| 20267 | 90 Epic Rogue Belt | 4 | 70643 | 60 | no | no |
| 20268 | 90 Epic Rogue Boots | 4 | 109200 | 60 | no | no |
| 20269 | 90 Epic Rogue Bracers | 4 | 73065 | 60 | no | no |
| 20270 | 90 Epic Rogue Cap | 4 | 109995 | 60 | no | no |
| 20271 | 90 Epic Rogue Gloves | 4 | 73595 | 60 | no | no |
| 20272 | 90 Epic Rogue Pants | 4 | 147707 | 60 | no | no |
| 20273 | 90 Epic Rogue Spaulders | 4 | 111177 | 60 | no | no |
| 20274 | 90 Epic Rogue Tunic | 4 | 148767 | 60 | no | no |
| 21532 | Drudge Boots | 4 | 58116 | 60 | no | no |
| 21586 | Belt of Never-ending Agony | 4 | 66525 | 60 | no | no |
| 21594 | Bracers of the Fallen Son | 4 | 61930 | 60 | no | no |
| 21602 | Qiraji Execution Bracers | 4 | 46595 | 60 | no | no |
| 21605 | Gloves of the Hidden Temple | 4 | 47103 | 60 | no | no |
| 21609 | Regenerating Belt of Vek'nilash | 4 | 47782 | 60 | no | no |
| 21613 | Wormhide Boots | 4 | 72691 | 60 | no | no |
| 21614 | Wormhide Protector | 4 | 66012 | 60 | no | no |
| 21645 | Hive Tunneler's Boots | 4 | 58116 | 60 | no | no |
| 21665 | Mantle of Wicked Revenge | 4 | 58104 | 60 | no | no |
| 21669 | Creeping Vine Helm | 4 | 52140 | 60 | no | no |
| 21672 | Gloves of Enforcement | 4 | 35158 | 60 | no | no |
| 21693 | Guise of the Devourer | 4 | 50412 | 60 | no | no |
| 22661 | Polar Tunic | 4 | 89377 | 60 | no | no |
| 22662 | Polar Gloves | 4 | 44851 | 60 | no | no |
| 22663 | Polar Bracers | 4 | 46175 | 60 | no | no |
| 22668 | Bracers of Subterfuge | 4 | 16048 | 0 | no | no |
| 22701 | Polar Leggings | 4 | 91682 | 0 | no | no |
| 22740 | Outrider's Leather Pants | 4 | 43935 | 60 | no | no |
| 22741 | Outrider's Lizardhide Pants | 4 | 44092 | 60 | no | no |
| 22749 | Sentinel's Leather Pants | 4 | 42217 | 60 | no | no |
| 22750 | Sentinel's Lizardhide Pants | 4 | 42373 | 60 | no | no |
| 22941 | Polar Shoulder Pads | 4 | 77904 | 60 | no | no |
| 23020 | Polar Helmet | 4 | 79607 | 60 | no | no |
| 234819 | Demonic Gauntlet | 4 | 0 | 60 | no | no |
| 235044 | Goo-Covered Demonic Gauntlet | 4 | 0 | 60 | no | no |
| 252483 | Dawn Armor | 4 | 0 | 56 | no | no |
| 252484 | Timbermaw Tunic | 4 | 0 | 56 | no | no |
| 252485 | Warbear Helm | 4 | 0 | 56 | no | no |
| 252486 | Ironfeather Leggings | 4 | 0 | 56 | no | no |
| 252561 | Living Crown | 4 | 0 | 56 | no | no |
| 271955 | Theramore Pauldrons | 4 | 23843 | 60 | no | no |
| 272105 | Darkspear Pauldrons | 4 | 23843 | 60 | no | no |
| 272395 | Assassin's Waistguard | 4 | 50000 | 60 | no | no |
| 272396 | Shifter's Belt | 4 | 50000 | 60 | no | no |
| 272398 | Caretaker's Cord | 4 | 50000 | 60 | no | no |
| 272401 | Elunite Cord | 4 | 50000 | 60 | no | no |
| 272518 | Premier Legionnaire's Dragonhide Bracers | 4 | 0 | 60 | no | no |
| 272521 | Premier Legionnaire's Dragonhide Belt | 4 | 0 | 60 | no | no |
| 272522 | Premier Legionnaire's Shadowhide Girdle | 4 | 0 | 60 | no | no |
| 272524 | Premier Legionnaire's Shadowhide Armsplints | 4 | 0 | 60 | no | no |
| 272754 | Premier Knight-Captain's Beasthide Bracers | 4 | 0 | 60 | no | no |
| 272756 | Premier Knight-Captain's Beasthide Waistguard | 4 | 0 | 60 | no | no |
| 272767 | Premier Knight-Captain's Leather Cinch | 4 | 0 | 60 | no | no |
| 272769 | Premier Knight-Captain's Leather Armsplints | 4 | 0 | 60 | no | no |
| 273389 | Premier Knight-Captain's Lunarhide Bracers | 4 | 0 | 60 | no | no |
| 273390 | Premier Knight-Captain's Lunarhide Waistguard | 4 | 0 | 60 | no | no |
| 273397 | Premier Knight-Captain's Dreamhide Bracers | 4 | 0 | 60 | no | no |
| 273398 | Premier Knight-Captain's Dreamhide Waistguard | 4 | 0 | 60 | no | no |
| 273409 | Premier Legionnaire's Wyrmhide Bracers | 4 | 0 | 60 | no | no |
| 273412 | Premier Legionnaire's Wyrmhide Belt | 4 | 0 | 60 | no | no |
| 273417 | Premier Legionnaire's Kodohide Bracers | 4 | 0 | 60 | no | no |
| 273420 | Premier Legionnaire's Kodohide Belt | 4 | 0 | 60 | no | no |
| 279252 | Elderwild Waistcord | 4 | 15518 | 60 | no | no |
| 279253 | Outlaw's Collar | 4 | 21404 | 60 | no | no |
| 279254 | Elderwild Pants | 4 | 5252 | 60 | no | no |

### 4/3 Armadura / Malla, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 285 | Scalemail Vest | 1 | 711 | 17 | no | no |
| 286 | Scalemail Pants | 1 | 645 | 17 | no | no |
| 287 | Scalemail Boots | 1 | 488 | 17 | no | no |
| 718 | Scalemail Gloves | 1 | 322 | 17 | no | no |
| 847 | Chainmail Armor | 1 | 349 | 12 | no | no |
| 848 | Chainmail Pants | 1 | 351 | 12 | no | no |
| 849 | Chainmail Boots | 1 | 265 | 12 | no | no |
| 850 | Chainmail Gloves | 1 | 176 | 12 | no | no |
| 907 | Black Mail Shoulderpads of might (Test) | 1 | 1 | 1 | no | no |
| 1154 | Belt of the People's Militia | 1 | 102 | 0 | no | no |
| 1174 | Deprecated Light Soldier Boots | 1 | 65 | 0 | no | no |
| 1182 | Brass-studded Bracers | 1 | 44 | 0 | no | no |
| 1360 | Stormwind Chain Gloves | 1 | 42 | 0 | no | no |
| 1445 | Blackrock Pauldrons | 1 | 583 | 18 | no | no |
| 1845 | Chainmail Belt | 1 | 175 | 12 | no | no |
| 1846 | Chainmail Bracers | 1 | 176 | 12 | no | no |
| 1852 | Scalemail Bracers | 1 | 336 | 17 | no | no |
| 1853 | Scalemail Belt | 1 | 338 | 17 | no | no |
| 2109 | Frostmane Chain Vest | 1 | 14 | 1 | no | no |
| 2148 | Polished Scale Belt | 1 | 581 | 22 | no | no |
| 2149 | Polished Scale Boots | 1 | 879 | 22 | no | no |
| 2150 | Polished Scale Bracers | 1 | 586 | 22 | no | no |
| 2151 | Polished Scale Gloves | 1 | 588 | 22 | no | no |
| 2152 | Polished Scale Leggings | 1 | 1181 | 22 | no | no |
| 2153 | Polished Scale Vest | 1 | 1185 | 22 | no | no |
| 2172 | Rustic Belt | 1 | 7 | 0 | no | no |
| 2379 | Tarnished Chain Vest | 1 | 15 | 1 | no | no |
| 2380 | Tarnished Chain Belt | 1 | 7 | 1 | no | no |
| 2381 | Tarnished Chain Leggings | 1 | 15 | 1 | no | no |
| 2383 | Tarnished Chain Boots | 1 | 11 | 1 | no | no |
| 2384 | Tarnished Chain Bracers | 1 | 7 | 1 | no | no |
| 2385 | Tarnished Chain Gloves | 1 | 7 | 1 | no | no |
| 2386 | Rusted Chain Vest | 1 | 15 | 1 | no | no |
| 2387 | Rusted Chain Belt | 1 | 7 | 1 | no | no |
| 2388 | Rusted Chain Leggings | 1 | 15 | 1 | no | no |
| 2389 | Rusted Chain Boots | 1 | 11 | 1 | no | no |
| 2390 | Rusted Chain Bracers | 1 | 7 | 1 | no | no |
| 2391 | Rusted Chain Gloves | 1 | 7 | 1 | no | no |
| 2392 | Light Mail Armor | 1 | 82 | 5 | no | no |
| 2393 | Light Mail Belt | 1 | 41 | 5 | no | no |
| 2394 | Light Mail Leggings | 1 | 83 | 5 | no | no |
| 2395 | Light Mail Boots | 1 | 64 | 5 | no | no |
| 2396 | Light Mail Bracers | 1 | 43 | 5 | no | no |
| 2397 | Light Mail Gloves | 1 | 43 | 5 | no | no |
| 2398 | Light Chain Armor | 1 | 86 | 5 | no | no |
| 2399 | Light Chain Belt | 1 | 43 | 5 | no | no |
| 2400 | Light Chain Leggings | 1 | 87 | 5 | no | no |
| 2401 | Light Chain Boots | 1 | 66 | 5 | no | no |
| 2402 | Light Chain Bracers | 1 | 43 | 5 | no | no |
| 2403 | Light Chain Gloves | 1 | 44 | 5 | no | no |
| 2417 | Augmented Chain Vest | 1 | 3134 | 32 | no | no |
| 2418 | Augmented Chain Leggings | 1 | 3146 | 32 | no | no |
| 2419 | Augmented Chain Belt | 1 | 1578 | 32 | no | no |
| 2420 | Augmented Chain Boots | 1 | 2387 | 32 | no | no |
| 2421 | Augmented Chain Bracers | 1 | 1590 | 32 | no | no |
| 2422 | Augmented Chain Gloves | 1 | 1596 | 32 | no | no |
| 2423 | Brigandine Vest | 1 | 8554 | 45 | no | no |
| 2424 | Brigandine Belt | 1 | 4292 | 45 | no | no |
| 2425 | Brigandine Leggings | 1 | 8615 | 45 | no | no |
| 2426 | Brigandine Boots | 1 | 6513 | 45 | no | no |
| 2427 | Brigandine Bracers | 1 | 4029 | 45 | no | no |
| 2428 | Brigandine Gloves | 1 | 4044 | 45 | no | no |
| 2547 | Boar Handler Gloves | 1 | 7 | 0 | no | no |
| 2690 | Latched Belt | 1 | 7 | 0 | no | no |
| 2691 | Outfitter Boots | 1 | 10 | 0 | no | no |
| 2853 | Copper Bracers | 1 | 17 | 2 | no | no |
| 2898 | Mountaineer Chestpiece | 1 | 32 | 2 | no | no |
| 2967 | Warrior's Boots | 1 | 66 | 5 | no | no |
| 2968 | Warrior's Gloves | 1 | 33 | 4 | no | no |
| 2979 | Veteran Boots | 1 | 157 | 9 | no | no |
| 3151 | Siege Brigade Vest | 1 | 87 | 0 | no | no |
| 3213 | Veteran Bracers | 1 | 89 | 8 | no | no |
| 3214 | Warrior's Bracers | 1 | 33 | 4 | no | no |
| 3273 | Rugged Mail Vest | 1 | 15 | 0 | no | no |
| 3279 | Battle Chain Boots | 1 | 105 | 7 | no | no |
| 3280 | Battle Chain Bracers | 1 | 33 | 4 | no | no |
| 3281 | Battle Chain Gloves | 1 | 56 | 6 | no | no |
| 3303 | Brackwater Bracers | 1 | 70 | 7 | no | no |
| 3304 | Brackwater Gauntlets | 1 | 106 | 9 | no | no |
| 3332 | Perrine's Boots | 1 | 48 | 4 | no | no |
| 3333 | Deprecated Scarlet Captain's Pauldrons | 1 | 82 | 6 | no | no |
| 3437 | Clasped Belt | 1 | 23 | 0 | no | no |
| 3447 | Cryptwalker Boots | 1 | 34 | 0 | no | no |
| 3522 | Black Night Elf Breastplate | 1 | 2 | 1 | no | no |
| 3523 | Unused Black Night Elf Pants | 1 | 2 | 1 | no | no |
| 3524 | Unused Black Night Elf Boots | 1 | 1 | 1 | no | no |
| 3525 | Unused Black Night Elf Bracers | 1 | 1 | 1 | no | no |
| 3526 | Black Night Elf Gloves | 1 | 1 | 1 | no | no |
| 3527 | White Night Elf Breastplate | 1 | 2 | 1 | no | no |
| 3529 | Black Night Elf Helm | 1 | 1 | 1 | no | no |
| 3536 | Demon Hunter Blindfold | 1 | 1 | 1 | no | no |
| 3885 | Deprecated Scalemail Cap | 1 | 503 | 17 | no | no |
| 3888 | Deprecated Polished Scale Cap | 1 | 913 | 22 | no | no |
| 3891 | Augmented Chain Helm | 1 | 2456 | 32 | no | no |
| 3894 | Brigandine Helm | 1 | 5997 | 45 | no | no |
| 4657 | Deprecated Warrior's Pauldrons | 1 | 84 | 6 | no | no |
| 4659 | Warrior's Girdle | 1 | 23 | 3 | no | no |
| 4667 | Deprecated Battle Chain Pauldrons | 1 | 127 | 8 | no | no |
| 4669 | Battle Chain Girdle | 1 | 41 | 5 | no | no |
| 4678 | Veteran Girdle | 1 | 108 | 9 | no | no |
| 4681 | Brackwater Girdle | 1 | 109 | 9 | no | no |
| 4694 | Burnished Pauldrons | 1 | 515 | 17 | no | no |
| 4728 | Twain's Shoulder | 1 | 0 | 0 | no | no |
| 4910 | Painted Chain Gloves | 1 | 7 | 0 | no | no |
| 4913 | Painted Chain Belt | 1 | 7 | 0 | no | no |
| 4917 | Battleworn Chain Leggings | 1 | 14 | 0 | no | no |
| 4922 | Jagged Chain Vest | 1 | 15 | 0 | no | no |
| 4935 | Wide Metal Girdle | 1 | 23 | 0 | no | no |
| 4946 | Lightweight Boots | 1 | 67 | 0 | no | no |
| 4969 | Fortified Bindings | 1 | 42 | 0 | no | no |
| 4972 | Cliff Runner Boots | 1 | 64 | 0 | no | no |
| 5091 | test Eric Shirt | 1 | 1 | 0 | no | no |
| 5399 | Tracking Boots | 1 | 11 | 0 | no | no |
| 5589 | Moss-covered Gauntlets | 1 | 41 | 0 | no | no |
| 5592 | Shackled Girdle | 1 | 54 | 0 | no | no |
| 5607 | Deprecated Graystone Shoulders | 1 | 37 | 0 | no | no |
| 5941 | Brass Scale Pants | 1 | 115 | 0 | no | no |
| 6061 | Graystone Bracers | 1 | 23 | 0 | no | no |
| 6063 | Cold Steel Gauntlets | 1 | 23 | 0 | no | no |
| 6177 | Ironwrought Bracers | 1 | 69 | 0 | no | no |
| 6506 | Infantry Boots | 1 | 87 | 6 | no | no |
| 6507 | Infantry Bracers | 1 | 44 | 5 | no | no |
| 6509 | Infantry Belt | 1 | 44 | 5 | no | no |
| 6510 | Infantry Gauntlets | 1 | 54 | 6 | no | no |
| 6579 | Defender Spaulders | 1 | 667 | 19 | no | no |
| 9758 | Cadet Belt | 1 | 72 | 7 | no | no |
| 9759 | Cadet Boots | 1 | 138 | 8 | no | no |
| 9760 | Cadet Bracers | 1 | 73 | 7 | no | no |
| 9762 | Cadet Gauntlets | 1 | 92 | 8 | no | no |
| 10407 | Raider's Shoulderpads | 1 | 431 | 16 | no | no |
| 10635 | Painted Chain Leggings | 1 | 14 | 0 | no | no |
| 10656 | Barkmail Vest | 1 | 14 | 0 | no | no |
| 11849 | Rustmetal Bracers | 1 | 7 | 0 | no | no |
| 11852 | Roamer's Leggings | 1 | 14 | 0 | no | no |
| 13733 | [PH] Rising Dawn Fists | 1 | 1 | 1 | no | no |
| 13793 | [PH] Rising Dawn Coif | 1 | 1 | 1 | no | no |
| 14728 | War Paint Shoulder Pads | 1 | 485 | 17 | no | no |
| 15400 | Clamshell Bracers | 1 | 109 | 0 | no | no |
| 15472 | Charger's Belt | 1 | 33 | 4 | no | no |
| 15473 | Charger's Boots | 1 | 65 | 5 | no | no |
| 15474 | Charger's Bindings | 1 | 23 | 3 | no | no |
| 15476 | Charger's Handwraps | 1 | 44 | 5 | no | no |
| 15480 | War Torn Girdle | 1 | 84 | 8 | no | no |
| 15481 | War Torn Greaves | 1 | 127 | 8 | no | no |
| 15482 | War Torn Bands | 1 | 54 | 6 | no | no |
| 15484 | War Torn Handgrips | 1 | 68 | 7 | no | no |
| 15496 | Bloodspattered Shoulder Pads | 1 | 461 | 16 | no | no |
| 15505 | Outrunner's Pauldrons | 1 | 561 | 18 | no | no |
| 257257 | Thendal Ranger's Shoes | 1 | 10 | 0 | no | no |
| 257272 | Skychain Belt | 1 | 7 | 0 | no | no |
| 257331 | Brass-Banded Bracers | 1 | 44 | 0 | no | no |
| 257338 | Valanaar Chain Gloves | 1 | 42 | 0 | no | no |
| 257878 | Highlander's Chain Vest | 1 | 87 | 0 | no | no |
| 263410 | Watcher's Mail Chest | 1 | 14 | 0 | no | no |
| 263420 | Hiking Boots | 1 | 34 | 0 | no | no |
| 263423 | Highlands Mail Legguards | 1 | 23 | 0 | no | no |
| 263426 | Ex-Commander's Gauntlets | 1 | 23 | 0 | no | no |
| 277080 | Zephrali Chainmail | 1 | 201 | 9 | no | no |
| 277081 | Zephrali Wristguards | 1 | 101 | 9 | no | no |
| 277082 | Zephrali Gauntlets | 1 | 101 | 9 | no | no |
| 277083 | Zephrali Chain | 1 | 102 | 9 | no | no |
| 277084 | Zephrali Legguards | 1 | 204 | 9 | no | no |
| 277085 | Zephrali Greaves | 1 | 155 | 9 | no | no |

### 4/3 Armadura / Malla, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1273 | Forest Chain | 2 | 1656 | 0 | no | no |
| 1275 | Deputy Chain Coat | 2 | 1668 | 0 | no | no |
| 1282 | Sparkmetal Coif | 2 | 2825 | 0 | no | no |
| 1303 | Bridgeworker's Gloves | 2 | 418 | 0 | no | no |
| 2037 | Tunneler's Boots | 2 | 469 | 0 | no | no |
| 2230 | Gloves of Brawn | 2 | 714 | 0 | no | no |
| 2545 | Malleable Chain Leggings | 2 | 1796 | 0 | no | no |
| 2546 | Royal Frostmane Girdle | 2 | 55 | 8 | no | no |
| 2694 | Settler's Leggings | 2 | 539 | 0 | no | no |
| 2851 | Copper Chain Belt | 2 | 56 | 6 | no | no |
| 2852 | Copper Chain Pants | 2 | 67 | 4 | no | no |
| 2854 | Runed Copper Bracers | 2 | 225 | 14 | no | no |
| 2857 | Runed Copper Belt | 2 | 198 | 13 | no | no |
| 2864 | Runed Copper Breastplate | 2 | 630 | 13 | no | no |
| 2865 | Rough Bronze Leggings | 2 | 577 | 16 | no | no |
| 2866 | Rough Bronze Cuirass | 2 | 601 | 18 | no | no |
| 2867 | Rough Bronze Bracers | 2 | 317 | 18 | no | no |
| 2868 | Patterned Bronze Bracers | 2 | 507 | 20 | no | no |
| 2869 | Silvered Bronze Breastplate | 2 | 1831 | 21 | no | no |
| 2910 | Gold Militia Boots | 2 | 1257 | 0 | no | no |
| 3166 | Ironheart Chain | 2 | 407 | 0 | no | no |
| 3458 | Rugged Mail Gloves | 2 | 334 | 0 | no | no |
| 3469 | Copper Chain Boots | 2 | 49 | 4 | no | no |
| 3471 | Copper Chain Vest | 2 | 142 | 5 | no | no |
| 3472 | Runed Copper Gauntlets | 2 | 71 | 7 | no | no |
| 3473 | Runed Copper Pants | 2 | 299 | 8 | no | no |
| 3474 | Gemmed Copper Gauntlets | 2 | 216 | 10 | no | no |
| 3480 | Rough Bronze Shoulders | 2 | 532 | 17 | no | no |
| 3481 | Silvered Bronze Shoulders | 2 | 916 | 20 | no | no |
| 3482 | Silvered Bronze Boots | 2 | 918 | 21 | no | no |
| 3483 | Silvered Bronze Gauntlets | 2 | 965 | 22 | no | no |
| 3484 | Green Iron Boots | 2 | 1767 | 24 | no | no |
| 3485 | Green Iron Gauntlets | 2 | 1295 | 25 | no | no |
| 3559 | Night Watch Gauntlets | 2 | 473 | 0 | no | no |
| 3733 | Orcish War Chain | 2 | 1269 | 0 | no | no |
| 3751 | Mercenary Leggings | 2 | 2661 | 0 | no | no |
| 3758 | Crusader Belt | 2 | 1817 | 0 | no | no |
| 3765 | Brigand's Pauldrons | 2 | 4811 | 0 | no | no |
| 3835 | Green Iron Bracers | 2 | 1106 | 28 | no | no |
| 3836 | Green Iron Helm | 2 | 3053 | 29 | no | no |
| 3837 | Golden Scale Coif | 2 | 3084 | 33 | no | no |
| 3840 | Green Iron Shoulders | 2 | 2571 | 27 | no | no |
| 3841 | Golden Scale Shoulders | 2 | 3106 | 30 | no | no |
| 3842 | Green Iron Leggings | 2 | 2906 | 26 | no | no |
| 3843 | Golden Scale Leggings | 2 | 3882 | 29 | no | no |
| 3845 | Golden Scale Cuirass | 2 | 6558 | 35 | no | no |
| 3846 | Polished Steel Boots | 2 | 3937 | 32 | no | no |
| 3847 | Golden Scale Boots | 2 | 4977 | 35 | no | no |
| 4118 | Poobah's Nose Ring | 2 | 7313 | 0 | no | no |
| 4123 | Frost Metal Pauldrons | 2 | 3804 | 0 | no | no |
| 4132 | Darkspear Armsplints | 2 | 2681 | 0 | no | no |
| 4136 | Darkspear Boots | 2 | 6021 | 0 | no | no |
| 4138 | Blackwater Tunic | 2 | 10140 | 0 | no | no |
| 4443 | Grim Pauldrons | 2 | 3472 | 0 | no | no |
| 4508 | Blood-tinged Armor | 2 | 7793 | 0 | no | no |
| 4653 | Ironheel Boots | 2 | 7178 | 0 | no | no |
| 4741 | Stromgarde Cavalry Leggings | 2 | 5438 | 0 | no | no |
| 4745 | War Rider Bracers | 2 | 3230 | 0 | no | no |
| 4800 | Mighty Chain Pants | 2 | 1221 | 18 | no | no |
| 4816 | Legionnaire's Leggings | 2 | 1503 | 19 | no | no |
| 4833 | Glorious Shoulders | 2 | 1731 | 23 | no | no |
| 4835 | Elite Shoulders | 2 | 2110 | 25 | no | no |
| 5312 | Riveted Gauntlets | 2 | 419 | 0 | no | no |
| 5320 | Padded Lamellar Boots | 2 | 372 | 0 | no | no |
| 5328 | Cinched Belt | 2 | 205 | 0 | no | no |
| 5822 | Hedgeseed Gauntlets | 2 | 722 | 0 | no | no |
| 5944 | Greaves of the People's Militia | 2 | 331 | 0 | no | no |
| 6040 | Golden Scale Bracers | 2 | 1315 | 32 | no | no |
| 6084 | Stormwind Guard Leggings | 2 | 290 | 0 | no | no |
| 6188 | Mud Stompers | 2 | 305 | 0 | no | no |
| 6189 | Durable Chain Shoulders | 2 | 624 | 0 | no | no |
| 6350 | Rough Bronze Boots | 2 | 295 | 13 | no | no |
| 6502 | Violet Scale Armor | 2 | 1140 | 0 | no | no |
| 6665 | Hexed Bracers | 2 | 895 | 0 | no | no |
| 6666 | Dredge Boots | 2 | 830 | 0 | no | no |
| 6671 | Juggernaut Leggings | 2 | 2068 | 0 | no | no |
| 6675 | Tempered Bracers | 2 | 1048 | 0 | no | no |
| 6721 | Chestplate of Kor | 2 | 1418 | 0 | no | no |
| 6722 | Beastial Manacles | 2 | 1331 | 0 | no | no |
| 6730 | Ironforge Chain | 2 | 298 | 11 | no | no |
| 6731 | Ironforge Breastplate | 2 | 690 | 15 | no | no |
| 6733 | Ironforge Gauntlets | 2 | 1145 | 23 | no | no |
| 6747 | Enforcer Pauldrons | 2 | 5015 | 0 | no | no |
| 6773 | Kolkar Marauder Chain | 2 | 7366 | 35 | no | no |
| 6792 | Sanguine Pauldrons | 2 | 4738 | 0 | no | no |
| 6793 | Auric Bracers | 2 | 3157 | 0 | no | no |
| 6971 | Fire Hardened Coif | 2 | 2221 | 0 | no | no |
| 6973 | Fire Hardened Leggings | 2 | 2465 | 0 | no | no |
| 6974 | Fire Hardened Gauntlets | 2 | 1497 | 0 | no | no |
| 7107 | Belt of the Stars | 2 | 1858 | 0 | no | no |
| 7129 | Brutal Gauntlets | 2 | 1546 | 0 | no | no |
| 7130 | Brutal Helm | 2 | 2328 | 0 | no | no |
| 7132 | Brutal Legguards | 2 | 2338 | 0 | no | no |
| 7229 | Explorer's Vest | 2 | 285 | 0 | no | no |
| 7336 | Wildwood Chain | 2 | 1509 | 0 | no | no |
| 7913 | Barbaric Iron Shoulders | 2 | 2500 | 27 | no | no |
| 7914 | Barbaric Iron Breastplate | 2 | 3330 | 27 | no | no |
| 7915 | Barbaric Iron Helm | 2 | 3337 | 30 | no | no |
| 7916 | Barbaric Iron Boots | 2 | 3700 | 31 | no | no |
| 7917 | Barbaric Iron Gloves | 2 | 2711 | 32 | no | no |
| 7920 | Mithril Plate Pants | 2 | 8053 | 40 | no | no |
| 7924 | Mithril Plate Bracers | 2 | 4103 | 40 | no | no |
| 7925 | Mithril Plate Gloves | 2 | 4447 | 40 | no | no |
| 7929 | Orcish War Leggings | 2 | 7739 | 40 | no | no |
| 7931 | Mithril Coif | 2 | 7955 | 41 | no | no |
| 7932 | Mithril Plate Shoulders | 2 | 8661 | 42 | no | no |
| 7963 | Steel Breastplate | 2 | 5615 | 35 | no | no |
| 8185 | Turtle Scale Leggings | 2 | 10952 | 42 | no | no |
| 8187 | Turtle Scale Gloves | 2 | 3477 | 36 | no | no |
| 8189 | Turtle Scale Breastplate | 2 | 7567 | 37 | no | no |
| 8191 | Turtle Scale Helm | 2 | 7780 | 41 | no | no |
| 8198 | Turtle Scale Bracers | 2 | 4013 | 37 | no | no |
| 8203 | Tough Scorpid Breastplate | 2 | 8628 | 39 | no | no |
| 8204 | Tough Scorpid Gloves | 2 | 4676 | 40 | no | no |
| 8205 | Tough Scorpid Bracers | 2 | 4346 | 39 | no | no |
| 8206 | Tough Scorpid Leggings | 2 | 12704 | 44 | no | no |
| 8207 | Tough Scorpid Shoulders | 2 | 8978 | 43 | no | no |
| 8208 | Tough Scorpid Helm | 2 | 10272 | 45 | no | no |
| 8209 | Tough Scorpid Boots | 2 | 8375 | 42 | no | no |
| 9366 | Golden Scale Gauntlets | 2 | 3689 | 36 | no | no |
| 9599 | Barkmail Leggings | 2 | 142 | 0 | no | no |
| 9638 | Chelonian Cuffs | 2 | 6875 | 0 | no | no |
| 9650 | Honorguard Chestpiece | 2 | 18016 | 0 | no | no |
| 9663 | Dawnrider's Chestpiece | 2 | 9969 | 0 | no | no |
| 9666 | Stronghorn Girdle | 2 | 7266 | 0 | no | no |
| 10421 | Rough Copper Vest | 2 | 32 | 2 | no | no |
| 10423 | Silvered Bronze Leggings | 2 | 2366 | 26 | no | no |
| 10542 | Goblin Mining Helmet | 2 | 5255 | 0 | no | no |
| 10701 | Boots of Zua'tec | 2 | 7536 | 0 | no | no |
| 10706 | Nightscale Girdle | 2 | 5521 | 0 | no | no |
| 10743 | Drakefire Headguard | 2 | 10830 | 0 | no | no |
| 11194 | Prismscale Hauberk | 2 | 20404 | 0 | no | no |
| 11229 | Brightscale Girdle | 2 | 1696 | 0 | no | no |
| 11606 | Dark Iron Mail | 2 | 19255 | 51 | no | no |
| 11867 | Maddening Gauntlets | 2 | 8769 | 0 | no | no |
| 11882 | Outrider Leggings | 2 | 20520 | 0 | no | no |
| 11913 | Clayridge Helm | 2 | 14044 | 0 | no | no |
| 11918 | Grotslab Gloves | 2 | 9537 | 0 | no | no |
| 12051 | Brazen Gauntlets | 2 | 8996 | 0 | no | no |
| 12105 | Pridemail Leggings | 2 | 25144 | 0 | no | no |
| 12257 | Heavy Notched Belt | 2 | 3885 | 37 | no | no |
| 12258 | Serpent Clasp Belt | 2 | 4549 | 39 | no | no |
| 12415 | Radiant Breastplate | 2 | 17003 | 49 | no | no |
| 12416 | Radiant Belt | 2 | 7595 | 47 | no | no |
| 12417 | Radiant Circlet | 2 | 17034 | 54 | no | no |
| 12418 | Radiant Gloves | 2 | 10242 | 52 | no | no |
| 12419 | Radiant Boots | 2 | 16421 | 53 | no | no |
| 12420 | Radiant Leggings | 2 | 25330 | 56 | no | no |
| 12615 | Savage Mail Tunic | 2 | 27510 | 57 | no | no |
| 12616 | Savage Mail Boots | 2 | 21841 | 58 | no | no |
| 12617 | Savage Mail Shoulders | 2 | 21919 | 58 | no | no |
| 14727 | War Paint Legguards | 2 | 778 | 14 | no | no |
| 15076 | Heavy Scorpid Vest | 2 | 16604 | 48 | no | no |
| 15077 | Heavy Scorpid Bracers | 2 | 7615 | 46 | no | no |
| 15078 | Heavy Scorpid Gauntlet | 2 | 9649 | 50 | no | no |
| 15079 | Heavy Scorpid Leggings | 2 | 21760 | 52 | no | no |
| 15080 | Heavy Scorpid Helm | 2 | 18230 | 54 | no | no |
| 15081 | Heavy Scorpid Shoulders | 2 | 20261 | 56 | no | no |
| 15082 | Heavy Scorpid Belt | 2 | 10375 | 51 | no | no |
| 15203 | Guststorm Legguards | 2 | 621 | 0 | no | no |
| 15402 | Noosegrip Gauntlets | 2 | 109 | 0 | no | no |
| 15404 | Breakwater Girdle | 2 | 337 | 0 | no | no |
| 15406 | Crustacean Boots | 2 | 402 | 0 | no | no |
| 15459 | Grimtoll Wristguards | 2 | 1142 | 0 | no | no |
| 15463 | Palestrider Gloves | 2 | 787 | 0 | no | no |
| 15470 | Plainsguard Leggings | 2 | 2432 | 0 | no | no |
| 15588 | Bracesteel Belt | 2 | 2194 | 0 | no | no |
| 15698 | Wrangling Spaulders | 2 | 4273 | 0 | no | no |
| 15787 | Willow Band Hauberk | 2 | 22592 | 0 | no | no |
| 15796 | Seaspray Bracers | 2 | 12063 | 0 | no | no |
| 15813 | Gold Link Belt | 2 | 10113 | 0 | no | no |
| 15823 | Bricksteel Gauntlets | 2 | 9191 | 0 | no | no |
| 16664 | Ornate Bracers | 2 | 9234 | 49 | no | no |
| 16793 | Arcmetal Shoulders | 2 | 4353 | 0 | no | no |
| 16794 | Gripsteel Wristguards | 2 | 2705 | 0 | no | no |
| 16986 | Sandspire Gloves | 2 | 850 | 0 | no | no |
| 17006 | Cobalt Legguards | 2 | 1966 | 0 | no | no |
| 17769 | Sagebrush Spaulders | 2 | 8673 | 0 | no | no |
| 19125 | Seared Mail Girdle | 2 | 6652 | 0 | no | no |
| 19128 | Seared Mail Vest | 2 | 13358 | 0 | no | no |
| 21312 | Belt of the Den Watcher | 2 | 6377 | 0 | no | no |
| 21320 | Vest of the Den Watcher | 2 | 22497 | 0 | no | no |
| 217270 | Turtle Scale Gloves | 2 | 3477 | 36 | no | no |
| 217273 | Golden Scale Gauntlets | 2 | 3689 | 36 | no | no |
| 250483 | Sterling Silver Boots | 2 | 1267 | 20 | no | no |
| 250484 | Sterling Silver Leggings | 2 | 1908 | 21 | no | no |
| 250485 | Sterling Silver Gauntlet | 2 | 957 | 21 | no | no |
| 250486 | Sterling Silver Shoulders | 2 | 490 | 22 | no | no |
| 250487 | Sterling Silver Breastplate | 2 | 485 | 25 | no | no |
| 250533 | Hard Gold Cuirass | 2 | 3929 | 29 | no | no |
| 250534 | Hard Gold Boots | 2 | 3268 | 30 | no | no |
| 250535 | Hard Gold Bracers | 2 | 2634 | 32 | no | no |
| 250536 | Hard Gold Leggings | 2 | 5711 | 33 | no | no |
| 250537 | Hard Gold Coif | 2 | 5036 | 35 | no | no |
| 250538 | Hard Gold Gauntlet | 2 | 3354 | 35 | no | no |
| 250539 | Hard Gold Pauldrons | 2 | 5073 | 35 | no | no |
| 252574 | Supple Scorpid Boots | 2 | 0 | 46 | no | no |
| 252575 | Charged Scorpid Belt | 2 | 0 | 46 | no | no |
| 252580 | Supple Scorpid Leggings | 2 | 0 | 48 | no | no |
| 252581 | Charged Scorpid Helm | 2 | 0 | 48 | no | no |
| 252582 | Supple Scorpid Bracers | 2 | 0 | 50 | no | no |
| 252583 | Charged Scorpid Shoulders | 2 | 0 | 50 | no | no |
| 252592 | Supple Scorpid Shoulders | 2 | 0 | 51 | no | no |
| 252593 | Charged Scorpid Bracers | 2 | 0 | 51 | no | no |
| 252594 | Heavy Scorpid Boots | 2 | 0 | 51 | no | no |
| 252595 | Supple Scorpid Belt | 2 | 0 | 51 | no | no |
| 252596 | Charged Scorpid Gauntlets | 2 | 0 | 51 | no | no |
| 252597 | Supple Scorpid Helm | 2 | 0 | 52 | no | no |
| 252598 | Charged Scorpid Vest | 2 | 0 | 52 | no | no |
| 252599 | Supple Scorpid Vest | 2 | 0 | 54 | no | no |
| 252600 | Charged Scorpid Leggings | 2 | 0 | 54 | no | no |
| 252601 | Supple Scorpid Sabatons | 2 | 0 | 56 | no | no |
| 252602 | Charged Scorpid Boots | 2 | 0 | 56 | no | no |
| 257342 | Elite Peacekeeper's Leggings | 2 | 290 | 0 | no | no |
| 263308 | Cult Hunter's Boots | 2 | 87 | 0 | no | no |
| 263311 | Scuffed Cuffs | 2 | 54 | 0 | no | no |
| 263333 | Peacekeeper's Mail | 2 | 189 | 0 | no | no |
| 263337 | Breaker's Gauntlets | 2 | 56 | 0 | no | no |
| 263340 | Peacekeeper's Legguards | 2 | 115 | 0 | no | no |
| 263403 | Cilice of Regret | 2 | 56 | 0 | no | no |
| 270010 | Raptorcrest Bracers | 2 | 725 | 0 | no | no |
| 270034 | Shadow Gauntlets | 2 | 825 | 0 | no | no |
| 270038 | Runed Gauntlets | 2 | 1124 | 0 | no | no |
| 270068 | Stromgarde Bracers | 2 | 3268 | 0 | no | no |
| 270073 | Stromgarde Cuffs | 2 | 3268 | 0 | no | no |
| 270077 | Undertow Legguards | 2 | 8665 | 0 | no | no |
| 270087 | Thick Ogre's Belt | 2 | 4303 | 0 | no | no |
| 270097 | Archer's Leggings | 2 | 12692 | 0 | no | no |
| 270103 | Reloading Assist Armbands | 2 | 5130 | 0 | no | no |
| 270110 | First Mate's Armguards | 2 | 6571 | 0 | no | no |
| 274720 | Abandoned Boots | 2 | 16980 | 0 | no | no |
| 274745 | Deckswabber's Mitts | 2 | 2208 | 30 | no | no |
| 274757 | Substandard Belt Chain | 2 | 9355 | 50 | no | no |
| 274916 | Verger Greaves | 2 | 5164 | 0 | no | no |
| 274939 | Southern Watch Leggings | 2 | 8080 | 0 | no | no |
| 274943 | Gnoll Crusher Leggings | 2 | 7626 | 0 | no | no |
| 275434 | Murkborn Girdle | 2 | 11102 | 0 | no | no |
| 276201 | Misplaced Pantaloons | 2 | 5884 | 40 | no | no |
| 276719 | DNT HEAD | 2 | 0 | 0 | no | no |
| 276720 | Criminal's Pauldrons | 2 | 0 | 0 | no | no |
| 276721 | DNT CHEST | 2 | 0 | 0 | no | no |
| 276722 | Gnoll Shackles | 2 | 0 | 0 | no | no |
| 276723 | Wise Gauntlets | 2 | 0 | 0 | no | no |
| 276724 | Trophy Belt | 2 | 0 | 0 | no | no |
| 276725 | DNT LEGS | 2 | 0 | 0 | no | no |
| 276727 | Glistening Stompers | 2 | 0 | 0 | no | no |
| 276992 | Cloudy Skyforged Chainmail | 2 | 0 | 7 | no | no |
| 276993 | Cloudy Skyforged Wristguards | 2 | 0 | 5 | no | no |
| 276994 | Cloudy Skyforged Gauntlets | 2 | 0 | 6 | no | no |
| 276995 | Cloudy Skyforged Chain | 2 | 0 | 5 | no | no |
| 276996 | Cloudy Skyforged Legguards | 2 | 0 | 7 | no | no |
| 276997 | Cloudy Skyforged Greaves | 2 | 0 | 6 | no | no |
| 277016 | Azure Skyforged Chainmail | 2 | 0 | 7 | no | no |
| 277017 | Azure Skyforged Wristguards | 2 | 0 | 5 | no | no |
| 277018 | Azure Skyforged Gauntlets | 2 | 0 | 6 | no | no |
| 277019 | Azure Skyforged Chain | 2 | 0 | 5 | no | no |
| 277020 | Azure Skyforged Legguards | 2 | 0 | 7 | no | no |
| 277021 | Azure Skyforged Greaves | 2 | 0 | 6 | no | no |
| 277040 | Cloudy Skyforged Helm | 2 | 0 | 30 | no | no |
| 277041 | Cloudy Skyforged Pauldrons | 2 | 0 | 30 | no | no |
| 277048 | Azure Skyforged Helm | 2 | 0 | 30 | no | no |
| 277049 | Azure Skyforged Pauldrons | 2 | 0 | 30 | no | no |
| 277227 | Magistrate's Chain Hood | 2 | 0 | 0 | no | no |
| 277228 | Snakescale Pauldrons | 2 | 0 | 40 | no | no |
| 277229 | Enduring Chain Vest | 2 | 0 | 40 | no | no |
| 277230 | Grayscale Bracers | 2 | 0 | 40 | no | no |
| 277231 | Conductive Gauntlets | 2 | 0 | 40 | no | no |
| 277232 | Jailer's Discarded Chain | 2 | 0 | 0 | no | no |
| 277233 | Clinking Mail Legguards | 2 | 0 | 40 | no | no |
| 277234 | Alacritous Treads | 2 | 0 | 0 | no | no |
| 277672 | Rough Copper Chain Boots | 2 | 49 | 4 | no | no |
| 280308 | Clanking Cord | 2 | 1033 | 30 | no | no |
| 281262 | Crystal-flecked Waistguard | 2 | 0 | 0 | no | no |
| 281267 | Raptorscale Pants | 2 | 0 | 0 | no | no |
| 281272 | Brog's Friendship Bracelet | 2 | 0 | 0 | no | no |
| 281273 | Migi's Friendship Bracelet | 2 | 0 | 0 | no | no |
| 281277 | Shoulders of Scaleslaying | 2 | 0 | 0 | no | no |
| 281280 | Mountain Climbers | 2 | 0 | 0 | no | no |
| 281285 | Finscale Soles | 2 | 1 | 0 | no | no |
| 281303 | Bleached Scale Vest | 2 | 0 | 0 | no | no |
| 281316 | Glimmerchain Trousers | 2 | 0 | 0 | no | no |
| 281323 | Spirit-buckle Belt | 2 | 0 | 0 | no | no |
| 281701 | Restored Mail Coif | 2 | 1 | 1 | no | no |
| 281702 | Restored Mail Shoulderguards | 2 | 1 | 1 | no | no |
| 281703 | Restored Mail Chestpiece | 2 | 1 | 1 | no | no |
| 281704 | Restored Mail Wristguards | 2 | 1 | 1 | no | no |
| 281705 | Restored Mail Clasps | 2 | 1 | 1 | no | no |
| 281706 | Restored Mail Belt | 2 | 1 | 1 | no | no |
| 281707 | Restored Mail Legguards | 2 | 1 | 1 | no | no |
| 281708 | Restored Mail Boots | 2 | 1 | 1 | no | no |

### 4/3 Armadura / Malla, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2275 | Deprecated Sentinel Coif | 3 | 795 | 15 | no | no |
| 3844 | Green Iron Hauberk | 3 | 5658 | 31 | no | no |
| 8347 | Dragonscale Gauntlets | 3 | 5979 | 40 | no | no |
| 12018 | Conservator Helm | 3 | 13842 | 0 | no | no |
| 12624 | Wildthorn Mail | 3 | 20642 | 49 | no | no |
| 12636 | Helm of the Great Chief | 3 | 24285 | 56 | no | no |
| 13090 | Breastplate of the Chosen | 3 | 35955 | 58 | no | no |
| 15047 | Red Dragonscale Breastplate | 3 | 29836 | 56 | no | no |
| 16400 | Knight-Captain's Chain Girdle | 3 | 7768 | 55 | no | no |
| 16401 | Knight-Lieutenant's Chain Boots | 3 | 13596 | 58 | no | no |
| 16402 | Knight-Captain's Chain Armguards | 3 | 7823 | 55 | no | no |
| 16425 | Knight-Captain's Chain Hauberk | 3 | 16571 | 58 | no | no |
| 16426 | Knight-Captain's Chain Leggings | 3 | 16635 | 58 | no | no |
| 16427 | Lieutenant Commander's Chain Pauldrons | 3 | 12923 | 58 | no | no |
| 16428 | Lieutenant Commander's Chain Helmet | 3 | 12914 | 58 | no | no |
| 16517 | Legionnaire's Chain Bracers | 3 | 7131 | 55 | no | no |
| 16519 | Blood Guard's Mail Grips | 3 | 8318 | 58 | no | no |
| 16520 | Legionnaire's Mail Cinch | 3 | 7213 | 55 | no | no |
| 16521 | Champion's Mail Helm | 3 | 12572 | 58 | no | no |
| 16522 | Legionnaire's Mail Chestpiece | 3 | 16827 | 58 | no | no |
| 16523 | Legionnaire's Mail Leggings | 3 | 17349 | 58 | no | no |
| 16524 | Champion's Mail Shoulders | 3 | 13117 | 58 | no | no |
| 16525 | Legionnaire's Chain Breastplate | 3 | 17475 | 58 | no | no |
| 16527 | Legionnaire's Chain Leggings | 3 | 17603 | 58 | no | no |
| 16528 | Champion's Chain Pauldrons | 3 | 13309 | 58 | no | no |
| 16529 | Legionnaire's Chain Girdle | 3 | 7657 | 55 | no | no |
| 16531 | Blood Guard's Chain Boots | 3 | 13452 | 58 | no | no |
| 16532 | First Sergeant's Mail Wristguards | 3 | 8960 | 58 | no | no |
| 16978 | Warsong Gauntlets | 3 | 1158 | 0 | no | no |
| 18432 | First Sergeant's Mail Wristguards | 3 | 4348 | 45 | no | no |
| 18448 | Sergeant Major's Chain Armguards | 3 | 8801 | 58 | no | no |
| 18449 | Sergeant Major's Chain Armguards | 3 | 4301 | 45 | no | no |
| 18508 | Swift Flight Bracers | 3 | 17194 | 57 | no | no |
| 18807 | Helm of Latent Power | 3 | 25796 | 0 | no | no |
| 19043 | Heavy Timbermaw Belt | 3 | 13291 | 53 | no | no |
| 19048 | Heavy Timbermaw Boots | 3 | 28061 | 56 | no | no |
| 19088 | Frostwolf Mail Belt | 3 | 15319 | 55 | no | no |
| 19092 | Stormpike Mail Girdle | 3 | 14233 | 55 | no | no |
| 20088 | Highlander's Chain Girdle | 3 | 10495 | 48 | no | no |
| 20089 | Highlander's Chain Girdle | 3 | 5208 | 40 | no | no |
| 20108 | Highlander's Lamellar Girdle | 3 | 2075 | 28 | no | no |
| 20118 | Highlander's Mail Girdle | 3 | 10121 | 48 | no | no |
| 20119 | Highlander's Mail Girdle | 3 | 5022 | 40 | no | no |
| 20126 | Highlander's Plate Girdle | 3 | 2058 | 28 | no | no |
| 20151 | Defiler's Chain Girdle | 3 | 9858 | 48 | no | no |
| 20153 | Defiler's Chain Girdle | 3 | 4911 | 40 | no | no |
| 20178 | Defiler's Lamellar Girdle | 3 | 2210 | 28 | no | no |
| 20196 | Defiler's Mail Girdle | 3 | 10309 | 48 | no | no |
| 20198 | Defiler's Mail Girdle | 3 | 5134 | 40 | no | no |
| 20207 | Defiler's Plate Girdle | 3 | 2122 | 28 | no | no |
| 20215 | Belt of Shriveled Heads | 3 | 24684 | 0 | no | no |
| 20476 | Sandstalker Bracers | 3 | 16401 | 57 | no | no |
| 20477 | Sandstalker Gauntlets | 3 | 16898 | 57 | no | no |
| 20478 | Sandstalker Breastplate | 3 | 33917 | 57 | no | no |
| 20479 | Spitfire Breastplate | 3 | 34036 | 57 | no | no |
| 20480 | Spitfire Gauntlets | 3 | 17078 | 57 | no | no |
| 20481 | Spitfire Bracers | 3 | 17139 | 57 | no | no |
| 20701 | Cenarion Reservist's Legguards | 3 | 34314 | 0 | no | no |
| 20702 | Cenarion Reservist's Legguards | 3 | 35358 | 0 | no | no |
| 20712 | Wastewalker's Gauntlets | 3 | 16583 | 0 | no | no |
| 20713 | Desertstalkers's Gauntlets | 3 | 16647 | 0 | no | no |
| 22195 | Light Obsidian Belt | 3 | 22885 | 60 | no | no |
| 22690 | Leggings of the Plague Hunter | 3 | 38147 | 0 | no | no |
| 227947 | Golem Fitted Pauldrons | 3 | 17311 | 51 | no | no |
| 250482 | Glowing Copper Boots | 3 | 207 | 10 | no | no |
| 250488 | Veteran's Chain Shirt | 3 | 488 | 15 | no | no |
| 250489 | Guard's Chain Shirt | 3 | 493 | 15 | no | no |
| 250490 | Protector's Chain Shirt | 3 | 503 | 15 | no | no |
| 250491 | Acolyte's Chain Shirt | 3 | 503 | 15 | no | no |
| 250492 | Crusader's Chain Shirt | 3 | 498 | 15 | no | no |
| 250493 | Veteran's Chain Leggings | 3 | 965 | 20 | no | no |
| 250494 | Guard's Chain Leggings | 3 | 984 | 20 | no | no |
| 250495 | Protector's Chain Leggings | 3 | 965 | 20 | no | no |
| 250496 | Acolyte's Chain Leggings | 3 | 965 | 20 | no | no |
| 250497 | Crusader's Chain Leggings | 3 | 1004 | 20 | no | no |
| 250498 | Veteran's Chain Helm | 3 | 1274 | 25 | no | no |
| 250499 | Guard's Chain Helm | 3 | 1262 | 25 | no | no |
| 250500 | Protector's Chain Helm | 3 | 1274 | 25 | no | no |
| 250501 | Acolyte's Chain Helm | 3 | 1262 | 25 | no | no |
| 250502 | Crusader's Chain Helm | 3 | 1274 | 25 | no | no |
| 250503 | Veteran's Boots | 3 | 1054 | 17 | no | no |
| 250504 | Guard's Boots | 3 | 1057 | 17 | no | no |
| 250505 | Protector's Boots | 3 | 1061 | 17 | no | no |
| 250506 | Acolyte's Boots | 3 | 1065 | 17 | no | no |
| 250507 | Crusader's Boots | 3 | 1069 | 17 | no | no |
| 250508 | Veteran's Gloves | 3 | 487 | 15 | no | no |
| 250509 | Guard's Gloves | 3 | 489 | 15 | no | no |
| 250510 | Protector's Gloves | 3 | 504 | 15 | no | no |
| 250511 | Acolyte's Gloves | 3 | 506 | 15 | no | no |
| 250512 | Crusader's Gloves | 3 | 508 | 15 | no | no |
| 250513 | Veteran's Chain Belt | 3 | 335 | 12 | no | no |
| 250514 | Guard's Chain Belt | 3 | 336 | 12 | no | no |
| 250515 | Protector's Chain Belt | 3 | 337 | 12 | no | no |
| 250516 | Acolyte's Chain Belt | 3 | 339 | 12 | no | no |
| 250517 | Crusader's Chain Belt | 3 | 340 | 12 | no | no |
| 250518 | Veteran's Silvered Chain Shirt | 3 | 2464 | 22 | no | no |
| 250519 | Guard's Silvered Chain Shirt | 3 | 2473 | 22 | no | no |
| 250520 | Protector's Silvered Chain Shirt | 3 | 2482 | 22 | no | no |
| 250521 | Acolyte's Silvered Chain Shirt | 3 | 2491 | 22 | no | no |
| 250522 | Crusader's Silvered Chain Shirt | 3 | 2500 | 22 | no | no |
| 250523 | Veteran's Silvered Chain Leggings | 3 | 3340 | 25 | no | no |
| 250524 | Guard's Silvered Chain Leggings | 3 | 3352 | 25 | no | no |
| 250525 | Protector's Silvered Chain Leggings | 3 | 3363 | 25 | no | no |
| 250526 | Acolyte's Silvered Chain Leggings | 3 | 3137 | 25 | no | no |
| 250527 | Crusader's Silvered Chain Leggings | 3 | 3149 | 25 | no | no |
| 250528 | Veteran's Silvered Chain Helm | 3 | 1439 | 20 | no | no |
| 250529 | Guard's Silvered Chain Helm | 3 | 1444 | 20 | no | no |
| 250530 | Protector's Silvered Chain Helm | 3 | 1450 | 20 | no | no |
| 250531 | Acolyte's Silvered Chain Helm | 3 | 1455 | 20 | no | no |
| 250532 | Crusader's Silvered Chain Helm | 3 | 1460 | 20 | no | no |
| 250556 | Officer's Belt | 3 | 1378 | 30 | no | no |
| 250557 | Sentinel's Belt | 3 | 1337 | 30 | no | no |
| 250558 | Warder's Belt | 3 | 1378 | 30 | no | no |
| 250559 | Prefect's Belt | 3 | 1392 | 30 | no | no |
| 250560 | Justicar's Belt | 3 | 1365 | 30 | no | no |
| 250566 | Officer's Gauntlet | 3 | 3850 | 35 | no | no |
| 250567 | Sentinel's Gauntlet | 3 | 3864 | 35 | no | no |
| 250568 | Warder's Gauntlet | 3 | 3878 | 35 | no | no |
| 250569 | Prefect's Gauntlet | 3 | 3893 | 35 | no | no |
| 250570 | Justicar's Gauntlet | 3 | 3908 | 35 | no | no |
| 250620 | Gemmed Copper Boots | 3 | 203 | 10 | no | no |
| 250621 | Strange Copper Boots | 3 | 191 | 10 | no | no |
| 252562 | Stalker's Mail Boots | 3 | 4430 | 40 | no | no |
| 252563 | Skycaller's Mail Boots | 3 | 4387 | 40 | no | no |
| 252564 | Skirmisher's Mail Boots | 3 | 4256 | 40 | no | no |
| 252565 | Mender's Mail Boots | 3 | 4300 | 40 | no | no |
| 252566 | Stalker's Mail Shoulders | 3 | 0 | 42 | no | no |
| 252567 | Skycaller's Mail Shoulders | 3 | 0 | 42 | no | no |
| 252568 | Skirmisher's Mail Shoulders | 3 | 0 | 42 | no | no |
| 252569 | Mender's Mail Shoulders | 3 | 0 | 42 | no | no |
| 252570 | Stalker's Mail Bracers | 3 | 0 | 45 | no | no |
| 252571 | Skycaller's Mail Bracers | 3 | 0 | 45 | no | no |
| 252572 | Skirmisher's Mail Bracers | 3 | 0 | 45 | no | no |
| 252573 | Mender's Mail Bracers | 3 | 0 | 45 | no | no |
| 252576 | Stalker's Mail Sabatons | 3 | 0 | 47 | no | no |
| 252577 | Skycaller's Mail Sabatons | 3 | 0 | 47 | no | no |
| 252578 | Skirmisher's Mail Sabatons | 3 | 0 | 47 | no | no |
| 252579 | Mender's Mail Sabatons | 3 | 0 | 47 | no | no |
| 252584 | Stalker's Mail Gauntlets | 3 | 5866 | 50 | no | no |
| 252585 | Skycaller's Mail Gauntlets | 3 | 5866 | 50 | no | no |
| 252586 | Skirmisher's Mail Gauntlets | 3 | 5866 | 50 | no | no |
| 252587 | Mender's Mail Gauntlets | 3 | 5808 | 50 | no | no |
| 252588 | Stalker's Mail Belt | 3 | 0 | 50 | no | no |
| 252589 | Skycaller's Mail Belt | 3 | 0 | 50 | no | no |
| 252590 | Skirmisher's Mail Belt | 3 | 0 | 50 | no | no |
| 252591 | Mender's Mail Belt | 3 | 0 | 50 | no | no |
| 260185 | Hippogryph Hide Boots | 3 | 10563 | 0 | no | no |
| 271811 | Clacking Carapace Spaulders | 3 | 7777 | 1 | no | no |
| 272483 | Premier Chain Bracers | 3 | 0 | 55 | no | no |
| 272494 | Premier Chain Girdle | 3 | 0 | 55 | no | no |
| 272497 | Premier Linked Wristguards | 3 | 0 | 55 | no | no |
| 272581 | First Sergeant's Mail Wristguards | 3 | 4348 | 45 | no | no |
| 272712 | Premier Chainmail Girdle | 3 | 0 | 55 | no | no |
| 272830 | Premier Chainmail Armguards | 3 | 0 | 55 | no | no |
| 273352 | Premier Linked Girdle | 3 | 0 | 55 | no | no |
| 273353 | Premier Mail Wristguards | 3 | 0 | 55 | no | no |
| 273361 | Premier Ringmail Wristguards | 3 | 0 | 55 | no | no |
| 273362 | Premier Ringmail Girdle | 3 | 0 | 55 | no | no |
| 273372 | Premier Mail Girdle | 3 | 0 | 55 | no | no |
| 274182 | Premier Flatmail Wristguards | 3 | 0 | 55 | no | no |
| 274214 | Premier Flatmail Girdle | 3 | 0 | 55 | no | no |
| 274215 | Premier Scalemail Wristguards | 3 | 0 | 55 | no | no |
| 274223 | Premier Linkmail Wristguards | 3 | 0 | 55 | no | no |
| 274224 | Premier Linkmail Girdle | 3 | 0 | 55 | no | no |
| 274225 | Premier Scalemail Girdle | 3 | 0 | 55 | no | no |
| 275616 | Scalegut Clenchers | 3 | 13126 | 53 | no | no |
| 275617 | Scalegut Belt | 3 | 13176 | 53 | no | no |
| 275618 | Scalegut Treaders | 3 | 19928 | 53 | no | no |
| 275619 | Broodwatcher's Clenchers | 3 | 13275 | 53 | no | no |
| 275620 | Broodwatcher's Belt | 3 | 13325 | 53 | no | no |
| 275621 | Broodwatcher's Treaders | 3 | 20152 | 53 | no | no |
| 275737 | Hermit's Pauldron | 3 | 23588 | 0 | no | no |
| 275741 | Ketharas' Linked Belt | 3 | 15886 | 0 | no | no |

### 4/3 Armadura / Malla, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 15141 | Onyxia Scale Breastplate | 4 | 41937 | 57 | no | no |
| 16461 | Marshal's Chain Bracers | 4 | 12326 | 60 | no | no |
| 16462 | Marshal's Chain Boots | 4 | 24982 | 60 | no | no |
| 16464 | Marshal's Chain Girdle | 4 | 12466 | 60 | no | no |
| 16465 | Field Marshal's Chain Helm | 4 | 29117 | 60 | no | no |
| 16466 | Field Marshal's Chain Breastplate | 4 | 38968 | 60 | no | no |
| 16467 | Marshal's Chain Legguards | 4 | 33788 | 60 | no | no |
| 16468 | Field Marshal's Chain Spaulders | 4 | 29576 | 60 | no | no |
| 16565 | Warlord's Chain Chestpiece | 4 | 39843 | 60 | no | no |
| 16566 | Warlord's Chain Helmet | 4 | 29991 | 60 | no | no |
| 16567 | General's Chain Legguards | 4 | 34666 | 60 | no | no |
| 16568 | Warlord's Chain Shoulders | 4 | 30341 | 60 | no | no |
| 16569 | General's Chain Sabatons | 4 | 26305 | 60 | no | no |
| 16570 | General's Chain Wristguards | 4 | 13073 | 60 | no | no |
| 16572 | General's Chain Girdle | 4 | 12233 | 60 | no | no |
| 16574 | General's Mail Gauntlets | 4 | 16518 | 60 | no | no |
| 16575 | General's Mail Waistband | 4 | 12373 | 60 | no | no |
| 16576 | General's Mail Bracers | 4 | 12420 | 60 | no | no |
| 16577 | Warlord's Mail Armor | 4 | 38681 | 60 | no | no |
| 16578 | Warlord's Mail Helm | 4 | 29117 | 60 | no | no |
| 16579 | General's Mail Leggings | 4 | 33662 | 60 | no | no |
| 16580 | Warlord's Mail Spaulders | 4 | 29466 | 60 | no | no |
| 16984 | Black Dragonscale Boots | 4 | 32653 | 56 | no | no |
| 16988 | Fiery Chain Shoulders | 4 | 31460 | 57 | no | no |
| 16989 | Fiery Chain Girdle | 4 | 18610 | 54 | no | no |
| 19157 | Chromatic Gauntlets | 4 | 31943 | 60 | no | no |
| 19582 | Windtalker's Wristguards | 4 | 24220 | 60 | no | no |
| 19583 | Windtalker's Wristguards | 4 | 14452 | 50 | no | no |
| 19584 | Windtalker's Wristguards | 4 | 7418 | 40 | no | no |
| 20380 | Dreamscale Breastplate | 4 | 57958 | 60 | no | no |
| 21530 | Onyx Embedded Leggings | 4 | 92311 | 60 | no | no |
| 21584 | Bracers of Eternal Reckoning | 4 | 77194 | 60 | no | no |
| 21588 | Wristguards of Elemental Fury | 4 | 80408 | 60 | no | no |
| 21607 | Grasp of the Fallen Emperor | 4 | 56933 | 60 | no | no |
| 21612 | Wormscale Stompers | 4 | 87308 | 60 | no | no |
| 21624 | Gauntlets of Kalimdor | 4 | 48645 | 60 | no | no |
| 21890 | Gloves of the Fallen Prophet | 4 | 42013 | 60 | no | no |
| 22664 | Icy Scale Breastplate | 4 | 100642 | 60 | no | no |
| 22665 | Icy Scale Bracers | 4 | 50516 | 60 | no | no |
| 22666 | Icy Scale Gauntlets | 4 | 50712 | 60 | no | no |
| 22673 | Outrider's Chain Leggings | 4 | 50092 | 60 | no | no |
| 22676 | Outrider's Mail Leggings | 4 | 50650 | 60 | no | no |
| 22702 | Icy Scale Leggings | 4 | 110409 | 0 | no | no |
| 22748 | Sentinel's Chain Leggings | 4 | 48441 | 60 | no | no |
| 22967 | Icy Scale Spaulders | 4 | 95926 | 0 | no | no |
| 23033 | Icy Scale Coif | 4 | 93164 | 60 | no | no |
| 252603 | Red Dragonscale Leggings | 4 | 0 | 56 | no | no |
| 252604 | Blue Dragonscale Helm | 4 | 0 | 56 | no | no |
| 252605 | Black Dragonscale Helm | 4 | 0 | 56 | no | no |
| 252606 | Pristine Scorpid Leggings | 4 | 0 | 56 | no | no |
| 272397 | Ranger's Belt | 4 | 50000 | 60 | no | no |
| 272399 | Stormseeker's Girdle | 4 | 50000 | 60 | no | no |
| 272402 | Prophet's Waistcord | 4 | 50000 | 60 | no | no |
| 272410 | Windseeker's Belt | 4 | 50000 | 60 | no | no |
| 272535 | Premier Legionnaire's Chain Wristguards | 4 | 0 | 60 | no | no |
| 272537 | Premier Legionnaire's Chain Girdle | 4 | 0 | 60 | no | no |
| 272540 | Premier Legionnaire's Linked Waistband | 4 | 0 | 60 | no | no |
| 272541 | Premier Legionnaire's Linked Bracers | 4 | 0 | 60 | no | no |
| 272770 | Premier Knight-Captain's Chainmail Bracers | 4 | 0 | 60 | no | no |
| 272773 | Premier Knight-Captain's Chainmail Girdle | 4 | 0 | 60 | no | no |
| 273338 | Premier Legionnaire's Mail Waistband | 4 | 0 | 60 | no | no |
| 273339 | Premier Legionnaire's Mail Bracers | 4 | 0 | 60 | no | no |
| 273346 | Premier Legionnaire's Ringmail Waistband | 4 | 0 | 60 | no | no |
| 273347 | Premier Legionnaire's Ringmail Bracers | 4 | 0 | 60 | no | no |
| 274185 | Premier Knight-Captain's Flatmail Waistband | 4 | 0 | 60 | no | no |
| 274186 | Premier Knight-Captain's Flatmail Bracers | 4 | 0 | 60 | no | no |
| 274200 | Premier Knight-Captain's Scalemail Waistband | 4 | 0 | 60 | no | no |
| 274201 | Premier Knight-Captain's Scalemail Bracers | 4 | 0 | 60 | no | no |
| 274208 | Premier Knight-Captain's Linkmail Waistband | 4 | 0 | 60 | no | no |
| 274209 | Premier Knight-Captain's Linkmail Bracers | 4 | 0 | 60 | no | no |
| 279255 | Eternity Pauldrons | 4 | 22503 | 60 | no | no |
| 279256 | Tranquil Wristguards | 4 | 840 | 60 | no | no |
| 279257 | Mourning Handguards | 4 | 17210 | 60 | no | no |

### 4/4 Armadura / Placas, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 8088 | Platemail Belt | 1 | 2667 | 45 | no | no |
| 8089 | Platemail Boots | 1 | 4016 | 45 | no | no |
| 8090 | Platemail Bracers | 1 | 2687 | 45 | no | no |
| 8091 | Platemail Gloves | 1 | 2697 | 45 | no | no |
| 8092 | Platemail Helm | 1 | 4062 | 45 | no | no |
| 8093 | Platemail Leggings | 1 | 5437 | 45 | no | no |
| 8094 | Platemail Armor | 1 | 5458 | 45 | no | no |
| 12187 | Test Defense Chest | 1 | 10390 | 55 | no | no |
| 12188 | Test Armor Chest | 1 | 10425 | 55 | no | no |
| 12189 | Test Strength Chest | 1 | 9466 | 55 | no | no |
| 12244 | Test Agility Chest | 1 | 9488 | 55 | no | no |
| 12245 | Test Spirit Chest | 1 | 9488 | 55 | no | no |
| 13586 | Test Crit Chest | 1 | 9488 | 55 | no | no |
| 13710 | Test Stamina Chest | 1 | 9488 | 55 | no | no |
| 13711 | Test Attack Power Chest | 1 | 9488 | 55 | no | no |
| 13712 | Test Sword Chest | 1 | 9488 | 55 | no | no |
| 13713 | Test Dodge Chest | 1 | 9488 | 55 | no | no |
| 13714 | Test Parry Chest | 1 | 9488 | 55 | no | no |
| 13715 | Test Block Chest | 1 | 9488 | 55 | no | no |
| 13716 | Test Haste Chest | 1 | 9652 | 55 | no | no |
| 13717 | Test Hit Chance Chest | 1 | 9488 | 55 | no | no |
| 13734 | [PH] Rising Dawn Gauntlets | 1 | 1 | 1 | no | no |
| 13796 | [PH] Rising Dawn Helm | 1 | 1 | 1 | no | no |
| 16026 | PVP Plate Helm Alliance | 1 | 7160 | 0 | no | no |
| 16027 | PVP Plate Breastplate Alliance | 1 | 9488 | 0 | no | no |
| 16028 | PVP Plate Legplates Alliance | 1 | 9488 | 0 | no | no |
| 16029 | PVP Plate Gauntlets Alliance | 1 | 4828 | 0 | no | no |
| 16030 | PVP Plate Boots Alliance | 1 | 7270 | 0 | no | no |
| 16031 | PVP Plate Shoulder Alliance | 1 | 7297 | 0 | no | no |
| 16033 | PVP Plate Wrist Alliance | 1 | 4901 | 0 | no | no |
| 16035 | PVP Cloth Helm Horde | 1 | 7407 | 0 | no | no |
| 16038 | PVP Cloth Shoulder Horde | 1 | 7116 | 0 | no | no |
| 16211 | Test Quality Modifier Chest | 1 | 9488 | 55 | no | no |
| 16213 | Test Quality Modifier Chest | 1 | 9488 | 55 | no | no |

### 4/4 Armadura / Placas, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 7918 | Heavy Mithril Shoulder | 2 | 3701 | 40 | no | no |
| 7919 | Heavy Mithril Gauntlet | 2 | 2476 | 40 | no | no |
| 7921 | Heavy Mithril Pants | 2 | 5387 | 40 | no | no |
| 7922 | Steel Plate Helm | 2 | 1944 | 40 | no | no |
| 7926 | Ornate Mithril Pants | 2 | 5952 | 40 | no | no |
| 7927 | Ornate Mithril Gloves | 2 | 2987 | 40 | no | no |
| 7928 | Ornate Mithril Shoulders | 2 | 4857 | 40 | no | no |
| 7930 | Heavy Mithril Breastplate | 2 | 7045 | 41 | no | no |
| 7933 | Heavy Mithril Boots | 2 | 5769 | 42 | no | no |
| 7934 | Heavy Mithril Helm | 2 | 5790 | 42 | no | no |
| 7935 | Ornate Mithril Breastplate | 2 | 8368 | 43 | no | no |
| 7937 | Ornate Mithril Helm | 2 | 6763 | 44 | no | no |
| 9637 | Shinkicker Boots | 2 | 4749 | 0 | no | no |
| 9646 | Gnomish Water Sinking Device | 2 | 6791 | 0 | no | no |
| 9656 | Granite Grips | 2 | 4251 | 0 | no | no |
| 9662 | Rushridge Boots | 2 | 4258 | 0 | no | no |
| 9664 | Sentinel's Guard | 2 | 5002 | 0 | no | no |
| 10384 | Hyperion Armor | 2 | 20370 | 60 | no | no |
| 10707 | Steelsmith Greaves | 2 | 7772 | 0 | no | no |
| 10740 | Centurion Legplates | 2 | 10692 | 0 | no | no |
| 10746 | Runesteel Vambraces | 2 | 4549 | 0 | no | no |
| 11195 | Warforged Chestplate | 2 | 13655 | 0 | no | no |
| 11605 | Dark Iron Shoulders | 2 | 10776 | 53 | no | no |
| 11872 | Eschewal Greaves | 2 | 8566 | 0 | no | no |
| 11889 | Bark Iron Pauldrons | 2 | 7345 | 0 | no | no |
| 11910 | Bejeweled Legguards | 2 | 12345 | 0 | no | no |
| 11919 | Cragplate Greaves | 2 | 9572 | 0 | no | no |
| 12106 | Boulderskin Breastplate | 2 | 16824 | 0 | no | no |
| 12405 | Thorium Armor | 2 | 9239 | 45 | no | no |
| 12406 | Thorium Belt | 2 | 4636 | 45 | no | no |
| 12408 | Thorium Bracers | 2 | 4998 | 46 | no | no |
| 12409 | Thorium Boots | 2 | 10336 | 51 | no | no |
| 12410 | Thorium Helm | 2 | 10372 | 51 | no | no |
| 12414 | Thorium Leggings | 2 | 17376 | 55 | no | no |
| 12610 | Runic Plate Shoulders | 2 | 12247 | 55 | no | no |
| 12611 | Runic Plate Boots | 2 | 12293 | 55 | no | no |
| 12612 | Runic Plate Helm | 2 | 12956 | 56 | no | no |
| 12613 | Runic Breastplate | 2 | 18205 | 57 | no | no |
| 12614 | Runic Plate Leggings | 2 | 18272 | 57 | no | no |
| 14864 | Warleader's Belt | 2 | 7602 | 54 | no | no |
| 15709 | Gearforge Girdle | 2 | 7270 | 0 | no | no |
| 15795 | Emerald Mist Gauntlets | 2 | 7631 | 0 | no | no |
| 15797 | Shining Armplates | 2 | 7530 | 0 | no | no |
| 16160 | Test Arcane Res Shoulders Plate | 2 | 3155 | 40 | no | no |
| 16161 | Test Shadow Res Hands Plate | 2 | 2103 | 40 | no | no |
| 17688 | Jungle Boots | 2 | 3155 | 0 | no | no |
| 19037 | Emerald Peak Spaulders | 2 | 5877 | 0 | no | no |
| 19117 | Laquered Wooden Plate Legplates | 2 | 8915 | 0 | no | no |
| 19124 | Slagplate Leggings | 2 | 8259 | 0 | no | no |
| 19126 | Slagplate Gauntlets | 2 | 4451 | 0 | no | no |
| 20239 | 90 Green Warrior Bracelets | 2 | 34271 | 60 | no | no |
| 20240 | 90 Green Warrior Breastplate | 2 | 68808 | 60 | no | no |
| 20242 | 90 Green Warrior Gauntlets | 2 | 34665 | 60 | no | no |
| 20246 | 90 Green Warrior Helm | 2 | 52788 | 60 | no | no |
| 20247 | 90 Green Warrior Legplates | 2 | 70650 | 60 | no | no |
| 20249 | 90 Green Warrior Pauldrons | 2 | 53380 | 60 | no | no |
| 20251 | 90 Green Warrior Sabatons | 2 | 53777 | 60 | no | no |
| 20252 | 90 Green Warrior Waistband | 2 | 36933 | 60 | no | no |
| 20281 | 63 Green Warrior Bracelets | 2 | 9247 | 58 | no | no |
| 20282 | 63 Green Warrior Breastplate | 2 | 18566 | 58 | no | no |
| 20284 | 63 Green Warrior Gauntlets | 2 | 9607 | 58 | no | no |
| 20286 | 63 Green Warrior Helm | 2 | 14518 | 58 | no | no |
| 20287 | 63 Green Warrior Legplates | 2 | 19426 | 58 | no | no |
| 20289 | 63 Green Warrior Pauldrons | 2 | 14676 | 58 | no | no |
| 20291 | 63 Green Warrior Sabatons | 2 | 14781 | 58 | no | no |
| 20292 | 63 Green Warrior Waistband | 2 | 9889 | 58 | no | no |
| 20640 | Southsea Head Bucket | 2 | 4812 | 0 | no | no |
| 20650 | Desert Wind Gauntlets | 2 | 8511 | 0 | no | no |
| 21316 | Leggings of the Ursa | 2 | 12407 | 0 | no | no |
| 21322 | Ursa's Embrace | 2 | 15108 | 0 | no | no |
| 250540 | Shining Mithril Breastplate | 2 | 11586 | 40 | no | no |
| 250541 | Shining Mithril Pauldrons | 2 | 8704 | 40 | no | no |
| 250542 | Shining Mithril Boots | 2 | 8110 | 40 | no | no |
| 250543 | Shining Mithril Helm | 2 | 10255 | 43 | no | no |
| 250544 | Shining Mithril Pants | 2 | 14716 | 44 | no | no |
| 250545 | Shining Mithril Gauntlet | 2 | 7428 | 44 | no | no |
| 260178 | Honor Guard's Plate | 2 | 10251 | 0 | no | no |
| 260181 | Sentinel's Plate | 2 | 10251 | 0 | no | no |
| 269502 | Dwarven Plate | 2 | 22519 | 53 | no | no |
| 270096 | Rebel Breastplate | 2 | 8438 | 0 | no | no |
| 270105 | Protector's Armguards | 2 | 3988 | 0 | no | no |
| 274718 | Lost Veteran's Sabatons | 2 | 19541 | 0 | no | no |
| 274750 | Reflective Wristguards | 2 | 5487 | 40 | no | no |
| 274758 | Coldmetal Guard | 2 | 21912 | 50 | no | no |
| 275438 | Greaves of Mourning | 2 | 19681 | 0 | no | no |
| 276200 | Crawler's Clackers | 2 | 5487 | 40 | no | no |
| 276341 | Plaguecrusher Greaves | 2 | 20130 | 0 | no | no |
| 277235 | Soldier's Visor | 2 | 0 | 0 | no | no |
| 277237 | Inspiring Chestplate | 2 | 0 | 40 | no | no |
| 277238 | Shimmering Bracers | 2 | 0 | 40 | no | no |
| 277239 | Bejeweled Punchers | 2 | 0 | 40 | no | no |
| 277240 | Gilded Plate Belt | 2 | 0 | 40 | no | no |
| 277241 | Double-Plated Legplates | 2 | 0 | 40 | no | no |
| 277242 | Silverrune Greaves | 2 | 0 | 40 | no | no |
| 281259 | Stonard Stompers | 2 | 0 | 0 | no | no |
| 281278 | Shoulderplates of Scaleslaying | 2 | 0 | 0 | no | no |
| 281279 | Hailgiant's Fists | 2 | 0 | 0 | no | no |
| 281301 | Sacrificial Shackles | 2 | 0 | 0 | no | no |
| 281317 | Redstone Boots | 2 | 0 | 0 | no | no |
| 281709 | Restored Plate Helm | 2 | 1 | 1 | no | no |
| 281710 | Restored Plate Shoulders | 2 | 1 | 1 | no | no |
| 281711 | Restored Plate Chestguard | 2 | 1 | 1 | no | no |
| 281712 | Restored Plate Wristguards | 2 | 1 | 1 | no | no |
| 281713 | Restored Plate Handguards | 2 | 1 | 1 | no | no |
| 281714 | Restored Plate Belt | 2 | 1 | 1 | no | no |
| 281715 | Restored Plate Legs | 2 | 1 | 1 | no | no |
| 281716 | Restored Plate Boots | 2 | 1 | 1 | no | no |

### 4/4 Armadura / Placas, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 7938 | Truesilver Gauntlets | 3 | 4028 | 40 | no | no |
| 11604 | Dark Iron Plate | 3 | 19428 | 54 | no | no |
| 12021 | Shieldplate Sabatons | 3 | 9327 | 0 | no | no |
| 12618 | Enchanted Thorium Breastplate | 3 | 23972 | 58 | no | no |
| 12619 | Enchanted Thorium Leggings | 3 | 24058 | 58 | no | no |
| 12620 | Enchanted Thorium Helm | 3 | 17245 | 57 | no | no |
| 12625 | Dawnbringer Shoulders | 3 | 13080 | 53 | no | no |
| 12633 | Whitesoul Helm | 3 | 14859 | 55 | no | no |
| 12970 | General's Ceremonial Plate | 3 | 22768 | 58 | no | no |
| 16404 | Knight-Captain's Plate Wristguards | 3 | 4754 | 55 | no | no |
| 16405 | Knight-Lieutenant's Plate Boots | 3 | 8286 | 58 | no | no |
| 16407 | Knight-Captain's Plate Girdle | 3 | 4809 | 55 | no | no |
| 16409 | Knight-Lieutenant's Lamellar Sabatons | 3 | 8413 | 58 | no | no |
| 16411 | Knight-Captain's Lamellar Cinch | 3 | 5013 | 55 | no | no |
| 16412 | Knight-Captain's Lamellar Armsplints | 3 | 5031 | 55 | no | no |
| 16429 | Lieutenant Commander's Plate Helm | 3 | 8641 | 58 | no | no |
| 16430 | Knight-Captain's Plate Chestguard | 3 | 11564 | 58 | no | no |
| 16431 | Knight-Captain's Plate Leggings | 3 | 11606 | 58 | no | no |
| 16432 | Lieutenant Commander's Plate Pauldrons | 3 | 8736 | 58 | no | no |
| 16433 | Knight-Captain's Lamellar Breastplate | 3 | 11691 | 58 | no | no |
| 16434 | Lieutenant Commander's Lamellar Headguard | 3 | 8800 | 58 | no | no |
| 16435 | Knight-Captain's Lamellar Leggings | 3 | 11775 | 58 | no | no |
| 16436 | Lieutenant Commander's Lamellar Shoulders | 3 | 8863 | 58 | no | no |
| 16509 | Blood Guard's Plate Boots | 3 | 8866 | 58 | no | no |
| 16511 | Legionnaire's Plate Cinch | 3 | 5142 | 55 | no | no |
| 16512 | Legionnaire's Plate Bracers | 3 | 5160 | 55 | no | no |
| 16513 | Legionnaire's Plate Armor | 3 | 11991 | 58 | no | no |
| 16514 | Champion's Plate Headguard | 3 | 9024 | 58 | no | no |
| 16515 | Legionnaire's Plate Legguards | 3 | 12075 | 58 | no | no |
| 16516 | Champion's Plate Pauldrons | 3 | 8223 | 58 | no | no |
| 18429 | First Sergeant's Plate Bracers | 3 | 5889 | 58 | no | no |
| 18430 | First Sergeant's Plate Bracers | 3 | 2878 | 45 | no | no |
| 18445 | Sergeant Major's Plate Wristguards | 3 | 5804 | 58 | no | no |
| 18447 | Sergeant Major's Plate Wristguards | 3 | 2847 | 45 | no | no |
| 19051 | Girdle of the Dawn | 3 | 9365 | 53 | no | no |
| 19057 | Gloves of the Dawn | 3 | 11606 | 56 | no | no |
| 19087 | Frostwolf Plate Belt | 3 | 10176 | 55 | no | no |
| 19091 | Stormpike Plate Girdle | 3 | 9488 | 55 | no | no |
| 20106 | Highlander's Lamellar Girdle | 3 | 6946 | 48 | no | no |
| 20107 | Highlander's Lamellar Girdle | 3 | 3201 | 40 | no | no |
| 20124 | Highlander's Plate Girdle | 3 | 7075 | 48 | no | no |
| 20125 | Highlander's Plate Girdle | 3 | 3176 | 40 | no | no |
| 20177 | Defiler's Lamellar Girdle | 3 | 11783 | 58 | no | no |
| 20179 | Defiler's Lamellar Girdle | 3 | 6948 | 48 | no | no |
| 20180 | Defiler's Lamellar Girdle | 3 | 3448 | 40 | no | no |
| 20205 | Defiler's Plate Girdle | 3 | 6599 | 48 | no | no |
| 20206 | Defiler's Plate Girdle | 3 | 3275 | 40 | no | no |
| 20213 | Belt of Shrunken Heads | 3 | 16337 | 0 | no | no |
| 20549 | Darkrune Gauntlets | 3 | 11484 | 58 | no | no |
| 20550 | Darkrune Breastplate | 3 | 23051 | 58 | no | no |
| 20551 | Darkrune Helm | 3 | 17352 | 58 | no | no |
| 20699 | Cenarion Reservist's Legplates | 3 | 22708 | 0 | no | no |
| 20700 | Cenarion Reservist's Legplates | 3 | 21968 | 0 | no | no |
| 20710 | Crystal Encrusted Greaves | 3 | 16457 | 0 | no | no |
| 20711 | Crystal Lined Greaves | 3 | 16521 | 0 | no | no |
| 22197 | Heavy Obsidian Belt | 3 | 14282 | 60 | no | no |
| 250546 | Officer's Boots | 3 | 4966 | 40 | no | no |
| 250547 | Sentinel's Boots | 3 | 5016 | 40 | no | no |
| 250548 | Warder's Boots | 3 | 5016 | 40 | no | no |
| 250549 | Prefect's Boots | 3 | 5016 | 40 | no | no |
| 250550 | Justicar's Boots | 3 | 5016 | 40 | no | no |
| 250551 | Officer's Gloves | 3 | 6687 | 50 | no | no |
| 250552 | Sentinel's Gloves | 3 | 6620 | 50 | no | no |
| 250553 | Warder's Gloves | 3 | 6620 | 50 | no | no |
| 250554 | Prefect's Gloves | 3 | 6620 | 50 | no | no |
| 250555 | Justicar's Gloves | 3 | 6754 | 50 | no | no |
| 250561 | Officer's Sabatons | 3 | 15856 | 47 | no | no |
| 250562 | Sentinel's Sabatons | 3 | 15918 | 47 | no | no |
| 250563 | Warder's Sabatons | 3 | 15979 | 47 | no | no |
| 250564 | Prefect's Sabatons | 3 | 16041 | 47 | no | no |
| 250565 | Justicar's Sabatons | 3 | 16101 | 47 | no | no |
| 250571 | Officer's Waistguard | 3 | 13177 | 50 | no | no |
| 250572 | Sentinel's Waistguard | 3 | 13225 | 50 | no | no |
| 250573 | Warder's Waistguard | 3 | 13274 | 50 | no | no |
| 250574 | Prefect's Waistguard | 3 | 13677 | 50 | no | no |
| 250575 | Justicar's Waistguard | 3 | 13726 | 50 | no | no |
| 250576 | Officer's Pauldrons | 3 | 12276 | 42 | no | no |
| 250577 | Sentinel's Pauldrons | 3 | 12320 | 42 | no | no |
| 250578 | Warder's Pauldrons | 3 | 12364 | 42 | no | no |
| 250579 | Prefect's Pauldrons | 3 | 12408 | 42 | no | no |
| 250580 | Justicar's Pauldrons | 3 | 12450 | 42 | no | no |
| 250581 | Officer's Wristguards | 3 | 9390 | 45 | no | no |
| 250582 | Sentinel's Wristguards | 3 | 9426 | 45 | no | no |
| 250583 | Warder's Wristguards | 3 | 9462 | 45 | no | no |
| 250584 | Prefect's Wristguards | 3 | 9498 | 45 | no | no |
| 250585 | Justicar's Wristguards | 3 | 9535 | 45 | no | no |
| 250595 | Enriched Thorium Breastplate | 3 | 39509 | 57 | no | no |
| 250596 | Enriched Thorium Leggings | 3 | 41634 | 58 | no | no |
| 250597 | Enriched Thorium Helm | 3 | 31277 | 58 | no | no |
| 260184 | Cliff Walker's Cinch | 3 | 5061 | 0 | no | no |
| 272187 | Thornplated Cord | 3 | 7777 | 1 | no | no |
| 272579 | Premier Mortarplate Bracers | 3 | 0 | 55 | no | no |
| 272580 | First Sergeant's Plate Bracers | 3 | 2878 | 45 | no | no |
| 272720 | Premier Chevalier Cinch | 3 | 0 | 55 | no | no |
| 272721 | Premier Chevalier Armsplints | 3 | 0 | 55 | no | no |
| 272828 | Premier Plate Wristguards | 3 | 0 | 55 | no | no |
| 273324 | Premier Mortarplate Girdle | 3 | 0 | 55 | no | no |
| 273325 | Premier Plate Girdle | 3 | 0 | 55 | no | no |
| 273364 | Premier Luminous Armsplints | 3 | 0 | 55 | no | no |
| 273366 | Premier Luminous Cinch | 3 | 0 | 55 | no | no |
| 274228 | Premier Scaled Cinch | 3 | 0 | 55 | no | no |
| 274229 | Premier Scaled Armsplints | 3 | 0 | 55 | no | no |
| 274257 | Premier Lamellar Armsplints | 3 | 0 | 55 | no | no |
| 274259 | Premier Lamellar Cinch | 3 | 0 | 55 | no | no |
| 275622 | Goregasher Grips | 3 | 15752 | 53 | no | no |
| 275623 | Goregasher Support | 3 | 15809 | 53 | no | no |
| 275624 | Goregasher Stompers | 3 | 23622 | 53 | no | no |
| 275625 | Clutchlord's Grips | 3 | 15927 | 53 | no | no |
| 275626 | Clutchlord's Support | 3 | 15986 | 53 | no | no |
| 275627 | Clutchlord's Stompers | 3 | 23882 | 53 | no | no |
| 277236 | Pauldrons of Vindication | 3 | 0 | 0 | no | no |

### 4/4 Armadura / Placas, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 12640 | Lionheart Helm | 4 | 21894 | 56 | no | no |
| 16469 | Marshal's Lamellar Armguards | 4 | 8466 | 60 | no | no |
| 16470 | Marshal's Lamellar Belt | 4 | 8497 | 60 | no | no |
| 16472 | Marshal's Lamellar Boots | 4 | 17205 | 60 | no | no |
| 16473 | Field Marshal's Lamellar Chestplate | 4 | 26654 | 60 | no | no |
| 16474 | Field Marshal's Lamellar Faceguard | 4 | 20063 | 60 | no | no |
| 16475 | Marshal's Lamellar Legplates | 4 | 23793 | 60 | no | no |
| 16476 | Field Marshal's Lamellar Pauldrons | 4 | 18757 | 60 | no | no |
| 16477 | Field Marshal's Plate Armor | 4 | 25107 | 60 | no | no |
| 16478 | Field Marshal's Plate Helm | 4 | 18903 | 60 | no | no |
| 16479 | Marshal's Plate Legguards | 4 | 21856 | 60 | no | no |
| 16480 | Field Marshal's Plate Shoulderguards | 4 | 19047 | 60 | no | no |
| 16481 | Marshal's Plate Bracers | 4 | 8216 | 60 | no | no |
| 16482 | Marshal's Plate Girdle | 4 | 8247 | 60 | no | no |
| 16483 | Marshal's Plate Boots | 4 | 16642 | 60 | no | no |
| 16541 | Warlord's Plate Armor | 4 | 26178 | 60 | no | no |
| 16542 | Warlord's Plate Headpiece | 4 | 19707 | 60 | no | no |
| 16543 | General's Plate Leggings | 4 | 22782 | 60 | no | no |
| 16544 | Warlord's Plate Shoulders | 4 | 19850 | 60 | no | no |
| 16545 | General's Plate Boots | 4 | 17210 | 60 | no | no |
| 16546 | General's Plate Armguards | 4 | 8593 | 60 | no | no |
| 16547 | General's Plate Girdle | 4 | 8624 | 60 | no | no |
| 17013 | Dark Iron Leggings | 4 | 26441 | 55 | no | no |
| 17014 | Dark Iron Bracers | 4 | 12637 | 54 | no | no |
| 19148 | Dark Iron Helm | 4 | 25399 | 60 | no | no |
| 19164 | Dark Iron Gauntlets | 4 | 22425 | 60 | no | no |
| 19578 | Berserker Bracers | 4 | 17699 | 60 | no | no |
| 19580 | Berserker Bracers | 4 | 9635 | 50 | no | no |
| 19581 | Berserker Bracers | 4 | 4945 | 40 | no | no |
| 20039 | Dark Iron Boots | 4 | 31709 | 60 | no | no |
| 20135 | 90 Epic Warrior Bracelets | 4 | 56732 | 60 | no | no |
| 20136 | 90 Epic Warrior Breastplate | 4 | 113877 | 60 | no | no |
| 20137 | 90 Epic Warrior Gauntlets | 4 | 57150 | 60 | no | no |
| 20138 | 90 Epic Warrior Helm | 4 | 86044 | 60 | no | no |
| 20139 | 90 Epic Warrior Legplates | 4 | 115150 | 60 | no | no |
| 20140 | 90 Epic Warrior Pauldrons | 4 | 88950 | 60 | no | no |
| 20141 | 90 Epic Warrior Sabatons | 4 | 89269 | 60 | no | no |
| 20142 | 90 Epic Warrior Waistband | 4 | 59724 | 60 | no | no |
| 20184 | Defiler's Lamellar Spaulders | 4 | 26635 | 60 | no | no |
| 20639 | Strangely Glyphed Legplates | 4 | 46989 | 60 | no | no |
| 21184 | Deeprock Bracers | 4 | 14425 | 0 | no | no |
| 21581 | Gauntlets of Annihilation | 4 | 50891 | 60 | no | no |
| 21587 | Wristguards of Castigation | 4 | 53413 | 60 | no | no |
| 21598 | Royal Qiraji Belt | 4 | 35753 | 60 | no | no |
| 21606 | Belt of the Fallen Emperor | 4 | 37819 | 60 | no | no |
| 21618 | Hive Defiler Wristguards | 4 | 31727 | 60 | no | no |
| 21623 | Gauntlets of the Righteous Champion | 4 | 32315 | 60 | no | no |
| 21639 | Pauldrons of the Unrelenting | 4 | 45485 | 60 | no | no |
| 21667 | Legplates of Blazing Light | 4 | 55193 | 60 | no | no |
| 21674 | Gauntlets of Steadfast Determination | 4 | 28340 | 60 | no | no |
| 22385 | Titanic Leggings | 4 | 25276 | 55 | no | no |
| 22651 | Outrider's Plate Legguards | 4 | 33147 | 60 | no | no |
| 22669 | Icebane Breastplate | 4 | 68390 | 60 | no | no |
| 22670 | Icebane Gauntlets | 4 | 34321 | 60 | no | no |
| 22671 | Icebane Bracers | 4 | 34452 | 60 | no | no |
| 22672 | Sentinel's Plate Legguards | 4 | 33269 | 60 | no | no |
| 22699 | Icebane Leggings | 4 | 72832 | 0 | no | no |
| 22753 | Sentinel's Lamellar Legguards | 4 | 34271 | 60 | no | no |
| 22940 | Icebane Pauldrons | 4 | 62103 | 60 | no | no |
| 23019 | Icebane Helmet | 4 | 63466 | 60 | no | no |
| 23034 | Nax PH Crit Plate Shoulders | 4 | 58290 | 60 | no | no |
| 213391 | UNUSED Electrified Mithril Gauntlets | 4 | 4028 | 40 | no | no |
| 250598 | Champion's Legplates | 4 | 50706 | 56 | no | no |
| 250599 | Stalwart Helm | 4 | 38092 | 56 | no | no |
| 250600 | Martyr's Legplates | 4 | 51067 | 56 | no | no |
| 250601 | Breastplate of Salvation | 4 | 46368 | 56 | no | no |
| 271940 | Theramore Gauntlets | 4 | 30313 | 60 | no | no |
| 271941 | Theramore Gauntlets | 4 | 18152 | 50 | no | no |
| 272095 | Raider Gauntlets | 4 | 30313 | 60 | no | no |
| 272096 | Raider Gauntlets | 4 | 18152 | 50 | no | no |
| 272403 | Valiant's Waistguard | 4 | 50000 | 60 | no | no |
| 272404 | Vindicator's Belt | 4 | 50000 | 60 | no | no |
| 272405 | Redeemer's Waistcord | 4 | 50000 | 60 | no | no |
| 272511 | Premier Legionnaire's Mortarplate Armguards | 4 | 0 | 60 | no | no |
| 272512 | Premier Legionnaire's Mortarplate Girdle | 4 | 0 | 60 | no | no |
| 272778 | Premier Knight-Captain's Chevalier Armguards | 4 | 0 | 60 | no | no |
| 272779 | Premier Knight-Captain's Chevalier Belt | 4 | 0 | 60 | no | no |
| 272790 | Premier Knight-Captain's Plate Bracers | 4 | 0 | 60 | no | no |
| 272791 | Premier Knight-Captain's Plate Girdle | 4 | 0 | 60 | no | no |
| 273327 | Premier Knight-Captain's Luminous Armguards | 4 | 0 | 60 | no | no |
| 273328 | Premier Knight-Captain's Luminous Belt | 4 | 0 | 60 | no | no |
| 274234 | Premier Legionnaire's Scaled Armguards | 4 | 0 | 60 | no | no |
| 274235 | Premier Legionnaire's Scaled Belt | 4 | 0 | 60 | no | no |
| 274248 | Premier Legionnaire's Lamellar Armguards | 4 | 0 | 60 | no | no |
| 274249 | Premier Legionnaire's Lamellar Belt | 4 | 0 | 60 | no | no |
| 279263 | Depleted Thorium Sabatons | 4 | 13732 | 60 | no | no |
| 279264 | Heavy Thorium Gauntlets | 4 | 13149 | 60 | no | no |
| 279265 | Azerothium Legplates | 4 | 13732 | 60 | no | no |

### 4/5 Armadura / Cosmética, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6833 | White Tuxedo Shirt | 1 | 500 | 0 | no | no |
| 6835 | Black Tuxedo Pants | 1 | 504 | 0 | no | no |
| 21154 | Festival Dress | 1 | 1 | 0 | no | no |
| 21157 | Festive Green Dress | 1 | 1250 | 0 | no | no |
| 21538 | Festive Pink Dress | 1 | 1250 | 0 | no | no |
| 21539 | Festive Purple Dress | 1 | 1250 | 0 | no | no |
| 21541 | Festive Black Pant Suit | 1 | 1250 | 0 | no | no |
| 21542 | Festival Suit | 1 | 1 | 0 | no | no |
| 21543 | Festive Teal Pant Suit | 1 | 1250 | 0 | no | no |
| 21544 | Festive Blue Pant Suit | 1 | 1250 | 0 | no | no |
| 34085 | Red Winter Clothes | 1 | 7 | 0 | no | no |
| 34086 | Winter Boots | 1 | 1 | 0 | no | no |
| 34087 | Green Winter Clothes | 1 | 7 | 0 | no | no |
| 135510 | Transmog UI Trim Head Item | 1 | 1 | 1 | no | no |
| 135522 | Transmog UI Chest Item | 1 | 1 | 1 | no | no |
| 135548 | Transmog UI Legs Item | 1 | 1 | 1 | no | no |
| 135549 | Transmog UI Hand Item | 1 | 1 | 1 | no | no |
| 135550 | Transmog UI Feet Item | 1 | 1 | 1 | no | no |
| 244228 | Sash of the Tipsy Sage | 1 | 3 | 1 | no | no |
| 244229 | Angler's Mantle | 1 | 3 | 1 | no | no |
| 244230 | Strawhat of Frosted Currents | 1 | 3 | 1 | no | no |
| 244352 | Cloak of the Veiled Paws | 1 | 3 | 1 | no | no |
| 271722 | Shen'dorei Magister's Belt | 1 | 0 | 1 | no | no |
| 271723 | Shen'dorei Magister's Boots | 1 | 0 | 1 | no | no |
| 271724 | Shen'dorei Magister's Cloak | 1 | 0 | 1 | no | no |
| 271725 | Shen'dorei Magister's Robe | 1 | 0 | 1 | no | no |
| 271726 | Shen'dorei Magister's Gloves | 1 | 0 | 1 | no | no |
| 271727 | Shen'dorei Magister's Helm | 1 | 0 | 1 | no | no |
| 271728 | Shen'dorei Magister's Leggings | 1 | 0 | 1 | no | no |
| 271729 | Shen'dorei Magister's Vest | 1 | 0 | 1 | no | no |
| 271730 | Shen'dorei Magister's Pauldrons | 1 | 0 | 1 | no | no |
| 271733 | Shen'dorei Peacekeeper's Belt | 1 | 0 | 1 | no | no |
| 271734 | Shen'dorei Peacekeeper's Boots | 1 | 0 | 1 | no | no |
| 271735 | Shen'dorei Peacekeeper's Cloak | 1 | 0 | 1 | no | no |
| 271736 | Shen'dorei Peacekeeper's Robe | 1 | 0 | 1 | no | no |
| 271737 | Shen'dorei Peacekeeper's Gloves | 1 | 0 | 1 | no | no |
| 271738 | Shen'dorei Peacekeeper's Helm | 1 | 0 | 1 | no | no |
| 271739 | Shen'dorei Peacekeeper's Leggings | 1 | 0 | 1 | no | no |
| 271742 | Shen'dorei Peacekeeper's Vest | 1 | 0 | 1 | no | no |
| 271743 | Shen'dorei Peacekeeper's Pauldrons | 1 | 0 | 1 | no | no |
| 271746 | Shen'dorei Skyseer's Belt | 1 | 0 | 1 | no | no |
| 271747 | Shen'dorei Skyseer's Boots | 1 | 0 | 1 | no | no |
| 271748 | Shen'dorei Skyseer's Cloak | 1 | 0 | 1 | no | no |
| 271749 | Shen'dorei Skyseer's Robe | 1 | 0 | 1 | no | no |
| 271750 | Shen'dorei Skyseer's Gloves | 1 | 0 | 1 | no | no |
| 271751 | Shen'dorei Skyseer's Helm | 1 | 0 | 1 | no | no |
| 271752 | Shen'dorei Skyseer's Leggings | 1 | 0 | 1 | no | no |
| 271753 | Shen'dorei Skyseer's Vest | 1 | 0 | 1 | no | no |
| 271754 | Shen'dorei Skyseer's Pauldrons | 1 | 0 | 1 | no | no |
| 271756 | Al'Aketh Zealot's Belt | 1 | 0 | 1 | no | no |
| 271757 | Al'Aketh Zealot's Boots | 1 | 0 | 1 | no | no |
| 271758 | Al'Aketh Zealot's Cloak | 1 | 0 | 1 | no | no |
| 271759 | Al'Aketh Zealot's Robe | 1 | 0 | 1 | no | no |
| 271760 | Al'Aketh Zealot's Gloves | 1 | 0 | 1 | no | no |
| 271761 | Al'Aketh Zealot's Helm | 1 | 0 | 1 | no | no |
| 271762 | Al'Aketh Zealot's Leggings | 1 | 0 | 1 | no | no |
| 271763 | Al'Aketh Zealot's Vest | 1 | 0 | 1 | no | no |
| 271764 | Al'Aketh Zealot's Pauldrons | 1 | 0 | 1 | no | no |
| 279173 | Veteran Adventurer's Chestpiece | 1 | 2 | 1 | no | no |
| 279174 | Veteran Adventurer's Belt | 1 | 2 | 1 | no | no |
| 279175 | Veteran Adventurer's Legguards | 1 | 2 | 1 | no | no |
| 279176 | Veteran Adventurer's Boots | 1 | 2 | 1 | no | no |
| 279177 | Veteran Adventurer's Bracer | 1 | 2 | 1 | no | no |
| 279178 | Veteran Adventurer's Gloves | 1 | 2 | 1 | no | no |
| 279179 | Veteran Adventurer's Cloak | 1 | 2 | 1 | no | no |
| 279180 | Veteran Adventurer's Hood | 1 | 2 | 1 | no | no |
| 279181 | Veteran Adventurer's Shoulderpads | 1 | 3 | 1 | no | no |
| 280404 | Lordaeron Forever Tabard | 1 | 0 | 1 | no | no |
| 280623 | Veteran Adventurer's Rucksack | 1 | 2 | 1 | no | no |
| 280729 | Shen'dorei Tabard | 1 | 1 | 1 | no | no |

### 4/5 Armadura / Cosmética, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 20583 | Sturdy Female Dwarf Mask | 2 | 4738 | 0 | no | no |
| 20584 | Sturdy Female Gnome Mask | 2 | 4756 | 0 | no | no |
| 20585 | Sturdy Female Human Mask | 2 | 4774 | 0 | no | no |
| 20586 | Sturdy Female Night Elf Mask | 2 | 4792 | 0 | no | no |
| 20587 | Sturdy Female Orc Mask | 2 | 4810 | 0 | no | no |
| 20588 | Sturdy Female Tauren Mask | 2 | 4827 | 0 | no | no |
| 20589 | Sturdy Female Troll Mask | 2 | 4845 | 0 | no | no |
| 20590 | Sturdy Female Undead Mask | 2 | 4992 | 0 | no | no |
| 20591 | Sturdy Male Dwarf Mask | 2 | 5010 | 0 | no | no |
| 20592 | Sturdy Male Gnome Mask | 2 | 5028 | 0 | no | no |
| 20593 | Sturdy Male Human Mask | 2 | 5046 | 0 | no | no |
| 20594 | Sturdy Male Night Elf Mask | 2 | 5064 | 0 | no | no |
| 20595 | Sturdy Male Orc Mask | 2 | 5082 | 0 | no | no |
| 20596 | Sturdy Male Tauren Mask | 2 | 5099 | 0 | no | no |
| 20597 | Sturdy Male Troll Mask | 2 | 4631 | 0 | no | no |
| 20598 | Sturdy Male Undead Mask | 2 | 4649 | 0 | no | no |
| 22742 | Bloodsail Shirt | 2 | 6250 | 1 | no | no |
| 22743 | Bloodsail Sash | 2 | 6250 | 1 | no | no |
| 22744 | Bloodsail Boots | 2 | 6250 | 1 | no | no |
| 22745 | Bloodsail Pants | 2 | 6250 | 1 | no | no |
| 44803 | Spring Circlet | 2 | 50 | 0 | no | no |
| 49715 | Forever-Lovely Rose | 2 | 0 | 0 | no | no |
| 134110 | Hidden Helm | 2 | 7 | 1 | no | no |
| 134111 | Hidden Cloak | 2 | 7 | 1 | no | no |
| 134112 | Hidden Shoulder | 2 | 0 | 0 | no | no |
| 142503 | Hidden Shirt | 2 | 2 | 1 | no | no |
| 142504 | Hidden Tabard | 2 | 2 | 1 | no | no |
| 143539 | Hidden Belt | 2 | 7 | 1 | no | no |
| 158329 | Hidden Gloves | 2 | 7 | 1 | no | no |
| 168659 | Hidden Chestpiece | 2 | 7 | 1 | no | no |
| 168664 | Hidden Boots | 2 | 7 | 1 | no | no |
| 168665 | Hidden Bracers | 2 | 2 | 0 | no | no |
| 216696 | Hidden Pants | 2 | 7 | 1 | no | no |

### 4/5 Armadura / Cosmética, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 274021 | Barrens Headband | 3 | 1 | 1 | no | no |
| 274022 | Tough Guy's Eyepatch | 3 | 1 | 1 | no | no |
| 274023 | Stolen Wastewander Cowl | 3 | 1 | 1 | no | no |
| 274024 | Fizzbolt's Fashionable Fedora | 3 | 1 | 1 | no | no |
| 276199 | Haughty Fellow's Monocle | 3 | 1 | 1 | no | no |
| 276272 | Master Angler's Fishing Hat | 3 | 0 | 1 | no | no |
| 285353 | Eternal Explorer's Backpack | 3 | 2 | 1 | no | no |
| 287620 | Rugged Totemic Backpack | 3 | 2 | 1 | no | no |
| 287621 | Gilded Blademaster's Chestpiece | 3 | 2 | 1 | no | no |
| 287622 | Gilded Blademaster's Belt | 3 | 2 | 1 | no | no |
| 287623 | Gilded Blademaster's Legguards | 3 | 2 | 1 | no | no |
| 287624 | Gilded Blademaster's Boots | 3 | 2 | 1 | no | no |
| 287625 | Gilded Blademaster's Gloves | 3 | 2 | 1 | no | no |
| 287626 | Gilded Blademaster's Banner | 3 | 2 | 1 | no | no |
| 287627 | Gilded Blademaster's Collar | 3 | 2 | 1 | no | no |
| 287628 | Gilded Blademaster's Shoulders | 3 | 3 | 1 | no | no |

### 4/5 Armadura / Cosmética, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 285352 | Tabard of Eternal Exploration | 4 | 1 | 1 | no | no |

### 4/6 Armadura / Escudo, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 876 | Worn Wooden Buckler | 1 | 1 | 1 | no | no |
| 1166 | Dented Buckler | 1 | 16 | 1 | no | no |
| 1167 | Small Targe | 1 | 96 | 5 | no | no |
| 1193 | Banded Buckler | 1 | 355 | 12 | no | no |
| 1200 | Large Wooden Shield | 1 | 16 | 1 | no | no |
| 1201 | Dull Heater Shield | 1 | 94 | 5 | no | no |
| 1202 | Wall Shield | 1 | 367 | 12 | no | no |
| 1438 | Warrior's Shield | 1 | 70 | 4 | no | no |
| 2129 | Large Round Shield | 1 | 15 | 1 | no | no |
| 2133 | Small Shield | 1 | 15 | 1 | no | no |
| 2249 | Militia Buckler | 1 | 91 | 0 | no | no |
| 2362 | Worn Wooden Shield | 1 | 1 | 1 | no | no |
| 2376 | Worn Heater Shield | 1 | 89 | 5 | no | no |
| 2377 | Round Buckler | 1 | 89 | 5 | no | no |
| 2441 | Ringed Buckler | 1 | 729 | 17 | no | no |
| 2442 | Reinforced Targe | 1 | 1312 | 22 | no | no |
| 2443 | Metal Buckler | 1 | 3417 | 32 | no | no |
| 2444 | Ornate Buckler | 1 | 9393 | 45 | no | no |
| 2445 | Large Metal Shield | 1 | 686 | 17 | no | no |
| 2446 | Kite Shield | 1 | 1236 | 22 | no | no |
| 2448 | Heavy Pavise | 1 | 3231 | 32 | no | no |
| 2451 | Crested Heater Shield | 1 | 8725 | 45 | no | no |
| 2900 | Stone Buckler | 1 | 89 | 0 | no | no |
| 3276 | Deathguard Buckler | 1 | 15 | 0 | no | no |
| 3648 | Warrior's Buckler | 1 | 73 | 4 | no | no |
| 3649 | Tribal Buckler | 1 | 115 | 6 | no | no |
| 3650 | Battle Shield | 1 | 68 | 4 | no | no |
| 4263 | Standard Issue Shield | 1 | 94 | 5 | no | no |
| 4911 | Thick Bark Buckler | 1 | 15 | 0 | no | no |
| 4937 | Charging Buckler | 1 | 71 | 0 | no | no |
| 4950 | Deprecated Orc Protector | 1 | 126 | 0 | no | no |
| 4967 | Tribal Warrior's Shield | 1 | 116 | 0 | no | no |
| 5094 | Razormane War Shield | 1 | 233 | 19 | no | no |
| 5395 | Woodland Shield | 1 | 16 | 0 | no | no |
| 5593 | Crag Buckler | 1 | 116 | 0 | no | no |
| 5940 | Bone Buckler | 1 | 153 | 0 | no | no |
| 6078 | Pikeman Shield | 1 | 15 | 0 | no | no |
| 6176 | Dwarven Kite Shield | 1 | 15 | 0 | no | no |
| 7109 | Pioneer Buckler | 1 | 74 | 4 | no | no |
| 9444 | Techbot CPU Shell | 1 | 1120 | 21 | no | no |
| 11199 | Engineer's Shield 1 | 1 | 2 | 1 | no | no |
| 11200 | Engineer's Shield 2 | 1 | 2 | 1 | no | no |
| 11201 | Engineer's Shield 3 | 1 | 2 | 1 | no | no |
| 12961 | JEFF TEST SHIELD | 1 | 2 | 0 | no | no |
| 14393 | Durability Shield | 1 | 2 | 0 | no | no |
| 14691 | Deprecated Battle Chain Buckler | 1 | 116 | 6 | no | no |
| 14696 | Deprecated Battle Chain Shield | 1 | 118 | 6 | no | no |
| 15006 | Primal Buckler | 1 | 72 | 4 | no | no |
| 15478 | Charger's Shield | 1 | 52 | 3 | no | no |
| 17183 | Dented Buckler | 1 | 6 | 1 | no | no |
| 17184 | Small Shield | 1 | 6 | 1 | no | no |
| 17185 | Round Buckler | 1 | 48 | 3 | no | no |
| 17186 | Small Targe | 1 | 48 | 3 | no | no |
| 17187 | Banded Buckler | 1 | 215 | 9 | no | no |
| 17188 | Ringed Buckler | 1 | 453 | 14 | no | no |
| 17189 | Metal Buckler | 1 | 2408 | 29 | no | no |
| 17190 | Ornate Buckler | 1 | 6921 | 42 | no | no |
| 17192 | Reinforced Targe | 1 | 879 | 19 | no | no |
| 241086 | Scarlet Tower Shield | 1 | 15 | 1 | no | no |
| 257336 | Peacekeeper's Buckler | 1 | 91 | 0 | no | no |

### 4/6 Armadura / Escudo, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1276 | Fire Hardened Buckler | 2 | 2220 | 0 | no | no |
| 1547 | Shield of the Faith | 2 | 2795 | 0 | no | no |
| 1557 | Buckler of the Seas | 2 | 918 | 0 | no | no |
| 2916 | Gold Lion Shield | 2 | 4405 | 0 | no | no |
| 3160 | Ironplate Buckler | 2 | 470 | 0 | no | no |
| 3450 | Faerleia's Shield | 2 | 443 | 0 | no | no |
| 3743 | Sentry Buckler | 2 | 2451 | 0 | no | no |
| 3761 | Deadskull Shield | 2 | 3306 | 0 | no | no |
| 3763 | Lunar Buckler | 2 | 6761 | 0 | no | no |
| 4115 | Grom'gol Buckler | 2 | 5783 | 0 | no | no |
| 4129 | Collection Plate | 2 | 9444 | 0 | no | no |
| 4507 | Pit Fighter's Shield | 2 | 8282 | 0 | no | no |
| 4652 | Salbac Shield | 2 | 10126 | 0 | no | no |
| 4820 | Guardian Buckler | 2 | 1664 | 20 | no | no |
| 4821 | Bear Buckler | 2 | 1308 | 18 | no | no |
| 4822 | Owl's Disk | 2 | 1349 | 18 | no | no |
| 4975 | Vigilant Buckler | 2 | 6477 | 0 | no | no |
| 5302 | Cobalt Buckler | 2 | 929 | 0 | no | no |
| 5325 | Welding Shield | 2 | 498 | 0 | no | no |
| 5357 | Ward of the Vale | 2 | 2221 | 0 | no | no |
| 6187 | Dwarven Defender | 2 | 613 | 0 | no | no |
| 6203 | Thuggish Shield | 2 | 121 | 8 | no | no |
| 6223 | Crest of Darkshire | 2 | 4797 | 0 | no | no |
| 6676 | Constable Buckler | 2 | 2245 | 0 | no | no |
| 6746 | Basalt Buckler | 2 | 7075 | 0 | no | no |
| 6828 | Visionary Buckler | 2 | 6268 | 0 | no | no |
| 6970 | Furen's Favor | 2 | 906 | 0 | no | no |
| 7120 | Ruga's Bulwark | 2 | 895 | 0 | no | no |
| 7748 | Forcestone Buckler | 2 | 10862 | 0 | no | no |
| 9607 | Bastion of Stormwind | 2 | 1762 | 0 | no | no |
| 9643 | Optomatic Deflector | 2 | 15988 | 0 | no | no |
| 9661 | Earthclasp Barrier | 2 | 9051 | 0 | no | no |
| 9706 | Tharg's Disk | 2 | 9212 | 0 | no | no |
| 9888 | Deprecated Elven Protector | 2 | 5204 | 31 | no | no |
| 10686 | Aegis of Battle | 2 | 21163 | 0 | no | no |
| 11915 | Shizzle's Drizzle Blocker | 2 | 20124 | 0 | no | no |
| 14597 | Deprecated Warden's Buckler | 2 | 7312 | 36 | no | no |
| 14609 | Deprecated Ceremonial Buckler | 2 | 600 | 12 | no | no |
| 15207 | Steelcap Shield | 2 | 868 | 0 | no | no |
| 15466 | Clink Shield | 2 | 2323 | 0 | no | no |
| 15695 | Studded Ring Shield | 2 | 5771 | 0 | no | no |
| 15865 | Anchorhold Buckler | 2 | 6562 | 0 | no | no |
| 15888 | Deprecated Glorious Shield | 2 | 26929 | 55 | no | no |
| 15889 | Deprecated Jademir Scale Shield | 2 | 23125 | 52 | no | no |
| 16660 | Driftmire Shield | 2 | 2200 | 0 | no | no |
| 16788 | Captain Rackmore's Wheel | 2 | 5095 | 0 | no | no |
| 246265 | Salvaged Wooden Tower Shield | 2 | 15 | 0 | no | no |
| 257255 | Highlands Defender's Shield | 2 | 15 | 0 | no | no |
| 263305 | Windshaped Shield | 2 | 94 | 0 | no | no |
| 263431 | Defender's Aegis | 2 | 89 | 0 | no | no |
| 270065 | Farseer's Forgotten Shield | 2 | 6202 | 0 | no | no |
| 270270 | Scale of the Tidebender | 2 | 6202 | 0 | no | no |
| 271798 | Desperate Barrier | 2 | 5796 | 35 | no | no |
| 275049 | Farholde Bastion | 2 | 11603 | 0 | no | no |
| 275051 | Twilight Barrier | 2 | 11685 | 0 | no | no |
| 276334 | Hand-Hewn Buckler | 2 | 25722 | 0 | no | no |
| 276889 | Thornwoven Shield | 2 | 0 | 1 | no | no |
| 277555 | Monster - Shield, Skyborne (Gray) | 2 | 15 | 0 | no | no |
| 281020 | Monster - Shield, Skyborne (White) | 2 | 15 | 0 | no | no |
| 281307 | Dragonmaw Buckler | 2 | 0 | 0 | no | no |
| 281731 | Restored Buckler | 2 | 1 | 1 | no | no |

### 4/6 Armadura / Escudo, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 16998 | Sacred Protector | 3 | 35631 | 0 | no | no |
| 20502 | Ironbark Shield | 3 | 21277 | 0 | no | no |
| 260210 | A Bigger Shield | 3 | 21163 | 0 | no | no |
| 274418 | Burrow Barricade | 3 | 28525 | 53 | no | no |
| 276204 | Thrash's Trash | 3 | 7597 | 40 | no | no |
| 276754 | Sunderbark Vigil | 3 | 24224 | 0 | no | no |
| 277257 | Raven Hill Crest | 3 | 0 | 0 | no | no |
| 277258 | Crest of Elucidation | 3 | 0 | 40 | no | no |
| 280696 | Elementalist's Guard | 3 | 0 | 1 | no | no |
| 281637 | Antique Bulwark | 3 | 0 | 0 | no | no |

### 4/6 Armadura / Escudo, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 19321 | The Immovable Object | 4 | 159059 | 60 | no | no |
| 21269 | Blessed Qiraji Bulwark | 4 | 110563 | 60 | no | no |
| 21610 | Wormscale Blocker | 4 | 122759 | 60 | no | no |
| 278468 | Premier Grand Marshal's Barricade | 4 | 0 | 60 | no | no |
| 278469 | Premier High Warlord's Barricade | 4 | 0 | 60 | no | no |
| 279262 | Evergreen Shield | 4 | 19893 | 60 | no | no |

### 4/7 Armadura / Tratado, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 22316 | Test Relic | 3 | 0 | 10 | no | no |

### 5/0 Componente / Componente, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 211779 | Comprehension Charm | 1 | 0 | 1 | no | no |
| 213552 | Tear of Theradras | 1 | 0 | 1 | no | no |
| 213553 | Tear of Theradras | 1 | 0 | 1 | no | no |

### 5/0 Componente / Componente, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 216645 | Mote of Darkness | 2 | 0 | 0 | no | no |

### 5/0 Componente / Componente, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 257348 | Essence of Innovation | 3 | 20000 | 0 | no | no |

### 6/2 Proyectil / Flecha, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2103 | Test Arrow | 1 | 1 | 1 | no | no |
| 2512 | Rough Arrow | 1 | 0 | 1 | no | no |
| 2514 | Depricated Sharp Arrow | 1 | 0 | 3 | no | no |
| 2515 | Sharp Arrow | 1 | 0 | 10 | no | no |
| 2517 | Deprecated Standard Arrow | 1 | 0 | 1 | no | no |
| 3029 | Depricated Whipwood Arrow | 1 | 0 | 15 | no | no |
| 3031 | Depricated Razor Arrow | 1 | 0 | 30 | no | no |
| 11285 | Jagged Arrow | 1 | 2 | 40 | no | no |
| 19082 | Monster - Fire Arrow | 1 | 0 | 1 | no | no |

### 6/2 Proyectil / Flecha, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3464 | Feathered Arrow | 2 | 8 | 0 | no | no |
| 18042 | Thorium Headed Arrow | 2 | 10 | 52 | no | no |
| 19316 | Ice Threaded Arrow | 2 | 7 | 51 | no | no |

### 6/2 Proyectil / Flecha, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 10579 | Explosive Arrow | 3 | 0 | 37 | no | no |

### 6/2 Proyectil / Flecha, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 274387 | Swiftfeather Arrow | 4 | 0 | 60 | no | no |

### 6/3 Proyectil / Bala, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2104 | Deprecated Standard Shot | 1 | 0 | 1 | no | no |
| 2513 | Deprecated Iron Shot | 1 | 0 | 1 | no | no |
| 2516 | Light Shot | 1 | 0 | 1 | no | no |
| 2518 | Deprecated Solid Shot | 1 | 0 | 3 | no | no |
| 2519 | Heavy Shot | 1 | 0 | 10 | no | no |
| 3032 | Deprecated Impact Shot | 1 | 0 | 15 | no | no |
| 3033 | Solid Shot | 1 | 0 | 25 | no | no |
| 3034 | Deprecated BKP "Impact" Shot | 1 | 0 | 30 | no | no |
| 4960 | Flash Pellet | 1 | 12 | 0 | no | no |
| 5568 | Smooth Pebble | 1 | 4 | 13 | no | no |
| 8067 | Crafted Light Shot | 1 | 0 | 5 | no | no |
| 8068 | Crafted Heavy Shot | 1 | 0 | 15 | no | no |
| 8069 | Crafted Solid Shot | 1 | 0 | 30 | no | no |
| 11284 | Accurate Slugs | 1 | 1 | 40 | no | no |

### 6/3 Proyectil / Bala, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 3465 | Exploding Shot | 2 | 9 | 0 | no | no |
| 10512 | Hi-Impact Mithril Slugs | 2 | 2 | 37 | no | no |
| 10513 | Mithril Gyro-Shot | 2 | 5 | 44 | no | no |
| 15997 | Thorium Shells | 2 | 10 | 52 | no | no |
| 19317 | Ice Threaded Bullet | 2 | 7 | 51 | no | no |

### 6/3 Proyectil / Bala, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 274388 | Swiftstrike Shot | 4 | 0 | 60 | no | no |

### 7/0 Material / Material, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 239011 | Shard of Crystallized Light | 5 | 100000 | 0 | no | no |
| 239012 | Splinter of Crystallized Light | 5 | 100000 | 0 | no | no |
| 239013 | Crystalline Axe | 5 | 100000 | 0 | no | no |

### 7/1 Material / Pieza, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 258526 | Flight Log | 1 | 0 | 0 | no | no |

### 7/1 Material / Pieza, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 260826 | Gnomish Weather Machine NYI | 2 | 5000 | 60 | no | no |

### 7/6 Material / Cuero, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 17967 | Refined Scale of Onyxia | 3 | 5000 | 0 | no | no |

### 7/7 Material / Metal y piedra, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 741 | Deprecated Copper Ingot | 1 | 5 | 0 | no | no |
| 786 | Deprecated Pure Copper Ingot | 1 | 15 | 0 | no | no |
| 807 | Deprecated Iron Ingot | 1 | 125 | 0 | no | no |
| 1950 | Deprecated Gold Ingot | 1 | 100 | 0 | no | no |
| 11099 | Dark Iron Ore | 1 | 250 | 0 | no | no |

### 7/7 Material / Metal y piedra, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 17771 | Elementium Bar | 5 | 100000 | 0 | no | no |

### 7/8 Material / Cocina, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2296 | Great Goretusk Snout | 1 | 50 | 0 | no | no |

### 7/9 Material / Hierba, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 19727 | Blood Scythe | 3 | 15000 | 0 | no | no |

### 7/11 Material / Otro, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 784 | Deprecated Tiny Flame Sac | 1 | 15 | 0 | no | no |
| 808 | Deprecated Malachite | 1 | 75 | 0 | no | no |
| 1638 | Deprecated Thornstone Chunk | 1 | 30 | 0 | no | no |
| 1654 | Deprecated Strangleslash Metal | 1 | 30 | 0 | no | no |
| 1689 | Deprecated Medium Tiger Pelt | 1 | 57 | 0 | no | no |
| 1693 | Deprecated Shadowmaw Pelt | 1 | 70 | 0 | no | no |
| 1694 | Deprecated Lashtail Hide | 1 | 70 | 0 | no | no |
| 1695 | Deprecated Jungle Stalker Pelt | 1 | 75 | 0 | no | no |
| 1963 | Deprecated Bone Chips | 1 | 29 | 0 | no | no |
| 2322 | Deprecated Crag Boar Hide | 1 | 18 | 0 | no | no |
| 2323 | Deprecated Longsnout Hide | 1 | 55 | 0 | no | no |
| 2693 | OLD Stormwind Seasoning Salts  | 1 | 20 | 0 | no | no |
| 2929 | Tomb Rot | 1 | 2 | 0 | no | no |
| 2932 | Torment Vine | 1 | 50 | 0 | no | no |
| 5523 | Small Barnacled Clam | 1 | 15 | 0 | no | no |
| 5524 | Thick-shelled Clam | 1 | 21 | 0 | no | no |
| 7872 | Rusty Thieves' Tools | 1 | 0 | 15 | no | no |
| 7973 | Big-mouth Clam | 1 | 46 | 0 | no | no |
| 13757 | Lightning Eel | 1 | 10 | 0 | no | no |
| 20423 | Sandy Scorpid Claw | 1 | 0 | 1 | no | no |
| 241652 | Discolored Beast Heart | 1 | 250 | 0 | no | no |

### 7/11 Material / Otro, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 210772 | Supply Shipment: Copper Bars | 2 | 0 | 1 | no | no |
| 211365 | Supply Shipment | 2 | 0 | 1 | no | no |
| 211367 | Supply Shipment | 2 | 0 | 1 | no | no |
| 211368 | Supply Shipment | 2 | 0 | 1 | no | no |
| 211839 | Supply Shipment | 2 | 0 | 1 | no | no |
| 211840 | Supply Shipment | 2 | 0 | 1 | no | no |
| 211841 | Supply Shipment | 2 | 0 | 1 | no | no |
| 217337 | Supply Shipment | 2 | 0 | 1 | no | no |
| 217338 | Supply Shipment | 2 | 0 | 1 | no | no |
| 217339 | Supply Shipment | 2 | 0 | 1 | no | no |
| 221008 | Supply Shipment | 2 | 0 | 1 | no | no |
| 221009 | Supply Shipment | 2 | 0 | 1 | no | no |
| 221010 | Supply Shipment | 2 | 0 | 1 | no | no |
| 227801 | Firelands Ember | 2 | 500 | 0 | no | no |
| 235786 | Karazhan Curio | 2 | 0 | 0 | no | no |
| 237504 | Supply Shipment | 2 | 0 | 1 | no | no |

### 7/11 Material / Otro, calidad 7

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 232454 | Emblem of the Wild Gods | 7 | 0 | 0 | no | no |
| 232455 | Emblem of Dishonor | 7 | 0 | 0 | no | no |
| 232456 | Emblem of the Violet Eye | 7 | 0 | 0 | no | no |
| 232457 | Emblem of the Worldcore | 7 | 0 | 0 | no | no |

### 7/12 Material / Encantamiento, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 247884 | Luminous Residue | 1 | 5 | 0 | no | no |

### 7/12 Material / Encantamiento, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 247883 | Crude Wax Effigy | 2 | 18 | 0 | no | no |
| 275724 | Hexed Pendant | 2 | 18 | 0 | no | no |

### 9/0 Receta / Libro, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 966 | Tome of Frost Shield | 1 | 87 | 8 | sí | no |
| 967 | Tome of Frost Ward | 1 | 1050 | 22 | sí | no |
| 968 | Tome of Fire Blast | 1 | 20 | 6 | sí | no |
| 973 | Tome of Fireball II | 1 | 250 | 12 | sí | no |
| 974 | Tome of Frost Armor II | 1 | 75 | 10 | sí | no |
| 975 | Tome of Chains of Ice | 1 | 187 | 10 | sí | no |
| 976 | Tome of Remove Curse | 1 | 625 | 18 | sí | no |
| 980 | Tome of Frost Shield II | 1 | 750 | 20 | sí | no |
| 985 | Tome of Khadgar's Unlocking | 1 | 550 | 18 | sí | no |
| 986 | Tome of Frostbolt II | 1 | 50 | 8 | sí | no |
| 989 | Tome of Frost Nova | 1 | 75 | 10 | sí | no |
| 992 | Tome of Fireball III | 1 | 125 | 12 | sí | no |
| 994 | Tome of Ice Armor | 1 | 2425 | 30 | sí | no |
| 1002 | Tome of Lesser Invisibility | 1 | 1675 | 26 | sí | no |
| 1004 | Tome of Chains of Ice II | 1 | 2000 | 30 | sí | no |
| 1029 | Tablet of Serpent Totem | 1 | 20 | 4 | sí | no |
| 1030 | Tablet of Unyielding Will | 1 | 187 | 10 | sí | no |
| 1031 | Tablet of Molten Blast | 1 | 20 | 6 | sí | no |
| 1032 | Tablet of Agitating Totem | 1 | 87 | 8 | sí | no |
| 1033 | Tablet of Nullify Poison | 1 | 625 | 18 | sí | no |
| 1034 | Tablet of Undying Strength | 1 | 1000 | 22 | sí | no |
| 1035 | Tablet of Call Spirit | 1 | 187 | 10 | sí | no |
| 1036 | Tablet of Nullify Disease | 1 | 450 | 16 | sí | no |
| 1037 | Tablet of Lightning Bolt II | 1 | 75 | 10 | sí | no |
| 1038 | Tablet of Restoration II | 1 | 87 | 8 | sí | no |
| 1048 | Tablet of Lightning Shield II | 1 | 325 | 16 | sí | no |
| 1049 | Tablet of Purge | 1 | 150 | 12 | sí | no |
| 1052 | Tablet of Spirit Armor II | 1 | 325 | 14 | sí | no |
| 1053 | Tablet of Molten Blast II | 1 | 225 | 14 | sí | no |
| 1057 | Tablet of Restoration III | 1 | 450 | 16 | sí | no |
| 1058 | Tablet of Lightning Bolt III | 1 | 550 | 18 | sí | no |
| 1061 | Tablet of Nullify Poison II | 1 | 1500 | 26 | sí | no |
| 1063 | Tablet of Nullify Disease II | 1 | 1500 | 26 | sí | no |
| 1084 | Codex of Renew | 1 | 50 | 8 | sí | no |
| 1085 | Codex of Mind Vision | 1 | 1050 | 22 | sí | no |
| 1086 | Codex of Inner Fire | 1 | 150 | 12 | sí | no |
| 1087 | Codex of Shadow Word: Pain | 1 | 10 | 4 | sí | no |
| 1088 | Codex of Renew II | 1 | 225 | 14 | sí | no |
| 1089 | Codex of Nullify Disease | 1 | 325 | 14 | sí | no |
| 1090 | Codex of Resurrection | 1 | 75 | 10 | sí | no |
| 1091 | Codex of Holy Smite II | 1 | 20 | 6 | sí | no |
| 1092 | Codex of Lesser Heal II | 1 | 10 | 4 | sí | no |
| 1093 | Codex of Remove Curse | 1 | 1000 | 22 | sí | no |
| 1095 | Codex of Dispel Magic | 1 | 550 | 18 | sí | no |
| 1096 | Codex of Shadow Word: Pain II | 1 | 75 | 10 | sí | no |
| 1099 | Deprecated Codex of Sustenance II | 1 | 850 | 21 | sí | no |
| 1100 | Codex of Holy Smite III | 1 | 225 | 14 | sí | no |
| 1101 | Codex of Renew V | 1 | 2750 | 32 | sí | no |
| 1102 | Codex of Lesser Heal III | 1 | 75 | 10 | sí | no |
| 1105 | Codex of Renew VI | 1 | 4500 | 38 | sí | no |
| 1108 | Codex of Renew III | 1 | 725 | 20 | sí | no |
| 1109 | Codex of Dominate | 1 | 2000 | 30 | sí | no |
| 1111 | Codex of Sleep | 1 | 50 | 6 | sí | no |
| 1112 | Codex of Holy Word: Fortitude II | 1 | 150 | 12 | sí | no |
| 1136 | Libram: Divine Favor II | 1 | 550 | 18 | sí | no |
| 1138 | Libram: Divine Favor | 1 | 10 | 4 | sí | no |
| 1139 | Libram: Cleanse | 1 | 2425 | 30 | sí | no |
| 1141 | Libram: Holy Light II | 1 | 20 | 6 | sí | no |
| 1144 | Libram: Divine Shield | 1 | 3250 | 34 | sí | no |
| 1146 | Libram: Resurrection | 1 | 0 | 12 | sí | no |
| 1149 | Libram: Seal of Might II | 1 | 750 | 20 | sí | no |
| 1150 | Libram: Purify | 1 | 20 | 6 | sí | no |
| 1151 | Libram: Holy Light III | 1 | 225 | 14 | sí | no |
| 1164 | Sam's Tome | 1 | 0 | 0 | no | no |
| 1224 | Grimoire of Sense Demons | 1 | 1325 | 24 | sí | no |
| 1228 | Grimoire of Blood Boil | 1 | 50 | 6 | sí | no |
| 1229 | Grimoire of Create Soulstone | 1 | 550 | 18 | sí | no |
| 1231 | Grimoire of Shadow Bolt II | 1 | 25 | 6 | sí | no |
| 1232 | Grimoire of Demon Skin II | 1 | 75 | 10 | sí | no |
| 1238 | Grimoire of Fear | 1 | 50 | 8 | sí | no |
| 1239 | Grimoire of Siphon Mana | 1 | 1675 | 26 | sí | no |
| 1243 | Grimoire of Shadow Bolt III | 1 | 150 | 12 | sí | no |
| 1244 | Grimoire of Demon Armor | 1 | 1050 | 22 | sí | no |
| 1245 | Grimoire of Immolate II | 1 | 75 | 10 | sí | no |
| 1246 | Grimoire of Demon Breath | 1 | 325 | 16 | sí | no |
| 1250 | Grimoire of Detect Lesser Invisibility | 1 | 1675 | 26 | sí | no |
| 1323 | Deprecated [PH] Recipe: Broiled Sunfish | 1 | 1 | 0 | no | no |
| 1328 | Book of Faerie Fire | 1 | 550 | 18 | sí | no |
| 1332 | Book of Cure Poison | 1 | 225 | 14 | sí | no |
| 1334 | Book of Rejuvenation II | 1 | 75 | 10 | sí | no |
| 1335 | Deprecated Book of Nullify Disease | 1 | 325 | 14 | no | no |
| 1339 | Book of Entangling Roots | 1 | 50 | 8 | sí | no |
| 1341 | Book of Moonfire | 1 | 10 | 4 | sí | no |
| 1492 | Deprecated Recipe: Murloc Fin Soup | 1 | 1 | 0 | no | no |
| 1534 | Libram: Holy Light IV | 1 | 1050 | 22 | sí | no |
| 1536 | Libram: Seal of Wrath | 1 | 2425 | 30 | sí | no |
| 1554 | Tome of Frostbolt III | 1 | 225 | 14 | sí | no |
| 1559 | Tome of Arcane Missiles II | 1 | 325 | 16 | sí | no |
| 1567 | Tome of Khadgar's Unlocking II | 1 | 2425 | 30 | sí | no |
| 1568 | Tome of Water Elemental | 1 | 2000 | 30 | sí | no |
| 1571 | Tome of Frost Nova II | 1 | 1675 | 26 | sí | no |
| 1574 | Tome of Fire Ward | 1 | 725 | 20 | sí | no |
| 1588 | Tablet of Molten Blast III | 1 | 1050 | 22 | sí | no |
| 1589 | Tablet of Spirit Armor III | 1 | 1750 | 28 | sí | no |
| 1591 | Tablet of Lightning Shield III | 1 | 1325 | 24 | sí | no |
| 1597 | Tablet of Lightning Storm | 1 | 750 | 20 | sí | no |
| 1599 | Deprecated [PH] Recipe: Zombie Juice | 1 | 1 | 0 | no | no |
| 1603 | Tablet of Call Spirit II | 1 | 5000 | 40 | sí | no |
| 1619 | Tablet of Lightning Storm II | 1 | 2000 | 30 | sí | no |
| 1641 | Codex of Shadow Word: Pain III | 1 | 550 | 18 | sí | no |
| 1648 | Codex of Heal IV | 1 | 3250 | 34 | sí | no |
| 1651 | Codex of Holy Word: Shield VI | 1 | 3750 | 36 | sí | no |
| 1655 | Deprecated Codex of Sustenance III | 1 | 1900 | 29 | sí | no |
| 1657 | Codex of Resurrection II | 1 | 1675 | 26 | sí | no |
| 1658 | Codex of Shadow Word: Pain IV | 1 | 1675 | 26 | sí | no |
| 1676 | Codex of Sleep II | 1 | 750 | 20 | sí | no |
| 1681 | Grimoire of Cripple | 1 | 450 | 16 | sí | no |
| 1877 | Book of Rejuvenation III | 1 | 325 | 16 | sí | no |
| 1878 | Deprecated Book of Nullify Poison II | 1 | 1750 | 28 | sí | no |
| 1880 | Deprecated Book of Nullify Disease II | 1 | 1250 | 24 | no | no |
| 1882 | Book of Moonfire III | 1 | 325 | 16 | sí | no |
| 1886 | Book of Moonfire II | 1 | 75 | 10 | sí | no |
| 3088 | Book of Rejuvenation IV | 1 | 1050 | 22 | sí | no |
| 3089 | Tome of Flamestrike | 1 | 325 | 16 | sí | no |
| 3090 | Tome of Frostbolt | 1 | 10 | 4 | sí | no |
| 3091 | Tome of Arcane Intellect II | 1 | 225 | 14 | sí | no |
| 3092 | Tome of Flamestrike III | 1 | 2750 | 32 | sí | no |
| 3093 | Tome of Flamestrike II | 1 | 1325 | 24 | sí | no |
| 3094 | Tome of Fire Blast II | 1 | 225 | 14 | sí | no |
| 3095 | Tome of Fire Blast III | 1 | 1050 | 22 | sí | no |
| 3096 | Tome of Feather Fall | 1 | 150 | 12 | sí | no |
| 3097 | Tome of Conjure Water II | 1 | 75 | 10 | sí | no |
| 3098 | Tome of Slow | 1 | 1750 | 28 | sí | no |
| 3099 | Tome of Ice Armor II | 1 | 5000 | 40 | sí | no |
| 3100 | Tome of Blizzard II | 1 | 2025 | 28 | sí | no |
| 3101 | Tome of Frost Nova III | 1 | 5000 | 40 | sí | no |
| 3102 | Tome of Arcane Intellect III | 1 | 2025 | 28 | sí | no |
| 3113 | Codex of Holy Word: Shield | 1 | 20 | 6 | sí | no |
| 3114 | Codex of Shadow Word: Befuddle | 1 | 1250 | 24 | sí | no |
| 3115 | Codex of Renew IV | 1 | 1675 | 26 | sí | no |
| 3116 | Codex of Holy Word: Shield II | 1 | 150 | 12 | sí | no |
| 3118 | Codex of Greater Heal | 1 | 5000 | 40 | sí | no |
| 3119 | Codex of Holy Word: Shield V | 1 | 2425 | 30 | sí | no |
| 3120 | Codex of Holy Smite IV | 1 | 1050 | 22 | sí | no |
| 3121 | Codex of Levitate | 1 | 3250 | 34 | sí | no |
| 3122 | Codex of Holy Word: Shield III | 1 | 550 | 18 | sí | no |
| 3123 | Codex of Holy Word: Fortitude III | 1 | 1325 | 24 | sí | no |
| 3124 | Codex of Inner Fire III | 1 | 2425 | 30 | sí | no |
| 3125 | Tablet of Serpent Totem II | 1 | 187 | 10 | sí | no |
| 3126 | Tablet of Shock II | 1 | 250 | 12 | sí | no |
| 3127 | Tablet of Shock III | 1 | 750 | 20 | sí | no |
| 3129 | Tablet of Lightning Bolt IV | 1 | 1675 | 26 | sí | no |
| 3130 | Tablet of Restoration IV | 1 | 1250 | 24 | sí | no |
| 3132 | Tablet of Molten Blast IV | 1 | 2425 | 30 | sí | no |
| 3133 | Tablet of Mana Totem | 1 | 2000 | 30 | sí | no |
| 3134 | Grimoire of Curse of Mannoroth | 1 | 20 | 4 | sí | no |
| 3138 | Grimoire of Shadow Bolt IV | 1 | 725 | 20 | sí | no |
| 3139 | Grimoire of Demon Armor II | 1 | 3250 | 34 | sí | no |
| 3140 | Grimoire of Blood Boil II | 1 | 625 | 18 | sí | no |
| 3141 | Grimoire of Life Drain | 1 | 225 | 14 | sí | no |
| 3142 | Grimoire of Curse of Sargeras | 1 | 187 | 10 | sí | no |
| 3143 | Grimoire of Burning Spirit | 1 | 50 | 6 | sí | no |
| 3144 | Grimoire of Burning Spirit II | 1 | 450 | 16 | sí | no |
| 3146 | Grimoire of Burning Spirit III | 1 | 1750 | 28 | sí | no |
| 4141 | Tome of Conjure Food | 1 | 20 | 6 | sí | no |
| 4143 | Tome of Conjure Food II | 1 | 125 | 12 | sí | no |
| 4145 | Tome of Conjure Mana Gem | 1 | 2025 | 28 | sí | no |
| 4146 | Tome of Polymorph: Sheep | 1 | 5000 | 40 | sí | no |
| 4147 | Tome of Conjure Food III | 1 | 1050 | 22 | sí | no |
| 4148 | Tome of Counterspell | 1 | 1325 | 24 | sí | no |
| 4149 | Tome of Frost Shield III | 1 | 3000 | 34 | sí | no |
| 4150 | Tome of Conjure Water IV | 1 | 2425 | 30 | sí | no |
| 4151 | Tome of Frostbolt IV | 1 | 725 | 20 | sí | no |
| 4152 | Tome of Conjure Food IV | 1 | 2750 | 32 | sí | no |
| 4153 | Tome of Arcane Missiles III | 1 | 1325 | 24 | sí | no |
| 4154 | Tome of Slow II | 1 | 5000 | 40 | sí | no |
| 4155 | Tome of Water Elemental II | 1 | 5000 | 40 | sí | no |
| 4156 | Deprecated Tome of Conjure Mana Jewel | 1 | 3925 | 37 | sí | no |
| 4157 | Tome of Dampen Magic | 1 | 125 | 12 | sí | no |
| 4158 | Tome of Khadgar's Unlocking III | 1 | 5500 | 42 | sí | no |
| 4159 | Tome of Arcane Missiles | 1 | 50 | 8 | sí | no |
| 4160 | Tome of Invisibility | 1 | 4500 | 38 | sí | no |
| 4161 | Tome of Fireball IV | 1 | 550 | 18 | sí | no |
| 4162 | Tome of Blink II | 1 | 4250 | 38 | sí | no |
| 4163 | Deprecated Libram: Seal of Fury | 1 | 2500 | 32 | sí | no |
| 4164 | Libram: Holy Light V | 1 | 2425 | 30 | sí | no |
| 4165 | Libram: Holy Light VI | 1 | 4500 | 38 | sí | no |
| 4166 | Libram: Seal of Protection | 1 | 50 | 8 | sí | no |
| 4167 | Libram: Judgement | 1 | 5000 | 40 | sí | no |
| 4168 | Tablet of Ensnaring Totem | 1 | 450 | 16 | sí | no |
| 4169 | Tablet of Unyielding Will II | 1 | 1250 | 24 | sí | no |
| 4170 | Tablet of Astral Recall | 1 | 2000 | 30 | sí | no |
| 4171 | Tablet of Agitating Totem III | 1 | 1750 | 28 | sí | no |
| 4172 | Tablet of Thunderclap II | 1 | 3750 | 36 | sí | no |
| 4173 | Tablet of Shock IV | 1 | 1750 | 28 | sí | no |
| 4174 | Tablet of Shock V | 1 | 3750 | 36 | sí | no |
| 4175 | Tablet of Lightning Shield IV | 1 | 2750 | 32 | sí | no |
| 4176 | Tablet of Undying Strength II | 1 | 3750 | 36 | sí | no |
| 4177 | Tablet of Nature Resistance | 1 | 2500 | 32 | sí | no |
| 4178 | Tablet of Lightning Bolt V | 1 | 3250 | 34 | sí | no |
| 4179 | Tablet of Restoration V | 1 | 2500 | 32 | sí | no |
| 4180 | Tablet of Ethereal Form II | 1 | 3000 | 34 | sí | no |
| 4181 | Tablet of Agitating Totem IV | 1 | 4250 | 38 | sí | no |
| 4182 | Tablet of Unyielding Will III | 1 | 4250 | 38 | sí | no |
| 4183 | Tablet of Healing Totem V | 1 | 3750 | 36 | sí | no |
| 4184 | Tablet of Molten Blast V | 1 | 4500 | 38 | sí | no |
| 4185 | Tablet of Group Astral Recall | 1 | 5000 | 40 | sí | no |
| 4186 | Tablet of Fire Resistance | 1 | 2500 | 32 | sí | no |
| 4187 | Tablet of Serpent Totem V | 1 | 5000 | 40 | no | no |
| 4188 | Tablet of Invisibility Totem | 1 | 5000 | 40 | sí | no |
| 4189 | Tablet of Chain Lightning | 1 | 2750 | 32 | sí | no |
| 4198 | Grimoire of Soul Funnel | 1 | 250 | 12 | sí | no |
| 4199 | Grimoire of Soul Funnel II | 1 | 750 | 20 | sí | no |
| 4200 | Grimoire of Immolate III | 1 | 1050 | 22 | sí | no |
| 4201 | Grimoire of Eye of Kilrogg | 1 | 2025 | 28 | sí | no |
| 4202 | Grimoire of Fear II | 1 | 1325 | 24 | sí | no |
| 4203 | Grimoire of Pestilence II | 1 | 1500 | 26 | sí | no |
| 4204 | Grimoire of Soul Funnel III | 1 | 1750 | 28 | sí | no |
| 4205 | Grimoire of Immolate IV | 1 | 3250 | 34 | sí | no |
| 4206 | Grimoire of Curse of Sargeras II | 1 | 1250 | 24 | sí | no |
| 4207 | Grimoire of Curse of Archimonde | 1 | 2000 | 30 | sí | no |
| 4208 | Grimoire of Mind Bomb | 1 | 2500 | 32 | sí | no |
| 4209 | Grimoire of Shadow Ward | 1 | 2000 | 30 | sí | no |
| 4210 | Grimoire of Create Lesser Bloodstone | 1 | 325 | 14 | sí | no |
| 4211 | Grimoire of Pestilence | 1 | 325 | 14 | sí | no |
| 4212 | Grimoire of Curse of Mannoroth III | 1 | 2500 | 32 | sí | no |
| 4214 | Grimoire of Life Drain III | 1 | 2425 | 30 | sí | no |
| 4215 | Grimoire of Rain of Fire | 1 | 725 | 20 | sí | no |
| 4216 | Grimoire of Holy Ward | 1 | 5000 | 40 | sí | no |
| 4217 | Grimoire of Soul Funnel IV | 1 | 3750 | 36 | sí | no |
| 4218 | Grimoire of Create Bloodstone | 1 | 1500 | 26 | sí | no |
| 4219 | Grimoire of Burning Spirit IV | 1 | 5000 | 40 | sí | no |
| 4220 | Grimoire of Blood Boil III | 1 | 2000 | 30 | sí | no |
| 4221 | Grimoire of Detect Invisibility | 1 | 5000 | 40 | sí | no |
| 4222 | Deprecated Book of Rejuvenation V | 1 | 2500 | 32 | sí | no |
| 4223 | Book of Abolish Magic | 1 | 3750 | 36 | sí | no |
| 4224 | Deprecated Book of Nullify Disease III | 1 | 3300 | 35 | no | no |
| 4225 | Book of Entangling Roots III | 1 | 2025 | 28 | sí | no |
| 4226 | Book of Wrath VI | 1 | 4500 | 38 | sí | no |
| 4227 | Deprecated Book of Nullify Poison III | 1 | 5000 | 40 | sí | no |
| 4228 | Book of Moonfire IV | 1 | 1050 | 22 | sí | no |
| 4229 | Deprecated Book of Rejuvenation VI | 1 | 5000 | 40 | sí | no |
| 4230 | Book of Healing Touch VI | 1 | 2750 | 32 | sí | no |
| 4266 | Codex of Inner Fire II | 1 | 725 | 20 | sí | no |
| 4267 | Codex of Shadow Word: Fumble | 1 | 750 | 20 | sí | no |
| 4268 | Codex of Heal II | 1 | 1050 | 22 | sí | no |
| 4269 | Codex of Prayer of Healing | 1 | 2425 | 30 | sí | no |
| 4270 | Codex of Heal III | 1 | 2025 | 28 | sí | no |
| 4271 | Codex of Holy Smite V | 1 | 2425 | 30 | sí | no |
| 4272 | Codex of Holy Protection | 1 | 2425 | 30 | sí | no |
| 4273 | Codex of Heal | 1 | 325 | 16 | sí | no |
| 4274 | Codex of Divine Escape | 1 | 3750 | 36 | sí | no |
| 4275 | Codex of Mind Rot | 1 | 4250 | 38 | sí | no |
| 4276 | Codex of Shadow Word: Fumble II | 1 | 2500 | 32 | sí | no |
| 4277 | Codex of Shadow Word: Befuddle II | 1 | 3750 | 36 | sí | no |
| 4279 | Codex of Shadow Word: Pain V | 1 | 3250 | 34 | sí | no |
| 4280 | Codex of Holy Word: Shield IV | 1 | 1325 | 24 | sí | no |
| 4281 | Codex of Shadow Protection | 1 | 2425 | 30 | sí | no |
| 4282 | Codex of Dispel Magic II | 1 | 3750 | 36 | sí | no |
| 4283 | Codex of Sleep III | 1 | 5000 | 40 | sí | no |
| 4284 | Codex of Holy Smite VI | 1 | 4500 | 38 | sí | no |
| 4285 | Codex of Holy Word: Fortitude IV | 1 | 3750 | 36 | sí | no |
| 4286 | Codex of Prayer of Healing II | 1 | 5000 | 40 | sí | no |
| 4287 | Codex of Nullify Disease II | 1 | 2500 | 32 | sí | no |
| 4288 | Codex of Remove Curse II | 1 | 4250 | 38 | sí | no |
| 5126 | Knowledge: Defias Disguise | 1 | 162 | 13 | sí | no |
| 5127 | Knowledge: South Seas Pirate Disguise | 1 | 162 | 13 | sí | no |
| 5129 | Knowledge: Dark Iron Dwarf Disguise | 1 | 162 | 22 | sí | no |
| 5130 | Knowledge: Dalaran Wizard Disguise | 1 | 162 | 13 | sí | no |
| 5131 | Knowledge: Stonesplinter Disguise | 1 | 162 | 13 | sí | no |
| 5132 | Knowledge: Syndicate Disguise | 1 | 162 | 22 | sí | no |
| 5139 | Book of Thorns | 1 | 20 | 6 | sí | no |
| 5141 | Book of Regrowth | 1 | 150 | 12 | sí | no |
| 5142 | Book of Wrath II | 1 | 20 | 6 | sí | no |
| 5144 | Deprecated Book of Cyclone | 1 | 187 | 10 | sí | no |
| 5145 | Book of Healing Touch II | 1 | 87 | 8 | sí | no |
| 5146 | Deprecated Book of Barkskin | 1 | 325 | 14 | sí | no |
| 5147 | Book of Entangling Roots II | 1 | 550 | 18 | sí | no |
| 5148 | Book of Thorns II | 1 | 225 | 14 | sí | no |
| 5149 | Book of Wrath III | 1 | 225 | 14 | sí | no |
| 5150 | Book of Healing Touch III | 1 | 225 | 14 | sí | no |
| 5151 | Book of Wrath IV | 1 | 1050 | 22 | sí | no |
| 5152 | Book of Healing Touch IV | 1 | 725 | 20 | sí | no |
| 5153 | Book of Mark of the Wild IV | 1 | 2425 | 30 | sí | no |
| 5154 | Book of Thorns III | 1 | 1325 | 24 | sí | no |
| 5155 | Book of Mark of the Wild II | 1 | 75 | 10 | sí | no |
| 5156 | Book of Wrath V | 1 | 2425 | 30 | sí | no |
| 5157 | Deprecated Book of Cyclone II | 1 | 3000 | 34 | sí | no |
| 5158 | Book of Tranquility | 1 | 2425 | 30 | sí | no |
| 5159 | Deprecated Book of Entangling Roots IV | 1 | 3750 | 36 | sí | no |
| 5160 | Book of Healing Touch V | 1 | 1675 | 26 | sí | no |
| 5161 | Deprecated Book of Barkskin II | 1 | 3925 | 37 | sí | no |
| 5162 | Deprecated Book of Battle Roar II | 1 | 5000 | 40 | sí | no |
| 5163 | Book of Mark of the Wild III | 1 | 725 | 20 | sí | no |
| 5644 | Tome of Conjure Water | 1 | 10 | 4 | sí | no |
| 5647 | Tome of Blink | 1 | 1000 | 22 | sí | no |
| 5648 | Tome of Frost Armor III | 1 | 725 | 20 | sí | no |
| 5649 | Tome of Blizzard | 1 | 725 | 20 | sí | no |
| 5650 | Tome of Conjure Water III | 1 | 725 | 20 | sí | no |
| 5657 | Recipe: Instant Toxin | 1 | 250 | 0 | sí | no |
| 5658 | Libram: Seal of Might | 1 | 87 | 8 | sí | no |
| 5660 | Libram: Seal of Righteousness | 1 | 325 | 16 | sí | no |
| 5661 | Libram: Seal of Righteousness II | 1 | 1675 | 26 | sí | no |
| 5662 | Libram: Seal of Righteousness III | 1 | 3750 | 36 | sí | no |
| 5666 | Libram: Seal of Wrath II | 1 | 5000 | 40 | sí | no |
| 5667 | Libram: Seal of Wisdom II | 1 | 1250 | 24 | sí | no |
| 5670 | Libram: Seal of Wrath IV | 1 | 14750 | 60 | sí | no |
| 5671 | Libram: Seal of Might III | 1 | 2500 | 32 | sí | no |
| 5672 | Libram: Exorcism | 1 | 725 | 20 | sí | no |
| 5673 | Libram: Exorcism II | 1 | 2025 | 28 | sí | no |
| 5674 | Libram: Exorcism III | 1 | 3750 | 36 | sí | no |
| 5676 | Libram: Sense Undead | 1 | 725 | 20 | sí | no |
| 5677 | Libram: Turn Undead | 1 | 1325 | 24 | sí | no |
| 5678 | Libram: Seal of Sacrifice | 1 | 3750 | 36 | sí | no |
| 5679 | Libram: Seal of Wisdom III | 1 | 3750 | 36 | sí | no |
| 5680 | Libram: Seal of Protection II | 1 | 725 | 20 | sí | no |
| 5682 | Libram: Turn Undead II | 1 | 4500 | 38 | sí | no |
| 5683 | Libram: Divine Shield II | 1 | 8750 | 50 | sí | no |
| 5684 | Libram: Seal of Salvation | 1 | 1050 | 22 | sí | no |
| 5685 | Libram: Redemption | 1 | 5000 | 40 | sí | no |
| 5688 | Test Language Item | 1 | 0 | 0 | no | no |
| 5696 | Tablet of Shock | 1 | 20 | 4 | sí | no |
| 5697 | Tablet of Healing Totem | 1 | 50 | 6 | sí | no |
| 5698 | Tablet of Lightning Shield | 1 | 50 | 8 | sí | no |
| 5699 | Tablet of Ghost Wolf | 1 | 250 | 12 | sí | no |
| 5700 | Tablet of Healing Totem II | 1 | 250 | 12 | sí | no |
| 5701 | Tablet of Sentry Totem | 1 | 325 | 14 | sí | no |
| 5702 | Tablet of Agitating Totem II | 1 | 625 | 18 | sí | no |
| 5703 | Tablet of Thunderclap | 1 | 750 | 20 | sí | no |
| 5704 | Tablet of Water Breathing | 1 | 750 | 20 | sí | no |
| 5705 | Tablet of Healing Totem III | 1 | 750 | 20 | sí | no |
| 5706 | Tablet of Serpent Totem III | 1 | 750 | 20 | sí | no |
| 5707 | Tablet of Far Sight | 1 | 1675 | 26 | sí | no |
| 5708 | Tablet of Ethereal Form | 1 | 1250 | 24 | sí | no |
| 5709 | Tablet of Water Walking | 1 | 1750 | 28 | sí | no |
| 5710 | Tablet of Healing Totem IV | 1 | 1750 | 28 | sí | no |
| 5711 | Tablet of Ghost Wolf II | 1 | 2000 | 30 | sí | no |
| 5712 | Tablet of Serpent Totem IV | 1 | 2000 | 30 | sí | no |
| 5713 | Tablet of Thunderbolt | 1 | 2500 | 32 | sí | no |
| 5714 | Tablet of Ensnaring Totem II | 1 | 3000 | 34 | no | no |
| 5715 | Tablet of Lightning Storm III | 1 | 5000 | 40 | sí | no |
| 5716 | Tablet of Restoration VI | 1 | 5000 | 40 | sí | no |
| 5719 | Grimoire of Life Drain II | 1 | 1050 | 22 | sí | no |
| 5720 | Grimoire of Curse of Mannoroth II | 1 | 750 | 20 | sí | no |
| 5721 | Grimoire of Create Spellstone | 1 | 3000 | 34 | sí | no |
| 5722 | Grimoire of Siphon Mana II | 1 | 4500 | 36 | sí | no |
| 5723 | Grimoire of Curse of Sargeras III | 1 | 3750 | 36 | sí | no |
| 5724 | Grimoire of Curse of Tongues | 1 | 1050 | 22 | sí | no |
| 5725 | Grimoire of Pestilence III | 1 | 4250 | 38 | sí | no |
| 5726 | Grimoire of Create Greater Bloodstone | 1 | 4250 | 38 | sí | no |
| 5727 | Grimoire of Mana Funnel | 1 | 5000 | 40 | sí | no |
| 5728 | Grimoire of Rain of Fire II | 1 | 5000 | 40 | sí | no |
| 5729 | Grimoire of Fear III | 1 | 5000 | 40 | sí | no |
| 5730 | Book of Rejuvenation | 1 | 10 | 4 | sí | no |
| 6132 | Libram: Seal of Wisdom | 1 | 250 | 12 | sí | no |
| 6133 | Libram: Seal of Fury | 1 | 225 | 14 | sí | no |
| 6619 | Manual: The Path of Defense | 1 | 0 | 10 | sí | no |
| 6621 | Manual of Taunt | 1 | 0 | 10 | sí | no |
| 6897 | Manual: Path of the Berserker | 1 | 0 | 30 | sí | no |
| 8046 | Kearnen's Journal | 1 | 0 | 0 | no | no |
| 8743 | Book of Mark of the Wild | 1 | 2 | 1 | sí | no |
| 8744 | Book of Wrath | 1 | 50 | 6 | sí | no |
| 8745 | Book of Healing Touch | 1 | 50 | 8 | sí | no |
| 8756 | Book of Regrowth II | 1 | 550 | 18 | sí | no |
| 8757 | Book of Starfire | 1 | 725 | 20 | sí | no |
| 8758 | Book of Remove Curse | 1 | 1050 | 22 | no | no |
| 8759 | Book of Regrowth III | 1 | 1325 | 24 | sí | no |
| 8760 | Book of Abolish Poison | 1 | 1675 | 26 | sí | no |
| 8761 | Book of Starfire II | 1 | 1675 | 26 | sí | no |
| 8762 | Book of Rejuvenation V | 1 | 2025 | 28 | sí | no |
| 8763 | Book of Moonfire V | 1 | 2025 | 28 | sí | no |
| 8764 | Book of Faerie Fire II | 1 | 2425 | 30 | sí | no |
| 8765 | Book of Regrowth IV | 1 | 2425 | 30 | sí | no |
| 8768 | Book of Starfire III | 1 | 3250 | 34 | sí | no |
| 8769 | Book of Thorns IV | 1 | 3250 | 34 | sí | no |
| 8770 | Book of Moonfire VI | 1 | 3250 | 34 | sí | no |
| 8771 | Book of Rejuvenation VI | 1 | 3250 | 34 | sí | no |
| 8772 | Book of Regrowth V | 1 | 3750 | 36 | sí | no |
| 8773 | Book of Entangling Roots V | 1 | 7750 | 48 | sí | no |
| 8774 | Book of Healing Touch VII | 1 | 4500 | 38 | sí | no |
| 8775 | Book of Tranquility II | 1 | 5000 | 40 | sí | no |
| 8776 | Book of Mark of the Wild VI | 1 | 8750 | 50 | sí | no |
| 8777 | Book of Moonfire IX | 1 | 10000 | 52 | sí | no |
| 8778 | Book of Rejuvenation VII | 1 | 5000 | 40 | sí | no |
| 8779 | Book of Faerie Fire III | 1 | 5500 | 42 | sí | no |
| 8780 | Book of Starfire V | 1 | 8750 | 50 | sí | no |
| 8781 | Book of Regrowth VII | 1 | 7750 | 48 | sí | no |
| 8782 | Book of Thorns V | 1 | 6250 | 44 | sí | no |
| 8783 | Book of Healing Touch IX | 1 | 8750 | 50 | sí | no |
| 8784 | Book of Wrath VII | 1 | 7000 | 46 | sí | no |
| 8785 | Book of Rejuvenation IX | 1 | 10000 | 52 | sí | no |
| 8786 | Book of Tranquility III | 1 | 8750 | 50 | sí | no |
| 8787 | Book of Soothe Animal | 1 | 1050 | 22 | sí | no |
| 8788 | Book of Soothe Animal II | 1 | 4500 | 38 | sí | no |
| 8789 | Book of Soothe Animal III | 1 | 11000 | 54 | sí | no |
| 8790 | Book of Faerie Fire IV | 1 | 11000 | 54 | sí | no |
| 8791 | Book of Regrowth VIII | 1 | 11000 | 54 | sí | no |
| 8792 | Book of Thorns VI | 1 | 11000 | 54 | sí | no |
| 8793 | Book of Wrath VIII | 1 | 7000 | 54 | sí | no |
| 8794 | Book of Healing Touch X | 1 | 12000 | 56 | sí | no |
| 8795 | Book of Entangling Roots VI | 1 | 13250 | 58 | sí | no |
| 8796 | Book of Moonfire X | 1 | 13250 | 58 | sí | no |
| 8797 | Book of Rejuvenation X | 1 | 13250 | 58 | sí | no |
| 8798 | Book of Starfire VI | 1 | 13250 | 58 | sí | no |
| 8799 | Book of Mark of the Wild VII | 1 | 14750 | 60 | sí | no |
| 8800 | Book of Regrowth IX | 1 | 14750 | 60 | sí | no |
| 8801 | Book of Tranquility IV | 1 | 14750 | 60 | sí | no |
| 8802 | Tome of Arcane Intellect | 1 | 2 | 1 | sí | no |
| 8803 | Tome of Fireball | 1 | 20 | 6 | sí | no |
| 8804 | Tome of Arcane Explosion | 1 | 225 | 14 | sí | no |
| 8805 | Tome of Detect Magic | 1 | 325 | 16 | sí | no |
| 8806 | Tome of Remove Lesser Curse | 1 | 550 | 18 | sí | no |
| 8807 | Tome of Amplify Magic | 1 | 550 | 18 | sí | no |
| 8808 | Tome of Mana Shield | 1 | 725 | 20 | sí | no |
| 8809 | Tome of Sleep | 1 | 50 | 8 | sí | no |
| 8810 | Tome of Sleep II | 1 | 725 | 20 | sí | no |
| 8811 | Tome of Scorch | 1 | 1050 | 22 | sí | no |
| 8812 | Tome of Arcane Explosion II | 1 | 1050 | 22 | sí | no |
| 8813 | Tome of Dampen Magic II | 1 | 1325 | 24 | sí | no |
| 8814 | Tome of Fireball V | 1 | 1325 | 24 | sí | no |
| 8815 | Tome of Cone of Cold | 1 | 1675 | 26 | sí | no |
| 8816 | Tome of Frostbolt V | 1 | 1675 | 26 | sí | no |
| 8818 | Tome of Mana Shield II | 1 | 2025 | 28 | sí | no |
| 8819 | Tome of Scorch II | 1 | 2025 | 28 | sí | no |
| 8820 | Tome of Fire Ward II | 1 | 2425 | 30 | sí | no |
| 8821 | Tome of Amplify Magic II | 1 | 2425 | 30 | sí | no |
| 8822 | Tome of Arcane Explosion III | 1 | 1050 | 30 | sí | no |
| 8823 | Tome of Fire Blast IV | 1 | 2425 | 30 | sí | no |
| 8824 | Tome of Fireball VI | 1 | 2425 | 30 | sí | no |
| 8825 | Tome of Frost Ward III | 1 | 5500 | 42 | sí | no |
| 8826 | Tome of Arcane Missiles IV | 1 | 2750 | 32 | sí | no |
| 8828 | Tome of Frostbolt VI | 1 | 2750 | 32 | sí | no |
| 8829 | Tome of Cone of Cold II | 1 | 3250 | 34 | sí | no |
| 8830 | Tome of Scorch III | 1 | 2750 | 34 | sí | no |
| 8832 | Tome of Blizzard III | 1 | 3750 | 36 | sí | no |
| 8833 | Tome of Mana Shield III | 1 | 3750 | 36 | sí | no |
| 8834 | Tome of Dampen Magic III | 1 | 3750 | 36 | sí | no |
| 8835 | Tome of Fireball VII | 1 | 3750 | 36 | sí | no |
| 8837 | Tome of Arcane Explosion V | 1 | 7000 | 46 | sí | no |
| 8840 | Tome of Conjure Mana Gem II | 1 | 4500 | 38 | sí | no |
| 8841 | Tome of Fire Blast V | 1 | 4500 | 38 | sí | no |
| 8842 | Tome of Frostbolt VII | 1 | 4500 | 38 | sí | no |
| 8843 | Tome of Fire Ward III | 1 | 5000 | 40 | sí | no |
| 8844 | Tome of Sleep III | 1 | 5000 | 40 | sí | no |
| 8847 | Tome of Scorch V | 1 | 7000 | 46 | sí | no |
| 8848 | Tome of Flamestrike IV | 1 | 5000 | 40 | sí | no |
| 8849 | Tome of Arcane Missiles V | 1 | 5000 | 40 | sí | no |
| 8850 | Tome of Conjure Water V | 1 | 5000 | 40 | sí | no |
| 8851 | Tome of Fireball VIII | 1 | 5500 | 42 | sí | no |
| 8852 | Tome of Arcane Intellect IV | 1 | 5500 | 42 | sí | no |
| 8853 | Tome of Conjure Food V | 1 | 5500 | 42 | sí | no |
| 8854 | Tome of Cone of Cold III | 1 | 5500 | 42 | sí | no |
| 8855 | Tome of Amplify Magic III | 1 | 5500 | 42 | sí | no |
| 8856 | Tome of Frostbolt VIII | 1 | 6250 | 44 | sí | no |
| 8857 | Tome of Blizzard IV | 1 | 6250 | 44 | sí | no |
| 8858 | Tome of Mana Shield IV | 1 | 6250 | 44 | sí | no |
| 8859 | Tome of Fire Blast VI | 1 | 7000 | 46 | sí | no |
| 8860 | Tome of Fireball IX | 1 | 7750 | 48 | sí | no |
| 8861 | Tome of Conjure Mana Gem III | 1 | 7750 | 48 | sí | no |
| 8862 | Tome of Arcane Missiles VI | 1 | 7750 | 48 | sí | no |
| 8863 | Tome of Dampen Magic IV | 1 | 7750 | 48 | sí | no |
| 8864 | Tome of Flamestrike V | 1 | 7750 | 48 | sí | no |
| 8865 | Tome of Ice Armor III | 1 | 8750 | 50 | sí | no |
| 8866 | Tome of Cone of Cold IV | 1 | 8750 | 50 | sí | no |
| 8867 | Tome of Frostbolt IX | 1 | 8750 | 50 | sí | no |
| 8868 | Tome of Conjure Water VI | 1 | 8750 | 50 | sí | no |
| 8869 | Tome of Fire Ward IV | 1 | 8750 | 50 | sí | no |
| 8870 | Tome of Greater Invisibility | 1 | 8750 | 50 | sí | no |
| 8871 | Tome of Conjure Food VI | 1 | 10000 | 52 | sí | no |
| 8872 | Tome of Blizzard V | 1 | 10000 | 52 | sí | no |
| 8873 | Tome of Mana Shield V | 1 | 10000 | 52 | sí | no |
| 8874 | Tome of Scorch VI | 1 | 10000 | 52 | sí | no |
| 8875 | Tome of Frost Ward IV | 1 | 10000 | 52 | sí | no |
| 8876 | Tome of Frost Ward II | 1 | 2750 | 32 | sí | no |
| 8877 | Tome of Fireball X | 1 | 11000 | 54 | sí | no |
| 8878 | Tome of Fire Blast VII | 1 | 11000 | 54 | sí | no |
| 8879 | Tome of Frost Nova IV | 1 | 11000 | 54 | sí | no |
| 8880 | Tome of Arcane Explosion VI | 1 | 11000 | 54 | sí | no |
| 8881 | Tome of Khadgar's Unlocking IV | 1 | 11000 | 54 | sí | no |
| 8882 | Tome of Amplify Magic IV | 1 | 11000 | 54 | sí | no |
| 8883 | Tome of Arcane Intellect V | 1 | 12000 | 56 | sí | no |
| 8884 | Tome of Frostbolt X | 1 | 12000 | 56 | sí | no |
| 8885 | Tome of Arcane Missiles VII | 1 | 12000 | 56 | sí | no |
| 8886 | Tome of Flamestrike VI | 1 | 12000 | 56 | sí | no |
| 8887 | Tome of Scorch VII | 1 | 13250 | 58 | sí | no |
| 8888 | Tome of Cone of Cold V | 1 | 13250 | 58 | sí | no |
| 8889 | Tome of Conjure Mana Gem IV | 1 | 13250 | 58 | sí | no |
| 8890 | Tome of Fireball XI | 1 | 14750 | 60 | sí | no |
| 8891 | Tome of Ice Armor IV | 1 | 14750 | 60 | sí | no |
| 8892 | Tome of Conjure Water VII | 1 | 14750 | 60 | sí | no |
| 8893 | Tome of Sleep IV | 1 | 14750 | 60 | sí | no |
| 8894 | Tome of Dampen Magic V | 1 | 14750 | 60 | sí | no |
| 8895 | Tome of Blizzard VI | 1 | 14750 | 60 | sí | no |
| 8896 | Tome of Mana Shield VI | 1 | 14750 | 60 | sí | no |
| 8897 | Tome of Fire Ward V | 1 | 14750 | 60 | sí | no |
| 8898 | Tome of Arcane Explosion IV | 1 | 4500 | 38 | sí | no |
| 8899 | Tome of Scorch IV | 1 | 5000 | 40 | sí | no |
| 8900 | Book of Entangling Roots IV | 1 | 4500 | 38 | sí | no |
| 8901 | Book of Healing Touch VIII | 1 | 6250 | 44 | sí | no |
| 8902 | Book of Mark of the Wild V | 1 | 5000 | 40 | sí | no |
| 8903 | Book of Moonfire VII | 1 | 5000 | 40 | sí | no |
| 8904 | Book of Moonfire VIII | 1 | 7000 | 46 | sí | no |
| 8905 | Book of Regrowth VI | 1 | 5500 | 42 | sí | no |
| 8906 | Book of Rejuvenation VIII | 1 | 6250 | 46 | sí | no |
| 8907 | Book of Starfire IV | 1 | 5500 | 42 | sí | no |
| 8909 | Libram: Holy Strike II | 1 | 50 | 8 | sí | no |
| 8910 | Libram: Lay on Hands | 1 | 75 | 10 | sí | no |
| 8911 | Libram: Fist of Justice | 1 | 75 | 10 | sí | no |
| 8912 | Libram: Crusader Strike | 1 | 75 | 10 | sí | no |
| 8913 | Libram: Holy Strike III | 1 | 325 | 16 | sí | no |
| 8914 | Libram: Crusader Strike II | 1 | 1050 | 22 | sí | no |
| 8915 | Libram: Holy Strike IV | 1 | 1325 | 24 | sí | no |
| 8916 | Libram: Fist of Justice II | 1 | 1675 | 26 | sí | no |
| 8917 | Libram: Lay on Hands II | 1 | 2425 | 30 | sí | no |
| 8918 | Libram: Seal of Protection III | 1 | 2425 | 30 | sí | no |
| 8919 | Libram: Holy Strike V | 1 | 2750 | 32 | sí | no |
| 8920 | Libram: Crusader Strike III | 1 | 3250 | 34 | sí | no |
| 8921 | Libram: Fist of Justice III | 1 | 5000 | 40 | sí | no |
| 8922 | Libram: Holy Strike VI | 1 | 5000 | 40 | sí | no |
| 8929 | Libram: Exorcism IV | 1 | 6250 | 44 | sí | no |
| 8930 | Libram: Seal of Righteousness IV | 1 | 7000 | 46 | sí | no |
| 8931 | Libram: Crusader Strike IV | 1 | 7000 | 46 | sí | no |
| 8933 | Libram: Holy Light VII | 1 | 7000 | 46 | sí | no |
| 8934 | Libram: Holy Strike VII | 1 | 7750 | 48 | sí | no |
| 8935 | Libram: Judgement II | 1 | 8750 | 50 | sí | no |
| 8936 | Libram: Seal of Wrath III | 1 | 8750 | 50 | sí | no |
| 8937 | Libram: Lay on Hands III | 1 | 8750 | 50 | sí | no |
| 8938 | Libram: Turn Undead III | 1 | 10000 | 52 | sí | no |
| 8939 | Libram: Exorcism V | 1 | 10000 | 52 | sí | no |
| 8940 | Libram: Fist of Justice IV | 1 | 11000 | 54 | sí | no |
| 8941 | Libram: Holy Light VIII | 1 | 11000 | 54 | sí | no |
| 8942 | Libram: Seal of Righteousness V | 1 | 12000 | 56 | sí | no |
| 8943 | Libram: Holy Strike VIII | 1 | 12000 | 56 | sí | no |
| 8944 | Libram: Crusader Strike V | 1 | 13250 | 58 | sí | no |
| 8945 | Libram: Judgement III | 1 | 14750 | 60 | sí | no |
| 8947 | Libram: Exorcism VI | 1 | 14750 | 60 | sí | no |
| 8954 | Codex of Holy Word: Fortitude | 1 | 2 | 1 | sí | no |
| 8955 | Codex of Fade | 1 | 50 | 8 | sí | no |
| 8958 | Codex of Mind Blast | 1 | 75 | 10 | sí | no |
| 8960 | Codex of Cure Disease | 1 | 225 | 14 | sí | no |
| 8961 | Codex of Psychic Scream | 1 | 225 | 14 | sí | no |
| 8962 | Codex of Mind Blast II | 1 | 325 | 16 | sí | no |
| 8963 | Codex of Mind Soothe | 1 | 725 | 20 | sí | no |
| 8964 | Codex of Flash Heal | 1 | 725 | 20 | sí | no |
| 8965 | Codex of Fade II | 1 | 725 | 20 | sí | no |
| 8966 | Codex of Shackle Undead | 1 | 725 | 20 | sí | no |
| 8967 | Codex of Mind Blast III | 1 | 1050 | 22 | sí | no |
| 8968 | Codex of Mana Burn | 1 | 1325 | 24 | sí | no |
| 8969 | Codex of Flash Heal II | 1 | 1675 | 26 | sí | no |
| 8971 | Codex of Psychic Scream II | 1 | 2025 | 28 | sí | no |
| 8972 | Codex of Mind Blast IV | 1 | 2025 | 28 | sí | no |
| 8974 | Codex of Mind Control | 1 | 2425 | 30 | sí | no |
| 8975 | Codex of Fade III | 1 | 2425 | 30 | sí | no |
| 8976 | Codex of Abolish Disease | 1 | 2750 | 32 | sí | no |
| 8977 | Codex of Mana Burn II | 1 | 2750 | 32 | sí | no |
| 8978 | Codex of Flash Heal III | 1 | 2750 | 32 | sí | no |
| 8980 | Codex of Mind Blast V | 1 | 3250 | 34 | sí | no |
| 8981 | Codex of Mind Soothe II | 1 | 3750 | 36 | sí | no |
| 8983 | Codex of Flash Heal IV | 1 | 4500 | 38 | sí | no |
| 8986 | Codex of Shackle Undead II | 1 | 5000 | 40 | sí | no |
| 8987 | Codex of Holy Protection II | 1 | 5000 | 40 | sí | no |
| 8988 | Codex of Mana Burn III | 1 | 5000 | 40 | sí | no |
| 8989 | Codex of Fade IV | 1 | 5000 | 40 | sí | no |
| 8990 | Codex of Mind Blast VI | 1 | 5000 | 40 | sí | no |
| 8991 | Codex of Inner Fire IV | 1 | 5000 | 40 | sí | no |
| 8992 | Codex of Psychic Scream III | 1 | 5500 | 42 | sí | no |
| 8993 | Codex of Shadow Protection II | 1 | 5500 | 42 | sí | no |
| 8994 | Codex of Shadow Word: Pain VI | 1 | 5500 | 42 | sí | no |
| 8995 | Codex of Holy Word: Shield VII | 1 | 5500 | 42 | sí | no |
| 8996 | Codex of Resurrection III | 1 | 5500 | 42 | sí | no |
| 8997 | Codex of Mind Control II | 1 | 6250 | 44 | sí | no |
| 8998 | Codex of Mind Vision II | 1 | 6250 | 44 | sí | no |
| 8999 | Codex of Flash Heal V | 1 | 6250 | 44 | sí | no |
| 9000 | Codex of Renew VII | 1 | 6250 | 44 | sí | no |
| 9001 | Codex of Greater Heal II | 1 | 7000 | 46 | sí | no |
| 9002 | Codex of Mind Blast VII | 1 | 7000 | 46 | sí | no |
| 9003 | Codex of Holy Smite VII | 1 | 7000 | 46 | sí | no |
| 9004 | Codex of Holy Word: Fortitude V | 1 | 7750 | 48 | sí | no |
| 9005 | Codex of Mana Burn IV | 1 | 7750 | 48 | sí | no |
| 9006 | Codex of Holy Word: Shield VIII | 1 | 7750 | 48 | sí | no |
| 9007 | Codex of Fade V | 1 | 8750 | 50 | sí | no |
| 9008 | Codex of Prayer of Healing III | 1 | 8750 | 50 | sí | no |
| 9009 | Codex of Inner Fire V | 1 | 8750 | 50 | sí | no |
| 9010 | Codex of Flash Heal VI | 1 | 8750 | 50 | sí | no |
| 9011 | Codex of Shadow Word: Pain VII | 1 | 8750 | 50 | sí | no |
| 9012 | Codex of Renew VIII | 1 | 8750 | 50 | sí | no |
| 9013 | Codex of Greater Heal III | 1 | 10000 | 52 | sí | no |
| 9014 | Codex of Mind Soothe III | 1 | 10000 | 52 | sí | no |
| 9015 | Codex of Mind Blast VIII | 1 | 10000 | 52 | sí | no |
| 9016 | Codex of Holy Smite VIII | 1 | 11000 | 54 | sí | no |
| 9017 | Codex of Holy Protection III | 1 | 11000 | 54 | sí | no |
| 9018 | Codex of Holy Word: Shield IX | 1 | 11000 | 54 | sí | no |
| 9019 | Codex of Renew IX | 1 | 12000 | 56 | sí | no |
| 9020 | Codex of Psychic Scream IV | 1 | 12000 | 56 | sí | no |
| 9021 | Codex of Mana Burn V | 1 | 12000 | 56 | sí | no |
| 9022 | Codex of Flash Heal VII | 1 | 12000 | 56 | sí | no |
| 9023 | Codex of Shadow Protection III | 1 | 12000 | 56 | sí | no |
| 9024 | Codex of Mind Control III | 1 | 13250 | 58 | sí | no |
| 9025 | Codex of Greater Heal IV | 1 | 13250 | 58 | sí | no |
| 9026 | Codex of Resurrection IV | 1 | 13250 | 58 | sí | no |
| 9027 | Codex of Mind Blast IX | 1 | 13250 | 58 | sí | no |
| 9028 | Codex of Shadow Word: Pain VIII | 1 | 13250 | 58 | sí | no |
| 9029 | Codex of Fade VI | 1 | 14750 | 60 | sí | no |
| 9031 | Codex of Shackle Undead III | 1 | 14750 | 60 | sí | no |
| 9032 | Codex of Prayer of Healing IV | 1 | 14750 | 60 | sí | no |
| 9033 | Codex of Inner Fire VI | 1 | 14750 | 60 | sí | no |
| 9034 | Codex of Holy Word: Fortitude VI | 1 | 14750 | 60 | sí | no |
| 9035 | Codex of Holy Word: Shield X | 1 | 14750 | 60 | sí | no |
| 9037 | Tablet of Rockbiter Weapon | 1 | 2 | 1 | sí | no |
| 9039 | Tablet of Earth Shock | 1 | 10 | 4 | sí | no |
| 9040 | Tablet of Healing Wave II | 1 | 20 | 6 | sí | no |
| 9041 | Tablet of Earthbind Totem | 1 | 20 | 6 | sí | no |
| 9043 | Tablet of Stoneclaw Totem | 1 | 50 | 8 | sí | no |
| 9044 | Tablet of Earth Shock II | 1 | 50 | 8 | sí | no |
| 9046 | Tablet of Strength of Earth Totem | 1 | 75 | 10 | sí | no |
| 9047 | Tablet of Flame Shock | 1 | 75 | 10 | sí | no |
| 9048 | Tablet of Rebirth | 1 | 150 | 12 | sí | no |
| 9049 | Tablet of Fire Nova Totem | 1 | 150 | 12 | sí | no |
| 9050 | Tablet of Healing Wave III | 1 | 150 | 12 | sí | no |
| 9051 | Tablet of Earth Shock III | 1 | 225 | 14 | sí | no |
| 9052 | Tablet of Stoneskin Totem II | 1 | 225 | 14 | sí | no |
| 9053 | Tablet of Rockbiter Weapon II | 1 | 325 | 16 | sí | no |
| 9054 | Tablet of Flame Shock II | 1 | 550 | 18 | sí | no |
| 9055 | Tablet of Stoneclaw Totem II | 1 | 550 | 18 | sí | no |
| 9056 | Tablet of Healing Wave IV | 1 | 550 | 18 | sí | no |
| 9057 | Tablet of Frostbrand Weapon | 1 | 725 | 20 | sí | no |
| 9058 | Tablet of Frost Shock | 1 | 725 | 20 | sí | no |
| 9059 | Tablet of Flametongue Weapon | 1 | 75 | 10 | sí | no |
| 9062 | Tablet of Cure Disease | 1 | 1050 | 22 | sí | no |
| 9063 | Tablet of Poison Cleansing Totem | 1 | 1050 | 22 | sí | no |
| 9064 | Tablet of Flametongue Weapon II | 1 | 1050 | 22 | sí | no |
| 9065 | Tablet of Fire Nova Totem II | 1 | 1050 | 22 | sí | no |
| 9066 | Tablet of Frost Resistance Totem | 1 | 1325 | 24 | sí | no |
| 9067 | Tablet of Strength of Earth Totem II | 1 | 1325 | 24 | sí | no |
| 9068 | Tablet of Stoneskin Totem III | 1 | 1325 | 24 | sí | no |
| 9069 | Tablet of Earth Shock IV | 1 | 1325 | 24 | sí | no |
| 9070 | Tablet of Healing Wave V | 1 | 1325 | 24 | sí | no |
| 9071 | Tablet of Mana Font Totem | 1 | 1675 | 26 | sí | no |
| 9072 | Tablet of Flametongue Totem | 1 | 1675 | 26 | sí | no |
| 9073 | Tablet of Windfury Weapon | 1 | 1675 | 26 | sí | no |
| 9074 | Tablet of Flame Shock III | 1 | 2025 | 28 | sí | no |
| 9075 | Tablet of Fire Resistance Totem | 1 | 550 | 18 | sí | no |
| 9076 | Tablet of Magma Totem | 1 | 550 | 18 | sí | no |
| 9077 | Tablet of Stoneclaw Totem III | 1 | 550 | 18 | sí | no |
| 9078 | Tablet of Grounding Totem | 1 | 2425 | 30 | sí | no |
| 9079 | Tablet of Lightning Shock | 1 | 2425 | 30 | sí | no |
| 9080 | Tablet of Nature Resistance Totem | 1 | 2425 | 30 | sí | no |
| 9081 | Tablet of Healing Stream Totem II | 1 | 2425 | 30 | sí | no |
| 9082 | Tablet of Rockbiter Weapon III | 1 | 2425 | 30 | sí | no |
| 9083 | Tablet of Searing Totem III | 1 | 2425 | 30 | sí | no |
| 9084 | Tablet of Windfury Totem | 1 | 2750 | 32 | sí | no |
| 9085 | Tablet of Fire Nova Totem III | 1 | 2750 | 32 | sí | no |
| 9086 | Tablet of Healing Wave VI | 1 | 2750 | 32 | sí | no |
| 9087 | Tablet of Purge II | 1 | 2750 | 32 | sí | no |
| 9089 | Tablet of Frost Shock II | 1 | 3250 | 34 | sí | no |
| 9090 | Tablet of Frostbrand Weapon II | 1 | 3250 | 34 | sí | no |
| 9091 | Tablet of Stoneskin Totem IV | 1 | 3250 | 34 | sí | no |
| 9092 | Tablet of Sentry Totem | 1 | 3250 | 34 | sí | no |
| 9093 | Tablet of Mana Font Totem II | 1 | 3750 | 36 | sí | no |
| 9094 | Tablet of Flametongue Weapon III | 1 | 3750 | 36 | sí | no |
| 9095 | Tablet of Earth Shock V | 1 | 3750 | 36 | sí | no |
| 9096 | Tablet of Disease Cleansing Totem | 1 | 4500 | 38 | sí | no |
| 9097 | Tablet of Magma Totem II | 1 | 4500 | 38 | sí | no |
| 9098 | Tablet of Strength of Earth Totem III | 1 | 4500 | 38 | sí | no |
| 9099 | Tablet of Stoneclaw Totem IV | 1 | 4500 | 38 | sí | no |
| 9100 | Tablet of Lightning Shield V | 1 | 5000 | 40 | sí | no |
| 9101 | Tablet of Windfury Weapon II | 1 | 5000 | 40 | sí | no |
| 9102 | Tablet of Chain Lightning II | 1 | 5000 | 40 | sí | no |
| 9103 | Tablet of Healing Stream Totem III | 1 | 5000 | 40 | sí | no |
| 9104 | Tablet of Searing Totem IV | 1 | 5000 | 40 | sí | no |
| 9105 | Tablet of Healing Wave VII | 1 | 5000 | 40 | sí | no |
| 9123 | Tablet of Lightning Bolt VI | 1 | 5500 | 42 | sí | no |
| 9124 | Tablet of Lightning Shock II | 1 | 5500 | 42 | sí | no |
| 9125 | Tablet of Grace of Air Totem | 1 | 5500 | 42 | sí | no |
| 9126 | Tablet of Flametongue Totem II | 1 | 5500 | 42 | sí | no |
| 9127 | Tablet of Fire Resistance Totem II | 1 | 5500 | 42 | sí | no |
| 9128 | Tablet of Fire Nova Totem IV | 1 | 5500 | 42 | sí | no |
| 9129 | Tablet of Rockbiter Weapon IV | 1 | 6250 | 44 | sí | no |
| 9130 | Tablet of Nature Resistance Totem II | 1 | 6250 | 44 | sí | no |
| 9131 | Tablet of Stoneskin Totem V | 1 | 6250 | 44 | sí | no |
| 9132 | Tablet of Molten Blast VI | 1 | 7000 | 46 | sí | no |
| 9133 | Tablet of Chain Heal II | 1 | 7000 | 46 | sí | no |
| 9134 | Tablet of Windfury Totem II | 1 | 7000 | 46 | sí | no |
| 9135 | Tablet of Frost Shock III | 1 | 7000 | 46 | sí | no |
| 9136 | Tablet of Mana Font Totem III | 1 | 7000 | 46 | sí | no |
| 9137 | Tablet of Lightning Shield VI | 1 | 7750 | 48 | sí | no |
| 9138 | Tablet of Magma Totem III | 1 | 7750 | 48 | sí | no |
| 9139 | Tablet of Frostbrand Weapon III | 1 | 7750 | 48 | sí | no |
| 9140 | Tablet of Chain Lightning III | 1 | 7750 | 48 | sí | no |
| 9141 | Tablet of Stoneclaw Totem V | 1 | 7750 | 48 | sí | no |
| 9142 | Tablet of Earth Shock VI | 1 | 7750 | 48 | sí | no |
| 9143 | Tablet of Healing Wave VIII | 1 | 7750 | 48 | sí | no |
| 9145 | Tablet of Lightning Bolt VII | 1 | 8750 | 50 | sí | no |
| 9146 | Tablet of Searing Totem V | 1 | 8750 | 50 | sí | no |
| 9147 | Tablet of Healing Stream Totem IV | 1 | 8750 | 50 | sí | no |
| 9148 | Tablet of Flametongue Weapon IV | 1 | 8750 | 50 | sí | no |
| 9150 | Tablet of Strength of Earth Totem IV | 1 | 10000 | 52 | sí | no |
| 9151 | Tablet of Flame Shock V | 1 | 10000 | 52 | sí | no |
| 9152 | Tablet of Fire Nova Totem V | 1 | 10000 | 52 | sí | no |
| 9156 | Tablet of Molten Blast VII | 1 | 8750 | 54 | sí | no |
| 9157 | Tablet of Chain Heal III | 1 | 8750 | 54 | sí | no |
| 9158 | Tablet of Frost Resistance Totem III | 1 | 8750 | 54 | sí | no |
| 9159 | Tablet of Lightning Shock III | 1 | 8750 | 54 | sí | no |
| 9160 | Tablet of Windfury Weapon III | 1 | 8750 | 54 | sí | no |
| 9161 | Tablet of Stoneskin Totem VI | 1 | 8750 | 54 | sí | no |
| 9162 | Tablet of Lightning Shield VII | 1 | 12000 | 56 | sí | no |
| 9164 | Tablet of Grace of Air Totem II | 1 | 12000 | 56 | sí | no |
| 9165 | Tablet of Flametongue Totem III | 1 | 12000 | 56 | sí | no |
| 9166 | Tablet of Mana Font Totem IV | 1 | 12000 | 56 | sí | no |
| 9167 | Tablet of Chain Lightning IV | 1 | 12000 | 56 | sí | no |
| 9168 | Tablet of Healing Wave IX | 1 | 12000 | 56 | sí | no |
| 9169 | Tablet of Lightning Bolt VIII | 1 | 13250 | 58 | sí | no |
| 9170 | Tablet of Fire Resistance Totem III | 1 | 13250 | 58 | sí | no |
| 9171 | Tablet of Magma Totem IV | 1 | 13250 | 58 | sí | no |
| 9174 | Tablet of Frost Shock IV | 1 | 13250 | 58 | sí | no |
| 9175 | Tablet of Rockbiter Weapon V | 1 | 13250 | 58 | sí | no |
| 9176 | Tablet of Stoneclaw Totem VI | 1 | 13250 | 58 | sí | no |
| 9177 | Tablet of Earth Shock VII | 1 | 14750 | 60 | sí | no |
| 9178 | Tablet of Nature Resistance Totem III | 1 | 14750 | 60 | sí | no |
| 9180 | Tablet of Windfury Totem III | 1 | 14750 | 60 | sí | no |
| 9181 | Tablet of Healing Stream Totem V | 1 | 14750 | 60 | sí | no |
| 9182 | Tablet of Searing Totem VI | 1 | 14750 | 60 | sí | no |
| 9183 | Tablet of Chain Heal | 1 | 5000 | 40 | sí | no |
| 9184 | Tablet of Flame Shock IV | 1 | 5000 | 40 | sí | no |
| 9185 | Tablet of Frost Resistance Totem II | 1 | 4500 | 38 | sí | no |
| 9188 | Tablet of Searing Totem II | 1 | 725 | 20 | sí | no |
| 9190 | Grimoire of Immolate | 1 | 2 | 1 | sí | no |
| 9191 | Grimoire of Curse of Weakness | 1 | 10 | 4 | sí | no |
| 9192 | Grimoire of Corruption | 1 | 10 | 4 | sí | no |
| 9193 | Grimoire of Life Tap | 1 | 25 | 6 | sí | no |
| 9194 | Grimoire of Curse of Agony | 1 | 50 | 8 | sí | no |
| 9195 | Grimoire of Drain Soul | 1 | 75 | 10 | sí | no |
| 9198 | Grimoire of Health Funnel | 1 | 150 | 12 | sí | no |
| 9199 | Grimoire of Curse of Recklessness | 1 | 150 | 12 | sí | no |
| 9200 | Grimoire of Curse of Weakness II | 1 | 225 | 14 | sí | no |
| 9201 | Grimoire of Corruption II | 1 | 325 | 16 | sí | no |
| 9202 | Grimoire of Life Tap II | 1 | 550 | 18 | sí | no |
| 9203 | Grimoire of Ritual of Summoning | 1 | 725 | 20 | sí | no |
| 9204 | Grimoire of Health Funnel II | 1 | 725 | 20 | sí | no |
| 9205 | Grimoire of Curse of Agony II | 1 | 725 | 20 | sí | no |
| 9207 | Grimoire of Create Bloodstone II | 1 | 1325 | 24 | sí | no |
| 9208 | Grimoire of Drain Soul II | 1 | 1325 | 24 | sí | no |
| 9209 | Grimoire of Curse of Weakness III | 1 | 1325 | 24 | sí | no |
| 9211 | Grimoire of Curse of Recklessness II | 1 | 1675 | 26 | sí | no |
| 9212 | Grimoire of Shadow Bolt V | 1 | 2025 | 28 | sí | no |
| 9215 | Grimoire of Health Funnel III | 1 | 2025 | 28 | sí | no |
| 9216 | Grimoire of Corruption III | 1 | 2025 | 28 | sí | no |
| 9217 | Grimoire of Life Tap III | 1 | 2425 | 30 | sí | no |
| 9218 | Grimoire of Enslave Demon | 1 | 2425 | 30 | sí | no |
| 9219 | Grimoire of Hellfire | 1 | 2425 | 30 | sí | no |
| 9221 | Grimoire of Curse of Agony III | 1 | 2750 | 32 | sí | no |
| 9222 | Grimoire of Curse of the Elements | 1 | 2750 | 32 | sí | no |
| 9223 | Grimoire of Curse of Weakness IV | 1 | 3250 | 34 | sí | no |
| 9225 | Grimoire of Shadow Bolt VI | 1 | 3750 | 36 | sí | no |
| 9226 | Grimoire of Health Funnel IV | 1 | 3750 | 36 | sí | no |
| 9227 | Grimoire of Drain Soul III | 1 | 4500 | 36 | sí | no |
| 9228 | Grimoire of Create Bloodstone III | 1 | 4500 | 36 | sí | no |
| 9229 | Grimoire of Life Drain IV | 1 | 4500 | 36 | sí | no |
| 9230 | Grimoire of Curse of Recklessness III | 1 | 5000 | 40 | sí | no |
| 9231 | Grimoire of Corruption IV | 1 | 5000 | 40 | sí | no |
| 16302 | Grimoire of Firebolt (Rank 2) | 1 | 25 | 8 | sí | no |
| 16316 | Grimoire of Firebolt (Rank 3) | 1 | 375 | 18 | sí | no |
| 16317 | Grimoire of Firebolt (Rank 4) | 1 | 1250 | 28 | sí | no |
| 16318 | Grimoire of Firebolt (Rank 5) | 1 | 2500 | 38 | sí | no |
| 16319 | Grimoire of Firebolt (Rank 6) | 1 | 3500 | 48 | sí | no |
| 16320 | Grimoire of Firebolt (Rank 7) | 1 | 6000 | 58 | sí | no |
| 16321 | Grimoire of Blood Pact (Rank 1) | 1 | 25 | 4 | sí | no |
| 16322 | Grimoire of Blood Pact (Rank 2) | 1 | 225 | 14 | sí | no |
| 16323 | Grimoire of Blood Pact (Rank 3) | 1 | 1000 | 26 | sí | no |
| 16324 | Grimoire of Blood Pact (Rank 4) | 1 | 2500 | 38 | sí | no |
| 16325 | Grimoire of Blood Pact (Rank 5) | 1 | 3750 | 50 | sí | no |
| 16326 | Grimoire of Fire Shield (Rank 1) | 1 | 225 | 14 | sí | no |
| 16327 | Grimoire of Fire Shield (Rank 2) | 1 | 750 | 24 | sí | no |
| 16328 | Grimoire of Fire Shield (Rank 3) | 1 | 2000 | 34 | sí | no |
| 16329 | Grimoire of Fire Shield (Rank 4) | 1 | 3000 | 44 | sí | no |
| 16330 | Grimoire of Fire Shield (Rank 5) | 1 | 5000 | 54 | sí | no |
| 16331 | Grimoire of Phase Shift | 1 | 150 | 12 | sí | no |
| 16346 | Grimoire of Torment (Rank 2) | 1 | 500 | 20 | sí | no |
| 16347 | Grimoire of Torment (Rank 3) | 1 | 1500 | 30 | sí | no |
| 16348 | Grimoire of Torment (Rank 4) | 1 | 2750 | 40 | sí | no |
| 16349 | Grimoire of Torment (Rank 5) | 1 | 3750 | 50 | sí | no |
| 16350 | Grimoire of Torment (Rank 6) | 1 | 6500 | 60 | sí | no |
| 16351 | Grimoire of Sacrifice (Rank 1) | 1 | 300 | 16 | sí | no |
| 16352 | Grimoire of Sacrifice (Rank 2) | 1 | 750 | 24 | sí | no |
| 16353 | Grimoire of Sacrifice (Rank 3) | 1 | 1750 | 32 | sí | no |
| 16354 | Grimoire of Sacrifice (Rank 4) | 1 | 2750 | 40 | sí | no |
| 16355 | Grimoire of Sacrifice (Rank 5) | 1 | 3500 | 48 | sí | no |
| 16356 | Grimoire of Sacrifice (Rank 6) | 1 | 5500 | 56 | sí | no |
| 16357 | Grimoire of Consume Shadows (Rank 1) | 1 | 375 | 18 | sí | no |
| 16358 | Grimoire of Consume Shadows (Rank 2) | 1 | 1000 | 26 | sí | no |
| 16359 | Grimoire of Consume Shadows (Rank 3) | 1 | 2000 | 34 | sí | no |
| 16360 | Grimoire of Consume Shadows (Rank 4) | 1 | 2750 | 42 | sí | no |
| 16361 | Grimoire of Consume Shadows (Rank 5) | 1 | 3750 | 50 | sí | no |
| 16362 | Grimoire of Consume Shadows (Rank 6) | 1 | 6000 | 58 | sí | no |
| 16363 | Grimoire of Suffering (Rank 1) | 1 | 750 | 24 | sí | no |
| 16364 | Grimoire of Suffering (Rank 2) | 1 | 2250 | 36 | sí | no |
| 16365 | Grimoire of Suffering (Rank 3) | 1 | 3500 | 48 | sí | no |
| 16366 | Grimoire of Suffering (Rank 4) | 1 | 6500 | 60 | sí | no |
| 16368 | Grimoire of Lash of Pain (Rank 2) | 1 | 1250 | 28 | sí | no |
| 16371 | Grimoire of Lash of Pain (Rank 3) | 1 | 2250 | 36 | sí | no |
| 16372 | Grimoire of Lash of Pain (Rank 4) | 1 | 3000 | 44 | sí | no |
| 16373 | Grimoire of Lash of Pain (Rank 5) | 1 | 4500 | 52 | sí | no |
| 16374 | Grimoire of Lash of Pain (Rank 6) | 1 | 6500 | 60 | sí | no |
| 16375 | Grimoire of Soothing Kiss (Rank 1) | 1 | 625 | 22 | sí | no |
| 16376 | Grimoire of Soothing Kiss (Rank 2) | 1 | 2000 | 34 | sí | no |
| 16377 | Grimoire of Soothing Kiss (Rank 3) | 1 | 3250 | 46 | sí | no |
| 16378 | Grimoire of Soothing Kiss (Rank 4) | 1 | 6000 | 58 | sí | no |
| 16379 | Grimoire of Seduction | 1 | 1000 | 26 | sí | no |
| 16380 | Grimoire of Lesser Invisibility | 1 | 1750 | 32 | sí | no |
| 16381 | Grimoire of Devour Magic (Rank 2) | 1 | 2500 | 38 | sí | no |
| 16382 | Grimoire of Devour Magic (Rank 3) | 1 | 3250 | 46 | sí | no |
| 16383 | Grimoire of Devour Magic (Rank 4) | 1 | 5000 | 54 | sí | no |
| 16384 | Grimoire of Tainted Blood (Rank 1) | 1 | 1750 | 32 | sí | no |
| 16385 | Grimoire of Tainted Blood (Rank 2) | 1 | 2750 | 40 | sí | no |
| 16386 | Grimoire of Tainted Blood (Rank 3) | 1 | 3500 | 48 | sí | no |
| 16387 | Grimoire of Tainted Blood (Rank 4) | 1 | 5500 | 56 | sí | no |
| 16388 | Grimoire of Spell Lock (Rank 1) | 1 | 2250 | 36 | sí | no |
| 16389 | Grimoire of Spell Lock (Rank 2) | 1 | 4500 | 52 | sí | no |
| 16390 | Grimoire of Paranoia | 1 | 2750 | 42 | sí | no |
| 17412 | zzOLDCodex of Prayer of Fortitude | 1 | 2 | 36 | sí | no |

### 9/0 Receta / Libro, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4213 | Grimoire of Doom | 2 | 2500 | 60 | sí | no |
| 9214 | Grimoire of Inferno | 2 | 2500 | 50 | sí | no |
| 11732 | Libram of Rumination | 2 | 0 | 50 | no | no |
| 11733 | Libram of Constitution | 2 | 0 | 50 | no | no |
| 11734 | Libram of Tenacity | 2 | 0 | 50 | no | no |
| 11736 | Libram of Resilience | 2 | 0 | 50 | no | no |
| 11737 | Libram of Voracity | 2 | 0 | 50 | no | no |
| 16665 | Tome of Tranquilizing Shot | 2 | 0 | 60 | sí | no |
| 18332 | Libram of Rapidity | 2 | 0 | 50 | no | no |
| 18333 | Libram of Focus | 2 | 0 | 50 | no | no |
| 18334 | Libram of Protection | 2 | 0 | 50 | no | no |
| 203745 | Spell Notes: Ice Lance | 2 | 0 | 1 | sí | no |
| 203746 | Spell Notes: Living Flame | 2 | 0 | 1 | sí | no |
| 203747 | Spell Notes: Fingers of Frost | 2 | 0 | 1 | sí | no |
| 203748 | Spell Notes: Burnout | 2 | 0 | 1 | sí | no |
| 203749 | Spell Notes: Enlightenment | 2 | 0 | 1 | sí | no |
| 208753 | Spell Notes: Regeneration | 2 | 0 | 1 | sí | no |
| 208853 | Spell Notes: Brain Freeze | 2 | 0 | 1 | sí | no |
| 210654 | Spell Notes: Rewind Time | 2 | 0 | 1 | sí | no |
| 211386 | Spell Notes: Arcane Surge | 2 | 0 | 1 | sí | no |
| 237041 | Tome of Enchanted Flare | 2 | 0 | 60 | sí | no |

### 9/0 Receta / Libro, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 4142 | Tome of Polymorph: Pig | 3 | 750 | 60 | sí | no |
| 4144 | Tome of Polymorph: Cow | 3 | 2000 | 60 | sí | no |
| 17413 | Codex: Prayer of Fortitude | 3 | 7750 | 48 | sí | no |
| 17414 | Codex: Prayer of Fortitude II | 3 | 14750 | 60 | sí | no |
| 17682 | Book: Gift of the Wild | 3 | 8750 | 50 | sí | no |
| 17683 | Book: Gift of the Wild II | 3 | 14750 | 60 | sí | no |
| 18600 | Tome of Arcane Brilliance | 3 | 12000 | 56 | sí | no |
| 21214 | Tome of Frostbolt XI | 3 | 100000 | 60 | sí | no |
| 21279 | Tome of Fireball XII | 3 | 100000 | 60 | sí | no |
| 21280 | Tome of Arcane Missiles VIII | 3 | 100000 | 60 | sí | no |
| 21281 | Grimoire of Shadow Bolt X | 3 | 100000 | 60 | sí | no |
| 21282 | Grimoire of Immolate VIII | 3 | 100000 | 60 | sí | no |
| 21283 | Grimoire of Corruption VII | 3 | 100000 | 60 | sí | no |
| 21284 | Codex of Greater Heal V | 3 | 100000 | 60 | sí | no |
| 21285 | Codex of Renew X | 3 | 100000 | 60 | sí | no |
| 21287 | Codex of Prayer of Healing V | 3 | 100000 | 60 | sí | no |
| 21288 | Libram: Blessing of Wisdom VI | 3 | 100000 | 60 | sí | no |
| 21289 | Libram: Blessing of Might VII | 3 | 100000 | 60 | sí | no |
| 21290 | Libram: Holy Light IX | 3 | 100000 | 60 | sí | no |
| 21291 | Tablet of Healing Wave X | 3 | 100000 | 60 | sí | no |
| 21292 | Tablet of Strength of Earth Totem V | 3 | 100000 | 60 | sí | no |
| 21293 | Tablet of Grace of Air Totem III | 3 | 100000 | 60 | sí | no |
| 21294 | Book of Healing Touch XI | 3 | 100000 | 60 | sí | no |
| 21295 | Book of Starfire VII | 3 | 100000 | 60 | sí | no |
| 21296 | Book of Rejuvenation XI | 3 | 100000 | 60 | sí | no |
| 21297 | Manual of Heroic Strike IX | 3 | 100000 | 60 | sí | no |
| 21298 | Manual of Battle Shout VII | 3 | 100000 | 60 | sí | no |
| 21299 | Manual of Revenge VI | 3 | 100000 | 60 | sí | no |
| 21300 | Handbook of Backstab IX | 3 | 100000 | 60 | sí | no |
| 21302 | Handbook of Deadly Poison V | 3 | 100000 | 60 | sí | no |
| 21303 | Handbook of Feint V | 3 | 100000 | 60 | sí | no |
| 21304 | Guide: Multi-Shot V | 3 | 100000 | 60 | sí | no |
| 21306 | Guide: Serpent Sting IX | 3 | 100000 | 60 | sí | no |
| 21307 | Guide: Aspect of the Hawk VII | 3 | 100000 | 60 | sí | no |
| 22393 | Codex: Prayer of Shadow Protection | 3 | 14750 | 60 | sí | no |
| 22739 | Tome of Polymorph: Turtle | 3 | 14750 | 60 | sí | no |
| 22890 | Tome of Frost Ward V | 3 | 10000 | 60 | sí | no |
| 22891 | Grimoire of Shadow Ward IV | 3 | 10000 | 60 | sí | no |
| 22897 | Tome of Conjure Food VII | 3 | 10000 | 60 | sí | no |
| 23320 | Tablet of Flame Shock VI | 3 | 100000 | 60 | sí | no |
| 24101 | Book of Ferocious Bite V | 3 | 100000 | 60 | sí | no |
| 24102 | Manual of Eviscerate IX | 3 | 100000 | 60 | sí | no |

### 11/2 Carcaj / Carcaj, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 1281 | Deprecated Quiver (TEST) | 1 | 0 | 1 | no | no |
| 2003 | Deprecated Big Quiver | 1 | 0 | 1 | no | no |

### 15/0 Misceláneo / Chatarra, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 894 | Deprecated Ravager Claw | 1 | 162 | 0 | no | no |
| 1016 | Deprecated Lurker Leg | 1 | 51 | 0 | no | no |
| 1255 | Deprecated Conjured Mana Gem | 1 | 0 | 18 | no | no |
| 1690 | Deprecated Fine Panther Whisker | 1 | 331 | 0 | no | no |
| 1691 | Deprecated Ebony Panther Claw | 1 | 237 | 0 | no | no |
| 1915 | Deprecated Bag of Teeth | 1 | 30 | 0 | no | no |
| 2887 | Ruined Wolf Pelt | 1 | 5 | 0 | no | no |
| 2890 | Ruined Boar Pelt | 1 | 5 | 0 | no | no |
| 3249 | Conjured test Item | 1 | 0 | 0 | no | no |
| 3259 | Ruined Bat Hide | 1 | 5 | 0 | no | no |
| 3500 | Deprecated Battered Lock | 1 | 62 | 0 | no | no |
| 3501 | Deprecated Rusted Lock | 1 | 0 | 0 | no | no |
| 3503 | Deprecated Forboding Document | 1 | 0 | 0 | no | no |
| 3705 | Deprecated Rabid Fang | 1 | 727 | 0 | no | no |
| 3878 | Deprecated Conjured Mana Jewel | 1 | 0 | 27 | no | no |
| 4095 | Deprecate Snare Kit | 1 | 617 | 0 | no | no |
| 4451 | Deprecated Stasis Totem | 1 | 13 | 0 | no | no |
| 4475 | Deprecated The Southern Kingdoms | 1 | 0 | 0 | no | no |
| 4486 | Deprecated Jorell's Head | 1 | 0 | 0 | no | no |
| 4573 | Deprecated Pat's Test Strongbox | 1 | 5000 | 25 | no | no |
| 4578 | Deprecated Long Panther Tail | 1 | 536 | 0 | no | no |
| 4579 | Deprecated Spotted Panther Skin | 1 | 737 | 0 | no | no |
| 4756 | Ruined Cat Pelt | 1 | 5 | 0 | no | no |
| 5105 | Explosive Shell | 1 | 25 | 0 | no | no |
| 5331 | OLDBlackfathom MAGIC Relic | 1 | 236 | 0 | no | no |
| 5335 | A Sack of Coins | 1 | 0 | 0 | no | no |
| 5365 | Deprecated Pickpocket | 1 | 7 | 0 | no | no |
| 5434 | Deprecated Pickpocket Water 31-40 | 1 | 182 | 0 | no | no |
| 5436 | Deprecated Pickpocket Undead 41-50 | 1 | 303 | 0 | no | no |
| 5562 | Voidstone (Deprecated) | 1 | 50 | 0 | no | no |
| 5563 | Succubi Stone (Deprecated) | 1 | 200 | 0 | no | no |
| 5738 | Covert Ops Pack | 1 | 0 | 0 | no | no |
| 5863 | Guild Charter | 1 | 0 | 0 | no | no |
| 6292 | 10 Pound Mud Snapper | 1 | 1000 | 0 | no | no |
| 6294 | 12 Pound Mud Snapper | 1 | 1200 | 0 | no | no |
| 6295 | 15 Pound Mud Snapper | 1 | 1500 | 0 | no | no |
| 6307 | Message in a Bottle | 1 | 1 | 0 | no | no |
| 6309 | 17 Pound Catfish | 1 | 1700 | 0 | no | no |
| 6310 | 19 Pound Catfish | 1 | 1900 | 0 | no | no |
| 6311 | 22 Pound Catfish | 1 | 2200 | 0 | no | no |
| 6353 | Small Chest | 1 | 1 | 0 | no | no |
| 6356 | Battered Chest | 1 | 1 | 0 | no | no |
| 6363 | 26 Pound Catfish | 1 | 2600 | 0 | no | no |
| 6364 | 32 Pound Catfish | 1 | 3200 | 0 | no | no |
| 6755 | A Small Container of Gems | 1 | 0 | 0 | no | no |
| 6827 | Box of Supplies | 1 | 150 | 0 | no | no |
| 7668 | Bloodstained Journal | 1 | 0 | 0 | no | no |
| 7907 | Certificate of Thievery | 1 | 0 | 0 | no | no |
| 8087 | Sample of Zanzil's Altered Mixture | 1 | 0 | 1 | no | no |
| 8383 | Plain Letter | 1 | 0 | 0 | no | no |
| 8484 | Gadgetzan Water Co. Care Package | 1 | 68 | 0 | no | no |
| 9259 | Troll Tribal Necklace | 1 | 64 | 0 | no | no |
| 9276 | Pirate's Footlocker | 1 | 100 | 0 | no | no |
| 9363 | Sparklematic-Wrapped Box | 1 | 12 | 0 | no | no |
| 9529 | Internal Warrior Equipment Kit L25 | 1 | 0 | 0 | no | no |
| 9532 | Internal Warrior Equipment Kit L30 | 1 | 0 | 0 | no | no |
| 9537 | Neatly Wrapped Box | 1 | 0 | 0 | no | no |
| 9539 | Box of Rations | 1 | 50 | 0 | no | no |
| 9540 | Box of Spells | 1 | 150 | 0 | no | no |
| 9541 | Box of Goodies | 1 | 200 | 0 | no | no |
| 10456 | A Bulging Coin Purse | 1 | 0 | 0 | no | no |
| 10467 | Trader's Satchel | 1 | 0 | 0 | no | no |
| 10569 | Hoard of the Black Dragonflight | 1 | 0 | 0 | no | no |
| 10575 | Black Dragonflight Molt | 1 | 0 | 0 | no | no |
| 10594 | [PH] Hakkar'i Urn | 1 | 0 | 0 | no | no |
| 10695 | Box of Empty Vials | 1 | 0 | 0 | no | no |
| 10834 | Felhound Tracker Kit | 1 | 0 | 0 | no | no |
| 10839 | Crystallized Note | 1 | 0 | 0 | no | no |
| 10840 | Crystallized Note | 1 | 0 | 0 | no | no |
| 11228 | Frenzied Dragonflight Molt | 1 | 0 | 0 | no | no |
| 11442 | Stormwind Deputy Kit | 1 | 0 | 0 | no | no |
| 11568 | Torwa's Pouch | 1 | 0 | 0 | no | no |
| 11883 | A Dingy Fanny Pack | 1 | 0 | 0 | no | no |
| 11887 | Cenarion Circle Cache | 1 | 12 | 0 | no | no |
| 11912 | Package of Empty Ooze Containers | 1 | 0 | 0 | no | no |
| 11937 | Fat Sack of Coins | 1 | 187 | 0 | no | no |
| 11938 | Sack of Gems | 1 | 213 | 0 | no | no |
| 11955 | Bag of Empty Ooze Containers | 1 | 0 | 0 | no | no |
| 11966 | Small Sack of Coins | 1 | 164 | 0 | no | no |
| 13642 | Level 15 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13643 | Level 15 Test Gear Leather - Druid/Shaman | 1 | 0 | 0 | no | no |
| 13644 | Level 15 Test Gear Leather - Hunter/Rogue | 1 | 0 | 0 | no | no |
| 13645 | Level 15 Test Gear Mail - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13646 | Level 20 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13647 | Level 25 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13648 | Level 30 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13649 | Level 35 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13650 | Level 40 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13651 | Level 45 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13652 | Level 50 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13653 | Level 55 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13654 | Level 60 Test Gear Cloth - Mage/Priest/Warlock | 1 | 0 | 0 | no | no |
| 13655 | Level 65 Test Gear Cloth - Mage | 1 | 0 | 0 | no | no |
| 13656 | Level 20 Test Gear Mail - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13657 | Level 25 Test Gear Mail - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13658 | Level 30 Test Gear Mail - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13659 | Level 35 Test Gear Mail - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13660 | Level 20 Test Gear Leather - Druid/Shaman | 1 | 0 | 0 | no | no |
| 13661 | Level 25 Test Gear Leather - Druid/Shaman | 1 | 0 | 0 | no | no |
| 13662 | Level 30 Test Gear Leather - Druid/Shaman | 1 | 0 | 0 | no | no |
| 13663 | Level 35 Test Gear Leather - Druid/Shaman | 1 | 0 | 0 | no | no |
| 13664 | Level 20 Test Gear Leather - Hunter/Rogue | 1 | 0 | 0 | no | no |
| 13665 | Level 25 Test Gear Leather - Hunter/Rogue | 1 | 0 | 0 | no | no |
| 13666 | Level 30 Test Gear Leather - Hunter/Rogue | 1 | 0 | 0 | no | no |
| 13667 | Level 35 Test Gear Leather - Hunter/Rogue | 1 | 0 | 0 | no | no |
| 13668 | Level 40 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13669 | Level 45 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13670 | Level 50 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13671 | Level 55 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13672 | Level 60 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13673 | Level 65 Test Gear Leather - Druid | 1 | 0 | 0 | no | no |
| 13674 | Level 40 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13675 | Level 45 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13676 | Level 50 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13677 | Level 55 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13678 | Level 60 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13679 | Level 65 Test Gear Leather - Rogue | 1 | 0 | 0 | no | no |
| 13680 | Level 40 Test Gear Plate - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13681 | Level 45 Test Gear Plate - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13682 | Level 50 Test Gear Plate - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13683 | Level 55 Test Gear Plate - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13684 | Level 60 Test Gear Plate - Paladin/Warrior | 1 | 0 | 0 | no | no |
| 13685 | Level 65 Test Gear Plate - Paladin | 1 | 0 | 0 | no | no |
| 13686 | Level 40 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13687 | Level 45 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13688 | Level 50 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13689 | Level 55 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13690 | Level 60 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13691 | Level 65 Test Gear Mail - Hunter | 1 | 0 | 0 | no | no |
| 13692 | Level 40 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13693 | Level 45 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13694 | Level 50 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13695 | Level 55 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13696 | Level 60 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13697 | Level 65 Test Gear Mail - Shaman | 1 | 0 | 0 | no | no |
| 13842 | Fall/Winter Morning | 1 | 375 | 0 | no | no |
| 13843 | Fall/Winter Afternoon | 1 | 375 | 0 | no | no |
| 13844 | Fall/Winter Evening | 1 | 375 | 0 | no | no |
| 13845 | Fall/Winter Night | 1 | 375 | 0 | no | no |
| 13846 | Spring/Summer Morning | 1 | 375 | 0 | no | no |
| 13847 | Spring/Summer Afternoon | 1 | 375 | 0 | no | no |
| 13848 | Spring/Summer Evening | 1 | 375 | 0 | no | no |
| 13849 | Spring/Summer Night | 1 | 375 | 0 | no | no |
| 13876 | 40 Pound Yellowtail | 1 | 4000 | 0 | no | no |
| 13877 | 47 Pound Yellowtail | 1 | 4700 | 0 | no | no |
| 13878 | 53 Pound Yellowtail | 1 | 5300 | 0 | no | no |
| 13879 | 59 Pound Yellowtail | 1 | 5900 | 0 | no | no |
| 13880 | 68 Pound Yellowtail | 1 | 6800 | 0 | no | no |
| 13882 | 42 Pound Redgill | 1 | 4200 | 0 | no | no |
| 13883 | 45 Pound Redgill | 1 | 4500 | 0 | no | no |
| 13884 | 49 Pound Redgill | 1 | 4900 | 0 | no | no |
| 13885 | 34 Pound Redgill | 1 | 3400 | 0 | no | no |
| 13886 | 37 Pound Redgill | 1 | 3700 | 0 | no | no |
| 13887 | 52 Pound Redgill | 1 | 5200 | 0 | no | no |
| 13901 | 15 Pound Salmon | 1 | 1500 | 0 | no | no |
| 13902 | 18 Pound Salmon | 1 | 1800 | 0 | no | no |
| 13903 | 22 Pound Salmon | 1 | 2200 | 0 | no | no |
| 13904 | 25 Pound Salmon | 1 | 2500 | 0 | no | no |
| 13905 | 29 Pound Salmon | 1 | 2900 | 0 | no | no |
| 13906 | 32 Pound Salmon | 1 | 3200 | 0 | no | no |
| 13907 | 7 Pound Lobster | 1 | 700 | 0 | no | no |
| 13908 | 9 Pound Lobster | 1 | 900 | 0 | no | no |
| 13909 | 12 Pound Lobster | 1 | 1200 | 0 | no | no |
| 13910 | 15 Pound Lobster | 1 | 1500 | 0 | no | no |
| 13911 | 19 Pound Lobster | 1 | 1900 | 0 | no | no |
| 13912 | 21 Pound Lobster | 1 | 2100 | 0 | no | no |
| 13913 | 22 Pound Lobster | 1 | 2200 | 0 | no | no |
| 13914 | 70 Pound Mightfish | 1 | 7000 | 0 | no | no |
| 13915 | 85 Pound Mightfish | 1 | 8500 | 0 | no | no |
| 13916 | 92 Pound Mightfish | 1 | 9200 | 0 | no | no |
| 13917 | 103 Pound Mightfish | 1 | 10300 | 0 | no | no |
| 15102 | Un'Goro Tested Sample | 1 | 0 | 0 | no | no |
| 15103 | Corrupt Tested Sample | 1 | 0 | 0 | no | no |
| 15699 | Small Brown-wrapped Package | 1 | 25 | 0 | no | no |
| 15902 | A Crazy Grab Bag | 1 | 20000 | 0 | no | no |
| 16068 | Test Fire Resist Cloth LockBox | 1 | 0 | 0 | no | no |
| 16069 | Test Fire Resist Leather LockBox | 1 | 0 | 0 | no | no |
| 16070 | Test Fire Resist Mail LockBox | 1 | 0 | 0 | no | no |
| 16071 | Test Fire Resist Plate LockBox | 1 | 0 | 0 | no | no |
| 16074 | Test Potion LockBox (Warrior) | 1 | 0 | 0 | no | no |
| 16075 | Test Potion LockBox (Rogue) | 1 | 0 | 0 | no | no |
| 16076 | Test Potion LockBox (Paladin) | 1 | 0 | 0 | no | no |
| 16077 | Test Potion LockBox (Hunter) | 1 | 0 | 0 | no | no |
| 16078 | Test Potion LockBox (Druid) | 1 | 0 | 0 | no | no |
| 16079 | Test Potion LockBox (Shaman) | 1 | 0 | 0 | no | no |
| 16080 | Test Potion LockBox (Mage/Priest/Warlock) | 1 | 0 | 0 | no | no |
| 16081 | Test Potion LockBox (Raid) | 1 | 0 | 0 | no | no |
| 16109 | Test Enchantments LockBox (Enchanting Items) | 1 | 0 | 0 | no | no |
| 16173 | Test Frost Resist Cloth LockBox | 1 | 0 | 0 | no | no |
| 16174 | Test Frost Resist Leather LockBox | 1 | 0 | 0 | no | no |
| 16175 | Test Frost Resist Mail LockBox | 1 | 0 | 0 | no | no |
| 16176 | Test Frost Resist Plate LockBox | 1 | 0 | 0 | no | no |
| 16177 | Test Nature Resist Plate LockBox | 1 | 0 | 0 | no | no |
| 16178 | Test Nature Resist Leather LockBox | 1 | 0 | 0 | no | no |
| 16179 | Test Nature Resist Mail LockBox | 1 | 0 | 0 | no | no |
| 16180 | Test Nature Resist Cloth LockBox | 1 | 0 | 0 | no | no |
| 16181 | Test Shadow Resist Cloth LockBox | 1 | 0 | 0 | no | no |
| 16182 | Test Shadow Resist Leather LockBox | 1 | 0 | 0 | no | no |
| 16183 | Test Shadow Resist Mail LockBox | 1 | 0 | 0 | no | no |
| 16184 | Test Shadow Resist Plate LockBox | 1 | 0 | 0 | no | no |
| 16185 | Test Arcane Resist Plate LockBox | 1 | 0 | 0 | no | no |
| 16186 | Test Arcane Resist Cloth LockBox | 1 | 0 | 0 | no | no |
| 16187 | Test Arcane Resist Leather LockBox | 1 | 0 | 0 | no | no |
| 16188 | Test Arcane Resist Mail LockBox | 1 | 0 | 0 | no | no |
| 16967 | Feralas Ahi | 1 | 0 | 0 | no | no |
| 17195 | UNUSED ITEM | 1 | 0 | 0 | no | no |
| 17685 | Smokywood Pastures Sampler | 1 | 0 | 0 | no | no |
| 17726 | Smokywood Pastures Special Gift | 1 | 0 | 0 | no | no |
| 17727 | Smokywood Pastures Gift Pack | 1 | 0 | 0 | no | no |
| 17735 | The Feast of Winter Veil | 1 | 0 | 0 | no | no |
| 17824 | Level 65 Test Gear Cloth - Priest | 1 | 0 | 0 | no | no |
| 17825 | Level 65 Test Gear Cloth - Warlock | 1 | 0 | 0 | no | no |
| 17826 | Level 65 Test Gear Plate - Warrior | 1 | 0 | 0 | no | no |
| 17831 | Level 60 Test Gear Cloth - Mage/Priest/Warlock 2 | 1 | 0 | 0 | no | no |
| 17832 | Level 60 Test Gear Leather - Druid 2 | 1 | 0 | 0 | no | no |
| 17833 | Level 60 Test Gear Leather - Rogue 2 | 1 | 0 | 0 | no | no |
| 17834 | Level 60 Test Gear Mail - Hunter 2 | 1 | 0 | 0 | no | no |
| 17835 | Level 60 Test Gear Mail - Shaman 2 | 1 | 0 | 0 | no | no |
| 17836 | Level 60 Test Gear Plate - Paladin/Warrior 2 | 1 | 0 | 0 | no | no |
| 17837 | Level 55 Test Gear Cloth - Mage/Priest/Warlock 2 | 1 | 0 | 0 | no | no |
| 17838 | Level 55 Test Gear Leather - Druid 2 | 1 | 0 | 0 | no | no |
| 17839 | Level 55 Test Gear Leather - Rogue 2 | 1 | 0 | 0 | no | no |
| 17840 | Level 55 Test Gear Mail - Hunter 2 | 1 | 0 | 0 | no | no |
| 17841 | Level 55 Test Gear Mail - Shaman 2 | 1 | 0 | 0 | no | no |
| 17842 | Level 55 Test Gear Plate - Paladin/Warrior 2 | 1 | 0 | 0 | no | no |
| 17843 | Level 50 Test Gear Cloth - Mage/Priest/Warlock 2 | 1 | 0 | 0 | no | no |
| 17844 | Level 50 Test Gear Leather - Druid 2 | 1 | 0 | 0 | no | no |
| 17845 | Level 50 Test Gear Leather - Rogue 2 | 1 | 0 | 0 | no | no |
| 17846 | Level 50 Test Gear Mail - Hunter 2 | 1 | 0 | 0 | no | no |
| 17847 | Level 50 Test Gear Mail - Shaman 2 | 1 | 0 | 0 | no | no |
| 17848 | Level 50 Test Gear Plate - Paladin/Warrior 2 | 1 | 0 | 0 | no | no |
| 17851 | Level 65 Test Gear Cloth - Mage 2 | 1 | 0 | 0 | no | no |
| 17852 | Level 65 Test Gear Cloth - Priest 2 | 1 | 0 | 0 | no | no |
| 17853 | Level 65 Test Gear Cloth - Warlock 2 | 1 | 0 | 0 | no | no |
| 17854 | Level 65 Test Gear Leather - Druid 2 | 1 | 0 | 0 | no | no |
| 17855 | Level 65 Test Gear Leather - Rogue 2 | 1 | 0 | 0 | no | no |
| 17856 | Level 65 Test Gear Leather - Rogue 3 | 1 | 0 | 0 | no | no |
| 17857 | Level 65 Test Gear Mail - Hunter 2 | 1 | 0 | 0 | no | no |
| 17858 | Level 65 Test Gear Mail - Hunter 3 | 1 | 0 | 0 | no | no |
| 17859 | Level 65 Test Gear Mail - Shaman 2 | 1 | 0 | 0 | no | no |
| 17860 | Level 65 Test Gear Plate - Paladin 2 | 1 | 0 | 0 | no | no |
| 17861 | Level 65 Test Gear Plate - Warrior 2 | 1 | 0 | 0 | no | no |
| 17862 | Level 65 Test Gear Plate - Warrior 3 | 1 | 0 | 0 | no | no |
| 18664 | A Treatise on Military Ranks | 1 | 25 | 0 | no | no |
| 18675 | Military Ranks of the Horde & Alliance | 1 | 25 | 0 | no | no |
| 19229 | Sayge's Fortune #1 | 1 | 0 | 0 | no | no |
| 19237 | Sayge's Fortune #19 | 1 | 0 | 0 | no | no |
| 19238 | Sayge's Fortune #3 | 1 | 0 | 0 | no | no |
| 19239 | Sayge's Fortune #4 | 1 | 0 | 0 | no | no |
| 19240 | Sayge's Fortune #5 | 1 | 0 | 0 | no | no |
| 19241 | Sayge's Fortune #6 | 1 | 0 | 0 | no | no |
| 19242 | Sayge's Fortune #7 | 1 | 0 | 0 | no | no |
| 19243 | Sayge's Fortune #8 | 1 | 0 | 0 | no | no |
| 19244 | Sayge's Fortune #9 | 1 | 0 | 0 | no | no |
| 19245 | Sayge's Fortune #10 | 1 | 0 | 0 | no | no |
| 19246 | Sayge's Fortune #11 | 1 | 0 | 0 | no | no |
| 19247 | Sayge's Fortune #12 | 1 | 0 | 0 | no | no |
| 19248 | Sayge's Fortune #13 | 1 | 0 | 0 | no | no |
| 19249 | Sayge's Fortune #14 | 1 | 0 | 0 | no | no |
| 19250 | Sayge's Fortune #15 | 1 | 0 | 0 | no | no |
| 19251 | Sayge's Fortune #16 | 1 | 0 | 0 | no | no |
| 19252 | Sayge's Fortune #18 | 1 | 0 | 0 | no | no |
| 19253 | Sayge's Fortune #17 | 1 | 0 | 0 | no | no |
| 19254 | Sayge's Fortune #21 | 1 | 0 | 0 | no | no |
| 19255 | Sayge's Fortune #22 | 1 | 0 | 0 | no | no |
| 19256 | Sayge's Fortune #2 | 1 | 0 | 0 | no | no |
| 19266 | Sayge's Fortune #20 | 1 | 0 | 0 | no | no |
| 19451 | Sayge's Fortune #26 | 1 | 0 | 0 | no | no |
| 19453 | Sayge's Fortune #28 | 1 | 0 | 0 | no | no |
| 19454 | Sayge's Fortune #29 | 1 | 0 | 0 | no | no |
| 19483 | Peeling the Onion | 1 | 0 | 0 | no | no |
| 19484 | The Frostwolf Artichoke | 1 | 0 | 0 | no | no |
| 19775 | Sealed Azure Bag | 1 | 0 | 0 | no | no |
| 19911 | Whipweed Heart | 1 | 0 | 0 | no | no |
| 19933 | Glowing Scorpid Blood | 1 | 1180 | 0 | no | no |
| 19978 | Fishing Tournament! | 1 | 0 | 0 | no | no |
| 20017 | Perfect Courser Antler | 1 | 0 | 0 | no | no |
| 20019 | Tooth of Morphaz | 1 | 0 | 0 | no | no |
| 20022 | Azure Key | 1 | 0 | 0 | no | no |
| 20085 | Arcane Shard | 1 | 0 | 0 | no | no |
| 20087 | Wavethrasher Scales | 1 | 0 | 0 | no | no |
| 20364 | Test Ammo Lockbox | 1 | 0 | 0 | no | no |
| 20393 | Treat Bag | 1 | 0 | 0 | no | no |
| 20415 | The War of the Shifting Sands | 1 | 0 | 0 | no | no |
| 20469 | Decoded True Believer Clippings | 1 | 12 | 0 | no | no |
| 20601 | Sack of Spoils | 1 | 12 | 0 | no | no |
| 20602 | Chest of Spoils | 1 | 12 | 0 | no | no |
| 20603 | Bag of Spoils | 1 | 12 | 0 | no | no |
| 20606 | Amber Voodoo Feather | 1 | 0 | 0 | no | no |
| 20607 | Blue Voodoo Feather | 1 | 0 | 0 | no | no |
| 20608 | Green Voodoo Feather | 1 | 0 | 0 | no | no |
| 20609 | Voodoo Feathers | 1 | 0 | 0 | no | no |
| 20610 | Bloodshot Spider Eye | 1 | 0 | 0 | no | no |
| 20611 | Thick Black Claw | 1 | 0 | 0 | no | no |
| 20612 | Inert Scourgestone | 1 | 0 | 0 | no | no |
| 20613 | Rotting Wood | 1 | 0 | 0 | no | no |
| 20614 | Bloodvenom Essence | 1 | 0 | 0 | no | no |
| 20708 | Tightly Sealed Trunk | 1 | 2 | 0 | no | no |
| 20737 | Singed Corestone | 1 | 0 | 0 | no | no |
| 20766 | Slimy Bag | 1 | 0 | 0 | no | no |
| 20767 | Scum Covered Bag | 1 | 0 | 0 | no | no |
| 20768 | Oozing Bag | 1 | 0 | 0 | no | no |
| 20805 | Followup Logistics Assignment | 1 | 12 | 0 | no | no |
| 20808 | Combat Assignment | 1 | 12 | 0 | no | no |
| 20809 | Tactical Assignment | 1 | 12 | 0 | no | no |
| 21037 | Crude Map | 1 | 0 | 0 | no | no |
| 21042 | Narain's Special Kit | 1 | 0 | 0 | no | no |
| 21113 | Watertight Trunk | 1 | 2 | 0 | no | no |
| 21130 | Diary of Weavil | 1 | 0 | 0 | no | no |
| 21131 | Followup Combat Assignment | 1 | 12 | 0 | no | no |
| 21132 | Logistics Assignment | 1 | 12 | 0 | no | no |
| 21133 | Followup Tactical Assignment | 1 | 12 | 0 | no | no |
| 21142 | From the Desk of Lord Victor Nefarius | 1 | 0 | 0 | no | no |
| 21150 | Iron Bound Trunk | 1 | 2 | 0 | no | no |
| 21156 | Scarab Bag | 1 | 12 | 0 | no | no |
| 21175 | The Scepter of the Shifting Sands | 1 | 0 | 0 | no | no |
| 21191 | Carefully Wrapped Present | 1 | 0 | 1 | no | no |
| 21216 | Smokywood Pastures Extra-Special Gift | 1 | 0 | 0 | no | no |
| 21228 | Mithril Bound Trunk | 1 | 2 | 0 | no | no |
| 21229 | Qiraji Lord's Insignia | 1 | 0 | 0 | no | no |
| 21266 | Logistics Assignment | 1 | 12 | 0 | no | no |
| 21270 | Gently Shaken Gift | 1 | 0 | 1 | no | no |
| 21271 | DEPRECATED ITEM | 1 | 0 | 1 | no | no |
| 21274 | Test Stackable Items | 1 | 0 | 0 | no | no |
| 21310 | Gaily Wrapped Present | 1 | 0 | 1 | no | no |
| 21314 | Metzen's Letters and Notes | 1 | 0 | 0 | no | no |
| 21315 | Smokywood Satchel | 1 | 0 | 0 | no | no |
| 21327 | Ticking Present | 1 | 0 | 1 | no | no |
| 21363 | Festive Gift | 1 | 0 | 1 | no | no |
| 21386 | Followup Logistics Assignment | 1 | 12 | 0 | no | no |
| 21436 | Alliance Commendation Signet | 1 | 0 | 0 | no | no |
| 21438 | Horde Commendation Signet | 1 | 0 | 0 | no | no |
| 21509 | Ahn'Qiraj War Effort Supplies | 1 | 0 | 0 | no | no |
| 21510 | Ahn'Qiraj War Effort Supplies | 1 | 0 | 0 | no | no |
| 21511 | Ahn'Qiraj War Effort Supplies | 1 | 0 | 0 | no | no |
| 21512 | Ahn'Qiraj War Effort Supplies | 1 | 0 | 0 | no | no |
| 21513 | Ahn'Qiraj War Effort Supplies | 1 | 0 | 0 | no | no |
| 21628 | Test AQ Resource - Copper | 1 | 0 | 0 | no | no |
| 21629 | Test AQ Resource - Iron | 1 | 0 | 0 | no | no |
| 21630 | Test AQ Resource - Thorium | 1 | 0 | 0 | no | no |
| 21631 | Test AQ Resource - Light Leather | 1 | 0 | 0 | no | no |
| 21632 | Test AQ Resource - Medium Leather | 1 | 0 | 0 | no | no |
| 21633 | Test AQ Resource - Thick Leather | 1 | 0 | 0 | no | no |
| 21634 | Test AQ Resource - Linen Bandage | 1 | 0 | 0 | no | no |
| 21636 | Test AQ Resource - Silk Bandage | 1 | 0 | 0 | no | no |
| 21637 | Test AQ Resource - Runecloth Bandage | 1 | 0 | 0 | no | no |
| 21638 | Test AQ Resource - Spotted Yellowtail | 1 | 0 | 0 | no | no |
| 21640 | Lunar Festival Fireworks Pack | 1 | 0 | 0 | no | no |
| 21641 | Test AQ Resource - Rainbow Fin Albacore | 1 | 0 | 0 | no | no |
| 21642 | Test AQ Resource - Roast Raptor | 1 | 0 | 0 | no | no |
| 21643 | Test AQ Resource - Arthas' Tear | 1 | 0 | 0 | no | no |
| 21644 | Test AQ Resource - Stranglekelp | 1 | 0 | 0 | no | no |
| 21646 | Test AQ Resource - Purple Lotus | 1 | 0 | 0 | no | no |
| 21649 | Test AQ Resource - Tin | 1 | 0 | 0 | no | no |
| 21653 | Test AQ Resource - Mithril | 1 | 0 | 0 | no | no |
| 21655 | Test AQ Resource - Heavy Leather | 1 | 0 | 0 | no | no |
| 21656 | Test AQ Resource - Rugged Leather | 1 | 0 | 0 | no | no |
| 21657 | Test AQ Resource - Wool Bandages | 1 | 0 | 0 | no | no |
| 21658 | Test AQ Resource - Mageweave Bandages | 1 | 0 | 0 | no | no |
| 21659 | Test AQ Resource - Lean Wolf Steak | 1 | 0 | 0 | no | no |
| 21660 | Test AQ Resource - Baked Salmon | 1 | 0 | 0 | no | no |
| 21661 | Test AQ Resource - Firebloom | 1 | 0 | 0 | no | no |
| 21662 | Test AQ Resource - Peacebloom | 1 | 0 | 0 | no | no |
| 21812 | Box of Chocolates | 1 | 0 | 1 | no | no |
| 21920 | Creased Letter | 1 | 0 | 1 | no | no |
| 21921 | Carefully Penned Note | 1 | 0 | 1 | no | no |
| 21925 | Immaculate Letter | 1 | 0 | 1 | no | no |
| 21926 | Slightly Creased Note | 1 | 0 | 1 | no | no |
| 22045 | Test QARaid Uber Ammo Lockbox | 1 | 0 | 0 | no | no |
| 22059 | Valentine's Day Card | 1 | 0 | 0 | no | no |
| 22137 | Ysida's Satchel | 1 | 12 | 0 | no | no |
| 22152 | Anthion's Pouch | 1 | 12 | 0 | no | no |
| 22264 | Carefully Written Letter | 1 | 0 | 1 | no | no |
| 22265 | Lovingly Composed Letter | 1 | 0 | 1 | no | no |
| 22320 | Mux's Quality Goods | 1 | 12 | 0 | no | no |
| 22344 | Brazier of Invocation: User's Manual | 1 | 0 | 0 | no | no |
| 22434 | Bloodcap | 1 | 0 | 0 | no | no |
| 22435 | Gorishi Sting | 1 | 0 | 0 | no | no |
| 22444 | Putrid Vine | 1 | 0 | 0 | no | no |
| 22568 | Sealed Craftsman's Writ | 1 | 0 | 0 | no | no |
| 22593 | Writ of Safe Passage | 1 | 0 | 0 | no | no |
| 22595 | Call to Arms Announcement | 1 | 0 | 1 | no | no |
| 22648 | Hive'Ashi Dossier | 1 | 12 | 0 | no | no |
| 22649 | Hive'Regal Dossier | 1 | 12 | 0 | no | no |
| 22650 | Hive'Zora Dossier | 1 | 12 | 0 | no | no |
| 22765 | Mildewed Letter | 1 | 0 | 0 | no | no |
| 23022 | Curmudgeon's Payoff | 1 | 0 | 0 | no | no |
| 23250 | Prismatic Shell | 1 | 0 | 0 | no | no |
| 23271 | QATest Darkmoon Faire Tickets | 1 | 20000 | 0 | no | no |
| 23325 | [PH] Picnic Parcel | 1 | 0 | 1 | no | no |
| 189419 | Fire Resist Plate Gear | 1 | 0 | 0 | no | no |
| 189420 | Fire Resist Plate Gear | 1 | 0 | 0 | no | no |
| 189421 | Fire Resist Leather Gear | 1 | 0 | 0 | no | no |
| 189426 | Raid Consumables | 1 | 0 | 0 | no | no |
| 189427 | More Raid Consumables | 1 | 0 | 0 | no | no |
| 203723 | Cutty's Note | 1 | 0 | 1 | no | no |
| 204476 | Severed Kobold Head | 1 | 0 | 0 | no | no |
| 204477 | Severed Murloc Head | 1 | 0 | 0 | no | no |
| 204478 | Severed Gnoll Head | 1 | 0 | 0 | no | no |
| 204906 | Gnoll Blood | 1 | 0 | 1 | no | no |
| 204907 | Wolf Jawbone | 1 | 0 | 1 | no | no |
| 205019 | Tainted Soul Shard | 1 | 0 | 0 | no | no |
| 205020 | Pure Soul Shard | 1 | 0 | 0 | no | no |
| 205181 | Unidentified Artifact | 1 | 0 | 0 | no | no |
| 205183 | Fel-Powered Artifact | 1 | 0 | 0 | no | no |
| 205184 | Acolyte's Note | 1 | 0 | 1 | no | no |
| 205364 | Acolyte's Knapsack | 1 | 0 | 0 | no | no |
| 205863 | Corrupted Libram | 1 | 0 | 1 | no | no |
| 205864 | Charred Note | 1 | 0 | 1 | no | no |
| 206994 | Severed Quilboar Head | 1 | 0 | 0 | no | no |
| 206995 | Severed Harpy Head | 1 | 0 | 0 | no | no |
| 207062 | Severed Centaur Head | 1 | 0 | 0 | no | no |
| 207098 | Note from Ba'so | 1 | 0 | 1 | no | no |
| 207732 | Makrura Leg | 1 | 0 | 1 | no | no |
| 207733 | Kul Tiran Skull | 1 | 0 | 1 | no | no |
| 207973 | Hound Jawbone | 1 | 0 | 1 | no | no |
| 207975 | Severed Bat Head | 1 | 0 | 0 | no | no |
| 208086 | Forged Scarlet Memorandum | 1 | 0 | 1 | no | no |
| 208140 | Wendigo Blood | 1 | 0 | 1 | no | no |
| 208158 | Pristine Trogg Heart | 1 | 0 | 0 | no | no |
| 208159 | Severed Troll Head | 1 | 0 | 0 | no | no |
| 208160 | Severed Wendigo Paw | 1 | 0 | 0 | no | no |
| 208205 | Blackrat's Note | 1 | 0 | 1 | no | no |
| 208223 | Acolyte's Knapsack | 1 | 0 | 0 | no | no |
| 208224 | Acolyte's Note | 1 | 0 | 1 | no | no |
| 208610 | Severed Owl Head | 1 | 0 | 0 | no | no |
| 208611 | Severed Tiger Head | 1 | 0 | 0 | no | no |
| 208612 | Severed Spider Head | 1 | 0 | 0 | no | no |
| 208847 | Skull-Shaped Geode | 1 | 0 | 1 | no | no |
| 208848 | Cracked Skull-Shaped Geode | 1 | 0 | 1 | no | no |
| 209029 | Message from Emily | 1 | 0 | 1 | no | no |
| 209031 | Discreet Envelope | 1 | 0 | 1 | no | no |
| 209042 | Fishy Bonemeal | 1 | 0 | 1 | no | no |
| 209043 | Fertile Soil Sample | 1 | 0 | 1 | no | no |
| 209819 | Wyvern Taming Wand | 1 | 0 | 1 | no | no |
| 209838 | Hypnotic Crystal | 1 | 0 | 1 | no | no |
| 209840 | Gnarled Wand of Wild Magic | 1 | 0 | 1 | no | no |
| 209872 | Dragonslayer's Helm | 1 | 0 | 1 | no | no |
| 209873 | Dragonslayer's Shield | 1 | 0 | 1 | no | no |
| 209874 | Dragonslayer's Lance | 1 | 0 | 1 | no | no |
| 210187 | Venture Co. Work Order | 1 | 0 | 1 | no | no |
| 210329 | Hillsbrad Treasure Map | 1 | 0 | 0 | no | no |
| 210330 | Hot Tip | 1 | 0 | 1 | no | no |
| 210568 | Decrepit Phylactery | 1 | 0 | 1 | no | no |
| 210967 | Confidential Message | 1 | 0 | 1 | no | no |
| 211777 | Naga Manuscript | 1 | 0 | 1 | no | no |
| 211799 | Sack of Stolen Goods | 1 | 0 | 0 | no | no |
| 213443 | DEPRECATED ITEM | 1 | 0 | 1 | no | no |
| 213528 | Balmy Brew | 1 | 0 | 1 | no | no |
| 213529 | Viscous Venom | 1 | 0 | 1 | no | no |
| 213563 | Field Guide | 1 | 0 | 1 | no | no |
| 213565 | Entomology Starter Kit | 1 | 0 | 1 | no | no |
| 213701 | Strong Harpy Feather | 1 | 0 | 1 | no | no |
| 213709 | Cloud Serpent Fang | 1 | 0 | 1 | no | no |
| 215456 | Singed Message | 1 | 0 | 0 | no | no |
| 215458 | Enclosed Message | 1 | 0 | 0 | no | no |
| 215459 | Enclosed Message | 1 | 0 | 0 | no | no |
| 215460 | Enclosed Message | 1 | 0 | 0 | no | no |
| 216618 | Captain Aransas' Reward | 1 | 0 | 1 | no | no |
| 216637 | A Pile of Random Parts | 1 | 2500 | 0 | no | no |
| 217017 | Fishing Tournament! | 1 | 0 | 0 | no | no |
| 219399 | Nightmare Moss | 1 | 25 | 0 | no | no |
| 219401 | Cold Iron Ore | 1 | 150 | 0 | no | no |
| 219402 | Dream-Touched Dragonscale | 1 | 500 | 0 | no | no |
| 219414 | Shattered Eggshells | 1 | 0 | 0 | no | no |
| 219444 | Dreamroot | 1 | 75 | 0 | no | no |
| 219446 | Dream-Infused Dragonscale | 1 | 500 | 0 | no | no |
| 219454 | Star Lotus | 1 | 300 | 0 | no | no |
| 219487 | Starshell | 1 | 100 | 0 | no | no |
| 219514 | Moonroot | 1 | 100 | 0 | no | no |
| 219517 | Moondragon Scale | 1 | 500 | 0 | no | no |
| 219526 | Mission Brief: Duskwood | 1 | 12 | 0 | no | no |
| 219773 | Mission Brief: Ashenvale | 1 | 12 | 0 | no | no |
| 219774 | Mission Brief: Hinterlands | 1 | 12 | 0 | no | no |
| 219775 | Mission Brief: Feralas | 1 | 12 | 0 | no | no |
| 221017 | Keldara's Log | 1 | 0 | 1 | no | no |
| 221019 | Satyrweed Sample | 1 | 0 | 1 | no | no |
| 221260 | Head of the Obliterator | 1 | 0 | 1 | no | no |
| 221370 | Precious Medallion | 1 | 0 | 1 | no | no |
| 221371 | Kidnapper's Coin Purse | 1 | 0 | 1 | no | no |
| 221544 | Stormcrow Egg | 1 | 0 | 1 | no | no |
| 225676 | Molten Obsidian Core | 1 | 0 | 1 | no | no |
| 225929 | Plagued Soul Shard | 1 | 0 | 1 | no | no |
| 227549 | Scrap of Parchment | 1 | 0 | 1 | no | no |
| 227931 | Hidden Bundle | 1 | 0 | 1 | no | no |
| 228327 | Satchel of Silver Slaughter Coins | 1 | 0 | 0 | no | no |
| 235867 | Scrap of Parchment | 1 | 2500 | 0 | no | no |
| 237037 | Haute Club Membership Card | 1 | 0 | 1 | no | no |
| 243299 | Big Bag o' Gold | 1 | 0 | 0 | no | no |
| 247876 | [DNT] Minimus Tentaculus | 1 | 2500 | 0 | no | no |
| 249900 | Regurgitated Seed Pod | 1 | 0 | 0 | no | no |
| 251723 | Charged Stone | 1 | 0 | 1 | no | no |
| 252264 | "Gold" | 1 | 0 | 1 | no | no |
| 258771 | Al'Aketh Cultist's Ear | 1 | 0 | 0 | no | no |
| 262917 | Notarized Shipping Container | 1 | 0 | 1 | no | no |
| 268796 | Smuggled Goods | 1 | 0 | 1 | no | no |
| 269247 | Inert Phylactery | 1 | 0 | 1 | no | no |
| 270312 | Translated Tale of I'lalai | 1 | 0 | 0 | no | no |
| 270313 | Tale of I'lalai in Zandali | 1 | 0 | 0 | no | no |
| 271745 | Bloody Map | 1 | 0 | 0 | no | no |
| 271994 | Undermine Satchel | 1 | 0 | 0 | no | no |
| 272011 | Activated Ogre Lightning Rod | 1 | 0 | 1 | no | no |
| 272015 | Huge Quartz Gem | 1 | 200000 | 0 | no | no |
| 272016 | Gold Nugget | 1 | 100000 | 0 | no | no |
| 272124 | Translated Tale of I'lalai | 1 | 0 | 0 | no | no |
| 273050 | Blackmaw Pouch | 1 | 200 | 0 | no | no |
| 274041 | Document Box | 1 | 250000 | 0 | no | no |
| 276468 | Consecrated Holy Salts | 1 | 0 | 1 | no | no |
| 277533 | Fel Tainted Journal | 1 | 0 | 1 | no | no |
| 277651 | Bundle of Scrolls | 1 | 0 | 0 | no | no |
| 280943 | Tome of Tremayne Family Blacksmithing Techniques | 1 | 0 | 0 | no | no |
| 281347 | Torn Page | 1 | 170 | 0 | no | no |
| 281348 | Parchment of Chaos | 1 | 170 | 0 | no | no |
| 281349 | Parchment of Darkness | 1 | 170 | 0 | no | no |
| 281356 | Burnt Page | 1 | 170 | 0 | no | no |
| 281473 | Guild Charter | 1 | 0 | 0 | no | no |
| 284271 | Emergency Cache | 1 | 12 | 0 | no | no |
| 286210 | A Winter Veil Gift | 1 | 0 | 1 | no | no |

### 15/0 Misceláneo / Chatarra, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 8502 | Bronze Lotterybox | 2 | 0 | 0 | no | no |
| 8503 | Heavy Bronze Lotterybox | 2 | 0 | 0 | no | no |
| 8504 | Iron Lotterybox | 2 | 0 | 0 | no | no |
| 8505 | Heavy Iron Lotterybox | 2 | 0 | 0 | no | no |
| 8506 | Mithril Lotterybox | 2 | 0 | 0 | no | no |
| 8507 | Heavy Mithril Lotterybox | 2 | 0 | 0 | no | no |
| 10479 | Kovic's Trading Satchel | 2 | 24 | 0 | no | no |
| 10595 | Kum'isha's Junk | 2 | 0 | 0 | no | no |
| 10752 | Emerald Encrusted Chest | 2 | 0 | 0 | no | no |
| 10773 | Hakkari Urn | 2 | 0 | 0 | no | no |
| 12122 | Kum'isha's Junk | 2 | 0 | 0 | no | no |
| 13247 | Quartermaster Zigris' Footlocker | 2 | 5837 | 0 | no | no |
| 17962 | Blue Sack of Gems | 2 | 4762 | 0 | no | no |
| 17963 | Green Sack of Gems | 2 | 213 | 0 | no | no |
| 17964 | Gray Sack of Gems | 2 | 5512 | 0 | no | no |
| 17965 | Yellow Sack of Gems | 2 | 213 | 0 | no | no |
| 17969 | Red Sack of Gems | 2 | 4773 | 0 | no | no |
| 18250 | Gordok Shackle Key | 2 | 0 | 0 | no | no |
| 19035 | Lard's Special Picnic Basket | 2 | 250 | 0 | no | no |
| 19803 | Brownell's Blue Striped Racer | 2 | 0 | 0 | no | no |
| 19804 | Pale Ghoulfish | 2 | 0 | 0 | no | no |
| 19805 | Keefer's Angelfish | 2 | 0 | 0 | no | no |
| 19806 | Dezian Queenfish | 2 | 0 | 0 | no | no |
| 20402 | Agent of Nozdormu | 2 | 0 | 0 | no | no |
| 21528 | Colossal Bag of Loot | 2 | 0 | 0 | no | no |
| 22484 | Necrotic Rune | 2 | 0 | 0 | no | no |
| 22523 | Insignia of the Dawn | 2 | 0 | 0 | no | no |
| 22524 | Insignia of the Crusade | 2 | 0 | 0 | no | no |
| 22746 | Buccaneer's Uniform | 2 | 0 | 0 | no | no |
| 208765 | Helping Hand | 2 | 0 | 1 | no | no |
| 208766 | Helping Hand | 2 | 0 | 1 | no | no |
| 211419 | Handful of Shifting Scales | 2 | 0 | 0 | no | no |
| 213427 | Grime-Encrusted Salvage | 2 | 0 | 0 | no | no |
| 213452 | Dormant Holy Rune | 2 | 0 | 1 | no | no |
| 219445 | Fool's Gold Dust | 2 | 500 | 0 | no | no |
| 219486 | Starsilver Ore | 2 | 75 | 0 | no | no |
| 219515 | Greater Moonstone | 2 | 600 | 0 | no | no |
| 221262 | Wild Offering | 2 | 0 | 0 | no | no |
| 221471 | Emerald Wardens Chest | 2 | 0 | 0 | no | no |
| 225954 | Charred Spell Notes | 2 | 0 | 1 | no | no |
| 226405 | Damaged Undermine Supply Crate | 2 | 0 | 0 | no | no |
| 231642 | Warden's Herb Bag | 2 | 0 | 0 | no | no |
| 231644 | Warden's Enchanting Bag | 2 | 0 | 0 | no | no |
| 236414 | Damaged Undermine Supply Crate | 2 | 0 | 0 | no | no |
| 236878 | Mysterious Relic | 2 | 0 | 1 | no | no |
| 236879 | Mysterious Relic | 2 | 0 | 1 | no | no |
| 236880 | Mysterious Relic | 2 | 0 | 1 | no | no |
| 254432 | Carved Centaur Totem | 2 | 0 | 1 | no | no |
| 270257 | Captain Sander's Locker | 2 | 0 | 0 | no | no |
| 272001 | Gold Ring | 2 | 1000000 | 0 | no | no |
| 272014 | Silver Necklace | 2 | 400000 | 0 | no | no |
| 272151 | Damaged Undermine Supply Crate | 2 | 0 | 0 | no | no |

### 15/0 Misceláneo / Chatarra, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 20367 | Hunting Gear | 3 | 0 | 0 | no | no |
| 22637 | Primal Hakkari Idol | 3 | 0 | 58 | no | no |
| 234728 | Hakkari Summoning Token | 3 | 0 | 58 | no | no |
| 237024 | Opera Ticket | 3 | 0 | 1 | no | no |
| 272000 | Golden Statue | 3 | 3000000 | 0 | no | no |
| 274559 | Level 23 Cloth Gear | 3 | 0 | 0 | no | no |
| 274561 | Level 23 Leather Gear | 3 | 0 | 0 | no | no |
| 274562 | Level 23 Mail Gear | 3 | 0 | 0 | no | no |
| 274563 | Level 38 Cloth Gear | 3 | 0 | 0 | no | no |
| 274564 | Level 38 Leather Gear | 3 | 0 | 0 | no | no |
| 274565 | Level 38 Mail Gear | 3 | 0 | 0 | no | no |
| 274566 | Level 57 Cloth Gear | 3 | 0 | 0 | no | no |
| 274567 | Level 57 Leather Gear | 3 | 0 | 0 | no | no |
| 274568 | Level 57 Mail Gear | 3 | 0 | 0 | no | no |
| 274569 | Level 57 Plate Gear | 3 | 0 | 0 | no | no |
| 274570 | Level 60 Cloth Gear | 3 | 0 | 0 | no | no |
| 274571 | Level 60 Leather Gear | 3 | 0 | 0 | no | no |
| 274572 | Level 60 Mail Gear | 3 | 0 | 0 | no | no |
| 274573 | Level 60 Plate Gear | 3 | 0 | 0 | no | no |
| 274684 | Level 23 Mining Supplies | 3 | 0 | 0 | no | no |
| 274686 | Level 38 Mining Supplies | 3 | 0 | 0 | no | no |
| 274687 | Level 57 Mining Supplies | 3 | 0 | 0 | no | no |
| 274688 | Level 60 Mining Supplies | 3 | 0 | 0 | no | no |
| 274689 | Level 23 Herbalism Supplies | 3 | 0 | 0 | no | no |
| 274690 | Level 38 Herbalism Supplies | 3 | 0 | 0 | no | no |
| 274691 | Level 57 Herbalism Supplies | 3 | 0 | 0 | no | no |
| 274692 | Level 60 Herbalism Supplies | 3 | 0 | 0 | no | no |
| 274693 | Level 23 Skinning Supplies | 3 | 0 | 0 | no | no |
| 274694 | Level 38 Skinning Supplies | 3 | 0 | 0 | no | no |
| 274695 | Level 57 Skinning Supplies | 3 | 0 | 0 | no | no |
| 274696 | Level 60 Skinning Supplies | 3 | 0 | 0 | no | no |
| 274697 | Level 23 Cloth Supplies | 3 | 0 | 0 | no | no |
| 274698 | Level 38 Cloth Supplies | 3 | 0 | 0 | no | no |
| 274699 | Level 57 Cloth Supplies | 3 | 0 | 0 | no | no |
| 274700 | Level 60 Cloth Supplies | 3 | 0 | 0 | no | no |
| 274701 | Level 23 Enchanting Supplies | 3 | 0 | 0 | no | no |
| 274702 | Level 38 Enchanting Supplies | 3 | 0 | 0 | no | no |
| 274703 | Level 57 Enchanting Supplies | 3 | 0 | 0 | no | no |
| 274704 | Level 60 Enchanting Supplies | 3 | 0 | 0 | no | no |
| 276471 | Level 23 Hunter Supplies | 3 | 0 | 0 | no | no |
| 276472 | Level 38 Hunter Supplies | 3 | 0 | 0 | no | no |
| 276473 | Level 57 Hunter Supplies | 3 | 0 | 0 | no | no |
| 276474 | Level 60 Hunter Supplies | 3 | 0 | 0 | no | no |
| 278066 | Level 60 Tradeskill Supplies | 3 | 0 | 0 | no | no |
| 284092 | Keystone Fragment | 3 | 170 | 0 | no | no |

### 15/0 Misceláneo / Chatarra, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21103 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21104 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21105 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21106 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21107 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21108 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21109 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21110 | Draconic for Dummies | 4 | 0 | 0 | no | no |
| 21232 | Imperial Qiraji Armaments | 4 | 0 | 60 | no | no |
| 21237 | Imperial Qiraji Regalia | 4 | 0 | 60 | no | no |
| 22349 | Desecrated Breastplate | 4 | 0 | 60 | no | no |
| 22350 | Desecrated Tunic | 4 | 0 | 60 | no | no |
| 22351 | Desecrated Robe | 4 | 0 | 60 | no | no |
| 22352 | Desecrated Legplates | 4 | 0 | 60 | no | no |
| 22353 | Desecrated Helmet | 4 | 0 | 60 | no | no |
| 22354 | Desecrated Pauldrons | 4 | 0 | 60 | no | no |
| 22355 | Desecrated Bracers | 4 | 0 | 60 | no | no |
| 22356 | Desecrated Waistguard | 4 | 0 | 60 | no | no |
| 22357 | Desecrated Gauntlets | 4 | 0 | 60 | no | no |
| 22358 | Desecrated Sabatons | 4 | 0 | 60 | no | no |
| 22359 | Desecrated Legguards | 4 | 0 | 60 | no | no |
| 22360 | Desecrated Headpiece | 4 | 0 | 60 | no | no |
| 22361 | Desecrated Spaulders | 4 | 0 | 60 | no | no |
| 22362 | Desecrated Wristguards | 4 | 0 | 60 | no | no |
| 22363 | Desecrated Girdle | 4 | 0 | 60 | no | no |
| 22364 | Desecrated Handguards | 4 | 0 | 60 | no | no |
| 22365 | Desecrated Boots | 4 | 0 | 60 | no | no |
| 22366 | Desecrated Leggings | 4 | 0 | 60 | no | no |
| 22367 | Desecrated Circlet | 4 | 0 | 60 | no | no |
| 22368 | Desecrated Shoulderpads | 4 | 0 | 60 | no | no |
| 22369 | Desecrated Bindings | 4 | 0 | 60 | no | no |
| 22370 | Desecrated Belt | 4 | 0 | 60 | no | no |
| 22371 | Desecrated Gloves | 4 | 0 | 60 | no | no |
| 22372 | Desecrated Sandals | 4 | 0 | 60 | no | no |
| 226678 | Premonition and Combat Foresight | 4 | 0 | 1 | no | no |
| 227337 | Feline Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227338 | Astral Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227339 | Guardian's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227340 | Mender's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227341 | Pursuer's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227343 | Merciful Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227344 | Radiant Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227345 | Divine Will Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227346 | Dawn Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227347 | Twilight Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227348 | Thrill's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227350 | Relief's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227351 | Eruption's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227352 | Impact's Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227354 | Corrupted Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227356 | Immoveable Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227357 | Unstoppable Gloves and Belt Set | 4 | 12 | 0 | no | no |
| 227359 | Feline Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227360 | Astral Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227361 | Guardian's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227365 | Mender's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227366 | Pursuer's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227368 | Merciful Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227369 | Radiant Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227370 | Divine Will Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227371 | Dawn Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227372 | Twilight Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227373 | Thrill's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227375 | Relief's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227376 | Eruption's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227377 | Impact's Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227379 | Corrupted Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227381 | Immoveable Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227382 | Unstoppable Boots, Legs, and Shoulders Set | 4 | 12 | 0 | no | no |
| 227383 | Feline Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227384 | Astral Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227385 | Guardian's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227387 | Mender's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227388 | Pursuer's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227390 | Merciful Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227391 | Radiant Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227392 | Divine Will Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227393 | Dawn Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227394 | Twilight Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227395 | Thrill's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227397 | Relief's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227398 | Eruption's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227399 | Impact's Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227401 | Corrupted Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227403 | Immoveable Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 227404 | Unstoppable Helm and Chestpiece Set | 4 | 12 | 0 | no | no |
| 284093 | Keystone Fragment | 4 | 170 | 0 | no | no |

### 15/0 Misceláneo / Chatarra, calidad 5

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 18563 | Bindings of the Windseeker | 5 | 0 | 0 | no | no |
| 18564 | Bindings of the Windseeker | 5 | 0 | 0 | no | no |

### 15/1 Misceláneo / Reactivo, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 2895 | Creeping Pain | 1 | 12 | 0 | no | no |
| 2931 | Deprecated Maiden's Anguish | 1 | 25 | 0 | no | no |
| 5024 | Frost Vial | 1 | 10 | 0 | no | no |
| 5172 | Death Capsule | 1 | 25 | 0 | no | no |
| 5517 | Tiny Bronze Key | 1 | 50 | 0 | no | no |
| 5518 | Tiny Iron Key | 1 | 150 | 0 | no | no |
| 5564 | Felstone (Deprecated) | 1 | 375 | 0 | no | no |
| 8147 | Tiny Copper Key | 1 | 100 | 0 | no | no |
| 8148 | Tiny Silver Key | 1 | 375 | 0 | no | no |
| 17019 | Arcane Dust | 1 | 175 | 0 | no | no |
| 17024 | Wild Root | 1 | 175 | 0 | no | no |
| 17027 | Scented Candle | 1 | 100 | 0 | no | no |

### 15/3 Misceláneo / Festividad, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 21816 | Heart Candy | 1 | 0 | 1 | no | no |
| 21817 | Heart Candy | 1 | 0 | 1 | no | no |
| 21818 | Heart Candy | 1 | 0 | 1 | no | no |
| 21819 | Heart Candy | 1 | 0 | 1 | no | no |
| 21820 | Heart Candy | 1 | 0 | 1 | no | no |
| 21821 | Heart Candy | 1 | 0 | 1 | no | no |
| 21822 | Heart Candy | 1 | 0 | 1 | no | no |
| 21823 | Heart Candy | 1 | 0 | 1 | no | no |
| 21830 | Empty Wrapper | 1 | 0 | 0 | no | no |
| 21831 | Wrappered Gift | 1 | 0 | 0 | no | no |
| 21975 | Pledge of Adoration: Stormwind | 1 | 0 | 0 | no | no |
| 21979 | Gift of Adoration: Darnassus | 1 | 0 | 0 | no | no |
| 21980 | Gift of Adoration: Ironforge | 1 | 0 | 0 | no | no |
| 21981 | Gift of Adoration: Stormwind | 1 | 0 | 0 | no | no |
| 22058 | Valentine's Day Stationery | 1 | 0 | 0 | no | no |
| 22154 | Pledge of Adoration: Ironforge | 1 | 0 | 0 | no | no |
| 22155 | Pledge of Adoration: Darnassus | 1 | 0 | 0 | no | no |
| 22156 | Pledge of Adoration: Orgrimmar | 1 | 0 | 0 | no | no |
| 22157 | Pledge of Adoration: Undercity | 1 | 0 | 0 | no | no |
| 22158 | Pledge of Adoration: Thunder Bluff | 1 | 0 | 0 | no | no |
| 22159 | Pledge of Friendship: Darnassus | 1 | 0 | 0 | no | no |
| 22160 | Pledge of Friendship: Ironforge | 1 | 0 | 0 | no | no |
| 22161 | Pledge of Friendship: Orgrimmar | 1 | 0 | 0 | no | no |
| 22162 | Pledge of Friendship: Thunder Bluff | 1 | 0 | 0 | no | no |
| 22163 | Pledge of Friendship: Undercity | 1 | 0 | 0 | no | no |
| 22164 | Gift of Adoration: Orgrimmar | 1 | 0 | 0 | no | no |
| 22165 | Gift of Adoration: Thunder Bluff | 1 | 0 | 0 | no | no |
| 22166 | Gift of Adoration: Undercity | 1 | 0 | 0 | no | no |
| 22167 | Gift of Friendship: Darnassus | 1 | 0 | 0 | no | no |
| 22168 | Gift of Friendship: Ironforge | 1 | 0 | 0 | no | no |
| 22169 | Gift of Friendship: Orgrimmar | 1 | 0 | 0 | no | no |
| 22170 | Gift of Friendship: Stormwind | 1 | 0 | 0 | no | no |
| 22171 | Gift of Friendship: Thunder Bluff | 1 | 0 | 0 | no | no |
| 22172 | Gift of Friendship: Undercity | 1 | 0 | 0 | no | no |
| 22178 | Pledge of Friendship: Stormwind | 1 | 0 | 0 | no | no |
| 22262 | Alliance Gift Collection | 1 | 0 | 1 | no | no |
| 22263 | Horde Gift Collection | 1 | 0 | 1 | no | no |
| 23086 | [UNUSED] Letter Cookie | 1 | 0 | 0 | no | no |

### 15/4 Misceláneo / Otro, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6351 | Dented Crate | 1 | 1 | 0 | no | no |
| 6352 | Waterlogged Crate | 1 | 1 | 0 | no | no |
| 6357 | Sealed Crate | 1 | 1 | 0 | no | no |
| 6644 | Bloated Mackerel | 1 | 6 | 1 | no | no |
| 6646 | Bloated Albacore | 1 | 31 | 5 | no | no |
| 13874 | Heavy Crate | 1 | 1 | 0 | no | no |
| 19807 | Speckled Tastyfish | 1 | 0 | 0 | no | no |
| 269758 | Quest Reward Placeholder | 1 | 0 | 0 | no | no |
| 269759 | Quest Reward Placeholder | 1 | 0 | 0 | no | no |
| 270332 | Fredd's Head | 1 | 0 | 0 | no | no |
| 273318 | Pack of Journeyman Supplies | 1 | 0 | 1 | no | no |
| 273319 | Pack of Apprentice Supplies | 1 | 0 | 1 | no | no |
| 273320 | Pack of Expert Supplies | 1 | 0 | 1 | no | no |
| 273321 | Pack of Artisan Supplies | 1 | 0 | 1 | no | no |
| 274483 | The Walks of Shaman | 1 | 0 | 0 | no | no |
| 274964 | Mote of Unstable Magic | 1 | 200 | 0 | no | no |
| 275642 | Waylaid Herbs | 1 | 0 | 0 | no | no |
| 276278 | Handful of Coins | 1 | 0 | 1 | no | no |
| 276279 | Small Bag of Coins | 1 | 0 | 1 | no | no |
| 276280 | Hefty Sack of Coins | 1 | 0 | 1 | no | no |
| 276423 | Unstable Elemental Core | 1 | 200 | 0 | no | no |
| 277648 | Stormwind Library Card | 1 | 0 | 0 | no | no |
| 277649 | Undercity Library Card | 1 | 0 | 0 | no | no |
| 284583 | Coin Pouch | 1 | 0 | 1 | no | no |
| 284584 | Coin Pouch | 1 | 0 | 1 | no | no |
| 284585 | Coin Pouch | 1 | 0 | 1 | no | no |
| 284586 | Coin Pouch | 1 | 0 | 1 | no | no |

### 15/4 Misceláneo / Otro, calidad 2

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 6643 | Bloated Brilliant Smallfish | 2 | 6 | 0 | no | no |
| 6645 | Bloated Mud Snapper | 2 | 25 | 0 | no | no |
| 6647 | Bloated Bristle Whisker Catfish | 2 | 40 | 0 | no | no |
| 8366 | Bloated Mithril Head Trout | 2 | 100 | 0 | no | no |
| 13881 | Bloated Redgill | 2 | 100 | 0 | no | no |
| 13891 | Bloated Whitescale Salmon | 2 | 100 | 0 | no | no |
| 21162 | Bloated Oily Blackmouth | 2 | 25 | 0 | no | no |
| 21163 | Bloated Firefin Snapper | 2 | 40 | 0 | no | no |
| 21164 | Bloated Rockscale Cod | 2 | 100 | 0 | no | no |
| 21243 | Bloated Glossy Mightfish | 2 | 100 | 0 | no | no |
| 274974 | Message in a Bottle | 2 | 0 | 1 | no | no |
| 277534 | Arena Spoils | 2 | 12 | 0 | no | no |
| 281680 | Customer Service Care Package | 2 | 0 | 1 | no | no |

### 15/4 Misceláneo / Otro, calidad 3

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 274026 | Extravagant Extravaganza Coin | 3 | 0 | 0 | no | no |

### 15/4 Misceláneo / Otro, calidad 4

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 274020 | Seal of Armorcrafting | 4 | 0 | 1 | no | no |

### 18/0 Ficha de WoW / Sin subclase declarada en ItemSubClass, calidad 1

| ID | Nombre | Calidad | Precio de venta | Nivel requerido | Uso | Equipar |
| ---: | --- | ---: | ---: | ---: | --- | --- |
| 122270 | WoW Token | 1 | 0 | 1 | no | no |
| 122284 | WoW Token | 1 | 0 | 1 | no | no |
