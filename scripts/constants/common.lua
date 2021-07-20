local floor = math.floor;
local min = math.min;

local R, G, B, _ = game.GetSkinSetting('colorScheme');

-- Get color from skin settings
---@param key string # Skin setting key
local getColor = function(key)
  local r, g, b, _ = game.GetSkinSetting(key);

  return {
    r or 0,
    g or 0,
    b or 0,
  };
end

-- Make color table
---@param r? number
---@param g? number
---@param b? number
---@param pct? number
---@return table # ```{ r, g, b }```
local makeColor = function(r, g, b, pct)
  r = r or 0;
  g = g or 0;
  b = b or 0;
  pct = pct or 1;

  return {
    min(floor(r * pct), 255),
    min(floor(g * pct), 255),
    min(floor(b * pct), 255),
  };
end

return {
  Alignments = {
    center = gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP,
    left = gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP,
    leftMid = gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE,
    middle = gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE,
    right = gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP,
    rightMid = gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE,
  },

  Colors = {
    black = { 0, 0, 0 },
    critical = getColor('criticalColor'),
    criticalEarly = getColor('criticalColor'),
    criticalLate = getColor('criticalColor'),
    dark = makeColor(R, G, B, 0.075),
    early = getColor('earlyColor'),
    error = getColor('errorColor'),
    errorEarly = getColor('errorColor'),
    errorLate = getColor('errorColor'),
    late = getColor('lateColor'),
    light = makeColor(R, G, B, 1.125),
    maxChain = getColor('criticalColor'),
    med = makeColor(R, G, B, 0.3),
    neg = getColor('negColor'),
    norm = makeColor(R, G, B),
    pos = getColor('posColor'),
    red = { 200, 80, 80 },
    redDark = { 160, 40, 40 },
    sCritical = getColor('sCriticalColor'),
    white = { 255, 255, 255 },
  },

  Fonts = {
    bold = 'GothamBold.ttf',
    jp = 'DFMGM.ttf',
    med = 'GothamMedium.ttf',
    mono = 'MonoLisaMedium.ttf',
    norm = 'GothamBook.ttf',
    num = 'DigitalSerialBold.ttf',
  },
};
