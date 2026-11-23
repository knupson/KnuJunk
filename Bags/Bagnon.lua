local _, ns = ...

-- Bagnon y Bagnonium por el hook de actualizacion: hooksecurefunc(<addon>.Item, 'Update', ...). Contrato leido en Bagnon 12.1.11 (BagBrother, compartido por ambos).
-- Solo 'inventory' y, con el banco vivo, 'bank' con IsCached() == false; identidad = button.info. Bagnonium se asume igual (sin verificar en el juego).
local Common = ns.Bags.Common
local Adapters = {}
ns.BagnonAdapters = Adapters

local WINDOW, BANK_WINDOW = 'inventory', 'bank'

local function newAdapter(folder)
    local adapter = {}
    local tracker = Common.NewTracker(folder)
    local hooked = false

    local function locate(button)
        if type(button) ~= 'table' then return nil end
        local window = button.frame
        if type(window) ~= 'table' then return nil end
        if window.id == BANK_WINDOW then
            -- Banco: solo vivo (ns.Bank) y si el propio boton dice que no es cache (bank.lua
            -- l.93-102: IsCached(bag) = no estar en el banco, dueno offline o banco no visible).
            if not ns.Bank.IsLive() or Common.Call(button, 'IsCached') ~= false then return nil end
            if Common.NonCarried(button, true) then return nil end
            local bag = Common.Call(button, 'GetBag')
            if not ns.Bank.IsBankBag(bag) then return nil end
            return bag, Common.Call(button, 'GetID')
        end
        if window.id ~= WINDOW then return nil end
        if Common.NonCarried(button) then return nil end
        return Common.Call(button, 'GetBag'), Common.Call(button, 'GetID')
    end

    local reader = Common.ExposedReader(locate)

    local function revalidate(button) return tracker:Read(button) end

    -- Corre despues de Item:Update: button.info ya es lo que Bagnon acaba de dibujar.
    local function onUpdate(button)
        pcall(function()
            local bag, slot = locate(button)
            if type(bag) ~= 'number' or type(slot) ~= 'number' then return tracker:Release(button) end
            tracker:Apply(button, reader)
        end)
    end

    -- true cuando el hook esta puesto (idempotente).
    function adapter.Install()
        if hooked then return true end
        local addon = rawget(_G, folder)
        local item = type(addon) == 'table' and addon.Item
        if type(item) ~= 'table' or type(item.Update) ~= 'function' then return false end
        hooked = pcall(hooksecurefunc, item, 'Update', onUpdate)
        return hooked
    end

    function adapter.Refresh() tracker:Refresh() end

    function adapter.ResetState() hooked = false end
    Common.OnReset(adapter.ResetState)

    ns.Bags.Register(folder, { addon = folder, install = adapter.Install, refresh = adapter.Refresh,
        revalidate = revalidate, bank = true })
    Adapters[folder] = adapter
end

newAdapter('Bagnon')
newAdapter('Bagnonium')
