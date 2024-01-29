local getFolderData = require("songselect/helpers/getFolderData")
local getFolderScoreData = require("songselect/helpers/getFolderScoreData")
local isOfficialChart = require("common/helpers/isOfficialChart")

local getOfficialStats = getSetting("getOfficialStats", true)

---@class FolderStatsCache: FolderStatsCacheBase
local FolderStatsCache = {}
FolderStatsCache.__index = FolderStatsCache

---@return FolderStatsCache
function FolderStatsCache.new()
	---@class FolderStatsCacheBase
	local self = {
		cache = {},
		timers = {},
	}

	---@diagnostic disable-next-line
	return setmetatable(self, FolderStatsCache)
end

---@param dt deltaTime
---@return FolderStatsData|nil
function FolderStatsCache:get(dt)
	local cache = self.cache
	local currentFolder = getSetting("_currentFolder", 1)
	local currentLevel = getSetting("_currentLevel", 1)
	local currentLevelName = "ALL"
	local doFilterAll = getOfficialStats and (currentFolder == 1)
	local diffCount = self:getDiffCount(doFilterAll)

	if currentLevel > 1 then
		currentLevelName = ("%02d"):format(currentLevel - 1)
	end

	if not cache[currentFolder] then
		cache[currentFolder] = {}
	end

	cache = cache[currentFolder]

	if cache[currentLevel] and getSetting("_reloadStats", 0) == 1 then
		cache[currentLevel] = nil

		if self.timers[currentFolder] and self.timers[currentFolder][currentLevel] then
			self.timers[currentFolder][currentLevel] = 0
		end

		game.SetSkinSetting("_reloadStats", 0)
	end

	if not cache[currentLevel] and self:shouldGetData(dt, currentFolder, currentLevel) then
		cache[currentLevel] = {
			diffCount = diffCount,
			clears = getFolderData(diffCount, true, doFilterAll),
			folder = getSetting("_currentFolderName", ""),
			grades = getFolderData(diffCount, false, doFilterAll),
			level = currentLevelName,
			scores = getFolderScoreData(diffCount, doFilterAll),
		}
	end

	return cache[currentLevel]
end

---@param dt deltaTime
---@return boolean
function FolderStatsCache:shouldGetData(dt, currentFolder, currentLevel)
	local timers = self.timers

	if not timers[currentFolder] then
		timers[currentFolder] = {}
	end

	timers = timers[currentFolder]

	if not timers[currentLevel] then
		timers[currentLevel] = 0
	end

	timers[currentLevel] = timers[currentLevel] + dt

	return timers[currentLevel] >= 1
end

---@param doFilterAll boolean
---@return integer
function FolderStatsCache:getDiffCount(doFilterAll)
	local count = 0

	for _, song in ipairs(songwheel.songs) do
		if doFilterAll then
			if isOfficialChart(song.path) then
				count = count + #song.difficulties
			end
		else
			count = count + #song.difficulties
		end
	end

	return count
end

return FolderStatsCache

---@class FolderStatsData
---@field diffCount integer
---@field folder string
---@field clears FolderStatsCategoryData
---@field grades FolderStatsCategoryData
---@field level string
---@field scores FolderStatsScoreData
