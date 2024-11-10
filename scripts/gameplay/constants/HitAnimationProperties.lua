---@type table<string, table<string, HitAnimationProperties>>
local HitAnimationProperties = {
	Error = {
		SDVX = {
			folderPath = "gameplay/hit_animations/error/sdvx",
			fps = 60,
			hueSettingKey = "",
			scale = 0.5,
		},
		STANDARD = {
			folderPath = "gameplay/hit_animations/error/sdvx",
			fps = 60,
			hueSettingKey = "",
			scale = 0.5,
		},
	},
	Critical = {
		SDVX = {
			alpha = 1.0,
			folderPath = "gameplay/hit_animations/critical/sdvx",
			fps = 120,
			hueSettingKey = "criticalHue",
		},
		STANDARD = {
			folderPath = "gameplay/hit_animations/critical/standard",
			fps = 60,
			hueSettingKey = "criticalHue",
			scale = 1.5,
		},
	},
	Near = {
		SDVX = {
			alpha = 1.0,
			folderPath = "gameplay/hit_animations/near/sdvx",
			fps = 120,
			hueSettingKey = "nearHue",
		},
		STANDARD = {
			alpha = 1.5,
			folderPath = "gameplay/hit_animations/near/standard",
			fps = 60,
			hueSettingKey = "nearHue",
			scale = 1.5,
		},
	},
	SCritical = {
		SDVX = {
			alpha = 1.0,
			folderPath = "gameplay/hit_animations/s_critical/sdvx",
			fps = 120,
			hueSettingKey = "sCriticalHue",
		},
		STANDARD = {
			folderPath = "gameplay/hit_animations/critical/standard",
			fps = 60,
			hueSettingKey = "sCriticalHue",
			scale = 1.5,
		},
	},
}

return HitAnimationProperties

---@class HitAnimationProperties:Animation.new.params
---@field alpha? number
---@field folderPath string
---@field fps number
---@field hueSettingKey string
