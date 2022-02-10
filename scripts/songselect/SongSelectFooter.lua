local ControlLabel = require("common/ControlLabel")
local Spinner = require("common/Spinner")

---@class SongSelectFooter
local SongSelectFooter = {}
SongSelectFooter.__index = SongSelectFooter

---@param ctx SongSelectContext
---@param window Window
---@return SongSelectFooter
function SongSelectFooter.new(ctx, window)
  ---@type SongSelectFooter
  local self = {
    ctx = ctx,
    openGameSettingsControl = ControlLabel.new("FX-L + FX-R", "OPEN GAME SETTINGS"),
    loadInfoControl = ControlLabel.new("BT-D", "LOAD PLAYER INFO"),
    spinner = Spinner.new(),
    spinnerTimer = 0,
    vf = makeLabel("SemiBold", "VF"),
    viewScoresControl = ControlLabel.new("BT-A", "VIEW SCORES"),
    volforce = makeLabel("Number", "0", 19),
    window = window,
  }

  return setmetatable(self, SongSelectFooter)
end

---@param dt deltaTime
function SongSelectFooter:draw(dt)
  local x = self.window.paddingX
  local y = self.window.footerY

  if self.window.isPortrait then
    self.openGameSettingsControl:draw(x, y)
    self:drawLoadInfoControl(dt, (x * 2) + 280, y)
    
    y = 30
  else
    self.openGameSettingsControl:draw((x * 2) + 768, y)
    self:drawLoadInfoControl(dt, (x * 2) + 1084, y)
  end

  self.viewScoresControl:draw(x, y)
  self:drawVolforce(x, y)
end

---@param dt deltaTime
---@param x number
---@param y number
function SongSelectFooter:drawLoadInfoControl(dt, x, y)
  self:handleTimer(dt)
  self.loadInfoControl:draw(x, y)
  
  if self.spinnerTimer > 0 then
    self.spinner:draw(dt, x + self.loadInfoControl.w + 3, y + 24)
  end
end

---@param dt deltaTime
function SongSelectFooter:handleTimer(dt)
  if self.ctx.statsLoaded then
    self.spinnerTimer = 1
    self.ctx.statsLoaded = false
  end

  if self.spinnerTimer > 0 then
    self.spinnerTimer = self.spinnerTimer - dt
  end
end

---@param x number
---@param y number
function SongSelectFooter:drawVolforce(x, y)
  if self.window.isPortrait then
    x = x + 968
  else
    x = x + 768
  end

  self.vf:draw({
    x = x,
    y = y - 3,
    align = "RightTop",
  })
  self.volforce:draw({
    x = x - 26,
    y = y - 2,
    align = "RightTop",
    color = "White",
    text = ("%.3f"):format(self.ctx.volforce * 0.001),
    update = true,
  })
end

return SongSelectFooter
