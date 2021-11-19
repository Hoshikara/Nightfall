local formatChart = require("results/helpers/formatChart")
local formatScore = require("results/helpers/formatScore")
local getGraphData = require("results/helpers/getGraphData")

local showHardScores = getSetting("showHardScores", false)

---@class ResultsContext
---@field getPanelRegion function
---@field scores ResultsScore[]
local ResultsContext = {}
ResultsContext.__index = ResultsContext

---@return ResultsContext
function ResultsContext.new()
  ---@type ResultsContext
  local self = {
    chart = nil,
    graphData = nil,
    isSingleplayer = true,
    myScore = nil,
    scores = {},
    scoreCount = 0,
    screenshotPath = "",
    screenshotTimer = 0,
  }

  return setmetatable(self, ResultsContext)
end

---@param data result
function ResultsContext:update(data)
  local isSingleplayer = data.uid == nil

  if not self.chart then
    self.chart = formatChart(data)
  end

  if not self.myScore then
    self.myScore = formatScore(data)
  end

  if isSingleplayer then
    self:reloadPlayerStats(data)
  end

  if isSingleplayer or data.isSelf then
    self.graphData = getGraphData(data)
  end

  self:updateScores(data, isSingleplayer)

  self.isSingleplayer = isSingleplayer
end

---@param data result
function ResultsContext:reloadPlayerStats(data)
  if (data.level >= 10) and (data.badge > 1) and (data.score >= 8700000) then
    game.SetSkinSetting("_reloadPlayerData", 1)
  end
end

---@param data result
---@param isSingleplayer boolean
function ResultsContext:updateScores(data, isSingleplayer)
  local count = 0
  local highScores = data.highScores
  local scores = {}

  if isSingleplayer and showHardScores then
    if (#highScores == 0) and scores[1].hitWindow then
      local newScores = {}
  
      for _, score in ipairs(highScores) do
        if score.hitWindow.perfect < 46 then
          newScores[#newScores + 1] = score
        end
      end
    
      highScores = newScores
    end
  end

  for i, score in ipairs(highScores) do
    scores[i] = formatScore(score, i)

    count = count + 1
  end

  self.scoreCount = count
  self.scores = scores
end

---@param path string
function ResultsContext:handleScreenshot(path)
  self.screenshotPath = path:upper()
  self.screenshotTimer = 5
end

return ResultsContext
