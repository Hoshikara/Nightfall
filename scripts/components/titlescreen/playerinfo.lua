local Helpers = require('helpers/playerinfo');

local Constants = require('constants/playerinfo');
local Labels = require('constants/songwheel');

local DialogBox = require('components/common/dialogbox');
local List = require('components/common/list');

local Clears = Constants.clears;
local Grades = Constants.grades;
local Scores = Constants.scores;

local Order = {
	'title',
	'artist',
	'effector',
	'difficulty',
};

local ceil = math.ceil;
local floor = math.floor;
local min = math.min;

local dialogBox = DialogBox:new();

local jacketFallback = gfx.CreateSkinImage('loading.png', 0);

---@class PlayerInfoClass
local PlayerInfo = {
	-- PlayerInfo constructor
	---@param window Window
	---@param mouse Mouse
	---@param state Titlescreen
	---@return PlayerInfo
	new = function(this, window, mouse, state)
		---@class PlayerInfo : PlayerInfoClass
		---@field btns Button[]
		---@field charts nil|table<string, Label>[]
		---@field mouse Mouse
		---@field state Titlescreen
		---@field window Window
		local t = {
			btns = {},
			cache = { w = 0, h = 0 },
			category = nil,
			charts = nil,
			chartPage = 1,
			chartPages = 1,
			chartPageMax = 14,
			currBtn = 0,
			currFolder = 1,
			dropdown = {
				alphaTimer = 0,
				max = 18,
				offset = 0,
				timer = 0,
				w = 0,
				h = 0,
			},
			folderCache = {},
			hoverTimer = 0,
			jacket = nil,
			jacketSize = { 424, 240 },
			labels = {
				artist = makeLabel('med', 'ARTIST'),
				chartPage = makeLabel('num', '00', 20),
				chartTotal = makeLabel('num', '00', 30),
				click = makeLabel('med', 'CLICK TO VIEW CHARTS', 18),
				folder = makeLabel('med', 'FOLDER', 20),
				fxl = makeLabel('med', '[FX-L]', 20),
				noInfo = {
					heading = makeLabel('norm', 'NO INFO AVAILABLE', 40),
					desc1 = makeLabel(
						'norm',
						{
							{ color = 'white', text = 'PRESS' },
							{ color = 'norm', text = '[BT-D]' },
							{ color = 'white', text = 'DURING SONG SELECT TO' },
						},
						32
					),
					desc2 = makeLabel('norm', 'LOAD YOUR INFORMATION', 32),
				},
				page = makeLabel(
					'med',
					{
						{ color = 'white', text = 'PAGE' },
						{ color = 'norm', text = '[FX-L]  /  [FX-R]' },
					},
					20
				),
				play = {},
				player = makeLabel('med', getSetting('displayName', 'GUEST'), 60),
				title = makeLabel('med', 'TITLE'),
				top50Page = makeLabel('num', '00', 20),
			},
			level = nil,
			levels = {},
			list = List:new(),
			margin = 0,
			maxWidth = { 0, 0 },
			mouse = mouse,
			pressedFXL = false,
			pressedFXR = false,
			state = state,
			timer = 0,
			top50 = {},
			top50Page = 1,
			top50Pages = 1,
			top50PageMax = 3,
			viewingTop50 = false,
			window = window,
			x = { 0, 0, 0 },
			y = { 0, 0, 0 },
			w = { 0, 0 },
			h = { 0, 0 },
		};

		for k, v in pairs(Constants.labels) do
			t.labels[k] = makeLabel('med', v, 24);
		end

		for k, v in pairs(Labels) do t.labels.play[k] = makeLabel('med', v); end

		for i = 10, 20 do t.levels[i] = makeLabel('num', i, 30); end

		t.levels[21] = makeLabel('med', 'ALL', 30);

		if (state.hasInfo) then this:loadInfo(t); end

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Sets the sizes for the current component
	---@param this PlayerInfo
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			dialogBox:setSizes(this.window.w, this.window.h, this.window.isPortrait);

			this:makeBtns();

			this.w[1] = 0;

			for _, btn in ipairs(this.btns) do
				if (btn.label.w > this.w[1]) then this.w[1] = btn.label.w; end
			end

			if (this.window.isPortrait) then
				this.w[2] = this.window.w - (this.window.padding.x * 2);

				this.h[1] = this.window.h * 0.75;
				this.h[2] = this.h[1] // 22;

				this.x[1] = this.window.padding.x;
				this.x[2] = this.x[1] - 18;
				this.x[3] = this.window.w - this.window.padding.x;

				this.y[1] = this.window.padding.y;
				this.y[2] = this.window.padding.y * 6;
				this.y[3] = this.window.h - this.window.padding.y;

				this.jacketSize[1] = 480;
				this.jacketSize[2] = 240;

				this.chartPageMax = 28;
				this.top50PageMax = 5;
			else
				this.w[2] = this.window.w - (this.window.padding.x * 3.5) - this.w[1];

				this.h[1] = this.window.h - (this.window.padding.y * 5);
				this.h[2] = this.h[1] // 12;

				this.x[1] = this.window.padding.x;
				this.x[2] = this.x[1] + this.w[1] + (this.window.padding.x * 1.5);
				this.x[3] = this.window.w - this.window.padding.x;

				this.y[1] = this.window.padding.y;
				this.y[2] = this.window.padding.y * 3;
				this.y[3] = this.window.h - (this.window.padding.y * 1.25) + 6;

				this.jacketSize[1] = 424;
				this.jacketSize[2] = 240;

				this.chartPageMax = 14;
				this.top50PageMax = 3;
			end

			this.margin = (this.h[1] - (this.jacketSize[2] * this.top50PageMax))
				/ (this.top50PageMax - 1);

			this.list:setSizes({
				max = 1,
				shift = this.h[1] + this.margin,
			});
			
			this.cache.w = this.window.w;
			this.cache.h = this.window.h;
		end
	end,

	-- Make the tab buttons
	---@param this PlayerInfo
	makeBtns = function(this)
		local size = (this.window.isPortrait and 26) or 36;

		for i, page in ipairs(Constants.pages) do
			this.btns[i] = {
				event = function()
					this.state:set({ currBtn = i });

					this.viewingCharts = false;

					this:resetCharts();

					this.viewingTop50 = i == 5;
				end,
				label = makeLabel('med', page, size),
			};
		end
	end,

	-- Load and parse player information
	---@param this PlayerInfo
	---@param t PlayerInfo
	loadInfo = function(this, t)
		t = t or this;

		t.currFolder = 1;

		t.jacket = nil;
		t.bestPlay, t.top50 = Helpers.makeTop50(t.state.player.stats.top50);
		t.clears, t.grades, t.scores =
			Helpers.makeAllStats(t.state.player.stats.levels);

		t.playCount = {
			label = makeLabel('med', 'playCount'),
			val = makeLabel('num', t.state.player.stats.playCount, 30),
		};

		t.volforce = {
			label = makeLabel('med', 'VOLFORCE'),
			val = makeLabel('num', ('%.3f'):format(t.state.player.VF), 30),
		};

		t.folders = {};
		t.folderCache = {};

		if (t.dropdown) then
			t.dropdown.w = 0;
			t.dropdown.h = 0;
		end

		for i, name in ipairs(t.state.player.stats.folders) do
			local f = {
				sm = {
					event = function()
						t.state:set({ currBtn = i });
					end,
					name = makeLabel('norm', name)
				},
				lg = makeLabel('norm', name, 36),
			};

			if (t.dropdown) then
				if (f.sm.name.w > t.dropdown.w) then
					t.dropdown.w = f.sm.name.w;
				end

				if (i <= t.dropdown.max) then
					t.dropdown.h = t.dropdown.h + f.sm.name.h + 24;
				end
			end

			t.folders[i] = f;
		end

		if (t.dropdown) then
			t.dropdown.w = t.dropdown.w + 48;
			t.dropdown.h = t.dropdown.h + 24;
		end
	end,

	-- Draw the button for a tab
	---@param btn Button
	---@param x number
	---@param y number
	---@param isCurr boolean
	---@param isPortrait boolean
	---@return number
	drawBtn = function(this, btn, x, y, isCurr, isPortrait)
		if (isCurr) then
			drawRect({
				x = x - 12,
				y = y - ((isPortrait and 4) or 2),
				w = (this.w[1] + 48) * smoothstep(this.timer),
				h = btn.label.h + 16,
				alpha = 100,
				fast = true,
			});
		end

		btn.label:draw({
			x = x,
			y = y,
			alpha = (isCurr and 255) or 155,
			color = 'white',
		});

		if (this.mouse:clipped(
			x - 20,
			y - 10,
			btn.label.w + 40,
			btn.label.h + 30)
			and (not this.state.choosingFolder)
		) then
			this.state.btnEvent = btn.event;
		end

		if (isPortrait) then return this.w[1] + 48; end
		
		return btn.label.h * 2;
	end,

	-- Player info entry point
	---@param this PlayerInfo
	---@param dt deltaTime
	drawInfo = function(this, dt)
		local x = this.x[2];
		local y = this.y[2];

		if ((not this.state.viewingCharts) and this.charts) then
			this:resetCharts();
		end
		
		if (this.currBtn == 1) then
			this:drawOverview(
				this.bestPlay,
				this.labels.play,
				this.clears,
				this.grades,
				x,
				y
			);
		elseif (this.currBtn == 2) then
			if (this.charts) then
				this:drawCharts(x, y);
			else
				this:drawStats(dt, this.clears, true, x, y);
			end
		elseif (this.currBtn == 3) then
			if (this.charts) then
				this:drawCharts(x, y);
			else
				this:drawStats(dt, this.grades, false, x, y);
			end
		elseif (this.currBtn == 4) then
			this:drawScores(this.scores, x, y);
		elseif (this.currBtn == 5) then
			this:drawTop50(dt, this.top50);
		end
	end,

	-- Player info overview entry point
	---@param bestPlay TopPlayFormatted
	---@param labels table<string, Label>
	---@param clears PlayerStatsTable
	---@param grades PlayerStatsTable
	---@param x number
	---@param y number
	drawOverview = function(this, bestPlay, labels, clears, grades, x, y)
		x = x + 12;

		this:drawTotals(clears, grades, x + 1, y);

		if (bestPlay) then
			if (this.window.isPortrait) then
				y = y + this.jacketSize[1] * 0.8;
			else
				y = y + (this.jacketSize[1] / 1.25);
			end

			this:drawBestPlay(bestPlay, labels, x, y);
		end
	end,

		-- Draws the totals for the overview
	---@param this PlayerInfo
	---@param clears PlayerStatsTable
	---@param grades PlayerStatsTable
	---@param x number
	---@param y number
	drawTotals = function(this, clears, grades, x, y)
		this.labels.totals:draw({ x = x, y = y - (this.labels.totals.h * 1.5) });

		y = y + (this.labels.totals.h * 0.5);

		this.volforce.label:draw({ x = x, y = y });
		this.playCount.label:draw({ x = x + 216, y = y });

		y = y + (this.volforce.label.h * 1.35);

		this.volforce.val:draw({
			x = x,
			y = y,
			color = 'white',
		});

		this.playCount.val:draw({
			x = x + 216,
			y = y,
			color = 'white',
		});

		y = y + (this.volforce.val.h * 2);

		local xTemp = x;
		local yTemp = y;

		for i, clear in ipairs(Clears) do
			local curr = clears[clear];

			curr.label:draw({ x = xTemp, y = yTemp });

			curr.completed:draw({
				x = xTemp,
				y = yTemp + (curr.label.h * 1.35),
				color = 'white',
			});

			if (i == #Clears) then
				yTemp = yTemp + (curr.label.h * 1.35) + (curr.completed.h * 2);
			end

			xTemp = xTemp + 210;
		end

		xTemp = x;

		for _, grade in ipairs(Grades) do
			local curr = grades[grade];

			curr.label:draw({ x = xTemp, y = yTemp });

			curr.completed:draw({
				x = xTemp,
				y = yTemp + (curr.label.h * 1.35),
				color = 'white',
			});

			xTemp = xTemp + 140;
		end
	end,

	-- Draws the best play for the overview
	---@param bestPlay TopPlayFormatted
	---@param labels table<string, Label>
	---@param x number
	---@param y number
	drawBestPlay = function(this, bestPlay, labels, x, y)
		local isPortrait = this.window.isPortrait;
		local maxWidth = this.w[2] - this.jacketSize[1] - (this.window.w / 40);

		if (isPortrait) then maxWidth = this.w[2]; end

		if ((not this.jacket) or this.jacket == jacketFallback) then
			this.jacket = gfx.LoadImageJob(
				bestPlay.jacketPath,
				jacketFallback,
				this.jacketSize[1],
				this.jacketSize[1]
			);
		end

		this.labels.bestPlay:draw({ x = x, y = y });

		bestPlay.timestamp:draw({
			x = x + this.labels.bestPlay.w + 16,
			y = y,
			color = 'white',
		});

		y = y + (this.labels.bestPlay.h * 2);

		this.window:scale();

		drawRect({
			x = x + 3,
			y = y,
			w = this.jacketSize[1],
			h = this.jacketSize[1],
			image = this.jacket,
			stroke = { color = 'norm', size = 2 },
		});

		this.window:unscale();


		if (isPortrait) then
			y = y + this.jacketSize[1] + 24;
		else
			x = x + this.jacketSize[1] + (this.window.w / 40);
			y = y - 6;
		end

		for _, name in ipairs(Order) do
			if (name ~= 'difficulty') then
				labels[name]:draw({ x = x, y = y });
			else
				labels[name]:draw({ x = x, y = y });

				labels.bpm:draw({ x = x + 216, y = y });
			end

			y = y + (labels[name].h * 1.35);

			if (name == 'title') then
				bestPlay[name]:draw({
					x = x,
					y = y,
					color = 'white',
					maxWidth = maxWidth,
					size = 36,
					update = true,
				});
			else
				bestPlay[name]:draw({
					x = x,
					y = y,
					color = 'white',
					maxWidth = maxWidth,
				});
			end

			if (name == 'difficulty') then
				bestPlay.level:draw({
					x = x + bestPlay[name].w + 8,
					y = y,
					color = 'white',
				});

				bestPlay.bpm:draw({
					x = x + 216,
					y = y,
					color = 'white',
				});
			end

			y = y + (bestPlay[name].h * 2);
		end

		local yPrev = y;

		labels.grade:draw({ x = x, y = y });

		y = y + (labels.grade.h * 1.35);

		bestPlay.grade:draw({
			x = x,
			y = y,
			color = 'white',
		});

		y = y + (bestPlay.clear.h * 1.75) + 3;

		labels.clear:draw({ x = x, y = y });

		y = y + (labels.clear.h * 1.35);

		bestPlay.clear:draw({
			x = x,
			y = y,
			color = 'white',
		});

		x = x + 216;
		y = yPrev;

		labels.score:draw({ x = x, y = y });

		y = y + labels.score.h;

		bestPlay.score:draw({ x = x - 4, y = y - 14 });
	end,

	-- Gets alpha value for the given row
	---@param this PlayerInfo
	---@param hoveredRow integer
	---@param row integer
	---@param timer number
	---@return number alpha
	getRowAlpha = function(this, hoveredRow, row, timer)
		local a = 255 - (200 * timer);

		return ((hoveredRow ~= 0) and (hoveredRow ~= row) and a) or 255;
	end,

	-- Draws the clear or grade stats
	---@param this PlayerInfo
	---@param dt deltaTime
	---@param stats PlayerStatsTable
	---@param isClears boolean
	---@param x number
	---@param y number
	drawStats = function(this, dt, stats, isClears, x, y)
		local cols = {};
		local hovered = stats.hovered;
		local isPortrait = this.window.isPortrait;
		local xOffset = (isClears and 204) or 127.5;

		if (isPortrait) then xOffset = (isClears and 160) or 100; end

		local xTemp = x + xOffset;
		local yTemp = y;
		local w = this.w[2] + ((isPortrait and 36) or 0);
		local hBar = this.h[2];
		local hCat = this.labels.level.h * 1.5;

		for i = 1, ((isClears and 5) or 8) do cols[i] = y; end

		this.labels.level:draw({ x = x + 12, y = y - hCat });

		for i = 10, 21 do
			this.levels[i]:draw({
				x = x + 12,
				y = yTemp + (hBar / 2) + (((i < 21) and -2) or -5),
				align = 'leftMid',
				alpha = this:getRowAlpha(hovered.row, i, hovered.timer),
			});

			if ((i % 2) ~= 1) then
				drawRect({
					x = x,
					y = yTemp,
					w = w,
					h = hBar,
					alpha = 50,
					color = 'norm',
					fast = true,
				});
			end

			yTemp = yTemp + hBar;
		end

		for _, name in ipairs((isClears and Clears) or Grades) do
			for i = 10, 21 do
				local curr = stats[name][tostring(i)];

				if (hovered.key ~= '') then
					if (hovered.key == curr.key) then
						curr.alpha = 255;
					else
						curr.alpha = 255 - (200 * hovered.timer);
					end
				else
					curr.alpha = 255 - (200 * hovered.timer);
				end
			end
		end

		if ((hovered.row == 0) and (hovered.timer > 0)) then
			hovered.timer = to0(hovered.timer, dt, 0.1);
		else
			hovered.timer = to1(hovered.timer, dt, 0.1);
		end

		hovered.completed = nil;
		hovered.key = '';
		hovered.pct = nil;
		hovered.row = 0;

		for i, name in ipairs((isClears and Clears) or Grades) do
			stats[name].label:draw({
				x = xTemp,
				y = cols[i] - hCat,
				size = 24,
				update = true,
			});

			cols[i] = cols[i];

			for j = 10, 21 do
				local curr = stats[name][tostring(j)];

				if (curr.hoverable
					and this.mouse:clipped(
						xTemp - 16,
						cols[i] + 8,
						curr.completed.w + 32,
						hBar - 16)
					and (not this.state.choosingFolder)
				) then
					hovered.completed = curr.completed;
					hovered.key = curr.key;
					hovered.pct = curr.pct;
					hovered.row = j;

					this.state.btnEvent = function()
						this.state.viewingCharts = true;

						this.category = stats[name].label;
						this.charts = curr.charts;
						this.chartPage = 1;
						this.level = this.levels[j];
					end
				end

				curr.completed:draw({
					x = xTemp,
					y = cols[i] + (hBar / 2) - 2,
					align = 'leftMid',
					alpha = curr.alpha,
					color = 'white',
				});

				cols[i] = cols[i] + hBar;
			end

			xTemp = xTemp + xOffset;
		end

		this.labels.completed:draw({ x = xTemp, y = cols[#cols] - hCat });

		cols[#cols] = cols[#cols];

		for i = 10, 21 do
			local alpha = this:getRowAlpha(hovered.row, i, hovered.timer);
			local curr = stats[tostring(i)];

			(((i == hovered.row) and hovered.completed) or curr.completed):draw({
				x = xTemp,
				y = cols[#cols] + (hBar / 2) - 2,
				align = 'leftMid',
				alpha = alpha,
				color = 'white',
			});

			curr.total:draw({
				x = xTemp + 80,
				y = cols[#cols] + (hBar / 2) - 2,
				align = 'leftMid',
				alpha = alpha,
			});

			if (not isPortrait) then
				(((i == hovered.row) and hovered.pct) or curr.pct):draw({
					x = xTemp + 336,
					y = cols[#cols] + (hBar / 2) - 2,
					align = 'rightMid',
					alpha = alpha,
					color = 'white',
				});
			end

			cols[#cols] = cols[#cols] + hBar;
		end

		if (hovered.key ~= '') then
			this.hoverTimer = this.hoverTimer + dt;
		else
			this.hoverTimer = 0;
		end

		if (this.hoverTimer >= 0.4) then
			local scale = 1 / this.window:getScale();
			local x = this.mouse.x * scale;
			local y = this.mouse.y * scale;

			drawRect({
				x = x + 20,
				y = y - 28,
				w = 240,
				h = 28,
				alpha = 200,
				color = 'dark',
				fast = true,
			});

			this.labels.click:draw({
				x = x + 26,
				y = y - 25,
				color = 'white',
			});
		end
	end,

	-- Draw the list of charts of a level and category
	---@param this PlayerInfo
	---@param x number
	---@param y number
	drawCharts = function(this, x, y)
		local max = this.chartPageMax;
		local maxWidth = this.w[2] * 0.35;
		local yTemp = y;
		local w = this.w[2] + ((this.window.isPortrait and 36) or 0);
		local hCat = this.labels.level.h * 1.5;

		x = x + 12;

		this.labels.total:draw({ x = x, y = yTemp - hCat });

		this.labels.level:draw({ x = x + 160, y = yTemp - hCat });

		this.labels.category:draw({ x = x + 320, y = yTemp - hCat });

		this.labels.chartTotal:draw({
			x = x,
			y = yTemp - 5,
			color = 'white',
			text = #(this.charts or {}),
			update = true,
		});

		this.level:draw({
			x = x + 160,
			y = yTemp - 5,
			color ='white',
		});

		this.category:draw({
			x = x + 320,
			y = yTemp - 5,
			color ='white',
			size = 30,
			update = true,
		});

		yTemp = yTemp + (this.category.h * 2.5);

		this.labels.score:draw({ x = x, y = yTemp });
		this.labels.title:draw({ x = x + 200, y = yTemp });
		this.labels.artist:draw({ x = x + 200 + maxWidth + 36, y = yTemp });

		yTemp = yTemp + (this.labels.title.h * 2);

		for i = (1 + (max * (this.chartPage - 1))), (max * this.chartPage) do
			local curr = this.charts[i];

			if (not curr) then return; end

			if (((i % max) % 2) == 1) then
				drawRect({
					x = x - 12,
					y = yTemp - 9,
					w = w,
					h = 48,
					alpha = 50,
					color = 'norm',
					fast = true,
				});
			end

			curr.score:draw({ x = x, y = yTemp });

			curr.title:draw({
				x = x + 200,
				y = yTemp,
				color = 'white',
				maxWidth = maxWidth,
			});

			curr.artist:draw({
				x = x + 200 + maxWidth + 36,
				y = yTemp,
				color = 'white',
				maxWidth = maxWidth,
			});

			yTemp = yTemp + (curr.title.h * 2);
		end
	end,

	-- Draws the score stats
	---@param this PlayerInfo
	---@param scores PlayerScoreStats
	drawScores = function(this, scores, x, y)
		local cols = { y, y, y };
		local isPortrait = this.window.isPortrait;
		local xTemp = x + ((isPortrait and 144) or 200);
		local yTemp = y;
		local w = this.w[2];
		local hBar = this.h[2];
		local hCat = this.labels.level.h * 1.5;

		this.labels.level:draw({ x = x + 12, y = y - hCat });

		for i = 10, 20 do
			this.levels[i]:draw({
				x = x + 12,
				y = yTemp + (hBar / 2) - 2,
				align = 'leftMid',
			});

			if ((i % 2) ~= 1) then
				drawRect({
					x = x,
					y = yTemp,
					w = w,
					h = hBar,
					alpha = 50,
					color = 'norm',
					fast = true,
				});
			end

			yTemp = yTemp + hBar;
		end

		for i, score in ipairs(Scores) do
			scores[score].label:draw({ x = xTemp + 1, y = cols[i] - hCat });

			cols[i] = cols[i];

			for j = 10, 20 do
				local curr = scores[score][tostring(j)];

				if (curr.text) then
					curr:draw({
						x = xTemp + 3,
						y = cols[i] + 5,
						color = 'white'
					});
				else
					scores[score][tostring(j)]:draw({
						x = xTemp,
						y = cols[i] + 8,
					});
				end

				cols[i] = cols[i] + hBar;
			end

			xTemp = xTemp + ((isPortrait and 300) or 420);
		end
	end,

	-- Draws the top 50 plays
	---@param this PlayerInfo
	---@param dt deltaTime
	---@param top50 TopPlayFormatted[]
	drawTop50 = function(this, dt, top50)
		local max = this.top50PageMax;
		local y = this.y[2] + this.list.offset;

		if (this.window.isPortrait) then y = y - (this.labels.totals.h * 1.5); end

		for i, play in ipairs(top50) do
			y = y + this:drawTopPlay(y, play, (i % max) ~= 0, this.list:onPage(i / max));
		end
	end,

	-- Draw a top play
	---@param this PlayerInfo
	---@param y number
	---@param play TopPlayFormatted
	---@param drawSep boolean
	---@param isVis boolean
	drawTopPlay = function(this, y, play, drawSep, isVis)
		local size = this.jacketSize[2];
		local yTemp = y;

		if (isVis) then
			local x = this.x[2];
			local labels = this.labels.play;
			local maxWidth = this.w[2] - size - 36;
			local multi = (this.window.isPortrait and 0.975) or 1;

			if (this.window.isPortrait) then x = x + 14; end

			if ((not play.jacket) or (play.jacket == jacketFallback)) then
				play.jacket = gfx.LoadImageJob(
					play.jacketPath,
					jacketFallback,
					size,
					size
				);
			end

			this.window:scale();

			drawRect({
				x = x,
				y = y,
				w = size,
				h = size,
				image = play.jacket,
				stroke = { color = 'norm', size = 1 },
			});

			drawRect({
				x = x + 8,
				y = y + 8,
				w = 64,
				h = 52,
				alpha = 200,
				color = 'dark',
			});

			this.window:unscale();

			play.place:draw({
				x = x + 16,
				y = y + 10,
				color = 'white',
			});

			x = x + size + 36;

			y = y - 5;

			labels.title:draw({ x = x, y = y });

			y = y + (labels.title.h * 1.35);

			play.title:draw({
				x = x,
				y = y,
				color = 'white',
				maxWidth = maxWidth,
			});

			y = y + (play.title.h * 2);

			labels.difficulty:draw({ x = x, y = y });
			labels.bpm:draw({ x = x + (labels.difficulty.w * 2), y = y });
			this.volforce.label:draw({ x = x + (labels.difficulty.w * 3.25), y = y });

			y = y + (labels.difficulty.h * 1.35);

			play.difficulty:draw({
				x = x,
				y = y,
				color = 'white',
			});

			play.level:draw({
				x = x + play.difficulty.w + 8,
				y = y,
				color = 'white',
			});

			play.bpm:draw({
				x = x + (labels.difficulty.w * 2),
				y = y,
				color = 'white',
			});

			play.VF:draw({
				x = x + (labels.difficulty.w * 3.25),
				y = y,
				color = 'white',
			});

			y = y + (play.difficulty.h * 2);

			labels.score:draw({ x = x, y = y });
			labels.grade:draw({ x = x + (size * 1.825 * multi), y = y });
			labels.clear:draw({ x = x + (size * 2.5 * multi), y = y });

			play.grade:draw({
				x = x + (size * 1.825 * multi),
				y = y + (labels.grade.h * 1.35),
				color = 'white',
				size = this.window.isPortrait and 24,
				update = true,
			});

			play.clear:draw({
				x = x + (size * 2.5 * multi),
				y = y + (labels.clear.h * 1.35),
				color = 'white',
				size = this.window.isPortrait and 24,
				update = true,
			});

			y = y + (labels.score.h * 0.75);

			play.score:draw({ x = x - 4, y = y - 4 });

			if (drawSep) then
				this.window:scale();

				drawRect({
					x = this.x[2] + ((this.window.isPortrait and 12) or -1),
					y = yTemp + size + (this.margin / 2) - 1;
					w = this.w[2] + ((this.window.isPortrait and 12) or 0),
					h = 2,
					alpha = 100,
          color = 'norm',
				});

				this.window:unscale();
			end
		end

		return size + this.margin;
	end,

	-- Draw folder dropdown
	---@param this PlayerInfo
	---@param dt deltaTime
	---@param isPortrait boolean
	drawDropdown = function(this, dt, y, isPortrait)
		local dropdown = this.dropdown;
		local sign = (isPortrait and -1) or 1;
		local x = this.window.w - this.window.padding.x + 3;

		if (isPortrait) then x = this.x[1] - 5; end

		drawRect({
			x = x - (dropdown.w * sign),
			y = y,
			w = dropdown.w * sign,
			h = dropdown.h * dropdown.alphaTimer,
			alpha = 240,
			color = 'dark',
			fast = true,
		});

		y = y + 17 + dropdown.offset;

		for i, folder in ipairs(this.folders) do
			y = y + this:drawFolder(
				dt,
				folder.sm,
				i,
				x,
				y,
				sign,
				i == this.currFolder
			);
		end
	end,

	-- Draw a folder
	---@param this PlayerInfo
	---@param dt deltaTime
	---@param folder Label
	---@param i integer
	---@param x number
	---@param y number
	---@param sign integer
	---@param isCurr boolean
	drawFolder = function(this, dt, folder, i, x, y, sign, isCurr)
		local dropdown = this.dropdown;
		local isVis = true;

		if (this.currFolder > dropdown.max) then
			if ((i <= (this.currFolder - dropdown.max)) or (i > this.currFolder)) then
				isVis = false;
			end
		else
			isVis = (i <= dropdown.max);
		end
		
		if (isVis) then
			local alpha = floor(
				((isCurr and 255) or 150) * min(dropdown.alphaTimer ^ 2, 1)
			);
			local isPortrait = sign == -1;
			local maxWidth = this.w[2] - 32;
			local w = (dropdown.w - 32) * smoothstep(dropdown.timer);

			if (isCurr) then
				drawRect({
					x = x - (16 * sign),
					y = y + ((isPortrait and 1) or 0),
					w = -w * sign,
					h = 30,
					alpha = alpha * 0.4,
					color = 'norm',
					fast = true,
				});
			end

			if (this.mouse:clipped(
				x - (16 * sign) - ((isPortrait and 0) or w),
				y - 6,
				w,
				42)
			) then
				this.state.btnEvent = folder.event;
			end

			folder.name:draw({
				x = x - (24 * sign),
				y = y,
				align = (isPortrait and 'left') or 'right',
				alpha = alpha,
				color = 'white',
				maxWidth = maxWidth,
			});
		end

		return folder.name.h + 24;
	end,

	-- Draws navigation labels
	---@param this PlayerInfo
	drawNavigation = function(this, dt)
		local isPortrait = this.window.isPortrait;
		local x = this.x[1];
		local xLeft = this.x[1] - 5;
		local yTop = this.y[1] - 12;
		local yBot = this.y[3];

		if (isPortrait) then yTop = this.y[1] + (this.window.padding.y * 1.35); end
		
		this.labels.close:draw({
			x = x - ((isPortrait and 4) or 0),
			y = yBot - this.labels.close.h
		});

		if (this.state.hasInfo) then
			x = this.x[3];

			if (this.state.viewingCharts) then
				if (this.chartPages > 1) then
					this.labels.chartPage:draw({
						x = x,
						y = yBot - this.labels.chartPage.h + 4,
						align = 'right',
						color = 'white',
						text = ('%02d  /  %02d'):format(this.chartPage, this.chartPages),
						update = true,
					});

					this.labels.page:draw({
						x = x - this.labels.chartPage.w - 12,
						y = yBot - this.labels.page.h,
						align = 'right',
					});
				end
			elseif (this.viewingTop50) then
				if (this.top50Pages > 1) then
					this.labels.top50Page:draw({
						x = x,
						y = yBot - this.labels.top50Page.h + 4,
						align = 'right',
						color = 'white',
						text = ('%02d  /  %02d'):format(this.top50Page, this.top50Pages),
						update = true,
					});

					this.labels.page:draw({
						x = x - this.labels.top50Page.w - 12,
						y = yBot - this.labels.page.h,
						align = 'right',
					});
				end
			else
				this.labels.fxl:draw({
					x = (isPortrait and xLeft) or (x - this.labels.folder.w - 8),
					y = yTop,
					align = (isPortrait and 'left') or 'right',
				});
			end

			if (this.viewingTop50) then
				this.folders[2].lg:draw({
					x = (isPortrait and xLeft) or (x + 2),
					y = yTop + 24;
					align = (isPortrait and 'left') or 'right',
					color = 'white',
				});
			else
				local xFolder = x;

				if (isPortrait) then
					if (this.state.viewingCharts) then
						xFolder = xLeft;
					else
						xFolder = xLeft + this.labels.fxl.w + 8;
					end
				end
				
				this.labels.folder:draw({
					x = xFolder,
					y = yTop,
					align = (isPortrait and 'left') or 'right',
					color = 'white',
				});

				this.folders[this.currFolder].lg:draw({
					x = (isPortrait and xLeft) or (x + 2),
					y = yTop + 24;
					align = (isPortrait and 'left') or 'right',
					color = (this.state.choosingFolder and 'norm') or 'white',
				});

				if (this.dropdown.alphaTimer > 0) then
					this:drawDropdown(
						dt,
						yTop + 24 + this.folders[this.currFolder].lg.h + 16,
						isPortrait
					);
				end
			end
		end
	end,

	-- Loads the stats for the current folder
	---@param this PlayerInfo
	changeFolder = function(this)
		local folder = this.folderCache[this.currFolder];

		if (folder) then
			this.clears = folder.clears;
			this.grades = folder.grades;
			this.scores = folder.scores;
		else
			this.clears, this.grades, this.scores = Helpers.makeAllStats(
				this.state.player.stats.levels,
				this.state.player.stats.folders[this.currFolder]
			);

			this.folderCache[this.currFolder] = {
				clears = this.clears,
				grades = this.grades,
				scores = this.scores,
			};
		end
	end,

	-- Resets chart page information
	---@param this PlayerInfo
	resetCharts = function(this)
		this.category = nil;
		this.charts = nil;
		this.chartPage = 1;
		this.level = nil;
	end,

	-- Toggles controls from folder selection to tab selection
	---@param this PlayerInfo
	toggleSelection = function(this)
		if (this.state.choosingFolder) then
			this.state.currBtn = this.currFolder;
		else
			this.state.currBtn = this.currBtn;
		end
	end,

	-- Handles input and navigation around the screen
	---@param this PlayerInfo
	---@param dt deltaTime
	handleChange = function(this, dt)
		if (this.state.viewingCharts) then
			this.chartPages = ceil(
				(this.charts and (#this.charts / this.chartPageMax)) or 1);

			if ((not this.pressedFXL) and pressed('FXL')) then
				this.chartPage = advance(this.chartPage, this.chartPages, -1);
			end

			if ((not this.pressedFXR) and pressed('FXR')) then
				this.chartPage = advance(this.chartPage, this.chartPages, 1);
			end
		elseif (this.viewingTop50) then
			this.top50Pages = ceil(
				(this.top50 and (#this.top50 / this.top50PageMax)) or 1);

			if ((not this.pressedFXL) and pressed('FXL')) then
				this.top50Page = advance(this.top50Page, this.top50Pages, -1);
			end

			if ((not this.pressedFXR) and pressed('FXR')) then
				this.top50Page = advance(this.top50Page, this.top50Pages, 1);
			end

			this.list:handleChange(dt, { watch = this.top50Page });
		else
			if ((not this.pressedFXL) and pressed('FXL')) then
				this.state.choosingFolder = not this.state.choosingFolder;

				this:toggleSelection();
			end
		end

		this.pressedFXL = pressed('FXL');
		this.pressedFXR = pressed('FXR');

		if (this.state.choosingFolder) then
			this.dropdown.alphaTimer = to1(this.dropdown.alphaTimer, dt, 0.1);

			if (this.currFolder ~= this.state.currBtn) then
				this.dropdown.timer = 0;

				this.currFolder = this.state.currBtn;

				this:changeFolder();
			end

			this.dropdown.timer = to1(this.dropdown.timer, dt, 0.2);

			local delta = this.currFolder - this.dropdown.max;

			if (delta >= 1) then
				this.dropdown.offset = -(delta * (this.folders[1].sm.name.h + 24));
			else
				this.dropdown.offset = 0;
			end
		else
			if (this.dropdown.alphaTimer > 0) then
				this.dropdown.alphaTimer = to0(this.dropdown.alphaTimer, dt, 0.1);
			end

			if (this.currBtn ~= this.state.currBtn) then
				this.timer = 0;

				if (this.state.viewingCharts) then
					this.state.viewingCharts = false;

					this:resetCharts();
				end

				this.currBtn = this.state.currBtn;
			end

			this.timer = to1(this.timer, dt, 0.2);
		end

		this.viewingTop50 = (not this.state.choosingFolder) and (this.currBtn == 5);

		if (not this.viewingTop50) then this.top50Page = 1; end
	end,

	-- Renders the current component
	---@param this PlayerInfo
	---@param dt deltaTime
	render = function(this, dt)
		this:setSizes();

		local x = this.window.w / 20;
		local y = this.y[1];

		this.window:scale();

		drawRect({
			w = this.window.w,
			h = this.window.h,
			alpha = 225,
			color = 'black',
		});

		this.window:unscale();

		if (not this.state.hasInfo) then
			this.window:scale();

			dialogBox:render({
				x = this.window.w / 2,
				y = this.window.h / 2,
			});

			this.window:unscale();

			this.labels.noInfo.heading:draw({
				x = dialogBox.x.outerLeft,
				y = dialogBox.y.top - 8,
			});

			this.labels.noInfo.desc1:draw({
				x = dialogBox.x.outerLeft + 42,
				y = dialogBox.y.top + 64,
			});

			this.labels.noInfo.desc2:draw({
				x = dialogBox.x.outerLeft + 42,
				y = dialogBox.y.top + 64 + this.labels.noInfo.desc1.h + 16,
				color = 'white',
			});
		else
			this.labels.player:draw({
				x = x - 3,
				y = y - 12,
			});

			y = y + (this.labels.player.h * 2) - 17;

			if (this.state.refreshInfo) then
				this:loadInfo();

				this.state.refreshInfo = false;
			end

			this:handleChange(dt);

			if (this.window.isPortrait) then
				y = y + (this.window.padding.y * 1.5);

				for i, btn in ipairs(this.btns) do
					x = x + this:drawBtn(
						btn,
						x,
						y,
						i == this.currBtn,
						this.window.isPortrait
					);
				end
			else
				for i, btn in ipairs(this.btns) do
					y = y + this:drawBtn(
						btn,
						x,
						y,
						i == this.currBtn,
						this.window.isPortrait
					);
				end
			end

			this:drawInfo(dt);
		end

		this:drawNavigation(dt);

		if (this.state.hasInfo and this.state.choosingFolder) then
			this.state.btnCount = #this.state.player.stats.folders;
		else
			this.state.btnCount = #this.btns;
		end
	end,
};

return PlayerInfo;