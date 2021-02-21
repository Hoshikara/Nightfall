return function(params)
  local image = gfx.CreateSkinImage(params.path, 0);

  if (not image) then
    image = gfx.CreateSkinImage('image_warning.png', 0);
  end

  local w, h = gfx.ImageSize(image);

  return {
    image = image,
    w = w,
    h = h,

    draw = function(self, params)
      drawRectangle({
        x = params.x,
        y = params.y,
        w = params.w or self.w,
        h = params.h or self.h,
        alpha = params.alpha,
        blendOp = params.blendOp,
        centered = params.centered,
        image = self.image,
      });
    end
  };
end