local _ = require('lib/luadash');
local Constants = require('constants/common');

gfx.LoadSkinFont('DFMGM.ttf');

quadraticEase = function(progress)
  return 1 - (1 - progress) * (1 - progress);
end

alignText = function(alignment)
  alignment = Constants.Alignments[alignment] or Constants.Alignments.left;

  gfx.TextAlign(alignment);
end

drawRectangle = function(params)
  local scale = params.scale or 1;
  local x = params.x or 0;
  local y = params.y or 0;
  local w = (params.w or 1000) * scale;
  local h = (params.h or 1000) * scale;

  if (params.centered) then
    x = x - (w / 2);
    y = y - (h / 2);
  end

  gfx.BeginPath();

  if (params.blendOp) then
    gfx.GlobalCompositeOperation(params.blendOp);
  end

  if (params.image) then
    if (params.tint) then
      gfx.SetImageTint(params.tint[1], params.tint[2], params.tint[3]);

      gfx.ImageRect(x, y, w, h, params.image, params.alpha or 1, 0);

      gfx.SetImageTint(255, 255, 255);
    else
      gfx.ImageRect(x, y, w, h, params.image, params.alpha or 1, 0);
    end
  else
    setFill(params.color, params.alpha);

    if (params.fast) then
      gfx.FastRect(x, y, w, h);
    else
      gfx.Rect(x, y, w, h);
    end

    gfx.Fill();
  end

  if (params.stroke) then
    setStroke(params.stroke);

    gfx.Stroke();
  end
end

loadFont = function(font)
  font = Constants.Fonts[font] or Constants.Fonts.jp;

  gfx.LoadSkinFont(font);
end

setFill = function(color, alpha)
  alpha = (alpha and math.floor(alpha)) or 255;
  color = Constants.Colors[color] or color or Constants.Colors.normal;

  gfx.FillColor(color[1], color[2], color[3], alpha);
end

setStroke = function(params)
  local alpha = (params.alpha and math.floor(params.alpha)) or 255;
  local color = Constants.Colors[params.color]
    or params.color
    or Constants.Colors.normal;
  local size = params.size or 1;

  gfx.StrokeColor(color[1], color[2], color[3], alpha);
  gfx.StrokeWidth(size);
end

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

  drawRectangle({
    x = -100,
    y = -6,
    w = 720,
    h = (y * length) * 9,
    alpha = 200,
    color = 'black',
  });

  gfx.BeginPath();
  gfx.FontSize(30);
  alignText('left');
  setFill('white');
  loadFont('mono');

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
  alignText('left');
  loadFont('mono');
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