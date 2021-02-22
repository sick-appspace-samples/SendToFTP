-- Events
Script.serveEvent('SendToFTP.recordStatus', 'recordStatus')
Script.serveEvent('SendToFTP.errorMessage', 'errorMessage', 'string')

-- Global parameters
-- luacheck: globals gRecord gFolder gSetupFTPClient gSendImageToFTP gImageConfig3D

gRecord = false
gFolder = ''

local address = ''
local port = 21
local error = 'All fields need to be filled in'
local ftp = nil

-- Set the user's input as address
--@setAddress(newAddress:string)
local function setAddress(newAddress)
  print("Address: "..newAddress)
  address = newAddress
  ftp:setIpAddress(address)
end
Script.serveFunction('SendToFTP.setAddress', setAddress)

-- Get the address
local function getAddress()
  return address
end
Script.serveFunction('SendToFTP.getAddress', getAddress)

-- Set the user's input as gFolder
--@setFolder(newFolder:string)
local function setFolder(newFolder)
  print('Folder: C:/ftp/' .. newFolder)
  gFolder = newFolder
end
Script.serveFunction('SendToFTP.setFolder', setFolder)

-- Get the folder
local function getFolder()
  return gFolder
end
Script.serveFunction('SendToFTP.getFolder', getFolder)

-- Checks if the inputs are valid
-- and starts the saving process
local function startRecording()
  if address == '' or gFolder == '' then
    Script.notifyEvent('errorMessage', error)
  else
    gRecord = true
    Script.notifyEvent('recordStatus', gRecord)
    Script.notifyEvent('errorMessage', '')
  end
end
Script.serveFunction('SendToFTP.startRecording', startRecording)

-- Stops the saving process
local function stopRecording()
  gRecord = false
  Script.notifyEvent('recordStatus', gRecord)
end
Script.serveFunction('SendToFTP.stopRecording', stopRecording)

-- Creates an FTP client object with
-- properties according to user input
function gSetupFTPClient()
  if address == nil then
    print('Address is required')
  end

  if ftp == nil then
    ftp = FTPClient.create()
    ftp:setPort(port)
    print('FTP is created')
  end
end


-- Sends any data to the FTP server
--@sendDataToFTP(data: Object, gFolder: string, name: string, config: Image.Provider.Camera.V3TConfig3D)
local function sendDataToFTP(data, gFolder, name, config)
  local success = false
  -- Try to connect to the server
  if (ftp:connect('SICK', 'SICK')) then
    -- Set transfer mode to binary
    if (ftp:setMode('binary')) then
      -- Change to target directory
      if (ftp:cd(gFolder)) then
        -- Create new directory
        print('Directory exists')
        -- Put a file with contents
        if (ftp:put(name .. '.json', data)) then
          print('File successfully written to FTP server')
          success = true
        else
          Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to write file' )
          print('Try to send file to FTP: Failed to write file')
        end
        -- Check if subfolder "config" exists
        if (ftp:cd('config')) then
          -- Put a config file with contents in subfolder
          if (ftp:put('config_' .. name .. '.json', config)) then
            print('Config file successfully written to FTP server')
          else
            Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to put a config file' )
            print('Try to send file to FTP: Failed to put a config file')
          end
        else
          if (ftp:mkdir('config')) then
            ftp:cd('config')
            if (ftp:put('config_' .. name .. '.json', config)) then
              print('Config file successfully written to FTP server')
            else
              Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to put a config file' )
              print('Try to send file to FTP: Failed to put a config file')
            end
          else
            Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to open config gFolder' )
            print('Try to send file to FTP: Failed to open config gFolder')
          end
        end
      elseif (ftp:mkdir(gFolder)) then
        print('New directory created')
        -- Change to target directory
        if (ftp:cd(gFolder)) then
          -- Put a file with contents
          if (FTPClient.put(ftp, name .. '.json', data)) then
            print('File successfully written to FTP server')
            success = true
          else
            Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to write file' )
            print('Try to send file to FTP: Failed to write file')
          end
          -- Create new config directory
          ftp:mkdir('config')
          -- Change to target directory
          if (ftp:cd('config')) then
            -- Put a config file with contents
            if (ftp:put('config_' .. name .. '.json', config)) then
              print('Config file successfully written to FTP server')
            else
              Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to write config file' )
              print('Try to send file to FTP: Failed to write config file')
            end
          else
            Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to open config gFolder' )
            print('Try to send file to FTP: Failed to open config gFolder')
          end
        else
          Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to open new gFolder' )
          print('Try to send file to FTP: Failed to open new gFolder')
        end
      else
        Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to open gFolder or create new gFolder' )
        print( 'Try to send file to FTP: Failed to open gFolder or create new gFolder' )
      end
    else
      Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to set mode' )
      print('Try to send file to FTP: Failed to set mode')
    end
  else Script.notifyEvent( 'errorMessage', 'Try to send file to FTP: Failed to connect to FTP server' )
    print('Try to send file to FTP: Failed to connect to FTP server')
  end

  -- Disconnect the client
  ftp:disconnect()

  return success
end

-- Saves an image to the FTP server
--@gSendImageToFTP(hMap: Image, iMap:Image, _sensorData:SensorData, gFolder:string, name:string)
function gSendImageToFTP(hMap, iMap, _sensorData, gFolder, name)
  local data = Object.serialize({hMap, iMap, _sensorData}, 'JSON')
  local configData = Object.serialize({gImageConfig3D}, 'JSON')
  sendDataToFTP(data, gFolder, name, configData)
end
