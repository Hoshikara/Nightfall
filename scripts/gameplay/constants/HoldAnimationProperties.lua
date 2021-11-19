---@type table<string, HoldAnimationProperties>
local HoldAnimationProperties = {
  SDVX = {
    alpha = 1.5,
    effect = "gameplay/hit_animations/hold/sdvx/effect.png",
    folderPath = "gameplay/hit_animations/hold/sdvx/inner",
    fps = 60,
    hueSettingKey = "holdHue",
    ring = "gameplay/hit_animations/hold/sdvx/ring.png",
  },
  STANDARD = {
    alpha = 1.5,
    effect = "gameplay/hit_animations/hold/standard/effect.png",
    folderPath = "gameplay/hit_animations/hold/standard/inner",
    fps = 60,
    hueSettingKey = "holdHue",
    ring = "gameplay/hit_animations/hold/standard/ring.png",
  },
}

return HoldAnimationProperties

---@class HoldAnimationProperties
---@field alpha number
---@field effect string
---@field folderPath string
---@field fps number
---@field hueSettingKey string
---@field ring string
