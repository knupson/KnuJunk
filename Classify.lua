local _, ns = ...

-- Clasificador: una marca por ítem legible. Ante la duda, útil; nunca moneda ni basura.
-- El núcleo decide utilidad; la salida consulta Auctionator de forma opcional y protegida.
-- item = { id, quality, classID, subclassID, equipLoc, hasUseOrEquipSpell, isSetPiece, price, isBound, reqLevel }
--   isBound = true solo si la bolsa confirma que el ejemplar esta ligado; false/nil = no (o no se sabe).
--   hasUseOrEquipSpell = true tambien cuando no se puede saber (sin API de hechizos).
-- ctx  = { class, level, professions = {[skillLineID]=true}, isQuestDone(questID)->true|false|nil,
--          questInLog(questID)->true|false|nil, questItemsInLog = {[itemID]=true},
--          questItemTitle(itemID)->titulo|nil,
--          questieUses(itemID)->{ {questID=, repeatable=, starter=, reputationFactions={factionID,...}} }|nil,
--          overrides = {[itemID]='keep'|'sell'}, questLogIncomplete = true|nil }
-- result = { mark = uno de ns.IconKinds o nil pendiente, reasons = { {kind=...} }, auctionPrice = número|nil }
-- quest conserva el dato de material de misión; reasonMark conserva la marca de profesión para los motivos.
-- Misiones (decision del user, 2026-11-17): un item de mision solo es util si lo pide una mision que
-- esta AHORA en el diario; si no, monedita 'quest_not_active' (futuras, no tomadas, hechas y
-- repetibles no tomadas no protegen, salvo entregas de reputación R20). Los iniciadores siguen su propia regla: mision no hecha (o
-- sin saberlo) -> util ('quest_starter'); hecha y no repetible CONFIRMADO por QuestieDB (repeatable =
-- false) -> monedita 'quest_done'; hecha sin saber si es repetible -> sin moneda
-- ('quest_starter_done_unknown_repeat').
-- Libros de biblioteca y cajones arrebatados (Data/Special.lua): útiles y sin moneda automática,
-- motivo 'library_book' o 'waylaid_crate' (sealed = true si el cajon ya esta lleno).

local ITEM_CLASS_WEAPON, ITEM_CLASS_ARMOR, ITEM_CLASS_QUEST = 2, 4, 12

-- Subclases que alguna clase puede usar. Las que no estan (armadura 0 miscelaneo,
-- arma 20 cania, libros, etc.) nunca dan monedita.
local knownSubclasses
local function isKnownSubclass(kind, subclassID)
    if not knownSubclasses then
        knownSubclasses = { armor = {}, weapon = {} }
        for _, gear in pairs(ns.ClassGear) do
            for id in pairs(gear.armor) do knownSubclasses.armor[id] = true end
            for id in pairs(gear.weapon) do knownSubclasses.weapon[id] = true end
        end
    end
    return knownSubclasses[kind][subclassID] == true
end

-- true solo si el cliente dice explicitamente true; false y nil (no se sabe) son "no".
local function questDone(ctx, questID)
    if type(ctx.isQuestDone) ~= 'function' or questID == nil then return false end
    return ctx.isQuestDone(questID) == true
end

-- true/false segun el diario; nil si no se puede saber (sin questInLog o el diario no lo sabe).
local function inLog(ctx, questID)
    if type(ctx.questInLog) ~= 'function' or questID == nil then return nil end
    local answer = ctx.questInLog(questID)
    if answer == true or answer == false then return answer end
    return nil
end

local function classCannotUse(item, ctx)
    local kind
    if item.classID == ITEM_CLASS_ARMOR then kind = 'armor'
    elseif item.classID == ITEM_CLASS_WEAPON then kind = 'weapon'
    else return false end
    local subclassID = item.subclassID
    if type(subclassID) ~= 'number' or not isKnownSubclass(kind, subclassID) then return false end
    local gear = ctx.class and ns.ClassGear[ctx.class]
    if not gear then return false end
    return gear[kind][subclassID] ~= true
end

local CLASS_BITS = {
    WARRIOR = 1, PALADIN = 2, HUNTER = 4, ROGUE = 8, PRIEST = 16,
    SHAMAN = 64, MAGE = 128, WARLOCK = 256, DRUID = 1024,
}

local function hasClassBit(mask, bit)
    if type(mask) ~= 'number' or type(bit) ~= 'number' or bit <= 0 then return false end
    if mask <= 0 then return true end -- -1 o 0: todas las clases
    return math.floor(mask / bit) % 2 == 1
end

local function knowsClassBookSpell(spell)
    if type(spell) ~= 'number' or spell <= 0 then return nil end
    local known, checked = false, false
    for _, apiName in ipairs({ 'IsPlayerSpell', 'IsSpellKnown' }) do
        local fn = rawget(_G, apiName)
        if type(fn) == 'function' then
            local ok, res = pcall(fn, spell)
            if not ok then return nil end
            checked = true
            if res == true then known = true end
        end
    end
    if not checked then return nil end
    return known
end

local function isOpenable(item)
    return item.openable == true or (ns.Data.openables and ns.Data.openables[item.id] == true) or false
end

local function noRuleException(item)
    if isOpenable(item) then return 'openable' end
    local c = item.classID
    if c == 1 or c == 11 then return 'bag'
    elseif c == 2 or c == 4 then return 'gear'
    elseif c == 6 then return 'ammo'
    elseif c == 9 then return 'book'
    elseif c == 12 then return 'quest'
    elseif c == 13 then return 'key' end
    if type(item.quality) == 'number' and item.quality >= 3 then return 'rare_or_epic' end
    return nil
end

local function classify(item, ctx)
    local result = { mark = nil, reasons = {} }
    local reasons = result.reasons
    if type(item) ~= 'table' or type(ctx) ~= 'table' or item.id == nil then return result end
    local id = item.id
    local rules = ctx.rules or {}

    -- 1. Overrides del usuario.
    local override = ctx.overrides and ctx.overrides[id]
    if override == 'keep' then
        reasons[#reasons + 1] = { kind = 'override_keep' }
        return result
    elseif override == 'sell' then
        result.mark = 'coin'
        reasons[#reasons + 1] = { kind = 'override_sell' }
        return result
    end

    -- Libros de biblioteca y cajones arrebatados de Forever (Data/Special.lua): se guardan hasta
    -- entregarlos al bibliotecario o al representante de comercio. Nunca moneda automatica, aunque
    -- sean de clase Mision y ninguna mision del diario los pida; sin marca, motivo para el tooltip.
    local specialReason
    if ns.Data.libraryBooks and ns.Data.libraryBooks[id] then specialReason = { kind = 'library_book' } end
    local crate = ns.Data.waylaidCrates and ns.Data.waylaidCrates[id]
    if crate and not specialReason then specialReason = { kind = 'waylaid_crate', sealed = crate == 'sealed' or nil } end

    -- R18 sólo evita la moneda; misión activa y profesión conservan sus marcas.
    local lockReason
    if item.classID == 13 or (ns.Data.keys and ns.Data.keys[id]) then
        lockReason = { kind = 'key' }
    elseif ns.Data.lockboxes and ns.Data.lockboxes[id] then
        lockReason = { kind = 'lockbox' }
    end

    -- Datos del item sin cargar: no se decide nada.
    if item.quality == nil then
        if specialReason then reasons[#reasons + 1] = specialReason end
        if lockReason then reasons[#reasons + 1] = lockReason end
        return result
    end

    -- 2. Misiones. Iniciadores (Data.starters o QuestieDB con starter = true) aparte del resto.
    local uses = type(ctx.questieUses) == 'function' and ctx.questieUses(id) or nil
    local starterQuest = ns.Data.starters and ns.Data.starters[id]
    local starterPending, starterRepeatable
    if starterQuest and not questDone(ctx, starterQuest) then starterPending = starterQuest end
    local questUses, logUnknown = {}, false
    for _, use in ipairs(uses or {}) do
        if use.starter then
            starterQuest = starterQuest or use.questID
            if not starterPending and not questDone(ctx, use.questID) then starterPending = use.questID end
        else
            questUses[#questUses + 1] = use
        end
    end
    -- Repetibilidad del iniciador segun QuestieDB: true/false solo si alguna entrega de esa mision lo
    -- dice explicitamente; nil = no se sabe (sin QuestieDB, sin entrada o sin el dato).
    local starterRepeat
    for _, use in ipairs(uses or {}) do
        if starterQuest and use.questID == starterQuest then
            if use.repeatable == true then starterRepeat = true
            elseif use.repeatable == false and starterRepeat == nil then starterRepeat = false end
        end
    end
    if starterRepeat == true then starterRepeatable = starterQuest end
    -- Util para una mision del diario: sin monedita. Si ademas es reactivo o herramienta, manda el
    -- martillo (paso 3) con quest = true; si no, la marca es 'quest'.
    local questReasons = {}
    for _, use in ipairs(questUses) do
        local answer = inLog(ctx, use.questID)
        if answer == true then
            questReasons[1] = { kind = 'quest_active', questID = use.questID }
            break
        elseif answer == nil then
            logUnknown = true
        end
    end
    if #questReasons == 0 and ctx.questItemsInLog and ctx.questItemsInLog[id] then
        local title = type(ctx.questItemTitle) == 'function' and ctx.questItemTitle(id) or nil
        questReasons[1] = { kind = 'quest_active', title = type(title) == 'string' and title or nil }
    end
    for _, reason in ipairs(questReasons) do reasons[#reasons + 1] = reason end
    if lockReason then reasons[#reasons + 1] = lockReason end
    result.uncertain = ctx.questLogIncomplete or logUnknown or item.effect == 'unknown'
    if specialReason then
        reasons[#reasons + 1] = specialReason
        if #questReasons > 0 then result.mark = 'quest' end
        return result
    end

    -- 3. Reactivo o herramienta de profesion (la herramienta se pide pero no se consume: martillo,
    -- pico, cuchillo). Mismo trato: martillito verde si es de una profesion tuya, naranja si no; nunca
    -- monedita automatica, aunque el item sea gris. Si es las dos cosas, manda el reactivo salvo que solo la
    -- herramienta sea de una profesion tuya.
    local reagentLines = ns.Data.reagents and ns.Data.reagents[id]
    local toolLines = ns.Data.tools and ns.Data.tools[id]
    local recipe = ns.Data.recipes and ns.Data.recipes[id]
    -- Las cañas de pescar no figuran en spelltotems de Forever (Pesca no las pide como herramienta),
    -- pero son la herramienta de Pesca: arma (classID 2) de subclase 20.
    if not toolLines and item.classID == 2 and item.subclassID == 20 then toolLines = { 356 } end
    local function mineOf(list)
        local mine = {}
        for _, line in ipairs(list or {}) do
            if ctx.professions and ctx.professions[line] then mine[#mine + 1] = line end
        end
        return mine
    end
    local function copy(list)
        local all = {}
        for i, line in ipairs(list) do all[i] = line end
        return all
    end
    local mineReagent, mineTool = mineOf(reagentLines), mineOf(toolLines)
    if #questReasons > 0 then
        if reagentLines or toolLines or recipe then result.quest = true else
            result.mark = 'quest'
            return result
        end
    end
    if #mineReagent > 0 then
        result.mark = 'hammer_mine'
        reasons[#reasons + 1] = { kind = 'profession', professions = mineReagent }
        return result
    elseif #mineTool > 0 then
        result.mark = 'hammer_mine'
        reasons[#reasons + 1] = { kind = 'profession_tool', professions = mineTool }
        return result
    end
    -- R14 por defecto; R12/R13 sólo difieren la receta conocida para evaluar todas las P.
    local knownRecipe = rules.knownRecipe == true and item.classID == 9 and item.knownRecipe == true
        and #questReasons == 0
    local recipeReasonIndex
    if recipe then
        result.mark = ctx.professions and ctx.professions[recipe.skillLine] and 'hammer_mine' or 'hammer_other'
        reasons[#reasons + 1] = { kind = 'recipe', skillLine = recipe.skillLine, rank = recipe.rank }
        if not knownRecipe then return result end
        -- R14 queda de respaldo incluso si una protección corta antes del bloque opcional.
        recipeReasonIndex = #reasons
    end
    -- Reactivo o herramienta de un hechizo de clase (Data/ClassReagents.lua: runas del mago, ankh,
    -- fragmento de alma, venenos...). Sin moneda y sin marca (nunca martillo, que es de profesiones);
    -- no se exige que el hechizo ya este aprendido. Si ademas es material o herramienta de profesion,
    -- manda el martillo (verde o amarillo): la clase solo evita la moneda. spells solo para tu clase.
    local classReagent = ns.Data.classReagents and ns.Data.classReagents[id]
    local classReason
    if type(classReagent) == 'table' then
        local classes, own = {}, false
        for i, name in ipairs(classReagent) do
            classes[i] = name
            if name == ctx.class then own = true end
        end
        local spells = own and type(classReagent.spells) == 'table' and classReagent.spells[ctx.class] or nil
        classReason = { kind = 'class_reagent', own = own, classes = classes, class = own and ctx.class or nil,
            spells = own and (type(spells) == 'table' and spells or {}) or nil }
    end
    if reagentLines then
        result.mark = 'hammer_other'
        reasons[#reasons + 1] = { kind = 'profession', professions = copy(reagentLines) }
        return result
    elseif toolLines then
        result.mark = 'hammer_other'
        reasons[#reasons + 1] = { kind = 'profession_tool', professions = copy(toolLines) }
        return result
    end
    if classReason then
        -- Reactivo de otra clase (decision del user 2026-11-21): no te sirve, se vende como un libro de
        -- otra clase. Sin precio, de la clase Misión (12) o con el diario sin leer, se guarda como antes.
        if not classReason.own and ctx.class and item.classID ~= 12 and (item.price or 0) > 0 then
            if ctx.questLogIncomplete or logUnknown then
                result.reasons = { { kind = 'quest_log_incomplete' } }
                return result
            end
            result.mark = 'coin'
            reasons[#reasons + 1] = { kind = 'class_reagent_other', classes = classReason.classes }
            return result
        end
        reasons[#reasons + 1] = classReason
        return result
    end
    if lockReason then return result end
    local classBook = item.classID == 9 and item.subclassID == 0 and ns.Data.classBooks and ns.Data.classBooks[id]
    if classBook then
        local classBit = ctx.class and CLASS_BITS[ctx.class]
        if not classBit then return result end
        if not hasClassBit(classBook.classMask, classBit) then
            if ctx.questLogIncomplete or logUnknown then
                result.reasons = { { kind = 'quest_log_incomplete' } }
                return result
            end
            if item.effect == 'unknown' then return result end
            result.mark = 'coin'
            if item.isBound == true then
                reasons[#reasons + 1] = { kind = 'class_cannot_use', classID = item.classID,
                    subclassID = item.subclassID, subclassName = item.subclassName }
            else
                reasons[#reasons + 1] = { kind = 'book_other_class' }
            end
            return result
        end
        local known = knowsClassBookSpell(classBook.spell)
        if known == true then
            if ctx.questLogIncomplete or logUnknown then
                result.reasons = { { kind = 'quest_log_incomplete' } }
                return result
            end
            if item.effect == 'unknown' then return result end
            result.mark = 'coin'
            reasons[#reasons + 1] = { kind = 'book_known', spell = classBook.spell }
            return result
        elseif known == false then
            reasons[#reasons + 1] = { kind = 'book_unknown', spell = classBook.spell }
            return result
        end
        return result
    end
    -- Una receta sin profesión identificada tampoco es basura confirmada.
    if item.classID == 9 and not knownRecipe then return result end

    -- R20: excepción del dueño a «fuera del diario = moneda». Sólo objetivos de entregas
    -- repetibles que otorgan reputación; misión activa y profesión conservan su precedencia.
    for _, use in ipairs(questUses) do
        if use.repeatable == true and type(use.reputationFactions) == 'table' and #use.reputationFactions > 0 then
            local factions = {}
            for i, factionID in ipairs(use.reputationFactions) do factions[i] = factionID end
            reasons[#reasons + 1] = { kind = 'reputation_token', factionIDs = factions, questID = use.questID }
            return result
        end
    end

    -- Iniciador de mision cuya mision no esta confirmada como hecha (false o nil): es util,
    -- sin marca y sin monedita aunque sea gris. Hecha pero repetible: tampoco hay moneda.
    if starterPending then
        reasons[#reasons + 1] = { kind = 'quest_starter', questID = starterPending }
        return result
    end
    if starterRepeatable then
        reasons[#reasons + 1] = { kind = 'quest_repeatable', questID = starterRepeatable }
        return result
    end
    -- Tanda 1, regla 4: mision hecha pero sin confirmar que NO es repetible (sin QuestieDB o sin el
    -- dato): no se sabe si el item vuelve a servir, asi que ninguna moneda automatica.
    if starterQuest and questDone(ctx, starterQuest) and starterRepeat ~= false then
        reasons[#reasons + 1] = { kind = 'quest_starter_done_unknown_repeat', questID = starterQuest }
        return result
    end

    -- R24: sólo subtipos que la clase puede llegar a usar, con ambos niveles conocidos.
    local gear = ctx.class and ns.ClassGear[ctx.class]
    local kind = item.classID == 4 and 'armor' or item.classID == 2 and 'weapon' or nil
    -- Los grises quedan afuera: el gris es basura para el dueño aunque sea de nivel futuro.
    if item.quality ~= 0 and gear and kind and gear[kind][item.subclassID] == true
        and type(item.reqLevel) == 'number' and type(ctx.level) == 'number' and item.reqLevel > ctx.level then
        reasons[#reasons + 1] = { kind = 'future_level', level = item.reqLevel }
        return result
    end

    -- Efecto de uso/equipar en tres estados (Player.ReadLink): 'yes' (evidencia: GetItemSpell o una
    -- linea del tooltip), 'no' (tooltip completo sin efecto) o 'unknown'. Sin item.effect (items armados
    -- a mano) se deriva de hasUseOrEquipSpell: true = 'yes', false/nil = 'no'.
    local effect = item.effect
    if effect ~= 'yes' and effect ~= 'no' and effect ~= 'unknown' then
        effect = item.hasUseOrEquipSpell and 'yes' or 'no'
    end
    -- Un efecto confirmado o una pieza de set conservan utilidad: ninguna moneda automatica.
    -- En recetas (clase 9), el uso que enseña no protege de R12/R13.
    -- En armas y armaduras, «Equipar:» son estadísticas: las juzga la cadena de equipo (GearQuest,
    -- Pawn, nivel de objeto), no esta regla. Caso real: Cinturón de equilibrista (16659).
    local isGear = item.classID == ITEM_CLASS_WEAPON or item.classID == ITEM_CLASS_ARMOR
    if (effect == 'yes' and not isGear and item.classID ~= 9 and item.classID ~= ITEM_CLASS_QUEST
        and not classCannotUse(item, ctx) and not (rules.food == true and item.restorationOnly == true
        and ns.Data.food and ns.Data.food[id])) or item.isSetPiece then
        reasons[#reasons + 1] = { kind = 'useful', setPiece = item.isSetPiece or nil }
        return result
    end
    -- Efecto desconocido: ninguna moneda automática, tampoco por calidad gris.
    local unknownEffect = effect == 'unknown'

    -- Opcionales: después de TODAS las protecciones; diario incompleto nunca habilita moneda.
    if not unknownEffect and not ctx.questLogIncomplete and not logUnknown then
        if knownRecipe then
            result.mark = nil
            if recipeReasonIndex then table.remove(reasons, recipeReasonIndex) end
            if item.isBound == true then
                result.mark = 'coin'
                reasons[#reasons + 1] = { kind = 'recipe_known' }
            else
                reasons[#reasons + 1] = { kind = 'recipe_known_tradeable' }
            end
            return result
        end
        -- Los cazadores conservan toda comida/bebida: sus mascotas comen comida común.
        local food = rules.food == true and ctx.class ~= 'HUNTER' and item.classID == 0 and item.subclassID == 5
            and item.bag and item.bag >= 0 and item.bag <= 4 and item.slot
            and ns.Data.food and ns.Data.food[id]
        if food and type(ctx.level) == 'number' and ctx.level >= food.reqLevel + 15 then
            for _, stock in ipairs(ctx.bagStock or {}) do
                local better = stock.usable == true and ns.Data.food[stock.id]
                -- Una alternativa debe superar todos los recursos que restaura el original.
                if better and better.reqLevel <= ctx.level
                    and (not food.health or (better.health and better.health > food.health))
                    and (not food.mana or (better.mana and better.mana > food.mana)) then
                    result.mark = 'coin'; reasons[#reasons + 1] = { kind = 'food_outgrown' }
                    return result
                end
            end
        end
        local ammo = rules.ammo == true and item.classID == 6 and ns.Data.ammo and ns.Data.ammo[id]
        -- Sólo ejemplares de bolsas: el botín/banco/enlaces no acreditan la reserva.
        if ammo and item.subclassID == ammo.subclass and item.bag and item.bag >= 0 and item.bag <= 4
            and item.slot and not item.equippedAmmo and type(ctx.level) == 'number' then
            local current, alternative, reserve = false, false, 0
            for _, stock in ipairs(ctx.bagStock or {}) do
                local other = ns.Data.ammo[stock.id]
                if other and other.subclass == ammo.subclass and stock.usable == true and other.reqLevel <= ctx.level then
                    if stock.bag == item.bag and stock.slot == item.slot and stock.id == id then
                        current = true
                    else
                        reserve = reserve + 1
                        if other.dps > ammo.dps and other.ilvl >= ammo.ilvl + 10 then alternative = true end
                    end
                end
            end
            if current and reserve >= 1 and alternative then
                result.mark = 'coin'; reasons[#reasons + 1] = { kind = 'ammo_outgrown' }
                return result
            end
        end
    end
    -- Conocida pero sin permiso de moneda: conserva la marca habitual de receta.
    if knownRecipe then
        return result
    end
    if effect == 'yes' and not isGear and item.classID ~= 9 and item.classID ~= ITEM_CLASS_QUEST and not classCannotUse(item, ctx) then
        reasons[#reasons + 1] = { kind = 'useful' }
        return result
    end

    -- 4. Monedita: cada regla suma su motivo; basta una. Un nil de isQuestDone nunca la da.
    if item.quality == 0 then
        reasons[#reasons + 1] = { kind = 'gray' }
    end
    if unknownEffect then
        -- nada: las monedas de mision quedan bloqueadas mientras no se sepa el efecto
    elseif starterQuest and questDone(ctx, starterQuest) then
        reasons[#reasons + 1] = { kind = 'quest_done', questID = starterQuest }
    elseif #questUses > 0 or item.classID == ITEM_CLASS_QUEST then
        -- Item de mision (objetivo, fuente o clase Mision) que ninguna mision del diario pide.
        reasons[#reasons + 1] = { kind = 'quest_not_active' }
    end
    -- Equipo que tu clase nunca puede usar: moneda SOLO si este ejemplar esta ligado (confirmado por
    -- la bolsa: item.isBound == true). Sin ligar (se puede subastar o pasar) o sin saberlo (botin,
    -- enlaces): sin moneda; motivo neutro 'class_cannot_use_tradeable' para el tooltip.
    local tradeable
    if classCannotUse(item, ctx) then
        local reason = { kind = 'class_cannot_use', classID = item.classID, subclassID = item.subclassID, subclassName = item.subclassName }
        if item.isBound == true then
            -- Ligado: moneda sólo con el estado del efecto conocido.
            if not unknownEffect then reasons[#reasons + 1] = reason end
        else
            reason.kind = 'class_cannot_use_tradeable'
            tradeable = reason
        end
    end
    -- Diario con misiones sin leer (encabezado plegado en combate, sin API): el item podria ser
    -- un objetivo de mision, asi que no se da NINGUNA moneda (salvo override_sell, ya resuelto arriba).
    -- Lo mismo si el diario no supo decir si una mision que usa el item esta tomada.
    if #reasons > 0 and (ctx.questLogIncomplete or logUnknown) then
        result.reasons = { { kind = 'quest_log_incomplete' } }
        reasons = result.reasons
    elseif #reasons > 0 and not unknownEffect then
        result.mark = 'coin'
    end
    if tradeable then reasons[#reasons + 1] = tradeable end
    return result
end

local armorSlots = {
    INVTYPE_HEAD = 1, INVTYPE_SHOULDER = 3, INVTYPE_CHEST = 5, INVTYPE_ROBE = 5,
    INVTYPE_WAIST = 6, INVTYPE_LEGS = 7, INVTYPE_FEET = 8, INVTYPE_WRIST = 9, INVTYPE_HAND = 10,
    ['1'] = 1, ['3'] = 3, ['5'] = 5, ['20'] = 5, ['6'] = 6, ['7'] = 7, ['8'] = 8, ['9'] = 9, ['10'] = 10,
}

local function armorBelowReason(item, ctx)
    if (ctx.rules and ctx.rules.armorBelow == false) or item.isSetPiece
        or item.classID ~= ITEM_CLASS_ARMOR
        or type(item.subclassID) ~= 'number' or item.subclassID < 1 or item.subclassID > 3
        or type(item.quality) ~= 'number' or item.quality <= 0 or item.quality > 2
        or (item.quality == 2 and ctx.professions and ctx.professions[333]) then return nil end
    local slot = item.equipLoc and armorSlots[item.equipLoc]
    local equipped = slot and type(ctx.equippedArmor) == 'table' and ctx.equippedArmor[slot]
    if type(equipped) ~= 'number' or equipped < 1 or equipped > 4 or equipped <= item.subclassID then return nil end
    return { kind = 'armor_below_equipped', subclassID = item.subclassID, equipped = equipped }
end

-- Evidencia informativa: no toca el item, el contexto ni el veredicto. Se ejecuta después
-- de decidir, incluso si una protección hizo retornar antes de las reglas inferiores.
local function collectEvidence(item, ctx, result)
    local other, seen = {}, {}
    for _, reason in ipairs(result.reasons) do seen[reason.kind] = true end
    local function add(reason)
        if seen[reason.kind] and reason.professions then
            local covered = {}
            for _, existing in ipairs(result.reasons) do
                if existing.kind == reason.kind then
                    for _, line in ipairs(existing.professions or {}) do covered[line] = true end
                end
            end
            local remaining = {}
            for _, line in ipairs(reason.professions) do if not covered[line] then remaining[#remaining + 1] = line end end
            if #remaining == 0 then return end
            reason.professions = remaining
        elseif seen[reason.kind] then return end
        other[#other + 1] = reason; seen[reason.kind] = true
    end
    if classCannotUse(item, ctx) then
        add({ kind = item.isBound == true and 'class_cannot_use' or 'class_cannot_use_tradeable',
            classID = item.classID, subclassID = item.subclassID, subclassName = item.subclassName })
    end
    local uses = type(ctx.questieUses) == 'function' and ctx.questieUses(item.id) or nil
    local questItem, active, unknown = item.classID == ITEM_CLASS_QUEST, false, ctx.questLogIncomplete
    for _, use in ipairs(uses or {}) do
        if not use.starter then
            questItem = true
            local answer = inLog(ctx, use.questID)
            if answer == true then active = true elseif answer == nil then unknown = true end
        end
    end
    active = active or (ctx.questItemsInLog and ctx.questItemsInLog[item.id])
    if questItem and not active and not unknown then add({ kind = 'quest_not_active' }) end
    if item.quality == 0 then add({ kind = 'gray' }) end
    for _, entry in ipairs({ { 'reagents', 'profession' }, { 'tools', 'profession_tool' } }) do
        local lines = ns.Data[entry[1]] and ns.Data[entry[1]][item.id]
        if not lines and entry[1] == 'tools' and item.classID == 2 and item.subclassID == 20 then lines = { 356 } end
        local others = {}
        for _, line in ipairs(lines or {}) do
            if not (ctx.professions and ctx.professions[line]) then others[#others + 1] = line end
        end
        if #others > 0 then add({ kind = entry[2], professions = others, other = true }) end
    end
    local gear = ctx.class and ns.ClassGear[ctx.class]
    local kind = item.classID == 4 and 'armor' or item.classID == 2 and 'weapon' or nil
    if item.quality ~= 0 and gear and kind and gear[kind][item.subclassID] == true
        and type(item.reqLevel) == 'number' and type(ctx.level) == 'number' and item.reqLevel > ctx.level then
        add({ kind = 'future_level', level = item.reqLevel })
    end
    local effect = item.effect
    if effect ~= 'yes' and effect ~= 'no' and effect ~= 'unknown' then effect = item.hasUseOrEquipSpell and 'yes' or 'no' end
    -- En equipo, «Equipar:» son estadísticas: no se muestra como motivo secundario.
    if effect == 'yes' and not seen.useful and item.classID ~= ITEM_CLASS_WEAPON and item.classID ~= ITEM_CLASS_ARMOR then add({ kind = 'effect' }) end
    if not item.isSetPiece and type(item.quality) == 'number' and item.quality > 0 and item.quality <= 2
        and not (item.quality == 2 and ctx.professions and ctx.professions[333])
        and (item.classID == ITEM_CLASS_WEAPON or item.classID == ITEM_CLASS_ARMOR)
        and type(item.reqLevel) == 'number' and item.reqLevel > 0
        and type(ctx.level) == 'number' and item.reqLevel + 10 <= ctx.level then
        add({ kind = 'gear_outgrown', level = item.reqLevel })
    end
    local below = armorBelowReason(item, ctx)
    if below then add(below) end
    return other
end

-- Conjuntos guardados por el jugador, distintos de los sets de objetos (isSetPiece).
local function inEquipmentSet(id)
    local modern = type(C_EquipmentSet) == 'table' and C_EquipmentSet or nil
    local idsAPI = modern and modern.GetItemIDs or GetEquipmentSetItemIDs
    if type(idsAPI) ~= 'function' then return false end
    local success, sets = pcall(function()
        if modern and type(modern.GetEquipmentSetIDs) == 'function' then
            return modern.GetEquipmentSetIDs()
        end
        if type(GetNumEquipmentSets) ~= 'function' or type(GetEquipmentSetInfo) ~= 'function' then return {} end
        local names = {}
        for index = 1, GetNumEquipmentSets() do
            names[#names + 1] = GetEquipmentSetInfo(index)
        end
        return names
    end)
    if not success or type(sets) ~= 'table' then return true end
    for _, set in pairs(sets) do
        local good, items = pcall(idsAPI, set)
        if not good or type(items) ~= 'table' then return true end
        for _, itemID in pairs(items) do if itemID == id then return true end end
    end
    return false
end

local excludedGearSlots = {
    INVTYPE_TRINKET = true, INVTYPE_TABARD = true, INVTYPE_BODY = true, INVTYPE_BAG = true,
    INVTYPE_NON_EQUIP = true, INVTYPE_NON_EQUIP_IGNORE = true,
    [''] = true, ['0'] = true, ['4'] = true, ['12'] = true, ['18'] = true, ['19'] = true,
}

-- Sin GearQuest: no puntuado. Con GearQuest en simulación o con error: se trata como puntuado (no se vende).
-- GearQuest Forever se publica como _G.GearQuest (GearQuestForever/Core.lua:11); GQ es su local.
-- Se acepta GQ también por compatibilidad con versiones o pruebas que lo exponían así.
-- Pawn (PawnGetItemData + PawnIsItemAnUpgrade, Pawn.lua:1370 y 3633). Devuelve:
--   nil = Pawn no está o no tiene escalas aplicables; false = no es mejora;
--   'pending' = Pawn no tiene los datos aún;
--   tabla = mejora ({ scale, percent } o { best = true } si ya es tu mejor o segundo mejor).
-- Ranuras del jugador por equipLoc (las mismas que compara Pawn, Pawn.lua:107-160).
local GEAR_SLOTS = {
    INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 }, INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 }, INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 }, INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16, 17 }, INVTYPE_2HWEAPON = { 16, 17 }, INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_WEAPONOFFHAND = { 17 }, INVTYPE_SHIELD = { 17 }, INVTYPE_HOLDABLE = { 17 },
    INVTYPE_RANGED = { 18 }, INVTYPE_RANGEDRIGHT = { 18 }, INVTYPE_THROWN = { 18 }, INVTYPE_RELIC = { 18 },
}
ns.GearSlots = GEAR_SLOTS

local function foldLabel(label)
    local accents = { ['Á'] = 'á', ['É'] = 'é', ['Í'] = 'í', ['Ó'] = 'ó', ['Ú'] = 'ú', ['Ü'] = 'ü', ['Ñ'] = 'ñ' }
    return (label:gsub('[\194-\244][\128-\191]+', accents)):lower()
end
ns.FoldSpecLabel = foldLabel

-- Comparte el mismo filtro con los vetos y el diagnóstico.
-- true si la escala de Pawn `name` es de la rama activa (ctx.specIndex) de tu clase: Pawn guarda
-- ClassID y SpecID en cada escala (PawnCommon.Scales) y en Forever SpecID es el orden de la rama de
-- talentos (paladin: 1 Sagrado, 2 Proteccion, 3 Reprension; KnuUI/PawnSpec.lua, probado en el juego).
local function specIDMatches(name, ctx)
    if not ctx.specIndex or type(name) ~= 'string' then return false end
    local common = rawget(_G, 'PawnCommon')
    local scale = type(common) == 'table' and type(common.Scales) == 'table' and common.Scales[name]
    if type(scale) ~= 'table' or scale.SpecID == nil then return false end
    local classID = type(UnitClass) == 'function' and select(3, UnitClass('player')) or nil
    return scale.SpecID == ctx.specIndex and (classID == nil or scale.ClassID == nil or scale.ClassID == classID)
end

function ns.PawnScales(ctx)
    local getter = rawget(_G, 'PawnGetAllScalesEx')
    local ok, scales
    if type(getter) == 'function' then ok, scales = pcall(getter) end
    local visible, matches, count, offspec = {}, {}, 0, {}
    for _, scale in pairs(ok and type(scales) == 'table' and scales or {}) do
        if type(scale) == 'table' and scale.IsVisible then
            local label = scale.LocalizedName or scale.Name
            local main = not (ctx.specLabel or ctx.specIndex) or specIDMatches(scale.Name, ctx)
                or (ctx.specLabel and type(label) == 'string'
                and foldLabel(label):find(foldLabel(ctx.specLabel), 1, true) ~= nil) or false
            local other = ctx.offSpecLabel and type(scale.LocalizedName) == 'string'
                and foldLabel(scale.LocalizedName):find(foldLabel(ctx.offSpecLabel), 1, true) ~= nil
            local match = main or other or false
            local isOffSpec = other and (not (ctx.specLabel or ctx.specIndex) or not main) or nil
            visible[#visible + 1] = { name = scale.Name, label = label, matches = match, offspec = isOffSpec }
            if match then
                count = count + 1
                if scale.Name then matches[scale.Name] = true end
                if label then matches[label] = true end
                if isOffSpec then
                    if scale.Name then offspec[scale.Name] = true end
                    if label then offspec[label] = true end
                end
            end
        end
    end
    return visible, matches, count, offspec
end

local function pawnUpgrade(link, equipLoc, ctx, offOnly)
    local getData, isUpgrade = rawget(_G, 'PawnGetItemData'), rawget(_G, 'PawnIsItemAnUpgrade')
    if type(getData) ~= 'function' or type(isUpgrade) ~= 'function' then return nil end
    local _, matches, count, offspec = ns.PawnScales(ctx)
    if count == 0 and (ctx.specLabel or ctx.specIndex or type(rawget(_G, 'PawnGetAllScalesEx')) == 'function') then return nil end
    local function accepts(raw, localized)
        if offOnly then return offspec[raw] or offspec[localized] end
        return matches[raw] or matches[localized] or (not (ctx.specLabel or ctx.specIndex) and count == 0
            and type(rawget(_G, 'PawnGetAllScalesEx')) ~= 'function')
    end
    if type(link) ~= 'string' or link == '' then return 'pending' end
    -- Pawn devuelve nil también si no tiene los datos de lo que tenés puesto (Pawn.lua:3735/3740):
    -- sin esos datos un «no es mejora» no vale.
    local slotData = rawget(_G, 'PawnGetItemDataForInventorySlot')
    local slots = GEAR_SLOTS[equipLoc]
    if not slots then return 'pending' end
    if type(slotData) == 'function' then
        for _, slot in ipairs(slots) do
            local okSlot, equipped, had = pcall(slotData, slot, true)
            if not okSlot or (had and type(equipped) ~= 'table') then return 'pending' end
        end
    end
    local ok, data = pcall(getData, link)
    if not ok or type(data) ~= 'table' then return 'pending' end
    local good, info, _, best, second = pcall(isUpgrade, data)
    if not good then return 'pending' end
    for _, upgrade in ipairs(type(info) == 'table' and info or {}) do
        if type(upgrade) == 'table' and accepts(upgrade.ScaleName, upgrade.LocalizedScaleName) then
            return { scale = upgrade.LocalizedScaleName or upgrade.ScaleName, percent = upgrade.PercentUpgrade,
                offspec = offspec[upgrade.ScaleName] or offspec[upgrade.LocalizedScaleName] or nil }
        end
    end
    for _, items in ipairs({ type(best) == 'table' and best or {}, type(second) == 'table' and second or {} }) do
        for scale, value in pairs(items) do
            if value and accepts(scale) then
                return { best = true, scale = offspec[scale] and scale or nil, offspec = offspec[scale] or nil }
            end
        end
    end
    return false
end

local function gearQuestRoot()
    local root = rawget(_G, 'GearQuest')
    if type(root) ~= 'table' then root = rawget(_G, 'GQ') end
    return root
end
ns.GearQuestRoot = gearQuestRoot

-- nil = no se pudo consultar; false = consulta completa sin puesto.
function ns.GearQuestOffSpecRanked(item, ctx)
    local root = gearQuestRoot()
    if not ctx.offSpecLabel or not ctx.offSpecId or type(item.link) ~= 'string'
        or type(root) ~= 'table' or type(root.Log) ~= 'table'
        or type(root.Log.WithSpecProbe) ~= 'function' or type(root.Data) ~= 'table'
        or type(root.Data.EntryForItemLink) ~= 'function'
        or type(root.Data.GearScoreTooltipLine) ~= 'function' then return nil end
    if ns.GearQuestSimulating() then return nil end
    local good, ranked = pcall(root.Log.WithSpecProbe, root.Log, ctx.offSpecId, function()
        local entry = root.Data:EntryForItemLink(item.link)
        local line = entry and root.Data:GearScoreTooltipLine(entry)
        return type(line) == 'string' and line ~= ''
    end)
    if good and type(ranked) == 'boolean' then return ranked end
    return nil
end

function ns.PawnOffSpecUpgrade(item, ctx)
    if not ctx.offSpecLabel then return nil end
    return pawnUpgrade(item.link, item.equipLoc, ctx, true)
end

local function gearQuestRanked(item, ctx)
    if type(item.link) ~= 'string' or item.link == '' then return false end
    local root = gearQuestRoot()
    if type(root) ~= 'table' or type(root.Data) ~= 'table'
        or type(root.Data.EntryForItemLink) ~= 'function' then return false end
    if type(root.IsPreviewEnabled) == 'function' then
        local ok, preview = pcall(root.IsPreviewEnabled, root)
        if not ok or preview ~= false then return true end
    end
    if type(root.GetEffectiveLevel) == 'function' then
        local ok, level = pcall(root.GetEffectiveLevel, root)
        if not ok or level ~= ctx.level then return true end
    end
    if type(root.GetEffectiveClass) == 'function' then
        local ok, class = pcall(root.GetEffectiveClass, root)
        if not ok or class ~= ctx.class then return true end
    end
    local ok, entry = pcall(root.Data.EntryForItemLink, root.Data, item.link)
    if not ok then return true end
    if entry == nil then return false end
    -- Puesto real sólo si GearQuest le da línea (Data.lua:7437-7459); ante error, se veta.
    if type(root.Data.GearScoreTooltipLine) ~= 'function' then return true end
    local okLine, line = pcall(root.Data.GearScoreTooltipLine, root.Data, entry)
    return not okLine or (type(line) == 'string' and line ~= '')
end

local function gearOutgrown(item, ctx, result)
    if result.mark ~= 'useful' or result.uncertain or ctx.questLogIncomplete or item.effect == 'unknown'
        or item.isSetPiece or type(item.quality) ~= 'number' or item.quality <= 0 or item.quality > 2
        or (item.quality == 2 and ctx.professions and ctx.professions[333])
        or (item.classID ~= ITEM_CLASS_WEAPON and item.classID ~= ITEM_CLASS_ARMOR)
        or type(item.reqLevel) ~= 'number' or item.reqLevel <= 0
        or type(ctx.level) ~= 'number' or item.reqLevel + 10 > ctx.level
        or (item.equipLoc ~= nil and excludedGearSlots[item.equipLoc]) then return false end
    for _, reason in ipairs(result.reasons) do
        if reason.kind ~= 'useful' and reason.kind ~= 'no_rule' and reason.kind ~= 'no_sell_price'
            and reason.kind ~= 'class_cannot_use_tradeable' then return false end
    end
    if inEquipmentSet(item.id) or gearQuestRanked(item, ctx) then return false end
    -- Pawn dice que es mejora (o todavía no sabe): no se vende por nivel bajo.
    local pawn = pawnUpgrade(item.link, item.equipLoc, ctx)
    if type(pawn) == 'table' or pawn == 'pending' then return false end
    return true
end

local function armorBelowEquipped(item, ctx, result)
    if result.mark ~= 'useful' or result.uncertain or ctx.questLogIncomplete or item.effect == 'unknown' then return nil end
    local reason = armorBelowReason(item, ctx)
    if not reason then return nil end
    for _, r in ipairs(result.reasons) do
        if r.kind ~= 'useful' and r.kind ~= 'no_rule' and r.kind ~= 'no_sell_price'
            and r.kind ~= 'class_cannot_use_tradeable' and r.kind ~= 'future_level' then return nil end
    end
    if inEquipmentSet(item.id) or gearQuestRanked(item, ctx) then return nil end
    local pawn = pawnUpgrade(item.link, item.equipLoc, ctx)
    if type(pawn) == 'table' or pawn == 'pending' then return nil end
    return reason
end

local function gearMissText(item, ctx, result)
    -- Se anota por qué no decide, para que el tooltip lo diga (sólo equipo).
    local function skip(state, extra)
        result.gearQuest = { state = state, gqLevel = extra and extra.gqLevel, gqClass = extra and extra.gqClass,
            delta = extra and extra.delta }
    end
    if item.classID ~= ITEM_CLASS_WEAPON and item.classID ~= ITEM_CLASS_ARMOR then return end
    if ctx.rules and ctx.rules.gearNotRanked == false then return skip('rule_off') end
    if result.mark ~= 'useful' then return end
    if result.uncertain then return skip('uncertain') end
    if ctx.questLogIncomplete then return skip('quest_log') end
    if item.isSetPiece then return skip('set_piece') end
    if type(item.link) ~= 'string' or item.link == '' then return skip('no_link') end
    if not item.equipLoc or item.equipLoc == '' or excludedGearSlots[item.equipLoc] then return skip('slot') end
    if type(item.reqLevel) == 'number' and type(ctx.level) == 'number' and item.reqLevel > ctx.level then return skip('future') end
    -- Las protecciones del núcleo conservan su precedencia aunque su marca sea Útil.
    for _, reason in ipairs(result.reasons) do
        if reason.kind ~= 'useful' and reason.kind ~= 'no_rule' and reason.kind ~= 'no_sell_price'
            and reason.kind ~= 'class_cannot_use_tradeable' then return end
    end
    local root = gearQuestRoot()
    if type(root) ~= 'table' then return skip('no_gearquest') end
    if type(root.Data) ~= 'table' or type(root.Data.GearScoreMissText) ~= 'function' then return skip('api') end
    if inEquipmentSet(item.id) then return skip('equipment_set') end
    -- GearScoreMissText también devuelve texto («not scoring this item», Data.lua:7370-7375) cuando
    -- el ítem no está en su base o la base no cargó: eso no prueba que no te sirva. Sólo cuenta si
    -- GearQuest tiene filas para el ítem.
    if type(root.Data.GetEntriesByItemId) ~= 'function' then return skip('api') end
    local okEntries, entries = pcall(root.Data.GetEntriesByItemId, root.Data, item.id)
    if not okEntries then return skip('error') end
    if type(entries) ~= 'table' or next(entries) == nil then return skip('unknown_item') end
    -- GearQuest puede simular otra clase, especialización o nivel (Preview.lua:929-979,
    -- Core.lua:621): con simulación activa o perfil distinto al personaje real, no se decide nada.
    local function gq(method)
        if type(root[method]) ~= 'function' then return nil, false end
        local ok, value = pcall(root[method], root)
        return value, ok
    end
    local preview, okPreview = gq('IsPreviewEnabled')
    if not okPreview then return skip('error') end
    if preview ~= false then return skip('simulating') end
    local level, okLevel = gq('GetEffectiveLevel')
    if not okLevel or type(ctx.level) ~= 'number' or level ~= ctx.level then
        return skip('level', { gqLevel = okLevel and level or nil })
    end
    local class, okClass = gq('GetEffectiveClass')
    if not okClass or type(ctx.class) ~= 'string' or class ~= ctx.class then
        return skip('class', { gqClass = okClass and class or nil })
    end
    -- Mismo criterio que el tooltip de GearQuest (Data.lua:7437-7459): hay puesto sólo si existe la
    -- fila del enlace (EntryForItemLink) Y GearScoreTooltipLine le da una línea. Una fila sin línea
    -- es «Sin puesto a tu nivel» (caso real: Fajín de avizor del oso 15528, nivel 28, franja 21-27).
    if type(root.Data.EntryForItemLink) ~= 'function' then return skip('api') end
    local okEntry, entry = pcall(root.Data.EntryForItemLink, root.Data, item.link)
    if not okEntry then return skip('error') end
    if entry ~= nil then
        if type(root.Data.GearScoreTooltipLine) ~= 'function' then return skip('ranked') end
        local okLine, line = pcall(root.Data.GearScoreTooltipLine, root.Data, entry)
        if not okLine then return skip('error') end
        if type(line) == 'string' and line ~= '' then
            -- Puesto, pero comparado con lo que tenés puesto (la flecha de GearQuest, Data.lua
            -- GearScoreTrail): peor o igual se vende, mejor se guarda. Sin comparación, se guarda.
            local delta
            if root.Log and type(root.Log.RankListContext) == 'function' and type(root.Data.GearScoreContext) == 'function'
                and type(root.Data.GearScoreArrowDelta) == 'function' then
                local okSlot, slotName, handKind = pcall(root.Log.RankListContext, root.Log, entry)
                local okCtx, scoreCtx = false, nil
                if okSlot then okCtx, scoreCtx = pcall(root.Data.GearScoreContext, root.Data, slotName, handKind) end
                if okCtx and scoreCtx then
                    local okArrow, arrow = pcall(root.Data.GearScoreArrowDelta, root.Data, entry, scoreCtx)
                    if okArrow and type(arrow) == 'number' then delta = arrow end
                end
            end
            if delta and delta <= 0 then return skip('ranked_worse', { delta = delta }) end
            return skip('ranked', { delta = delta })
        end
    end
    local success, text = pcall(root.Data.GearScoreMissText, root.Data, item.link)
    if success and type(text) == 'string' and text ~= '' then return text end
    return skip(success and 'no_text' or 'error')
end

-- La moneda automatica siempre acredita un precio de venta conocido y positivo.
-- Se conserva el veredicto de utilidad y sus motivos; la venta manual prevalece.
-- withEvidence=false permite contrastar exactamente el mismo decisor sin la segunda pasada.
function ns.Classify(item, ctx, withEvidence)
    local result = classify(item, ctx)
    if type(item) ~= 'table' or type(ctx) ~= 'table' or item.id == nil then return result end
    if item.pending == true or item.quality == nil then
        result.mark, result.pending = nil, true
        return result
    end
    if item.price == 0 then
        result.reasons[#result.reasons + 1] = { kind = 'no_sell_price' }
    end
    local manual = ctx.overrides and ctx.overrides[item.id] == 'sell'
    result.reasonMark = result.mark
    local protected = ctx.overrides and ctx.overrides[item.id] == 'keep'
    local active = result.quest == true or result.mark == 'quest'
    if protected then result.mark = 'protected'
    elseif active then result.mark = 'quest'
    elseif not manual and result.mark == 'coin' and not (type(item.price) == 'number' and item.price > 0) then
        result.mark = item.price == 0 and 'trash' or 'useful'
    end
    -- Regla del dueño: gris = basura, siempre, con el mismo criterio que Leatrix Plus (vende todo
    -- gris con precio: Leatrix_Plus.lua:7988 `Rarity == 0 and ItemPrice ~= 0`). Si KnuJunk dijera
    -- otra cosa de un gris, el ícono mentiría: otro addon lo vende igual. Sólo el candado lo salva
    -- (traba el ítem en el vendedor). Con precio: monedita; sin precio: tacho.
    local isGray = item.quality == 0 and result.mark ~= 'protected'
    if isGray then
        local hasGrayReason = false
        for _, reason in ipairs(result.reasons) do if reason.kind == 'gray' then hasGrayReason = true end end
        if not hasGrayReason then result.reasons[#result.reasons + 1] = { kind = 'gray' } end
        if type(item.price) == 'number' and item.price > 0 then result.mark = 'coin'
        elseif item.price == 0 then result.mark = 'trash' end
    end
    if not result.mark and (#result.reasons == 0
        or (#result.reasons == 1 and result.reasons[1].kind == 'no_sell_price')) then
        table.insert(result.reasons, 1, { kind = 'no_rule', exception = noRuleException(item) })
    end
    result.mark = result.mark or 'useful'
    -- Duda real: datos del juego que faltan. Es el único caso que muestra «?» (Marks.markOf).
    result.doubt = (result.uncertain or ctx.questLogIncomplete or item.effect == 'unknown') and true or nil
    -- La otra especialización sólo protege equipo común; conserva la precedencia del núcleo.
    if ctx.offSpecLabel and not isGray and not manual and not protected and result.mark == 'useful'
        and not result.doubt and (item.classID == ITEM_CLASS_ARMOR or item.classID == ITEM_CLASS_WEAPON)
        and not excludedGearSlots[item.equipLoc or ''] and not ns.GearQuestSimulating() then
        local eligible = true
        for _, reason in ipairs(result.reasons) do
            if reason.kind ~= 'no_rule' and reason.kind ~= 'useful' and reason.kind ~= 'no_sell_price'
                and reason.kind ~= 'class_cannot_use_tradeable' and reason.kind ~= 'future_level' then eligible = false end
        end
        if eligible and not gearQuestRanked(item, ctx) then
            local ranked = ns.GearQuestOffSpecRanked(item, ctx)
            local pawn = not ranked and ns.PawnOffSpecUpgrade(item, ctx)
            local reason
            if ranked then reason = { kind = 'offspec_ranked', spec = ctx.offSpecLabel }
            elseif type(pawn) == 'table' then
                reason = { kind = 'pawn_upgrade', scale = pawn.scale, percent = pawn.percent, best = pawn.best, offspec = true }
            end
            if reason then
                for i = #result.reasons, 1, -1 do
                    if result.reasons[i].kind == 'no_rule' then table.remove(result.reasons, i) end
                end
                table.insert(result.reasons, 1, reason)
            end
        end
    end
    local outgrown = not isGray and gearOutgrown(item, ctx, result)
    if outgrown then
        for i = #result.reasons, 1, -1 do
            local k = result.reasons[i].kind
            if k == 'no_rule' or k == 'useful' or k == 'class_cannot_use_tradeable' then
                table.remove(result.reasons, i)
            end
        end
        table.insert(result.reasons, 1, { kind = 'gear_outgrown', level = item.reqLevel })
        result.mark = type(item.price) == 'number' and item.price > 0 and 'coin'
            or (item.price == 0 and 'trash' or 'useful')
    end
    local armorBelow = not isGray and not outgrown and armorBelowEquipped(item, ctx, result)
    if armorBelow then
        for i = #result.reasons, 1, -1 do
            local k = result.reasons[i].kind
            if k == 'no_rule' or k == 'useful' or k == 'class_cannot_use_tradeable' or k == 'future_level' then
                table.remove(result.reasons, i)
            end
        end
        table.insert(result.reasons, 1, armorBelow)
        result.mark = type(item.price) == 'number' and item.price > 0 and 'coin'
            or (item.price == 0 and 'trash' or 'useful')
    end
    local gearMiss = not isGray and not outgrown and not armorBelow and gearMissText(item, ctx, result)
    if gearMiss then
        for i = #result.reasons, 1, -1 do
            if result.reasons[i].kind == 'no_rule' then table.remove(result.reasons, i) end
        end
        result.reasons[#result.reasons + 1] = { kind = 'gear_not_ranked', text = gearMiss }
        result.mark = type(item.price) == 'number' and item.price > 0 and 'coin'
            or (item.price == 0 and 'trash' or 'useful')
    elseif result.gearQuest and result.gearQuest.state == 'ranked' and result.mark == 'useful'
        and result.reasons[1] and result.reasons[1].kind == 'no_rule' then
        -- GearQuest la puntúa para vos: es una razón para guardarla (tilde verde), no «sin regla».
        result.reasons[1] = { kind = 'gear_ranked', delta = result.gearQuest.delta }
    elseif result.gearQuest and result.gearQuest.state == 'ranked_worse' and result.mark == 'useful'
        and result.reasons[1] and result.reasons[1].kind == 'no_rule' and not manual and not protected then
        -- Puesto en GearQuest pero peor o igual que lo que tenés puesto: se vende (blanco o verde).
        result.reasons[1] = { kind = 'gear_worse_than_equipped', delta = result.gearQuest.delta }
        if type(item.quality) == 'number' and item.quality >= 1 and item.quality <= 2
            and type(item.price) == 'number' and item.price > 0 and ctx.rules and ctx.rules.gearNotRanked ~= false then
            result.mark = 'coin'
        end
    elseif not isGray and not manual and not protected and not result.doubt and result.mark == 'useful'
        and result.reasons[1] and result.reasons[1].kind == 'no_rule' and result.reasons[1].exception == 'gear'
        and not ns.GearQuestSimulating() then
        local state = result.gearQuest and result.gearQuest.state
        if (state == 'no_gearquest' or state == 'unknown_item') and not inEquipmentSet(item.id) then
            local pawn = pawnUpgrade(item.link, item.equipLoc, ctx)
            local canSell = type(item.quality) == 'number' and item.quality >= 1 and item.quality <= 2
                and type(item.price) == 'number' and item.price > 0
                and ctx.rules and ctx.rules.gearNoRanking == true
            if type(pawn) == 'table' then
                result.reasons[1] = { kind = 'pawn_upgrade', scale = pawn.scale, percent = pawn.percent, best = pawn.best,
                    offspec = pawn.offspec }
            elseif pawn == 'pending' then
                result.doubt = true
            elseif pawn == false then
                result.reasons[1] = { kind = 'gear_no_ranking', pawn = true }
                if canSell then result.mark = 'coin' end
            else
                local slots = GEAR_SLOTS[item.equipLoc]
                -- Armas: la de dos manos sólo va en la derecha (la izquierda queda vacía a propósito), y
                -- la de una mano va a la izquierda sólo si la clase puede usar dos armas en Classic.
                if item.equipLoc == 'INVTYPE_2HWEAPON' then slots = { 16 }
                elseif item.equipLoc == 'INVTYPE_WEAPON' and ctx.class ~= 'WARRIOR' and ctx.class ~= 'ROGUE'
                    and ctx.class ~= 'HUNTER' then slots = { 16 } end
                local lowest, empty, unknown
                for _, slot in ipairs(slots or {}) do
                    local level = ctx.equippedLevel and ctx.equippedLevel[slot]
                    if level == false then empty = true
                    elseif type(level) ~= 'number' then unknown = true
                    elseif not lowest or level < lowest then lowest = level end
                end
                if empty then result.reasons[1] = { kind = 'gear_empty_slot' }
                elseif not slots or unknown or type(item.itemLevel) ~= 'number' or not lowest then
                    result.doubt = true
                else
                    local below = item.itemLevel <= lowest
                    result.reasons[1] = { kind = below and 'gear_below_equipped' or 'gear_maybe_upgrade',
                        level = item.itemLevel, equipped = lowest }
                    if below and canSell then result.mark = 'coin' end
                end
            end
        end
    end
    if not isGray and not manual and not protected and result.mark == 'useful'
        and result.reasons[1] and result.reasons[1].kind == 'no_rule'
        and ctx.rules and ctx.rules.sellUnruled == true
        and type(item.price) == 'number' and item.price > 0
        and type(item.quality) == 'number' and item.quality <= 2
        and type(item.classID) == 'number' and not result.reasons[1].exception
        and not result.uncertain and not ctx.questLogIncomplete and item.effect ~= 'unknown'
        and item.effect ~= 'yes' and not (ns.Data.food and ns.Data.food[item.id])
        and not inEquipmentSet(item.id) then
        result.reasons[1] = { kind = 'no_keep_reason' }
        result.mark = 'coin'
    end
    local price = (not isGray) and ns.AuctionPrice(item.id) or nil
    result.auctionPrice = price
    if not manual and not result.uncertain and not ctx.questLogIncomplete and item.effect ~= 'unknown'
        and (result.mark == 'coin' or result.mark == 'useful' or ((gearMiss or outgrown or armorBelow) and result.mark == 'trash'))
        and item.isBound ~= true and price then
        local settings = ns.DB and ns.DB.auction or {}
        if price >= math.max((type(item.price) == 'number' and item.price or 0) * (settings.factor or 2), settings.minCopper or 100) then
            result.mark = 'auction'
        end
    end
    if withEvidence ~= false then result.otherReasons = collectEvidence(item, ctx, result) end
    return result
end

-- true sólo si GearQuest dice que está simulando otro personaje (GQ:IsPreviewEnabled). En ese caso
-- KnuJunk no usa su ranking para vender equipo (gearMissText y gearQuestRanked lo vetan).
function ns.GearQuestSimulating()
    local root = gearQuestRoot()
    if type(root) ~= 'table' or type(root.IsPreviewEnabled) ~= 'function' then return false end
    local ok, value = pcall(root.IsPreviewEnabled, root)
    return ok and value == true
end

-- API opcional: ni la ausencia del addon ni una base sin inicializar cortan la clasificación.
function ns.AuctionPrice(id)
    local success, price = pcall(function()
        local root = rawget(_G, 'Auctionator')
        local api = root and root.API and root.API.v1
        if api and type(api.GetAuctionPriceByItemID) == 'function' then
            return api.GetAuctionPriceByItemID('KnuJunk', id)
        end
    end)
    if success and type(price) == 'number' and price == price and price >= 0 and price < math.huge then return price end
end
