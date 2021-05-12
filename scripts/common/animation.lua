---Create frames from images in the specified folder
---@param path string
---@param count integer
local loadFrames = function(path, count)
  local f = {};

  for i = 1, count do f[i] = Image:new(('%s/%04d.png'):format(path, i)); end

  return f;
end

---@class AnimationState
---@field frame integer # Current frame of the animation
---@field queued boolean # Whether or not the animation is queued up to be played
---@field timer number # Timer to determine when the next frame should be played
local AnimationState = {};

---@class AnimationClass
local Animation = {
  -- Animation constructor
  ---@param this AnimationClass
  ---@param p table #
  -- ```
  -- {
  --   alpha: number = 1,
  --   blendOp: integer = 0,,
  --   centered: boolean = false,
  --   fps: number = 30,
  --   frameCount: integer = 1,
  --   path: string,
  --   loop: boolean = false,
  --   loopPoint: integer = 1,
  --   scale: number = 1,
  -- }
  -- ```
  ---@return Animation
  new = function(this, p)
    ---@class Animation : AnimationClass
    local t = {
      alpha = p.alpha or 1,
      blendOp = p.blendOp or 0,
      centered = p.centered or false,
      frameCount = p.frameCount or 1,
      frameTime = 1 / (p.fps or 30),
      loop = p.loop or false,
      loopPoint = p.loopPoint or 1,
      scale = p.scale or 1,
    };

    t.frames = loadFrames(p.path, t.frameCount);

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Start the current animation  
  ---@param this Animation
  ---@param dt deltaTime
  ---@param state AnimationState
  ---@param effect? function
  start = function(this, dt, state, effect)
    state.timer = state.timer + dt;

    if (state.timer > this.frameTime) then
      state.frame = state.frame + 1;
      state.timer = 0;
    end

    if (state.timer < this.frameTime) then
      this.frames[state.frame]:draw({
        blendOp = this.blendOp,
        centered = this.centered,
        scale = this.scale,
      });
    end

    if (state.frame == this.frameCount) then
      if (this.loop) then
        state.frame = this.loopPoint;
      else
        state.frame = 1;
        state.queued = false;
        state.timer = 0;

        if (effect) then effect(); end
      end
    end
  end,
};

return Animation;