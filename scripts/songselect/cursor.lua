local _ = {};

_.drawDifficultyCursor = function(self, x, y, w, h, s, a)
  gfx.BeginPath();
  gfx.StrokeWidth(1.5);
  gfx.StrokeColor(255, 255, 255, math.floor(255 * a));

  gfx.MoveTo(
    x - s,
    y + (s * 2.75)
  );
  gfx.LineTo(
    x - s,
    y
  );
  gfx.LineTo(
    x + (s * 2.25),
    y
  );
  
  gfx.MoveTo(
    x + w + (s * 0.75),
    y + (s * 2.75)
  );
  gfx.LineTo(
    x + w + (s * 0.75),
    y
  );
  gfx.LineTo(
    x + w - (s * 2.5),
    y
  );

  gfx.MoveTo(
    x - s,
    y + h - (s * 2.75)
  );
  gfx.LineTo(
    x - s,
    y + h
  );
  gfx.LineTo(
    x + (s * 2.25),
    y + h
  );

  gfx.MoveTo(
    x + w + (s * 0.75),
    y + h - (s * 2.75)
  );
  gfx.LineTo(
    x + w + (s * 0.75),
    y + h
  );
  gfx.LineTo(
    x + w - (s * 2.5),
    y + h
  );

  gfx.Stroke();
end

_.drawSongCursor = function(self, x, y, w, h, s, a)
  gfx.BeginPath();
  gfx.StrokeWidth(1.5);
  gfx.StrokeColor(255, 255, 255, math.floor(255 * a));

  gfx.MoveTo(
    x - (s * 2.5),
    y - (s * 0.25)
  );
  gfx.LineTo(
    x - (s * 2.5),
    y - (s * 2.25)
  );
  gfx.LineTo(
    x - (s * 0.25),
    y - (s * 2.25)
  );

  gfx.MoveTo(
    x + w + (s * 2.5),
    y - (s * 0.25)
  );
  gfx.LineTo(
    x + w + (s * 2.5),
    y - (s * 2.25)
  );
  gfx.LineTo(
    x + w + (s * 0.25),
    y - (s * 2.25)
  );

  gfx.MoveTo(
    x - (s * 2.5),
    y + h + (s * 0.25)
  );
  gfx.LineTo(
    x - (s * 2.5),
    y + h + (s * 2.25)
  );
  gfx.LineTo(
    x - (s * 0.25),
    y + h + (s * 2.25)
  );

  gfx.MoveTo(
    x + w + (s * 2.5),
    y + h + (s * 0.25)
  );
  gfx.LineTo(
    x + w + (s * 2.5),
    y + h + (s * 2.25)
  );
  gfx.LineTo(
    x + w + (s * 0.25),
    y + h + (s * 2.25)
  )

  gfx.Stroke();
end

return _;