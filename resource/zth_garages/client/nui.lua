ZTH.NUI = {}

ZTH.NUI.Open = function(data)
    Debug("Opening NUI with data: " .. json.encode(data))
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", data = data })
end

ZTH.NUI.Close = function()
    Debug("Closing NUI")
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

ZTH.NUI.RegisterNUICallback = function(name, cb)
    RegisterNUICallback("html/" .. name, function(data, _cb)
        Debug("Received NUI callback: " .. name .. " with data: " .. json.encode(data))
        cb(data, _cb)
    end)
end

ZTH.NUI.RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("take", function(data, cb)
    ZTH.Functions.TakeVehicle(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("money", function(data, cb)
    print("money", json.encode(data, { indent = true }))
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("buySpot", function(data, cb)
    print("buySpot", json.encode(data, { indent = true }))
    ZTH.Functions.BuySpot(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("changeSpot", function(data, cb)
    print("changeSpot", json.encode(data, { indent = true }))
    cb({ message = "ok" })
end)