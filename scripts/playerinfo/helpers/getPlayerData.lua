local JsonTable = require("common/JsonTable")
local playerJson = JsonTable.new("player")
local playerData = playerJson:get()

do
	if (not playerData.version) and playerData.stats then
		local levels = {}

		for levelKey, level in pairs(playerData.stats.levels) do
			levels[levelKey] = {
				clears = {},
				clearTotals = {},
				diffTotals = {},
				grades = {},
				gradeTotals = {},
				scoreStats = level.scoreStats,
			}

			local clears = levels[levelKey].clears
			local clearTotals = levels[levelKey].clearTotals
			local diffTotals = levels[levelKey].diffTotals
			local grades = levels[levelKey].grades
			local gradeTotals = levels[levelKey].gradeTotals

			for clearKey, clear in pairs(level.clears) do
				clears[clearKey] = {}

				local folders = clears[clearKey]

				for folderKey, folder in pairs(clear) do
					folders[folderKey] = folder.charts
				end
			end

			for i = 10, 20 do
				clears["PLAYED"] = {}

				local folders = clears["PLAYED"]

				for folderKey, _ in pairs(level.clears["NORMAL"]) do
					folders[folderKey] = {}
				end
			end

			for gradeKey, grade in pairs(level.grades) do
				grades[gradeKey] = {}

				local folders = grades[gradeKey]

				for folderKey, folder in pairs(grade) do
					folders[folderKey] = folder.charts
				end
			end

			for folderKey, folder in pairs(level.clearTotals) do
				clearTotals[folderKey] = folder.total
			end

			for folderKey, folder in pairs(level.diffTotals) do
				diffTotals[folderKey] = folder.total
			end

			for folderKey, folder in pairs(level.gradeTotals) do
				gradeTotals[folderKey] = folder.total
			end
		end

		playerData = {
			stats = {
				folders = playerData.stats.folders,
				levels = levels,
				playCount = playerData.stats.playCount,
				top50 = playerData.stats.top50,
			},
			version = SKIN_VERSION,
			volforce = playerData.VF
		}

		playerJson:overwriteContents(playerData)
	end
end

---@param refetch boolean
---@return PlayerData
local function getPlayerData(refetch)
	if refetch then
		playerData = playerJson:get(true)
	end

	return playerData
end

return getPlayerData
