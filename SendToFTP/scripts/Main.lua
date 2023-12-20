--[[----------------------------------------------------------------------------

  Application Name:
  SendToFTP

  Summary:
  Taking images with TrispectorP and transferring to FTP server

  Description:
  This Sample takes images with TrispectorP device and transfers them
  as JSON to an FTP server

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage. A TriSpectorP
  camera is required to be to run the app.

------------------------------------------------------------------------------]]
require('Camera')
require('SendToFTP')

--Start of Global Scope---------------------------------------------------------

-- luacheck: globals gImageProvider gImageConfig3D gLoadConfig gOnNewImage gSetupFTPClient

-- Create an image provider and an empty config
gImageProvider = Image.Provider.Camera.create()
gImageConfig3D = Image.Provider.Camera.V3TConfig3D.create()

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  -- Define path to config file
  local jobPath = 'public/Image3DConfig.json'

  -- Load image config
  gImageConfig3D = gLoadConfig(jobPath) or gImageConfig3D

  if gImageConfig3D:validate() then -- If OK
    -- Apply config on image provider
    gImageProvider:setConfig(gImageConfig3D)

    -- Register image callback
    gImageProvider:register('OnNewImage', gOnNewImage)

    -- Start image provider
    gImageProvider:start()
  else
    print('Error in image config')
  end

  -- Initialize the FTP Client on app startup
  gSetupFTPClient()
end

-- Serve API in global scope
Script.register('Engine.OnStarted', main)
