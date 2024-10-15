ZTH.Functions = {}

function ZTH.Functions.RegisterZones(self)
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
            for j, spot in pairs(garage) do
                ClearSpawnPoint(spot.pos)

                if spot.enabled and self.PlayerData.source == spot.enabled then
                    spot.name = _type .. "_" .. i .. "_" .. j
                    spot.action = function() self.Functions.MarkerAction(self, _type, i, j) end
                    CreateMarker(_type, spot)
                end
            end

            ::continue::
        end
    end
end

function ZTH.Functions.InitializeGarages(self)
    local spots = self.Tunnel.Interface.GetParkedVehicles()
end

function ZTH.Functions.MarkerAction(self, _type, id, spotid)
    if spotid then
        self.Functions.DepositVehicle(self, id, spotid)
    else
        Debug("MarkerAction: " .. _type .. " " .. id)

        if _type == "Manage" then
            if self.Tunnel.Interface.IsOwnerOfGarage(id) then
                local managementTable = self.Tunnel.Interface.GetManagementGarageData(id)
                self.NUI.Open({ screen = "garage-manage", garageData = managementTable })
            else
                self.Core.Functions.Notify("You are not the owner of this garage", 'error', 5000)
                return Debug("You are not the owner of this garage")
            end
        end

        if _type == "TakeVehicle" then
            self.Functions.OpenTakeVehicle(self, id)
        end

        if _type == "ParkingSpots" then
        end

        if _type == "Deposit" then
            self.Functions.DepositVehicle(self, id, spotid)
        end
    end
end

function ZTH.Functions.OpenTakeVehicle(self, id)
    local garageData = self.Tunnel.Interface.GetParkedVehicles(id)
    self.NUI.Open({ screen = "list", garageData = { vehicles = garageData, showManage = false } })
end

function ZTH.Functions.DepositVehicle(self, id, spotid)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        self.Core.Functions.Notify("You are not in a vehicle", 'error', 5000)
        return Debug("You are not in a vehicle")
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
            Citizen.Wait(3000)
            self.Core.Functions.DeleteVehicle(vehicle)
        else
            self.Core.Functions.Notify("You can't deposit here", 'error', 5000)
            return Debug("You can't deposit here")
        end
    elseif not spotid then
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
            Citizen.Wait(3000)
            self.Core.Functions.DeleteVehicle(vehicle)
        else
            self.Core.Functions.Notify("You don't own this car", 'error', 5000)
            return Debug("You don't own this car")
        end
    else
        self.Core.Functions.Notify("You can't deposit here", 'error', 5000)
        return Debug("You can't deposit here")
    end
end

function ZTH.Functions.TakeVehicle(self, _data)
    local data = _data.car
    local ped = PlayerPedId()
    local spawnCoords = self.Config.Garages[data.garage].SpawnVehicle
    local coords = vector4(spawnCoords.pos.x, spawnCoords.pos.y, spawnCoords.pos.z, spawnCoords.heading)
    -- check if the spawnpoint is free
    if not IsSpawnPointFree(coords, 5.0) then
        self.Core.Functions.Notify("The spawnpoint is not free", 'error', 5000)
        return Debug("The spawnpoint is not free")
    end
    
    if self.Tunnel.Interface.TakeVehicle(data.plate, data.garage) then
        self.Core.Functions.SpawnVehicle(data.mods.model, function(vehicle)
            ZTH.NUI.Close()
            self.Core.Functions.SetVehicleProperties(vehicle, data.mods)

            self.Core.Functions.Notify("Vehicle taken from the garage", 'success', 5000)
        end, coords, true, true)
    else
        self.Core.Functions.Notify("You can't take this vehicle", 'error', 5000)
        return Debug("You can't take this vehicle")
    end
end

function ZTH.Functions.Init()
    ZTH.PlayerData = ZTH.Core.Functions.GetPlayerData()
    -- print(json.encode(ZTH.PlayerData, { indent = true }))
    
    ZTH.Functions.InitializeGarages(ZTH)
    ZTH.Functions.RegisterZones(ZTH)
end