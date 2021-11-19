---@class Spinner
---@field text? Label
local Spinner = {}
Spinner.__index = Spinner

---@param params Spinner.new.params
---@return Spinner
function Spinner.new(params)
  params = params or {}

  ---@type Spinner  
  local self = {
    color = params.color or "Standard",
    radius = params.radius or 12,
    rotationTimer = 0,
    text = params.text and makeLabel("SemiBold", params.text),
    thickness = params.thickness or 3,
  }

  return setmetatable(self, Spinner)
end

---@param dt deltaTime
---@param x number
---@param y number
function Spinner:draw(dt, x, y)
  self.rotationTimer = self.rotationTimer + dt

  gfx.Save()
  gfx.Translate(x + 14, y - 14)
  gfx.Rotate(self.rotationTimer * 8)
  gfx.BeginPath()
  setColor("Black", 0)
  setStroke({
    alpha = 0.4,
    color = self.color,
    size = self.thickness,
  })
  gfx.Circle(0, 0, self.radius)
  gfx.Fill()
  gfx.Stroke()
  gfx.BeginPath()
  setStroke({
    alpha = 1,
    color = self.color,
    size = self.thickness,
  })
  gfx.Arc(0, 0, self.radius, 0, 3.14159 * 1.5, 1)
  gfx.Stroke()
  gfx.Restore()

  if self.text then
    self.text:draw({
      x = x + 39,
      y = y - 27,
      color = "White",
    })
  end
end

return Spinner

---@class Spinner.new.params
---@field color? string|Color
---@field radius? number
---@field text? string
---@field thickness? number
