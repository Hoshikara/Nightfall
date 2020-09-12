local _ = {};

_.drawAlertDetail = function(self, x, y, w, h, s, a)
  gfx.BeginPath();
  gfx.StrokeWidth(2);
  gfx.StrokeColor(255, 255, 255, a);

  gfx.MoveTo(
    x - (s * 1.25),
    y
  );
  gfx.LineTo(
    x - (s * 1.25),
    y - s
  );
  gfx.LineTo(
    x - (s * 0.125),
    y - s
  );

  gfx.MoveTo(
    x + w + (s * 1.25),
    y
  );
  gfx.LineTo(
    x + w + (s * 1.25),
    y - s
  );
  gfx.LineTo(
    x + w + (s * 0.125),
    y - s
  );

  gfx.MoveTo(
    x - (s * 1.25),
    y + h + (s * 0.25)
  );
  gfx.LineTo(
    x - (s * 1.25),
    y + h + (s * 1.25)
  );
  gfx.LineTo(
    x - (s * 0.125),
    y + h + (s * 1.25)
  );

  gfx.MoveTo(
    x + w + (s * 1.25),
    y + h + (s * 0.25)
  );
  gfx.LineTo(
    x + w + (s * 1.25),
    y + h + (s * 1.25)
  );
  gfx.LineTo(
    x + w + (s * 0.125),
    y + h + (s * 1.25)
  );

  gfx.Stroke();
end

return _;