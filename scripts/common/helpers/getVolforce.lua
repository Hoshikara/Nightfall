---@diagnostic disable

--#region Require

local Clears = require("common/constants/Clears")
local DifficultyNames = require("common/constants/DifficultyNames")
local Grades = require("common/constants/Grades")
local isOfficialChart = require("common/helpers/isOfficialChart")

--#endregion

local floor = math.floor

---@param diff Difficulty
---@return number
local function calculateVolforce(diff)
	if (#diff.scores < 1) or (not isOfficialChart(diff.jacketPath)) then
		return 0
	end

	local level = diff.level
	local score = diff.scores[1].score

	if not (level and score) then
		return 0
	end

	local clearRate = Clears:get(diff.topBadge, true)
	local gradeRate = Grades:get(score, true)

	return floor(level * (score / 10000000) * clearRate * gradeRate * 2 * 10)
end

---@return Difficulty[]
local function getDiffsWithVolforce()
	local diffs = {}

	for i, song in ipairs(songwheel.allSongs) do
		for _, diff in ipairs(song.difficulties) do
			diff.score = (diff.scores[1] and diff.scores[1].score) or 0
			diff.songIndex = i
			diff.title = song.title
			diff.volforce = calculateVolforce(diff)

			diffs[#diffs + 1] = diff
		end
	end

	table.sort(diffs, function(l, r)
		if l.volforce == r.volforce then
			return l.score > r.score
		end

		return l.volforce > r.volforce
	end)

	return diffs
end

---@param diffs Difficulty[]
---@return number, TopPlays
local function getTotalVolforce(diffs)
	local lastIndex = math.min(#diffs, 50)
	local total = 0
	local topPlays = {}

	for i, diff in ipairs(diffs) do
		if diff.volforce > 0 then
			topPlays[diff.id] = {
				clear = Clears:get(diff.topBadge),
				diffName = DifficultyNames:get(diff.jacketPath, diff.difficulty),
				jacketPath = diff.jacketPath,
				level = diff.level,
				rank = i,
				score = diff.score,
				title = diff.title,
				volforce = diff.volforce,
			}

			total = total + diff.volforce
		end

		if i == lastIndex then
			game.SetSkinSetting("_minimumVolforce", diff.volforce)

			break
		end
	end

	game.SetSkinSetting("_volforce", total)

	return total, topPlays
end

---@param topPlays? TopPlays
---@param singleDiff? Difficulty
---@return number, TopPlays
local function getVolforce(topPlays, singleDiff)
	if singleDiff then
		return calculateVolforce(singleDiff)
	end

	local diffs = getDiffsWithVolforce()

	return getTotalVolforce(diffs)
end

return getVolforce

---@alias TopPlays table<integer, TopPlay>

---@class TopPlay
---@field clear integer
---@field diffName string
---@field jacket any
---@field jacketPath string
---@field level integer
---@field rank integer
---@field score integer
---@field title string
---@field volforce number
