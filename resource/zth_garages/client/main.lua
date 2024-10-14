
ZTH.Garages = {}
ZTH.Tunnel = {}

ZTH.Tunnel = module("zth_garages", "lib/TunnelV2")
ZTH.Tunnel.Interface = ZTH.Tunnel.getInterface("zth_garages", "zth_garages_t", "zth_garages_t")

Citizen.CreateThread(ZTH.Functions.Init)
