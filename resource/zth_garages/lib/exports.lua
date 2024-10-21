
Citizen.CreateThread(function()
    while not ZTH do Citizen.Wait(1000) end
    while not ZTH.IsReady do Citizen.Wait(1000) end

    if not SERVER then
    
    else
        exports("IsInImpound", function(id) return ZTH.Config.Impounds[id].isInImpound end)
    end
    Debug("Exports loaded")
end)
