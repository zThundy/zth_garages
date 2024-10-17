Citizen.CreateThread(ZTH.Functions.Init)

RegisterCommand("kok", function(source, args)
    TriggerClientEvent("kok", source, args[1])
end)

AddEventHandler("QBCore:Server:OnJobUpdate", function(job)
    for _, v in pairs(ZTH.Cache.Players) do
        if v.job == job then
            print("Player: " .. v.name .. " has changed from: " .. json.encode(v.job))
            v.job = job
            print("Player: " .. v.name .. " has changed job to: " .. json.encode(v.job))
            break
        end
    end
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
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