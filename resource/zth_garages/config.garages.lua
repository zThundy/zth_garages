
-- you can configure global settings for markers here
ZTH.Config.Markers = {
    Manage = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to open the garage",
        drawDistance = 10.0,
        control = "E",
        forceExit = true,
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
    },
    TakeVehicle = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to take the vehicle",
        drawDistance = 10.0,
        control = "E",
        forceExit = true,
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
    },
    ParkingSpots = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to park the vehicle",
        drawDistance = 10.0,
        control = "E",
        forceExit = true,
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
    }
}

-- you can configure global settings for blips here
ZTH.Config.Blips = {
    ["garage_1"] = {
        pos = vec3(0.0, 0.0, 0.0),
        sprite = 357,
        color = 1,
        display = 4,
        scale = 1.0,
        name = "Garage",
        shortRange = true,
    }
}

ZTH.Config.Garages = {
    ["garage_1"] = {
        Settings = {
            pricePerDay = 200,
            displayName = "Garage 1",
            managementPrice = 1000000,
            sellPrice = 5000,
        }
        -- You can override the global settings for this garage's blip here
        -- Blip = {
        --     pos = vec3(0.0, 0.0, 0.0),
        --     sprite = 357,
        --     color = 1,
        --     scale = 1.0,
        --     name = "Garage",
        --     shortRange = true,
        -- }
        -- For the marker, you can override the global settings like this, or you can just remove everything,
        -- leaving only the action and the position
        Manage = {
            pos = vec3(0.0, 0.0, 0.0),
            scale = vec3(1.0, 1.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to open the garage",
            drawDistance = 10.0,
            control = "E",
            forceExit = true,
            show3D = false,
            type = 20,
            color = { r = 255, g = 0, b = 0 },
            action = ZTH.Garages.Manage.action,
        },
        TakeVehicle = {
            pos = vec3(0.0, 0.0, 0.0),
            action = ZTH.Garages.TakeVehicle.action,
        },
        ParkingSpots = {
            {
                pos = vec3(0.0, 0.0, 0.0),
                heading = 0.0,
                vehicle = nil,
                taken = false,
            },
            {
                pos = vec3(0.0, 0.0, 0.0),
                heading = 0.0,
                vehicle = nil,
                taken = false,
            },
            {
                pos = vec3(0.0, 0.0, 0.0),
                heading = 0.0,
                vehicle = nil,
                taken = false,
            },
        }
    }
}