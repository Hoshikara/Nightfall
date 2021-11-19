local Easing = require("common/Easing")

---@param isRing boolean
---@return LaserAnimationState[]|LaserSlamAnimationState[][]
local function makeLaserAnimationStates(isRing)
  local states = {}

  for laser = 1, 2 do
    if isRing then
      states[laser] = {
        active = false,
        alpha = Easing.new(),
        timer = 0,
      }
    else
      states[laser] = {}

      for i = 1, 6 do
        states[laser][i] = {
          frame = 1,
          pos = 0,
          queued = false,
          timer = 0,
        }
      end
    end
  end

  return states
end

return makeLaserAnimationStates
