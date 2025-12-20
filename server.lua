local QBCore = exports['qb-core']:GetCoreObject()

local SnowmenCache = {}

-- Load da DB quando o resource inicia
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    exports.oxmysql:execute('SELECT * FROM snowmen', {}, function(result)
        SnowmenCache = result
        print('[Snowman] ' .. #SnowmenCache .. ' snowmans loaded')
    end)
end)

-- Enviar snowmans ao jogador quando entra
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source

    for _, v in ipairs(SnowmenCache) do
        TriggerClientEvent(
            'my_snowman:client:spawn',
            src,
            vector3(v.x, v.y, v.z),
            v.model,
            v.id
        )
    end
end)

-- Criar snowman
RegisterNetEvent('my_snowman:saveSnowman', function(coords, model)
    exports.oxmysql:insert(
        'INSERT INTO snowmen (model, x, y, z) VALUES (?, ?, ?, ?)',
        { model, coords.x, coords.y, coords.z },
        function(id)
            local data = {
                id = id,
                model = model,
                x = coords.x,
                y = coords.y,
                z = coords.z
            }

            table.insert(SnowmenCache, data)

            TriggerClientEvent('my_snowman:client:spawn', -1, coords, model, id)
        end
    )
end)

-- Remover snowman
RegisterNetEvent('my_snowman:removeSnowman', function(id)
    exports.oxmysql:execute('DELETE FROM snowmen WHERE id = ?', { id })

    for i, v in ipairs(SnowmenCache) do
        if v.id == id then
            table.remove(SnowmenCache, i)
            break
        end
    end

    -- Remove do jogo para todos os clientes
    TriggerClientEvent('my_snowman:client:remove', -1, id)
end)

local SnowballItem = "weapon_snowball"
local InventoryConfig = "ox"

RegisterNetEvent('pinguim_xmas:server:GetSnowballItem', function()
    local src = source

    if InventoryConfig == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer then
            xPlayer.Functions.AddItem(SnowballItem, Config.SnowballAmount)
            TriggerClientEvent('pinguim_xmas:client:NotifySnowball', src)
        else
            print("[Snowball] QBCore: jogador não encontrado")
        end

    elseif InventoryConfig == "ox" then
        -- No servidor, para OX Inventory você deve usar AddItem direto
        local added = exports.ox_inventory:AddItem(src, SnowballItem, Config.SnowballAmount)
        if added then
            TriggerClientEvent('pinguim_xmas:client:NotifySnowball', src)
        else
            print("[Snowball] OX Inventory: erro ao adicionar item")
        end
    end
end)


RegisterNetEvent('pinguim_xmas:server:CraftSnowman', function()
    local src = source
    local inv = exports.ox_inventory

    local snowballs = inv:GetItem(src, 'weapon_snowball', false, true) or {count = 0}
    local sticks = inv:GetItem(src, 'stick', false, true) or {count = 0}
    local carrots = inv:GetItem(src, 'carrot', false, true) or {count = 0}

    if snowballs.count >= 5 and sticks.count >= 2 and carrots.count >= 1 then
        inv:RemoveItem(src, 'weapon_snowball', 5)
        inv:RemoveItem(src, 'stick', 2)
        inv:RemoveItem(src, 'carrot', 1)
        inv:AddItem(src, 'snowman', 1)
        TriggerClientEvent('pinguim_xmas:client:Notify', src, true, "Você craftou um boneco de neve!")
    else
        TriggerClientEvent('pinguim_xmas:client:Notify', src, false, "Você não tem os itens necessários!")
    end
end)


RegisterNetEvent('pinguim_xmas:server:ConsumePlacedItem', function(itemType)
    local src = source

    if itemType == "xmastree" then
        exports.ox_inventory:RemoveItem(src, 'xmastree', 1)
    else
        exports.ox_inventory:RemoveItem(src, 'snowman', 1)
    end
end)


-- server.lua
exports.qbx_core:CreateUseableItem("snowman", function(source, item)
    TriggerClientEvent('pinguim_xmas:client:StartPlaceObject', source, "snowman")
end)

exports.qbx_core:CreateUseableItem("xmastree", function(source, item)
    TriggerClientEvent('pinguim_xmas:client:StartPlaceObject', source, "xmastree")
end)




exports.ox_inventory:RegisterShop('ChristmasShop', {
    name = 'Christmas Shop',
    inventory = {
        { name = 'snowman', price = 100 },
        { name = 'xmastree', price = 100 },
        { name = 'WEAPON_CANDYCANE', price = 100 },
    },
})


CreateThread(function()
    Wait(5000) -- espera o servidor estabilizar
    TriggerClientEvent('santa:spawnPeds', -1)
end)
