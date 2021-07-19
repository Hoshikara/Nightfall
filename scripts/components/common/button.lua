---@class ButtonClass
local Button = {
  -- Button constructor
  ---@param this ButtonClass
  ---@param w number # Suggested: `198`, `258`, `355`, `415`
  ---@param h number # Suggested: `50`
  ---@return Button
  new = function(this, w, h)
    ---@class Button : ButtonClass
    local t = {
      w = w or 0,
      h = h or 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this Button
  ---@param p table
  -- ```
  -- {
  --   x: number = 0,
  --   y: number = 0,
  --   alpha: number = 1,
  -- }
  -- ```
  render = function(this, p)
    drawRect({
      x = p.x,
      y = p.y,
      w = this.w,
      h = this.h,
      alpha = 80 * (p.alpha or 1),
      color = 'med',
    });

    drawRect({
      x = p.x,
      y = p.y,
      w = 6,
      h = this.h,
      alpha = 255 * (p.accentAlpha or 1),
      color = 'norm',
    });
  end,
};

return Button;