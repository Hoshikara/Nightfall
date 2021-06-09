---@class ImageClass
local Image = {
	-- Image constructor
	---@param this ImageClass
	---@param path string
	---@return Image
	new = function(this, path)
		path = path or 'image_warning.png';

		---@class Image : ImageClass
		local t = {
			image = gfx.CreateSkinImage(path, 0)
				or gfx.CreateSkinImage('image_warning.png', 0),
			w = 500,
			h = 500,
		};

		t.w, t.h = gfx.ImageSize(t.image);
		
		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Draw the current image
	---@param this Image
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
		local scale = params.scale or 1;
		local x = params.x or 0;
		local y = params.y or 0;
		local w = (params.w or this.w) * scale;
		local h = (params.h or this.h) * scale;

		if (params.centered) then
			x = x - (w / 2);
			y = y - (h / 2);
		end

		gfx.BeginPath();

		gfx.GlobalCompositeOperation(params.blendOp or 0);

		if (params.tint) then
			gfx.SetImageTint(params.tint[1], params.tint[2], params.tint[3]);

			gfx.ImageRect(x, y, w, h, this.image, params.alpha or 1, 0);

			gfx.SetImageTint(255, 255, 255);
		else
			gfx.ImageRect(x, y, w, h, this.image, params.alpha or 1, 0);
		end
	
		if (params.stroke) then
			setStroke(params.stroke);
			
			gfx.Stroke();
		end
	end,
};

return Image;