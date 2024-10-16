
function CreateBlip(data)
    if not data then return Debug("CreateBlip: data is required") end
    if not data.pos then return Debug("CreateBlip: data.pos is required") end
    if not data.name then return Debug("CreateBlip: data.name is required") end

    local blip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
    SetBlipSprite(blip, data.sprite or 357)
    SetBlipDisplay(blip, data.display or 4)
    SetBlipScale(blip, data.scale or 1.0)
    SetBlipColour(blip, data.color or 1)
    SetBlipAsShortRange(blip, data.shortRange or true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

function CreateMarker(_type, data)
    local GlobalConfig = ZTH.Config.Markers[_type]
    if not GlobalConfig then return Debug("CreateMarker: GlobalConfig is required for marker " .. _type) end

    if not data.scale then data.scale = GlobalConfig.scale end
    if not data.msg then data.msg = GlobalConfig.msg end
    if not data.drawDistance then data.drawDistance = GlobalConfig.drawDistance end
    if not data.control then data.control = GlobalConfig.control end
    if not data.forceExit then data.forceExit = GlobalConfig.forceExit end
    if not data.show3D then data.show3D = GlobalConfig.show3D end
    if not data.type then data.type = GlobalConfig.type end
    if not data.color then data.color = GlobalConfig.color end
    if not data.name then data.name = _type end
    
    if not data.pos then return Debug("CreateMarker: data.pos is required for marker " .. _type) end
    if not data.action then return Debug("CreateMarker: data.action is required for marker " .. _type) end
    
    if data.type == 1 then data.pos = vec3(data.pos.x, data.pos.y, data.pos.z - 1.0) end

    TriggerEvent('gridsystem:registerMarker', data)
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