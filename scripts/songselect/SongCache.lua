--#region Require

local Clears = require("common/constants/Clears")
local DifficultyNames = require("common/constants/DifficultyNames")
local Grades = require("common/constants/Grades")
local getDateTemplate = require("common/helpers/getDateTemplate")
local loadJackets = require("common/helpers/loadJackets")

--#endregion

local date = os.date

---@class SongCache
---@field cache table<integer, CachedSong> # Index with `Song.id`
local SongCache = {}
SongCache.__index = SongCache

---@param ctx SongSelectContext
---@return SongCache
function SongCache.new(ctx)
  ---@type SongCache
  local self = {
    cache = {},
    ctx = ctx,
  }

  return setmetatable(self, SongCache)
end

---@param song Song
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
    title = song.title:upper(),
  }
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
      self:updateDiff(cachedDiffs[i], diff, song, false)
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
      jacketPath = diff.jacketPath,
      level = ("%02d"):format(diff.level),
    }

    self:updateDiff(cachedDiff, diff, song, true)

    cachedDiffs[i] = cachedDiff
  end

  return cachedDiffs
end

---@param cachedDiff CachedDiff
---@param diff Difficulty
---@param song Song
---@param isInitialCache boolean
function SongCache:updateDiff(cachedDiff, diff, song, isInitialCache)
  if diff.topBadge > 0 then
    local topScore = diff.scores[1]
    
    cachedDiff.clear = Clears:get(diff.topBadge)
    cachedDiff.date = date(getDateTemplate(), topScore.timestamp)
    cachedDiff.grade = Grades:get(topScore.score)
    cachedDiff.rank = self:getRank(diff.id)
    cachedDiff.score = topScore.score
  end
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
---@field clear string
---@field date string
---@field diffIndex integer
---@field diffName string
---@field effector string
---@field grade string
---@field jacket any
---@field jacketPath string
---@field level string
---@field rank? string
---@field score integer

---@class CachedSong
---@field artist string
---@field bpm number
---@field diffs CachedDiff[]
---@field title string
