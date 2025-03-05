local RatingColors = require("common/constants/RatingColors")

local abs = math.abs

local MOCK_HITS = {
	0,
	4,
	-4,
	24,
	-24,
	48,
	-48,
}

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
		deltaAlign = "CenterMiddle",
		deltaText = makeLabel("Number", "0.0 ms", 27),
		flickerEnabled = getSetting("earlateFlicker", true),
		flickerTimer = 0,
		isGameplaySettings = isGameplaySettings,
		mockIndex = 0,
		offset = 0,
		opacity = getSetting("earlateOpacity", 1),
		scale = getSetting("earlateScale", 1),
		showDeltaOn = getSetting("earlateDelta", "OFF"),
		showTextOn = getSetting("earlateText", "<= NEAR"),
		text = makeLabel("Medium", "EARLY", 30),
		textAlign = "CenterMiddle",
		textDeltaGap = getSetting("earlateGap", 0.25),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	if isGameplaySettings then
		self.ctx = {
			earlate = {
				delta = 0,
				deltaColor = RatingColors.SCritical,
				deltaTimer = 0.5,
				text = "EARLY",
				textColor = RatingColors.Early,
				textTimer = 0.5,
			},
		}
	end

	---@diagnostic disable-next-line
	return setmetatable(self, Earlate)
end

---@param dt deltaTime
function Earlate:draw(dt)
	local props = self.ctx.earlate

	if self.isGameplaySettings then
		self:updateProps(props)
	end

	props.deltaTimer = props.deltaTimer - dt
	props.textTimer = props.textTimer - dt

	if props.deltaTimer < 0 and props.textTimer < 0 then
		return
	end

	local alpha = self:getAlpha(dt)

	self:setProps()

	gfx.Save()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)

	if props.deltaTimer >= 0 and self.showDeltaOn ~= "OFF" then
		self:drawDelta(props, alpha)
	end

	if props.textTimer >= 0 and self.showTextOn ~= "OFF" then
		self:drawText(props, alpha)
	end

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

		if self.showDeltaOn ~= "OFF" and self.showTextOn ~= "OFF" then
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

---@param props EarlateProps
---@param alpha number
function Earlate:drawDelta(props, alpha)
	local text = self:getDeltaString()

	self.deltaText:draw({
		x = self.offset,
		y = 2,
		align = self.deltaAlign,
		alpha = 0.4 * alpha,
		color = "White",
		shadowAlpha = 0,
		text = text,
		update = true,
	})
	self.deltaText:draw({
		x = self.offset,
		y = 1,
		align = self.deltaAlign,
		alpha = alpha,
		color = props.deltaColor,
		shadowAlpha = 0,
		text = text,
		update = true,
	})
end

---@param props EarlateProps
---@param alpha number
function Earlate:drawText(props, alpha)
	self.text:draw({
		x = -self.offset,
		y = 1,
		align = self.textAlign,
		alpha = 0.4 * alpha,
		color = "White",
		shadowAlpha = 0,
		text = props.text,
		update = true,
	})
	self.text:draw({
		x = -self.offset,
		y = 0,
		align = self.textAlign,
		alpha = alpha,
		color = props.textColor,
		shadowAlpha = 0,
		text = props.text,
		update = true,
	})
end

---@param dt deltaTime
function Earlate:getAlpha(dt)
	if self.flickerEnabled then
		self.flickerTimer = self.flickerTimer + dt

		return ((self.flickerTimer * 16) % 1) * self.opacity
	end

	return self.opacity
end

---@param props EarlateProps
function Earlate:updateProps(props)
	self.flickerEnabled = getSetting("earlateFlicker", true)
	self.opacity = getSetting("earlateOpacity", 1)
	self.scale = getSetting("earlateScale", 1)
	self.showDeltaOn = getSetting("earlateDelta", "OFF")
	self.showTextOn = getSetting("earlateText", "<= NEAR")
	self.textDeltaGap = getSetting("earlateGap", 0.25)

	-- This code mocks the behavior of GameplayContext:handleButton()

	if props.deltaTimer <= 0 and props.textTimer <= 0 then
		self.mockIndex = (self.mockIndex + 1) % #MOCK_HITS
	else
		return
	end

	local delta = MOCK_HITS[self.mockIndex + 1]

	if abs(delta) >= 46 then
		if self.showDeltaOn ~= "OFF" then
			props.deltaColor = delta < 0 and RatingColors.Early or RatingColors.Late
			props.delta = delta
			props.deltaTimer = 0.5
		end

		if self.showTextOn ~= "OFF" then
			props.text = delta < 0 and "EARLY" or "LATE"
			props.textColor = delta < 0 and RatingColors.Early or RatingColors.Late
			props.textTimer = 0.5
		end
	else
		local sCritHit = abs(delta) <= 23

		if self.showDeltaOn == "ALL" or (self.showDeltaOn == "<= CRITICAL" and not sCritHit) then
			if sCritHit then
				props.deltaColor = RatingColors.SCritical
			else
				props.deltaColor = delta < 0 and RatingColors.Early or RatingColors.Late
			end

			props.delta = delta
			props.deltaTimer = 0.5
		end

		if self.showTextOn == "<= CRITICAL" and not sCritHit then
			props.text = delta < 0 and "EARLY" or "LATE"
			props.textColor = delta < 0 and RatingColors.Early or RatingColors.Late
			props.textTimer = 0.5
		end
	end
end

function Earlate:getDeltaString()
	local delta = self.ctx.earlate.delta

	return (delta > 0 and "-%.1f ms" or "+%.1f ms"):format(abs(delta))
end

return Earlate
