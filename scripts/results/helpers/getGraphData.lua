local getGaugeData = require("results/helpers/getGaugeData")
local getHistogramData = require("results/helpers/getHistogramData")
local getHitStats = require("results/helpers/getHitStats")
local getHitWindows = require("results/helpers/getHitWindows")
local getObjectRatings = require("results/helpers/getObjectRatings")
local getRatings = require("results/helpers/getRatings")
local getTimingData = require("results/helpers/getTimingData")

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
    value = makeLabel("Number", "0", 18)
  }, hoverScale
end

---@param data result
---@return ResultsGraphData
local function getGraphData(data)
  local duration, hoverScale = getHoverScale(data)
  local hardFail = ((data.gauge_type or 0) == 1) and (data.badge == 1)
  local hitStats = data.noteHitStats or {}
  local sCriticalWindow =
    math.floor(((data.hitWindow and data.hitWindow.perfect) or 46) / 2)
  local ratings, exScore = getRatings(data, hitStats, sCriticalWindow)

  return {
    duration = duration,
    exScore = exScore,
    gauge = getGaugeData(data, hardFail),
    histogram = getHistogramData(data, hitStats, hardFail),
    hitStats = getHitStats(hitStats, sCriticalWindow),
    hitWindows = getHitWindows(data, sCriticalWindow),
    hoverScale = hoverScale,
    objectRatings = getObjectRatings(data, sCriticalWindow),
    ratings = ratings,
    timings = getTimingData(data, hitStats),
    totalRatings = data.perfects + data.goods + data.misses,
  }
end

return getGraphData

---@class ResultsGraphData
---@field duration ResultsDuration
---@field exScore DimmedNumber
---@field gauge ResultsGauge
---@field histogram number[]
---@field hitStats ResultsHitStat[]
---@field hitWindows ResultsHitWindows
---@field hoverScale number
---@field objectRatings ResultsObjectRatings
---@field ratings ResultsRatings
---@field timing ResultsTimings
---@field totalRatings integer

---@class ResultsDuration
---@field currentValue number
---@field value Label
