local Animation = require('common/animation');

local RingAnimation = require('components/gameplay/ringanimation');

local Colors = {
  RED = 'r',
  GREEN = 'g',
  BLUE = 'b',
  YELLOW = 'y',
};

local colL = Colors[getSetting('leftColor', 'BLUE')];
local colR = Colors[getSetting('rightColor', 'RED')];

---@class LaserAnimationClass
local LaserAnimation = {
  -- LaserAnimation constructor
  ---@param this LaserAnimationClass
  ---@param window Window
  ---@return LaserAnimation
  new = function(this, window)
    ---@class LaserAnimation : LaserAnimationClass
    ---@field window Window
    local t = {
      ring = {},
      slam = {},
      ---@type table<string, AnimationState[]>
      states = {
        ring = {},
        slam = {},
      },
      window = window,
    };

    for i = 1, 2 do
      local color = ((i == 1) and colL) or colR;

      t.ring[i] = RingAnimation:new(color);

      t.slam[i] = Animation:new({
        alpha = 1.5,
        blendOp = 8,
        centered = true,
        fps = 52,
        frameCount = 12,
        path = ('gameplay/hit_animation/slam/%s'):format(color),
        scale = 0.625,
      });

      for name, part in pairs(t.states) do
        if (name ~= 'ring') then
          part[i] = {};

          for j = 1, 16 do
            part[i][j] = {
              frame = 1,
              pos = 0,
              queued = false,
              timer = 0,
            };
          end
        else
          part[i] = {
            active = false,
            alpha = 0,
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

  -- Queues an animation to be played
  ---@param this LaserAnimation
  ---@param pos number # x-position relative to the center of the crit line
  ---@param laser integer # Laser index, `1 = left`, `2 = right`
  trigger = function(this, pos, laser)
    for _, state in ipairs(this.states.slam[laser]) do
      if (not state.queued) then
        state.pos = 0.5 + (pos * 0.8);
        state.queued = true;

        break;
      end
    end
  end,

  -- Transformation helper function
  ---@param this LaserAnimation
  ---@param pos number # x-position relative to the center of the crit line
  transform = function(this, pos)
    if (pos) then
      gfx.Translate(
        gameplay.critLine.line.x1
          + (gameplay.critLine.line.x2 - gameplay.critLine.line.x1)
          * pos,
        gameplay.critLine.line.y1
          + (gameplay.critLine.line.y2 - gameplay.critLine.line.y1)
          * pos
          - (36 * this.window:getScale())
      );
    else
      gfx.Translate(gameplay.critLine.x, gameplay.critLine.y);
    end

    gfx.Rotate(-gameplay.critLine.rotation);

    if (pos) then this.window:scale(); end
  end,

  -- Play the given animation
  ---@param this LaserAnimation
  ---@param dt deltaTime
  ---@param animation Animation
  ---@param state AnimationState
  play = function(this, dt, animation, state)
    gfx.Save();

    this:transform(state.pos);

    animation:start(dt, state, function() state.pos = 0; end);

    gfx.Restore();
  end,

  -- Play the cursor animation and draw the cursor tail
  ---@param this LaserAnimation
  ---@param dt deltaTime
  ---@param ring RingAnimation
  ---@param pos number
  playRing = function(this, dt, ring, state, pos)
    ring.scale = 0.85 * this.window:getScale();
    ring.inner.scale = 1.1 * this.window:getScale();

    gfx.Save();

    this:transform();

    gfx.Translate(pos, 0);

    ring:start(dt, state);

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this LaserAnimation
  ---@param dt deltaTime
  render = function(this, dt)
    local ring = this.states.ring;
    local slam = this.states.slam;

    for laser = 1, 2 do
      local curr = gameplay.critLine.cursors[laser - 1];

      ---@param state AnimationState
      for _, state in ipairs(slam[laser]) do
        if (state.queued) then this:play(dt, this.slam[laser], state); end
      end

      ring[laser].active = gameplay.laserActive[laser];
  
      this:playRing(dt, this.ring[laser], ring[laser], curr.pos);
    end
  end,
};

return LaserAnimation;