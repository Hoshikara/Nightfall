local Cursor = require('components/common/cursor');

---@class Button
---@field event function
---@field label Label
local button = {};

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
			cache = { w = 0, h = 0 },
			cursor = Cursor:new({
				size = 12,
				stroke = 1.5,
				type = 'horizontal',
			}),
			btns = nil,
			images = {
				hover = Image:new('buttons/normal_hover.png'),
				normal = Image:new('buttons/normal.png'),
			},
			margin = 0,
			mouse = mouse,
			state = state,
			window = window,
			x = {},
			y = 0,
		};

		setmetatable(t, this);
		this.__index = this;
		
		return t;
	end,

	-- Sets the sizes for the current component
	---@param this Buttons
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			local width = this.window.w - (this.window.w / 6);
			local x = this.window.padding.x + 6;

			this.margin = (width - (this.images.normal.w * #this.btns.mainMenu))
				/ (#this.btns.mainMenu + 1);

			this.x[1] = x;
			this.y = this.window.h - (this.window.h / 4);

			for i = 2, 5 do
				x = x + this.images.normal.w + this.margin;

				this.x[i] = x;
			end

			this.cursor:setSizes({
				x = this.x[1] + 4,
				y = this.y + 4,
				w = this.images.normal.w - 8,
				h = this.images.normal.h - 8,
				margin = this.margin + 8,
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
								viewingInfo = true,
							});
						end,
						label = makeLabel('med', 'PLAYER INFO'),
					},
					{
						event = function()
							this.state:set({
								currBtn = 1,
								currPage = 'mainMenu',
							});
						end,
						label = makeLabel('med', 'MAIN MENU'),
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
		local btns = this.btns[this.state.currPage];
		local isNavigable = this.state.loaded
			and (not this.state.viewingControls)
			and (not this.state.viewingInfo);
		local isActionable = isNavigable and (not this.state.promptUpdate);
		local isActive = btn.event
			== (isNavigable and btns[this.state.currBtn].event);
		local isHovering = this.mouse:clipped(
			this.x[i],
			this.y,
			this.images.normal.w,
			this.images.normal.h
		);

		if (isActionable and (isHovering or isActive)) then
			this.state:set({
				currBtn = i,
				btnEvent = btn.event,
				isClickable = isHovering,
			});

			this.images.hover:draw({ x = this.x[i], y = this.y });
		else
			this.images.normal:draw({ x = this.x[i], y = this.y });
		end

		btn.label:draw({
			x = this.x[i] + (this.images.normal.w / 8),
			y = this.y + (this.images.normal.h / 2) - 12,
			alpha = 255 * ((isActionable and isActive and 1) or 0.2),
			color = 'white',
		});
	end,

	-- Renders the current component
	---@param this Buttons
	---@param dt deltaTime
	render = function(this, dt)
		this:makeBtns();

		this:setSizes();
	
		for i, btn in ipairs(this.btns[this.state.currPage]) do
			this:drawBtn(i, btn);
		end

		if (this.state.loaded
			and (not this.state.viewingControls)
			and (not this.state.viewingInfo)
			and (not this.state.promptUpdate)
		) then
			this.cursor:render(dt, {
				curr = this.state.currBtn,
				total = #this.btns[this.state.currPage],
			});
		end

		this.state.btnCount = #this.btns[this.state.currPage];
	end,
};

return Buttons;