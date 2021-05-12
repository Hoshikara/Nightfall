local Constants = require('constants/controls');

local Pages = {
	'GENERAL',
	'SONG SELECT',
	'GAMEPLAY SETTINGS',
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
			currBtn = 0,
			labels = {
				action = makeLabel('med', 'ACTION', 30),
				close = makeLabel('med', 'CLOSE', 24),
				controller = makeLabel('med', 'CONTROLLER', 30),
				heading = makeLabel('med', 'CONTROLS', 60),
				keyboard = makeLabel('med', 'KEYBOARD', 30),
				startEsc = makeLabel('med', '[START]  /  [ESC]', 24),
			},
			lists = {},
			maxWidth = 0,
			mouse = mouse,
			state = state,
			timer = 0,
			window = window,
		};

		for i, page in ipairs(Pages) do
			t.btns[i] = {
				event = function() t.state:set({ currBtn = i }); end,
				label = makeLabel('med', page, 36),
			};

			t.lists[i] = {};

			for j, control in ipairs(Constants[page]) do
				---@class Control
				---@field lineBreak boolean
				---@field note boolean
				local c = {
					action = makeLabel('norm', control.action),
					controller = makeLabel('med', control.controller, 24),
					keyboard = makeLabel('med', control.keyboard, 24),
					lineBreak = control.lineBreak,
					note = control.note,
				};

				t.lists[i][j] = c;
			end
		end

		setmetatable(t, this);
		this.__index = this;

		return t;
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
				y = y - 2,
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
	---@param x number
	---@param y number
	drawControls = function(this, list, x, y)
		this.labels.controller:draw({
			x = x,
			y = y,
			color = 'white',
		});

		this.labels.keyboard:draw({
			x = x + 350,
			y = y,
			color = 'white',
		});

		this.labels.action:draw({
			x = x + 700,
			y = y,
			color = 'white',
		});

		y = y + 60;

		for i, control in ipairs(list) do
			if (((i % 2) ~= 0) and (not control.note)) then
				drawRect({
					x = x - 12,
					y = y - 6,
					w = this.window.w / 1.6,
					h = 45,
					alpha = 50,
					color = 'norm',
					fast = true,
				});
			end

			control.controller:draw({
				x = x,
				y = y,
				color = (control.note and 'white') or 'norm',
			});

			control.keyboard:draw({
				x = x + 350,
				y = y,
				color = (control.note and 'white') or 'norm',
			});

			control.action:draw({
				x = x + 700,
				y = y,
				color = 'white',
			});

			y = y + ((control.lineBreak and 90) or 45);
		end
	end,

	-- Draw the navigation controls
	---@param this Controls
	drawNavigation = function(this)
		local x = this.window.w / 20;
		local y = this.window.h - (this.window.h / 10);

		this.labels.startEsc:draw({ x = x, y = y - 1 });

		this.labels.close:draw({
			x = x + this.labels.startEsc.w + 8,
			y = y,
			color = 'white',
		});
	end,

	-- Renders the current component
	---@param this Controls
	---@param dt deltaTime
	render = function(this, dt)
		if (this.currBtn ~= this.state.currBtn) then
			this.timer = 0;

			this.currBtn = this.state.currBtn;
		end

		this.timer = to1(this.timer, dt, 0.25);

		local x = this.window.w / 20;
		local y = this.window.h / 20;

		drawRect({
			w = this.window.w,
			h = this.window.h,
			alpha = 200,
			color = 'black',
			fast = true,
		});

		this.labels.heading:draw({
			x = x - 3,
			y = y,
			color = 'white',
		});

		y = y + (this.labels.heading.h * 2);

		for i, btn in ipairs(this.btns) do
			y = y + this:drawBtn(btn, x, y, i == this.state.currBtn);
		end

		x = x + this.maxWidth + 96;
		y = (this.window.h / 20) + (this.labels.heading.h * 2);

		this:drawControls(this.lists[this.state.currBtn], x, y);

		this:drawNavigation();

		this.state.btnCount = #this.btns;
	end,
};

return Controls;