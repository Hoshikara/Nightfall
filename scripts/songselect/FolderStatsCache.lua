local getFolderData = require("songselect/helpers/getFolderData")
local getFolderScoreData = require("songselect/helpers/getFolderScoreData")

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
	local diffCount = self:getDiffCount()

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
			clears = getFolderData(diffCount, true),
			folder = getSetting("_currentFolderName", ""),
			grades = getFolderData(diffCount),
			level = currentLevelName,
			scores = getFolderScoreData(diffCount),
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

---@return integer
function FolderStatsCache:getDiffCount()
	local count = 0

	for _, song in ipairs(songwheel.songs) do
		count = count + #song.difficulties
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
