local DifficultyNames = require("common/constants/DifficultyNames")

local fallbackJacket = gfx.CreateSkinImage("loading.png", 0)

---@param data result
local function getTitle(data)
	if data.playerName and data.realTitle then
		return makeLabel("JP", data.realTitle, 36)
	end

	return makeLabel("JP", data.title or "", 36)
end

---@param data result
---@return ResultsChart
local function formatChart(data)
	local resultsChart = {
		artist = makeLabel("JP", data.artist or "", 24),
		bpm = makeLabel("Number", data.bpm or "", 27),
		difficulty = makeLabel(
			"Medium",
			DifficultyNames:get(data.jacketPath, data.difficulty),
			29
		),
		effector = makeLabel("JP", data.effector or "", 24),
		jacket = gfx.LoadImageJob(data.jacketPath, fallbackJacket, 500, 500),
		level = makeLabel("Number", ("%02d"):format(data.level or 0), 27),
		title = getTitle(data),
	}

	if data.bpm:find("-") and (data.speedModType == 2) then
		resultsChart.cmodText = makeLabel("Standard", "CMOD USED", 29)
	end

	return resultsChart
end

return formatChart

---@class ResultsChart
---@field artist Label
---@field bpm Label
---@field cmodText? Label
---@field difficulty Label
---@field effector Label
---@field jacket any
---@field level Label
---@field title Label
