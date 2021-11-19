local RatingColors = require("common/constants/RatingColors")

local Buttons = {
  [0] = "A",
  [1] = "B",
  [2] = "C",
  [3] = "D",
  [4] = "L",
  [5] = "R",
}

---@param hitStats HitStat[]
---@param sCriticalWindow integer
---@return ResultsHitStat[]
local function getHitStats(hitStats, sCriticalWindow)
  if #hitStats == 0 then
    return
  end

  for _, hitStat in ipairs(hitStats) do
    if hitStat.rating == 0 then
      hitStat.color = RatingColors.Error
    elseif hitStat.rating == 1 then
      if hitStat.delta < 0 then
        hitStat.color = RatingColors.Early
      else
        hitStat.color = RatingColors.Late
      end
    elseif hitStat.rating == 2 then
      if (hitStat.delta >= -sCriticalWindow) and (hitStat.delta <= sCriticalWindow) then
        hitStat.color = RatingColors.SCritical
      else
        hitStat.color = RatingColors.Critical
      end
    end

    hitStat.button = Buttons[hitStat.lane]
  end

  return hitStats
end

return getHitStats

---@class ResultsHitStat : HitStat
---@field button string
---@field color Color
