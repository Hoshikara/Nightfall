local DimmedNumber = require("common/DimmedNumber")

---@class ScoreInfo: ScoreInfoBase
local ScoreInfo = {}
ScoreInfo.__index = ScoreInfo

---@param ctx GameplayContext
---@param window Window
---@return ScoreInfo
function ScoreInfo.new(ctx, window)
	---@class ScoreInfoBase
	local self = {
		ctx = ctx,
		exScore = DimmedNumber.new({ digits = 5, size = 27 }),
		exScoreLabel = makeLabel("Medium", "EX", 30),
		maxChain = DimmedNumber.new({ digits = 5, size = 27 }),
		maxChainLabel = makeLabel("Medium", "MAX CHAIN", 30),
		maxExScore = makeLabel("Number", "", 27),
		scale = 1,
		score = DimmedNumber.new({ size = 130 }),
		scoreLabel = makeLabel("Medium", "SCORE", 71),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, ScoreInfo)
end

function ScoreInfo:draw()
	self:setProps()

	local introAlpha = self.ctx.introAlpha
	local isPortrait = self.window.isPortrait

	gfx.Save()
	gfx.Translate(self.x + ((self.window.w / 4) * self.ctx.introOffset), self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawScore(introAlpha, isPortrait)
	self:drawExScore(introAlpha, isPortrait)
	self:drawMaxChain(introAlpha, isPortrait)
	gfx.Restore()
end

function ScoreInfo:setProps()
	if self.windowResized ~= self.window.resized then
		if self.window.isPortrait then
			self.x = 681
			self.y = 375
			self.exScore = DimmedNumber.new({ digits = 5, size = 21 })
			self.exScoreLabel = makeLabel("Medium", "EX", 24)
			self.maxChain = DimmedNumber.new({ digits = 5, size = 21 })
			self.maxChainLabel = makeLabel("Medium", "MAX CHAIN", 24)
			self.maxExScore = makeLabel("Number", "", 21)
			self.score = DimmedNumber.new({ size = 85 })
			self.scoreLabel = makeLabel("Medium", "SCORE", 46)
		else
			self.x = self.window.w - (self.window.paddingX / 2) - 576
			self.y = self.window.paddingY * 0.75
			self.exScore = DimmedNumber.new({ digits = 5, size = 27 })
			self.exScoreLabel = makeLabel("Medium", "EX", 30)
			self.maxChain = DimmedNumber.new({ digits = 5, size = 27 })
			self.maxChainLabel = makeLabel("Medium", "MAX CHAIN", 30)
			self.maxExScore = makeLabel("Number", "", 27)
			self.score = DimmedNumber.new({ size = 130 })
			self.scoreLabel = makeLabel("Medium", "SCORE", 71)
		end

		self.windowResized = self.window.resized
	end
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawScore(introAlpha, isPortrait)
	self.scoreLabel:draw({
		x = (isPortrait and -6) or -5,
		y = -33,
		alpha = introAlpha,
		color = "Standard",
		shadowAlpha = 1,
		shadowOffset = 2,
	})
	self.score:draw({
		x = -8,
		y = (isPortrait and 4) or 24,
		alpha = introAlpha,
		value = self.ctx.score,
		shadowAlpha = 1,
		shadowOffset = 2,
	})
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawExScore(introAlpha, isPortrait)
	local exScore = self.ctx.exScore
	local maxExScore = self.ctx.maxExScore
	local maxExScoreAlpha = 1
	local pctString = "(MAX-0)"
	local shadowAlpha = 1
	local shadowOffset = 2

	self.exScoreLabel:draw({
		x = (isPortrait and -5) or -2,
		y = (isPortrait and 96) or 163,
		alpha = introAlpha,
		color = "Standard",
		shadowAlpha = shadowAlpha,
		shadowOffset = shadowOffset,
	})
	self.exScore:draw({
		x = (isPortrait and 30) or 41,
		y = (isPortrait and 99) or 166,
		alpha = introAlpha,
		color = "White",
		shadowAlpha = shadowAlpha,
		shadowOffset = shadowOffset,
		value = exScore,
	})

	if maxExScore > 0 then
		if (exScore / maxExScore) >= 0.98 then
			pctString = ("(MAX-%s)"):format(maxExScore - exScore)
		else
			pctString = ("(%.1f%%)"):format((exScore / maxExScore) * 100)
		end
	end

	if maxExScore == 0 then
		maxExScoreAlpha = 0.4
	end

	self.maxExScore:draw({
		x = (isPortrait and 100) or 130,
		y = (isPortrait and 99) or 166,
		alpha = introAlpha * maxExScoreAlpha,
		color = "White",
		shadowAlpha = shadowAlpha,
		shadowOffset = shadowOffset,
		text = pctString,
		update = true,
	})
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawMaxChain(introAlpha, isPortrait)
	self.maxChainLabel:draw({
		x = (isPortrait and 198) or 349,
		y = (isPortrait and 96) or 163,
		alpha = introAlpha,
		color = "Standard",
		shadowAlpha = 1,
		shadowOffset = 2,
	})
	self.maxChain:draw({
		x = (isPortrait and 312) or 494,
		y = (isPortrait and 99) or 166,
		alpha = introAlpha,
		color = "White",
		shadowAlpha = 1,
		shadowOffset = 2,
		value = self.ctx.maxChain,
	})
end

return ScoreInfo
