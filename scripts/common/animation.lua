---Create frames from images in the specified folder
---@param path string
---@return Image[], number frameCount
local loadFrames = function(path)
  local f = {};
  local i = 1;
  local loaded = false;

  while (not loaded) do
    local frame = Image:new(('%s/%04d.png'):format(path, i), true);

    if (not frame) then
      loaded = true;

      break;
    end

    f[i] = frame;

    i = i + 1;
  end

  return f, i;
end

---@class AnimationClass
local Animation = {
  -- Animation constructor
  ---@param this AnimationClass
  ---@param p AnimationConstructorParams
  ---@return Animation
  new = function(this, p)
    ---@class Animation : AnimationClass
    local t = {
      alpha = p.alpha or 1,
      blendOp = p.blendOp or 0,
      centered = p.centered or false,
      frameCount = 1,
      frameTime = 1 / (p.fps or 30),
      loop = p.loop or false,
      loopPoint = p.loopPoint or 1,
      scale = p.scale or 1,
    };

    t.frames, t.frameCount = loadFrames(p.path);

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

    if (state.timer >= this.frameTime) then
      state.frame = state.frame + 1;
      state.timer = 0;
    end

    if (this.frames[state.frame]) then
      this.frames[state.frame]:draw({
        alpha = state.alpha or this.alpha,
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