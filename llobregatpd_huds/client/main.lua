local speed = 0.0
local seatbeltOn = false
local cruiseOn = false
local radarActive = false
local nos = 0
-- local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local voice = 2
local limit = false
local lastJob = 'unemployed'
local lastchaleco = 101
local Notify = {}
local lastEstamina = -1
local shifter = nil
isLoggedIn = false

-- Events



RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerEvent('esx_status:getStatus', 'hunger', function(status) hunger = status.val / 10000 end)
    TriggerEvent('esx_status:getStatus', 'thirst', function(status) thirst = status.val / 10000 end)

end)



AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(2000)
        isLoggedIn = true
        QBHud.Show = true
        TriggerEvent('esx_status:getStatus', 'hunger', function(status) hunger = status.val / 10000 end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status) thirst = status.val / 10000 end) 
    end
end)



RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    isLoggedIn = true
    QBHud.Show = true
 
end)


-- RegisterNetEvent('hud:client:UpdateStress') -- Add this event with adding stress elsewhere
-- AddEventHandler('hud:client:UpdateStress', function(newStress)
--     stress = newStress
-- end)
RegisterKeyMapping("cinturon","Ponerse/quitar cinturon","KEYBOARD","B")
RegisterCommand("cinturon",function()
TriggerEvent("seatbelt:client:ToggleSeatbelt")
end)
RegisterNetEvent('seatbelt:client:ToggleSeatbelt') -- Triggered in smallresources
AddEventHandler('seatbelt:client:ToggleSeatbelt', function()
    seatbeltOn = not seatbeltOn
    SendNUIMessage({
        action = 'seatbelt',
        seatbelt = seatbeltOn,
    })
end)

-- Comando de prueba: /testchaleco (solo admins) para verificar la barra de armadura del HUD
RegisterCommand('testchaleco', function()
    TriggerServerEvent('llobregatpd_hud:darChalecoPrueba')
end, false)

RegisterNetEvent('llobregatpd_hud:client:darChalecoPrueba')
AddEventHandler('llobregatpd_hud:client:darChalecoPrueba', function()
    SetPedArmour(PlayerPedId(), 100)
    ESX.ShowNotification('Chaleco de prueba equipado (100%)')
end)

RegisterNetEvent('seatbelt:client:ToggleCruise') -- Triggered in smallresources
AddEventHandler('seatbelt:client:ToggleCruise', function()
    cruiseOn = not cruiseOn
    SendNUIMessage({
        action = 'cruise',
        cruise = cruiseOn,
    })
end)

local isDead = false

checkIsDeathI = function()
    return isDead
end

RegisterNetEvent('hud:client:UpdateNitrous')
AddEventHandler('hud:client:UpdateNitrous', function(hasNitro, nitroLevel, bool)
    nos = nitroLevel
end)

RegisterNetEvent('hud:client:mostrar-muerte')
AddEventHandler('hud:client:mostrar-muerte', function(tiempo)
    isDead = true
    TriggerEvent('inventory:hideHotBar')
    SendNUIMessage({
        action = 'mostrar-muerte',
        tiempo = tiempo,
    })
end)

local statusRadarCar = false

RegisterNetEvent('hud:client:statusRadarCar')
AddEventHandler('hud:client:statusRadarCar', function(bool)
    statusRadarCar = bool
end)

RegisterNetEvent('hud:client:mostrar-respawn')
AddEventHandler('hud:client:mostrar-respawn', function(msg)
    SendNUIMessage({
        action = 'mostrar-respawn',
        msg = msg,
    })
end)

RegisterNetEvent('hud:client:ocultar-muerte')
AddEventHandler('hud:client:ocultar-muerte', function(tiempo)
    isDead = false
    SendNUIMessage({
        action = 'ocultar-muerte'
    })
end)

RegisterNetEvent('hud:client:set-voz')
AddEventHandler('hud:client:set-voz', function(voz)
    voice = voz
end)

AddEventHandler('hud:client:showVoiceControl', function()
    SendNUIMessage({
        action = "showVoiceControl"
    })
end)

AddEventHandler('hud:client:hideVoiceControl', function()
    SendNUIMessage({
        action = "hideVoiceControl"
    })
end)

-- Player HUD


RegisterNetEvent('hud:client:showGear')
AddEventHandler('hud:client:showGear', function(gear)
    shifter = gear
end)


Citizen.CreateThread(function()
    Citizen.Wait(500)
    while true do 
        if ESX ~= nil and isLoggedIn and QBHud.Show then
            local player = PlayerPedId()
            -- local speed = GetEntitySpeed(GetVehiclePedIsIn(player, false)) * 2.23694
            local pos = GetEntityCoords(player)
            local talking = NetworkIsPlayerTalking(PlayerId())
            -- local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            local fuel = 0
            if IsPedInAnyVehicle(player) then
                fuel = GetVehicleFuelLevel(GetVehiclePedIsIn(player))
            end
            local armor = GetPedArmour(player)
            local estamina = IsPedSwimmingUnderWater(player) and GetPlayerUnderwaterTimeRemaining(PlayerId())*10 or GetPlayerStamina(PlayerId())

            TriggerEvent('esx_status:getStatus', 'hunger', function(status) hunger = status.val / 10000 end)
            TriggerEvent('esx_status:getStatus', 'thirst', function(status) thirst = status.val / 10000 end)
            SendNUIMessage({
                action = 'hudtick',
                show = IsPauseMenuActive(),
                health = GetEntityHealth(player) - 100,
                armor = armor,
                estamina = estamina ~= lastEstamina and math.floor(estamina) or false,
                thirst = thirst,
                hunger = hunger,
                stress = stress,
                voice = voice,
                talking = talking,
                -- direction = GetDirectionText(GetEntityHeading(player)),
                -- street1 = GetStreetNameFromHashKey(street1),
                -- street2 = GetStreetNameFromHashKey(street2),
                -- speed = math.ceil(speed),
                -- rpm = IsPedInAnyVehicle(player, false) and GetVehicleCurrentRpm(GetVehiclePedIsIn(player, false)) or 0.0,
                -- nos = nos,
                fuel = fuel,
                gear = shifter or "A",
            })

            if lastchaleco > 0 and armor <= 0 and lastchaleco <= 100 then
                ESX.ShowNotification("Tu chaleco antibalas se ha roto")
            end
            lastchaleco = armor
            lastEstamina = estamina
            Citizen.Wait(750)
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local w = 2000
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if veh ~= 0 and GetEntityModel(veh) ~= -1963629913 then
            SendNUIMessage({
                action = 'speedtick',
                speed = math.ceil((GetEntitySpeed(veh) * 2.23694) / 1.609344),
            })
            w = 100
        else
            SendNUIMessage({
                action = 'speedtick',
                speed = 0
            })
        end

        Citizen.Wait(w)
    end
end)


-- Raise Minimap

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    while not HasScaleformMovieLoaded(minimap) do
      Wait(0)
    end

    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0045, -0.012, 0.150, 0.188888)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.020, 0.022, 0.111, 0.159)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.03, 0.012, 0.266, 0.237)
    DisplayRadar(false)
end)

-- Vehicle HUD

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1000)
        if IsPedInAnyVehicle(PlayerPedId()) and not radarActive and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) ~= -1963629913 then
            DisplayRadar(true)
            SendNUIMessage({
                action = 'car',
                show = true,
            })
            radarActive = true
        elseif radarActive and not IsPedInAnyVehicle(PlayerPedId()) then
            DisplayRadar(false)
            radarActive = false
            SendNUIMessage({
                action = 'car',
                show = false,
            })
        end
    end
end)

RegisterNetEvent('hud:client:statusNitro')
AddEventHandler('hud:client:statusNitro', function(bool)
    SendNUIMessage({
        type = 'status',
        display = bool,
    })
end)

RegisterNetEvent('hud:client:nosLevelNitro')
AddEventHandler('hud:client:nosLevelNitro', function(bool)
    SendNUIMessage({
        type = 'nosLevel',
        nos = bool,
    })
end)

RegisterNetEvent('hud:client:purgeLevelNitro')
AddEventHandler('hud:client:purgeLevelNitro', function(bool)
    SendNUIMessage({
        type = 'purgeLevel',
        purge = bool,
    })
end)



function GetDirectionText(heading)
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return 'North'
    elseif (heading >= 45 and heading < 135) then
        return 'South'
    elseif (heading >=135 and heading < 225) then
        return 'East'
    elseif (heading >= 225 and heading < 315) then
        return 'West'
    end
end

-- Stress Gain

function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for k, v in pairs(QBHud.Intensity['shake']) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

function GetEffectInterval(stresslevel)
    local retval = 60000
    for k, v in pairs(QBHud.EffectInterval) do
        if stresslevel >= v.min and stresslevel < v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end


RegisterNetEvent('origen_hud:updateCops')
AddEventHandler('origen_hud:updateCops',function(number)
	SendNUIMessage({
		action = "setCops",
		policeCount = number
	})
	if tonumber(number) < 2 then
        SendNUIMessage({
            action = 'hidePolice'
        })
	else
        SendNUIMessage({
            action = 'showPolice'
        })
	end
end)



RegisterNetEvent('origen_hud:mostrarEntorno')
AddEventHandler('origen_hud:mostrarEntorno',function(text)

	SendNUIMessage({
		action = "mostrarEntorno",
        text = text
	})
	
end)

RegisterNetEvent('origen_hud:ocultarEntorno')
AddEventHandler('origen_hud:ocultarEntorno',function(text)

	SendNUIMessage({
		action = "ocultarEntorno"
	})
	
end)

RegisterNetEvent('origen_hud:mostrarRadio')
AddEventHandler('origen_hud:mostrarRadio',function(text)

	SendNUIMessage({
		action = "showRadio",
        text = text
	})
	
end)

RegisterNetEvent('origen_hud:ocultarRadio')
AddEventHandler('origen_hud:ocultarRadio',function(text)

	SendNUIMessage({
		action = "hideRadio"
	})
	
end)

Citizen.CreateThread(function()
    while true do
        local wait = 1500
        if IsPedInAnyVehicle(PlayerPedId()) then
            wait = 25
            DisableControlAction(0, 99, true)
        end
        Citizen.Wait(wait)
    end
end)