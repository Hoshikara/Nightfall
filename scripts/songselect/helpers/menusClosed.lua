---@return boolean
local function menusClosed()
	return (getSetting("_isFiltering", 0) == 0)
	and (getSetting("_isSorting", 0) == 0)
	and (getSetting("_changingSettings", 0) == 0)
	and (getSetting("_managingCollections", 0) == 0)
	and (not songwheel.searchInputActive)
end

return menusClosed
