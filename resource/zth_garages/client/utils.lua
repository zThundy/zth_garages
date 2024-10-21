
function CreateBlip(data)
    if not data then return Debug("CreateBlip: [^1FATAL^0] data is required") end
    if not data.name then return Debug("CreateBlip: [^1FATAL^0] data.name is required") end
    if not data.pos then return Debug("CreateBlip: [^1FATAL^0] data.pos is required in " .. data.name) end

    for k, v in pairs(ZTH.Blips) do
        if v.data.id == data.name .. "_" .. v.blip then
            RemoveBlip(v.blip)
            table.remove(ZTH.Blips, k)
        end
    end

    if not data.sprite then Debug("CreateBlip: [^3WARN^0] data.sprite is missing in " .. data.name .. ", using default 357") data.sprite = 357 end
    if not data.display then Debug("CreateBlip: [^3WARN^0] data.display is missing in " .. data.name .. ", using default 4") data.display = 4 end
    if not data.scale then Debug("CreateBlip: [^3WARN^0] data.scale is missing in " .. data.name .. ", using default 1.0") data.scale = 1.0 end
    if not data.color then Debug("CreateBlip: [^3WARN^0] data.color is missing in " .. data.name .. ", using default 1") data.color = 1 end
    if not data.shortRange then Debug("CreateBlip: [^3WARN^0] data.shortRange is missing in " .. data.name .. ", using default false") data.shortRange = false end

    local blip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, data.display)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, data.shortRange)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    
    data.id = data.name .. "_" .. blip
    table.insert(ZTH.Blips, { blip = blip, data = data })
    return blip
end

function UnregisterAllMarkers()
    Debug("Unregistering all markers")
    for _, v in pairs(ZTH.Zones) do
        TriggerEvent("gridsystem:unregisterMarker", v.data.name)
    end
end

function CreateMarker(_type, data)
    local GlobalConfig = ZTH.Config.Markers[_type]
    if not GlobalConfig then return Debug("CreateMarker: [^1FATAL^0] GlobalConfig is required for marker " .. _type) end
    if not data.pos then return Debug("CreateMarker: [^1FATAL^0] data.pos is required for marker " .. _type) end
    if not data.action then return Debug("CreateMarker: [^1FATAL^0] data.action is required for marker " .. _type) end
    
    if not data.onEnter then Debug("CreateMarker: [^3WARN^0] onEnter function not found in " .. _type .. ", creating anyway and skipping...") end
    if not data.onExit then Debug("CreateMarker: [^3WARN^0] onExit function not found in " .. _type .. ", creating anyway and skipping...") end

    if not data.scale then data.scale = GlobalConfig.scale end
    if not data.msg then data.msg = GlobalConfig.msg end
    if not data.drawDistance then data.drawDistance = GlobalConfig.drawDistance end
    if not data.control then data.control = GlobalConfig.control end
    if not data.forceExit then data.forceExit = GlobalConfig.forceExit end
    if not data.show3D then data.show3D = GlobalConfig.show3D end
    if not data.type then data.type = GlobalConfig.type end
    if not data.color then data.color = GlobalConfig.color end
    if not data.name then data.name = _type end
    
    local pos = data.pos
    if data.type == 1 then pos = vec3(data.pos.x, data.pos.y, data.pos.z - 1.0) end
    table.insert(ZTH.Zones, { data = data, action = data.action })
    TriggerEvent('gridsystem:registerMarker', {
        id = data.name,
        pos = pos,
        scale = data.scale,
        msg = data.msg,
        drawDistance = data.drawDistance,
        control = data.control,
        forceExit = data.forceExit,
        show3D = data.show3D,
        type = data.type,
        color = data.color,
        name = data.name,
        action = data.action,
        onEnter = data.onEnter,
        onExit = data.onExit,
    })
end

function ClearSpawnPoint(coords)
    RemoveVehiclesFromGeneratorsInArea(coords.x + 1.0, coords.y + 1.0, coords.z + 1.0, coords.x - 1.0, coords.y - 1.0, coords.z - 1.0)
    local vehicles = GetVehiclesInArea(coords, 1.0)
    for k, vehicle in pairs(vehicles) do
        DeleteEntity(vehicle)
    end
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local ped = PlayerPedId()
        coords = GetEntityCoords(ped)
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

function GetVehicles() -- Leave the function for compatibility
    return GetGamePool("CVehicle")
end

function IsSpawnPointFree(coords, maxDistance)
    return #GetVehiclesInArea(coords, maxDistance) == 0
end

function GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, maxDistance)
end

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

function LoadModel(model)
    if HasModelLoaded(model) then return end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

function SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(model) then return end
    if not isnetworked then isnetworked = false end
    LoadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(veh)
    if teleportInto then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
    if cb then cb(veh) end
end

function IsPedDriving()
    local ped = PlayerPedId()
    local type = false
    if IsPedInAnyBoat(ped) then
        type = "boat"
    elseif IsPedInAnyHeli(ped) then
        type = "heli"
    elseif IsPedInAnyPlane(ped) then
        type = "plane"
    elseif IsPedInAnySub(ped) then
        type = "sub"
    elseif IsPedInAnyPoliceVehicle(ped) then
        type = "police"
    elseif IsPedInAnyTrain(ped) then
        type = "train"
    elseif IsPedInAnyTaxi(ped) then
        type = "taxi"
    elseif IsPedInAnyVehicle(ped, false) then
        local model = GetEntityModel(GetVehiclePedIsIn(ped, false))
        if IsThisModelACar(model) then
            type = "car"
        elseif IsThisModelABike(model) then
            type = "bike"
        elseif IsThisModelABicycle(model) then
            type = "bicycle"
        elseif IsThisModelAQuadbike(model) then
            type = "quadbike"
        else
            type = "vehicle"
        end
    end
    return type
end