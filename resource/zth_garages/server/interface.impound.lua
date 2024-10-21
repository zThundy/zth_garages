
ZTH.Tunnel.Interface.GetImpoundVehicleList = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local impoundedVehicles = {}
    for _, v in pairs(ZTH.Cache.PlayerVehicles) do
        for impound, _ in pairs(ZTH.Config.Impounds) do
            if v.citizenid == citizenid and v.garage == impound then
                local data = ZTH.Functions.ParseVehicle(v)

                table.insert(impoundedVehicles, {
                    id = data.id,
                    garage = impound,
                    name = data.vehicle,
                    model = data.vehicle,
                    plate = data.plate,
                    fuelLevel = data.fuelLevel,
                    engineLevel = data.engineLevel,
                    bodyLevel = data.bodyLevel,
                    mods = data.mods,
                    impoundAmount = data.depotprice,
                    isImpounded = data.isImpounded,
                })
                break
            end
        end
    end
    return impoundedVehicles
end