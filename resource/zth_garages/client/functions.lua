ZTH.Functions = {}

function ZTH.Functions.RegisterZones(self, id)
    UnregisterAllMarkers(id)
    
    Debug("Registering all markers")
    for i, garages in pairs(self.Config.Garages) do
        if id and i ~= id then goto skip end

        if not garages.Settings then Debug("Settings is missing for garage " .. i) goto skip end
        
        Debug("Registering zone " .. i)
        local Settings = garages.Settings
        if Settings.blip then
            if Settings.center then Settings.blip.pos = Settings.center end
            Settings.blip.confId = i
            CreateBlip(Settings.blip)
        else
            Debug("No blip found for garage " .. i .. ", skipping")
        end
        
        if not self.Functions.RegisterZonesForJob(self, i, garages) then
            for _type, garage in pairs(garages) do
                if _type == "Settings" then goto continue end
                if _type == "SpawnVehicle" then goto continue end
                if _type == "ParkingSpots" then goto continue end
                
                garage.name = _type .. "_" .. i
                garage.action = function() self.Functions.MarkerAction(self, _type, i) end
                ClearSpawnPoint(garage.pos)
                Debug("Registering marker " .. _type .. "_" .. i)
                CreateMarker(_type, garage)

                ::continue::
            end
        end

        ::skip::
    end
end

function ZTH.Functions.RegisterZonesForJob(self, i, garages)
    local found = false
    local Settings = garages.Settings
    
    if Settings.JobSettings then
        Debug("Registering job zone " .. i)
        if Settings.JobSettings.blip then
            if Settings.center then Settings.JobSettings.blip.pos = Settings.center end
            Settings.blip.confId = i
            CreateBlip(Settings.blip)
        else
            Debug("No blip found for job garage " .. i .. ", skipping")
        end
        
        if Settings.JobSettings.job then
            if self.PlayerData.job.name == Settings.JobSettings.job then
                for _type, garage in pairs(garages) do
                    if _type == "Settings" then goto continue end
                    if _type == "SpawnVehicle" then goto continue end
                    if _type == "ParkingSpots" then goto continue end
                    
                    garage.name = _type .. "_" .. i
                    garage.action = function() self.Functions.MarkerAction(self, _type, i) end
                    ClearSpawnPoint(garage.pos)
                    CreateMarker(_type, garage)
                    found = true

                    ::continue::
                end
            else
                Debug("Player is not in the correct job for garage " .. i .. ", skipping")
            end
        else
            Debug("No job found for garage " .. i .. ", skipping")
        end
    end
    return found
end

function ZTH.Functions.InitializeGarages(self, _id)
    for id, garage in pairs(self.Config.Garages) do
        if _id and _id ~= id then goto continue end
        if self.CloseGarage ~= id then goto continue end
        if not garage["ParkingSpots"] then goto continue end
        local spots = self.Tunnel.Interface.GetManagementGarageSpots(id)
        
        Debug("Initializing garage " .. id)
        for k, vehicle in pairs(spots) do
            ClearSpawnPoint(vehicle.config.pos)

            vehicle.id = tonumber(vehicle.id)
            if vehicle.state == 1 then
                local pos = garage["ParkingSpots"][vehicle.id].pos
                local heading = garage["ParkingSpots"][vehicle.id].heading
                if not heading then heading = pos.w end
                if not heading then Debug("Heading not found for vehicle " .. vehicle.plate .. " at " .. id .. " spot " .. vehicle.id) goto continue end
                local coords = vector4(pos.x, pos.y, pos.z, heading)
                
                SpawnVehicle(vehicle.model, function(veh)
                    Debug("Spawned vehicle " .. vehicle.plate .. " at " .. id .. " spot " .. vehicle.id)
                    SetVehicleOnGroundProperly(veh)
                    FreezeEntityPosition(veh, true)
                    SetEntityInvincible(veh, true)
                    -- fuel --
                    SetVehicleFuelLevel(veh, vehicle.fuel)
                    exports[self.Config.FuelResource]:SetFuel(veh, vehicle.fuel)
                    ----------
                    SetVehicleEngineHealth(veh, vehicle.engine)
                    SetVehicleBodyHealth(veh, vehicle.body)
                    SetVehicleNumberPlateText(veh, vehicle.plate)
                    if vehicle.user_id ~= self.PlayerData.citizenid then SetVehicleDoorsLocked(veh, 2) end
                    self.Core.Functions.SetVehicleProperties(veh, vehicle.mods)
                end, coords, false)
            else
                if vehicle.user_id == self.PlayerData.citizenid then
                    garage["ParkingSpots"][vehicle.id].occupiedData = vehicle
                    garage["ParkingSpots"][vehicle.id].occupied = garage["ParkingSpots"][vehicle.id].occupiedData.user_id
                    garage["ParkingSpots"][vehicle.id].name = "ParkingSpots_" .. vehicle.garage_id .. "_" .. vehicle.id
                    garage["ParkingSpots"][vehicle.id].action = function()
                        self.Functions.MarkerAction(self, "ParkingSpots", vehicle.garage_id, vehicle.id)
                    end
                    CreateMarker("ParkingSpots", garage["ParkingSpots"][vehicle.id])
                else
                    Debug("Skipped vehicle " .. vehicle.plate .. " at " .. id .. " spot " .. vehicle.id)
                end
            end
        end

        ::continue::
    end
end

function ZTH.Functions.MarkerAction(self, _type, id, spotid)
    if hasTimeout() then return end
    addTimeout(nil, self.Config.TimeoutBetweenInteractions)
    if spotid and _type == "ParkingSpots" then
        self.Functions.DepositVehicle(self, id, spotid)
    else
        Debug("MarkerAction: " .. _type .. " " .. id)

        if _type == "Manage" then
            if IsPedDriving() then
                return self.Core.Functions.Notify(L("ERROR_MANAGE_GARAGE"), 'error', 5000)
            end

            local managementTable = self.Tunnel.Interface.GetManagementGarageData(id)
            if self.Tunnel.Interface.CanBuyGarage(id) then
                self.NUI.Open({ screen = "property-buy", garageData = managementTable })
            else
                if self.Tunnel.Interface.IsOwnerOfGarage(id) then
                    self.NUI.Open({ screen = "garage-manage", garageData = managementTable })
                else
                    return self.Core.Functions.Notify(L("ERROR_NOT_OWNER"), 'error', 5000)
                end
            end
        end

        if _type == "TakeVehicle" then
            if IsPedDriving() then
                return self.Core.Functions.Notify(L("ERROR_CANT_TAKE_WHILE_DRIVING"), 'error', 5000)
            end

            self.Tunnel.Interface.UpdateVehiclesCacheForUser()
            local garageData = self.Tunnel.Interface.GetParkedVehicleList(id)
            self.NUI.Open({ screen = "list", garageData = { vehicles = garageData.vehicles } })
            if garageData.canManage then
                Debug("Showing manage button")
                local data = {}
                data.vehicles = {}
                data.levels = {}
                data.users = {}

                for k, v in pairs(self.Config.Garages[id].Settings.JobSettings.lists.cars) do
                    v.id = v.model
                    v.name = v.label
                    table.insert(data.vehicles, v)
                end
                
                data.users = self.Tunnel.Interface.GetGarageUsers(id)
                data.levels = self.Tunnel.Interface.GetGarageLevels(id)

                self.NUI.OpenSpecific({ action = "show-manage", value = garageData.canManage, data = data })
            end
        end

        if _type == "BuySpot" then
            if not self.Tunnel.Interface.IsGarageOwned(id) then
                return self.Core.Functions.Notify(L("ERROR_BUY_SPOT_NO_OWNER"), 'error', 5000)
            end

            if IsPedDriving() then
                return self.Core.Functions.Notify(L("ERROR_CANT_BUY_SPOT_WHILE_DRIVING"), 'error', 5000)
            end

            local managementTable = self.Tunnel.Interface.GetManagementGarageData(id)
            self.NUI.Open({ screen = "garage-buy", garageData = managementTable })
        end

        if _type == "Deposit" then
            self.Functions.DepositVehicle(self, id, spotid)
        end
    end
end

function ZTH.Functions.BuySpot(self, data)
    if not data.canBuy then
        -- todo: add debug serverside with client data???
        return self.Core.Functions.Notify(L("ERROR_UNAVAILABLE_BUY_SPOT"), 'error', 5000)
    end

    if self.Tunnel.Interface.BuySpot(data) then
        if hasTimeout() then return end
        addTimeout(nil, self.Config.TimeoutBetweenInteractions)

        self.Core.Functions.Notify(L("SUCCESS_BUY_SPOT"), 'success', 5000)
        self.Functions.Init()
        self.NUI.Close()
    else
        self.Core.Functions.Notify(L("ERROR_CANT_BUY_SPOT"), 'error', 5000)
    end
end

function ZTH.Functions.BuyVehicles(self, data)
    if hasTimeout() then return end
    addTimeout(nil, self.Config.TimeoutBetweenInteractions)
    self.NUI.Close()

    local toBuy = {}
    local totalPrice = 0
    if data.ranks then
        for _, rank in pairs(data.ranks) do
            for _, v in pairs(data.vehicles) do
                local hash = GetHashKey(v.model)
                local garageSettings = self.Config.Garages[rank.garage].Settings
                local platePrefix = garageSettings.JobSettings.platePrefix
                -- local newPlate = self.Tunnel.Interface.IsPlateValid(plateIndex)

                table.insert(toBuy, {
                    license = rank.job .. ":" .. rank.grade,
                    citizenid = rank.job .. ":" .. rank.grade,
                    model = v.model,
                    price = v.price,
                    job = rank.job,
                    hash = hash,
                    garage = rank.garage,
                    platePrefix = platePrefix,
                    mods = {},
                    state = 1
                })

                totalPrice = totalPrice + v.price
            end
        end
    end

    if data.officers then
        for _, officer in pairs(data.officers) do
            for _, v in pairs(data.vehicles) do
                local hash = GetHashKey(v.model)
                local garageSettings = self.Config.Garages[officer.garage].Settings
                local platePrefix = garageSettings.JobSettings.platePrefix
                -- local newPlate = self.Tunnel.Interface.IsPlateValid(plateIndex)

                table.insert(toBuy, {
                    license = officer.license,
                    citizenid = officer.id,
                    model = v.model,
                    price = v.price,
                    job = officer.job.name,
                    hash = hash,
                    garage = officer.garage,
                    platePrefix = platePrefix,
                    plate = nil,
                    mods = {},
                    state = 1
                })

                totalPrice = totalPrice + v.price
            end
        end
    end

    if self.Tunnel.Interface.BuyVehicles(toBuy, totalPrice) then
        self.Core.Functions.Notify(L("SUCCESS_VEHICLES_BOUGHT", totalPrice), 'success', 5000)
    else
        self.Core.Functions.Notify(L("ERROR_COMPANY_NO_MONEY"), 'error', 5000)
    end
end

function ZTH.Functions.DepositVehicle(self, id, spotid)
    local ped = PlayerPedId()
    local garageSettings = self.Config.Garages[id].Settings
    local drivingType = IsPedDriving()
    local vehicle = GetVehiclePedIsIn(ped, false)
    -- local plate = self.Core.Functions.GetPlate(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)

    if not drivingType then
        return self.Core.Functions.Notify(L("ERROR_NOT_IN_VEHICLE"), 'error', 5000)
    end

    if garageSettings.parkingType then
        if not garageSettings.parkingType[drivingType] then
            return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
        end
    end

    for _id, _garage in pairs(self.Config.Garages) do
        if _garage.Settings and _garage.Settings.JobSettings then
            local _garageSettings = _garage.Settings
            if string.sub(plate, 1, string.len(_garageSettings.JobSettings.platePrefix)) == _garageSettings.JobSettings.platePrefix then
                if id ~= _id then
                    return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
                end
            end
        end
    end

    -- means that this is a private parking spot
    if spotid then
        if self.Tunnel.Interface.CanDeposit(id, spotid, plate) then
            local model = GetEntityModel(vehicle)
            local hash = GetHashKey(vehicle)
            
            local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
            local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
            local totalFuel = exports[self.Config.FuelResource]:GetFuel(vehicle)

            local mods = self.Core.Functions.GetVehicleProperties(vehicle)
            local toDepositData = {
                body = bodyDamage,
                fuel = totalFuel,
                engine = engineDamage,
                plate = plate,
                mods = json.encode(mods),
            }

            -- walk out of the vehicle
            TaskLeaveVehicle(ped, vehicle, 0)
            Citizen.Wait(2000)
            -- self.Functions.Init()
            self.Tunnel.Interface.DepositVehicle(id, spotid, toDepositData)
            self.Tunnel.Interface.TellClientsToRefreshGarage(id)
            -- self.Core.Functions.DeleteVehicle(vehicle)
            if self.Config.IsAdvancedParkingInstalled then exports["AdvancedParking"]:DeleteVehicle(vehicle, false) end
            if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
            self.Core.Functions.Notify(L("SUCCESS_VEHICLE_DEPOSITED"), 'success', 5000)
        else
            return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
        end
    elseif not spotid then
        ZTH.Tunnel.Interface.UpdateVehiclesCacheForUser()

        if garageSettings.JobSettings then
            if self.PlayerData.job.name ~= garageSettings.JobSettings.job then
                return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
            end
            
            -- check if the plate starts with the plate prefix
            if string.sub(plate, 1, string.len(garageSettings.JobSettings.platePrefix)) ~= garageSettings.JobSettings.platePrefix then
                return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
            end
        end

        if self.Tunnel.Interface.OwnsCar(id, plate) then
            local model = GetEntityModel(vehicle)
            local hash = GetHashKey(vehicle)
            
            local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
            local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
            local totalFuel = exports[self.Config.FuelResource]:GetFuel(vehicle)

            local mods = self.Core.Functions.GetVehicleProperties(vehicle)
            local toDepositData = {
                body = bodyDamage,
                fuel = totalFuel,
                engine = engineDamage,
                plate = plate,
                mods = json.encode(mods),
            }

            -- walk out of the vehicle
            TaskLeaveVehicle(ped, vehicle, 0)
            Citizen.Wait(2000)
            self.Tunnel.Interface.DepositVehicle(id, spotid, toDepositData)
            -- self.Core.Functions.DeleteVehicle(vehicle)
            if self.Config.IsAdvancedParkingInstalled then exports["AdvancedParking"]:DeleteVehicle(vehicle, false) end
            if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
            self.Core.Functions.Notify(L("SUCCESS_VEHICLE_DEPOSITED"), 'success', 5000)
        else
            return self.Core.Functions.Notify(L("ERROR_NOT_OWN_CAR"), 'error', 5000)
        end
    else
        return self.Core.Functions.Notify(L("ERROR_CANT_DEPOSIT_HERE"), 'error', 5000)
    end
end

function ZTH.Functions.TakeVehicle(self, _data)
    local data = _data.car
    local ped = PlayerPedId()
    local spawnCoords = self.Config.Garages[data.garage].SpawnVehicle
    if not spawnCoords.heading then spawnCoords.heading = spawnCoords.pos.w end
    if not spawnCoords.heading then Debug("Heading not found for vehicle " .. data.plate .. " at " .. data.garage) return end
    local coords = vector4(spawnCoords.pos.x, spawnCoords.pos.y, spawnCoords.pos.z, spawnCoords.heading)
    -- check if the spawnpoint is free
    if not IsSpawnPointFree(coords, 5.0) then
        return self.Core.Functions.Notify(L("ERROR_SPAWNPOINT_NOT_FREE"), 'error', 5000)
    end

    if type(data.mods) == "string" then
        data.mods = json.decode(data.mods)
    end
    
    if self.Tunnel.Interface.TakeVehicle(data.plate, data.garage) then
        SpawnVehicle(data.model, function(vehicle)
            data.engineLevel = data.engineLevel * 10.0
            data.bodyLevel = data.bodyLevel * 10.0
            ZTH.NUI.Close()
            SetVehicleNumberPlateText(vehicle, data.plate)
            -- fuel --
            SetVehicleFuelLevel(vehicle, data.fuelLevel)
            exports[self.Config.FuelResource]:SetFuel(vehicle, data.fuelLevel)
            ----------
            SetVehicleEngineHealth(vehicle, data.engineLevel)
            SetVehicleBodyHealth(vehicle, data.bodyLevel)
            if data.mods and data.mods.plate then self.Core.Functions.SetVehicleProperties(vehicle, data.mods) end
            TriggerEvent(ZTH.Config.Events.SetVehicleOwner, data.plate)
            self.Core.Functions.Notify(L("SUCCESS_VEHICLE_TAKEN_OUT"), 'success', 5000)
        end, coords, true, true)
    else
        return self.Core.Functions.Notify(L("ERROR_CANT_TAKE_VEHICLE"), 'error', 5000)
    end
end

function ZTH.Functions.EnteredVehicle(vehicle, seat, vehDisplay)
    local mods = ZTH.Core.Functions.GetVehicleProperties(vehicle)
    local vehicleData = ZTH.Tunnel.Interface.GetParkedVehicleData(mods.plate)

    if vehicleData then
        if not vehicleData.spot_config.heading then vehicleData.spot_config.heading = vehicleData.spot_config.pos.w end
        if not vehicleData.spot_config.heading then Debug("Heading not found for vehicle " .. vehicleData.plate .. " at " .. vehicleData.garage_id) return end
        local ped = PlayerPedId()
        local garage_id = vehicleData.garage_id
        local vehCoords = GetEntityCoords(vehicle)
        ZTH.Tunnel.Interface.SetParkedVehicleState(vehicleData, 0)
        local coords = vector4(vehCoords.x, vehCoords.y, vehCoords.z, vehicleData.spot_config.heading)
        -- self.Core.Functions.DeleteVehicle(vehicle)
        DoScreenFadeOut(100)
        SetEntityVisible(ped, false)
        if ZTH.Config.IsAdvancedParkingInstalled then exports["AdvancedParking"]:DeleteVehicle(vehicle, false) end
        if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
        ZTH.Tunnel.Interface.TellClientsToRefreshGarage(garage_id)
        -- ZTH.Functions.Init()
        Citizen.Wait(1500)
        SetEntityVisible(ped, true)
        DoScreenFadeIn(100)
        SpawnVehicle(vehicleData.model, function(veh)
            SetVehicleNumberPlateText(veh, vehicleData.plate)
            -- fuel --
            SetVehicleFuelLevel(veh, vehicleData.fuel)
            exports[ZTH.Config.FuelResource]:SetFuel(veh, vehicleData.fuel)
            ----------
            SetVehicleEngineHealth(veh, vehicleData.engine)
            SetVehicleBodyHealth(veh, vehicleData.body)
            ZTH.Core.Functions.SetVehicleProperties(veh, vehicleData.mods)
            TriggerEvent(ZTH.Config.Events.SetVehicleOwner, mods.plate)
            ZTH.Core.Functions.Notify(L("SUCCESS_VEHICLE_TAKEN_OUT"), 'success', 5000)
        end, coords, true, true)
    else
        Debug("EnteredVehicle: Vehicle data not found, ignoring...")
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

function ZTH.Functions.UnloadVehicles(id)
    local configSpots = ZTH.Config.Garages[id].ParkingSpots
    for _, spot in pairs(configSpots) do
        ClearSpawnPoint(spot.pos)
    end
end

function ZTH.Functions.Init()
    ZTH.IsReady = ZTH.Tunnel.Interface.RequestReady()
    while not ZTH.IsReady do Wait(1000) end
    ZTH.PlayerData = ZTH.Core.Functions.GetPlayerData()

    ZTH.Functions.RegisterZones(ZTH)
    ZTH.Functions.InitializeGarages(ZTH)
    ZTH.Functions.InitImpounds(ZTH)
end

function ZTH.Functions.RefreshGarage(self, id)
    Debug("Refreshing garage " .. id .. " vehicles")
    self.Functions.UnloadVehicles(id)
    self.Functions.RegisterZones(self, id)
    self.Functions.InitializeGarages(self, id)
    self.Functions.InitImpounds(self)
end