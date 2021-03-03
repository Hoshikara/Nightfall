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
  };
end