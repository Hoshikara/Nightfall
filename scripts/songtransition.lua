
local background = cacheImage('bg.png');

local jacketFallback = gfx.CreateSkinImage('song_select/loading.png', 0);

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
	scalingFactor = resX / scaledW;
	
	gfx.Scale(scalingFactor, scalingFactor);
end

local introComplete = false;
local outroComplete = false;

local flickerAlpha = 0;

local timers = {
	['intro'] = 0,
	['outro'] = 0,
	['fade'] = {
		['in'] = 1
	},
	['flicker'] = {
		['intro'] = 0,
		['outro'] = 0
	},
	['scissor'] = {
		['intro'] = 0,
		['outro'] = {
			['left'] = 1,
			['right'] = 0,
		}
	}
};

local labels = nil;

setLabels = function()
	if (not labels) then
		gfx.LoadSkinFont('DFMGM.ttf');

		labels = {
			['artist'] = cacheLabel(string.upper(song.artist), 36),
			['title'] = cacheLabel(string.upper(song.title), 48)
		};
	end
end


drawTransition = function(deltaTime, isIntro);
	local jacket = ((song.jacket == 0) and jacketFallback) or song.jacket;

	gfx.Save();

	setupLayout();
	
	setLabels();

	if (isIntro) then
		timers['fade']['in'] = math.max(timers['fade']['in'] - (deltaTime * 1.5), 0);
	
		timers['flicker']['intro'] = timers['flicker']['intro'] + deltaTime;
	
		timers['scissor']['intro'] = math.min(timers['scissor']['intro'] + (deltaTime * 3), 1)

		flickerAlpha = math.floor(timers['flicker']['intro'] * 30) % 2;
		flickerAlpha = ((flickerAlpha * 80) + 175) / 255;

		if (timers['flicker']['intro'] >= 0.3) then
			flickerAlpha = 1;
		end

		timers['intro'] = timers['intro'] + deltaTime;

		introComplete = timers['intro'] >= 1;
	else
		timers['scissor']['outro']['left'] = math.max(
			timers['scissor']['outro']['left'] - (deltaTime * 2),
			0
		);
		timers['scissor']['outro']['right'] = math.min(
			timers['scissor']['outro']['right'] + (deltaTime *  2),
			1
		);

		timers['flicker']['outro'] = timers['flicker']['outro'] + deltaTime;

		flickerAlpha = math.floor(timers['flicker']['outro'] * 36) % 2;
		flickerAlpha = ((flickerAlpha * 80) + 175) / 255;

		if (timers['flicker']['outro'] >= 0.3) then
			flickerAlpha = timers['scissor']['outro']['left'];
		end

		timers['outro'] = timers['outro'] + (deltaTime * 2);
		
		outroComplete = timers['outro'] >= 1;
	end

	if (isIntro) then
		gfx.Translate(scaledW / 2, 0);

		gfx.Scissor(
			-((scaledW / 2) * timers['scissor']['intro']),
			0,
			scaledW * timers['scissor']['intro'],
			scaledH
		);

		gfx.Translate(-(scaledW / 2), 0);

		background:draw({
			['x'] = scaledW / 2,
			['y'] = scaledH / 2,
			['centered'] = true
		});

		gfx.BeginPath();
		gfx.FillColor(0, 0, 0, math.floor(150 * timers['fade']['in']));
		gfx.Rect(0, 0, scaledW, scaledH);
		gfx.Fill();

		gfx.ResetScissor();
	else
		gfx.Scissor(
			0,
			0,
			(scaledW / 2) * timers['scissor']['outro']['left'],
			scaledH
		);

		background:draw({
			['x'] = scaledW / 2,
			['y'] = scaledH / 2,
			['centered'] = true
		});

		gfx.ResetScissor();

		gfx.Scissor(
			(scaledW / 2) + ((scaledW / 2) * timers['scissor']['outro']['right']),
			0,
			scaledW / 2,
			scaledH
		);

		background:draw({
			['x'] = scaledW / 2,
			['y'] = scaledH / 2,
			['centered'] = true
		});

		gfx.ResetScissor();
	end

	gfx.Translate(scaledW / 2, scaledH / 2);

	drawDetails(-240, -360, 480, 480, 24, flickerAlpha);

	gfx.BeginPath();
	gfx.StrokeWidth(2);
	gfx.StrokeColor(60, 110, 160, math.floor(255 * flickerAlpha));
	gfx.ImageRect(-240, -360, 480, 480, jacket, flickerAlpha, 0);
	gfx.Stroke();

	if (isIntro) then
		gfx.BeginPath();
		gfx.FillColor(0, 0, 0, math.floor(255 * flickerAlpha));
		gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP);
		labels['title']:draw({
			['x'] = 0,
			['y'] = 241
		});
		gfx.FillColor(255, 255, 255, math.floor(255 * flickerAlpha));
		gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP);
		labels['title']:draw({
			['x'] = 0,
			['y'] = 240
		});

		gfx.FillColor(0, 0, 0, math.floor(255 * flickerAlpha));
		gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP);
		labels['artist']:draw({
			['x'] = 0,
			['y'] = 241 + labels['title']['h'] * 1.5
		});
		gfx.FillColor(60, 110, 160, math.floor(255 * flickerAlpha));
		gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP);
		labels['artist']:draw({
			['x'] = 0,
			['y'] = 240 + labels['title']['h'] * 1.5
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
	gfx.LineTo(x, y - (s * 0.875));

	gfx.MoveTo(x + w + s, y);
	gfx.LineTo(x + w + s, y - (s * 0.875));
	gfx.LineTo(x + w, y - (s * 0.875));

	gfx.MoveTo(x - s, y + h);
	gfx.LineTo(x - s, y + h + (s * 0.875));
	gfx.LineTo(x, y + h + (s * 0.875));

	gfx.MoveTo(x + w + s, y + h);
	gfx.LineTo(x + w + s, y + h + (s * 0.875));
	gfx.LineTo(x + w, y + h + (s * 0.875));

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
		['intro'] = 0,
		['outro'] = 0,
		['fade'] = {
			['in'] = 1
		},
		['flicker'] = {
			['intro'] = 0,
			['outro'] = 0
		},
		['scissor'] = {
			['intro'] = 0,
			['outro'] = {
				['left'] = 1,
				['right'] = 0,
			}
		}
	};
end