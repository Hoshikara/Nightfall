local Easing = require("common/Easing")

local floor = math.floor

---@class Scrollbar
local Scrollbar = {}
Scrollbar.__index = Scrollbar

---@return Scrollbar
function Scrollbar.new()
  ---@type Scrollbar
  local self = {
    currentItem = nil,
    currentPage = 0,
    easing = Easing.new(),
    offset = 0,
    pageItemCount = 1,
    previousOffset = 0,
    x = 0,
    y = 0,
    w = 8,
    h = 0,
  }

  return setmetatable(self, Scrollbar)
end

---@param dt deltaTime
---@param params Scrollbar.draw.params
function Scrollbar:draw(dt, params)
  self:updateProps(dt, params.currentItem or 1, params.totalItems or 1)
  self:drawBar(params.alphaMod or 1)
end

---@param params Scrollbar.setProps.params
function Scrollbar:setProps(params)
  self.x = params.x or 0
  self.y = params.y or 0
  self.h = params.h or 0
  self.pageItemCount = params.pageItemCount or 1
end

---@param dt deltaTime
---@param currentItem integer
---@param totalItems integer
function Scrollbar:updateProps(dt, currentItem, totalItems)
  if self.currentItem ~= currentItem then
    local currentPage = self:getPage(currentItem)
    
    if self.currentPage ~= currentPage then
			self.easing:reset()

			self.currentPage = currentPage
		end

    self.currentItem = currentItem
  end

  if self.easing.value < 1 then
    local currentY = self:getCurrentY(totalItems)

    self.easing:start(dt, 3, 0.26)
    self.offset = self.previousOffset
      + ((currentY - self.previousOffset) * self.easing.value)
    
    if tostring(self.offset) == "-nan(ind)" then
      self.previousOffset = 0
    else
      self.previousOffset = self.offset
    end
  end
end

---@param totalItems integer
---@return number
function Scrollbar:getCurrentY(totalItems)
  local totalPages = floor(totalItems / self.pageItemCount)

  return floor((self.h - 32) * (self.currentPage / totalPages))
end

---@param itemIndex integer
---@return integer
function Scrollbar:getPage(itemIndex)
	return floor((itemIndex - 1) / self.pageItemCount)
end

---@param alpha number
function Scrollbar:drawBar(alpha)
  local x = self.x
  local y = self.y
  local w = self.w

  drawRect({
    x = x,
    y = y,
    w = w,
    h = self.h,
    alpha = 0.65 * alpha,
    color = "Black",
    isFast = true,
  })
  drawRect({
    x = x,
    y = y + self.offset,
    w = w,
    h = 32,
    alpha = alpha,
    color = "Standard",
    isFast = true,
  })
end

return Scrollbar

--#region Interfaces

---@class Scrollbar.draw.params
---@field alphaMod number
---@field currentItem integer
---@field totalItems integer

---@class Scrollbar.setProps.params
---@field x number
---@field y number
---@field h number
---@field pageItemCount? integer

--#endregion
