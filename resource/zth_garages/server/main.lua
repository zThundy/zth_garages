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