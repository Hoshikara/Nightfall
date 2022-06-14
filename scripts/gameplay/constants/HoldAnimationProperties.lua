---@type table<string, HoldAnimationProperties>
local HoldAnimationProperties = {
	SDVX = {
		alpha = 1.5,
		effect = "gameplay/hit_animations/hold/sdvx/effect",
		folderPath = "gameplay/hit_animations/hold/sdvx/inner",
		fps = 60,
		hueSettingKey = "holdHue",
		ring = "gameplay/hit_animations/hold/sdvx/ring",
	},
	STANDARD = {
		alpha = 1.5,
		effect = "gameplay/hit_animations/hold/standard/effect",
		folderPath = "gameplay/hit_animations/hold/standard/inner",
		fps = 60,
		hueSettingKey = "holdHue",
		ring = "gameplay/hit_animations/hold/standard/ring",
	},
}

return HoldAnimationProperties

---@class HoldAnimationProperties
---@field alpha number
---@field effect string
---@field folderPath string
---@field fps number
---@field hueSettingKey string
---@field ring string
