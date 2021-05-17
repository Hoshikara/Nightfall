---@type string
local earlatePos = getSetting('earlatePos', 'BOTTOM');
---@type string
local earlateType = getSetting('earlateType', 'TEXT');

---@class EarlateClass
local Earlate = {
  -- Earlate constructor
  ---@param this EarlateClass
  ---@param window Window
  ---@param state Gameplay
  ---@return Earlate
  new = function(this, window, state)
    ---@class Earlate : EarlateClass
    ---@field labels table<string, Label>
    ---@field state Gameplay
    ---@field window Window
    local t = {
      alpha = 0,
      cache = { w = 0, h = 0 },
      deltaAlign = 'middle',
      labels = {
        delta = makeLabel('num', '0.0 ms', 30),
        early = makeLabel('med', 'EARLY', 30),
        late = makeLabel('med', 'LATE', 30),
      },
      offset = 0,
      x = 0,
      y = 0,
      state = state,
      textAlign = 'middle',
      timer = 0,
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Earlate
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.x = this.window.w / 2;

      if (earlatePos == 'BOTTOM') then
        this.y = this.window.h - (this.window.h / 3.35);
      elseif (earlatePos == 'MIDDLE') then
        this.y = this.window.h - (this.window.h / 1.85);
      elseif (earlatePos == 'UPPER') then
        this.y = this.window.h - (this.window.h / 1.35);
      elseif (earlatePos == 'UPPER+') then
        this.y = this.window.h - (this.window.h / 1.15);
      end

      if (earlateType == 'TEXT + DELTA') then
        this.deltaAlign = 'rightMid';
        this.textAlign = 'leftMid';
        this.offset = this.window.w / 11;
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Renders the current component
  ---@param this Earlate
  ---@param dt deltaTime
  render = function(this, dt)
    if (earlatePos == 'OFF') then return; end

    this.state.timers.earlate = to0(this.state.timers.earlate, dt, 1);

    if (this.state.timers.earlate == 0) then return; end

    this:setSizes();

    this.timer = this.timer + dt;

    this.alpha = math.floor(this.timer * 30) % 2;
    this.alpha = ((this.alpha * 175) + 80) / 255;

    local color = (this.state.isLate and { 105, 205, 255 }) or { 255, 105, 255 };
    ---@type Label
    local label = (this.state.isLate and this.labels.late) or this.labels.early;
    local deltaStr = ('%.1f ms'):format(this.state.buttonDelta);

    if (this.state.buttonDelta > 0) then
      deltaStr = ('+%.1f ms'):format(this.state.buttonDelta);
    end

    gfx.Save();

    gfx.Translate(this.x, this.y);

    if (earlateType ~= 'DELTA') then
      label:draw({
        x = -this.offset;
        y = 2,
        align = this.textAlign,
        alpha = 100,
        color = { 150, 150, 150 },
      });

      label:draw({
				x = -this.offset,
				y = 0,
				align = this.textAlign,
				alpha = 255 * this.alpha,
				color = color,
			});
    end

    if (earlateType ~= 'TEXT') then
      this.labels.delta:draw({
        x = this.offset,
        y = 6,
        align = this.deltaAlign,
        alpha = 100,
        color = { 150, 150, 150 },
        text = deltaStr,
        update = true,
      });

      this.labels.delta:draw({
        x = this.offset,
        y = 4,
        align = this.deltaAlign,
        alpha = 255 * this.alpha,
        color = color,
        text = deltaStr,
        update = true,
      });
    end

    gfx.Restore();
  end,
};

return Earlate;