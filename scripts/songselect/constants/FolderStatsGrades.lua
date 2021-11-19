---@type FolderStatsGrade[]
local FolderStatsGrades = {
	{ breakpoint = 9900000, name = "S" },
	{ breakpoint = 9800000, name = "AAA+" },
	{ breakpoint = 9700000, name = "AAA" },
	{ breakpoint = 9500000, name = "AA+" },
	{ breakpoint = 9300000, name = "AA" },
	{ breakpoint = 9000000, name = "A+" },
	{ breakpoint = 8700000, name = "A" },
	{ breakpoint = 7500000, name = "B" },
	{ breakpoint = 6500000, name = "C" },
	{ breakpoint = 0,       name = "D" },
	{ breakpoint = -1,      name = "NONE" },
}

return FolderStatsGrades

---@class FolderStatsGrade
---@field breakpoint integer
---@field name string
