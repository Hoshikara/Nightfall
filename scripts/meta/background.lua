---@meta

---
---The global `background` table.  
---Only available for `*/bg.lua` (background scripts).  
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/bgfg.html)
---
---@class background
---
background = {}

---
---Draws the background shader and invokes `gfx.ForceRender`.
---
function background.DrawShader() end

---
---Gets the current clear state
---
---@return integer clearState #
---* `0` = Fail
---* `1` = Clear
function background.GetClearTransition() end

---
---Gets the file path to the current background folder.
---
---@return string filePath
function background.GetPath() end

---
---Gets the pixel coordinates for a point slightly above the end of the track.
---
---@return number x, number y
function background.GetScreenCenter() end

---
---Gets the current tilt values.  
---* `< 0` = Clockwise
---* `> 0` = Counter-Clockwise
---
---@return number laserTilt
---@return number spinTilt
function background.GetTilt() end

---
---Gets current timing data.
---
---@return number bartime # Covers the range `[0, 1]` over the duration of each beat and then resets.
---@return number offsync # Covers the range `[0, 1]` over the duration `BPM * multiplier` and then resets.
---@return number time # The current time in milliseconds.
function background.GetTiming() end

---
---Loads a texture that can be used in the fragment shader code.
---
---@param uniformName uniformName
---@param imagePath imagePath
function background.LoadTexture(uniformName, imagePath) end

---
---Sets a float value for the given uniform variable.
---
---@param uniformName uniformName
---@param value number
function background.SetParamf(uniformName, value) end

---
---Sets an integer value for the given uniform variable.
---
---@param uniformName string
---@param value integer
function background.SetParami(uniformName, value) end

---
---Sets the speed multiplier for the `offsync` timer returned by `background.GetTiming` or `foreground.GetTiming`.
---
---@param speed number
function background.SetSpeedMulti(speed) end
