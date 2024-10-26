ZTH.Camera = {}
ZTH.Camera.Current = nil
ZTH.Camera.Extradata = nil

function ZTH.Camera.SpawnCamera(self)
    local camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1000, true, true)
    SetCamParams(camera, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 90.0, 1000, 0, 2, 1)
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
    local cameraSettings = self.Config.Garages[self.Camera.Extradata].Settings.Camera
    if not cameraSettings then
        self.Config.Garages[self.Camera.Extradata].Settings.Camera = {
            distance = 5.0,
            height = 2.0,
        }
    end
    local offset = vector3(0, 0, cameraSettings.height)
    local angle = pos.w * math.pi / 180
    local x = pos.x + cameraSettings.distance * math.sin(angle)
    local y = pos.y - cameraSettings.distance * math.cos(angle)
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
    SetCamParams(self.Camera.Current, cameraPos.x, cameraPos.y, cameraPos.z, pos.x, pos.y, pos.z, 90.0, 200, 0, 2, 1)
    PointCamAtCoord(self.Camera.Current, pos.x, pos.y, pos.z)
end