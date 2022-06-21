local floor = math.floor

---@class DimmedNumber
---@field alpha number[]
---@field color Color|string
---@field digits Label[]
---@field isScore boolean
---@field numbers integer[]
---@field offsetY number
---@field positions number[]
---@field value number
---@field w number
---@field h number
local DimmedNumber = {}
DimmedNumber.__index = DimmedNumber

---@param params DimmedNumber.new.params
---@return DimmedNumber
function DimmedNumber.new(params)
	local size = params.size or 100

	---@type DimmedNumber
	local self = {
		alpha = {},
		color = params.color or "Standard",
		digits = {},
		isScore = not params.digits,
		numbers = {},
		offsetY = nil,
		positions = {},
		size = size,
		value = params.value or 0,
		w = 0,
		h = nil,
	}

	if self.isScore then
		for i = 1, 4 do
			self.digits[i] = makeLabel("Number", "0", size)
			self.digits[i + 4] = makeLabel("Number", "0", floor(size * 0.8))

			local w1 = self.digits[i].w
			local w2 = self.digits[i + 4].w

			self.positions[i] = (i - 1) * w1
			self.positions[i + 4] = (w1 * 4) + ((i - 1) * w2)
			self.w = self.w + w1 + w2

			if not self.offsetY then
				self.offsetY = self.digits[i].h * 0.16
			end

			if not self.h then
				self.h = self.digits[i].h
			end
		end
	else
		for i = 1, params.digits or 4 do
			self.digits[i] = makeLabel("Number", "0", size)
			self.positions[i] = (i - 1) * self.digits[i].w
			self.w = self.w + self.digits[i].w

			if not self.h then
				self.h = self.digits[i].h
			end
		end
	end

	return setmetatable(self, DimmedNumber)
end

---@param params DimmedNumber.draw.params
function DimmedNumber:draw(params)
	self:updateNumbers(params.value or self.value)

	local color = params.color or self.color
	local x = params.x or 0
	local y = params.y or 0

	if self.isScore then
		self:drawScore(x, y, color)
	else
		self:drawNumber(x, y, params.alpha, color, params.spacing)
	end
end

---@param value number
function DimmedNumber:updateNumbers(value)
	local digitCount = #self.digits

	for i = 1, digitCount do
		local min = 10 ^ (digitCount - i)

		self.alpha[i] = ((value >= min) and 1) or 0.4
		self.numbers[i] = floor(value / min) % 10
	end
end

---@param x number
---@param y number
---@param color string
function DimmedNumber:drawScore(x, y, color)
	local alpha = self.alpha
	local digits = self.digits
	local numbers = self.numbers
	local offsetY = self.offsetY
	local positions = self.positions

	for i = 1, 4 do
		digits[i]:draw({
			x = x + positions[i],
			y = y,
			align = "LeftTop",
			alpha = alpha[i],
			color = "White",
			text = numbers[i],
			update = true,
		})
		digits[i + 4]:draw({
			x = x + positions[i + 4],
			y = y + offsetY,
			align = "LeftTop",
			alpha = alpha[i + 4],
			color = color,
			text = numbers[i + 4],
			update = true,
		})
	end
end

---@param x number
---@param y number
---@param color string
function DimmedNumber:drawNumber(x, y, alphaMod, color, spacing)
	local alpha = self.alpha
	local numbers = self.numbers
	local positions = self.positions

	alphaMod = alphaMod or 1
	spacing = spacing or 0

	for i, digit in ipairs(self.digits) do
		digit:draw({
			x = x + positions[i] + (spacing * (i - 1)),
			y = y,
			align = "LeftTop",
			alpha = alpha[i] * alphaMod,
			color = color,
			text = numbers[i],
			update = true,
		})
	end
end

return DimmedNumber

--#region Interfaces

---@class DimmedNumber.new.params
---@field color? Color|string
---@field digits? integer
---@field size? integer
---@field value? number

---@class DimmedNumber.draw.params
---@field x? number
---@field y? number
---@field alpha? integer
---@field color? Color|string
---@field offset? number
---@field spacing? number
---@field value? integer

--#endregion
