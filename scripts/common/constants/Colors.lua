local getColor = require("common/helpers/getColor")

local floor = math.floor
local min = math.min

local RED = 0
local GREEN = 0
local BLUE = 0

---@param r? number
---@param g? number
---@param b? number
---@param pct? number
---@return Color
local function makeColor(r, g, b, pct)
	r = r or 0
	g = g or 0
	b = b or 0
	pct = pct or 1

	return {
		min(floor(r * pct), 255),
		min(floor(g * pct), 255),
		min(floor(b * pct), 255),
	}
end

---@type table<string, Color>
local Colors = {
	Black = { 0, 0, 0 },
	Negative = getColor("negativeColor"),
	Positive = getColor("positiveColor"),
	White = { 255, 255, 255 },
}

---@diagnostic disable-next-line
function Colors:update()
	local r, g, b, _ = game.GetSkinSetting("colorScheme")

	if (r ~= RED) or (g ~= GREEN) or (b ~= BLUE) then
		self.Dark = makeColor(r, g, b, 0.075)
		self.Medium = makeColor(r, g, b, 0.3)
		self.Standard = makeColor(r, g, b)

		RED = r
		GREEN = g
		BLUE = b
	end
end

Colors:update()

return Colors

---@class Color
---@field [1] integer # Red value in range `[0, 255]`
---@field [2] integer # Green value in range `[0, 255]`
---@field [3] integer # Blue value in range `[0, 255]`
