
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
    msg = "Press ~INPUT_CONTEXT~ to check your impounded vehicles",
    drawDistance = 40.0,
    control = "E",
    show3D = false,
    type = 20,
    color = { r = 255, g = 0, b = 0 },
}

ZTH.Config.DefaultImpoundValue = 50000
ZTH.Config.DefaultImpound = "impound"
ZTH.Config.Impounds = {
    ["impound"] = {
        Settings = {
            price = 5000,
            displayName = "Impound",
            blip = {
                sprite = 67,
                color = 2,
                scale = 1.0,
                name = "Impound",
                pos = vec3(408.19, -1641.04, 29.29),
            },
        },
        ImpoundZone = {
            show = true,
            pos = vec3(402.81, -1632.0, 29.29),
            scale = vec3(5.0, 5.0, 1.0),
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
}