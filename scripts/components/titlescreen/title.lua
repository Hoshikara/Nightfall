game.LoadSkinSample('intro');

local Spinner = require('components/common/spinner');

---@class TitleClass
local Title = {
	-- Title constructor
	---@param this TitleClass
	---@param window Window
	---@param state Titlescreen
	---@return Title
	new = function(this, window, state)
		---@class Title : TitleClass
		---@field labels table<string, Label>
		---@field state Titlescreen
		---@field window Window
		local t = {
			alpha = 0,
			cache = { w = 0, h = 0 },
			labels = {
				checking = makeLabel('med', 'CHECKING FOR UPDATES'),
				game = makeLabel('med', 'UNNAMED SDVX CLONE', 31),
				skin = makeLabel('med', 'NIGHTFALL', 120),
				version = makeLabel('num', SkinVersion, 20),
			},
			spinner = Spinner:new(),
			state = state,
			timers = { alpha = 0, fade = 1.2 },
			window = window,
			x = 0,
			y = 0,
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
  end,

	-- Sets the sizes for the current component
	---@param this Title
	setSizes = function(this)
		if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
			if (this.window.isPortrait) then
				this.x = this.window.w / 11;	
			else
				this.x = this.window.padding.x;
			end

			this.y = this.window.h / 4;

			this.cache.w = this.window.w;
			this.cache.h = this.window.h;
		end
	end,

	-- Load the title and check for updates
	---@param this Title
	---@param dt deltaTime
	load = function(this, dt)
		if (this.state.loaded) then return; end

		local x = this.window.w - this.window.padding.x;
		local y = this.window.h - this.window.padding.y - this.labels.checking.h;

		if (not this.state.samplePlayed) then
			game.PlaySample('intro');
	
			this.state.samplePlayed = true;
		end
	
		if (not this.state.checkedUpdate) then
			local updateUrl = game.UpdateAvailable();
	
			if (updateUrl) then
				this.state:set({ checkedUpdate = true, promptUpdate = true });
			end
		end
	
		this.timers.fade = to0(this.timers.fade, dt, 1.8);
	
		drawRect({
			w = this.window.w,
			h = this.window.h,
			alpha = 255 * this.timers.fade,
			color = 'black',
		});

		this.labels.checking:draw({
			x = x,
			y = y,
			align = 'right',
			color = 'white',
		});

		this.spinner:render(dt, x - this.labels.checking.w - 12, y - 1);
	
		this.state.loaded = this.timers.fade == 0;
	end,

	-- Renders the current component
	---@param this Title
	---@param dt deltaTime
	render = function(this, dt)
		this:load(dt);

		if (not this.state.loaded or this.state.promptUpdate) then return end;

		this:setSizes();

		this.timers.alpha = this.timers.alpha + dt;

		this.alpha = math.floor(this.timers.alpha * 30) % 2;
		this.alpha = ((this.alpha * 55) + 200) / 255;
	
		if (this.timers.alpha >= 0.22) then this.alpha = 1; end
		
		local alpha = 255 * this.alpha;

		if (this.state.viewingControls or this.state.viewingInfo) then
			alpha = 30;
		end

		this.labels.game:draw({
			x = this.x + 8,
			y = this.y,
			alpha = alpha,
			maxWidth = (this.labels.skin.w * 0.54) - 3,
		});
		
		this.labels.skin:draw({
			x = this.x,
			y = this.y + (this.labels.game.h * 0.25),
			alpha = alpha,
			color = 'white',
		});

		this.labels.version:draw({
			x = this.x + this.labels.skin.w + 4,
			y = this.y
				+ (this.labels.game.h * 0.25)
				+ this.labels.skin.h
				- (this.labels.version.h * 0.5)
				- 3,
			align = 'left',
			alpha = alpha,
			color = 'white',
		});
	end,
};

return Title;