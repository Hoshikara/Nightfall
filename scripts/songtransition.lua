
local background = New.Image({ path = 'bg.png' });

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local cache = { resX = 0, resY = 0 };

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();

  if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
    scaledW = 1920;
    scaledH = scaledW * (resY / resX);
    scalingFactor = resX / scaledW;

    cache.resX = resX;
    cache.resY = resY;
  end

  gfx.Scale(scalingFactor, scalingFactor);
end

local introComplete = false;
local outroComplete = false;

local flickerAlpha = 0;

local timers = {
	intro = 0,
	outro = 0,
	fade = 1,
	flicker = { intro = 0, outro = 0 },
	scissor = {
		intro = 0,
		outro = { left = 1, right = 0 },
	},
};

local labels = nil;

setLabels = function()
	if (not labels) then
		Font.JP();

		labels = {
			artist = New.Label({ text = string.upper(song.artist), size = 40 }),
			title = New.Label({ text = string.upper(song.title), size = 48 }),
		};
	end
end


drawTransition = function(deltaTime, isIntro);
	local jacket = ((song.jacket == 0) and jacketFallback) or song.jacket;

	gfx.Save();

	setupLayout();
	
	setLabels();

	if (isIntro) then
		timers.fade = math.max(timers.fade - (deltaTime * 1.5), 0);
	
		timers.flicker.intro = timers.flicker.intro + deltaTime;
	
		timers.scissor.intro = math.min(timers.scissor.intro + (deltaTime * 4), 1)

		flickerAlpha = math.floor(timers.flicker.intro * 30) % 2;
		flickerAlpha = ((flickerAlpha * 80) + 175) / 255;

		if (timers.flicker.intro >= 0.3) then
			flickerAlpha = 1;
		end

		timers.intro = timers.intro + deltaTime;

		introComplete = timers.intro >= 1;
	else
		timers.scissor.outro.left = math.max(timers.scissor.outro.left - (deltaTime * 3), 0);
		timers.scissor.outro.right = math.min(timers.scissor.outro.right + (deltaTime *  3), 1);

		timers.flicker.outro = timers.flicker.outro + deltaTime;

		flickerAlpha = math.floor(timers.flicker.outro * 36) % 2;
		flickerAlpha = ((flickerAlpha * 80) + 175) / 255;

		if (timers.flicker.outro >= 0.3) then
			flickerAlpha = timers.scissor.outro.left * 0.5;
		end

		timers.outro = timers.outro + (deltaTime * 2);
		
		outroComplete = timers.outro >= 1;
	end

	if (isIntro) then
		gfx.Translate(scaledW / 2, 0);

		gfx.Scissor(
			-((scaledW / 2) * timers.scissor.intro),
			0,
			scaledW * timers.scissor.intro,
			scaledH
		);

		gfx.Translate(-(scaledW / 2), 0);

		background:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			centered = true,
		});

		gfx.BeginPath();
		Fill.Black(150 * timers.fade);
		gfx.Rect(0, 0, scaledW, scaledH);
		gfx.Fill();

		gfx.ResetScissor();
	else
		gfx.Scissor(
			0,
			0,
			(scaledW / 2) * timers.scissor.outro.left,
			scaledH
		);

		background:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			centered = true,
		});

		gfx.ResetScissor();

		gfx.Scissor(
			(scaledW / 2) + ((scaledW / 2) * timers.scissor.outro.right),
			0,
			scaledW / 2,
			scaledH
		);

		background:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			centered = true,
		});

		gfx.ResetScissor();
	end

	gfx.Translate(scaledW / 2, scaledH / 2);

	drawCursor({
		x = -240,
		y = -360,
		w = 480,
		h = 480,
		alpha = flickerAlpha,
		size = 26,
		stroke = 2,
	});

	gfx.BeginPath();
	gfx.StrokeWidth(2);
	gfx.StrokeColor(60, 110, 160, math.floor(255 * flickerAlpha));
	gfx.ImageRect(-240, -360, 480, 480, jacket, flickerAlpha, 0);
	gfx.Stroke();

	if (isIntro) then
		gfx.BeginPath();
		FontAlign.Center();

		labels.title:draw({
			x = 0,
			y = 255,
			a = 255 * flickerAlpha,
			color = 'White',
		});

		labels.artist:draw({
			x = 0,
			y = 255 + labels.title.h * 1.75,
			a = 255 * flickerAlpha,
			color = 'Normal',
		});
	end

	gfx.Restore();
end

drawDetails = function(x, y, w, h, s, a)
	gfx.BeginPath();
	gfx.StrokeWidth(2);
	gfx.StrokeColor(255, 255, 255, math.floor(255 * a));

	gfx.MoveTo(x - s, y);
	gfx.LineTo(x - s, y - (s * 0.875));
	gfx.LineTo(x - (s * 0.075), y - (s * 0.875));

	gfx.MoveTo(x + w + s, y);
	gfx.LineTo(x + w + s, y - (s * 0.875));
	gfx.LineTo(x + w + (s * 0.075), y - (s * 0.875));

	gfx.MoveTo(x - s, y + h);
	gfx.LineTo(x - s, y + h + (s * 0.875));
	gfx.LineTo(x - (s * 0.075), y + h + (s * 0.875));

	gfx.MoveTo(x + w + s, y + h);
	gfx.LineTo(x + w + s, y + h + (s * 0.875));
	gfx.LineTo(x + w + (s * 0.075), y + h + (s * 0.875));

	gfx.Stroke();
end

render = function(deltaTime)
	drawTransition(deltaTime, true);
	
  return introComplete;
end

render_out = function(deltaTime)
	drawTransition(deltaTime, false);

	return outroComplete;
end

reset = function()
	labels = nil;
	timers = {
		intro = 0,
		outro = 0,
		fade = 1,
		flicker = { intro = 0, outro = 0 },
		scissor = {
			intro = 0,
			outro = { left = 1, right = 0 },
		},
	};
end