-- Global `game` table

-- Gets the state of the specified button
---@param button integer # options are under the `game` table prefixed with `BUTTON`
---@return boolean # `true` if it is being pressed
GetButton = function(button) end

-- Gets the absolute rotation of the specified knob
---@param knob integer # `0 = left`, `1 = right`
---@return number angle # in radians, `0.0` to `2*pi`
GetKnob = function(knob) end

-- Gets the color of the specified laser
---@param laser integer # `0 = left`, `1 = right`
---@return integer r, integer g, integer b
GetLaserColor = function(laser) end

-- Gets the mouse's position on the game window in pixel coordinates
---@return number, number
GetMousePos = function() end

-- Gets the game window's resolution in pixels
---@return number, number
GetResolution = function() end

-- Gets the name of the current skin
---@return string
GetSkin = function() end

-- Gets the value of the skin setting with the specified key
---@param key string
---@return any
GetSkinSetting = function(key) end

-- Checks whether the named sample is currently playing
---@param name string # name of the loaded sample
---@return boolean|nil # `nil` if the sample is not loaded
IsSamplePlaying = function(name) end

-- Loads an audio sample from the `audio` directory of the current skin folder
---@param name string # `.wav` extension assumed if not provided
LoadSkinSample = function(name) end

-- Logs a message to the game's log file
---@param message string
---@param severity integer # options are under the `game` table prefixed with `LOGGER`
Log = function(message, severity) end

-- Plays a loaded sample
---@param name string # name of the loaded sample
---@param loop? boolean
PlaySample = function(name, loop) end

-- Sets the value of the skin setting with the specified key
---@param key string
---@param value any # type must match the type of the defined skin setting
SetSkinSetting = function(key, value) end

-- Stops a playing sample
---@param name string # name of the loaded sample
StopSample = function(name) end

-- Checks if an update is available
---@return string url, string version # `nil` if there is no update available
UpdateAvailable = function() end

game = {
  LOGGER_INFO = 1,
  LOGGER_NORMAL = 2,
  LOGGER_WARNING = 3,
  LOGGER_ERROR = 4,

  BUTTON_BTA = 0,
  BUTTON_BTB = 1,
  BUTTON_BTC = 2,
  BUTTON_BTD = 3,
  BUTTON_FXL = 4,
  BUTTON_FXR = 5,
  BUTTON_STA = 6,
  BUTTON_BCK = 11,

  GetButton = GetButton,
  GetKnob = GetKnob,
  GetLaserColor = GetLaserColor,
  GetMousePos = GetMousePos,
  GetResolution = GetResolution,
  GetSkin = GetSkin,
  GetSkinSetting = GetSkinSetting,
  IsSamplePlaying = IsSamplePlaying,
  LoadSkinSample = LoadSkinSample,
  Log = Log,
  PlaySample = PlaySample,
  SetSkinSetting = SetSkinSetting,
  StopSample = StopSample,
  UpdateAvailable = UpdateAvailable,
};