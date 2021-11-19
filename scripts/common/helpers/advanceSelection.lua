---@param itemIndex integer
---@param totalItems integer
---@param step integer #
--* `-1` = Backwards
--* `1` = Forwards
---@return integer
local function advanceSelection(itemIndex, totalItems, step)
	return (((itemIndex - 1) + step) % totalItems) + 1
end

return advanceSelection
