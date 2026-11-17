local _, ns = ...

-- Clasificador de marcas: funcion pura. Regla de oro: ante cualquier duda, sin marca.
-- item = { id, quality, classID, subclassID, equipLoc, hasUseOrEquipSpell, isSetPiece, price }
-- ctx  = { class, professions = {[skillLineID]=true}, isQuestDone(questID)->true|false|nil,
--          questItemsInLog = {[itemID]=true}, questieUses(itemID)->{ {questID=, repeatable=} }|nil,
--          overrides = {[itemID]='keep'|'sell'}, questLogIncomplete = true|nil }
-- result = { mark = 'coin'|'hammer_mine'|'hammer_other'|'quest'|nil, reasons = { {kind=...} } }

local ITEM_CLASS_WEAPON, ITEM_CLASS_ARMOR = 2, 4

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

local function classCannotUse(item, ctx)
    local kind
    if item.classID == ITEM_CLASS_ARMOR then kind = 'armor'
    elseif item.classID == ITEM_CLASS_WEAPON then kind = 'weapon'
    else return false end
    if item.hasUseOrEquipSpell or item.isSetPiece then return false end
    local subclassID = item.subclassID
    if type(subclassID) ~= 'number' or not isKnownSubclass(kind, subclassID) then return false end
    local gear = ctx.class and ns.ClassGear[ctx.class]
    if not gear then return false end
    return gear[kind][subclassID] ~= true
end

function ns.Classify(item, ctx)
    local result = { mark = nil, reasons = {} }
    local reasons = result.reasons
    if type(item) ~= 'table' or type(ctx) ~= 'table' or item.id == nil then return result end
    local id = item.id

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

    -- Datos del item sin cargar: no se decide nada.
    if item.quality == nil then return result end

    -- 2. Util para una mision: sin monedita.
    if ctx.questItemsInLog and ctx.questItemsInLog[id] then
        result.mark = 'quest'
        reasons[#reasons + 1] = { kind = 'quest_active' }
        return result
    end
    local uses = type(ctx.questieUses) == 'function' and ctx.questieUses(id) or nil
    if uses then
        for _, use in ipairs(uses) do
            if not questDone(ctx, use.questID) then
                result.mark = 'quest'
                reasons[#reasons + 1] = { kind = 'quest_active', questID = use.questID }
                return result
            end
        end
    end

    -- 3. Reactivo de profesion.
    local lines = ns.Data.reagents and ns.Data.reagents[id]
    if lines then
        local mine = {}
        for _, line in ipairs(lines) do
            if ctx.professions and ctx.professions[line] then mine[#mine + 1] = line end
        end
        if #mine > 0 then
            result.mark = 'hammer_mine'
            reasons[#reasons + 1] = { kind = 'profession', professions = mine }
        else
            result.mark = 'hammer_other'
            local all = {}
            for i, line in ipairs(lines) do all[i] = line end
            reasons[#reasons + 1] = { kind = 'profession', professions = all }
        end
        return result
    end

    -- Iniciador de mision cuya mision no esta confirmada como hecha (false o nil): es util,
    -- sin marca y sin monedita aunque sea gris.
    local starterQuest = ns.Data.starters and ns.Data.starters[id]
    if starterQuest and not questDone(ctx, starterQuest) then
        reasons[#reasons + 1] = { kind = 'quest_starter', questID = starterQuest }
        return result
    end

    -- 4. Monedita: cada regla suma su motivo; basta una. Un nil de isQuestDone nunca la da.
    if item.quality == 0 and type(item.price) == 'number' and item.price > 0 then
        reasons[#reasons + 1] = { kind = 'gray' }
    end
    if starterQuest and questDone(ctx, starterQuest) then
        reasons[#reasons + 1] = { kind = 'quest_done', questID = starterQuest }
    end
    if uses and #uses > 0 then
        local allDone = true
        for _, use in ipairs(uses) do
            if use.repeatable or not questDone(ctx, use.questID) then allDone = false; break end
        end
        if allDone then reasons[#reasons + 1] = { kind = 'quest_done', questID = uses[1].questID } end
    end
    if classCannotUse(item, ctx) then
        reasons[#reasons + 1] = { kind = 'class_cannot_use', classID = item.classID, subclassID = item.subclassID }
    end
    -- Diario con misiones sin leer (encabezado plegado en combate, sin API): el item podria ser
    -- un objetivo de mision, asi que no se da NINGUNA moneda (salvo override_sell, ya resuelto arriba).
    if #reasons > 0 and ctx.questLogIncomplete then
        result.reasons = { { kind = 'quest_log_incomplete' } }
        return result
    end
    if #reasons > 0 then result.mark = 'coin' end
    return result
end
