local RatingColors = require("common/constants/RatingColors")
local DimmedNumber = require("common/DimmedNumber")

local colorCodeRatings = getSetting("colorCodeRatings", false)

---@param value integer
---@param color string
---@return ResultsRating
local function makeRating(value, color)
	return {
		color = colorCodeRatings and RatingColors[color],
		number = DimmedNumber.new({
			color = "White",
			digits = 5,
			size = 18,
			value = value,
		}),
		value = value
	}
end

---@param data result
---@param hitStats HitStat[]
---@param sCriticalWindow integer
---@return ResultsRatings, DimmedNumber
local function getRatings(data, hitStats, sCriticalWindow)
	local errorEarlyCount = 0
	local nearEarlyCount = 0
	local criticalEarlyCount = 0
	local sCriticalCount = 0
	local sCriticalButtonCount = 0
	local criticalLateCount = 0
	local nearLateCount = 0
	local errorLateCount = 0

	for _, stat in ipairs(hitStats) do
		if stat.rating == 2 then
			if stat.delta < -sCriticalWindow then
				criticalEarlyCount = criticalEarlyCount + 1
			elseif stat.delta > sCriticalWindow then
				criticalLateCount = criticalLateCount + 1
			else
				sCriticalButtonCount = sCriticalButtonCount + 1
			end
		elseif stat.rating == 1 then
			if stat.delta < 0 then
				nearEarlyCount = nearEarlyCount + 1
			else
				nearLateCount = nearLateCount + 1
			end
		elseif stat.rating == 0 then
			if stat.delta < 0 then
				errorEarlyCount = errorEarlyCount + 1
			else
				errorLateCount = errorLateCount + 1
			end
		end
	end

	errorLateCount = errorLateCount + (data.misses - (errorEarlyCount + errorLateCount))
	sCriticalCount = data.perfects - (criticalEarlyCount + criticalLateCount)

	return {
		errorEarly = makeRating(errorEarlyCount, "Error"),
		nearEarly = makeRating(nearEarlyCount, "Early"),
		criticalEarly = makeRating(criticalEarlyCount, "Critical"),
		sCritical = makeRating(sCriticalCount, "SCritical"),
		criticalLate = makeRating(criticalLateCount, "Critical"),
		nearLate = makeRating(nearLateCount, "Late"),
		errorLate = makeRating(errorLateCount, "Error"),
	}, DimmedNumber.new({
		digits = 5,
		size = 27,
		value = (sCriticalButtonCount * 5)
		+ ((criticalEarlyCount + criticalLateCount) * 4)
		+ (data.goods * 2)
		+ ((sCriticalCount - sCriticalButtonCount) * 2)
	})
end

return getRatings

---@class ResultsRatings
---@field errorEarly ResultsRating
---@field nearEarly ResultsRating
---@field criticalEarly ResultsRating
---@field sCritical ResultsRating
---@field criticalLate ResultsRating
---@field nearLate ResultsRating
---@field errorLate ResultsRating

---@class ResultsRating
---@field color? Color
---@field number DimmedNumber
---@field value integer
