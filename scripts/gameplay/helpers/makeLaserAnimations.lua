local Animation = require("common/Animation")
local RingAnimation = require("gameplay/RingAnimation")

---@param isGameplaySettings? boolean
---@return RingAnimation[], Animation[]
local function makeLaserAnimations(isGameplaySettings)
	local ringAnimations = {}
	local slamAnimations = {}

	for laserIndex = 1, 2 do
		ringAnimations[laserIndex] = RingAnimation.new(laserIndex, isGameplaySettings)
		slamAnimations[laserIndex] = Animation.new({
			alpha = 2.0,
			folderPath = ("gameplay/hit_animations/laser_slam_%d"):format(laserIndex),
			fps = 180,
			hueSettingKey = ((laserIndex == 1) and "leftLaserHue") or "rightLaserHue",
			isCentered = true,
			scale = 1.0,
			updateMeshHue = isGameplaySettings,
		})
	end

	return ringAnimations, slamAnimations
end

return makeLaserAnimations
