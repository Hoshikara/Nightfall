local Sorts = require("songselect/constants/Sorts")

---@class SortItem: SortItemBase
local SortItem = {}
SortItem.__index = SortItem

---@param item string
---@return SortItem
function SortItem.new(item)
	local sort = Sorts[item]

	---@class SortItemBase
	---@field subText Label[]
	local self = {
		subText = {
			makeLabel("SemiBold", sort.subText[1], 11),
			makeLabel("SemiBold", sort.subText[2], 11),
		},
		text = makeLabel("Medium", sort.name, 32),
	}

	local w1 = self.subText[1].w
	local w2 = self.subText[2].w
	local subTextWidth = ((w1 > w2) and w1) or w2

	self.w = self.text.w + subTextWidth + 15

	---@diagnostic disable-next-line
	return setmetatable(self, SortItem)
end

function SortItem:draw(params)
	self.text:draw(params)

	params.x = params.x + self.text.w + 11
	params.y = params.y + 9

	self.subText[1]:draw(params)

	params.y = params.y + 12

	self.subText[2]:draw(params)
end

return SortItem
