---@class Grid: GridBase
local Grid = {}
Grid.__index = Grid

---@param window Window
---@return Grid
function Grid.new(window)
	---@class GridBase
	local self = {
		jacketSize = 0,
		margin = 0,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, Grid)
end

function Grid:setProps()
	if self.windowResized ~= self.window.resized then
		if self.window.isPortrait then
			self.jacketSize = 296
			self.margin = 40
			self.h = self.window.w - (self.window.paddingX * 2)
			self.y = self.window.h - self.window.paddingY - self.h
		else
			self.jacketSize = 280
			self.margin = 36
			self.h = self.window.h - (self.window.paddingY * 3)
			self.y = self.window.paddingY * 2
		end

		self.w = self.h
		self.x = self.window.w - self.window.paddingX - self.w
		self.windowResized = self.window.resized
	end
end

return Grid
