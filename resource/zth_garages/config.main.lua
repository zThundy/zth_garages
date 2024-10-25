ZTH = {}
ZTH.Config = {}

---- DO NOT TOUCH -----
ZTH.IsReady = false
-----------------------
ZTH.Config.Debug = true

ZTH.Config.CoreFunction = function()
    if GetResourceState('es_extended') ~= 'missing' then
        return "ESX"
    elseif GetResourceState('qb-core') ~= 'missing' then
        return "QB-Core"
    end
end
ZTH.Config.Core = ZTH.Config.CoreFunction()

ZTH.Config.FuelResource = 'cdn-fuel' -- supports any that has a GetFuel() and SetFuel() export
-- will be using LegacyFuel as default, since qb-base gamemode uses that one.
if GetResourceState(ZTH.Config.FuelResource) == 'missing' then ZTH.Config.FuelResource = 'LegacyFuel' end
ZTH.Config.IsAdvancedParkingInstalled = GetResourceState("AdvancedParking") == "started"
ZTH.Config.IsOrigenHousingInstalled = GetResourceState("origen_housing") == "started"

ZTH.Config.CoreExport = function()
    if ZTH.Config.Core == "ESX" then
        return exports['es_extended']:getSharedObject()
    elseif ZTH.Config.Core == "QB-Core" then
        return exports['qb-core']:GetCoreObject()
    end

    return false
end
ZTH.Core = ZTH.Config.CoreExport()

if GetResourceState("qb-bossmenu") ~= "missing" then
    ZTH.Config.AccountScript = "qb-bossmenu"
elseif GetResourceState("qb-management") ~= "missing" then
    ZTH.Config.AccountScript = "qb-management"
elseif GetResourceState("qb-banking") ~= "missing" then
    ZTH.Config.AccountScript = "qb-banking"
elseif GetResourceState("esx_society") ~= "missing" then
    ZTH.Config.AccountScript = "esx_society"
end

ZTH.Config.Events = {}
ZTH.Config.Events.PlayerLoaded = ZTH.Config.Core == "ESX" and "esx:playerLoaded" or "QBCore:Client:OnPlayerLoaded"
ZTH.Config.Events.PlayerLoadedServer = ZTH.Config.Core == "ESX" and "esx:playerLoaded" or "QBCore:Server:PlayerLoaded"
ZTH.Config.Events.PlayerLogoutServer = ZTH.Config.Core == "ESX" and "esx:playerDropped" or "QBCore:Server:OnPlayerUnload"
ZTH.Config.Events.PlayerSetJob = ZTH.Config.Core == "ESX" and "esx:setJob" or "QBCore:Client:OnJobUpdate"
ZTH.Config.Events.PlayerSetJobServer = ZTH.Config.Core == "ESX" and "esx:setJob" or "QBCore:Server:OnJobUpdate"
ZTH.Config.Events.SetVehicleOwner = 'vehiclekeys:client:SetOwner'
ZTH.Config.Events.SharedUpdated = "QBCore:Client:SharedUpdate"
ZTH.Config.Events.ResourceInit = "zth_garages:client:Init"
ZTH.Config.Events.RefreshGarages = "zth_garages:client:refreshGarage"
ZTH.Config.Events.SpawnCarOnSpot = "zth_garages:client:spawnCarOnSpot"

ZTH.Config.Shared = {}
ZTH.Config.Shared.Jobs = ZTH.Core.Shared.Jobs

ZTH.Config.TimeoutBetweenInteractions = 2000