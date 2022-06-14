---@class Window
local Window = {}
Window.__index = Window

---@return Window
function Window.new()
	---@type Window
	local self = {
		cornerX = 0,
		cornerY = 0,
		footerY = 0,
		headerY = 0,
		isPortrait = false,
		paddingX = 80,
		paddingY = 56,
		resized = false,
		resX = 0,
		resY = 0,
		scaleFactor = 1,
		shiftX = 0,
		shiftY = 0,
		w = 0,
		h = 0,
	}

	return setmetatable(self, Window)
end

---@param dontScale? boolean
function Window:update(dontScale)
	local resX, resY = game.GetResolution()

	if (self.resX ~= resX) or (self.resY ~= resY) then
		local isPortrait = resY > resX

		self:updateProps(isPortrait)

		local scale = self:updateScaling(isPortrait, resX, resY)

		self.isPortrait = isPortrait
		self.resized = not self.resized
		self.resX = resX
		self.resY = resY
		self.scaleFactor = scale
	end

	self:setup(dontScale)
end

---@param dontScale boolean
function Window:setup(dontScale)
	gfx.ResetTransform()
	gfx.Translate(self.shiftX, self.shiftY)

	if dontScale then
		return
	end

	gfx.Scale(self.scaleFactor, self.scaleFactor)
end

---@param isPortrait boolean
function Window:updateProps(isPortrait)
	if isPortrait then
		self.w = 1080
		self.h = 1920
		self.paddingX = 56
		self.paddingY = 80
		self.footerY = self.h - self.paddingY + 30
		self.headerY = self.paddingY - 38
	else
		self.w = 1920
		self.h = 1080
		self.paddingX = 80
		self.paddingY = 56
		self.footerY = self.h - self.paddingY + 17
		self.headerY = self.paddingY - 38
	end
end

---@param isPortrait boolean
---@param resX number
---@param resY number
---@return number
function Window:updateScaling(isPortrait, resX, resY)
	local aspectRatio = (isPortrait and (1080 / 1920)) or (1920 / 1080)
	local scale = resX / self.w

	if (resX / resY) > aspectRatio then
		scale = resY / self.h
	end

	self.shiftX = (resX - (self.w * scale)) / 2
	self.shiftY = (resY - (self.h * scale)) / 2

	return scale
end

---@param multiplier number
function Window:scale(multiplier)
	multiplier = multiplier or 1

	gfx.Scale(self.scaleFactor * multiplier, self.scaleFactor * multiplier)
end

function Window:unscale()
	gfx.Scale(1 / self.scaleFactor, 1 / self.scaleFactor)
end

return Window
