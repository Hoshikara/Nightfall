local SettingsWindowContext = require("settingswindow/SettingsWindowContext")
local SettingsWindow = require("settingswindow/SettingsWindow")

local window = Window.new()

local context = SettingsWindowContext.new()
local gameSettingsWindow = nil
local practiceSettingsWindow = nil

---@param dt deltaTime
---@param isVisible boolean
function render(dt, isVisible)
	if isVisible then
		game.SetSkinSetting("_isViewingTop50", 0)
	end

	context:update(dt, isVisible)

	if context.shift.value == 0 then
		return
	end

	gfx.ForceRender()
	gfx.Save()
	window:update()

	if context.isSongSelect then
		if not gameSettingsWindow then
			gameSettingsWindow = SettingsWindow.new(context, window, true)
		else
			gameSettingsWindow:draw(dt)
		end
	else
		if not practiceSettingsWindow then
			practiceSettingsWindow = SettingsWindow.new(context, window)
		else
			practiceSettingsWindow:draw(dt)
		end
	end

	gfx.Restore()
end
