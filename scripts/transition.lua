
local background = cacheImage('bg.png');

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

local timers = {
	['intro'] = 0,
	['outro'] = 0,
	['fade'] = {
		['in'] = 1
	},
	['scissor'] = {
		['intro'] = 0,
		['outro'] = {
			['left'] = 1,
			['right'] = 0,
		}
	}
};


drawTransition = function(deltaTime, isIntro);
	gfx.Save();

	setupLayout();

	if (isIntro) then
		timers['fade']['in'] = math.max(timers['fade']['in'] - (deltaTime * 1.5), 0);
	
		timers['scissor']['intro'] = math.min(timers['scissor']['intro'] + (deltaTime * 3), 1)

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

	gfx.Restore();
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
	timers = {
		['intro'] = 0,
		['outro'] = 0,
		['fade'] = {
			['in'] = 1
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