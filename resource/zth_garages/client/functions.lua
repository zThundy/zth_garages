ZTH.Functions = {}

function ZTH.Functions.RegisterZones(self)
    Debug("Registering zones")
    for i, garages in pairs(self.Config.Garages) do
        Debug("Registering zone " .. i)
        -- ZTH.Functions.ReplaceDefaults(self, i)
        
        for _type, garage in pairs(garages) do
            if _type == "Settings" then goto continue end
            if _type == "ParkingSpots" then goto spots end
            
            garage.name = _type .. "_" .. i
            garage.action = function() self.Functions.MarkerAction(self, _type, i) end
            CreateMarker(_type, garage)
            goto continue

            ::spots::
            for j, spot in pairs(garage) do
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

function ZTH.Functions.MarkerAction(self, _type, id, spotid)
    if spotid then
        self.Functions.DepositVehicle(self, id, spotid)
    else
        Debug("MarkerAction: " .. _type .. " " .. id)
        self.NUI.Open({ type = _type, id = id })
        Citizen.Wait(5000)
        self.NUI.Close()
    end
end

function ZTH.Functions.DepositVehicle(self, id, spotid)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        self.Core.Functions.Notify("You are not in a vehicle", 'error', 5000)
        return Debug("You are not in a vehicle")
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = self.Core.Functions.GetPlate(vehicle)
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
end

function ZTH.Functions.Init()
    ZTH.PlayerData = ZTH.Core.Functions.GetPlayerData()
    -- print(json.encode(ZTH.PlayerData, { indent = true }))
    
    ZTH.Functions.RegisterZones(ZTH)
end