local RatingColors = require("common/constants/RatingColors")
local getLaserColors = require("common/helpers/getLaserColors")

local distinguishCritRating = getSetting("distinguishCritRating", false)

local abs = math.abs

---@param color Color
---@return Color
local function darken(color)
	return {
		math.floor(color[1] * 0.5),
		math.floor(color[2] * 0.5),
		math.floor(color[3] * 0.5),
	}
end

local BTNoteProperties = {
	color = { 225, 230, 235 },
	offset = 0,
	x = { 18, 41, 64, 87 },
	w = 18,
	h = -5,
}
local BTHoldProperties = {
	color = { 245, 250, 255 },
	x = { 20, 43, 66, 89 },
	w = 14,
}

local FXNoteProperties = {
	color = { 225, 155, 0 },
	offset = 1,
	x = { 17, 63 },
	w = 43,
	h = -7,
}
local FXHoldProperties = {
	color = { 225, 155, 0 },
	x = { 16, 61.5 },
	w = 45.5,
}

local LaserProperties = {
	color = getLaserColors(),
	x = { 1, 108 },
	w = 14,
}

local EarlyColor = distinguishCritRating and darken(RatingColors.Early) or RatingColors.Early
local LateColor = distinguishCritRating and darken(RatingColors.Late) or RatingColors.Late

---@param rating integer
---@param delta? integer
---@param sCriticalWindow? integer
---@return Color|nil
local function getObjectColor(rating, delta, sCriticalWindow)
	if delta and rating == 2 then
		if abs(delta) <= sCriticalWindow then
			return
		end

		if distinguishCritRating then
			if delta < 0 then
				return RatingColors.Early
			end

			return RatingColors.Late
		end

		return
	elseif rating == 1 then
		if delta < 0 then
			return EarlyColor
		end

		return LateColor
	elseif rating == 0 then
		return RatingColors.Error
	end
end

---@param holdsOrLasers HitStat[]
---@param isLasers? boolean
---@return HitStat[][]|HitStat[][], ...
local function separateObjects(holdsOrLasers, isLasers)
	if isLasers then
		local lasers = { {}, {} }

		for _, obj in ipairs(holdsOrLasers) do
			lasers[obj.lane - 5] = lasers[obj.lane - 5] or {}
			lasers[obj.lane - 5][#lasers[obj.lane - 5] + 1] = obj
		end

		return lasers
	end

	local bt = { {}, {}, {}, {} }
	local fx = { {}, {} }

	for _, obj in ipairs(holdsOrLasers) do
		local lane = obj.lane + 1

		if lane < 5 then
			bt[lane][#bt[lane] + 1] = obj
		else
			fx[lane - 4][#fx[lane - 4] + 1] = obj
		end
	end

	return bt, fx
end

---@param allObjects HitStat[][]
---@return number
local function getSmallestDiff(allObjects)
	local time = 10000000

	for _, objects in ipairs(allObjects) do
		for i, obj in ipairs(objects) do
			if objects[i + 1] then
				local diff = objects[i + 1].time - obj.time

				if diff < time then
					time = diff
				end
			end
		end
	end

	return time
end

---@param allBTHoldsOrLasers HitStat[][]
---@param allFXHolds HitStat[][]
---@return number
local function getTickTime(allBTHoldsOrLasers, allFXHolds)
	return math.min(getSmallestDiff(allBTHoldsOrLasers), getSmallestDiff(allFXHolds))
end

---@param holdsOrLasers HitStat[]
---@param tickHeight number
---@param tickTime number
---@param tickFrac number
---@param x number
---@param w number
---@param color Color
---@return ResultsHoldObject[]
local function makeHoldOrLaserObjects(holdsOrLasers, tickHeight, tickTime, tickFrac, x, w, color)
	local objects = {}
	local tickIndex = 1
	local i = 1

	for j, obj in ipairs(holdsOrLasers) do
		local nextObj = holdsOrLasers[j + 1]

		if not objects[i] then
			objects[i] = {
				[1] = {
					color = getObjectColor(obj.rating) or color,
					timeFrac = obj.timeFrac - tickFrac,
					h = tickHeight * 2,
				},
				startFrac = obj.timeFrac - tickFrac,
				x = x,
				w = w,
			}

			if (not nextObj) or ((obj.time + tickTime) < nextObj.time) then
				i = i + 1
			end
		else
			tickIndex = tickIndex + 1

			objects[i][tickIndex] = {
				color = getObjectColor(obj.rating) or color,
				timeFrac = obj.timeFrac,
			}

			if nextObj and ((obj.time + tickTime) > nextObj.time) then
				objects[i][tickIndex].h = tickHeight
			else
				if (tickIndex % 2) == 0 then
					objects[i][tickIndex].h = tickHeight * 2
				else
					objects[i][tickIndex].h = tickHeight
				end

				tickIndex = 1
				i = i + 1
			end
		end
	end

	return objects
end

---@param notes HitStat[]
---@param x number
---@param w number
---@param h number
---@param color Color
---@param offset number
---@param sCriticalWindow integer
---@return ResultsNoteObject[]
local function makeNoteObjects(notes, x, w, h, color, offset, sCriticalWindow)
	local noteIndex = 1
	local noteObjects = {}

	for _, obj in ipairs(notes) do
		noteObjects[noteIndex] = {
			color = getObjectColor(obj.rating, obj.delta, sCriticalWindow) or color,
			offset = offset,
			timeFrac = obj.timeFrac,
			x = x,
			w = w,
			h = h,
		}

		noteIndex = noteIndex + 1
	end

	return noteObjects
end

---@param separatedHoldsOrLasers HitStat[][]
---@param tickHeight number
---@param tickTime number
---@param tickFrac number
---@param properties table
---@return ResultsHoldObject[][]
local function formatHoldsOrLasers(separatedHoldsOrLasers, tickHeight, tickTime, tickFrac, properties, isLasers)
	local formatted = {}

	for i, holds in ipairs(separatedHoldsOrLasers) do
		formatted[i] = makeHoldOrLaserObjects(
			holds,
			tickHeight,
			tickTime,
			tickFrac,
			properties.x[i],
			properties.w,
			(isLasers and properties.color[i]) or properties.color
		)
	end

	return formatted
end

---@param separatedNotes HitStat[][]
---@param properties table
---@param sCriticalWindow integer
---@return ResultsNoteObject[][]
local function formatNotes(separatedNotes, properties, sCriticalWindow)
	local formatted = {}

	for i, notes in ipairs(separatedNotes) do
		formatted[i] = makeNoteObjects(
			notes,
			properties.x[i],
			properties.w,
			properties.h,
			properties.color,
			properties.offset,
			sCriticalWindow
		)
	end

	return formatted
end

---@param holds HitStat[]
---@param duration number
---@return table<string, ResultsHoldObject[][]>, number, number
local function getHoldObjects(holds, duration)
	local separatedBTHolds, separatedFXHolds = separateObjects(holds)
	local tickTime = getTickTime(separatedBTHolds, separatedFXHolds)
	local tickHeight = -math.ceil(tickTime * 0.175) - 0.5

	return {
		bt = formatHoldsOrLasers(separatedBTHolds, tickHeight, tickTime + 2, tickTime / duration, BTHoldProperties),
		fx = formatHoldsOrLasers(separatedFXHolds, tickHeight, tickTime + 2, tickTime / duration, FXHoldProperties),
	}, tickHeight, tickTime
end

---@param notes HitStat[]
---@param sCriticalWindow integer
---@return table<string, ResultsNoteObject[][]>
local function getNoteObjects(notes, sCriticalWindow)
	local separatedBTNotes, separatedFXNotes = separateObjects(notes)

	return {
		bt = formatNotes(separatedBTNotes, BTNoteProperties, sCriticalWindow),
		fx = formatNotes(separatedFXNotes, FXNoteProperties, sCriticalWindow),
	}
end

local function getLaserObjects(lasers, duration, tickHeight, tickTime)
	local separatedLasers = separateObjects(lasers, true)

	return formatHoldsOrLasers(separatedLasers, tickHeight, tickTime + 2, tickTime / duration, LaserProperties, true)
end

---@param notes HitStat[]
---@param holds HitStat[]
---@param duration number
---@param sCriticalWindow integer
---@return ResultsTrackObjects|nil
local function getTrackObjects(notes, holds, lasers, duration, sCriticalWindow)
	if (#notes == 0) and (#holds == 0) and (#lasers == 0) then
		return
	end

	local holdObjects, tickHeight, tickTime = getHoldObjects(holds, duration)

	return {
		notes = getNoteObjects(notes, sCriticalWindow),
		holds = holdObjects,
		lasers = getLaserObjects(lasers, duration, tickHeight, tickTime),
	}
end

return getTrackObjects

---@class ResultsTrackObjects
---@field holds ResultsHoldObjects
---@field notes ResultsNoteObjects
---@field lasers ResultsHoldObject[][]

---@class ResultsHoldObjects
---@field bt ResultsHoldObject[][]
---@field fx ResultsHoldObject[][]

---@class ResultsNoteObjects
---@field bt ResultsNoteObject[][]
---@field fx ResultsNoteObject[][]

---@class ResultsHoldObject
---@field color Color
---@field startFrac number
---@field x number
---@field w number

---@class ResultsNoteObject
---@field color Color
---@field offset number
---@field timeFrac number
---@field x number
---@field w number
---@field h number
