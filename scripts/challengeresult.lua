local LabelConstants = require('constants/challengeresult');

local help = require('helpers/challengeresult');

local background = New.Image({ path = 'bg.png' });

local challengeInfo = {};

local charts = {};

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

local challengeHeading = {
	cache = { scaledW = 0, scaledH = 0 },
	labels = LabelConstants.generate('challengeHeading'),
	order = {
		'result',
		'completion',
		'date',
		'player',
	},
	padding = { x = 0, y = 0 },
	w = { base = 0, max = 0 },
	h = 0,
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.w.base = scaledW - (scaledW / 10);
			self.w.base = self.w.base * (2 / 3);
			self.h = scaledH / 2.625;
			self.x = scaledW / 20;
			self.y = scaledH / 20;

			self.padding.x = self.w.base / 30;
			self.padding.y = self.h / 12;

			self.w.max = self.w.base - (self.padding.x * 2);

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	drawChallengeHeading = function(self)
		local x = self.x + self.padding.x;
		local y = self.y + self.padding.y;


		drawLabel({
			x = x,
			y = y,
			color = 'normal',
			label = self.labels.challenge,
		});

		y = y + (self.labels.challenge.h * 1.25);

		drawLabel({
			x = x,
			y = y,
			color = 'white',
			label = challengeInfo.title,
		});

		y = y + (challengeInfo.title.h * 0.85) + self.padding.y;

		for i, name in ipairs(self.order) do
			local tempX = x + (self.padding.x * ((i - 1) * 5));

			drawLabel({
				x = tempX,
				y = y,
				color = 'normal',
				label = self.labels[name],
			});

			drawLabel({
				x = tempX,
				y = y + (self.labels[name].h * 1.35),
				color = 'white',
				label = challengeInfo[name],
			});
		end

		y = y + (self.labels.result.h * 1.35) + (challengeInfo.result.h * 2.25);

		drawLabel({
			x = x,
			y = y,
			color = 'normal',
			label = self.labels.requirements,
		});

		y = y + (self.labels.requirements.h * 1.35) + 2;

		for i, requirement in ipairs(challengeInfo.requirements) do
			drawLabel({
				x = x + 1,
				y = y,
				color = 'white',
				label = requirement,
			});

			y = y + (requirement.h * 1.625);

			if (i == 6) then
				break;
			end
		end
	end,

	render = function(self, deltaTime)
		self:setSizes();

		gfx.Save();

		drawRectangle({
			x = self.x,
			y = self.y,
			w = self.w.base,
			h = self.h,
			alpha = 120,
			color = 'dark',
		});

		self:drawChallengeHeading();

		gfx.Restore();
	end,
};

local chartsPanel = {
	cache = { scaledW = 0, scaledH = 0 },
	labels = LabelConstants.generate('chartsPanel'),
	jacketSize = 0,
	order = {
		'critical',
		'near',
		'error',
		'maxChain',
	},
	padding = {
		column = { x = 0, y = 0 },
		x = 0,
		y = 0,
	},
	w = { base = 0, column = { base = 0, max = 0 } },
	h = 0,
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.w.base = scaledW - (scaledW / 10);
			self.h = scaledH - (scaledH / 2.625) - (scaledH / 10) - (scaledH / 40);
			self.x = (scaledW / 2) - (self.w.base / 2);
			self.y = (scaledH / 2.625) + ((scaledH / 10) - scaledH / 40);

			self.padding.x = self.w.base / 30;
			self.padding.y = self.h / 13;
			
			self.w.column.base = (self.w.base - (self.padding.x * 6)) / 3;
			self.w.column.max = self.w.column.base;

			self.jacketSize = self.w.column.base / 3;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	getSpacing = function(self)
		local totalWidth = 0;

		for _, name in ipairs(self.order) do
			totalWidth = totalWidth + self.labels[name].w;
		end

		return (self.w.column.max - totalWidth) / (#self.order - 1);
	end,

	drawCharts = function(self, deltaTime)
		local x = self.x + self.padding.x;

		for i = 1, math.min(3, #charts) do
			local chart = charts[i];
			local innerX = x + self.jacketSize + (self.padding.x / 2);
			local y = self.y + self.padding.y;

			drawRectangle({
				x = x,
				y = y,
				w = self.jacketSize,
				h = self.jacketSize,
				image = chart.jacket,
				stroke = { color = 'normal', size = 1 },
			});

			drawLabel({
				x = innerX,
				y = y - 5,
				color = 'normal',
				label = self.labels.result,
			});

			drawLabel({
				x = innerX + (self.padding.x * 2.75),
				y = y - 5,
				color = 'normal',
				label = self.labels.completion,
			});

			y = y + (self.labels.result.h * 1.35) - 5;

			drawLabel({
				x = innerX,
				y = y,
				color = 'white',
				label = chart.result,
			});

			drawLabel({
				x = innerX + (self.padding.x * 2.75),
				y = y,
				color = 'white',
				label = chart.completion,
			});

			y = y + (chart.completion.h * 2);

			drawLabel({
				x = innerX,
				y = y + 4,
				color = 'normal',
				label = self.labels.score,
			});

			y = y + self.labels.score.h;

			chart.score.label:setInfo({ value = chart.score.value });

			chart.score.label:draw({
				x = innerX - 3,
				y1 = y,
				y2 = y + (chart.score.label.labels[5].h / 4) - 3,
				offset = 10,
			});

			y = self.y + self.padding.y + self.jacketSize + (self.padding.y / 2);

			drawLabel({
				x = x,
				y = y,
				color = 'normal',
				label = self.labels.title,
			});

			y = y + (self.labels.title.h * 1.35);

			if (chart.title.w > self.w.column.max) then
				chart.timers.title = chart.timers.title + deltaTime;

				drawScrollingLabel({
					x = x,
					y = y,
					alpha = 255,
					color = 'white',
					label = chart.title,
					scale = scalingFactor,
					timer = chart.timers.title,
					width = self.w.column.max,
				});
			else
				drawLabel({
					x = x,
					y = y,
					color = 'white',
					label = chart.title,
				});
			end

			y = y + (chart.title.h * 1.75);

			drawLabel({
				x = x + (self.labels.difficulty.w * 2),
				y = y,
				color = 'normal',
				label = self.labels.bpm,
			});

			drawLabel({
				x = x,
				y = y,
				color = 'normal',
				label = self.labels.difficulty,
			});

			y = y + (self.labels.difficulty.h * 1.35);

			drawLabel({
				x = x,
				y = y,
				color = 'white',
				label = chart.difficulty,
			});

			drawLabel({
				x = x + chart.difficulty.w + 8,
				y = y,
				color = 'white',
				label = chart.level,
			});

			drawLabel({
				x = x + (self.labels.difficulty.w * 2),
				y = y,
				color = 'white',
				label = chart.bpm,
			});

			y = y + (chart.difficulty.h * 2);

			drawLabel({
				x = x,
				y = y,
				color = 'normal',
				label = self.labels.gauge,
			});

			drawLabel({
				x = x + (self.padding.x * 2.5),
				y = y,
				color = 'normal',
				label = self.labels.grade,
			});

			drawLabel({
				x = x + (self.padding.x * 5),
				y = y,
				color = 'normal',
				label = self.labels.clear,
			});

			y = y + (self.labels.gauge.h * 1.35);

			drawLabel({
				x = x,
				y = y,
				color = 'white',
				label = chart.gauge,
			});

			drawLabel({
				x = x + (self.padding.x * 2.5),
				y = y,
				color = 'white',
				label = chart.grade,
			});

			drawLabel({
				x = x + (self.padding.x * 5),
				y = y,
				color = 'white',
				label = chart.clear,
			});

			y = y + (chart.grade.h * 2);
			
			local spacing = self:getSpacing();
			local statX = x;

			for i, name in ipairs(self.order) do
				drawLabel({
					x = statX,
					y = y,
					color = 'normal',
					label = self.labels[name],
				});

				drawLabel({
					x = statX,
					y = y + (self.labels[name].h * 1.35),
					color = 'white',
					label = chart[name],
				});

				statX = statX + self.labels[name].w + spacing;
			end
	
			if (i ~= math.min(3, #charts)) then
				drawRectangle({
					x = x + self.w.column.base + self.padding.x,
					y = self.y + self.padding.y,
					w = 2,
					h = self.h - (self.padding.y * 2),
					alpha = 100,
					color = 'normal',
				});
			end

			x = x + self.w.column.base + (self.padding.x * 2);
		end
	end,

	render = function(self, deltaTime)
		self:setSizes();

		gfx.Save();

		drawRectangle({
			x = self.x,
			y = self.y,
			w = self.w.base,
			h = self.h,
			alpha = 120,
			color = 'dark',
		});

		self:drawCharts(deltaTime);

		gfx.Restore();
	end,
};

local screenshot = {
	labels = nil,
	path = '',
	timer = 0,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {
				path = New.Label({
					font = 'normal',
					text = '',
					size = 24,
				});
				saved = New.Label({
					font = 'normal',
					text = 'SCREENSHOT SAVED TO',
					size = 24,
				});
			};
		end
	end,

	drawNotification = function(self, deltaTime);
		self:setLabels();

		if (self.timer > 0) then
			self.timer = math.max(self.timer - deltaTime, 0);

			self.labels.path:update({ new = self.path });

			gfx.Save();

			gfx.Translate(8, 4);

			drawLabel({
				x = 0,
				y = 0,
				color = 'normal',
				label = self.labels.saved,
			});

			drawLabel({
				x = self.labels.saved.w + 16,
				y = 0,
				color = 'white',
				label = self.labels.path,
			});

			gfx.Restore();
		end
	end,
};

result_set = function()
	challengeInfo = help.formatChallengeInfo(result);

	charts = help.formatCharts(result);
end

render = function(deltaTime, newScroll)
	setupLayout();

	drawImage({
		x = 0,
		y = 0,
		w = scaledW,
		h = scaledH,
		image = background,
	});

	challengeHeading:render(deltaTime);

	chartsPanel:render(deltaTime);

	screenshot:drawNotification(deltaTime);
end

get_capture_rect = function()
	resX, resY = game.GetResolution();

	return 0, 0, resX, resY;
end

screenshot_captured = function(path)
	screenshot.timer = 5;
	screenshot.path = string.upper(path);
end