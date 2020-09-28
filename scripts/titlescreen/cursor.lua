local _ = {};

_.drawCursor = function(self, x, y, w, h, s, a);
	gfx.BeginPath();
	gfx.StrokeWidth(1.5);
	gfx.StrokeColor(255, 255, 255, math.floor(255 * a));

	gfx.MoveTo(
		x - (s * 2),
		y - (h / 2)
	);
	gfx.LineTo(
		x - (s * 2),
		y - (h / 2) - (s * 3)
	);
	gfx.LineTo(
		x + (s * 1.25),
		y - (h / 2) - (s * 3)
	);

	gfx.MoveTo(
		x + w + (s * 6),
		y - (h / 2)
	);
	gfx.LineTo(
		x + w + (s * 6),
		y - (h / 2) - (s * 3)
	);
	gfx.LineTo(
		x + w + (s * 2.75),
		y - (h / 2) - (s * 3)
	);

	gfx.MoveTo(
		x - (s * 2),
		y + (h / 2)
	);
	gfx.LineTo(
		x - (s * 2),
		y + (h / 2) + (s * 3)
	);
	gfx.LineTo(
		x + (s * 1.25),
		y + (h / 2) + (s * 3)
	);
	
	gfx.MoveTo(
		x + w + (s * 6),
		y + (h / 2)
	);
	gfx.LineTo(
		x + w + (s * 6),
		y + (h / 2) + (s * 3)
	);
	gfx.LineTo(
		x + w + (s * 2.75),
		y + (h / 2) + (s * 3)
	);

	gfx.Stroke();
end

return _;