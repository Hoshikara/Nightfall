local Animation = require("common/Animation")
local HitAnimationProperties = require("gameplay/constants/HitAnimationProperties")

---@param hitType string
---@return Animation
local function makeHitAnimation(hitType, isGameplaySettings)
	local props =
		HitAnimationProperties[hitType][getSetting("hitAnimationType", "STANDARD")]

	props.isCentered = true
	props.updateMeshHue = isGameplaySettings

	return Animation.new(props)
end

return makeHitAnimation
