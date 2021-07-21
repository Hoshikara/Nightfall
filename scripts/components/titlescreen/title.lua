game.LoadSkinSample('intro');

local Spinner = require('components/common/spinner');

local ChangelogURL = 'https://github.com/Hoshikara/Nightfall/blob/main/CHANGELOG.md';

local openChangelog = function()
	if (package.config:sub(1, 1) == '\\') then
		os.execute('start ' .. ChangelogURL);
	else
		os.execute('xdg-open ' .. ChangelogURL);
	end
end

---@class TitleClass
local Title = {
	-- Title constructor
	---@param this TitleClass
	---@param window Window
	---@param mouse Mouse
	---@param state Titlescreen
	---@return Title
	new = function(this, window, mouse, state)
		---@class Title : TitleClass
		---@field labels table<string, Label>
		---@field mouse Mouse
		---@field state Titlescreen
		---@field window Window
		local t = {
			alpha = 0,
			cache = { w = 0, h = 0 },
			labels = {
				checking = makeLabel('med', 'CHECKING FOR UPDATES'),
				click = makeLabel('med', 'CLICK TO VIEW NEW VERSION', 20),
				game = makeLabel('med', 'UNNAMED SDVX CLONE', 31),
				skin = makeLabel('med', 'NIGHTFALL', 120),
				version = makeLabel('num', SkinVersion, 20),
			},
			mouse = mouse,
			spinner = Spinner:new(),
			state = state,
			timers = {
				alpha = 0,
				fade = 1.2,
				version = 0,
			},
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

		this.spinner:render(dt, x - this.labels.checking.w - 21, y + 11);
	
		this.state.loaded = this.timers.fade == 0;
	end,

	-- Draw skin version number
	---@param this Title
	---@param dt deltaTime
	---@param x number
	---@param y number
	drawVersion = function(this, dt, alpha, x, y)
		local alphaMod;
		local color = 'white';

		if (this.state.newVersion) then
			this.timers.version = this.timers.version + dt;

			alphaMod = pulse(this.timers.version, 0.85, 0.2);
			color = 'neg';
		else
			alphaMod = 1;
		end

		this.labels.version:draw({
			x = x,
			y = y,
			alpha = alpha * alphaMod,
			color = color,
		});

		if (this.mouse:clipped(
			x,
			y,
			this.labels.version.w + 4,
			this.labels.version.h + 4
		)) then
			this.state:set({
				btnEvent = openChangelog,
				hoveringVersion = true,
				isClickable = true,
			});

			if (this.state.newVersion) then
				drawRect({
					x = x + this.labels.version.w,
					y = y - 29,
					w = -330,
					h = 28,
					alpha = 225,
					color = 'dark',
					fast = true,
				});
		
				this.labels.click:draw({
					x = x + this.labels.version.w - 6,
					y = y - 28,
					align = 'right',
					alpha = alpha,
					color = 'white',
				});
			end
		else
			this.state.hoveringVersion = false;
		end
	end,

	-- Renders the current component
	---@param this Title
	---@param dt deltaTime
	render = function(this, dt)
		this:load(dt);

		if (not this.state.loaded or this.state.promptUpdate) then return end;

		this:setSizes();

		local x = this.x;
		local y = this.y;

		this.timers.alpha = this.timers.alpha + dt;

		this.alpha = math.floor(this.timers.alpha * 30) % 2;
		this.alpha = ((this.alpha * 55) + 200) / 255;
	
		if (this.timers.alpha >= 0.22) then this.alpha = 1; end
		
		local alpha = 255 * this.alpha;

		if (this.state.viewingControls or this.state.viewingInfo) then
			alpha = 30;
		end

		this.labels.game:draw({
			x = x + 8,
			y = y,
			alpha = alpha,
			maxWidth = (this.labels.skin.w * 0.54) - 3,
		});

		y = y + (this.labels.game.h * 0.25);
		
		this.labels.skin:draw({
			x = x,
			y = y,
			alpha = alpha,
			color = 'white',
		});

		x = x + this.labels.skin.w + 4;
		y = y + this.labels.skin.h - (this.labels.version.h * 0.5) - 3;

		this:drawVersion(dt, alpha, x, y);
	end,
};

return Title;