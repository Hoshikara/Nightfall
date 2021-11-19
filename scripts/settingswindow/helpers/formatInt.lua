---@param category string
---@param setting SettingsDiagSetting
---@return string, string
local function formatInt(category, setting)
  local color = "White"
  local text = ""

  if category == "hitWindow" then
    text = ("±%d ms"):format(setting.value)

    if setting.value < setting.max then
      color = "Negative"
    end
  elseif category == "percentage" then
    text = ("%d%%"):format(setting.value)
  elseif (category == "time") or setting.name:lower():find("offset") then
    text = ("%d ms"):format(setting.value)
  else
    text = tostring(setting.value)
  end
  
  return color, text
end

return formatInt
