local window = Window:new();

local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

local introDone = false;
local outroDone = false;

local timers = {
	fade = 1,
	i = 0,
	o = 0,
	scissor = {
		i = 0,
		o = { l = 1, r = 0 },
	},
};

local drawTransition = function(dt, isIntro);
	gfx.Save();

	window:set();

	if (isIntro) then
		timers.fade = to0(timers.fade, dt, (window.isPortrait and 0.4) or 0.67);
		timers.scissor.i =
			to1(timers.scissor.i, dt, (window.isPortrait and 0.15) or 0.25); 
		timers.i = timers.i + dt;

		introDone = timers.i >= 1;
	else
		local duration = (window.isPortrait and 0.2) or 0.33;

		timers.scissor.o.l = to0(timers.scissor.o.l, dt, duration);
		timers.scissor.o.r = to1(timers.scissor.o.r, dt, duration);
		timers.o = timers.o + (dt * 2);
		
		outroDone = timers.o >= 1;
	end

	if (isIntro) then
		gfx.Translate(window.w / 2, 0);

		gfx.Scissor(
			-((window.w / 2) * timers.scissor.i),
			0,
			window.w * timers.scissor.i,
			window.h
		);

		gfx.Translate(-(window.w / 2), 0);

		if (window.isPortrait) then
			bgPortrait:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		end

		drawRect({
			w = window.w,
			h = window.h,
			alpha = 150 * timers.fade,
			color = 'black',
		});

		gfx.ResetScissor();
	else
		gfx.Scissor(
			0,
			0,
			(window.w / 2) * timers.scissor.o.l,
			window.h
		);

		if (window.isPortrait) then
			bgPortrait:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		end

		gfx.ResetScissor();

		gfx.Scissor(
			(window.w / 2) + ((window.w / 2) * timers.scissor.o.r),
			0,
			window.w / 2,
			window.h
		);

		if (window.isPortrait) then
			bgPortrait:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true;
			});
		end

		gfx.ResetScissor();
	end

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
	timers.fade = 1;
	timers.i = 0;
	timers.o = 0;
	timers.scissor.i = 0;
	timers.scissor.o.l = 1;
	timers.scissor.o.r = 0;
end