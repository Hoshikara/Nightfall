---@class Button
local Button = {}
Button.__index = Button

---@param w number
---@param h number
---@return Button
function Button.new(w, h)
  ---@type Button
  local self = { w = w or 0, h = h or 0 }

  return setmetatable(self, Button)
end

---@param params Button.draw.params
function Button:draw(params)
  drawRect({
    x = params.x,
    y = params.y,
    w = self.w,
    h = self.h,
    alpha = 0.2 * (params.alpha or 1),
    color = "Black",
  })
  drawRect({
    x = params.x,
    y = params.y,
    w = 4,
    h = self.h,
    alpha = 1 * (params.accentAlpha or 1),
    color = "Standard",
  })
end

return Button

---@class Button.draw.params
---@field x? number
---@field y? number
---@field alpha? number
---@field accentAlpha? number
