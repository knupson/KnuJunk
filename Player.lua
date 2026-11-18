local _, ns = ...

-- Contexto del personaje para el clasificador y lectura de items de las bolsas.
-- Toda API del cliente se detecta antes de usarla: en Forever conviven nombres clasicos
-- y modernos (C_*) y no se asume ninguno.
local Player = {}
ns.Player = Player

local cache    -- contexto vigente (nil = sucio, se reconstruye en el proximo GetContext)
local previous -- ultimo contexto antes de ensuciarse: para avisar a OnChanged si cambio de contenido
local lastQuestNames -- {[nombre normalizado] = nombre} del ultimo escaneo COMPLETO del diario
local questMemo, skillMemo = {}, {} -- {fp=, data=}: resultado del ultimo escaneo con expansion
local scanning = false -- true mientras se expanden/pliegan encabezados: sus eventos sincronicos se ignoran
local pending = false -- hay una reconstruccion diferida programada
local changedCallbacks = {}
local signatures = setmetatable({}, { __mode = 'k' }) -- [ctx] = firma de contenido
-- Sube con cada alta, baja o entrega de mision: isQuestDone puede responder distinto aunque
-- el resto del contexto sea igual, y eso tiene que avisar por OnChanged. Los ecos de expandir
-- el diario (QUEST_LOG_UPDATE) no la tocan, asi que no reabren aquel bucle.
local questRevision = 0

local function markDirty()
    if cache then previous = cache end
    cache = nil
end

function Player.Invalidate() markDirty() end

-- fn(ctx) se llama tras una reconstruccion SOLO si el contenido del contexto cambio
-- (clase, profesiones, items de misiones, questLogIncomplete, revision de misiones).
function Player.OnChanged(fn) changedCallbacks[#changedCallbacks + 1] = fn end

-- Solo para pruebas: deja el modulo como recien cargado.
function Player.ResetState()
    cache, previous, lastQuestNames, scanning, pending = nil, nil, nil, false, false
    questMemo, skillMemo, changedCallbacks = {}, {}, {}
end

local MIN_EXPAND_INTERVAL = 1 -- sin huella, no se expande mas de una vez por segundo
local function now() return GetTime and GetTime() or 0 end
local function inCombat() return InCombatLockdown ~= nil and InCombatLockdown() == true end

-- Lee una lista con encabezados plegables (diario de misiones, habilidades). Si hay
-- encabezados plegados los expande (fuera de combate), llama scan() y los vuelve a plegar
-- exactamente igual.
--   count() -> n ; entry(i) -> title, isHeader, isCollapsed ; expand(i), collapse(i) pueden ser nil.
--   fingerprint() -> string|nil describe lo visible; si coincide con la de la ultima expansion
--   (memo.fp) no se expande de nuevo: es lo que corta el bucle expandir -> evento -> reconstruir.
-- Devuelve complete, how: how = 'expanded' (scan() corrio con todo expandido), 'cached'
-- (memo.fp coincide: scan() NO corrio) o nil.
local function scanExpanded(count, entry, expand, collapse, scan, saveState, restoreState, fingerprint, memo)
    local collapsedTitles, any = {}, false
    for index = 1, count() do
        local title, isHeader, isCollapsed = entry(index)
        if isHeader and isCollapsed then
            any = true
            if title then collapsedTitles[title] = true end
        end
    end
    if not any then scan(); return true end
    -- La huella de la ultima expansion completa certifica lo escaneado aunque ahora no se
    -- pueda expandir (combate): mismo diario visible y mismo total. Aceptar, abandonar o
    -- entregar una mision borra memo.fp, asi que despues de esos eventos no certifica.
    local before = fingerprint and fingerprint()
    if before and memo and memo.fp == before then return true, 'cached' end
    if inCombat() or not expand or not collapse then scan(); return false end
    if not before and memo and memo.at and now() < memo.at + MIN_EXPAND_INTERVAL then
        -- Sin huella no se puede saber si algo cambio: se limita el ritmo de expansiones
        -- (acota el bucle expandir -> evento -> reconstruir) y mientras tanto se reusa lo ultimo.
        if memo.data then return true, 'cached' end
        return false
    end
    if memo then memo.at = now() end
    local complete, state = false, nil
    scanning = true
    pcall(function()
        state = saveState and saveState()
        -- De abajo hacia arriba: expandir un encabezado no mueve los indices de los de arriba.
        for index = count(), 1, -1 do
            local _, isHeader, isCollapsed = entry(index)
            if isHeader and isCollapsed then expand(index) end
        end
        local stillCollapsed = false
        for index = 1, count() do
            local _, isHeader, isCollapsed = entry(index)
            if isHeader and isCollapsed then stillCollapsed = true; break end
        end
        scan()
        complete = not stillCollapsed
    end)
    pcall(function()
        for index = count(), 1, -1 do
            local title, isHeader, isCollapsed = entry(index)
            if isHeader and not isCollapsed and title and collapsedTitles[title] then collapse(index) end
        end
    end)
    if restoreState then pcall(restoreState, state) end
    scanning = false
    if complete and memo and before then memo.fp = fingerprint() end
    return complete, complete and 'expanded' or nil
end

-- ---------------------------------------------------------------------------
-- Profesiones
-- ---------------------------------------------------------------------------

local function readProfessions()
    local professions = {}
    local viaModern = false
    if type(GetProfessions) == 'function' and type(GetProfessionInfo) == 'function' then
        local indexes = { GetProfessions() }
        -- GetProfessions devuelve hasta 6 posiciones; las vacias vienen en nil.
        for position = 1, 6 do
            local index = indexes[position]
            if index then
                viaModern = true
                local name, _, _, _, _, _, skillLine = GetProfessionInfo(index)
                local id = type(skillLine) == 'number' and ns.PROFESSIONS[skillLine] and skillLine
                    or ns.ProfessionByName(name)
                if id and ns.PROFESSIONS[id] then professions[id] = true end
            end
        end
    end
    if not viaModern and type(GetNumSkillLines) == 'function' and type(GetSkillLineInfo) == 'function' then
        local function entry(index)
            local name, isHeader, isExpanded = GetSkillLineInfo(index)
            -- Plegado solo si el cliente lo dice con false/0: ante un nil no se toca nada.
            return name, isHeader, isHeader and (isExpanded == false or isExpanded == 0)
        end
        local function fingerprint()
            local parts = { GetNumSkillLines() or 0 }
            for index = 1, parts[1] do
                local name, isHeader, isExpanded = GetSkillLineInfo(index)
                parts[#parts + 1] = tostring(name) .. ':' .. tostring(isHeader) .. ':' .. tostring(isExpanded)
            end
            return table.concat(parts, '|')
        end
        -- Si no se puede expandir (combate o sin API) quedan las visibles: peor caso hammer_other.
        local _, how = scanExpanded(function() return GetNumSkillLines() or 0 end, entry,
            type(ExpandSkillHeader) == 'function' and ExpandSkillHeader or nil,
            type(CollapseSkillHeader) == 'function' and CollapseSkillHeader or nil,
            function()
                for index = 1, GetNumSkillLines() or 0 do
                    local name, isHeader = GetSkillLineInfo(index)
                    if not isHeader then
                        local id = ns.ProfessionByName(name)
                        if id and ns.PROFESSIONS[id] then professions[id] = true end
                    end
                end
            end, nil, nil, fingerprint, skillMemo)
        if how == 'cached' then
            for id in pairs(skillMemo.data or {}) do professions[id] = true end
        elseif how == 'expanded' then
            skillMemo.data = {}
            for id in pairs(professions) do skillMemo.data[id] = true end
        end
    end
    return professions
end

-- ---------------------------------------------------------------------------
-- Misiones
-- ---------------------------------------------------------------------------

-- true/false segun el cliente; nil si no hay ninguna API de misiones completadas.
local function isQuestDone(questID)
    if questID == nil then return nil end
    if C_QuestLog and type(C_QuestLog.IsQuestFlaggedCompleted) == 'function' then
        return C_QuestLog.IsQuestFlaggedCompleted(questID) == true
    elseif type(IsQuestFlaggedCompleted) == 'function' then
        return IsQuestFlaggedCompleted(questID) == true
    end
    return nil
end

-- "Nombre del item: 3/5" -> "Nombre del item". Otros objetivos (muertes, etc.) no cuentan.
local function objectiveItemName(text, kind)
    if kind ~= nil and kind ~= 'item' then return nil end
    if type(text) ~= 'string' then return nil end
    return text:match('^(.-):%s*%d+%s*/%s*%d+%s*$')
end

-- Lee el diario completo. Devuelve names ({[normalizado]=nombre} de items pedidos) y complete.
-- complete=false si quedaron misiones sin leer (encabezado plegado en combate, sin API para
-- expandir, o sin API de diario).
local function scanQuestLog()
    local names = {}
    local function add(text, kind)
        local name = objectiveItemName(text, kind)
        if name and name ~= '' then names[ns.NormalizeName(name)] = name end
    end
    if C_QuestLog and type(C_QuestLog.GetNumQuestLogEntries) == 'function'
        and type(C_QuestLog.GetInfo) == 'function' and type(C_QuestLog.GetQuestObjectives) == 'function' then
        local expand = type(C_QuestLog.ExpandQuestHeader) == 'function' and C_QuestLog.ExpandQuestHeader
            or (type(ExpandQuestHeader) == 'function' and ExpandQuestHeader or nil)
        local collapse = type(C_QuestLog.CollapseQuestHeader) == 'function' and C_QuestLog.CollapseQuestHeader
            or (type(CollapseQuestHeader) == 'function' and CollapseQuestHeader or nil)
        local function count() return C_QuestLog.GetNumQuestLogEntries() or 0 end
        local function entry(index)
            local info = C_QuestLog.GetInfo(index)
            if not info then return nil end
            return info.title, info.isHeader, info.isCollapsed and info.isCollapsed ~= 0
        end
        local function fingerprint()
            local shown, total = C_QuestLog.GetNumQuestLogEntries()
            if total == nil then return nil end -- sin total no se detectan cambios ocultos
            local parts = { tostring(shown), tostring(total) }
            for index = 1, shown or 0 do
                local title, isHeader, isCollapsed = entry(index)
                parts[#parts + 1] = tostring(title) .. ':' .. tostring(isHeader) .. ':' .. tostring(isCollapsed)
            end
            return table.concat(parts, '|')
        end
        local save, restore
        if type(C_QuestLog.GetSelectedQuest) == 'function' and type(C_QuestLog.SetSelectedQuest) == 'function' then
            save = C_QuestLog.GetSelectedQuest
            restore = function(questID) if questID and questID ~= 0 then C_QuestLog.SetSelectedQuest(questID) end end
        end
        local complete, how = scanExpanded(count, entry, expand, collapse, function()
            for index = 1, count() do
                local info = C_QuestLog.GetInfo(index)
                if info and not info.isHeader and info.questID then
                    for _, objective in ipairs(C_QuestLog.GetQuestObjectives(info.questID) or {}) do
                        add(objective.text, objective.type)
                    end
                end
            end
        end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = names end
        return names, complete
    elseif type(GetNumQuestLogEntries) == 'function' and type(GetQuestLogTitle) == 'function'
        and type(GetNumQuestLeaderBoards) == 'function' and type(GetQuestLogLeaderBoard) == 'function' then
        local function count() return (GetNumQuestLogEntries()) or 0 end
        local function entry(index)
            local title, _, _, isHeader, isCollapsed = GetQuestLogTitle(index)
            return title, isHeader, isCollapsed and isCollapsed ~= 0
        end
        local function fingerprint()
            local shown, total = GetNumQuestLogEntries()
            if total == nil then return nil end
            local parts = { tostring(shown), tostring(total) }
            for index = 1, shown or 0 do
                local title, isHeader, isCollapsed = entry(index)
                parts[#parts + 1] = tostring(title) .. ':' .. tostring(isHeader) .. ':' .. tostring(isCollapsed)
            end
            return table.concat(parts, '|')
        end
        local save, restore
        if type(GetQuestLogSelection) == 'function' and type(SelectQuestLogEntry) == 'function' then
            save = GetQuestLogSelection
            restore = function(selected) if selected and selected > 0 then SelectQuestLogEntry(selected) end end
        end
        local complete, how = scanExpanded(count, entry,
            type(ExpandQuestHeader) == 'function' and ExpandQuestHeader or nil,
            type(CollapseQuestHeader) == 'function' and CollapseQuestHeader or nil,
            function()
                for index = 1, count() do
                    local _, _, _, isHeader = GetQuestLogTitle(index)
                    if not isHeader then
                        for objective = 1, GetNumQuestLeaderBoards(index) or 0 do
                            local text, kind = GetQuestLogLeaderBoard(objective, index)
                            add(text, kind)
                        end
                    end
                end
            end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = names end
        return names, complete
    end
    return names, false
end

-- Devuelve questItemsInLog = {[itemID]=true} y si el diario quedo incompleto. Un escaneo
-- incompleto no reemplaza al ultimo completo: se unen (lo ya visto sigue protegiendo), pero
-- el contexto queda questLogIncomplete igual: el escaneo anterior no certifica misiones
-- nuevas que no se pudieron leer. Se certifica de nuevo solo con un escaneo completo.
-- Los objetivos traen el nombre, no el id: se resuelve con GetItemInfo(nombre) y, para lo
-- que no se pudo resolver, __index compara por el nombre del item consultado (un item de
-- mision gris no debe quedar con monedita por no haberse resuelto a tiempo).
local function buildQuestItems()
    local names, complete = scanQuestLog()
    local incomplete = not complete
    if complete then
        lastQuestNames = names
    elseif lastQuestNames then
        for key, name in pairs(lastQuestNames) do names[key] = names[key] or name end
    end
    local ids = {}
    for _, name in pairs(names) do
        if type(GetItemInfo) == 'function' then
            local _, link = GetItemInfo(name)
            local id = type(link) == 'string' and tonumber(link:match('item:(%d+)'))
            if id then ids[id] = true end
        end
    end
    return setmetatable(ids, { __index = function(_, id)
        if next(names) == nil or type(GetItemInfo) ~= 'function' then return nil end
        local name = GetItemInfo(id)
        if type(name) == 'string' and names[ns.NormalizeName(name)] then return true end
        return nil
    end }), incomplete, names
end

-- ---------------------------------------------------------------------------
-- Contexto
-- ---------------------------------------------------------------------------

local function sortedKeys(set)
    local list = {}
    for key in pairs(set) do list[#list + 1] = key end
    table.sort(list, function(x, y) return tostring(x) < tostring(y) end)
    return table.concat(list, ',')
end

local function buildContext()
    local class
    if type(UnitClass) == 'function' then class = select(2, UnitClass('player')) end
    local professions = readProfessions()
    local questItems, incomplete, names = buildQuestItems()
    -- QuestieDB disponible pero con el indice aun sin terminar: Uses da nil y no se sabe si el
    -- item es de una mision. Mismo trato que un diario sin leer: ninguna moneda.
    if ns.Questie and type(ns.Questie.Pending) == 'function' and ns.Questie.Pending() then incomplete = true end
    local ctx = {
        class = class,
        professions = professions,
        isQuestDone = isQuestDone,
        questItemsInLog = questItems,
        questLogIncomplete = incomplete or nil,
        questieUses = ns.Questie and ns.Questie.Uses or nil,
        overrides = ns.DB and ns.DB.overrides or {},
    }
    -- pairs ignora el __index de questItemsInLog: solo los ids ya resueltos.
    signatures[ctx] = table.concat({ tostring(class), tostring(incomplete), tostring(questRevision), sortedKeys(professions),
        sortedKeys(questItems), sortedKeys(names) }, '|')
    return ctx
end

function Player.GetContext()
    -- ns.DB puede reemplazarse (primer login, pruebas): si cambio el origen, se reconstruye.
    local overrides = ns.DB and ns.DB.overrides
    if cache and overrides and cache.overrides ~= overrides then markDirty() end
    if not cache then
        local old = previous
        previous = nil
        cache = buildContext()
        if old and signatures[old] ~= signatures[cache] then
            local fresh = cache
            for _, fn in ipairs(changedCallbacks) do pcall(fn, fresh) end
        end
    end
    return cache
end

-- ---------------------------------------------------------------------------
-- Items
-- ---------------------------------------------------------------------------

-- true si el item tiene (o puede tener) hechizo de uso/equipar; false solo si la API
-- respondio sin nombre NI id. Se conservan los dos retornos: el nombre puede llegar tarde y el
-- id solo ya es evidencia. Sin API, o si la API falla, no se sabe: true (conservador, ninguna
-- moneda automatica). Que GetItemSpell informe efectos SOLO de equipar en Forever no esta
-- verificado en el juego.
local function hasItemSpell(id)
    local api
    if C_Item and type(C_Item.GetItemSpell) == 'function' then api = C_Item.GetItemSpell
    elseif type(GetItemSpell) == 'function' then api = GetItemSpell end
    if not api then return true end
    local success, name, spellID = pcall(api, id)
    if not success then return true end
    return name ~= nil or spellID ~= nil
end

-- item = { id, quality, price, classID, subclassID, subclassName, equipLoc, hasUseOrEquipSpell, isSetPiece };
-- nil si GetItemInfo aun no tiene los datos (reintentar con GET_ITEM_INFO_RECEIVED).
function Player.ReadLink(link)
    if link == nil or type(GetItemInfo) ~= 'function' then return nil end
    local id
    if type(link) == 'number' then id = link
    elseif type(link) == 'string' then id = tonumber(link:match('item:(%d+)')) end
    if not id then return nil end
    local _, _, quality, _, _, _, subclassName, _, equipLoc, _, price, classID, subclassID, _, _, setID = GetItemInfo(link)
    if quality == nil then return nil end
    local hasSpell = hasItemSpell(id)
    return {
        id = id,
        quality = quality,
        price = price or 0,
        classID = classID,
        subclassID = subclassID,
        subclassName = subclassName,
        equipLoc = equipLoc,
        hasUseOrEquipSpell = hasSpell,
        isSetPiece = setID ~= nil and setID ~= 0,
    }
end

function Player.ReadItem(bag, slot)
    local link, itemID
    if C_Container and type(C_Container.GetContainerItemInfo) == 'function' then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then link, itemID = info.hyperlink, info.itemID end
    elseif type(GetContainerItemLink) == 'function' then
        link = GetContainerItemLink(bag, slot)
    end
    local target = link or itemID
    if not target then return nil end
    return Player.ReadLink(target)
end

-- ---------------------------------------------------------------------------
-- Invalidacion
-- ---------------------------------------------------------------------------

local frame = CreateFrame('Frame')
-- Todo evento que pueda cambiar el contexto lo ensucia; la reconstruccion es perezosa. Un
-- evento que el cliente no conozca no debe romper la carga.
for _, event in ipairs({ 'QUEST_LOG_UPDATE', 'SKILL_LINES_CHANGED', 'QUEST_ACCEPTED', 'QUEST_REMOVED',
    'QUEST_TURNED_IN', 'PLAYER_LEVEL_UP', 'PLAYER_REGEN_ENABLED' }) do
    pcall(frame.RegisterEvent, frame, event)
end

-- Una reconstruccion diferida (agrupada) para que OnChanged se entere de cambios reales aunque
-- nadie pida el contexto. Expandir encabezados provoca otro evento, pero esa segunda
-- reconstruccion no expande (misma huella) y no cambia el contenido: no avisa y se corta ahi.
local function scheduleCheck()
    if pending or #changedCallbacks == 0 or not (C_Timer and C_Timer.After) then return end
    pending = true
    C_Timer.After(0.2, function()
        pending = false
        if #changedCallbacks > 0 then Player.GetContext() end
    end)
end

frame:SetScript('OnEvent', function(_, event)
    if scanning then return end -- eco sincronico de nuestra propia expansion
    -- Aceptar/abandonar/entregar una mision puede cambiar el diario sin cambiar la huella (mismo
    -- total bajo un encabezado plegado): se olvida lo escaneado. QUEST_LOG_UPDATE no, porque es
    -- tambien el eco de nuestra propia expansion.
    if event == 'QUEST_ACCEPTED' or event == 'QUEST_REMOVED' or event == 'QUEST_TURNED_IN' then
        questMemo.fp, questMemo.at = nil, nil
        questRevision = questRevision + 1
    end
    markDirty()
    scheduleCheck()
end)
