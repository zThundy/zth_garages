
ZTH.Garages = {}
ZTH.Tunnel = {}
ZTH.Blips = {}
ZTH.Zones = {}

ZTH.CloseGarage = nil

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = ZTH.Tunnel.getInterface("zth_garages", "zth_garages_t", "zth_garages_t")

Citizen.CreateThread(ZTH.Functions.Init)

RegisterNetEvent(ZTH.Config.Events.ResourceInit, function() ZTH.IsReady = true end)
AddEventHandler(ZTH.Config.Events.PlayerLoaded, function() ZTH.Functions.Init() end)
RegisterNetEvent(ZTH.Config.Events.PlayerSetJob, function(job) ZTH.Functions.Init() end)
AddEventHandler(ZTH.Config.Events.SharedUpdated, function(data) ZTH.Config.Shared = data end)
RegisterNetEvent(ZTH.Config.Events.RefreshGarages, function(id) ZTH.Functions.RefreshGarage(ZTH, id) end)
RegisterNetEvent(ZTH.Config.Events.SpawnCarOnSpot, function(pData, spot) ZTH.Functions.SpawnCarOnSpot(ZTH, pData, spot) end)

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