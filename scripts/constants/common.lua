local floor = math.floor;
local min = math.min;

local r, g, b, _ = game.GetSkinSetting('colorScheme');

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
    dark = makeColor(r, g, b, 0.075),
    light = makeColor(r, g, b, 1.125),
    med = makeColor(r, g, b, 0.3),
    norm = makeColor(r, g, b),
    red = { 200, 80, 80 },
    redDark = { 160, 40, 40 },
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