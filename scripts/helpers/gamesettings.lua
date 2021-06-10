---@param firstTab string
---@param default string
---@param tabName string
---@param settingName string
local makeParser = function(firstTab, default, tabName, settingName)
  return {
    default = default or '',
    firstTab = firstTab or '',
    settingIdx = nil,
    settingName = settingName or '',
    tabIdx = nil,
    tabName = tabName or '',

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
end

return makeParser;