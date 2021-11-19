game.LoadSkinSample("click_diff")
game.LoadSkinSample("click_song")

--#region Require

local didPress = require("common/helpers/didPress")
local getVolforce = require("common/helpers/getVolforce")
local loadJackets = require("common/helpers/loadJackets")
local menusClosed = require("songselect/helpers/menusClosed")

--#endregion

---@class SongSelectContext: SongSelectContextBase
local SongSelectContext = {}
SongSelectContext.__index = SongSelectContext

---@return SongSelectContext
function SongSelectContext.new()
	---@class SongSelectContextBase
	---@field topPlays TopPlays
	local self = {
		allowFetch = false,
		currentDiff = 1,
		currentSong = 1,
		didPressBTA = false,
		didPressBTD = false,
		fetchTimer = 0,
		folderStatsEnabled = getSetting("showFolderStats", true),
		isFiltering = false,
		pageItemCount = 9,
		playDiffSelectSound = getSetting("playDiffSelectSound", true),
		playSongSelectSound = getSetting("playSongSelectSound", true),
		songCount = 0,
		topPlays = {},
		topPlaysAsArray = {},
		viewingScores = false,
		viewingTop50 = false,
		volforce = 0,
	}

	game.SetSkinSetting("_isSongSelect", 1)
	game.SetSkinSetting("_isViewingTop50", 0)

	---@diagnostic disable-next-line
	return setmetatable(self, SongSelectContext)
end

---@param dt deltaTime
function SongSelectContext:update(dt)
	local song = songwheel.songs[self.currentSong]
	local diff = song and song.difficulties[self.currentDiff]

	if diff then
		self:setDiffInfo(diff, song)
	end

	self.isFiltering = getSetting("_isFiltering", 0) == 1
	self.songCount = #songwheel.songs
	self.viewingTop50 = getSetting("_isViewingTop50", 0) == 1

	self:handleFetch(dt)
	self:handleInput()
end

function SongSelectContext:handleInput()
	if menusClosed() then
		if (not self.didPressBTA)
			and didPress("BTA")
			and (not self.viewingScores)
		then
			self.viewingTop50 = not self.viewingTop50

			game.SetSkinSetting("_isViewingTop50", (self.viewingTop50 and 1) or 0)
		end

		if (not self.didPressBTD)
			and didPress("BTD")
			and (not self.viewingTop50)
		then
			self.viewingScores = not self.viewingScores
		end

		self.didPressBTA = didPress("BTA")
		self.didPressBTD = didPress("BTD")
	end
end

---@param dt deltaTime
function SongSelectContext:handleFetch(dt)
	self.allowFetch = self.fetchTimer >= 1
	self.fetchTimer = self.fetchTimer + dt
end

---@param diff Difficulty
---@param song Song
function SongSelectContext:setDiffInfo(diff, song)
	local key = diff.hash or ("%s_%d"):format(song.title, diff.level)
	local topPlay = self.topPlays[diff.id]
	local dashIndex = song.bpm:find("-")

	if dashIndex then
		game.SetSkinSetting("_minBpm", tonumber(song.bpm:sub(1, dashIndex - 1)))
		game.SetSkinSetting("_maxBpm", tonumber(song.bpm:sub(dashIndex + 1)))
	else
		game.SetSkinSetting("_minBpm", tonumber(song.bpm))
		game.SetSkinSetting("_maxBpm", tonumber(song.bpm))
	end

	game.SetSkinSetting("_diffKey", key)
	game.SetSkinSetting("_diffVolforce", (topPlay and topPlay.volforce) or 0)
end

---@param newSong integer
function SongSelectContext:updateSong(newSong)
	if self.currentSong ~= newSong then
		self.fetchTimer = 0

		if self.playSongSelectSound then
			game.PlaySample("click_song")
		end
	end

	self.currentSong = newSong
end

---@param newDiff integer
function SongSelectContext:updateDiff(newDiff)
	if self.currentDiff ~= newDiff then
		self.fetchTimer = 0

		if self.playDiffSelectSound then
			game.PlaySample("click_diff")
		end
	end

	self.currentDiff = newDiff
end

function SongSelectContext:updateVolforce()
	self.volforce, self.topPlays = getVolforce()

	local array = {}

	for _, topPlay in pairs(self.topPlays) do
		array[#array + 1] = topPlay
	end

	table.sort(array, function(l, r)
		if l.volforce == r.volforce then
			return l.score > r.score
		end

		return l.volforce > r.volforce
	end)

	loadJackets(array)

	self.topPlaysAsArray = array
end

return SongSelectContext
