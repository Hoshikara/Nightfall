local abs = math.abs
local max = math.max

local minCritDelta = getSetting("minCritDelta", 23)
local showCritDelta = getSetting("ShowCritDelta", false)

---@class GameplayContext
---@field bpmData BpmPoint[]
local GameplayContext = {}
GameplayContext.__index = GameplayContext

---@return GameplayContext
function GameplayContext.new()
  ---@type GameplayContext
  local self = {
    alertTimers = { -1.5, -1.5 },
    bpmData = nil,
    buttonDelta = 0,
    chain = 0,
    chainTimer = 0,
    critHit = false,
    earlateTimer = 0,
    exScore = 0,
    introAlpha = 1,
    introOffset = 0,
    introTimer = 2,
    isButton = false,
    maxChain = 0,
    outroTimer = 0,
    score = 0,
    sCritWindow = nil,
  }

  return setmetatable(self, GameplayContext)
end

function GameplayContext:update()
  if gameplay.progress == 0 then
    self.exScore = 0
    self.isButton = false
    self.maxChain = 0
  end
end

---@param btn integer
---@param delta integer
---@param rating rating
function GameplayContext:handleButton(btn, delta, rating)
	if not self.sCritWindow then
		self.sCritWindow = math.floor(gameplay.hitWindow.perfect / 2)
	end

  self.isButton = rating ~= 3

  if rating == 1 then
    self.buttonDelta = delta
    self.critHit = false
    self.exScore = self.exScore + 2
  elseif rating == 2 then
    delta = abs(delta)

    if showCritDelta and (delta >= minCritDelta) then
      self.buttonDelta = delta
      self.critHit = true
      self.earlateTimer = 0.75
    end

    if delta <= self.sCritWindow then
      self.exScore = self.exScore + 5
    else
      self.exScore = self.exScore + 4
    end
  end
end

---@param dt deltaTime
function GameplayContext:handleIntro(dt)
  self.introTimer = max(self.introTimer - (dt / 2), 0)

  local t = max(self.introTimer - 1, 0)

  self.introAlpha = 1 - (t ^ 1.5)
  self.introOffset = t ^ 4
end

---@param newChain integer
function GameplayContext:updateChain(newChain)
  if (newChain > self.chain) and (not self.isButton) then
    self.exScore = self.exScore + 2
  end

  if newChain > self.maxChain then
    self.maxChain = newChain
  end

  self.chain = newChain
  self.chainTimer = 0.75
  self.isButton = false
end

---@param isLate boolean
function GameplayContext:updateEarlate(isLate)
  self.earlateTimer = 0.75
  self.isLate = isLate
end

function GameplayContext:updateLaserAlerts(isRight)
  if isRight and (self.alertTimers[2] < -1) then
    self.alertTimers[2] = 1
  elseif self.alertTimers[1] < -1 then
    self.alertTimers[1] = 1
  end
end

return GameplayContext
