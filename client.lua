local QBCore = exports['qb-core']:GetCoreObject()

local placingObject = false
local isPlacing = false
local object = nil
local baseZ = 0.0
local heightOffset = 0.0
local pendingSnowman = nil -- snowman pendente aguardando ID do servidor

---------------------------------------------------------------------
-- 🔹 Carregar idioma
---------------------------------------------------------------------
local function LoadLocale()
    local localePath = ('locales/%s.json'):format(Config.Locale)
    local file = LoadResourceFile(GetCurrentResourceName(), localePath)
    if file then
        Lang = json.decode(file)
        print(("[Christmas] Idioma carregado: %s"):format(Config.Locale))
    else
        print(("[Christmas] ERRO: Arquivo de idioma '%s' não encontrado!"):format(localePath))
    end
end

LoadLocale()

-- Função de tradução
function L(key, ...)
    if not Lang then return key end
    local text = Lang[key]

    if not text then
        return key
    end

    if select('#', ...) > 0 then
        return string.format(text, ...)
    end

    return text
end



local SnowmenObjects = {}

-- Função para spawn de snowman
local function spawnSnowman(coords, model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local obj = CreateObject(hash, coords.x, coords.y, coords.z, true, true, true)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    return obj
end

-- Inicializa semente aleatória
math.randomseed(GetGameTimer() + PlayerId())

-- Função para pegar modelo aleatório
local function GetRandomSnowmanModel()
    local models = Config.SnowmanModel
    local index = math.random(1, #models)
    return models[index]
end

-- Comando para receber snowballs
RegisterCommand("snowball", function()
    TriggerServerEvent('pinguim_xmas:server:GetSnowballItem')
end, false)

-- Função animação de pegar snowball
local function PegarSnowball()
    local ped = PlayerPedId()
    local animDict = "anim@mp_snowball"
    local animName = "pickup_snowball"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 1500, 0, 0, false, false, false)
    Citizen.Wait(1500)
    ClearPedTasks(ped)
end

-- Cooldown para pegar snowball
local canUse = true
local cooldownTimer = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if placingObject then
            DisableControlAction(0, 38, true) -- bloqueia E
        else
            if IsDisabledControlJustReleased(0, 38) then
                if not canUse then
                    Notify(L("wait_seconds", math.ceil(cooldownTimer)), "error")
                else
                    canUse = false
                    cooldownTimer = Config.Cooldown

                    Notify(L("item_used"), "success")
                    TriggerServerEvent('pinguim_xmas:server:GetSnowballItem')
                    TriggerEvent('pinguim_xmas:client:UsarSnowball')
                    PegarSnowball()

                    Citizen.CreateThread(function()
                        while cooldownTimer > 0 do
                            Citizen.Wait(1000)
                            cooldownTimer = cooldownTimer - 1
                        end
                        canUse = true
                        Notify(L("cooldown_done"), "success")
                    end)
                end
            end
        end
    end
end)

-- Função universal de notificação
function Notify(msg, tipo)
    tipo = tipo or "info"

    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg, tipo)
    elseif exports.qbx_core and exports.qbx_core.Notify then
        exports.qbx_core:Notify(msg, tipo)
    else
        print("[Snowball] " .. msg)
    end
end


-- Função para remover o snowman mais próximo
local function RemoveClosestSnowman()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local closestObj, closestId, closestDist = nil, nil, 5.0

    for id, obj in pairs(SnowmenObjects) do
        if DoesEntityExist(obj) then
            local dist = #(pos - GetEntityCoords(obj))
            if dist < closestDist then
                closestDist = dist
                closestObj = obj
                closestId = id
            end
        end
    end

    if closestObj then
        DeleteObject(closestObj)
        if closestId then SnowmenObjects[closestId] = nil end
        return closestId
    end
    return nil
end

-- Função para começar a colocar snowman
local function startPlacingObject(itemType)
    if placingObject then return end
    placingObject = true

    local model = (itemType == "xmastree") and Config.TreeModel[1] or GetRandomSnowmanModel()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)

    lib.showTextUI(L("place_help"))
    SetNuiFocus(false, false)

    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    object = CreateObject(hash, pos.x, pos.y, pos.z, true, true, false)
    SetEntityCollision(object, false, false)
    SetEntityAlpha(object, 150, false)
    FreezeEntityPosition(object, true)
    SetEntityDynamic(object, false)

    baseZ = pos.z
    heightOffset = 0.0
    isPlacing = true
    local moveSpeed = 0.03
    local rotateSpeed = 1.0

    Citizen.CreateThread(function()
        while isPlacing do
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 23, true)

            if not DoesEntityExist(object) then
                isPlacing = false
                placingObject = false
                lib.hideTextUI()
                return
            end

            local objCoords = GetEntityCoords(object)

            -- ARROWS MOVE
            if IsControlPressed(0, 172) then objCoords = objCoords + vector3(0.0, moveSpeed, 0.0) end
            if IsControlPressed(0, 173) then objCoords = objCoords - vector3(0.0, moveSpeed, 0.0) end
            if IsControlPressed(0, 174) then objCoords = objCoords - vector3(moveSpeed, 0.0, 0.0) end
            if IsControlPressed(0, 175) then objCoords = objCoords + vector3(moveSpeed, 0.0, 0.0) end

            -- SCROLL HEIGHT
            if IsControlJustPressed(0, 15) then heightOffset = heightOffset + 0.05
            elseif IsControlJustPressed(0, 14) then heightOffset = heightOffset - 0.05 end

            heightOffset = math.min(math.max(heightOffset, -1.0), 2.0)

            -- Q / R ROTATE
            local heading = GetEntityHeading(object)
            if IsControlPressed(0, 44) then SetEntityHeading(object, heading - rotateSpeed)
            elseif IsControlPressed(0, 45) then SetEntityHeading(object, heading + rotateSpeed) end

            -- APLICAR POSIÇÃO
            SetEntityCoordsNoOffset(object, objCoords.x, objCoords.y, baseZ + heightOffset, false, false, false)
            SetEntityCollision(object, false, true)
            FreezeEntityPosition(object, true)
            SetEntityNoCollisionEntity(PlayerPedId(), object, true)

            -- PLACE
            if IsControlJustPressed(0, 191) then -- ENTER
                isPlacing = false
                placingObject = false
                lib.hideTextUI()

                local ped = PlayerPedId()
                FreezeEntityPosition(object, true)
                SetEntityCollision(object, false, false)

                local targetPos = GetOffsetFromEntityInWorldCoords(object, 0.0, -1.0, 0.0)
                TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, 1.0, -1, GetEntityHeading(object), 0.5)

                Citizen.CreateThread(function()
                    local startTime = GetGameTimer()
                    local maxTime = 3000

                    while true do
                        Citizen.Wait(0)
                        DisableAllControlActions(0)
                        EnableControlAction(0, 1, true)
                        EnableControlAction(0, 2, true)

                        local pedCoords = GetEntityCoords(ped)
                        local dist = #(pedCoords - targetPos)

                        if dist <= 0.8 or (GetGameTimer() - startTime) >= maxTime then
                            ClearPedTasksImmediately(ped)
                            TaskStandStill(ped, 500)
                            TaskTurnPedToFaceEntity(ped, object, 500)
                            Citizen.Wait(500)

                            local animDict = "mini@repair"
                            local animName = "fixing_a_ped"

                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Citizen.Wait(10)
                            end

                            TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

                            local craftLabel = (itemType == "xmastree") and L("craft_tree") or L("craft_snowman")

                            local success = lib.progressBar({
                                duration = 3000,
                                label = craftLabel,
                                canCancel = true,
                                disable = { move = true, combat = true }
                            })

                            ClearPedTasks(ped)

                            if not success then
                                DeleteObject(object)
                                object = nil
                                pendingSnowman = nil
                                return
                            end

                            SetEntityAlpha(object, 255, false)
                            SetEntityCollision(object, true, true)

                            if itemType == "xmastree" then
                                FreezeEntityPosition(object, true)
                                SetEntityDynamic(object, false)
                            else
                                FreezeEntityPosition(object, false)
                                SetEntityDynamic(object, true)
                            end

                            pendingSnowman = object
                            TriggerServerEvent('pinguim_xmas:server:ConsumePlacedItem', itemType)
                            TriggerServerEvent('my_snowman:saveSnowman', GetEntityCoords(object), model)

                            break
                        end
                    end
                end) -- Fecha thread interna
            end -- Fecha if ENTER

            -- CANCEL
            if IsControlJustPressed(0, 177) then -- BACKSPACE
                DeleteObject(object)
                object = nil
                isPlacing = false
                placingObject = false
                lib.hideTextUI()
            end

            Wait(0)
        end -- Fecha while isPlacing
    end) -- Fecha thread principal
end


-- Comando remover snowman próximo
RegisterCommand("removechristmas", function()
    local id = RemoveClosestSnowman()

    if id then
        local ped = PlayerPedId()
        local animDict = "mini@repair"  -- pode trocar para outra anim
        local animName = "fixing_a_ped"   -- animação temporária de pegar snowball

        -- Carregar animação
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end

        -- Tocar animação
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 2000, 0, 0, false, false, false)

        -- Espera duração da animação antes de remover
        Citizen.SetTimeout(2000, function()
            TriggerServerEvent('my_snowman:removeSnowman', id)
            Notify(L("remove_success"), "success")
        end)
    else
        Notify(L("remove_none"), "error")
    end
end)

-- Eventos
RegisterNetEvent('pinguim_xmas:client:StartPlaceObject', function(itemType)
    startPlacingObject(itemType)
end)


RegisterNetEvent('my_snowman:client:spawn', function(coords, model, id)
    if SnowmenObjects[id] then return end

    if pendingSnowman then
        -- Reutiliza snowman que já existe localmente
        SnowmenObjects[id] = pendingSnowman
        pendingSnowman = nil
        return
    end

    local obj = spawnSnowman(coords, model)
    SnowmenObjects[id] = obj
end)

RegisterNetEvent('my_snowman:client:remove', function(id)
    if SnowmenObjects[id] and DoesEntityExist(SnowmenObjects[id]) then
        DeleteObject(SnowmenObjects[id])
        SnowmenObjects[id] = nil
    end
end)



local shopConfig = {
    coords = vec3(-946.06, -787.79, 16.00),
    heading = 69.39,
    pedModel = 'Santaclaus',
    shopName = L("shop_name"),

    blip = {
        enabled = true,
        sprite = 89,      -- ícone de loja
        color = 1,        -- verde
        scale = 0.8,
        label = 'Santa Claus'
    }
}

CreateThread(function()
    RequestModel(shopConfig.pedModel)
    while not HasModelLoaded(shopConfig.pedModel) do
        Wait(0)
    end

    local ped = CreatePed(
        0,
        shopConfig.pedModel,
        shopConfig.coords.x,
        shopConfig.coords.y,
        shopConfig.coords.z - 1.0,
        shopConfig.heading,
        false,
        true
    )

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    -- Request da animação
    RequestAnimDict("switch@michael@goodbye_to_jimmy")
    while not HasAnimDictLoaded("switch@michael@goodbye_to_jimmy") do
        Wait(0)
    end

    -- Fazer o ped executar a animação
    TaskPlayAnim(
        ped,
        "switch@michael@goodbye_to_jimmy",
        "base",   -- nome da animação dentro do dict
        8.0,      -- velocidade de reprodução
        -8.0,     -- velocidade de reprodução inversa
        -1,       -- duração (-1 = loop infinito)
        1,        -- flag (1 = loop, 0 = play once)
        0,        -- playback rate (normal = 0)
        false,
        false,
        false
    )
end)

CreateThread(function()
    if not shopConfig.blip.enabled then return end

    local blip = AddBlipForCoord(shopConfig.coords)

    SetBlipSprite(blip, shopConfig.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, shopConfig.blip.scale)
    SetBlipColour(blip, shopConfig.blip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(shopConfig.blip.label)
    EndTextCommandSetBlipName(blip)
end)



exports.ox_target:addBoxZone({
    coords = vec3(-946.06, -787.79, 15.92),
    size = vec3(1.5, 1.5, 2.0),
    rotation = 0.0,
    options = {
        {
            name = 'loja_dinamica',
            icon = 'fa-solid fa-shop',
            label = L("shop_open"),
            onSelect = function()
                exports.ox_inventory:openInventory('shop', { type = 'ChristmasShop' })
            end
        }
    }
})


local ragdollCooldown = {}

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end

    local victim = args[1]
    local weaponHash = args[7]

    if weaponHash ~= GetHashKey('WEAPON_SNOWBALL') then return end
    if not IsEntityAPed(victim) or IsEntityDead(victim) then return end

    local netId = NetworkGetNetworkIdFromEntity(victim)
    local now = GetGameTimer()

    if ragdollCooldown[netId] and (now - ragdollCooldown[netId]) < 2000 then
        return
    end

    ragdollCooldown[netId] = now

    SetPedToRagdoll(victim, 1500, 2000, 0, false, false, false)
end)


CreateThread(function()

    -- coordenadas onde queres que o veado apareça
    local deerCoords = vec4(-946.31, -785.65, 15.92, 108.58) -- x, y, z, heading

    -- hash do ped
    local deerModel = GetHashKey("A_C_Deer")

    -- carrega o model
    RequestModel(deerModel)
    while not HasModelLoaded(deerModel) do Wait(0) end

    -- cria o ped
    local deerPed = CreatePed(
        28,             -- tipo animal
        deerModel,
        deerCoords.x,
        deerCoords.y,
        deerCoords.z - 1.0,  -- ajuste para não aparecer debaixo do chão
        deerCoords.w,
        false,
        true
    )

    -- fixa o veado no local
    FreezeEntityPosition(deerPed, true)
    SetEntityInvincible(deerPed, true)
    SetBlockingOfNonTemporaryEvents(deerPed, true)

    -- garante que é visível
    SetEntityVisible(deerPed, true)
    SetEntityAlpha(deerPed, 255, false)

    print("^2[DEBUG] Veado criado com sucesso^7")
end)
