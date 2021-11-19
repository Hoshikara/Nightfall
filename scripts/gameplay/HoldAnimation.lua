--#region Require

local HitLanes = require("gameplay/constants/HitLanes")
local MockCritLine = require("gameplay/MockCritLine")
local RingAnimation = require("gameplay/RingAnimation")
local makeHoldAnimationStates = require("gameplay/helpers/makeHoldAnimationStates")

--#endregion

---@class HoldAnimation: HoldAnimationBase
local HoldAnimation = {}
HoldAnimation.__index = HoldAnimation

---@param window Window
---@param isGameplaySettings? boolean
---@return HoldAnimation
function HoldAnimation.new(window, isGameplaySettings)
	---@class HoldAnimationBase
	local self = {
		animation = RingAnimation.new(nil, isGameplaySettings),
		animationType = getSetting("hitAnimationType", "STANDARD"),
		isGameplaySettings = isGameplaySettings,
		mockCritLine = isGameplaySettings and MockCritLine.new(window),
		scale = getSetting("hitAnimationScale", 1),
		states = makeHoldAnimationStates(),
		window = window,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, HoldAnimation)
end

---@param dt deltaTime
function HoldAnimation:draw(dt)
	local isGameplaySettings = self.isGameplaySettings
	local noteHeld = nil

	if isGameplaySettings then
		local state = self.states[4]

		self:updateProps(state)

		state.active = true

		self:playHold(dt, 4, state)
	else
		noteHeld = gameplay.noteHeld
	end

	for btn, state in ipairs(self.states) do
		if not isGameplaySettings then
			---@diagnostic disable-next-line
			state.active = noteHeld[btn]

			self:playHold(dt, btn, state)
		end
	end
end

---@param dt deltaTime
---@param btn integer
---@param state HoldAnimationState
function HoldAnimation:playHold(dt, btn, state)
	gfx.Save()
	self:setupCritLineTransform(btn)
	self.animation:play(dt, state)
	gfx.Restore()
end

---@param btn integer
function HoldAnimation:setupCritLineTransform(btn)
	local critLine = self.mockCritLine or gameplay.critLine

	gfx.Translate(
		critLine.line.x1 + (critLine.line.x2 - critLine.line.x1) * HitLanes[btn],
		critLine.line.y1 + (critLine.line.y2 - critLine.line.y1) * HitLanes[btn]
	)
	gfx.Rotate(-critLine.rotation * (180 / 3.14))
	self.window:scale(self.scale)
end

---@param state HoldAnimationState
function HoldAnimation:updateProps(state)
	local animationType = getSetting("hitAnimationType", "STANDARD")

	self.scale = getSetting("hitAnimationScale", 1)

	self.mockCritLine:update()

	if self.animationType ~= animationType then
		self:resetProps(state)

		self.animationType = animationType
	end
end

---@param state HoldAnimationState
function HoldAnimation:resetProps(state)
	self.animation = RingAnimation.new(nil, true)

	state.active = false
	state.timer = 0
	state.inner.frame = 1
	state.inner.timer = 0
end

return HoldAnimation

---@class HoldAnimationState : AnimationState
---@field active boolean
---@field effect? EffectAnimationState
---@field inner? AnimationState
