local SongSelectScoreListLabels = require("songselect/constants/SongSelectScoreListLabels")
local DimmedNumber = require("common/DimmedNumber")
local Easing = require("common/Easing")
local Grid = require("common/Grid")
local Mouse = require("common/Mouse")
local Spinner = require("common/Spinner")

local LocalOrder = {
	"score",
	"grade",
	"clear",
	"date",
}

local OnlineOrder = {
	"score",
	"grade",
	"clear",
	"username",
}

local StatOrder = {
	"critical",
	"near",
	"error",
}

local function makeWebsiteFunction(self)
	return function(res)
		if (res.statusCode == 20) and res.body and res.body.serverName then
			self.irWebsite = res.body.serverName .. " SCORES"
		end
	end
end

---@class SongSelectScoreList: SongSelectScoreListBase
local SongSelectScoreList = {}
SongSelectScoreList.__index = SongSelectScoreList

---@param ctx SongSelectContext
---@param leaderboardCache LeaderboardCache
---@param songCache SongCache
---@param window Window
---@return SongSelectScoreList
function SongSelectScoreList.new(ctx, leaderboardCache, songCache, window)
	---@class SongSelectScoreListBase
	---@field irWebsite? string
	local self = {
		chartUntracked = makeLabel("Medium", "CHART IS NOT TRACKED", 40),
		ctx = ctx,
		currentStats = nil,
		failedToFetch = makeLabel("Medium", "FAILED TO FETCH SCORES", 40),
		grid = Grid.new(window),
		isOnline = IRData.Active,
		labels = {},
		leaderboardCache = leaderboardCache,
		localScores = makeLabel("Medium", "LOCAL SCORES", 40),
		localSpacing = 0,
		mouse = Mouse.new(window),
		onlineScores = makeLabel("Medium", "ONLINE SCORES", 40),
		onlineSpacing = 0,
		shiftAmount = 0,
		shiftEasing = Easing.new(1),
		songCache = songCache,
		spinner = Spinner.new({ radius = 36, thickness = 4 }),
		stats = {
			critical = DimmedNumber.new({ digits = 5, size = 19 }),
			error = DimmedNumber.new({ digits = 5, size = 19 }),
			near = DimmedNumber.new({ digits = 5, size = 19 }),
		},
		text = {
			clear = makeLabel("Medium", "", 32),
			date = makeLabel("Number", "", 30),
			grade = makeLabel("Medium", "", 32),
			score = DimmedNumber.new({ size = 30 }),
			username = makeLabel("JP", "", 25)
		},
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	for name, str in pairs(SongSelectScoreListLabels) do
		self.labels[name] = makeLabel("SemiBold", str)
	end

	if self.isOnline then
		IR.Heartbeat(makeWebsiteFunction(self))
	end

	---@diagnostic disable-next-line
	return setmetatable(self, SongSelectScoreList)
end

function SongSelectScoreList:draw(dt)
	self.mouse:update()
	self:setProps()
	self:handleShift(dt)
	gfx.Save()
	gfx.Translate(self.x + (self.shiftAmount * self.shiftEasing.value), self.y)
	self:drawWindow()
	self:drawLists(dt)

	if self.currentStats then
		self:drawStatsWindow()
	end

	gfx.Restore()

	self.currentStats = nil
end

function SongSelectScoreList:setProps()
	if self.windowResized ~= self.window.resized then
		local localWidth = 0
		local onlineWidth = 0

		for _, name in ipairs(LocalOrder) do
			localWidth = localWidth + self.labels[name].w
		end

		for _, name in ipairs(OnlineOrder) do
			onlineWidth = onlineWidth + self.labels[name].w
		end

		self.grid:setProps()
		self.x = self.grid.x
		self.y = self.grid.y
		self.w = self.grid.w
		self.h = self.grid.h
		self.localSpacing = (self.w - 104 - localWidth) / 2
		self.onlineSpacing = (self.w - 104 - onlineWidth) / 2
		self.shiftAmount = self.w + self.window.shiftX + (self.window.paddingX * 2)
		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
function SongSelectScoreList:handleShift(dt)
	if self.ctx.viewingScores then
		self.shiftEasing:stop(dt, 3, 0.2)
	else
		self.shiftEasing:start(dt, 3, 0.2)
	end
end

function SongSelectScoreList:drawWindow()
	drawRect({
		x = 0,
		y = 0,
		w = self.w,
		h = self.h,
		alpha = 0.65,
		color = "Black",
	})
end

---@param dt delta
function SongSelectScoreList:drawLists(dt)
	local cachedSong = self.songCache:get(songwheel.songs[self.ctx.currentSong])

	if not cachedSong then
		return
	end

	---@type CachedDiff
	local cachedDiff = cachedSong.diffs[self.ctx.currentDiff] or cachedSong.diffs[1]
	local labels = self.labels
	local isOnline = self.isOnline

	if cachedDiff then
		self:drawScoreList(dt, labels, cachedDiff, true, isOnline)

		if isOnline then
			local cachedLeaderboard = self.leaderboardCache:get(cachedDiff.hash)

			if cachedLeaderboard then
				self:drawScoreList(dt, labels, cachedLeaderboard, false, true)
			end
		end
	end
end

---@param dt deltaTime
---@param labels table<string, Label>
---@param diffOrLeaderboard CachedDiff|CachedLeaderboard
---@param isLocal boolean
---@param isOnline boolean
function SongSelectScoreList:drawScoreList(dt, labels, diffOrLeaderboard, isLocal, isOnline)
	local x = 37
	local y = 26
	local spacing = (self.w - 104) / 4

	if isOnline and (not isLocal) then
		y = 460

		self.onlineScores:draw({
			x = x,
			y = y,
			color = "White",
			text = self.irWebsite or "ONLINE SCORES",
			update = true,
		})
	else
		self.localScores:draw({
			x = x,
			y = y,
			color = "White",
		})
	end

	if diffOrLeaderboard then
		local scores = diffOrLeaderboard.scores

		if isLocal and scores then
			self:drawLabels(x + 14, y + 65, labels, isLocal, spacing)
			self:drawScores(x + 14, y + 100, scores, isLocal, isOnline, spacing)
		else
			if (not diffOrLeaderboard.isGood) then
				self:handleBadReason(dt, diffOrLeaderboard.reason)
			elseif scores then
				self:drawLabels(x + 14, y + 65, labels, isLocal, spacing)
				self:drawScores(x + 14, y + 100, scores, isLocal, isOnline, spacing)
			end
		end
	end
end

---@param x number
---@param y number
---@param labels table<string, Label>
---@param isLocal boolean
---@param spacing number
function SongSelectScoreList:drawLabels(x, y, labels, isLocal, spacing)
	for i, name in ipairs((isLocal and LocalOrder) or OnlineOrder) do
		local tempX = x + ((i - 1) * spacing)

		labels[name]:draw({
			x = tempX,
			y = y,
			color = "Standard",
		})
	end
end

---@param x number
---@param y number
---@param scores CachedScore[]|CachedLeaderboardScore[]
---@param isLocal boolean
---@param isOnline boolean
---@param spacing number
function SongSelectScoreList:drawScores(x, y, scores, isLocal, isOnline, spacing)
	local w = self.w - 80
	local isPortrait = self.window.isPortrait
	local mouse = self.mouse
	local offsetX = self.x
	local offsetY = self.y
	local text = self.text

	for i, score in ipairs(scores) do
		local tempY = y + ((i - 1) * 45)

		if (i % 2) == 1 then
			drawRect({
				x = x - 11,
				y = tempY - 3,
				w = w,
				h = 45,
				alpha = 0.2,
				color = "Standard",
			})
		end

		if mouse:clipped(x - 7 + offsetX, tempY + 1 + offsetY, w - 8, 37) then
			self.currentStats = score.stats
		end

		text.score:draw({
			x = x - 1,
			y = tempY,
			value = score.score,
		})
		text.grade:draw({
			x = x + spacing - 1,
			y = tempY - 2,
			color = "White",
			text = score.grade,
			update = true,
		})
		text.clear:draw({
			x = x + (spacing * 2) - 1,
			y = tempY - 2,
			color = "White",
			text = score.clear,
			update = true,
		})

		if isLocal then
			text.date:draw({
				x = x + (spacing * 3) - 1,
				y = tempY,
				color = "White",
				text = score.date,
				update = true,
			})
		else
			text.username:draw({
				x = x + (spacing * 3) - 1,
				y = tempY + 4,
				color = "White",
				maxWidth = 202,
				text = score.username,
				update = true,
			})
		end

		if isLocal and (not isOnline) then
			if i == ((isPortrait and 18) or 16) then
				break
			end
		elseif isLocal or isOnline then
			if i == 7 then
				break
			end
		end
	end
end

function SongSelectScoreList:drawStatsWindow()
	local x, y = self.mouse:getPos()

	x = x - 95 - self.x
	y = y - self.y - 107

	drawRect({
		x = x,
		y = y,
		w = 189,
		h = 95,
		alpha = 0.9,
		color = "Black",
		isFast = true,
	})

	y = y + 9

	for _, stat in ipairs(StatOrder) do
		self.labels[stat]:draw({
			x = x + 11,
			y = y,
			color = "Standard"
		})
		self.stats[stat]:draw({
			x = x + 114,
			y = y + 1,
			color = "White",
			value = self.currentStats[stat],
		})

		y = y + 25
	end
end

---@param reason string
function SongSelectScoreList:handleBadReason(dt, reason)
	if reason == "LOADING" then
		self.spinner:draw(dt, (self.w * 0.5) - 16, (self.h * 0.75) + 16)
	elseif reason == "UNTRACKED" then
		self.chartUntracked:draw({
			x = self.w * 0.5,
			y = self.h * 0.75,
			align = "CenterMiddle",
			color = "Negative",
		})
	elseif reason == "FAILED" then
		self.failedToFetch:draw({
			x = self.w * 0.5,
			y = self.h * 0.75,
			align = "CenterMiddle",
			color = "Negative",
		})
	end
end

return SongSelectScoreList
