
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

ZTH.Config.DefaultImpoundValue = 5000
ZTH.Config.DefaultImpound = "impound_police"
ZTH.Config.Impounds = {
    ["impound"] = {
        Settings = {
            job = "police",
            -- if to show the blip in map, even if the player is not in the job
            alwaysShowBlip = true,
            -- if to show the take vehicle option even if the player is not in the job
            alwaysShowTakeVehicle = false,
            defaultPrice = 50000,
            defaultDescription = "Nessuna descrizione fornita",
            displayName = "Impound",
            blip = {
                sprite = 67,
                color = 2,
                scale = 0.5,
                name = "Impound",
                pos = vec3(408.19, -1641.04, 29.29),
                shortRange = true,
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
            pos = vec3(412.26, -1640.65, 28.64),
            heading = 356.7,
        }
    },
    ["impound_police"] = {
        Settings = {
            -- if to show the blip in map, even if the player is not in the job
            alwaysShowBlip = true,
            -- if to show the take vehicle option even if the player is not in the job
            alwaysShowTakeVehicle = true,
            defaultPrice = 50000,
            defaultDescription = "Nessuna descrizione fornita",
            displayName = "Impound Police",
        },
        TakeVehicleImpound = {
            pos = vec3(386.36, -1615.32, 29.29),
        },
        SpawnVehicleImpound = {
            pos = vec4(394.1, -1617.85, 28.66, 318.38),
        }
    },
}