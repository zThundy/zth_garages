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