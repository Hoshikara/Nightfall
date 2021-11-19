local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local pi = math.pi

--#region Helpers

---@param val number
---@return integer
local function getSign(val)
  return (val > 0 and 1) or (val < 0 and -1) or 0
end
  
---@param delta number
---@return number
local function getDelta(delta)
	if abs(delta) > (1.5 * pi) then
		return delta + (2 * (pi * getSign(delta) * -1))
	end

	return delta
end
  
---@param val number
---@return integer
local function roundToZero(val)
	if val < 0 then
		return ceil(val)
	elseif val > 0 then
		return floor(val)
	end

	return 0
end

--#endregion

---@class Knobs
local Knobs = {}
Knobs.__index = Knobs

---@return Knobs
function Knobs.new()
	---@type Knobs
	local self = {
		knobs = nil,
		oldProgress = { 0, 0 },
		progress = { 0, 0 },
	}

	return setmetatable(self, Knobs)
end

---@param itemIndex integer
---@param itemCount integer
function Knobs:handleLeft(itemIndex, itemCount)
	return self:advanceSelection(1, itemIndex, itemCount)
end

---@param itemIndex integer
---@param itemCount integer
function Knobs:handleRight(itemIndex, itemCount)
	return self:advanceSelection(2, itemIndex, itemCount)
end

---@param index integer
---@param itemIndex integer
---@param itemCount integer
function Knobs:advanceSelection(index, itemIndex, itemCount)
	if not self.knobs then
		self.knobs = { game.GetKnob(0), game.GetKnob(1) }
	elseif itemCount > 0 then
		local knob = game.GetKnob(index - 1)
		local progress = self.progress

		progress[index] = progress[index] - (getDelta(self.knobs[index] - knob) * 1.2)
		self.knobs[index] = knob

		if abs(progress[index]) > 1 then
			itemIndex = (itemIndex - 1) + roundToZero(progress[index])
			itemIndex = (itemIndex % itemCount) + 1
			progress[index] = progress[index] - roundToZero(progress[index])
		end
	end

	return itemIndex
end

return Knobs
