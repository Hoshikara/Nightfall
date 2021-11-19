local getColor = require("common/helpers/getColor")

---@type table<string, Color>
local RatingColors = {
	Critical = getColor("criticalColor"),
	Early = getColor("earlyColor"),
	Error = getColor("errorColor"),
	Late = getColor("lateColor"),
	SCritical = getColor("SCriticalColor"),
}

return RatingColors
