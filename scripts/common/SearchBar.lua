local Easing = require("common/Easing")
local ControlLabel = require("common/ControlLabel")
local pulse = require("common/helpers/pulse")

local min = math.min

---@class SearchBar
local SearchBar = {}
SearchBar.__index = SearchBar

---@return SearchBar
function SearchBar.new()
  ---@type SearchBar
  local self = {
    alpha = Easing.new(),
    cursorTimer = 0,
    input = makeLabel("JP", "", 21),
    searchControl = ControlLabel.new("TAB", "SEARCH"),
    x = 0,
    y = 0,
    w = 0,
    h = 32,
  }

  return setmetatable(self, SearchBar)
end

---@param dt deltaTime
---@param params SearchBar.draw.params
function SearchBar:draw(dt, params)
  local input = params.input or ""
  local isActive = params.isActive
  local shouldShow = (input:len() > 0) or isActive
  local x = self.x
  local y = self.y

  self:handleTimers(dt, isActive, shouldShow)

  gfx.Save()
  self.searchControl:draw(x, y + 6)

  x = x + self.searchControl.w

  self:drawBar(x, y)

  if shouldShow then
    self:drawInput(x, y, input, isActive)
  end

  gfx.Restore()
end

---@param params SearchBar.setProps.params
function SearchBar:setProps(params)
  self.x = params.x or 0
  self.y = params.y or 0
  self.w = (params.w or 0) - self.searchControl.w
  self.h = params.h or self.h
end

---@param dt deltaTime
---@param isActive boolean
---@param shouldShow boolean
function SearchBar:handleTimers(dt, isActive, shouldShow)
  if shouldShow then
    self.alpha:start(dt, 3, 0.26)
    self.cursorTimer = self.cursorTimer + dt
  elseif (not shouldShow) and (self.alpha.value > 0) then
    self.alpha:stop(dt, 3, 0.26)
    self.cursorTimer = 0
  end
end

---@param x number
---@param y number
function SearchBar:drawBar(x, y)
  drawRect({
    x = x + 0.5,
    y = y + 0.5,
    w = self.w - 1,
    h = self.h - 1,
    alpha = 0.8,
    color = "Black",
    stroke = {
      alpha = self.alpha.value,
      color = "Standard",
      size = 1,
    },
  })
end

---@param x number
---@param y number
---@param input string
---@param isActive boolean
function SearchBar:drawInput(x, y, input, isActive)
  local maxWidth = self.w - 16

  if self.alpha.value == 1 then
    local alpha = 0
    local offset = min(self.input.w, maxWidth)

    if isActive then
      alpha = pulse(self.cursorTimer, 0.2, 5)
    end

    drawRect({
      x = x + 7 + offset,
      y = y + 5,
      w = 2,
      h = 22,
      alpha = alpha,
      color = "White",
      isFast = true,
    })
  end

  self.input:draw({
    x = x + 6,
    y = y + 2,
    color = "White",
    maxWidth = maxWidth,
    text = input:upper(),
    update = true,
  })
end

return SearchBar

--#region Interfaces

---@class SearchBar.draw.params
---@field input string
---@field isActive boolean

---@class SearchBar.setProps.params
---@field x? number
---@field y? number
---@field w? number
---@field h? number

--#endregion
