return function(t)
  if (not t) then return end

  local w = 0;
  local h = 0;
  local i = 0;
  local n = 0;

  gfx.FontSize(30);
  loadFont('mono');

  for k, v in pairs(t) do
  local x1, y1, x2, y2 = gfx.TextBounds(0, 0, ('%s: %s'):format(k, v));

  if ((x2 - x1) > w) then w = x2 - x1; end
  if ((y2 - y1) > h) then h = y2 - y1; end

  n = n + 1;
  end

  gfx.Save();
  gfx.Translate(8, 4);

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 255);
  gfx.Rect(-8, -4, w + 16, (h * n) + 8);
  gfx.Fill();

  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
  gfx.FillColor(255, 255, 255, 255);

  for k, v in pairs(t) do
  gfx.Text(('%s: %s'):format(k, v), 0, h * i);

  i = i + 1;
  end

  gfx.Restore();
end