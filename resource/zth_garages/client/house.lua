ZTH.Housing = {}
ZTH.Housing.Functions = {}
ZTH.Housing.Tunnel = {}
ZTH.ResourceName = "origen_housing"

ZTH.Housing.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Housing.Tunnel.Interface = ZTH.Housing.Tunnel.getInterface("zth_garages", "zth_garages_housing_t", "zth_garages_housing_t")

if not ZTH.Config.IsOrigenHousingInstalled then
    Debug("Origen Housing resource is not started, exiting...")
    return
end

function ZTH.Housing.Functions.Init(self)
    local citizenId = self.PlayerData.citizenid

    -- ZTH.Housing.Houses = exports['origen_housing']:getHouses()
    self.Housing.Houses = exports['origen_housing']:getPlayerHouses(citizenId)
    for _, v in pairs(self.Housing.Houses) do
        Debug("House: " .. v.name .. " found.")
        if self.Config.Houses[v.name] then
            local houseConfig = self.Config.Houses[v.name]
            if houseConfig.Enter then
                houseConfig.Enter.action = function() self.Functions.EnterHouse(self, v, houseConfig) end
                CreateMarker("EnterHouse", houseConfig.Enter)
            end
        end
    end
end

function ZTH.Housing.Functions.EnterGarage(house, houseCfg)
    
end