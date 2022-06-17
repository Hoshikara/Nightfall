--#region Require

local SongPanelLabels = require("songselect/constants/SongPanelLabels")
local Button = require("common/Button")
local DimmedNumber = require("common/DimmedNumber")
local Easing = require("common/Easing")
local Image = require("common/Image")
local ItemCursor = require("common/ItemCursor")
local SearchBar = require("common/SearchBar")
local Spinner = require("common/Spinner")
local getDiffInOrder = require("songselect/helpers/getDiffInOrder")

--#endregion

local min = math.min

---@class SongPanel
---@field diffNames Label[]
---@field labels table<string, Label>
---@field text table<string, Label>
---@field timers table<string, number>
local SongPanel = {}
SongPanel.__index = SongPanel

---@param ctx SongSelectContext
---@param songCache SongCache
---@param window Window
---@return SongPanel
function SongPanel.new(ctx, songCache, window)
	---@type SongPanel
	local self = {
		artistText = makeLabel("JP", "", 28),
		artistTimer = 0,
		bpmText = makeLabel("Number", "", 29),
		button = Button.new(132, 48),
		buttonMargin = 0,
		chartLoadingSpinner = Spinner.new({ text = "LOADING CHARTS" }),
		clearText = makeLabel("Medium", "", 32),
		ctx = ctx,
		currentDiff = 0,
		currentSong = 0,
		diffText = makeLabel("Medium", ""),
		effectorText = makeLabel("JP", "", 25),
		effectorTimer = 0,
		gradeText = makeLabel("Medium", "", 32),
		illustratorText = makeLabel("JP", "", "25"),
		illustratorTimer = 0,
		itemCursor = ItemCursor.new({
			size = 10,
			stroke = 1.5,
			type = "Horizontal",
		}),
		jacketAlpha = Easing.new(),
		jacketGradient = Image.new({ path = "song_select/jacket_gradient" }),
		jacketOffset = 0,
		jacketShift1 = 0,
		jacketShift2 = 0,
		jacketSize = 0,
		labels = {},
		levelText = makeLabel("Number", "", 20),
		maxWidthBottom = 0,
		maxWidthTop = 0,
		scissorSize = 0,
		score = DimmedNumber.new({ size = 155 }),
		searchBar = SearchBar.new(),
		shiftDelayTimer = 0,
		songCache = songCache,
		titleText = makeLabel("JP", "", 42),
		titleTimer = 0,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	for name, str in pairs(SongPanelLabels) do
		self.labels[name] = makeLabel("Medium", str, 32)
	end

	return setmetatable(self, SongPanel)
end

---@param dt deltaTime
function SongPanel:draw(dt)
	local currentDiff = self.ctx.currentDiff
	local currentSong = self.ctx.currentSong
	local song = songwheel.songs[currentSong]

	self:setProps()
	self:handleTimers(currentSong, currentDiff)

	gfx.Save()
	self:drawPanel(dt, song, currentDiff)
	self:drawHeader(dt)
	gfx.Restore()
end

function SongPanel:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = self.window.paddingX
		self.y = self.window.paddingY

		if self.window.isPortrait then
			self.w = 968
			self.h = 632

			self.button.w = 128
			self.buttonMargin = 125.3
			self.jacketSize = self.w
			self.scissorSize = self.h
			self.score = DimmedNumber.new({ size = 105 })

			self.itemCursor:setProps({
				x = self.x + 40,
				y = self.y + self.scissorSize - 244,
				w = self.button.w,
				h = self.button.h,
				margin = self.buttonMargin,
			})
			self.searchBar:setProps({
				x = self.x,
				y = self.window.paddingY + self.h + 16,
				w = self.w,
			})
		else
			self.w = 768
			self.h = 968

			self.button.w = 128
			self.buttonMargin = 58.6
			self.jacketSize = 768
			self.scissorSize = 597
			self.score = DimmedNumber.new({ size = 155 })

			self.itemCursor:setProps({
				x = self.x + 40,
				y = self.y + self.scissorSize + 38,
				w = self.button.w,
				h = self.button.h,
				margin = self.buttonMargin,
			})
			self.searchBar:setProps({
				x = self.x,
				y = 12,
				w = self.w,
			})
		end

		self.jacketOffset = -(self.scissorSize - self.jacketSize)
		self.maxWidthBottom = self.w - 261
		self.maxWidthTop = self.w - 80

		self.windowResized = self.window.resized
	end
end

---@param currentSong integer
---@param currentDiff integer
function SongPanel:handleTimers(currentSong, currentDiff)
	if (self.currentSong ~= currentSong) or (self.currentDiff ~= currentDiff) then
		self.artistTimer = 0
		self.effectorTimer = 0
		self.jacketShift1 = 0
		self.jacketShift2 = 0
		self.shiftDelayTimer = 0
		self.titleTimer = 0

		self.jacketAlpha:reset()
		self.currentSong = currentSong
		self.currentDiff = currentDiff
	end
end

---@param dt deltaTime
---@param song Song|nil
---@param currentDiff integer
function SongPanel:drawPanel(dt, song, currentDiff)
	local cachedSong = self.songCache:get(song)

	if not cachedSong then
		return
	end

	local cachedDiff = cachedSong.diffs[currentDiff] or cachedSong.diffs[1]
	local diffOffset = 0
	local isPortrait = self.window.isPortrait
	local scissorSize = self.scissorSize
	local x = self.x
	local y = self.y

	self:drawJacket(dt, x, y, cachedDiff, isPortrait)

	if isPortrait then
		if not cachedDiff.clear then
			diffOffset = 105
		end

		drawRect({
			x = x,
			y = y + scissorSize - 284 + diffOffset,
			w = self.w,
			h = self.h - scissorSize + 284 - diffOffset,
			alpha = 0.85,
			color = "Black",
		})
	else
		drawRect({
			x = x,
			y = y + scissorSize,
			w = self.w,
			h = self.h - scissorSize,
			alpha = 0.65,
			color = "Black",
		})
	end

	drawRect({
		x = x + 1.5,
		y = y + 1,
		w = self.w - 3,
		h = scissorSize - 2,
		alpha = 0,
		stroke = { color = "Medium", size = 3 },
	})

	self:drawMetadata(dt, x, y, cachedSong)

	if isPortrait then
		y = y - 161 + diffOffset
	else
		y = y + 86
	end

	self:drawDiffs(dt, x, y, cachedSong.diffs, cachedDiff.diffIndex, diffOffset)
	self:drawDiffInfo(dt, x, y, cachedDiff, isPortrait)
end

---@param dt deltaTime
---@param x number
---@param y number
---@param cachedDiff CachedDiff
---@param isPortrait boolean
function SongPanel:drawJacket(dt, x, y, cachedDiff, isPortrait)
	local jacketOffset = self.jacketOffset
	local jacketSize = self.jacketSize
	local alpha, shift1, shift2 = self:handleJacketShift(dt)

	gfx.Scissor(x, y, jacketSize, self.scissorSize)
	drawRect({
		x = x,
		y = y - (jacketOffset * shift1),
		w = jacketSize,
		h = jacketSize,
		image = cachedDiff.jacket,
	})
	drawRect({
		x = x,
		y = y - (jacketOffset * shift2),
		w = jacketSize,
		h = jacketSize,
		alpha = alpha,
		image = cachedDiff.jacket,
	})
	self.jacketGradient:draw({
		x = x,
		y = y,
		w = jacketSize,
		h = 640,
		alpha = (isPortrait and 0.925) or 0.85,
	})
	gfx.ResetScissor()
end

---@param dt deltaTime
---@return number, number, number
function SongPanel:handleJacketShift(dt)
	self.shiftDelayTimer = min(self.shiftDelayTimer + dt, 1)

	if self.shiftDelayTimer == 1 then
		if self.jacketAlpha.value == 0 then
			self.jacketShift1 = min(self.jacketShift1 + (dt * 0.125), 1)
			self.jacketShift2 = 0
		elseif self.jacketAlpha.value == 1 then
			self.jacketShift1 = 0
			self.jacketShift2 = min(self.jacketShift2 + (dt * 0.125), 1)
		end

		if self.jacketShift1 == 1 then
			self.jacketAlpha:start(dt, 3, 1.5)
		elseif self.jacketShift2 == 1 then
			self.jacketAlpha:stop(dt, 3, 1.5)
		end
	end

	return self.jacketAlpha.value, self.jacketShift1, self.jacketShift2
end

---@param dt deltaTime
---@param x number
---@param y number
---@param cachedSong CachedSong
function SongPanel:drawMetadata(dt, x, y, cachedSong)
	local maxWidth = self.maxWidthTop
	local scale = self.window.scaleFactor

	x = x + 37
	y = y + 29

	if self.titleText.w > maxWidth then
		self.titleTimer = self.titleTimer + dt

		self.titleText:drawScrolling({
			x = x,
			y = y,
			color = "White",
			scale = scale,
			text = cachedSong.title,
			timer = self.titleTimer,
			update = true,
			width = maxWidth,
		})
	else
		self.titleText:draw({
			x = x,
			y = y,
			color = "White",
			text = cachedSong.title,
			update = true,
		})
	end

	x = x + 1

	if self.artistText.w > maxWidth then
		self.artistTimer = self.artistTimer + dt

		self.artistText:drawScrolling({
			x = x,
			y = y + 57,
			color = "Standard",
			scale = scale,
			text = cachedSong.artist,
			timer = self.artistTimer,
			update = true,
			width = maxWidth,
		})
	else
		self.artistText:draw({
			x = x,
			y = y + 57,
			color = "Standard",
			text = cachedSong.artist,
			update = true,
		})
	end

	if cachedSong.illustrator then
		maxWidth = maxWidth - 222

		self.labels.illustratedBy:draw({
			x = x,
			y = y + 94,
			color = "Standard",
		})

		if self.illustratorText.w > maxWidth then
			self.illustratorTimer = self.illustratorTimer + dt

			self.illustratorText:drawScrolling({
				x = x + 223,
				y = y + 100,
				color = "White",
				scale = scale,
				text = cachedSong.illustrator,
				timer = self.illustratorTimer,
				update = true,
				width = maxWidth,
			})
		else
			self.illustratorText:draw({
				x = x + 223,
				y = y + 100,
				color = "White",
				text = cachedSong.illustrator,
				update = true,
			})
		end

		y = y + 40
	end

	self.bpmText:draw({
		x = x,
		y = y + 97,
		color = "White",
		text = cachedSong.bpm,
		update = true
	})
	self.labels.bpm:draw({
		x = x + self.bpmText.w + 13,
		y = y + 94,
		color = "Standard",
	})
end

---@param dt deltaTime
---@param x number
---@param y number
---@param cachedDiffs CachedDiff[]
---@param currentDiff integer
---@param diffOffset number
function SongPanel:drawDiffs(dt, x, y, cachedDiffs, currentDiff, diffOffset)
	local buttonWidth = self.button.w + self.buttonMargin
	local cursorIndex = 1

	x = x + 40
	y = y + 512

	for i = 1, 4 do
		local diff = getDiffInOrder(cachedDiffs, i)
		local isCurrent = currentDiff == (i - 1)

		if isCurrent then
			cursorIndex = i
		end

		self:drawDiff(x + ((i - 1) * buttonWidth), y, diff, isCurrent)
	end

	self.itemCursor:draw(dt, {
		currentItem = cursorIndex,
		totalItems = 4,
		yOffset = diffOffset
	})
end

---@param x number
---@param y number
---@param diff CachedDiff
---@param isCurrent boolean
function SongPanel:drawDiff(x, y, diff, isCurrent)
	y = y + 37

	self.button:draw({
		x = x,
		y = y,
		alpha = 3,
		isActive = isCurrent,
	})

	if diff then
		self.diffText:draw({
			x = x + 20,
			y = y + 7,
			color = "White",
			text = diff.diffName,
			update = true,
		})
		self.levelText:draw({
			x = x + 107,
			y = y + 11,
			align = "RightTop",
			color = "White",
			text = diff.level,
			update = true,
		})
	end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param cachedDiff CachedDiff
---@param isPortrait boolean
function SongPanel:drawDiffInfo(dt, x, y, cachedDiff, isPortrait)
	local labels = self.labels
	local maxWidth = self.maxWidthBottom

	x = x + 39
	y = y + 617

	labels.effectedBy:draw({
		x = x,
		y = y,
		color = "Standard",
	})

	if self.effectorText.w > maxWidth then
		self.effectorTimer = self.effectorTimer + dt

		self.effectorText:drawScrolling({
			x = x + 179,
			y = y + 6,
			color = "White",
			scale = self.window.scaleFactor,
			text = cachedDiff.effector,
			timer = self.effectorTimer,
			width = maxWidth,
			update = true,
		})
	else
		self.effectorText:draw({
			x = x + 179,
			y = y + 6,
			color = "White",
			text = cachedDiff.effector,
			update = true,
		})
	end

	if cachedDiff.clear then
		self:drawScoreInfo(x, y, cachedDiff, labels, isPortrait)
	end
end

---@param x number
---@param y number
---@param cachedDiff CachedDiff
---@param labels table<string, Label>
---@param isPortrait boolean
function SongPanel:drawScoreInfo(x, y, cachedDiff, labels, isPortrait)
	local margin = self.buttonMargin
	local offset = self.button.w + margin

	if isPortrait then
		y = y + 32

		self.score:draw({
			x = x - 5,
			y = y,
			value = cachedDiff.score,
		})

		x = x + 506

		labels.clear:draw({
			x = x,
			y = y + 20,
			color = "Standard"
		})
		self.clearText:draw({
			x = x + offset,
			y = y + 20,
			color = "White",
			text = cachedDiff.clear,
			update = true,
		})
		labels.grade:draw({
			x = x,
			y = y + 72,
			color = "Standard"
		})
		self.gradeText:draw({
			x = x + offset,
			y = y + 72,
			color = "White",
			text = cachedDiff.grade,
			update = true,
		})
	else
		y = y + 52

		labels.clear:draw({
			x = x,
			y = y,
			color = "Standard"
		})
		self.clearText:draw({
			x = x + offset - 2,
			y = y,
			color = "White",
			text = cachedDiff.clear,
			update = true,
		})
		labels.grade:draw({
			x = x + (offset * 2),
			y = y,
			color = "Standard"
		})
		self.gradeText:draw({
			x = x + (offset * 3) - 2,
			y = y,
			color = "White",
			text = cachedDiff.grade,
			update = true,
		})
		self.score:draw({
			x = x - 8,
			y = y + 18,
			value = cachedDiff.score,
		})
	end
end

---@param dt deltaTime
function SongPanel:drawHeader(dt)
	if (songwheel.searchStatus or ""):find("Discovered") then
		local x = self.x
		local y = self.y - 14

		if self.window.isPortrait then
			y = y + self.h + 60
		end

		self.chartLoadingSpinner:draw(dt, x, y)
	else
		self.searchBar:draw(dt, {
			input = songwheel.searchText,
			isActive = songwheel.searchInputActive,
		})
	end
end

return SongPanel
