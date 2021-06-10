local Animation = require('common/animation');

local RingAnimation = require('components/gameplay/ringanimation');

-- Lane position map
local Lanes = {
  1.5 / 6,
  2.5 / 6,
  3.5 / 6,
  4.5 / 6,
  1 / 3,
  2 / 3,
};

---@class HitAnimationClass
local HitAnimation = {
  -- HitAnimation constructor
  ---@param this HitAnimationClass
  ---@param window Window
  ---@return HitAnimation
  new = function(this, window)
    ---@class HitAnimation : HitAnimationClass
    ---@field window Window
    local t = {
      crit = Animation:new({
        alpha = 1.2,
        centered = true,
        fps = 58,
        frameCount = 17,
        path = 'gameplay/hit_animation/critical',
        scale = 0.65,
      }),
      hold = RingAnimation:new(),
      near = Animation:new({
        alpha = 1,
        centered = true,
        fps = 74,
        frameCount = 17,
        path = 'gameplay/hit_animation/near',
        scale = 0.975,
      }),
      ---@type table<string, AnimationState[]>
      states = {
        crit = {},
        hold = {},
        near = {},
      },
      window = window,
    };

    for name, part in pairs(t.states) do
      for btn = 1, 6 do
        if (name ~= 'hold') then
          part[btn] = {};

          for i = 1, 8 do
            part[btn][i] = {
              frame = 1,
              queued = false,
              timer = 0,
            };
          end
        else
          part[btn] = {
            active = false,
            alpha = 0,
            effect = {
              alpha = 1,
              playIn = true,
              playOut = false,
              timer = 0,
            },
            inner = {
              frame = 1,
              timer = 0,
            },
            timer = 0,
          };
        end
      end
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Queues a hit animation to be played
  ---@param this HitAnimation
  ---@param btn integer # `0 = BTA`, `1 = BTB`, `2 = BTC`, `3 = BTD`, `4 = FXL`, `5 = FXR`
  ---@param rating integer # `0 = Miss`, `1 = Near`, `2 = Crit`, `3 = Idle`
  trigger = function(this, btn, rating)
    if (rating == 2) then
      for _, state in ipairs(this.states.crit[btn + 1]) do
        if (not state.queued) then state.queued = true; break; end
      end
    elseif (rating == 1) then
      for _, state in ipairs(this.states.near[btn + 1]) do
        if (not state.queued) then state.queued = true; break; end
      end
    end
  end,

  -- Transformation helper function
  ---@param this HitAnimation
  ---@param lane number # From `Lanes` map
  transform = function(this, lane)
    gfx.Translate(
      gameplay.critLine.line.x1
        + (gameplay.critLine.line.x2 - gameplay.critLine.line.x1)
        * lane,
      gameplay.critLine.line.y1
        + (gameplay.critLine.line.y2 - gameplay.critLine.line.y1)
        * lane
    );
    gfx.Rotate(-gameplay.critLine.rotation);
    this.window:scale();
  end,

  -- Play the given animation
  ---@param this HitAnimation
  ---@param dt deltaTime
  ---@param animation Animation
  ---@param lane number # From `Lanes` map
  ---@param state AnimationState
  play = function(this, dt, animation, lane, state)
    gfx.Save();

    this:transform(lane);

    animation:start(dt, state);

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this HitAnimation
  ---@param dt deltaTime
  render = function(this, dt)
    local crit = this.states.crit;
    local hold = this.states.hold;
    local near = this.states.near;

    for btn = 1, 6 do
      ---@param state AnimationState
      for _, state in ipairs(crit[btn]) do
        if (state.queued) then
          this:play(dt, this.crit, Lanes[btn], state);
        end
      end

      ---@param state AnimationState
      for _, state in ipairs(near[btn]) do
        if (state.queued) then
          this:play(dt, this.near, Lanes[btn], state);
        end
      end

      hold[btn].active = gameplay.noteHeld[btn];

      this:play(dt, this.hold, Lanes[btn], hold[btn]);
    end
  end,
};

return HitAnimation;