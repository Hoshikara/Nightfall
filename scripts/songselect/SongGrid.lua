--#region Require

local Grid = require("common/Grid")
local ItemCount = require("common/ItemCount")
local ItemCursor = require("common/ItemCursor")
local List = require("common/List")
local Scrollbar = require("common/Scrollbar")

--#endregion

local floor = math.floor
local min = math.min

---@param itemIndex integer
---@return integer
local function getColumn(itemIndex)
  return floor((itemIndex - 1) % 3)
end

---@class SongGrid
local SongGrid = {}
SongGrid.__index = SongGrid

---@param ctx SongSelectContext
---@param songCache SongCache
---@param window Window
---@return SongGrid
function SongGrid.new(ctx, songCache, window)
  ---@type SongGrid
  local self = {
    breakpointText = makeLabel("Number", "", 20),
    ctx = ctx,
    gradeText = makeLabel("Medium", "", 40),
    grid = Grid.new(window),
    itemCursor = ItemCursor.new({
      size = 18,
      speed = 8,
      stroke = 1.5,
      type = "Grid",
    }),
    list = List.new(),
    noSongsText = makeLabel("Medium", "NO SONGS FOUND", 80),
    scrollbar = Scrollbar.new(),
    songCache = songCache,
    songCount = ItemCount.new(),
    topText = makeLabel("Medium", "TOP"),
    window = window,
    windowResized = nil,
  }

  return setmetatable(self, SongGrid)
end

---@param dt deltaTime
function SongGrid:draw(dt)
  local currentSong = self.ctx.currentSong
  local songCount = self.ctx.songCount

  self:setProps()

  gfx.Save()

  if songCount > 0 then
    local isPortrait = self.window.isPortrait
    local params = {
      currentItem = currentSong,
      isPortrait = isPortrait,
      totalItems = songCount,
    }

    self.list:update(dt, params)
    self:drawGrid(currentSong)
    self.itemCursor:draw(dt, params)

    if songCount > self.ctx.pageItemCount then
      self.scrollbar:draw(dt, params)
    end
      
    self:drawSongAmounts(currentSong, songCount)
  else
    self.noSongsText:draw({
      x = self.window.w / 2,
      y = self.window.h / 2,
      align = "CenterMiddle",
      color = "White",
    })
  end

  gfx.Restore()
end

function SongGrid:setProps()
  if self.windowResized ~= self.window.resized then
    self.grid:setProps()
    self.itemCursor:setProps({
      x = self.grid.x,
      y = self.grid.y,
      w = self.grid.jacketSize,
      h = self.grid.jacketSize,
      margin = self.grid.margin,
    })
    self.list:setProps({
      pageItemCount = self.ctx.pageItemCount,
      pageSize = self.grid.h + self.grid.margin,
    })
    self.scrollbar:setProps({
      x = self.window.w - (self.window.paddingX / 2) - 4,
      y = self.grid.y,
      h = self.grid.h,
      pageItemCount = self.ctx.pageItemCount,
    })

    self.windowResized = self.window.resized
  end
end

---@param currentSong integer
function SongGrid:drawGrid(currentSong)
  local currentDiff = self.ctx.currentDiff
  local jacketSize = self.grid.jacketSize
  local margin = self.grid.margin
  local x = self.grid.x
  local y = self.grid.y + self.list.offset
  
  for i, song in ipairs(songwheel.songs) do
    local cachedDiff = self:getCachedDiff(currentDiff, song, i)
    local column = getColumn(i)

    if cachedDiff then
      self:drawJacket(
        x + ((jacketSize + margin) * column),
        y,
        cachedDiff,
        i == currentSong,
        jacketSize
      )      
    end

    if column == 2 then
      y = y + jacketSize + margin
    end
  end
end

---@param x number
---@param y number
---@param cachedDiff CachedDiff|nil
---@param isCurrent boolean
---@param jacketSize number
function SongGrid:drawJacket(x, y, cachedDiff, isCurrent, jacketSize)
  local alpha = (isCurrent and 1) or 0.5

  if cachedDiff then
    drawRect({
      x = x,
      y = y,
      w = jacketSize,
      h = jacketSize,
      color = "Black",
    })
    drawRect({
      x = x,
      y = y,
      w = jacketSize,
      h = jacketSize,
      alpha = alpha,
      image = cachedDiff.jacket,
      stroke = { color = "Medium", size = 2 },
    })

    if cachedDiff.breakpoint then
      self:drawTopPlayBreakpoint(x, y, alpha, cachedDiff.breakpoint)
    end

    if cachedDiff.grade then
      self:drawGrade(x, y, alpha, cachedDiff.grade, jacketSize)
    end
  end
end

---@param x number
---@param y number
---@param alpha number
---@param breakpoint? string
function SongGrid:drawTopPlayBreakpoint(x, y, alpha, breakpoint)
  drawRect({
    x = x + 9,
    y = y + 9,
    w = 81,
    h = 31,
    alpha = min(alpha * 1.5, 1),
    color = "Black",
  })
  self.topText:draw({
    x = x + 17,
    y = y + 8,
    alpha = alpha,
    color = "White",
  })
  self.breakpointText:draw({
    x = x + 58,
    y = y + 12,
    alpha = alpha,
    color = "Standard",
    text = breakpoint,
    update = true,
  })
end

---@param x number
---@param y number
---@param alpha number
---@param grade Label
---@param jacketSize number
function SongGrid:drawGrade(x, y, alpha, grade, jacketSize)
  x = x + jacketSize - 108
  y = y + jacketSize - 50

  drawRect({
    x = x - 9,
    y = y - 9,
    w = 108,
    h = 50,
    alpha = min(alpha * 1.5, 1),
    color = "Dark",
  })
  self.gradeText:draw({
    x = x + 2,
    y = y - 11,
    alpha = alpha,
    color = "White",
    text = grade,
    update = true,
  })
end

---@param currentSong integer
---@param songCount integer
function SongGrid:drawSongAmounts(currentSong, songCount)
  self.songCount:draw({
    x = self.window.w - self.window.paddingX,
    y = self.window.footerY - 2,
    currentItem = currentSong,
    totalItems = songCount,
  })
end

---@param currentDiff integer
---@param song Song
---@param songIndex integer
---@return CachedDiff|nil
function SongGrid:getCachedDiff(currentDiff, song, songIndex)
  if not self.list:isOnPage(songIndex) then
    return
  end

  local cachedSong = self.songCache:get(song)

  if not cachedSong then
    return
  end

  return cachedSong.diffs[currentDiff] or cachedSong.diffs[1]
end

return SongGrid
