
ZTH.Tunnel.Interface.GetImpoundVehicleList = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local Settings = ZTH.Config.Impounds[id].Settings
    if not Settings then return Debug("Impound settings not found for " .. id) end

    local impoundedVehicles = {}
    for _, v in pairs(ZTH.Cache.PlayerVehicles) do
        if (v.citizenid == citizenid or (Settings.job and Settings.job == Player.PlayerData.job.name)) and v.garage == id and v.state == 1 then
            local data = ZTH.Functions.ParseVehicle(v)

            table.insert(impoundedVehicles, {
                id = data.id,
                garage = id,
                impound = impound,
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
        end
    end
    return impoundedVehicles
end

ZTH.Tunnel.Interface.PayImpound = function(data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local toPayAmount = data.impoundAmount
    local money = Player.Functions.GetMoney("cash")
    local bank = Player.Functions.GetMoney("bank")

    if type(toPayAmount) ~= "number" then toPayAmount = tonumber(toPayAmount) end
    if not toPayAmount then return false end
    if type(money) ~= "number" then money = tonumber(money) end
    if not money then return false end
    if type(bank) ~= "number" then bank = tonumber(bank) end
    if not bank then return false end

    -- take money from cash first, if not enough, take from bank, if the sum is not enough, return false
    if money + bank < toPayAmount then return false end

    if money >= toPayAmount then
        Player.Functions.RemoveMoney("cash", toPayAmount, "impound")
        return true
    elseif money + bank >= toPayAmount then
        Player.Functions.RemoveMoney("cash", money, "impound")
        Player.Functions.RemoveMoney("bank", toPayAmount - money, "impound")
        return true
    else
        return false
    end
end

ZTH.Tunnel.Interface.ImpoundVehicle = function(plate, data)
    local impoundAmound = data.money
    if type(impoundAmound) ~= "number" then impoundAmound = tonumber(impoundAmound) end

    local Settings = ZTH.Config.Impounds[data.garage].Settings
    if not impoundAmound then impoundAmound = Settings.defaultPrice end
    -- should be the same as the one at the top, but lua is garbage, so it's there anyway
    if impoundAmount == 0 then impoundAmount = Settings.defaultPrice end

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate then
            v.garage = data.garage
            v.depotprice = impoundAmound
            v.state = 1
            v.depotdescription = data.description
            v.parking_spot = nil

            ZTH.MySQL.ExecQuery("ImpoundVehicle", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `garage` = @garage, `state` = @state, `depotprice` = @depotprice, `depotdescription` = @depotdescription, `parking_spot` = @parkingSpot WHERE `id` = @id", {
                ['@garage'] = v.garage,
                ['@state'] = v.state,
                ['@depotprice'] = v.depotprice,
                ['@depotdescription'] = v.depotdescription,
                ['@id'] = v.id,
                ["@parkingSpot"] = v.parking_spot
            })

            return true
        end
    end

    return false
end

ZTH.Tunnel.Interface.GetVehicleFromCache = function(plate)
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate then
            return v
        end
    end

    return false
end

ZTH.Tunnel.Interface.UpdateVehicleState = function(id, state)
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.id == id then
            v.state = state
            ZTH.MySQL.ExecQuery("UpdateVehicleState", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = @state WHERE `id` = @id", {
                ['@state'] = v.state,
                ['@id'] = v.id
            })
            return true
        end
    end

    return false
end