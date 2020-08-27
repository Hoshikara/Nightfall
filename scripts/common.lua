gfx.LoadSkinFont("NotoSans-Regular.ttf");

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
  gfx.FillColor(255, 255, 255, 255);
  
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