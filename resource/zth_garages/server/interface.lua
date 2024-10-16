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
        for k, v in pairs(ZTH.Cache.PlayerVehicles) do
            if v.user_id == citizenid and v.garage_id == garage and v.parking_spot == spot then
                if v["until"] > os.time() then
                    return true
                end
            end
        end
        return false
    end
    return false
end

ZTH.Tunnel.Interface.DepositVehicle = function(garage, spot, data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == data.plate and v.citizenid == citizenid then
            ZTH.Cache.PlayerVehicles[k].garage = garage
            ZTH.Cache.PlayerVehicles[k].parking_spot = spot
            ZTH.Cache.PlayerVehicles[k].parking_date = os.time()
            ZTH.Cache.PlayerVehicles[k].body = data.mods.bodyHealth
            ZTH.Cache.PlayerVehicles[k].fuel = data.mods.fuelLevel
            ZTH.Cache.PlayerVehicles[k].engine = data.mods.engineHealth
            ZTH.Cache.PlayerVehicles[k].mods = data.mods
            ZTH.Cache.PlayerVehicles[k].status = {}
            ZTH.Cache.PlayerVehicles[k].state = 1

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

ZTH.Tunnel.Interface.IsOwnerOfGarage = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.Garages) do
        print(json.encode(v))
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
        for _, vehicle in pairs(ZTH.Cache.PlayerVehicles) do
            if spot.garage_id == id and vehicle.garage == id and tostring(vehicle.parking_spot) == tostring(spot.spot_id) then
                table.insert(spots, {
                    id = spot.spot_id,
                    user_id = spot.user_id,
                    garage_id = spot.garage_id,
                    price = spot.price,
                    fromDate = spot.date,
                    toDate = spot["until"],
                    name = spot.player_name,
                    plate = vehicle.plate,
                    model = vehicle.vehicle,
                    mods = json.decode(vehicle.mods)
                })
            end
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

    local garageData = {}
    for k, v in pairs(ZTH.Cache.Garages) do
        if v.garage_id == id then
            garageData = v
            break
        end
    end

    return {
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