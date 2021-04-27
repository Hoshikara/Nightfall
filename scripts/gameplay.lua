local CONSTANTS = require('constants/gameplay');

local ScoreNumber = require('common/scorenumber');

local hitAnimation = require('gameplay/hitanimation');
local hitError = require('gameplay/hiterror');
local laserAnimation = require('gameplay/laseranimation');

hitAnimation:initializeAll();
laserAnimation:initializeAll();

if (not introTimer) then
	introTimer = 2;
	outroTimer = 0;
end

local buttonDelta = 0;

local clearStates = nil;

do
	if (not clearStates) then
		clearStates = {};

		for i, clearState in ipairs(CONSTANTS.clearStates) do
			clearStates[i] = New.Label({
				font = 'normal',
				text = clearState,
				size = 60,
			});
		end
	end
end

local critLineBar = New.Image({ path = 'gameplay/crit_bar/crit_bar.png' });

local difficulties = nil;

do
	if (not difficulties) then
		difficulties = {};

		for i, difficulty in ipairs(CONSTANTS.difficulties) do
			difficulties[i] = New.Label({
				font = 'medium',
				text = difficulty,
				size = 18,
			});
		end

		difficulties.level = New.Label({
			font = 'number',
			text = '',
			size = 18,
		});
	end
end

local earlatePosition = getSetting('earlatePosition', 'BOTTOM');
local earlateType = getSetting('earlateType', 'TEXT');

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

	drawRectangle({
		x = -scaledW,
		y = height / 2,
		w = scaledW * 2,
		h = scaledH,
		alpha = 200,
		color = 'black',
	});

	drawImage({
		x = 0,
		y = 0,
		w = length,
		h = height,
		blendOp = gfx.BLEND_OP_LIGHTER,
		centered = true,
		image = critLineBar,
	});

	drawImage({
		x = 0,
		y = 0,
		w = length,
		h = height,
		alpha = 0.5,
		blendOp = gfx.BLEND_OP_SOURCE_OVER,
		centered = true,
		image = critLineBar,
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

		drawRectangle({
			x = cursorPos - (width / 2),
			y = -(height / 2),
			w = width,
			h = height,
			alpha = currentCursor.alpha,
			image = laser.fill,
			tint = { r, g, b },
		});

		drawRectangle({
			x = cursorPos - (width / 2),
			y = -(height / 2),
			w = width,
			h = height,
			alpha = currentCursor.alpha,
			image = laser.overlay,
		});
		
		gfx.SkewX(-cursorSkew);
	end

	gfx.ResetTransform();
end

button_hit = function(button, rating, delta)
	if (rating == 1) then
		buttonDelta = ((delta < 0) and (delta + gameplay.hitWindow.perfect))
			or (delta - gameplay.hitWindow.perfect);
	end

	hitAnimation:queueHit(button, rating);
	hitError:queueHit(button, rating, delta);
end

local alerts = {
	alpha = { 0, 0 },
	labels = nil,
	timers = {
		[1] = -1.5,
		[2] = -1.5,
		fade = { 0, 0 },
		pulse = { 0, 0 },
		start = { false, false },
	},

	drawAlerts = function(self, deltaTime)
		if (not self.labels) then
			self.labels = {
				[1] = New.Label({
					font = 'normal',
					text = 'L',
					size = 120,
				}),
				[2] = New.Label({
					font = 'normal',
					text = 'R',
					size = 120,
				}),
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
			self.timers[i] = math.max(self.timers[i] - deltaTime, -1.5);

			if (self.timers[i] > 0) then
				self.timers.start[i] = true;
			end

			if (self.timers.start[i]) then
				self.timers.fade[i] = math.min(self.timers.fade[i] + (deltaTime * 7), 1);
				self.timers.pulse[i] = self.timers.pulse[i] + deltaTime;
				self.alpha[i] = math.abs(0.8 * math.cos(self.timers.pulse[i] * 10)) + 0.2;
			end

			if (self.timers[i] == -1.5) then
				self.timers.start[i] = false;
			
				self.timers.fade[i] = math.max(self.timers.fade[i] - (deltaTime * 6), 0);
				self.timers.pulse[i] = self.timers.pulse[i] - deltaTime;
				self.alpha[i] = 1;
			end
		end

		gfx.Save();

		for i = 1, 2 do
			gfx.Translate(x[i], y[i]);

			gfx.Scissor(-64, -64, 128, 128 * self.timers.fade[i]);

			drawLabel({
				x = 0,
				y = self.labels.y,
				align = 'middle',
				alpha = 255 * self.alpha[i],
				color = {
					self.colors.r[i],
					self.colors.g[i],
					self.colors.b[i],
				},
				label = self.labels[i],
			});

			drawLabel({
				x = 0,
				y = self.labels.y,
				align = 'middle',
				alpha = 70 * self.alpha[i],
				color = 'white',
				label = self.labels[i],
			});

			gfx.ResetScissor();

			drawCursor({
				x = -64 * self.timers.fade[i],
				y = -64 * self.timers.fade[i],
				w = 128 * self.timers.fade[i],
				h = 128 * self.timers.fade[i],
				alpha = self.timers.fade[i],
				size = 16,
				stroke = 2,
			});
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
		if (gameplay.progress == 0) then
			self.max = 0;
		end

		if (self.current == 0) then return end
	
		local x = scaledW / 2;
		local y = (scaledH * 0.95) - (scaledH / 6);
	
		if (not self.labels) then
			self.labels = {
				burst = {},
			};
	
			for i = 1, 4 do
				self.labels[i] = New.Label({
					font = 'number',
					text = '0',
					size = 64,
				});
				self.labels.burst[i] = New.Label({
					font = 'number',
					text = '0',
					size = 64,
				});
			end
	
			local w = self.labels[1].w * 0.85;
	
			self.x = {
				x - (w * 2),
				x - (w * 0.675),
				x + (w * 0.675),
				x + (w * 2),
			};
	
			self.labels.chain = New.Label({
				font = 'medium',
				text = 'CHAIN',
				size = 22,
			});
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
	
		if ((gameplay.comboState == 2) or (gameplay.comboState == 1)) then
			drawLabel({
				x = x + 1,
				y = y - (self.labels.chain.h * 2.25) + 1,
				align = 'middle',
				alpha = 125,
				color = { 4, 8, 12 },
				label = self.labels.chain,
			});
	
			drawLabel({
				x = x,
				y = y - (self.labels.chain.h * 2.25),
				align = 'middle',
				alpha = 255,
				color = { 255, 235, 100 },
				label = self.labels.chain,
			});
	
			for i = 1, 4 do
				self.labels[i]:update({ new = digits[i] });

				drawLabel({
					x = self.x[i] + 1,
					y = y + 1,
					align = 'middle',
					alpha = alpha[i] * 0.5,
					color = { 4, 8, 12 },
					label = self.labels[i],
				});
	
				drawLabel({
					x = self.x[i],
					y = y,
					align = 'middle',
					alpha = alpha[i],
					color = { 255, 235, 100 },
					label = self.labels[i],
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
	
			for i = 1, 4 do
				self.labels.burst[i]:update({
					new = digits[i],
					size = math.floor(64 * self.scale),
				});
	
				drawLabel({
					x = self.x[i],
					y = y,
					align = 'middle',
					alpha = 255 * self.alpha,
					color = { 255, 235, 100 },
					label = self.labels.burst[i],
				});
			end
		else
			drawLabel({
				x = x + 1,
				y = y - (self.labels.chain.h * 2.5) + 1,
				align = 'middle',
				alpha = 125,
				color = { 4, 8, 12 },
				label = self.labels.chain,
			});

			drawLabel({
				x = x,
				y = y - (self.labels.chain.h * 2.5),
				align = 'middle',
				alpha = 255,
				color = { 235, 235, 235 },
				label = self.labels.chain,
			});
	
			for i = 1, 4 do
				self.labels[i]:update({ new = digits[i] });

				drawLabel({
					x = self.x[i] + 1,
					y = y + 1,
					align = 'middle',
					alpha = alpha[i] * 0.5,
					color = { 4, 8, 12 },
					label = self.labels[i],
				});
	
				drawLabel({
					x = self.x[i],
					y = y,
					align = 'middle',
					alpha = alpha[i],
					color = { 235, 235, 235 },
					label = self.labels[i],
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
			self.labels = {
				early = New.Label({
					font = 'medium',
					text = 'EARLY',
					size = 30,
				}),
				late = New.Label({
					font = 'medium',
					text = 'LATE',
					size = 30,
				}),
			};

			self.labels.delta = New.Label({
				font = 'number',
				text = '0.0 ms',
				size = 30,
			});
		end
	end,

	drawEarlate = function(self, deltaTime)
		self:setLabels();

		if (earlatePosition == 'OFF') then return end

		self.timer = math.max(self.timer - deltaTime, 0);

		if (self.timer == 0) then return end

		local deltaString = string.format('%.1f ms', buttonDelta);

		if (buttonDelta > 0) then
			deltaString = string.format('+%.1f ms', buttonDelta);
		end

		self.labels.delta:update({ new = deltaString });

		self.alphaTimer = self.alphaTimer + deltaTime;

		self.alpha = math.floor(self.alphaTimer * 30) % 2;
		self.alpha = ((self.alpha * 175) + 80) / 255;

		local x = scaledW / 2;
		local y = scaledH - (scaledH / 3.35);
		local color = { 255, 105, 255 };
		local offset = 0;
		local whichLabel = (self.isLate and 'late') or 'early';

		if (earlatePosition == 'BOTTOM') then
			y = scaledH - (scaledH / 3.35);
		elseif (earlatePosition == 'MIDDLE') then
			y = scaledH - (scaledH / 1.85);
		elseif (earlatePosition == 'UPPER') then
			y = scaledH - (scaledH / 1.35);
		elseif (earlatePosition == 'UPPER+') then
			y = scaledH - (scaledH / 1.15);
		end

		if (earlateType == 'TEXT + DELTA') then
			offset = scaledW / 18;
		end

		gfx.Save();

		gfx.Translate(x, y);

		if (earlateType ~= 'DELTA') then
			drawLabel({
				x = -offset,
				y = 2,
				align = 'middle',
				alpha = 100,
				color = { 150, 150, 150 },
				label = self.labels[whichLabel],
			});
		end

		if (earlateType ~= 'TEXT') then
			drawLabel({
				x = offset,
				y = 6,
				align = 'middle',
				alpha = 100,
				color = { 150, 150, 150 },
				label = self.labels.delta,
			});
		end

		if (self.isLate) then
			color = { 105, 205, 255 };
		end

		if (earlateType ~= 'DELTA') then
			drawLabel({
				x = -offset,
				y = 0,
				align = 'middle',
				alpha = 255 * self.alpha,
				color = color,
				label = self.labels[whichLabel],
			});
		end

		if (earlateType ~= 'TEXT') then
			drawLabel({
				x = offset,
				y = 4,
				align = 'middle',
				alpha = 255 * self.alpha,
				color = color,
				label = self.labels.delta,
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
			self.labels = {
				effective = New.Label({
					font = 'normal',
					text = 'EFFECTIVE RATE',
					size = 24,
				}),
				excessive = New.Label({
					font = 'normal',
					text = 'EXCESSIVE RATE',
					size = 24,
				}),
			};

			self.labels.percentage = New.Label({
				font = 'number',
				text = '0',
				size = 24,
			});

			self.labels.h = self.labels.effective.h;
		end
	end,
	
	drawGauge = function(self, deltaTime)
		self:setLabels();

		local gauge;
		local gaugeColor = { 255, 255, 255 };

		if (gameplay.gaugeType) then
			gauge = { type = gameplay.gaugeType, value = gameplay.gauge };
		else
			gauge = { type = gameplay.gauge.type, value = gameplay.gauge.value };
		end

		if (gauge.type == 0) then
			if (gauge.value < 0.7) then
				gaugeColor = { 25, 125, 225 };
			else
				gaugeColor = { 225, 25, 155 };
			end
		else
			if (gauge.value < 0.3) then
				gaugeColor = { 225, 25, 25 };
			else
				gaugeColor = { 225, 105, 25 };
			end
		end

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local height = scaledH / 2;
		local x = scaledW - (scaledW / 6.5);
		local y = scaledH / 3.5;
		local formattedValue = ((gauge.value < 0.1) and '%02d%%') or '%d%%';

		self.timer = self.timer + deltaTime;

		self.alpha = math.abs(1 * math.cos(self.timer * 2));

		self.labels.percentage:update({
			new = string.format(formattedValue, math.floor(gauge.value * 100))
		});

		gfx.Save();

		gfx.Translate(x, y - ((scaledH / 8) * (introShift ^ 4)));

		drawRectangle({
			x = 0,
			y = height,
			w = 18,
			h = -(height * gauge.value),
			alpha = 255,
			color = gaugeColor,
		});

		drawRectangle({
			x = 0,
			y = height,
			w = 18,
			h = -(height * gauge.value),
			alpha = (introAlpha / 5) * self.alpha,
			color = 'white',
		});

		drawRectangle({
			x = 0,
			y = 0,
			w = 18,
			h = height,
			alpha = 0,
			color = 'black',
			stroke = {
				alpha = introAlpha,
				color = 'white',
				size = 2,
			},
		});

		drawRectangle({
			x = 0,
			y = ((gauge.type == 0) and (height * 0.3)) or (height * 0.7),
			w = 18,
			h = 3,
			alpha = introAlpha,
			color = 'white',
		});

		drawLabel({
			x = -6,
			y = height - (height * gauge.value) - 14,
			align = 'right',
			alpha = introAlpha,
			color = 'white',
			label = self.labels.percentage,
		});

		gfx.BeginPath();
		gfx.Rotate(90);

		if (gauge.type == 0) then
			drawLabel({
				x = height + 3,
				y = -self.labels.h - 26,
				align = 'right',
				alpha = introAlpha,
				color = 'white',
				label = self.labels.effective,
			});
		else
			drawLabel({
				x = -4,
				y = -self.labels.h - 26,
				alpha = introAlpha,
				color = 'white',
				label = self.labels.excessive,
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
			local setNumberLabel = function(text)
				return {
					font = 'number',
					text = text or '0',
					size = 24,
				};
			end

			self.labels = {
				hitDelta = {
					label = New.Label({
						font = 'medium',
						text = 'MEAN HIT DELTA',
						size = 18,
					}),
				},
				miss = { 
					label = New.Label({
						font = 'medium',
						text = 'MISS',
						size = 18,
					}),
				},
				mission = {
					label = New.Label({
						font = 'medium',
						text = 'MISSION',
						size = 24,
					}),
					description = New.Label({
						font = 'normal',
						text = '',
						size = 24,
					}),
				},
				near = {
					label = New.Label({
						font = 'medium',
						text = 'NEAR',
						size = 18,
					}),
				},
				passRate = {
					label = New.Label({
						font = 'medium',
						text = 'PASS RATE',
						size = 24,
					}),
				},
				previousRun = New.Label({
					font = 'medium',
					text = 'PREVIOUS PLAY', 
					size = 24,
				}),
				score = {
					label = New.Label({
						font = 'medium',
						text = 'SCORE',
						size = 18,
					}),
				},
			};

			self.labels.practiceMode = New.Label({
				font = 'normal',
				text = 'PRACTICE MODE',
				size = 36,
			});

			self.labels.hitDelta.plusMinus = New.Label(setNumberLabel('±'));
			self.labels.hitDelta.mean = New.Label(setNumberLabel());
			self.labels.hitDelta.meanAbs = New.Label(setNumberLabel());
			self.labels.miss.value = New.Label(setNumberLabel());
			self.labels.near.value = New.Label(setNumberLabel());
			self.labels.passRate.ratio = New.Label(setNumberLabel());
			self.labels.passRate.value = New.Label(setNumberLabel());
			self.labels.score.value = ScoreNumber.New({
				isScore = true,
				sizes = { 46, 36 },
			});
		end
	end,

	drawPracticeInfo = function(self)
		self:setLabels();

		drawLabel({
			x = scaledW / 2,
			y = scaledH / 60,
			align = 'middle',
			color = 'white',
			label = self.labels.practiceMode,
		});

		if (not self.practicing) then return end

		local y = 0;

		gfx.Save();

		gfx.Translate(scaledW / 100, scaledH / 3);

		drawLabel({
			x = 0,
			y = y,
			color = 'normal',
			label = self.labels.mission.label,
		});

		y = y + self.labels.mission.label.h * 1.4;

		drawLabel({
			x = 0,
			y = y,
			color = 'white',
			label = self.labels.mission.description,
			maxWidth = scaledW / 4,
		});

		if (self.counts.plays > 0) then
			y = y + (self.labels.mission.description.h * 3);

			drawLabel({
				x = 1,
				y = y,
				color = 'normal',
				label = self.labels.previousRun,
			});

			y = y + (self.labels.previousRun.h * 1.5);

			drawLabel({
				x = 1,
				y = y,
				color = 'normal',
				label = self.labels.score.label,
			});

			y = y + self.labels.score.label.h;

			self.labels.score.value:draw({
				x = -1,
				y1 = y,
				y2 = y + 10,
				offset = 6,
			});

			y = y + (self.labels.score.value.labels[1].h * 1.25);

			drawLabel({
				x = 0,
				y = y,
				color = 'normal',
				label = self.labels.near.label,
			 });

			drawLabel({
				x = self.labels.near.label.w * 2,
				y = y,
				color = 'normal',
				label = self.labels.miss.label,
			});

			y = y + (self.labels.near.label.h * 1.25);

			drawLabel({
				x = 0,
				y = y,
				color = 'white',
				label = self.labels.near.value,
			});

			drawLabel({
				x = self.labels.near.label.w * 2,
				y = y,
				color = 'white',
				label = self.labels.miss.value,
			});

			y = y + (self.labels.score.value.labels[1].h * 0.75);

			drawLabel({
				x = 0,
				y = y,
				color = 'normal',
				label = self.labels.hitDelta.label,
			});

			y = y + (self.labels.hitDelta.label.h * 1.25);

			drawLabel({
				x = 0,
				y = y,
				color = 'white',
				label = self.labels.hitDelta.mean,
			});

			drawLabel({
				x = self.labels.hitDelta.mean.w + 10,
				y = y,
				color = 'normal',
				label = self.labels.hitDelta.plusMinus,
			});

			drawLabel({
				x = self.labels.hitDelta.mean.w
					+ 10
					+ self.labels.hitDelta.plusMinus.w
					+ 8,
				y = y,
				color = 'white',
				label = self.labels.hitDelta.meanAbs,
			});

			y = y + (self.labels.mission.description.h * 3);

			drawLabel({
				x = 0,
				y = y,
				color = 'normal',
				label = self.labels.passRate.label,
			});

			y = y + (self.labels.passRate.label.h * 1.5);

			drawLabel({
				x = 0,
				y = y,
				color = 'white',
				label = self.labels.passRate.value,
			});

			drawLabel({
				x = self.labels.passRate.value.w + 16,
				y = y,
				color = 'normal',
				label = self.labels.passRate.ratio,
			});
		end

		gfx.Restore();
	end
};

local scoreInfo = {
	current = 0,
	score = ScoreNumber.New({
		isScore = true,
		sizes = { 100, 80 }
	}),
	labels = nil,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {
				score = New.Label({
					font = 'normal',
					text = 'SCORE',
					size = 48,
				}),
				maxChain = {
					label = New.Label({
						font = 'normal',
						text = 'MAXIMUM CHAIN',
						size = 24,
					}),
				},
			};
			
			self.labels.maxChain.value = ScoreNumber.New({
				digits = 4,
				isScore = false,
				sizes = { 24 },
			});
		end
	end,

	drawScore = function(self, deltaTime)
		self:setLabels();

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local x = scaledW - (scaledW / 36);
		local y = scaledH / 14;

		self.score:setInfo({ value = self.current });

		self.labels.maxChain.value:setInfo({ value = combo.max });

		gfx.Save();

		gfx.Translate(x + ((scaledW / 4) * (introShift ^ 4)), y);
	
		drawLabel({
			x = -(self.labels.score.w * 1.675) + 2,
			y = -(self.score.labels[1].h * 0.35) + 4,
			align = 'right',
			alpha = introAlpha,
			color = 'normal',
			label = self.labels.score,
		});

		self.score:draw({
			x = -(scaledW / 4.75) + 1,
			y1 = 0, 
			y2 = 20,
			align = 'right',
			alpha = introAlpha,
			offset = 0,
		});

		gfx.Translate(-3, self.score.labels[1].h - 6);

		drawLabel({
			x = 0,
			y = 0,
			align = 'right',
			alpha = introAlpha,
			color = 'white',
			label = self.labels.maxChain.label,
		});

		self.labels.maxChain.value:draw({
			x = -(self.labels.maxChain.label.w * 1.25 + 4),
			y = 0,
			align = 'right',
			alpha = introAlpha,
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
		current = 0,
		artist = 0,
		fade = 0,
		title = 0,
		total = 0,
	},

	setLabels = function(self)
		if (not self.labels) then
			local setNumberLabel = function(text)
				return {
					font = 'number',
					text = text or '0',
					size = 24,
				};
			end

			self.labels = {
				artist = New.Label({
					font = 'jp',
					text = string.upper(gameplay.artist),
					size = 24,
				}),
				bpm = {},
				hidden = {},
				hispeed = {},
				sudden = {},
				time = {},
				title = New.Label({
					font = 'jp',
					text = string.upper(gameplay.title),
					size = 30,
				}),
			};

			self.labels.bpm.label = New.Label({
				font = 'normal',
				text = 'BPM',
				size = 24,
			});
			self.labels.hispeed.label = New.Label({
				font = 'normal',
				text = 'HI-SPEED',
				size = 24,
			});
			self.labels.hidden = {
				cutoff = {
					label = New.Label({
						font = 'normal',
						text = 'HIDDEN CUTOFF',
						size = 24,
					}),
				},
				fade = {
					label = New.Label({
						font = 'normal',
						text = 'HIDDEN FADE',
						size = 24,
					}),
				},
			};
			self.labels.sudden = {
				cutoff = {
					label = New.Label({
						font = 'normal',
						text = 'SUDDEN CUTOFF',
						size = 24,
					}),
				},
				fade = {
					label = New.Label({
						font = 'normal',
						text = 'SUDDEN FADE',
						size = 24,
					}),
				},
			};

			self.stats.y = (self.labels.bpm.label.h * 1.375) - 1;

			self.labels.bpm.value = New.Label(setNumberLabel());
			self.labels.hispeed.adjust = New.Label(setNumberLabel());
			self.labels.hispeed.value = New.Label(setNumberLabel());
			self.labels.hidden.cutoff.value = New.Label(setNumberLabel());
			self.labels.hidden.fade.value = New.Label(setNumberLabel());
			self.labels.sudden.cutoff.value = New.Label(setNumberLabel());
			self.labels.sudden.fade.value = New.Label(setNumberLabel());
			self.labels.time.current = New.Label(setNumberLabel('00:00'));
			self.labels.time.total = New.Label(setNumberLabel('/ 00:00'));
		end
	end,

	updateLabels = function(self)
		difficulties.level:update({ new = string.format('%02d', gameplay.level) });

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

		self.labels.time.current:update({
			new = string.format(
				'%02d:%02d',
				math.floor(self.timers.current / 60),
				math.floor((self.timers.current % 60) + 0.5)
			)
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

		local difficultyIndex = getDifficultyIndex(
			gameplay.jacketPath,
			gameplay.difficulty
		);

		local introShift = math.max(introTimer - 1, 0);
		local introAlpha = math.floor(255 * (1 - (introShift ^ 1.5)));
		local initialX = scaledW / 32;
		local initialY = scaledH / 20;

		if (introShift < 0.5) then
			self.timers.fade = math.min(self.timers.fade + (deltaTime * 6), 1);
		end

		if (gameplay.practice_setup == nil) then
			if ((gameplay.progress > 0) and (gameplay.progress < 1)) then
				self.timers.current = self.timers.current + deltaTime;

				local total = math.floor(
					((1 / gameplay.progress) * self.timers.current) + 0.5
				);

				if (self.timers.total ~= total) then
					self.labels.time.total:update({
						new = string.format(
							'/ %02d:%02d',
							math.floor(total / 60),
							math.floor(total % 60)
						)
					});

					self.timers.total = total;
				end
			elseif (gameplay.progress == 0) then
				self.timers.current = 0;
			end
		end

		local length = (scaledW / 4) - self.jacket.w;

		self:updateLabels();

		gfx.Save();

		gfx.Translate(initialX - ((scaledW / 4) * (introShift ^ 4)), initialY);

		drawRectangle({
			x = 0,
			y = 0,
			w = self.jacket.w,
			h = self.jacket.h,
			alpha = self.timers.fade,
			image = self.jacket.image,
			stroke = {
				alpha = 255 * self.timers.fade,
				color = 'normal',
				size = 1,
			},
		});

		drawLabel({
			x = -1,
			y = self.jacket.h + 6,
			alpha = 255 * self.timers.fade,
			color = 'white',
			label = difficulties[difficultyIndex],
		});

		drawLabel({
			x = self.jacket.w + 2,
			y = self.jacket.h + 6,
			align = 'right',
			alpha = 255 * self.timers.fade,
			color = 'normal',
			label = difficulties.level,
		});

		self:drawDetails(
			0,
			0,
			self.jacket.w,
			self.jacket.h + (difficulties[1].h * 1.5)
		);

		local x = self.jacket.w + 28;
		local y = -10;

		if (self.labels.title.w > length) then
			self.timers.title = self.timers.title + deltaTime;

			drawScrollingLabel({
				x = x - 2,
				y = y + 2,
				alpha = introAlpha,
				color = 'white',
				label = self.labels.title,
				scale = scalingFactor,
				timer = self.timers.title,
				width = length,
			});
		else
			drawLabel({
				x = x - 2,
				y = y + 2,
				alpha = introAlpha,
				color = 'white',
				label = self.labels.title,
			});
		end

		y = y + (self.labels.title.h * 1.25);

		if (self.labels.artist.w > length) then
			self.timers.artist = self.timers.artist + deltaTime;

			drawScrollingLabel({
				x = x - 1,
				y = y + 2,
				alpha = introAlpha,
				color = 'normal',
				label = self.labels.artist,
				scale = scalingFactor,
				timer = self.timers.artist,
				width = length,
			});
		else
			drawLabel({
				x = x - 1,
				y = y + 2,
				alpha = introAlpha,
				color = 'normal',
				label = self.labels.artist,
			});
		end

		y = y + (self.labels.artist.h * 1.75);

		drawRectangle({
			x = x,
			y = y - 2,
			w = length,
			h = 26,
			alpha = introAlpha / 5,
			color = 'white',
		});

		drawRectangle({
			x = x,
			y = y - 2,
			w = length * gameplay.progress,
			h = 26,
			alpha = introAlpha,
			color = 'normal',
		});

		x = x + length + 2;

		if (gameplay.practice_setup == nil) then
			drawLabel({
				x = x - 5 - self.labels.time.total.w - 8,
				y = y - 4,
				align = 'right',
				alpha = introAlpha,
				color = 'white',
				label = self.labels.time.current,
			});

			drawLabel({
				x = x - 5,
				y = y - 4,
				align = 'right',
				alpha = introAlpha,
				color = 'white',
				label = self.labels.time.total,
			});
		end

		y = y + (self.labels.artist.h * 1.425);
	
		drawLabel({
			x = x,
			y = y,
			align = 'right',
			alpha = introAlpha,
			color = 'normal',
			label = self.labels.bpm.value,
		});

		drawLabel({
			x = x + self.stats.x,
			y = y - 1,
			align = 'right',
			alpha = introAlpha,
			color = 'white',
			label = self.labels.bpm.label,
		});

		if (game.GetButton(game.BUTTON_STA) and showAdjustments) then
			if (game.GetButton(game.BUTTON_BTB)) then
				drawLabel({
					x = x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'normal',
					label = self.labels.hidden.cutoff.value,
				});

				drawLabel({
					x = x,
					y = y + self.stats.y * 2,
					align = 'right',
					alpha = introAlpha,
					color = 'normal',
					label = self.labels.sudden.cutoff.value,
				});

				drawLabel({
					x = x + self.stats.x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'white',
					label = self.labels.hidden.cutoff.label,
				});

				drawLabel({
					x = x + self.stats.x,
					y = y + (self.stats.y * 2),
					align = 'right',
					alpha = introAlpha,
					color = 'white',
					label = self.labels.sudden.cutoff.label,
				});
			elseif (game.GetButton(game.BUTTON_BTC)) then
				drawLabel({
					x = x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'normal',
					label = self.labels.hidden.fade.value,
				});

				drawLabel({
					x = x,
					y = y + self.stats.y * 2,
					align = 'right',
					alpha = introAlpha,
					color = 'normal',
					label = self.labels.sudden.fade.value,
				});

				drawLabel({
					x = x + self.stats.x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'white',
					label = self.labels.hidden.fade.label,
				});

				drawLabel({
					x = x + self.stats.x,
					y = y + (self.stats.y * 2),
					align = 'right',
					alpha = introAlpha,
					color = 'white',
					label = self.labels.sudden.fade.label,
				});
			else
				drawLabel({
					x = x + self.stats.x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'white',
					label = self.labels.hispeed.adjust,
				});

				drawLabel({
					x = x,
					y = y + self.stats.y,
					align = 'right',
					alpha = introAlpha,
					color = 'normal',
					label = self.labels.hispeed.value,
				});
			end
		else
			drawLabel({
				x = x + self.stats.x,
				y = y + self.stats.y,
				align = 'right',
				alpha = introAlpha,
				color = 'white',
				label = self.labels.hispeed.label,
			});

			drawLabel({
				x = x,
				y = y + self.stats.y,
				align = 'right',
				alpha = introAlpha,
				color = 'normal',
				label = self.labels.hispeed.value,
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

local showHitWindows = getSetting('showHitWindows', true);
local scoreDifferencePosition = getSetting('scoreDifferencePosition', 'LEFT');
local showScoreDifference = getSetting('showScoreDifference', false);
local showUserInfo = getSetting('showUserInfo', false);
local username = getSetting('displayName', 'GUEST');

local userInfo = {
	isAdditive = true,
	labels = nil,
	timer = 0,
	x = {},

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {
				hitWindows = {
					label = New.Label({
						font = 'medium',
						text = 'HIT WINDOWS',
						size = 18,
					}),
					value = New.Label({
						font = 'number',
						text = string.format(
							'±%d / %d ms',
							get(gameplay, 'hitWindow.perfect', 46),
							get(gameplay, 'hitWindow.good', 92)
						),
						size = 24,
					}),
				},
				player = New.Label({
					font = 'medium',
					text = 'PLAYER',
					size = 18,
				}),
				scoreDifference = New.Label({
					font = 'medium',
					text = 'SCORE DIFFERENCE',
					size = 18,
				}),
			};

			if (gameplay.autoplay) then
				self.labels.username = New.Label({
					font = 'normal',
					text = 'AUTOPLAY',
					size = 36,
				});
			else
				self.labels.username = New.Label({
					font = 'normal',
					text = string.upper(username),
					size = 36,
				});
			end

			self.labels.prefixes = {
				minus = New.Label({
					font = 'number',
					text = '-',
					size = 46,
				}),
				plus = New.Label({
					font = 'number',
					text = '+',
					size = 36,
				}),
			};

			if (scoreDifferencePosition == 'LEFT') then
				self.labels.difference = ScoreNumber.New({
					isScore = true,
					sizes = { 46, 36 }
				});
			else
				self.labels.difference = {
					large = {
						New.Label({
							font = 'number',
							text = '0',
							size = 50,
						}),
						New.Label({
							font = 'number',
							text = '0',
							size = 50,
						}),
						New.Label({
							font = 'number',
							text = '0',
							size = 50,
						}),
					},
					small = New.Label({
						font = 'number',
						text = '0',
						size = 40,
					}),
				};
			end
		end
	end,

	drawUserInfo = function(self, deltaTime)
		-- Kind of a jank solution but needs to be done to account for non-additive
		-- scoring:
		-- 	Subtractive: Starting a chart with 10,000,000 score
		-- 	Average: 5% into a chart with a score greater than 2,000,000
		if (((gameplay.progress == 0) and (scoreInfo.current == 10000000))
			or ((gameplay.progress <= 0.05) and (scoreInfo.current >= 2000000))
		) then
			self.isAdditive = false;
		end

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

		drawLabel({
			x = 0,
			y = y,
			alpha = 255 * self.timer,
			color = 'normal',
			label = self.labels.player,
		});

		y = y + (self.labels.player.h * 1.125);

		drawLabel({
			x = 0,
			y = y,
			alpha = 255 * self.timer,
			color = 'white',
			label = self.labels.username,
		});

		if (showScoreDifference and gameplay.scoreReplays[1]) then
			local difference = 0;

			if (self.isAdditive) then
				difference = scoreInfo.current - gameplay.scoreReplays[1].currentScore;
			else
				difference = scoreInfo.current - gameplay.scoreReplays[1].maxScore;
			end

			local prefix = ((difference < 0) and 'minus') or 'plus';
			
			if (scoreDifferencePosition == 'LEFT') then
				self.labels.difference:setInfo({ value = math.abs(difference) });
			else
				local diffString = string.format('%08d', math.abs(difference));

				self.labels.difference.large[1]:update({ new = diffString:sub(2, 2) });
				self.labels.difference.large[2]:update({ new = diffString:sub(3, 3) });
				self.labels.difference.large[3]:update({ new = diffString:sub(4, 4) });
				self.labels.difference.small:update({ new = diffString:sub(5, 5) });
			end

			if (scoreDifferencePosition == 'LEFT') then
				y = y + (self.labels.username.h * 1.75);

				drawLabel({
					x = 0,
					y = y,
					alpha = 255 * self.timer,
					color = 'normal',
					label = self.labels.scoreDifference,
				});

				y = y + self.labels.scoreDifference.h;

				if (difference ~= 0) then
					drawLabel({
						x = ((prefix == 'plus') and 0) or 6,
						y = y + ((prefix == 'plus' and (self.labels.prefixes.plus.h * 0.125))
						or -4),
						alpha = 255 * self.timer,
						color = ((prefix == 'plus') and 'white') or 'red',
						label = self.labels.prefixes[prefix],
					});
				end

				self.labels.difference:draw({
					x = self.labels.prefixes.plus.w + 4,
					y1 = y,
					y2 = y + 10,
					alpha = 255 * self.timer,
					color = ((prefix == 'plus') and 'normal') or 'red',
					offset = 6,
				});
			else
				local abs = math.abs(difference);
				local differenceX = (scaledW / 2) - initialX;
				local differenceY = (scaledH / 2) - initialY;
				local width = self.labels.difference.large[1].w * 0.85;

				if (scoreDifferencePosition == 'TOP') then
					differenceY = differenceY - (scaledH * 0.35);
				elseif (scoreDifferencePosition == 'MIDDLE') then
					differenceY = differenceY + (scaledH * 0.165);
				elseif (scoreDifferencePosition == 'BOTTOM') then
					differenceY = differenceY + (scaledH * 0.35);
				end

				if (abs ~= 0) then
					drawLabel({
						x = differenceX - (width * 2.95),
						y = differenceY + (((prefix == 'plus') and 0) or -5),
						align = 'middle',
						alpha = 255 * self.timer,
						color = ((prefix == 'plus') and 'white') or 'red',
						label = self.labels.prefixes[prefix],
					});
				end

				drawLabel({
					x = differenceX - (width * 1.75),
					y = differenceY,
					align = 'middle',
					alpha = (((abs > 1000000) and 255) or 50) * self.timer,
					color = 'white',
					label = self.labels.difference.large[1],
				});

				drawLabel({
					x = differenceX - (width * 0.6),
					y = differenceY,
					align = 'middle',
					alpha = (((abs > 100000) and 255) or 50) * self.timer,
					color = 'white',
					label = self.labels.difference.large[2],
				});

				drawLabel({
					x = differenceX + (width * 0.6),
					y = differenceY,
					align = 'middle',
					alpha = (((abs > 10000) and 255) or 50) * self.timer,
					color = 'white',
					label = self.labels.difference.large[3],
				});

				drawLabel({
					x = differenceX + (width * 1.75),
					y = differenceY + 4.5,
					align = 'middle',
					alpha = (((abs > 1000) and 255) or 50) * self.timer,
					color = ((prefix == 'plus') and 'normal') or 'red',
					label = self.labels.difference.small,
				});
			end
		end

		if (showHitWindows) then
			if (showScoreDifference and (scoreDifferencePosition == 'LEFT')) then
				y = y + (self.labels.difference.labels[5].h * 1.65);
			else
				y = y + (self.labels.username.h * 1.75);
			end

			drawLabel({
				x = 0,
				y = y,
				alpha = 255 * self.timer,
				color = 'normal',
				label = self.labels.hitWindows.label,
			});

			y = y + (self.labels.hitWindows.label.h * 1.25);

			drawLabel({
				x = 0,
				y = y,
				alpha = 255 * self.timer,
				color = 'white',
				label = self.labels.hitWindows.value,
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

	scoreInfo:drawScore(deltaTime);

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
		drawRectangle({
			x = 0,
			y = 0,
			w = scaledW,
			h = scaledH,
			alpha = 150 * math.min(outroTimer, 1),
			color = 'black',
			fast = true,
		});

		drawLabel({
			x = scaledW / 2,
			y = scaledH / 2,
			align = 'middle',
			alpha = 255 * math.min(outroTimer, 1),
			color = 'white',
			label = clearStates[clearStatus],
		});

		outroTimer = outroTimer + deltaTime;

		return (outroTimer > 2), (1 - outroTimer);
	else
		outroTimer = outroTimer + deltaTime;

		return (outroTimer > 2), 1;
	end
end

laser_alert = function(rightAlert)
	if ((rightAlert) and (alerts.timers[2] < -1)) then
		alerts.timers[2] = 1;
	elseif (alerts.timers[1] < -1) then
		alerts.timers[1] = 1;
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
	scoreInfo.current = newScore;
end

----------------------------------------
-- MULTIPLAYER
----------------------------------------

local JSON = require('lib/JSON');

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

	local data = JSON.decode(res.text);

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
				self.labels[i] = {
					name = New.Label({
						font = 'normal',
						text = 'NAME',
						size = 24,
					}),
				};
	
				self.labels[i].score = ScoreNumber.New({
					isScore = true,
					sizes = { 46, 36 },
				});
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

			self.labels[i].name:update({ new = string.upper(user.name) });

			self.labels[i].score:setInfo({ value = user.score });

			drawLabel({
				x = 1,
				y = y,
				alpha = alpha,
				color = 'normal',
				label = self.labels[i].name,
			});
	
			y = y + self.labels[i].name.h;

			self.labels[i].score:draw({
				x = 0,
				y1 = y,
				y2 = y + 10,
				alpha = alpha,
				offset = 6,
			});
	
			y = y + (self.labels[i].score.labels[1].h * 1.25);
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

	practice.labels.mission.description:update({
		new = string.upper(description),
	});
end

practice_end_run = function(playCount, passCount, passed, scoreInfo)
	practice.counts.plays = playCount;
	practice.counts.passes = passCount;

	practice.labels.passRate.ratio:update({ new = string.format('%d/%d', passCount, playCount) });

	practice.labels.passRate.value:update({
		new = string.format('%.1f%%', (passCount / playCount) * 100),
	});

	practice.labels.score.value:setInfo({ value = scoreInfo.score });

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