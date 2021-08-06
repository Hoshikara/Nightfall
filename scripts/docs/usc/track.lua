-- `track` table
-- Only exists in `gameplay.lua` and background/foreground scripts

-- Creates a new `ShadedMeshOnTrack` object
---@param materialName string # Default `'guiTex'`, loaded from the current skin's `shaders` folder  
-- `<materialName>.fs` and `<materialName>.vs` must exist at this location
---@return ShadedMeshOnTrack
CreateShadedMeshOnTrack = function(materialName) end

-- Gets the x-value for the left side of the given `lane`
---@param lane integer # `1` = A, `2` = B, `3` = C, `4` = D, `5` = L, `6` = R
---@return number x
GetCurrentLaneXPos = function(lane) end

-- Gets the y-length of a long note from `start` for `duration`, adjusted for the current track speed
---@param start integer # In miliseconds
---@param duration integer # In miliseconds
---@return number y
GetLengthForDuration = function(start, duration) end

-- Gets the y-position for an object at the given `time`, adjusted for the current track speed
---@param time integer # In miliseconds
---@return number y
GetYPosForTime = function(time) end

-- Hides an object in the given `lane` at the given `time`  
-- If no object is found, hides the closest object after the given `time`
---@param time integer # In miliseconds
---@param lane integer # `1` = A, `2` = B, `3` = C, `4` = D, `5` = L, `6` = R
HideObject = function(time, lane) end

---@class track
track = {
  CreateShadedMeshOnTrack = CreateShadedMeshOnTrack,
  GetCurrentLaneXPos = GetCurrentLaneXPos,
  GetLengthForDuration = GetLengthForDuration,
  GetYPosForTime = GetYPosForTime,
  HideObject = HideObject,
};