local abs = math.abs
local cos = math.cos

---@param timer number
---@param pct number # The lowest point of the phase in range `[0, 1]`.
---@param speed number
---@return number
function pulse(timer, pct, speed)
	return abs((1 - pct) * cos(timer * speed)) + pct
end

return pulse
