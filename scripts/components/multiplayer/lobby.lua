local Panel = require('components/multiplayer/panel');
local Users = require('components/multiplayer/users');

---@class LobbyClass
local Lobby = {
  -- Lobby constructor
  ---@param this LobbyClass
  ---@param window Window
  ---@param mouse Mouse
  ---@param state Multiplayer
  ---@param constants table
  ---@return Lobby
  new = function(this, window, mouse, state, constants)
    ---@class Lobby : LobbyClass
    ---@field panel Panel
    ---@field users Users
    local t = {
      panel = Panel:new(window, mouse, state, constants.btns),
      users = Users:new(window, mouse, state, constants.user),
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  --Renders the current component
  ---@param this Lobby
  ---@param dt deltaTime
  render = function(this, dt)
    gfx.Save();

    local w, h = this.panel:render(dt);

    this.users:render(w, h);

    gfx.Restore();
  end,
};

return Lobby;