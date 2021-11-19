---@param obj VolforceTargetBase
---@param num string
---@return function
function getInputFunction(obj, num)
	return function()
		local dotIndex = obj.input:find("%.")

		if (num == "0") and (obj.input == "") then
			return
		end

		if (dotIndex == 2 and string.len(obj.input) == 5)
			or (dotIndex == 3 and string.len(obj.input) == 6)
		then
			return
		end

		if (string.len(obj.input) == 2) and (not dotIndex) then
			obj.input = obj.input .. "." .. num
		else
			obj.input = obj.input .. num
		end
	end
end

---@param obj VolforceTargetBase
---@return CalculatorButton[]
function getCalculatorButtons(obj)
	return {
		{ text = "1", event = getInputFunction(obj, "1") },
		{ text = "2", event = getInputFunction(obj, "2") },
		{ text = "3", event = getInputFunction(obj, "3") },
		{ text = "4", event = getInputFunction(obj, "4") },
		{ text = "5", event = getInputFunction(obj, "5") },
		{ text = "6", event = getInputFunction(obj, "6") },
		{ text = "7", event = getInputFunction(obj, "7") },
		{ text = "8", event = getInputFunction(obj, "8") },
		{ text = "9", event = getInputFunction(obj, "9") },
		{ text = "0", event = getInputFunction(obj, "0") },
		{
			text = ".",
			event = function()
				if (obj.input == "") or (obj.input:find("%.") ~= nil) then
					return
				end

				obj.input = obj.input .. "."
			end,
		},
		{
			text = "←",
			event = function()
				if obj.input == "" then
					return
				elseif string.len(obj.input) == 1 then
					obj.input = ""
				else
					obj.input = string.sub(obj.input, 1, -2)

					if obj.input:sub(-1) == "." then
						obj.input = string.sub(obj.input, 1, -2)
					end
				end
			end,
		},
	}
end

return getCalculatorButtons

---@class CalculatorButton
---@field text string
---@field event function
