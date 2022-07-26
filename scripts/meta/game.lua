---@meta

---
---The global `game` table.
---Available for all scripts.
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/game.html)
---
---@class game
game = {
	BUTTON_BTA = 0,
	BUTTON_BTB = 1,
	BUTTON_BTC = 2,
	BUTTON_BTD = 3,
	BUTTON_FXL = 4,
	BUTTON_FXR = 5,
	BUTTON_STA = 6,
	BUTTON_BCK = 11,

	LOGGER_INFO = 1,
	LOGGER_NORMAL = 2,
	LOGGER_WARNING = 3,
	LOGGER_ERROR = 4,
}

---
---Gets the current state of the given `button`.
---
---@param button integer # Refer to `game.BUTTON_*` for options
---@return boolean isBeingPressed
function game.GetButton(button) end

---
---Gets the absolute rotation value of the indexed knob in range `[0, 2 * pi]`.
---
---@param knobIndex integer #
---* `0` = Left Knob
---* `1` = Right Knob
---@return number radians
function game.GetKnob(knobIndex) end

---
---Gets the RGB color values of the indexed laser.
---
---@param laserIndex integer #
---* `0` = Left Laser
---* `1` = Right Laser
---@return integer R, integer G, integer B
function game.GetLaserColor(laserIndex) end

---
---Gets the pixel coordinates of the current mouse position.
---
---@return number x, number y
function game.GetMousePos() end

---
---Gets the pixel dimensions of the current game window.
---
---@return number w, number h
function game.GetResolution() end

---
---Gets the name of the current skin.
---
---@return string skinName
function game.GetSkin() end

---
---Gets the value of the named skin setting.
---
---@param skinSettingName string
---@return ...
function game.GetSkinSetting(skinSettingName) end

---
---Checks if the named sample is currently playing.
---
---@param sampleName string # Name of the sample loaded with `game.LoadSkinSample`.
---@return boolean|nil isPlaying # If the sample is not loaded, returns `nil`.
function game.IsSamplePlaying(sampleName) end

---
---Loads the named sample within the `audio` folder of the current skin.
---
---@param sampleName string # If no extension is provided, `.wav` is assumed.
function game.LoadSkinSample(sampleName) end

---
---Logs the given `message` to the game's log file
---
---@param message string
---@param severity integer # Refer to `game.LOGGER_*` for options
function game.Log(message, severity) end

---
---Starts playback of the named sample.
---
---@param sampleName string
---@param loop? boolean # If `true`, the sample will loop until stopped with `game.StopSample`.
function game.PlaySample(sampleName, loop) end

---
---Sets the value of the named skin setting.
---
---@param skinSettingName string
---@param value any # The type of the given value must match the type of the defined skin setting.
function game.SetSkinSetting(skinSettingName, value) end

---
---Stops playback of the named sample.
---
---@param sampleName string
function game.StopSample(sampleName) end

---
---Checks if a game update is available.
---
---@return string url, string version # If there is no update available, returns `nil`.
function game.UpdateAvailable() end
