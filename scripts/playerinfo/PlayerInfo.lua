local PlayerInfoLabels = require("playerinfo/constants/PlayerInfoLabels")
local ControlLabel = require("common/ControlLabel")
local Easing = require("common/Easing")
local DropdownMenu = require("songselect/DropdownMenu")
local PlayerClearsOrGrades = require("playerinfo/PlayerClearsOrGrades")
local PlayerScores = require("playerinfo/PlayerScores")
local didPress = require("common/helpers/didPress")
local formatPlayerStats = require("playerinfo/helpers/formatPlayerStats")
local getPlayerData = require("playerinfo/helpers/getPlayerData")

---@class PlayerInfo
---@field clearStats FormattedPlayerStatsClears
---@field gradeStats FormattedPlayerStatsGrades
---@field playerData PlayerData
---@field scoreStats FormattedPlayerStatsScores
---@field tabs PlayerInfoTab[]
local PlayerInfo = {}
PlayerInfo.__index = PlayerInfo

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return PlayerInfo
function PlayerInfo.new(ctx, mouse, window)
  ---@type PlayerInfo
  local self = {
    clearStats = nil,
    clearsOrGrades = PlayerClearsOrGrades.new(ctx, mouse, window),
    ctx = ctx,
    currentFolder = 1,
    currentTab = 1,
    didPressFXL = false,
    folderCache = {},
    folderCount = 1,
    folderDropdownMenu = DropdownMenu.new(window, {
      altControl = "KNOB-R",
      altText = "SELECT FOLDER",
      control = "FX-L",
      font = "Medium",
      isLong = true,
      name = "FOLDER FILTER",
    }),
    gradeStats = nil,
    hasData = false,
    init = true,
    jacket = nil,
    loadInfoControl = ControlLabel.new("BT-D", "DURING SONG SELECT TO LOAD YOUR INFO"),
    mouse = mouse,
    noInfoAvailableText = makeLabel("Medium", "NO INFO AVAILABLE", 40),
    pressText = makeLabel("SemiBold", "PRESS", 20),
    scoreStats = nil,
    scores = PlayerScores.new(window),
    selectTabControl = ControlLabel.new("KNOB-L / MOUSE 1", "SELECT TAB"),
    tabs = nil,
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
    w = 0,
  }

  return setmetatable(self, PlayerInfo)
end

---@param dt deltaTime
function PlayerInfo:draw(dt)
  if self.init or (getSetting("_loadPlayerData", 0) == 1) then
    self:getPlayerData()
  end

  gfx.Save()

  if self.hasData then
    if not self.tabs then
      self:makeTabs()
    end

    self:setProps()
    self:handleInput()

    local currentTab = self.currentTab
    local x = self.x
    local y = self.y

    self:drawBackground(y)
    self:drawHeader(dt, x, y, currentTab)
    self:drawInfo(dt, x, y, currentTab)
    self:drawDropdownMenu(dt, x, y)
    self.selectTabControl:draw(x + 240, self.window.headerY)
  else
    self:drawNoInfoWindow()
  end

  gfx.Restore()
end

function PlayerInfo:getPlayerData()
  self.playerData = getPlayerData(true)

  if self.playerData.volforce then
    self:loadPlayerData(self.playerData)
    game.SetSkinSetting("_loadPlayerData", 0)

    self.folderCount = #self.playerData.stats.folders
    self.hasData = true
  end

  if self.init then
    self.init = false
  end
end

---@param playerData PlayerData
function PlayerInfo:loadPlayerData(playerData)
  self.currentFolder = 1
  self.jacket = nil
  self.clearStats, self.gradeStats, self.scoreStats = formatPlayerStats(playerData.stats)
  self.folderCache = {}
end

function PlayerInfo:makeTabs()
  local tabs = {}

  for i, label in ipairs(PlayerInfoLabels) do
    tabs[i] = {
      alpha = Easing.new(),
      event = function()
        self.ctx.currentBtn = i

        if i == 5 then
          self.ctx.currentView = "Top50"
        end

        self.clearsOrGrades:resetProps()
      end,
      text = makeLabel("Medium", label, 48)
    }
  end

  self.tabs = tabs
end

function PlayerInfo:setProps()
  if self.windowResized ~= self.window.resized then
    self.x = self.window.paddingX
    self.y = self.window.paddingY
    self.w = self.window.w - (self.window.paddingX * 2)
    self.windowResized = self.window.resized
  end
end

function PlayerInfo:handleInput()
  local ctx = self.ctx

  if ctx.currentView == "Charts" then
    self.clearsOrGrades:handleInput()
  else
    if (not self.didPressFXL) and didPress("FXL") then
      ctx.choosingFolder = not ctx.choosingFolder

      if ctx.choosingFolder then
        ctx.currentTab = self.currentFolder
      else
        ctx.currentTab = self.currentTab
      end
    end
  end

  self.didPressFXL = didPress("FXL")

  if ctx.choosingFolder then
    ctx.tabCount = self.folderCount

    if self.currentFolder ~= ctx.currentTab then
      self:changeFolders(ctx.currentTab)

      self.currentFolder = ctx.currentTab  
    end
  else
    if self.currentTab ~= ctx.currentBtn then
      if ctx.currentView == "Charts" then
        ctx.currentView = "PlayerInfo"

        self.clearsOrGrades:resetProps()
      end

      self.currentTab = ctx.currentBtn
    end

    ctx.btnCount = #self.tabs
  end
end

---@param currentFolder integer
function PlayerInfo:changeFolders(currentFolder)
  local folder = self.folderCache[currentFolder]

  if folder then
    self.clearStats = folder.clearStats
    self.gradeStats = folder.gradeStats
    self.scoreStats = folder.scoreStats
  else
    self.clearStats, self.gradeStats, self.scoreStats = formatPlayerStats(
      self.playerData.stats,
      self.playerData.stats.folders[currentFolder]
    )
    self.folderCache[currentFolder] = {
      clearStats = self.clearStats,
      gradeStats = self.gradeStats,
      scoreStats = self.scoreStats,
    }
  end
end

---@param y number
function PlayerInfo:drawBackground(y)
  local window = self.window
  local scale = window.scaleFactor

  drawRect({
    x = -window.shiftX / scale,
    y = -window.shiftY / scale,
    w = window.resX / scale,
    h = window.resY / scale,
    alpha = 0.85,
    color = "Black",
  })
end

---@param dt deltaTime
---@param x number
---@param y number
---@param currentTab integer
function PlayerInfo:drawHeader(dt, x, y, currentTab)
  local mouse = self.mouse
  local spacing = 121 

  x = x - 3

  if self.window.isPortrait then
    spacing = 48
    y = y + 45
  else
    y = y + 40
  end

  for i, tab in ipairs(self.tabs) do
    if i == currentTab then
      tab.alpha:start(dt, 3, 0.16)
    else
      tab.alpha:stop(dt, 3, 0.16)
    end

    tab.text:draw({
      x = x,
      y = y,
      alpha = 0.4 + (0.6 * tab.alpha.value),
      color = "White",
    })

    if mouse:clipped(x - 5, y + 8, tab.text.w + 9, 48) then
      self.ctx.btnEvent = tab.event
    end

    x = x + tab.text.w + spacing
  end
end

---@param dt deltaTime
---@param x number
---@param y number
---@param currentTab integer
function PlayerInfo:drawInfo(dt, x, y, currentTab)
  local w = self.w

  y = y + 94

  if currentTab == 2 then
    self.clearsOrGrades:draw(dt, x, y, w, self.clearStats, "clears")
  elseif currentTab == 3 then
    self.clearsOrGrades:draw(dt, x, y, w, self.gradeStats, "grades")
  elseif currentTab == 4 then
    self.scores:draw(x, y, w, self.scoreStats)
  end
end

---@param dt deltaTime
---@param x number
---@param y number
function PlayerInfo:drawDropdownMenu(dt, x, y)
  if self.window.isPortrait then
    y = y
  else
    y = y - 38
  end

  self.folderDropdownMenu:draw(dt, {
    x = x,
    y = y,
    currentItem = self.currentFolder,
    currentItemOffset = -12,
    isOpen = self.ctx.choosingFolder,
    items = self.playerData.stats.folders,
    showAltControl = self.ctx.choosingFolder,
  })
end

function PlayerInfo:drawNoInfoWindow()
  local x = self.window.w / 2 - (640 / 2)
  local y = self.window.h / 2 - (183 / 2)

  drawRect({
    x = x,
    y = y,
    w = 640,
    h = 183,
    alpha = 0.65,
    color = "Black",
  })
  self.noInfoAvailableText:draw({
    x = x + 45,
    y = y + 34,
    color = "White",
  })
  self.pressText:draw({
    x = x + 47,
    y = y + 115,
    color = "White",
  })
  self.loadInfoControl:draw(x + 109, y + 118)
end

return PlayerInfo

---@class PlayerInfoTab : TitlescreenButton
---@field alpha Easing
