
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
    if not GlobalConfig then return Debug("CreateMarker: GlobalConfig is required") end

    if not data.scale then data.scale = GlobalConfig.scale end
    if not data.msg then data.msg = GlobalConfig.msg end
    if not data.drawDistance then data.drawDistance = GlobalConfig.drawDistance end
    if not data.control then data.control = GlobalConfig.control end
    if not data.forceExit then data.forceExit = GlobalConfig.forceExit end
    if not data.show3D then data.show3D = GlobalConfig.show3D end
    if not data.type then data.type = GlobalConfig.type end
    if not data.color then data.color = GlobalConfig.color end

    if not data.pos then return Debug("CreateMarker: data.pos is required") end
    if not data.action then return Debug("CreateMarker: data.action is required") end

    TriggerEvent('gridsystem:registerMarker', data)
end