ZTH.Functions = {}
ZTH.MySQL = {}

function ZTH.MySQL.ExecQuery(msg, fn, query, parameters)
    local start = os.nanotime()
    local result = fn(query, parameters)
    local finish = os.nanotime()

    Debug(msg .. ' > Executed ' .. (type(query) == 'string' and 1 or #query) .. ' queries in ' .. (finish - start) / 1e6 .. 'ms')
    return result
end

function ZTH.Functions.Init()
    local initTable = {
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `parking_spot` VARCHAR(255) DEFAULT NULL;",
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `parking_date` DATETIME DEFAULT CURRENT_TIMESTAMP;",
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
                `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `until` DATETIME NOT NULL,
                `player_name` VARCHAR(255) NOT NULL,
                FOREIGN KEY (`user_id`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    }

    ZTH.MySQL.ExecQuery("Create table if not exists and alter", MySQL.transaction.await, initTable)

    -- insert all the garages from config.garages.lua in the garages table
    for garage, data in pairs(ZTH.Config.Garages) do
        -- check if the garage is already in the database
        local result = ZTH.MySQL.ExecQuery("Init - Check if garage exists", MySQL.Sync.fetchScalar, "SELECT COUNT(*) FROM `garages` WHERE `garage_id` = @garage_id", {
            ['@garage_id'] = garage
        })

        if result == 0 then
            ZTH.MySQL.ExecQuery("Init - Insert garage", MySQL.Sync.execute, "INSERT INTO `garages` (`user_id`, `garage_id`) VALUES (@user_id, @garage_id)", {
                ['@user_id'] = "0",
                ['@garage_id'] = garage
            })
        end
    end

    ZTH.Cache = {}
    ZTH.Cache.Garages = {}

    ZTH.Functions.FullUpdateCache(ZTH)
end

function ZTH.Functions.FullUpdateCache(self)
    -- get all the garages from the database
    self.Cache.Garages          =   self.MySQL.ExecQuery("Init - Get all garages", MySQL.Sync.fetchAll, "SELECT * FROM `garages`")
    self.Cache.GarageSpots      =   self.MySQL.ExecQuery("Init - Get all garage spots", MySQL.Sync.fetchAll, "SELECT * FROM `garages_spots`")
    self.Cache.PlayerVehicles   =   self.MySQL.ExecQuery("Init - Get all player vehicles", MySQL.Sync.fetchAll, "SELECT * FROM `player_vehicles`")
    self.Cache.Players          =   self.MySQL.ExecQuery("Init - Get all players", MySQL.Sync.fetchAll, "SELECT * FROM `players`")

    -- set ready
    ZTH.IsReady = true
    -- this is sent for restart of the resource
    TriggerClientEvent("zth_garages:client:Init", -1)

    ZTH.Functions.AutoImpountVehicles(self)
end

function ZTH.Functions.AutoImpountVehicles(self)
    local setStateVehIds = ""

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        local garage = self.Config.Garages[v.garage]
        if garage and garage.Settings then
            local jobSettings = garage.Settings.JobSettings
            if jobSettings then
                if not jobSettings.impoundVehicles then
                    if string.sub(v.plate, 1, string.len(jobSettings.platePrefix)) == jobSettings.platePrefix and v.state ~= 1 then
                        v.state = 1
                        -- create a string for the query like v.id in (1, 2, 3).
                        -- if it's the last one, don't add a comma
                        if setStateVehIds == "" then
                            setStateVehIds = tostring(v.id)
                        else
                            setStateVehIds = setStateVehIds .. ", " .. v.id
                        end
                        goto continue
                    end
                end
            end
        end

        if v.state == 0 and v.garage ~= "impound" and v.parking_spot == nil then
            v.garage = "impound"
            self.MySQL.ExecQuery("AutoImpoundVehicles", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `garage` = @garage WHERE `id` = @id", {
                ['@garage'] = v.garage,
                ['@id'] = v.id
            })
        elseif v.parking_spot == nil then
            -- 4 later cause not bothered enough now
            -- check if veh is actually parked in the spot and the until date is still valid.
            -- else imound the mfk
        end

        ::continue::
    end

    if setStateVehIds ~= "" then
        Debug("AutoImpoundVehicles - Setting state to 1 for vehicles: " .. setStateVehIds)
        self.MySQL.ExecQuery("AutoStateToOne", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = 1 WHERE `id` in (" .. setStateVehIds .. ")")
    end
end

function ZTH.Functions.GetGarageFromCahce(id)
    for k, v in pairs(ZTH.Cache.Garages) do
        if tostring(v.garage_id) == tostring(id) then
            return v
        end
    end
end

function ZTH.Functions.ParseVehicle(data)
    local mods = json.decode(data.mods)
    if not mods then mods = {} end
    if not mods.fuelLevel then mods.fuelLevel = 100 end
    if not mods.engineHealth then mods.engineHealth = 1000 end
    if not mods.bodyHealth then mods.bodyHealth = 1000 end
    if not mods.model then mods.model = data.vehicle end
    if not mods.plate then mods.plate = data.plate end

    data.model = data.vehicle
    data.vehicle = string.upper(data.vehicle)

    local fuelLevel = math.floor(mods.fuelLevel)
    local engineLevel = math.floor(mods.engineHealth / 10)
    local bodyLevel = math.floor(mods.bodyHealth / 10)

    data.fuelLevel = fuelLevel
    data.engineLevel = engineLevel
    data.bodyLevel = bodyLevel
    data.depotprice = tonumber(data.depotprice)
    if type(data.depotprice) ~= "number" then data.depotprice = ZTH.Config.DefaultImpoundValue end

    for k, v in pairs(ZTH.Config.Impounds) do
        if data.garage == k then
            data.isImpounded = true
            break
        end
    end

    return data
end

function ZTH.Functions.UpdateSingleCache(self, type)
    Debug("UpdateSingleCache - " .. type)
    if type == "garages" then
        ZTH.Cache.Garages = self.MySQL.ExecQuery("UpdateSingleCache - Get all garages", MySQL.Sync.fetchAll, "SELECT * FROM `garages`")
    elseif type == "garage_spots" then
        ZTH.Cache.GarageSpots = self.MySQL.ExecQuery("UpdateSingleCache - Get all garage spots", MySQL.Sync.fetchAll, "SELECT * FROM `garages_spots`")
    elseif type == "player_vehicles" then
        ZTH.Cache.PlayerVehicles = self.MySQL.ExecQuery("UpdateSingleCache - Get all player vehicles", MySQL.Sync.fetchAll, "SELECT * FROM `player_vehicles`")
    end
end