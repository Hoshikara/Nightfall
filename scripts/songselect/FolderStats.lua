local DimmedNumber = require("common/DimmedNumber")
local FolderStatsCache = require("songselect/FolderStatsCache")
local FolderStatsClears = require("songselect/constants/FolderStatsClears")
local FolderStatsGrades = require("songselect/constants/FolderStatsGrades")
local Easing = require("common/Easing")
local Spinner = require("common/Spinner")

local NumberTemplate = "%d (%.1f%%)"
local ScoreTypes = {
	"min",
	"avg",
	"max",
}

local ceil = math.ceil

---@class FolderStats: FolderStatsBase
local FolderStats = {}
FolderStats.__index = FolderStats

---@param ctx SongSelectContext
---@param window Window
---@return FolderStats
function FolderStats.new(ctx, window)
	---@class FolderStatsBase
	local self = {
		cache = FolderStatsCache.new(),
		clearsText = makeLabel("Medium", "CLEARS", 32, "White"),
		ctx = ctx,
		folderLabel = makeLabel("Medium", "FOLDER", 32),
		folderText = makeLabel("Medium", "", 32, "White"),
		folderTimer = 0,
		gradesText = makeLabel("Medium", "GRADES", 32, "White"),
		heading = makeLabel("Medium", "", 37, "White"),
		levelLabel = makeLabel("Medium", "LV", 32),
		levelText = makeLabel("Medium", "", 29, "White"),
		numberText = makeLabel("Number", "", 22, "White"),
		score = DimmedNumber.new({ size = 48 }),
		scoreLabel = makeLabel("Medium", "SCORES", 32, "White"),
		scoreType = makeLabel("Medium", "", 25),
		shiftAmount = 0,
		shiftEasing = Easing.new(1),
		spinner = Spinner.new({ radius = 64, thickness = 8 }),
		textLabel = makeLabel("Medium", "", 25, "White"),
		window = window,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, FolderStats)
end

---@param dt deltaTime
function FolderStats:draw(dt)
	local isHidden = self:handleShift(dt)

	if isHidden or (self.ctx.songCount == 0) then
		return
	end

	local currentStats = self.cache:get(dt)
	local isPortrait = self.window.isPortrait

	self:setProps()
	gfx.Save()
	gfx.Translate(self.x + (self.shiftAmount * self.shiftEasing.value), self.y)
	self:drawWindow()

	if not currentStats then
		self.spinner:draw(dt, (self.w * 0.5) - 14, (self.h * 0.5) + 14)
	else
		local x = (isPortrait and 38) or 37
		local y = 164

		self:drawHeader(dt, x, currentStats)
		self:drawScores(x, y, isPortrait, currentStats.scores)

		y = y + 137

		self:drawStats(
			x,
			y,
			isPortrait,
			(isPortrait and 306) or 689,
			(isPortrait and 306) or 328,
			currentStats.clears,
			FolderStatsClears,
			self.clearsText
		)

		if isPortrait then
			x = x + 338
		else
			y = y + 320
		end

		self:drawStats(
			x,
			y,
			isPortrait,
			(isPortrait and 550) or 689,
			(isPortrait and 259) or 328,
			currentStats.grades,
			FolderStatsGrades,
			self.gradesText
		)
	end

	gfx.Restore()
end

function FolderStats:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = self.window.paddingX
		self.y = self.window.paddingY

		if self.window.isPortrait then
			self.w = 968
			self.h = 632
		else
			self.w = 768
			self.h = 968
		end

		self.shiftAmount = -(self.window.shiftX + self.window.paddingX + self.w)
		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
---@return boolean
function FolderStats:handleShift(dt)
	if self.ctx.isFiltering then
		self.shiftEasing:stop(dt, 3, 0.2)
	else
		self.shiftEasing:start(dt, 3, 0.2)
	end

	return self.shiftEasing.value == 1
end

function FolderStats:drawWindow()
	drawRect({
		x = 0,
		y = 0,
		w = self.w,
		h = self.h,
		alpha = 0.65,
		color = "Black",
	})
end

---@param dt deltaTime
---@param x number
---@param currentStats FolderStatsData
function FolderStats:drawHeader(dt, x, currentStats)
	local isAll = currentStats.level == "ALL"
	local maxWidth = self.w - 316
	local y = 27

	self.folderText:update(currentStats.folder)
	self.heading:draw({
		x = x,
		y = y,
		text = ("%s'S STATS  -  %d CHARTS"):format(
			getSetting("playerName", "GUEST"),
			currentStats.diffCount
		),
		update = true,
	})

	y = y + 49

	self.levelLabel:draw({ x = x, y = y })
	self.levelText:draw({
		x = x + ((isAll and 45) or 43),
		y = y + ((isAll and 0) or 3),
		font = (isAll and "Medium") or "Number",
		size = (isAll and 32) or 29,
		text = currentStats.level,
		update = true,
	})

	x = x + 128

	self.folderLabel:draw({ x = x, y = y })

	if self.folderText.w > maxWidth then
		self.folderTimer = self.folderTimer + dt

		self.folderText:drawScrolling({
			x = x + 109,
			y = y,
			scale = self.window.scaleFactor,
			timer = self.folderTimer,
			width = maxWidth,
		})
	else
		self.folderText:draw({ x = x + 109, y = y })
	end

	drawRect({
		x = 40,
		y = y + 64,
		w = self.w - 80,
		h = 4,
		color = "Medium",
	})
end

---@param x number
---@param y number
---@param isPortrait boolean
---@param barWidth number
---@param gap number
---@param category FolderStatsCategoryData
---@param categories FolderStatsGrade[]|string[]
---@param categoryName Label
function FolderStats:drawStats(x, y, isPortrait, barWidth, gap, category, categories, categoryName)
	local itemCount = 0
	local lastSegmentColor = Colors.White
	local legendX = x + 2
	local numberText = self.numberText
	local segmentX = x + barWidth + 2
	local textLabel = self.textLabel

	for _, segment in ipairs(category.stats) do
		if segment.count > 0 then
			lastSegmentColor = segment.color
		end
	end

	categoryName:draw({ x = x, y = y })

	x = x + 2
	y = y + 52

	drawRect({
		x = x,
		y = y,
		w = barWidth,
		h = 32,
		color = lastSegmentColor,
	})

	local legendY = y + 52

	for i, segment in ipairs(category.stats) do
		if segment.count > 0 then
			drawRect({
				x = segmentX,
				y = y,
				w = -segment.pct * barWidth,
				h = 32,
				color = segment.color,
			})

			if itemCount == 6 then
				legendY = y + 52
				legendX = x + ((isPortrait and 291) or 360)
			end

			self:drawLegendItem(
				legendX,
				legendY,
				gap,
				segment,
				categories[i].name or categories[i],
				numberText,
				textLabel
			)

			segmentX = ceil(segmentX - (segment.pct * barWidth))
			itemCount = itemCount + 1
			legendY = legendY + 36
		end
	end
end

---@param x number
---@param y number
---@param gap number
---@param segment CategoryStats
---@param name string
---@param numberText Label
---@param textLabel Label
function FolderStats:drawLegendItem(x, y, gap, segment, name, numberText, textLabel)
	drawRect({
		x = x,
		y = y,
		w = 16,
		h = 16,
		color = segment.color,
	})
	textLabel:draw({
		x = x + 30,
		y = y - 9,
		text = name,
		update = true,
	})
	numberText:draw({
		x = x + gap,
		y = y - 6,
		align = "RightTop",
		text = NumberTemplate:format(segment.count, segment.pct * 100),
		update = true,
	})
end

---@param x number
---@param y number
---@param isPortrait boolean
---@param scores FolderStatsScoreData
function FolderStats:drawScores(x, y, isPortrait, scores)
	local score = self.score
	local scoreType = self.scoreType
	local gap = (isPortrait and 339) or 240

	self.scoreLabel:draw({ x = x, y = y })

	y = y + 43

	for _, type in ipairs(ScoreTypes) do
		scoreType:draw({
			x = x,
			y = y,
			text = type,
			update = true,
		})
		score:draw({
			x = x - 1,
			y = y + 26,
			value = scores[type],
		})

		x = x + gap
	end
end

return FolderStats
