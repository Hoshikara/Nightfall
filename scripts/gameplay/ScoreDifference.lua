local abs = math.abs
local random = math.random

---@param value number
---@param mult integer
---@return number
local function getAlpha(value, mult)
	if value >= (10 ^ (7 - mult)) then
		return 1
	end

	return 0.2
end

---@class ScoreDifference: ScoreDifferenceBase
local ScoreDifference = {}
ScoreDifference.__index = ScoreDifference

---@param ctx GameplayContext
---@param window Window
---@param isGameplaySettings? boolean
---@return ScoreDifference
function ScoreDifference.new(ctx, window, isGameplaySettings)
	---@class ScoreDifferenceBase
	local self = {
		ctx = ctx,
		delay = getSetting("scoreDifferenceDelay", 0.05),
		delayTimer = 0,
		digits = {
			makeLabel("Number", "0000", 40),
			makeLabel("Number", "0000", 40),
			makeLabel("Number", "0000", 40),
			makeLabel("Number", "0000", 32),
		},
		isGameplaySettings = isGameplaySettings,
		minus = makeLabel("Number", "-", 40),
		plus = makeLabel("Number", "+", 32),
		scale = getSetting("scoreDifferenceScale", 1.0),
		value = 0,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, ScoreDifference)
end

---@param dt deltaTime
function ScoreDifference:draw(dt)
	if gameplay and (not gameplay.scoreReplays[1]) then
		return
	end

	if self.isGameplaySettings then
		self:updateProps()
	end

	self:setProps()
	self:updateValue(dt)

	gfx.Save()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawDifference()
	gfx.Restore()
end

function ScoreDifference:setProps()
	if (self.windowResized ~= self.window.resized) or self.isGameplaySettings then
		local posX = getSetting("scoreDifferenceX", 0.10)
		local posY = getSetting("scoreDifferenceY", 0.50)

		if self.window.isPortrait then
			self.x = self.window.w * posX
			self.y = 294 + ((self.window.h * 0.625) * posY)
		else
			self.x = self.window.w * posX
			self.y = self.window.h * posY
		end

		self.windowResized = self.window.resized
	end
end

function ScoreDifference:drawDifference()
	local absDifference = abs(self.value)
	local difference = ("%08d"):format(absDifference)
	local isNegative = self.value < 0
	local w = self.digits[1].w

	if absDifference ~= 0 then
		self:drawPrefix(isNegative)
	end

	for i, number in ipairs(self.digits) do
		local color = ((i < 4) and "White") or (isNegative and "Negative") or "Positive"
		local offset = ((i == 4) and 8) or 0

		number:draw({
			x = (-3 + i) * w,
			y = offset,
			alpha = getAlpha(absDifference, i),
			color = color,
			shadowAlpha = 1,
			shadowOffset = 2,
			text = difference:sub(i + 1, i + 1),
			update = true,
		})
	end
end

---@param isNegative boolean
function ScoreDifference:drawPrefix(isNegative)
	if isNegative then
		self.minus:draw({
			x = -69.5,
			y = -3,
			color = "Negative",
			shadowAlpha = 1,
			shadowOffset = 2,
		})
	else
		self.plus:draw({
			x = -74,
			y = 5.5,
			color = "Positive",
			shadowAlpha = 1,
			shadowOffset = 2,
		})
	end
end

function ScoreDifference:updateProps()
	self.delay = getSetting("scoreDifferenceDelay", 0.05)
	self.scale = getSetting("scoreDifferenceScale", 1.0)
end

---@param dt deltaTime
function ScoreDifference:updateValue(dt)
	self.delayTimer = self.delayTimer + dt

	if (self.delayTimer >= self.delay) or (gameplay and (gameplay.progress == 1)) then
		if self.isGameplaySettings then
			self.value = random(1000000, 9999999)
		else
			self.value = self.ctx.score - gameplay.scoreReplays[1].currentScore
		end

		self.delayTimer = 0
	end
end

return ScoreDifference
