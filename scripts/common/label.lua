local Fonts = require("common/constants/Fonts")
local TextAlignments = require("common/constants/TextAlignments")

local max = math.max

---@class Label
local Label = {}
Label.__index = Label

---@param params Label.new.params
---@return Label
function Label.new(params)
	---@type Label
	local self = {
		color = params.color or "Standard",
		font = params.font or "JP",
		size = params.size or 50,
		text = params.text or "Label Text",
		w = 0,
		h = 0,
	}
	
	if self.font ~= "Number" then
		self.text = self.text:upper()
	end

	Fonts:load(self.font)
	self.label = gfx.CreateLabel(self.text, self.size, 0)
	self.w, self.h = gfx.LabelSize(self.label)

	return setmetatable(self, Label)
end

---@param text string
---@param size string
---@param font string
function Label:update(text, size, font)
	font = font or self.font
	text = text or self.text

	if font ~= "Number" then
		text = text:upper()
	end

	Fonts:load(font)
	gfx.UpdateLabel(self.label, text, size or self.size)
	self.w, self.h = gfx.LabelSize(self.label)
end

---@param params Label.draw.params
function Label:draw(params)
	local alpha = params.alpha or 1
	local maxWidth = params.maxWidth or -1
	local x = params.x or 0
	local y = params.y or 0

	if params.update then
		self:update(params.text, params.size, params.font)
	end

	gfx.BeginPath()
	TextAlignments:align(params.align)
	setColor("Black", alpha * 0.5)
	gfx.DrawLabel(self.label, x + 1, y + 1, maxWidth)
	setColor(params.color or self.color, alpha)
	gfx.DrawLabel(self.label, x, y, maxWidth)
end

---@param params Label.drawScrolling.params
function Label:drawScrolling(params)
	local alpha = params.alpha or 1
	local scale = params.scale or 1
	local timer = (params.timer or 0) * 2
	local width = params.width or 0
	local labelX = self.w + 80
	local duration = (labelX / 80) * 0.75
	local phase = max((timer % (duration + 1.5)) - 1.5, 0) / duration
	local x = params.x or 0
	local y = params.y or 0

	if params.update then
		self:update(params.text, params.size, params.font)
	end

	gfx.Save()
	gfx.BeginPath()
	TextAlignments:align("params.align")
	gfx.Scissor((x + 2) * scale, y * scale, width, self.h * 1.25)
	setColor("Black", alpha * 0.5)
	gfx.DrawLabel(self.label, x - (phase * labelX) + 1, y + 1, -1)
	gfx.DrawLabel(self.label, x - (phase * labelX) + labelX + 1, y + 1, -1)
	setColor(params.color or self.color, alpha)
	gfx.DrawLabel(self.label, x - (phase * labelX), y, -1)
	gfx.DrawLabel(self.label, x - (phase * labelX) + labelX, y, -1)
	gfx.ResetScissor()
	gfx.Restore()
end

return Label

--#region Interfaces

---@class Label.new.params
---@field color? string
---@field font? string
---@field size? integer
---@field text? string

---@class Label.draw.params
---@field x? number
---@field y? number
---@field align? string
---@field alpha? number
---@field color? string|Color
---@field font? string
---@field maxWidth? number
---@field size? integer
---@field text? string
---@field update? boolean

---@class Label.drawScrolling.params
---@field x? number
---@field y? number
---@field align? string
---@field alpha? number
---@field color? string|Color
---@field font? string
---@field scale? number
---@field timer? number
---@field width? number
---@field size? integer
---@field text? string
---@field update? boolean

--#endregion
