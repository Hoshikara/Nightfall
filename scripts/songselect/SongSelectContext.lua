game.LoadSkinSample("click_diff")
game.LoadSkinSample("click_song")

--#region Require

local JsonTable = require("common/JsonTable")
local didPress = require("common/helpers/didPress")
local getVolforce = require("common/helpers/getVolforce")
local menusClosed = require("songselect/helpers/menusClosed")
local getPlayerStats = require("songselect/helpers/getPlayerStats")

--#endregion

---@class SongSelectContext
---@field topPlays TopPlays
local SongSelectContext = {}
SongSelectContext.__index = SongSelectContext

---@return SongSelectContext
function SongSelectContext.new()
  ---@type SongSelectContext
  local self = {
    currentDiff = 1,
    currentSong = 1,
    pageItemCount = 9,
    songCount = 0,
    statsLoaded = false,
    topPlays = {},
    volforce = 0,
  }

  game.SetSkinSetting("_isSongSelect", 1)

  return setmetatable(self, SongSelectContext)
end

function SongSelectContext:update()
  local song = songwheel.songs[self.currentSong]
  local diff = song and song.difficulties[self.currentDiff]

  if diff then
    self:setDiffInfo(diff, song)
  end

  self.songCount = #songwheel.songs

  self:handlePlayerData()
end

function SongSelectContext:handlePlayerData()
  if (not self.statsLoaded) and didPress("BTD") and menusClosed() then
    self:makePlayerData(true)
  end

  if getSetting("_reloadPlayerData", 0) == 1 then
    self:makePlayerData()

    game.SetSkinSetting("_reloadPlayerData", 0)
  end
end

function SongSelectContext:makePlayerData(showNotification)
  local playerDataJson = JsonTable.new("player")
  local stats = getPlayerStats()

  if stats then
    playerDataJson:set("stats", stats)
    playerDataJson:set("version", SKIN_VERSION)
    playerDataJson:set("volforce", getSetting("_volforce", 0))

    game.SetSkinSetting("_loadPlayerData", 1)

    if showNotification then
      self.statsLoaded = true
    end
  end
end

---@param diff Difficulty
---@param song Song
function SongSelectContext:setDiffInfo(diff, song)
  local key = diff.hash or ("%s_%d"):format(song.title, diff.level)
  local topPlay = self.topPlays[diff.id]

  game.SetSkinSetting("_diffKey", key)
  game.SetSkinSetting("_diffVolforce", (topPlay and topPlay.volforce) or 0)  
end

---@param newSong integer
function SongSelectContext:updateSong(newSong)
  if self.currentSong ~= newSong then
    game.PlaySample("click_song")
  end

  self.currentSong = newSong
end

---@param newDiff integer
function SongSelectContext:updateDiff(newDiff)
  if self.currentDiff ~= newDiff then
    game.PlaySample("click_diff")
  end

  self.currentDiff = newDiff
end

function SongSelectContext:updateVolforce()
  self.volforce, self.topPlays = getVolforce()
end

return SongSelectContext
