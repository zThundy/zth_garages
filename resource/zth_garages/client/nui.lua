ZTH.NUI = {}

ZTH.NUI.Open = function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = data
    })
end