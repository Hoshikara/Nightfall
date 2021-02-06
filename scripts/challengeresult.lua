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

		gfx.BeginPath();
		FontAlign.Left();

			self.labels.challenge:draw({
			x = x,
			y = y,
			color = 'Normal',
		});

		y = y + (self.labels.challenge.h * 1.25);

		challengeInfo.title:draw({
			x = x,
			y = y,
			color = 'White',
		});

		y = y + (challengeInfo.title.h * 0.85) + self.padding.y;

		for i, name in ipairs(self.order) do
			local tempX = x + (self.padding.x * ((i - 1) * 5));

			self.labels[name]:draw({
				x = tempX,
				y = y,
				color = 'Normal',
			});

			challengeInfo[name]:draw({
				x = tempX,
				y = y + (self.labels[name].h * 1.35),
				color = 'White',
			});
		end

		y = y + (self.labels.result.h * 1.35) + (challengeInfo.result.h * 2.25);

		self.labels.requirements:draw({
			x = x,
			y = y,
			color = 'Normal',
		});

		y = y + (self.labels.requirements.h * 1.35) + 2;

		for i, requirement in ipairs(challengeInfo.requirements) do
			requirement:draw({
				x = x + 1,
				y = y,
				color = 'White',
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

		gfx.BeginPath();
		Fill.Dark(120);
		gfx.Rect(
			self.x,
			self.y,
			self.w.base,
			self.h
		);
		gfx.Fill();

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

			gfx.BeginPath();
      gfx.StrokeWidth(1);
      gfx.StrokeColor(60, 110, 160, 255);
      gfx.ImageRect(
        x,
        y,
				self.jacketSize,
				self.jacketSize,
        chart.jacket,
        1,
        0
      );
			gfx.Stroke();

			gfx.BeginPath();
			FontAlign.Left();

			self.labels.result:draw({
				x = innerX,
				y = y - 5,
				color = 'Normal',
			});

			self.labels.completion:draw({
				x = innerX + (self.padding.x * 2.75),
				y = y - 5,
				color = 'Normal',
			});

			y = y + (self.labels.result.h * 1.35) - 5;

			chart.result:draw({
				x = innerX,
				y = y,
				color = 'White',
			});

			chart.completion:draw({
				x = innerX + (self.padding.x * 2.75),
				y = y,
				color = 'White',
			});

			y = y + (chart.completion.h * 2);

			self.labels.score:draw({
				x = innerX,
				y = y + 4,
				color = 'Normal',
			});

			y = y + self.labels.score.h;

			chart.score.label:setInfo({ value = chart.score.value });

			chart.score.label:draw({
				offset = 10,
				x = innerX - 3,
				y1 = y,
				y2 = y + (chart.score.label.labels[5].h / 4) - 3,
			});

			y = self.y + self.padding.y + self.jacketSize + (self.padding.y / 2);

			self.labels.title:draw({
				x = x,
				y = y,
				color = 'Normal',
			});

			y = y + (self.labels.title.h * 1.35);

			if (chart.title.w > self.w.column.max) then
				chart.timers.title = chart.timers.title + deltaTime;

				chart.title:draw({
					x = x,
					y = y,
					a = 255,
					color = 'White',
					scale = scalingFactor,
					scrolling = true,
					timer = chart.timers.title,
					width = self.w.column.max,
				});
			else
				chart.title:draw({
					x = x,
					y = y,
					color = 'White',
				});
			end

			y = y + (chart.title.h * 1.75);

			self.labels.bpm:draw({
				x = x + (self.labels.difficulty.w * 2),
				y = y,
				color = 'Normal',
			});

			self.labels.difficulty:draw({
				x = x,
				y = y,
				color = 'Normal',
			});

			y = y + (self.labels.difficulty.h * 1.35);

			chart.difficulty:draw({
				x = x,
				y = y,
				color = 'White',
			});

			chart.level:draw({
				x = x + chart.difficulty.w + 8,
				y = y,
				color = 'White',
			});

			chart.bpm:draw({
				x = x + (self.labels.difficulty.w * 2),
				y = y,
				color = 'White',
			});

			y = y + (chart.difficulty.h * 2);

			self.labels.gauge:draw({
				x = x,
				y = y,
				color = 'Normal',
			});

			self.labels.grade:draw({
				x = x + (self.padding.x * 2.5),
				y = y,
				color = 'Normal',
			});

			self.labels.clear:draw({
				x = x + (self.padding.x * 5),
				y = y,
				color = 'Normal',
			});

			y = y + (self.labels.gauge.h * 1.35);

			chart.gauge:draw({
				x = x,
				y = y,
				color = 'White',
			});

			chart.grade:draw({
				x = x + (self.padding.x * 2.5),
				y = y,
				color = 'White',
			});

			chart.clear:draw({
				x = x + (self.padding.x * 5),
				y = y,
				color = 'White',
			});

			y = y + (chart.grade.h * 2);
			
			local spacing = self:getSpacing();
			local statX = x;

			for i, name in ipairs(self.order) do
				self.labels[name]:draw({
					x = statX,
					y = y,
					color = 'Normal',
				});

				chart[name]:draw({
					x = statX,
					y = y + (self.labels[name].h * 1.35),
					color = 'White',
				});

				statX = statX + self.labels[name].w + spacing;
			end
	
			if (i ~= math.min(3, #charts)) then
				gfx.BeginPath();
				Fill.Normal(100);
				gfx.Rect(
					x + self.w.column.base + self.padding.x,
					self.y + self.padding.y,
					2,
					self.h - (self.padding.y * 2)
				);
				gfx.Fill();
			end

			x = x + self.w.column.base + (self.padding.x * 2);
		end
	end,

	render = function(self, deltaTime)
		self:setSizes();

		gfx.Save();

		gfx.BeginPath();
		Fill.Dark(120);
		gfx.Rect(
			self.x,
			self.y,
			self.w.base,
			self.h
		);
		gfx.Fill();

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
			Font.Normal();

			self.labels = {
				path = New.Label({ text = '', size = 24 });
				saved = New.Label({ text = 'SCREENSHOT SAVED TO', size = 24 });
			};
		end
	end,

	drawNotification = function(self, deltaTime);
		self:setLabels();

		if (self.timer > 0) then
			self.timer = math.max(self.timer - deltaTime, 0);

			Font.Normal();
			self.labels.path:update({ new = self.path });

			gfx.Save();

			gfx.Translate(8, 4);

			gfx.BeginPath();
			FontAlign.Left();
			
			self.labels.saved:draw({
				x = 0,
				y = 0,
				color = 'Normal'
			});

			self.labels.path:draw({
				x = self.labels.saved.w + 16,
				y = 0,
				color = 'White',
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

	background:draw({
		x = 0,
		y = 0,
		w = scaledW,
		h = scaledH,
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