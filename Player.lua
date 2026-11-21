local _, ns = ...

-- Contexto del personaje para el clasificador y lectura de items de las bolsas.
-- Toda API del cliente se detecta antes de usarla: en Forever conviven nombres clasicos
-- y modernos (C_*) y no se asume ninguno.
local Player = {}
ns.Player = Player

local cache    -- contexto vigente (nil = sucio, se reconstruye en el proximo GetContext)
local previous -- ultimo contexto antes de ensuciarse: para avisar a OnChanged si cambio de contenido
local lastQuestFound -- {names=, titles=, ids=, idsKnown=} del ultimo escaneo COMPLETO del diario
local questMemo, skillMemo = {}, {} -- {fp=, data=}: resultado del ultimo escaneo con expansion
local scanning = false -- true mientras se expanden/pliegan encabezados: sus eventos sincronicos se ignoran
local pending = false -- hay una reconstruccion diferida programada
local changedCallbacks = {}
local knownState, restorationState, optionalRevision = {}, {}, 0 -- conocimiento por ejemplar
-- Efectos vistos en el tooltip (regla 30): [itemID] = true|false, solo lecturas completas.
local effectState = {} -- [itemID] = true|false|{pendiente}: ver resolveEffect
local scanTip -- GameTooltip oculto de respaldo (sin C_TooltipInfo), creado al primer uso
local retryAt -- momento del timer de reintento de efectos programado
local effectRevision = 0 -- sube cuando se resuelve un efecto pendiente: entra en la firma (OnChanged)
local signatures = setmetatable({}, { __mode = 'k' }) -- [ctx] = firma de contenido
-- Sube con cada alta, baja o entrega de mision: isQuestDone puede responder distinto aunque
-- el resto del contexto sea igual, y eso tiene que avisar por OnChanged. Los ecos de expandir
-- el diario (QUEST_LOG_UPDATE) no la tocan, asi que no reabren aquel bucle.
local questRevision = 0

local function markDirty()
    if cache then previous = cache end
    cache = nil
    knownState, restorationState = {}, {}
end

function Player.Invalidate() markDirty() end

-- fn(ctx) se llama tras una reconstruccion SOLO si el contenido del contexto cambio
-- (clase, profesiones, items de misiones, questLogIncomplete, revision de misiones).
function Player.OnChanged(fn) changedCallbacks[#changedCallbacks + 1] = fn end

-- Solo para pruebas: deja el modulo como recien cargado.
function Player.ResetState()
    cache, previous, lastQuestFound, scanning, pending = nil, nil, nil, false, false
    questMemo, skillMemo, changedCallbacks = {}, {}, {}
    effectState, scanTip, retryAt, effectRevision = {}, nil, nil, 0
    knownState, restorationState, optionalRevision = {}, {}, 0
    eventQueue, eventScheduled = {}, false
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
    -- scan() devuelve false si alguna fila u objetivo todavía no tiene datos: ese escaneo no es completo.
    if not any then return scan() ~= false end
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
        local full = scan() ~= false
        complete = not stillCollapsed and full
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

-- Lee el diario completo. Devuelve found y complete:
--   found = { names = {[normalizado]=nombre} de items pedidos, titles = {[normalizado]=titulo de la
--   mision que lo pide}, ids = {[questID]=true} de las misiones del diario, idsKnown = true si todas
--   las misiones leidas trajeron su questID (si no, ids no alcanza para decir "no esta") }.
-- complete=false si quedaron misiones sin leer (encabezado plegado en combate, sin API para
-- expandir, o sin API de diario).
local function scanQuestLog()
    local found = { names = {}, titles = {}, ids = {}, idsKnown = true }
    local names = found.names
    local function add(text, kind, title)
        local name = objectiveItemName(text, kind)
        if name and name ~= '' then
            local key = ns.NormalizeName(name)
            names[key] = name
            if type(title) == 'string' and title ~= '' then found.titles[key] = title end
        end
    end
    local function quest(questID)
        if type(questID) == 'number' and questID > 0 then found.ids[questID] = true else found.idsKnown = false end
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
            local full = true
            for index = 1, count() do
                local info = C_QuestLog.GetInfo(index)
                if not info then
                    full = false -- fila sin datos: podría ser una misión con objetos
                elseif not info.isHeader then
                    quest(info.questID)
                    if info.questID then
                        local objectives = C_QuestLog.GetQuestObjectives(info.questID)
                        if objectives == nil then
                            -- Datos de la misión sin cargar: pedirlos y no dar el diario por leído.
                            full = false
                            if type(C_QuestLog.RequestLoadQuestByID) == 'function' then
                                pcall(C_QuestLog.RequestLoadQuestByID, info.questID)
                            end
                        end
                        for _, objective in ipairs(objectives or {}) do
                            add(objective.text, objective.type, info.title)
                        end
                    end
                end
            end
            return full
        end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = found end
        return found, complete
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
                    -- 8.o retorno: questID (si el cliente no lo da, idsKnown queda en false).
                    local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
                    if not isHeader then
                        quest(questID)
                        for objective = 1, GetNumQuestLeaderBoards(index) or 0 do
                            local text, kind = GetQuestLogLeaderBoard(objective, index)
                            add(text, kind, title)
                        end
                    end
                end
            end, save, restore, fingerprint, questMemo)
        if how == 'cached' then return questMemo.data, true end
        if how == 'expanded' then questMemo.data = found end
        return found, complete
    end
    found.idsKnown = false
    return found, false
end

-- Devuelve questItemsInLog = {[itemID]=true} y si el diario quedo incompleto. Un escaneo
-- incompleto no reemplaza al ultimo completo: se unen (lo ya visto sigue protegiendo), pero
-- el contexto queda questLogIncomplete igual: el escaneo anterior no certifica misiones
-- nuevas que no se pudieron leer. Se certifica de nuevo solo con un escaneo completo.
-- Los objetivos traen el nombre, no el id: se resuelve con GetItemInfo(nombre) y, para lo
-- que no se pudo resolver, __index compara por el nombre del item consultado (un item de
-- mision gris no debe quedar con monedita por no haberse resuelto a tiempo).
local function buildQuestItems()
    local found, complete = scanQuestLog()
    local incomplete = not complete
    if complete then
        lastQuestFound = found
    elseif lastQuestFound then
        -- Copia: no se toca la tabla del memo ni la del ultimo escaneo completo.
        local merged = { names = {}, titles = {}, ids = {}, idsKnown = false }
        for _, source in ipairs({ lastQuestFound, found }) do
            for field in pairs({ names = true, titles = true, ids = true }) do
                for key, value in pairs(source[field]) do merged[field][key] = value end
            end
        end
        found = merged
    end
    local names = found.names
    local ids = {}
    for _, name in pairs(names) do
        if type(ns.API.GetItemInfo) == 'function' then
            local _, link = ns.API.GetItemInfo(name)
            local id = type(link) == 'string' and tonumber(link:match('item:(%d+)'))
            if id then ids[id] = true end
        end
    end
    return setmetatable(ids, { __index = function(_, id)
        if next(names) == nil or type(ns.API.GetItemInfo) ~= 'function' then return nil end
        local name = ns.API.GetItemInfo(id)
        if type(name) == 'string' and names[ns.NormalizeName(name)] then return true end
        return nil
    end }), incomplete, found
end

-- questInLog(questID): true si la mision esta en el diario; false si no (lo dicen los questID del
-- escaneo o C_QuestLog.IsOnQuest); nil si no se puede saber.
local function questInLogFor(found)
    return function(questID)
        if type(questID) ~= 'number' then return nil end
        if found.ids[questID] then return true end
        if found.idsKnown then return false end
        if C_QuestLog and type(C_QuestLog.IsOnQuest) == 'function' then
            local success, answer = pcall(C_QuestLog.IsOnQuest, questID)
            if success and (answer == true or answer == false) then return answer end
        end
        return nil
    end
end

-- questItemTitle(itemID): titulo de la mision del diario que pide el item, o nil.
local function questItemTitleFor(found)
    return function(itemID)
        if type(ns.API.GetItemInfo) ~= 'function' or next(found.titles) == nil then return nil end
        local name = ns.API.GetItemInfo(itemID)
        return type(name) == 'string' and found.titles[ns.NormalizeName(name)] or nil
    end
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

local ARMOR_SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10 }

local function readEquippedArmor()
    local equipped, parts = {}, {}
    local inv = type(GetInventoryItemID) == 'function' and GetInventoryItemID or nil
    local instant = type(ns.API.GetItemInfoInstant) == 'function' and ns.API.GetItemInfoInstant
        or (type(C_Item) == 'table' and type(C_Item.GetItemInfoInstant) == 'function' and C_Item.GetItemInfoInstant) or nil
    for i, slot in ipairs(ARMOR_SLOTS) do
        local sub = false
        if inv and instant then
            local ok, id = pcall(inv, 'player', slot)
            if ok and type(id) == 'number' and id > 0 then
                local good, _, _, _, _, _, classID, subclassID = pcall(instant, id)
                if good and classID == 4 and type(subclassID) == 'number' and subclassID >= 1 and subclassID <= 4 then
                    sub = subclassID
                end
            end
        end
        equipped[slot] = sub
        parts[i] = slot .. ':' .. tostring(sub)
    end
    return equipped, table.concat(parts, ',')
end

-- Suma de rangos de la rama `tab` con GetTalentInfo (rango = 5.o valor; `group` opcional), o nil.
local function summedRanks(tab, group)
    if type(GetNumTalents) ~= 'function' or type(GetTalentInfo) ~= 'function' then return nil end
    local ok, count = pcall(GetNumTalents, tab, group)
    if not ok or type(count) ~= 'number' then ok, count = pcall(GetNumTalents, tab) end
    if not ok or type(count) ~= 'number' or count <= 0 then return nil end
    local total = 0
    for index = 1, count do
        local good, _, _, _, _, rank = pcall(GetTalentInfo, tab, index, false, false, group)
        if not good or type(rank) ~= 'number' then good, _, _, _, _, rank = pcall(GetTalentInfo, tab, index) end
        if good and type(rank) == 'number' and rank > 0 and rank <= 10 then total = total + rank end
    end
    return total
end

-- Nombre y puntos de la rama `tab` (del grupo `group`, o el activo). Acepta las dos formas de
-- GetTalentTabInfo (vieja: nombre, icono, puntos; nueva: id, nombre, descripcion, icono, puntos) y
-- las firmas (tab), (tab, grupo) y (tab, false, false, grupo). Si los puntos no vienen, los suma
-- talento por talento. nil si no hay nombre.
function Player.TalentTab(tab, group)
    if type(GetTalentTabInfo) ~= 'function' then return nil end
    local calls = group and { { tab, false, false, group }, { tab, group } } or { { tab } }
    local found
    for _, args in ipairs(calls) do
        local ok, first, second, third, fourth, fifth = pcall(GetTalentTabInfo, unpack(args))
        if ok then
            local name, points = first, third
            if type(first) == 'number' then name, points = second, fifth end
            if type(name) == 'string' and name ~= '' then
                if type(points) == 'number' and points > 0 then return name, points end
                found = found or name
            end
        end
    end
    if found then return found, summedRanks(tab, group) or 0 end
end

-- Rama activa en el cliente de Forever: no hay GetNumTalentTabs (probado en el juego 2026-11-21). La
-- ventana de talentos lee las ramas con C_Traits: GetGroupDisplayInfoByTreeID da las 3 en orden y
-- GetGroupCurrencyInfo los puntos gastados (mismo metodo que KnuUI/PawnSpec.lua, probado en el juego).
-- Devuelve indice (1..3), nombre (si el cliente lo da) y las filas leidas; indice nil sin puntos o empate.
function Player.TraitSpec()
    local traits = rawget(_G, 'C_Traits')
    if type(traits) ~= 'table' or type(traits.GetConfigInfo) ~= 'function'
        or type(traits.GetGroupDisplayInfoByTreeID) ~= 'function' or type(traits.GetGroupCurrencyInfo) ~= 'function' then
        return nil
    end
    local config
    local talents = rawget(_G, 'C_ClassTalents')
    if type(talents) == 'table' and type(talents.GetActiveConfigID) == 'function' then
        local ok, id = pcall(talents.GetActiveConfigID); if ok then config = id end
    end
    local spec = rawget(_G, 'C_SpecializationInfo')
    if not config and type(spec) == 'table' and type(spec.GetCombatConfigIDForSpecGroup) == 'function' then
        local group = 1
        if type(spec.GetActiveSpecGroup) == 'function' then
            local ok, value = pcall(spec.GetActiveSpecGroup); if ok and type(value) == 'number' then group = value end
        end
        local ok, id = pcall(spec.GetCombatConfigIDForSpecGroup, group); if ok then config = id end
    end
    if not config then return nil end
    local ok, info = pcall(traits.GetConfigInfo, config)
    local tree = ok and type(info) == 'table' and type(info.treeIDs) == 'table' and info.treeIDs[1]
    if not tree then return nil end
    local good, groups = pcall(traits.GetGroupDisplayInfoByTreeID, tree)
    if not good or type(groups) ~= 'table' then return nil end
    local ids, index, names = {}, {}, {}
    for i, g in ipairs(groups) do
        if type(g) == 'table' and g.groupID ~= nil then
            ids[#ids + 1] = g.groupID; index[g.groupID] = i
            names[i] = type(g.name) == 'string' and g.name ~= '' and g.name or nil
        end
    end
    local fine, currencies = pcall(traits.GetGroupCurrencyInfo, config, ids)
    if not fine or type(currencies) ~= 'table' then return nil end
    local best, bestSpent, tie, rows = nil, 0, false, {}
    for _, g in ipairs(currencies) do
        local c = type(g) == 'table' and type(g.currencyInfos) == 'table' and g.currencyInfos[1]
        local spent = type(c) == 'table' and tonumber(c.spent) or 0
        local i = type(g) == 'table' and index[g.traitNodeGroupID]
        if i then
            rows[#rows + 1] = i .. '=' .. spent
            if spent > bestSpent then best, bestSpent, tie = i, spent, false
            elseif spent > 0 and spent == bestSpent then tie = true end
        end
    end
    if tie or not best then return nil, nil, rows end
    return best, names[best], rows
end

-- Nombre localizado de la rama `index` segun Pawn (si esta), o nil.
local function pawnSpecName(index)
    local getter = rawget(_G, 'PawnGetSpecializationInfoForClassID')
    if type(getter) ~= 'function' or type(UnitClass) ~= 'function' then return nil end
    local classID = select(3, UnitClass('player'))
    local ok, _, name = pcall(getter, classID, index)
    if ok and type(name) == 'string' and name ~= '' then return name end
end

local function readSpec(class)
    local root = ns.GearQuestRoot and ns.GearQuestRoot()
    if type(root) == 'table' and type(root.GetEffectiveSpec) == 'function'
        and type(root.Spec) == 'table' and type(root.Spec.GetOptions) == 'function' then
        local good, id = pcall(root.GetEffectiveSpec, root)
        local ok, options = pcall(root.Spec.GetOptions, root.Spec, class)
        if good and id and ok and type(options) == 'table' then
            for _, option in ipairs(options) do
                if option.id == id and type(option.label) == 'string' and option.label ~= '' then
                    return option.label, 'gearquest'
                end
            end
        end
    end
    local index, name = Player.TraitSpec()
    if index then return name or pawnSpecName(index), 'talents', index end
    if type(GetNumTalentTabs) ~= 'function' or type(GetTalentTabInfo) ~= 'function' then return end
    local good, tabs = pcall(GetNumTalentTabs)
    if not good or type(tabs) ~= 'number' then return end
    local most, label = 0
    for tab = 1, tabs do
        local name, points = Player.TalentTab(tab)
        if name and points > most then most, label = points, name end
    end
    if label then return label, 'talents' end
end

local function readOffSpec(class, mainLabel)
    local groups, active = 1, 1
    if type(GetNumTalentGroups) == 'function' then
        local good, count = pcall(GetNumTalentGroups)
        if good and type(count) == 'number' then groups = count end
    end
    if groups < 2 then return nil, nil, groups, active end
    if type(GetActiveTalentGroup) == 'function' then
        local good, value = pcall(GetActiveTalentGroup)
        if good and (value == 1 or value == 2) then active = value end
    end
    if type(GetNumTalentTabs) ~= 'function' or type(GetTalentTabInfo) ~= 'function' then
        return nil, nil, groups, active
    end
    local good, tabs = pcall(GetNumTalentTabs)
    if not good or type(tabs) ~= 'number' then return nil, nil, groups, active end
    local other = active == 1 and 2 or 1
    local label, most = nil, 0
    for tab = 1, tabs do
        local name, points = Player.TalentTab(tab, other)
        if name and points > most then label, most = name, points end
    end
    if not label or (mainLabel and ns.FoldSpecLabel(label) == ns.FoldSpecLabel(mainLabel)) then
        return nil, nil, groups, active
    end
    local root = ns.GearQuestRoot and ns.GearQuestRoot()
    if type(root) == 'table' and type(root.Spec) == 'table' and type(root.Spec.GetOptions) == 'function' then
        local ok, options = pcall(root.Spec.GetOptions, root.Spec, class)
        for _, option in ipairs(ok and type(options) == 'table' and options or {}) do
            if type(option.label) == 'string' and ns.FoldSpecLabel(option.label) == ns.FoldSpecLabel(label) then
                return label, option.id, groups, active
            end
        end
    end
    return label, nil, groups, active
end

local function readEquippedLevel()
    local levels, signature, pending = {}, {}, false
    for slot = 1, 18 do
        if slot ~= 4 then
            if type(GetInventoryItemLink) == 'function' then
                local ok, link = pcall(GetInventoryItemLink, 'player', slot)
                if ok and link == nil then levels[slot] = false
                elseif ok and type(ns.API.GetItemInfo) == 'function' and type(link) == 'string' then
                    local good, name, _, _, level = pcall(ns.API.GetItemInfo, link)
                    if good and name and type(level) == 'number' then levels[slot] = level end
                end
            end
            signature[#signature + 1] = slot .. ':' .. tostring(levels[slot])
            if levels[slot] == nil then pending = true end
        end
    end
    return levels, table.concat(signature, ','), pending
end

local function buildContext()
    local class
    if type(UnitClass) == 'function' then class = select(2, UnitClass('player')) end
    local professions = readProfessions()
    local level
    if type(UnitLevel) == 'function' then
        local good, value = pcall(UnitLevel, 'player')
        if good and type(value) == 'number' and value > 0 then level = value end
    end
    local questItems, incomplete, found = buildQuestItems()
    local equippedArmor, armorSig = readEquippedArmor()
    local specLabel, specSource, specIndex = readSpec(class)
    local offSpecLabel, offSpecId, talentGroups, activeTalentGroup = readOffSpec(class, specLabel)
    local equippedLevel, levelSig, equippedLevelPending = readEquippedLevel()
    -- QuestieDB disponible pero con el indice aun sin terminar: Uses da nil y no se sabe si el
    -- item es de una mision. Mismo trato que un diario sin leer: ninguna moneda.
    if ns.Questie and type(ns.Questie.Pending) == 'function' and ns.Questie.Pending() then incomplete = true end
    local ctx = {
        class = class,
        level = level,
        professions = professions,
        equippedArmor = equippedArmor,
        equippedLevel = equippedLevel,
        equippedLevelPending = equippedLevelPending,
        specLabel = specLabel,
        specSource = specSource,
        specIndex = specIndex,
        offSpecLabel = offSpecLabel,
        offSpecId = offSpecId,
        talentGroups = talentGroups,
        activeTalentGroup = activeTalentGroup,
        isQuestDone = isQuestDone,
        questInLog = questInLogFor(found),
        questItemsInLog = questItems,
        questItemTitle = questItemTitleFor(found),
        questLogIncomplete = incomplete or nil,
        questieUses = ns.Questie and ns.Questie.Uses or nil,
        overrides = ns.DB and ns.DB.overrides or {},
        rules = ns.DB and ns.DB.rules or {},
    }
    ctx.bagStock = Player.BagStock(level, ctx.rules)
    -- pairs ignora el __index de questItemsInLog: solo los ids ya resueltos.
    signatures[ctx] = table.concat({ tostring(class), tostring(level), tostring(incomplete), tostring(questRevision), tostring(effectRevision), sortedKeys(professions),
        sortedKeys(questItems), sortedKeys(found.names), sortedKeys(found.ids), tostring(optionalRevision),
        ctx.bagStock.signature or '', armorSig, levelSig, tostring(specLabel), tostring(specSource), tostring(specIndex),
        tostring(offSpecLabel), tostring(offSpecId), tostring(talentGroups), tostring(activeTalentGroup) }, '|')
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

local function bare(text)
    if type(text) ~= 'string' then return nil end
    return (text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', ''):gsub('^%s+', ''))
end

-- Prefijos de las lineas de efecto: las globales del cliente (localizadas) y, por si faltan, ingles y
-- castellano. "Probabilidad al acertar" (proc de arma) tambien es un efecto.
local function triggers()
    local list = {}
    for _, global in ipairs({ 'ITEM_SPELL_TRIGGER_ONEQUIP', 'ITEM_SPELL_TRIGGER_ONUSE', 'ITEM_SPELL_TRIGGER_ONPROC' }) do
        local value = rawget(_G, global)
        if type(value) == 'string' and value ~= '' then list[#list + 1] = value end
    end
    for _, value in ipairs({ 'Equip:', 'Use:', 'Chance on hit:', 'Equipar:', 'Uso:', 'Probabilidad al acertar:' }) do
        list[#list + 1] = value
    end
    return list
end

-- Tipos de linea de C_TooltipInfo que pueden venir sin texto legitimamente (Blank, Separator).
local function blankLineType(kind)
    if type(kind) ~= 'number' then return false end
    local enum = type(Enum) == 'table' and type(Enum.TooltipDataLineType) == 'table' and Enum.TooltipDataLineType or nil
    local blank = enum and enum.Blank or 1
    local separator = enum and enum.Separator or 23
    -- Precio de venta: el juego no manda texto (dibuja las monedas). Visto en Forever con
    -- /knu junk debug: «6 tipo=11 izq=""». Enum.TooltipDataLineType.SellPrice = 11 (warcraft.wiki.gg).
    local sellPrice = enum and enum.SellPrice or 11
    return kind == blank or kind == separator or kind == sellPrice
end

local function retrieving(text)
    local global = rawget(_G, 'RETRIEVING_ITEM_INFO')
    return type(global) == 'string' and global ~= '' and text == global
end

-- Lee el tooltip del item. Devuelve texts, how, instance:
--   how = 'complete', 'partial' o 'unavailable' (no hay forma de leerlo en este cliente).
--   Completo = el titulo (nombre) y al menos otra linea con texto, y ninguna linea pendiente. Una
--   lectura con solo el titulo es 'partial': no prueba que no haya efectos.
--   instance = dataInstanceID de C_TooltipInfo, para cruzar con TOOLTIP_DATA_UPDATE.
-- C_TooltipInfo.GetHyperlink: una linea sin texto es espaciador solo si su tipo es Blank o Separator;
-- si no, esta pendiente. GameTooltip oculto (sin C_TooltipInfo): solo se llama con el item ya en la
-- cache del cliente (ReadLink exige GetItemInfo antes); con el titulo presente, una region con texto
-- vacio ('') es un espaciador de diseno, y una sin texto (nil) o "Recuperando..." esta pendiente.
local function tooltipTexts(id, bag, slot)
    local link = 'item:' .. id
    local getter = type(C_TooltipInfo) == 'table' and (bag ~= nil and C_TooltipInfo.GetBagItem or C_TooltipInfo.GetHyperlink)
    if bag ~= nil and type(C_TooltipInfo) == 'table' and type(C_TooltipInfo.GetBagItem) ~= 'function' then getter = nil end
    if type(getter) == 'function' then
        local success, data
        if bag ~= nil then success, data = pcall(getter, bag, slot)
        else success, data = pcall(getter, link) end
        if not success or type(data) ~= 'table' or type(data.lines) ~= 'table' or #data.lines == 0 then
            return nil, 'partial'
        end
        local instance = data.dataInstanceID
        local texts, complete, withText = {}, true, 0
        for index, line in ipairs(data.lines) do
            local text = type(line) == 'table' and line.leftText or nil
            if text == nil and type(line) == 'table' and type(line.args) == 'table' then
                for _, arg in ipairs(line.args) do
                    if type(arg) == 'table' and arg.field == 'leftText' then text = arg.stringVal end
                end
            end
            if type(text) ~= 'string' or text == '' then
                if not (type(line) == 'table' and blankLineType(line.type)) then complete = false end
                text = ''
            elseif retrieving(text) then
                complete = false
            else
                withText = withText + 1
            end
            texts[index] = text
        end
        if texts[1] == '' or withText < 2 then complete = false end
        return texts, complete and 'complete' or 'partial', instance
    end
    if type(CreateFrame) ~= 'function' then return nil, 'unavailable' end
    local success, texts, how = pcall(function()
        if not scanTip then
            scanTip = CreateFrame('GameTooltip', 'KnuJunkScanTooltip', nil, 'GameTooltipTemplate')
        end
        if type(scanTip.NumLines) ~= 'function' then return nil, 'unavailable' end
        if bag ~= nil and type(scanTip.SetBagItem) ~= 'function' then return nil, 'unavailable' end
        if bag == nil and type(scanTip.SetHyperlink) ~= 'function' then return nil, 'unavailable' end
        if type(scanTip.SetOwner) == 'function' then scanTip:SetOwner(rawget(_G, 'WorldFrame') or UIParent, 'ANCHOR_NONE') end
        if type(scanTip.ClearLines) == 'function' then scanTip:ClearLines() end
        if bag ~= nil then scanTip:SetBagItem(bag, slot) else scanTip:SetHyperlink(link) end
        local count = scanTip:NumLines()
        if type(count) ~= 'number' or count == 0 then return nil, 'partial' end
        local list, complete, withText = {}, true, 0
        for index = 1, count do
            local region = rawget(_G, 'KnuJunkScanTooltipTextLeft' .. index)
            local text = type(region) == 'table' and type(region.GetText) == 'function' and region:GetText() or nil
            if type(text) ~= 'string' or retrieving(text) then
                complete = false; text = ''
            elseif text ~= '' then
                withText = withText + 1
            end
            list[index] = text
        end
        if list[1] == '' or withText < 2 then complete = false end
        return list, complete and 'complete' or 'partial'
    end)
    if success then return texts, how end
    return nil, 'partial'
end

-- Busca una linea de efecto. true si aparece (aunque la lectura sea parcial: es evidencia); false solo
-- con lectura completa sin efecto; nil si no se sabe. Devuelve tambien how e instance.
local function scanEffect(id)
    local texts, how, instance = tooltipTexts(id)
    if texts then
        local prefixes = triggers()
        for index = 2, #texts do
            local text = bare(texts[index]) or ''
            for _, prefix in ipairs(prefixes) do
                if text ~= '' and text:sub(1, #prefix) == prefix then return true, how, instance end
            end
        end
        if how == 'complete' then return false, how, instance end
    end
    return nil, how, instance
end

-- Estado por itemID (regla 30): { value = true|false|nil, instance, attempts, nextAt, final }.
--   value true/false = resuelto (guarda el dataInstanceID de la lectura); nil = pendiente.
-- Un pendiente no se re-escanea en cada repintado: el timer lo reintenta con espera creciente
-- (EFFECT_BACKOFF * 2^n) hasta MAX_EFFECT_ATTEMPTS lecturas y despues queda final. Los eventos de datos
-- que llegan (TOOLTIP_DATA_UPDATE de su instancia, o sin instancia; GET_ITEM_INFO_RECEIVED del item)
-- lo releen aunque este final; TOOLTIP_DATA_UPDATE de la instancia de un 'no' guardado lo invalida y
-- lo relee. Cada cambio resuelto avisa una sola vez (agrupado) por OnChanged.
local MAX_EFFECT_ATTEMPTS, EFFECT_BACKOFF = 5, 0.5
local scheduleEffectRetry

-- mode: nil (lectura normal), 'timer' (reintento programado), 'event' (llego un dato).
-- Diagnóstico (/knu junk debug <enlace>): qué líneas del tooltip lee KnuJunk y cuál lo deja incompleto.
function Player.DebugTooltip(link)
    local id = type(link) == 'string' and tonumber(link:match('item:(%d+)')) or tonumber(link)
    if not id then return nil end
    local out = {}
    local getter = type(C_TooltipInfo) == 'table' and C_TooltipInfo.GetHyperlink
    if type(getter) ~= 'function' then
        out[1] = 'C_TooltipInfo.GetHyperlink: no existe (se usa el tooltip oculto)'
    else
        local ok, data = pcall(getter, 'item:' .. id)
        if not ok or type(data) ~= 'table' or type(data.lines) ~= 'table' then
            out[1] = 'C_TooltipInfo.GetHyperlink: sin datos (' .. tostring(data) .. ')'
        else
            for index, line in ipairs(data.lines) do
                local text = type(line) == 'table' and line.leftText or nil
                local right = type(line) == 'table' and line.rightText or nil
                local bad = (type(text) ~= 'string' or text == '') and not (type(line) == 'table' and blankLineType(line.type))
                out[#out + 1] = string.format('%d tipo=%s izq=%q der=%q%s', index, tostring(type(line) == 'table' and line.type),
                    tostring(text), tostring(right), bad and '  <- INCOMPLETA' or (retrieving(text or '') and '  <- CARGANDO' or ''))
            end
        end
    end
    local _, how = tooltipTexts(id)
    local state = effectState[id]
    out[#out + 1] = string.format('lectura=%s efecto=%s intentos=%s final=%s', tostring(how),
        tostring(state and state.value), tostring(state and state.attempts), tostring(state and state.final))
    local ctx, item = Player.GetContext(), Player.ReadLink(link)
    local L = ns.L
    local source = ctx.specSource == 'gearquest' and 'GearQuest' or ctx.specSource == 'talents' and L['talents'] or L['no source']
    out[#out + 1] = L['Spec: %s | source: %s']:format(ctx.specLabel or L['none'], source)
    local traitIndex, traitName, traitRows = Player.TraitSpec()
    out[#out + 1] = string.format('C_Traits: rama=%s nombre=%s puntos=%s', tostring(traitIndex), tostring(traitName),
        traitRows and table.concat(traitRows, ' ') or 'sin datos')
    out[#out + 1] = 'specIndex=' .. tostring(ctx.specIndex)
    -- Lectura cruda y en el momento (sin caché) de cada rama, para diagnosticar clientes nuevos.
    local tabsOk, tabs = pcall(GetNumTalentTabs or function() return nil end)
    out[#out + 1] = 'GetNumTalentTabs=' .. tostring(tabsOk and tabs)
    for tab = 1, (tabsOk and type(tabs) == 'number' and tabs or 0) do
        local raw = { pcall(GetTalentTabInfo or function() return nil end, tab) }
        local parts = {}
        for i = 1, 6 do parts[i] = tostring(raw[i + 1]) end
        local name, points = Player.TalentTab(tab)
        out[#out + 1] = string.format('GetTalentTabInfo(%d)=%s -> %s %s', tab, table.concat(parts, ', '),
            tostring(name), tostring(points))
    end
    out[#out + 1] = L['Talent groups: %s | active: %s']:format(tostring(ctx.talentGroups), tostring(ctx.activeTalentGroup))
    out[#out + 1] = L['Other spec: %s | GearQuest id: %s']:format(ctx.offSpecLabel or L['none'], ctx.offSpecId or L['none'])
    local ranked = item and ns.GearQuestOffSpecRanked(item, ctx)
    local pawn = item and ns.PawnOffSpecUpgrade(item, ctx)
    local function verdict(value)
        if value == nil or value == 'pending' then return L['no verdict'] end
        return L[value and 'yes' or 'no']
    end
    out[#out + 1] = L['Other spec GearQuest rank: %s']:format(verdict(ranked))
    out[#out + 1] = L['Other spec Pawn upgrade: %s']:format(verdict(pawn))
    local scales = ns.PawnScales(ctx)
    out[#out + 1] = L['Visible Pawn scales: %s']:format(#scales == 0 and L['none'] or tostring(#scales))
    for _, scale in ipairs(scales) do
        out[#out + 1] = L['Pawn scale: %s | matches: %s']:format(tostring(scale.label), L[scale.matches and 'yes' or 'no'])
    end
    out[#out + 1] = L['Item level: %s']:format(tostring(item and item.itemLevel))
    for _, slot in ipairs(item and ns.GearSlots[item.equipLoc] or {}) do
        out[#out + 1] = L['Equipped slot %d: %s']:format(slot,
            ctx.equippedLevel[slot] == false and L['empty'] or tostring(ctx.equippedLevel[slot]))
    end
    return out
end

local function resolveEffect(id, mode)
    local state = effectState[id]
    if state and state.value ~= nil then return state.value end
    if state and mode == nil and (state.final or now() < (state.nextAt or 0)) then return nil end
    if state and mode == 'timer' and state.final then return nil end
    local answer, how, instance = scanEffect(id)
    if answer ~= nil then
        effectState[id] = { value = answer, instance = instance }
        return answer
    end
    state = state or { attempts = 0, nextAt = 0 }
    state.attempts, state.nextAt = state.attempts or 0, state.nextAt or 0
    state.instance = instance or state.instance
    if how == 'unavailable' then
        state.final = true
    elseif mode == 'event' then
        -- Las relecturas por evento no gastan intentos; si el pendiente todavia tiene intentos del timer
        -- y no hay uno programado a futuro, se programa el proximo.
        if not state.final and state.nextAt <= now() then
            state.nextAt = now() + EFFECT_BACKOFF * 2 ^ state.attempts
            scheduleEffectRetry(state.nextAt)
        end
    else
        -- Las relecturas por evento no gastan intentos del timer.
        state.attempts = state.attempts + 1
        if state.attempts >= MAX_EFFECT_ATTEMPTS then
            state.final = true
        else
            state.nextAt = now() + EFFECT_BACKOFF * 2 ^ (state.attempts - 1)
            scheduleEffectRetry(state.nextAt)
        end
    end
    effectState[id] = state
    return nil
end

local function announceEffects()
    effectRevision = effectRevision + 1
    markDirty()
    if #changedCallbacks > 0 then Player.GetContext() end
end

local function retryEffects()
    local resolved, earliest = false, nil
    for id, state in pairs(effectState) do
        if state.value == nil and not state.final and now() >= state.nextAt then
            if resolveEffect(id, 'timer') ~= nil then resolved = true end
        end
    end
    for _, state in pairs(effectState) do
        if state.value == nil and not state.final and (not earliest or state.nextAt < earliest) then earliest = state.nextAt end
    end
    if earliest then scheduleEffectRetry(earliest) end
    if resolved then announceEffects() end
end

-- Un solo timer, para el reintento mas proximo.
scheduleEffectRetry = function(at)
    if not (C_Timer and C_Timer.After) then return end
    if retryAt and retryAt <= at then return end
    retryAt = at
    C_Timer.After(math.max(0, at - now()), function()
        if retryAt ~= at then return end -- reemplazado por uno mas proximo
        retryAt = nil
        retryEffects()
    end)
end

-- Relecturas por evento, agrupadas: [id] = valor anterior (o false si era pendiente).
local eventQueue, eventScheduled = {}, false
local function flushEventQueue()
    eventScheduled = false
    local queue = eventQueue
    eventQueue = {}
    local changed = false
    -- Cualquier cambio de estado avisa, tambien no -> no se sabe (retira una moneda de clase vieja).
    for id, before in pairs(queue) do
        local after = resolveEffect(id, 'event')
        if after == nil then after = 'pending' end
        if after ~= before then changed = true end
    end
    if changed then announceEffects() end
end

local function queueEffect(id, before)
    if eventQueue[id] == nil then eventQueue[id] = before end
    if eventScheduled then return end
    if C_Timer and C_Timer.After then
        eventScheduled = true
        C_Timer.After(0, flushEventQueue)
    else
        flushEventQueue()
    end
end

-- Ambos devuelven true sólo si el evento tocaba un ítem que KnuJunk estaba esperando.
local function onTooltipDataUpdate(instance)
    local touched = false
    for id, state in pairs(effectState) do
        if state.value == nil then
            if instance == nil or state.instance == nil or state.instance == instance then
                queueEffect(id, 'pending'); touched = true
            end
        elseif state.value == false and instance ~= nil and state.instance == instance then
            -- Invalidado: pasa a pendiente completo (intentos del timer desde cero) y se relee.
            effectState[id] = { attempts = 0, nextAt = 0, instance = state.instance }
            queueEffect(id, false); touched = true
        end
    end
    return touched
end

local function onItemInfo(id)
    local state = effectState[id]
    if state and state.value == nil then queueEffect(id, 'pending'); return true end
    -- Sólo cuenta si el ítem es de una regla opcional encendida.
    local data, rules = ns.Data or {}, (ns.DB and ns.DB.rules) or {}
    return id ~= nil and ((rules.food and data.food and data.food[id])
        or (rules.ammo and data.ammo and data.ammo[id])
        or (rules.knownRecipe and data.recipes and data.recipes[id])) and true or false
end

-- Efecto de uso/equipar: 'yes' (GetItemSpell con nombre o id, o una linea "Equipar:"/"Uso:"/
-- "Probabilidad al acertar:" en el tooltip), 'no' (GetItemSpell sin nada Y tooltip completo sin esas
-- lineas) o 'unknown' (sin API, error, o tooltip pendiente/ilegible). Ver Classify: 'unknown' no
-- bloquea la moneda del gris pero si las demas.
local function itemEffect(id)
    local api
    if C_Item and type(C_Item.GetItemSpell) == 'function' then api = C_Item.GetItemSpell
    elseif type(ns.API.GetItemSpell) == 'function' then api = ns.API.GetItemSpell end
    if not api then return 'unknown' end
    local success, name, spellID = pcall(api, id)
    if not success then return 'unknown' end
    if name ~= nil or spellID ~= nil then return 'yes' end
    local seen = resolveEffect(id, nil)
    if seen == true then return 'yes' elseif seen == false then return 'no' end
    return 'unknown'
end

-- item = { id, quality, price, classID, subclassID, subclassName, equipLoc, effect, hasUseOrEquipSpell, isSetPiece };
-- nil si GetItemInfo aun no tiene los datos (reintentar con GET_ITEM_INFO_RECEIVED). Sin ubicacion no
-- se sabe si esta ligado: isBound queda en nil (ReadItem lo completa).
function Player.ReadLink(link)
    if link == nil or type(ns.API.GetItemInfo) ~= 'function' then return nil end
    local id
    if type(link) == 'number' then id = link
    elseif type(link) == 'string' then id = tonumber(link:match('item:(%d+)')) end
    if not id then return nil end
    local _, itemLink, quality, itemLevel, reqLevel, _, subclassName, _, equipLoc, _, price, classID, subclassID, _, _, setID = ns.API.GetItemInfo(link)
    if quality == nil then return nil end
    local effect = itemEffect(id)
    -- Sólo el efecto exacto de restauración acreditado por la build queda exceptuado.
    -- Un segundo prefijo de uso/equipar/proc o una lectura incompleta conserva la protección.
    local restorationOnly
    local food = ns.DB and ns.DB.rules and ns.DB.rules.food and ns.Data.food and ns.Data.food[id]
    local spellAPI = type(C_Item) == 'table' and C_Item.GetItemSpell or nil
    if type(spellAPI) ~= 'function' then spellAPI = ns.API.GetItemSpell end
    local restored = restorationState[id]
    if food and restored then
        restorationOnly = restored.value
    elseif food and classID == 0 and subclassID == 5 and type(spellAPI) == 'function' then
        local good, _, spell = pcall(spellAPI, id)
        if good and spell == food.spell then
            local texts, how = tooltipTexts(id)
            local count, onlyUse = 0, true
            for _, text in ipairs(texts or {}) do
                text = bare(text) or ''
                for _, prefix in ipairs(triggers()) do
                    if text:sub(1, #prefix) == prefix then
                        count = count + 1
                        if prefix ~= rawget(_G, 'ITEM_SPELL_TRIGGER_ONUSE') and prefix ~= 'Use:' and prefix ~= 'Uso:' then onlyUse = false end
                        break
                    end
                end
            end
            restorationOnly = how == 'complete' and onlyUse and count == 1 or nil
        end
        restorationState[id] = {value=restorationOnly}
    end
    return {
        id = id,
        link = type(link) == 'string' and link or (type(itemLink) == 'string' and itemLink or nil),
        quality = quality,
        itemLevel = type(itemLevel) == 'number' and itemLevel or nil,
        reqLevel = type(reqLevel) == 'number' and reqLevel or nil,
        price = price or 0,
        classID = classID,
        subclassID = subclassID,
        subclassName = subclassName,
        equipLoc = equipLoc,
        effect = effect,
        hasUseOrEquipSpell = effect ~= 'no', -- compatibilidad: true = con efecto o sin saberlo
        isSetPiece = setID ~= nil and setID ~= 0,
        restorationOnly = restorationOnly,
    }
end

-- true/false si el cliente confirma si el ejemplar de bag/slot esta ligado; nil si no se sabe.
-- Primero C_Item.IsBound(ItemLocation); si falta, falla o no responde un booleano, el isBound de
-- C_Container.GetContainerItemInfo (info ya leida).
local function boundAt(bag, slot, info)
    if type(C_Item) == 'table' and type(C_Item.IsBound) == 'function'
        and type(ItemLocation) == 'table' and type(ItemLocation.CreateFromBagAndSlot) == 'function' then
        local success, answer = pcall(function()
            return C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot))
        end)
        if success and (answer == true or answer == false) then return answer end
    end
    if type(info) == 'table' and (info.isBound == true or info.isBound == false) then return info.isBound end
    return nil
end

-- Como ReadLink, mas isBound (regla 8: equipo de otra clase da moneda solo si esta ligado).
function Player.ReadItem(bag, slot)
    local link, itemID, info
    if C_Container and type(C_Container.GetContainerItemInfo) == 'function' then
        info = C_Container.GetContainerItemInfo(bag, slot)
        if info then link, itemID = info.hyperlink, info.itemID end
    elseif type(GetContainerItemLink) == 'function' then
        link = GetContainerItemLink(bag, slot)
    end
    local target = link or itemID
    if not target then return nil end
    local item = Player.ReadLink(target)
    if item then
        item.isBound = boundAt(bag, slot, info)
        item.bag, item.slot = bag, slot
        if ns.DB and ns.DB.rules and ns.DB.rules.knownRecipe and item.classID == 9 then
            local key = bag .. ':' .. slot
            local state = knownState[key]
            if not state or state.id ~= item.id then
                local texts = tooltipTexts(item.id, bag, slot)
                local wanted = { ['Already known'] = true, ['Ya conocido'] = true }
                local global = rawget(_G, 'ITEM_SPELL_KNOWN')
                if type(global) == 'string' and global ~= '' then wanted[global] = true end
                state = {id=item.id}
                for _, text in ipairs(texts or {}) do
                    if wanted[bare(text) or ''] then state.known = true; break end
                end
                knownState[key] = state
            end
            item.knownRecipe = state.known
        end
        if item.classID == 6 then
            local equipped = Player.EquippedAmmo()
            item.equippedAmmo = equipped == nil or equipped == item.id
        end
    end
    return item
end

-- false = no hay munición equipada; nil = API ausente/fallida (se conserva).
function Player.EquippedAmmo()
    if type(GetInventoryItemID) == 'function' then
        local good, id = pcall(GetInventoryItemID, 'player', 0)
        if good then return id or false end
    elseif type(GetInventoryItemLink) == 'function' then
        local good, link = pcall(GetInventoryItemLink, 'player', 0)
        if good then return link and tonumber(link:match('item:(%d+)')) or false end
    end
    return nil -- sin API o con error: desconocido (nil explícito para tostring y comparaciones)
end

-- Inventario vivo, sólo mochila y bolsas del personaje; nunca banco ni cachés de alts.
function Player.BagStock(level, rules)
    local stock, signature = {}, {}
    if not (rules.food or rules.ammo) or type(level) ~= 'number' then return stock end
    local modern = type(C_Container) == 'table' and C_Container or nil
    local slots = modern and C_Container.GetContainerNumSlots or GetContainerNumSlots
    if type(slots) ~= 'function' then return stock end
    for bag = 0, (tonumber(rawget(_G, 'NUM_BAG_SLOTS')) or 4) do
        local good, count = pcall(slots, bag)
        if good and type(count) == 'number' then
            for slot = 1, count do
                local id
                if modern and type(modern.GetContainerItemInfo) == 'function' then
                    local info = modern.GetContainerItemInfo(bag, slot)
                    if info then id = info.itemID or (info.hyperlink and tonumber(info.hyperlink:match('item:(%d+)'))) end
                elseif type(GetContainerItemLink) == 'function' then
                    local link = GetContainerItemLink(bag, slot)
                    id = link and tonumber(link:match('item:(%d+)'))
                end
                local candidate = id and ((rules.food and ns.Data.food and ns.Data.food[id])
                    or (rules.ammo and ns.Data.ammo and ns.Data.ammo[id]))
                local item = candidate and Player.ReadItem(bag, slot)
                if item then
                    local food = rules.food and ns.Data.food and ns.Data.food[item.id]
                    local ammo = rules.ammo and ns.Data.ammo and ns.Data.ammo[item.id]
                    local data = food or ammo
                    if data then
                        local usable = level >= data.reqLevel and not item.isSetPiece
                            and (item.effect == 'no' or (food and item.restorationOnly == true))
                        if ammo and Player.EquippedAmmo() == nil then usable = false end
                        stock[#stock + 1] = {id=item.id, bag=bag, slot=slot, usable=usable == true}
                        signature[#signature + 1] = bag .. ':' .. slot .. ':' .. item.id .. ':' .. tostring(usable)
                    end
                end
            end
        end
    end
    signature[#signature + 1] = tostring(Player.EquippedAmmo())
    stock.signature = table.concat(signature, ',')
    return stock
end

-- ---------------------------------------------------------------------------
-- Invalidacion
-- ---------------------------------------------------------------------------

local frame = CreateFrame('Frame')
-- Todo evento que pueda cambiar el contexto lo ensucia; la reconstruccion es perezosa. Un
-- evento que el cliente no conozca no debe romper la carga.
for _, event in ipairs({ 'QUEST_LOG_UPDATE', 'SKILL_LINES_CHANGED', 'QUEST_ACCEPTED', 'QUEST_REMOVED',
    'QUEST_TURNED_IN', 'QUEST_DATA_LOAD_RESULT', 'PLAYER_LEVEL_UP', 'PLAYER_REGEN_ENABLED', 'BAG_UPDATE_DELAYED',
    'SPELLS_CHANGED', 'LEARNED_SPELL_IN_TAB', 'PLAYER_EQUIPMENT_CHANGED', 'UNIT_INVENTORY_CHANGED',
    'PLAYER_TALENT_UPDATE', 'CHARACTER_POINTS_CHANGED', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_LOGIN',
    'PLAYER_ENTERING_WORLD', 'TRAIT_CONFIG_UPDATED', 'TRAIT_CONFIG_LIST_UPDATED' }) do
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

pcall(frame.RegisterEvent, frame, 'TOOLTIP_DATA_UPDATE')
pcall(frame.RegisterEvent, frame, 'GET_ITEM_INFO_RECEIVED')

frame:SetScript('OnEvent', function(_, event, arg1)
    local rules = ns.DB and ns.DB.rules
    local optionalEnabled = rules and (rules.food or rules.ammo or rules.knownRecipe)
    -- Los datos pendientes también llegan al expandir/plegar el diario: no perder el reintento.
    if event == 'TOOLTIP_DATA_UPDATE' or event == 'GET_ITEM_INFO_RECEIVED' then
        local relevant
        if event == 'TOOLTIP_DATA_UPDATE' then relevant = onTooltipDataUpdate(arg1) else relevant = onItemInfo(arg1) end
        -- Tooltips ajenos (otra instancia, ningún ítem pendiente) no reescanean las bolsas.
        if not scanning and event == 'GET_ITEM_INFO_RECEIVED' and cache and cache.equippedLevelPending then
            -- Los niveles equipados pueden haber quedado sin datos en el contexto anterior.
            markDirty()
            scheduleCheck()
        end
        if relevant and optionalEnabled and not scanning then
            optionalRevision = optionalRevision + 1
            markDirty()
            scheduleCheck()
        end
        return
    end
    if scanning then return end
    local optionalEvent = event == 'BAG_UPDATE_DELAYED' or event == 'SPELLS_CHANGED'
        or event == 'LEARNED_SPELL_IN_TAB' or event == 'PLAYER_EQUIPMENT_CHANGED'
        or event == 'UNIT_INVENTORY_CHANGED'
    if optionalEvent then
        local enabled = optionalEnabled or event == 'PLAYER_EQUIPMENT_CHANGED' or event == 'UNIT_INVENTORY_CHANGED'
        if not enabled or (event == 'UNIT_INVENTORY_CHANGED' and arg1 ~= 'player') then return end
        optionalRevision = optionalRevision + 1
    end
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
