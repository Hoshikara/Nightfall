local JsonTable = require("common/JsonTable")

local floor = math.floor

---@class BpmData
local BpmData = {}
BpmData.__index = BpmData

---@param ctx GameplayContext
---@return BpmData
function BpmData.new(ctx)
  ---@type BpmData
  local self = {
    bpmDataJson = JsonTable.new("bpms"),
    currentBpm = nil,
    currentTime = 0,
    data = {},
    didSave = false,
    diffKey = getSetting("_diffKey", ""),
    index = 1,
  }

  local currentData = self.bpmDataJson:get(false, self.diffKey)

  if currentData then
    ctx.bpmData = currentData
  end

  return setmetatable(self, BpmData)
end

---@param dt deltaTime
function BpmData:collect(dt)
  if self.didSave then
    return
  end

  local currentBpm = gameplay.bpm

  if not self.currentBpm then
    self.currentBpm = currentBpm
  end

  if gameplay.progress == 0 then
    self:resetProps()
  else
    self.currentTime = self.currentTime + dt
  end

  if self.currentBpm ~= currentBpm then
    self.data[self.index] = {
      bpm = currentBpm,
      time = (floor(self.currentTime * 10) / 10) - 2.5,
    }
    self.currentBpm = currentBpm
    self.index = self.index + 1
  end
end

function BpmData:save()
  if self.diffKey == "" then
    return
  end

  if not self.didSave then
    self.bpmDataJson:set(self.diffKey, self.data)

    self.didSave = true
  end
end

function BpmData:resetProps()
  self.currentBpm = nil
  self.currentTime = 0
  self.data = {}
  self.index = 1
end

return BpmData

---@class BpmPoint
---@field bpm number
---@field time number
