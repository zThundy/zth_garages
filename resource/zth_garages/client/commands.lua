ZTH.Commands = {}


ZTH.Functions.ParseArgs = function(args, requiredArgs)
    local parsedArgs = {}
    for i = 1, #requiredArgs do
        parsedArgs[requiredArgs[i]] = args[i]
    end
    return parsedArgs
end

ZTH.Commands.RegisterCommand = function(name, data, cb, isAdmin)
    local self = ZTH
    Debug("RegisterCommands: Registering command: " .. name)

    RegisterCommand(name, function(source, args)
        local fromServer = nil
        local args = ZTH.Functions.ParseArgs(args, data.requiredArgs)
        
        -- check if all requiredArgs are passed after parsing
        for i = 1, #data.requiredArgs do
            if not args[data.requiredArgs[i]] then
                Debug("RegisterCommands: Command '" .. name .. "' was called with missing arguments")
                return
            end
        end

        if data.goToServer then fromServer = self.Tunnel.Interface.CalledCommand(source, name, args) end
        if data.returnFromServer then
            cb(self, source, args, fromServer)
        else
            cb(self, source, args)
        end
    end, isAdmin or false)

    ZTH.Commands[name] = {
        name = name,
        action = cb,
        isAdmin = isAdmin or false
    }
end

ZTH.Commands.RegisterCommand("add", {
    goToServer = true,
    returnFromServer = true,
    requiredArgs = {
        "garage_id",
    }
}, function(self, source, args, response)
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    coords = vec4(coords.x, coords.y, coords.z, heading)

    if response then
        self.Tunnel.Interface.AddVehicleCoords(args.garage_id, coords)
    else
        self.Core.Functions.Notify(L("COMMANDS_GENERIC_ERROR"), "error", 5000)
    end
end)