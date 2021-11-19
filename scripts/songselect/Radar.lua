local RadarLabels = require("songselect/constants/RadarLabels")

---@class Radar: RadarBase
local Radar = {}
Radar.__index = Radar

---@return Radar
function Radar.new()
	---@class RadarBase
	---@field notes Label
	---@field peak Label
	---@field tricky Label
	---@field tsumami Label
	---@field oneHand Label
	---@field handTrip Label
	local self = {}

	for name, str in pairs(RadarLabels) do
		self[name] = makeLabel("Bold", str, 12)
	end

	---@diagnostic disable-next-line
	return setmetatable(self, Radar)
end

---@param x number
---@param y number
---@param alpha number
---@param data RadarData
function Radar:draw(x, y, alpha, data)
	gfx.Save()
	gfx.Translate(x, y)
	self:drawHexagon(alpha)
	self:drawLines(alpha)
	self:drawFill(alpha, data)
	self:drawLabels(alpha)
	gfx.Restore()
end

---@param alpha number
function Radar:drawHexagon(alpha)
	setColor("Black", alpha * 0.8)
	setStroke({
		alpha = alpha * 0.4,
		color = "White",
		width = 1,
	})
	gfx.BeginPath()
	gfx.MoveTo(0, -65)
	gfx.LineTo(57, -33)
	gfx.LineTo(57, 33)
	gfx.LineTo(0, 65)
	gfx.LineTo(-57, 33)
	gfx.LineTo(-57, -33)
	gfx.ClosePath()
	gfx.Fill()
	gfx.Stroke()
end

---@param alpha number
---@param data RadarData
function Radar:drawFill(alpha, data)
	setColor("Standard", alpha * 0.8)
	gfx.BeginPath()
	gfx.MoveTo(0, -96 * data.notes)
	gfx.LineTo(83 * data.peak, -46 * data.peak)
	gfx.LineTo(83 * data.tsumami, 46 * data.tsumami)
	gfx.LineTo(0, 96 * data.tricky)
	gfx.LineTo(-83 * data.handTrip, 46 * data.handTrip)
	gfx.LineTo(-83 * data.oneHand, -46 * data.oneHand)
	gfx.ClosePath()
	gfx.Fill()
end

---@param alpha number
function Radar:drawLines(alpha)
	setStroke({
		alpha = alpha * 0.4,
		color = "White",
		width = 1,
	})
	gfx.BeginPath()
	gfx.MoveTo(0, -65)
	gfx.LineTo(0, 65)
	gfx.Stroke()
	gfx.BeginPath()
	gfx.MoveTo(-57, -33)
	gfx.LineTo(57, 33)
	gfx.Stroke()
	gfx.BeginPath()
	gfx.MoveTo(57, -33)
	gfx.LineTo(-57, 33)
	gfx.Stroke()
end

---@param alpha number
function Radar:drawLabels(alpha)
	self.notes:draw({
		x = 0,
		y = -76,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 0, 240, 240 },
	})
	self.peak:draw({
		x = 78,
		y = -47,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 240, 0, 60 },
	})
	self.tsumami:draw({
		x = 88,
		y = 44,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 220, 0, 180 },
	})
	self.tricky:draw({
		x = 0,
		y = 76,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 220, 220, 0 },
	})
	self.handTrip:draw({
		x = -88,
		y = 43,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 140, 0, 240 },
	})
	self.oneHand:draw({
		x = -88,
		y = -46,
		align = "CenterMiddle",
		alpha = alpha,
		color = { 0, 240, 100 },
	})
end

return Radar
