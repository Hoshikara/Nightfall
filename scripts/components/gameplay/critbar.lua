local abs = math.abs;
local sin = math.sin;

local r, g, b, _ = game.GetSkinSetting('colorScheme');

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
      fill = Image:new('gameplay/crit_bar_fill.png'),
      front = Image:new('gameplay/console/console_front.png'),
      timer = 0,
      top = Image:new('gameplay/crit_bar_top.png'),
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

    this.fill:draw({
      w = w,
      h = 14,
      alpha = 0.8 + (0.2 * abs(sin(this.timer * 50))),
      blendOp = 8,
      centered = true,
      tint = { r, g, b },
    });

    this.fill:draw({
      w = w,
      h = 14,
      alpha = 0.5,
      centered = true,
      tint = { r, g, b },
    });

    this.top:draw({
      w = w,
      h = 14,
      centered = true,
    });

    if (this.window.isPortrait) then
      this.front:draw({
        y = this.front.h * 0.9,
        centered = true,
      });
    end

    gfx.Restore();
  end,
};

return CritBar;