-- bg 'background' table

-- Draws the background shader and invokes `gfx.ForceRender`
DrawShader = function() end

-- Gets the clear state value, `0` for fail state, `1` for clear state
---@return integer
GetClearTransition = function() end

-- Retrieves the path to the background folder
GetPath = function() end

-- Gets the pixel coordinates for a point just above the end of the track
---@return number x
---@return number y
GetScreenCenter = function() end

-- Gets tilt values, `< 0` for clockwise, `> 0` for counter-clockwise
---@return number laserTilt # Tilt induced by lasers
---@return number spinTilt # Tilt induced by spinEvents
GetTilt = function() end

-- Gets timing data of the chart
---@return number bartime # Value that goes from `0` to `1` over the duration of each beat
---@return number offsync # Value that goes from `0` to `1` over the duration `BPM * multiplier`
---@return number time # Current time in the chart
GetTiming = function() end

-- Loads a texture which will be available in the fragment shader under the given `shaderName`
---@param shaderName string
---@param fileName string
LoadTexture = function(shaderName, fileName) end

-- Set a float value to a uniform variable in the shader
---@param uniformName string
---@param val number
SetParamf = function(uniformName, val) end

-- Set an integer value to a uniform variable in the shader
---@param uniformName string
---@param val integer
SetParami = function(uniformName, val) end

-- Sets the speed multiplier for the `offsync` timer returned by `GetTiming`
---@param speed number
SetSpeedMulti = function(speed) end

---@class background
background = {
  DrawShader = DrawShader,
  GetClearTransition = GetClearTransition,
  GetPath = GetPath,
  GetScreenCenter = GetScreenCenter,
  GetTilt = GetTilt,
  GetTiming = GetTiming,
  LoadTexture = LoadTexture,
  SetParamf = SetParamf,
  SetParami = SetParami,
  SetSpeedMulti = SetSpeedMulti,
};