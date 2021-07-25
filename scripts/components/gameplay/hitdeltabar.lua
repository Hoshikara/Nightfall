---@class HitDeltaBarClass
local HitDeltaBar = {
  -- HitDeltaBar constructor
  ---@param this HitDeltaBarClass
  ---@param window Window
  ---@return HitDeltaBar
  new = function(this, window)
    ---@class HitDeltaBar : HitDeltaBarClass
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      ---@type table<string, integer[]>
      critScale = 1,
      critWin = (gameplay and gameplay.hitWindow and gameplay.hitWindow.perfect) or 46,
      decayTime = getSetting('hitDecayTime', 6.0),
      nearScale = 1,
      nearWin = (gameplay and gameplay.hitWindow and gameplay.hitWindow.good) or 92,
      ---@type table<string, AnimationState[]>
      states = { crit = {}, near = {} },
      timer = 1,
      window = window,
      x = { base = 0, near = 0 },
      y = 40,
      w = 0,
      wBar = { 3, 2 },
      h = 30,
    };

    t.labels = {
      critNeg = makeLabel('num', ('-%d'):format(t.critWin), 20),
      critPos = makeLabel('num', ('+%d'):format(t.critWin), 20),
      nearNeg = makeLabel('num', ('-%d'):format(t.nearWin), 20),
      nearPos = makeLabel('num', ('+%d'):format(t.nearWin), 20),
      zero = makeLabel('num', '0', 20),
    };

    for _, rating in pairs(t.states) do
      for btn = 1, 6 do
        rating[btn] = {};

        for i = 1, 40 do
          rating[btn][i] = {
            color = 'white',
            delta = 0,
            queued = false,
            timer = 1,  
          };
        end
      end
    end
    
    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this HitDeltaBar
  ---@param isPreview boolean
  setSizes = function(this, isPreview)
    if ((this.cache.w ~= this.window.w)
      or (this.cache.h ~= this.window.h)
      or isPreview
    ) then
      local hitDeltaBarScale = getSetting('hitDeltaBarScale', 1.0);

      if (this.window.isPortrait) then
        this.w = this.window.w * 0.495 * hitDeltaBarScale;
        this.y = this.window.h / 6;
      else
        this.w = (this.window.w / 3) * hitDeltaBarScale;
        this.y = 28;
      end

      this.x.base = this.window.w / 2;
      this.x.near = this.w / 4;

      this.wBar[1] = 3 * hitDeltaBarScale;
      this.wBar[2] = 2 * hitDeltaBarScale;
      this.h = 30 * hitDeltaBarScale;

      this.critScale = (this.w / 4) / this.critWin;
      this.nearScale = (this.w / 4) / (this.nearWin - this.critWin);

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the given hit delta
  ---@param this HitDeltaBar
  ---@param dt deltaTime
  ---@param state AnimationState
  drawHit = function(this, dt, state)
    state.timer = to0(state.timer, dt, this.decayTime);

    drawRect({
      x = state.delta - (this.wBar[2] / 2),
      y = 4,
      w = this.wBar[2],
      h = this.h - 8,
      alpha = 255 * (state.timer ^ 2),
      blendOp = gfx.BLEND_OP_LIGHTER,
      color = state.color,
    });

    if (state.timer == 0) then
      state.delta = 0;
      state.queued = false;
      state.timer = 1;
    end
  end,

  -- Queues a hit delta to be drawn
  ---@param this HitDeltaBar
  ---@param btn integer # `0 = BTA`, `1 = BTB`, `2 = BTC`, `3 = BTD`, `4 = FXL`, `5 = FXR`
  ---@param rating integer # `0 = Miss`, `1 = Near`, `2 = Crit`, `3 = Idle`
  ---@param delta integer # delta from 0 of the hit, in milliseconds
  trigger = function(this, btn, rating, delta)
    if (rating == 2) then
      for _, state in ipairs(this.states.crit[btn + 1]) do
        if (not state.queued) then
          state.color = Colors.critical;
          state.delta = delta * this.critScale;
          state.queued = true;

          break;
        end
      end
    elseif (rating == 1) then
      for _, state in ipairs(this.states.near[btn + 1]) do
        if (not state.queued) then
          if (delta < 0) then
            state.color = Colors.early;
            state.delta = -this.x.near
              + ((delta + this.critWin) * this.nearScale);
          else
            state.color = Colors.late;
            state.delta = this.x.near
              + ((delta - this.critWin) * this.nearScale);
          end

          state.queued = true;

          break;
        end
      end
    end
  end,

  -- Renders the current component
  ---@param this HitDeltaBar
  ---@param dt deltaTime
  ---@param isPreview boolean
  render = function(this, dt, isPreview)
    local alpha = 255 * this.timer;
    local crit = this.states.crit;
    local critCol = Colors.critical;
    local near = this.states.near;

    if (isPreview) then
      this.decayTime = getSetting('hitDecayTime', 6.0);
    else
      if (gameplay.progress == 0) then
        for _, rating in pairs(this.states) do
          for btn = 1, 6 do
            if (not rating[btn]) then break; end

            for i = 1, 30 do
              rating[btn][i].color = 'white';
              rating[btn][i].delta = 0;
              rating[btn][i].queued = false;
              rating[btn][i].timer = 1;
            end
          end
        end
      end
    end

    this:setSizes(isPreview);

    local w = this.wBar[1];
    local h = this.h;

    gfx.Save();

    gfx.Translate(this.x.base, this.y);

    for btn = 1, 6 do
      for _, state in ipairs(crit[btn]) do
        if (state.queued) then this:drawHit(dt, state); end
      end

      for _, state in ipairs(near[btn]) do
        if (state.queued) then this:drawHit(dt, state); end
      end
    end

    drawRect({
      x = -(w / 2),
      y = 0,
      w = w,
      h = h,
      alpha = 200,
      color = 'white',
    });

    drawRect({
      x = -this.x.near - (w / 2),
      y = 0,
      w = w,
      h = h,
      alpha = 100,
      color = critCol,
    });

    drawRect({
      x = this.x.near - (w / 2),
      y = 0,
      w = w,
      h = h,
      alpha = 100,
      color = critCol,
    });

    drawRect({
      x = -(this.w / 2) - (w / 2),
      y = 0,
      w = w,
      h = h,
      alpha = 100,
      color = Colors.early,
    });

    drawRect({
      x = (this.w / 2) - (w / 2),
      y = 0,
      w = w,
      h = h,
      alpha = 100,
      color = Colors.late,
    });

    if (not isPreview) then
      if (gameplay.progress > 0) then this.timer = to0(this.timer, dt, 1); end

      if (this.timer > 0) then
        this.labels.zero:draw({
          x = 0,
          y = -16,
          align = 'middle',
          alpha = alpha,
          color = 'white',
        });

        this.labels.critNeg:draw({
          x = -this.x.near - 1,
          y = -16,
          align = 'middle',
          alpha = alpha,
          color = critCol,
        });

        this.labels.critPos:draw({
          x = this.x.near,
          y = -16,
          align = 'middle',
          alpha = alpha,
          color = critCol,
        });

        this.labels.nearNeg:draw({
          x = -(this.w / 2) - 1,
          y = -16,
          align = 'middle',
          alpha = alpha,
          color = Colors.early,
        });

        this.labels.nearPos:draw({
          x = this.w / 2,
          y = -16,
          align = 'middle',
          alpha = alpha,
          color = Colors.late,
        });
      end
    end

    gfx.Restore();
  end,
};

return HitDeltaBar;