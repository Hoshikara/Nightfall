--#region Require

local Clears = require("common/constants/Clears")
local DifficultyNames = require("common/constants/DifficultyNames")
local Grades = require("common/constants/Grades")
local getDateTemplate = require("common/helpers/getDateTemplate")
local loadJackets = require("common/helpers/loadJackets")

--#endregion

local date = os.date

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
			hash = diff.hash,
			illustrator = diff.illustrator:upper(),
			jacketPath = diff.jacketPath,
			level = ("%02d"):format(diff.level),
		}

		self:updateDiff(cachedDiff, diff)

		cachedDiffs[i] = cachedDiff
	end

	return cachedDiffs
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

	for i, score in ipairs(scores) do
		cachedScores[i] = {
			clear = Clears:get(score.badge),
			grade = Grades:get(score.score),
			date = date(getDateTemplate(), score.timestamp),
			score = score.score,
			stats = {
				critical = score.perfects,
				error = score.misses,
				near = score.goods,
			},
			username = "HOSHIKARA"
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
---@field rank? string
---@field score integer
---@field scores CachedScore[]

---@class CachedScore
---@field clear string
---@field date string
---@field grade string
---@field score integer
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
