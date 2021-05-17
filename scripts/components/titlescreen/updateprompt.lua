local Cursor = require('components/common/cursor');
local DialogBox = require('components/common/dialogbox');

local dialogBox = DialogBox:new();

local viewUpdate = function()
	if (package.config:sub(1, 1) == '\\') then
		local updateUrl = game.UpdateAvailable();

		if (updateUrl) then os.execute('start ' .. updateUrl); end
	else
		os.execute('xdg-open ' .. updateUrl);
	end
end

---@class UpdatePromptClass
local UpdatePrompt = {
	-- UpdatePrompt constructor
	---@param this UpdatePromptClass
	---@param window Window
	---@param mouse Mouse
	---@param state Titlescreen
	---@return UpdatePrompt
	new = function(this, window, mouse, state)
		---@class UpdatePrompt : UpdatePromptClass
		---@field mouse Mouse
		---@field state Titlescreen
		---@field window Window 
		local t = {
			btns = nil,
			cache = { w = 0, h = 0 },
			cursor = Cursor:new({
				size = 10,
				stroke = 1.5,
				type = 'horizontal',
			}),
			heading = makeLabel('norm', 'A NEW UPDATE IS AVAILABLE', 36),
			images = {
				btnH = Image:new('buttons/short_hover.png'),
				btn = Image:new('buttons/short.png'),
			},
			margin = 0,
			mouse = mouse,
			state = state,
			timer = 0,
			window = window,
			x = {},
			y = 0,
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Sets the sizes for the current component
	---@param this UpdatePrompt
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			dialogBox:setSizes(this.window.w, this.window.h, this.window.isPortrait);

			this.margin = (dialogBox.w.outer - (this.images.btn.w * #this.btns))
				/ (#this.btns + 1);

			this.x[3] = dialogBox.x.outerRight - this.images.btn.w;
			this.x[2] = this.x[3] - (this.images.btn.w + this.margin);
			this.x[1] = this.x[2] - (this.images.btn.w + this.margin);
			this.y = dialogBox.y.bottom - this.images.btn.h + 8;

			this.cursor:setSizes({
				x = this.x[1] + 4,
				y = this.y + 4,
				w = this.images.btn.w - 8,
				h = this.images.btn.h - 8,
				margin = this.margin + 8,
			});

			this.cache.w = this.window.w;
			this.cache.h = this.window.h;
		end
	end,

	-- Make the buttons and their events
	---@param this UpdatePrompt
	makeBtns = function(this)
		if (not this.btns) then
			---@type Button[]
			this.btns = {
				{
					event = Menu.Update,
					label = makeLabel('med', 'UPDATE'),
				},
				{
					event = viewUpdate,
					label = makeLabel('med', 'VIEW'),
				},
				{
					event = function()
						this.state:set({
							currBtn = 1,
							currPage = 'mainMenu',
							promptUpdate = false,
						});
					end,
					label = makeLabel('med', 'CLOSE'),
				},
			};
		end
	end,

	-- Draw a button
	---@param this UpdatePrompt
	---@param i integer
	---@param btn Button
	drawBtn = function(this, i, btn)
		if ((not btn) or (not this.btns[this.state.currBtn])) then return; end

		local isActive = btn.event == this.btns[this.state.currBtn].event;
		local isHovering = this.mouse:clipped(
			this.x[i],
			this.y,
			this.images.btn.w,
			this.images.btn.h
		);

		if (isHovering or isActive) then
			this.state:set({
				currBtn = i;
				btnEvent = btn.event;
				isClickable = isHovering;
			})

			this.images.btnH:draw({ x = this.x[i], y = this.y });
		else
			this.images.btn:draw({
				x = this.x[i],
				y = this.y,
				alpha = 0.45,
			});
		end

		btn.label:draw({
			x = this.x[i] + (this.images.btn.w / 6),
			y = this.y + (this.images.btn.h / 2) - 12,
			alpha = 255 * ((isActive and 1) or 0.2),
			color = 'white',
		});
	end,

	-- Renders the current component
	---@param this UpdatePrompt
	---@param dt deltaTime
	render = function(this, dt)
		this:makeBtns();

		this:setSizes();

		this.timer = math.min(this.timer + (dt * 3), 1);

		drawRect({
			w = this.window.w,
			h = this.window.h,
			alpha = 150 * this.timer,
			color = 'black',
		});

		dialogBox:draw({
			x = this.window.w / 2,
			y = this.window.h / 2,
			alpha = this.timer,
			centered = true,
		});

		this.heading:draw({
			x = dialogBox.x.outerLeft,
			y = dialogBox.y.top - 8,
			alpha = 255 * this.timer,
			color = 'white',
		});

		for i, btn in ipairs(this.btns) do this:drawBtn(i, btn); end

		this.cursor:render(dt, { curr = this.state.currBtn, total = #this.btns });

		this.state.btnCount = #this.btns;
	end,
};

return UpdatePrompt;