ZTH = {}
ZTH.Config = {}

ZTH.Config.Debug = true

local frameworkAutoFind = function()
    if GetResourceState('es_extended') ~= 'missing' then
        return "ESX"
    elseif GetResourceState('qb-core') ~= 'missing' then
        return "QB-Core"
    end
end

ZTH.Config.FuelResource = 'LegacyFuel' -- supports any that has a GetFuel() and SetFuel() export

ZTH.Config.Core = frameworkAutoFind()
ZTH.Config.CoreExport = function()
    if ZTH.Config.Core == "ESX" then
        return exports['es_extended']:getSharedObject()
    elseif ZTH.Config.Core == "QB-Core" then
        return exports['qb-core']:GetCoreObject()
    end

    return false
end

ZTH.Core = ZTH.Config.CoreExport()

ZTH.Config.Events = {}
ZTH.Config.Events.PlayerLoaded = ZTH.Config.Core == "ESX" and "esx:playerLoaded" or "QBCore:Client:OnPlayerLoaded"  
ZTH.Config.Events.PlayerLogoutServer = ZTH.Config.Core == "ESX" and "esx:playerDropped" or "QBCore:Server:OnPlayerUnload"
ZTH.Config.Events.PlayerSetJob = ZTH.Config.Core == "ESX" and "esx:setJob" or "QBCore:Client:OnJobUpdate"

