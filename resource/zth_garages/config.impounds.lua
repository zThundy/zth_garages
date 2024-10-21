
ZTH.Config.Markers["ImpoundZone"] = {
    scale = vec3(1.0, 1.0, 1.0),
    msg = "Press ~INPUT_CONTEXT~ to impound the vehicle",
    drawDistance = 40.0,
    control = "E",
    show3D = false,
    type = 20,
    color = { r = 255, g = 0, b = 0 },
}

ZTH.Config.Markers["TakeVehicleImpound"] = {
    scale = vec3(1.0, 1.0, 1.0),
    msg = "Press ~INPUT_CONTEXT~ to take the vehicle",
    drawDistance = 40.0,
    control = "E",
    show3D = false,
    type = 20,
    color = { r = 255, g = 0, b = 0 },
}

ZTH.Config.DefaultImpound = "impound"
ZTH.Config.Impounds = {
    ["impound"] = {
        Settings = {
            price = 5000,
            displayName = "Impound",
            blip = {
                sprite = 67,
                color = 1,
                scale = 1.0,
                name = "Impound",
                pos = vec3(408.19, -1641.04, 29.29),
            },
        },
        ImpoundZone = {
            show = false,
            pos = vec3(410.04, -1623.3, 29.29),
            scale = vec3(3.0, 3.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to impound the vehicle",
            type = 1,
        },
        TakeVehicleImpound = {
            pos = vec3(395.15, -1640.29, 29.29),
        },
        SpawnVehicleImpound = {
            pos = vec3(401.53, -1632.84, 29.29),
            heading = 306.71,
        }
    },
    ["impound2"] = {
        Settings = {
            price = 5000,
            displayName = "Impound 2",
            blip = {
                sprite = 67,
                color = 2,
                scale = 1.0,
                shortRange = true,
                name = "Impound",
                pos = vec3(413.38, -1633.54, 29.29),
            },
        },
        ImpoundZone = {
            show = false,
            pos = vec3(416.8, -1642.2, 29.29),
            scale = vec3(3.0, 3.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to impound the vehicle",
            type = 1,
        },
        TakeVehicleImpound = {
            pos = vec3(395.15, -1640.29, 29.29),
        },
        SpawnVehicleImpound = {
            pos = vec3(401.53, -1632.84, 29.29),
            heading = 306.71,
        }
    }
}