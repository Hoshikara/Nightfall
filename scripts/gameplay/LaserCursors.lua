---@diagnostic disable: need-check-nil

local Image = require("common/Image")
local MockCritLine = require("gameplay/MockCritLine")
local getLaserColors = require("common/helpers/getLaserColors")

local laserColors = getLaserColors()

local abs = math.abs
local sin = math.sin

---@class LaserCursors: LaserCursorsBase
local LaserCursors = {}
LaserCursors.__index = LaserCursors

---@param window Window
---@param isGameplaySettings? boolean
---@return LaserCursors
function LaserCursors.new(window, isGameplaySettings)
	---@class LaserCursorsBase
	local self = {
		fill = Image.new({ path = "gameplay/laser_cursors/fill" }),
		flickerTimer = 0,
		isGameplaySettings = isGameplaySettings,
		mockCritLine = isGameplaySettings and MockCritLine.new(window),
		overlay = Image.new({ path = "gameplay/laser_cursors/overlay" }),
		streakBot = Image.new({ path = "gameplay/laser_cursors/streak_bot" }),
		streakTop = Image.new({ path = "gameplay/laser_cursors/streak_top" }),
		window = window,
	}

	self.h = self.overlay.h * 1.15

	---@diagnostic disable-next-line
	return setmetatable(self, LaserCursors)
end

function LaserCursors:draw(dt)
	local cursors = (self.mockCritLine or gameplay.critLine).cursors
	---@type Image
	local fill = self.fill
	local laserActive = (self.mockCritLine or gameplay).laserActive
	local scale = self.window.scaleFactor
	---@type Image
	local streakBot = self.streakBot
	local streakTop = self.streakTop
	local cursorScale = 0.4 * scale
	local h = self.h

	if self.isGameplaySettings then
		self.mockCritLine:updateCursors(true)
	end

	self.flickerTimer = self.flickerTimer + dt

	for i = 1, 2 do
		local cursor = cursors[i]

		gfx.SkewX(cursor.skew)

		if laserActive[i] then
			local p1 = {
				x = cursor.pos,
				w = streakBot.w * 1.2,
				h = streakBot.h * 0.9,
				alpha = 0.8,
				blendOp = 8,
				isCentered = true,
				scale = 0.5 * scale,
				tint = laserColors[i],
			}
			local p2 = {
				x = cursor.pos,
				w = streakBot.w * 1.2,
				h = streakBot.h * 0.9,
				alpha = 0.4,
				blendOp = 8,
				isCentered = true,
				scale = 0.5 * scale,
			}

			streakBot:draw(p1)
			streakBot:draw(p2)
			streakTop:draw(p1)
			streakTop:draw(p2)
		end

		fill:draw({
			x = cursor.pos,
			h = h,
			alpha = cursor.alpha * (0.4 * abs(sin(self.flickerTimer * 40))),
			blendOp = 8,
			isCentered = true,
			scale = cursorScale,
			tint = laserColors[i],
		})
		fill:draw({
			x = cursor.pos,
			h = h,
			alpha = cursor.alpha * 0.6,
			isCentered = true,
			scale = cursorScale,
			tint = laserColors[i],
		})
		self.overlay:draw({
			x = cursor.pos,
			h = h,
			alpha = cursor.alpha,
			isCentered = true,
			scale = cursorScale,
		})
		gfx.SkewX(-cursor.skew)
	end
end

return LaserCursors
