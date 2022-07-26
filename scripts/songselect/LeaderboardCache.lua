local Clears = require("common/constants/Clears")
local Grades = require("common/constants/Grades")

---@class LeaderboardCache: LeaderboardCacheBase
local LeaderboardCache = {}
LeaderboardCache.__index = LeaderboardCache

---@param ctx SongSelectContext
---@return LeaderboardCache
function LeaderboardCache.new(ctx)
	---@class LeaderboardCacheBase
	---@field cache table<string, CachedLeaderboard> # Index with `Difficulty.hash`
	local self = {
		cache = {},
		ctx = ctx,
		called = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, LeaderboardCache)
end

---@param hash? string
---@return CachedLeaderboard|nil
function LeaderboardCache:get(hash)
	if not hash then
		return
	end

	if not self.cache[hash] then
		self.cache[hash] = {
			isGood = false,
			fetched = false,
			reason = "LOADING",
		}
	elseif self.ctx.allowFetch and (not self.cache[hash].fetched) then
		if self.ctx.allowFetch then
			self.cache[hash].fetched = true
			self.called = self.called + 1

			IR.Leaderboard(hash, "best", 7, self:cacheFactory(hash))
		end
	end

	return self.cache[hash]
end

---@param hash string
function LeaderboardCache:cacheFactory(hash)
	return function(res)
		if res.statusCode == 42 then
			self.cache[hash].reason = "UNTRACKED"
		elseif (res.statusCode == 20) and (res.body ~= nil) then
			self.cache[hash].isGood = true
			self.cache[hash].scores = self:getScores(res.body)
		elseif res.statusCode == 44 then
			self.cache[hash].reason = "UNTRACKED"
		else
			self.cache[hash].reason = "FAILED"
		end
	end
end

---@param scores IRScore[]
---@return CachedLeaderboardScore[]
function LeaderboardCache:getScores(scores)
	local cachedLeaderboardScores = {}

	for i, score in ipairs(scores) do
		cachedLeaderboardScores[i] = {
			clear = Clears:get(score.lamp),
			grade = Grades:get(score.score),
			score = score.score,
			stats = {
				critical = score.crit or 0,
				error = score.error or 0,
				near = score.near or 0,
			},
			username = score.username or "",
		}
	end

	return cachedLeaderboardScores
end

return LeaderboardCache

---@class CachedLeaderboard
---@field fetched boolean
---@field isGood boolean
---@field reason? string
---@field scores? CachedLeaderboardScore[]

---@class CachedLeaderboardScore : CachedScore
---@field username string
