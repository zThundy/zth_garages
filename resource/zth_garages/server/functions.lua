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
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `depotdescription` VARCHAR(500) DEFAULT NULL;",
        "ALTER TABLE `player_vehicles` ADD IF NOT EXISTS `depotprice` INT(11) DEFAULT '0';",

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
                `spot_id` INT(11) NOT NULL,
                `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `until` DATETIME NOT NULL,
                `player_name` VARCHAR(255) NOT NULL,
                FOREIGN KEY (`user_id`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    }

    ZTH.MySQL.ExecQuery("Create table if not exists and alter", MySQL.transaction.await, initTable)

    ZTH.Cache = {}
    ZTH.Cache.Garages = {}

    ZTH.Functions.PopulateFromJson(ZTH, -1)
    ZTH.Functions.FullUpdateCache(ZTH)
end

function ZTH.Functions.FullUpdateCache(self)
    -- get all the garages from the database
    self.Cache.Garages          =   self.MySQL.ExecQuery("Init - Get all garages", MySQL.Sync.fetchAll, "SELECT * FROM `garages`")
    self.Cache.GarageSpots      =   self.MySQL.ExecQuery("Init - Get all garage spots", MySQL.Sync.fetchAll, "SELECT * FROM `garages_spots`")
    self.Cache.PlayerVehicles   =   self.MySQL.ExecQuery("Init - Get all player vehicles", MySQL.Sync.fetchAll, "SELECT * FROM `player_vehicles`")
    self.Cache.Players          =   self.MySQL.ExecQuery("Init - Get all players", MySQL.Sync.fetchAll, "SELECT * FROM `players`")

    ZTH.Functions.AutoImpountVehicles(self)
    ZTH.Functions.AutoRemoveParkingSpots(self)

    -- set ready
    ZTH.IsReady = true
    -- this is sent for restart of the resource
    TriggerClientEvent(ZTH.Config.Events.ResourceInit, -1)
end

function ZTH.Functions.GetSpotFromGarageId(garageId, spotId)
    if type(garageId) ~= "string" then garageId = tostring(garageId) end
    if type(spotId) ~= "number" then spotId = tonumber(spotId) end

    for k, v in pairs(ZTH.Cache.GarageSpots) do
        if v.garage_id == garageId and v.spot_id == spotId then
            return v
        end
    end
end

function ZTH.Functions.AutoImpountVehicles(self)
    local setStateVehIds = ""
    local autoImpoundVehicles = ""

    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        local garage = self.Config.Garages[v.garage]
        local impound = self.Config.Impounds[v.garage]
        if not garage and not impound then
            Debug("AutoImpoundVehicles: [^1FATAL^0] No garage and not impound found for vehicle: " .. v.id)
            goto continue
        end

        if garage and not garage.Settings then
            Debug("AutoImpoundVehicles: [^1FATAL^0] No settings found for garage: " .. v.garage)
            goto continue
        end

        if garage and garage.Settings then
            local jobSettings = garage.Settings.JobSettings
            if jobSettings then
                if not jobSettings.impoundVehicles then
                    if string.sub(v.plate, 1, string.len(jobSettings.platePrefix)) == jobSettings.platePrefix and v.state ~= 1 then
                        v.state = 1
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

        if v.state == 0 and v.parking_spot == nil then
            v.garage = self.Config.DefaultImpound
            v.state = 1
            v.depotprice = 0
            -- redundant, but just to be sure
            v.parking_spot = nil

            if autoImpoundVehicles == "" then
                autoImpoundVehicles = tostring(v.id)
            else
                autoImpoundVehicles = autoImpoundVehicles .. ", " .. v.id
            end
        elseif v.parking_spot ~= nil then
            if garage.ParkingSpots and garage.Settings.autoImpoundOnExpire then
                local spot = self.Functions.GetSpotFromGarageId(v.garage, v.parking_spot)
                if spot then
                    if ConditionalDates(math.floor(spot["until"] / 1000), os.time()) then
                        v.garage = self.Config.DefaultImpound
                        v.state = 1
                        v.depotprice = 0
                        v.parking_spot = nil

                        if autoImpoundVehicles == "" then
                            autoImpoundVehicles = tostring(v.id)
                        else
                            autoImpoundVehicles = autoImpoundVehicles .. ", " .. v.id
                        end
                    else
                        Debug("AutoImpoundVehicles: [^3WARN^0] Parking spot is still valid for vehicle: " .. v.id)
                    end
                else
                    -- TODO: decide what to do here, for now, impound the vehicle
                    v.garage = self.Config.DefaultImpound
                    v.state = 1
                    v.depotprice = 0
                    v.parking_spot = nil
                    if autoImpoundVehicles == "" then
                        autoImpoundVehicles = tostring(v.id)
                    else
                        autoImpoundVehicles = autoImpoundVehicles .. ", " .. v.id
                    end
                    Debug("AutoImpoundVehicles: [^1FATAL^0] No spot found for vehicle: " .. v.id)
                end
            end
        end

        ::continue::
    end

    if setStateVehIds ~= "" then
        Debug("AutoImpoundVehicles - Setting state to 1 for vehicles: " .. setStateVehIds)
        self.MySQL.ExecQuery("AutoStateToOne", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = 1 WHERE `id` in (" .. setStateVehIds .. ")")
    end

    if autoImpoundVehicles ~= "" then
        Debug("AutoImpoundVehicles - Impounding vehicles: " .. autoImpoundVehicles)
        self.MySQL.ExecQuery("AutoImpoundVehicles", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `garage` = @garage, `state` = 1, `depotprice` = 0, `parking_spot` = NULL WHERE `id` in (" .. autoImpoundVehicles .. ")", {
            ['@garage'] = self.Config.DefaultImpound
        })
    end
end

function ZTH.Functions.AutoRemoveParkingSpots(self)
    for id, spot in pairs(self.Cache.GarageSpots) do
        if ConditionalDates(os.time(), math.floor(spot["until"] / 1000)) then
            Debug("AutoRemoveParkingSpots: [^2SUCCESS^0] Removing parking spot: " .. spot.spot_id)
            self.MySQL.ExecQuery("AutoRemoveParkingSpots", MySQL.Sync.execute, "DELETE FROM `garages_spots` WHERE `spot_id` = @spot_id", {
                ['@spot_id'] = spot.spot_id
            })
            
            for k, v in pairs(self.Cache.PlayerVehicles) do
                if v.parking_spot == spot.spot_id then
                    v.parking_spot = nil
                    Debug("AutoRemoveParkingSpots: [^2SUCCESS^0] Removing parking spot from vehicle: " .. v.id)
                    self.MySQL.ExecQuery("AutoRemoveParkingSpots", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `parking_spot` = NULL WHERE `id` = @id", {
                        ['@id'] = v.id
                    })
                end
            end
        else
            Debug("AutoRemoveParkingSpots: [^3WARN^0] Parking spot " .. spot.spot_id .. " is still valid")
        end
    end

    self.Functions.UpdateSingleCache(self, "garage_spots")
end

function ZTH.Functions.GetGarageFromCache(id)
    for k, v in pairs(ZTH.Cache.Garages) do
        if tostring(v.garage_id) == tostring(id) then
            return v
        end
    end
    return {}
end

function ZTH.Functions.ParseVehicle(data)
    local mods = json.decode(data.mods)
    if not mods then mods = {} end
    if not mods.fuelLevel then mods.fuelLevel = 100 end
    if not mods.engineHealth then mods.engineHealth = 1000 end
    if not mods.bodyHealth then mods.bodyHealth = 1000 end
    if not mods.model then mods.model = data.vehicle end
    if not mods.plate then mods.plate = data.plate end

    data.label = data.vehicle
    if ZTH.Core.Shared then
        local vehicle = ZTH.Core.Shared.Vehicles[data.label]
        if vehicle then
            data.label = vehicle.name
        end
    end

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
    Debug("UpdateSingleCache executing type - " .. type)
    if type == "garages" then
        ZTH.Cache.Garages = self.MySQL.ExecQuery("UpdateSingleCache - Get all garages", MySQL.Sync.fetchAll, "SELECT * FROM `garages`")
        Debug("UpdateSingleCache - Garages: " .. #ZTH.Cache.Garages)
    elseif type == "garage_spots" then
        ZTH.Cache.GarageSpots = self.MySQL.ExecQuery("UpdateSingleCache - Get all garage spots", MySQL.Sync.fetchAll, "SELECT * FROM `garages_spots`")
        Debug("UpdateSingleCache - Garage spots: " .. #ZTH.Cache.GarageSpots)
    elseif type == "player_vehicles" then
        ZTH.Cache.PlayerVehicles = self.MySQL.ExecQuery("UpdateSingleCache - Get all player vehicles", MySQL.Sync.fetchAll, "SELECT * FROM `player_vehicles`")
        Debug("UpdateSingleCache - Player vehicles: " .. #ZTH.Cache.PlayerVehicles)
    end
end

function ZTH.Functions.PopulateFromJson(self, source)
    if not self.Cache.ToSendSpots then
        self.Cache.ToSendSpots = {}
        local jsongarages = LoadResourceFile(GetCurrentResourceName(), "config.garages.json")
        if not jsongarages then
            Debug("PopulateFromJson: [^1FATAL^0] No garages found")
            return false
        end

        jsongarages = json.decode(jsongarages)
        for k, garage in pairs(self.Config.Garages) do
            if jsongarages[tostring(k)] then
                for key, v in pairs(jsongarages[tostring(k)]) do
                    if garage.ParkingSpots[tonumber(key)] then
                        Debug("PopulateFromJson: [^1FATAL^0] Parking spot defined in config for garage: " .. k)
                        goto continue
                    end

                    Debug("PopulateFromJson: Adding parking spot to garage: " .. k)
                    table.insert(garage.ParkingSpots, v)
                    table.insert(self.Cache.ToSendSpots, {
                        garage_id = k,
                        spot_id = tonumber(key),
                        pos = v.pos
                    })

                    ::continue::
                end
            end
        end
    end

    -- send to client side
    TriggerClientEvent(ZTH.Config.Events.UpdateGaragesParkingSpotsConfig, source, self.Cache.ToSendSpots)
    return true
end