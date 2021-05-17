---@class DialogBoxClass
local DialogBox = {
	images = {
		dialogBox = Image:new('common/dialog.png'),
		dialogBoxPortrait = Image:new('common/dialog_p.png'),
		btn = Image:new('buttons/long.png'),
		btnH = Image:new('buttons/long_hover.png'),
	},

	-- DialogBox constructor
	---@param this DialogBoxClass
	---@return DialogBox
	new = function(this)
		---@class DialogBox : DialogBoxClass
		local t = {
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
				inner = 0,
				middle = 0,
				outer = 0,
			},
			h = { outer = 0 },
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
				this.w.inner = w / (1080 / 446); 
				this.w.middle = w / (1080 / 624);
				this.w.outer = w / (1080 / 800);
				this.h.outer = h / (1920 / 306);
			else
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
	---@param params table #
	-- ```
	-- {
	-- 	x: number = 0,
	-- 	y: number = 0,
	-- 	w: number = 500,
	-- 	h: number = 500,
	-- 	alpha: number = 1,
	-- 	blendOp?: integer,
	-- 	tint?: { r, g, b },
	-- 	stroke?: {
	-- 		color?: string
	-- 		size?: number
	-- 	}
	-- }
	-- ```
	draw = function(this, params)
		if (this.isPortrait) then
			this.images.dialogBoxPortrait:draw(params);
		else
			this.images.dialogBox:draw(params);
		end
	end,
};

return DialogBox;