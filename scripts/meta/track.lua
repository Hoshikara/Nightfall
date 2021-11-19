---@meta

---
---The global `track` table.  
---Only available for:
---* `/scripts/gameplay.lua`
---* `*/bg.lua` (background scripts)
---* `*/fg.lua` (foreground scripts)  
---
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/track.html)
---
---@class track
track = {}

---Creates a new `ShadedMeshOnTrack` object
---@param materialName string # Default: `"guiTex"`, this is loaded from the `shaders` folder of the current skin.  
---The shaders `<materialName>.fs` and `<materialName>.vs` must exist in this folder.
---@return ShadedMeshOnTrack
function track.CreateShadedMeshOnTrack(materialName) end

---Gets the x-value for the left side of the given `lane`.
---@param lane integer #
---* `1` = A
---* `2` = B
---* `3` = C
---* `4` = D
---* `5` = L
---* `6` = R
---@return number x
function track.GetCurrentLaneXPos(lane) end

---Gets the y-length of a hold note from `start` and for `duration`.  
---This value is adjusted for the current track speed.
---@param start integer # The starting time of the hold note in milliseconds.
---@param duration integer # The duration of the hold note in milliseconds.
---@return number y
function track.GetLengthForDuration(start, duration) end

---Gets the y-position for an object at the given `time`.  
---This value is adjusted for the current track speed.
---@param time integer # The time of the object in milliseconds.
---@return number y
function track.GetYPosForTime(time) end

---Hides an object in the given `lane` at the given `time`.  
---If no object is found, the closest object after the given `time` will be hidden.
---@param time integer # The time of the object in milliseconds.
---@param lane integer #
---* `1` = A
---* `2` = B
---* `3` = C
---* `4` = D
---* `5` = L
---* `6` = R
function track.HideObject(time, lane) end
