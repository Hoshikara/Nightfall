local Clears = {
	{ name = "PUC",    rate = 1.10 },
	{ name = "UC",     rate = 1.05 },
	{ name = "HARD",   rate = 1.02 },
	{ name = "NORMAL", rate = 1.00 },
}

---@param score integer
---@return number
local function getGradeRate(score)
	if score >= 9900000 then
		return 1.05
	elseif score >= 9800000 then
		return 1.02
	elseif score >= 9700000 then
		return 1.00
	elseif score >= 9500000 then
		return 0.97
	elseif score >= 9300000 then
		return 0.94
	end

	return 0.91
end

---@param target string
---@return integer[][]
local function getVfRequirements(target)
	local minVf = (tonumber(target) * 1000) / 50
	local reqs = {}
	local i = 1

	for level = 20, 1, -1 do
		reqs[i] = {}

		for j, clear in ipairs(Clears) do
			local score = ((clear.name == "PUC") and 10000000) or 9000000

			while score < 10001000 do
				local gradeRate = getGradeRate(score)
				local vf = level * (score / 10000000) * clear.rate * gradeRate * 2 * 10

				if vf >= minVf then
					reqs[i][j] = score

					break
				end

				score = score + 100
			end
		end

		i = i + 1
	end

	return reqs
end

return getVfRequirements
