---@param hasSCrit boolean
---@return HitAnimationState[][]
local function makeHitAnimationQueues(hasSCrit)
  local states = {}

  for btn = 1, 6 do
    states[btn] = {}

    for i = 1, 8 do
      states[btn][i] = {
        frame = 1,
        queued = false,
        timer = 0,
      }

      if hasSCrit then
        states[btn][i].sCrit = false
      end
    end
  end

  return states
end

return makeHitAnimationQueues
