ZTH.Functions = {}

function ZTH.Functions.RegisterZones(self)
    Debug("Unregistering all markers")
    for _, v in pairs(self.Zones) do
        TriggerEvent("gridsystem:unregisterMarker", v.data.name)
    end

    Debug("Registering all markers")
    for i, garages in pairs(self.Config.Garages) do
        Debug("Registering zone " .. i)

        local Settins = garages["Settings"]
        if Settins.blip then
            CreateBlip(Settins.blip)
        else
            Debug("No blip found for garage " .. i .. ", skipping")
        end
        
        for _type, garage in pairs(garages) do
            if _type == "Settings" then goto continue end
            if _type == "ParkingSpots" then goto spots end
            if _type == "SpawnVehicle" then goto continue end
            
            garage.name = _type .. "_" .. i
            garage.action = function() self.Functions.MarkerAction(self, _type, i) end
            ClearSpawnPoint(garage.pos)
            CreateMarker(_type, garage)
            goto continue

            ::spots::
            self.Functions.RegisterSpotZones(self, i)

            ::continue::
        end
    end
end

function ZTH.Functions.RegisterSpotZones(self, garage_id)
    local garage = self.Config.Garages[garage_id]
    local spotsData = ZTH.Tunnel.Interface.GetManagementGarageSpots(garage_id)
    if not garage.ParkingSpots then return end
    if not spotsData then return end

    -- print(json.encode(garage, { indent = true }))

    Debug("Registering spot zones for garage " .. garage_id)
    for j, spot in pairs(garage.ParkingSpots) do
        ClearSpawnPoint(spot.pos)
        local _spotData = spotsData[j]
        if not _spotData then goto continue end

        spot.occupiedData = _spotData
        spot.occupied = spot.occupiedData.user_id

        if spot.occupied and self.PlayerData.citizenid == spot.occupied and spot.occupiedData.state == 0 then
            spot.name = "ParkingSpots_" .. garage_id .. "_" .. j
            spot.action = function() self.Functions.MarkerAction(self, "ParkingSpots", garage_id, j) end
            CreateMarker("ParkingSpots", spot)
        end

        ::continue::
    end
end

function ZTH.Functions.InitializeGarages(self)
    for id, garage in pairs(self.Config.Garages) do
        if not garage["ParkingSpots"] then goto continue end
        local spots = self.Tunnel.Interface.GetManagementGarageSpots(id)

        for k, vehicle in pairs(spots) do
            vehicle.id = tonumber(vehicle.id)
            if vehicle.state == 1 then
                local pos = garage["ParkingSpots"][vehicle.id].pos
                local heading = garage["ParkingSpots"][vehicle.id].heading
                local coords = vector4(pos.x, pos.y, pos.z, heading)
                
                self.Core.Functions.SpawnVehicle(vehicle.mods.model, function(veh)
                    Debug("Spawned vehicle " .. vehicle.plate .. " at " .. id .. " spot " .. vehicle.id)
                    SetVehicleOnGroundProperly(veh)
                    FreezeEntityPosition(veh, true)
                    SetEntityInvincible(veh, true)
                    self.Core.Functions.SetVehicleProperties(veh, vehicle.mods)
                end, coords, false)
            else
                garage["ParkingSpots"][vehicle.id].occupiedData = vehicle
                garage["ParkingSpots"][vehicle.id].occupied = garage["ParkingSpots"][vehicle.id].occupiedData.user_id
                garage["ParkingSpots"][vehicle.id].name = "ParkingSpots_" .. vehicle.garage_id .. "_" .. vehicle.id
                garage["ParkingSpots"][vehicle.id].action = function()
                    self.Functions.MarkerAction(self, "ParkingSpots", vehicle.garage_id, vehicle.id)
                end
                CreateMarker("ParkingSpots", garage["ParkingSpots"][vehicle.id])
            end
        end

        ::continue::
    end
end

function ZTH.Functions.MarkerAction(self, _type, id, spotid)
    if spotid and _type == "ParkingSpots" then
        self.Functions.DepositVehicle(self, id, spotid)
    else
        Debug("MarkerAction: " .. _type .. " " .. id)

        if _type == "Manage" then
            if self.Tunnel.Interface.IsOwnerOfGarage(id) then
                local managementTable = self.Tunnel.Interface.GetManagementGarageData(id)
                self.NUI.Open({ screen = "garage-manage", garageData = managementTable })
            else
                return self.Core.Functions.Notify("You are not the owner of this garage", 'error', 5000)
            end
        end

        if _type == "TakeVehicle" then
            self.Functions.OpenTakeVehicle(self, id)
        end

        if _type == "BuySpot" then
        end

        if _type == "Deposit" then
            self.Functions.DepositVehicle(self, id, spotid)
        end
    end
end

function ZTH.Functions.OpenTakeVehicle(self, id)
    ZTH.Tunnel.Interface.UpdateVehiclesCacheForUser()
    local garageData = self.Tunnel.Interface.GetParkedVehicles(id)
    self.NUI.Open({ screen = "list", garageData = { vehicles = garageData, showManage = false } })
end

function ZTH.Functions.DepositVehicle(self, id, spotid)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        return self.Core.Functions.Notify("You are not in a vehicle", 'error', 5000)
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = self.Core.Functions.GetPlate(vehicle)
    -- means that this is a private parking spot
    if spotid then
        if self.Tunnel.Interface.CanDeposit(id, spotid, plate) then
            local model = GetEntityModel(vehicle)
            local hash = GetHashKey(vehicle)
            
            local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
            local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
            local totalFuel = exports[self.Config.FuelResource]:GetFuel(vehicle)

            local mods = self.Core.Functions.GetVehicleProperties(vehicle)
            self.Tunnel.Interface.DepositVehicle(id, spotid, {
                body = bodyDamage,
                fuel = totalFuel,
                engine = engineDamage,
                plate = plate,
                mods = json.encode(mods),
            })

            -- walk out of the vehicle
            TaskLeaveVehicle(ped, vehicle, 0)
            Citizen.Wait(2000)
            self.Core.Functions.DeleteVehicle(vehicle)
            self.Functions.RegisterSpotZones(self, id)
            self.Functions.RegisterZones(self)
            self.Functions.InitializeGarages(self)
        else
            return self.Core.Functions.Notify("You can't deposit here", 'error', 5000)
        end
    elseif not spotid then
        ZTH.Tunnel.Interface.UpdateVehiclesCacheForUser()

        if self.Tunnel.Interface.OwnsCar(id, plate) then
            local model = GetEntityModel(vehicle)
            local hash = GetHashKey(vehicle)
            
            local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
            local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
            local totalFuel = exports[self.Config.FuelResource]:GetFuel(vehicle)

            local mods = self.Core.Functions.GetVehicleProperties(vehicle)
            self.Tunnel.Interface.DepositVehicle(id, spotid, {
                body = bodyDamage,
                fuel = totalFuel,
                engine = engineDamage,
                plate = plate,
                mods = json.encode(mods),
            })

            -- walk out of the vehicle
            TaskLeaveVehicle(ped, vehicle, 0)
            Citizen.Wait(2000)
            self.Core.Functions.DeleteVehicle(vehicle)
        else
            return self.Core.Functions.Notify("You don't own this car", 'error', 5000)
        end
    else
        return self.Core.Functions.Notify("You can't deposit here", 'error', 5000)
    end
end

function ZTH.Functions.TakeVehicle(self, _data)
    local data = _data.car
    local ped = PlayerPedId()
    local spawnCoords = self.Config.Garages[data.garage].SpawnVehicle
    local coords = vector4(spawnCoords.pos.x, spawnCoords.pos.y, spawnCoords.pos.z, spawnCoords.heading)
    -- check if the spawnpoint is free
    if not IsSpawnPointFree(coords, 5.0) then
        return self.Core.Functions.Notify("The spawnpoint is not free", 'error', 5000)
    end
    
    if self.Tunnel.Interface.TakeVehicle(data.plate, data.garage) then
        self.Core.Functions.SpawnVehicle(data.mods.model, function(vehicle)
            ZTH.NUI.Close()
            self.Core.Functions.SetVehicleProperties(vehicle, data.mods)
            self.Core.Functions.Notify("Vehicle taken from the garage", 'success', 5000)
        end, coords, true, true)
    else
        return self.Core.Functions.Notify("You can't take this vehicle", 'error', 5000)
    end
end

function ZTH.Functions.EnteredVehicle(vehicle, seat, vehDisplay)
    print("Entered vehicle", vehicle, seat, vehDisplay)
    local mods = ZTH.Core.Functions.GetVehicleProperties(vehicle)
    local vehicleData = ZTH.Tunnel.Interface.GetParkedVehicleData(mods.plate)
    -- print(json.encode(vehicleData, { indent = true }))

    if vehicleData then
        local garage_id = vehicleData.garage_id
        -- get this for future refresh (maybe????)
        -- local spots = self.Tunnel.Interface.GetManagementGarageSpots(garage_id)

        local vehCoords = GetEntityCoords(vehicle)
        local coords = vector4(vehCoords.x, vehCoords.y, vehCoords.z, vehicleData.spot_config.heading)
        ZTH.Tunnel.Interface.SetParkedVehicleState(vehicleData, 0)
        DeleteVehicle(vehicle)
        ZTH.Functions.RegisterSpotZones(ZTH, garage_id)
        ZTH.Functions.RegisterZones(ZTH)
        ZTH.Functions.InitializeGarages(ZTH)
        ZTH.Core.Functions.SpawnVehicle(vehicleData.mods.model, function(veh)
            ZTH.Core.Functions.SetVehicleProperties(veh, vehicleData.mods)
            ZTH.Core.Functions.Notify("Vehicle taken from the garage", 'success', 5000)
        end, coords, true, true)
    end
end

function ZTH.Functions.LeftVehicle(vehicle, seat, vehDisplay)
    -- print("Left vehicle", vehicle, seat, vehDisplay)
end

function ZTH.Functions.EnteringVehicle(vehicle, seat, vehDisplay)
    -- print("Entering vehicle", vehicle, seat, vehDisplay)
end

function ZTH.Functions.EnteredVehicleAborted(vehicle, seat, vehDisplay)
    -- print("Entered vehicle aborted", vehicle, seat, vehDisplay)
end

function ZTH.Functions.Init()
    ZTH.IsReady = ZTH.Tunnel.Interface.RequestReady()
    while not ZTH.IsReady do Wait(1000) end
    ZTH.PlayerData = ZTH.Core.Functions.GetPlayerData()
    -- print(json.encode(ZTH.PlayerData, { indent = true }))

    ZTH.Functions.RegisterZones(ZTH)
    ZTH.Functions.InitializeGarages(ZTH)
end