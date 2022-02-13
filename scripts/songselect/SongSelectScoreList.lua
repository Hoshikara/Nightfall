local SongSelectScoreListLabels = require("songselect/constants/SongSelectScoreListLabels")
local DimmedNumber = require("common/DimmedNumber")
local Easing = require("common/Easing")
local Grid = require("common/Grid")
local Spinner = require("common/Spinner")

local LocalOrder = {
  "score",
  "grade",
  "clear",
  "date",
}

local OnlineOrder = {
  "score",
  "grade",
  "clear",
  "username",
}

---@class SongSelectScoreList
local SongSelectScoreList = {}
SongSelectScoreList.__index = SongSelectScoreList

---@param ctx SongSelectContext
---@param songCache SongCache
---@param window Window
---@return SongSelectScoreList
function SongSelectScoreList.new(ctx, songCache, window)
  ---@type SongSelectScoreList
  local self = {
    ctx = ctx,
    grid = Grid.new(window),
    labels = {},
    localScores = makeLabel("Medium", "LOCAL SCORES", 40),
    localSpacing = 0,
    onlineScores = makeLabel("Medium", "ONLINE SCORES", 40),
    onlineSpacing = 0,
    shiftAmount = 0,
    shiftEasing = Easing.new(1),
    songCache = songCache,
    text = {
      clear = makeLabel("Medium", "", 32),
      date = makeLabel("Number", "", 30),
      grade = makeLabel("Medium", "", 32),
      score = DimmedNumber.new({ size = 30 }),
      username = makeLabel("JP", "", 25)
    },
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 0,
    h = 0,
  }

  for name, str in pairs(SongSelectScoreListLabels) do
    self.labels[name] = makeLabel("SemiBold", str)
  end

  return setmetatable(self, SongSelectScoreList)
end

function SongSelectScoreList:draw(dt)
  self:setProps()
  self:handleShift(dt)

  gfx.Save()
  gfx.Translate(self.x + (self.shiftAmount * self.shiftEasing.value), self.y)
  self:drawWindow()
  self:drawLists()
  gfx.Restore()
end

function SongSelectScoreList:setProps()
  if self.windowResized ~= self.window.resized then
    local localWidth = 0
    local onlineWidth = 0

    for _, name in ipairs(LocalOrder) do
      localWidth = localWidth + self.labels[name].w
    end

    for _, name in ipairs(OnlineOrder) do
      onlineWidth = onlineWidth + self.labels[name].w
    end

    self.grid:setProps()
    self.x = self.grid.x
    self.y = self.grid.y
    self.w = self.grid.w
    self.h = self.grid.h
    self.localSpacing = (self.w - 104 - localWidth) / 2
    self.onlineSpacing = (self.w - 104 - onlineWidth) / 2
    self.shiftAmount = self.w + self.window.shiftX + self.window.paddingX
    self.windowResized = self.window.resized
  end
end

---@param dt deltaTime
function SongSelectScoreList:handleShift(dt)
  if self.ctx.viewingScores then
    self.shiftEasing:stop(dt, 3, 0.2)
  else
    self.shiftEasing:start(dt, 3, 0.2)
  end
end

function SongSelectScoreList:drawWindow()
  drawRect({
    x = 0,
    y = 0,
    w = self.w,
    h = self.h,
    alpha = 0.65,
    color = "Black",
  })
end

function SongSelectScoreList:drawLists()
  local cachedSong = self.songCache:get(songwheel.songs[self.ctx.currentSong])

  if not cachedSong then
    return
  end

  ---@type CachedDiff
  local cachedDiff = cachedSong.diffs[self.ctx.currentDiff] or cachedSong.diffs[1]
  local labels = self.labels
  local showOnlineScores = true--IRData.Active

  if cachedDiff then
    self:drawScores(labels, cachedDiff.scores, true)
    self:drawScores(labels, cachedDiff.scores, false) 
  end
end

function SongSelectScoreList:drawScores(labels, scores, isLocal, isOnline)
  local x = 37
  local y = 26
  local w = self.w - 80
  local isPortrait = self.window.isPortrait
  local spacing = (self.w - 104) / 4
  local text = self.text

  if isLocal then
    self.localScores:draw({
      x = x,
      y = y,
      color = "White",
    })
  else
    y = 460
    
    self.onlineScores:draw({
      x = x,
      y = y,
      color = "White",
    })
  end

  if not scores then
    return
  end

  x = x + 14
  y = y + 65

  for i, name in ipairs((isLocal and LocalOrder) or OnlineOrder) do
    local tempX = x + ((i - 1) * spacing)

    labels[name]:draw({
      x = tempX,
      y = y,
      color = "Standard",
    })
  end

  y = y + 35

  isOnline = true

  for i, score in ipairs(scores) do
    local tempY = y + ((i - 1) * 45)

    if (i % 2) == 1 then
      drawRect({
        x = x - 11,
        y = tempY - 3,
        w = w,
        h = 45,
        alpha = 0.2,
        color = "Standard",
      })
    end

    -- text.score:draw({
    --   x = x - 1,
    --   y = tempY,
    --   value = score.score,
    -- })
    -- text.grade:draw({
    --   x = x + spacing - 1,
    --   y = tempY - 2,
    --   color = "White",
    --   text = score.grade,
    --   update = true,
    -- })
    -- text.clear:draw({
    --   x = x + (spacing * 2) - 1,
    --   y = tempY - 2,
    --   color = "White",
    --   text = score.clear,
    --   update = true,
    -- })
    
    -- if isLocal then
    --   text.date:draw({
    --     x = x + (spacing * 3) - 1,
    --     y = tempY,
    --     color = "White",
    --     text = score.date,
    --     update = true,
    --   })
    -- else
    --   text.username:draw({
    --     x = x + (spacing * 3) - 1,
    --     y = tempY + 4,
    --     color = "White",
    --     text = score.username,
    --     update = true,
    --   })
    -- end

    if not isLocal then
      if i == 7 then
        break
      end
    else
      if i == ((isPortrait and 18) or 16) then
        break
      end
    end
  end

end

return SongSelectScoreList
