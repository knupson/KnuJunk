local _, ns = ...

-- Bagnon y Bagnonium por el hook de actualizacion: hooksecurefunc(<addon>.Item, 'Update', ...).
-- Contrato VERIFICADO contra el codigo fuente de Bagnon 12.1.11 (BagBrother, compartido por Bagnon y
-- Bagnonium; cada uno carga su copia bajo un global con el nombre de su carpeta, p. ej. _G.Bagnon):
--   * core/classes/base.lua l.20: cada NewClass publica la clase en el addon (Addon.Item = clase Item)
--     y libs/WildAddon-1.1 l.85 deja el addon en _G[<carpeta>]: de ahi _G.Bagnon.Item.
--   * core/classes/item.lua l.123-141: Item:Update(info) fija self.info (con itemID/hyperlink del
--     item DIBUJADO) antes de dibujar; l.306-312: GetBag() devuelve self.bag y el slot es GetID().
--   * core/classes/containerItem.lua l.62-63: ContainerItem:Update llama Super(Item):Update, que
--     Poncho resuelve en la clase al momento de la llamada (libs/Poncho-2.0 l.28-34): un hook sobre
--     Item.Update alcanza a los botones que ya existen. Los de hermandad y vault (frames/guild/item.lua
--     l.7, frames/vault/item.lua l.7) heredan el mismo Update.
--   * core/classes/parented.lua l.9-12: button.frame es la ventana; core/api/frames.lua l.8-13: sus
--     ids son 'inventory', 'bank', 'guild' y 'vault'. La hermandad contesta GetBag() con el numero de
--     pestana, que pasaria por una bolsa portada: por eso solo se aceptan 'inventory' y, con el banco
--     VIVO (ns.Bank), 'bank' con bolsas del banco (ns.Bank.IsBankBag) y Item:IsCached() == false
--     (frames/bank/bank.lua l.93-102: cacheado si no se esta en el banco o el dueno es otro personaje).
--   * containerItem.lua l.132-134 y frameBase.lua l.222-224: IsCached() = owner.offline (otro
--     personaje); Common.NonCarried lo consulta en el boton y en sus ancestros.
-- Identidad: la EXPUESTA, button.info (itemID/hyperlink): nunca el slot vivo. Sin info o con info
-- que se contradice o no coincide con el slot, sin marca (Common.ExposedReader).
-- Bagnonium no esta instalado aqui: se asume su misma forma (mismo BagBrother); SIN VERIFICAR EN EL
-- JUEGO. Referencia leida (competencia/): magic-eraser Tint-Junk.lua l.291-310.
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
            -- Banco: solo vivo (ns.Bank) y si el propio boton dice que NO es cache (bank.lua
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

    -- Corre DESPUES de Item:Update: button.info ya es lo que Bagnon acaba de dibujar.
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
