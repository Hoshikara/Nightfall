--#region Require

local MockCritLine = require("gameplay/MockCritLine")
local makeLaserAnimations = require("gameplay/helpers/makeLaserAnimations")
local makeLaserAnimationStates = require("gameplay/helpers/makeLaserAnimationStates")

--#endregion

---@class LaserAnimations: LaserAnimationsBase
local LaserAnimations = {}
LaserAnimations.__index = LaserAnimations

---@param window Window
---@param isGameplaySettings? boolean
---@return LaserAnimations
function LaserAnimations.new(window, isGameplaySettings)
	---@class LaserAnimationsBase
	local self = {
		isGameplaySettings = isGameplaySettings,
		mockCritLine = isGameplaySettings and MockCritLine.new(window),
		ringAnimations = {},
		ringStates = makeLaserAnimationStates(true),
		scale = getSetting("hitAnimationScale", 1),
		slamAnimations = {},
		slamHitTimer = 0,
		slamStates = makeLaserAnimationStates(),
		window = window,
	}

	self.ringAnimations, self.slamAnimations = makeLaserAnimations(isGameplaySettings)

	---@diagnostic disable-next-line
	return setmetatable(self, LaserAnimations)
end

---@param dt deltaTime
function LaserAnimations:draw(dt)
	---@type cursors
	local cursors = (self.mockCritLine or gameplay.critLine).cursors
	local isGameplaySettings = self.isGameplaySettings
	local ringStates = self.ringStates

	if isGameplaySettings then
		self.scale = getSetting("hitAnimationScale", 1)

		self.mockCritLine:update()
		self.mockCritLine:updateCursors()
		self:enqueueSlamHits(dt)
	end

	for laserIndex = 1, 2 do
		local cursor = cursors[laserIndex - 1]

		for _, state in ipairs(self.slamStates[laserIndex]) do
			if state.queued then
				self:dequeueSlamHit(dt, self.slamAnimations[laserIndex], state)
			end
		end

		ringStates[laserIndex].active = isGameplaySettings
			or gameplay.laserActive[laserIndex]

		self:playRing(
			dt,
			self.ringAnimations[laserIndex],
			ringStates[laserIndex],
			cursor.pos
		)
	end
end

---@param dt deltaTime
---@param animation Animation
---@param state LaserSlamAnimationState
function LaserAnimations:dequeueSlamHit(dt, animation, state)
	gfx.Save()
	self:setupCritLineTransform(state.pos)
	animation:play(dt, state, function() state.pos = 0 end)
	gfx.Restore()
end

---@param dt deltaTime
---@param ringAnimation RingAnimation
---@param state LaserAnimationState
---@param pos number
function LaserAnimations:playRing(dt, ringAnimation, state, pos)
	gfx.Save()
	self:setupCritLineTransform(pos, true)
	ringAnimation:play(dt, state)
	gfx.Restore()
end

---@param pos number
---@param isRing? boolean
function LaserAnimations:setupCritLineTransform(pos, isRing)
	local critLine = self.mockCritLine or gameplay.critLine

	if isRing then
		gfx.Translate(critLine.x, critLine.y)
		gfx.Rotate(-critLine.rotation * (180 / 3.14))
		gfx.Translate(pos, 0)
		self.window:scale(0.875 * self.scale)
	else
		local line = critLine.line

		gfx.Translate(
			line.x1 + ((line.x2 - line.x1) * pos),
			line.y1 + ((line.y2 - line.y1) * pos) - (48 * self.window.scaleFactor)
		)
		gfx.Rotate(-critLine.rotation * (180 / 3.14))
		self.window:scale(self.scale)
	end
end

---@param dt deltaTime
function LaserAnimations:enqueueSlamHits(dt)
	self.slamHitTimer = self.slamHitTimer + dt

	if self.slamHitTimer >= 1 then
		self:enqueueSlamHit(0, -0.5)
		self:enqueueSlamHit(1, 0.5)

		self.slamHitTimer = 0
	end
end

---@param laser integer
---@param pos number
function LaserAnimations:enqueueSlamHit(laser, pos)
	for _, state in ipairs(self.slamStates[laser + 1]) do
		if not state.queued then
			state.pos = 0.5 + (pos * 0.775)
			state.queued = true

			break
		end
	end
end

return LaserAnimations

---@class LaserAnimationState : AnimationState
---@field active boolean

---@class LaserSlamAnimationState : AnimationState
---@field pos number
