local Easing = require("common/Easing")
local Spinner = require("common/Spinner")
local pulse = require("common/helpers/pulse")

local ChangelogURL =
  "https://github.com/Hoshikara/Nightfall/blob/main/CHANGELOG.md"

local function openChangelog()
	if (package.config:sub(1, 1) == "\\") then
		os.execute("start " .. ChangelogURL)
	else
		os.execute("xdg-open " .. ChangelogURL)
	end
end

local floor = math.floor

---@class Title
local Title = {}
Title.__index = Title

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return Title
function Title.new(ctx, mouse, window)
  ---@type Title
  local self = {
    alpha = 0,
    alphaTimer = 0,
    ctx = ctx,
    fade = Easing.new(1),
    mouse = mouse,
    nightfallText = makeLabel("Medium", "NIGHTFALL", 160),
    uscText = makeLabel("Medium", "UNNAMED SDVX CLONE", 40),
    updateCheckSpinner = Spinner.new({ text = "CHECKING FOR UPDATES" }),
    viewChangelogText = makeLabel("SemiBold", "CLICK TO VIEW CHANGELOG"),
    viewNewVersionText = makeLabel(
      "SemiBold",
      "NEW VERSION AVAILABLE, CLICK TO VIEW CHANGELOG"
    ),
    versionNumberText = makeLabel("Number", SKIN_VERSION, 19),
    versionText = makeLabel("SemiBold", "VERSION"),
    versionTimer = 0,
    window = window,
    windowResized = nil,
    x = 0,
    y = 0,
  }

  return setmetatable(self, Title)
end

---@param dt deltaTime
function Title:draw(dt)
  self:load(dt)
  
  if (not self.ctx.isLoaded) or (self.ctx.currentView ~= "") then
    return
  end

  self:setProps()
  self:updateAlpha(dt)
  self:drawTitle(dt)
end

---@param dt deltaTime
function Title:load(dt)
  self:checkForUpdate(dt)

  if self.ctx.isLoaded then
    return
  end

  self.fade:stop(dt, 3, 2.5)
  self:drawDim()
  self.updateCheckSpinner:draw(
    dt, 
    self.window.w - self.window.paddingX - 235,
    self.window.footerY + 24
  )

  self.ctx.isLoaded = self.fade.value == 0
end

---@param dt deltaTime
function Title:checkForUpdate(dt)
  if self.ctx.checkForUpdate and (not self.ctx.updateClosed) then
    if game.UpdateAvailable() then
      self.ctx.checkForUpdate = false
      self.ctx.currentView = "UpdatePrompt"
    end
  end
end

function Title:setProps()
  if self.windowResized ~= self.window.resized then
    if self.window.isPortrait then
      self.x = self.window.paddingX * 1.5
      self.y = self.window.paddingY * 5
    else
      self.x = self.window.paddingX
      self.y = self.window.paddingY * 5
    end
    
    self.windowResized = self.window.resized
  end
end

---@param dt deltaTime
function Title:updateAlpha(dt)
  self.alphaTimer = self.alphaTimer + dt
  self.alpha = floor(self.alphaTimer * 30) % 2
  self.alpha = (self.alpha * 0.2) + 0.8
  
  if self.alphaTimer >= 0.22 then
    self.alpha = 1
  end
end

function Title:drawDim()
  local window = self.window
  local scale = window.scaleFactor

  drawRect({
    x = -window.shiftX / scale,
    y = -window.shiftY / scale,
    w = window.resX / scale,
    h = window.resY / scale,
    alpha = self.fade.value,
    color = "Black",
  })
end

---@param dt deltaTime
function Title:drawTitle(dt)
  local alpha = self.alpha
  local x = self.x
  local y = self.y

  self.uscText:draw({
    x = x - 2,
    y = y - 14,
    alpha = alpha,
    color = "Standard",
  })
  self.nightfallText:draw({
    x = x - 12,
    y = y - 19,
    alpha = alpha,
    color = "White",
  })
  self:drawVersion(dt, x, y, alpha)
end

---@param dt deltaTime
---@param x number
---@param y number
---@param alpha number
function Title:drawVersion(dt, x, y, alpha)
  local alphaMod = 1
  local color = "White"
  local newVersion = self.ctx.newVersion
  local w = -234

  if newVersion then
    self.versionTimer = self.versionTimer + dt
    alphaMod = pulse(self.versionTimer, 0.2, 0.5)
    color = "Negative"
    w = -448
  end

  self.versionText:draw({
    x = x + 539,
    y = y + 146,
    alpha = alpha * alphaMod,
    color = color,
  })
  self.versionNumberText:draw({
    x = x + 625,
    y = y + 147,
    alpha = alpha * alphaMod,
    color = color,
  })
  self:drawTooltip(x, y, w, alpha, color, newVersion)
end

---@param x number
---@param y number
---@param w number
---@param alpha number
---@param color string
---@param newVersion boolean
function Title:drawTooltip(x, y, w, alpha, color, newVersion)
  if self.mouse:clipped(x + 531, y + 145, 144, 30) then
    self.ctx.btnEvent = openChangelog
    self.ctx.hoveringVersion = true
    self.ctx.isClickable = true

    drawRect({
      x = x + 531,
      y = y + 145,
      w = w,
      h = 29,
      alpha = 0.95,
      color = "Dark",
      isFast = true,
    })

    if newVersion then
      self.viewNewVersionText:draw({
        x = x + 524,
        y = y + 146,
        align = "RightTop",
        alpha = alpha,
        color = "White",  
      })
    else
      self.viewChangelogText:draw({
        x = x + 524,
        y = y + 146,
        align = "RightTop",
        alpha = alpha,
        color = "White",
      })
    end
  else
    self.ctx.hoveringVersion = false
  end
end

return Title
