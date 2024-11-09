SKIN_VERSION = "1.5.7"

gfx.LoadSkinFont("SmartFontUI.otf")

--#region Require

Colors = require("common/constants/Colors")
Background = require("common/Background")
Window = require("common/Window")

local Label = require("common/Label")

--#endregion

local FontSizes = {
	SemiBold = 20,
	JP = 24,
	Medium = 24,
	Number = 20,
	Regular = 32,
}

--#region Functions

local floor = math.floor

---@param params drawRectParams
function drawRect(params)
	local scale = params.scale or 1
	local x = params.x or 0
	local y = params.y or 0
	local w = (params.w or 500) * scale
	local h = (params.h or 500) * scale

	if params.isCentered then
		x = x - (w * 0.5)
		y = y - (h * 0.5)
	end

	gfx.BeginPath()

	if params.blendOp then
		gfx.GlobalCompositeOperation(params.blendOp)
	end

	if params.image then
		if params.tint then
			gfx.SetImageTint(params.tint[1], params.tint[2], params.tint[3])
			gfx.ImageRect(x, y, w, h, params.image, params.alpha or 1, 0)
			gfx.SetImageTint(255, 255, 255)
		else
			gfx.ImageRect(x, y, w, h, params.image, params.alpha or 1, 0)
		end
	else
		setColor(params.color, params.alpha)

		if params.isFast then
			gfx.FastRect(x, y, w, h)
		elseif params.radius then
			gfx.RoundedRect(x, y, w, h, params.radius)
		else
			gfx.Rect(x, y, w, h)
		end

		gfx.Fill()
	end

	if params.stroke then
		setStroke(params.stroke)
		gfx.Stroke()
	end
end

---@param settingKey string
---@param default any
---@return any
function getSetting(settingKey, default)
	local setting = game.GetSkinSetting(settingKey)

	if setting == nil then
		return default
	end

	if type(setting) == "string" then
		setting = setting:gsub('[%"%\r]', "")
	end

	return setting
end

---@param font? string
---@param text? number|string
---@param size? integer
---@param color? Color|string
---@return Label
function makeLabel(font, text, size, color)
	return Label.new({
		color = color,
		font = font,
		size = size or FontSizes[font],
		text = text,
	})
end

---@param color? string|Color
---@param alpha? number
function setColor(color, alpha, isStroke)
	alpha = floor((alpha or 1) * 255)
	color = Colors[color] or color or Colors.White

	if isStroke then
		gfx.StrokeColor(color[1], color[2], color[3], alpha)
	else
		gfx.FillColor(color[1], color[2], color[3], alpha)
	end
end

---@param params setStrokeParams
function setStroke(params)
	setColor(params.color, params.alpha, true)
	gfx.StrokeWidth(params.size or 1)
end

--#endregion

--#region Interfaces

---@class drawRectParams
---@field x? number
---@field y? number
---@field w? number
---@field h? number
---@field alpha? number
---@field color? string|Color
---@field blendOp? integer
---@field image? any
---@field isCentered? boolean
---@field isFast? boolean
---@field radius? number
---@field scale? number
---@field stroke? setStrokeParams
---@field tint? string|Color

---@class setStrokeParams
---@field alpha? number
---@field color? string|Color
---@field size? number

--#endregion
