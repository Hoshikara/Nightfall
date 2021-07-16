local Button = require('components/common/button');

---@class DialogBoxClass
local DialogBox = {
	-- DialogBox constructor
	---@param this DialogBoxClass
	---@return DialogBox
	new = function(this)
		---@class DialogBox : DialogBoxClass
		local t = {
			button = Button:new(415, 50),
			cache = { w = 0, h = 0 },
			dialog = {
				x = 0,
				y = 0,
				w = 0,
				h = 0,
			},
			maxWidth = 0,
			x = {
				center = 0,
				middleLeft = 0,
				outerLeft = 0,
				middleRight = 0,
				outerRight = 0,
			},
			y = {
				center = 0,
				top = 0,
				bottom = 0,
			},
			w = {
				box = 0,
				corner = 0,
				inner = 0,
				middle = 0,
				outer = 0,
			},
			h = { box = 432, outer = 0 },
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Sets the sizes for the current component
	---@param this DialogBox
	---@param w number
	---@param h number
	setSizes = function(this, w, h, isPortrait)
		if ((this.cache.w ~= w) or (this.cache.h ~= h)) then
			this.isPortrait = isPortrait;

			if (isPortrait) then
				this.w.box = 1050;
				this.w.corner = 150;
				this.w.inner = w / (1080 / 446); 
				this.w.middle = w / (1080 / 624);
				this.w.outer = w / (1080 / 800);
				this.h.outer = h / (1920 / 306);
			else
				this.w.box = 1250;
				this.w.corner = 250;
				this.w.inner = w / (1920 / 446); 
				this.w.middle = w / (1920 / 624);
				this.w.outer = w / (1920 / 800);
				this.h.outer = h / (1080 / 306);
			end

			this.maxWidth = this.w.outer - (176 / 2);
	
			this.x.center = w / 2;
			this.y.center = h / 2;
	
			this.x.innerLeft = this.x.center - (this.w.inner / 2);
			this.x.middleLeft = this.x.center - (this.w.middle / 2);
			this.x.outerLeft = this.x.center - (this.w.outer / 2);
			this.x.innerRight = this.x.center + (this.w.inner / 2);
			this.x.middleRight = this.x.center + (this.w.middle / 2);
			this.x.outerRight = this.x.center + (this.w.outer / 2);
	
			this.y.top = this.y.center - (this.h.outer / 2);
			this.y.bottom = this.y.center + (this.h.outer / 2);
			
			this.cache.w = w;
			this.cache.h = h;
		end
	end,

	-- Draw the DialogBox
	---@param this DialogBox
	---@param p table #
	-- ```
	-- {
	-- 	x: number = 0,
	-- 	y: number = 0,
	-- 	alpha: number = 1,
	-- }
	-- ```
	draw = function(this, p)
		local x = p.x or 0;
		local y = p.y or 0;
		local w = (this.w.box * 0.5);
		local h = (this.h.box * 0.5);

		gfx.BeginPath();

		setFill('dark', 250 * (p.alpha or 1));

		gfx.MoveTo(x, y - h);
		gfx.LineTo(x - w, y - h);
		gfx.LineTo(x - w + this.w.corner, y + h);
		gfx.LineTo(x + w, y + h);
		gfx.LineTo(x + w - this.w.corner, y - h);
		gfx.ClosePath();

		gfx.Fill();
	end,
};

return DialogBox;