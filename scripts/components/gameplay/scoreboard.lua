local ScoreNumber = require('components/common/scorenumber');

---@alias players table # Array of users
-- {
--   id: integer
--   name: string,
--   score: integer,
-- }

---@class ScoreboardClass
local Scoreboard = {
  -- Scoreboard constructor
  ---@param this ScoreboardClass
  ---@param window Window
  ---@return Scoreboard
  new = function(this, window)
    ---@class Scoreboard : ScoreboardClass
    ---@field players table
    local t = {
      players = nil,
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Set scoreboard entries
  ---@param this Scoreboard
  ---@param players players
  setUsers = function(this, players)
    if (not this.players) then
      this.players = {};

      for i, player in ipairs(players) do
        this.players[i] = {
          name = makeLabel('norm', player.name:upper()),
          score = ScoreNumber:new({ size = 46 }),
        };
      end
    end
  end,

  -- Renders the current component
  ---@param this Scoreboard
  ---@param players players
  render = function(this, players)
    if (not players) then return; end

    this:setUsers(players);

    gfx.Save();

    if (this.window.isPortrait) then
      gfx.Translate(30, 24);

      local x = 0;

      for i = 1, 4 do
        local player = players[i];

        if (player and this.players[i]) then
          local alpha = ((player.id == gameplay.user_id) and 255) or 150;
  
          this.players[i].name:draw({
            x = x + 1,
            alpha = alpha,
            color = 'norm',
            text = (player.name or ''):upper(),
            update = true,
          });
  
          this.players[i].score:draw({
            x = x,
            y = this.players[i].name.h,
            alpha = alpha,
            val = player.score,
          });
  
          x = x + (this.players[i].score.w * 1.24);
        end
      end
    else
      gfx.Translate(this.window.w / 100, this.window.h / 3.75);

      local y = 0;

      for i, player in ipairs(players) do
        if (this.players[i]) then
          local alpha = ((player.id == gameplay.user_id) and 255) or 150;
  
          this.players[i].name:draw({
            x = 1,
            y = y,
            alpha = alpha,
            color = 'norm',
            text = (player.name or ''):upper(),
            update = true,
          });
  
          y = y + this.players[i].name.h;
  
          this.players[i].score:draw({
            x = 0,
            y = y,
            alpha = alpha,
            val = player.score,
          });
  
          y = y + (this.players[i].score.h * 1.25);
        end
      end
    end

    gfx.Restore();
  end,
};

return Scoreboard;