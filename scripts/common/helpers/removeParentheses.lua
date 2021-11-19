---@param str string
---@return string, integer
local function removeParentheses(str)
	return str:gsub(" %((.*)%)", "")
end

return removeParentheses
