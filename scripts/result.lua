local CONSTANTS = require('constants/result');

local Cursor = require('common/cursor');
local List = require('common/list');
local ScoreNumber = require('common/scorenumber');
local Scrollbar = require('common/scrollbar');

local help = require('helpers/result');

local background = New.Image({ path = 'bg.png' });

local jacket = nil;
local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

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

local screenshotRegion = getSetting('screenshotRegion', 'PANEL');
local showHardScores = getSetting('showHardScores', false);

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
	colors = {
		critical = { 255, 235, 100 },
		near = { 255, 105, 255 },
		early = { 255, 105, 255 },
		late = { 105, 205, 255 },
		error = { 205, 0, 0 },
		maxChain = { 255, 235, 100 },
	},
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
					'hitWindows',
					'timestamp',
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
		image = New.Image({ path = 'common/panel_wide.png' }),
		maxWidth = 0,
		w = 0,
		h = 0,
		x = 0,
		y = 0,
	},
	score = ScoreNumber.New({
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

			self.panel.w = scaledW / (1920 / self.panel.image.w);
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
			self.labels = {
				btbbtc = New.Label({
					font = 'medium',
					text = '[BT-B]  +  [BT-C]',
					size = 20,
				}),
				f12 = New.Label({
					font = 'medium',
					text = '[F12]',
					size = 20,
				}),
				screenshot = New.Label({
					font = 'medium',
					text = 'SCREENSHOT',
					size = 20,
				}),
				songCollections = New.Label({
					font = 'medium',
					text = 'SONG COLLECTIONS',
					size = 20,
				}),
			};

			for key, name in pairs(CONSTANTS.song) do
				self.labels[key] = New.Label({
					font = 'medium',
					text = name,
					size = 18,
				});
			end

			for key, name in pairs(CONSTANTS.stats) do
				self.labels[key] = New.Label({
					font = 'medium',
					text = name,
					size = 18,
				});
			end

			if (upScore) then
				self.labels.plus = New.Label({
					font = 'number',
					text = '+',
					size = 30,
				});

				self.upScore = ScoreNumber.New({
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
				self.songInfo[key] = New.Label({
					font = value.font,
					text = value.value,
					size = value.size,
				});
			end
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			self.stats = {};

			for key, value in pairs(myScore) do
				if (key ~= 'score') then
					self.stats[key] = New.Label({
						font = value.font,
						text = value.value,
						size = value.size,
					});
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

	drawControls = function(self)
		drawLabel({
			x = self.panel.x,
			y = scaledH - (scaledH / 20) + (self.labels.btbbtc.h - 6),
			color = 'normal',
			label = self.labels.btbbtc,
		});

		drawLabel({
			x = self.panel.x + self.labels.btbbtc.w + 8,
			y = scaledH - (scaledH / 20) + (self.labels.btbbtc.h - 6) + 1,
			color = 'white',
			label = self.labels.songCollections,
		});

		drawLabel({
			x = self.panel.x + self.panel.w,
			y = scaledH - (scaledH / 20) + (self.labels.f12.h - 6) + 1,
			align = 'right',
			color = 'white',
			label = self.labels.screenshot,
		});

		drawLabel({
			x = self.panel.x + self.panel.w - self.labels.screenshot.w - 8,
			y = scaledH - (scaledH / 20) + (self.labels.f12.h - 6),
			align = 'right',
			color = 'normal',
			label = self.labels.f12,
		});
	end,

	drawSongInfo = function(self, deltaTime)
		local maxWidth = self.panel.maxWidth - (self.jacketSize + self.padding.x.full);
		local x = self.text.x[1];
		local y = self.padding.y.full - 5;

		gfx.Save();

		gfx.Translate(self.panel.x, self.panel.y);

		drawRectangle({
			x = self.padding.x.double,
			y = self.padding.y.full,
			w = self.jacketSize,
			h = self.jacketSize,
			image = jacket,
			stroke = { color = 'normal', size = 1 },
		});

		for _, name in ipairs(self.orders.song) do
			drawLabel({
				x = x,
				y = y,
				color = 'normal',
				label = self.labels[name]
			});

			if (name == 'difficulty') then
				drawLabel({
					x = self.panel.w - (self.padding.x.double * 3),
					y = y,
					color = 'normal',
					label = self.labels.bpm,
				});
			end

			y = y + (self.labels[name].h * 1.5);

			if (self.songInfo[name].w > maxWidth) then
				self.timers[name] = self.timers[name] + deltaTime;

				drawScrollingLabel({
					x = x,
					y = y,
					alpha = 255,
					color = 'white',
					label = self.songInfo[name],
					scale = scalingFactor,
					timer = self.timers[name],
					width = maxWidth,
				});
			else
				drawLabel({
					x = x,
					y = y,
					color = 'white',
					label = self.songInfo[name],
				});
			end
			
			if (name == 'difficulty') then
				drawLabel({
					x = x + self.songInfo[name].w + 8,
					y = y,
					color = 'white',
					label = self.songInfo.level,
				});
			end

			if (name ~= 'difficulty') then
				y = y + self.songInfo[name].h + (self.labels[name].h * 1.5);
			end
		end

		drawLabel({
			x = self.panel.w - (self.padding.x.double * 3),
			y = y,
			color = 'white',
			label = self.songInfo.bpm,
		});

		gfx.Restore();
	end,

	drawStats = function(self)
		local x = self.text.x[2] - 2;
		local y = self.text.y;

		self.score:setInfo({ value = score });

		gfx.Save();

		gfx.Translate(self.panel.x, self.panel.y);

		drawLabel({
			x = x,
			y = y,
			color = 'normal',
			label = self.labels.score,
		});

		if (upScore) then
			self.upScore:setInfo({ value = upScore });

			drawLabel({
				x = x + (self.score.position[5] * 1.1),
				y = y - 3,
				color = 'white',
				label = self.labels.plus,
			});

			self.upScore:draw({
				x = x + (self.score.position[5] * 1.2) + 5,
				y1 = y - 3,
				y2 = y + 3,
				offset = 4,
			});
		end

		drawLabel({
			x = self.panel.w 
				- (self.padding.x.full * 1.75)
				- 4
				- (((self.stats.name.w > self.labels.name.w) and self.stats.name.w)
					or self.labels.name.w
				),
			y = y,
			color = 'normal',
			label = self.labels.name,
		});

		drawLabel({
			x = self.panel.w - (self.padding.x.full * 1.75) - 4,
			y = y + (self.labels.name.h * 1.5),
			align = 'right',
			color = 'white',
			label = self.stats.name,
		});
		
		y = y + (self.labels.score.h * 0.5);

		self.score:draw({
			x = x - 5,
			y1 = y,
			y2 = y + (self.score.labels[5].h / 4) - 3,
			offset = 10,
		});

		y = y + (self.score.labels[1].h * 1.0625);

		local statX = x;
		local statY = y + (self.labels.grade.h * 1.5);
		local spacing = self:getSpacing(self.orders.stat.row[1]);

		for i, name in ipairs(self.orders.stat.row[1]) do
			local overflow = 0;

			if (name == 'timestamp') then
				overflow = self.stats[name].w - self.labels[name].w - 3;
			end

			drawLabel({
				x = statX - overflow,
				y = y,
				color = 'normal',
				label = self.labels[name],
			});

			drawLabel({
				x = statX - overflow,
				y = statY,
				color = 'white',
				label = self.stats[name],
			});

			statX = statX + self.labels[name].w + spacing;
		end

		y = y + (self.labels.grade.h * 2) + (self.stats.grade.h * 2);

		statX = x;
		statY = y + (self.labels.critical.h * 1.5);
		spacing = self:getSpacing(self.orders.stat.row[2]);

		for _, name in ipairs(self.orders.stat.row[2]) do
			drawLabel({
				x = statX,
				y = y,
				color = 'normal',
				label = self.labels[name],
			});

			drawRectangle({
				x = statX - 8,
				y = y + 5,
				w = 4,
				h = 13,
				color = self.colors[name],
			});

			drawLabel({
				x = statX + 1,
				y = statY,
				color = 'white',
				label = self.stats[name],
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

		drawImage({
			x = self.panel.x,
			y = self.panel.y,
			w = self.panel.w,
			h = self.panel.h,
			alpha = 0.5,
			image = self.panel.image,
		});

		self:drawSongInfo(deltaTime);

		self:drawStats();

		self:drawControls();

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
			self.labels = {
				decrease = New.Label({
					font = 'medium',
					text = 'DECREASE CURRENT SONG OFFSET BY',
					size = 18,
				}),
				earliest = New.Label({
					font = 'medium',
					text = 'EARLIEST',
					size = 18,
				}),
				increase = New.Label({
					font = 'medium',
					text = 'INCREASE CURRENT SONG OFFSET BY',
					size = 18,
				}),
				latest = New.Label({
					font = 'medium',
					text = 'LATEST',
					size = 18,
				}),
				mean = New.Label({
					font = 'medium',
					text = 'MEAN',
					size = 18,
				}),
				median = New.Label({
					font = 'medium',
					text = 'MEDIAN',
					size = 18,
				}),
				offset = New.Label({
					font = 'medium',
					text = '0',
					size = 18,
				}),
			};
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			self.stats = {
				currentGauge = New.Label({
					font = 'number',
					text = '0',
					size = 18,
				}),
				earliest = New.Label({
					font = 'number',
					text = string.format('%.1f ms', self.earliest),
					size = 18,
				}),
				latest = New.Label({
					font = 'number',
					text = string.format('%.1f ms', self.latest),
					size = 18,
				}),
			};

			for _, name in ipairs(self.statOrder) do
				local value = myScore[name];

				if (value.raw) then
					self.stats.rawMedian = value.raw;
				end

				self.stats[name] = New.Label({
					font = value.font,
					text = value.value,
					size = value.size,
				});
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

		if (gaugeType == 1) then
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
		local y = self.y + self.h + 4;
		local spacing = (self.w.total / 2)
			- self.labels.mean.w
			- self.labels.median.w;

		drawLabel({
			x = x,
			y = y,
			color = 'normal',
			label = self.labels.mean,
		});

		drawLabel({
			x = x + self.labels.mean.w + 16,
			y = y,
			color = 'white',
			label = self.stats.meanDelta,
		});

		x = self.x + self.w.total;

		drawLabel({
			x = x - 4,
			y = y,
			align = 'right',
			color = 'white',
			label = self.stats.medianDelta,
		});

		drawLabel({
			x = x - 4 - self.stats.medianDelta.w - 16,
			y = y,
			align = 'right',
			color = 'normal',
			label = self.labels.median,
		});

		if (self.stats.rawMedian
			and (math.abs(math.floor(self.stats.rawMedian)) > 1)
		) then
				self.labels.offset:update({ new = string.format(
					'%d ms',
					math.abs(math.floor(self.stats.rawMedian))
				)});

				drawLabel({
					x = x - 4,
					y = y + (self.labels.median.h * 1.35),
					align = 'right',
					color = 'white',
					label = self.labels.offset,
				});

				if (self.stats.rawMedian > 0) then
					drawLabel({
						x = x - 4 - self.labels.offset.w - 6,
						y = y + (self.labels.median.h * 1.35),
						align = 'right',
						color = 'red',
						label = self.labels.increase,
					});
				elseif (self.stats.rawMedian < 0) then
					drawLabel({
						x = x - 4 - self.labels.offset.w - 6,
						y = y + (self.labels.median.h * 1.35),
						align = 'right',
						color = 'red',
						label = self.labels.decrease,
					});
				end
		end
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

		drawLabel({
			x = self.x,
			y = self.y + self.h + 12,
			color = 'white',
			label = resultPanel.songInfo.duration,
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

				self.stats.currentGauge:update({
					new = string.format('%d%%', math.floor(samples[gaugeIndex] * 100))
				});

				gfx.BeginPath();
				setFill('white', 150);
				gfx.Circle(mouseX, y + gaugeY + 2, 4);
				gfx.Fill();

				drawLabel({
					x = mouseX + 8,
					y = y + gaugeY - 12,
					color = 'white',
					label = self.stats.currentGauge,
				});
			end

			drawLabel({
				x = x + 4,
				y = y,
				color = 'white',
				label = self.stats.gauge,
			});
		end
	end,

	drawRightGraph = function(self, x, y, w, h)
		if (not self.hitStats) then return end

		self:drawHistogram(x, y, w, h);

		drawLabel({
			x = x + 6,
			y = y,
			color = 'normal',
			label = self.labels.earliest,
		});

		drawLabel({
			x = x + 6,
			y = y + h - self.labels.latest.h - 6,
			color = 'normal',
			label = self.labels.latest,
		});

		drawLabel({
			x = x + w - 4,
			y = y,
			align = 'right',
			color = 'white',
			label = self.stats.earliest,
		});

		drawLabel({
			x = x + w - 4,
			y = y + h - self.labels.latest.h - 6,
			align = 'right',
			color = 'white',
			label = self.stats.latest,
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

		drawRectangle({
			x = self.x,
			y = self.y,
			w = self.w.total,
			h = self.h,
			alpha = 120,
			color = 'dark',
		});

		self:drawGraphLines(self.x, self.y, self.w.total, self.h);

		self:drawLeftGraph(self.x, self.y, self.w.left, self.h);

		self:drawRightGraph(self.x + self.w.left, self.y, self.w.right, self.h);

		self:drawStats();

		gfx.Restore();
	end
};

local scoreList = {
	cache = { scaledW = 0, scaledH = 0 },
	currentPage = 1,
	cursor = Cursor.New(),
	labels = nil,
	list = {
		maxWidth = 0,
		margin = 0,
		padding = { x = 0, y = 0 },
		timer = 1,
		w = 0,
		h = {
			base = 0,
			item = {
				collapsed = 0,
				difference = 0,
				expanded = 0,
			},
		},
		x = 0,
		y = {
			base = 0,
			current = 0,
			previous = 0,
		},
	},
	orders = {
		sp = {
			row = {
				{
					'grade',
					'clear',
					'hitWindows',
					'timestamp',
				},
				{
					'gauge',
					'critical',
					'near',
					'error',
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
	pressed = { FXL = false, FXR = false },
	scrollbar = Scrollbar.New(),
	selectedScore = 0,
	stats = nil,
	viewLimit = 4,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.list.x = (scaledW / 20) + resultPanel.panel.w + (scaledW / 40);
			self.list.y.base = (scaledH / 20);

			self.list.w = scaledW
				- (scaledW / 10)
				- resultPanel.panel.w 
				- (scaledW / 40);
			self.list.h.base = scaledH - (scaledH / 10);
			self.list.h.item.collapsed = scaledH // 7;
			self.list.h.item.expanded = self.list.h.item.collapsed * 2.125;
			self.list.h.item.difference = self.list.h.item.expanded
				- self.list.h.item.collapsed;

			local remainingHeight = self.list.h.base
				- ((self.list.h.item.collapsed) * (self.viewLimit - 1))
				- self.list.h.item.expanded;

			self.list.margin = remainingHeight / (self.viewLimit - 1);

			self.list.padding.x = self.list.w / 20;
			self.list.padding.y = self.list.h.item.collapsed / 7.5;

			self.list.maxWidth = self.list.w - (self.list.padding.x * 2);

			self.cursor:setSizes({
				x = self.list.x,
				y = self.list.y.base,
				w = self.list.w,
				h = self.list.h.item.expanded,
				margin = self.list.margin,
			});

			if (#allScores > self.viewLimit) then
				self.scrollbar:setSizes({
					screenW = scaledW,
					y = self.list.y.base,
					h = self.list.h.base,
				});
			end

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {
				fxlfxr = New.Label({
					font = 'medium',
					text = '[FX-L]  /  [FX-R]',
					size = 20,
				}),
				selectScore = New.Label({
					font = 'medium',
					text = 'SELECT SCORE',
					size = 20,
				}),
			};

			for key, name in pairs(CONSTANTS.stats) do
				self.labels[key] = New.Label({
					font = 'medium',
					text = name,
					size = 18,
				});
			end
		end
	end,

	setStats = function(self)
		if (not self.stats) then
			self.stats = {};

			for i, score in ipairs(allScores) do
				self.stats[i] = {
					place = New.Label({
						font = 'number',
						text = i,
						size = 90,
					}),
				};

				for key, value in pairs(score) do
					if (key == 'score') then
						self.stats[i].score = ScoreNumber.New({
							isScore = true,
							sizes = { 90, 72 },
						});
					else
						self.stats[i][key] = New.Label({
							font = value.font,
							text = value.value,
							size = value.size,
						});
					end
				end
			end
		end
	end,

	getSpacing = function(self, order, scale)
		local totalWidth = 0;

		for _, name in ipairs(order) do
			totalWidth = totalWidth + self.labels[name].w;
		end

		return ((self.list.maxWidth * scale) - totalWidth) / (#order - 1);
	end,

	drawControls = function(self)
		local x = self.list.x;
		local y = scaledH - (scaledH / 20) + (self.labels.fxlfxr.h - 6);

		drawLabel({
			x = x,
			y = y,
			color = 'normal',
			label = self.labels.fxlfxr,
		});

		drawLabel({
			x = x + self.labels.fxlfxr.w + 8,
			y = y + 1,
			color = 'white',
			label = self.labels.selectScore,
		});
	end,

	drawScoreList = function(self, deltaTime)
		if (self.list.timer < 1) then
			self.list.timer = math.min(self.list.timer + (deltaTime * 4), 1);
		end

		local change = (self.list.y.current - self.list.y.previous)
			* smoothstep(self.list.timer);
		local offset = self.list.y.previous + change;
		local y = 0;

		self.list.y.previous = offset;

		gfx.Save();

		gfx.Translate(self.list.x, self.list.y.base + offset);

		for i = 1, #allScores do
			local isSelected = i == selectedScore;

			y = y + self:drawScore(i, y, isSelected);
		end

		gfx.Restore();
	end,

	drawScore = function(self, i, initialY, isSelected)
		local isVisible = List.isVisible(i, self.viewLimit, self.currentPage);
		local h = (isSelected and self.list.h.item.expanded)
			or self.list.h.item.collapsed;
		local x = self.list.padding.x;
		local y = initialY + self.list.padding.y;

		if (isVisible) then
			self.stats[i].score:setInfo({ value = allScores[i].score });

			drawRectangle({
				x = 0,
				y = initialY,
				w = self.list.w,
				h = h,
				alpha = 120,
				color = 'dark',
			});

			drawLabel({
				x = self.list.w - self.list.padding.x + 8,
				y = y - 1,
				alpha = 40,
				align = 'right',
				color = 'normal',
				label = self.stats[i].place,
			});

			drawLabel({
				x = x + 1,
				y = y,
				color = 'normal',
				label = self.labels.score,
			});
		
			if (isSelected) then
				y = y + (self.labels.score.h * 0.75);
			else
				x = self.stats[i].score.position[8] + 144;

				drawLabel({
					x = x,
					y = y,
					color = 'normal',
					label = self.labels.clear,
				});

				y = y + (self.labels.score.h * 0.75);

				drawLabel({
					x = x,
					y = y + 8,
					color = 'white',
					label = self.stats[i].clear,
				});

				if (singleplayer) then
					drawLabel({
						x = x,
						y = y + (self.labels.score.h * 2.5) + 2,
						color = 'normal',
						label = self.labels.timestamp,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.score.h * 3.75) + 2,
						color = 'white',
						label = self.stats[i].timestamp,
					});
				else
					drawLabel({
						x = x,
						y = y + (self.labels.score.h * 2.5) + 2,
						color = 'normal',
						label = self.labels.name,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.score.h * 3.75) + 2,
						color = 'white',
						label = self.stats[i].name,
					});
				end
			end

			x = self.list.padding.x;

			self.stats[i].score:draw({
				x = x - 3,
				y1 = y,
				y2 = y + (self.stats[i].score.labels[1].h * 0.125) + 5,
				offset = 10,
			});

			if (isSelected) then
				y = y + self.stats[i].score.labels[1].h * 1.125;

				if (singleplayer) then
					local statX = x;
					local statY = y + (self.labels.timestamp.h * 1.5);
					local spacing = self:getSpacing(self.orders.sp.row[1], 1);

					for _, name in ipairs(self.orders.sp.row[1]) do
						local overflow = 0;

						if (name == 'timestamp') then
							overflow = self.stats[i].timestamp.w - self.labels.timestamp.w;
						end

						drawLabel({
							x = statX - overflow,
							y = y,
							color = 'normal',
							label = self.labels[name],
						});

						drawLabel({
							x = statX - overflow,
							y = statY,
							color = 'white',
							label = self.stats[i][name],
						});

						statX = statX + self.labels[name].w + spacing;
					end

					y = y + (self.labels.timestamp.h * 2) + (self.stats[i].timestamp.h * 2);

					statX = x;
					statY = y + (self.labels.critical.h * 1.5);
					spacing = self:getSpacing(self.orders.sp.row[2], 0.9375);

					for _, name in ipairs(self.orders.sp.row[2]) do
						drawLabel({
							x = statX,
							y = y,
							color = 'normal',
							label = self.labels[name],
						});

						drawLabel({
							x = statX,
							y = statY,
							color = 'white',
							label = self.stats[i][name],
						});

						statX = statX + self.labels[name].w + spacing;
					end
				else
					drawLabel({
						x = x,
						y = y,
						color = 'normal',
						label = self.labels.name,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.name.h * 1.5),
						color = 'white',
						label = self.stats[i].name,
					});

					x = x + (self.labels.name.w * 3.5) + 1;

					drawLabel({
						x = x,
						y = y,
						color = 'normal',
						label = self.labels.grade,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.grade.h * 1.5),
						color = 'white',
						label = self.stats[i].grade,
					});

					x = x + (self.labels.grade.w * 1.825) + 2;

					drawLabel({
						x = x,
						y = y,
						color = 'normal',
						label = self.labels.gauge,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.gauge.h * 1.5),
						color = 'white',
						label = self.stats[i].gauge,
					});

					x = x + (self.labels.gauge.w * 2);

					drawLabel({
						x = x,
						y = y,
						color = 'normal',
						label = self.labels.clear,
					});

					drawLabel({
						x = x,
						y = y + (self.labels.clear.h * 1.5),
						color = 'white',
						label = self.stats[i].clear,
					});

					y = y + (self.labels.name.h * 2) + (self.stats[i].name.h * 2);

					local statX = self.list.padding.x;
					local statY = y + (self.labels.critical.h * 1.5);
					local spacing = self:getSpacing(self.orders.mp.row[1], 1);

					for _, name in ipairs(self.orders.mp.row[1]) do
						drawLabel({
							x = statX,
							y = y,
							color = 'normal',
							label = self.labels[name],
						});

						if (self.stats[i][name]) then
							drawLabel({
								x = statX,
								y = statY,
								color = 'white',
								label = self.stats[i][name],
							});
						end

						statX = statX + self.labels[name].w + spacing;
					end
				end
			end
		end

		return h + self.list.margin;
	end,

	handleChange = function(self)
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

		if (self.selectedScore ~= selectedScore) then
			self.selectedScore = selectedScore;
		
			self.currentPage = List.getCurrentPage({
				current = self.selectedScore,
				limit = self.viewLimit,
				total = #allScores,
			});

			self.list.y.current = (self.list.h.base
				- self.list.h.item.difference
				+ self.list.margin
			) * (self.currentPage - 1);
			self.list.y.current = -self.list.y.current;

			self.list.timer = 0;

			self.cursor:setPosition({
				current = self.selectedScore,
				height = self.list.h.item.collapsed,
				total = self.viewLimit,
				vertical = true,
			});

			self.cursor.timer.flicker = 0;

			self.scrollbar:setPosition({
				current = self.selectedScore,
				total = #allScores,
			});
		end
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self:setStats();

		gfx.Save();

		self:drawScoreList(deltaTime);

		self.cursor:render(deltaTime, {
			size = 20,
			stroke = 2,
			vertical = true,
		});

		if (#allScores > self.viewLimit) then
			self.scrollbar:render(deltaTime);
		end

		self:drawControls();

		self:handleChange();

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
				}),
				saved = New.Label({
					font = 'normal',
					text = 'SCREENSHOT SAVED TO',
					size = 24,
				}),
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

local filterHighScores = function(highScores)
	local newScores = {};

	for _, highScore in ipairs(highScores) do
		if (get(highScore, 'hitWindow.perfect', 46) < 46) then
			newScores[#newScores + 1] = highScore;
		end
	end

	return newScores;
end

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
		if (showHardScores) then
			result.highScores = filterHighScores(result.highScores);
		end

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
		gaugeType = get(result, 'gauge_type', get(result, 'flags', 0));

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

	drawImage({
    x = 0,
    y = 0,
    w = scaledW,
    h = scaledH,
		image = background,
	});
	
	resultPanel:render(deltaTime);

	if (#allScores > 0) then
		scoreList:render(deltaTime);
	end

	graphs:render(deltaTime);

	screenshot:drawNotification(deltaTime);
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