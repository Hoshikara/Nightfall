local floor = math.floor;

local r, g, b, _ = game.GetSkinSetting('colorScheme');

local clampColor = function(v)
  v = floor(v);

  if (v > 255) then return 255; end
  if (v < 0) then return 0; end

  return v;
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
    dark = {
      clampColor(r * 0.075),
      clampColor(g * 0.075),
      clampColor(b * 0.075),  
    },
    light = {
      clampColor(r * 1.125),
      clampColor(g * 1.125),
      clampColor(b * 1.125),
    },
    med = {
      clampColor(r * 0.3),
      clampColor(g * 0.3),
      clampColor(b * 0.3),
    },
    norm = {
      clampColor(r),
      clampColor(g),
      clampColor(b),
    },
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