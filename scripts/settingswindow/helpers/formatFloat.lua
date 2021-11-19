---@param category string
---@param setting SettingsDiagSetting
---@return string
local function formatFloat(category, setting)
  if setting.max <= 1 then
    return ("%.f%%"):format(setting.value * 100)
  end

  if category == "laneSpeed" then
    return ("%.2f"):format(setting.value * 0.01)
  end

  return ("%.2f"):format(setting.value)
end

return formatFloat
