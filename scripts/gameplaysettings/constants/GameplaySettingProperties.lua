---@type table<string, GameplaySettingProperties[]>
local GameplaySettingProperties = {
  Earlate = {
    {
      default = "TEXT",
      key = "earlateType",
      name = "DISPLAY TYPE",
      options = {
        "DELTA",
        "TEXT",
        "TEXT + DELTA",
      },
    },
    {
      default = 1.0,
      increment = 0.1,
      key = "earlateScale",
      max = 5.0,
      min = 0.5,
      name = "SCALE",
      templateString = "%.0f%%",
    },
    {
      default = 1,
      key = "earlateFlicker",
      name = "FLICKER",
    },
    {
      default = 0.25,
      increment = 0.05,
      key = "earlateGap",
      max = 1.0,
      min = 0.0,
      name = "TEXT / DELTA GAP",
      templateString = "%.0f%%",
    },
    {
      default = 0.5,
      increment = 0.05,
      key = "earlateX",
      max = 1.0,
      min = 0.0,
      name = "X-POSITION",
      templateString = "%.0f%%",
    },
    {
      default = 0.75,
      increment = 0.05,
      key = "earlateY",
      max = 1.0,
      min = 0.0,
      name = "Y-POSITION",
      templateString = "%.0f%%",
    },
  },
  HitAnimations = {
    {
      default = "STANDARD",
      key = "hitAnimationType",
      name = "DISPLAY TYPE",
      options = {
        "SDVX",
        "STANDARD",
      },
    },
    {
      default = 1.0,
      increment = 0.1,
      key = "hitAnimationScale",
      max = 5.0,
      min = 0.5,
      name = "SCALE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "leftLaserHue",
      max = 1.0,
      min = 0.0,
      name = "LEFT LASER HUE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "rightLaserHue",
      max = 1.0,
      min = 0.0,
      name = "RIGHT LASER HUE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "sCriticalHue",
      max = 1.0,
      min = 0.0,
      name = "S-CRITICAL HUE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "criticalHue",
      max = 1.0,
      min = 0.0,
      name = "CRITICAL HUE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "nearHue",
      max = 1.0,
      min = 0.0,
      name = "NEAR HUE",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.02,
      key = "holdHue",
      max = 1.0,
      min = 0.0,
      name = "HOLD HUE",
      templateString = "%.0f%%",
    },
  },
  HitDeltaBar = {
    {
      default = 1.0,
      increment = 0.1,
      key = "hitDeltaBarScale",
      max = 2.0,
      min = 0.5,
      name = "SCALE",
      templateString = "%.0f%%",
    },
    {
      default = 1.0,
      increment = 0.5,
      key = "hitDecayTime",
      max = 10.0,
      min = 2.0,
      multi = 1,
      name = "DECAY TIME",
      templateString = "%.2f s",
    },
    {
      default = 0.5,
      increment = 0.05,
      key = "hitDeltaBarX",
      max = 1.0,
      min = 0.0,
      name = "X-POSITION",
      templateString = "%.0f%%",
    },
    {
      default = 0.0,
      increment = 0.05,
      key = "hitDeltaBarY",
      max = 1.0,
      min = 0.0,
      name = "Y-POSITION",
      templateString = "%.0f%%",
    },
  },
  LaneSpeed = {
    {
      default = 0,
      key = "ignoreSpeedChange",
      name = "IGNORE CHANGE HINT",
    },
    {
      default = 1.0,
      increment = 0.1,
      key = "laneSpeedScale",
      max = 5.0,
      min = 0.5,
      name = "SCALE",
      templateString = "%.0f%%",
    },
    {
      default = 1.0,
      key = "laneSpeedOpacity",
      increment = 0.05,
      max = 1.0,
      min = 0.2,
      multi = 100,
      name = "OPACITY",
      templateString = "%.0f%%",
    },
    {
      default = 0.5,
      increment = 0.05,
      key = "laneSpeedX",
      max = 1.0,
      min = 0.0,
      name = "X-POSITION",
      templateString = "%.0f%%",
    },
    {
      default = 0.5,
      increment = 0.05,
      key = "laneSpeedY",
      max = 1.0,
      min = 0.0,
      name = "Y-POSITION",
      templateString = "%.0f%%",
    },
  },
  PlayerCard = {
    {
      default = 1,
      key = "showPlayerAvatar",
      name = "AVATAR",
    },
    {
      default = "NONE",
      key = "danLevel",
      name = "DAN LEVEL",
      options = {
        "NONE",
        "01",
        "02",
        "03",
        "04",
        "05",
        "06",
        "07",
        "08",
        "09",
        "10",
        "11",
        "∞",
      },
    },
  },
  ScoreDifference = {
    {
      default = 1.0,
      increment = 0.1,
      key = "scoreDifferenceScale",
      max = 5.0,
      min = 0.5,
      name = "SCALE",
      templateString = "%.0f%%",
    },
    {
      default = 0.05,
      key = "scoreDifferenceDelay",
      increment = 0.05,
      max = 1.0,
      min = 0.05,
      multi = 1,
      name = "UPDATE DELAY",
      templateString = "%.2f s",
    },
    {
      default = 0.5,
      increment = 0.05,
      key = "scoreDifferenceX",
      max = 1.0,
      min = 0.0,
      name = "X-POSITION",
      templateString = "%.0f%%",
    },
    {
      default = 0.75,
      increment = 0.05,
      key = "scoreDifferenceY",
      max = 1.0,
      min = 0.0,
      name = "Y-POSITION",
      templateString = "%.0f%%",
    },
  },
}

return GameplaySettingProperties

---@class GameplaySettingProperties
---@field default number
---@field increment? number
---@field key string
---@field max? number
---@field min? number
---@field multi? number
---@field name? string
---@field options? string[]
---@field templateString? string
