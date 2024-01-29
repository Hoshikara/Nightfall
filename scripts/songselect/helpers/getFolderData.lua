local FolderStatsClears = require("songselect/constants/FolderStatsClears")
local FolderStatsGrades = require("songselect/constants/FolderStatsGrades")
local getSegmentColors = require("songselect/helpers/getSegmentColors")
local isOfficialChart = require("common/helpers/isOfficialChart")

---@param isClears? boolean
local function makeEmptyTable(isClears)
	local t = {}

	for i, objOrString in ipairs((isClears and FolderStatsClears) or FolderStatsGrades) do
		t[i] = {
			name = (isClears and objOrString) or objOrString.name,
			count = 0,
			pct = 0,
		}
	end

	return t
end

---@param isClears? boolean
---@param stats CategoryStats
---@param diffs Difficulty[]
local function addToCount(isClears, stats, diffs)
	local unplayedGradeIndex = #FolderStatsGrades

	for _, diff in ipairs(diffs) do
		if isClears then
			stats[6 - diff.topBadge].count = stats[6 - diff.topBadge].count + 1
		else
			local gradeIndex = unplayedGradeIndex

			if diff.topBadge > 0 then
				for i, grade in ipairs(FolderStatsGrades) do
					if diff.scores[1].score >= grade.breakpoint then
						gradeIndex = i

						break
					end
				end
			end

			stats[gradeIndex].count = stats[gradeIndex].count + 1
		end
	end
end

---@param diffCount integer
---@param stats CategoryStats[]
local function getTotalPercentages(diffCount, stats)
	for _, category in ipairs(stats) do
		category.pct = category.count / diffCount
	end
end

---@param stats CategoryStats[]
---@return integer
local function getCategoryCount(stats)
	local count = 0

	for _, category in ipairs(stats) do
		if category.count > 0 then
			count = count + 1
		end
	end

	return count
end

---@param diffCount integer
---@param isClears boolean
---@param doFilterAll boolean
---@return FolderStatsCategoryData
local function getFolderData(diffCount, isClears, doFilterAll)
	local count = 0
	local stats = makeEmptyTable(isClears)

	if diffCount > 0 then
		for _, song in ipairs(songwheel.songs) do
			if doFilterAll then
				if isOfficialChart(song.path) then
					addToCount(isClears, stats, song.difficulties)
				end
			else
				addToCount(isClears, stats, song.difficulties)
			end
		end

		getTotalPercentages(diffCount, stats)
		getSegmentColors(stats)

		count = getCategoryCount(stats)
	end

	return {
		count = count,
		stats = stats,
		total = diffCount,
	}
end

return getFolderData

---@class FolderStatsCategoryData
---@field count integer
---@field stats CategoryStats[]
---@field total integer

---@class CategoryStats
---@field color Color
---@field count integer
---@field name string
---@field pct number
