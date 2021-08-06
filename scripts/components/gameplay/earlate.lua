local Gray = { 150, 150, 150 };

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
      gap = getSetting('earlateGap', 0.25),
      hz = getSetting('earlateHz', 18),
      labels = {
        delta = makeLabel('num', '0.0 ms', 30),
        early = makeLabel('med', 'EARLY', 30),
        late = makeLabel('med', 'LATE', 30),
      },
      offset = 0,
      opacity = getSetting('earlateOpacity', 1),
      x = 0,
      y = 0,
      show = getSetting('showEarlate', true),
      state = state,
      textAlign = 'middle',
      timer = 0,
      type = getSetting('earlateType', 'TEXT'),
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Earlate
  ---@param isPreview boolean
  setSizes = function(this, isPreview)
    if ((this.cache.w ~= this.window.w)
      or (this.cache.h ~= this.window.h)
      or isPreview
    ) then
      local earlateX = getSetting('earlateX', 0.5);
      local earlateY = getSetting('earlateY', 0.75);

      this.offset = 0;

      this.x = this.window.w * earlateX;

      if (this.window.isPortrait) then
        this.y = ((this.window.h * 0.625) * earlateY) + (this.window.h * 0.125);
      else
        this.y = this.window.h * earlateY;
      end

      if (this.type == 'TEXT + DELTA') then
        this.deltaAlign = 'rightMid';
        this.textAlign = 'leftMid';

        if (this.window.isPortrait) then
          this.offset = this.window.w * (this.gap * 0.4);
        else
          this.offset = this.window.w * (this.gap * 0.25);
        end
      else
        this.deltaAlign = 'middle';
        this.textAlign = 'middle';
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Updates skin settings
  ---@param this Earlate
  update = function(this)
    this.gap = getSetting('earlateGap', 0.25);
    this.hz = getSetting('earlateHz', 18);
    this.opacity = getSetting('earlateOpacity', 1);
    this.show = getSetting('showEarlate', true);
    this.type = getSetting('earlateType', 'TEXT');
  end,

  -- Renders the current component
  ---@param this Earlate
  ---@param dt deltaTime
  ---@param isPreview boolean
  render = function(this, dt, isPreview)
    if (isPreview) then this:update(); end

    if (not this.show) then return; end

    if (not isPreview) then
      this.state.timers.earlate = to0(this.state.timers.earlate, dt, 1);
    end

    if (this.state.timers.earlate == 0) then return; end

    this:setSizes(isPreview);

    this.timer = this.timer + dt;

    this.alpha = ((this.timer * this.hz) % 1) * this.opacity;

    local isLate = this.state.buttonDelta > 0;
    local color = (isLate and Colors.late) or Colors.early;
    ---@type Label
    local label = (isLate and this.labels.late) or this.labels.early;
    local deltaStr =
      ((isLate and ('+%.1f ms')) or ('%.1f ms')):format(this.state.buttonDelta);

    gfx.Save();

    gfx.Translate(this.x, this.y);

    if ((this.type ~= 'DELTA') and (not this.state.isCrit)) then
      label:draw({
        x = -this.offset;
        y = 2,
        align = this.textAlign,
        alpha = 100 * this.alpha,
        color = Gray,
      });

      label:draw({
				x = -this.offset,
				y = 0,
				align = this.textAlign,
				alpha = 255 * this.alpha,
				color = color,
			});
    end

    if (this.type ~= 'TEXT') then
      this.labels.delta:draw({
        x = this.offset,
        y = 6,
        align = this.deltaAlign,
        alpha = 100 * this.alpha,
        color = Gray,
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