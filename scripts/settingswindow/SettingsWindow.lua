local ControlLabel = require("common/ControlLabel")
local removeParentheses = require("common/helpers/removeParentheses")
local formatBool = require("settingswindow/helpers/formatBool")
local formatFloat = require("settingswindow/helpers/formatFloat")
local formatInt = require("settingswindow/helpers/formatInt")
local getSettingsProps = require("settingswindow/helpers/getSettingsProps")

---@class SettingsWindow: SettingsWindowBase
local SettingsWindow = {}
SettingsWindow.__index = SettingsWindow

---@param ctx SettingsWindowContext
---@param window Window
---@param isSongSelect? boolean
---@return SettingsWindow
function SettingsWindow.new(ctx, window, isSongSelect)
	---@class SettingsWindowBase
	---@field description Label[]|nil
	local self = {
		currentSetting = 0,
		ctx = ctx,
		description = {},
		descriptionAlpha = 0,
		modifyValueControl = ControlLabel.new("KNOB-R / BT-A  -  BT-D", "MODIFY VALUE"),
		selectOptionControl = ControlLabel.new("KNOB-R / BT-A  -  BT-D", "SELECT OPTION"),
		selectSettingControl = ControlLabel.new("KNOB-L", "SELECT SETTING"),
		selectTabControl = ControlLabel.new("FX-L / FX-R", "SELECT TAB"),
		shift = 0,
		triggerControl = ControlLabel.new("START", "TRIGGER"),
		whichControl = "value",
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 808,
		h = 664,
	}

	self.highlights, self.settings, self.tabs = getSettingsProps(isSongSelect)

	---@diagnostic disable-next-line
	return setmetatable(self, SettingsWindow)
end

---@param dt deltaTime
function SettingsWindow:draw(dt)
	self:setProps()

	if self.ctx.isSongSelect then
		self:drawDim()
	end

	gfx.Translate(self.x + (self.shift * self.ctx.shift.value), self.y)
	self:drawWindow(dt)
end

function SettingsWindow:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = -self.w - self.window.shiftX
		self.y = (self.window.h / 2) - (self.h / 2)

		if self.ctx.isSongSelect then
			self.shift = self.w + self.window.shiftX + (self.window.w / 2) - (self.w / 2)
		else
			self.shift = self.w + self.window.shiftX
		end

		self.windowResized = self.window.resized
	end
end

function SettingsWindow:drawDim()
	local window = self.window
	local scale = window.scaleFactor

	drawRect({
		x = -window.shiftX / scale,
		y = -window.shiftY / scale,
		w = window.resX / scale,
		h = window.resY / scale,
		alpha = self.ctx.shift.value * 0.4,
		color = "Black",
	})
end

---@param dt deltaTime
function SettingsWindow:drawWindow(dt)
	local tabIndex = self.ctx.tabIndex
	local x = 31
	local y = -6

	drawRect({
		w = self.w,
		h = self.h,
		alpha = 0.95,
		color = "Black",
		stroke = { color = "Medium", size = 2 },
	})

	self:drawHeader(x, y, tabIndex)

	y = y + 63

	self:drawSettings(dt, x, y, tabIndex)

	if self.description then
		self:drawDescription(x, y)
	end

	self:drawControls(x, y)
end

---@param x number
---@param y number
---@param tabIndex integer
function SettingsWindow:drawHeader(x, y, tabIndex)
	y = y + 31

	for i, tab in ipairs(self.tabs) do
		tab:draw({
			x = x,
			y = y,
			alpha = ((i == tabIndex) and 1) or 0.4,
			color = "White",
		})

		x = x + tab.w + 30
	end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param tabIndex integer
function SettingsWindow:drawSettings(dt, x, y, tabIndex)
	local highlights = self.highlights
	local settingIndex = self.ctx.settingIndex
	local settings = self.settings[tabIndex]
	local w = self.w - 64

	x = x + 6
	y = y + 16

	for i, setting in ipairs(self.ctx.settings) do
		local isCurrent = i == settingIndex

		if isCurrent then
			highlights[i]:start(dt, 3, 0.2)
		else
			highlights[i]:stop(dt, 3, 0.2)
		end

		self:drawSetting(
			x,
			y,
			w,
			setting,
			settings[removeParentheses(setting.name)],
			highlights[i].value,
			isCurrent
		)

		y = y + 44
	end
end

---@param x number
---@param y number
---@param w number
---@param baseSetting SettingsDiagSetting
---@param setting FormattedSetting
---@param highlight number
---@param isCurrent boolean
function SettingsWindow:drawSetting(x, y, w, baseSetting, setting, highlight, isCurrent)
	if setting then
		local alpha = 0.4 + (0.6 * highlight)

		if isCurrent then
			self.description = setting.description
			self.descriptionAlpha = highlight
		end

		drawRect({
			x = x - 5,
			y = y + 4,
			w = w * highlight,
			h = 36,
			alpha = 0.5,
			color = "Standard",
		})
		---@diagnostic disable-next-line
		setting.name:draw({
			x = x,
			y = y,
			color = "White",
			alpha = alpha,
		})

		self:drawSettingValue(x, y, w, alpha, baseSetting, setting, isCurrent)
	end
end

---@param x number
---@param y number
---@param w number
---@param alpha number
---@param baseSetting SettingsDiagSetting
---@param setting FormattedSetting
---@param isCurrent boolean
function SettingsWindow:drawSettingValue(x, y, w, alpha, baseSetting, setting, isCurrent)
	local offsetY = 0
	local params = {
		x = x + w - 12,
		align = "RightTop",
		alpha = alpha,
		color = "White",
		update = true,
	}
	local type = baseSetting.type

	if type == "int" then
		if isCurrent then
			self.whichControl = "value"
		end

		params.color, params.text = formatInt(setting.category, baseSetting)
		offsetY = 3
	elseif type == "float" then
		if isCurrent then
			self.whichControl = "value"
		end

		params.text = formatFloat(setting.category, baseSetting)
		offsetY = 3
	elseif type == "enum" then
		if isCurrent then
			self.whichControl = "option"
		end

		params.text = setting.options[baseSetting.value]
	elseif type == "toggle" then
		if isCurrent then
			self.whichControl = "option"
		end

		params.color, params.text = formatBool(setting.isInverted, baseSetting)
	elseif type == "button" then
		if isCurrent then
			self.whichControl = "button"
		end
	end

	if setting.value then
		params.y = y + offsetY
		setting.value:draw(params)
	end
end

---@param category string
---@param setting SettingsDiagSetting
---@param isCurrent boolean
---@return string, string
function SettingsWindow:handleFloat(category, setting, isCurrent)
	local color = "White"
	local text = ""

	if isCurrent then
		self.whichControl = "value"
	end

	if category == "hitWindow" then
		text = ("±%d ms"):format(setting.value)

		if setting.value < setting.max then
			color = "Negative"
		end
	elseif (category == "time") or setting.name:lower():find("offset") then
		text = ("%d ms"):format(setting.value)
	else
		text = tostring(setting.value)
	end

	return color, text
end

---@param x number
---@param y number
function SettingsWindow:drawDescription(x, y)
	local alpha = self.descriptionAlpha
	local numLines = #self.description

	y = y + 525

	for _, line in ipairs(self.description) do
		---@diagnostic disable-next-line
		line:draw({
			x = x,
			y = y - (numLines * 25),
			alpha = alpha,
			color = "White",
		})

		numLines = numLines - 1
	end
end

---@param x number
---@param y number
function SettingsWindow:drawControls(x, y)
	local whichControl = self.whichControl

	x = x + 2
	y = y + 553

	self.selectTabControl:draw(x, y)

	x = x + 208

	self.selectSettingControl:draw(x, y)

	x = x + 226

	if whichControl == "button" then
		self.triggerControl:draw(x, y)
	elseif whichControl == "option" then
		self.selectOptionControl:draw(x, y)
	elseif whichControl == "value" then
		self.modifyValueControl:draw(x, y)
	end
end

return SettingsWindow
