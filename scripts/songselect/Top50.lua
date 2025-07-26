local ControlLabel = require("common/ControlLabel")
local DimmedNumber = require("common/DimmedNumber")
local getDateTemplate = require("common/helpers/getDateTemplate")

local floor = math.floor
local max = math.max

local CLEAR_NAMES = {
	PLAYED = "FAIL",
	NORMAL = "EFF",
	HARD = "EXC",
	UC = "UC",
	PUC = "PUC",
}

local CLEAR_TO_COLOR = {
	PLAYED = { 220, 40, 40 },
	NORMAL = { 20, 160, 240 },
	HARD = { 240, 120, 40 },
	UC = { 220, 80, 240 },
	PUC = { 220, 180, 20 },
}

local DIFF_TO_COLOR = {
	NOV = { 120, 60, 240 },
	ADV = { 220, 180, 0 },
	EXH = { 220, 40, 40 },
	INF = { 220, 40, 200 },
	GRV = { 220, 120, 20 },
	HVN = { 0, 150, 200 },
	VVD = { 220, 40, 120 },
	XCD = { 40, 100, 240 },
	MXM = { 110, 120, 130 },
	ULT = { 220, 200, 20 },
}

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
		clear = makeLabel("SemiBold", "", 14, "White"),
		closeControl = ControlLabel.new("BT-A", "CLOSE"),
		colors = {},
		date = makeLabel(
			"Number",
			---@diagnostic disable-next-line
			os.date(getDateTemplate(), os.time()),
			22,
			"White"
		),
		diff = makeLabel("SemiBold", "", 14, "White"),
		entryNumLabel = makeLabel("Number", "", 22, "White"),
		heading = makeLabel("Regular", "", 48, "White"),
		level = makeLabel("Number", "", 14, "White"),
		marginX = 12,
		marginY = 0,
		numCols = 0,
		numRows = 0,
		player = getSetting("playerName", "GUEST"),
		score = DimmedNumber.new({ size = 22 }),
		title = makeLabel("JP", "", 16, "White"),
		volforce = makeLabel("Number", "", 14, "White"),
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
			self.volforce,
			i,
			self.entryNumLabel,
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
---@param clearLabel Label
---@param volforceLabel Label
---@param entryNum number
---@param entryNumLabel Label
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
  clearLabel,
  volforceLabel,
  entryNum,
  entryNumLabel,
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
		x = x + 0.5,
		y = y + 0.5,
		w = h - 1,
		h = h - 1,
		image = entry.jacket,
		stroke = { color = "White", size = 1 },
	})

	x = x + h + 8
	y = y + 5

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

	y = y + 25

	drawRect({
		x = x + 1,
		y = y,
		w = 59,
		h = 17,
		color = DIFF_TO_COLOR[entry.diffName],
		radius = 2,
	})
	diff:draw({
		x = x + 6,
		y = y - 1,
		shadowAlpha = 0,
		text = entry.diffName,
		update = true,
	})
	level:draw({
		x = x + 37,
		y = y - 1,
		text = ("%02d"):format(entry.level),
		shadowAlpha = 0,
		update = true,
	})

	drawRect({
		x = x + 68,
		y = y,
		w = 40,
		h = 17,
		color = CLEAR_TO_COLOR[entry.clear],
		radius = 2,
	})
	clearLabel:draw({
		x = x + 68 + 20,
		y = y - 1,
		align = "CenterTop",
		shadowAlpha = 0,
		text = CLEAR_NAMES[entry.clear],
		update = true,
	})

	drawRect({
		x = x + 114,
		y = y,
		w = 49,
		h = 17,
		color = { 72, 76, 80 },
		radius = 2,
	})
	volforceLabel:draw({
		x = x + 114 + 5,
		y = y - 1,
		shadowAlpha = 0,
		text = ("%.3f"):format(entry.volforce / 1000),
		update = true,
	})

	score:draw({
		x = x,
		y = y + 19,
		value = entry.score,
	})

	entryNumLabel:draw({
		x = x + maxWidth,
		y = y + 19,
		align = "RightTop",
		alpha = 0.25,
		color = "Standard",
		shadowAlpha = 0,
		text = ("%02d"):format(entryNum),
		update = true,
	})

end

return Top50
