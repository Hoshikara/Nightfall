local DimmedNumber = require("common/DimmedNumber")

local getColor = require("common/helpers/getColor")

local ChainColors = {
  [0] = getColor("normalChainColor"),
  [1] = getColor("UcChainColor"),
  [2] = getColor("PucChainColor"),
}

---@class Chain
local Chain = {}
Chain.__index = Chain

---@param ctx GameplayContext
---@param window Window
---@return Chain
function Chain.new(ctx, window)
  ---@type Chain
  local self = {
    ctx = ctx,
    number = DimmedNumber.new({ digits = 4, size = 72 }),
    text = makeLabel("Medium", "CHAIN"),
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
  }

  return setmetatable(self, Chain)
end

---@param dt deltaTime
function Chain:draw(dt)
  if (self.ctx.chain == 0) or (self.ctx.chainTimer < 0) then
    return
  end

  self.ctx.chainTimer = self.ctx.chainTimer - dt

  self:setProps()

  local chain = self.ctx.chain
  local color = ChainColors[gameplay.comboState]
  local x = self.x
  local y = self.y
  
  self:drawChain(x, y, chain, color)
end

function Chain:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.y = (self.window.h * 0.707) - 224
    else
      self.y = (self.window.h * 0.941) - 224
    end

    self.x = self.window.w / 2
    self.windowResized = self.window.resized
  end
end

function Chain:drawChain(x, y, chain, color)
  self.text:draw({
    x = x,
    y = y - 24,
    align = "CenterTop",
    color = color,
  })
  self.number:draw({
    x = x - 94,
    y = y - 4,
    color = color,
    spacing = 3,
    value = chain,
  })
end

return Chain
