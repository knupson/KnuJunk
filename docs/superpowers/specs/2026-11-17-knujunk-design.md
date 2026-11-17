# KnuJunk — diseño (2026-11-17)

Addon de WoW Forever (Interface 16001, Lua 5.1) del ecosistema Knunet (KnuUI, KnuMail, KnuSonda, KnuLib). Idea del user. Material de respaldo en `E:\Repositorios\Personal\_datos\WOWAddons\knubags\`: `requisitos-user-2026-11-17.md`, `propuesta-2026-11-17.md`, `analisis/` (fichas de 18+ competidores con citas `archivo:línea`, comentarios de CurseForge, matriz de 69 addons, síntesis y auditoría).

## 1. Intención
El jugador abre la bolsa y sabe al instante qué puede vender o tirar y qué material le sirve a una profesión, sin pasar el mouse por cada item. Lo mismo al lootear un mob. Las cuatro molestias del user: bolsas llenas de basura, items de misiones viejas, no saber qué material guardar, miedo a tirar algo útil.

## 2. Objetivos
1. **Monedita** en el slot de lo vendible/tirable: (a) gris; (b) item de misión cuyas misiones ya entregaste o ya no podés hacer; (c) equipo que tu clase nunca puede equipar. Los materiales de profesiones que no tenés llevan martillito gris (ver §7).
2. **Martillito** en el slot de los materiales de profesión: verde si una profesión tuya lo usa, gris si no. Mouseover sobre el item: línea en el tooltip con la profesión («Minería», «Herrería, Ingeniería»).
3. Tooltip con el **motivo** de la monedita («Misión entregada: X», «Tu clase no usa Placas», «Ninguna de tus profesiones usa esto»).
4. **Ventana de botín**: mismas marcas (monedita, martillito) y una marca de misión para lo que pide una misión activa.
5. **Compatibilidad**: las 21 bolsas que soporta la competencia + un hook genérico. La beta no sale sin las 21 (decisión del user).
6. **Ecosistema Knunet** con KnuLib-1.0 MINOR 4 embebida: `/knu junk`, textos es/en, tema compartido con KnuUI.

## 3. No-objetivos (beta 0.1)
- No es un addon de bolsas: no dibuja ventanas de bolsa ni banco (evaluable más adelante si prende).
- No vende ni borra nada automáticamente (plus posterior).
- «Equipo peor que lo puesto», lista de recetas por comando, mandar a un alt con KnuMail, banco y alts vía Syndicator, precios de subasta: después.

## 4. Anti-objetivos (fracaso aunque funcione)
- **Una monedita falsa.** Si el addon marca para vender algo que hacía falta (caso Magic Eraser con el Befouled Water Globe; Keep or Toss con el pergamino de Cyclonian), perdemos la confianza. Regla: ante cualquier duda, sin monedita.
- **Tooltip ruidoso**: nada de líneas en items que no son material ni tirables (queja contra What's This Reagent y Keep or Toss).
- **Taint / «acción bloqueada por Blizzard»** (queja contra Keep or Toss): sólo `hooksecurefunc` y APIs públicas de cada addon de bolsas; nada sobre frames protegidos en combate.
- **Trabas de rendimiento** al abrir bolsas o lootear (Peddler agenda una pasada por cada `BAG_UPDATE` sin agrupar).
- Depender de Questie (el user lo tiene apagado).

## 5. Restricciones
- WoW Forever, Interface 16001, Lua 5.1. Verificar cada evento/API en el juego antes de confiar (en Forever `MAIL_CLOSED` no llega: `CONVENCION.md`).
- KnuLib-1.0 MINOR 4 embebida desde `E:\Repositorios\Personal\KnuLib` (API: `NewLocale`, `NewPrinter`, `RegisterCommand`, `GetTheme`, `RegisterCallback`, `StylePanel`, `StyleButton`, `Hoverable`). Subcomando común `/knu junk`.
- No se copia código de la competencia (Keep or Toss es «All Rights Reserved»). Se imita el enfoque, se escribe de cero.
- Nada se escribe en `D:\World of Warcraft` (sólo lectura).
- Auditoría doble con Codex sobre todo código; humanizer para textos de CurseForge.

## 6. Enfoques considerados (fuente de datos)
| Enfoque | Trade-off |
|---|---|
| **A. Tablas propias generadas desde los datos del cliente Forever en wago.tools + estado del personaje en vivo; QuestieDB sólo como extra opcional** | Funciona sin Questie y sin licencia GPL; hay que regenerar en cada parche y armar la lógica de cadenas. |
| B. Índice derivado de QuestieDB Forever (como QuestJunkSweeper) | Mejor dato de cadenas, pero GPL-3.0-only. |
| C. Sólo API en vivo | No hay API que diga «este item es de qué misión»: no cubre misiones viejas. |

**Elegido por el user: A** (2026-11-17). Verificado: wago.tools publica Forever como producto `wowf` (builds 1.60.1.70959, 70938, 70888 el 17/11).

## 7. Lo decidido
### Marcas
- Monedita = «vendible/tirable»; martillito = «material que usa una profesión tuya»; marca de misión sólo en el botín (necesario para una misión activa).
- Precedencia por item: si algo es útil por cualquier motivo (misión activa, profesión tuya, herramienta, reactivo de hechizo de tu clase), **no** lleva monedita.
- En Baganator la monedita es la nativa de Baganator vía `Baganator.API.RegisterJunkPlugin` (`Baganator/API/Main.lua:62-66`: devolver `true` hace que Baganator muestre su moneda de basura); el martillito vía `RegisterCornerWidget` (`:229`).

### Datos (enfoque A)
- Script generador en el repo (fuera del addon empaquetado) que baja tablas de wago.tools para `wowf` y produce Lua: item → profesiones que lo usan como reactivo; item → misiones (objetivo, inicio, entrega) con datos de cadena/repetible/raza/clase; subtipos de arma/armadura por clase.
- Cada tabla generada lleva la build de origen en el encabezado.
- En vivo: `C_QuestLog.IsQuestFlaggedCompleted` (y respaldo global si falta), diario activo, profesiones aprendidas, clase.
- Item de misión → monedita sólo si **ninguna** misión aplicable a tu personaje sigue pendiente ni es repetible (opuesto a la regla «alcanza con una» de Magic Eraser). Estado «no sé» = sin monedita.

### Bolsas (21 + genérico)
Blizzard (bolsas individuales y combinada), Baganator (API oficial), Bagnon/Bagnonium, ElvUI, AdiBags, BetterBags, ArkInventory, EllesmereUIBags, LiteBag, tdBag2, BaudBag, Baggins, Combuctor, OneBag3, Inventorian, cargBags_Nivaya, m_Bags, DerpyStuffing, famBags, LUI, RealUI_Inventory. Para el resto, hook genérico (`SetItemButtonQuality` / `ContainerFrameItemButtonMixin`). Mecanismo de cada uno documentado en `analisis/_sintesis-gemini.md` §4 con las correcciones de `analisis/_auditoria-codex.md`. Preferencia por API pública del addon de bolsas; recorrer frames internos sólo si no hay otra.

### Integración Knunet
`/knu junk` (ayuda, activar/desactivar marcas, recargar tablas); textos con `NewLocale(es, en)`; mensajes con `NewPrinter('KnuJunk')`; colores/acento del tema KnuLib (KnuUI lo provee si está cargado).

### Decisiones del user tras la revisión del constructor (2026-11-17)
1. **Misiones — QuestieDB opcional.** Verificado: wago.tools `wowf` no tiene `questobjective`; sí `ItemSparse.StartQuestID`. Sin QuestieDB: monedita sólo en items que **inician** una misión ya hecha (o imposible para tu raza/clase). Con QuestieDB cargado (LibQuestieDB, como Keep or Toss `Core.lua:74-79`): también objetivos y entregas. QuestieDB no se embebe (sin GPL en el paquete; implicancia legal del uso en ejecución: no verificada). El user hoy no tiene Questie ni QuestieDB instalados (verificado en `Interface/AddOns`).
2. **Corregir una marca — beta: comandos** `/knu junk keep <item>` / `/knu junk sell <item>`, con el estado visible en el tooltip. **Para la versión final el user exige algo directo en la interfaz** («no podés hacer que un tipo tire un comando para excluir cada item, es estúpido, difícil y lento»): menú o clic sobre el item, diseñado aparte.
3. **Bolsas sin versión Forever o no instalables: se saltan con aviso** (quedan con el hook genérico y se anota en la página de CurseForge). «Soportada» = probada en el juego por el user.
4. **Martillito de dos colores** (idea del user): **verde** = material que usa una profesión tuya; **gris** = material de una profesión que no tenés. La monedita queda para la basura real (gris, misión terminada, equipo que tu clase nunca usa). El tooltip nombra las profesiones. Así un personaje sin profesiones no se llena de monedas.

### Decisiones del constructor (Claude, corregibles)
- **Superficies**: sólo las bolsas del personaje actual y la ventana de botín de Blizzard. Banco, banco de hermandad, bolsa de reactivos y vistas cacheadas de otros personajes (Baganator/Bagnon) **sin marcas** en la beta: con clase/profesiones de otro personaje serían monedas falsas.
- **Equipo inútil** = subtipo de arma/armadura que tu clase **nunca** podrá equipar (no «todavía no»). Ranuras sin subtipo (anillos, abalorios, capas, camisas, tabardos) quedan fuera. Sin monedita si tiene efecto de uso/equipar o es parte de un set.
- **Profesiones**: cuentan principales y secundarias (Cocina, Primeros Auxilios, Pesca).
- **Baganator**: se registra el junk plugin; activarlo lo elige el jugador en las opciones de Baganator (no tocamos su configuración). Si no está activo, la monedita va por `RegisterCornerWidget` igual que el martillito.
- **Botín**: `LootFrame` de Blizzard; otros marcos de botín, después. Con autolooteo no hay ventana y no se marca nada.
- **Carpeta y licencia**: el repo y la carpeta del addon pasan a llamarse `KnuJunk` al arrancar el código; licencia MIT como KnuLib; empaquetado con el `release.yml` común (`CONVENCION.md` §3).

## 8. Lo que queda al constructor
- Estructura de archivos, nombres internos, formato exacto de las tablas generadas y su compresión.
- Cómo agrupar eventos (`BAG_UPDATE_DELAYED`, botín) y qué cachear por item vs. por personaje.
- Textura exacta de monedita y martillito (íconos del juego o propios), posición por defecto en el slot.
- Plan de prueba por bolsa en el juego (el user instala cada addon de bolsas en Forever y prueba).
- Pruebas automáticas con el stub de WoW común (`CONVENCION.md` §4).
