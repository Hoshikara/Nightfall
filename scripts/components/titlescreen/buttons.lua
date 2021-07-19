local Button = require('components/common/button');
local Cursor = require('components/common/cursor');

---@class ButtonsClass
local Buttons = {
	-- Buttons constructor
	---@param this ButtonsClass
	---@param window Window
	---@param mouse Mouse
	---@param state Titlescreen
	---@return Buttons
	new = function(this, window, mouse, state)
		---@class Buttons : ButtonsClass
		---@field mouse Mouse
		---@field state Titlescreen
		---@field window Window
		local t = {
			alpha = 1,
			allowAction = true,
			btns = nil,
			button = Button:new(258, 50),
			cache = { w = 0, h = 0 },
			currPage = 'mainMenu',
			cursor = Cursor:new({
				size = 12,
				stroke = 1.5,
				type = 'horizontal',
			}),
			margin = 0,
			mainMenu = makeLabel(
				'med',
				{
					{ color = 'norm', text = '[BACK]' },
					{ color = 'white', text = 'MAIN MENU' },
				},
				20
			),
			mouse = mouse,
			state = state,
			window = window,
			x = {},
			y = {},
		};

		setmetatable(t, this);
		this.__index = this;
		
		return t;
	end,

	-- Sets the sizes for the current component
	---@param this Buttons
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			local x = this.window.padding.x + 12;
			local y = this.window.h - (this.window.h / 3.5);
			local w = this.button.w;
			local h = this.button.h;

			if (this.window.isPortrait) then
				x = (this.window.w / 11) + 12;
				y = this.window.h / 2;
			end

			this.x[1] = x;
			this.y[1] = y;

			if (this.window.isPortrait) then
				local height = (this.window.h / 2) - (this.window.padding.y * 2);

				this.margin = (height - (h * #this.btns.mainMenu))
					/ (#this.btns.mainMenu + 1);

				for i = 2, 5 do
					y = y + h + this.margin;

					this.y[i] = y;
				end

				this.cursor.type = 'vertical';
			else
				local width = this.window.w - (this.window.w / 6);

				this.margin = (width - (w * #this.btns.mainMenu))
					/ (#this.btns.mainMenu + 1);

				for i = 2, 5 do
					x = x + w + this.margin;

					this.x[i] = x;
				end

				this.cursor.type = 'horizontal';
			end

			this.cursor.x.offset = 0;
			this.cursor.y.offset = 0;

			this.cursor:setSizes({
				x = this.x[1],
				y = this.y[1],
				w = w,
				h = h,
				margin = this.margin,
			});

			this.cache.w = this.window.w;
			this.cache.h = this.window.h;
		end
	end,

	-- Make the buttons and their events
	---@param this Buttons
	makeBtns = function(this)
		if (not this.btns) then
			this.btns = {
				mainMenu = {
					{
						event = function()
							this.state:set({
								currBtn = 1, 
								currPage = 'playOptions',
							});
						end,
						label = makeLabel('med', 'PLAY'),
					},
					{
						event = Menu.DLScreen,
						label = makeLabel('med', 'NAUTICA'),
					},
					{
						event = function()
							this.state:set({
								currBtn = 1,
								currPage = 'mainMenu',
								viewingControls = true,
							});
						end,
						label = makeLabel('med', 'CONTROLS'),
					},
					{
						event = Menu.Settings,
						label = makeLabel('med', 'SETTINGS'),
					},
					{
						event = Menu.Exit,
						label = makeLabel('med', 'EXIT'),
					},
				},
				playOptions = {
					{
						event = Menu.Start,
						label = makeLabel('med', 'SINGLEPLAYER'),
					},
					{
						event = Menu.Multiplayer,
						label = makeLabel('med', 'MULTIPLAYER'),
					},
					{
						event = Menu.Challenges,
						label = makeLabel('med', 'CHALLENGES'),
					},
					{
						event = function()
							this.state:set({
								currBtn = 1,
								currPage = 'playOptions',
								viewingPreview = true,
							});
						end,
						label = makeLabel('med', 'IN-GAME PREVIEW'),
					},
					{
						event = function()
							this.state:set({
								currBtn = 1,
								currPage = 'playOptions',
								viewingInfo = true,
							});
						end,
						label = makeLabel('med', 'PLAYER INFO'),
					},
				},
			};
		end
	end,

	-- Draw a button
	---@param this Buttons
	---@param i integer
	---@param btn Button
	drawBtn = function(this, i, btn)
		local x = this.x[i];
		local y = this.y[1];

		if (this.window.isPortrait) then
			x = this.x[1];
			y = this.y[i];
		end

		local btns = this.btns[this.currPage];
		local isNavigable = this.state.loaded
			and (not this.state.viewingControls)
			and (not this.state.viewingInfo)
			and (not this.state.viewingPreview);
		local isActionable = isNavigable and (not this.state.promptUpdate)
			and this.allowAction;
		local isActive = btn.event
			== (isNavigable and btns[this.state.currBtn].event);
		local isHovering = this.mouse:clipped(
			x,
			y,
			this.button.w,
			this.button.h
		);

		if (isActionable and (isHovering or isActive)) then
			this.state:set({
				currBtn = i,
				btnEvent = btn.event,
				isClickable = isHovering,
			});
		end

		this.button:render({
			x = x,
			y = y,
			accentAlpha = (((isActionable) and (isHovering or isActive) and 1)
				or 0.3) * this.alpha,
			alpha = this.alpha,
		});

		btn.label:draw({
			x = x + 24,
			y = y + (50 * 0.5) - 12,
			alpha = 255 * ((isActionable and isActive and 1) or 0.2) * this.alpha,
			color = 'white',
		});
	end,

	-- Handle the transition effect
	---@param this Buttons
	---@param dt deltaTime
	handleChange = function(this, dt)
		if (this.state.currPage == 'mainMenu') then
			if (this.currPage == 'playOptions') then
				this.alpha = to0(this.alpha, dt, 0.1);

				if (this.alpha == 0) then this.currPage = 'mainMenu'; end
			else
				this.alpha = to1(this.alpha, dt, 0.1);
			end
		elseif (this.state.currPage == 'playOptions') then
			if (this.currPage == 'mainMenu') then
				this.alpha = to0(this.alpha, dt, 0.1);

				if (this.alpha == 0) then this.currPage = 'playOptions'; end
			else
				this.alpha = to1(this.alpha, dt, 0.1);
			end
		end

		this.allowAction = this.alpha == 1;
	end,

	-- Renders the current component
	---@param this Buttons
	---@param dt deltaTime
	render = function(this, dt)
		this:makeBtns();

		this:setSizes();

		this:handleChange(dt);
	
		for i, btn in ipairs(this.btns[this.currPage]) do this:drawBtn(i, btn); end

		if ((this.currPage == 'playOptions') and (not this.state.viewingInfo)) then
			this.mainMenu:draw({
				x = this.x[1] + 4,
				y = this.window.h - (this.window.padding.y * 1.5),
				alpha = 255 * this.alpha,
			});
		end

		if (this.state.loaded
			and (not this.state.promptUpdate)
			and (not this.state.viewingControls)
			and (not this.state.viewingInfo)
			and (not this.state.viewingPreview)
		) then
			this.cursor:render(dt, {
				alphaMod = this.alpha,
				curr = this.state.currBtn,
				total = #this.btns[this.currPage],
			});
		end

		this.state.btnCount = #this.btns[this.currPage];
	end,
};

return Buttons;