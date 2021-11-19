---@param value number
---@return ResultsHitWindow
local function makeHitWindow(value)
  value = value or 0

  return {
    negValue = makeLabel("Number", ("-%d"):format(value), 18),
    posValue = makeLabel("Number", ("+%d"):format(value), 18),
    value = value,
  }
end

---@param data result
---@param sCriticalWindow integer
---@return ResultsHitWindows
local function getHitWindows(data, sCriticalWindow)
  local hitWindows = data.hitWindow or {}

  return {
    SCritical = makeHitWindow(sCriticalWindow),
    Critical = makeHitWindow(hitWindows.perfect),
    Near = makeHitWindow(hitWindows.good),
    Error = makeHitWindow(hitWindows.miss),
  }
end

return getHitWindows

---@class ResultsHitWindows
---@field SCritical ResultsHitWindow
---@field Critical ResultsHitWindow
---@field Near ResultsHitWindow
---@field Error ResultsHitWindow

---@class ResultsHitWindow
---@field negValue Label
---@field posValue Label
---@field value number
