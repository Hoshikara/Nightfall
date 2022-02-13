local JSON = require("lib/json")

local baseTemplate = "Nightfall Log: %s"
local errorTemplate = "Nightfall Log: Invalid data type provided (expected a string, got a %s)"

---@class Logger
local Logger = {
  logged = false,
}

---@param content string|table
---@param forceLog boolean
function Logger:log(content, forceLog)
  if not self.logged then
    if type(content) == "table" then
      game.Log(baseTemplate:format(JSON.encode(content)), game.LOGGER_INFO)
    elseif type(content) == "string" then
      game.Log(baseTemplate:format(content), game.LOGGER_INFO)
    else
      game.Log(errorTemplate:format(type(content)), game.LOGGER_INFO)
    end

    if not forceLog then
      self.logged = true
    end
  end
end

return Logger
