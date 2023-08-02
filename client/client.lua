
local currentGarage = nil
local currentImpound = nil

local Impound, Garage = nil, nil

local insideGarage, insideImpound = false, false
local jobBlips = {}


local function HasItem(items, amount)
    amount = amount or 1
    local count = exports.ox_inventory:Search('count', items)
    if type(items) == 'table' and type(count) == 'table' then
        for _, v in pairs(count) do
            if v < amount then
                return false
            end
        end
        return true
    end
    return count >= amount
end

lib.locale()


function InsideGarage()
	return insideGarage
end exports('InsideGarage', InsideGarage)

function InsideImpound()
	return insideImpound
end exports('InsideImpound', InsideImpound)

AddEventHandler('esx:playerLogout', function()
    for i = 1, #jobBlips do RemoveBlip(jobBlips[i]) end
end)


local function GarageBlips(coords, type, label, blipOptions, job)
    if blipOptions == false then return end
    if job then return end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 357)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip,
        type == 'car' and sdpGarage.BlipColors.Car or type == 'boat' and sdpGarage.BlipColors.Boat or
        sdpGarage.BlipColors.Aircraft)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end

local function JobGarageBlip(garage)
    local index = #jobBlips + 1
    local blip = AddBlipForCoord(garage.zone.coords.x, garage.zone.coords.y, garage.zone.coords.z)
    jobBlips[index] = blip
    SetBlipSprite(jobBlips[index], 357)
    SetBlipScale(jobBlips[index], 0.8)
    SetBlipColour(jobBlips[index],
        garage.type == 'car' and sdpGarage.BlipColors.Car or garage.type == 'boat' and sdpGarage.BlipColors.Boat or
        sdpGarage.BlipColors.Aircraft)
    SetBlipAsShortRange(jobBlips[index], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(garage.label)
    EndTextCommandSetBlipName(jobBlips[index])
end

local function ImpoundBlips(coords, type, label, blipOptions)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 285)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip,
        type == 'car' and sdpGarage.BlipColors.Car or type == 'boat' and sdpGarage.BlipColors.Boat or
        sdpGarage.BlipColors.Aircraft)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end


local function isAllowedOnGarage(data)
    for k, v in pairs(sdpGarage.WhitelistAccess) do
        if ESX.PlayerData.job.name == v and ESX.PlayerData.job.name == data then
            return true
        end
    end
    return false
end

local function isAllowedOnImpound(data)
    for k, v in pairs(sdpGarage.WhitelistAccess) do
        if ESX.PlayerData.job.name == v and ESX.PlayerData.job.name == data then
            return v
        end
    end
    return 'civ'
end


AddEventHandler('esx:playerLoaded', function(xPlayer)
    for i = 1, #jobBlips do RemoveBlip(jobBlips[i]) end
    for i = 1, #sdpGarage.Garages do
        local garage = sdpGarage.Garages[i]
        if garage.job then
            if type(garage.job) == 'string' then
                if garage.job == xPlayer.job.name then JobGarageBlip(garage) end
            else
                for jobName, _ in pairs(garage.job) do
                    if jobName == xPlayer.job.name then
                        JobGarageBlip(garage)
                        break
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    for i = 1, #jobBlips do RemoveBlip(jobBlips[i]) end
    for i = 1, #sdpGarage.Garages do
        local garage = sdpGarage.Garages[i]
        if garage.job then
            if type(garage.job) == 'string' then
                if garage.job == job.name then JobGarageBlip(garage) end
            else
                for jobName, _ in pairs(garage.job) do
                    if jobName == job.name then
                        JobGarageBlip(garage)
                        break
                    end
                end
            end
        end
    end
end)

CreateThread(function()
	while ESX.PlayerData.job == nil do
		Wait(200)
	end

	for i = 1, #sdpGarage.Impounds do
		local data = sdpGarage.Impounds[i]
		ImpoundBlips(vector3(data.zone.coords.x, data.zone.coords.y, data.zone.coords.z), data.type, data.label, data.blip)
		Impound = lib.zones.box({
			coords = data.zone.coords,
			size = data.zone.size,
			rotation = data.zone.rotation,
			debug = false,
	
			onEnter = function()

                SendNUIMessage({
                    action = "show_hint",
                    keyword = sdpGarage.keyInfo,
                    maintext = locale('open_impound'),
                    desc = locale('open_impound_desc')
                })
				currentImpound = sdpGarage.Impounds[i]
				insideImpound = true
                if sdpGarage.radial then
                    lib.addRadialItem({
                        id = 'side_garagev2:impound:menu',
                        icon = 'fa-solid fa-warehouse',
                        label = locale('impound_menu'),
                        onSelect = function()
                            TriggerEvent('side_garagev2:client:requestImpoundVehicle')
                        end
                    })
                end
			end,
			onExit = function()
                if sdpGarage.radial then
                    lib.removeRadialItem('side_garagev2:impound:menu')
                end
                SendNUIMessage({
                    action = "hide_hint"
                })
				insideImpound = false
				currentImpound = nil
			end,
		})
	end

	for i = 1, #sdpGarage.Garages do
		local data = sdpGarage.Garages[i]
		GarageBlips(vector3(data.zone.coords.x, data.zone.coords.y, data.zone.coords.z), data.type, data.label, data.blip,
			data.job)
		Garage = lib.zones.box({
			coords = data.zone.coords,
			size = data.zone.size,
			rotation = data.zone.rotation,
			debug = false,
            
			onEnter = function()
				currentGarage = sdpGarage.Garages[i]
				if currentGarage.job == nil then
					insideGarage = true
                    SendNUIMessage({
                        action = "show_hint",
                        keyword = sdpGarage.keyInfo,
                        maintext = locale('open_garage'),
                        desc = locale('open_garage_desc')
                    })
				elseif isAllowedOnGarage(currentGarage.job) then
					insideGarage = true
                    SendNUIMessage({
                        action = "show_hint",
                        keyword = sdpGarage.keyInfo,
                        maintext = locale('open_garage'),
                        desc = locale('open_garage_desc')
                    })
				end
                if sdpGarage.radial then
                    lib.addRadialItem({
                        id = 'side_garagev2:garage:menu',
                        icon = 'fa-solid fa-warehouse',
                        label = locale('garage_menu'),
                        onSelect = function()
                            TriggerEvent('side_garagev2:client:requestVehicle')
                        end
                    })
                    lib.addRadialItem({
                        id = 'side_garagev2:garage:store',
                        icon = 'fas fa-parking',
                        label = locale('store_vehicle'),
                        onSelect = function()
                            if not cache.vehicle then return sdpGarage.clientNotif(locale('not_in_vehicle')) end
                            TriggerEvent('side_garagev2:client:storeVehicle')
                        end
                    })
                end
			end,
			onExit = function()
                if sdpGarage.radial then
                    lib.removeRadialItem('side_garagev2:garage:menu')
                    lib.removeRadialItem('side_garagev2:garage:store')
                end
                SendNUIMessage({action = "hide_hint"})
				insideGarage = false
				currentGarage = nil
			end,
		})
	end
end)

RegisterNetEvent('side_garagev2:client:requestVehicle', function ()
	if not insideGarage and cache.vehicle then return end
	local thisGarage = currentGarage.label
	local jobGarage = currentGarage.job or 'civ'
	local typeGarage = currentGarage.type

	print(thisGarage, jobGarage, typeGarage)

	local data = {}
    local vehicles = lib.callback.await('side_garagev2:server:GetVehicles', false, typeGarage, jobGarage, thisGarage)
    if not vehicles then
        return sdpGarage.clientNotif(locale('not_on_garage', thisGarage), 'error', 3000)
    end

	SendNUIMessage({action = "show_garage", garage = thisGarage})
	SetNuiFocus(true, true)
    for i = 1, #vehicles do
        local veh = vehicles[i]
        local vehicleName = veh.vehiclename or GetDisplayNameFromVehicleModel(veh.vehicle.model)
		SendNUIMessage({
			action = "add_car",
			number = i,
			chosed = 'A', 
			engined = 'Engine',
			bodyd = 'Body',
			engine = veh.vehicle.engineHealth,
			body = veh.vehicle.bodyHealth,
			modelName = vehicleName,
			plate = veh.vehicle.plate
		})
	end

end)

RegisterNetEvent('side_garagev2:client:requestImpoundVehicle', function ()
	if not insideImpound and cache.vehicle then return end
    local currentJob = isAllowedOnImpound(ESX.PlayerData.job.name)
    if currentImpound.whitelist and not isAllowedOnGarage(ESX.PlayerData.job.name) then
        return sdpGarage.clientNotif(locale('not_allowed'))
    elseif not currentImpound.whitelist or currentImpound.whitelist == nil then
        currentJob = 'civ'
    end
    local vehicles = lib.callback.await('side_garagev2:server:GetImpound', false, currentImpound.type, currentJob)
    if vehicles == nil then
        return dpGarage.clientNotif(locale('not_on_impound'), 'error', 5000)
    end

	SendNUIMessage({action = "show_impound", head = currentImpound.label})
	SetNuiFocus(true, true)
    for i = 1, #vehicles do
        local veh = vehicles[i]
		local vehicle = veh.vehicle
		local vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))
        local vehicleName = veh.vehiclename or GetDisplayNameFromVehicleModel(veh.vehicle.model)
		SendNUIMessage({
			action = "add_impound_car",
			number = i,
			chosed = 'Choose Car', 
			engined = 'Engine',
			bodyd =  'Body',
			engine = vehicle.engineHealth,
			body = vehicle.bodyHealth,
			price = sdpGarage.ImpoundPrices[GetVehicleClassFromName(vehicleModel)],
			modelName = vehicleName,
			plate = vehicle.plate
		})
	end

end)

RegisterNUICallback('close', function(data, cb)
	SendNUIMessage({action = "hide_garage"})
	SetNuiFocus(false, false)
	cb('ok')
end)


local function spawnVehicle(data, spawn, price)
	print('spawn ?')
	lib.requestModel(data.model)
	TriggerServerEvent('side_garagev2:server:SpawnVehicle', data.model, data.plate, vector3(spawn.x, spawn.y, spawn.z - 1), type(spawn) == 'vector4' and spawn.w or spawn.h, price)
end

RegisterNUICallback('changeName', function(data, cb)
	print(data)
	print('Change Name ?')
	SendNUIMessage({action = "hide_garage"})
	SetNuiFocus(false, false)
	local plate = ESX.Math.Trim(data.model)
    local price = sdpGarage.ChangeNamePrice
    local input = lib.inputDialog('Change Vehicle Name', {
        { type = 'input', label = 'Price : '..price, max = 20, placeholder = 'Name' },
    })

    if input[1] ~= nil then
        TriggerServerEvent('side_garagev2:server:renamevehicle', plate, input[1], price)
    end
end)

RegisterNUICallback('takeCar', function(data, cb)
	SendNUIMessage({action = "hide_garage"})
	SetNuiFocus(false, false)
	print(json.encode(data, {indent = true}))
	cb('ok')
	local vehData = {}
	local spawn = currentGarage.spawns
	local vehicles = lib.callback.await('side_garagev2:server:request', false, data.model)
    if not vehicles then
        return dpGarage.clientNotif(locale('invalid_vehicle'), 'error', 5000)
    end

	for i = 1, #vehicles do
        vehData = {
            model = vehicles[i].vehicle.model,
            plate = vehicles[i].plate
        }
    end

	for i = 1, #spawn do
        if ESX.Game.IsSpawnPointClear(vector3(spawn[i].x, spawn[i].y, spawn[i].z), 1.0) then
            return spawnVehicle(vehData, spawn[i], false)
        end
        if i == #spawn then sdpGarage.clientNotif(locale('no_spawn_spot'), 'error', 5000) end
    end
end)


RegisterNUICallback('takeImpound', function(data, cb)
	SendNUIMessage({action = "hide_garage"})
	SetNuiFocus(false, false)
	print(json.encode(data, {indent = true}))
	cb('ok')

	local vehData = {}
	local spawn = currentImpound.spawns
	local vehicles = lib.callback.await('side_garagev2:server:request', false, data.model)
    if not vehicles then
        return sdpGarage.clientNotif(locale('invalid_vehicle'), 'error', 5000)
    end

	for i = 1, #vehicles do
        vehData = {
            model = vehicles[i].vehicle.model,
            plate = vehicles[i].plate
        }
    end
	local price = sdpGarage.ImpoundPrices[GetVehicleClassFromName(vehData.model)]
	print(price)
	for i = 1, #spawn do
        if ESX.Game.IsSpawnPointClear(vector3(spawn[i].x, spawn[i].y, spawn[i].z), 1.0) then
            return spawnVehicle(vehData, spawn[i], price)
        end
        if i == #spawn then dpGarage.clientNotif(locale('no_spawn_spot'), 'error', 5000) end
    end
end)


AddStateBagChangeHandler('vehicleData', nil, function(bagName, key, value, _unused, replicated)
    if not value then return end
    local entNet = bagName:gsub('entity:', '')
    local timer = GetGameTimer()
    while not NetworkDoesEntityExistWithNetworkId(tonumber(entNet)) do
        Wait(0)
        if GetGameTimer() - timer > 10000 then
            return
        end
    end
    local vehicle = NetToVeh(tonumber(entNet))
    local timer = GetGameTimer()
    while NetworkGetEntityOwner(vehicle) ~= PlayerId() do
        Wait(0)
        if GetGameTimer() - timer > 10000 then
            return
        end
    end
    lib.setVehicleProperties(vehicle, json.decode(value.vehicle))
    Entity(vehicle).state.fuel = value.vehicle.fuelLevel
    TriggerServerEvent('side_garagev2:server:ChangeStored', value.plate)
    Entity(vehicle).state:set('vehicleData', nil, true)
end)

RegisterNetEvent('side_garagev2:client:storeVehicle', function()
	if not insideGarage and not cache.vehicle then return end
	local jobGarage = currentGarage.job or 'civ'
	local typeGarage = currentGarage.type or 'car'
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local vehPlate = GetVehicleNumberPlateText(vehicle)
    local vehProps = lib.getVehicleProperties(vehicle)
    local bisaMasuk = lib.callback.await('side_garagev2:server:checkGarage', false, vehPlate)
    if bisaMasuk ~= nil then
        for _, v in pairs(bisaMasuk) do
            if v.job == jobGarage and v.type == typeGarage then
                TaskLeaveVehicle(PlayerPedId(), vehicle, 1)
                Wait(1500)
                TriggerServerEvent('side_garagev2:server:saveVehicle', vehProps, vehPlate, VehToNet(vehicle),
                    currentGarage.label)
            else
				return sdpGarage.clientNotif(locale('not_allow_to_store'), 'error', 5000)
            end
        end
    end
end)