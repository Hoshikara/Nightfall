---@class GameSetting: GameSettingBase
local GameSetting = {}
GameSetting.__index = GameSetting

---@param params GameSetting.new.params
---@return GameSetting
function GameSetting.new(params)
	---@class GameSettingBase
	local self = {
		default = params.default or "",
		firstTabName = params.firstTabName or "",
		key = params.key or "",
		settingIndex = nil,
		settingName = params.settingName or "",
		tabIndex = nil,
		tabName = params.tabName or "",
		type = params.type or "number",
	}

	---@diagnostic disable-next-line
	return setmetatable(self, GameSetting)
end

function GameSetting:set()
	local value = self:getSettingValue()

	if self.type == "bool" then
		game.SetSkinSetting(self.key, ((value == true) and 1) or 0)
	elseif self.type == "number" then
		game.SetSkinSetting(tostring(value))
	else
		game.SetSkinSetting(value:upper())
	end
end

---@return any
function GameSetting:getSettingValue()
	local tabs = SettingsDiag.tabs

	if tabs[1].name ~= self.firstTabName then
		return self.default
	end

	if self.settingIndex and self.tabIndex then
		local setting = tabs[self.tabIndex].settings[self.settingIndex]

		if setting and (setting.value ~= nil) then
			if setting.options then
				return setting.options[setting.value]
			end

			return setting.value
		end
	end

	for i, tab in ipairs(tabs) do
		if tab.name == self.tabName then
			self.tabIndex = i

			for j, setting in ipairs(tab.settings) do
				if setting.name == self.settingName then
					self.settingIndex = j

					if setting.options then
						return setting.options[setting.value]
					end

					return setting.value
				end
			end
		end
	end

	return self.default
end

return GameSetting

---@class GameSetting.new.params
---@field default any
---@field firstTabName string
---@field key string
---@field settingName string
---@field tabName string
---@field type string
