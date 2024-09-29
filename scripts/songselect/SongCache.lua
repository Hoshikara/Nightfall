--#region Require

local Clears = require("common/constants/Clears")
local DifficultyNames = require("common/constants/DifficultyNames")
local Grades = require("common/constants/Grades")
---@type RadarDbEntry[]
local RadarDb = require("songselect/constants/RadarDb")
local getDateTemplate = require("common/helpers/getDateTemplate")
local loadJackets = require("common/helpers/loadJackets")

--#endregion

local SetterTemplate = "%s @ %s"

local date = os.date
local playerName = getSetting("playerName", "GUEST")

---@class SongCache: SongCacheBase
local SongCache = {}
SongCache.__index = SongCache

---@param ctx SongSelectContext
---@return SongCache
function SongCache.new(ctx)
	---@class SongCacheBase
	---@field cache table<integer, CachedSong> # Index with `Song.id`
	local self = {
		cache = {},
		---@diagnostic disable-next-line
		ctx = ctx,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, SongCache)
end

---@param song Song|nil
---@return CachedSong|nil
function SongCache:get(song)
	if not song then
		return
	end

	local cachedSong = self.cache[song.id]

	if not cachedSong then
		self.cache[song.id] = self:cacheSong(song)
	else
		self:updateDiffs(song, cachedSong)
		loadJackets(cachedSong.diffs)
	end

	return cachedSong
end

---@param song Song
---@return CachedSong
function SongCache:cacheSong(song)
	return {
		artist = song.artist:upper(),
		bpm = song.bpm,
		diffs = self:cacheDiffs(song),
		illustrator = self:getIllustrator(song),
		title = song.title:upper(),
	}
end

---@param song Song
---@return string|nil
function SongCache:getIllustrator(song)
	for _, diff in ipairs(song.difficulties) do
		if (diff.illustrator ~= "") and (diff.illustrator ~= "-") then
			return diff.illustrator
		end
	end
end

---@param song Song
---@param cachedSong CachedSong
function SongCache:updateDiffs(song, cachedSong)
	local cachedDiffs = cachedSong.diffs
	local diffs = song.difficulties

	if (not diffs[1]) or (not cachedDiffs[1]) then
		return
	end

	if (diffs[1].difficulty ~= cachedDiffs[1].diffIndex) or (#diffs ~= #cachedDiffs) then
		cachedSong.diffs = self:cacheDiffs(song)
	else
		for i, diff in ipairs(diffs) do
			self:updateDiff(cachedDiffs[i], diff)
		end
	end
end

---@param song Song
---@return CachedDiff[]
function SongCache:cacheDiffs(song)
	local cachedDiffs = {}

	for i, diff in ipairs(song.difficulties) do
		---@type CachedDiff
		local cachedDiff = {
			diffIndex = diff.difficulty,
			diffName = DifficultyNames:get(diff.jacketPath, diff.difficulty, true),
			effector = diff.effector:upper(),
			hash = diff.id,
			illustrator = diff.illustrator:upper(),
			jacketPath = diff.jacketPath,
			level = ("%02d"):format(diff.level),
			radar = self:getDiffRadar(song, diff.difficulty, diff.level),
		}

		self:updateDiff(cachedDiff, diff)

		cachedDiffs[i] = cachedDiff
	end

	return cachedDiffs
end

---@param song Song
---@param diffIndex integer
---@param level integer
---@return RadarData|nil
function SongCache:getDiffRadar(song, diffIndex, level)
	for _, entry in ipairs(RadarDb) do
		for __, title in ipairs(entry.titles) do
			if (song.title == title) then
				for ___, artist in ipairs(entry.artists) do
					if (song.artist == artist) then
						for ____, diff in ipairs(entry.diffs) do
							if (diff.index == diffIndex) and (diff.level == level) then
								return diff.radar
							end
						end
					end
				end
			end
		end
	end

	if not song.path then return nil end

	-- Check if the chart folder has a radar file
	local radarFile = io.open(song.path .. "/radar.lua", "r")

	if radarFile then
		local file = dofile(song.path .. "/radar.lua")

		for _, diff in ipairs(file) do
			if (diff.index == diffIndex) and (diff.level == level) then
				return diff.radar
			end
		end

		radarFile:close()
	end
end

---@param cachedDiff CachedDiff
---@param diff Difficulty
function SongCache:updateDiff(cachedDiff, diff)
	if diff.topBadge > 0 then
		local topScore = diff.scores[1]

		cachedDiff.clear = Clears:get(diff.topBadge)
		cachedDiff.date = date(getDateTemplate(), topScore.timestamp)
		cachedDiff.grade = Grades:get(topScore.score)
		cachedDiff.rank = self:getRank(diff.id)
		cachedDiff.score = topScore.score
		cachedDiff.scores = self:getScores(diff.scores)
	end
end

---@param scores Score[]
---@return CachedScore[]
function SongCache:getScores(scores)
	local cachedScores = {}
	local dateTemplate = getDateTemplate()

	for i, score in ipairs(scores) do
		local scoreDate = date(dateTemplate, score.timestamp)

		cachedScores[i] = {
			clear = Clears:get(score.badge),
			grade = Grades:get(score.score),
			date = scoreDate,
			score = score.score,
			setter = self:getSetter(score, scoreDate),
			stats = {
				critical = score.perfects,
				error = score.misses,
				near = score.goods,
			},
		}
	end

	return cachedScores
end

---@param diffId integer
---@return string|nil
function SongCache:getRank(diffId)
	local topPlay = self.ctx.topPlays[diffId]

	if topPlay then
		return ("%02d / 50"):format(topPlay.rank)
	end
end

---@param score Score
---@param scoreDate string|osdate
---@return string
function SongCache:getSetter(score, scoreDate)
	local setterName = playerName

	if score.playerName and score.playerName ~= "" then
		setterName = score.playerName
	end

	return SetterTemplate:format(setterName, scoreDate)
end

return SongCache

---@class CachedDiff
---@field clear string|number
---@field date string|osdate
---@field diffIndex integer
---@field diffName string
---@field effector string
---@field grade string|number|nil
---@field hash string
---@field jacket any
---@field jacketPath string
---@field level string
---@field radar RadarData|nil
---@field rank? string
---@field score integer
---@field scores CachedScore[]

---@class CachedScore
---@field clear string
---@field grade string
---@field score integer
---@field setter string
---@field stats CachedHitStats

---@class CachedSong
---@field artist string
---@field bpm number
---@field diffs CachedDiff[]
---@field illustrator? string
---@field title string

---@class CachedHitStats
---@field critical integer
---@field near integer
---@field error integer

---@class RadarDbEntry
---@field artists string[]
---@field titles string[]
---@field diffs RadarDbDiff[]

---@class RadarDbDiff
---@field index integer
---@field level integer
---@field radar RadarData

---@class RadarData
---@field notes number
---@field peak number
---@field tsumami number
---@field tricky number
---@field oneHand number
---@field handTrip number
