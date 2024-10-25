ZTH.Camera = {}
ZTH.Camera.Current = nil
ZTH.Camera.Extradata = nil

function ZTH.Camera.SpawnCamera(self)
    local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1000, true, true)
    self.Camera.Current = camera
    return camera
end

function ZTH.Camera.FullyKillCameras(self)
    if self.Camera.Current == nil then return end
    DestroyAllCams(true)
    RenderScriptCams(false, true, 1000, true, true)
    self.Camera.Current = nil
    self.Camera.Extradata = nil
end

function ZTH.Camera.DestroyCamera(self)
    if self.Camera.Current == nil then return end
    DestroyCam(self.Camera.Current, false)
    RenderScriptCams(false, true, 1000, true, true)
    self.Camera.Current = nil
    self.Camera.Extradata = nil
end

-- calculate camera position from the pos and heading of the vehicle
function ZTH.Camera.CalculateCameraPosition(self, pos)
    local offset = vector3(0, 0, 1.5)
    local distance = 4.5
    local angle = pos.w * math.pi / 180
    local x = pos.x + distance * math.sin(angle)
    local y = pos.y - distance * math.cos(angle)
    local z = pos.z + offset.z
    return vector3(x, y, z)
end

-- spawn camera and set position
function ZTH.Camera.MakeCamera(self, pos, extradata)
    self.Camera.Extradata = extradata
    self.Camera.SpawnCamera(self)
    local cameraPos = self.Camera.CalculateCameraPosition(self, pos)
    SetCamCoord(self.Camera.Current, cameraPos.x, cameraPos.y, cameraPos.z)
    PointCamAtCoord(self.Camera.Current, pos.x, pos.y, pos.z)
end

function ZTH.Camera.UpdateCamera(self, pos)
    local cameraPos = self.Camera.CalculateCameraPosition(self, pos)
    SetCamParams(self.Camera.Current, cameraPos.x, cameraPos.y, cameraPos.z, pos.x, pos.y, pos.z, 60.0, 200, 0, 2, 1)
    PointCamAtCoord(self.Camera.Current, pos.x, pos.y, pos.z)
end