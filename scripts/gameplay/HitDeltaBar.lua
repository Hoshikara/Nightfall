local RatingColors = require("common/constants/RatingColors")
local Easing = require("common/Easing")

local abs = math.abs
local max = math.max
local random = math.random

---@return HitDeltaState[][]
local function makeQueues()
	local queues = {}

	for btn = 1, 6 do
		queues[btn] = {}

		for i = 1, 40 do
			queues[btn][i] = {
				color = "White",
				delta = 0,
				fade = Easing.new(1),
				queued = false,
			}
		end
	end

	return queues
end

---@class HitDeltaBar: HitDeltaBarBase
local HitDeltaBar = {}
HitDeltaBar.__index = HitDeltaBar

---@param window Window
---@param isGameplaySettings? boolean
---@return HitDeltaBar
function HitDeltaBar.new(window, isGameplaySettings)
	---@class HitDeltaBarBase
	local self = {
		critQueues = makeQueues(),
		critScale = 1,
		critWindow = (gameplay and gameplay.hitWindow.perfect) or 46,
		decayTime = getSetting("hitDecayTime", 6.0),
		fade = Easing.new(1),
		isGameplaySettings = isGameplaySettings,
		nearQueues = makeQueues(),
		nearScale = 1,
		nearWindow = (gameplay and gameplay.hitWindow.good) or 150,
		nearX = 0,
		scale = getSetting("hitDeltaBarScale", 1.0),
		timer = 1,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 32,
	}

	self.sCritWindow = math.floor(self.critWindow / 2)
	self.hitWindowTexts = {
		sCritPos = makeLabel("Number", ("+%d"):format(self.sCritWindow)),
		sCritNeg = makeLabel("Number", ("-%d"):format(self.sCritWindow)),
		critPos = makeLabel("Number", ("+%d"):format(self.critWindow)),
		critNeg = makeLabel("Number", ("-%d"):format(self.critWindow)),
		nearPos = makeLabel("Number", ("+%d"):format(self.nearWindow)),
		nearNeg = makeLabel("Number", ("-%d"):format(self.nearWindow)),
	}

	if isGameplaySettings then
		self.hitTimer = 0
	end

	---@diagnostic disable-next-line
	return setmetatable(self, HitDeltaBar)
end

---@param dt deltaTime
function HitDeltaBar:draw(dt)
	if self.isGameplaySettings then
		self:enqueueHits(dt)
		self:updateProps()
	end

	if gameplay and (gameplay.progress == 0) then
		self:resetQueues()
	end

	self:setProps()

	gfx.Save()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawBar(dt)
	self:dequeueHits(dt)
	gfx.Restore()
end

function HitDeltaBar:setProps()
	if (self.windowResized ~= self.window.resized) or self.isGameplaySettings then
		self.x = self.window.w * getSetting("hitDeltaBarX", 0.5)

		if self.window.isPortrait then
			self.y = 306 + ((self.window.h * 0.625) * getSetting("hitDeltaBarY", 0.0))
			self.w = 512
		else
			self.y = 12 + self.window.h * getSetting("hitDeltaBarY", 0.0)
			self.w = 512
		end

		self.critScale = (self.w / 4) / self.critWindow
		self.nearScale = (self.w / 4) / (self.nearWindow - self.critWindow)
		self.nearX = self.w / 4

		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
function HitDeltaBar:drawBar(dt)
	local barWidth = 3
	local nearX = self.nearX
	local w = self.w
	local h = self.h

	drawRect({
		x = -(w / 2) - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.Early,
	})
	drawRect({
		x = -nearX - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.Critical,
	})
	drawRect({
		x = -(nearX / 2) - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.SCritical,
	})
	drawRect({
		x = -(barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.8,
		color = "White",
	})
	drawRect({
		x = (nearX / 2) - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.SCritical,
	})
	drawRect({
		x = nearX - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.Critical,
	})
	drawRect({
		x = (w / 2) - (barWidth / 2),
		y = 0,
		w = barWidth,
		h = h,
		alpha = 0.5,
		color = RatingColors.Late,
	})

	if (not self.isGameplaySettings) and (self.timer > 0) then
		self:drawHitWindows(dt, nearX, w, h)
	end
end

---@param dt deltaTime
---@param nearX number
---@param w number
---@param h number
function HitDeltaBar:drawHitWindows(dt, nearX, w, h)
	local alpha = self.timer
	local texts = self.hitWindowTexts
	local y = 16

	if gameplay.progress > 0 then
		self.timer = max(self.timer - dt, 0)
	end

	texts.nearNeg:draw({
		x = -nearX * 1.5,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.Early,
	})
	texts.critNeg:draw({
		x = -nearX * 0.75,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.Critical,
	})
	texts.sCritNeg:draw({
		x = -nearX * 0.25,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.SCritical,
	})
	texts.sCritPos:draw({
		x = nearX * 0.25,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.SCritical,
	})
	texts.critPos:draw({
		x = nearX * 0.75,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.Critical,
	})
	texts.nearPos:draw({
		x = nearX * 1.5,
		y = y,
		align = "CenterMiddle",
		alpha = alpha,
		color = RatingColors.Late,
	})
end

---@param dt deltaTime
function HitDeltaBar:dequeueHits(dt)
	local critQueues = self.critQueues
	local decayTime = self.decayTime
	local nearQueues = self.nearQueues

	for btn = 1, 6 do
		for _, state in ipairs(critQueues[btn]) do
			if state.queued then
				self:dequeueHit(dt, decayTime, state)
			end
		end

		for _, state in ipairs(nearQueues[btn]) do
			if state.queued then
				self:dequeueHit(dt, decayTime, state)
			end
		end
	end
end

---@param dt deltaTime
---@param state HitDeltaState
function HitDeltaBar:dequeueHit(dt, decayTime, state)
	state.fade:stop(dt, 3, decayTime)

	drawRect({
		x = state.delta - 1,
		y = 4,
		w = 2,
		h = 24,
		alpha = state.fade.value,
		blendOp = 8,
		color = state.color,
	})

	if state.fade.value == 0 then
		state.queued = false
		state.fade:reset()
	end
end

---@param dt deltaTime
function HitDeltaBar:enqueueHits(dt)
	self.hitTimer = self.hitTimer + dt

	if self.hitTimer >= 0.1 then
		self:enqueueHit(random(0, 5), random(-46, 46), 2)
		self:enqueueHit(random(0, 2), random(-150, -46), 1)
		self:enqueueHit(random(2, 5), random(46, 150), 1)

		self.hitTimer = 0
	end
end

---@param btn integer
---@param delta integer
---@param rating rating
function HitDeltaBar:enqueueHit(btn, delta, rating)
	if rating == 2 then
		for _, state in ipairs(self.critQueues[btn + 1]) do
			if not state.queued then
				if abs(delta) <= self.sCritWindow then
					state.color = RatingColors.SCritical
				else
					state.color = RatingColors.Critical
				end

				state.delta = delta * self.critScale
				state.queued = true

				break
			end
		end
	elseif rating == 1 then
		for _, state in ipairs(self.nearQueues[btn + 1]) do
			if not state.queued then
				if delta < 0 then
					state.color = RatingColors.Early
					state.delta = -self.nearX + ((delta + self.critWindow) * self.nearScale)
				else
					state.color = RatingColors.Late
					state.delta = self.nearX + ((delta - self.critWindow) * self.nearScale)
				end

				state.queued = true

				break
			end
		end
	end
end

function HitDeltaBar:updateProps()
	self.decayTime = getSetting("hitDecayTime", 6.0)
	self.scale = getSetting("hitDeltaBarScale", 1.0)
end

function HitDeltaBar:resetQueues()
	local critQueues = self.critQueues
	local nearQueues = self.nearQueues

	for btn = 1, 6 do
		local critStates = critQueues[btn]
		local nearStates = nearQueues[btn]

		for i = 1, 40 do
			critStates[i].color = "White"
			critStates[i].delta = 0
			critStates[i].fade:reset()
			critStates[i].queued = false

			nearStates[i].color = "White"
			nearStates[i].delta = 0
			nearStates[i].fade:reset()
			nearStates[i].queued = false
		end
	end
end

return HitDeltaBar

---@class HitDeltaState
---@field color Color|string
---@field delta number
---@field fade Easing
---@field queued boolean
