---@param data result|Score|IRScore
---@param unlabeled? boolean
---@return Label
local function getGaugeValue(data, unlabeled)
  if data.lamp then
    return makeLabel("Number", "-", 29)
  end

  local value = ("%.1f%%"):format((data.gauge or 0) * 100)

  if unlabeled then
    return makeLabel("Number", value, 18)
  end

  local option = data.gauge_option or 0
  local type = data.gauge_type or 0

  if type == 1 then
    value = value .. " [ EXC ]"
  elseif type == 2 then
    value = value .. " [ PMS ]"
  elseif type == 3 then
    value = value .. (" [ BLS %.1f ]"):format((option or 0) * 0.5)
  end

  return makeLabel("Number", value, 27)
end

return getGaugeValue
