lib.locale()

local function canAfford(src, price)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        if sdpGarage.PayInCash then
            if xPlayer.getMoney() >= price then
                xPlayer.removeMoney(price)
                return true
            else
                sdpGarage.serverNotif(source, locale('no_money'))
                return false
            end
        else
            if xPlayer.getAccount('bank').money >= price then
                xPlayer.removeAccountMoney('bank', price)
                return true
            else
                sdpGarage.serverNotif(source, locale('no_money'))
                return false
            end
        end
    end
end

lib.callback.register('side_garagev2:server:GetVehicles', function(source, garageType, job, currentGarage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local vehicles = {}
    local currentGarage = ESX.Math.Trim(currentGarage)

    if not job then
        local results = MySQL.Sync.fetchAll(
        "SELECT `plate`, `vehicle`, `vehiclename`, `stored`, `garage`, `job` FROM `owned_vehicles` WHERE `owner` = @identifier AND `type` = @type AND `garage` = @garage",
            {
                ['@identifier'] = identifier,
                ['@type'] = garageType,
                ['@garage'] = currentGarage
            })
        if results[1] ~= nil then
            for i = 1, #results do
                local result = results[i]
                if not result.job or result.job == 'civ' then
                    local veh = json.decode(result.vehicle)
                    vehicles[#vehicles + 1] = { plate = result.plate, vehiclename = result.vehiclename, vehicle = veh,
                        stored = result.stored, garage = result.garage }
                end
            end
            return vehicles
        end
    else
        local jobs = {}
        if type(job) == 'table' then for k, _ in pairs(job) do jobs[#jobs + 1] = k end else jobs = job end
        local results = MySQL.Sync.fetchAll(
        'SELECT `plate`, `vehicle`, `vehiclename`, `stored`, `garage` FROM `owned_vehicles` WHERE (`owner` = @identifier OR `owner` IN (@jobs)) AND `type` = @type AND `job` IN (@jobs) AND `garage` = @garage',
            {
                ['@identifier'] = identifier,
                ['@type'] = garageType,
                ['@jobs'] = jobs,
                ['@garage'] = currentGarage
            })
        if results[1] ~= nil then
            for i = 1, #results do
                local result = results[i]
                local veh = json.decode(result.vehicle)
                vehicles[#vehicles + 1] = { plate = result.plate, vehiclename = result.vehiclename, vehicle = veh,
                    stored = result.stored, garage = result.garage }
            end
            return vehicles
        end
    end
end)

lib.callback.register('side_garagev2:server:request', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local plate = ESX.Math.Trim(plate)
    local vehicles = {}
    local results = MySQL.Sync.fetchAll(
        "SELECT `plate`, `vehicle` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate",
            {
                ['@identifier'] = xPlayer.identifier,
                ['@plate'] = plate
            })
        if results[1] ~= nil then
            for i = 1, #results do
                local result = results[i]
                local veh = json.decode(result.vehicle)
                vehicles[#vehicles + 1] = {vehicle = veh, plate = result.plate}
            end
            return vehicles
        else
            return sdpGarage.serverNotif(source, locale('vehicle_not_exists', plate))
        end
end)

lib.callback.register('side_garagev2:server:checkGarage', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local kendaraan = {}

    local hasil = MySQL.Sync.fetchAll(
    "SELECT `job`, `type` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate ", {
        ['@identifier'] = identifier,
        ['@plate'] = ESX.Math.Trim(plate),
    })
    if hasil[1] ~= nil then
        for i = 1, #hasil do
            local data = hasil[i]
            kendaraan[#kendaraan + 1] = {
                type = data.type,
                job = data.job
            }
        end
        return kendaraan
    else
        sdpGarage.serverNotif(source, locale('not_your_vehicle'))
    end
end)

lib.callback.register('side_garagev2:server:GetImpound', function(source, type, currentJob)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local vehicles = {}

    local worldVehicles = GetAllVehicles()
    local results = MySQL.Sync.fetchAll(
    'SELECT `plate`, `vehicle`, `vehiclename`, `job` FROM owned_vehicles WHERE (`owner` = @identifier) AND `type` = @type AND `stored` = 0',
        {
            ['@identifier'] = identifier,
            ['@type'] = type,
            ['@job'] = currentJob
        })
    if results[1] ~= nil then
        for i = 1, #results do
            local result = results[i]
            local veh = json.decode(result.vehicle)
            if #worldVehicles ~= nil and #worldVehicles > 0 then
                for index = 1, #worldVehicles do
                    local vehicle = worldVehicles[index]
                    if ESX.Math.Trim(result.plate) == ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)) then
                        if GetVehiclePetrolTankHealth(vehicle) > 0 and GetVehicleBodyHealth(vehicle) > 0 then break end
                        if GetVehiclePetrolTankHealth(vehicle) <= 0 and GetVehicleBodyHealth(vehicle) <= 0 then
                            DeleteEntity(vehicle)
                            -- Allows players to only get their job vehicle from impound while having the job
                            if (result.job == currentJob or result.job == nil) then
                                vehicles[#vehicles + 1] = { plate = result.plate, vehiclename = result.vehiclename,  vehicle = veh }
                            end
                        end
                        break
                    elseif index == #worldVehicles then
                        -- Allows players to only get their job vehicle from impound while having the job
                        if (result.job == currentJob or result.job == nil) then
                            vehicles[#vehicles + 1] = { plate = result.plate, vehiclename = result.vehiclename,  vehicle = veh }
                        end
                    end
                end
            else
                if (result.job == currentJob or result.job == nil) then
                    vehicles[#vehicles + 1] = { plate = result.plate, vehiclename = result.vehiclename,  vehicle = veh }
                end
            end
        end
        return vehicles
    end
end)

RegisterNetEvent('side_garagev2:server:SpawnVehicle', function(model, plate, coords, heading, price)
    if type(model) == 'string' then model = GetHashKey(model) end
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = GetAllVehicles()
    plate = ESX.Math.Trim(plate)
    if price and not canAfford(source, price) then return end
    for i = 1, #vehicles do
        if ESX.Math.Trim(GetVehicleNumberPlateText(vehicles[i])) == plate then
            if GetVehiclePetrolTankHealth(vehicle) > 0 and GetVehicleBodyHealth(vehicle) > 0 then
                return sdpGarage.serverNotif(source, locale('vehicle_exists'))
            end
        end
    end
    MySQL.Async.fetchAll('SELECT vehicle, plate, garage FROM `owned_vehicles` WHERE plate = @plate',
        { ['@plate'] = ESX.Math.Trim(plate) }, function(result)
        if result[1] then
            CreateThread(function()
                local entity = Citizen.InvokeNative(`CREATE_AUTOMOBILE`, model, coords.x, coords.y, coords.z, heading)
                local ped = GetPedInVehicleSeat(entity, -1)
                if ped > 0 then
                    for i = -1, 6 do
                        ped = GetPedInVehicleSeat(entity, i)
                        local popType = GetEntityPopulationType(ped)
                        if popType <= 5 or popType >= 1 then
                            DeleteEntity(ped)
                        end
                    end
                end
                if sdpGarage.TeleportToVehicles then
                    local playerPed = GetPlayerPed(xPlayer.source)
                    local timer = GetGameTimer()
                    while GetVehiclePedIsIn(playerPed) ~= entity do
                        Wait(0)
                        SetPedIntoVehicle(playerPed, entity, -1)
                        if timer - GetGameTimer() > 15000 then
                            break
                        end
                    end
                end
                local ent = Entity(entity)
                ent.state.vehicleData = result[1]
            end)
        end
    end)
end)

RegisterNetEvent('side_garagev2:server:ChangeStored', function(plate)
    local plate = ESX.Math.Trim(plate)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `stored` = @stored, `garage` = @garage WHERE `plate` = @plate', {
        ['@garage'] = 'Outside',
        ['@stored'] = 0,
        ['@plate'] = ESX.Math.Trim(plate)
    })
end)

RegisterNetEvent('side_garagev2:server:saveVehicle', function(vehicle, plate, ent, garage)
    MySQL.Async.execute(
    'UPDATE `owned_vehicles` SET `vehicle` = @vehicle, `garage` = @garage, `last_garage` = @garage, `stored` = @stored WHERE `plate` = @plate',
        {
            ['@vehicle'] = json.encode(vehicle),
            ['@plate'] = ESX.Math.Trim(plate),
            ['@stored'] = 1,
            ['@garage'] = garage
        })
    local ent = NetworkGetEntityFromNetworkId(ent)
    DeleteEntity(ent)
end)


RegisterNetEvent('side_garagev2:server:renamevehicle', function(vehicleplate, name, price)
    local src = source
    if not canAfford(source, price) then return end
    MySQL.Async.execute("UPDATE owned_vehicles SET vehiclename =@vehiclename WHERE plate=@plate", {
        ['@vehiclename'] = name,
        ['@plate'] = ESX.Math.Trim(vehicleplate)
    }, function(result)
        if result then
            sdpGarage.serverNotif(src, locale('vehicle_name_changed', name))
        end
    end)
end)