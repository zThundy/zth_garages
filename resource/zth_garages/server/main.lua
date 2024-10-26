Citizen.CreateThread(ZTH.Functions.Init)

-- AddEventHandler(ZTH.Config.Events.PlayerLogoutServer, function() ZTH.IsReady = false end)

AddEventHandler(ZTH.Config.Events.PlayerSetJobServer, function(job)
    for _, v in pairs(ZTH.Cache.Players) do
        if v.job == job then
            v.job = job
            Debug("Player: " .. v.name .. " has changed job to: " .. json.encode(v.job))
            break
        end
    end
end)

AddEventHandler(ZTH.Config.Events.PlayerLoadedServer, function(Player)
    local result = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `citizenid` = @citizenid", { ['@citizenid'] = Player.PlayerData.citizenid })
    if result[1] then
        -- check if the player already exists in the cache
        for _, v in pairs(ZTH.Cache.Players) do
            if v.citizenid == Player.PlayerData.citizenid then
                v = result[1]
                return
            end
        end

        table.insert(ZTH.Cache.Players, {
            citizenid = Player.PlayerData.citizenid,
            name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            job = result[1].job,
            job_grade = result[1].job_grade
        })
    end
end)


RegisterCommand("populateCarDebug", function()
    for i = 200, 300 do
        local plate = MakeRandomNumber(2) .. string.upper(MakeRandomString(3)) .. MakeRandomNumber(3)
        local data = {
            license = "license:e8686d26646df08121509642500f9372982a9000",
            citizenid = "FUZ94215",
            vehicle = "t20",
            hash = GetHashKey("t20"),
            mods = "{}",
            plate = plate,
            garage = "garage_multipiano",
            fuel = 100,
            engine = 1000,
            body = 1000,
            state = 1,
            parking_spot = i
        }

        ZTH.MySQL.ExecQuery("DebugAddVehicle", MySQL.Sync.execute, "INSERT INTO `player_vehicles` (`license`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `garage`, `fuel`, `engine`, `body`, `state`, `parking_spot`) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @fuel, @engine, @body, @state, @parking_spot)", {
            ['@license'] = data.license,
            ['@citizenid'] = data.citizenid,
            ['@vehicle'] = data.vehicle,
            ['@hash'] = data.hash,
            ['@mods'] = data.mods,
            ['@plate'] = data.plate,
            ['@garage'] = data.garage,
            ['@fuel'] = data.fuel,
            ['@engine'] = data.engine,
            ['@body'] = data.body,
            ['@state'] = data.state,
            ['@parking_spot'] = data.parking_spot
        })

        local current = os.time()
        local _until = current + 60 * 60 * 24 * 30
        local date = os.date("%Y-%m-%d %H:%M:%S", _until)

        ZTH.MySQL.ExecQuery("DebugAddSpot", MySQL.Sync.execute, "INSERT INTO `garages_spots` (`user_id`, `spot_id`, `garage_id`, `player_name`, `until`) VALUES (@citizenid, @spot, @garage_id, @player_name, @until)", {
            ['@citizenid'] = data.citizenid,
            ['@spot'] = data.parking_spot,
            ['@garage_id'] = data.garage,
            ['@player_name'] = "DebugAdd",
            ['@until'] = date
        })
    end

    Debug("Populated 200 vehicles")
end)