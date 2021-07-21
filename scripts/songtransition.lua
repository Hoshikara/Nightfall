local Cursor = require('components/common/cursor');

local Order = {
	'title',
	'artist',
	'effector',
	'illustrator',
};

local window = Window:new();
local background = Background:new(window);

local cursor = Cursor:new({ size = 26, stroke = 2.5 }, true);

local floor = math.floor;

local alpha = 0;

local introDone = false;
local outroDone = false;

local jacket = nil;
local jacketFallback = gfx.CreateSkinImage('loading.png', 0);
local jacketSize = nil;

local labels = nil;

local songAlpha = {
	artist = 0,
	effector = 0,
	illustrator = 0,
	title = 0,
};
local songInfo = nil;

local timers = {
	artist = 0,
	effector = 0,
	flicker = { i = 0, o = 0 },
	illustrator = 0,
	title = 0,
	i = 0,
	o = 0,
};

-- Sets the jacket size
local setSizes = function()
	if (not jacket) then
		jacket = ((song.jacket == 0) and jacketFallback) or song.jacket;
	end

	if (not jacketSize) then
		if (window.isPortrait) then
			jacketSize = window.w - (window.padding.x * 6);
		else
			jacketSize = window.h - (window.padding.y * 10);
		end
	end
end

-- Creates the labels used for song information
local setSongInfo = function()
	if (not songInfo) then
		labels = {
			artist = makeLabel('med', 'ARTIST'),
			effector = makeLabel('med', 'EFFECTOR'),
			illustrator = makeLabel('med', 'ILLUSTRATOR'),
			title = makeLabel('med', 'TITLE'),
		};

		songInfo = {
			artist = makeLabel('jp', song.artist, 30),
			difficulty = makeLabel('norm', 'MAXIMUM', 24),
			effector = makeLabel('jp', song.effector, 30),
			illustrator = makeLabel('jp', song.illustrator, 30),
			level = makeLabel('num', ('%02d'):format(song.level), 24),
			title = makeLabel('jp', song.title, 36),
		};
	end
end

-- Handles the animation timers
---@param dt deltaTime
---@param isIntro boolean
local handleTimers = function(dt, isIntro)
	if (isIntro) then
		timers.flicker.i = timers.flicker.i + dt;
		timers.i = to1(timers.i, dt, (window.isPortrait and 0.15) or 0.2);

		alpha = floor(timers.flicker.i * 30) % 2;
		alpha = ((alpha * 80) + 175) / 255;

		if (timers.flicker.i >= 0.3) then alpha = 1; end

		if (timers.i >= 1) then
			timers.title = timers.title + dt;
			songAlpha.title = flicker(timers.title);

			if (timers.title > 0.22) then
				timers.artist = timers.artist + dt;
				songAlpha.artist = flicker(timers.artist);
			end

			if (timers.artist > 0.22) then
				timers.effector = timers.effector + dt;
				songAlpha.effector = flicker(timers.effector);
			end

			if (timers.effector > 0.22) then
				timers.illustrator = timers.illustrator + dt;
				songAlpha.illustrator = flicker(timers.illustrator);
			end
		end

		introDone = timers.illustrator >= 0.75;
	else
		timers.flicker.o = timers.flicker.o + dt;
		timers.o = to1(timers.o, dt, (window.isPortrait and 0.2) or 0.28);

		alpha = floor(timers.flicker.o * 36) % 2;
		alpha = ((alpha * 80) + 175) / 255;
		
		outroDone = timers.o >= 1;
	end
end

-- Renders the transition
---@param dt deltaTime
---@param isIntro boolean
local renderTransition = function(dt, isIntro);
	window:set();

	handleTimers(dt, isIntro);

	setSongInfo();

	setSizes();

	local padding = (jacketSize / 2) / 3.5;
	local x = window.w / 2;
	local y = (window.h / 2) + (window.padding.y * 1.35) - jacketSize;
	local w = window.w / 2.5;
	local maxWidth = w - (w / 10);

	if (window.isPortrait) then
		maxWidth = jacketSize - (jacketSize / 10);
		padding = (jacketSize / 2) / 4.5;
		y = (window.h / 2) + (window.padding.y * 2) - jacketSize;
		w = jacketSize;
	end

	gfx.Save();

	gfx.Scissor(
		window.w * timers.o,
		0,
		window.w * timers.i,
		window.h
	);

	background:render({ w = window.w, h = window.h });

	gfx.ResetScissor();

	if (window.isPortrait) then
		x = window.padding.x * 3;
	else
		x = (window.w / 2) - (jacketSize / 2);
	end

	cursor:draw({
		x = x,
		y = y,
		w = jacketSize,
		h = jacketSize,
		alpha = 255 * alpha,
		size = window.isPortrait and 30,
	});

	drawRect({
		x = x,
		y = y,
		w = jacketSize,
		h = jacketSize,
		alpha = alpha,
		image = jacket,
		stroke = {
			alpha = 255 * alpha,
			color = 'norm',
			size = (window.isPortrait and 2.5) or 2,
		},
	});

	x = (window.w / 2) - (w / 2)
	y = y + jacketSize + window.padding.y;

	if (isIntro) then
		drawRect({
			x = x + (w / 2) - ((w / 2) * timers.i),
			y = y,
			w = w * timers.i,
			h = ((window.isPortrait) and (w / 2)) or (w / 2.225),
			alpha = 180,
			color = 'dark',
			fast = true,
		});

		x = x + (w / 20);
		y = y + (w / 2) / 14;

		for _, name in ipairs(Order) do
			labels[name]:draw({
				x = x,
				y = y,
				alpha = 255 * timers.i,
			});

			songInfo[name]:draw({
				x = x,
				y = y + (labels[name].h * 1.35),
				alpha = 255 * songAlpha[name],
				color = 'white',
				maxWidth = maxWidth,
			});

			y = y + padding;
		end
	end

	gfx.Restore();
end

-- Called by the game for the intro transition
---@param dt deltaTime
render = function(dt)
	reloadColors();
	
	renderTransition(dt, true);
	
  return introDone;
end

-- Called by the game for the outro transition
---@param dt deltaTime
render_out = function(dt)
	renderTransition(dt, false);

	return outroDone;
end

-- Called by the game when the transition is started
reset = function()
	jacket = nil;
	jacketSize = nil;
	labels = nil;
	songInfo = nil;

	songAlpha.artist = 0;
	songAlpha.effector = 0;
	songAlpha.illustrator = 0;
	songAlpha.title = 0;
	
	timers.artist = 0;
	timers.effector = 0;
	timers.flicker.i = 0;
	timers.flicker.o = 0;
	timers.illustrator = 0;
	timers.title = 0;
	timers.i = 0;
	timers.o = 0;
end