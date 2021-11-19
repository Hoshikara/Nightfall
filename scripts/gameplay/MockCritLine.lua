---@class MockCritLine
local MockCritLine = {}
MockCritLine.__index = MockCritLine

---@param window Window
---@return MockCritLine
function MockCritLine.new(window)
  ---@type MockCritLine
  local self = {
    ---@type cursors
    cursors = {},
    laserActive = { true, true },
    ---@type Line
    line = {
      x1 = 0,
      x2 = 0,
      y1 = 0,
      y2 = 0,
    },
    rotation = 0,
    window = window,
    x = 0,
    y = 0,
  }

  for i = 0, 1 do
    self.cursors[i] = {
      alpha = 1,
      pos = 0,
      skew = 0,
    }
  end

  return setmetatable(self, MockCritLine)
end

function MockCritLine:update()
  local isPortrait = self.window.isPortrait
  local line = self.line
  local window = self.window
  local x = window.resX - (window.shiftX * 2)
  local y = window.resY - (window.shiftY * 2)

  line.x1 = x * ((isPortrait and 0.095) or 0.282)
  line.x2 = x * ((isPortrait and 0.905) or 0.718)
  line.y1 = y * ((isPortrait and 0.707) or 0.941)
  line.y2 = y * ((isPortrait and 0.707) or 0.941)

  self.x = (window.resX / 2) - window.shiftX
  self.y = line.y1
end

---@param translate boolean
function MockCritLine:updateCursors(translate)
  local scale = self.window.scaleFactor

  if self.window.isPortrait then
    self.cursors[0].pos = -350 * scale
    self.cursors[0].skew = -0.4
    self.cursors[1].pos = 350 * scale
    self.cursors[1].skew = 0.4
    
    if translate then
      gfx.Translate(
        (self.window.resX / 2) - self.window.shiftX,
        (self.window.resY - (self.window.shiftY * 2)) * 0.707
      )
    end
  else
    self.cursors[0].pos = -330 * scale
    self.cursors[0].skew = -0.35
    self.cursors[1].pos = 330 * scale
    self.cursors[1].skew = 0.35

    if translate then
      gfx.Translate(
        (self.window.resX / 2) - self.window.shiftX,
        (self.window.resY - (self.window.shiftY * 2)) * 0.941
      )
    end
  end
end

return MockCritLine
