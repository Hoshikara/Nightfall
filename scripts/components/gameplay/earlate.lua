local Colors = {
  crit = { 255, 235, 100 },
  early = { 255, 105, 255 },
  late = { 105, 205, 255 },
};

---@type number
local earlateX = getSetting('earlateX', 0.5);
local earlateY = getSetting('earlateY', 0.75);
local earlateGap = getSetting('earlateGap', 0.25);
local showEarlate = getSetting('showEarlate', true);

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
      this.offset = 0;

      this.x = this.window.w * earlateX;

      if (this.window.isPortrait) then
        this.y = ((this.window.h * 0.625) * earlateY) + (this.window.h * 0.125);
      else
        this.y = this.window.h * earlateY;
      end

      if (earlateType == 'TEXT + DELTA') then
        this.deltaAlign = 'rightMid';
        this.textAlign = 'leftMid';

        if (this.window.isPortrait) then
          this.offset = this.window.w * (earlateGap * 0.4);
        else
          this.offset = this.window.w * (earlateGap * 0.25);
        end
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Renders the current component
  ---@param this Earlate
  ---@param dt deltaTime
  render = function(this, dt)
    if (not showEarlate) then return; end

    this.state.timers.earlate = to0(this.state.timers.earlate, dt, 1);

    if (this.state.timers.earlate == 0) then return; end

    this:setSizes();

    this.timer = this.timer + dt;

    this.alpha = math.floor(this.timer * 30) % 2;
    this.alpha = ((this.alpha * 175) + 80) / 255;

    local color = (this.state.isLate and Colors.late) or Colors.early;
    ---@type Label
    local label = (this.state.isLate and this.labels.late) or this.labels.early;
    local deltaStr = ('%.1f ms'):format(this.state.buttonDelta);

    if (this.state.isCrit) then color = Colors.crit; end

    if (this.state.buttonDelta > 0) then
      deltaStr = ('+%.1f ms'):format(this.state.buttonDelta);
    end

    gfx.Save();

    gfx.Translate(this.x, this.y);

    if ((earlateType ~= 'DELTA') and (not this.state.isCrit)) then
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