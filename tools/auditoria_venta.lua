-- Ejecutar desde la raíz: luajit tools/auditoria_venta.lua entrada.csv salida.csv [ambos]
-- Entrada normalizada por auditoria_venta.py; CSV RFC 4180, incluidos nombres multilínea.
local input, output, binding = assert(arg[1], 'Falta entrada.csv'), assert(arg[2], 'Falta salida.csv'), arg[3]
local ns = {}
_G.ns = ns
dofile('tests/wow_stub.lua')
for _, path in ipairs({ 'Libs/KnuLib/LibStub/LibStub.lua', 'Libs/KnuLib/KnuLib.lua', 'Locales/Locales.lua', 'Core.lua' }) do
    assert(loadfile(path))('KnuJunk', ns)
end
-- Sigue el orden de Data del addon, sin cargar UI, integraciones ni addons opcionales.
for line in io.lines('KnuJunk.toc') do
    if line:match('^Data[\\/]') and line:match('%.lua$') then
        assert(loadfile((line:gsub('\\', '/'):gsub('\r$', ''))))('KnuJunk', ns)
    end
end
assert(loadfile('Classify.lua'))('KnuJunk', ns)
FAKE.Fire('ADDON_LOADED', 'KnuJunk')
Auctionator, GQ = nil, nil

local function readCSV(path)
    local file = assert(io.open(path, 'rb'))
    local text = file:read('*a'); file:close()
    text = text:gsub('^\239\187\191', '')
    local rows, row, field, quoted, i = {}, {}, {}, false, 1
    local function cell() row[#row + 1] = table.concat(field); field = {} end
    local function record() cell(); rows[#rows + 1] = row; row = {} end
    while i <= #text do
        local c = text:sub(i, i)
        if c == '"' then
            if quoted and text:sub(i + 1, i + 1) == '"' then field[#field + 1] = '"'; i = i + 1
            else quoted = not quoted end
        elseif not quoted and c == ',' then cell()
        elseif not quoted and (c == '\n' or c == '\r') then
            record()
            if c == '\r' and text:sub(i + 1, i + 1) == '\n' then i = i + 1 end
        else field[#field + 1] = c end
        i = i + 1
    end
    assert(not quoted, 'CSV con comillas sin cerrar')
    if #field > 0 or #row > 0 then record() end
    return rows
end
local function csv(value)
    value = tostring(value == nil and '' or value)
    if value:find('[,"\r\n]') then return '"' .. value:gsub('"', '""') .. '"' end
    return value
end
local function kinds(reasons)
    local values = {}
    for _, reason in ipairs(reasons or {}) do values[#values + 1] = reason.kind end
    return table.concat(values, ';')
end
local function winner(result, item)
    if (result.mark == 'coin' or result.mark == 'trash') and item.quality == 0 then
        for i, reason in ipairs(result.reasons) do if reason.kind == 'gray' then return 'gray', i end end
    end
    return result.reasons[1] and result.reasons[1].kind or (result.pending and 'pending' or ''), 1
end
local rows = readCSV(input)
local header = table.remove(rows, 1)
local out = assert(io.open(output, 'wb'))
out:write('id,class,subclass,quality,price,context,mark,winner_reason,other_reasons\n')
local equippedOutput = output:gsub('%.csv$', '') .. '_equipada.csv'
local outEquipped = assert(io.open(equippedOutput, 'wb'))
outEquipped:write('id,class,subclass,quality,price,context,mark,winner_reason\n')
local classes = { 'WARRIOR', 'PALADIN', 'HUNTER', 'ROGUE', 'PRIEST', 'SHAMAN', 'MAGE', 'WARLOCK', 'DRUID' }
local equippedByTier = {}
for tier = 1, 4 do
    equippedByTier[tier] = { [1] = tier, [3] = tier, [5] = tier, [6] = tier, [7] = tier, [8] = tier, [9] = tier, [10] = tier }
end
local bestArmor = {
    WARRIOR = { [30] = 3, [60] = 4 }, PALADIN = { [30] = 3, [60] = 4 },
    HUNTER = { [30] = 2, [60] = 3 }, SHAMAN = { [30] = 2, [60] = 3 },
    ROGUE = { [30] = 2, [60] = 2 }, DRUID = { [30] = 2, [60] = 2 },
    PRIEST = { [30] = 1, [60] = 1 }, MAGE = { [30] = 1, [60] = 1 }, WARLOCK = { [30] = 1, [60] = 1 },
}
local count = 0
for _, row in ipairs(rows) do
    local r = {}
    for i, name in ipairs(header) do r[name] = row[i] end
    local item = { id = assert(tonumber(r.id)), quality = tonumber(r.quality), classID = tonumber(r.classID),
        subclassID = tonumber(r.subclassID), price = tonumber(r.price), reqLevel = tonumber(r.reqLevel),
        equipLoc = r.equipLoc, isSetPiece = r.isSetPiece == '1', effect = r.effect,
        hasUseSpell = r.hasUseSpell == '1', hasEquipSpell = r.hasEquipSpell == '1',
        openable = r.openable == '1' or (ns.Data.openables and ns.Data.openables[tonumber(r.id)] == true) or false }
    item.hasUseOrEquipSpell = item.hasUseSpell or item.hasEquipSpell
    -- StartQuestID completo, sin depender de que Data/Starters.lua tenga esa fila.
    if tonumber(r.startQuestID) and tonumber(r.startQuestID) > 0 then ns.Data.starters[item.id] = tonumber(r.startQuestID) end
    local gear = item.classID == 2 or item.classID == 4
    local passes = binding == 'ambos' and gear and 2 or 1
    for pass = 1, passes do
        item.isBound = gear and pass == 1 or false
        for _, class in ipairs(classes) do
            for _, level in ipairs({ 10, 30, 60 }) do
                local ctx = { class = class, level = level, professions = {}, overrides = {},
                    rules = { sellUnruled = true, armorBelow = true, food = false, ammo = false, knownRecipe = false, gearNotRanked = true },
                    questItemsInLog = {}, questLogIncomplete = false,
                    questInLog = function() return false end, isQuestDone = function() return false end }
                local result = ns.Classify(item, ctx)
                local winning, winningIndex = winner(result, item)
                local secondary = {}
                for i, reason in ipairs(result.reasons) do if i ~= winningIndex then secondary[#secondary + 1] = reason end end
                for _, reason in ipairs(result.otherReasons or {}) do secondary[#secondary + 1] = reason end
                local ctxName = class .. ':' .. level .. ':' .. (item.isBound and 'ligado' or 'libre')
                local values = { item.id, item.classID, item.subclassID, item.quality or '', item.price or '',
                    ctxName, result.mark or 'pending',
                    winning, kinds(secondary) }
                for i, value in ipairs(values) do values[i] = csv(value) end
                out:write(table.concat(values, ','), '\n')
                if item.classID == 4 and level ~= 10 then
                    ctx.equippedArmor = equippedByTier[bestArmor[class][level]]
                    local eqResult = ns.Classify(item, ctx, false)
                    local eqWinning = winner(eqResult, item)
                    local eqValues = { item.id, item.classID, item.subclassID, item.quality or '', item.price or '',
                        ctxName, eqResult.mark or 'pending', eqWinning }
                    for i, value in ipairs(eqValues) do eqValues[i] = csv(value) end
                    outEquipped:write(table.concat(eqValues, ','), '\n')
                end
                count = count + 1
            end
        end
    end
end
out:close()
outEquipped:close()
print(('Auditoría: %d ítems, %d contextos evaluados'):format(#rows, count))
