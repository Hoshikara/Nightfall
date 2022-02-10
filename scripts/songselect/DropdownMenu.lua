local Easing = require("common/Easing")
local ControlLabel = require("common/ControlLabel")
local List = require("common/List")
local formatDropdownItem = require("songselect/helpers/formatDropdownItem")

---@class DropdownMenu
---@field list List|nil
---@field text Label[]
---@field timers table<string, number>
local DropdownMenu = {}
DropdownMenu.__index = DropdownMenu

---@param window Window
---@param params DropdownMenu.new.params
---@return DropdownMenu
function DropdownMenu.new(window, params)
  ---@type DropdownMenu
  local self = {
    alpha = Easing.new(),
    control = ControlLabel.new(
      params.control,
      params.name,
      params.altControl,
      params.altText
    ),
    currentItem = 1,
    font = params.font or "JP",
    fontSize = params.fontSize or 50,
    highlights = {},
    items = {},
    list = params.isLong and List.new(),
    pageItemCount = 21,
    scrollTimer = 0,
    scrollTimers = {},
    totalItems = 0,
    window = window,
    windowResized = nil,
    w = 0,
    h = 0,
  }

  for i = 1, self.pageItemCount do
    self.highlights[i] = Easing.new()
    self.scrollTimers[i] = 0
  end

  return setmetatable(self, DropdownMenu)
end

---@param dt deltaTime
---@param params DropdownMenu.draw.params
---@return boolean
function DropdownMenu:draw(dt, params)
  local items = params.items

  if not items then
    return
  end

  local currentItem = params.currentItem or 1
  local isOpen = params.isOpen
  local x = params.x
  local y = params.y

  self:makeItems(items)
  self:setProps()
  self:handleTimers(dt, currentItem, isOpen)

  self.control:draw(x, y, 1, params.showAltControl)
  self:drawCurrentItem(dt, x, y + 38, currentItem, isOpen, params)
  
  if self.alpha.value == 0 then
    return
  end
  
  self:drawItems(dt, x, y + 38, currentItem, items, params)
end

function DropdownMenu:setProps()
  if self.windowResized ~= self.window.resized then
    if self.list then
      self.list:setProps({
        pageItemCount = self.pageItemCount,
        pageSize = self.h,
      })
    end

    self.windowResized = self.window.resized
  end
end

---@param items string[]
function DropdownMenu:makeItems(items)
  if self.totalItems ~= #items then
    local baseFont = self.font
    local maxItems = self.pageItemCount
    local totalItems = 0
    local w = 0
    local h = 0

    self:resetProps()

    for i, item in ipairs(items) do
      self.items[i] = makeLabel(formatDropdownItem(baseFont, item))

      if self.items[i].w > w then
        w = self.items[i].w
      end

      if i <= maxItems then
        h = h + 44
      end

      totalItems = totalItems + 1
    end

    self.totalItems = totalItems
    self.w = w + 28
    self.h = h
  end
end

---@param dt deltaTime
---@param currentItem integer
---@param isOpen boolean
function DropdownMenu:handleTimers(dt, currentItem, isOpen)
  if isOpen then
    self:handleHighlights(dt, currentItem)

    self.alpha:start(dt, 3, 0.16)
  else
    self.alpha:stop(dt, 3, 0.16)
  end

  if self.currentItem ~= currentItem then
    self.scrollTimer = 0
    self.currentItem = currentItem
  end
end

---@param dt deltaTime
---@param currentItem integer
function DropdownMenu:handleHighlights(dt, currentItem)
  local highlights = self.highlights

  for i = 1, self.pageItemCount do
    local listIndex = self:getIndexInRange(currentItem)

    if i == listIndex then
      highlights[i]:start(dt, 3, 0.2)
    else
      highlights[i]:stop(dt, 3, 0.2)
    end
  end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param currentItem integer
---@param isOpen boolean
---@param params DropdownMenu.draw.params
function DropdownMenu:drawCurrentItem(dt, x, y, currentItem, isOpen, params)
  local item = self.items[currentItem]

  if not item then
    return
  end

  local color = (isOpen and "Standard") or "White"
  local maxWidth = params.maxWidthCurrent or 10000

  if item.w > maxWidth then
    self.scrollTimer = self.scrollTimer + dt

    item:drawScrolling({
      x = x,
      y = y + (params.currentItemOffset or 0),
      color = color,
      scale = self.window.scaleFactor,
      timer = self.scrollTimer,
      width = maxWidth,
    })
  else
    item:draw({
      x = x,
      y = y + (params.currentItemOffset or 0),
      color = color,
    })
  end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param currentItem integer
---@param items string[]
---@param params DropdownMenu.draw.params
function DropdownMenu:drawItems(dt, x, y, currentItem, items, params)
  local alpha = self.alpha.value
  local highlights = self.highlights
  local itemOffset = params.itemOffset or 0
  local mayOverflow = params.maxWidthItems
  local w = (mayOverflow or self.w) + 2

  x = x - 1
  y = y + 28

  drawRect({
    x = x,
    y = y,
    w = w,
    h = (self.h + 8) * alpha,
    alpha = 0.95,
    color = "Black",
    isFast = true,
  })

  if self.list then
    self.list:update(dt, { currentItem = currentItem, totalItems = self.pageItemCount })

    y = y + self.list.offset
  end

  for i, _ in ipairs(items) do
    local listIndex = self:getIndexInRange(i)

    self:drawItem(
      dt,
      x,
      y,
      w,
      alpha,
      highlights[listIndex].value,
      i == currentItem,
      self:getItem(i),
      listIndex,
      mayOverflow,
      ((listIndex > 1) and itemOffset) or 0
    )

    y = y + 44
  end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param w number
---@param alpha number
---@param highlight number
---@param isCurrent boolean
---@param item Label|nil
---@param listIndex integer
---@param mayOverflow boolean
---@param offset number
function DropdownMenu:drawItem(dt, x, y, w, alpha, highlight, isCurrent, item, listIndex, mayOverflow, offset)
  if item then
    drawRect({
      x = x + 8,
      y = y + 8,
      w = (w - 16) * highlight,
      h = 36,
      alpha = alpha * 0.5,
      color = "Standard",
      isFast = true,
    })

    alpha = alpha * (0.4 + (0.6 * highlight))

    if mayOverflow and (item.w > (w - 32)) then
      if isCurrent then
        self.scrollTimers[listIndex] = self.scrollTimers[listIndex] + dt
      else
        self.scrollTimers[listIndex] = 0
      end

      item:drawScrolling({
        x = x + 14,
        y = y + 4 + offset,
        alpha = alpha,
        color = "White",
        scale = self.window.scaleFactor,
        timer = self.scrollTimers[listIndex],
        width = w - 32,
      })
    else
      item:draw({
        x = x + 14,
        y = y + 4 + offset,
        alpha = alpha,
        color = "White",
      })
    end
  end
end

---@param itemIndex integer
---@return Label|nil
function DropdownMenu:getItem(itemIndex)
  if self.list and (not self.list:isOnPage(itemIndex)) then
    return
  end
  
  return self.items[itemIndex]
end

---@param itemIndex integer
---@return integer
function DropdownMenu:getIndexInRange(itemIndex)
  return ((itemIndex - 1) % self.pageItemCount) + 1
end

function DropdownMenu:resetProps()
  self.items = {}
  self.totalItems = 0
  self.w = 0
  self.h = 0
end

return DropdownMenu

--#region Interfaces

---@class DropdownMenu.new.params
---@field altControl? string
---@field altText? string
---@field control? string
---@field font? string
---@field fontSize? integer
---@field isLong? boolean
---@field maxWidth? number
---@field name? string

---@class DropdownMenu.draw.params
---@field x? number
---@field y? number
---@field currentItem integer
---@field currentItemOffset number
---@field isOpen boolean
---@field items table
---@field itemOffset number
---@field maxWidthCurrent number
---@field maxWidthItems number
---@field showAltControl? boolean

--#endregion
