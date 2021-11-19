local RatingColors = require("common/constants/RatingColors")

local distinguishCritRating = getSetting("distinguishCritRating", false)

---@param color Color
---@return Color
local function darken(color)
	return {
		math.floor(color[1] * 0.5),
		math.floor(color[2] * 0.5),
		math.floor(color[3] * 0.5),
	}
end

---@param hitStats HitStat[]
---@param sCriticalWindow integer
---@return ResultsHitStat[]|nil
local function getHitStats(hitStats, sCriticalWindow)
	if #hitStats == 0 then
		return
	end

	local earlyColor = distinguishCritRating and darken(RatingColors.Early) or RatingColors.Early
	local lateColor = distinguishCritRating and darken(RatingColors.Late) or RatingColors.Late

	for _, hitStat in ipairs(hitStats) do
		if hitStat.rating == 0 then
			hitStat.color = RatingColors.Error
		elseif hitStat.rating == 1 then
			if hitStat.delta < 0 then
				hitStat.color = earlyColor
			else
				hitStat.color = lateColor
			end
		elseif hitStat.rating == 2 then
			if (hitStat.delta >= -sCriticalWindow) and (hitStat.delta <= sCriticalWindow) then
				hitStat.color = RatingColors.SCritical
			else
				if distinguishCritRating then
					if hitStat.delta < 0 then
						hitStat.color = RatingColors.Early
					else
						hitStat.color = RatingColors.Late
					end
				else
					hitStat.color = RatingColors.Critical
				end
			end
		end
	end

	return hitStats
end

return getHitStats

---@class ResultsHitStat : HitStat
---@field color Color
