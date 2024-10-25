ZTH.Housing = {}
ZTH.Housing.Tunnel = {}
ZTH.Housing.Tunnel.Interface = {}
ZTH.Tunnel.bindInterface("zth_garages", "zth_garages_housing_t", ZTH.Housing.Tunnel.Interface)

if not ZTH.Config.IsOrigenHousingInstalled then
    Debug("Origen Housing resource is not started, exiting...")
    return
end