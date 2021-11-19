local Easing = require("common/Easing")
local removeParentheses = require("common/helpers/removeParentheses")

local max = math.max

---@param settings SettingsDiagSetting[]
local function handleBlastiveLevel(settings)
	if (settings[1].options and (#settings[1].options > 2))
		and (settings[1].value and (settings[1].value ~= 4))
	then
		table.insert(settings, 2, {
			name = "Blastive Rate Level",
			type = "float",
		})
	end
end

---@param isSongSelect? boolean
---@return Easing[], table<string, table<string, FormattedSetting>>, Label[]
local function getSettingsProps(isSongSelect)
	local FormattedTabs = (isSongSelect and require("settingswindow/constants/FormattedGameSettings"))
		or require("settingswindow/constants/FormattedPracticeSettings")
	local highlights = {}
	local highlightCount = 0
	local tabs = {}
	local settings = {}

	for i, tab in ipairs(SettingsDiag.tabs) do
		local tabName = tab.name
		local formattedTab = FormattedTabs[tabName]
		local formattedTabName = (formattedTab and formattedTab.name) or tabName

		---@diagnostic disable-next-line
		tabs[i] = makeLabel("SemiBold", formattedTabName)

		if isSongSelect and (tabName == "Game") then
			handleBlastiveLevel(tab.settings)
		end

		settings[i] = {}

		highlightCount = max(highlightCount, #tab.settings)

		for _, setting in ipairs(tab.settings) do
			local settingName = removeParentheses(setting.name or "")
			local settingType = setting.type
			local formattedSetting = (formattedTab and formattedTab[settingName]) or {}
			local newSetting = {
				category = formattedSetting.category or "",
				isInverted = formattedSetting.isInverted,
				---@diagnostic disable-next-line
				name = makeLabel("Medium", formattedSetting.name or settingName, 32),
				options = formattedSetting.options or setting.options,
			}

			if formattedSetting.description then
				local description = {}

				for j, text in ipairs(formattedSetting.description) do
					description[j] = makeLabel("SemiBold", text)
				end

				newSetting.description = description
			end

			if (settingType == "int") or (settingType == "float") then
				newSetting.value = makeLabel("Number", "0", 29)
			elseif settingType ~= "button" then
				newSetting.value = makeLabel("Medium", "", 32)
			end

			settings[i][settingName] = newSetting
		end
	end

	for i = 1, highlightCount do
		highlights[i] = Easing.new()
	end

	return highlights, settings, tabs
end

return getSettingsProps
