local Easing = require("common/Easing")
local pulse = require("common/helpers/pulse")

local floor = math.floor

---@param itemIndex integer
---@return integer row, integer column
local function getGridPos(itemIndex)
	return floor((itemIndex - 1) / 3) % 3, floor((itemIndex - 1) % 3)
end

---@class ItemCursor: ItemCursorBase
---@field type string
local ItemCursor = {}
ItemCursor.__index = ItemCursor

---@param params ItemCursor.new.params
---@param simpleItemCursor? boolean
---@return ItemCursor
function ItemCursor.new(params, simpleItemCursor)
	---@class ItemCursorBase
	local self = {
		alpha = 0,
		currentItem = 0,
		easing = Easing.new(),
		margin = 0,
		offsetX = 0,
		offsetY = 0,
		phaseTimer = 0,
		previousX = 0,
		previousY = 0,
		size = params.size or 6,
		speed = params.speed or 6,
		stroke = params.stroke or 1,
		type = params.type or "Horizontal",
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	if simpleItemCursor then
		self = {
			size = params.size or 6,
			stroke = params.stroke or 1,
			type = params.type or "Horizontal",
		}
	end

	---@diagnostic disable-next-line
	return setmetatable(self, ItemCursor)
end

---@param dt deltaTime
---@param params ItemCursor.draw.params
function ItemCursor:draw(dt, params)
	self:updateProps(
		dt,
		params.h or self.h,
		params.currentItem or 1,
		params.totalItems or 1
	)

	gfx.Save()
	self:drawItemCursor({
		xOffset = params.xOffset or 0,
		yOffset = params.yOffset or 0,
		alphaMod = params.alphaMod,
	})
	gfx.Restore()
end

---@param params ItemCursor.setProps.params
function ItemCursor:setProps(params)
	self.x = params.x or self.x
	self.y = params.y or self.y
	self.w = params.w or self.w
	self.h = params.h or self.h
	self.offsetX = 0
	self.offsetY = 0
	self.margin = params.margin or self.margin
end

---@param dt deltaTime
---@param h number
---@param currentItem integer
---@param totalItems integer
function ItemCursor:updateProps(dt, h, currentItem, totalItems)
	self:updateTimers(dt, currentItem)

	if self.type == "Grid" then
		local column, row = getGridPos(currentItem)

		self:updateOffsetX(self:getCurrentPos(row))
		self:updateOffsetY(self:getCurrentPos(column))
	else
		local i = self:getOffsetAmount(currentItem, totalItems)

		if self.type == "Horizontal" then
			self:updateOffsetX(self:getCurrentPos(i - 1, self.w))
		else
			self:updateOffsetY(self:getCurrentPos(i - 1, h))
		end
	end
end

---@param dt deltaTime
---@param currentItem integer
function ItemCursor:updateTimers(dt, currentItem)
	self.phaseTimer = self.phaseTimer + dt

	if self.currentItem ~= currentItem then
		self.easing:reset()
		self.currentItem = currentItem
	end

	self.alpha = pulse(self.phaseTimer, 0.15, 4.5)
	self.easing:start(dt, 3, 1 / self.speed)
end

---@param currentX number
function ItemCursor:updateOffsetX(currentX)
	self.offsetX = self.previousX + (currentX - self.previousX) * self.easing.value
	self.previousX = self.offsetX
end

---@param currentY number
function ItemCursor:updateOffsetY(currentY)
	self.offsetY = self.previousY + (currentY - self.previousY) * self.easing.value
	self.previousY = self.offsetY
end

---@param params ItemCursor.drawItemCursor.params
function ItemCursor:drawItemCursor(params)
	local color = params.color or "White"
	local size = (params.size or self.size) * 0.95
	local gap = size / (size * 1.05)
	local x = params.x or (self.x + self.offsetX) + (params.xOffset or 0)
	local y = params.y or (self.y + self.offsetY) + (params.yOffset or 0)
	local w = params.w or self.w
	local h = params.h or self.h

	gfx.BeginPath()
	setStroke({
		alpha = params.alpha or (self.alpha * (params.alphaMod or 1)),
		color = color,
		size = self.stroke,
	})
	gfx.MoveTo(x - size - gap, y)
	gfx.LineTo(x - size - gap, y - size)
	gfx.LineTo(x - gap, y - size)
	gfx.MoveTo(x + w + size + gap, y)
	gfx.LineTo(x + w + size + gap, y - size)
	gfx.LineTo(x + w + gap, y - size)
	gfx.MoveTo(x - size - gap, y + h)
	gfx.LineTo(x - size - gap, y + h + size)
	gfx.LineTo(x - gap, y + h + size)
	gfx.MoveTo(x + w + size + gap, y + h)
	gfx.LineTo(x + w + size + gap, y + h + size)
	gfx.LineTo(x + w + gap, y + h + size)
	gfx.Stroke()
end

---@param amount integer
---@param dimension? number
---@return number
function ItemCursor:getCurrentPos(amount, dimension)
	return ((dimension or self.h) + self.margin) * amount
end

---@param currentItem integer
---@param totalItems integer
function ItemCursor:getOffsetAmount(currentItem, totalItems)
	if (currentItem % totalItems) > 0 then
		return currentItem % totalItems
	end

	return totalItems
end

return ItemCursor

--#region Interfaces

---@class ItemCursor.new.params
---@field size? number
---@field speed? number
---@field stroke? number
---@field type? string

---@class ItemCursor.draw.params
---@field h? number
---@field alphaMod? number
---@field currentItem? integer
---@field totalItems? integer
---@field xOffset? number
---@field yOffset? number

---@class ItemCursor.setProps.params
---@field x? number
---@field y? number
---@field w? number
---@field h? number
---@field margin? number

---@class ItemCursor.drawItemCursor.params
---@field x? number
---@field y? number
---@field w? number
---@field h? number
---@field alpha? number
---@field alphaMod? number
---@field color? Color|string
---@field size? number
---@field xOffset? number
---@field yOffset? number

--#endregion
