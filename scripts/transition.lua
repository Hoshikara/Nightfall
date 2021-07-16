local window = Window:new();
local background = Background:new(window);

local introDone = false;
local outroDone = false;

local timers = {
	i = 0,
	o = 0,
};

local drawTransition = function(dt, isIntro);
	gfx.Save();

	window:set();

	if (isIntro) then
		timers.i = to1(timers.i, dt, (window.isPortrait and 0.22) or 0.3);

		introDone = timers.i >= 1;
	else
		timers.o = to1(timers.o, dt, (window.isPortrait and 0.22) or 0.3);
		
		outroDone = timers.o >= 1;
	end

	gfx.Scissor(
		window.w * timers.o,
		0,
		window.w * timers.i,
		window.h
	);

	background:render({ w = window.w, h = window.h });

	gfx.ResetScissor();

	gfx.Restore();
end

render = function(dt)
	drawTransition(dt, true);

  return introDone;
end

render_out = function(dt)
	drawTransition(dt, false);

	return outroDone;
end

reset = function()
	timers.i = 0;
	timers.o = 0;
end