local max = math.max
local min = math.min

---@class Easing
local Easing = {}
Easing.__index = Easing

---@param initialValue number
---@return Easing
function Easing.new(initialValue)
  ---@type Easing
  local self = {
    initialValue = initialValue or 0,
    timer = initialValue or 0,
    value = initialValue or 0,
  }

  return setmetatable(self, Easing)
end

---@param value number
function Easing:reset(value)
  self.timer = value or self.initialValue
  self.value = value or self.initialValue
end

---@param dt deltaTime
---@param type easingType
---@param duration number
function Easing:start(dt, type, duration)
  self.timer = min(self.timer + (dt * (1 / duration)), 1)

  self:ease(type)
end

---@param dt deltaTime
---@param type easingType
---@param duration number
function Easing:stop(dt, type, duration)
  self.timer = max(self.timer - (dt * (1 / duration)), 0)

  self:ease(type)
end

---@param type easingType
function Easing:ease(type)
  if type == 1 then
    self.value = self.timer ^ 3
  elseif type == 2 then
    self.value = 1 - ((1 - self.timer) ^ 3)
  elseif type == 3 then
    if self.timer < 0.5 then
      self.value = 4 * (self.timer ^ 3)
    else
      self.value = 1 - (((-2 * self.timer + 2) ^ 3) / 2)
    end
  end
end

return Easing

---Easing type:
---* `1` = In
---* `2` = Out
---* `3` = In & Out
---@alias easingType integer
