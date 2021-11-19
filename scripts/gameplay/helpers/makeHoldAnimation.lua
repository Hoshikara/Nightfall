local Animation = require("common/Animation")
local Image = require("common/Image")
local HoldAnimationProperties = require("gameplay/constants/HoldAnimationProperties")

---@param isGameplaySettings? boolean
---@return Image|nil, Animation, Image[]
local function makeHoldAnimation(isGameplaySettings)
	local props =
		HoldAnimationProperties[getSetting("hitAnimationType", "STANDARD")]
	local params = {
		hueSettingKey = props.hueSettingKey,
		isCentered = true,
		isMesh = true,
		meshBlendMode = 1,
		path = props.effect,
		updateMeshHue = isGameplaySettings,
	}
	local effect = Image.new(params)

	params.path = props.ring
	props.isCentered = true
	props.updateMeshHue = isGameplaySettings

	return effect, Animation.new(props), {
		Image.new(params),
		Image.new(params),
		Image.new(params),
	}
end

return makeHoldAnimation
