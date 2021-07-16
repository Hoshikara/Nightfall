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
      t.effect = Image:new('gameplay/hit_animation/ring/effect.png');
      t.ring = Image:new('gameplay/hit_animation/ring/ring.png');
      t.inner = Animation:new({
        alpha = 1.5,
        blendOp = 8,
        centered = true,
        fps = 40,
        frameCount = 4,
        loop = true,
        path = 'gameplay/hit_animation/ring/inner/hold',
        scale = 0.725,
      });
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Start the ring animation
  ---@param this RingAnimation
  ---@param dt deltaTime
  ---@param state AnimationState
  start = function(this, dt, state)
    if (state.active) then
      if (this.isHold) then
        state.alpha = to1(state.alpha, dt, 0.1);
      else
        state.alpha = 1;
      end
    else
      if (state.effect) then
        if (state.effect.playIn) then
          state.effect.alpha = 1;
          state.effect.timer = 0;
          
          state.inner.frame = 1;
          state.inner.timer = 0;

          state.timer = 0;

          return;
        else
          if (not state.effect.playOut) then state.effect.playOut = true; end
        end
      elseif (state.alpha == 0) then return; end

      if (this.isHold) then
        state.alpha = to0(state.alpha, dt, 0.1);
      else
        state.alpha = 0;
      end
      
      state.timer = 0;
    end

    state.timer = state.timer + (dt * 2);

    local alpha = state.alpha;
    local isHold = this.isHold;
    local scale = this.scale;
    local speed = this.speed;
    local w = this.ring.w;

    if (isHold) then
      if (state.timer <= 0.5) then speed = 4; end

      if (state.effect.playIn or state.effect.playOut) then
        state.effect.timer = to1(state.effect.timer, dt, 0.125);

        if (state.effect.timer >= 0.8) then
          state.effect.alpha = to0(state.effect.alpha, dt, 0.125);
        end

        this.effect:draw({
          w = w,
          h = w,
          alpha = 1.5 * state.effect.alpha,
          blendOp = 8,
          centered = true,
          scale = state.effect.timer,
        });

        if (state.effect.alpha == 0) then
          state.effect.alpha = 1;
          state.effect.timer = 0;

          if (state.effect.playIn) then
            state.effect.playIn = false;
          elseif (state.effect.playOut) then
            state.effect.playIn = true;
            state.effect.playOut = false;
          end
        end
      end
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