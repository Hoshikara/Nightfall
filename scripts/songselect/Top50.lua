local ControlLabel = require("common/ControlLabel")
local DimmedNumber = require("common/DimmedNumber")
local getDateTemplate = require("common/helpers/getDateTemplate")

local floor = math.floor
local max = math.max

---@class Top50: Top50Base
local Top50 = {}
Top50.__index = Top50

---@param ctx SongSelectContext
---@param window Window
---@return Top50
function Top50.new(ctx, window)
	---@class Top50Base
	local self = {
		ctx = ctx,
		clear = makeLabel("SemiBold", "", 20, "White"),
		closeControl = ControlLabel.new("BT-A", "CLOSE"),
		colors = {},
		date = makeLabel(
			"Number",
			---@diagnostic disable-next-line
			os.date(getDateTemplate(), os.time()),
			22,
			"White"
		),
		diff = makeLabel("SemiBold", "", 20, "White"),
		heading = makeLabel("Regular", "", 48, "White"),
		level = makeLabel("Number", "", 18, "White"),
		marginX = 12,
		marginY = 0,
		numCols = 0,
		numRows = 0,
		player = getSetting("playerName", "GUEST"),
		score = DimmedNumber.new({ size = 18 }),
		title = makeLabel("JP", "", 16, "White"),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, Top50)
end

function Top50:draw()
	self:setProps()
	gfx.Save()
	self.heading:draw({
		x = self.x - 4,
		y = self.y - 16,
		text = ("%s'S TOP 50  -  %.3f VF"):format(
			self.player,
			self.ctx.volforce * 0.001
		),
		update = true,
	})
	self.date:draw({
		x = self.window.w - self.window.paddingX,
		y = self.y + 10,
		align = "RightTop",
	})
	self:drawEntries(self.x, self.y + 64)
	self.closeControl:draw(self.x, self.window.footerY)
	gfx.Restore()
end

function Top50:setProps()
	if self.windowResized ~= self.window.resized then
		if self.window.isPortrait then
			self.numCols = 3
			self.numRows = 17
			self.marginY = 22
			self.w = 314
			self.h = 79
		else
			self.numCols = 5
			self.numRows = 10
			self.marginY = 12
			self.w = 342
			self.h = 79
		end

		self:makeColors(self.numRows)

		self.x = self.window.paddingX
		self.y = self.window.paddingY
		self.windowResized = self.window.resized
	end
end

---@param numRows integer
function Top50:makeColors(numRows)
	local colors = {}
	local c1 = Colors.Black
	local c2 = Colors.Medium
	local increments = {
		(c2[1] - c1[1]) / numRows,
		(c2[2] - c1[2]) / numRows,
		(c2[3] - c1[3]) / numRows,
	}

	for i = 1, numRows do
		colors[i] = {
			max(floor(c2[1] - (increments[1] * i)), 0),
			max(floor(c2[2] - (increments[2] * i)), 0),
			max(floor(c2[3] - (increments[3] * i)), 0),
		}
	end

	self.colors = colors
end

---@param x1 number
---@param y1 number
function Top50:drawEntries(x1, y1)
	local clear = self.clear
	local colors = self.colors
	local colorIndex = 1
	local diff = self.diff
	local level = self.level
	local marginX = self.marginX
	local marginY = self.marginY
	local title = self.title
	local score = self.score
	local x2 = x1
	local y2 = y1
	local w = self.w
	local h = self.h

	for i, entry in ipairs(self.ctx.topPlaysAsArray) do
		self:drawEntry(
			x2,
			y2,
			w,
			h,
			title,
			diff,
			level,
			score,
			clear,
			colors[colorIndex],
			entry
		)

		if i % self.numCols == 0 then
			x2 = x1
			y2 = y2 + h + marginY
			colorIndex = colorIndex + 1
		else
			x2 = x2 + w + marginX
		end
	end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param title Label
---@param diff Label
---@param level Label
---@param score DimmedNumber
---@param clear Label
---@param color Color
---@param entry TopPlay
function Top50:drawEntry(
	x,
	y,
	w,
	h,
	title,
	diff,
	level,
	score,
	clear,
	color,
	entry
)
	local maxWidth = (self.window.isPortrait and 218) or 246

	drawRect({
		x = x,
		y = y,
		w = w,
		h = h,
		alpha = 0.65,
		color = color,
	})

	drawRect({
		x = x + 1,
		y = y + 1,
		w = h - 2,
		h = h - 2,
		image = entry.jacket,
		stroke = { color = "Medium", size = 2 },
	})

	x = x + h + 8
	y = y + 6

	title:update(entry.title)

	if title.w > maxWidth then
		title:drawCutoff({
			x = x,
			y = y,
			scale = self.window.scaleFactor,
			width = maxWidth,
		})
	else
		title:draw({ x = x, y = y })
	end

	y = y + 20

	diff:draw({
		x = x,
		y = y,
		text = entry.diffName,
		update = true,
	})
	level:draw({
		x = x + diff.w + 5,
		y = y + 2,
		text = ("%02d"):format(entry.level),
		update = true,
	})

	y = y + 25

	score:draw({
		x = x,
		y = y,
		value = entry.score,
	})
	clear:draw({
		x = x + score.w + 6,
		y = y - 2,
		text = ("[ %s ]"):format(entry.clear),
		update = true,
	})
end

return Top50
