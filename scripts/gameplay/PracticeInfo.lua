local RatingColors = require("common/constants/RatingColors")
local ControlLabel = require("common/ControlLabel")
local DimmedNumber = require("common/DimmedNumber")

local showControls = getSetting("showPracticeControls", true)

local RatingOrder = {
	"errorEarly",
	"nearEarly",
	"criticalEarly",
	"sCritical",
	"criticalLate",
	"nearLate",
	"errorLate",
}

local RatingColorOrder = {
	"Error",
	"Early",
	"Critical",
	"SCritical",
	"Critical",
	"Late",
	"Error",
}

local RatingLabelOrder = {
	"ER",
	"NR",
	"CR",
	"SC",
	"CR",
	"NR",
	"ER",
}

---@class PracticeInfo: PracticeInfoBase
local PracticeInfo = {}
PracticeInfo.__index = PracticeInfo

---@param ctx GameplayContext
---@param window Window
---@return PracticeInfo
function PracticeInfo.new(ctx, window)
	---@class PracticeInfoBase
	local self = {
		ctx = ctx,
		buttonRatings = {
			errorEarly = 0,
			nearEarly = 0,
			criticalEarly = 0,
			sCritical = 0,
			criticalLate = 0,
			nearLate = 0,
			errorLate = 0,
		},
		isPracticing = false,
		label = makeLabel("SemiBold", "", 20),
		labels = {},
		mission = makeLabel("Medium", "", 25),
		numbers = {},
		openControl = ControlLabel.new("BACK", "OPEN SETTINGS WINDOW"),
		playCount = 0,
		playPauseControl = ControlLabel.new("FX-L / FX-R", "PLAY / PAUSE"),
		passRate = makeLabel("Number", "0 / 0  (0.0%)", 22, "White"),
		score = DimmedNumber.new({ size = 46 }),
		scrubFastControl = ControlLabel.new("KNOB-R", "SCRUB THROUGH SONG (FAST)"),
		scrubSlowControl = ControlLabel.new("KNOB-L", "SCRUB THROUGH SONG (SLOW)"),
		totalButtons = 0,
		window = window,
	}

	for i, _ in ipairs(RatingOrder) do
		self.labels[i] = makeLabel("SemiBold", RatingLabelOrder[i], 20)
		self.numbers[i] = DimmedNumber.new({
			color = "White",
			digits = 4,
			size = 18,
		})
	end

	---@diagnostic disable-next-line
	return setmetatable(self, PracticeInfo)
end

function PracticeInfo:draw()
	if not self.isPracticing then
		return
	end

	gfx.Save()

	if self.window.isPortrait then
		gfx.Translate(23, 592)
	else
		gfx.Translate(38, 300)
	end

	self:drawHeading()
	self:drawRatings()

	gfx.Restore()
end

function PracticeInfo:drawControls()
	if not showControls then
		return
	end

	local x = 41
	local y = 306

	if self.window.isPortrait then
		x = 25
		y = 31
	end

	self.openControl:draw(x, y)
	self.scrubSlowControl:draw(x, y + 31)
	self.scrubFastControl:draw(x, y + 62)
	self.playPauseControl:draw(x, y + 93)
end

function PracticeInfo:drawHeading()
	local x = 0
	local y = 0

	self.label:draw({
		x = x,
		y = x,
		color = "Standard",
		text = "GOAL",
		update = true,
	})
	self.mission:draw({
		x = x - 1,
		y = y + 23,
		color = "White",
		maxWidth = 300,
	})

	y = y + 65

	self.label:draw({
		x = x,
		y = y,
		color = "Standard",
		text = "PASS RATE",
		update = true,
	})
	self.passRate:draw({
		x = x,
		y = y + 26,
	})

	y = y + 65

	self.label:draw({
		x = x,
		y = y,
		color = "Standard",
		text = "SCORE",
		update = true,
	})
	self.score:draw({
		x = x - 2,
		y = y + 18,
	})
end

function PracticeInfo:drawRatings()
	local buttonRatings = self.buttonRatings
	local numbers = self.numbers
	local labels = self.labels
	local total = self.totalButtons
	local x = 0
	local y = 211
	local w = 116

	for i, name in ipairs(RatingOrder) do
		labels[i]:draw({
			x = x,
			y = y,
			color = RatingColors[RatingColorOrder[i]],
		})
		numbers[i]:draw({
			x = x + 32,
			y = y + 2,
			value = buttonRatings[name],
		})
		drawRect({
			x = x + 87,
			y = y + 7,
			w = w,
			h = 13,
			color = "Medium",
		})
		drawRect({
			x = x + 87,
			y = y + 7,
			w = w * (buttonRatings[name] / total),
			h = 13,
			color = "Standard",
		})

		y = y + 25
	end
end

---@param playCount integer
---@param passCount integer
---@param practiceScoreInfo PracticeScoreInfo
function PracticeInfo:set(playCount, passCount, practiceScoreInfo)
	self.playCount = playCount

	if practiceScoreInfo then
		self.passRate:update(("%d / %d  (%.1f%%)"):format(
			passCount,
			playCount,
			(passCount / playCount) * 100
		))
		self.score:updateNumbers(practiceScoreInfo.score)
		self:setButtonRatings(practiceScoreInfo)
	else
		self.isPracticing = false
	end
end

---@param mission string
function PracticeInfo:start(mission)
	self.isPracticing = true
	self.mission:update(mission)
	self.ctx:resetButtonRatings()
end

---@param info PracticeScoreInfo
function PracticeInfo:setButtonRatings(info)
	local buttonRatings = self.buttonRatings

	for rating, value in pairs(self.ctx.buttonRatings) do
		buttonRatings[rating] = value
	end

	local holdAndLaserTicks = info.perfects
		- buttonRatings.sCritical
		- buttonRatings.criticalEarly
		- buttonRatings.criticalLate
	local nonButtonMisses = info.misses
		- buttonRatings.errorEarly
		- buttonRatings.errorLate

	buttonRatings.sCritical = buttonRatings.sCritical + holdAndLaserTicks
	buttonRatings.errorLate = buttonRatings.errorLate + nonButtonMisses

	self.totalButtons = 0

	for _, name in ipairs(RatingOrder) do
		self.totalButtons = self.totalButtons + buttonRatings[name]
	end

	self.ctx:resetButtonRatings()
end

return PracticeInfo

---@class PracticeScoreInfo
---@field goods integer
---@field meanHitDelta integer
---@field meanHitDeltaAbs integer
---@field medianHitDelta integer
---@field medianHitDeltaAbs integer
---@field misses integer
---@field perfects integer
---@field score integer
