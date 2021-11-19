local getGaugeData = require("results/helpers/getGaugeData")
local getHitStats = require("results/helpers/getHitStats")
local getHitWindows = require("results/helpers/getHitWindows")
local getObjectRatings = require("results/helpers/getObjectRatings")
local getRatings = require("results/helpers/getRatings")
local getScoreData = require("results/helpers/getScoreData")
local getTimingData = require("results/helpers/getTimingData")
local getTrackObjects = require("results/helpers/getTrackObjects")

---@param hitStats HitStat[]
---@return number[]
local function getHistogramData(hitStats)
	local histogram = {}

	for _, stat in ipairs(hitStats) do
		if (stat.rating == 1) or (stat.rating == 2) then
			if not histogram[stat.delta] then
				histogram[stat.delta] = 0
			end

			histogram[stat.delta] = histogram[stat.delta] + 1
		end
	end

	return histogram
end

---@param data result
---@return ResultsDuration, number
local function getHoverScale(data)
	local duration = data.duration
	local hoverScale = 10

	if duration then
		hoverScale = math.max(duration / 10000, 5)
	end

	return {
		currentValue = duration or 0,
		value = makeLabel("Number", "0", 18),
	}, hoverScale
end

---@param data result
---@return ResultsGraphData
local function getGraphData(data)
	local duration, hoverScale = getHoverScale(data)
	local hardFail = ((data.gauge_type or 0) == 1) and (data.badge == 1)
	local hitStats = data.noteHitStats or {}
	local holdStats = data.holdHitStats or {}
	local laserStats = data.laserHitStats or {}
	local scoreData = (data.badge > 0)
		and getScoreData(hitStats, holdStats, laserStats, result.duration)
	local sCriticalWindow =
		math.floor(((data.hitWindow and data.hitWindow.perfect) or 46) / 2)
	local ratings, exScore, exScorePct = getRatings(data, hitStats, sCriticalWindow)

	return {
		duration = duration,
		exScore = exScore,
		exScorePct = exScorePct,
		gauge = getGaugeData(data, hardFail),
		histogram = getHistogramData(hitStats),
		hitStats = getHitStats(hitStats, sCriticalWindow),
		hitWindows = getHitWindows(data, sCriticalWindow),
		hoverScale = hoverScale,
		objectRatings = getObjectRatings(data, sCriticalWindow),
		ratings = ratings,
		scoreData = scoreData,
		timings = getTimingData(data, hitStats),
		totalRatings = data.perfects + data.goods + data.misses,
		trackObjects = getTrackObjects(hitStats, holdStats, laserStats, result.duration or 1, sCriticalWindow),
	}
end

return getGraphData

---@class ResultsGraphData
---@field duration ResultsDuration
---@field exScore DimmedNumber
---@field exScorePct Label
---@field gauge ResultsGauge
---@field histogram number[]
---@field hitStats ResultsHitStat[]
---@field hitWindows ResultsHitWindows
---@field hoverScale number
---@field objectRatings ResultsObjectRatings
---@field ratings ResultsRatings
---@field scoreData integer[]
---@field timings ResultsTimings
---@field totalRatings integer
---@field trackObjects ResultsTrackObjects

---@class ResultsDuration
---@field currentValue number
---@field value Label
