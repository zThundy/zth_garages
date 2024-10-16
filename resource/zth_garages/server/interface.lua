ZTH.Tunnel = {}

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = {}
ZTH.Tunnel.bindInterface("zth_garages", "zth_garages_t", ZTH.Tunnel.Interface)

ZTH.Tunnel.Interface.RequestReady = function()
    return ZTH.IsReady
end

ZTH.Tunnel.Interface.OwnsCar = function(garage, plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate and v.citizenid == citizenid then
            return true
        end
    end
    return false
end

ZTH.Tunnel.Interface.CanDeposit = function(garage, spot, plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    if ZTH.Tunnel.Interface.OwnsCar(garage, plate) then
        Debug("CanDeposit: Player owns the vehicle")
        for k, v in pairs(ZTH.Cache.GarageSpots) do
            if v.garage_id == garage and tonumber(v.spot_id) == tonumber(spot) then
                Debug("CanDeposit: Spot exists")
                if v.user_id == citizenid then
                    Debug("CanDeposit: Player owns the spot")
                    -- check if v.until is passed, if so, return false
                    if v["until"] ~= nil and os.time() > v["until"] then
                        Debug("CanDeposit: Spot is expired")
                        return false
                    end
                    
                    return true
                end
            end
        end
    end
    return false
end

ZTH.Tunnel.Interface.DepositVehicle = function(garage, spot, data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == data.plate and v.citizenid == citizenid then
            v.garage = garage
            v.parking_spot = spot
            v.parking_date = os.time()
            v.body = data.mods.bodyHealth
            v.fuel = data.mods.fuelLevel
            v.engine = data.mods.engineHealth
            v.mods = data.mods
            v.status = {}
            v.state = 1

            ZTH.MySQL.ExecQuery("UpdateVehicle", MySQL.Sync.execute, 
                [[
                    UPDATE `player_vehicles`
                    SET
                        `garage` = @garage,
                        `parking_spot` = @spot_id,
                        `parking_date` = CURRENT_TIMESTAMP,
                        `body` = @body,
                        `fuel` = @fuel,
                        `engine` = @engine,
                        `status` = @status,
                        `mods` = @mods,
                        `state` = 1
                    WHERE
                        `plate` = @plate AND `citizenid` = @citizenid
                ]]
            , {
                ['@garage'] = garage,
                ['@spot_id'] = spot,
                ['@body'] = data.mods.bodyHealth,
                ['@fuel'] = data.mods.fuelLevel,
                ['@engine'] = data.mods.engineHealth,
                ['@status'] = json.encode({}),
                ['@mods'] = data.mods,
                ['@plate'] = data.plate,
                ['@citizenid'] = citizenid
            })
        end
    end
end

ZTH.Tunnel.Interface.GetParkedVehicleData = function(plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate and v.citizenid == citizenid and v.state == 1 then
            if v.parking_spot == nil then return false end
            
            return {
                plate = v.plate,
                state = v.state,
                model = v.vehicle,
                spot_id = v.parking_spot,
                garage_id = v.garage,
                spot_config = ZTH.Config.Garages[v.garage].ParkingSpots[tonumber(v.parking_spot)],
                mods = json.decode(v.mods)
            }
        end
    end
end

ZTH.Tunnel.Interface.IsOwnerOfGarage = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.Garages) do
        if v.user_id == citizenid and v.garage_id == id then
            return true
        end
    end
    return false
end

ZTH.Tunnel.Interface.GetOwnParkedVehicles = function(id, citizenid)
    if not citizenid then
        local Player = ZTH.Core.Functions.GetPlayer(source)
        if not Player then return end
        citizenid = Player.PlayerData.citizenid
    end

    local player = ZTH.MySQL.ExecQuery("GetOwnParkedVehicles - GetPlayers", MySQL.Sync.fetchAll, "SELECT * FROM `players` WHERE `citizenid` = @citizenid", {
        ['@citizenid'] = citizenid
    })

    local parkedVehicles = ZTH.MySQL.ExecQuery("GetOwnParkedVehicles", MySQL.Sync.fetchAll, [[
        SELECT pv.*, p.*, gs.*
        FROM player_vehicles pv
        JOIN players p ON pv.license = p.license
        JOIN garages_spots gs ON pv.garage = gs.garage_id
        WHERE pv.citizenid = @citizenid AND pv.garage = @garage_id
    ]], {
        ['@citizenid'] = citizenId,
        ['@garage_id'] = id
    })

    local _parkedVehicles = {}
    for k, v in pairs(parkedVehicles) do
        local displayName = json.decode(v.charinfo).firstname .. " " .. json.decode(v.charinfo).lastname
        table.insert(_parkedVehicles, {
            id = v.parking_spot,
            plate = v.plate,
            model = v.vehicle,
            garage = v.garage,
            name = displayName,
            fromDate = v.parking_date,
            toDate = v["until"]
        })
    end

    return _parkedVehicles
end

ZTH.Tunnel.Interface.GetParkedVehicles = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    -- local parkedVehicles = ZTH.MySQL.ExecQuery("Get parked vehicles", MySQL.Sync.fetchAll,
    --     [[
    --         SELECT
    --             `id`, `vehicle`, `plate`, `fuel`, `engine`, `body`,
    --             `state`, `garage`, `citizenid`, `mods`
    --         FROM `player_vehicles`
    --         WHERE `garage` = @garage
    --         AND `citizenid` = @citizenid
    --         AND `state` = 1
    --     ]]
    -- , {
    --     ['@garage'] = id,
    --     ["@citizenid"] = citizenId
    -- })

    
    local vehicles = {}
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.garage == id and v.citizenid == citizenId and v.state == 1 then
            local mods = json.decode(v.mods)
            local fuelLevel = math.floor(mods.fuelLevel)
            local engineLevel = math.floor(mods.engineHealth / 10)
            local bodyLevel = math.floor(mods.bodyHealth / 10)

            table.insert(vehicles, {
                id = v.id,
                garage = id,
                name = string.upper(v.vehicle),
                plate = v.plate,
                fuelLevel = fuelLevel,
                engineLevel = engineLevel,
                bodyLevel = bodyLevel,
                mods = json.decode(v.mods)
            })
        end
    end

    return vehicles
end

ZTH.Tunnel.Interface.TakeVehicle = function(plate, id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    local result = ZTH.MySQL.ExecQuery("TakeVehicle", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `player_vehicles` WHERE `plate` = @plate AND `citizenid` = @citizenid AND `garage` = @garage", {
        ['@plate'] = plate,
        ['@citizenid'] = citizenId,
        ['@garage'] = id
    })

    if result > 0 then
        ZTH.MySQL.ExecQuery("TakeVehicle", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = 0 WHERE `plate` = @plate AND `citizenid` = @citizenid AND `garage` = @garage", {
            ['@plate'] = plate,
            ['@citizenid'] = citizenId,
            ['@garage'] = id
        })
        return true
    else
        return false
    end
end

ZTH.Tunnel.Interface.GetManagementGarageSpots = function(id)
    local spots = {}
    for _, spot in pairs(ZTH.Cache.GarageSpots) do
        spot.spot_id = tonumber(spot.spot_id)
        
        for _, vehicle in pairs(ZTH.Cache.PlayerVehicles) do
            vehicle.state = tonumber(vehicle.state)
            vehicle.parking_spot = tonumber(vehicle.parking_spot)

            -- if spot.garage_id == id and vehicle.garage == id then
            if spot.garage_id == id and vehicle.garage == id and vehicle.state == 1 then
                if vehicle.parking_spot == spot.spot_id then
                    spots[spot.spot_id] = {
                        id = spot.spot_id,
                        state = vehicle.state,
                        user_id = spot.user_id,
                        garage_id = spot.garage_id,
                        price = spot.price,
                        fromDate = spot.date,
                        toDate = spot["until"],
                        name = spot.player_name,
                        plate = vehicle.plate,
                        model = vehicle.vehicle,
                        mods = json.decode(vehicle.mods)
                    }
                    break
                end
            end
        end

        if not spots[spot.spot_id] then
            spots[spot.spot_id] = {
                id = spot.spot_id,
                state = 0,
                user_id = spot.user_id,
                garage_id = spot.garage_id,
                price = spot.price,
                fromDate = spot.date,
                toDate = spot["until"],
                name = spot.player_name,
                plate = "NOT PARKED",
                model = "NOT PARKED",
                mods = {}
            }
        end
    end
    return spots
end

ZTH.Tunnel.Interface.GetManagementGarageData = function(id)
    local config = ZTH.Config.Garages[id]["Settings"]
    local configSpots = ZTH.Config.Garages[id]["ParkingSpots"]

    local spots = ZTH.Tunnel.Interface.GetManagementGarageSpots(id)
    local occupiedSlots = {}
    for k, v in pairs(spots) do
        table.insert(occupiedSlots, v.id)
    end

    local garageData = ZTH.Functions.GetGarageFromCahce(id)

    return {
        id = id,
        managementPrice = config.managementPrice,
        sellPrice = config.sellPrice,
        price = config.pricePerDay,
        occupied = occupiedSlots,
        spots = #configSpots,
        spotsData = spots,
        name = config.displayName,
        balance = garageData.balance,
        totEarning = garageData.total_earnings
    }
end

ZTH.Tunnel.Interface.UpdateVehiclesCacheForUser = function()
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local vehicles = ZTH.MySQL.ExecQuery("Update vehicles for user", MySQL.Sync.fetchAll, "SELECT * FROM `player_vehicles` WHERE `citizenid` = @citizenid", {
        ['@citizenid'] = citizenid
    })

    for k, v in pairs(vehicles) do
        for i, j in pairs(ZTH.Cache.PlayerVehicles) do
            if v.plate == j.plate and v.citizenid == citizenid then
                table.remove(ZTH.Cache.PlayerVehicles, i)
                break
            end
        end
    end

    for k, v in pairs(vehicles) do
        table.insert(ZTH.Cache.PlayerVehicles, v)
    end

    return
end

ZTH.Tunnel.Interface.SetParkedVehicleState = function(vehData, state)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == vehData.plate and v.citizenid == citizenid then
            Debug("SetParkedVehicleState: Setting state to " .. state .. " for " .. vehData.plate)
            v.state = state
            
            ZTH.MySQL.ExecQuery("SetParkedVehicleState", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = @state WHERE `plate` = @plate AND `citizenid` = @citizenid", {
                ['@state'] = state,
                ['@plate'] = vehData.plate,
                ['@citizenid'] = citizenid
            })
            break
        end
    end
end

ZTH.Tunnel.Interface.BuySpot = function(data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    
    local amountToRemove = tonumber(data.days) * ZTH.Config.Garages[data.parkingId]["Settings"].pricePerDay
    if Player.Functions.RemoveMoney("bank", amountToRemove) then
        local current_date = os.time()
        local until_time = current_date + (data.days * 86400)
        local until_date = os.date("%Y-%m-%d %H:%M:%S", until_time)

        table.insert(ZTH.Cache.GarageSpots, {
            spot_id = tostring(data.spotId),
            garage_id = tostring(data.parkingId),
            user_id = citizenid,
            date = os.time(),
            ["until"] = until_time,
            player_name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        })

        ZTH.MySQL.ExecQuery("BuySpot", MySQL.Sync.execute, 
            [[
                INSERT INTO `garages_spots` (`spot_id`, `garage_id`, `user_id`, `until`, `player_name`)
                VALUES (@spot_id, @garage_id, @user_id, @until, @player_name)
            ]]
        , {
            ['@spot_id'] = data.spotId,
            ['@garage_id'] = data.parkingId,
            ['@user_id'] = citizenid,
            ['@until'] = until_date,
            ['@player_name'] = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        })

        local garage = ZTH.Functions.GetGarageFromCahce(data.parkingId)
        garage.total_earnings = garage.total_earnings + amountToRemove
        garage.balance = garage.balance + amountToRemove

        ZTH.MySQL.ExecQuery("BuySpot", MySQL.Sync.execute, 
            [[
                UPDATE `garages`
                SET `total_earnings` = `total_earnings` + @amount,
                    `balance` = `balance` + @amount
                WHERE `garage_id` = @garage_id
            ]]
        , {
            ['@amount'] = amountToRemove,
            ['@garage_id'] = data.parkingId
        })

        return true
    else
        return false
    end
end

ZTH.Tunnel.Interface.BalanceAction = function(data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    
    if data.type == "deposit" then
        if Player.Functions.RemoveMoney("cash", data.amount) then
            local garage = ZTH.Functions.GetGarageFromCahce(data.id)
            garage.balance = garage.balance + data.amount
            ZTH.MySQL.ExecQuery("BalanceAction", MySQL.Sync.execute, "UPDATE `garages` SET `balance` = @balance WHERE `garage_id` = @garage_id AND user_id = @user_id", {
                ['@balance'] = garage.balance,
                ['@garage_id'] = data.id,
                ['@user_id'] = citizenid
            })
            return true
        end
    elseif data.type == "withdraw" then
        local garage = ZTH.Functions.GetGarageFromCahce(data.id)
        if garage.balance >= data.amount then
            garage.balance = garage.balance - data.amount
            ZTH.MySQL.ExecQuery("BalanceAction", MySQL.Sync.execute, "UPDATE `garages` SET `balance` = @balance WHERE `garage_id` = @garage_id AND user_id = @user_id", {
                ['@balance'] = garage.balance,
                ['@garage_id'] = data.id,
                ['@user_id'] = citizenid
            })
            Player.Functions.AddMoney("cash", data.amount)
            return true
        end
    end
    return false
end

ZTH.Tunnel.Interface.GetBalance = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local garage = ZTH.Functions.GetGarageFromCahce(id)
    return garage.balance
end