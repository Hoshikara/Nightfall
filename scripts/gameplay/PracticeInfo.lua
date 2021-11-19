local ControlLabel = require("common/ControlLabel")
local DimmedNumber = require("common/DimmedNumber")

---@class PracticeInfo
local PracticeInfo = {}
PracticeInfo.__index = PracticeInfo

---@return PracticeInfo
function PracticeInfo.new(window)
  ---@type PracticeInfo
  local self = {
    isPracticing = false,
    misses = makeLabel("Number", "0", 27),
    mission = makeLabel("Medium", "", 30),
    nears = makeLabel("Number", "0", 27),
    openControl = ControlLabel.new("BACK", "OPEN SETTINGS WINDOW"),
    playCount = 0,
    playPauseControl = ControlLabel.new("FX-L / FX-R", "PLAY / PAUSE"),
    passRate = makeLabel("Number", "0", 27),
    passRatio = makeLabel("Number", "0", 27),
    score = DimmedNumber.new({ size = 54 }),
    scrubFastControl = ControlLabel.new("KNOB-R", "SCRUB THROUGH SONG (FAST)"),
    scrubSlowControl = ControlLabel.new("KNOB-L", "SCRUB THROUGH SONG (SLOW)"),
    window = window,
  }

  return setmetatable(self, PracticeInfo)
end

function PracticeInfo:draw()
  self:drawControls()

  if not self.isPracticing then
    return
  end

  gfx.Save()

  if self.window.isPortrait then
    gfx.Translate(32, 580)
  else
    gfx.Translate(82, 580)
  end

  gfx.Restore()
end

function PracticeInfo:drawControls()
  local x = 41
  local y = 306

  if self.window.isPortrait then
    x = 32
    y = 31
  end

  self.openControl:draw(x, y)
  self.scrubSlowControl:draw(x, y + 31)
  self.scrubFastControl:draw(x, y + 62)
  self.playPauseControl:draw(x, y + 93)
end

---@param playCount integer
---@param passCount integer
---@param practiceScoreInfo PracticeScoreInfo
function PracticeInfo:set(playCount, passCount, practiceScoreInfo)
  self.playCount = playCount

  if practiceScoreInfo then
    self.misses:update(practiceScoreInfo.misses)
    self.nears:update(practiceScoreInfo.goods)
    self.passRate:update(("%.1f%%"):format((passCount / playCount) * 100))
    self.passRate:update(("%d / %d"):format(passCount, playCount))
    self.score:updateNumbers(practiceScoreInfo.score)
  else
    self.isPracticing = false
  end
end

---@param mission string
function PracticeInfo:start(mission)
  self.isPracticing = true
  self.mission:update(mission)
end

return PracticeInfo

---@class PracticeScoreInfo
---@field goods integer
---@field meanHitDelta integer
---@field meanHitDeltaAbs integer
---@field medianHitDelta integer
---@field medianHitDeltaAbs integer
---@field misses integer
---@field perfects integer
---@field score integer
