local _ = {};

_.drawDetail = function(self, x, y, w, h, alpha)
  local centerX = x + (w / 2);
  local centerY = y + (h / 2);

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, math.floor(255 * alpha));

  gfx.Rect(centerX - 4, -9, 8, 8);
  gfx.Rect(centerX - 4, h + 1, 8, 8);
  gfx.Rect(-9, centerY - 4, 8, 8);
  gfx.Rect(w + 1, centerY - 4, 8, 8);

  gfx.Fill();
end

return _;