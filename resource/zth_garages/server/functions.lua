ZTH.Tunnel = {}

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = {}
ZTH.Tunnel.bindInterface("zth_garages", "zth_garages_t", ZTH.Tunnel.Interface)

ZTH.Functions = {}
ZTH.MySQL = {}

function ZTH.MySQL.ExecQuery(msg, fn, query, parameters)
    local start = os.nanotime()
    local result = fn(query, parameters)
    local finish = os.nanotime()

    Debug(msg)
    Debug('Executed ' .. (type(query) == 'string' and 1 or #query) .. ' queries in ' .. (finish - start) / 1e6 .. 'ms')

    return result
end

function ZTH.Functions.Init()
    local initTable = {
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `parking_spot` VARCHAR(255) DEFAULT NULL;",
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `parking_date` DATETIME DEFAULT NULL;",
        [[
            CREATE TABLE IF NOT EXISTS `garages` (
                `user_id` VARCHAR(255) NOT NULL,
                `garage_id` VARCHAR(255) NOT NULL,
                `balance` INT(11) NOT NULL DEFAULT '0',
                `total_earnings` INT(11) NOT NULL DEFAULT '0',
                FOREIGN KEY (`user_id`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        -- crete foreign key on user_id and do it on players.citizenid
        [[
            CREATE TABLE IF NOT EXISTS `garages_spots` (
                `user_id` VARCHAR(255) NOT NULL DEFAULT '0',
                `garage_id` VARCHAR(255) NOT NULL,
                `spot_id` VARCHAR(255) NOT NULL,
                `price` INT(11) NOT NULL DEFAULT '0',
                `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `until` DATETIME NOT NULL,
                FOREIGN KEY (`user_id`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    }

    ZTH.MySQL.ExecQuery("Create table if not exists and alter", MySQL.transaction.await, initTable)

    -- insert all the garages from config.garages.lua in the garages table
    for garage, data in pairs(ZTH.Config.Garages) do
        -- check if the garage is already in the database
        local result = ZTH.MySQL.ExecQuery("Init - Check if garage exists", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `garages` WHERE `user_id` = @user_id AND `garage_id` = @garage_id", {
            ['@user_id'] = "0",
            ['@garage_id'] = garage
        })

        if result == 0 then
            ZTH.MySQL.ExecQuery("Init - Insert garage", MySQL.Sync.execute, "INSERT INTO `garages` (`user_id`, `garage_id`) VALUES (@user_id, @garage_id)", {
                ['@user_id'] = "0",
                ['@garage_id'] = garage
            })
        end
    end
end

ZTH.Tunnel.Interface.CanDeposit = function(garage, spot, plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    local result = ZTH.MySQL.ExecQuery("CanDeposit - OwnsParkingSpot", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `garages_spots` WHERE `user_id` = @user_id AND `garage_id` = @garage_id AND `spot_id` = @spot_id AND `until` > CURRENT_TIMESTAMP", {
        ['@user_id'] = citizenId,
        ['@garage_id'] = garage,
        ['@spot_id'] = spot
    })

    if result == 0 then return false end
    
    result = ZTH.MySQL.ExecQuery("CanDeposit - OwnsCar", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `player_vehicles` WHERE `plate` = @plate AND `citizenid` = @citizenid", {
        ['@plate'] = plate,
        ['@citizenid'] = citizenId
    })

    return result > 0
end

ZTH.Tunnel.Interface.DepositVehicle = function(garage, spot, data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    -- check if vehicle exists on the database, plate and citizenid
    local result = ZTH.MySQL.ExecQuery("DepositVehicle", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `player_vehicles` WHERE `plate` = @plate AND `citizenid` = @citizenid", {
        ['@plate'] = data.plate,
        ['@citizenid'] = citizenId
    })

    -- if vehicle exists, update the vehicle
    if result > 0 then
        ZTH.MySQL.ExecQuery("UpdateVehicle", MySQL.Sync.execute, [[
                UPDATE `player_vehicles`
                SET
                    `garage` = @garage,
                    `parking_spot` = @spot_id,
                    `parking_date` = CURRENT_TIMESTAMP
                    `body` = @body,
                    `fuel` = @fuel,
                    `engine` = @engine,
                    `status` = @status,
                    `mods` = @mods,
                    `state` = 1
                WHERE
                    `plate` = @plate AND `citizenid` = @citizenid
            ]], {
            ['@garage'] = garage,
            ['@spot_id'] = spot,
            ['@body'] = data.body,
            ["@fuel"] = data.fuel,
            ["@engine"] = data.engine,
            ["@status"] = data.status,
            ["@mods"] = data.mods,
            ['@plate'] = data.plate,
            ['@citizenid'] = citizenId
        })
    end
end

ZTH.Tunnel.Interface.GetGarageData = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    -- get all server data from the garage table
    local result = ZTH.MySQL.ExecQuery("GetGarageData", MySQL.Sync.fetchAll, "SELECT * FROM `garages` WHERE `user_id` = @user_id AND `garage_id` = @garage_id", {
        ['@user_id'] = citizenId,
        ['@garage_id'] = id
    })

    -- get all parked vehicles from the player_vehicles table and join the result with the players table using the license column
    local parkedVehicles = ZTH.MySQL.ExecQuery("GetGarageData - GetParkedVehicles", MySQL.Sync.fetchAll, [[
        SELECT
            pv.`id`,
            pv.`plate`,
            pv.`model`,
            pv.`garage`,
            pv.`parking_spot`,
            pv.`parking_date`,
            p.`charinfo`
        FROM
            `player_vehicles` pv
        LEFT JOIN
            `players` p
        ON
            pv.`citizenid` = p.`citizenid`
        WHERE
            pv.`citizenid` = @citizenid AND pv.`garage` = @garage_id
    ]], {
        ['@citizenid'] = citizenId,
        ['@garage_id'] = id
    })

    local _parkedVehicles = {}
    for k, v in pairs(parkedVehicles) do
        local displayName = json.decode(v.charinfo).firstname .. " " .. json.decode(v.charinfo).lastname
        _parkedVehicles.push({
            id: v.parking_spot,
            plate: v.plate,
            model: v.model,
            garage: v.garage,
            name: displayName,
            fromDate: v.parking_date
            -- add 14 days to the parking date
            toDate: v.parking_date + 14 * 24 * 60 * 60 * 1000
        })
    end

    return {
        balance = result[1].balance,
        totalEarnings = result[1].total_earnings,
        parkedVehicles = _parkedVehicles,
        occupiedSlots = #parkedVehicles
    }
end