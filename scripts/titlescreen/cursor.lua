local _ = {};

_.drawCursor = function(self, x, y, w, h, s);
	gfx.BeginPath();
	gfx.StrokeWidth(2);
	gfx.StrokeColor(255, 255, 255, 255);

	gfx.MoveTo(
		x - (s * 2),
		y - (h / 2)
	);
	gfx.LineTo(
		x - (s * 2),
		y - (h / 2) - (s * 3)
	);
	gfx.LineTo(
		x + s,
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
		x + w + (s * 3),
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
		x + s,
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
		x + w + (s * 3),
		y + (h / 2) + (s * 3)
	);

	gfx.Stroke();
end

return _;