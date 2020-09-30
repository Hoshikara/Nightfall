local CONSTANTS = require('constants/gameplay');

local detail = require('gameplay/detail');
local hitAnimation = require('gameplay/hitanimation');
local hitError = require('gameplay/hiterror');
local laserAnimation = require('gameplay/laseranimation');

hitAnimation:initializeAll();
hitError:initializeAll();
laserAnimation:initializeAll();

if (not introTimer) then
	introTimer = 2;
	outroTimer = 0;
end

local clearStates = nil;

do
	if (not clearStates) then
		font.normal();

		clearStates = {};

		for i, clearState in ipairs(CONSTANTS.clearStates) do
			clearStates[i] = cacheLabel(clearState, 60);
		end
	end
end

local critLineBar = cacheImage('gameplay/crit_bar/crit_bar.png');

local difficulties = nil;

do
	if (not difficulties) then
		font.medium();

		difficulties = {};

		for i, difficulty in ipairs(CONSTANTS.difficulties) do
			difficulties[i] = cacheLabel(difficulty, 18);
		end

		font.number();

		difficulties.level = cacheLabel('', 18);
	end
end

local earlatePosition = game.GetSkinSetting('earlatePosition') or 'BOTTOM';

setEarlatePosition = function()
	if (earlatePosition == 'OFF') then
		earlatePosition = 'BOTTOM';
	elseif (earlatePosition == 'BOTTOM') then
		earlatePosition = 'MIDDLE';
	elseif (earlatePosition == 'MIDDLE') then
		earlatePosition = 'UPPER';
	elseif (earlatePosition == 'UPPER') then
		earlatePosition = 'UPPER+';
	elseif (earlatePosition == 'UPPER+') then
		earlatePosition = 'OFF';
	end

	game.SetSkinSetting('earlatePosition', earlatePosition);
end

local laser = {
	fill = gfx.CreateSkinImage('gameplay/laser_cursor/pointer_fill.png', 0),
	overlay = gfx.CreateSkinImage('gameplay/laser_cursor/pointer_overlay.png', 0),
};

local showAdjustments = true;

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
end

setupCritTransform = function()
	gfx.ResetTransform();
	
	gfx.Translate(gameplay.critLine.x, gameplay.critLine.y);
	gfx.Rotate(-gameplay.critLine.rotation);
end

render_crit_base = function(deltaTime)
	setupLayout();

	setupCritTransform();

	local x = gameplay.critLine.xOffset * 10;

	gfx.Translate(x, 0);

	local height = 14 * scalingFactor;
	local length = (scaledW * 0.9) * scalingFactor;

	gfx.BeginPath();
	fill.black(200);
	gfx.Rect(-scaledW, height / 2, scaledW * 2, scaledH);
	gfx.Fill();

	critLineBar:draw({
		x = 0,
		y = 0,
		w = length,
		h = height,
		blendOp = gfx.BLEND_OP_LIGHTER,
		centered = true,
	});
	critLineBar:draw({
		x = 0,
		y = 0,
		w = length,
		h = height,
		a = 0.5,
		blendOp = gfx.BLEND_OP_SOURCE_OVER,
		centered = true,
	});

	gfx.ResetTransform();
end

render_crit_overlay = function(deltaTime)
	hitAnimation:render(deltaTime, scalingFactor);

	setupCritTransform();

	local w, h = gfx.ImageSize(laser.fill);
	local width = 56 * scalingFactor;
	local height = width * (h / w);

	for i = 1, 2 do
		local currentCursor = gameplay.critLine.cursors[i - 1];
		local cursorPos = currentCursor.pos;
		local cursorSkew = currentCursor.skew;
		local r, g, b = game.GetLaserColor(i - 1);

		laserAnimation:render(deltaTime, i, cursorPos, scalingFactor, cursorSkew);

		gfx.SkewX(cursorSkew);

		gfx.BeginPath();
		gfx.SetImageTint(r, g, b);
		gfx.ImageRect(cursorPos - (width / 2), -(height / 2), width, height, laser.fill, currentCursor.alpha, 0);
		gfx.SetImageTint(255, 255, 255);

		gfx.BeginPath();
		gfx.ImageRect(cursorPos - (width / 2), -(height / 2), width, height, laser.overlay, currentCursor.alpha, 0);
		
		gfx.SkewX(-cursorSkew);
	end

	gfx.ResetTransform();
end

button_hit = function(button, rating, delta)
	hitAnimation:queueHit(button, rating);
	hitError:queueHit(button, rating, delta);
end

local alerts = {
	alpha = { 0, 0 },
	labels = nil,
	timers = {
		[1] = -2,
		[2] = -2,
		fade = { 0, 0 },
		pulse = { 0, 0 },
		start = { false, false },
	},

	drawAlerts = function(self, deltaTime)
		if (not self.labels) then
			font.normal();

			self.labels = {
				[1] = cacheLabel('L', 120),
				[2] = cacheLabel('R', 120),
			};

			self.labels.y = -(self.labels[1].h / 5.5);

			self.colors = {
				r = {},
				g = {},
				b = {},
			};

			for i = 1, 2 do
				self.colors.r[i],
				self.colors.g[i],
				self.colors.b[i] = game.GetLaserColor(i - 1);
			end
		end

		local y = {
			(scaledH * 0.95) - (scaledH / 6),
			0,
		};
		local x = {
			(scaledW / 2) - (scaledW / 3.75),
			(scaledW / 3.75) * 2,
		};

		for i = 1, 2 do
			self.timers[i] = math.max(self.timers[i] - deltaTime, -2);

			if (self.timers[i] > 0) then
				self.timers.start[i] = true;
			end

			if (self.timers.start[i]) then
				self.timers.fade[i] = math.min(self.timers.fade[i] + (deltaTime * 7), 1);
				self.timers.pulse[i] = self.timers.pulse[i] + deltaTime;
				self.alpha[i] = math.abs(0.8 * math.cos(self.timers.pulse[i] * 10)) + 0.2;
			end

			if (self.timers[i] == -2) then
				self.timers.start[i] = false;
			
				self.timers.fade[i] = math.max(self.timers.fade[i] - (deltaTime * 6), 0);
				self.timers.pulse[i] = self.timers.pulse[i] - deltaTime;
				self.alpha[i] = 1;
			end
		end

		gfx.Save();

		for i = 1, 2 do
			gfx.Translate(x[i], y[i]);

			local alpha = math.floor(255 * self.alpha[i]);

			gfx.Scissor(-64, -64, 128, 128 * self.timers.fade[i]);

			gfx.BeginPath();
			align.middle();

			gfx.FillColor(self.colors.r[i], self.colors.g[i], self.colors.b[i], alpha);
			self.labels[i]:draw({
				x = 0,
				y = self.labels.y,
				override = true,
			});

			fill.white(70 * self.alpha[i]);
			self.labels[i]:draw({
				x = 0,
				y = self.labels.y,
				override = true,
			});

			gfx.ResetScissor();

			detail:drawAlertDetail(
				-64 * self.timers.fade[i],
				-64 * self.timers.fade[i],
				128 * self.timers.fade[i],
				128 * self.timers.fade[i],
				12,
				math.floor(255 * self.timers.fade[i])
			);
		end

		gfx.Restore();
	end,
};

local combo = {
	alpha = 0,
	burst = false,
	burstValue = 100,
	current = 0,
	labels = nil,
	max = 0,
	scale = 1,
	timer = 0,

	drawCombo = function(self, deltaTime)
		if (self.current == 0) then return end
	
		local x = scaledW / 2;
		local y = (scaledH * 0.95) - (scaledH / 6);
	
		if (not self.labels) then
			self.labels = {
				burst = {},
			};
	
			font.number();
	
			for i = 1, 4 do
				self.labels[i] = cacheLabel('0', 64);
				self.labels.burst[i] = cacheLabel('0', 64);
			end
	
			local w = self.labels[1].w * 0.85;
	
			self.x = {
				x - (w * 2),
				x - (w * 0.675),
				x + (w * 0.675),
				x + (w * 2),
			};
	
			font.medium();
		
			self.labels.chain = cacheLabel('CHAIN', 22);
		end
	
		self.timer = math.max(self.timer - deltaTime, 0);
	
		if ((self.timer == 0) and (not game.GetButton(game.BUTTON_STA))) then return end
	
		local alpha = {
			((self.current >= 1000) and 255) or 50,
			((self.current >= 100) and 255) or 50,
			((self.current >= 10) and 255) or 50,
			255,
		}
		local digits = {
			math.floor(self.current / 1000) % 10,
			math.floor(self.current / 100) % 10,
			math.floor(self.current / 10) % 10,
			self.current % 10,
		};
	
		font.number();
	
		if ((gameplay.comboState == 2) or (gameplay.comboState == 1)) then
			gfx.BeginPath();
			align.middle();

			gfx.FillColor(4, 8, 12, 125);
			self.labels.chain:draw({
				x = x + 1,
				y = y - (self.labels.chain.h * 2.25) + 1,
				override = true,
			});
	
			gfx.FillColor(255, 235, 100, 255);
			self.labels.chain:draw({
				x = x,
				y = y - (self.labels.chain.h * 2.25),
				override = true,
			});
	
			for i = 1, 4 do
				self.labels[i]:update({ new = digits[i] });

				gfx.FillColor(4, 8, 12, math.floor(alpha[i] * 0.5));
				self.labels[i]:draw({
					x = self.x[i] + 1,
					y = y + 1,
					override = true,
				});
	
				gfx.FillColor(255, 235, 100, alpha[i]);
				self.labels[i]:draw({
					x = self.x[i],
					y = y,
					override = true,
				});
			end
	
			if (self.current >= self.burstValue) then
				self.burstValue = self.burstValue + 100;
		
				if (not self.burst) then
					self.alpha = 1;
				end
		
				self.burst = true;
			end
		
			if (self.current < 100) then
				self.burstValue = 100;
			end
		
			if (self.burst and (self.scale < 3)) then
				self.alpha = math.max(self.alpha - (deltaTime * 5), 0);
				self.scale = self.scale + (deltaTime * 6);
			else
				self.alpha = 0;
				self.scale = 1;
				self.burst = false;
			end
	
			gfx.FillColor(255, 235, 100, math.floor(255 * self.alpha));
	
			for i = 1, 4 do
				self.labels.burst[i]:update({
					new = digits[i],
					size = math.floor(64 * self.scale),
				});
	
				self.labels.burst[i]:draw({
					x = self.x[i],
					y = y,
					override = true,
				});
			end
		else
			gfx.BeginPath();
			align.middle();

			gfx.FillColor(4, 8, 12, 125);
			self.labels.chain:draw({
				x = x + 1,
				y = y - (self.labels.chain.h * 2.5) + 1,
				override = true,
			});

			gfx.FillColor(235, 235, 235, 255);
			self.labels.chain:draw({
				x = x,
				y = y - (self.labels.chain.h * 2.5),
				override = true,
			});
	
			for i = 1, 4 do
				self.labels[i]:update({ new = digits[i] });

				gfx.FillColor(4, 8, 12, math.floor(alpha[i] * 0.5));
				self.labels[i]:draw({
					x = self.x[i] + 1,
					y = y + 1,
					override = true,
				});
	
				gfx.FillColor(235, 235, 235, alpha[i]);
				self.labels[i]:draw({
					x = self.x[i],
					y = y,
					override = true,
				});
			end
		end
	end,
};

local earlate = {
	alpha = 0,
	alphaTimer = 0,
	isLate = false,
	labels = nil,
	timer = 0,

	setLabels = function(self)
		if (not self.labels) then
			font.normal();

			self.labels = {
				early = cacheLabel('EARLY', 36),
				late = cacheLabel('LATE', 36),
			};
		end
	end,

	drawEarlate = function(self, deltaTime)
		self:setLabels();

		if (earlatePosition == 'OFF') then return end

		self.timer = math.max(self.timer - deltaTime, 0);

		if (self.timer == 0) then return end

		self.alphaTimer = self.alphaTimer + deltaTime;

		self.alpha = math.floor(self.alphaTimer * 30) % 2;
		self.alpha = ((self.alpha * 175) + 80) / 255;

		local x = scaledW / 2;
		local y = scaledH - (scaledH / 3.35);

		if (earlatePosition == 'BOTTOM') then
			y = scaledH - (scaledH / 3.35);
		elseif (earlatePosition == 'MIDDLE') then
			y = scaledH - (scaledH / 1.85);
		elseif (earlatePosition == 'UPPER') then
			y = scaledH - (scaledH / 1.35);
		elseif (earlatePosition == 'UPPER+') then
			y = scaledH - (scaledH / 1.15);
		end

		gfx.Save();

		gfx.Translate(x, y);

		gfx.BeginPath();
		align.middle();

		if (self.isLate) then
			gfx.FillColor(150, 150, 150, 100);
			self.labels.late:draw({
				x = 0,
				y = 2,
				override = true,
			});
			gfx.FillColor(105, 205, 255, math.floor(255 * self['alpha']));
			self.labels.late:draw({
				x = 0,
				y = 0,
				override = true,
			});
		else
			gfx.FillColor(150, 150, 150, 100);
			self.labels.early:draw({
				x = 0,
				y = 2,
				override = true,
			});
			gfx.FillColor(255, 105, 255, math.floor(255 * self['alpha']));
			self.labels.early:draw({
				x = 0,
				y = 0,
				override = true,
			});
		end

		gfx.Restore();
	end,
};

local gauge = {
	alpha = 0,
	labels = nil,
	timer = 0,

	setLabels = function(self)
		if (not self.labels) then
			font.normal();

			self.labels = {
				effective = cacheLabel('EFFECTIVE RATE', 24),
				excessive = cacheLabel('EXCESSIVE RATE', 24),
			};

			font.number();
			self.labels.percentage = cacheLabel('0', 24);

			self.labels.h = self.labels.effective.h;
		end
	end,
	
	drawGauge = function(self, deltaTime)
		self:setLabels();

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local height = scaledH / 2;
		local x = scaledW - (scaledW / 6.5);
		local y = scaledH / 3.5;
		local format = ((gameplay.gauge < 0.1) and '%02d%%') or '%d%%';

		self.timer = self.timer + deltaTime;

		self.alpha = math.abs(1 * math.cos(self.timer * 2));

		font.number();
		self.labels.percentage:update({
			new = string.format(format, math.floor(gameplay.gauge * 100))
		});

		gfx.Save();

		gfx.Translate(x, y - ((scaledH / 8) * (introShift ^ 4)));

		gfx.BeginPath();

		if (gameplay.gaugeType == 0) then
			if (gameplay.gauge < 0.7) then
				gfx.FillColor(25, 125, 225, 255);
			else
				gfx.FillColor(225, 25, 155, 255);
			end
		else
			if (gameplay.gauge < 0.3) then
				gfx.FillColor(225, 25, 25, 255);
			else
				gfx.FillColor(225, 105, 25, introAlpha);
			end
		end

		gfx.Rect(0, height, 18, -(height * gameplay.gauge));
		gfx.Fill();

		gfx.BeginPath();
		fill.white((introAlpha / 5) * self.alpha)
		gfx.Rect(0, height, 18, -(height * gameplay.gauge));
		gfx.Fill();

		gfx.BeginPath();
		gfx.StrokeWidth(2);
		gfx.FillColor(0, 0, 0, 0);
		gfx.StrokeColor(255, 255, 255, introAlpha);
		gfx.Rect(0, 0, 18, height);
		gfx.Fill();
		gfx.Stroke();

		gfx.BeginPath();
		fill.white(introAlpha);

		if (gameplay.gaugeType == 0) then
			gfx.Rect(0, height * 0.3, 18, 3);
		else
			gfx.Rect(0, height * 0.7, 18, 3);
		end
		
		gfx.Fill();

		gfx.BeginPath();
		align.right();
		self.labels.percentage:draw({
			x = -6,
			y = height - (height * gameplay.gauge) - 14,
			a = introAlpha,
			color = 'white',

		});

		gfx.BeginPath();
		gfx.Rotate(90);

		if (gameplay.gaugeType == 0) then
			align.right();
			self.labels.effective:draw({
				x = height + 3,
				y = -self.labels.h - 26,
				a = introAlpha,
				color = 'white',
			});
		else
			align.left();
			self.labels.excessive:draw({
				x = -4,
				y = -self.labels.h - 26,
				a = introAlpha,
				color = 'white',
			});
		end

		gfx.Rotate(-90);

		gfx.Restore();
	end
};

local practice = {
	counts = { passes = 0, plays = 0 },
	labels = nil,
	practicing = false,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				hitDelta = {
					label = cacheLabel('MEAN HIT DELTA', 18)
				},
				miss = {
					label = cacheLabel('MISS', 18)
				},
				mission = {
					label = cacheLabel('MISSION', 24),
					description = cacheLabel('', 24)
				},
				near = {
					label = cacheLabel('NEAR', 18)
				},
				passRate = {
					label = cacheLabel('PASS RATE', 24)
				},
				previousRun = cacheLabel('PREVIOUS PLAY', 24),
				score = {
					label = cacheLabel('SCORE', 18)
				},
			};

			font.normal();

			self.labels.practiceMode = cacheLabel('PRACTICE MODE', 36);

			font.number();

			self.labels.hitDelta.plusMinus = cacheLabel('±', 24)
			self.labels.hitDelta.mean = cacheLabel('0', 24);
			self.labels.hitDelta.meanAbs = cacheLabel('0', 24);
			self.labels.miss.value = cacheLabel('0', 24);
			self.labels.near.value = cacheLabel('0', 24);
			self.labels.passRate.ratio = cacheLabel('0', 24);
			self.labels.passRate.value = cacheLabel('0', 24);
			self.labels.score.values = {
				cacheLabel('0', 46),
				cacheLabel('0', 36),
			};
		end
	end,

	drawPracticeInfo = function(self)
		self:setLabels();

		gfx.BeginPath();
		align.middle();
		self.labels.practiceMode:draw({
			x = scaledW / 2,
			y = scaledH / 60,
			color = 'white',
		});

		if (not self.practicing) then return end

		local y = 0;

		gfx.Save();

		gfx.Translate(scaledW / 100, scaledH / 3);

		gfx.BeginPath();
		align.left();

		self.labels.mission.label:draw({
			x = 0,
			y = y,
			color = 'normal',
		});

		y = y + self.labels.mission.label.h * 1.4;

		self.labels.mission.description:draw({
			x = 0,
			y = y,
			color = 'white',
			maxWidth = scaledW / 4,
		});

		if (self.counts.plays > 0) then
			y = y + (self.labels.mission.description.h * 3);

			self.labels.previousRun:draw({
				x = 1,
				y = y,
				color = 'normal',
			});

			y = y + (self.labels.previousRun.h * 1.5);

			self.labels.score.label:draw({
				x = 1,
				y = y,
				color = 'normal',
			});

			y = y + self.labels.score.label.h;

			self.labels.score.values[1]:draw({
				x = 0,
				y = y,
				color = 'white',
			});

			self.labels.score.values[2]:draw({
				x = self.labels.score.values[1].w,
				y = y + 10,
				color = 'normal',
			});

			y = y + (self.labels.score.values[1].h * 1.25);

			self.labels.near.label:draw({
				x = 0,
				y = y,
				color = 'normal',
			 });

			self.labels.miss.label:draw({
				x = self.labels.near.label.w * 2,
				y = y,
				color = 'normal',
			});

			y = y + (self.labels.near.label.h * 1.25);

			self.labels.near.value:draw({
				x = 0,
				y = y,
				color = 'white',
			});

			self.labels.miss.value:draw({
				x = self.labels.near.label.w * 2,
				y = y,
				color = 'white',
			});

			y = y + (self.labels.score.values[1].h * 0.75);

			self.labels.hitDelta.label:draw({
				x = 0,
				y = y,
				color = 'normal',
			});

			y = y + (self.labels.hitDelta.label.h * 1.25);

			self.labels.hitDelta.mean:draw({
				x = 0,
				y = y,
				color = 'white',
			});

			self.labels.hitDelta.plusMinus:draw({
				x = self.labels.hitDelta.mean.w + 10,
				y = y,
				color = 'normal',
			});

			self.labels.hitDelta.meanAbs:draw({
				x = self.labels.hitDelta.mean.w
					+ 10
					+ self.labels.hitDelta.plusMinus.w
					+ 8,
				y = y,
				color = 'white',
			});

			y = y + (self.labels.mission.description.h * 3);

			self.labels.passRate.label:draw({
				x = 0,
				y = y,
				color = 'normal',
			});

			y = y + (self.labels.passRate.label.h * 1.5);

			self.labels.passRate.value:draw({
				x = 0,
				y = y,
				color = 'white',
			});

			self.labels.passRate.ratio:draw({
				x = self.labels.passRate.value.w + 16,
				y = y,
				color = 'normal',
			});
		end

		gfx.Restore();
	end
};

local score = {
	current = 0,
	labels = nil,

	setLabels = function(self)
		if (not self.labels) then
			font.normal();
		
			self.labels = {
				score = {
					label = cacheLabel('SCORE', 48),
				},
				maxChain = {
					label = cacheLabel('MAXIMUM CHAIN', 24),
				},
			};

			font.number();
			
			self.labels.maxChain.chain = cacheLabel('', 24);
			self.labels.score[1] = cacheLabel('', 100);
			self.labels.score[2] = cacheLabel('', 80);
		end
	end,

	updateLabels = function(self)
		local scoreString = string.format('%08d', self.current);

		font.number();
		self.labels.maxChain.chain:update({ new = string.format('%04d', combo.max) });
		self.labels.score[1]:update({ new = string.sub(scoreString, 1, 4) });
		self.labels.score[2]:update({ new = string.sub(scoreString, -4) });
	end,

	drawScore = function(self, deltaTime)
		self:setLabels();

		self:updateLabels();
	
		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local x = scaledW - (scaledW / 36);
		local y = scaledH / 14;

		gfx.Save();

		gfx.Translate(x + ((scaledW / 4) * (introShift ^ 4)), y);
	
		gfx.BeginPath();
		align.right();

		self.labels.score.label:draw({
			x = -(self.labels.score[1].w
				+ self.labels.score[2].w
				- self.labels.score.label.w
				- 4
			),
			y = -(self.labels.score[1].h * 0.35) + 4,
			a = introAlpha,
			color = 'normal',
		});

		self.labels.score[2]:draw({
			x = 0,
			y = 20,
			a = introAlpha,
			color = 'normal',
		});

		self.labels.score[1]:draw({
			x = -(self.labels.score[2].w),
			y = 0,
			a = introAlpha,
			color = 'white',
		});

		gfx.Translate(-3, self.labels.score[1].h - 6);

		gfx.BeginPath();
		align.right();

		self.labels.maxChain.label:draw({
			x = 0,
			y = 0,
			a = introAlpha,
			color = 'white',
		});

		self.labels.maxChain.chain:draw({
			x = -(self.labels.maxChain.label.w + 8),
			y = 0,
			a = introAlpha,
			color = 'normal',
		});
		
		gfx.Restore();
	end
};

local songInfo = {
	jacket = {
		fallback = gfx.CreateSkinImage('common/loading.png', 0),
		image = nil,
		w = 135,
		h = 135,
	},
	labels = nil,
	stats = { x = -72, y = 0 },
	timers = {
		artist = 0,
		fade = 0,
		title = 0,
	},

	setLabels = function(self)
		if (not self.labels) then
			font.jp();

			self.labels = {
				artist = cacheLabel(string.upper(gameplay.artist), 24),
				bpm = {},
				hidden = {},
				hispeed = {},
				sudden = {},
				title = cacheLabel(string.upper(gameplay.title), 30)
			};

			font.normal();

			self.labels.bpm.label = cacheLabel('BPM', 24);
			self.labels.hispeed.label = cacheLabel('HI-SPEED', 24);
			self.labels.hidden = {
				cutoff = {
					label = cacheLabel('HIDDEN CUTOFF', 24),
				},
				fade = {
					label = cacheLabel('HIDDEN FADE', 24),
				},
			};
			self.labels.sudden = {
				cutoff = {
					label = cacheLabel('SUDDEN CUTOFF', 24),
				},
				fade = {
					label = cacheLabel('SUDDEN FADE', 24),
				},
			};

			self.stats.y = (self.labels.bpm.label.h * 1.375) - 1;

			font.number();

			self.labels.bpm.value = cacheLabel('', 24);
			self.labels.hispeed.adjust = cacheLabel('', 24);
			self.labels.hispeed.value = cacheLabel('', 24);
			self.labels.hidden.cutoff.value = cacheLabel('', 24);
			self.labels.hidden.fade.value = cacheLabel('', 24);
			self.labels.sudden.cutoff.value = cacheLabel('', 24);
			self.labels.sudden.fade.value = cacheLabel('', 24);
		end
	end,

	updateLabels = function(self)
		font.number();

		difficulties.level:update({ new = gameplay.level });

		self.labels.bpm.value:update({ new = string.format('%.0f', gameplay.bpm) });

		self.labels.hispeed.adjust:update({
			new = string.format('%.0f  x  %.1f  =', gameplay.bpm, gameplay.hispeed),
		});

		self.labels.hispeed.value:update({
			new = string.format('%.0f', gameplay.bpm * gameplay.hispeed),
		});

		self.labels.hidden.cutoff.value:update({
			new = string.format('%.0f%%', gameplay.hiddenCutoff * 100),
		});

		self.labels.hidden.fade.value:update({
			new = string.format('%.0f%%', gameplay.hiddenFade * 100),
		});

		self.labels.sudden.cutoff.value:update({
			new = string.format('%.0f%%', gameplay.suddenCutoff * 100),
		});

		self.labels.sudden.fade.value:update({
			new = string.format('%.0f%%', gameplay.suddenFade * 100),
		});
	end,

	drawSongInfo = function(self, deltaTime)
		if ((not self.jacket.image) or (self.jacket.image == self.jacket.fallback)) then
			self.jacket.image = gfx.LoadImageJob(
				gameplay.jacketPath,
				self.jacket.fallback,
				self.jacket.w,
				self.jacket.h
			);
		end

		self:setLabels();

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local initialX = scaledW / 32;
		local initialY = scaledH / 20;

		if (introShift < 0.5) then
			self.timers.fade = math.min(self.timers.fade + (deltaTime * 6), 1);
		end

		local length = (scaledW / 4) - self.jacket.w;

		self:updateLabels();

		gfx.Save();

		gfx.Translate(initialX - ((scaledW / 4) * (introShift ^ 4)), initialY);

		gfx.BeginPath();
		gfx.StrokeWidth(1);
		gfx.StrokeColor(60, 110, 160, math.floor(255 * self.timers.fade));
		gfx.ImageRect(
			0,
			0,
			self.jacket.w,
			self.jacket.h,
			self.jacket.image,
			self.timers.fade,
			0
		);
		gfx.Stroke();

		gfx.BeginPath();
		align.left();
		difficulties[gameplay.difficulty + 1]:draw({
			x = -1,
			y = self.jacket.h + 6,
			a = 255 * self.timers.fade,
			color = 'white',
		});

		gfx.BeginPath();
		align.right();
		difficulties.level:draw({
			x = self.jacket.w + 2,
			y = self.jacket.h + 6,
			a = 255 * self.timers.fade,
			color = 'normal',
		});

		self:drawDetails(
			0,
			0,
			self.jacket.w,
			self.jacket.h + (difficulties[1].h * 1.5)
		);

		local x = self.jacket.w + 28;
		local y = -10;

		gfx.BeginPath();
		align.left();

		if (self.labels.title.w > length) then
			self.timers.title = self.timers.title + deltaTime;

			drawScrollingLabel(
				self.timers.title,
				self.labels.title,
				length,
				x - 2,
				y + 2,
				scalingFactor,
				'white',
				introAlpha
			);
		else
			self.labels.title:draw({
				x = x - 2,
				y = y + 2,
				a = introAlpha,
				color = 'white',
			});
		end

		y = y + (self.labels.title.h * 1.25);

		if (self.labels.artist.w > length) then
			self.timers.artist = self.timers.artist + deltaTime;

			drawScrollingLabel(
				self.timers.artist,
				self.labels.artist,
				length,
				x - 1,
				y,
				scalingFactor,
				'normal',
				introAlpha
			);
		else
			self.labels.artist:draw({
				x = x - 1,
				y = y,
				a = introAlpha,
				color = 'normal',
			});
		end

		y = y + (self.labels.artist.h * 1.75);

		gfx.BeginPath();
		fill.white(introAlpha / 5);
		gfx.Rect(x, y - 2, length, 8);
		gfx.Fill();

		gfx.BeginPath();
		fill.normal(introAlpha);
		gfx.Rect(x, y - 2, length * gameplay.progress, 8);
		gfx.Rect(x + (length * gameplay.progress), y - 8, 2, 20);
		gfx.Fill();

		x = x + length + 2;
		y = y + (self.labels.artist.h * 0.725);

		gfx.BeginPath();
		align.right();
	
		self.labels.bpm.value:draw({
			x = x,
			y = y,
			a = introAlpha,
			color = 'normal',
		});

		self.labels.bpm.label:draw({
			x = x + self.stats.x,
			y = y - 1,
			a = introAlpha,
			color = 'white',
		});

		if (game.GetButton(game.BUTTON_STA) and showAdjustments) then
			if (game.GetButton(game.BUTTON_BTB)) then
				self.labels.hidden.cutoff.value:draw({
					x = x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'normal',
				});
				self.labels.sudden.cutoff.value:draw({
					x = x,
					y = y + self.stats.y * 2,
					a = introAlpha,
					color = 'normal',
				});

				self.labels.hidden.cutoff.label:draw({
					x = x + self.stats.x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'white',
				});
				self.labels.sudden.cutoff.label:draw({
					x = x + self.stats.x,
					y = y + (self.stats.y * 2),
					a = introAlpha,
					color = 'white',
				});
			elseif (game.GetButton(game.BUTTON_BTC)) then
				self.labels.hidden.fade.value:draw({
					x = x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'normal',
				});
				self.labels.sudden.fade.value:draw({
					x = x,
					y = y + self.stats.y * 2,
					a = introAlpha,
					color = 'normal',
				});

				self.labels.hidden.fade.label:draw({
					x = x + self.stats.x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'white',
				});
				self.labels.sudden.fade.label:draw({
					x = x + self.stats.x,
					y = y + (self.stats.y * 2),
					a = introAlpha,
					color = 'white',
				});
			else
				self.labels.hispeed.adjust:draw({
					x = x + self.stats.x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'white',
				});

				self.labels.hispeed.value:draw({
					x = x,
					y = y + self.stats.y,
					a = introAlpha,
					color = 'normal',
				});
			end
		else
			self.labels.hispeed.label:draw({
				x = x + self.stats.x,
				y = y + self.stats.y,
				a = introAlpha,
				color = 'white',
			});

			self.labels.hispeed.value:draw({
				x = x,
				y = y + self.stats.y,
				a = introAlpha,
				color = 'normal',
			});
		end

		gfx.Restore();
	end,

	drawDetails = function(self, x, y, w, h)
		gfx.BeginPath();
		gfx.StrokeWidth(1.5);
		gfx.StrokeColor(255, 255, 255, 255);
		
		gfx.MoveTo(x - 12, y);
		gfx.LineTo(x - 12, y - 10);
		gfx.LineTo(x - 1, y - 10);
		
		gfx.MoveTo(x + w + 12, y);
		gfx.LineTo(x + w + 12, y - 10);
		gfx.LineTo(x + w + 1, y - 10);

		gfx.MoveTo(x - 12, y + h);
		gfx.LineTo(x - 12, y + h + 10);
		gfx.LineTo(x - 1, y + h + 10);

		gfx.MoveTo(x + w + 12, y + h);
		gfx.LineTo(x + w + 12, y + h + 10);
		gfx.LineTo(x + w + 1, y + h + 10);

		gfx.Stroke();
	end
};

local showScoreDifference = game.GetSkinSetting('showScoreDifference') or false;
local showUserInfo = game.GetSkinSetting('showUserInfo') or false;
local username = game.GetSkinSetting('displayName') or '';

local userInfo = {
	difference = 0,
	labels = nil,
	timer = 0,
	x = {},

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				player = cacheLabel('PLAYER', 18),
				scoreDifference = cacheLabel('SCORE DIFFERENCE', 18),
			};

			font.normal();

			if (gameplay.autoplay) then
				self.labels.username = cacheLabel('AUTOPLAY', 36);
			else
				self.labels.username = cacheLabel(string.upper(username), 36);
			end

			font.number();

			self.labels.prefixes = {
				minus = cacheLabel('-', 46),
				plus = cacheLabel('+', 36),
			};

			self.labels.score = {
				cacheLabel('', 46),
				cacheLabel('', 36),
			};
		end
	end,

	drawUserInfo = function(self, deltaTime)
		self:setLabels();

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local initialX = scaledW / 80;
		local initialY = scaledH / 2.375;
		local y = 0;

		if (introShift < 0.5) then
			self.timer = math.min(self.timer + (deltaTime * 6), 1);
		end

		gfx.Save();

		gfx.Translate(initialX - ((scaledW / 40) * (introShift ^ 4)), initialY);

		gfx.BeginPath();
		align.left();

		self.labels.player:draw({
			x = 0,
			y = y,
			a = 255 * self.timer,
			color = 'normal',
		});

		y = y + (self.labels.player.h * 1.125);

		self.labels.username:draw({
			x = 0,
			y = y,
			a = 255 * self.timer,
			color = 'white',
		});

		if (showScoreDifference and gameplay.scoreReplays[1]) then
			y = y + (self.labels.username.h * 1.75);

			local difference = score.current - gameplay.scoreReplays[1].currentScore;
			local differenceString = string.format('%08d', math.abs(difference));
			local prefix = ((difference < 0) and 'minus') or 'plus';

			font.number();

			self.labels.score[1]:update({ new = string.sub(differenceString, 1, 4) });
			self.labels.score[2]:update({ new = string.sub(differenceString, -4) });

			if (not self.x[1]) then
				self.x[1] = self.labels.prefixes.plus.w + 4;
				self.x[2] = self.x[1] + self.labels.score[1].w + 2;
			end

			gfx.BeginPath();
			align.left();

			self.labels.scoreDifference:draw({
				x = 0,
				y = y,
				a = 255 * self.timer,
				color = 'normal',
			});

			y = y + self.labels.scoreDifference.h;

			self.labels.prefixes[prefix]:draw({
				x = ((prefix == 'plus') and 0) or 6,
				y = y + ((prefix == 'plus' and (self.labels.prefixes.plus.h * 0.125))
				or -4),
				a = 255 * self.timer,
				color = 'white',
			});

			self.labels.score[1]:draw({
				x = self.x[1],
				y = y,
				a = 255 * self.timer,
				color = 'white',
			});

			self.labels.score[2]:draw({
				x = self.x[2],
				y = y + (self.labels.score[2].h * 0.25),
				a = 255 * self.timer,
				color = 'normal',
			});
		end

		gfx.Restore();
	end,
};

render = function(deltaTime);
	gfx.ResetTransform();

	setupLayout();

	gfx.Scale(scalingFactor, scalingFactor);

	alerts:drawAlerts(deltaTime);
	combo:drawCombo(deltaTime);
	earlate:drawEarlate(deltaTime);
	gauge:drawGauge(deltaTime);

	score:drawScore(deltaTime);

	songInfo:drawSongInfo(deltaTime);

	if (showUserInfo
		and (not gameplay.multiplayer)
		and (gameplay.practice_setup == nil)
	) then
		userInfo:drawUserInfo(deltaTime);
	end

	hitError:render(deltaTime, scaledW, scaledH);

	if (gameplay.practice_setup ~= nil) then
		practice:drawPracticeInfo();

		showAdjustments = not gameplay.practice_setup;
	end
end

local pressedBTA = false;

render_intro = function(deltaTime)
	if (gameplay.demoMode) then
		introTimer = 0;
		
		return true;
	end

	if (not game.GetButton(game.BUTTON_STA)) then
		introTimer = introTimer - (deltaTime * ((introTimer >= 1 and 0.5) or 1));

		earlate.timer = 0;
	else
		earlate.timer = 1;

		if ((not pressedBTA) and game.GetButton(game.BUTTON_BTA)) then
			setEarlatePosition();
		end
	end

	pressedBTA = game.GetButton(game.BUTTON_BTA);

	introTimer = math.max(introTimer, 0);

	return (introTimer <= 0);
end

render_outro = function(deltaTime, clearStatus)
	if (clearStatus == 0) then
		return true;
	end

	if (not gameplay.demoMode) then
		gfx.BeginPath();
		fill.black(150 * math.min(outroTimer, 1));
		gfx.FastRect(0, 0, scaledW, scaledH);
		gfx.Fill();

		gfx.BeginPath();
		align.middle();
		clearStates[clearStatus]:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			a = 255 * math.min(outroTimer, 1),
			color = 'white',
		});

		outroTimer = outroTimer + deltaTime;

		return (outroTimer > 2), (1 - outroTimer);
	else
		outroTimer = outroTimer + deltaTime;

		return (outroTimer > 2), 1;
	end
end

laser_alert = function(rightAlert)
	if ((rightAlert) and (alerts.timers[2] < -1.5)) then
		alerts.timers[2] = 1.5;
	elseif (alerts.timers[1] < 1.5) then
		alerts.timers[1] = 1.5;
	end
end

near_hit = function(wasLate)
	earlate.isLate = wasLate;

	earlate.timer = 0.75;
end

update_combo = function(newCombo)
	combo.current = newCombo;

	if (combo.current > combo.max) then
		combo.max = combo.current;
	end

	combo.timer = 0.75;
end

update_score = function(newScore)
	score.current = newScore;
end

----------------------------------------
-- MULTIPLAYER
----------------------------------------

local json = require('lib/json');

local realRender = render;
local users = nil;

init_tcp = function()
	Tcp.SetTopicHandler('game.scoreboard',
		function(data)
			users = {};

			for i, user in ipairs(data.users) do
				users[i] = user;
			end
		end
	);
end

score_callback = function(res)
	if (res.status ~= 200) then
		error();
	
		return;
	end

	local data = json.decode(res.text);

	users = {};

	for i, user in ipairs(data.users) do
		users[i] = user;
	end
end

local scoreboard = {
	labels = nil,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {};
	
			for i, user in ipairs(users) do
				font.normal();
	
				self.labels[i] = {
					name = cacheLabel('NAME', 24),
				};
	
				font.number();
	
				self.labels[i].score = {
					cacheLabel('', 46),
					cacheLabel('', 36),
				};
			end
		end
	end,

	drawScoreboard = function(self)
		if (not users) then return end
	
		self:setLabels();

		local y = 0;
	
		gfx.Save();
	
		gfx.Translate(scaledW / 100, scaledH / 3.75);
	
		for i, user in ipairs(users) do
			local alpha = ((user.id == gameplay.user_id) and 255) or 150;
			local scoreText = string.format('%08d', user.score);

			font.normal();

			self.labels[i].name:update({ new = string.upper(user.name) });

			font.number();

			self.labels[i].score[1]:update({ new = string.sub(scoreText, 1, 4) });
			self.labels[i].score[2]:update({ new = string.sub(scoreText, -4) });

			gfx.BeginPath();
			align.left();
	
			self.labels[i].name:draw({
				x = 1,
				y = y,
				a = alpha,
				color = 'light',
			});
	
			y = y + self.labels[i].name.h;

			self.labels[i].score[1]:draw({
				x = 0,
				y = y,
				a = alpha,
				color = 'white',
			});
	
			self.labels[i].score[2]:draw({
				x = self.labels[i].score[1].w,
				y = y + 10,
				a = alpha,
				color = 'light',
			});
	
			y = y + (self.labels[i].score[1].h * 1.25);
		end
	
		gfx.Restore();
	end
};

render = function(deltaTime)
	realRender(deltaTime);

	scoreboard:drawScoreboard();
end

----------------------------------------
-- PRACTICE MODE
----------------------------------------

practice_start = function(type, threshold, description)
	practice.practicing = true;

	font.normal();

	practice.labels.mission.description:update({
		new = string.upper(description),
	});
end

practice_end_run = function(playCount, passCount, passed, scoreInfo)
	font.number();
	
	practice.counts.plays = playCount;
	practice.counts.passes = passCount;

	practice.labels.passRate.ratio:update({ new = string.format('%d/%d', passCount, playCount) });

	practice.labels.passRate.value:update({
		new = string.format('%.1f%%', (passCount / playCount) * 100),
	});

	local scoreString = string.format('%08d', scoreInfo.score);

	practice.labels.score.values[1]:update({ new = string.sub(scoreString, 1, 4) });

	practice.labels.score.values[2]:update({ new = string.sub(scoreString, -4) });

	practice.labels.miss.value:update({ new = scoreInfo.misses });

	practice.labels.near.value:update({ new = scoreInfo.goods });

	practice.labels.hitDelta.mean:update({
		new = string.format('%.1f', scoreInfo.meanHitDelta)
	});

	practice.labels.hitDelta.meanAbs:update({
		new = string.format('%.1f ms', scoreInfo.meanHitDeltaAbs)
	});
end

practice_end = function(playCount, passCount)
	practice.practicing = false;

	practice.counts.plays = playCount;
	practice.counts.passes = passCount;
end