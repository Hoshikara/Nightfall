local JSON = require('lib/JSON');

local t1 = 'Nightfall Log: %s';
local t2 = 'Nightfall Log: Invalid data type provided (expected a string, got a %s)';

---@class Logger
local Logger = {
  logged = false,

  -- Sends a string to the game's log file
  ---@param this Logger
  ---@param content string|table
  ---@param force boolean # `true` to log more than once
  log = function(this, content, force)
    if (not this.logged) then
      if (type(content) == 'table') then
        game.Log(t1:format(JSON.encode(content)), game.LOGGER_INFO);
      elseif (type(content) == 'string') then
        game.Log(t1:format(content), game.LOGGER_INFO);
      else
        game.Log(t2:format(type(content)), game.LOGGER_INFO);
      end

      if (not force) then this.logged = true; end
    end
  end,
};

return Logger;