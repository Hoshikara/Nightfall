local DimmedNumber = require("common/DimmedNumber")
local getLaserColors = require("common/helpers/getLaserColors")

local Gray = { 100, 100, 100 }
local Yellow = { 255, 255, 0 }

local laserColors = getLaserColors()

local floor = math.floor

---@class ResultsTrack
---@field btHolds HitStat[]
---@field score DimmedNumber
---@field duration number
---@field fxHolds HitStat[]
---@field init boolean
---@field mouse Mouse
---@field numScoreData integer
---@field offset number
---@field trackHeight number
---@field w number
---@field h number
local ResultsTrack = {}
ResultsTrack.__index = ResultsTrack

---@param mouse Mouse
---@return ResultsTrack
function ResultsTrack.new(mouse)
	---@type ResultsTrack
	local self = {
		btHolds = {},
		duration = nil,
		fxHolds = {},
		init = true,
		mouse = mouse,
		numScoreData = nil,
		offset = 138,
		score = DimmedNumber.new({ size = 24 }),
		trackHeight = 0,
		w = 123,
		h = 276,
	}

	return setmetatable(self, ResultsTrack)
end

---@param y number
---@param progress number
---@param scoreData? integer[]
---@param trackObjects ResultsTrackObjects
function ResultsTrack:draw(y, progress, scoreData, trackObjects)
	if self.init then
		self.duration = result.duration or 0
		self.trackHeight = self.duration * 0.175
		self.init = false
	end

	local cutoff = progress + 0.05
	local trackHeight = self.trackHeight
	local offset = self.offset

	gfx.Save()
	gfx.Translate(self:getXTranslation(progress), y - 16)
	gfx.Scissor(0, 0, self.w, self.h)
	self:drawTrack()
	self:drawHoldsOrLasers(trackObjects.lasers, cutoff, progress, trackHeight, offset)
	self:drawHoldsOrLasers(trackObjects.holds.fx, cutoff, progress, trackHeight, offset)
	self:drawHoldsOrLasers(trackObjects.holds.bt, cutoff, progress, trackHeight, offset)
	self:drawNotes(trackObjects.notes.fx, cutoff, progress, trackHeight, offset)
	self:drawNotes(trackObjects.notes.bt, cutoff, progress, trackHeight, offset)
	self:drawCursor(offset)
	gfx.ResetScissor()

	if scoreData then
		self:drawScore(progress, scoreData)
	end

	gfx.Restore()
end

function ResultsTrack:drawTrack()
	local h = self.h

	drawRect({
		x = 0,
		y = 0,
		w = 123,
		h = h,
		color = "Black",
		alpha = 0.95,
	})

	for i = 1, 3 do
		drawRect({
			x = 16 + (22 * i) + (1 * (i - 1)),
			y = 0,
			w = 1,
			h = h,
			color = Gray,
			alpha = 0.85,
		})
	end

	drawRect({
		x = 0,
		y = 0,
		w = 16,
		h = h,
		color = laserColors[1],
		alpha = 0.25,
	})
	drawRect({
		x = 107,
		y = 0,
		w = 16,
		h = h,
		color = laserColors[2],
		alpha = 0.25,
	})
end

---@param allObjects ResultsHoldObject[][]
---@param cutoff number
---@param progress number
---@param trackHeight number
---@param offset number
function ResultsTrack:drawHoldsOrLasers(allObjects, cutoff, progress, trackHeight, offset)
	for _, objects in ipairs(allObjects) do
		for __, object in ipairs(objects) do
			for ___, tick in ipairs(object) do
				drawRect({
					x = object.x,
					y = -(trackHeight * tick.timeFrac) + (progress * trackHeight) + offset,
					w = object.w,
					h = tick.h,
					alpha = 0.85,
					color = tick.color,
				})
			end

			if object.startFrac >= cutoff then
				break
			end
		end
	end
end

---@param allNotes ResultsNoteObject[][]
---@param cutoff number
---@param progress number
---@param trackHeight number
---@param offset number
function ResultsTrack:drawNotes(allNotes, cutoff, progress, trackHeight, offset)
	for _, notes in ipairs(allNotes) do
		for __, obj in ipairs(notes) do
			drawRect({
				x = obj.x,
				y = -(trackHeight * obj.timeFrac) + (progress * trackHeight) + offset + obj.offset,
				w = obj.w,
				h = obj.h,
				color = obj.color,
				stroke = {
					alpha = 0.5,
					color = "Black",
					size = 1,
				},
			})

			if obj.timeFrac >= cutoff then
				break
			end
		end
	end
end

---@param offset number
function ResultsTrack:drawCursor(offset)
	drawRect({
		x = 0,
		y = offset - 1,
		w = self.w,
		h = 2,
		alpha = 0.5,
		color = Yellow,
	})
end

---@param progress number
---@param scoreData integer[]
function ResultsTrack:drawScore(progress, scoreData)
	local x = self.w + 6

	if not self.numScoreData then
		self.numScoreData = #scoreData
	end

	if progress >= 0.5 then
		x = -self.score.w - 7
	end

	self.score:draw({
		x = x,
		y = -7,
		value = scoreData[floor(progress * self.numScoreData)] or scoreData[self.numScoreData],
	})
end

function ResultsTrack:getXTranslation(progress)
	local x, _ = self.mouse:getPos()

	if progress < 0.5 then
		return x + 24
	end

	return x - self.w - 24
end

return ResultsTrack
