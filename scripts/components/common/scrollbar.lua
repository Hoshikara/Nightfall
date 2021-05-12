local floor = math.floor;

---@class ScrollbarClass
local Scrollbar = {
  -- Scrollbar constructor
  ---@param this ScrollbarClass
  ---@return Scrollbar
  new = function(this)
    ---@class Scrollbar : ScrollbarClass
    local t = {
      curr = 0,
      timer = 1,
      x = 0,
      y = {
        bar = {
          curr = 0,
          offset = 0,
          prev = 0,
        },
        track = 0,
      },
      w = 8,
      h = { bar = 32, track = 0 },
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Scrollbar
  ---@param params table #
  -- ```
  -- {
  --   x: number,
  --   y: number,
  --   h: number, 
  -- }
  -- ```
  setSizes = function(this, params)
    this.x = params.x;
    this.y.track = params.y;

    this.h.track = params.h;
    this.h.remaining = this.h.track - this.h.bar;
  end,

  -- Sets the position for the current scrollbar
  ---@param this Scrollbar
  ---@param dt deltaTime
  ---@param curr number
  ---@param total number
  handleChange = function(this, dt, curr, total)
    if (this.curr ~= curr) then
      this.timer = 0;

      this.curr = curr;
    end

    this.timer = to1(this.timer, dt, 0.25);

    this.y.bar.curr = floor(this.h.remaining * ((curr - 1) / (total - 1)));

    this.y.bar.offset = this.y.bar.prev
      + (this.y.bar.curr - this.y.bar.prev)
      * smoothstep(this.timer);
    
    if (tostring(this.y.bar.offset) == '-nan(ind)') then
      this.y.bar.prev = 0;
    else
      this.y.bar.prev = this.y.bar.offset;
    end
  end,

  -- Renders the current component
  ---@param this Scrollbar
  ---@param dt deltaTime
  ---@param params table #
  -- ```
  -- {
  --   curr: number = 1,
  --   total: number = 1,
  -- }
  -- ```
  render = function(this, dt, params)
    this:handleChange(
      dt,
      params.curr or 1,
      params.total or 1
    );

    gfx.Save();

    drawRect({
      x = this.x,
      y = this.y.track,
      w = this.w,
      h = this.h.track,
      alpha = 120 * (params.alphaMod or 1),
      color = params.color or 'dark',
      fast = true,
    });

    gfx.Translate(this.x, this.y.track + this.y.bar.offset);

    drawRect({
      x = 0,
      y = 0,
      w = this.w,
      h = this.h.bar,
      alpha = 255 * (params.alphaMod or 1),
      color = 'norm',
      fast = true,
    });

    gfx.Restore();
  end,
};

return Scrollbar;