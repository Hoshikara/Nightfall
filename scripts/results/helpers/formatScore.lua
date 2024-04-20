local Clears = require("common/constants/Clears")
local Grades = require("common/constants/Grades")
local DimmedNumber = require("common/DimmedNumber")
local getDateTemplate = require("common/helpers/getDateTemplate")
local getVolforce = require("common/helpers/getVolforce")
local getGaugeValue = require("results/helpers/getGaugeValue")

---@param data result|Score|IRScore
---@param highScores Score[]
local function getClearWithRaise(data, highScores)
	if data.badge == 0 then
		return makeLabel("Medium", Clears:get(data.badge, false, data), 29)
	end

	local currClear = data.badge
	local highestClear = 0

	for _, score in ipairs(highScores) do
		if score.badge > highestClear then
			highestClear = score.badge
		end
	end

	if currClear > highestClear then
		local curr = Clears:get(currClear, false, data)
		local high = (highestClear == 0 and "NO PLAY") or Clears:get(highestClear, false, data)

		return makeLabel("Medium", ("%s > %s"):format(high, curr), 29)
	end

	return makeLabel("Medium", Clears:get(currClear, false, data), 29)
end

---@param data result|Score|IRScore
---@return Label
local function getDate(data)
	local date = os.date(getDateTemplate(), data.timestamp or os.time())

	---@diagnostic disable-next-line
	return makeLabel("Number", date, 27)
end

---@param data result|Score|IRScore
---@return Label|nil
local function getHitWindows(data)
	if not data.hitWindow then
		return
	end

	return makeLabel(
		"Number",
		("%d / %d"):format(
			(data.hitWindow and data.hitWindow.perfect) or 46,
			(data.hitWindow and data.hitWindow.good) or 150
		),
		25
	)
end

---@param data result|Score|IRScore
---@return Label
local function getPlayer(data)
	local playerName = getSetting("playerName", "GUEST")

	return makeLabel(
		"Medium",
		data.name or data.playerName or data.username or playerName or "GUEST",
		29
	)
end

---@param data result|Score|IRScore
---@param i? integer
---@return ResultsScoreDifference|nil
local function getScoreDifference(data, i)
	if data.uid or (not data.isSelf) or i then
		return
	end

	if (#data.highScores > 0) and (data.badge > 0) then
		local highScore = data.highScores[1].score
		local score = data.score

		if score > highScore then
			return {
				isPositive = true,
				prefix = makeLabel("Number", "+", 27, "Positive"),
				value = DimmedNumber.new({
					color = "Positive",
					size = 27,
					value = score - highScore,
				}),
			}
		elseif score < highScore then
			return {
				isPositive = false,
				prefix = makeLabel("Number", "-", 27, "Negative"),
				value = DimmedNumber.new({
					color = "Negative",
					size = 27,
					value = highScore - score,
				}),
			}
		end
	end
end

---@param data result|Score|IRScore
---@param i? integer
---@return ResultsVolforce|nil
local function getPlayerVolforce(data, i)
	if i then
		return
	end

	local diffVolforce = getSetting("_diffVolforce", 0)
	local increase = nil
	local minimumVolforce = getSetting("_minimumVolforce", 0)
	local playVolforce = getVolforce(nil, {
		jacketPath = data.jacketPath,
		level = data.level,
		scores = { { score = data.score } },
		topBadge = data.badge,
	})
	local playerVolforce = getSetting("_volforce", 0)

	if diffVolforce ~= 0 then
		minimumVolforce = diffVolforce
	end

	if playVolforce > minimumVolforce then
		increase = playVolforce - minimumVolforce
		playerVolforce = playerVolforce + increase
		increase = makeLabel("Number", ("%.3f"):format(increase * 0.001), 18)
	end

	return {
		increase = increase,
		value = makeLabel("Number", ("%.3f"):format(playerVolforce * 0.001), 27),
	}
end

---@param value integer
---@return DimmedNumber
local function makeNumber(value, size)
	return DimmedNumber.new({
		digits = 5,
		size = size or 27,
		value = value or 0,
	})
end

---@param data result|Score|IRScore
---@param i? integer
---@param highScores? Score[]
---@return ResultsScore
local function formatScore(data, i, highScores)
	local clear = (highScores and getClearWithRaise(data, highScores)) or
		makeLabel("Medium", Clears:get(data.badge or data.lamp, false, data), 29)

	return {
		clear = clear,
		critical = makeNumber(data.perfects or data.crit),
		date = getDate(data),
		gauge = getGaugeValue(data),
		grade = makeLabel("Medium", Grades:get(data.score), 29),
		hitWindows = getHitWindows(data),
		error = makeNumber(data.misses or data.error),
		maxChain = makeNumber(data.maxCombo or data.combo, 27),
		near = makeNumber(data.goods or data.near),
		player = getPlayer(data),
		place = makeLabel("Number", ("%02d"):format(data.rank or i or 0), 18),
		score = DimmedNumber.new({ size = (i and 89) or 108, value = data.score or 0 }),
		scoreDifference = getScoreDifference(data, i),
		volforce = getPlayerVolforce(data, i),
	}
end

return formatScore

---@class ResultsScore
---@field clear Label
---@field critical DimmedNumber
---@field date Label
---@field gauge Label
---@field grade Label
---@field hitWindows Label
---@field error DimmedNumber
---@field maxChain? DimmedNumber
---@field near DimmedNumber
---@field player Label
---@field place Label
---@field score DimmedNumber
---@field scoreDifference? ResultsScoreDifference
---@field volforce ResultsVolforce

---@class ResultsScoreDifference
---@field isPositive boolean
---@field prefix Label
---@field value DimmedNumber

---@class ResultsVolforce
---@field increase? Label|nil
---@field value Label
