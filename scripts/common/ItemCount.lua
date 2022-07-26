local DimmedNumber = require("common/DimmedNumber")

---@class ItemCount: ItemCountBase
local ItemCount = {}
ItemCount.__index = ItemCount

---@param params? ItemCount.new.params
---@return ItemCount
function ItemCount.new(params)
	params = params or {}

	local size = params.size or 19
	local scale = size / 19

	---@class ItemCountBase
	local self = {
		currentItem = DimmedNumber.new({ digits = 4, size = size }),
		scale = scale,
		slash = makeLabel("Number", "/", size),
		totalItems = DimmedNumber.new({
			digits = 4,
			size = size,
			value = params.totalItems
		}),
		totalItemsValue = params.totalItems or 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, ItemCount)
end

---@param params ItemCount.draw.params
function ItemCount:draw(params)
	local alpha = params.alpha or 1
	local scale = self.scale
	local x = params.x or 0
	local y = params.y or 0

	self.currentItem:draw({
		x = x - (117 * scale),
		y = y,
		alpha = alpha,
		value = params.currentItem or 0,
	})
	self.slash:draw({
		x = x - (64 * scale),
		y = y,
		alpha = alpha,
	})
	self.totalItems:draw({
		x = x - (48 * scale),
		y = y,
		alpha = alpha,
		value = params.totalItems or self.totalItemsValue
	})
end

return ItemCount

---@class ItemCount.new.params
---@field size? integer
---@field totalItems? integer

---@class ItemCount.draw.params
---@field x? number
---@field y? number
---@field alpha? number
---@field currentItem? integer
---@field totalItems? integer
