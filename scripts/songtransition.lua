local Window = require('common/window');

local Cursor = require('components/common/cursor');

local window = Window:new();

local cursor = Cursor:new({ size = 26, stroke = 2 }, true);

local floor = math.floor;

local alpha = 0;

local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

local introDone = false;
local outroDone = false;

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local labels = nil;

local timers = {
	fade = 1,
	flicker = { i = 0, o = 0 },
	i = 0,
	o = 0,
	scissor = {
		i = 0,
		o = { l = 1, r = 0 },
	},
};

local setLabels = function()
	if (not labels) then
		labels = {
			artist = makeLabel('jp', song.artist, 40),
			title = makeLabel('jp', song.title, 48),
		};
	end
end

local drawTransition = function(dt, isIntro);
	local jacket = ((song.jacket == 0) and jacketFallback) or song.jacket;

	setLabels();

	gfx.Save();

	window:set(true);

	local maxWidth = window.w - (window.padding.x * 2);

	if (isIntro) then
		timers.fade = to0(timers.fade, dt, (window.isPortrait and 0.4) or 0.67);
		timers.flicker.i = timers.flicker.i + dt;
		timers.i = timers.i + dt;
		timers.scissor.i = to1(
			timers.scissor.i,
			dt,
			(window.isPortrait and 0.15) or 0.25
		);

		alpha = floor(timers.flicker.i * 30) % 2;
		alpha = ((alpha * 80) + 175) / 255;

		if (timers.flicker.i >= 0.3) then alpha = 1; end

		introDone = timers.i >= 1;
	else
		local duration = (window.isPortrait and 0.2) or 0.33;

		timers.flicker.o = timers.flicker.o + dt;
		timers.o = timers.o + (dt * 2);
		timers.scissor.o.l = to0(timers.scissor.o.l, dt, duration);
		timers.scissor.o.r = to1(timers.scissor.o.r, dt, duration);

		alpha = floor(timers.flicker.o * 36) % 2;
		alpha = ((alpha * 80) + 175) / 255;

		if (timers.flicker.o >= 0.3) then alpha = timers.scissor.o.l * 0.5; end
		
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
				centered = true,
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true,
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
				centered = true,
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true,
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
				centered = true,
			});
		else
			bg:draw({
				x = window.w / 2,
				y = window.h / 2,
				centered = true,
			});
		end

		gfx.ResetScissor();
	end

	gfx.Translate(window.w / 2, window.h / 2);

	cursor:draw({
		x = -240,
		y = -360,
		w = 480,
		h = 480,
		alpha = 255 * alpha,
	});

	drawRect({
		x = -240,
		y = -360,
		w = 480,
		h = 480,
		alpha = alpha,
		image = jacket,
		stroke = {
			alpha = 255 * alpha,
			color = 'norm',
			size = 2,
		},
	});

	if (isIntro) then
		labels.title:draw({
			x = 0,
			y = 255,
			align = 'center',
			alpha = 255 * alpha,
			color = 'white',
			maxWidth = maxWidth,
		});

		labels.artist:draw({
			x = 0,
			y = 255 + labels.title.h * 1.75,
			align = 'center',
			alpha = 255 * alpha,
			maxWidth = maxWidth,
		});
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
	labels = nil;
	timers.fade = 1;
	timers.flicker.i = 0;
	timers.flicker.o = 0;
	timers.i = 0;
	timers.o = 0;
	timers.scissor.i = 0;
	timers.scissor.o.l = 1;
	timers.scissor.o.r = 0;
end