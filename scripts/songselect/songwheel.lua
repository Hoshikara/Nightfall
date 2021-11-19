--#region Require

local FolderStats = require("songselect/FolderStats")
local LeaderboardCache = require("songselect/LeaderboardCache")
local SongCache = require("songselect/SongCache")
local SongGrid = require("songselect/SongGrid")
local SongPanel = require("songselect/SongPanel")
local SongSelectContext = require("songselect/SongSelectContext")
local SongSelectFooter = require("songselect/SongSelectFooter")
local SongSelectScoreList = require("songselect/SongSelectScoreList")
local Top50 = require("songselect/Top50")

--#endregion

local window = Window.new()

--#region Components

local context = SongSelectContext.new()
local folderStats = FolderStats.new(context, window)
local leaderboardCache = LeaderboardCache.new(context)
local songCache = SongCache.new(context)
local songGrid = SongGrid.new(context, songCache, window)
local songPanel = SongPanel.new(context, songCache, window)
local songSelectFooter = SongSelectFooter.new(context, window)
local songSelectScoreList = SongSelectScoreList.new(context, leaderboardCache, songCache, window)
local top50 = Top50.new(context, window)

--#endregion

---@param dt deltaTime
function render(dt)
	context:update(dt)
	gfx.Save()
	window:update()
	songPanel:draw(dt)
	songGrid:draw(dt)
	songSelectFooter:draw()
	songSelectScoreList:draw(dt)

	if songwheel.searchInputActive then
		game.SetSkinSetting("_isViewingTop50", 0)
	end

	if context.folderStatsEnabled then
		folderStats:draw(dt)
	end

	if context.viewingTop50 then
		top50:draw()
	end

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
