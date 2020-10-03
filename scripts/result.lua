local CONSTANTS = require('constants/result');

local easing = require('lib/easing');
local help = require('helpers/result');
local number = require('common/number');
local pages = require('common/pages');

local background = cacheImage('bg.png');

local jacket = nil;
local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local previousScore = nil;
local selectedScore = 1;

local allScores = {};
local loadedScores = {};

local myScore = nil;
local score = nil;

local singleplayer = true;
local songInfo = nil;

local gaugeSamples = {};
local gaugeType = 0;

local mousePosX = 0;
local mousePosY = 0;

local upScore = nil;

local screenshotRegion = game.GetSkinSetting('screenshotRegion') or 'PANEL';

local cache = { resX = 0, resY = 0 };

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

local moveX = 0;
local moveY = 0;

setupLayout = function()
  resX, resY = game.GetResolution();

  if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
    scaledW = 1920;
    scaledH = scaledW * (resY / resX);
		scalingFactor = resX / scaledW;

		local scaleX = resX / scaledW;
		local scaleY = resY / scaledH;
		
		if (scaleX > scaleY) then
			moveX = (resX / (2 * scalingFactor)) - (scaledW / 2);
			moveY = 0;
		else
			moveX = 0;
			moveY = (resY / (2 * scalingFactor) - (scaledH / 2));
		end

    cache.resX = resX;
    cache.resY = resY;
  end

  gfx.Scale(scalingFactor, scalingFactor);
end

local resultPanel = {
	cache = { scaledW = 0, scaledH = 0 },
	graph = { h = 0, y = 0 },
	jacketSize = 0,
	labels = nil,
	orders = {
		song = {
			'title',
			'artist',
			'effector',
			'difficulty',
		},
		stat = {
			row = {
				{
					'grade',
					'clear',
					'criticalWindow',
					'nearWindow',
				},
				{
					'critical',
					'near',
					'early',
					'late',
					'error',
					'maxChain',
				},
			},
		},
	},
	padding = {
		x = { double = 0, full = 0 },
		y = { double = 0, full = 0 },
	},
	panel = {
		image = cacheImage('results/panel.png'),
		maxWidth = 0,
		w = 0,
		h = 0,
		x = 0,
		y = 0,
	},
	score = number.create({
		isScore = true,
		sizes = { 90, 72 },
	}),
	songInfo = nil,
	stats = nil,
	timers = {
		artist = 0,
		effector = 0,
		title = 0,
	},
	text = { x = { 0, 0 }, y = 0 },

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.jacketSize = scaledW / 6.5;

			self.panel.w = scaledW / (scaledW / self.panel.image.w);
			self.panel.h = scaledH - (scaledH / 10);
			self.panel.x = (((not singleplayer) or (#allScores > 0)) and (scaledW / 20))
				or ((scaledW / 2) - (self.panel.w / 2));
			self.panel.y = scaledH / 20;

			self.padding.x.full = self.panel.w / 24;
			self.padding.x.double = self.padding.x.full * 2;

			self.padding.y.full = self.panel.h / 24;
			self.padding.y.double = self.padding.y.full * 2;

			self.panel.maxWidth = self.panel.w
				- self.padding.x.double
				- (self.padding.x.full * 1.75)
				- 4;
			
			self.text.x[1] = self.padding.x.double + self.jacketSize + self.padding.x.full;
			self.text.x[2] = self.padding.x.double;
			self.text.y = (self.padding.y.double * 0.75) + self.jacketSize;
			

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				btbbtc = cacheLabel('[BT-B]  +  [BT-C]', 20),
				songCollections = cacheLabel('SONG COLLECTIONS', 20),
			};

			for key, name in pairs(CONSTANTS.song) do
				self.labels[key] = cacheLabel(name, 18);
			end

			for key, name in pairs(CONSTANTS.stats) do
				self.labels[key] = cacheLabel(name, 18);
			end

			font.number();

			if (upScore) then
				self.labels.plus = cacheLabel('+', 30);

				self.upScore = number.create({
					isScore = true,
					sizes = { 30, 24 },
				});
			end
		end
	end,

	setSongInfo = function(self)
		if (not self.songInfo) then
			self.songInfo = {};

			for key, value in pairs(songInfo) do
				font[value.font]();

				self.songInfo[key] = cacheLabel(value.value, value.size);
			end
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			self.stats = {};

			for key, value in pairs(myScore) do
				if (key ~= 'score') then
					font[value.font]();

					self.stats[key] = cacheLabel(value.value, value.size);
				end
			end
		end
	end,

	getSpacing = function(self, order)
		local totalWidth = 0;

		for _, name in ipairs(order) do
			totalWidth = totalWidth + self.labels[name].w;
		end

		return (self.panel.maxWidth - totalWidth) / (#order - 1);
	end,

	drawNavigation = function(self)
		gfx.BeginPath();
		align.left();

		self.labels.btbbtc:draw({
			x = self.panel.x,
			y = scaledH - (scaledH / 20) + (self.labels.btbbtc.h - 6),
			color = 'normal',
		});

		self.labels.songCollections:draw({
			x = self.panel.x + self.labels.btbbtc.w + 8,
			y = scaledH - (scaledH / 20) + (self.labels.btbbtc.h - 6) + 1,
			color = 'white',
		});
	end,

	drawSongInfo = function(self, deltaTime)
		local maxWidth = self.panel.maxWidth - (self.jacketSize + self.padding.x.full);
		local x = self.text.x[1];
		local y = self.padding.y.full - 5;

		gfx.Save();

		gfx.Translate(self.panel.x, self.panel.y);

		gfx.BeginPath();
		gfx.StrokeWidth(1);
		gfx.StrokeColor(60, 110, 160, 255);
		gfx.ImageRect(
			self.padding.x.double,
			self.padding.y.full,
			self.jacketSize,
			self.jacketSize,
			jacket,
			1,
			0
		);
		gfx.Stroke();

		gfx.BeginPath();
		align.left();

		for _, name in ipairs(self.orders.song) do
			self.labels[name]:draw({
				x = x,
				y = y,
				color = 'normal',
			});

			if (name == 'difficulty') then
				self.labels.bpm:draw({
					x = self.panel.w - (self.padding.x.double * 3),
					y = y,
					color = 'normal',
				});
			end

			y = y + (self.labels[name].h * 1.5);

			if (self.songInfo[name].w > maxWidth) then
				self.timers[name] = self.timers[name] + deltaTime;

				drawScrollingLabel(
					self.timers[name],
					self.songInfo[name],
					maxWidth,
					x,
					y,
					scalingFactor,
					'white',
					255
				);
			else
				self.songInfo[name]:draw({
					x = x,
					y = y,
					color = 'white',
				});
			end
			
			if (name == 'difficulty') then
				self.songInfo.level:draw({
					x = x + self.songInfo[name].w + 8,
					y = y,
					color = 'white',
				});
			end

			if (name ~= 'difficulty') then
				y = y + self.songInfo[name].h + (self.labels[name].h * 1.5);
			end
		end

		self.songInfo.bpm:draw({
			x = self.panel.w - (self.padding.x.double * 3),
			y = y,
			color = 'white',
		});

		gfx.Restore();
	end,

	drawStats = function(self)
		local x = self.text.x[2] - 2;
		local y = self.text.y;

		self.score:setInfo({ value = score });

		gfx.Save();

		gfx.Translate(self.panel.x, self.panel.y);

		gfx.BeginPath();
		align.left();

		self.labels.score:draw({
			x = x,
			y = y,
			color = 'normal',
		});

		if (upScore) then
			self.upScore:setInfo({ value = upScore });

			self.labels.plus:draw({
				x = x + (self.score.position[5] * 1.1),
				y = y - 3,
				color = 'white',
			});

			self.upScore:draw({
				offset = 4,
				x = x + (self.score.position[5] * 1.2) + 5,
				y1 = y - 3,
				y2 = y + 3
			});
		end

		self.labels.name:draw({
			x = self.panel.w - (self.padding.x.full * 1.75) - 4 - self.stats.name.w,
			y = y,
			color = 'normal',
		});

		align.right();
		
		self.stats.name:draw({
			x = self.panel.w - (self.padding.x.full * 1.75) - 4,
			y = y + (self.labels.name.h * 1.5),
			color = 'white',
		});
		
		y = y + (self.labels.score.h * 0.5);

		align.left();

		self.score:draw({
			offset = 10,
			x = x - 5,
			y1 = y,
			y2 = y + (self.score.labels[5].h / 4) - 3,
		});

		y = y + (self.score.labels[1].h * 1.0625);

		local statX = x;
		local statY = y + (self.labels.grade.h * 1.5);
		local spacing = self:getSpacing(self.orders.stat.row[1]);

		for _, name in ipairs(self.orders.stat.row[1]) do
			self.labels[name]:draw({
				x = statX,
				y = y,
				color = 'normal',
			});

			self.stats[name]:draw({
				x = statX,
				y = statY,
				color = 'white',
			});
	
			statX = statX + self.labels[name].w + spacing;
		end

		y = y + (self.labels.grade.h * 2) + (self.stats.grade.h * 2);

		statX = x;
		statY = y + (self.labels.critical.h * 1.5);
		spacing = self:getSpacing(self.orders.stat.row[2]);

		for _, name in ipairs(self.orders.stat.row[2]) do
			self.labels[name]:draw({
				x = statX,
				y = y,
				color = 'normal',
			});

			self.stats[name]:draw({
				x = statX + 1,
				y = statY,
				color = 'white',
			});
	
			statX = statX + self.labels[name].w + spacing;
		end

		self.graph.y = statY + (self.labels.critical.h * 2.5) + (self.stats.critical.h * 2.5);
		self.graph.h = self.panel.h - self.graph.y;

		gfx.Restore();
	end,

	render = function(self, deltaTime)
		gfx.Save();

		self:setSizes();

		self:setLabels();

		self:setSongInfo();

		self:setStats();

		if (not myScore) then return end

		self.panel.image:draw({
			x = self.panel.x,
			y = self.panel.y,
			w = self.panel.w,
			h = self.panel.h,
			a = 0.5,
		});

		self:drawSongInfo(deltaTime);

		self:drawStats();

		self:drawNavigation();

		gfx.Restore();
	end,
};

local graphs = {
	cache = { scaledW = 0, scaledH = 0 },
	duration = 0,
	hitDeltaScale = 1,
	hitStats = false,
	histogram = {},
	hoverScale = 0,
	labels = nil,
	earliest = 0,
	latest = 0,
	pressedBTA = false,
	stats = nil,
	statOrder = {
		'gauge',
		'meanDelta',
		'medianDelta',
	},
	w = {
		left = 0,
		right = 0,
		total = 0,
	},
	h = 0,
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.w.total = resultPanel.panel.maxWidth;
			self.w.left = self.w.total * 0.7;
			self.w.right = self.w.total * 0.3;
			self.h = resultPanel.graph.h;
			self.x = resultPanel.panel.x + resultPanel.padding.x.double;
			self.y = resultPanel.graph.y;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				earliest = cacheLabel('EARLIEST', 18),
				latest = cacheLabel('LATEST', 18),
				mean = cacheLabel('MEAN', 18),
				median = cacheLabel('MEDIAN', 18),
			};
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			font.number();

			self.stats = {
				currentGauge = cacheLabel('0', 18),
				earliest = cacheLabel(
					string.format('%.1f ms', self.earliest),
					18
				),
				latest = cacheLabel(
					string.format('%.1f ms', self.latest),
					18
				),
			};

			for _, name in ipairs(self.statOrder) do
				local value = myScore[name];

				font[value.font]();

				self.stats[name] = cacheLabel(value.value, value.size);
			end
		end
	end,

	handleButton = function(self)
		if ((not self.pressedBTA) and game.GetButton(game.BUTTON_BTA)) then
			if ((self.hitDeltaScale + 0.2) > 3) then
				self.hitDeltaScale = 0.6;
			else
				self.hitDeltaScale = self.hitDeltaScale + 0.2;
			end
		end

		self.pressedBTA = game.GetButton(game.BUTTON_BTA);
	end,

	drawGaugeGraph = function(self, initialX, initialY, w, h, a, focusPoint, hoverScale)
		if (not focusPoint) then
			focusPoint = 0;
			hoverScale = 1;
		end

		local samples = gaugeSamples;
		local y = initialY + 1;

		if (#samples == 0) then return end

		local leftIndex = math.floor(
			(#samples / w) * ((-focusPoint / hoverScale) + focusPoint)
		);

		leftIndex = math.max(1, math.min(#samples, leftIndex));

		gfx.BeginPath();
		gfx.StrokeWidth(2);
		gfx.MoveTo(initialX, y + h - (h * samples[leftIndex]));

		for i = (leftIndex + 1), #samples do
			local x = (i * w) / #samples;

			x = (x - focusPoint) * hoverScale + focusPoint;

			if (x > w) then break end

			gfx.LineTo(initialX + x, y + h - (h * samples[i]));
		end

		if (gaugeType & 1 ~= 0) then
			gfx.StrokeColor(255, 155, 55, a);
			gfx.Stroke();
		else
			gfx.Scissor(initialX, y + (h * 0.3), w, h * 0.7);
			gfx.StrokeColor(55, 155, 255, a);
			gfx.Stroke();
			gfx.ResetScissor();

			gfx.Scissor(initialX, y - 10, w, 10 + (h * 0.3));
			gfx.StrokeColor(255, 55, 205, a);
			gfx.Stroke();
			gfx.ResetScissor();
		end
	end,

	drawGraphLines = function(self, x, y, w, h)
		local maximumDisplay = (h / 2) / self.hitDeltaScale;

		gfx.StrokeWidth(1);

		gfx.BeginPath();
		gfx.StrokeColor(255, 255, 255, 150);
		gfx.MoveTo(x, y + (h / 2));
		gfx.LineTo(x + w, y + (h / 2));
		gfx.Stroke();

		gfx.BeginPath();
		gfx.StrokeColor(60, 110, 160, 50);

		for i = -math.floor(maximumDisplay / 10), math.floor(maximumDisplay / 10) do
			local lineY = y + (h / 2) + (i * 10 * self.hitDeltaScale);

			if (i ~= 0) then
				gfx.MoveTo(x, lineY);
				gfx.LineTo(x + w, lineY);
			end
		end

		gfx.Stroke();
	end,

	drawHistogram = function(self, x, y, w, h)
		if (not self.hitStats) then return end

		local maximumDisplay = math.floor((h / 2) / self.hitDeltaScale);

		local mode = 0;
		local modeCount = 0;

		for i = (-maximumDisplay - 1), (maximumDisplay + 1) do
			if (not self.histogram[i]) then
				self.histogram[i] = 0;
			end
		end

		for i = -maximumDisplay, maximumDisplay do
			local count = self.histogram[i - 1]
				+ (self.histogram[i] * 2)
				+ (self.histogram[i + 1]);

			if (count > modeCount) then
				mode = i;
				modeCount = count;
			end
		end

		gfx.BeginPath();
		gfx.StrokeWidth(1.5);
		gfx.StrokeColor(60, 110, 160, 255);
		gfx.MoveTo(x, y);

		for i = -maximumDisplay, maximumDisplay do
			local count = self.histogram[i - 1]
				+ (self.histogram[i] * 2)
				+ (self.histogram[i + 1]);

			gfx.LineTo(
				x + (w * (count / modeCount)),
				y + (h / 2) + (i * self.hitDeltaScale)
			);
		end

		gfx.LineTo(x, y + h);
		gfx.Stroke();
	end,

	drawHitGraph = function(self, initialX, initialY, w, h, focusPoint, hoverScale)
		if (not self.hitStats) then return end

		if (not focusPoint) then
			focusPoint = 0;
		end

		if (not hoverScale) then
			hoverScale = 1;
		end

		for i = 1, #self.hitStats do
			local hitStat = self.hitStats[i];
			local x = (((hitStat.timeFrac * w) - focusPoint) * hoverScale) + focusPoint;

			if (x >= 0) then
				if (x > w) then break end

				local y = (h / 2) + (hitStat.delta * self.hitDeltaScale);

				if (y < 0) then
					y = 6;
				elseif (y > h) then
					y = h;
				end

				gfx.BeginPath();

				if (hitStat.rating == 2) then
					gfx.FillColor(85, 155, 255, 150);
				elseif (hitStat.rating == 1) then
					gfx.FillColor(255, 55, 255, 150);
				elseif (hitStat.rating == 0) then
					gfx.FillColor(255, 0, 0, 150);
				end

				gfx.Circle(initialX + x, initialY + y, 3);
				gfx.Fill();
			end
		end
	end,

	drawStats = function(self)
		local x = self.x + (self.w.total / 2);
		local y = self.y + self.h + 12;
		local spacing = (self.w.total / 2)
			- self.labels.mean.w
			- self.labels.median.w;

		gfx.BeginPath();
		align.left();

		self.labels.mean:draw({
			x = x,
			y = y,
			color = 'normal',
		});

		self.stats.meanDelta:draw({
			x = x + self.labels.mean.w + 16,
			y = y,
			color = 'white',
		});

		x = self.x + self.w.total;

		align.right();

		self.stats.medianDelta:draw({
			x = x - 4,
			y = y,
			color = 'white',
		});

		self.labels.median:draw({
			x = x - 4 - self.stats.medianDelta.w - 16,
			y = y,
			color = 'normal',
		});
	end,

	drawLeftGraph = function(self, x, y, w, h)
		local mouseX = (mousePosX / scalingFactor) - moveX;
		local mouseY = (mousePosY / scalingFactor) - moveY;

		local isHovering = (x <= mouseX)
			and (y <= mouseY)
			and (mouseX <= x + w)
			and (mouseY <= y + h);
		
		local currentTime = self.duration;
		local focusPoint = 0;
		local hoverScale = 1;

		if (isHovering) then
			focusPoint = mouseX - x;
			hoverScale = self.hoverScale

			currentTime = self.duration * (focusPoint / w);

			self:drawLine(mouseX, y, mouseX, y + h, 1, 255, 255, 255, 150);
		end

		font.number();
		resultPanel.songInfo.duration:update({
			new = string.format(
				'%dm %02d.%01ds',
				currentTime // 60000,
				(currentTime // 1000) % 60,
				(currentTime // 100) % 10
			),
			size = 18,
		});

		self:drawHitGraph(x, y, w, h, focusPoint, hoverScale);

		gfx.BeginPath();
		align.left();
		
		resultPanel.songInfo.duration:draw({
			x = self.x,
			y = self.y + self.h + 12,
			color = 'white',
		});

		if (#gaugeSamples > 1) then
			if (hoverScale == 1) then
				self:drawGaugeGraph(x, y, w, h, 255);
			else
				self:drawGaugeGraph(x, y, w, h, 50, focusPoint, hoverScale);
				self:drawGaugeGraph(x, y, w, h, 255);

				local samples = gaugeSamples;
				local gaugeIndex = math.floor(1
					+ (#samples / w)
					* (((mouseX - x - focusPoint) / hoverScale) + focusPoint)
				);
				
				gaugeIndex = math.max(1, math.min(#samples, gaugeIndex));

				local gaugeY = h - (h * samples[gaugeIndex]);

				font.number();
				self.stats.currentGauge:update({
					new = string.format('%d%%', math.floor(samples[gaugeIndex] * 100))
				});

				gfx.BeginPath();
				fill.white(150);
				gfx.Circle(mouseX, y + gaugeY + 2, 4);
				gfx.Fill();

				gfx.BeginPath();
				align.left();
				self.stats.currentGauge:draw({
					x = mouseX + 8,
					y = y + gaugeY - 12,
					color = 'white',
				});
			end

			gfx.BeginPath();
			align.left();
			self.stats.gauge:draw({
				x = x + 4,
				y = y,
				color = 'white',
			});
		end
	end,

	drawRightGraph = function(self, x, y, w, h)
		if (not self.hitStats) then return end

		self:drawHistogram(x, y, w, h);

		gfx.BeginPath();
		align.left();

		self.labels.earliest:draw({
			x = x + 6,
			y = y,
			color = 'normal',
		});

		self.labels.latest:draw({
			x = x + 6,
			y = y + h - self.labels.latest.h - 6,
			color = 'normal',
		});

		align.right();
		self.stats.earliest:draw({
			x = x + w - 4,
			y = y,
			color = 'white',
		});

		self.stats.latest:draw({
			x = x + w - 4,
			y = y + h - self.labels.latest.h - 6,
			color = 'white',
		});
	end,

	drawLine = function(self, x1, y1, x2, y2, w, r, g, b, a)
		gfx.BeginPath();
		gfx.StrokeColor(r, g, b, a);
		gfx.StrokeWidth(w);

		gfx.MoveTo(x1, y1);
		gfx.LineTo(x2, y2);

		gfx.Stroke();
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self:setStats();

		self:handleButton();

		gfx.Save();

		gfx.BeginPath();
		fill.dark(120);
		gfx.Rect(self.x, self.y, self.w.total, self.h);
		gfx.Fill();

		self:drawGraphLines(self.x, self.y, self.w.total, self.h);

		self:drawLeftGraph(self.x, self.y, self.w.left, self.h);

		self:drawRightGraph(self.x + self.w.left, self.y, self.w.right, self.h);

		self:drawStats();

		gfx.Restore();
	end
};

local scoreList = {
	bounds = { lower = 0, upper = 0 },
	cache = { scaledW = 0, scaledH = 0 },
	cursor = {
		alpha = 0,
		flickerTimer = 0,
		index = selectedScore,
		pos = 0,
		timer = 0,
		y = {},
	},
	easing = {
    scrollbar = {
      duration = 0.2,
      initial = 0,
      timer = 0,
    },
	},
	labels = nil,
	maxWidth = 0,
	multiplayerScore = 1,
	orders = {
		sp = {
			row = {
				{
					'timestamp',
					'gauge',
					'criticalWindow',
					'nearWindow'
				},
				{
					'grade',
					'clear',
					'critical',
					'near',
					'error'
				},
			},
		},
		mp = {
			row = {
				{
					'critical',
					'near',
					'early',
					'late',
					'error',
					'maxChain',
				},
			},
		},
	},
	padding = { x = 0, y = 0 },
	pressed = { FXL = false, FXR = false },
	scrollbar = {
		pos = 0,
		w = 0,
		h = 0,
		x = 0,
		y = 0
	},
	spacing = 0,
	stats = nil,
	timer = 0,
	viewLimit = 4,
	w = 0,
	h = { base = 0, selected = 0 },
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.x = (scaledW / 20) + resultPanel.panel.image.w + (scaledW / 40);
			self.y = scaledH / 20;
			self.w = scaledW - (scaledW / 20) - self.x;
			self.h.base = scaledH / 7;
			self.h.selected = self.h.base * 2.125;

			self.padding.x = self.w / 20;
			self.padding.y = self.h.base / 7.5;

			self.maxWidth = self.w - (self.padding.x * 2);

			self.scrollbar.w = 8;
			self.scrollbar.h = scaledH - (scaledH / 10);
			self.scrollbar.x = scaledW - (scaledW / 40) - 4;
			self.scrollbar.y = scaledH / 20;

			self.spacing = (scaledH
				- (scaledH / 10)
				- ((self.h.base * (self.viewLimit - 1)) + self.h.selected)
			) / (self.viewLimit - 1);

			self.cursor.y = {};

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				fxlfxr = cacheLabel('[FX-L]  /  [FX-R]', 20),
				selectScore = cacheLabel('SELECT SCORE', 20),
			};

			for key, name in pairs(CONSTANTS.stats) do
				self.labels[key] = cacheLabel(name, 18);
			end
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			self.stats = {};

			for i, score in ipairs(allScores) do
				font.number();

				self.stats[i] = {
					place = cacheLabel(i, 90),
				};

				for key, value in pairs(score) do
					if (key == 'score') then
						self.stats[i].score = number.create({
							isScore = true,
							sizes = { 90, 72 },
						});
					else
						font[value.font]();

						self.stats[i][key] = cacheLabel(value.value, value.size);
					end
				end
			end
		end
	end,

	setScrollbarPos = function(self, completion)
    self.easing.scrollbar.initial = self.scrollbar.pos;
    self.easing.scrollbar.timer = self.easing.scrollbar.duration;
		self.scrollbar.pos = self.scrollbar.y + (completion * (self.scrollbar.h - 32));
	end,
	
	getScrollbarPos = function(self)
    return easing.outQuad(
      self.easing.scrollbar.duration - self.easing.scrollbar.timer,
      self.easing.scrollbar.initial,
      self.scrollbar.pos - self.easing.scrollbar.initial,
      self.easing.scrollbar.duration
    );
	end,
	
	getSpacing = function(self, order, scale)
		local totalWidth = 0;

		for _, name in ipairs(order) do
			totalWidth = totalWidth + self.labels[name].w;
		end

		return ((self.maxWidth * scale) - totalWidth) / (#order - 1);
	end,

	handleNavigation = function(self, deltaTime)
		local cursorIndex =
			((selectedScore % self.viewLimit > 0) and (selectedScore % self.viewLimit))
		 	or self.viewLimit;
		local lowerBound, upperBound = pages.getPageBounds(
			self.viewLimit,
			#allScores,
			selectedScore
		);

		if (singleplayer and #allScores > 1) then
			if ((not self.pressed.FXL) and game.GetButton(game.BUTTON_FXL)) then
				if ((selectedScore - 1) < 1) then
					selectedScore = #allScores;
				else
					selectedScore = selectedScore - 1;
				end
			end

			if ((not self.pressed.FXR) and game.GetButton(game.BUTTON_FXR)) then
				if ((selectedScore + 1) > #allScores) then
					selectedScore = 1;
				else
					selectedScore = selectedScore + 1;
				end
			end

			self.pressed.FXL = game.GetButton(game.BUTTON_FXL);
			self.pressed.FXR = game.GetButton(game.BUTTON_FXR);
		end

		self.cursor.index = cursorIndex;
		self.bounds.lower = lowerBound;
		self.bounds.upper = upperBound;

		self:setScrollbarPos((selectedScore - 1) / (#allScores - 1));
	end,

	drawCursor = function(self, deltaTime)
		self.cursor.timer = self.cursor.timer + deltaTime;
		self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;
	
		self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
	
		if (self.cursor.flickerTimer >= 0.3) then
			self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
		end

		self.cursor.pos = self.cursor.pos
			- (self.cursor.pos - self.cursor.y[self.cursor.index])
			* deltaTime
			* 36;

		local scoreIndex =
			((selectedScore % self.viewLimit > 0) and (selectedScore % self.viewLimit))
			or self.viewLimit;

		gfx.Save();

		drawCursor({
			x = self.x,
			y = self.cursor.pos,
			w = self.w,
			h = (((self.cursor.index == scoreIndex) and self.h.selected) or self.h.base),
			alpha = self.cursor.alpha,
			size = 20,
			stroke = 2,
		});

		gfx.Restore();
	end,

	drawNavigation = function(self)
		local x = self.x;
		local y = scaledH - (scaledH / 20) + (self.labels.fxlfxr.h - 6);

		gfx.BeginPath();
		align.left();
	
		self.labels.fxlfxr:draw({
			x = x,
			y = y,
			color = 'normal',
		});

		self.labels.selectScore:draw({
			x = x + self.labels.fxlfxr.w + 8,
			y = y + 1,
			color = 'white',
		});
	end,

	drawScore = function(self, i, initialY, isSelected)
		local h = (isSelected and self.h.selected) or self.h.base;
		local x = self.padding.x;
		local y = self.padding.y + initialY;

		self.stats[i].score:setInfo({ value = allScores[i].score });

		gfx.BeginPath();
		fill.dark(120);
		gfx.Rect(0, initialY, self.w, h);
		gfx.Fill();

		gfx.BeginPath();
		align.right();
		self.stats[i].place:draw({
			x = self.w - self.padding.x + 8,
			y = y - 1,
			a = 40,
			color = 'normal',
		});

		gfx.BeginPath();
		align.left();

		self.labels.score:draw({
			x = x + 1,
			y = y,
			color = 'normal',
		});
	
		if (isSelected) then
			y = y + (self.labels.score.h * 0.75);
		else
			x = self.stats[i].score.position[8] + 144;

			if (singleplayer) then
				self.labels.timestamp:draw({
					x = x,
					y = y,
					color = 'normal',
				});
			else
				self.labels.name:draw({
					x = x,
					y = y,
					color = 'normal',
				});
			end

			y = y + (self.labels.score.h * 0.75);

			if (singleplayer) then
				self.stats[i].timestamp:draw({
					x = x,
					y = y + 8,
					color = 'white',
				});
			else
				self.stats[i].name:draw({
					x = x,
					y = y + 8,
					color = 'white',
				});
			end

			self.labels.clear:draw({
				x = x,
				y = y + (self.labels.score.h * 2.5) + 2,
				color = 'normal',
			});

			self.stats[i].clear:draw({
				x = x,
				y = y + (self.labels.score.h * 3.75) + 2,
				color = 'white',
			});
		end

		x = self.padding.x;

		self.stats[i].score:draw({
			offset = 10,
			x = x - 3,
			y1 = y,
			y2 = y + (self.stats[i].score.labels[1].h * 0.125) + 5,
		});

		if (isSelected) then
			y = y + self.stats[i].score.labels[1].h * 1.125;

			if (singleplayer) then
				local statX = x;
				local statY = y + (self.labels.timestamp.h * 1.5);
				local spacing = self:getSpacing(self.orders.sp.row[1], 1);

				for _, name in ipairs(self.orders.sp.row[1]) do
					self.labels[name]:draw({
						x = statX,
						y = y,
						color = 'normal',
					});

					self.stats[i][name]:draw({
						x = statX,
						y = statY,
						color = 'white',
					});

					statX = statX + self.labels[name].w + spacing;
				end

				y = y + (self.labels.timestamp.h * 2) + (self.stats[i].timestamp.h * 2);

				statX = x;
				statY = y + (self.labels.critical.h * 1.5);
				spacing = self:getSpacing(self.orders.sp.row[2], 1);

				for _, name in ipairs(self.orders.sp.row[2]) do
					self.labels[name]:draw({
						x = statX,
						y = y,
						color = 'normal',
					});

					self.stats[i][name]:draw({
						x = statX,
						y = statY,
						color = 'white',
					});

					statX = statX + self.labels[name].w + spacing;
				end
			else
				self.labels.name:draw({
					x = x,
					y = y,
					color = 'normal',
				});

				self.stats[i].name:draw({
					x = x,
					y = y + (self.labels.name.h * 1.5),
					color = 'white',
				});

				x = x + (self.labels.name.w * 3.5) + 1;

				self.labels.grade:draw({
					x = x,
					y = y,
					color = 'normal',
				});

				self.stats[i].grade:draw({
					x = x,
					y = y + (self.labels.grade.h * 1.5),
					color = 'white',
				});

				x = x + (self.labels.grade.w * 1.825) + 2;

				self.labels.gauge:draw({
					x = x,
					y = y,
					color = 'normal',
				});

				self.stats[i].gauge:draw({
					x = x,
					y = y + (self.labels.gauge.h * 1.5),
					color = 'white',
				});

				x = x + (self.labels.gauge.w * 2);

				self.labels.clear:draw({
					x = x,
					y = y,
					color = 'normal',
				});

				self.stats[i].clear:draw({
					x = x,
					y = y + (self.labels.clear.h * 1.5),
					color = 'white',
				});

				y = y + (self.labels.name.h * 2) + (self.stats[i].name.h * 2);

				local statX = self.padding.x;
				local statY = y + (self.labels.critical.h * 1.5);
				local spacing = self:getSpacing(self.orders.mp.row[1], 1);

				for _, name in ipairs(self.orders.mp.row[1]) do
					self.labels[name]:draw({
						x = statX,
						y = y,
						color = 'normal',
					});

					if (self.stats[i][name]) then
						self.stats[i][name]:draw({
							x = statX,
							y = statY,
							color = 'white',
						});
					end

					statX = statX + self.labels[name].w + spacing;
				end
			end

			return self.h.selected + self.spacing;
		end

		return self.h.base + self.spacing;
	end,

	drawScrollbar = function(self, deltaTime)
		if (self.easing.scrollbar.timer > 0) then
      self.easing.scrollbar.timer = math.max(self.easing.scrollbar.timer - deltaTime, 0);
		end
		
    local y = self:getScrollbarPos();

		gfx.BeginPath();
		fill.dark(120);
		gfx.Rect(
			self.scrollbar.x,
			self.scrollbar.y,
			self.scrollbar.w,
			self.scrollbar.h
		);
		gfx.Fill();

		gfx.BeginPath();
		fill.normal();
		gfx.Rect(self.scrollbar.x, y, 8, 32);
		gfx.Fill();
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self:setStats();

		self:handleNavigation(deltaTime);

		local y = 0;

		if (not self.cursor.y[self.viewLimit]) then
			for i = 1, self.viewLimit do
				self.cursor.y[i] = self.y + ((self.h.base + self.spacing) * (i - 1));
			end
		end

		gfx.Save();

		gfx.Translate(self.x, self.y);

		for i = self.bounds.lower, self.bounds.upper do
			y = y + self:drawScore(i, y, i == selectedScore);
		end

		gfx.Translate(-self.x, -self.y);

		self:drawCursor(deltaTime);

		if (#allScores > self.viewLimit) then
			self:drawScrollbar(deltaTime);
		end

		self:drawNavigation();

		gfx.Restore();
	end,
};

local screenshot = {
	labels = nil,
	path = '',
	timer = 0,

	setLabels = function(self)
		if (not self.labels) then
			font.normal();

			self.labels = {
				path = cacheLabel('', 24),
				saved = cacheLabel('SCREENSHOT SAVED TO', 24),
			};
		end
	end,

	drawNotification = function(self, deltaTime);
		self:setLabels();

		if (self.timer > 0) then
			self.timer = math.max(self.timer - deltaTime, 0);

			font.normal();
			self.labels.path:update({ new = self.path });

			gfx.Save();

			gfx.Translate(8, 4);

			gfx.BeginPath();
			align.left();
			
			self.labels.saved:draw({
				x = 0,
				y = 0,
				color = 'normal',
			});

			self.labels.path:draw({
				x = self.labels.saved.w + 16,
				y = 0,
				color = 'white',
			});

			gfx.Restore();
		end
	end,
};

result_set = function()
	singleplayer = result.uid == nil;

	if (not songInfo) then
		songInfo = help.formatSongInfo(result);

		if (result.jacketPath and (result.jacketPath ~= '')) then
			jacket = gfx.LoadImageJob(result.jacketPath, jacketFallback, 0, 0);
		end
	end

	if (not myScore) then
		myScore = help.formatScore(result);

		score = get(result, 'score', 0);
	end

	if (singleplayer) then
		if (#result.highScores > 0) then
			if (result.score > result.highScores[1].score) then
				upScore = result.score - result.highScores[1].score;
			end
		end

		for i, highScore in ipairs(result.highScores) do
			allScores[i] = help.formatHighScore(highScore);
		end
	else
		local currentIndex = result.displayIndex + 1;

		selectedScore = currentIndex;

		if (#result.highScores ~= #allScores) then
			allScores = {};
			loadedScores = {};

			if (scoreList.stats) then
				scoreList.stats = nil;
			end
		end

		if (not loadedScores[currentIndex]) then
			allScores[currentIndex] = help.formatScore(result);

			if (scoreList.stats) then
				font.number();

				scoreList.stats[currentIndex].early:update({
					new = allScores[currentIndex].early.value;
				});
				scoreList.stats[currentIndex].late:update({
					new = allScores[currentIndex].late.value;
				});
				scoreList.stats[currentIndex].maxChain:update({
					new = allScores[currentIndex].maxChain.value;
				});
			end

			loadedScores[currentIndex] = true;
		end

		if (#result.highScores ~= #loadedScores) then
			for i, highScore in ipairs(result.highScores) do
				if (not loadedScores[i]) then
					allScores[i] = help.formatScore(highScore);
				end
			end
		end
	end

	if (singleplayer or result.isSelf) then
		gaugeSamples = get(result, 'gaugeSamples', {});
		gaugeType = get(result, 'flags', 0);

		local duration = get(result, 'duration');

		if (duration) then
			graphs.duration = duration;
			graphs.hoverScale = math.max(duration / 10000, 5);
		else
			graphs.hoverScale = 10;
		end

		graphs.hitStats = get(result, 'noteHitStats');
		graphs.histogram = {};

		if (graphs.hitStats and (#graphs.hitStats > 0)) then
			for i = 1, #graphs.hitStats do
				local hitStat = graphs.hitStats[i];

				if ((hitStat.rating == 1) or (hitStat.rating == 2)) then
					if (not graphs.histogram[hitStat.delta]) then
						graphs.histogram[hitStat.delta] = 0;
					end

					graphs.histogram[hitStat.delta] = graphs.histogram[hitStat.delta] + 1;

					if (hitStat.delta < graphs.earliest) then
						graphs.earliest = hitStat.delta;
					end

					if (hitStat.delta > graphs.latest) then
						graphs.latest = hitStat.delta;
					end
				end
			end
		end
	end
end

render = function(deltaTime)
	setupLayout();

	mousePosX, mousePosY = game.GetMousePos();

	background:draw({
    x = 0,
    y = 0,
    w = scaledW,
    h = scaledH,
	});
	
	resultPanel:render(deltaTime);

	if (#allScores > 0) then
		scoreList:render(deltaTime);
	end

	graphs:render(deltaTime);

	screenshot:drawNotification(deltaTime);

	if (previousScore ~= selectedScore) then
		scoreList.cursor.flickerTimer = 0;

		previousScore = selectedScore;
	end
end

get_capture_rect = function()
	if (screenshotRegion == 'FULLSCREEN') then
		resX, resY = game.GetResolution();

		return 0, 0, resX, resY;
	elseif (screenshotRegion == 'PANEL') then
		return (resultPanel.panel.x * scalingFactor),
			(resultPanel.panel.y * scalingFactor),
			(resultPanel.panel.w * scalingFactor),
			(resultPanel.panel.h * scalingFactor);
	end
end

screenshot_captured = function(path)
	screenshot.timer = 5;
	screenshot.path = string.upper(path);
end