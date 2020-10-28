local background = Image.New('bg.png');

render = function(deltaTime)
	resX, resY = game.GetResolution();

	background:draw({
		x = 0,
		y = 0,
		w = resX,
		h = resY,
	});
end
