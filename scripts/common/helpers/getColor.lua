---@param settingKey string
---@return Color
local function getColor(settingKey)
	local r, g, b, _ = game.GetSkinSetting(settingKey)

	return {
		r or 0,
		g or 0,
		b or 0,
	}
end

return getColor
