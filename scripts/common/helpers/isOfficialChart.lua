local SDVX = "SDVX"
local SoundVoltex = "SOUND VOLTEX"

---@param path string
---@return integer|nil
local function isOfficialChart(path)
	if not path then
		return
	end

	local _, startIndex = path:find("songs")

	path = path:sub(startIndex or 1):upper()

	return path:find(SDVX) or path:find(SoundVoltex)
end

return isOfficialChart
