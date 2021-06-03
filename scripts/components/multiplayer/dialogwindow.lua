local DialogBox = require('components/common/dialogbox');

---@class DialogWindowClass
local DialogWindow = {
	confirm = makeLabel(
		'med',
		{
			{ color = 'white', text = 'CONFIRM' },
			{ color = 'norm', text = '[ENTER]' },
		}
	),
	dialogBox = DialogBox:new(),

	-- DialogWindow constructor
	---@param this DialogWindowClass
	---@param window Window
	---@param dialog table
	---@return DialogWindow
	new = function(this, window, dialog)
		---@class DialogWindow : DialogWindowClass
		---@field window Window
		local t = {
			cursor = {
				alpha = 0,
				timer = 0,
			},
			field = makeLabel('med', dialog.field),
			heading = makeLabel('norm', dialog.heading, 48),
			input = makeLabel('jp', '', 28),
			screen = dialog.screen,
			timer = 0,
			window = window,
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Draw the input field
	---@param this DialogWindow
	---@param dt deltaTime
	drawInput = function(this, dt)
		local alpha = 255 * this.timer;
		local offset = math.min(this.input.w + 2, this.dialogBox.w.middle - 20);
		local x = this.dialogBox.x.middleLeft;
		local y = this.dialogBox.y.center
			+ (this.dialogBox.h.outer / 10)
			+ (this.field.h * 2);
		local yField = this.dialogBox.y.center + (this.dialogBox.h.outer / 10);
		local w = this.dialogBox.w.middle;
		local h = this.dialogBox.h.outer / 6;

		this.window:scale();

		drawRect({
			x = x,
			y = y,
			w = w,
			h = h,
			alpha = alpha,
			color = 'dark',
			stroke = {
				alpha = alpha,
				color = 'norm',
				size = 1,
			};
		});

		drawRect({
			x = x + 8 + offset,
			y = y + 10,
			w = 2,
			h = h - 20,
			alpha = 255 * this.cursor.alpha,
			color = 'white',
		});

		this.window:unscale();

		gfx.Save();

		this.field:draw({
			x = x - 2,
			y = yField,
			alpha = alpha,
		});

		yField = yField + (this.field.h * 2);

		this.input:draw({
			x = x + 8,
			y = yField + 7,
			alpha = alpha,
			color = 'white',
			maxWidth = w - 22,
			text = textInput.text:upper(),
			update = true,
		});

		yField = yField + h;

		this.confirm:draw({
			x = this.dialogBox.x.middleRight + 2,
			y = yField + this.confirm.h + 1,
			align = 'right',
			alpha = alpha,
		});

		gfx.Restore();
	end,

	-- Draw the dialog window
	---@param this DialogWindow
	---@param dt deltaTime
	drawWindow = function(this, dt)
		this.window:scale();

		this.dialogBox:draw({
			x = this.window.w / 2,
			y = this.window.h / 2,
			alpha = this.timer,
			centered = true,
		});

		this.window:unscale();

		this.heading:draw({
			x = this.dialogBox.x.outerLeft,
			y = this.dialogBox.y.top - (this.heading.h * 0.25),
			alpha = 255 * this.timer,
			color =  'white',
		});

		this:drawInput(dt);
	end,

	-- Handle navigation on and away from the current dialog window
	---@param this DialogWindow
	---@param dt deltaTime
	---@param screen string
	handleChange = function(this, dt, screen)
		if (screen == this.screen) then
			this.timer = to1(this.timer, dt, 0.125);
		else
			if (this.timer > 0) then this.timer = to0(this.timer, dt, 0.167); end
		end

		this.cursor.timer = this.cursor.timer + dt;
		this.cursor.alpha = pulse(this.cursor.timer, 0.8, 0.2);
	end,

	-- Renders the current component
	---@param this DialogWindow
	---@param dt deltaTime
	---@param screen string
	render = function(this, dt, screen)
		this:handleChange(dt, screen);

		if (this.timer == 0) then return; end

		gfx.ForceRender();

		this.dialogBox:setSizes(this.window.w, this.window.h, this.window.isPortrait);

		gfx.Save();

		this:drawWindow(dt);

		gfx.Restore();
	end,
};

return DialogWindow;
