---@param firstTab string # Name of the first tab, `SettingsDiag.tabs[1].name`
---@param default string # Default value if setting cannot be parsed
---@param tabName string # Name of the tab that the setting is in
---@param settingName string # Name of the setting to be parsed
local makeParser = function(firstTab, default, tabName, settingName)
  ---@class SettingsParser
  ---@field default number|string
  ---@field firstTab string
  ---@field settingIdx integer
  ---@field settingName string
  ---@field tabIdx integer
  ---@param tabName string
  local s = {
    default = default or '',
    firstTab = firstTab or '',
    settingIdx = nil,
    settingName = settingName or '',
    tabIdx = nil,
    tabName = tabName or '',

    ---@param this SettingsParser
    ---@return boolean|number|string
    get = function(this)
      if (SettingsDiag.tabs[1].name ~= this.firstTab) then
        return this.default;
      end

      if (this.tabIdx and this.settingIdx) then
        local setting =
          SettingsDiag.tabs[this.tabIdx].settings[this.settingsIdx];

        if (setting and (setting.value ~= nil)) then
          if (setting.options) then return setting.options[setting.value]; end

          return setting.value;
        end
      end

      for i, tab in ipairs(SettingsDiag.tabs) do
        if (tab.name == this.tabName) then
          this.tabIdx = i;

          for j, setting in ipairs(tab.settings) do
            if (setting.name == this.settingName) then
              this.settingIdx = j;

              if (setting.options) then return setting.options[setting.value]; end

              return setting.value;
            end
          end
        end
      end

      return this.default;
    end,
  };

  return s;
end

return makeParser;