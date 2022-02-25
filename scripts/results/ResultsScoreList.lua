local ResultsScoreListLabels = require("results/constants/ResultsScoreListLabels")
local ControlLabel = require("common/ControlLabel")
local ItemCount = require("common/ItemCount")
local ItemCursor = require("common/ItemCursor")
local List = require("common/List")
local Scrollbar = require("common/Scrollbar")
local Spinner = require("common/Spinner")
local advanceSelection = require("common/helpers/advanceSelection")
local didPress = require("common/helpers/didPress")

local RatingOrder = {
  "critical",
  "near",
  "error",
}

local StatOrder = {
  "grade",
  "gauge",
  "hitWindows",
}

---@class ResultsScoreList
local ResultsScoreList = {}
ResultsScoreList.__index = ResultsScoreList

---@param ctx ResultsContext
---@param window Window
---@return ResultsScoreList
function ResultsScoreList.new(ctx, window)
  ---@type ResultsScoreList
  local self = {
    ctx = ctx,
    currentScore = 1,
    didPressBTD = false,
    didPressFXL = false,
    didPressFXR = false,
    errorMessage = makeLabel("SemiBold", ""),
    itemCursor = ItemCursor.new({
      size = 18,
      stroke = 2,
      type = "Vertical",
    }),
    labels = {},
    list = List.new(),
    margin = 0,
    pageItemCount = 5,
    scoreCount = ItemCount.new(),
    scrollbar = Scrollbar.new(),
    selectScore = ControlLabel.new("FX-L / FX-R", "SELECT SCORE"),
    spinner = Spinner.new({ radius = 48, thickness = 6 }),
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 0,
    h = {
      closed = 127,
      open = 256,
      total = 0,
    },
  }

  for name, str in pairs(ResultsScoreListLabels) do
    self.labels[name] = makeLabel("Medium", str, 29)
  end

  return setmetatable(self, ResultsScoreList)
end

---@param dt deltaTime
function ResultsScoreList:draw(dt)
  self:setProps()

  local currentScore = self.currentScore
  local viewingOnlineScores = self.ctx.viewingOnlineScores
  local scoreCount = (viewingOnlineScores and self.ctx.onlineScoreCount)
    or self.ctx.scoreCount

  self:handleInput(scoreCount)

  gfx.Save()

  if viewingOnlineScores and (self.ctx.irState == "LOADING") then
    self.spinner:draw(dt, self.x + (self.w * 0.5) + 14, self.y + (self.h.total * 0.5) + 16)
  elseif viewingOnlineScores and (self.ctx.irState == "ERROR") then
    self.errorMessage:draw({
      x = self.x + (self.w * 0.5),
      y = self.y + (self.h.total * 0.5),
      align = "CenterMiddle",
      color = "Negative",
      text = ("ERROR: %s (%d)"):format(result.irDescription, result.irState),
      update = true,
    })
  elseif scoreCount > 0 then
    self.list:update(dt, {
      currentItem = currentScore,
      isPortrait = self.window.isPortrait,
    })
    self:drawList(currentScore)
    self.itemCursor:draw(dt, {
      h = self.h.closed,
      currentItem = currentScore,
      totalItems = self.pageItemCount,
    })
  
    if scoreCount > self.pageItemCount then
      self.scrollbar:draw(dt, {
        currentItem = currentScore,
        totalItems = scoreCount
      })
    end
  end

  if scoreCount > 1 then
    self:drawFooter(currentScore, scoreCount)
  end

  gfx.Restore()
end

function ResultsScoreList:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.x = self.window.paddingX
      self.y = 1128
      self.w = self.window.w - (self.window.paddingX * 2)
      self.h.total = 712
      self.pageItemCount = 4
    else
      self.x = 1128
      self.y = self.window.paddingY
      self.w = 712
      self.h.total = self.window.h - (self.window.paddingY * 2)
      self.pageItemCount = 5
    end

    local availableSpace = self.h.total
      - self.h.open
      - ((self.h.closed) * (self.pageItemCount - 1))

    self.margin = availableSpace / (self.pageItemCount - 1)

    self.itemCursor:setProps({
      x = self.x,
      y = self.y,
      w = self.w,
      h = self.h.open,
      margin = self.margin,
    })
    self.list:setProps({
      pageItemCount = self.pageItemCount,
      pageSize = self.h.total - self.h.open + self.h.closed + self.margin,
    })
    self.scrollbar:setProps({
      x = self.window.w - (self.window.paddingX / 2) - 4,
      y = self.y,
      h = self.h.total,
      pageItemCount = self.pageItemCount
    })

    self.windowResized = self.window.resized
  end
end

---@param scoreCount integer
function ResultsScoreList:handleInput(scoreCount)
  if scoreCount > 1 then
    if (not self.didPressBTD) and didPress("BTD") then
      self.currentScore = 1
    end

    if (not self.didPressFXL) and didPress("FXL") then
      self.currentScore = advanceSelection(self.currentScore, scoreCount, -1)
    end

    if (not self.didPressFXR) and didPress("FXR") then
      self.currentScore = advanceSelection(self.currentScore, scoreCount, 1)
    end

    self.didPressBTD = didPress("BTD")
    self.didPressFXL = didPress("FXL")
    self.didPressFXR = didPress("FXR")
  end
end

---@param currentScore integer
function ResultsScoreList:drawList(currentScore)
  local closedHeight = self.h.closed
  local openHeight = self.h.open
  local isSingleplayer = self.ctx.isSingleplayer
  local labels = self.labels
  local list = self.list
  local margin = self.margin
  local offset = (self.window.isPortrait and 128) or 0
  local scores = (self.ctx.viewingOnlineScores and self.ctx.onlineScores) or self.ctx.scores
  local x = self.x
  local y = self.y + list.offset
  local w = self.w

  for i, score in ipairs(scores) do
    local isCurrent = i == currentScore
    local h = (isCurrent and openHeight) or closedHeight

    if list:isOnPage(i) then
      self:drawScore(score, x, y, w, h, offset, labels, isCurrent, isSingleplayer)
    end

    y = y + h + margin
  end
end

---@param score ResultsScore
---@param x number
---@param y number
---@param w number
---@param h number
---@param offset number
---@param labels table<string, Label>
---@param isCurrent boolean
---@param isSingleplayer boolean
function ResultsScoreList:drawScore(score, x, y, w, h, offset, labels, isCurrent, isSingleplayer)
  x = x + 26 + (offset / 2)
  y = y + 6

  drawRect({
    x = x - 26 - (offset / 2),
    y = y - 6,
    w = w,
    h = h,
    alpha = 0.8,
    color = "Black",
  })

  score.score:draw({ x = x, y = y })

  if isSingleplayer then
    labels.date:draw({ x = x + 430 + offset, y = y + 16 })
    score.date:draw({
      x = x + 656 + offset,
      y = y + 18,
      align = "RightTop",
      color = "White",
    })
  else
    labels.player:draw({ x = x + 430 + offset, y = y + 16 })
    score.player:draw({
      x = x + 656 + offset,
      y = y + 16,
      align = "RightTop",
      color = "White",
      maxWidth = 105,
    })
  end

  labels.clear:draw({ x = x + 430 + offset, y = y + 60 })
  score.clear:draw({
    x = x + 656 + offset,
    y = y + 60,
    align = "RightTop",
    color = "White",
  })

  if isCurrent then
    for i, rating in ipairs(RatingOrder) do
      local tempY = y + 103 + ((i - 1) * 43)

      labels[rating]:draw({ x = x + 4, y = tempY })
      score[rating]:draw({
        x = x + 231,
        y = tempY + 2,
        align = "RightTop",
        color = "White",
      })
    end

    for i, stat in ipairs(StatOrder) do
      local tempY = y + 103 + ((i - 1) * 43)

      if (not score[stat]) and (stat == "hitWindows") then
        stat = "player"
      end
      
      if score[stat] then
        local offsetY = (((stat == "grade") or (stat == "player")) and 0) or 2

        labels[stat]:draw({ x = x + 344 + offset, y = tempY })
        score[stat]:draw({
          x = x + 655 + offset,
          y = tempY + offsetY,
          align = "RightTop",
          color = "White",
        })
      end
    end
  end
end

---@param currentScore integer
---@param scoreCount integer
function ResultsScoreList:drawFooter(currentScore, scoreCount)
  local y = self.window.footerY

  self.selectScore:draw(self.x, y)
  self.scoreCount:draw({
    x = self.window.w - self.window.paddingX,
    y = y - 2,
    currentItem = currentScore,
    totalItems = scoreCount,
  })
end

return ResultsScoreList
