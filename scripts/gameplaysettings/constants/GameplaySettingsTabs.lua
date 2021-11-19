local GameplaySettingProperties = require("gameplaysettings/constants/GameplaySettingProperties")
local advanceSelection = require("common/helpers/advanceSelection")

--#region Helpers

---@param value number
---@param min number
---@param max number
---@param increment number
---@return number
local function step(value, min, max, increment)
	value = value + increment

	if value < min then
		value = max
	end

	if value > max then
		value = min
	end

	if value > min and (value < (min + increment)) then
		value = min
	end

	return value
end

---@param int integer
---@return integer
local function toggle(int)
	if int == 0 then
		return 1
	end

	return 0
end

---@param setting GameplaySetting
---@param params GameplaySettingProperties
local function handleIncrementSetting(setting, params)
	setting.text = (setting.templateString):format(setting.value * setting.multi)
	setting.valueLabel = makeLabel("Number", setting.text, 20)
	setting.offsetY = 4

	function setting.event(sign)
		setting.value = step(
			setting.value,
			params.min,
			params.max,
			params.increment * sign
		)
		setting.text = (setting.templateString):format(setting.value * setting.multi)

		game.SetSkinSetting(params.key, setting.value)
	end
end

---@param setting GameplaySetting
---@param params GameplaySettingProperties
local function handleOptionsSetting(setting, params)
	setting.options = params.options

	for i, option in ipairs(params.options) do
		if option == setting.value then
			setting.currentOption = i

			break
		end
	end

	if not setting.currentOption then
		setting.currentOption = 1
	end

	setting.value = setting.options[setting.currentOption]
	setting.text = setting.value
	setting.valueLabel = makeLabel("Medium", setting.text, 24)

	function setting.event(sign)
		setting.currentOption = advanceSelection(
			setting.currentOption,
			#setting.options,
			sign
		)
		setting.value = setting.options[setting.currentOption]
		setting.text = setting.value

		game.SetSkinSetting(params.key, setting.value)
	end
end

---@param setting GameplaySetting
---@param params GameplaySettingProperties
local function handleToggleSetting(setting, params)
	setting.options = { [0] = "DISABLED", [1] = "ENABLED" }
	setting.text = setting.options[setting.value]
	setting.valueLabel = makeLabel("Medium", setting.text, 24)

	function setting.event()
		setting.value = toggle(setting.value)
		setting.text = setting.options[setting.value]

		if setting.value == 0 then
			setting.color = "Negative"
		else
			setting.color = "Positive"
		end

		game.SetSkinSetting(params.key, setting.value)
	end
end

---@param params GameplaySettingProperties
---@return GameplaySetting
local function makeSetting(params)
	---@type GameplaySetting
	local setting = {
		color = "White",
		currentOption = 1,
		event = nil,
		multi = params.multi or 100,
		offsetY = 0,
		templateString = params.templateString or "%.0f%%",
		text = "",
		value = getSetting(params.key, params.default or 0),
		valueLabel = nil,
	}

	if params.name then
		setting.name = makeLabel("Medium", params.name, 24)
	end

	if type(setting.value) == "boolean" then
		setting.color = (setting.value and "Positive") or "Negative"
		setting.value = (setting.value and 1) or 0
	end

	if params.increment then
		handleIncrementSetting(setting, params)
	elseif params.options then
		handleOptionsSetting(setting, params)
	else
		handleToggleSetting(setting, params)
	end

	return setting
end

---@param tabName string
---@return GameplaySetting[]
local function makeSettings(tabName)
	local settings = {}

	for i, props in ipairs(GameplaySettingProperties[tabName]) do
		settings[i] = makeSetting(props)
	end

	return settings
end

---@param heading string
---@param tabName string
---@return GameplaySettingTab
local function makeTab(heading, tabName)
	local tab = {
		heading = makeLabel("Medium", heading, 24),
		settings = makeSettings(tabName),
	}

	return tab
end

--#endregion

---@type table<string, GameplaySettingTab>
local GameplaySettingsTabs = {
	Chain = makeTab("CHAIN", "Chain"),
	Earlate = makeTab("EARLY / LATE", "Earlate"),
	GaugeBar = makeTab("GAUGE BAR", "GaugeBar"),
	HitAnimations = makeTab("HIT ANIMATIONS", "HitAnimations"),
	HitDeltaBar = makeTab("HIT DELTA BAR", "HitDeltaBar"),
	LaneSpeed = makeTab("LANE-SPEED", "LaneSpeed"),
	PlayerCard = makeTab("PLAYER CARD", "PlayerCard"),
	ScoreDifference = makeTab("SCORE DIFFERENCE", "ScoreDifference"),
}

return GameplaySettingsTabs

--#region Interfaces

---@class GameplaySettingTab
---@field component any
---@field draw function
---@field heading Label
---@field height number
---@field settings GameplaySetting[]

---@class GameplaySetting
---@field color? string
---@field currentOption? integer
---@field event? function
---@field multi? number
---@field name Label
---@field offsetY number
---@field templateString? string
---@field text? string
---@field value? any
---@field valueLabel? Label

--#endregion
