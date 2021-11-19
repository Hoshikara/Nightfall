local Image = require("common/Image")

---@class PlayerCard
local PlayerCard = {}
PlayerCard.__index = PlayerCard

---@param ctx GameplayContext
---@param window Window
---@param isGameplaySettings boolean
---@return PlayerCard
function PlayerCard.new(ctx, window, isGameplaySettings)
  ---@type PlayerCard
  local self = {
    avatar = Image.new({ path = "gameplay/avatar.png" }),
    avatarEnabled = getSetting("showPlayerAvatar", true),
    ctx = ctx,
    danLevel = getSetting("danLevel", "NONE"),
    danLevelText = makeLabel("Number", "0", 19),
    danText = makeLabel("SemiBold", "DAN"),
    isGameplaySettings = isGameplaySettings,
    player = makeLabel("Medium", getSetting("playerName", "GUEST"), 34),
    vf = makeLabel("SemiBold", "VF"),
    volforce = makeLabel(
      "Number",
      ("%.3f"):format(getSetting("_volforce", 0) * 0.001),
      19
    ),
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
  }

  return setmetatable(self, PlayerCard)
end

function PlayerCard:draw()
  if self.isGameplaySettings then
    self:updateProps()
  end

  self:setProps()

  local introAlpha = self.ctx.introAlpha

  gfx.Save()
  gfx.Translate(self.x - ((self.window.w / 4) * self.ctx.introOffset), self.y)
  self:drawCard(introAlpha)
  gfx.Restore()
end

function PlayerCard:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.x = 24
      self.y = (self.window.h / 2) - 213
    else
      self.x = self.window.paddingX / 2
      self.y = (self.window.h / 2) - 18
    end

    self.windowResized = self.window.resized
  end
end

---@param introAlpha number
function PlayerCard:drawCard(introAlpha)
  local x = 0

  if self.avatarEnabled then
    self:drawAvatar(introAlpha)

    x = 84
  end

  self.player:draw({
    x = x - 2,
    y = -12,
    alpha = introAlpha,
    color = "White",
  })

  self:drawVolforce(x, introAlpha)
  self:drawDan(x, introAlpha)
end

---@param x number
---@param introAlpha number
function PlayerCard:drawAvatar(x, introAlpha)
  gfx.Scissor(0, 0, 72, 72)
  self.avatar:draw({
    x = 72 / 2,
    y = 72 / 2,
    alpha = introAlpha,
    isCentered = true,
    scale = 72 / self.avatar.w,
  })
  drawRect({
    x = 1,
    y = 1,
    w = 70,
    h = 70,
    alpha = 0,
    color = "Black",
    stroke = { size = 2, color = "Medium" },
  })
  gfx.ResetScissor()
end

---@param x number
---@param introAlpha number
function PlayerCard:drawVolforce(x, introAlpha)
  self.volforce:draw({
    x = x,
    y = 28,
    alpha = introAlpha,
    color = "White",
  })
  self.vf:draw({
    x = x + self.volforce.w + 6,
    y = 27,
    alpha = introAlpha,
    color = "Standard",
  })
end

---@param x number
---@param introAlpha number
function PlayerCard:drawDan(x, introAlpha)
  if self.danLevel ~= "NONE" then
    self.danLevelText:draw({
      x = x,
      y = 53,
      alpha = introAlpha,
      color = "White",
      text = self.danLevel,
      update = true,
    })
    self.danText:draw({
      x = x + self.danLevelText.w + 6,
      y = 52,
      alpha = introAlpha,
      color = "Standard",
    })
  end
end

function PlayerCard:updateProps()
  self.avatarEnabled = getSetting("showPlayerAvatar", true)
  self.danLevel = getSetting("danLevel", "NONE")
end

return PlayerCard
