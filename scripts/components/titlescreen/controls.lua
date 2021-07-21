local Constants = require('constants/controls');

local Pages = {
	'GENERAL',
	'SONG SELECT',
	'GAME SETTINGS',
	'GAMEPLAY',
	'RESULTS',
	'MULTIPLAYER',
	'NAUTICA',
};

---@class ControlsClass
local Controls = {
	-- Controls constructor
	---@param this ControlsClass
	---@param window Window
	---@param mouse Mouse
	---@param state Titlescreen
	---@return Controls
	new = function(this, window, mouse, state)
		---@class Controls : ControlsClass
		---@field labels table<string, Label>
		---@field mouse Mouse
		---@field state Titlescreen
		---@field window Window
		local t = {
			btns = {},
			cache = { w = 0, h = 0 },
			currBtn = 0,
			labels = {
				action = makeLabel('med', 'ACTION', 24),
				controller = makeLabel('med', 'CONTROLLER', 24),
				heading = makeLabel('med', 'CONTROLS', 60),
				keyboard = makeLabel('med', 'KEYBOARD', 24),
				close = makeLabel(
					'med',
					{
						{ color = 'norm', text = '[START]  /  [BACK]' },
						{ color = 'white', text = 'EXIT' },
					},
					24
				),
			},
			lists = {},
			maxWidth = 0,
			mouse = mouse,
			state = state,
			timer = 0,
			window = window,
			x = {},
			y = {},
			w = {},
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Sets the sizes for the current component
	---@param this Controls
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			this:makeBtns();

			this.w[1] = 0;

			for _, btn in ipairs(this.btns) do
				if (btn.label.w > this.w[1]) then this.w[1] = btn.label.w; end
			end

			if (this.window.isPortrait) then
				this.w[2] = this.window.w - (this.window.padding.x * 2);

				this.x[1] = this.window.padding.x;
				this.x[2] = this.x[1];

				this.y[1] = this.window.padding.y;
				this.y[2] = this.window.padding.y * 9.5;
			else
				this.w[2] = this.window.w - (this.window.padding.x * 3.5) - this.w[1];

				this.x[1] = this.window.padding.x;
				this.x[2] = this.x[1] + this.w[1] + (this.window.padding.x * 1.5);

				this.y[1] = this.window.padding.y;
				this.y[2] = this.window.padding.y * 3;
			end

			this.cache.w = this.window.w;
			this.cache.h = this.window.h;
		end
	end,

	-- Make the tab buttons
	makeBtns = function(this)
		local isPortrait = this.window.isPortrait;
		local sizeBtn = (isPortrait and 24) or 36;
		local sizeCtrl = (isPortrait and 20) or 24;

		for i, page in ipairs(Pages) do
			this.btns[i] = {
				event = function() this.state:set({ currBtn = i }); end,
				label = makeLabel('med', page, sizeBtn),
			};

			this.lists[i] = {};

			for j, control in ipairs(Constants[page]) do
				---@class Control
				---@field lineBreak boolean
				---@field note boolean
				local c = {
					action = makeLabel((isPortrait and 'med') or 'norm', control.action, sizeCtrl),
					controller = makeLabel('med', control.controller, sizeCtrl),
					keyboard = makeLabel('med', control.keyboard, sizeCtrl),
					lineBreak = control.lineBreak,
					note = control.note,
				};

				this.lists[i][j] = c;
			end
		end
	end,

	-- Draw a button for a tab
	---@param this Controls
	---@param btn Button
	---@param x number
	---@param y number
	---@param isCurr boolean
	drawBtn = function(this, btn, x, y, isCurr)
		if (isCurr) then
			drawRect({
				x = x - 12,
				y = y - 2 - ((this.window.isPortrait and 3) or 0),
				w = (this.maxWidth + 48) * smoothstep(this.timer),
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
		) then
			this.state.btnEvent = btn.event;
		end

		if (btn.label.w > this.maxWidth) then this.maxWidth = btn.label.w; end

		return btn.label.h * 2;
	end,

	-- Draw the list of controls
	---@param this Controls
	---@param list Control
	drawControls = function(this, list)
		local offset = (this.window.isPortrait and 290) or 350;
		local shift = (this.window.isPortrait and 2) or 0;
		local x = this.x[2];
		local y = this.y[2] - 50;

		this.labels.controller:draw({
			x = x,
			y = y,
			color = 'white',
		});

		this.labels.keyboard:draw({
			x = x + offset,
			y = y,
			color = 'white',
		});

		this.labels.action:draw({
			x = x + (offset * 2),
			y = y,
			color = 'white',
		});

		y = y + 43;

		for i, control in ipairs(list) do
			if (((i % 2) ~= 0) and (not control.note)) then
				drawRect({
					x = x - 12,
					y = y - 6,
					w = this.w[2] + 24,
					h = 45,
					alpha = 50,
					color = 'norm',
					fast = true,
				});
			end

			control.controller:draw({
				x = x,
				y = y + shift,
				color = (control.note and 'white') or 'norm',
			});

			control.keyboard:draw({
				x = x + offset,
				y = y + shift,
				color = (control.note and 'white') or 'norm',
			});

			control.action:draw({
				x = x + (offset * 2),
				y = y + shift,
				color = 'white',
			});

			y = y + ((control.lineBreak and 90) or 45);
		end
	end,

	-- Draw the navigation controls
	---@param this Controls
	drawNavigation = function(this)
		local x = this.x[1];
		local y = this.window.h - (this.window.padding.y * 1.25) + 6;

		if (this.window.isPortrait) then
			y = this.window.h - this.window.padding.y;
		end

		this.labels.close:draw({
			x = x - ((this.window.isPortrait and 4) or 0),
			y = y - this.labels.close.h
		});
	end,

	-- Renders the current component
	---@param this Controls
	---@param dt deltaTime
	render = function(this, dt)
		this:setSizes();

		if (this.currBtn ~= this.state.currBtn) then
			this.timer = 0;

			this.currBtn = this.state.currBtn;
		end

		this.timer = to1(this.timer, dt, 0.25);

		local x = this.x[1];
		local y = this.y[1];

		drawRect({
			w = this.window.w,
			h = this.window.h,
			alpha = 225,
			color = 'black',
			fast = true,
		});

		this.labels.heading:draw({ x = x - 3, y = y - 12 });

		y = y + (this.labels.heading.h * 2) - 17;

		for i, btn in ipairs(this.btns) do
			y = y + this:drawBtn(btn, x, y, i == this.state.currBtn);
		end

		this:drawControls(this.lists[this.state.currBtn]);

		this:drawNavigation();

		this.state.btnCount = #this.btns;
	end,
};

return Controls;