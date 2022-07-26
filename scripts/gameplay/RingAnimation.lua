local makeHoldAnimation = require("gameplay/helpers/makeHoldAnimation")
local makeLaserRings = require("gameplay/helpers/makeLaserRings")

local cos = math.cos
local min = math.min

---@class RingAnimation: RingAnimationBase
local RingAnimation = {}
RingAnimation.__index = RingAnimation

---@param laserIndex nil|integer
---@param isGameplaySettings? boolean
---@return RingAnimation
function RingAnimation.new(laserIndex, isGameplaySettings)
	---@class RingAnimationBase
	local self = {
		isHold = not laserIndex,
		speed = (laserIndex and 2) or 1,
	}

	if laserIndex then
		self.rings = makeLaserRings(laserIndex, isGameplaySettings)
	else
		self.effect, self.inner, self.rings = makeHoldAnimation(isGameplaySettings)
	end

	---@diagnostic disable-next-line
	return setmetatable(self, RingAnimation)
end

---@param dt deltaTime
---@param state HoldAnimationState|LaserAnimationState
function RingAnimation:play(dt, state)
	if state.effect then
		self:playEffect(dt, state.active, state.effect)
	end

	if state.active then
		state.alpha:start(dt, 3, (self.isHold and 0.1) or 0.01)
	else
		state.alpha:reset()
		state.timer = 0

		return
	end

	self:playRing(dt, state)
end

---@param dt deltaTime
---@param state HoldAnimationState|LaserAnimationState
function RingAnimation:playRing(dt, state)
	local alpha = state.alpha.value
	local isHold = self.isHold
	local speed = self.speed
	local w = self.rings[1].w

	state.timer = state.timer + (dt * 2)

	if isHold and (state.timer <= 0.5) then
		speed = 4
	end

	local t = state.timer * speed

	self.rings[1]:draw({
		alpha = alpha,
		isCentered = true,
		updateData = true,
	})
	gfx.Translate(0, (isHold and -10) or 4)

	if self.inner then
		state.inner.alpha = alpha

		self.inner:play(dt, state.inner)
	end

	gfx.Translate(0, (isHold and 10) or -4)
	gfx.Rotate(-(60 - (t * 1.5)))
	self.rings[2]:draw({
		w = w * cos(t),
		alpha = alpha,
		isCentered = true,
		updateData = true,
	})
	gfx.Rotate(60 - (t * 1.5))
	gfx.Rotate(-15 + (t * 1.5))
	self.rings[3]:draw({
		w = w * cos(t),
		alpha = alpha,
		isCentered = true,
		updateData = true,
	})
end

---@param dt deltaTime
---@param holdActive boolean
---@param state EffectAnimationState
function RingAnimation:playEffect(dt, holdActive, state)
	if (not holdActive) and (not state.playOut) then
		return
	end

	self:updateEffectState(holdActive, state)

	if state.playIn or ((not holdActive) and state.playOut) then
		state.timer = min(state.timer + (dt * (1 / 0.125)), 1)

		if state.timer >= 0.5 then
			state.alpha:stop(dt, 3, 0.17)
		end

		self.effect:draw({
			alpha = 1.75 * state.alpha.value,
			isCentered = true,
			scale = state.timer * 1.35,
			updateData = true,
		})
	end
end

---@param holdActive boolean
---@param state EffectAnimationState
function RingAnimation:updateEffectState(holdActive, state)
	if holdActive then
		if state.playIn and (state.alpha.value == 0) then
			state.alpha:reset()
			state.playIn = false
			state.playOut = true
			state.timer = 0
		end
	else
		if state.playIn then
			state.alpha:reset()
			state.playIn = false
			state.playOut = true
			state.timer = 0
		elseif state.playOut and (state.alpha.value == 0) then
			state.alpha:reset()
			state.playIn = true
			state.playOut = false
			state.timer = 0
		end
	end
end

return RingAnimation

---@class EffectAnimationState
---@field alpha Easing
---@field playIn boolean
---@field playOut boolean
---@field timer number
