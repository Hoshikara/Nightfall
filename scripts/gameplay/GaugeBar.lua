local GaugeProperties = require("common/constants/GaugeProperties")

local JsonTable = require("common/JsonTable")

local abs = math.abs
local cos = math.cos

local SAMPLE_INTERVAL = 1 / 255

---@class GaugeBar
local GaugeBar = {}
GaugeBar.__index = GaugeBar

---@param ctx GameplayContext
---@param window Window
---@return GaugeBar
function GaugeBar.new(ctx, window)
  ---@type GaugeBar
  local self = {
    ctx = ctx,
    gaugeType = nil,
    level = makeLabel("Number", "0", 24),
    name = makeLabel("Medium", "", 30),
    percentage = makeLabel("Number", "0"),
    samplesIndex = 1,
    samples = {},
    samplesData = JsonTable.new("samples"),
    samplesProgress = 0,
    samplesSaved = false,
    saveChange = true,
    warnTimer = 0,
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 20,
    h = 560,
  }

  return setmetatable(self, GaugeBar)
end

---@param dt deltaTime
function GaugeBar:draw(dt)
  self:setProps()

  local gaugeType = gameplay.gauge.type
  local gaugeValue = gameplay.gauge.value

  self:collectSamples(gaugeType, gaugeValue)

  gfx.Save()
  gfx.Translate(self.x, self.y - (128 * self.ctx.introOffset))
  self:drawGaugeBar(dt, gaugeType, gaugeValue)
  gfx.Restore()
end

function GaugeBar:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.x = 963
      self.y = 592
    else
      self.x = 1592
      self.y = 332
    end

    self.windowResized = self.window.resized
  end
end

function GaugeBar:drawGaugeBar(dt, gaugeType, gaugeValue)
  local alpha, color, name, threshold = self:getGaugeInfo(dt, gaugeType, gaugeValue)
  local introAlpha = self.ctx.introAlpha
  local w = self.w
  local h = self.h

  self:drawBar(w, h, alpha, color, gaugeValue, threshold)
  self:drawPercentage(w, h, gaugeValue, introAlpha)
  self:drawName(h, introAlpha, name, threshold)
end

---@param w number
---@param h number
---@param alpha number
---@param color Color
---@param gaugeValue number
---@param threshold number
function GaugeBar:drawBar(w, h, alpha, color, gaugeValue, threshold)
  drawRect({
    w = w,
    h = h,
    alpha = 1,
    color = "Black",
  })
  drawRect({
    y = h,
    w = w,
    h = -(h * gaugeValue),
    alpha = alpha,
    color = color,
  })
  drawRect({
    w = w,
    h = h,
    alpha = 0,
    stroke = {
      alpha = alpha,
      color = "White",
      size = 2,
    },
  })
  drawRect({
    y = (h * (1 - threshold)) - 1.5,
    w = w,
    h = 3,
    color = "White",
  })
end

---@param w number
---@param h number
---@param gaugeValue number
---@param introAlpha number
function GaugeBar:drawPercentage(w, h, gaugeValue, introAlpha)
  local template = "%.1f%%"

  if gaugeValue < 0.1 then
    template = "%.2f%%"
  end

  self.percentage:draw({
    x = -9,
    y = h - (h * gaugeValue) - 11,
    align = "RightTop",
    alpha = introAlpha,
    color = "White",
    text = template:format(gaugeValue * 100),
    update = true,
  })
end

---@param h number
---@param introAlpha number
---@param name string
---@param threshold number
function GaugeBar:drawName(h, introAlpha, name, threshold)
  local align = "LeftTop"
  local position = -3

  if threshold > 0.3 then
    align = "RightTop"
    position = h + 2
  end

  gfx.BeginPath()
  gfx.Rotate(90)
  self.name:draw({
    x = position,
    y = -59,
    align = align,
    alpha = introAlpha,
    color = "White",
    text = name,
    update = true,
  })
  gfx.Rotate(-90)
end

---@param dt deltaTime
---@param gaugeType integer
---@param value number
---@return number, Color, boolean, string, number
function GaugeBar:getGaugeInfo(dt, gaugeType, value)
  local props = GaugeProperties[gaugeType]
  local alpha = 1
  local color = props.colorPass
  local name = props.name
  local threshold = props.threshold

  if value < threshold then
    color = props.colorFail

    if props.warn then
      self.warnTmer = self.warnTimer + dt

      alpha = abs(cos(self.warnTimer * 12))
    end
  end

  if props.hasLevels then
    name = name .. (" [ %.1f ]"):format(gameplay.gauge.options * 0.5)
  end

  if (gaugeType > 0) and (getSetting("_arsEnabled", 0) == 1) then
    name = name .. " + ARS"
  end
  
  return alpha, color, name, threshold
end

---@param gaugeType integer
---@param gaugeValue number
function GaugeBar:collectSamples(gaugeType, gaugeValue)
  if gameplay.progress == 0 then
    self:resetSamplesInfo()
  end

  self:setChangePoint(gaugeType)
  self:updateSamplesInfo(gaugeValue)
  self:saveSamples()
end

function GaugeBar:resetSamplesInfo()
  self.gaugeType = nil
  self.samples = {}
  self.samplesIndex = 1
  self.samplesProgress = 0
  self.saveChange = true

  game.SetSkinSetting('_gaugeChange', -1)
end

---@param gaugeType integer
function GaugeBar:setChangePoint(gaugeType)
  if not self.gaugeType then
    self.gaugeType = gaugeType
  end

  if self.saveChange and (self.gaugeType ~= 0) and (gaugeType == 0) then
    game.SetSkinSetting("_gaugeSwapIndex", math.max(0, self.samplesIndex - 1))

    self.saveChange = false
  end
end

---@param gaugeValue number
function GaugeBar:updateSamplesInfo(gaugeValue)
  if gameplay.progress >= self.samplesProgress then
    self.samples[self.samplesIndex] = gaugeValue
    self.samplesIndex = self.samplesIndex + 1
    self.samplesProgress = self.samplesProgress + SAMPLE_INTERVAL
  end
end

function GaugeBar:saveSamples()
  if (gameplay.progress == 1) and (not self.samplesSaved) then
    self.samplesData:overwriteContents(self.samples)

    self.samplesSaved = true
  end
end

return GaugeBar
