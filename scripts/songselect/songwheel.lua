--#region Require

local SongCache = require("songselect/SongCache")
local SongGrid = require("songselect/SongGrid")
local SongPanel = require("songselect/SongPanel")
local SongSelectContext = require("songselect/SongSelectContext")
local SongSelectFooter = require("songselect/SongSelectFooter")
local SongSelectScoreList = require("songselect/SongSelectScoreList")

--#endregion

local window = Window.new()

--#region Components

local context = SongSelectContext.new()
local songCache = SongCache.new(context)
local songGrid = SongGrid.new(context, songCache, window)
local songPanel = SongPanel.new(context, songCache, window)
local songSelectFooter = SongSelectFooter.new(context, window)
local songSelectScoreList = SongSelectScoreList.new(context, songCache, window)

--#endregion
local debug = require("common/debug")
local logger = require("common/logger")

local cache = {}

local function loggerFactory(hash)
  return function(res)
    logger:log(res.body, true)
    cache[hash].body = res.body
  end
end

local function getLeaderboard()
  local song = songwheel.songs[context.currentSong]
  local diff = song.difficulties[context.currentDiff]

  if cache[diff.hash] then
    logger:log(cache[diff.hash].body, true)
  else
    IR.Leaderboard(diff.hash, "best", 6, loggerFactory(diff.hash))
  end

  cache[diff.hash] = {}
end


---@param dt deltaTime
function render(dt)
  context:update(dt)
  gfx.Save()
  window:update()
  songPanel:draw(dt)
  songGrid:draw(dt)
  songSelectFooter:draw(dt)
  songSelectScoreList:draw(dt)
  gfx.Restore()
  gfx.ForceRender()
  debug({
    allowFetch = context.allowFetch
  });
  -- if context.allowFetch and game.GetButton(game.BUTTON_BTB) then
  --   getLeaderboard()
  -- end
end

---@return integer
function get_page_size()
  return context.pageItemCount
end

---@param newSong integer
function set_index(newSong)
  context:updateSong(newSong)
end

---@param newDiff integer
function set_diff(newDiff)
  context:updateDiff(newDiff)
end

---@param withAll boolean
function songs_changed(withAll)
	if withAll then
    context:updateVolforce()
  end
end
