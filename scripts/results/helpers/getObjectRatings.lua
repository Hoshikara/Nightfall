local RatingColors = require("common/constants/RatingColors")
local DimmedNumber = require("common/DimmedNumber")

local abs = math.abs

---@param value? number
---@param color? string
local function makeNumber(value, color)
	if value then
		return DimmedNumber.new({
			color = color or "White",
			digits = 5,
			size = 18,
			value = value,
		})
	end

	return makeLabel("Number", "-", 18, "White")
end

---@return table<string, Color>|{}
local function getColors()
	if getSetting("colorCodeRatings", false) then
		return {
			sCritical = RatingColors.SCritical,
			critical = RatingColors.Critical,
			near = RatingColors.Late,
			error = RatingColors.Error,
		}
	end

	return {}
end

---@param data result
---@return ResultsObjectRating
local function getBestObjectRatings(data)
	local bestObjectRatings = {
		sCritical = makeNumber(),
		critical = makeNumber(),
		near = makeNumber(),
		error = makeNumber(),
	}

	if #data.highScores == 0 then
		return bestObjectRatings
	end

	local nearCount = nil
	local errorCount = nil

	for _, score in ipairs(data.highScores) do
		local hardFail = ((score.gauge_type or 0) == 1) and (score.badge == 1)

		if not hardFail then
			if not nearCount then
				nearCount = score.goods
			end

			if not errorCount then
				errorCount = score.misses
			end

			if score.goods < nearCount then
				nearCount = score.goods
			end

			if score.misses < errorCount then
				errorCount = score.misses
			end
		end
	end

	if (not nearCount) or (not errorCount) then
		return bestObjectRatings
	end

	bestObjectRatings.near = makeNumber(
		nearCount,
		((data.goods <= nearCount) and "Positive") or "Negative"
	)
	bestObjectRatings.error = makeNumber(
		errorCount,
		((data.misses <= errorCount) and "Positive") or "Negative"
	)

	return bestObjectRatings
end

---@param data result
---@param sCriticalWindow integer
---@return integer, integer, integer, integer
local function getButtonCounts(data, sCriticalWindow)
	local criticalCount = 0
	local errorCount = 0
	local nearCount = data.goods or 0
	local sCriticalCount = 0
	local stats = data.noteHitStats or {}

	for _, stat in ipairs(stats) do
		if stat.rating == 2 then
			if abs(stat.delta) <= sCriticalWindow then
				sCriticalCount = sCriticalCount + 1
			else
				criticalCount = criticalCount + 1
			end
		elseif stat.rating == 0 then
			errorCount = errorCount + 1
		end
	end

	return sCriticalCount, criticalCount, nearCount, errorCount
end

---@param stats HitStat[]
---@return integer, integer
local function getHoldOrLaserCounts(stats)
	local sCriticalCount = 0
	local errorCount = 0

	for _, stat in ipairs(stats) do
		if stat.rating == 0 then
			errorCount = errorCount + 1
		else
			sCriticalCount = sCriticalCount + 1
		end
	end

	return sCriticalCount, errorCount
end

---@param data result
---@param sCriticalWindow integer
---@return ResultsObjectRatings
local function getObjectRatings(data, sCriticalWindow)
	local sCriticalCount, criticalCount, nearCount, errorCount =
	  getButtonCounts(data, sCriticalWindow)
	local holdSCriticalCount, holdErrorCount =
	  getHoldOrLaserCounts(data.holdHitStats or {})
	local laserSCriticalCount, laserErrorCount =
	  getHoldOrLaserCounts(data.laserHitStats or {})

	return {
		colors = getColors(),
		best = getBestObjectRatings(data),
		button = {
			sCritical = makeNumber(sCriticalCount),
			critical = makeNumber(criticalCount),
			near = makeNumber(nearCount),
			error = makeNumber(errorCount),
		},
		hold = {
			sCritical = makeNumber(holdSCriticalCount),
			critical = makeNumber(),
			near = makeNumber(),
			error = makeNumber(holdErrorCount),
		},
		laser = {
			sCritical = makeNumber(laserSCriticalCount),
			critical = makeNumber(),
			near = makeNumber(),
			error = makeNumber(laserErrorCount),
		},
		total = {
			sCritical = makeNumber(sCriticalCount + holdSCriticalCount + laserSCriticalCount),
			critical = makeNumber(criticalCount),
			near = makeNumber(nearCount),
			error = makeNumber(errorCount + holdErrorCount + laserErrorCount),
		},
	}
end

return getObjectRatings

---@class ResultsObjectRatings
---@field colors table<string, Color>
---@field best ResultsObjectRating
---@field button ResultsObjectRating
---@field hold ResultsObjectRating
---@field laser ResultsObjectRating
---@field total ResultsObjectRating

---@class ResultsObjectRating
---@field error Label
---@field critical Label
---@field near Label
---@field sCritical Label
