---@class ImageClass
local Image = {
	-- Image constructor
	---@param this ImageClass
	---@param path string
	---@param noFallback boolean
	---@return Image
	new = function(this, path, noFallback)
		---@class Image : ImageClass
		local t = {
			image = gfx.CreateSkinImage(path or '', 0),
			w = 500,
			h = 500,
		};

		if (not t.image) then
			if (noFallback) then return; end
		
			t.image = gfx.CreateSkinImage('image_warning.png', 0);
		end

		t.w, t.h = gfx.ImageSize(t.image);
		
		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Draw the current image
	---@param this Image
	---@param params ImageDrawParams
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