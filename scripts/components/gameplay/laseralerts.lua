local Cursor = require('components/common/cursor');

local max = math.max;

---@class LaserAlertsClass
local LaserAlerts = {
  -- LaserAlerts constructor
  ---@param this LaserAlertsClass
  ---@param window Window
  ---@param state Gameplay
  ---@return LaserAlerts
  new = function(this, window, state)
    ---@class LaserAlerts : LaserAlertsClass
    ---@field colors integer[][]
    ---@field labels Label[]
    ---@field state Gameplay
    ---@field window Window
    local t = {
      alpha = { 0, 0 },
      cache = { w = 0, h = 0 },
      colors = {},
      cursor = Cursor:new({ size = 16, stroke = 2 }, true);
      labels = {},
      size = 128,
      start = { false, false },
      state = state,
      timers = {
        fade = { 0, 0 },
        pulse = { 0, 0 },
      },
      window = window,
      x = {},
      y = {},
    };

    for i = 1, 2 do
      local r, g, b = game.GetLaserColor(i - 1);

      t.colors[i] = { r, g, b };
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this LaserAlerts
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local labelSize = 120;

      if (this.window.isPortrait) then
        labelSize = 100;

        this.x[1] = (this.window.w / 2) - (this.window.w / 2.4);
        this.x[2] = (this.window.w / 2.4) * 2;

        this.y[1] = this.window.h - (this.window.h / 2.8);
        this.y[2] = 0;

        this.size = 108;
      else
        this.x[1] = (this.window.w / 2) - (this.window.w / 3.75);
        this.x[2] = (this.window.w / 3.75) * 2;

        this.y[1] = (this.window.h * 0.95) - (this.window.h / 6);
        this.y[2] = 0;

        this.size = 128;
      end

      this.labels[1] = makeLabel('norm', 'L', labelSize);
      this.labels[2] = makeLabel('norm', 'R', labelSize);

      this.offset = -(this.labels[1].h / 5.5);

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Renders the current component
  ---@param this LaserAlerts
  ---@param dt deltaTime
  render = function(this, dt)
    this:setSizes();

    local size = this.size;

    gfx.Save();

    for i = 1, 2 do
      this.state.timers.alerts[i] = max(this.state.timers.alerts[i] - dt, -1.5);

      this.start[i] = this.state.timers.alerts[i] > -1.5;

      if (this.start[i]) then
        this.timers.fade[i] = to1(this.timers.fade[i], dt, 0.142);
        this.timers.pulse[i] = this.timers.pulse[i] + dt;
        this.alpha[i] = pulse(this.timers.pulse[i], 0.85, 0.1);
      else
        this.timers.fade[i] = to0(this.timers.fade[i], dt, 0.167);
        this.timers.pulse[i] = this.timers.pulse[i] - dt;
        this.alpha[i] = 1;
      end

      gfx.Translate(this.x[i], this.y[i]);

      gfx.Scissor(
        -(size / 2) * this.window:getScale(),
        -(size / 2) * this.window:getScale(),
        size,
        size * this.timers.fade[i]
      );

      this.labels[i]:draw({
        y = this.offset,
        align = 'middle',
        alpha = 255 * this.alpha[i],
        color = this.colors[i],
      });

      this.labels[i]:draw({
        y = this.offset,
        align = 'middle',
        alpha = 70 * this.alpha[i],
        color = 'white',
      });

      gfx.ResetScissor();

      this.cursor:draw({
        x = -(size / 2) * this.timers.fade[i],
        y = -(size / 2) * this.timers.fade[i],
        w = size * this.timers.fade[i],
        h = size * this.timers.fade[i],
        alpha = 255 * this.timers.fade[i],
      });
    end

    gfx.Restore();
  end,
};

return LaserAlerts;