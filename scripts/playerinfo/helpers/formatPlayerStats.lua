local PlayerStatsKeys = require("playerinfo/constants/PlayerStatsKeys")
local DimmedNumber = require("common/DimmedNumber")
local ItemCount = require("common/ItemCount")

local sort = table.sort

local AbbreviatedCategories = {
	"min",
	"max",
	"avg",
}

---@param value integer
---@param total integer
---@return string
local function getPercentage(value, total)
	if total == 0 then
		return "0.00%"
	end

	return ("%.2f%%"):format((value / total) * 100)
end

---@param value? number|string
---@return Label
local function makeNumLabel(value)
	if (type(value) == "number") and (value == 0) then
		value = "-"
	end

	return makeLabel("Number", value, 27)
end

---@param chart PlayerStatsChart
---@param willSort? boolean
---@return FormattedPlayerStatsChart
local function formatChart(chart, willSort)
	local formattedChart = {
		artist = makeLabel("JP", chart.artist, 24),
		score = DimmedNumber.new({ size = 27, value = chart.score }),
		title = makeLabel("JP", chart.title, 24),
	}

	if willSort then
		formattedChart.scoreValue = chart.score
	end

	return formattedChart
end

---@param levels table<string, PlayerStatsLevel>
---@param folder string
---@param isClears? boolean
---@return FormattedPlayerStatsLevels|FormattedPlayerStatsClears|FormattedPlayerStatsGrades
local function formatClearsOrGrades(levels, folder, isClears)
	local SubCategories = PlayerStatsKeys[(isClears and "Clears") or "Grades"]
	local category = (isClears and "clears") or "grades"
	local overallCompleted = 0
	local totalCategory = (isClears and "clearTotals") or "gradeTotals"
	local totalCharts = 0
	local formatted = {}

	for _, subcategory in ipairs(SubCategories) do
		local allCharts = {}
		local chartIndex = 1
		local totalCompleted = 0

		formatted[subcategory] = {
			label = makeLabel("SemiBold", subcategory),
		}

		for level, currentLevel in pairs(levels) do
			---@type FormattedPlayerStatsChart[]
			local charts = {}
			local completed = 0
			local numCharts = currentLevel.diffTotals[folder]

			for i, chart in ipairs(currentLevel[category][subcategory][folder]) do
				charts[i] = formatChart(chart)
				allCharts[chartIndex] = formatChart(chart, true)
				chartIndex = chartIndex + 1
				completed = completed + 1
			end

			totalCompleted = totalCompleted + completed

			formatted[subcategory][level] = {
				alpha = 1,
				charts = charts,
				completed = makeNumLabel(completed),
				completedValue = completed,
				completion = makeNumLabel(getPercentage(completed, numCharts)),
				isHoverable = completed > 0,
				key = ("%s%s"):format(subcategory, level),
				row = tonumber(level)
			}

			if not formatted[level] then
				local numCompleted = currentLevel[totalCategory][folder]

				formatted[level] = {
					completed = makeNumLabel(numCompleted),
					completedValue = numCompleted,
					completion = makeNumLabel(getPercentage(numCompleted, numCharts)),
					count = ItemCount.new({ size = 27, totalItems = numCharts }),
				}

				totalCharts = totalCharts + numCharts
			end
		end

		if chartIndex > 1 then
			sort(allCharts, function(l, r)
				return l.scoreValue > r.scoreValue
			end)
		end

		formatted[subcategory].charts = allCharts
		formatted[subcategory].total = totalCompleted
	end

	for _, subcategory in ipairs(SubCategories) do
		local categoryTotal = formatted[subcategory].total

		overallCompleted = overallCompleted + categoryTotal
		formatted[subcategory].completed = categoryTotal
		formatted[subcategory]["21"] = {
			alpha = 1,
			charts = formatted[subcategory].charts,
			completed = makeNumLabel(categoryTotal),
			completedValue = categoryTotal,
			completion = makeNumLabel(getPercentage(categoryTotal, totalCharts)),
			isHoverable = categoryTotal > 0,
			key = ("%s%s"):format(subcategory, "21"),
		}
	end

	formatted["21"] = {
		completed = makeNumLabel(overallCompleted),
		completedValue = overallCompleted,
		completion = makeNumLabel(getPercentage(overallCompleted, totalCharts)),
		count = ItemCount.new({ size = 27, totalItems = totalCharts }),
	}

	return formatted
end

---@param levels table<string, PlayerStatsLevel>
---@param folder string
---@return FormattedPlayerStatsScores
local function formatScores(levels, folder)
	local formatted = {}

	for i, _ in ipairs(PlayerStatsKeys.Scores) do
		local currentCategory = {}

		for level, currentLevel in pairs(levels) do
			local value = currentLevel.scoreStats[folder][AbbreviatedCategories[i]]

			if value == 0 then
				currentCategory[level] = makeLabel("Number", "-", 27, "White")
			else
				currentCategory[level] = DimmedNumber.new({ size = 27, value = value })
			end
		end

		formatted[i] = currentCategory
	end

	return formatted
end

---@param stats PlayerStats
---@param folder? string
---@return FormattedPlayerStatsClears, FormattedPlayerStatsGrades, FormattedPlayerStatsScores
local function formatPlayerStats(stats, folder)
	folder = folder or "All"

	local clearStats = formatClearsOrGrades(stats.levels, folder, true)
	local gradeStats = formatClearsOrGrades(stats.levels, folder)
	local scoreStats = formatScores(stats.levels, folder)

	return clearStats, gradeStats, scoreStats
end

return formatPlayerStats

--#region Interfaces

---@diagnostic disable-next-line
---@alias FormattedPlayerStatsLevels { ['10']: FormattedPlayerStatsLevel, ['11']: FormattedPlayerStatsLevel, ['12']: FormattedPlayerStatsLevel, ['13']: FormattedPlayerStatsLevel, ['14']: FormattedPlayerStatsLevel, ['15']: FormattedPlayerStatsLevel, ['16']: FormattedPlayerStatsLevel, ['17']: FormattedPlayerStatsLevel, ['18']: FormattedPlayerStatsLevel, ['19']: FormattedPlayerStatsLevel, ['20']: FormattedPlayerStatsLevel, ['21']: FormattedPlayerStatsLevel }

---@diagnostic disable-next-line
---@alias FormattedPlayerStatsClears { ['PLAYED']: FormattedPlayerStatsLevels, ['NORMAL']: FormattedPlayerStatsLevels, ['HARD']: FormattedPlayerStatsLevels, ['UC']: FormattedPlayerStatsLevels, ['PUC']: FormattedPlayerStatsLevels }

---@diagnostic disable-next-line
---@alias FormattedPlayerStatsGrades { ['A']: FormattedPlayerStatsLevels, ['A+']: FormattedPlayerStatsLevels, ['AA']: FormattedPlayerStatsLevels, ['AA+']: FormattedPlayerStatsLevels, ['AAA']: FormattedPlayerStatsLevels, ['AAA+']: FormattedPlayerStatsLevels, ['S']: FormattedPlayerStatsLevels }

---@alias FormattedScore DimmedNumber|Label

---@diagnostic disable-next-line
---@alias FormattedScores { ['10']: FormattedScore, ['11']: FormattedScore, ['12']: FormattedScore, ['13']: FormattedScore, ['14']: FormattedScore, ['15']: FormattedScore, ['16']: FormattedScore, ['17']: FormattedScore, ['18']: FormattedScore, ['19']: FormattedScore, ['20']: FormattedScore, ['21']: FormattedScore }

---@alias FormattedPlayerStatsScores FormattedScores[]

---@class FormattedPlayerStatsLevel
---@field alpha? number
---@field charts? FormattedPlayerStatsChart[]
---@field completed Label
---@field completedValue integer
---@field completion Label
---@field count ItemCount
---@field isHoverable? boolean
---@field key? string
---@field row? integer

---@class FormattedPlayerStatsChart
---@field artist Label
---@field score DimmedNumber
---@field scoreValue? integer
---@field title Label

--#endregion
