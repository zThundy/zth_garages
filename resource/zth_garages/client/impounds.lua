
function ZTH.Functions.ImpoundAction(self, type, id, impound)
    if hasTimeout() then return end
    addTimeout(nil, self.Config.TimeoutBetweenInteractions)

    Debug("ImpoundAction: " .. type .. " " .. id)
    local Settings = self.Config.Impounds[id].Settings

    if type == "TakeVehicleImpound" then
        if Settings.job then
            if Settings.job ~= self.PlayerData.job.name then
                self.Core.Functions.Notify(L("ERROR_NOT_JOB"), "error")
                return
            end
        end

        if IsPedDriving() then
            self.Core.Functions.Notify(L("ERROR_CANT_OPEN_IMPOUND_WHILE_DRIVING"), "error")
            return
        end

        self.Tunnel.Interface.UpdateVehiclesCacheForUser()
        local vehicles = self.Tunnel.Interface.GetImpoundVehicleList(id)
        self.NUI.Open({ screen = "list", garageData = { vehicles = vehicles, isImpound = true } })
    end

    if type == "ImpoundZone" then
        if not IsPedDriving() then
            self.Core.Functions.Notify(L("ERROR_NOT_IN_VEHICLE"), "error")
            return
        end

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local plate = GetVehicleNumberPlateText(vehicle)
        local vehData = self.Tunnel.Interface.GetVehicleFromCache(plate)
        if not vehData then
            self.Core.Functions.Notify(L("ERROR_CANT_IMPUND"), "error")
            return
        end

        local defaultDescription = ""
        if Settings.defaultDescription then defaultDescription = Settings.defaultDescription end

        self.NUI.Open({
            screen = "impound-add",
            garageData = {
                plate = vehData.plate,
                garage = id,
                description = defaultDescription,
                money = Settings.defaultPrice,
                name = Settings.displayName,
                vehicle = vehData
            }
        })
    end
end

function ZTH.Functions.TakeImpoundedVehicle(self, car)
    Debug("TakeImpoundedVehicle: " .. json.encode(car))

    if type(car.mods) == "string" then car.mods = json.decode(car.mods) end
    local coords = self.Config.Impounds[car.garage].SpawnVehicleImpound.pos
    local heading = self.Config.Impounds[car.garage].SpawnVehicleImpound.heading
    if not heading then heading = coords.w end

    if self.Tunnel.Interface.OwnsCar(car.garage, car.plate) then
        if self.Tunnel.Interface.PayImpound(car) then
            self.NUI.Close()
            car.modelHash = GetHashKey(car.model)
            SpawnVehicle(car.modelHash, function(vehicle)
                SetVehicleNumberPlateText(vehicle, car.plate)
                self.Core.Functions.Notify(L("SUCCESS_VEHICLE_TAKEN_FROM_IMPOUND"), "success")
                SetVehicleEngineOn(vehicle, true, true, true)
                self.Core.Functions.SetVehicleProperties(vehicle, car.mods)
                self.Tunnel.Interface.UpdateVehicleState(car.id, 0)
            end, vec4(coords.x, coords.y, coords.z, heading), true, true)
        else
            self.Core.Functions.Notify(L("ERROR_NO_MONEY"), "error")
        end
    else
        self.Core.Functions.Notify(L("ERROR_NO_MONEY"), "error")
    end
end

function ZTH.Functions.ImpoundVehicle(self, data)
    Debug("ImpoundVehicle: " .. json.encode(data))

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(vehicle)

    if self.Tunnel.Interface.ImpoundVehicle(plate, data) then
        self.Core.Functions.Notify(L("SUCCESS_VEHICLE_IMPOUND"), "success")
        self.NUI.Close()
        
        -- walk out of the vehicle
        TaskLeaveVehicle(ped, vehicle, 0)
        Citizen.Wait(2000)
        self.Core.Functions.DeleteVehicle(vehicle)
    else
        self.Core.Functions.Notify(L("ERROR_NO_MONEY"), "error")
    end
end

function ZTH.Functions.onEnter(self, type, id, impound)
    self.Config.Impounds[id].isInImpound = true
end

function ZTH.Functions.onExit(self, type, id, impound)
    self.Config.Impounds[id].isInImpound = false
end

function ZTH.Functions.InitImpounds(self)
    local impounds = self.Config.Impounds
    local playerJob = self.PlayerData.job.name

    for k, impound in pairs(impounds) do
        Debug("Registering impound zone " .. k)
        if not impound.Settings then Debug("Settings is missing for impound " .. k) goto continue end
        if not impound.TakeVehicleImpound then Debug("TakeVehicleImpound is missing for impound " .. k) goto continue end
        if not impound.SpawnVehicleImpound then Debug("SpawnVehicleImpound is missing for impound " .. k) goto continue end

        if impound.Settings.blip then
            impound.Settings.blip.confId = k
            if impound.Settings.job then
                if impound.Settings.job == playerJob then
                    CreateBlip(impound.Settings.blip)
                elseif impound.Settings.alwaysShowBlip then
                    CreateBlip(impound.Settings.blip)
                end
            else
                CreateBlip(impound.Settings.blip)
            end
        end

        if impound.Settings.job and impound.Settings.job ~= playerJob then
            Debug("Impound " .. k .. " is not for this job")
            if impound.Settings.alwaysShowTakeVehicle then
                Debug("Showing take vehicle for impound " .. k .. " even if not in job")
                goto takeVehicle
            end
            goto continue
        end

        if impound.ImpoundZone and impound.ImpoundZone.show then
            impound.ImpoundZone.action = function() self.Functions.ImpoundAction(self, "ImpoundZone", k, impound) end
            impound.ImpoundZone.onEnter = function() self.Functions.onEnter(self, "ImpoundZone", k, impound) end
            impound.ImpoundZone.onExit = function() self.Functions.onExit(self, "ImpoundZone", k, impound) end
            CreateMarker("ImpoundZone", impound.ImpoundZone)
            ClearSpawnPoint(impound.ImpoundZone.pos)
        end

        ::takeVehicle::
        impound.TakeVehicleImpound.action = function() self.Functions.ImpoundAction(self, "TakeVehicleImpound", k, impound) end
        impound.TakeVehicleImpound.onEnter = function() self.Functions.onEnter(self, "TakeVehicleImpound", k, impound) end
        impound.TakeVehicleImpound.onExit = function() self.Functions.onExit(self, "TakeVehicleImpound", k, impound) end
        CreateMarker("TakeVehicleImpound", impound.TakeVehicleImpound)
        ClearSpawnPoint(impound.TakeVehicleImpound.pos)

        ::continue::
    end
end