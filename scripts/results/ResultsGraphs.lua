local RatingColors = require("common/constants/RatingColors")
local ResultsGraphsLabels = require("results/constants/ResultsGraphsLabels")
local Mouse = require("common/Mouse")
local ResultsTrack = require("results/ResultsTrack")
local didPress = require("common/helpers/didPress")

local ExcessiveColor = { 240, 80, 40 }

local HitWindowOrder = {
	"SCritical",
	"Critical",
	"Near",
}

local ObjectOrder = {
	"button",
	"hold",
	"laser",
	"total",
	"best",
}

---@type string[]
local ObjectRatingOrder = {
	"sCritical",
	"critical",
	"near",
	"error",
}

local RatingOrder = {
	"errorEarly",
	"nearEarly",
	"criticalEarly",
	"sCritical",
	"criticalLate",
	"nearLate",
	"errorLate",
}

local max = math.max
local min = math.min
local floor = math.floor

local suggestSongOffset = getSetting("suggestSongOffset", true)

---@class ResultsGraphs: ResultsGraphsBase
local ResultsGraphs = {}
ResultsGraphs.__index = ResultsGraphs

---@param ctx ResultsContext
---@param panel ResultsPanel|ResultsPanelBase
---@param window Window
---@return ResultsGraphs
function ResultsGraphs.new(ctx, panel, window)
	---@class ResultsGraphsBase
	---@field labels table<string, Label>
	local self = {
		button = makeLabel("SemiBold", "", 20),
		ctx = ctx,
		data = nil,
		didPressBTA = false,
		disclaimer = makeLabel("SemiBold", "HOLD AND LASER LENGTHS MAY BE INACCURATE", 18),
		histogramMode = 0,
		histogramNormalized = false,
		hitStatScale = nil,
		isSimpleView = nil,
		mouse = Mouse.new(window),
		labels = {},
		panel = panel,
		showDisclaimer = false,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
	}

	self.track = ResultsTrack.new(self.mouse)

	for name, str in pairs(ResultsGraphsLabels) do
		self.labels[name] = makeLabel("SemiBold", str, 20)
	end

	---@diagnostic disable-next-line
	return setmetatable(self, ResultsGraphs)
end

function ResultsGraphs:draw()
	if not self.ctx.graphData then
		return
	end

	if not self.data then
		self.data = self.ctx.graphData
	end

	self:setProps()
	self:handleInput()
	self.mouse:update()

	local data = self.data
	local labels = self.labels
	local x = self.x
	local y = self.y

	gfx.Save()
	self:drawObjectRatings(data, labels, x, y)

	if self.isSimpleView then
		self:drawSimpleView(data, labels, x, y)
	else
		self:drawDetailedView(data, x, y)
	end

	self:drawTimings(data, x, y)
	gfx.Restore()
end

function ResultsGraphs:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = self.panel.x + 39
		self.y = self.panel.y + 459
		self.w = self.panel.w - 80

		self.histogramNormalized = false
		self.windowResized = self.window.resized
	end
end

function ResultsGraphs:handleInput()
	if self.isSimpleView == nil then
		self.isSimpleView = getSetting("showSimpleGraph", false)
	end

	if didPress("BTA") and (not self.didPressBTA) then
		self.isSimpleView = not self.isSimpleView

		game.SetSkinSetting("showSimpleGraph", (self.isSimpleView and 1) or 0)
	end

	self.didPressBTA = didPress("BTA")
end

---@param data ResultsGraphData
---@param labels table<string, Label>
---@param x number
---@param y number
function ResultsGraphs:drawObjectRatings(data, labels, x, y)
	local objectRatings = data.objectRatings
	local colors = objectRatings.colors

	for i, rating in ipairs(ObjectRatingOrder) do
		local tempY = y - 3 + (i * 32)

		labels[rating]:draw({
			x = x,
			y = tempY,
			color = colors[rating],
		})

		if i > 1 then
			drawRect({
				x = x,
				y = tempY - 4,
				w = 475,
				h = 2,
				alpha = 0.6,
				color = "Medium",
			})
		end
	end

	for i, object in ipairs(ObjectOrder) do
		local ratings = objectRatings[object]
		local tempX = x + 32 + (i * 78)

		labels[object]:draw({
			x = tempX,
			y = y,
		})

		for j, rating in ipairs(ObjectRatingOrder) do
			ratings[rating]:draw({
				x = tempX,
				y = y - 1 + (j * 32),
			})
		end
	end
end

---@param data ResultsGraphData
---@param labels table<string, Label>
---@param x number
---@param y number
function ResultsGraphs:drawSimpleView(data, labels, x, y)
	y = y + 178

	self:drawRatings(data, labels, x, y)
	self:drawGaugeBar(data, x, y)
end

---@param data ResultsGraphData
---@param x number
---@param y number
function ResultsGraphs:drawDetailedView(data, x, y)
	local w = self.w
	local h = 244

	y = y + 178

	self:drawBox(data, x, y, w, h)
	self:drawLeftGraphs(data, x, y, w * 0.75, h)
	self:drawRightGraph(data, x + (w * 0.75), y, w * 0.25, h)
end

---@param data ResultsGraphData
---@param labels table<string, Label>
---@param x number
---@param y number
function ResultsGraphs:drawRatings(data, labels, x, y)
	local ratings = data.ratings
	local totalRatings = data.totalRatings
	local w = 700

	for i, rating in ipairs(RatingOrder) do
		---@type ResultsRating
		local currentRating = ratings[rating]
		local tempY = y + ((i - 1) * 25)

		labels[rating]:draw({
			x = x,
			y = tempY,
			color = currentRating.color,
		})
		currentRating.number:draw({ x = x + 110, y = tempY + 2 })
		drawRect({
			x = x + 189,
			y = tempY + 7,
			w = w,
			h = 13,
			alpha = 0.4,
			color = "Medium",
		})
		drawRect({
			x = x + 189,
			y = tempY + 7,
			w = w * (currentRating.value / totalRatings),
			h = 13,
			color = "Standard",
		})
	end
end

---@param data ResultsGraphData
---@param x number
---@param y number
function ResultsGraphs:drawGaugeBar(data, x, y)
	local gauge = data.gauge
	local value = gauge.endingValue
	local w = self.w

	y = y + 212

	drawRect({
		x = x + 1,
		y = y,
		w = w * value,
		h = 17,
		color = ((value >= gauge.threshold) and gauge.colorPass) or gauge.colorFail,
	})
	drawRect({
		x = x + 2,
		y = y + 1,
		w = w - 2,
		h = 15,
		alpha = 0,
		stroke = { color = "White", size = 2 },
	})
	drawRect({
		x = x + (w * gauge.threshold),
		y = y + 1,
		w = 2,
		h = 15,
		color = "White",
	})
	gauge.label:draw({
		x = x,
		y = y + 19,
		color = "White",
	})
	gauge.unlabeledValue:draw({
		x = x + w + 1,
		y = y + 21,
		align = "RightTop",
		color = "White",
	})
end

---@param data ResultsGraphData
---@param x number
---@param y number
function ResultsGraphs:drawTimings(data, x, y)
	local timings = data.timings

	y = y + 449

	if self.showDisclaimer then
		self.disclaimer:draw({
			x = x,
			y = y + 1,
			color = "Negative",
		})
	else
		if suggestSongOffset and timings.suggestion then
			timings.suggestion.text:draw({ x = x, y = y })
			timings.suggestion.value:draw({
				x = x + timings.suggestion.text.w + 15,
				y = y + 2,
				color = "White",
			})
		end
	end

	x = x + 890

	timings.stdDev.text:draw({
		x = x - 78,
		y = y,
		align = "RightTop",
	})
	timings.stdDev.value:draw({
		x = x,
		y = y + 2,
		align = "RightTop",
		color = "White",
	})

	x = x - 183

	timings.absMean.text:draw({
		x = x - 78,
		y = y,
		align = "RightTop",
	})
	timings.absMean.value:draw({
		x = x,
		y = y + 2,
		align = "RightTop",
		color = "White",
	})

	x = x - 202

	timings.mean.text:draw({
		x = x - 78,
		y = y,
		align = "RightTop",
	})
	timings.mean.value:draw({
		x = x,
		y = y + 2,
		align = "RightTop",
		color = "White",
	})
end

---@param data ResultsGraphData
---@param x number
---@param y number
---@param w number
---@param h number
function ResultsGraphs:drawBox(data, x, y, w, h)
	local hitWindows = data.hitWindows

	if not self.hitStatScale then
		self.hitStatScale = (h / 2) / (hitWindows.Near.value * 1.10)
	end

	drawRect({
		x = x,
		y = y,
		w = w,
		h = h,
		alpha = 0.8,
		color = "Dark",
	})

	y = y + (h / 2)

	drawRect({
		x = x,
		y = y - 0.5,
		w = w,
		h = 1,
		alpha = 0.5,
		color = "White",
	})

	for _, hitWindow in ipairs(HitWindowOrder) do
		---@type ResultsHitWindow
		local currentHitWindow = hitWindows[hitWindow]
		local value = currentHitWindow.value * self.hitStatScale

		drawRect({
			x = x,
			y = y - 0.5 - value,
			w = w,
			h = 1,
			alpha = 0.3,
			color = RatingColors[hitWindow] or RatingColors.Early,
		})
		currentHitWindow.negValue:draw({
			x = x + w - 6,
			y = y - value - 12,
			align = "RightTop",
			color = RatingColors[hitWindow] or RatingColors.Early,
		})
		drawRect({
			x = x,
			y = y - 0.5 + value,
			w = w,
			h = 1,
			alpha = 0.3,
			color = RatingColors[hitWindow] or RatingColors.Late,
		})
		currentHitWindow.posValue:draw({
			x = x + w - 6,
			y = y + value - 12,
			align = "RightTop",
			color = RatingColors[hitWindow] or RatingColors.Late,
		})
	end
end

---@param data ResultsGraphData
---@param x number
---@param y number
---@param w number
---@param h number
function ResultsGraphs:drawLeftGraphs(data, x, y, w, h)
	local currentTime = data.duration.currentValue
	local focusPoint = 0
	local scale = 1
	local mouseX, _ = self.mouse:getPos()
	local isHovering = self.mouse:clipped(x, y, w, h)

	w = w - 4

	if isHovering then
		focusPoint = mouseX - x
		currentTime = data.duration.currentValue * (focusPoint / w)

		gfx.BeginPath()
		setStroke({
			alpha = 0.5,
			color = "White",
			size = 1,
		})
		gfx.MoveTo(mouseX - 0.5, y)
		gfx.LineTo(mouseX - 0.5, y + h)
		gfx.Stroke()
	else
	end

	if data.hitStats then
		self:drawHitStats(data.hitStats, x, y, w, h, focusPoint, scale)
	end

	self:drawGaugeGraph(data.gauge, x, y, w, h, mouseX, focusPoint / w, isHovering)

	if isHovering and data.trackObjects then
		self.showDisclaimer = true
		self.track:draw(y, focusPoint / w, data.scoreData, data.trackObjects)
	else
		self.showDisclaimer = false
	end

	data.duration.value:draw({
		x = x + w + 11,
		y = y + h - 25,
		color = "White",
		text = ("%02d:%02d"):format(currentTime // 60000, (currentTime // 1000) % 60),
		update = true,
	})
end

---@param data ResultsGraphData
---@param x number
---@param y number
---@param w number
---@param h number
function ResultsGraphs:drawRightGraph(data, x, y, w, h)
	local histogram = data.histogram
	local scale = self.hitStatScale
	local maxHeight = floor(h / 2 / scale)
	local mode = self.histogramMode

	if not self.histogramNormalized then
		mode = self:normalizeHistogram(histogram, maxHeight)

		self.histogramNormalized = true
	end

	gfx.BeginPath()
	setStroke({ color = "Standard", size = 1.5 })
	gfx.MoveTo(x, y)

	for i = -maxHeight, maxHeight do
		local count = histogram[i - 1] + (histogram[i] * 2) + histogram[i + 1]

		gfx.LineTo(x + (w * (count / mode)), y + (h / 2) + (i * scale))
	end

	gfx.LineTo(x, y + h)
	gfx.Stroke()
end

---@param histogram number[]
---@param maxHeight number
---@return number
function ResultsGraphs:normalizeHistogram(histogram, maxHeight)
	local mode = 0

	for i = -maxHeight - 1, maxHeight + 1 do
		if not histogram[i] then
			histogram[i] = 0
		end
	end

	for i = -maxHeight, maxHeight do
		local count = histogram[i - 1] + (histogram[i] * 2) + histogram[i + 1]

		if count > mode then
			mode = count
		end
	end

	self.histogramMode = mode

	return mode
end

---@param hitStats ResultsHitStat[]
---@param x number
---@param y number
---@param w number
---@param h number
---@param focusPoint number
---@param scale number
function ResultsGraphs:drawHitStats(hitStats, x, y, w, h, focusPoint, scale)
	focusPoint = focusPoint or 0
	scale = scale or 1

	local hitStatScale = self.hitStatScale

	for _, hitStat in ipairs(hitStats) do
		local statX = (((hitStat.timeFrac * w) - focusPoint) * scale) + focusPoint

		if statX >= 0 then
			if statX > w then
				break
			end

			local statY = (h / 2) + (hitStat.delta * hitStatScale) - 1

			if statY < 0 then
				statY = 6
			elseif statY > h then
				statY = h - 12
			end

			gfx.BeginPath()
			setColor(hitStat.color, 0.8)
			gfx.Circle(x + statX - 2, y + statY + 1, 4)
			gfx.Fill()
		end
	end
end

---@param gauge ResultsGauge
---@param x number
---@param y number
---@param w number
---@param h number
---@param mouseX number
---@param isHovering boolean
function ResultsGraphs:drawGaugeGraph(gauge, x, y, w, h, mouseX, progress, isHovering)
	local samples = gauge.samples
	local sampleCount = #samples

	if sampleCount > 0 then
		self:drawGaugeLine(gauge, samples, sampleCount, x, y, w, h)

		if isHovering then
			local i = floor(1 + (sampleCount / w) * ((mouseX - x)))

			i = max(1, min(sampleCount, i))

			local gaugeY = h - (h * samples[i])

			gfx.BeginPath()
			setColor("White", 0.5)
			gfx.Circle(mouseX, y + gaugeY, 4)
			gfx.Fill()

			gauge.currentValue:draw({
				x = mouseX + (((progress < 0.5) and -(gauge.currentValue.w + 9)) or 9),
				y = y + gaugeY - 12,
				color = "White",
				text = ("%.1f%%"):format(samples[i] * 100),
				update = true,
			})
		end
	end

	gauge.labeledValue:draw({
		x = x + w + 7,
		y = y + 4,
		color = "White",
		size = 18,
		update = true,
	})
end

---@param gauge ResultsGauge
---@param samples number[]
---@param sampleCount integer
---@param x number
---@param y number
---@param w number
---@param h number
function ResultsGraphs:drawGaugeLine(gauge, samples, sampleCount, x, y, w, h)
	local alpha = 255
	local scissorY = y
	local scissorH = h

	y = y + 2
	h = h - 4

	local leftIndex = floor(sampleCount / w)

	leftIndex = max(1, min(sampleCount, leftIndex))

	gfx.BeginPath()
	gfx.StrokeWidth(2)
	gfx.MoveTo(x, y + h - (h * samples[leftIndex]))

	for i = leftIndex + 1, sampleCount do
		local sampleX = (i * w) / sampleCount

		if sampleX > w then
			break
		end

		gfx.LineTo(x + sampleX, y + h - (h * samples[i]) + 2)
	end

	gfx.StrokeColor(0, 0, 0, alpha)
	gfx.Stroke()

	gfx.BeginPath()
	gfx.StrokeWidth(2)
	gfx.MoveTo(x, y + h - (h * samples[leftIndex]))

	for i = leftIndex + 1, sampleCount do
		local sampleX = (i * w) / sampleCount

		if sampleX > w then
			break
		end

		gfx.LineTo(x + sampleX, y + h - (h * samples[i]))
	end

	if gauge.type >= 1 then
		local color = gauge.colorPass

		gfx.StrokeColor(color[1], color[2], color[3], alpha)
		gfx.Stroke()
	else
		local colorPass = gauge.colorPass
		local colorFail = gauge.colorFail

		gfx.Scissor(x, scissorY + (scissorH * 0.3), w, (scissorH * 0.7))
		gfx.StrokeColor(colorFail[1], colorFail[2], colorFail[3], alpha)
		gfx.Stroke()
		gfx.ResetScissor()

		gfx.Scissor(x, scissorY, w, (scissorH * 0.3))
		gfx.StrokeColor(colorPass[1], colorPass[2], colorPass[3], alpha)
		gfx.Stroke()
		gfx.ResetScissor()

		if gauge.swapIndex then
			local region = w * (gauge.swapIndex / 256)

			gfx.Scissor(x, scissorY, region, scissorH)
			gfx.StrokeColor(ExcessiveColor[1], ExcessiveColor[2], ExcessiveColor[3], alpha)
			gfx.Stroke()
			gfx.ResetScissor()
		end
	end
end

return ResultsGraphs
