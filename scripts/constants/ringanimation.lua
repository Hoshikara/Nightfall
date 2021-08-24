---@type table<string, RingAnimationProps>
local RingAnimations = {
  SDVX = {
    alpha = 2,
    effect = 'gameplay/hit_animation/hold/sdvx/effect.png',
    fps = 60,
    inner = 'gameplay/hit_animation/hold/sdvx/inner',
    ring = 'gameplay/hit_animation/hold/sdvx/ring.png',
    scale = 0.65,
  },
  STANDARD = {
    alpha = 1.5,
    effect = 'gameplay/hit_animation/hold/standard/effect.png',
    fps = 40,
    inner = 'gameplay/hit_animation/hold/standard/inner',
    ring = 'gameplay/hit_animation/hold/standard/ring.png',
    scale = 0.725,
  },
};

return RingAnimations;