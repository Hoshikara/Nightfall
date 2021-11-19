local PlayerStatsKeys = require("playerinfo/constants/PlayerStatsKeys")
local ControlLabel = require("common/ControlLabel")
local Easing = require("common/Easing")
local ItemCount = require("common/ItemCount")
local List = require("common/List")
local Scrollbar = require("common/Scrollbar")

local ceil = math.ceil
local toString = tostring

---@class PlayerClearsOrGrades
---@field category Label
---@field charts FormattedPlayerStatsChart[]
---@field clearLabels Label[]
---@field gradeLabels Label[]
---@field levels Label[]
local PlayerClearsOrGrades = {}
PlayerClearsOrGrades.__index = PlayerClearsOrGrades

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return PlayerClearsOrGrades
function PlayerClearsOrGrades.new(ctx, mouse, window)
  ---@type PlayerClearsOrGrades
  local self = {
    artistLabel = makeLabel("SemiBold", "ARTIST"),
    charts = nil,
    chartsCategory = "clears",
    clearLabel = makeLabel("SemiBold", "CLEAR"),
    clearLabels = {},
    completionControl = ControlLabel.new(
      "MOUSE HOVER",
      "SHOW COMPLETION USING HOVERED TOTAL",
      "MOUSE 1",
      "VIEW CHARTS"
    ),
    completionLabel = makeLabel("SemiBold", "COMPLETION"),
    ctx = ctx,
    currentCategory = nil,
    currentLevel = nil,
    currentPage = 1,
    currentPageCount = ItemCount.new(),
    gradeLabel = makeLabel("SemiBold", "GRADE"),
    gradeLabels = {},
    hoveredAlpha = Easing.new(),
    hoveredCompletedValue = nil,
    hoveredCompletion = nil,
    hoveredKey = "",
    hoveredRow = 0,
    isHovering = false,
    levelLabel = makeLabel("SemiBold", "LEVEL"),
    levels = { [21] = makeLabel("Medium", "ALL", 29) },
    list = List.new(),
    mouse = mouse,
    pageControl = ControlLabel.new("KNOB-R", "NEXT / PREVIOUS PAGE"),
    pageCount = 1,
    pageItemCount = 12,
    scoreLabel = makeLabel("SemiBold", "SCORE"),
    scrollbar = Scrollbar.new(),
    titleLabel = makeLabel("SemiBold", "TITLE"),
    window = window,
    windowResized = nil,
  }

  for i, clear in ipairs(PlayerStatsKeys.Clears) do
    self.clearLabels[i] = makeLabel("SemiBold", clear)
  end

  for i, grade in ipairs(PlayerStatsKeys.Grades) do
    self.gradeLabels[i] = makeLabel("SemiBold", grade)
  end

  for i = 1, 20 do
    self.levels[i] = makeLabel("Number", i, 27)
  end

  return setmetatable(self, PlayerClearsOrGrades)
end

---@param dt deltaTime
---@param x number
---@param y number
---@param w number
---@param stats FormattedPlayerStatsClears|FormattedPlayerStatsGrades
---@param category string
function PlayerClearsOrGrades:draw(dt, x, y, w, stats, category)
  local labels, subcategories = self:getSubcategories(category)

  self:setProps()

  if (self.ctx.currentView ~= "Charts") and self.charts then
    self:resetProps()
  end

  if self.ctx.currentView == "Charts" then
    self:drawCharts(dt, x, y, w)

    if self.pageCount > 1 then
      self.pageControl:draw(x + 226, self.window.footerY)
    end
  else
    y = y + 83

    self:drawRows(x, y, w, stats)
    self:handleHover(dt, stats, subcategories)
    self:drawStats(x, y, labels, stats, category, subcategories)

    self.completionControl:draw(x + 226, self.window.footerY, 1, self.isHovering)
  end
end

function PlayerClearsOrGrades:setProps()
  if self.windowResized ~= self.window.resized then
    self.list:setProps({
      pageItemCount = 1,
      pageSize = 59 * self.pageItemCount,
    })
    self.scrollbar:setProps({
      x = self.window.w - (self.window.paddingX / 2) - 4,
      y = 317,
      h = 59 * self.pageItemCount,
    })

    self.windowResized = self.window.resized
  end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param w number
function PlayerClearsOrGrades:drawCharts(dt, x, y, w)
  local list = self.list
  local pageItemCount = self.pageItemCount

  self:drawChartsHeading(x, y)
  list:update(dt, { currentItem = self.currentPage })

  if self.pageCount > 1 then
    self.scrollbar:draw(dt, {
      currentItem = self.currentPage,
      totalItems = self.pageCount - 1,
    })
    self.currentPageCount:draw({
      x = self.window.w - self.window.paddingX,
      y = self.window.footerY - 2,
      currentItem = self.currentPage,
      totalItems = self.pageCount,
    })
  end

  y = y + 167 + list.offset

  for i, chart in ipairs(self.charts) do
    if list:isOnPage(i, pageItemCount) then
      self:drawChart(x, y, w, i, chart)
    end

    y = y + 59
  end
end

---@param x number
---@param y number
function PlayerClearsOrGrades:drawChartsHeading(x, y)
  y = y + 43

  self.levelLabel:draw({
    x = x + 19,
    y = y,
    color = "Standard",
  })
  self.currentLevel:draw({
    x = x + 18,
    y = y + 32,
    color = "White",
  })

  if self.chartsCategory == "clears" then
    self.clearLabel:draw({
      x = x + 199,
      y = y,
      color = "Standard",
    })
  else
    self.gradeLabel:draw({
      x = x + 199,
      y = y,
      color = "Standard",
    })
  end
  
  self.currentCategory:draw({
    x = x + 198,
    y = y + 30,
    color = "White",
    font = "Medium",
    size = 29,
    update = true,
  })

  y = y + 84

  self.scoreLabel:draw({
    x = x + 19,
    y = y,
    color = "Standard",
  })
  self.titleLabel:draw({
    x = x + 200,
    y = y,
    color = "Standard",
  })
  self.artistLabel:draw({
    x = x + 1002,
    y = y,
    color = "Standard",
  })
end

---@param x number
---@param y number
---@param w number
---@param itemIndex integer
---@param chart FormattedPlayerStatsChart
function PlayerClearsOrGrades:drawChart(x, y, w, itemIndex, chart)
  if (itemIndex % 2) == 1 then
    drawRect({
      x = x,
      y = y,
      w = w,
      h = 59,
      alpha = 0.2,
      color = "Standard",
    })
  end

  chart.score:draw({ x = x + 17, y = y + 12 })
  chart.title:draw({
    x = x + 199,
    y = y + 14,
    maxWidth = 738,
    color = "White",
  })
  chart.artist:draw({
    x = x + 1001,
    y = y + 14,
    maxWidth = 738,
    color = "White",
  })
end

---@param x number
---@param y number
---@param w number
---@param stats FormattedPlayerStatsClears|FormattedPlayerStatsGrades
function PlayerClearsOrGrades:drawRows(x, y, w, stats)
  local hoveredAlpha = self.hoveredAlpha.value
  local hoveredRow = self.hoveredRow
  local isHovering = hoveredRow ~= 0
  local levels = self.levels

  self.levelLabel:draw({
    x = x + 19,
    y = y - 40,
    color = "Standard",
  })
  self.completionLabel:draw({
    x = x + 1456,
    y = y - 40,
    color = "Standard",
  })

  for i = 10, 21 do
    ---@type FormattedPlayerStatsLevel
    local currentLevel = stats[toString(i)]
    local tempY = y + ((i - 10) * 59)

    if (i % 2) == 0 then
      drawRect({
        x = x,
        y = tempY,
        w = w,
        h = 59,
        alpha = 0.2,
        color = "Standard",
      })
    end

    tempY = tempY + 12

    levels[i]:draw({
      x = x + 18,
      y = tempY + (((i == 21) and -2) or 0),
      alpha = (isHovering and (i ~= hoveredRow) and (1 - (0.8 * hoveredAlpha))) or 1,
      color = "Standard",
    })

    self:drawCompletion(x, tempY, hoveredAlpha, currentLevel, i == hoveredRow)
  end
end

---@param x number
---@param y number
---@param alpha number
---@param level FormattedPlayerStatsLevel
---@param isHovering boolean
function PlayerClearsOrGrades:drawCompletion(x, y, alpha, level, isHovering)
  if isHovering then
    level.count:draw({
      x = x + 1622,
      y = y,
      align = "RightTop",
      alpha = 1 - alpha,
      currentItem = level.completedValue,
    })
    level.completion:draw({
      x = x + 1740,
      y = y,
      align = "RightTop",
      alpha = 1 - alpha,
      color = "White",
    })
    level.count:draw({
      x = x + 1622,
      y = y,
      align = "RightTop",
      alpha = alpha,
      currentItem = self.hoveredCompletedValue,
    })
    self.hoveredCompletion:draw({
      x = x + 1740,
      y = y,
      align = "RightTop",
      alpha = alpha,
      color = "White",
    })
  else
    level.count:draw({
      x = x + 1622,
      y = y,
      align = "RightTop",
      alpha = 1 - (0.8 * alpha),
      currentItem = level.completedValue,
    })
    level.completion:draw({
      x = x + 1740,
      y = y,
      align = "RightTop",
      alpha = 1 - (0.8 * alpha),
      color = "White",
    })
  end
end

---@param dt deltaTime
---@param stats FormattedPlayerStatsClears|FormattedPlayerStatsGrades
---@param subcategories string[]
function PlayerClearsOrGrades:handleHover(dt, stats, subcategories)
  local hoveredAlpha = self.hoveredAlpha.value
  local hoveredKey = self.hoveredKey
  
  for _, subcategory in ipairs(subcategories) do
    local currentStats = stats[subcategory]

    for i = 10, 21 do
      ---@type FormattedPlayerStatsLevel
      local currentLevel = currentStats[toString(i)]

      if (hoveredKey ~= "") and (hoveredKey ~= currentLevel.key) then
        currentLevel.alpha = 1 - (0.8 * hoveredAlpha)
      else
        currentLevel.alpha = 1
      end
    end
  end

  if self.isHovering then
    self.hoveredAlpha:start(dt, 3, 0.2)
  else
    self.hoveredAlpha:stop(dt, 3, 0.2)
  end

  if hoveredAlpha == 0 then
    self.hoveredCompletedValue = nil
    self.hoveredCompletion = nil
    self.hoveredKey = ""
    self.hoveredRow = 0
  end

  self.isHovering = false
end

---@param x number
---@param y number
---@param stats FormattedPlayerStatsClears|FormattedPlayerStatsGrades
---@param labels Label[]
---@param category string
---@param subcategories string[]
function PlayerClearsOrGrades:drawStats(x, y, labels, stats, category, subcategories)
  local mouse = self.mouse
  local notChoosingFolder = not self.ctx.choosingFolder
  local offsetX = 1317 / 5

  if category == "grades" then
    offsetX = 1317 / 7
  end

  x = x + 142
  y = y + 12
  
  for i, subcategory in ipairs(subcategories) do
    local tempX = x + ((i - 1) * offsetX)

    labels[i]:draw({
      x = tempX,
      y = y - 52,
      color = "Standard",
      font = "SemiBold",
      size = 20,
      update = true,
    })

    for j = 10, 21 do
      ---@type FormattedPlayerStatsLevel
      local currentLevel = stats[subcategory][toString(j)]
      local tempY = y + ((j - 10) * 59)

      currentLevel.completed:draw({
        x = tempX,
        y = tempY,
        alpha = currentLevel.alpha,
        color = "White",
      })

      if currentLevel.isHoverable
        and mouse:clipped(tempX - 6, tempY, currentLevel.completed.w + 11, 35)
        and notChoosingFolder
      then
        self.isHovering = true
        self.hoveredCompletedValue = currentLevel.completedValue
        self.hoveredCompletion = currentLevel.completion
        self.hoveredKey = currentLevel.key
        self.hoveredRow = j

        self.ctx.btnEvent = function()
          self.ctx.currentView = "Charts"
          self.ctx.currentTab = 1
          self.charts = currentLevel.charts
          self.chartsCategory = category
          self.currentCategory = labels[i]
          self.currentLevel = self.levels[j]
        end
      end
    end
  end
end

---@param category string
---@return Label[], string[]
function PlayerClearsOrGrades:getSubcategories(category)
  if category == "clears" then
    return self.clearLabels, PlayerStatsKeys.Clears
  end

  return self.gradeLabels, PlayerStatsKeys.Grades
end

function PlayerClearsOrGrades:handleInput()
  if self.charts then
    self.pageCount = ceil(#self.charts / self.pageItemCount)
  end

  self.ctx.tabCount = self.pageCount
  self.currentPage = self.ctx.currentTab
end

function PlayerClearsOrGrades:resetProps()
  self.currentCategory = nil
  self.currentLevel = nil
  self.charts = nil
end

return PlayerClearsOrGrades
