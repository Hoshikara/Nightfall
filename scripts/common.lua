gfx.LoadSkinFont('DFMGM.ttf');

colors = {
  black = {0, 0, 0, 255},
  blueDark = {16, 32, 48, 255},
  blueNormal = {60, 110, 160, 255},
  blueLight = {80, 130, 180, 255},
  white = {255, 255, 255, 255}
};

unpack = function(table, i)
  i = i or 1;

	if (table[i] ~= nil) then
		return table[i], unpack(table, i + 1);
	end
end

logInfo = function(tbl)
  local length = 0;
  local y = 30;
  local inc = 0;

  for k, v in pairs(tbl) do
    length = length + 1;
  end

  gfx.Save();
  gfx.Translate(5, 3);

  gfx.BeginPath();
  gfx.FillColor(0, 255, 0, 50);
  gfx.Rect(-100, -6, 5000, (y * length) + 9);
  gfx.Fill();

  gfx.BeginPath();
  gfx.LoadSkinFont('FiraCode.ttf');
  gfx.FontSize(30);
  gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT);
  gfx.FillColor(unpack(colors['white']));
  
  for k, v in pairs(tbl) do
    gfx.Text(string.format('%s: %s', k, v), 0, y * inc);

    inc = inc + 1;
  end

  gfx.Restore();
end

loadFrames = function(path, count)
  local frames = {};

  for i = 1, count do
    frames[i] = gfx.CreateSkinImage(string.format('%s/%04d.png', path, i), 0);
  end

  return frames;
end

cacheImage = function(path)
  local image = gfx.CreateSkinImage(path, 0);
  local w, h = gfx.ImageSize(image);

  return {
    ['image'] = image,
    ['w'] = w,
    ['h'] = h,

    draw = function(self, params)
      local a = params['a'] or 1;
      local w = params['w'] or self['w'];
      local h = params['h'] or self['h'];

      w = (params['s'] and (params['s'] * w)) or w;
      h = (params['s'] and (params['s'] * h)) or h;
  
      local x = (params['centered'] and (params['x'] - (w / 2))) or params['x'];
      local y = (params['centered'] and (params['y'] - (h / 2))) or params['y'];

      gfx.BeginPath();

      if (params['blendOp']) then
        gfx.GlobalCompositeOperation(params['blendOp']);
      end

      gfx.ImageRect(x, y, w, h, self['image'], a, 0);
    end
  };
end

cacheLabel = function(str, size)
  local label = gfx.CreateLabel(str, size, 0);
  local w, h = gfx.LabelSize(label);

  return {
    ['label'] = label,
    ['size'] = size,
    ['w'] = w,
    ['h'] = h,

    draw = function(self, params);
      local x = params['x'] or 0;
      local y = params['y'] or 0;
      local maxWidth = params['maxWidth'] or -1;
  
      gfx.DrawLabel(self['label'], x, y, maxWidth);
    end,

    update = function(self, params)
      local new = params['new'] or '';
      local size = params['size'] or self['size'];

      gfx.UpdateLabel(self['label'], new, size, 0);

      self['w'], self['h'] = gfx.LabelSize(self['label']);
    end
  };
end

createTable = function(size, initial)
  local table = {};

  for i = 1, size do
    table[i] = initial;
  end

  return table;
end

drawCenteredImage = function(params)
  local alpha = params['alpha'] or 1;
  local blendOp = params['blendOp'] or gfx.BLEND_OP_SOURCE_OVER;
  local w = params['width'];
  local h = params['height'] or w;
  local x = -(w / 2);
  local y = -(h / 2);

  gfx.BeginPath();
  gfx.GlobalCompositeOperation(blendOp);
  gfx.ImageRect(x, y, w, h, params['image'], alpha, 0);
end

drawScrollingLabel = function(timer, label, maxWidth, x, y, scale, color)
  local labelX = label['w'] * 1.2;
  local duration = (labelX / 80) * 0.75;
  local phase = math.max((timer % (duration + 1.5)) - 1.5, 0) / duration;

  gfx.Save();

  gfx.BeginPath();
  gfx.Scissor((x + 2) * scale, y * scale, maxWidth, label['h'] * 1.25);

  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

  gfx.FillColor(unpack(color));

  label:draw({
    ['x'] = x - (phase * labelX),
    ['y'] = y
  });
  label:draw({
    ['x'] = x - (phase * labelX) + labelX,
    ['y'] = y
  });

  gfx.ResetScissor();

  gfx.Restore();
end

getImageInfo = function(image)
  if (image) then
    local w, h = gfx.ImageSize(image);

    return { ['w'] = w, ['h'] = h };
  end

  return { ['w'] = 0, ['h'] = 0 };
end

getSign = function(val)
  return ((val > 0) and 1) or ((val < 0) and -1) or 0;
end

roundToZero = function(val)
	if (val < 0) then
		return math.ceil(val);
	elseif (val > 0) then 
		return math.floor(val);
	else 
		return 0;
	end
end

stringReplace = function(str, patternTable, replacement)
  local replaceWith = replacement or '';
	local newStr = str;

	for _, pattern in ipairs(patternTable) do
		newStr = string.gsub(newStr, pattern, replaceWith);
	end

	return string.upper(newStr);
end