local Fonts = require("common/constants/Fonts")
local TextAlignments = require("common/constants/TextAlignments")

---@param t table<string, any>
local function debug(t)
	if (not t) then
		return
	end

	local numItems = 0
	local w = 0
	local h = 0

	gfx.FontSize(32)
	Fonts:load("Regular")
	TextAlignments:align("LeftTop")

	for k, v in pairs(t) do
		local x1, y1, x2, y2 = gfx.TextBounds(0, 0, ("%s: %s"):format(k, v))

		if ((x2 - x1) > w) then
			w = x2 - x1
		end

		if ((y2 - y1) > h) then
			h = y2 - y1
		end

		numItems = numItems + 1
	end

	gfx.Save()
	gfx.Translate(8, 4)
	gfx.BeginPath()
	gfx.FillColor(0, 0, 0, 255)
	gfx.Rect(-8, -4, w + 16, (h * numItems) + 8)
	gfx.Fill()
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255, 255)

	numItems = 0

	for k, v in pairs(t) do
		gfx.Text(("%s: %s"):format(k, v), 0, h * numItems)

		numItems = numItems + 1
	end

	gfx.Restore()
end

return debug
