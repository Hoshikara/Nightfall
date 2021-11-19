---@return string
local function getDateTemplate()
	local dateFormat = game.GetSkinSetting("dateFormat") or "DAY-MONTH-YEAR"

  if dateFormat == "DAY-MONTH-YEAR" then
    return "%d-%m-%y"
  elseif dateFormat == "MONTH-DAY-YEAR" then
    return "%m-%d-%y"
  elseif dateFormat == "YEAR-MONTH-DAY" then
    return "%y-%m-%d"
  end

	return "%d-%m-%y"
end

return getDateTemplate
