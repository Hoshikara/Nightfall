local Easing = require("common/Easing")
local GameSetting = require("settingswindow/GameSetting")
local removeParentheses = require("common/helpers/removeParentheses")

local arsEnabled = GameSetting.new({
	default = false,
	firstTabName = "Offsets",
	key = "_arsEnabled",
	settingName = "Backup Gauge",
	tabName = "Game",
	type = "bool",
})
local songOffset = GameSetting.new({
	default = 0,
	firstTabName = "Offsets",
	key = "_songOffset",
	settingName = "Song Offset",
	tabName = "Offsets",
	type = "number",
})

---@class SettingsWindowContext: SettingsWindowContextBase
local SettingsWindowContext = {}
SettingsWindowContext.__index = SettingsWindowContext

---@return SettingsWindowContext
function SettingsWindowContext.new()
	---@class SettingsWindowContextBase
	local self = {
		settings = {},
		settingName = "",
		shift = Easing.new(),
		settingIndex = 0,
		tabName = "",
		tabIndex = 0,
		isSongSelect = true,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, SettingsWindowContext)
end

---@param dt deltaTime
---@param isVisible boolean
function SettingsWindowContext:update(dt, isVisible)
	self:handleShift(dt, isVisible)

	if self.shift.value > 0 then
		local tabs = SettingsDiag.tabs

		self.setSettings(isVisible)

		self.isSongSelect = tabs[1].name ~= "Main"
		self.settingIndex = SettingsDiag.currentSetting
		self.tabIndex = SettingsDiag.currentTab

		local tab = tabs[self.tabIndex]

		self.settings = tab.settings
		self.settingName = removeParentheses(self.settings[self.settingIndex].name)
		self.tabName = tab.name
	end
end

---@param dt deltaTime
---@param isVisible boolean
function SettingsWindowContext:handleShift(dt, isVisible)
	if isVisible then
		self.shift:start(dt, 3, 0.2)
	else
		self.shift:stop(dt, 3, 0.2)
	end
end

---@param isVisible boolean
function SettingsWindowContext.setSettings(isVisible)
	arsEnabled:set()
	songOffset:set()
	game.SetSkinSetting("_changingSettings", (isVisible and 1) or 0)
end

return SettingsWindowContext
