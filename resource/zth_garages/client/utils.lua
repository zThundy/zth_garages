
function MakeIdFromVector3(vector)
    return vector.x .. "_" .. vector.y .. "_" .. vector.z
end

function CreateBlip(data)
    if not data then return Debug("CreateBlip: [^1FATAL^0] data is required") end
    if not data.name then return Debug("CreateBlip: [^1FATAL^0] data.name is required") end
    if not data.pos then return Debug("CreateBlip: [^1FATAL^0] data.pos is required in " .. data.confId) end

    for k, v in pairs(ZTH.Blips) do
        if v.data.id == data.name .. "_" .. v.blip .. "_" .. MakeIdFromVector3(data.pos) then
            Debug("CreateBlip: Removing existing blip " .. data.name .. " with id " .. v.data.id)
            RemoveBlip(v.blip)
            table.remove(ZTH.Blips, k)
        end
    end

    if not data.sprite then Debug("CreateBlip: [^3WARN^0] data.sprite is missing in " .. data.confId .. ", using default 357") data.sprite = 357 end
    if not data.display then Debug("CreateBlip: [^3WARN^0] data.display is missing in " .. data.confId .. ", using default 4") data.display = 4 end
    if not data.scale then Debug("CreateBlip: [^3WARN^0] data.scale is missing in " .. data.confId .. ", using default 1.0") data.scale = 1.0 end
    if not data.color then Debug("CreateBlip: [^3WARN^0] data.color is missing in " .. data.confId .. ", using default 1") data.color = 1 end
    if not data.shortRange then Debug("CreateBlip: [^3WARN^0] data.shortRange is missing in " .. data.confId .. ", using default false") data.shortRange = false end

    local blip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, data.display)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, data.shortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)
    
    data.id = data.name .. "_" .. blip .. "_" .. MakeIdFromVector3(data.pos)
    table.insert(ZTH.Blips, { blip = blip, data = data })

    DumpTable(ZTH.Blips)
    return blip
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
    if not data.name then data.name = _type .. "_" .. MakeIdFromVector3(data.pos) end
    Debug("CreateMarker: Creating marker " .. _type .. " with name " .. data.name)
    
    local pos = data.pos
    if data.type == 1 then pos = vec3(data.pos.x, data.pos.y, data.pos.z - 1.0) end
    pos = vec3(pos.x, pos.y, pos.z)
    ZTH.Zones[data.name] = { data = data, action = data.action }
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
    SetVehicleOnGroundProperly(veh)
    SetModelAsNoLongerNeeded(model)
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

function PlayClickSound()
    PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", 1)
end

function PlayCloseSound()
    PlaySoundFrontend(-1, "CANCEL", "HUD_LIQUOR_STORE_SOUNDSET", 1)
end

DebugModeSpawnMarkers = function()
    local drawDistance = 100.0

    for k, v in pairs(ZTH.Config.Garages) do
        for _type, garage in pairs(v) do
            if _type == "Settings" then
                if garage.center then
                    TriggerEvent('gridsystem:registerMarker', {
                        pos = vec3(garage.center.x, garage.center.y, garage.center.z + 2.0),
                        scale = vec3(1.5, 1.5, 1.5),
                        msg = "Debug Marker",
                        drawDistance = drawDistance,
                        control = "E",
                        type = 2,
                        color = {
                            r = 0,
                            g = 0,
                            b = 255,
                        },
                        name = MakeRandomString(20),
                    })
                end
            end
            
            if _type == "Manage" then
                TriggerEvent('gridsystem:registerMarker', {
                    pos = vec3(garage.pos.x, garage.pos.y, garage.pos.z + 2.0),
                    scale = vec3(1.5, 1.5, 1.5),
                    msg = "Debug Marker",
                    drawDistance = drawDistance,
                    control = "E",
                    type = 2,
                    color = {
                        r = 255,
                        g = 0,
                        b = 0,
                    },
                    name = MakeRandomString(20),
                })
            end
            
            if _type == "BuySpot" then
                TriggerEvent('gridsystem:registerMarker', {
                    pos = vec3(garage.pos.x, garage.pos.y, garage.pos.z + 2.0),
                    scale = vec3(1.5, 1.5, 1.5),
                    msg = "Debug Marker",
                    drawDistance = drawDistance,
                    control = "E",
                    type = 2,
                    color = {
                        r = 255,
                        g = 0,
                        b = 0,
                    },
                    name = MakeRandomString(20),
                })
            end

            if _type == "ParkingSpots" then
                for _, spot in pairs(garage) do
                    TriggerEvent('gridsystem:registerMarker', {
                        pos = vec3(spot.pos.x, spot.pos.y, spot.pos.z + 2.0),
                        scale = vec3(1.5, 1.5, 1.5),
                        msg = "Debug Marker",
                        drawDistance = drawDistance,
                        control = "E",
                        show3D = true,
                        type = 2,
                        color = {
                            r = 0,
                            g = 255,
                            b = 0,
                        },
                        name = MakeRandomString(20),
                    })
                end
            end
            
            if _type == "TakeVehicle" then
                TriggerEvent('gridsystem:registerMarker', {
                    pos = vec3(garage.pos.x, garage.pos.y, garage.pos.z + 2.0),
                    scale = vec3(1.5, 1.5, 1.5),
                    msg = "Debug Marker",
                    drawDistance = drawDistance,
                    control = "E",
                    type = 2,
                    color = {
                        r = 255,
                        g = 0,
                        b = 0,
                    },
                    name = MakeRandomString(20),
                })
            end
            
            if _type == "SpawnVehicle" then
                TriggerEvent('gridsystem:registerMarker', {
                    pos = vec3(garage.pos.x, garage.pos.y, garage.pos.z + 2.0),
                    scale = vec3(1.5, 1.5, 1.5),
                    msg = "Debug Marker",
                    drawDistance = drawDistance,
                    control = "E",
                    type = 2,
                    color = {
                        r = 255,
                        g = 0,
                        b = 0,
                    },
                    name = MakeRandomString(20),
                })
            end
            
            if _type == "Deposit" then
                TriggerEvent('gridsystem:registerMarker', {
                    id = string,
                    pos = vec3(garage.pos.x, garage.pos.y, garage.pos.z + 2.0),
                    scale = vec3(1.5, 1.5, 1.5),
                    msg = "Debug Marker",
                    drawDistance = drawDistance,
                    control = "E",
                    type = 2,
                    color = {
                        r = 255,
                        g = 0,
                        b = 0,
                    },
                    name = MakeRandomString(20),
                })
            end
        end
    end
end