--#region Require

local Easing = require("common/Easing")
local ItemCursor = require("common/ItemCursor")
local getLaserColors = require("common/helpers/getLaserColors")
local pulse = require("common/helpers/pulse")

--#endregion

local laserColors = getLaserColors()

local max = math.max

---@class LaserAlerts
local LaserAlerts = {}
LaserAlerts.__index = LaserAlerts

---@param ctx GameplayContext
---@param window Window
---@return LaserAlerts
function LaserAlerts.new(ctx, window)
  ---@type LaserAlerts
  local self = {
    alpha = { 0, 0 },
    ctx = ctx,
    fade = { Easing.new(), Easing.new() },
    itemCursor = ItemCursor.new({ size = 16, stroke = 2 }, true),
    pulseTimers = { 0, 0 },
    size = 128,
    start = { false, false },
    text = { makeLabel("Medium", "L", 128), makeLabel("Medium", "R", 128) },
    window = window,
    windowResized = nil,
    x = { 0, 0 },
    y = 0,
  }

  return setmetatable(self, LaserAlerts)
end

---@param dt deltaTime
function LaserAlerts:draw(dt)
  self:setProps()

  local scale = self.window.scaleFactor
  
  gfx.Save()
  gfx.Translate(self.window.w / 2, self.y)

  for i = 1, 2 do
    self:handleTimers(dt, i)
    self:drawAlert(i, scale)
  end

  gfx.Restore()
end

function LaserAlerts:setProps()
  if self.windowResized ~= self.window.resized then
    local textSize = 128

    if self.window.isPortrait then
      textSize = 108
      self.x[1] = -456
      self.x[2] = 456
      self.y = 1244
    else
      textSize = 128
      self.x[1] = -484
      self.x[2] = 484
      self.y = 834
    end

    self.size = textSize
    self.text[1] = makeLabel("Medium", "L", textSize)
    self.text[2] = makeLabel("Medium", "R", textSize)

    self.windowResized = self.window.resized
  end
end

---@param index integer
---@param scale number
function LaserAlerts:drawAlert(index, scale)
  local fade = self.fade[index].value
  local size = self.size
  local x = self.x[index]

  gfx.Scissor(
    (x - (size / 2)) * scale,
    -(size / 2) * scale,
    size,
    size * fade
  )
  self.text[index]:draw({
    x = x,
    y = -6,
    align = "CenterMiddle",
    alpha = self.alpha[index],
    color = laserColors[index],
  })
  gfx.ResetScissor()
  self.itemCursor:drawItemCursor({
    x = x - (size / 2) * fade,
    y = -(size / 2) * fade,
    w = size * fade,
    h = size * fade,
    alpha = fade,
  })
end

---@param dt deltaTime
---@param index integer
function LaserAlerts:handleTimers(dt, index)
  self.ctx.alertTimers[index] = max(self.ctx.alertTimers[index] - dt, -1.5)
  self.start[index] = self.ctx.alertTimers[index] > -1.5

  if self.start[index] then
    self.fade[index]:start(dt, 3, 0.2)
    self.pulseTimers[index] = self.pulseTimers[index] + dt
    self.alpha[index] = pulse(self.pulseTimers[index], 0.2, 8)
  else
    self.fade[index]:stop(dt, 3, 0.2)
    self.pulseTimers[index] = self.pulseTimers[index] - dt
    self.alpha[index] = 1
  end
end


return LaserAlerts
