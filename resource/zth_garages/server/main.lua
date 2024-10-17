Citizen.CreateThread(ZTH.Functions.Init)


RegisterCommand("kok", function(source, args)
    TriggerClientEvent("kok", source, args[1])
end)