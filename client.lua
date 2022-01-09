local onJob = false
local npcSpawned = false
local notified = false
local distancepayment = {}


Citizen.CreateThread(function()
    blip = AddBlipForCoord(929.0531, -1256.4288, 25.4806)
    SetBlipSprite(blip, 67)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 4)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Logistics")
    EndTextCommandSetBlipName(blip)    
    while true do
        Citizen.Wait(1000)
            local npccoords = vector3(929.0531, -1256.4288, 24.4806)
            local pedCoords = GetEntityCoords(PlayerPedId()) 
            local dst = #(npccoords - pedCoords)
            if dst < 200 and npcSpawned == false then
                TriggerEvent('gb-logistics:spawnNPC',npccoords,29.3685)
                npcSpawned = true
            end
            if dst >= 201  then
                npcSpawned = false
                DeleteEntity(NPC)
            end

    end
end)


RegisterNetEvent('gb-logistics:spawnNPC')
AddEventHandler('gb-logistics:spawnNPC',function(coords,heading)
    local hash = GetHashKey('cs_joeminuteman')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    NPC = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    SetModelAsNoLongerNeeded(hash)
    TaskStartScenarioInPlace(NPC,'WORLD_HUMAN_CLIPBOARD_FACILITY')
    exports['qtarget']:AddEntityZone('NPCLOGISTICS', NPC, {
            name="NPC",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = 'gb-logistics:getJob',
                    icon = "fas fa-clipboard",
                    label = "Start Shift",
                    },                                         
                    {
                    event = 'gb-logistics:endJob',
                    icon = "fas fa-clipboard",
                    label = "End Shift",
                    }, 
                },
                    job = {"all"},
                    distance = 2.5
                })      
end)

RegisterNetEvent('gb-logistics:getJob',function()
    if onJob then
        exports['swt_notifications']:Warning('Job','Je bent al bezig met een job','top',2500,true)
    else
    local hash = 'benson'
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
        if ESX.Game.IsSpawnPointClear(vector3(925.1420, -1242.2168, 25.4946), 10) then
            vehicle = CreateVehicle(hash,925.1420, -1242.2168, 25.4946,34.1494,true,false)
            boxobject = CreateObject(300547451, 925.1420, -1242.2168, 26.4946, true, false)
                exports.qtarget:AddTargetEntity(boxobject, {
                    options = {
                        {
                            event = "gb-logistics:box",
                            icon = "fas fa-box-open",
                            label = "Doos pakken",
                            num = 1
                        },
                    },
                    distance = 2
                })
            
            AttachEntityToEntity(boxobject, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.0 + 0.0, -1.5 + -0.85, 0.0 + 0.95, 0, 0, 0, false, false, true, false, 0, true)
            exports['swt_notifications']:Caption('Job geaccepteerd',"Ga naar de bezorgplaats",'top',5000,'blue-10','grey-1',true)
            StartDelivery()

        else
            exports['swt_notifications']:Warning('voertuig','Wacht tot het gebied vrij is om een voertuig te spawnen','top',2500,true)
        end
    end
end)


function EndDelivery(payment)
    TriggerServerEvent('luke_maildelivery:Payment', payment)

    TriggerEvent('nh-context:sendMenu', {
        {
            id = 0,
            header = 'Job Complete',
            txt = '',
        },
        {
            id = 1,
            header = 'Continue Working',
            txt = 'Get another delivery location',
            params = {
                event = 'luke_maildelivery:EndDeliveryHandle',
                args = true
            }
        },
        {
            id = 2,
            header = 'Return To Depot',
            txt = 'Return back to the depot and store the vehicle',
            params = {
                event = 'luke_maildelivery:EndDeliveryHandle',
                args = false
            }
        }
    })
    exports.qtarget:RemoveTargetEntity(boxobject, {
        'gb-logisticsbox'
    })
end
--[[
RegisterServerEvent('gb-logisticspaymenttable')
AddEventHandler("gb-logisticspaymenttable", function(x)
    table.insert(distancepayment, source)
end)]]


function StartDelivery(DeliveryLocations)
    Onjob = true
    local randomDelivery = Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]
    --[[
    local pedcoords = GetEntityCoords(PlayerPedId())
    local dist = #(pedcoords - randomDelivery)
    table.insert(distancepayment, 1, dist)]]

    deliveryArea = CircleZone:Create(
        vector3(randomDelivery.x, randomDelivery.y, randomDelivery.z),
        50.0, {
        name = 'gb-logistics:DeliveryArea',
        useZ = true,
        --debugPoly = true
    })

    deliveryZone = BoxZone:Create(
        vector3(randomDelivery.x, randomDelivery.y, randomDelivery.z),
        3.0, 3.0, {
        name = 'gb-logistics:Deliveryzone',
        minZ = randomDelivery.z-1,
        maxZ = randomDelivery.z + 3,
        --debugPoly = true
    })
    deliveryZone:onPlayerInOut(function(isPointInside, point)
        insideDelivery = isPointInside
        if insideDelivery then
            TriggerEvent('cd_drawtextui:ShowUI', 'show', '<b>Afleverpunt</b></p>[E] om het pakket neer te zetten')
        else
            TriggerEvent('cd_drawtextui:HideUI')

        end
    end)

    DeliveryBlip(randomDelivery)

    while Onjob == true do
        local wait
        if insideDeliveryArea then
            wait = 5
            if insideDelivery then
                if insideDelivery and hasBox then
                    if IsControlJustReleased(0, 38) then
                        
                        Onjob = false
                        hasBox = false

                        DeleteEntity(boxModel)
                        ClearPedTasks(playerPed)
                        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
                        Citizen.Wait(3500)
                        ClearPedTasks(playerPed)

                        deliveryArea:destroy()
                        deliveryZone:destroy()

                        insideDelivery = false

                        RemoveBlip(deliveryBlip)

                        TriggerEvent('cd_drawtextui:HideUI')

                        EndDelivery(vehiclePayment)

                        zoneCreated = false
                        insideDeliveryArea = false
                        notified = false
                    end
                end
            end
        else
            wait = 500
        end
        Citizen.Wait(wait)
    end
end

RegisterNetEvent('gb-logistics:box',function()
    hasBox = true

    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 2.0, 1.0, -1, 63, 1, false, false, false)
    Citizen.Wait(500)

    AttachBox()

end)

function EndDelivery(payment)
    TriggerServerEvent('gb-logistics:Payment', payment)

    TriggerEvent('nh-context:sendMenu', {
        {
            id = 0,
            header = 'Job Complete',
            txt = '',
        },
        {
            id = 1,
            header = 'Door gaan met werken',
            txt = 'Krijg nog een bezorglocatie',
            params = {
                event = 'gb-logistics:EndDeliveryHandle',
                args = true
            }
        },
        {
            id = 2,
            header = 'Terug naar het depot',
            txt = 'Ga terug naar het depot en lever het voertuig in',
            params = {
                event = 'gb-logistics:EndDeliveryHandle',
                args = false
            }
        }
    })
end

RegisterNetEvent('gb-logistics:EndDeliveryHandle')
AddEventHandler('gb-logistics:EndDeliveryHandle', function(continue)
    if continue then
        StartDelivery(DeliveryLocations)
    else
        SetBlipRoute(blip, true)
        DeleteObject(boxobject)
    end
end)


function DeliveryBlip(coords)
    if DoesBlipExist(deliveryBlip) then
        return
    else
        deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)

        SetBlipScale(deliveryBlip, 0.8)
        SetBlipColour(deliveryBlip, 5)
        SetBlipDisplay(deliveryBlip, 2)
        SetBlipAsShortRange(deliveryBlip, false)
        SetBlipRoute(deliveryBlip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Package delivery location')
        EndTextCommandSetBlipName(deliveryBlip)
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        
        if Onjob then
            insideDeliveryArea = deliveryArea:isPointInside(GetEntityCoords(vehicle))
            if not notified and insideDeliveryArea then
                exports['swt_notifications']:Warning('Locatie','Je bent dicht bij het afleverpunt, haal het pakketje uit de laadruimte en bezorg het binnen','top',10500,false)
                notified = true
            end
        end
    end
end)

function AttachBox()
    local box = GetHashKey('v_serv_abox_04')

    RequestModel(box)
  
    local bone = GetPedBoneIndex(playerPed, 28422)
  
    while not HasModelLoaded(box) do
      Citizen.Wait(0)
    end

    SetModelAsNoLongerNeeded(box)
  
    boxModel = CreateObject(box, 0, 0, 0, true, true, false)
    AttachEntityToEntity(boxModel, playerPed, bone, 0.0, 0.0, -0.2, 90.0, 270.0, 90.0, 0.0, false, false, false, true, 2, true)
end
