---@type DifficultyName[]
local DifficultyNames = {
	{ full = "NOVICE",   short = "NOV" },
	{ full = "ADVANCED", short = "ADV" },
	{ full = "EXHAUST",  short = "EXH" },
	{ full = "MAXIMUM",  short = "MXM" },
	{ full = "INFINITE", short = "INF" },
	{ full = "GRAVITY",  short = "GRV" },
	{ full = "HEAVENLY", short = "HVN" },
	{ full = "VIVID",    short = "VVD" },
	{ full = "EXCEED",   short = "XCD" },
}

---@param jacketPath string
---@param diffIndex integer|string
---@return string
function DifficultyNames:get(jacketPath, diffIndex, isShort)
	if jacketPath then
		local path = ((jacketPath):lower()):match("[/\\][^\\/]+$")

		if (diffIndex == 3) and path then
			if path:find("inf") then
				diffIndex = 4
			elseif path:find("grv") then
				diffIndex = 5
			elseif path:find("hvn") then
				diffIndex = 6
			elseif path:find("vvd") then
				diffIndex = 7
			elseif path:find("xcd") then
				diffIndex = 8
			end
		end
	end

	if isShort then
		return self[diffIndex + 1].short
	end

	return self[diffIndex + 1].full
end

return DifficultyNames

---@class DifficultyName
---@field full string
---@field short string
