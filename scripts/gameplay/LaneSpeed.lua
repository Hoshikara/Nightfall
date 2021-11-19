---@class LaneSpeed: LaneSpeedBase
local LaneSpeed = {}
LaneSpeed.__index = LaneSpeed

---@param window Window
---@param isGameplaySettings? boolean
---@return LaneSpeed
function LaneSpeed.new(window, isGameplaySettings)
	---@class LaneSpeedBase
	local self = {
		ignoreHint = getSetting("ignoreSpeedChange", false),
		isGameplaySettings = isGameplaySettings,
		opacity = getSetting("laneSpeedOpacity", 1.0),
		scale = getSetting("laneSpeedScale", 1.0),
		speedRange = makeLabel("Number", "0", 19),
		text = makeLabel("Number", "0", 27),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, LaneSpeed)
end

---@param params? LaneSpeed.draw.params
function LaneSpeed:draw(params)
	if self.isGameplaySettings then
		self:updateProps()
	end

	self:setProps()

	gfx.Save()
	gfx.ResetTransform()
	self.window:update()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawValue(params or {})
	gfx.Restore()
end

function LaneSpeed:setProps()
	if (self.windowResized ~= self.window.resized) or self.isGameplaySettings then
		if self.window.isPortrait then
			self.y = 294 + ((self.window.h * 0.625) * getSetting("laneSpeedY", 0.5))
		else
			self.y = self.window.h * getSetting("laneSpeedY", 0.5)
		end

		self.x = self.window.w * getSetting("laneSpeedX", 0.5)

		self.windowResized = self.window.resized
	end
end

---@param params LaneSpeed.draw.params
function LaneSpeed:drawValue(params)
	local color, hintText, x = self:getHintInfo(params)
	local minBpm = params.minBpm or 0
	local maxBpm = params.maxBpm or 0

	if (not self.isGameplaySettings)
		and (params.isFromSongSelect)
		and (minBpm ~= maxBpm
		) then
		self.speedRange:draw({
			x = x - 40,
			y = 34,
			alpha = self.opacity,
			align = "CenterMiddle",
			color = "White",
			text = ("%.2f - %.2f"):format(
				minBpm * gameplay.hispeed * 0.01,
				maxBpm * gameplay.hispeed * 0.01
			),
			update = true,
		})
	end

	self.text:draw({
		x = x,
		y = 0,
		alpha = self.opacity,
		align = "CenterMiddle",
		color = color,
		text = hintText,
		update = true,
	})
	self:drawBars(params.laneSpeedColor or "White")
end

---@param leftColor Color|string
function LaneSpeed:drawBars(leftColor)
	local opacity = self.opacity

	if leftColor == "White" then
		drawRect({
			x = 15,
			y = 19,
			w = 52,
			h = 2,
			alpha = 0.5 * opacity,
			color = "Black",
		})
		drawRect({
			x = 14,
			y = 18,
			w = 52,
			h = 2,
			alpha = opacity,
			color = "White",
		})
	else
		drawRect({
			x = -65,
			y = 19,
			w = 52,
			h = 2,
			alpha = 0.5 * opacity,
			color = "Black",
		})
		drawRect({
			x = -66,
			y = 18,
			w = 52,
			h = 2,
			alpha = opacity,
			color = "White",
		})
	end
end

---@param params LaneSpeed.draw.params
function LaneSpeed:getHintInfo(params)
	---@type Color|string
	local color = "White"
	local hintText = params.hintText or "> 8.00   4.00"
	local x = 0

	if hintText ~= "" and (not self.ignoreHint) then
		if params.isSlowingDown then
			color = Colors.Positive
		else
			color = Colors.Negative
		end

		x = -10
	else
		if gameplay then
			hintText = ("%.2f   %.2f"):format(
				gameplay.bpm * gameplay.hispeed * 0.01,
				gameplay.hispeed
			)
		else
			hintText = "8.00   4.00"
		end
	end

	return color, hintText, x
end

function LaneSpeed:updateProps()
	self.ignoreHint = getSetting("ignoreSpeedChange", false)
	self.opacity = getSetting("laneSpeedOpacity", 1.0)
	self.scale = getSetting("laneSpeedScale", 1.0)
end

return LaneSpeed

---@class LaneSpeed.draw.params
---@field hintText string
---@field isFromSongSelect boolean
---@field isSlowingDown boolean
---@field laneSpeedColor Color|string
---@field maxBpm number
---@field minBpm number
