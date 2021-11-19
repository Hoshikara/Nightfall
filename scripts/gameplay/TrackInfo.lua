local LaneSpeed = require("gameplay/LaneSpeed")
local didPress = require("common/helpers/didPress")

local Green = { 120, 240, 80 }

local floor = math.floor
local min = math.min

---@class TrackInfo
local TrackInfo = {}
TrackInfo.__index = TrackInfo

---@param ctx GameplayContext
---@param window Window
---@return TrackInfo
function TrackInfo.new(ctx, window)
  ---@type TrackInfo
  local self = {
    asterisk = makeLabel("Medium", "*", 27),
    bpmHint = makeLabel("Number", "", 27),
    bpmIndex = 1,
    bpmLabel = makeLabel("Medium", "BPM", 30),
    bpmValue = makeLabel("Number", "0", 27),
    ctx = ctx,
    currentDuration = makeLabel("Number", "00:00", 19),
    currentDurationValue = "00:00",
    currentTime = 0,
    equalSign = makeLabel("Medium", "=", 27),
    isSlowingDown = false,
    laneSpeed = LaneSpeed.new(window),
    laneSpeedColor = "White",
    laneSpeedHint = makeLabel("Number", "", 27),
    laneSpeedHintValue = "",
    laneSpeedLabel = makeLabel("Medium", "LANE-SPEED", 30),
    laneSpeedMultiplier = makeLabel("Number", "0", 27),
    laneSpeedValue = makeLabel("Number", "0", 27),
    multiplierColor = Green,
    nextTime = 0,
    playbackSpeed = makeLabel("Number", "0", 27),
    totalDuration = makeLabel("Number", "/ 00:00", 19),
    testDuration = makeLabel("Number", "00:00 / 00:00", 19),
    totalDurationValue = "/ 00:00",
    totalTime = 0,
    window = window,
    windowResized = nil,
  }

  return setmetatable(self, TrackInfo)
end

---@param dt deltaTime
---@param x number
---@param w number
---@param introAlpha number
function TrackInfo:draw(dt, x, w, introAlpha)
  local isPortrait = self.window.isPortrait

  x = x + 20

  self:updateTime(dt)
  self:drawProgressBar(x, w, introAlpha)
  self:drawBpm(x, w, introAlpha, isPortrait)
  self:drawLaneSpeed(x, w, introAlpha, isPortrait)

  if self.ctx.bpmData then
    self:drawHints(x, w, isPortrait)
  end

  if didPress("STA") and (not gameplay.practice_setup) then
    self.laneSpeed:draw({
      hintText = self.laneSpeedHintValue,
      isSlowingDown = self.isSlowingDown,
      laneSpeedColor = self.laneSpeedColor,
      multiplierColor = self.multiplierColor,
    })
  end
end

---@param dt deltaTime
function TrackInfo:updateTime(dt)
  if gameplay.practice_setup == nil then
    local progress = gameplay.progress

    if (progress > 0) and (progress < 1) then
      self.currentTime = self.currentTime + dt

      local totalTime = floor((1 / progress) * self.currentTime)

      if self.totalTime ~= totalTime then
        self.totalDurationValue = ("/ %02d:%02d"):format(floor(totalTime / 60), floor(totalTime % 60))
        
        self.totalTimer = totalTime
      end
    elseif progress == 0 then
      self.currentTime = 0
    end

    self.currentDurationValue = ("%02d:%02d"):format(floor(self.currentTime / 60), floor(self.currentTime % 60))
  end
end

---@param x number
---@param w number
---@param introAlpha number
function TrackInfo:drawProgressBar(x, w, introAlpha)
  drawRect({
    x = x,
    y = 89,
    w = w,
    h = 21,
    alpha = introAlpha,
    color = "Medium",
  })
  drawRect({
    x = x,
    y = 89,
    w = w * gameplay.progress,
    h = 21,
    alpha = introAlpha,
    color = "Standard",
  })
  self:drawDuration(x, w, introAlpha)
end

---@param x number
---@param w number
---@param introAlpha number
function TrackInfo:drawDuration(x, w, introAlpha)
  x = x + w

  self.currentDuration:draw({
    x = x - 76,
    y = 87,
    align = "RightTop",
    alpha = introAlpha,
    color = "White",
    text = self.currentDurationValue,
    update = true,
  })
  self.totalDuration:draw({
    x = x - 3,
    y = 87,
    align = "RightTop",
    alpha = introAlpha,
    color = "White",
    text = self.totalDurationValue,
    update = true,
  })
end

---@param x number
---@param w number
---@param introAlpha number
---@param isPortrait boolean
function TrackInfo:drawBpm(x, w, introAlpha, isPortrait)
  local bpm = gameplay.bpm
  local playbackSpeed = gameplay.playbackSpeed or 1
  local playbackText = ""
  local y = 0

  if isPortrait then
    x = x + 7
    y = 187
  else
    x = x + w + 1
  end

  if playbackSpeed < 1 then
    bpm = floor(bpm * playbackSpeed)
    playbackText = ("[ %d%% ]"):format(floor((playbackSpeed * 100) + 0.5))
  end

  self.bpmLabel:draw({
    x = x - 168,
    y = y + 121,
    alpha = introAlpha,
    align = "RightTop",
    color = "Standard",
  })
  self.bpmValue:draw({
    x = x,
    y = y + 124,
    align = "RightTop",
    alpha = introAlpha,
    color = "White",
    text = ("%.0f"):format(bpm),
    update = true,
  })
  self.playbackSpeed:draw({
    x = x + 9,
    y = y + 124,
    align = "LeftTop",
    alpha = introAlpha,
    color = "White",
    text = playbackText,
    update = true,
  })
end

---@param x number
---@param w number
---@param introAlpha number
---@param isPortrait boolean
function TrackInfo:drawLaneSpeed(x, w, introAlpha, isPortrait)
  local y = 0

  self.laneSpeedColor = "White"
  self.multiplierColor = Green

  if isPortrait then
    x = x + 7
    y = 187
  else
    x = x + w + 1
  end

  if didPress("STA") then
    if gameplay.hispeedAdjust and (gameplay.hispeedAdjust == 2) then
      self.laneSpeedColor = Green
      self.multiplierColor = "White"
    end

    self.equalSign:draw({
      x = x - 72,
      y = y + 164,
      alpha = introAlpha,
      align = "RightTop",
      color = "White",
    })
    self.laneSpeedMultiplier:draw({
      x = x - 95,
      y = y + 165,
      alpha = introAlpha,
      align = "RightTop",
      color = self.multiplierColor,
      text = ("%.2f"):format(gameplay.hispeed),
      update = true,
    })
    self.asterisk:draw({
      x = x - self.laneSpeedMultiplier.w - 101,
      y = y + 162,
      alpha = introAlpha,
      align = "RightTop",
      color = "White",
      update = true,
    })
    self.bpmValue:draw({
      x = x - self.laneSpeedMultiplier.w - 119,
      y = y + 165,
      alpha = introAlpha,
      align = "RightTop",
      color = "White",
      text = ("%.0f"):format(gameplay.bpm),
      update = true,
    })
  else
    self.laneSpeedLabel:draw({
      x = x - 72,
      y = y + 162,
      alpha = introAlpha,
      align = "RightTop",
      color = "Standard",
    })
  end

  self.laneSpeedValue:draw({
    x = x,
    y = y + 165,
    align = "RightTop",
    alpha = introAlpha,
    color = self.laneSpeedColor,
    text = ("%.2f"):format(gameplay.bpm * gameplay.hispeed * 0.01),
    update = true,
  })
end

---@param x number
---@param w number
---@param isPortrait boolean
function TrackInfo:drawHints(x, w, isPortrait)
  local bpmHint, laneSpeedHint = self:getHints()
  local color = (self.isSlowingDown and "Positive") or "Negative"
  local y = 0

  if isPortrait then
    x = x + 7
    y = 187
  else
    x = x + w + 1
  end

  self.bpmHint:draw({
    x = x + 9,
    y = y + 124,
    align = "LeftTop",
    color = color,
    text = bpmHint,
    update = true,
  })
  self.laneSpeedHint:draw({
    x = x + 9,
    y = y + 165,
    align = "LeftTop",
    color = color,
    text = laneSpeedHint,
    update = true,
  })
end

---@return string, string
function TrackInfo:getHints()
  self:resetProps()

  local bpmPoint = self.ctx.bpmData[self.bpmIndex]

  if not bpmPoint then
    return
  end

  local bpmHint = ""
  local hintTime = bpmPoint.time
  local laneSpeedHint = ""
  local nextBpmPoint = self.ctx.bpmData[self.bpmIndex + 1]

  if nextBpmPoint then
    self.nextTime = min(hintTime + 2.5, nextBpmPoint.time)
  else
    self.nextTime = hintTime + 2.5
  end

  if self.currentTime >= hintTime then
    local bpm = bpmPoint.bpm

    if hintTime > 0 then
      bpmHint = ("> %.0f"):format(bpm)
      laneSpeedHint = ("> %.2f"):format(bpm * gameplay.hispeed * 0.01)

      self.isSlowingDown = bpm < gameplay.bpm
      self.laneSpeedHintValue = ("> %.2f   %.2f"):format(bpm * gameplay.hispeed * 0.01, gameplay.hispeed)
    end

    if self.currentTime >= self.nextTime then
      self.bpmIndex = self.bpmIndex + 1
    end
  end

  return bpmHint, laneSpeedHint
end

function TrackInfo:resetProps()
  self.laneSpeedHintValue = ""
  self.isSlowingDown = false

  if gameplay.progress == 0 then
    self.bpmIndex = 1
    self.nextTime = 0
  end
end

return TrackInfo
