local Easing = require("common/Easing")
local ResultsPanelLabels = require("results/constants/ResultsPanelLabels")
local ControlLabel = require("common/ControlLabel")
local ResultsGraphs = require("results/ResultsGraphs")

local min = math.min

---@class ResultsPanel
---@field labels table<string, Label>
local ResultsPanel = {}
ResultsPanel.__index = ResultsPanel

---@param ctx ResultsContext
---@param window Window
---@return ResultsPanel
function ResultsPanel.new(ctx, window)
  ---@type ResultsPanel
  local self = {
    artistTimer = 0,
    ctx = ctx,
    detailedViewControl = ControlLabel.new("BT-A", "DETAILED VIEW"),
    effectorTimer = 0,
    jacketAlpha = Easing.new(),
    jacketOffset = 0,
    jacketShift1 = 0,
    jacketShift2 = 0,
    jacketSize = 968,
    labels = {
      minus = makeLabel("Number", "-", 27),
      plus = makeLabel("Number", "+", 18),
    },
    maxWidth = 0,
    scissorSize = 310,
    screenshotControl = ControlLabel.new("F12", "SCREENSHOT"),
    screenshotPath = makeLabel("SemiBold", ""),
    screenshotSaved = makeLabel("SemiBold", "SCREENSHOT SAVED TO "),
    shiftDelayTimer = 0,
    simpleViewControl = ControlLabel.new("BT-A", "SIMPLE VIEW"),
    smallJacketSize = 230,
    titleTimer = 0,
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 968,
    h = 0,
  }

  self.graphs = ResultsGraphs.new(ctx, self, window)

  for name, str in pairs(ResultsPanelLabels) do
    self.labels[name] = makeLabel("Medium", str, 29)
  end

  return setmetatable(self, ResultsPanel)
end

---@param dt deltaTime
function ResultsPanel:draw(dt)
  self:setProps()

  local x = self.x
  local y = self.y

  gfx.Save()
  self:drawJacket(dt, x, y)
  self:drawPanel(x, y)
  self.graphs:draw()
  self:drawControls(dt, x, y)
  gfx.Restore()
end

function ResultsPanel:setProps()
  if self.windowResized ~= self.window.resized then
    self.x = self.window.paddingX
    self.y = self.window.paddingY

    if self.ctx.scoreCount == 0 then
      if self.window.isPortrait then
        self.y = (self.window.h / 2) - (self.w / 2)
      else
        self.x = (self.window.w / 2) - (self.w / 2)
      end
    end

    self.h = self.w - self.scissorSize
    self.jacketSize = self.w
    self.jacketOffset = -(self.scissorSize - self.jacketSize)
    self.maxWidth = self.w - self.smallJacketSize - 120

    self.ctx.getPanelRegion = function()
      local scale = self.window.scaleFactor
      local shiftX = self.window.shiftX / scale
      local shiftY = self.window.shiftY / scale
      local x = self.x + shiftX
      local y = self.y + shiftY

      if self.window.isPortrait then
        if self.ctx.scoreCount == 0 then
          y = (self.window.h / 2) - (self.w / 2) + shiftY
        else
          y = self.window.h - self.w - self.window.paddingY + shiftY
        end
      end

      return x * scale, y * scale, self.w * scale, self.w * scale
    end

    self.windowResized = self.window.resized
  end
end

---@param dt deltaTime
---@param x number
---@param y number
function ResultsPanel:drawJacket(dt, x, y)
  local chart = self.ctx.chart

  self:drawScissoredJacket(dt, chart.jacket, x, y)
  self:drawMetadata(dt, chart, x, y)

  drawRect({
    x = x + 1.5,
    y = y + 1.5,
    w = self.w - 3,
    h = self.scissorSize - 3,
    alpha = 0.825,
    color = "Black",
    stroke = { color = "Dark", size = 3 },
  })
  drawRect({
    x = x + 40,
    y = y + 40,
    w = self.smallJacketSize,
    h = self.smallJacketSize,
    image = chart.jacket,
  })
end

---@param dt deltaTime
---@param jacket any
---@param x number
---@param y number
function ResultsPanel:drawScissoredJacket(dt, jacket, x, y)
  local jacketOffset = self.jacketOffset
  local jacketSize = self.jacketSize
  local alpha, shift1, shift2 = self:handleJacketShift(dt)

  gfx.Scissor(x, y + 2, jacketSize, self.scissorSize - 2)
  drawRect({
    x = x,
    y = y - (jacketOffset * shift1),
    w = jacketSize,
    h = jacketSize,
    image = jacket,
  })
  drawRect({
    x = x,
    y = y - (jacketOffset * shift2),
    w = jacketSize,
    h = jacketSize,
    alpha = alpha,
    image = jacket,
  })
  gfx.ResetScissor()
end

---@param dt deltaTime
---@return number, number, number
function ResultsPanel:handleJacketShift(dt)
  self.shiftDelayTimer = min(self.shiftDelayTimer + dt, 1)

  if self.shiftDelayTimer == 1 then
    if self.jacketAlpha.value == 0 then
      self.jacketShift1 = min(self.jacketShift1 + (dt * 0.0625), 1)
      self.jacketShift2 = 0
    elseif self.jacketAlpha.value == 1 then
      self.jacketShift1 = 0
      self.jacketShift2 = min(self.jacketShift2 + (dt * 0.0625), 1)
    end

    if self.jacketShift1 == 1 then
      self.jacketAlpha:start(dt, 3, 2)
    elseif self.jacketShift2 == 1 then
      self.jacketAlpha:stop(dt, 3, 2)
    end
  end

  return self.jacketAlpha.value, self.jacketShift1, self.jacketShift2
end

---@param dt deltaTime
---@param chart ResultsChart
---@param x number
---@param y number
function ResultsPanel:drawMetadata(dt, chart, x, y)
  local maxWidth = self.maxWidth
  local scale = self.window.scaleFactor

  x = x + 309
  y = y + 54

  if chart.title.w > maxWidth then
    self.titleTimer = self.titleTimer + dt

    chart.title:drawScrolling({
      x = x,
      y = y,
      color = "White",
      scale = scale,
      timer = self.titleTimer,
      width = maxWidth,
    })
  else
    chart.title:draw({
      x = x,
      y = y,
      color = "White",
    })
  end

  y = y + 51

  if chart.artist.w > maxWidth then
    self.artistTimer = self.artistTimer + dt

    chart.artist:drawScrolling({
      x = x,
      y = y,
      color = "Standard",
      scale = scale,
      timer = self.artistTimer,
      width = maxWidth,
    })
  else
    chart.artist:draw({
      x = x,
      y = y,
      color = "Standard",
    })
  end

  y = y + 37

  chart.bpm:draw({
    x = x,
    y = y,
    color = "White",
  })
  self.labels.bpm:draw({
    x = x + chart.bpm.w + 13,
    y = y - 2,
    color = "Standard"
  })

  y = y + 37

  chart.difficulty:draw({
    x = x,
    y = y,
    color = "White",
  })
  chart.level:draw({
    x = x + chart.difficulty.w + 12,
    y = y + 2,
    color = "White"
  })

  maxWidth = maxWidth - 163
  y = y + 39

  self.labels.effector:draw({
    x = x,
    y = y,
    color = "Standard"
  })

  if chart.effector.w > maxWidth then
    self.effectorTimer = self.effectorTimer + dt

    chart.effector:drawScrolling({
      x = x + 163,
      y = y + 4,
      color = "White",
      scale = scale,
      timer = self.effectorTimer,
      width = maxWidth,
    })
  else
    chart.effector:draw({
      x = x + 163,
      y = y + 4,
      color = "White",
    })
  end
end

---@param x number
---@param y number
function ResultsPanel:drawPanel(x, y)
  y = y + self.scissorSize

  drawRect({
    x = x,
    y = y,
    w = self.w,
    h = self.h,
    color = "Black",
    alpha = 0.8
  })

  self:drawScoreInfo(x, y)
end

---@param x number
---@param y number
function ResultsPanel:drawScoreInfo(x, y)
  local labels = self.labels
  local offset = 377
  local score = self.ctx.myScore

  y = y + 8

  score.score:draw({
    x = x + 33,
    y = y
  })

  if score.scoreDifference then
    if score.scoreDifference.isPositive then
      score.scoreDifference.prefix:draw({ x = x + 375, y = y + 7.5 })  
    else
      score.scoreDifference.prefix:draw({ x = x + 383, y = y + 6 })
    end

    score.scoreDifference.value:draw({ x = x + 397, y = y + 8 })
  end

  x = x + 553
  y = y + 22

  labels.clear:draw({ x = x, y = y })
  score.clear:draw({
    x = x + offset,
    y = y,
    align = "RightTop",
    color = "White"
  })

  y = y + 47

  labels.grade:draw({ x = x, y = y })
  score.grade:draw({
    x = x + offset,
    y = y,
    align = "RightTop",
    color = "White"
  })

  y = y + 47

  labels.player:draw({ x = x, y = y })
  score.player:draw({
    x = x + offset,
    y = y,
    align = "RightTop",
    color = "White"
  })

  y = y + 47

  labels.volforce:draw({ x = x, y = y })

  if score.volforce.increase then
    score.volforce.value:draw({
      x = x + offset - 71,
      y = y + 3,
      align = "RightTop",
      color = "White"
    })
    labels.plus:draw({
      x = x + offset - 65,
      y = y + 12.5,
      color = "Positive"
    })
    score.volforce.increase:draw({
      x = x + offset - 48,
      y = y + 12,
      color = "White",
    })
  else
    score.volforce.value:draw({
      x = x + offset,
      y = y + 3,
      align = "RightTop",
      color = "White"
    })
  end

  y = y + 47

  labels.exScore:draw({ x = x, y = y })
  self.ctx.graphData.exScore:draw({
    x = x + offset - 86,
    y = y + 2,
    color = "White"
  })

  y = y + 47

  labels.maxChain:draw({ x = x, y = y })
  score.maxChain:draw({
    x = x + offset - 86,
    y = y + 2,
    color = "White"
  })
end

---@param dt deltaTime
---@param x number
---@param y number
function ResultsPanel:drawControls(dt, x, y)
  x = x + 1

  local screenshotY = y - 39
  
  if self.window.isPortrait and (self.ctx.scoreCount > 0) then
    screenshotY = y - 50
  end

  if self.ctx.screenshotTimer > 0 then
    self.ctx.screenshotTimer = self.ctx.screenshotTimer - dt

    self.screenshotSaved:draw({
      x = x - 2,
      y = screenshotY - 3,
      color = "White",
    })
    self.screenshotPath:draw({
      x = x - 2 + 196,
      y = screenshotY - 3,
      maxWidth = 774,
      text = self.ctx.screenshotPath,
      update = true,
    })
  else
    self.screenshotControl:draw(x, screenshotY)
  end

  if self.graphs.isSimpleView then
    self.detailedViewControl:draw(x, y + 985)
  else
    self.simpleViewControl:draw(x, y + 985)
  end
end

return ResultsPanel
