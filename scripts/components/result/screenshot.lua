---@class ScreenshotClass
local Screenshot = {
  -- Screenshot constructor
  ---@param this ScreenshotClass
  ---@param state Result
  ---@return Screenshot
  new = function(this, state)
    ---@class Screenshot : ScreenshotClass
    local t = {
      labels = {
        path = makeLabel('norm', ''),
        saved = makeLabel('norm', 'SCREENSHOT SAVED TO'),
      },
      state = state,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current Screenshot
  ---@param this Screenshot
  ---@param dt deltaTime
  render = function(this, dt)
    if (this.state.shotTimer > 0) then
      this.state.shotTimer = to0(this.state.shotTimer, dt, 1);

      gfx.Save();

      gfx.Translate(8, 4);

      this.labels.saved:draw({ alpha = 255 * (this.state.shotTimer / 5) });

      this.labels.path:draw({
        x = this.labels.saved.w + 16,
        y = 0,
        alpha = 255 * (this.state.shotTimer / 5),
        color = 'white',
        text = this.state.shotPath,
        update = true,
      });

      gfx.Restore();
    end
  end,
};

return Screenshot;