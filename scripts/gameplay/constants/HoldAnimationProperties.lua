---@type table<string, HoldAnimationProperties>
local HoldAnimationProperties = {
	SDVX = {
		alpha = 2.0,
		effect = "gameplay/hit_animations/hold/sdvx/effect",
		folderPath = "gameplay/hit_animations/hold/sdvx/inner",
		fps = 120,
		hueSettingKey = "holdHue",
		ring = "gameplay/hit_animations/hold/sdvx/ring",
		scale = 1.25,
	},
	STANDARD = {
		alpha = 2.0,
		effect = "gameplay/hit_animations/hold/standard/effect",
		folderPath = "gameplay/hit_animations/hold/sdvx/inner",
		fps = 120,
		hueSettingKey = "holdHue",
		ring = "gameplay/hit_animations/hold/standard/ring",
		scale = 1.25,
	},
}

return HoldAnimationProperties

---@class HoldAnimationProperties:Animation.new.params
---@field alpha number
---@field effect string
---@field folderPath string
---@field fps number
---@field hueSettingKey string
---@field ring string
