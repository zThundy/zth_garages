
ZTH.Garages = {}
ZTH.Tunnel = {}
ZTH.Blips = {}
ZTH.Zones = {}

ZTH.CloseGarage = nil

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = ZTH.Tunnel.getInterface("zth_garages", "zth_garages_t", "zth_garages_t")

Citizen.CreateThread(ZTH.Functions.Init)

ZTH.Functions.RegisterEvent = function(name, cb)
	RegisterNetEvent(name, function(...)
		Debug("[^5NET-EVENTS^0] Received net event: " .. name)
		cb(...)
	end)
end

ZTH.Functions.RegisterEvent(ZTH.Config.Events.UpdateGaragesParkingSpotsConfig, function(data)
	for key, value in pairs(data) do
		Debug("Updating garage: " .. key .. " with data: " .. json.encode(value))
		ZTH.Config.Garages[value.garage_id].ParkingSpots[value.spot_id] = { pos = value.pos }
	end
end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.ResourceInit, function() ZTH.IsReady = true end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.PlayerLoaded, function() ZTH.Functions.Init() end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.PlayerSetJob, function(job)
	if ZTH.PlayerData.job.name == job.name and ZTH.PlayerData.job.grade.level == job.grade.level then
		return Debug("Job is the same, skipping garage refresh. " .. json.encode(job))
	end
	
	local oldJob = ZTH.PlayerData.job
	ZTH.PlayerData.job = job
	ZTH.Functions.RefreshJobGarages(ZTH, oldJob)
end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.SharedUpdated, function(data) ZTH.Config.Shared = data end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.RefreshGarages, function(id) ZTH.Functions.RefreshGarage(ZTH, id) end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.SpawnCarOnSpot, function(pData, spot) ZTH.Functions.SpawnCarOnSpot(ZTH, pData, spot) end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.PlayerUpdateData, function() ZTH.Functions.RefreshJobGarages(ZTH) end)
ZTH.Functions.RegisterEvent(ZTH.Config.Events.SetPlayerData, function(PlayerData)
	if ZTH.PlayerData.job.name == PlayerData.job.name and ZTH.PlayerData.job.grade.level == PlayerData.job.grade.level then
		return Debug("Job is the same, skipping garage refresh. " .. json.encode(PlayerData.job))
	end

	local oldJob = ZTH.PlayerData.job
	ZTH.PlayerData = PlayerData
	ZTH.Functions.RefreshJobGarages(ZTH, oldJob)
end)

-- Enter / Leave vehicle thread
Citizen.CreateThread(function()
	while not ZTH.IsReady do Wait(1000) end

    local isInVehicle = false
    local isEnteringVehicle = false
    local currentVehicle = 0
    local currentSeat = 0

	while true do
		Citizen.Wait(0)
		local ped = PlayerPedId()
		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				isEnteringVehicle = true
                ZTH.Functions.EnteringVehicle(vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
                ZTH.Functions.EnteredVehicleAborted(0, 0, "nil")
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
                ZTH.Functions.EnteredVehicle(currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
				-- bye, vehicle
                ZTH.Functions.LeftVehicle(currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
		Citizen.Wait(50)
	end
end)

-- check if vehicles are actually at coords
Citizen.CreateThread(function()
	while not ZTH.IsReady do Wait(1000) end
	while not ZTH.PlayerData do Wait(1000) end
	while not ZTH.PlayerData.citizenid do Wait(1000) end

	while true do
		if not ZTH.CloseGarage then
			for id, garage in pairs(ZTH.Config.Garages) do
				if garage.ParkingSpots then
					local center = garage.Settings.center
					center = vector3(center.x, center.y, center.z)
					local coords = GetEntityCoords(PlayerPedId())
					local dst = #(coords - center)

					if dst < garage.Settings.renderDistance then
						ZTH.CloseGarage = id
						ZTH.Functions.RefreshGarage(ZTH, ZTH.CloseGarage)
						Debug("Closest found! Now is " .. tostring(ZTH.CloseGarage))
						break
					end
				end
			end
		else
			local garage = ZTH.Config.Garages[ZTH.CloseGarage]
			local center = garage.Settings.center
			center = vector3(center.x, center.y, center.z)
			local coords = GetEntityCoords(PlayerPedId())
			local dst = #(coords - center)

			if dst > garage.Settings.renderDistance then
				ZTH.Functions.UnloadVehicles(ZTH.CloseGarage)
				ZTH.CloseGarage = nil
				Debug("Closest lost! Now is " .. tostring(ZTH.CloseGarage))
			end
		end
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while not ZTH.IsReady do Wait(1000) end
	if ZTH.Config.Debug.enableMarkers then DebugModeSpawnMarkers() end
end)