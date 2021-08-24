---@type table<string, table<string, HitAnimationProps>>
local HitAnimations = {
  Critical = {
    SDVX = {
      alpha = 1.5,
      fps = 60,
      path = 'gameplay/hit_animation/critical/sdvx',
      scale = 0.525,
    },
    STANDARD = {
      alpha = 1.2,
      fps = 60,
      path = 'gameplay/hit_animation/critical/standard',
      scale = 0.65,
    },
  },
  Near = {
    SDVX = {
      alpha = 1.25,
      fps = 72,
      path = 'gameplay/hit_animation/near/sdvx',
      scale = 0.8,
    },
    STANDARD = {
      alpha = 1,
      fps = 74,
      path = 'gameplay/hit_animation/near/standard',
      scale = 0.975,
    },
  },
  SCritical = {},
};

return HitAnimations;