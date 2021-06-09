local abs = math.abs;
local sin = math.sin;

---@class CritBarClass
local CritBar = {
  -- CritBar constructor
  ---@param this CritBarClass
  ---@param window Window
  ---@return CritBar
  new = function(this, window)
    ---@class CritBar : CritBarClass
    ---@field window Window
    local t = {
      bar = Image:new('gameplay/crit_bar.png'),
      front = Image:new('gameplay/console/console_front.png'),
      timer = 0,
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this CritBar
  ---@param dt deltaTime
  render = function(this, dt)
    local w = this.window.w * ((this.window.isPortrait and 1.02) or 0.9);

    this.timer = this.timer + dt;

    gfx.Save();

    gfx.Translate(gameplay.critLine.xOffset * 10, 0);

    this.window:scale();

    drawRect({
      x = -w,
      y = 6,
      w = w * 2,
      h = this.window.h / 2,
      alpha = 200,
      color = 'black',
    });

    this.bar:draw({
      w = w,
      h = 14,
      alpha = 0.75 + (0.25 * abs(sin(this.timer * 50))),
      blendOp = 8,
      centered = true,
    });

    this.bar:draw({
      w = w,
      h = 14,
      alpha = 0.5,
      centered = true,
    });

    this.front:draw({
      y = this.front.h * 0.9,
      centered = true,
    });

    gfx.Restore();
  end,
};

return CritBar;