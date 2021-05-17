local Cursor = require('components/common/cursor');

---@type string[]
local ClearStates = {
  'TRACK CRASH',
  'TRACK COMPLETE',
  'TRACK COMPLETE',
  'ULTIMATE CHAIN',
  'PERFECT ULTIMATE CHAIN',
};

---@class OutroClass
local Outro = {
  -- Outro constructor
  ---@param this OutroClass
  ---@param window Window
  ---@return Outro
  new = function(this, window)
    ---@class Outro : OutroClass
    ---@field window Window
    local t = {
      alpha = 0,
      ---@type Label[]
      clearStates = {};
      cursor = Cursor:new({ size = 18, stroke = 2 }, true);
      window = window,
      timers = {
        alpha = 0,
        expand = 0,
        start = 0,
      },
    };

    for i, state in ipairs(ClearStates) do
      t.clearStates[i] = makeLabel('norm', state, 60);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this Outro
  ---@param dt deltaTime
  ---@param clearState integer # `0 = Manual exit`, `1 = Failed`, `2 = Cleared`, `3 = Hard Cleared`, `4 = Ultimate Chain`, `5 = Perfect Chain`
  render = function(this, dt, clearState)
    this.timers.expand = to1(this.timers.expand, dt, 0.33);
    this.timers.start = this.timers.start + dt;

    if (this.timers.start > 0.6) then
      this.timers.alpha = this.timers.alpha + dt;

      this.alpha = flicker(this.timers.alpha);
    end

    local label = this.clearStates[clearState];
    local smoothing = smoothstep(this.timers.expand);
    local y = (this.window.isPortrait and (this.window.h / 2.75))
      or (this.window.h / 2);

    drawRect({
      x = 0,
      y = 0,
      w = this.window.w,
      h = this.window.h,
      alpha = 220 * math.min(this.timers.start * 2, 1),
      color = 'black',
      fast = true,
    });

    gfx.ForceRender();

    gfx.Save();

    this.window:scale();

    this.cursor:draw({
      x = (this.window.w / 2) - ((label.w / 2) * smoothing),
      y = y - (label.h / 2) + 10,
      w = label.w * smoothing,
      h = label.h,
      alpha = 255 * this.timers.expand,
    });

    this.window:unscale();

    label:draw({
      x = this.window.w / 2,
      y = y,
      align = 'middle',
      alpha = 255 * this.alpha,
      color = ((clearState > 1) and 'norm') or 'red',
    });

    gfx.Restore();
  end,
};

return Outro;