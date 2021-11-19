---@param str string
---@return string
local function removeParentheses(str)
  return str:gsub(" %((.*)%)", "")
end

return removeParentheses
