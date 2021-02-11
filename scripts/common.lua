local _ = require('lib/luadash');

gfx.LoadSkinFont('DFMGM.ttf');

Ease = {
  OutQuad = function(progress)
    return 1 - (1 - progress) * (1 - progress);
  end,
};

Fill = {
  Black = function(alpha)
    gfx.FillColor(0, 0, 0, (alpha and math.floor(alpha)) or 255);
  end,

  Dark = function(alpha)
    gfx.FillColor(4, 8, 12, (alpha and math.floor(alpha)) or 255);
  end,

  Light = function(alpha)
    gfx.FillColor(80, 130, 180, (alpha and math.floor(alpha)) or 255);
  end,

  Normal = function(alpha)
    gfx.FillColor(60, 110, 160, (alpha and math.floor(alpha)) or 255);
  end,

  White = function(alpha)
    gfx.FillColor(255, 255, 255, (alpha and math.floor(alpha)) or 255);
  end,
};

Font = {
  Bold = function()
    gfx.LoadSkinFont('GothamBold.ttf');
  end,

  JP = function()
    gfx.LoadSkinFont('DFMGM.ttf');
  end,

  Medium = function()
    gfx.LoadSkinFont('GothamMedium.ttf');
  end,

  Mono = function()
    gfx.LoadSkinFont('SFMonoMedium.ttf');
  end,

  Normal = function()
    gfx.LoadSkinFont('GothamBook.ttf');
  end,

  Number = function()
    gfx.LoadSkinFont('DigitalSerialBold.ttf');
  end,
};

FontAlign = {
  Center = function()
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP);
  end,

  Left = function()
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
  end,

  Middle = function()
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  end,

  Right = function()
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
  end,
};

New = {
  Image = require('common/image'),
  Label = require('common/label'),
};

createError = function(description)
  return function(cause)
    error(string.format('%s: %s', description, cause));
  end
end

debug = function(tbl)
  local length = 0;
  local y = 30;
  local inc = 0;

  for k, v in pairs(tbl) do
    length = length + 1;
  end

  gfx.Save();
  gfx.Translate(5, 3);

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 200);
  gfx.Rect(-100, -6, 720, (y * length) + 9);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FontSize(30);
  FontAlign.Left();
  Fill.White();
  Font.Mono();

  for k, v in pairs(tbl) do
    gfx.Text(string.format('%s: %s', k, v), 0, y * inc);

    inc = inc + 1;
  end

  gfx.Restore();
end

log = function(content)
  if (type(content) == 'string') then
    game.Log(string.format('Nightfall Log: %s', content), game.LOGGER_INFO);
  else
    game.Log(
      string.format(
        'Nightfall Log: Invalid data type (expected a string, got a %s)',
        type(content)
      ),
      game.LOGGER_INFO
    );
  end
end

loadFrames = function(path, count)
  local frames = {};

  for i = 1, count do
    frames[i] = gfx.CreateSkinImage(string.format('%s/%04d.png', path, i), 0);
  end

  return frames;
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

drawCursor = function(params);
	local x = params.x or 0;
	local y = params.y or 0;
	local w = params.w or 0;
	local h = params.h or 0;
	local alpha = (params.alpha and math.floor(255 * params.alpha)) or 255;
	local stroke = params.stroke or 1;
  local size = params.size or 6;
  local sizeY = size * 0.95;
  local gap = size / (size * 1.05);

	gfx.BeginPath();
	gfx.StrokeWidth(stroke);
	gfx.StrokeColor(255, 255, 255, alpha);

	gfx.MoveTo(x - size - gap, y);
	gfx.LineTo(x - size - gap, y - sizeY);
	gfx.LineTo(x - gap, y - sizeY);

	gfx.MoveTo(x + w + size + gap, y);
	gfx.LineTo(x + w + size + gap, y - sizeY);
	gfx.LineTo(x + w + gap, y - sizeY);

	gfx.MoveTo(x - size - gap, y + h);
	gfx.LineTo(x - size - gap, y + h + sizeY);
	gfx.LineTo(x - gap, y + h + sizeY);

	gfx.MoveTo(x + w + size + gap, y + h);
	gfx.LineTo(x + w + size + gap, y + h + sizeY);
	gfx.LineTo(x + w + gap, y + h + sizeY);

	gfx.Stroke();
end

drawResolutionWarning = function(x, y)
  gfx.Save();

  gfx.BeginPath();
  gfx.FillColor(255, 55, 55, 255);
  gfx.FontSize(24);
  FontAlign.Left();
  Font.Mono();
  gfx.Text(
    'NON 16:9 RESOLUTION DETECTED -- SKIN ELEMENTS MAY NOT RENDER AS INTENDED. ENTER FULLSCREEN WITH  [ALT] + [ENTER]  IF THIS IS A MISTAKE',
    x, 
    y
  );

  gfx.Restore();
end

get = function(tbl, path, default)
  return _.get(tbl, path, default);
end

getDateFormat = function()
  local dateFormat = game.GetSkinSetting('dateFormat') or 'DAY-MONTH-YEAR';

  if (dateFormat == 'DAY-MONTH-YEAR') then
    return '%d-%m-%y';
  elseif (dateFormat == 'MONTH-DAY-YEAR') then
    return '%m-%d-%y';
  elseif (dateFormat == 'YEAR-MONTH-DAY') then
    return '%y-%m-%d';
  else
    return '%d-%m-%y';
  end
end

getDifficultyIndex = function(jacketPath, difficultyIndex)
  if (jacketPath and difficultyIndex) then
    local path = string.match(string.lower(jacketPath), '[/\\][^\\/]+$');

    if ((difficultyIndex == 3) and path) then
      if (string.find(path, 'inf')) then
        return 5;
      elseif (string.find(path, 'grv')) then
        return 6;
      elseif (string.find(path, 'hvn')) then
        return 7;
      elseif (string.find(path, 'vvd')) then
        return 8
      end
    end
  end

  return difficultyIndex + 1;
end

getSign = function(val)
  return ((val > 0) and 1) or ((val < 0) and -1) or 0;
end

loadJSON = function(filename)
  local JSON = require('lib/JSON');
  local path = path.Absolute(
    string.format('skins/%s/JSON/%s.json', game.GetSkin(), filename)
  );
  local contents = io.open(path, 'r');
  local decoded = {};

  if (contents) then
    local raw = contents:read('*all');

    if (raw == '') then
      contents:write(JSON.encode(decoded));
    else
      decoded = JSON.decode(raw);
    end

    contents:close();
  else
    local throwError = createError('Error loading JSON');

    throwError(string.format('File does not exist: %s', path));
  end

  return {
    contents = decoded,
    JSON = JSON,
    path = path,

    set = function(self, key, value)
      local contents = io.open(self.path, 'w');

      self.contents[key] = value;

      contents:write(self.JSON.encode(self.contents));

      contents:close();
    end,
  };
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