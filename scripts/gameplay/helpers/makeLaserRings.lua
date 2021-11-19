local Image = require("common/Image")

---@param laserIndex integer
---@param isGameplaySettings? boolean
---@return Image[]
local function makeLaserRings(laserIndex, isGameplaySettings)
	local params = {
		hueSettingKey = ((laserIndex == 1) and "leftLaserHue") or "rightLaserHue",
		isCentered = true,
		isMesh = true,
		meshBlendMode = 1,
		path = ("gameplay/hit_animations/laser_ring_%d"):format(laserIndex),
		updateMeshHue = isGameplaySettings,
	}

	return {
		Image.new(params),
		Image.new(params),
		Image.new(params),
	}
end

return makeLaserRings
