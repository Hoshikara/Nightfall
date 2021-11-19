---@type GaugeProperties[]
local GaugeProperties = {
	[0] = {
		colorFail = { 20, 120, 240 },
		colorPass = { 220, 20, 140 },
		name = "EFFECTIVE RATE",
		threshold = 0.7,
		type = 0,
		warn = false,
	},
	[1] = {
		colorFail = { 240, 20, 10 },
		colorPass = { 240, 80, 40 },
		name = "EXCESSIVE RATE",
		threshold = 0.3,
		type = 1,
		warn = true,
	},
	[2] = {
		colorFail = { 240, 20, 10 },
		colorPass = { 240, 80, 40 },
		name = "PERMISSIVE RATE",
		threshold = 0.3,
		type = 2,
		warn = true,
	},
	[3] = {
		colorFail = { 100, 80, 160 },
		colorPass = { 120, 120, 200 },
		hasLevels = true,
		name = "BLASTIVE RATE",
		threshold = 0.3,
		type = 3,
		warn = true,
	},
}

return GaugeProperties

---@class GaugeProperties
---@field colorFail Color
---@field colorPass Color
---@field hasLevels? boolean
---@field name string
---@field threshold number
---@field type integer
---@field warn boolean
