---@param diffCount integer
---@return FolderStatsScoreData
local function getFolderScoreData(diffCount)
	local min = 10000001
	local max = 0
	local total = 0
	local totalBest = 0

	if diffCount > 0 then
		for _, song in ipairs(songwheel.songs) do
			for _, diff in ipairs(song.difficulties) do
				if diff.topBadge > 0 then
					local score = diff.scores[1].score

					total = total + score
					totalBest = totalBest + 1

					if score < min then
						min = score
					end

					if score > max then
						max = score
					end
				end
			end
		end
	end

	if min == 10000001 then
		min = 0
	end

	if totalBest == 0 then
		totalBest = 1
	end

	return {
		avg = math.floor(total / totalBest),
		min = min,
		max = max,
	}
end

return getFolderScoreData

---@class FolderStatsScoreData
---@field avg integer
---@field min integer
---@field max integer
