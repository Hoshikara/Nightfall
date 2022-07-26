---@type Grade[]
local Grades = {
	{ name = "S", min = 9900000, rate = 1.05 },
	{ name = "AAA+", min = 9800000, rate = 1.02 },
	{ name = "AAA", min = 9700000, rate = 1.00 },
	{ name = "AA+", min = 9500000, rate = 0.97 },
	{ name = "AA", min = 9300000, rate = 0.94 },
	{ name = "A+", min = 9000000, rate = 0.91 },
	{ name = "A", min = 8700000, rate = 0.88 },
	{ name = "B", min = 7500000, rate = 0.85 },
	{ name = "C", min = 6500000, rate = 0.82 },
	{ name = "D", min = 0, rate = 0.80 },
}

---@param score integer
---@param getRate? boolean
---@return nil|number|string
function Grades:get(score, getRate)
	if not score then
		return
	end

	for _, grade in ipairs(self) do
		if score >= grade.min then
			if getRate then
				return grade.rate
			end

			return grade.name
		end
	end
end

return Grades

---@class Grade
---@field min integer
---@field name string
---@field rate number
