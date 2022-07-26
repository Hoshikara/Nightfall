---@type table<string, table<string, HitAnimationProperties>>
local HitAnimationProperties = {
	Critical = {
		SDVX = {
			folderPath = "gameplay/hit_animations/critical/sdvx",
			fps = 60,
			hueSettingKey = "criticalHue",
		},
		STANDARD = {
			folderPath = "gameplay/hit_animations/critical/standard",
			fps = 60,
			hueSettingKey = "criticalHue",
		},
	},
	Near = {
		SDVX = {
			alpha = 1.5,
			folderPath = "gameplay/hit_animations/near/sdvx",
			fps = 72,
			hueSettingKey = "nearHue",
		},
		STANDARD = {
			alpha = 1.5,
			folderPath = "gameplay/hit_animations/near/standard",
			fps = 60,
			hueSettingKey = "nearHue",
		},
	},
	SCritical = {
		SDVX = {
			alpha = 1.5,
			folderPath = "gameplay/hit_animations/critical/sdvx",
			fps = 60,
			hueSettingKey = "sCriticalHue",
		},
		STANDARD = {
			folderPath = "gameplay/hit_animations/critical/standard",
			fps = 60,
			hueSettingKey = "sCriticalHue",
		},
	},
}

return HitAnimationProperties

---@class HitAnimationProperties:Animation.new.params
---@field alpha? number
---@field folderPath string
---@field fps number
---@field hueSettingKey string
