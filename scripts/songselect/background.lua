local background = cacheImage('bg.png');

render = function(deltaTime)
	resx, resy = game.GetResolution();

	background:draw({
		['x'] = 0,
		['y'] = 0,
		['w'] = resx,
		['h'] = resy
	});
end
