---@param text string
---@param value number
---@return ResultsTiming
local function makeTiming(text, value)
  if not value then
    value = makeLabel("Number", "-", 18)
  end

  value = makeLabel("Number", ("%.1f ms"):format(value), 18)

  return {
    text = makeLabel("SemiBold", text, 20),
    value = value
  }
end

---@param hitStats HitStat[]
---@param mean number
---@return number
local function getStandardDeviation(hitStats, mean)
  local count = #hitStats
  local sum = 0

  if count == 0 then
    return sum
  end

  for _, hitStat in ipairs(hitStats) do
    sum = sum + ((hitStat.delta - mean) ^ 2)
  end

  return (sum / count) ^ 0.5
end

---@param data result
---@param hitStats HitStat[]
---@return ResultsTimings
local function getTimingData(data, hitStats)
  local mean = data.meanHitDelta
  local absMean = math.floor(math.abs(mean) + 0.5)
  local resultsTimings = {
    absMean = makeTiming("ABS MEAN", data.meanHitDeltaAbs),
    mean = makeTiming("MEAN", data.meanHitDelta),
    stdDev = makeTiming("STD DEV", getStandardDeviation(hitStats, absMean))
  }

  if absMean > getSetting("songOffsetMin", 3) then
    resultsTimings.suggestion = makeTiming(
      "RECOMMENDED SONG OFFSET",
      tonumber(getSetting("_songOffset", "0")) + math.floor(mean + 0.5)
    )
  end

  return resultsTimings
end

return getTimingData

---@class ResultsTimings
---@field absMean ResultsTiming
---@field mean ResultsTiming
---@field stdDev ResultsTiming
---@field suggestion ResultsTiming

---@class ResultsTiming
---@field text Label
---@field value Label
