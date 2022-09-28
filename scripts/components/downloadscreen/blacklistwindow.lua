local DialogBox = require('components/common/dialogbox');

local dialogBox = DialogBox:new();

---@class BlacklistWindowClass
local BlacklistWindow = {
	-- BlacklistWindow constructor
	---@param this BlacklistWindowClass
	---@param window Window
  ---@param state DownloadScreen
	---@return BlacklistWindow
	new = function(this, window, state)
		---@class BlacklistWindow : BlacklistWindowClass
		---@field window Window
		local t = {
			action = 'BLACKLISTING',
			heading = makeLabel('norm', 'CONFIRM BLACKLIST', 40),
			cancel = makeLabel(
				'med',
				{
					{ color = 'white', text = 'CANCEL' },
					{ color = 'norm', text = '[BACK / ESC]' },
				}
			),
			confirm = makeLabel(
				'norm',
				{
					{ color = 'white', text = 'PRESS' },
					{ color = 'norm', text = '[START]' },
					{ color = 'white', text = 'TO BLACKLIST' },
				},
				24
				
			),
			username = makeLabel('norm', '', 24),
			
			state = state,
			timer = 0,
			window = window,
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Draw the dialog window
	---@param this BlacklistWindow
	drawWindow = function(this)
		local alpha = this.timer

		this.window:scale();

		dialogBox:render({
			x = this.window.w / 2,
			y = this.window.h / 2,
			alpha = alpha,
		});

		this.window:unscale();

		this.heading:draw({
			x = dialogBox.x.outerLeft,
			y = dialogBox.y.top - 8,
			alpha = 255 * alpha,
		});
		this.confirm:draw({
			x = dialogBox.x.outerLeft + 42,
			y = dialogBox.y.top + 64,
			alpha = 255 * alpha,
		});
		this.username:draw({
			x = dialogBox.x.outerLeft + 42 + this.confirm.w + 24,
			y = dialogBox.y.top + 64,
			alpha = 255 * alpha,
			text = this.state.blacklistName:upper(),
			update = true,
		})
		this.cancel:draw({
			x = dialogBox.x.outerRight,
			y = dialogBox.y.bottom,
			align = 'right',
			alpha = 255 * alpha,
		});
	end,

	-- Handle navigation on and away from the current dialog window
	---@param this BlacklistWindow
	---@param dt deltaTime
	handleChange = function(this, dt)
		if (this.state.action == this.action) then
			this.timer = to1(this.timer, dt, 0.125);
		else
			if (this.timer > 0) then this.timer = to0(this.timer, dt, 0.167); end
		end
	end,

	-- Renders the current component
	---@param this BlacklistWindow
	---@param dt deltaTime
	render = function(this, dt)
		this:handleChange(dt);

		if (this.timer == 0) then return; end

		gfx.ForceRender();

		dialogBox:setSizes(this.window.w, this.window.h, this.window.isPortrait);

		gfx.Save();
		this:drawWindow();
		gfx.Restore();
	end,
};

return BlacklistWindow;
