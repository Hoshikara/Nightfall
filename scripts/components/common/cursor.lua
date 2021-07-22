local floor = math.floor;

-- Get the column and row of the current item
---@param i number # item index
---@return number, number
local getGridPos = function(i)
  return floor((i - 1) / 3) % 3, floor((i - 1) % 3);
end

---@class CursorClass
local Cursor =  {
  -- Cursor constructor
  ---@param this CursorClass
  ---@param p CursorConstructorParams
  ---@param simple? boolean # `true` if cursor is not animated
  ---@return Cursor
  new = function(this, p, simple)
    ---@class Cursor : CursorClass
    local t = {
      duration = 0.2,
      size = p.size or 6,
      stroke = p.stroke or 1,
      type = p.type or 'vertical',
    };

    if (not simple) then
      t.alpha = 0;
      t.margin = 0;
      t.curr = 0;
      t.timers = {
        flicker = 0,
        phase = 0,
        smoothing = 0,
      };
      t.x = {
        base = 0,
        curr = 0,
        offset = 0,
        prev = 0,
      };
      t.y = {
        base = 0,
        curr = 0,
        offset = 0,
        prev = 0,
      };
      t.w = 0;
      t.h = 0;
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Cursor
  ---@param params CursorSetSizesParams
  setSizes = function(this, params)
    this.x.base = params.x or this.x.base;
    this.y.base = params.y or this.y.base;
    this.w = params.w or this.w;
    this.h = params.h or this.h;
    this.margin = params.margin or this.margin;
  end,

  -- Draws the current cursor
  ---@param this Cursor
  ---@param params CursorDrawParams
  draw = function(this, params)
    local x = params.x or (this.x.base + this.x.offset);
    local y = params.y or (this.y.base + this.y.offset);
    local w = params.w or this.w;
    local h = params.h or this.h;
    local size = params.size or this.size * 0.95;
    local gap = size / (size * 1.05);
  
    gfx.BeginPath();

    setStroke({
      alpha = params.alpha or (255 * this.alpha * params.alphaMod),
      color = 'white',
      size = this.stroke,
    });
  
    gfx.MoveTo(x - size - gap, y);
    gfx.LineTo(x - size - gap, y - size);
    gfx.LineTo(x - gap, y - size);
  
    gfx.MoveTo(x + w + size + gap, y);
    gfx.LineTo(x + w + size + gap, y - size);
    gfx.LineTo(x + w + gap, y - size);
  
    gfx.MoveTo(x - size - gap, y + h);
    gfx.LineTo(x - size - gap, y + h + size);
    gfx.LineTo(x - gap, y + h + size);
  
    gfx.MoveTo(x + w + size + gap, y + h);
    gfx.LineTo(x + w + size + gap, y + h + size);
    gfx.LineTo(x + w + gap, y + h + size);
  
    gfx.Stroke();
  end,

  -- Sets the position for the current cursor
  ---@param this Cursor
  ---@param dt deltaTime
  ---@param h number
  ---@param curr number
  ---@param forceFlicker boolean
  ---@param total number
  handleChange = function(this, dt, h, curr, forceFlicker, total)
    this.timers.flicker = this.timers.flicker + dt;
    this.timers.phase = this.timers.phase + dt;

    this.alpha = flicker(this.timers.flicker, this.timers.phase, 0.85, 0.2);

    if ((this.curr ~= curr) or forceFlicker) then
      this.timers.flicker = 0;
      this.timers.smoothing = 0;

      this.curr = curr;
    end

    this.timers.smoothing = to1(this.timers.smoothing, dt, this.duration);

    local smoothing = smoothstep(this.timers.smoothing);

    if (this.type == 'grid') then
      local column, row = getGridPos(curr);

      this.x.curr = (this.h + this.margin) * row;
      this.y.curr = (this.h + this.margin) * column;

      this.x.offset = this.x.prev + (this.x.curr - this.x.prev) * smoothing;
      this.y.offset = this.y.prev + (this.y.curr - this.y.prev) * smoothing;

      this.x.prev = this.x.offset;
      this.y.prev = this.y.offset;
    else
      local i = total;

      if ((curr % total) > 0) then i = curr % total; end

      if (this.type == 'horizontal') then
        this.x.curr = (this.w + this.margin) * (i - 1);
        
        this.x.offset = this.x.prev + (this.x.curr - this.x.prev) * smoothing;

        this.x.prev = this.x.offset;
      else
        this.y.curr = (h + this.margin) * (i - 1);
        
        this.y.offset = this.y.prev + (this.y.curr - this.y.prev) * smoothing;

        this.y.prev = this.y.offset;
      end
    end
  end,

  -- Renders the current component
  ---@param this Cursor
  ---@param dt deltaTime
  ---@param params CursorRenderParams
  render = function(this, dt, params)
    this:handleChange(
      dt,
      params.h or this.h,
      params.curr or 1,
      params.forceFlicker or false,
      params.total or 1
    );

    gfx.Save();

    this:draw({ alphaMod = params.alphaMod or 1 });

    gfx.Restore();
  end,
};

return Cursor;