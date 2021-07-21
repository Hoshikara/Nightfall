-- gamesettingsdialog `SettingsDiag` table

---@class SettingsDiagSetting
---@field max? number # Maximum setting value, only available if setting `type` is `int` or `float`
---@field min? number # Minimum setting value, only available if setting `type` is `int` or `float`
---@field name string # Setting ane
---@field options? string[] # Array of setting value names, only available if setting `type` is `enum`
---@field type string # Type of the setting value: `button`, `enum`, `float`, `int`, or `toggle`
---@field value? number|boolean # Value of the setting, not available if setting `type` is `button`
SettingsDiagSetting = {};

---@class SettingsDiagTab
---@field name string # Tab name
---@field settings SettingsDiagSetting[] # Array of settings in the tab
SettingsDiagTab = {};

---@class SettingsDiag
---@field currentSetting integer # Current setting index for `SettigsDiag[currentTab].settings`
---@field currentTab integer # Current tab index for `SettingsDiag.tabs`
---@field posX number # X-Position relative to the entire screen, from `0.0` to `1.0`
---@field posY number # Y-Position relative to the entire screen, from `0.0` to `1.0`
---@field tabs SettingsDiagTab[]
SettingsDiag = {};
