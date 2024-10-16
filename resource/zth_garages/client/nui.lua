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
    local errorMessage = "The balance in the garage is not enough"
    local message = "You have withdrawn $" .. data.amount
    if data.type == "deposit" then
        errorMessage = "You do not have enough money"
        message = "You have deposited $" .. data.amount
    end

    if ZTH.Tunnel.Interface.BalanceAction(data) then
        ZTH.Core.Functions.Notify(message, "success")
        SendNUIMessage({ action = "balance-update", balance = ZTH.Tunnel.Interface.GetBalance(data.id) })
    else
        ZTH.Core.Functions.Notify(errorMessage, "error")
    end
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