ZTH.Commands = {}

ZTH.Commands.RegisterCommandsHandler = function(name, cb)
    local self = ZTH
    Debug("RegisterCommands: Registering command: " .. name)

    ZTH.Commands[name] = {
        name = name,
        action = cb
    }
end

ZTH.Tunnel.Interface.CalledCommand = function(source, name, args)
    if ZTH.Commands[name] then
        return ZTH.Commands[name].action(ZTH, source, args)
    end
end

ZTH.Commands.RegisterCommandsHandler("add", function(self, source, args)
    Debug("RegisterCommands: Command 'add' was called from client side")
    local garage = self.Config.Garages[args.garage_id]

    if not args then
        Debug("RegisterCommands: Command 'add' was called with missing arguments")
        return false
    end
    if not garage then
        Debug("RegisterCommands: Command 'add' was called with invalid garage id")
        return false
    end
    if not garage.ParkingSpots then
        Debug("RegisterCommands: Command 'add' was called with invalid garage id")
        return false
    end

    return true
end)

ZTH.Tunnel.Interface.AddVehicleCoords = function(garage_id, coords)
    local garage = ZTH.Config.Garages[garage_id]
    if not garage then
        Debug("RegisterCommands: Command 'add' was called with invalid garage id")
        return
    end
    if not garage.ParkingSpots then
        Debug("RegisterCommands: Command 'add' was called with invalid garage id")
        return
    end

    local spots = garage.ParkingSpots
    table.insert(spots, {
        pos = coords
    })
    garage.ParkingSpots = spots
    ZTH.Config.Garages[garage_id] = garage
    -- write config.garages.lua file

    if not LoadResourceFile(GetCurrentResourceName(), "config.garages.json") then
        SaveResourceFile(GetCurrentResourceName(), "config.garages.json", "", -1)
    end
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config.garages.json")
    if string.len(configFile) == 0 then configFile = "{}" end
    if not configFile then configFile = "{}" end
    local config = json.decode(configFile)
    config[garage_id] = garage.ParkingSpots
    SaveResourceFile(GetCurrentResourceName(), "config.garages.json", json.encode(config, { indent = true }), -1)
end