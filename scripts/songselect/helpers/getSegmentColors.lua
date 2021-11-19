local floor = math.floor
local max = math.max
local min = math.min

local function clampColor(value)
	if value < 0 then
		return 0
	end

	if value > 255 then
		return 255
	end

	return value
end

---@return Color, Color
local function getColors()
	local color = Colors.Standard
	local r = color[1]
	local g = color[2]
	local b = color[3]

	return color, {
		clampColor(max(r, g, b) + min(r, g, b) - r),
		clampColor(max(r, g, b) + min(r, g, b) - g),
		clampColor(max(r, g, b) + min(r, g, b) - b),
	}
end

---@param color Color
---@param multiplier integer
---@param segmentCount integer
---@return Color
local function getSegmentColor(color, multiplier, segmentCount)
	local newColor = {}

	for i, value in ipairs(color) do
		local delta = value / segmentCount

		newColor[i] = max(floor(color[i] - (delta * multiplier)), 50)
	end

	return newColor
end

---@param main Color
---@param secondary Color
---@param stats CategoryStats[]
---@param segmentCount integer
local function setSegmentColors(main, secondary, stats, segmentCount)
	local insertionCount = 0
	local color = main
	local swap = true

	for _, category in ipairs(stats) do
		if category.count > 0 then
			category.color = getSegmentColor(color, insertionCount, segmentCount)

			if swap then
				color = secondary
			else
				color = main
				insertionCount = insertionCount + 2
			end

			swap = not swap
		end
	end
end

---@param stats CategoryStats[]
---@return integer
local function getSegmentCount(stats)
	local count = 0

	for _, category in ipairs(stats) do
		if category.count > 0 then
			count = count + 1
		end
	end

	if count == 0 then
		return 1
	end

	return count
end

---@param stats CategoryStats[]
local function getSegmentColors(stats)
	local main, secondary = getColors()
	local segmentCount = getSegmentCount(stats)

	setSegmentColors(main, secondary, stats, segmentCount)
end

return getSegmentColors
