
ZTH.Garages = {}
ZTH.Tunnel = {}
ZTH.IsReady = false

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = ZTH.Tunnel.getInterface("zth_garages", "zth_garages_t", "zth_garages_t")

Citizen.CreateThread(ZTH.Functions.Init)

RegisterNetEvent("zth_garages:client:Init")
AddEventHandler("zth_garages:client:Init", function()
    Debug("Script is ready")
    ZTH.IsReady = true
end)
