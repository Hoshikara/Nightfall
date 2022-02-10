local Easing = require("common/Easing")
local Grid = require("common/Grid")
local Spinner = require("common/Spinner")

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
    shiftAmount = 0,
    shiftEasing = Easing.new(1),
    songCache = songCache,
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 0,
    h = 0,
  }

  return setmetatable(self, SongSelectScoreList)
end

function SongSelectScoreList:draw(dt)
  self:setProps()
  self:handleShift(dt)

  gfx.Save()
  gfx.Translate(self.x + (self.shiftAmount * self.shiftEasing.value), self.y)
  self:drawWindow()
  gfx.Restore()
end

function SongSelectScoreList:setProps()
  if self.windowResized ~= self.window.resized then
    self.grid:setProps()
    self.x = self.grid.x
    self.y = self.grid.y
    self.w = self.grid.w
    self.h = self.grid.h
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
    isFast = true,
  })
end

return SongSelectScoreList
