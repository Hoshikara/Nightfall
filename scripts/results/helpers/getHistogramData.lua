local JsonTable = require("common/JsonTable")

---@param data result
---@param hardFail boolean
---@return number[]
local function getHistogramData(data, hitStats, hardFail)
  local currentTime = 1000
  local densityData = {}
  local densityIndex = 1
  local diffKey = getSetting("_diffKey", "")
  local histogram = {}
  local hitCount = 0
  local saveDensity = true

  if hardFail then
    saveDensity = false
  elseif data.badge == 0 then
    saveDensity = data.autoplay and (data.score == 10000000)
  end

  for _, stat in ipairs(hitStats) do
    if (stat.rating == 1) or (stat.rating == 2) then
      if not histogram[stat.delta] then
        histogram[stat.delta] = 0
      end

      histogram[stat.delta] = histogram[stat.delta] + 1
    end

    if saveDensity then
      if stat.time < currentTime then
        hitCount = hitCount + 1
      else
        densityData[densityIndex] = hitCount

        currentTime = currentTime + 1000
        densityIndex = densityIndex + 1
        hitCount = 0
      end
    end
  end

  if (diffKey ~= "") and saveDensity then
    local densities = JsonTable.new("densities")

    densities:set(diffKey, densityData)
    game.SetSkinSetting("_newDensityData", 1)
  end

  return histogram
end

return getHistogramData
