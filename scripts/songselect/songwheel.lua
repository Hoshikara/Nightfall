--#region Require

local SongCache = require("songselect/SongCache")
local SongGrid = require("songselect/SongGrid")
local SongPanel = require("songselect/SongPanel")
local SongSelectContext = require("songselect/SongSelectContext")
local SongSelectFooter = require("songselect/SongSelectFooter")

--#endregion

local window = Window.new()

--#region Components

local context = SongSelectContext.new()
local songCache = SongCache.new(context)
local songGrid = SongGrid.new(context, songCache, window)
local songPanel = SongPanel.new(context, songCache, window)
local songSelectFooter = SongSelectFooter.new(context, window)

--#endregion

---@param dt deltaTime
function render(dt)
  context:update()

  gfx.Save()
  window:update()
  songPanel:draw(dt)
  songGrid:draw(dt)
  songSelectFooter:draw(dt)
  gfx.Restore()
  gfx.ForceRender()
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
