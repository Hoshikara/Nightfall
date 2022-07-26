local Easing = require("common/Easing")

---@return HoldAnimationState[]
local function makeHoldAnimationStates()
	local states = {}

	for btn = 1, 6 do
		states[btn] = {
			active = false,
			alpha = Easing.new(),
			effect = {
				alpha = Easing.new(1),
				playIn = true,
				playOut = false,
				timer = 0,
			},
			inner = {
				frame = 1,
				timer = 0,
			},
			timer = 0,
		}
	end

	return states
end

return makeHoldAnimationStates
