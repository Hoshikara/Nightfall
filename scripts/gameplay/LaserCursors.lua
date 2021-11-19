local Image = require("common/Image")
local MockCritLine = require("gameplay/MockCritLine")
local getLaserColors = require("common/helpers/getLaserColors")

local laserColors = getLaserColors()

local abs = math.abs
local sin = math.sin

---@class LaserCursors
local LaserCursors = {}
LaserCursors.__index = LaserCursors

---@param window Window
---@param isGameplaySettings boolean
---@return LaserCursors
function LaserCursors.new(window, isGameplaySettings)
  ---@type LaserCursors
  local self = {
    fill = Image.new({ path = "gameplay/laser_cursors/fill.png" }),
    flickerTimer = 0,
    isGameplaySettings = isGameplaySettings,
    ---@type MockCritLine
    mockCritLine = isGameplaySettings and MockCritLine.new(window),
    overlay = Image.new({ path = "gameplay/laser_cursors/overlay.png" }),
    tail = Image.new({ path = "gameplay/laser_cursors/tail.png" }),
    window = window,
  }

  self.h = self.overlay.h * 1.15

  return setmetatable(self, LaserCursors)
end

function LaserCursors:draw(dt)
  local cursors = (self.mockCritLine or gameplay.critLine).cursors
  local fill = self.fill
  local laserActive = (self.mockCritLine or gameplay).laserActive
  local scale = self.window.scaleFactor
  local tail = self.tail
  local cursorScale = 0.4 * scale
  local h = self.h

  if self.isGameplaySettings then
    self.mockCritLine:updateCursors(true)
  end

  self.flickerTimer = self.flickerTimer + dt

  for i = 1, 2 do
    local cursor = cursors[i - 1]

    gfx.SkewX(cursor.skew)

    if laserActive[i] then
      tail:draw({
        x = cursor.pos,
        y = 80 * scale,
        alpha = 0.75,
        blendOp = 8,
        isCentered = true,
        scale = 1.10 * scale,
        tint = laserColors[i]
      })
      tail:draw({
        x = cursor.pos,
        y = 80 * scale,
        alpha = 0.75,
        blendOp = 8,
        isCentered = true,
        scale = 1.10 * scale,
      })
    end
    
    fill:draw({
      x = cursor.pos,
      h = h,
      alpha = cursor.alpha * (0.4 * abs(sin(self.flickerTimer * 40))),
      blendOp = 8,
      isCentered = true,
      scale = cursorScale,
      tint = laserColors[i]
    })
    fill:draw({
      x = cursor.pos,
      h = h,
      alpha = cursor.alpha * 0.6,
      isCentered = true,
      scale = cursorScale,
      tint = laserColors[i]
    })
    self.overlay:draw({
      x = cursor.pos,
      h = h,
      alpha = cursor.alpha,
      isCentered = true,
      scale = cursorScale,
    })
    gfx.SkewX(-cursor.skew)
  end
end

return LaserCursors
