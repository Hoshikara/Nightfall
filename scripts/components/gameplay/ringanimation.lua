local Animation = require('common/animation');

local asin = math.asin;
local sin = math.sin;

---@param t number # timer
local triWave = function(t) return (2 / 3.14) * asin(sin(t)); end

---@class RingAnimationClass
local RingAnimation = {
  -- RingAnimation constructor
  ---@param this RingAnimationClass
  ---@return RingAnimation
  new = function(this, color)
    ---@class RingAnimation : RingAnimationClass
    local t = {
      isHold = not color,
      scale = 0.825,
      speed = (color and 2) or 1,
    };

    local useSDVX = getSetting('sdvxHitAnims', false);

    if (color) then
      t.ring = Image:new(('gameplay/hit_animation/ring/ring_%s.png'):format(color));
      t.inner = Animation:new({
        alpha = 1.25,
        blendOp = 8,
        centered = true,
        fps = 42,
        frameCount = 5,
        loop = true,
        path = ('gameplay/hit_animation/ring/inner/%s'):format(color),
        scale = 1,
      });
    else
      t.effect = Image:new(('gameplay/hit_animation/ring/effect_%s.png'):format(
        (useSDVX and 'g') or 'b'
      ));
      t.ring = Image:new(('gameplay/hit_animation/ring/ring_%d.png'):format(
        (useSDVX and 2) or 1
      ));
      t.inner = Animation:new({
        alpha = (useSDVX and 2) or 1.5,
        blendOp = 8,
        centered = true,
        fps = (useSDVX and 60) or 40,
        frameCount = (useSDVX and 7) or 4,
        loop = true,
        path = ('gameplay/hit_animation/ring/inner/hold/%s'):format(
          (useSDVX and 'g') or 'b'
        ),
        scale = (useSDVX and 0.65) or 0.725,
      });
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Plays the intro/outro effect for holds
  ---@param this RingAnimation
  ---@param dt deltaTime
  ---@param holdActive boolean
  ---@param state RingAnimationEffectState
  playEffect = function(this, dt, holdActive, state)
    if ((not holdActive) and (not state.playOut)) then return; end

    if (holdActive) then
      if (state.playIn and (state.alpha == 0)) then
        state.alpha = 1;
        state.playIn = false;
        state.playOut = true;
        state.timer = 0;
      end
    elseif (not holdActive) then
      if (state.playIn) then -- intro effect did not finish
        state.alpha = 1;
        state.playIn = false;
        state.playOut = true;
        state.timer = 0;
      elseif (state.playOut and (state.alpha == 0)) then -- reset
        state.alpha = 1;
        state.playIn = true;
        state.playOut = false;
        state.timer = 0;
      end
    end

    if (state.playIn or ((not holdActive) and (state.playOut))) then
      state.timer = to1(state.timer, dt, 0.125);

      if (state.timer >= 0.5) then state.alpha = to0(state.alpha, dt, 0.125); end

      this.effect:draw({
        w = w,
        h = w,
        alpha = 1.75 * state.alpha,
        blendOp = 8,
        centered = true,
        scale = state.timer * 1.35,
      });
    end
  end,

  -- Start the ring animation
  ---@param this RingAnimation
  ---@param dt deltaTime
  ---@param state AnimationState
  start = function(this, dt, state)
    if (state.effect) then this:playEffect(dt, state.active, state.effect); end

    if (state.active) then
      if (this.isHold) then
        state.alpha = to1(state.alpha, dt, 0.1);
      else
        state.alpha = 1;
      end
    else
      state.alpha = 0;
      state.timer = 0;

      return;
    end

    state.timer = state.timer + (dt * 2);

    local alpha = state.alpha;
    local isHold = this.isHold;
    local scale = this.scale;
    local speed = this.speed;
    local w = this.ring.w;

    if (isHold) then
      if (state.timer <= 0.5) then speed = 4; end
    end

    local t = state.timer * speed;

    this.ring:draw({
      alpha = alpha,
      blendOp = 8,
      centered = true,
      scale = scale,
    });

    gfx.Translate(0, (isHold and -10) or 4);

    state.inner.alpha = alpha;

    this.inner:start(dt, state.inner);

    gfx.Translate(0, (isHold and 10) or -4);

    gfx.Rotate(-(0.8 - (t * 1.5)));

    this.ring:draw({
      w = w * triWave(t),
      alpha = alpha,
      blendOp = 8,
      centered = true,
      scale = scale,
    });

    gfx.Rotate(0.8 - (t * 1.5));
    gfx.Rotate(-1.8 + (t * 1.5));

    this.ring:draw({
      w = w * triWave(t + 2.8),
      alpha = alpha,
      blendOp = 8,
      centered = true,
      scale = scale,
    });
  end,
};

return RingAnimation;