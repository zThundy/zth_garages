function ZTH.Functions.InitImpounds(self)
    local impounds = self.Config.Impounds

    for k, impound in pairs(impounds) do
        if not impound.Settings then Debug("Settings is missing for impound " .. k) goto continue end
        if not impound.ImpoundZone then Debug("ImpoundZone is missing for impound " .. k) goto continue end
        if not impound.TakeVehicleImpound then Debug("TakeVehicleImpound is missing for impound " .. k) goto continue end
        if not impound.SpawnVehicleImpound then Debug("SpawnVehicleImpound is missing for impound " .. k) goto continue end

        if impound.Settings.blip then
            CreateBlip(impound.Settings.blip)
        end

        if impound.ImpoundZone.show then
            impound.ImpoundZone.action = function() self.Functions.ImpoundAction(self, "ImpoundZone", k, impound) end
            impound.ImpoundZone.onEnter = function() self.Functions.onEnter(self, "ImpoundZone", k, impound) end
            impound.ImpoundZone.onExit = function() self.Functions.onExit(self, "ImpoundZone", k, impound) end
            CreateMarker("ImpoundZone", impound.ImpoundZone)
            ClearSpawnPoint(impound.pos)
        end

        impound.TakeVehicleImpound.action = function() self.Functions.ImpoundAction(self, "TakeVehicleImpound", k, impound) end
        impound.TakeVehicleImpound.onEnter = function() self.Functions.onEnter(self, "TakeVehicleImpound", k, impound) end
        impound.TakeVehicleImpound.onExit = function() self.Functions.onExit(self, "TakeVehicleImpound", k, impound) end
        CreateMarker("TakeVehicleImpound", impound.TakeVehicleImpound)
        ClearSpawnPoint(impound.TakeVehicleImpound.pos)

        ::continue::
    end
end

function ZTH.Functions.ImpoundAction(self, type, id, impound)

end

function ZTH.Functions.onEnter(self, type, id, impound)
    self.Config.Impounds[id].isInImpound = true
end

function ZTH.Functions.onExit(self, type, id, impound)
    self.Config.Impounds[id].isInImpound = false
end