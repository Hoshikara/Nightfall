local MaxScore = 10000000
local Intervals = math.floor((968 - 80) * 0.75) * 1.5 -- == left graph width

local floor = math.floor

---@param noteScores? integer[]
---@param holdScores? integer[]
---@param laserScores? integer[]
---@return integer[]
local function makeScoresTable(noteScores, holdScores, laserScores)
	local scores = {}

	if noteScores and holdScores and laserScores then
		for i = 1, Intervals do
			scores[i] = noteScores[i] + holdScores[i] + laserScores[i]
		end
	else
		for i = 1, Intervals do
			scores[i] = 0
		end
	end

	return scores
end

---@param objects HitStat[]
---@return integer
local function getMaxScore(objects)
	return #objects * 2
end

---@param objectTime integer
---@param step number
---@return integer
local function getObjectIndex(objectTime, step)
	local i = 0

	while objectTime > 0 do
		objectTime = objectTime - step
		i = i + 1
	end

	return i - 1
end

---@param objects HitStat[]
---@param getMax? boolean
---@return integer[]
local function getScoresByInterval(objects, step, getMax)
	local scores = makeScoresTable()

	for _, obj in ipairs(objects) do
		local i = getObjectIndex(obj.time, step)

		if not scores[i] then
			scores[i] = 0
		end

		if getMax then
			scores[i] = scores[i] + 2
		else
			scores[i] = scores[i] + obj.rating
		end
	end

	first = false

	return scores
end

---@param scores integer[]
---@param maxScores integer[]
---@param maxChartScore integer
local function getSubtractiveScores(scores, maxScores, maxChartScore)
	local s = {}

	for i = 1, Intervals do
		local currentScore = 0
		local currentMaxScore = 0

		for j = 1, i do
			currentScore = currentScore + scores[j]
			currentMaxScore = currentMaxScore + maxScores[j]
		end

		local hitScore = maxChartScore - (currentMaxScore - currentScore)

		s[i] = floor((hitScore / maxChartScore) * MaxScore)
	end

	return s
end

---@param notes HitStat[]
---@param holds HitStat[]
---@param lasers HitStat[]
---@param duration integer
---@return integer[]
local function getScoreData(notes, holds, lasers, duration)
	if (#notes == 0) and (#holds == 0) and (#lasers == 0) then
		return
	end

	local step = (duration or 1) / Intervals
	local maxChartScore = getMaxScore(notes) + getMaxScore(holds) + getMaxScore(lasers)
	local scores = makeScoresTable(
		getScoresByInterval(notes, step),
		getScoresByInterval(holds, step),
		getScoresByInterval(lasers, step)
	)
	local maxScores = makeScoresTable(
		getScoresByInterval(notes, step, true),
		getScoresByInterval(holds, step, true),
		getScoresByInterval(lasers, step, true)
	)

	return getSubtractiveScores(scores, maxScores, maxChartScore)
end

return getScoreData
