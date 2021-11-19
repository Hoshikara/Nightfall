local Easing = require("common/Easing")

local floor = math.floor

---@class List
local List = {}
List.__index = List

---@return List
function List.new()
	---@type List
	local self = {
		currentItem = nil,
		currentPage = 0,
		easing = Easing.new(),
		isPortrait = nil,
		offset = 0,
		pageItemCount = 0,
		pageSize = 0,
		previousOffset = 0,
	}

	return setmetatable(self, List)
end

---@param params List.setProps.params
function List:setProps(params)
	self.pageItemCount = params.pageItemCount or 0
	self.pageSize = params.pageSize or 0
end

---@param itemIndex integer
---@return integer
function List:getPage(itemIndex)
	return floor((itemIndex - 1) / self.pageItemCount) + 1
end

---@param itemIndex integer
---@param pageItemCount? integer
---@return boolean
function List:isOnPage(itemIndex, pageItemCount)
	pageItemCount = pageItemCount or self.pageItemCount

	return (itemIndex > ((self.currentPage - 1) * pageItemCount))
		and (itemIndex <= (self.currentPage * pageItemCount))
end

---@param dt deltaTime
---@param params List.update.params
function List:update(dt, params)
	if self.isPortrait ~= params.isPortrait then
		self.easing:reset()

		self.isPortrait = params.isPortrait
	end

	if self.currentItem ~= params.currentItem then
		local currentPage = self:getPage(params.currentItem)

		if self.currentPage ~= currentPage then
			self.easing:reset()

			self.currentPage = currentPage
		end

		self.currentItem = params.currentItem
	end

	if self.easing.value < 1 then
		local offset = -self.pageSize * (self.currentPage - 1)

		self.easing:start(dt, 3, 0.26)

		self.offset = self.previousOffset + (offset - self.previousOffset) * self.easing.value
		self.previousOffset = self.offset
	end
end

return List

--#region Interfaces

---@class List.setProps.params
---@field pageItemCount? integer # Default: `0`, the number of items on a page
---@field pageSize? number # Default: `0`, the width/height of a page in pixels.

---@class List.update.params
---@field currentItem integer
---@field isPortrait? boolean # Default: `nil`

--#endregion
