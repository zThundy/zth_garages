

ZTH.Config.Markers["EnterHouseGarage"] = {
    scale = vec3(1.0, 1.0, 1.0),
    msg = "Press ~INPUT_CONTEXT~ to enter the garage",
    drawDistance = 40.0,
    control = "E",
    show3D = false,
    type = 20,
    color = { r = 255, g = 0, b = 0 },
}

ZTH.Config.Markers["HouseParkingSpot"] = {
    scale = vec3(1.0, 1.0, 1.0),
    msg = "Press ~INPUT_CONTEXT~ to park your vehicle",
    drawDistance = 40.0,
    control = "E",
    show3D = false,
    type = 20,
    color = { r = 255, g = 0, b = 0 },
}

ZTH.Config.Houses = {
    ["Civico 335"] = {
        EnterHouseGarage = {
            pos = vec3(-1110.31, -1063.80, 2.15),
            heading = -1110.31,
        },
    },
    ["Civico 126"] = {
        HouseParkingSpots = {
            {
                pos = vec3(-1110.31, -1063.80, 2.15),
                heading = -1110.31,
            },
            {
                pos = vec3(-1110.31, -1063.80, 2.15),
                heading = -1110.31,
            },
        },
    }
}