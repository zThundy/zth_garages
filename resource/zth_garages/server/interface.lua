ZTH.Tunnel = {}

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = {}
ZTH.Tunnel.bindInterface("zth_garages", "zth_garages_t", ZTH.Tunnel.Interface)

ZTH.Tunnel.Interface.RequestReady = function()
    return ZTH.IsReady
end

ZTH.Tunnel.Interface.TellClientsToRefreshGarage = function(id)
    TriggerClientEvent(ZTH.Config.Events.RefreshGarages, -1, id)
end

ZTH.Tunnel.Interface.OwnsCar = function(plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    ZTH.Functions.UpdateSingleCache(ZTH, "player_vehicles")
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        plate = string.gsub(plate, "%s+", "")
        v.plate = string.gsub(v.plate, "%s+", "")

        if string.match(v.plate, plate) then
            if v.citizenid == citizenid then
                return true
            elseif string.match(v.license, Player.PlayerData.job.name .. ":" .. Player.PlayerData.job.grade.level) then
            -- elseif v.license == Player.PlayerData.job.name .. ":" .. Player.PlayerData.job.grade.level then
                return true
            end
        end
    end
    return false
end

ZTH.Tunnel.Interface.CanDeposit = function(garage, spot, plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    if ZTH.Tunnel.Interface.OwnsCar(plate) then
        Debug("CanDeposit: Player owns the vehicle")
        for k, v in pairs(ZTH.Cache.GarageSpots) do
            if v.garage_id == garage and tonumber(v.spot_id) == tonumber(spot) then
                Debug("CanDeposit: Spot exists")
                if v.user_id == citizenid then
                    Debug("CanDeposit: Player owns the spot")
                    -- check if v.until is passed, if so, return false
                    if ConditionalDates(os.time(), math.floor(v["until"] / 1000)) then
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
        data.plate = string.gsub(data.plate, "%s+", "")

        if string.match(v.plate, data.plate) and (v.citizenid == citizenid or v.license == Player.PlayerData.job.name .. ":" .. Player.PlayerData.job.grade.level) then
            v.mods = json.decode(data.mods)
            v.garage = garage
            v.parking_spot = spot
            v.parking_date = os.time()
            v.body = data.mods.bodyHealth
            v.fuel = data.mods.fuelLevel
            v.engine = data.mods.engineHealth
            v.status = {}
            v.state = 1
            v.mods = data.mods
            v.depotprice = data.depotprice
            
            ZTH.MySQL.ExecQuery("UpdateVehicle - DepositVehicle", MySQL.Sync.execute, 
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
                        `depotprice` = @depotprice,
                        `state` = 1
                    WHERE
                        `plate` = @plate
                ]]
            , {
                ['@garage'] = garage,
                ['@spot_id'] = spot,
                ['@body'] = data.body,
                ['@fuel'] = data.fuel,
                ['@engine'] = data.engine,
                ['@status'] = json.encode({}),
                ['@mods'] = data.mods,
                ["@depotprice"] = data.depotprice,
                ['@plate'] = data.plate
            })

            if ZTH.Config.IsAdvancedParkingInstalled then
                exports["AdvancedParking"]:DeleteVehicleUsingData(nil, nil, data.plate, false)
            end
        else
            Debug("DepositVehicle: Player does not own the vehicle or is not driving it. Plate: " .. data.plate .. ". CID: " .. v.citizenid)
        end
    end
end

ZTH.Tunnel.Interface.GetParkedVehicleData = function(plate)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    Debug("GetParkedVehicleData: Getting data for " .. plate .. " " .. citizenid)
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate and v.citizenid == citizenid and v.state == 1 then
            if v.parking_spot == nil then return false end
            
            return {
                plate = v.plate,
                state = v.state,
                model = v.vehicle,
                fuel = v.fuel,
                engine = v.engine,
                body = v.body,
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

ZTH.Tunnel.Interface.IsGarageOwned = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    for k, v in pairs(ZTH.Cache.Garages) do
        if v.garage_id == id then
            return true
        end
    end
    return false
end

ZTH.Tunnel.Interface.CanBuyGarage = function(id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local isBought = true
    for k, v in pairs(ZTH.Cache.Garages) do
        if id == v.garage_id then
            isBought = false
            break
        end
    end

    return isBought
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

ZTH.Tunnel.Interface.GetParkedVehicleList = function(id)
    Debug("GetParkedVehicleList: Getting parked vehicles for garage " .. id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    local isJobGarage = false
    local canManage = false
    local garageSettings = ZTH.Config.Garages[id]["Settings"]
    if garageSettings.JobSettings then
        isJobGarage = true
        local jobSettings = garageSettings.JobSettings
        if jobSettings.manageGrades then
            local gradeLevel = Player.PlayerData.job.grade.level
            if jobSettings.manageGrades[tonumber(gradeLevel)] then
                canManage = true
            elseif jobSettings.manageGrades[tostring(gradeLevel)] then
                canManage = true
            end
        end
    end

    local vehicles = {}
    for k, v in pairs(ZTH.Cache.PlayerVehicles) do
        if not isJobGarage then
            if v.garage == id and v.citizenid == citizenId and v.state == 1 then
                local data = ZTH.Functions.ParseVehicle(v)
                table.insert(vehicles, {
                    id = data.id,
                    label = data.label,
                    garage = id,
                    name = data.vehicle,
                    model = data.vehicle,
                    plate = data.plate,
                    fuelLevel = data.fuelLevel,
                    engineLevel = data.engineLevel,
                    bodyLevel = data.bodyLevel,
                    mods = data.mods,
                    isImpounded = data.isImpounded,
                    impoundAmount = data.depotprice
                })
            end
        else
            local settings = garageSettings.JobSettings
            -- get all plates that begin with settings.platePrefix
            if v.garage == id and (v.state == 1 or not settings.shouldCheckForState) then
                local data = ZTH.Functions.ParseVehicle(v)

                if string.sub(v.plate, 1, string.len(settings.platePrefix)) == settings.platePrefix then
                    Debug("GetParkedVehicleList: Plate " .. v.plate .. " matches prefix " .. settings.platePrefix)
                    if v.citizenid == citizenId and not string.match(v.license, settings.job .. ":%d") then
                        Debug("GetParkedVehicleList: Found plate " .. v.plate .. " for " .. v.citizenid)
                        table.insert(vehicles, {
                            id = data.id,
                            label = data.label,
                            garage = id,
                            assignedTo = L("ASSIGNED_TO_YOU"),
                            name = data.vehicle,
                            model = data.vehicle,
                            plate = data.plate,
                            fuelLevel = data.fuelLevel,
                            engineLevel = data.engineLevel,
                            bodyLevel = data.bodyLevel,
                            mods = data.mods,
                            isImpounded = data.isImpounded,
                            impoundAmount = data.depotprice
                        })
                    elseif string.match(v.license, settings.job .. ":%d") and v.license == Player.PlayerData.job.name .. ":" .. Player.PlayerData.job.grade.level then
                        table.insert(vehicles, {
                            id = data.id,
                            label = data.label,
                            garage = id,
                            assignedTo = L("ASSIGNED_TO_GRADE"),
                            name = data.vehicle,
                            model = data.vehicle,
                            plate = data.plate,
                            fuelLevel = data.fuelLevel,
                            engineLevel = data.engineLevel,
                            bodyLevel = data.bodyLevel,
                            mods = data.mods,
                            isImpounded = data.isImpounded,
                            impoundAmount = data.depotprice
                        })
                    end
                else
                    Debug("GetParkedVehicleList: Plate " .. v.plate .. " does not match prefix " .. settings.platePrefix)
                end
            end
        end
    end

    return { 
        canManage = canManage,
        vehicles = vehicles
    }
end

ZTH.Tunnel.Interface.TakeVehicle = function(plate, id)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    local garageSettings = ZTH.Config.Garages[id]["Settings"]
    if not garageSettings then return false end

    if not ZTH.Tunnel.Interface.OwnsCar(plate) then return false end

    for _, v in pairs(ZTH.Cache.PlayerVehicles) do
        if v.plate == plate and v.garage == id then
            if garageSettings.JobSettings then
                local platePrefix = garageSettings.JobSettings.platePrefix
                if string.sub(plate, 1, string.len(platePrefix)) == platePrefix then
                    v.state = 0
                    ZTH.MySQL.ExecQuery("TakeVehicle - JobSettings", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = 0 WHERE `plate` = @plate AND `garage` = @garage", {
                        ['@plate'] = plate,
                        ['@garage'] = id
                    })
                    return true
                end
            end

            v.state = 0
            ZTH.MySQL.ExecQuery("TakeVehicle", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = 0 WHERE `plate` = @plate AND `citizenid` = @citizenid AND `garage` = @garage", {
                ['@plate'] = plate,
                ['@citizenid'] = citizenId,
                ['@garage'] = id
            })
            return true
        end
    end
end

ZTH.Tunnel.Interface.GetManagementGarageSpots = function(id)
    Debug("GetManagementGarageSpots: Getting spots for garage " .. id)
    local spots = {}
    for _, spot in pairs(ZTH.Cache.GarageSpots) do
        spot.spot_id = tonumber(spot.spot_id)
        local config = ZTH.Config.Garages[id]["ParkingSpots"][spot.spot_id]
        if not config then
            Debug("GetManagementGarageSpots: [^1FATAL^0] Config not found for spot " .. spot.spot_id .. ". Maybe spot is on DB but not in config?")
            goto continue
        end
        
        if spot.garage_id == id then
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
                            mods = json.decode(vehicle.mods),
                            fuel = vehicle.fuel,
                            engine = vehicle.engine,
                            body = vehicle.body,
                            config = config
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
                    fuel = 100,
                    engine = 1000,
                    body = 1000,
                    plate = "NOT PARKED",
                    model = "NOT PARKED",
                    mods = {},
                    config = config
                }
            end
        end

        ::continue::
    end

    local recomputedSpots = {}
    for k, v in pairs(spots) do
        table.insert(recomputedSpots, v)
    end
    return recomputedSpots
end

ZTH.Tunnel.Interface.GetManagementGarageData = function(id)
    local config = ZTH.Config.Garages[id]["Settings"]
    local configSpots = ZTH.Config.Garages[id]["ParkingSpots"]

    local spots = ZTH.Tunnel.Interface.GetManagementGarageSpots(id)
    local occupiedSlots = {}
    for k, v in pairs(spots) do
        table.insert(occupiedSlots, v.id)
    end

    local garageData = ZTH.Functions.GetGarageFromCache(id)
    if not garageData then
        garageData.balance = 0
        garageData.total_earnings = 0
    end

    return {
        id = id,
        managementPrice = config.managementPrice,
        sellPrice = config.sellPrice,
        price = config.pricePerDay,
        occupied = occupiedSlots,
        spots = #configSpots,
        spotsData = spots,
        name = config.displayName,
        balance = garageData.balance or 0,
        totEarning = garageData.total_earnings or 0
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
            
            ZTH.MySQL.ExecQuery("SetParkedVehicleState", MySQL.Sync.execute, "UPDATE `player_vehicles` SET `state` = @state WHERE `plate` = @plate", {
                ['@state'] = state,
                ['@plate'] = vehData.plate
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
            ["until"] = until_time * 1000,
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

        local garage = ZTH.Functions.GetGarageFromCache(data.parkingId)
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
            local garage = ZTH.Functions.GetGarageFromCache(data.id)
            garage.balance = garage.balance + data.amount
            ZTH.MySQL.ExecQuery("BalanceAction", MySQL.Sync.execute, "UPDATE `garages` SET `balance` = @balance WHERE `garage_id` = @garage_id AND user_id = @user_id", {
                ['@balance'] = garage.balance,
                ['@garage_id'] = data.id,
                ['@user_id'] = citizenid
            })
            return true
        end
    elseif data.type == "withdraw" then
        local garage = ZTH.Functions.GetGarageFromCache(data.id)
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

    local garage = ZTH.Functions.GetGarageFromCache(id)
    return garage.balance
end

ZTH.Tunnel.Interface.GetGarageLevels = function(id)
    local garage = ZTH.Config.Garages[id]
    if garage.Settings.JobSettings then
        if ZTH.Config.Shared.Jobs[garage.Settings.JobSettings.job] then
            local jobGrades = {}
            for k, v in pairs(ZTH.Config.Shared.Jobs[garage.Settings.JobSettings.job].grades) do
                table.insert(jobGrades, {
                    id = k,
                    grade = k,
                    label = v.name,
                    name = v.name,
                    job = garage.Settings.JobSettings.job,
                    garage = id,
                    isboss = v.isboss or false
                })
            end

            -- order by grade level
            table.sort(jobGrades, function(a, b)
                a.grade = tonumber(a.grade)
                b.grade = tonumber(b.grade)
                return a.grade < b.grade
            end)

            return jobGrades
        end
    end
    return {}
end

ZTH.Tunnel.Interface.GetGarageUsers = function(id)
    local garage = ZTH.Config.Garages[id]
    if garage.Settings.JobSettings then
        local jobPlayers = {}
        for _, v in pairs(ZTH.Cache.Players) do
            if type(v.job) == "string" then v.job = json.decode(v.job) end
            if type(v.charinfo) == "string" then  v.charinfo = json.decode(v.charinfo) end
            if v.job.name == garage.Settings.JobSettings.job then
                table.insert(jobPlayers, {
                    name = v.charinfo.firstname .. " " .. v.charinfo.lastname,
                    id = v.citizenid,
                    job = v.job,
                    license = v.license,
                    garage = id
                })
            end
        end
        return jobPlayers
    end
    return {}
end

ZTH.Tunnel.Interface.BuyVehicles = function(toBuy, totalAmount)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    local foundJob = toBuy[1].job
    Debug("BuyVehicles: Buying vehicles for " .. foundJob)
    
    if not foundJob then return false end
    local account = GetAccountMoney(foundJob)

    Debug("BuyVehicles: Account: " .. account .. " Total: " .. totalAmount)
    if account >= totalAmount then
        RemoveAccountMoney(foundJob, totalAmount)

        for _, v in pairs(toBuy) do
            local plateExists = false
            repeat
                plateExists = false
                v.plate = v.platePrefix .. MakeRandomNumber(4)
                for _, vehicle in pairs(ZTH.Cache.PlayerVehicles) do
                    if vehicle.plate == v.plate then
                        plateExists = true
                        break
                    end
                end
            until not plateExists

            -- check if v.citizenid contains :
            if string.find(v.citizenid, ":") then
                v.license = v.citizenid
                v.citizenid = citizenid
            end

            -- insert in cache
            table.insert(ZTH.Cache.PlayerVehicles, {
                plate = v.plate,
                vehicle = v.model,
                citizenid = v.citizenid,
                license = v.license,
                garage = v.garage,
                hash = v.hash,
                parking_spot = nil,
                parking_date = nil,
                body = 1000,
                fuel = 100,
                engine = 1000,
                status = {},
                mods = json.encode({}),
                state = 1
            })

            -- insert in db
            ZTH.MySQL.ExecQuery("BuyVehicles", MySQL.Sync.execute, 
                [[
                    INSERT INTO `player_vehicles` (`plate`, `hash`, `license`, `vehicle`, `citizenid`, `garage`, `parking_spot`, `parking_date`, `body`, `fuel`, `engine`, `status`, `mods`, `state`)
                    VALUES (@plate, @hash, @license, @vehicle, @citizenid, @garage, @parking_spot, @parking_date, @body, @fuel, @engine, @status, @mods, @state)
                ]]
            , {
                ['@plate'] = v.plate,
                ['@vehicle'] = v.model,
                ['@citizenid'] = v.citizenid,
                ["@license"] = v.license,
                ['@garage'] = v.garage,
                ["@hash"] = v.hash,
                ['@parking_spot'] = nil,
                ['@parking_date'] = nil,
                ['@body'] = 1000,
                ['@fuel'] = 100,
                ['@engine'] = 1000,
                ['@status'] = json.encode({}),
                ['@mods'] = json.encode({}),
                ['@state'] = 1
            })
        end

        return true
    end

    return false
end

ZTH.Tunnel.Interface.SellParking = function(data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid

    return false
end

ZTH.Tunnel.Interface.CanAffordGarage = function(data)
    local Player = ZTH.Core.Functions.GetPlayer(source)
    if not Player then return end

    local hasFullAmount = false
    local neededAmount = data.managementPrice
    if type(neededAmount) ~= "number" then neededAmount = tonumber(neededAmount) end
    local cashAmount = Player.Functions.GetMoney("cash")
    local bankAmount = Player.Functions.GetMoney("bank")
    if cashAmount + bankAmount < neededAmount then return false end

    -- remove money from cash, then from bank if cash is not enough
    if cashAmount >= neededAmount then
        hasFullAmount = true
        Player.Functions.RemoveMoney("cash", neededAmount)
    end

    if not hasFullAmount then
        Player.Functions.RemoveMoney("bank", neededAmount - cashAmount)
        Player.Functions.RemoveMoney("cash", cashAmount)
        hasFullAmount = true
    end

    if hasFullAmount then
        ZTH.MySQL.ExecQuery("CanAffordGarage - Bought Garage", MySQL.Sync.execute, "INSERT INTO `garages` (`garage_id`, `user_id`, `balance`, `total_earnings`) VALUES (@garage_id, @user_id, @balance, @total_earnings)", {
            ['@garage_id'] = data.id,
            ['@user_id'] = Player.PlayerData.citizenid,
            ['@balance'] = 0,
            ['@total_earnings'] = 0
        })

        table.insert(ZTH.Cache.Garages, {
            garage_id = data.id,
            user_id = Player.PlayerData.citizenid,
            balance = 0,
            total_earnings = 0
        })
    end

    return hasFullAmount
end

ZTH.Tunnel.Interface.ManageGarageButton = function(data)
    local action = data.action
    local spot = data.slot
    local pData = data.pData
    local _source = source

    Debug("ManageGarageButton: " .. action .. " for spot " .. spot.id .. " in garage " .. spot.garage_id)
    if action == "revoke" then
        for k, v in pairs(ZTH.Cache.GarageSpots) do
            if v.spot_id == spot.id and v.garage_id == spot.garage_id then
                Debug("ManageGarageButton: Revoking spot " .. spot.id .. " in garage " .. spot.garage_id)
                table.remove(ZTH.Cache.GarageSpots, k)

                ZTH.MySQL.ExecQuery("ManageGarageButton - Revoke", MySQL.Sync.execute, "DELETE FROM `garages_spots` WHERE `spot_id` = @spot_id AND `garage_id` = @garage_id", {
                    ['@spot_id'] = spot.id,
                    ['@garage_id'] = spot.garage_id
                })

                ZTH.Tunnel.Interface.SetParkedVehicleState({ plate = spot.plate }, 0)
                ZTH.Tunnel.Interface.TellClientsToRefreshGarage(spot.garage_id)
                TriggerClientEvent(ZTH.Config.Events.SpawnCarOnSpot, _source, pData, spot)
                return true
            end
        end
    elseif action == "renew" then
        -- renew spot for 1 day
        local current_date = math.floor(spot.toDate / 1000)
        local until_time = current_date + 86400
        local until_date = os.date("%Y-%m-%d %H:%M:%S", until_time)
        
        for k, v in pairs(ZTH.Cache.GarageSpots) do
            if v.spot_id == spot.id and v.garage_id == spot.garage_id then
                Debug("ManageGarageButton: Renewing spot " .. spot.id .. " in garage " .. spot.garage_id)
                v["until"] = until_time * 1000
                ZTH.MySQL.ExecQuery("ManageGarageButton - Renew", MySQL.Sync.execute, "UPDATE `garages_spots` SET `until` = @until WHERE `spot_id` = @spot_id AND `garage_id` = @garage_id", {
                    ['@until'] = until_date,
                    ['@spot_id'] = spot.id,
                    ['@garage_id'] = spot.garage_id
                })

                -- maybe not needed ??
                -- ZTH.Tunnel.Interface.TellClientsToRefreshGarage(spot.garage_id)
                return true
            end
        end
    end

    return false
end

ZTH.Tunnel.Interface.RequestJSONGarages = function()
    local player = source
    Debug("RequestJSONGarages: Sending garages to " .. player)
    return ZTH.Functions.PopulateFromJson(ZTH, player)
end