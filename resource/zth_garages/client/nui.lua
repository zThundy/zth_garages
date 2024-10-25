ZTH.NUI = {}

ZTH.NUI.Open = function(data)
    Debug("Opening NUI with data: " .. DumpTable(data))
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", data = data })
end

ZTH.NUI.OpenSpecific = function(data)
    Debug("Opening custom NUI screen with data " .. DumpTable(data))
    SetNuiFocus(true, true)
    SendNUIMessage(data)
end

ZTH.NUI.Close = function()
    Debug("Closing NUI")
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

ZTH.NUI.RegisterNUICallback = function(name, cb)
    RegisterNUICallback("html/" .. name, function(data, _cb)
        if hasTimeout() then return end
        addTimeout(nil, ZTH.Config.TimeoutBetweenInteractions)

        Debug("Received NUI callback: " .. name .. " with data: " .. DumpTable(data))
        cb(data, _cb)
    end)
end

RegisterNUICallback("html/close", function(data, cb)
    SetNuiFocus(false, false)
    ZTH.Camera.FullyKillCameras(ZTH)
    cb({ message = "ok" })
end)

RegisterNUICallback("html/changeSpot", function(data, cb)
    local spotId = data.spotId
    local garageId = ZTH.Camera.Extradata
    local garage = ZTH.Config.Garages[garageId].ParkingSpots[spotId]

    if garage == nil then
        ZTH.Core.Functions.Notify(L("GENERIC_ERROR"), "error")
        return
    end

    ZTH.Camera.UpdateCamera(ZTH, garage.pos)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("impoundVehicle", function(data, cb)
    ZTH.Functions.ImpoundVehicle(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("payFee", function(data, cb)
    ZTH.Functions.TakeImpoundedVehicle(ZTH, data.car)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("take", function(data, cb)
    ZTH.Functions.TakeVehicle(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("money", function(data, cb)
    local errorMessage = L("ERROR_BALANCE_NOT_ENOUGH")
    local message = L("SUCCESS_WITHDAW", data.amount)
    if data.type == "deposit" then
        errorMessage = L("ERROR_NO_MONEY")
        message = L("SUCCESS_DEPOSIT", data.amount)
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
    ZTH.Functions.BuySpot(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("saveData", function(data, cb)
    ZTH.Functions.BuyVehicles(ZTH, data)
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("sellParking", function(data, cb)
    if ZTH.Tunnel.Interface.SellParking(data.pData) then
        ZTH.Core.Functions.Notify(L("SUCCESS_SELL_PARKING"), "success")
        ZTH.NUI.Close()
    else
        ZTH.Core.Functions.Notify(L("GENERIC_ERROR"), "error")
    end
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("propertyBuy", function(data, cb)
    if ZTH.Tunnel.Interface.CanAffordGarage(data) then
        ZTH.Core.Functions.Notify(L("SUCCESS_BUY_GARAGE"), "success")
        ZTH.NUI.Close()
    else
        ZTH.Core.Functions.Notify(L("GENERIC_ERROR"), "error")
    end
    cb({ message = "ok" })
end)

ZTH.NUI.RegisterNUICallback("manageGarageButton", function(data, cb)
    if ZTH.Tunnel.Interface.ManageGarageButton(data) then
        ZTH.NUI.Close()
        if data.action == "revoke" then
            ZTH.Core.Functions.Notify(L("SUCCESS_REVOKED_SPOT"), "success")
        elseif data.action == "renew" then
            ZTH.Core.Functions.Notify(L("SUCCESS_RENEWED_SPOT"), "success")
        end
    end
    cb({ message = "ok" })
end)