
-- you can configure global settings for markers here
Config.Markers = {
    ["garage_1"] = {
        pos = vec3(0.0, 0.0, 0.0),
        scale = vec3(1.0, 1.0, 1.0),
        msg = "Press ~INPUT_CONTEXT~ to open the garage",
        drawDistance = 10.0,
        control = "E",
        forceExit = true,
        show3D = false,
        type = 20,
        color = { r = 255, g = 0, b = 0 },
        action = getGarageFunction("garage_1"),
    }

}

-- you can configure global settings for blips here
Config.Blips = {
    
}

Config.Garages = {

}