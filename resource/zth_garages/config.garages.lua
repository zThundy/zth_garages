
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
            parkingType = {
                ["car"] = true,
                ["taxi"] = true,
                ["bike"] = true,
                ["bicycle"] = true,
                ["quadbike"] = true,
                ["vehicle"] = true,
                ["boat"] = false,
                ["heli"] = true,
                ["plane"] = false,
                ["police"] = false,
                ["boat"] = true,
                ["sub"] = false
            },
            autoImpoundOnExpire = true,
            pricePerDay = 200,
            displayName = "Garage 1",
            managementPrice = 1000000,
            sellPrice = 5000,
            center = vec3(274.49, -329.74, 44.92),
            renderDistance = 100.0,
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
                pos = vec4(266.26, -332.18, 44.95, 249.50)
            },
            {
                pos = vec4(267.69, -329.09, 44.95, 249.50)
            },
            {
                pos = vec4(268.59, -325.67, 44.95, 249.50)
            },
            {
                pos = vec4(269.98, -322.50, 44.95, 249.50)
            },
            {
                pos = vec4(271.26, -319.40, 44.95, 249.50)
            },
            {
                pos = vec4(277.71, -340.20, 44.95, 69.70)
            },
            {
                pos = vec4(278.83, -336.88, 44.95, 69.70)
            },
            {
                pos = vec4(279.60, -333.67, 44.95, 69.70)
            },
            {
                pos = vec4(280.85, -330.23, 44.95, 69.70)
            },
            {
                pos = vec4(281.80, -327.00, 44.95, 69.70)
            },
            {
                pos = vec4(282.63, -323.67, 44.95, 69.70)
            },
            {
                pos = vec4(283.16, -342.10, 44.95, 247.78)
            },
            {
                pos = vec4(284.59, -339.07, 44.95, 248.86)
            },
            {
                pos = vec4(285.54, -335.82, 44.95, 248.86)
            },
            {
                pos = vec4(287.05, -332.54, 44.95, 248.86)
            },
            {
                pos = vec4(288.40, -329.34, 44.95, 248.86)
            },
            {
                pos = vec4(289.11, -326.02, 44.95, 248.86)
            },
            {
                pos = vec4(292.42, -349.54, 44.95, 69.14)
            },
            {
                pos = vec4(294.27, -346.26, 44.95, 69.14)
            },
            {
                pos = vec4(295.38, -343.06, 44.95, 69.14)
            },
            {
                pos = vec4(296.14, -339.73, 44.95, 69.14)
            },
            {
                pos = vec4(297.08, -336.39, 44.95, 69.14)
            },
            {
                pos = vec4(298.37, -333.24, 44.95, 69.14)
            },
            {
                pos = vec4(299.87, -330.02, 44.95, 69.14)
            },
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
    ["garage_centrale"] = {
        Settings = {
            pricePerDay = 200,
            displayName = "Sfascio",
            managementPrice = 1000000,
            sellPrice = 5000,
            blip = {
                pos = vec3(289.15, -342.04, 44.92),
                sprite = 357,
                color = 1,
                display = 4,
                scale = 1.0,
                name = "Sfascio",
                shortRange = false,
            }
        },
        TakeVehicle = {
            pos = vec3(215.04, -805.87, 30.81),
        },
        SpawnVehicle = {
            pos = vec3(212.5, -797.84, 30.86),
            heading = 158.56,
        },
        -- Deposit = {
        --     pos = vec3(212.3, -798.61, 30.88),
        --     scale = vec3(3.0, 3.0, 1.0),
        --     msg = "Press ~INPUT_CONTEXT~ to deposit the vehicle",
        --     type = 1,
        -- },
    },
    ["garage_police"] = {
        Settings = {
            pricePerDay = 0,
            displayName = "Garage Police",
            managementPrice = 0,
            sellPrice = 0,
            JobSettings = {
                -- lol
                job = "police",
                -- lol
                platePrefix = "LSPD",
                -- if it should impound police vehicles on resource restart
                impoundVehicles = false,
                -- if taking grade assigned vehicle, it should check the state or not to take another one
                shouldCheckForState = true,
                -- when to show the manage wheel for the garage
                manageGrades = {
                    [4] = true
                },
                -- lol
                lists = {
                    cars = {
                        {model = "police", label = "Police Cruiser", price = 5000},
                        {model = "police2", label = "Police Buffalo", price = 20000},
                        {model = "police3", label = "Police Interceptor", price = 11110},
                        {model = "police4", label = "Police Riot", price = 2121210},
                        {model = "policeb", label = "Police Bike", price = 5445450},
                        {model = "policet", label = "Police Transport", price = 111110},
                        {model = "fbi", label = "FBI", price = 4554540},
                        {model = "fbi2", label = "FBI Buffalo", price = 546450},
                        {model = "sheriff", label = "Sheriff Cruiser", price = 545454},
                        {model = "sheriff2", label = "Sheriff Granger", price = 787140},
                        {model = "riot", label = "Riot", price = 564550},
                        {model = "riot2", label = "Riot 2", price = 854410},
                    },
                    levels = {
                        {grade = 1},
                        {grade = 2},
                        {grade = 3},
                    },
                }
            }
        },
        TakeVehicle = {
            pos = vec3(454.65, -1017.78, 28.43),
        },
        SpawnVehicle = {
            pos = vec3(443.77, -1021.69, 28.52),
            heading = 95.88,
        },
        Deposit = {
            pos = vec3(449.09, -1013.84, 28.49),
            scale = vec3(3.0, 3.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to deposit the vehicle",
            type = 1,
        },
    },
    ["garage_ambulance"] = {
        Settings = {
            pricePerDay = 0,
            displayName = "Garage Ems",
            managementPrice = 0,
            sellPrice = 0,
            JobSettings = {
                -- lol
                job = "ambulance",
                -- lol
                platePrefix = "EMS",
                -- if it should impound police vehicles on resource restart
                impoundVehicles = true,
                -- if taking grade assigned vehicle, it should check the state or not to take another one
                shouldCheckForState = true,
                -- when to show the manage wheel for the garage
                manageGrades = {
                    [1] = true,
                    [4] = true
                },
                -- lol
                lists = {
                    cars = {
                        {model = "ambulance", label = "Ambulanza", price = 5000},
                    },
                    levels = {
                        {grade = 1},
                    },
                }
            }
        },
        TakeVehicle = {
            pos = vec3(-1850.46, -318.52, 49.14),
        },
        SpawnVehicle = {
            pos = vec4(-1880.44, -285.68, 49.28, 60.52),
        },
        Deposit = {
            pos = vec3(-1844.40, -316.13, 49.13),
            scale = vec3(3.0, 3.0, 1.0),
            msg = "Press ~INPUT_CONTEXT~ to deposit the vehicle",
            type = 1,
        },
    },
}