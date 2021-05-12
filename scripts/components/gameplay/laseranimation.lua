local Animation = require('common/animation');

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
      dome = {},
      domeSize = 0,
      ---@type table<string, Animation[]>
      ending = { inner = {}, outer = {} },
      ---@type table<string, AnimationState[]>
      states = {
        inner = {},
        outer = {},
      },
      ---@type Image[]
      tail = {},
      window = window,
    };

    for i = 1, 2 do
      local side = ((i == 1) and 'l') or 'r';

      t.dome[i] = gfx.LoadSkinAnimation(
        ('gameplay/hit_animation/laser_%s/dome'):format(side),
        (1 / 30.0)
      );

      t.tail[i] = Image:new(('gameplay/laser_cursor/tail_%s.png'):format(side));

      t.ending.inner[i] = Animation:new({
        alpha = 2,
        blendOp = gfx.BLEND_OP_SOURCE_OVER,
        centered = true,
        fps = 52,
        frameCount = 13,
        path = ('gameplay/hit_animation/laser_%s/inner'):format(side),
        scale = 0.75,
      });
			
      t.ending.outer[i] = Animation:new({
        alpha = 1,
        blendOp = gfx.BLEND_OP_LIGHTER,
        centered = true,
        fps = 52,
        frameCount = 13,
        path = ('gameplay/hit_animation/laser_%s/outer'):format(side),
        scale = 0.625,
      });

      for _, part in pairs(t.states) do
        part[i] = {};

        for j = 1, 8 do
          part[i][j] = {
            frame = 1,
            pos = 0,
            queued = false,
            timer = 0,
          };
        end
      end
    end

    local frame = gfx.CreateSkinImage(
      'gameplay/hit_animation/laser_l/dome/0001.png',
      0
    );

    t.domeSize = gfx.ImageSize(frame) * 0.625;

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Queues an animation to be played
  ---@param this LaserAnimation
  ---@param pos number # x-position relative to the center of the crit line
  ---@param laser integer # Laser index, `1 = left`, `2 = right`
  trigger = function(this, pos, laser)
    for i, state in ipairs(this.states.inner[laser]) do
      if (not state.queued) then
        state.pos = 0.5 + (pos * 0.8);
        this.states.outer[laser][i].pos = 0.5 + (pos * 0.8);

        state.queued = true;
        this.states.outer[laser][i].queued = true;

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
  ---@param dome any
  ---@param tail Image
  ---@param alpha number
  ---@param pos number
  ---@param skew number
  playCursor = function(this, dt, dome, tail, alpha, pos, skew)
    local size = this.domeSize * this.window:getScale();

    gfx.Save();

    this:transform();

    gfx.BeginPath();
    gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);
    gfx.ImageRect(
      pos - (size / 2),
      -(size / 2),
      size,
      size,
      dome,
      1.5,
      0
    );
    gfx.TickAnimation(dome, dt);

    gfx.SkewX(skew);
    tail:draw({
      x = pos,
      alpha = alpha,
      blendOp = gfx.BLEND_OP_LIGHTER,
      centered = true,
      scale = 0.625 * this.window:getScale(),
    });

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this LaserAnimation
  ---@param dt deltaTime
  render = function(this, dt)
    local inner = this.states.inner;
    local outer = this.states.outer;

    for laser = 1, 2 do
      ---@param state AnimationState
      for i, state in ipairs(inner[laser]) do
        if (state.queued) then
          this:play(dt, this.ending.inner[laser], state);
          this:play(dt, this.ending.outer[laser], outer[laser][i]);
        end
      end

      if (gameplay.laserActive[laser]) then
        local curr = gameplay.critLine.cursors[laser - 1];
  
        this:playCursor(
          dt,
          this.dome[laser],
          this.tail[laser],
          curr.alpha,
          curr.pos,
          curr.skew
        );
      end
    end
  end,
};

return LaserAnimation;