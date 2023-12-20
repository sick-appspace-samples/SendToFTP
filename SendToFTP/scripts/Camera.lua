-- luacheck: globals gViewer gLoadConfig gOnNewImage gRecord gFolder gSendImageToFTP

gViewer = View.create() -- Will show in 3D viewer
gViewer:setID('viewer3D')

-------------------------------------
-- Load previously saved config -----
-------------------------------------

---@param jobPath string
function gLoadConfig(jobPath)
  -- Check if file exists
  if not File.exists(jobPath) then
    print('Error: File not found: ' .. jobPath)
    return
  end

  -- Try to load config
  local loadedConfig = Object.load(jobPath)
  if loadedConfig == nil then
    print('Error: Failed loading configuration')
    return
  end

  return loadedConfig
end

-------------------------------------
-- Image Callback -------------------
-------------------------------------

---@param images Image
---@param sensorData SensorData
function gOnNewImage(images, sensorData)
  if #images == 2 then -- Only 3D images
    local heightMap = images[1]
    local intensityMap = images[2]
    local _sensorData = sensorData
    local name = 'image_' .. _sensorData:getFrameNumber()

    -- Add to 3D viewer
    gViewer:addHeightmap({heightMap, intensityMap})

    -- If recording is on
    if gRecord then
      gSendImageToFTP(heightMap, intensityMap, _sensorData, gFolder, name)
    end

    gViewer:present()
  end
end
