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
      local a = params.a or 1;
      local w = params.w or self.w;
      local h = params.h or self.h;

      w = (params.s and (params.s * w)) or w;
      h = (params.s and (params.s * h)) or h;
  
      local x = (params.centered and (params.x - (w / 2))) or params.x or 0;
      local y = (params.centered and (params.y - (h / 2))) or params.y or 0;

      gfx.BeginPath();

      if (params.blendOp) then
        gfx.GlobalCompositeOperation(params.blendOp);
      end

      gfx.ImageRect(x, y, w, h, self.image, a, 0);
    end
  };
end