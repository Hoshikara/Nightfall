---@class SpinnerClass
local Spinner = {
  -- Spinner constructor
  ---@param this SpinnerClass
  ---@param p? table
  -- ```lua
  -- {
  --   color: Color,
  --   size: number = 12,
  --   thickness: number = 3,
  -- }
  -- ```
  ---@return Spinner
  new = function(this, p)
    p = p or {};

    ---@class Spinner : SpinnerClass
    local t = {
      color = p.color or 'norm',
      size = p.size or 12,
      thickness = p.thickness or 3,
      timer = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this Spinner
  ---@param dt deltaTime
  ---@param x number
  ---@param y number
  ---@param center boolean
  render = function(this, dt, x, y, center)
    this.timer = this.timer + dt;

    gfx.Save();

    if (center) then
      gfx.Translate(x, y);
    else
      gfx.Translate(x - this.size, y + this.size);
    end

    gfx.Rotate(this.timer * 8);

    gfx.BeginPath();
    setFill('black', 0);
    setStroke({
      alpha = 100,
      color = this.color,
      size = this.thickness,
    });
    gfx.Circle(0, 0, this.size);
    gfx.Fill();
    gfx.Stroke();

    gfx.BeginPath();
    setStroke({
      alpha = 255,
      color = this.color,
      size = this.thickness,
    });
    gfx.Arc(0, 0, this.size, 0, 3.14159 * 1.5, 1);
    gfx.Stroke();

    gfx.Restore();
  end,
};

return Spinner;