
-- you can configure global settings for markers here
ZTH.Config.Markers = {
    Manage = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to open the garage",
        drawDistance = 40.0,
        control = "E",
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
    },
    BuySpot = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to buy a parking space",
        drawDistance = 40.0,
        control = "E",
        show3D = false,
        type = 1,
        color = { r = 255, g = 0, b = 0 },
    },
    TakeVehicle = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to take the vehicle",
        drawDistance = 40.0,
        control = "E",
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
    },
    ParkingSpots = {
        scale = vec3(0.8, 0.8, 0.8),
        msg = "Press ~INPUT_CONTEXT~ to park the vehicle",
        drawDistance = 40.0,
        control = "E",
        show3D = false,
        type = 36,
        color = { r = 150, g = 150, b = 255 },
    },
    Deposit = {
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to deposit the vehicle",
        drawDistance = 40.0,
        control = "E",
        show3D = false,
        type = 20,
        color = { r = 255, g =0, b = 0 },
    }
}

ZTH.Config.Garages = {
    ["garage_1"] = {
        Settings = {
            pricePerDay = 200,
            displayName = "Garage 1",
            managementPrice = 1000000,
            sellPrice = 5000,
            center = vec3(274.49, -329.74, 44.92),
            renderDistance = 10.0,
            blip = {
                pos = vec3(275.47, -345.14, 45.17),
                sprite = 357,
                color = 2,
                display = 4,
                scale = 1.0,
                name = "Garage Privato",
                shortRange = false,
            }
        },
        Manage = {
            pos = vec3(275.47, -345.14, 45.17),
            scale = vec3(1.0, 1.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to open the garage",
            control = "E",
            type = 1,
            color = { r = 255, g = 0, b = 0 },
        },
        BuySpot = {
            pos = vec3(276.46, -342.28, 44.92),
            scale = vec3(1.0, 1.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to buy a parking space",
            control = "E",
            type = 3,
            color = { r = 0, g = 0, b = 120 },
        },
        ParkingSpots = {
            {
                pos = vec3(265.88, -332.03, 44.92),
                heading = 65.64
            },
            {
                pos = vec3(267.65, -328.95, 44.92),
                heading = 65.64
            },
            {
                pos = vec3(269.19, -325.93, 44.92),
                heading = 65.64
            },
            {
                pos = vec3(270.38, -322.57, 44.92),
                heading = 65.64
            },
            {
                pos = vec3(271.55, -319.41, 44.92),
                heading = 65.64
            },
            {
                pos = vec3(282.3, -323.4, 44.92),
                heading = 248.52
            },
            {
                pos = vec3(281.38, -326.8, 44.92),
                heading = 244.76
            }
        }
    },
    ["garage_2"] = {
        Settings = {
            pricePerDay = 200,
            displayName = "Garage 2",
            managementPrice = 1000000,
            sellPrice = 5000,
            blip = {
                pos = vec3(289.15, -342.04, 44.92),
                sprite = 357,
                color = 1,
                display = 4,
                scale = 1.0,
                name = "Garage Pubblico",
                shortRange = false,
            }
        },
        TakeVehicle = {
            pos = vec3(292.86, -352.15, 44.99),
        },
        SpawnVehicle = {
            pos = vec3(284.15, -352.86, 44.41),
            heading = 158.43,
        },
        Deposit = {
            pos = vec3(289.15, -342.04, 44.92),
            scale = vec3(3.0, 3.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to deposit the vehicle",
            type = 1,
        },
    },
}