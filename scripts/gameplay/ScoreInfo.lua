local DimmedNumber = require("common/DimmedNumber")

---@class ScoreInfo
local ScoreInfo = {}
ScoreInfo.__index = ScoreInfo

---@param ctx GameplayContext
---@param window Window
---@return ScoreInfo
function ScoreInfo.new(ctx, window)
  ---@type ScoreInfo
  local self = {
    ctx = ctx,
    exScore = DimmedNumber.new({ digits = 5, size = 27 }),
    exScoreLabel = makeLabel("Medium", "EX SCORE", 30),
    maxChain = DimmedNumber.new({ digits = 5, size = 27 }),
    maxChainLabel = makeLabel("Medium", "MAX CHAIN", 30),
    scale = 1,
    score = DimmedNumber.new({ size = 130 }),
    scoreLabel = makeLabel("Medium", "SCORE", 71),
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
  }

  return setmetatable(self, ScoreInfo)
end

function ScoreInfo:draw()
  self:setProps()

  local introAlpha = self.ctx.introAlpha
  local isPortrait = self.window.isPortrait

  gfx.Save()
  gfx.Translate(self.x + ((self.window.w / 4) * self.ctx.introOffset), self.y)
  gfx.Scale(self.scale, self.scale)
  self:drawScore(introAlpha, isPortrait)
  self:drawExScore(introAlpha, isPortrait)
  self:drawMaxChain(introAlpha, isPortrait)
  gfx.Restore()
end

function ScoreInfo:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.x = 673
      self.y = 351
      self.exScore = DimmedNumber.new({ digits = 5, size = 18 })
      self.exScoreLabel = makeLabel("Medium", "EX SCORE", 20)
      self.maxChain = DimmedNumber.new({ digits = 5, size = 18 })
      self.maxChainLabel = makeLabel("Medium", "MAX CHAIN", 20)
      self.score = DimmedNumber.new({ size = 85 })
      self.scoreLabel = makeLabel("Medium", "SCORE", 46)
    else
      self.x = self.window.w - (self.window.paddingX / 2) - 576
      self.y = self.window.paddingY * 0.75
      self.exScore = DimmedNumber.new({ digits = 5, size = 27 })
      self.exScoreLabel = makeLabel("Medium", "EX SCORE", 30)
      self.maxChain = DimmedNumber.new({ digits = 5, size = 27 })
      self.maxChainLabel = makeLabel("Medium", "MAX CHAIN", 30)
      self.score = DimmedNumber.new({ size = 130 })
      self.scoreLabel = makeLabel("Medium", "SCORE", 71)
    end

    self.windowResized = self.window.resized
  end
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawScore(introAlpha, isPortrait)
  self.scoreLabel:draw({
    x = (isPortrait and -6) or -3,
    y = -33,
    alpha = introAlpha,
    color = "Standard",
  })
  self.score:draw({
    x = -8,
    y = (isPortrait and 4) or 24,
    alpha = introAlpha,
    value = self.ctx.score,
  })
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawExScore(introAlpha, isPortrait)
  self.exScoreLabel:draw({
    x = (isPortrait and 211) or 325,
    y = (isPortrait and 5) or 31,
    alpha = introAlpha,
    color = "Standard",
  })
  self.exScore:draw({
    x = (isPortrait and 321) or 493,
    y = (isPortrait and 7) or 34,
    alpha = introAlpha,
    color = "White",
    value = self.ctx.exScore,
  })
end

---@param introAlpha number
---@param isPortrait boolean
function ScoreInfo:drawMaxChain(introAlpha, isPortrait)
  self.maxChainLabel:draw({
    x = (isPortrait and 211) or 325,
    y = (isPortrait and 98) or 163,
    alpha = introAlpha,
    color = "Standard",
  })
  self.maxChain:draw({
    x = (isPortrait and 321) or 493,
    y = (isPortrait and 100) or 166,
    alpha = introAlpha,
    color = "White",
    value = self.ctx.maxChain,
  })
end

return ScoreInfo
