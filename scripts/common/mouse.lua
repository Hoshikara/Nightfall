---@class Mouse: MouseBase
local Mouse = {}
Mouse.__index = Mouse

---@param window Window
---@return Mouse
function Mouse.new(window)
	---@class MouseBase
	local self = {
		window = window,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, Mouse)
end

function Mouse:update()
	self.x, self.y = game.GetMousePos()
end

---@return number x, number y
function Mouse:getPos()
	local scale = self.window.scaleFactor

	return (self.x - self.window.shiftX) / scale,
	(self.y - self.window.shiftY) / scale
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean
function Mouse:clipped(x, y, w, h)
	local scale = self.window.scaleFactor

	x = (x * scale) + self.window.shiftX
	y = (y * scale) + self.window.shiftY
	w = x + (w * scale)
	h = y + (h * scale)

	return (self.x > x) and (self.y > y) and (self.x < w) and (self.y < h)
end

return Mouse
