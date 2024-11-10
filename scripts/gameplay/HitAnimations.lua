--#region Require

local HitLanes = require("gameplay/constants/HitLanes")
local HoldAnimation = require("gameplay/HoldAnimation")
local MockCritLine = require("gameplay/MockCritLine")
local makeHitAnimation = require("gameplay/helpers/makeHitAnimation")
local makeHitAnimationQueues = require("gameplay/helpers/makeHitAnimationQueues")

--#endregion

local abs = math.abs

---@class HitAnimations: HitAnimationsBase
local HitAnimations = {}
HitAnimations.__index = HitAnimations

---@param ctx GameplayContext
---@param window Window
---@param isGameplaySettings? boolean
---@return HitAnimations
function HitAnimations.new(ctx, window, isGameplaySettings)
	---@class HitAnimationsBase
	local self = {
		animationType = getSetting("hitAnimationType", "STANDARD"),
		critAnimation = makeHitAnimation("Critical", isGameplaySettings),
		critQueues = makeHitAnimationQueues(true),
		errorAnimation = makeHitAnimation("Error", isGameplaySettings),
		errorQueues = makeHitAnimationQueues(),
		hitTimer = 0,
		holdAnimation = HoldAnimation.new(window, isGameplaySettings),
		isGameplaySettings = isGameplaySettings,
		mockCritLine = isGameplaySettings and MockCritLine.new(window),
		nearAnimation = makeHitAnimation("Near", isGameplaySettings),
		nearQueues = makeHitAnimationQueues(),
		scale = getSetting("hitAnimationScale", 1),
		sCritAnimation = makeHitAnimation("SCritical", isGameplaySettings),
		sCritWindow = ctx.sCritWindow or 23,
		window = window,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, HitAnimations)
end

---@param dt deltaTime
function HitAnimations:draw(dt)
	if self.isGameplaySettings then
		self:enqueueHits(dt)
		self:updateProps()
	end

	self.holdAnimation:draw(dt)
	self:dequeueHits(dt)
end

---@param dt deltaTime
function HitAnimations:dequeueHits(dt)
	local critAnimation = self.critAnimation
	local critQueues = self.critQueues
	local errorAnimation = self.errorAnimation
	local errorQueues = self.errorQueues
	local nearAnimation = self.nearAnimation
	local nearQueues = self.nearQueues
	local sCritAnimation = self.sCritAnimation

	for btn = 1, 6 do
		for _, state in ipairs(critQueues[btn]) do
			if state.queued then
				self:dequeueHit(
					dt,
					(state.sCrit and sCritAnimation) or critAnimation,
					btn,
					state,
					state.sCrit and (function() state.sCrit = false end)
				)
			end
		end

		for _, state in ipairs(nearQueues[btn]) do
			if state.queued then
				self:dequeueHit(dt, nearAnimation, btn, state)
			end
		end

		for _, state in ipairs(errorQueues[btn]) do
			if state.queued then
				self:dequeueHit(dt, errorAnimation, btn, state)
			end
		end
	end
end

---@param dt deltaTime
---@param animation Animation
---@param btn integer
---@param state HitAnimationState
---@param effect? boolean|function
function HitAnimations:dequeueHit(dt, animation, btn, state, effect)
	gfx.Save()
	self:setupCritLineTransform(btn)
	animation:play(dt, state, effect)
	gfx.Restore()
end

---@param dt deltaTime
function HitAnimations:enqueueHits(dt)
	self.hitTimer = self.hitTimer + dt

	if self.hitTimer >= 0.5 then
		self:enqueueHit(0, 0, 1)
		self:enqueueHit(1, 46, 2)
		self:enqueueHit(2, 0, 2)

		self.hitTimer = 0
	end
end

---@param btn integer
---@param delta integer
---@param rating rating
function HitAnimations:enqueueHit(btn, delta, rating)
	if rating == 2 then
		for _, state in ipairs(self.critQueues[btn + 1]) do
			if not state.queued then
				if abs(delta) <= self.sCritWindow then
					state.sCrit = true
				end

				state.queued = true

				break
			end
		end
	elseif rating == 1 then
		for _, state in ipairs(self.nearQueues[btn + 1]) do
			if not state.queued then
				state.queued = true

				break
			end
		end
	elseif rating == 0 then
		for _, state in ipairs(self.errorQueues[btn + 1]) do
			if not state.queued then
				state.queued = true

				break
			end
		end
	end
end

---@param btn integer
function HitAnimations:setupCritLineTransform(btn)
	local critLine = self.mockCritLine or gameplay.critLine

	gfx.Translate(
		critLine.line.x1 + (critLine.line.x2 - critLine.line.x1) * HitLanes[btn],
		critLine.line.y1 + (critLine.line.y2 - critLine.line.y1) * HitLanes[btn]
	)
	gfx.Rotate(-critLine.rotation * (180 / 3.14))
	self.window:scale(self.scale)
end

function HitAnimations:updateProps()
	local animationType = getSetting("hitAnimationType", "STANDARD")

	self.scale = getSetting("hitAnimationScale", 1)

	self.mockCritLine:update()

	if self.animationType ~= animationType then
		self:resetProps()

		self.animationType = animationType
	end
end

function HitAnimations:resetProps()
	self.critAnimation = makeHitAnimation("Critical", true)
	self.nearAnimation = makeHitAnimation("Near", true)
	self.sCritAnimation = makeHitAnimation("SCritical", true)

	self.critQueues[1].frame = 1
	self.critQueues[1].queued = false
	self.critQueues[1].timer = 0

	self.nearQueues[1].frame = 1
	self.nearQueues[1].queued = false
	self.nearQueues[1].timer = 0
end

return HitAnimations

---@class HitAnimationState : AnimationState
---@field sCrit? boolean
