ESX = exports["es_extended"]:getSharedObject()

local price         = Config.Price
local heading1      = Config.Heading1
local heading2      = Config.Heading2
local buttonText    = Config.ButtonText
local rentalCoords  = Config.RentalCoords      -- vector3
local spawnCoords   = Config.SpawnCoords       -- vector4
local pedModelHash  = Config.RentalPedModel and GetHashKey(Config.RentalPedModel) or GetHashKey("a_m_m_business_01")
local vehModelName  = Config.VehicleModel or "blista"
local vehModelHash  = GetHashKey(vehModelName)
local plateText     = (Config.PlateText or "RENTAL"):upper()
local color         = Config.VehicleColor or { r = 255, g = 255, b = 255 }
local rentalDuration = Config.RentalDuration or 10  

local function notify(msg)                     
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function drawText3D(x, y, z, text)       
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function spawnRentalVehicle()
    RequestModel(vehModelHash)
    while not HasModelLoaded(vehModelHash) do Wait(0) end

    local veh = CreateVehicle(
        vehModelHash,
        spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w,
        true, false
    )

    SetVehicleCustomPrimaryColour (veh, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(veh, color.r, color.g, color.b)

    SetVehicleNumberPlateText(veh, plateText)

    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetEntityAsMissionEntity(veh, true, true)

    local warnTime = (rentalDuration - 1) * 60000
    local deleteTime = rentalDuration * 60000

    CreateThread(function()
        Wait(warnTime)
        if DoesEntityExist(veh) then
            notify("~y~Your car rental will expire in 1 minute!")
        end

        Wait(60000)
        if DoesEntityExist(veh) then
            notify("~r~Your rental car has been returned.")
            DeleteVehicle(veh)
        end
    end)
end

local function openRentalUI()                  
    SetNuiFocus(true, true)
    SendNUIMessage({
        action     = "open",
        heading1   = heading1,
        heading2   = heading2,
        buttonText = buttonText,
        price      = price
    })
end


CreateThread(function()                        
    RequestModel(pedModelHash)
    while not HasModelLoaded(pedModelHash) do Wait(0) end

    local ped = CreatePed(0, pedModelHash,
        rentalCoords.x, rentalCoords.y, rentalCoords.z - 1.0,
        0.0, false, true
    )

    FreezeEntityPosition     (ped, true)
    SetEntityInvincible      (ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

CreateThread(function()                         
    local blip = AddBlipForCoord(rentalCoords)
    SetBlipSprite (blip, 225)  
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.8)
    SetBlipColour (blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Car Rental")
    EndTextCommandSetBlipName(blip)
end)

CreateThread(function()
    while true do
        Wait(0)
        local ped      = PlayerPedId()
        local distance = #(GetEntityCoords(ped) - rentalCoords)

        if distance < 2.0 then
            drawText3D(rentalCoords.x, rentalCoords.y, rentalCoords.z + 1.0, "[E] Rent a Car")
            if IsControlJustReleased(0, 38) then
                openRentalUI()
            end
        end
    end
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

RegisterNUICallback("rent", function(_, cb)
    ESX.TriggerServerCallback("ys_carrental:tryPayment", function(success)
        if success then
            spawnRentalVehicle()
            notify("Enjoy your ride!")
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "close" })
            cb("ok")
        else
            notify("~r~Not enough money in your bank account.")
            cb("failed")
        end
    end, price)
end)
