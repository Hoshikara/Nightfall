local MpPanel = require('components/multiplayer/mppanel');
local MpUsers = require('components/multiplayer/mpusers');

---@class MpLobbyClass
local MpLobby = {
  -- MpLobby constructor
  ---@param this MpLobbyClass
  ---@param window Window
  ---@param mouse Mouse
  ---@param state Multiplayer
  ---@param constants table
  ---@return MpLobby
  new = function(this, window, mouse, state, constants)
    ---@class MpLobby : MpLobbyClass
    ---@field panel MpPanel
    ---@field users MpUsers
    local t = {
      panel = MpPanel:new(window, mouse, state, constants.btns),
      users = MpUsers:new(window, mouse, state, constants.user),
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  --Renders the current component
  ---@param this MpLobby
  ---@param dt deltaTime
  render = function(this, dt)
    gfx.Save();

    local w, h = this.panel:render(dt);

    this.users:render(w, h);

    gfx.Restore();
  end,
};

return MpLobby;