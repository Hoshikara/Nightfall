local RatingColors = require("common/constants/RatingColors")

---@class Earlate: EarlateBase
local Earlate = {}
Earlate.__index = Earlate

---@param ctx GameplayContext
---@param window Window
---@param isGameplaySettings? boolean
---@return Earlate
function Earlate.new(ctx, window, isGameplaySettings)
	---@class EarlateBase
	local self = {
		alpha = 0,
		ctx = ctx,
		delta = makeLabel("Number", "0.0 ms", 27),
		deltaAlign = "CenterMiddle",
		displayType = getSetting("earlateType", "TEXT"),
		early = makeLabel("Medium", "EARLY", 30),
		flickerEnabled = getSetting("earlateFlicker", true),
		flickerTimer = 0,
		isGameplaySettings = isGameplaySettings,
		late = makeLabel("Medium", "LATE", 30),
		offset = 0,
		opacity = getSetting("earlateOpacity", 1),
		scale = getSetting("earlateScale", 1),
		textAlign = "CenterMiddle",
		textDeltaGap = getSetting("earlateGap", 0.25),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, Earlate)
end

---@param dt deltaTime
function Earlate:draw(dt)
	if self.isGameplaySettings then
		self:updateProps()
	else
		self.ctx.earlateTimer = self.ctx.earlateTimer - dt

		if self.ctx.earlateTimer < 0 then
			return
		end
	end

	self:setProps()

	gfx.Save()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawEarlate(dt)
	gfx.Restore()
end

function Earlate:setProps()
	if (self.windowResized ~= self.window.resized) or self.isGameplaySettings then
		local posX = getSetting("earlateX", 0.5)
		local posY = getSetting("earlateY", 0.5)

		self.offset = 0
		self.x = self.window.w * posX

		if self.window.isPortrait then
			self.y = 294 + ((self.window.h * 0.625) * posY)
		else
			self.y = self.window.h * posY
		end

		if self.displayType == "TEXT + DELTA" then
			self.deltaAlign = "RightMiddle"
			self.textAlign = "LeftMiddle"

			if self.window.isPortrait then
				self.offset = self.window.w * (self.textDeltaGap * 0.4)
			else
				self.offset = self.window.w * (self.textDeltaGap * 0.25)
			end
		else
			self.deltaAlign = "CenterMiddle"
			self.textAlign = "CenterMiddle"
		end

		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
function Earlate:drawEarlate(dt)
	local alpha = self:getAlpha(dt)
	local color, delta, text = self:getProps()
	local displayType = self.displayType
	local offset = self.offset

	if (displayType ~= "DELTA") and (not self.ctx.critHit) then
		text:draw({
			x = -offset,
			y = 1,
			align = self.textAlign,
			alpha = 0.4 * alpha,
			color = "White",
		})
		text:draw({
			x = -offset,
			y = 0,
			align = self.textAlign,
			alpha = alpha,
			color = color,
		})
	end

	if displayType ~= "TEXT" then
		self.delta:draw({
			x = offset,
			y = 2,
			align = self.deltaAlign,
			alpha = 0.4 * alpha,
			color = "White",
			text = delta,
			update = true,
		})
		self.delta:draw({
			x = offset,
			y = 1,
			align = self.deltaAlign,
			alpha = alpha,
			color = color,
			text = delta,
			update = true,
		})
	end
end

---@param dt deltaTime
function Earlate:getAlpha(dt)
	if self.flickerEnabled then
		self.flickerTimer = self.flickerTimer + dt

		return ((self.flickerTimer * 18) % 1) * self.opacity
	end

	return self.opacity
end

---@return Color, string, Label
function Earlate:getProps()
	local buttonDelta = self.ctx.buttonDelta or -1
	local color = RatingColors.Early
	local delta = "%.1f ms"
	local text = self.early

	if buttonDelta > 0 then
		color = RatingColors.Late
		delta = "+%.1f ms"
		text = self.late
	end

	return color, delta:format(buttonDelta), text
end

function Earlate:updateProps()
	self.displayType = getSetting("earlateType", "TEXT")
	self.flickerEnabled = getSetting("earlateFlicker", true)
	self.opacity = getSetting("earlateOpacity", 1)
	self.scale = getSetting("earlateScale", 1)
	self.textDeltaGap = getSetting("earlateGap", 0.25)
end

return Earlate
