---@param isInverted boolean
---@param setting SettingsDiagSetting
---@return string, string
local function formatBool(isInverted, setting)
	local color = "Negative"
	local text = ""

	if setting.value then
		if isInverted then
			text = "DISABLED"
		else
			text = "ENABLED"
		end
	else
		if isInverted then
			text = "ENABLED"
		else
			text = "DISABLED"
		end
	end

	if (text == "ENABLED") or (text == "true") then
		color = "Positive"
	end

	return color, text
end

return formatBool
