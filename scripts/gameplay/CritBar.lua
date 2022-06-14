local Image = require("common/Image")

local abs = math.abs
local sin = math.sin

local r, g, b, _ = game.GetSkinSetting("colorScheme")
local Color = { r, g, b }

---@class CritBar
local CritBar = {}
CritBar.__index = CritBar

---@return CritBar
function CritBar.new(window)
	---@type CritBar
	local self = {
		consoleFront = Image.new({ path = "gameplay/console/front" }),
		fill = Image.new({ path = "gameplay/crit_bar/fill" }),
		flickerTimer = 0,
		overlay = Image.new({ path = "gameplay/crit_bar/overlay" }),
		window = window,
	}

	return setmetatable(self, CritBar)
end

---@param dt deltaTime
function CritBar:draw(dt)
	local isPortrait = self.window.isPortrait
	local w = self.window.w * ((isPortrait and 1.02) or 0.9)

	gfx.Save()
	self.window:scale()
	drawRect({
		x = -w,
		y = 6,
		w = w * 2,
		h = self.window.h / 2,
		alpha = 0.8,
		color = "Black",
	})
	self:drawBar(dt, w)

	if isPortrait then
		self:drawConsoleFront()
	end

	gfx.Restore()
end

---@param dt deltaTime
---@param w number
function CritBar:drawBar(dt, w)
	self.flickerTimer = self.flickerTimer + dt

	self.fill:draw({
		w = w,
		h = 14,
		alpha = 0.8 + (0.2 * abs(sin(self.flickerTimer * 50))),
		blendOp = 8,
		isCentered = true,
		tint = Color,
	})
	self.fill:draw({
		w = w,
		h = 14,
		alpha = 0.5,
		isCentered = true,
		tint = Color,
	})
	self.overlay:draw({
		w = w,
		h = 14,
		isCentered = true,
	})
end

function CritBar:drawConsoleFront()
	self.consoleFront:draw({
		y = self.consoleFront.h * 0.9,
		isCentered = true,
	})
end

return CritBar
