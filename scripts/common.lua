local _ = require('lib/luadash');
local Constants = require('constants/common');

gfx.LoadSkinFont('DFMGM.ttf');

smoothstep = function(t)
  return t * t * (3 - 2 * t);
end

alignText = function(alignment)
  alignment = Constants.Alignments[alignment] or Constants.Alignments.left;

  gfx.TextAlign(alignment);
end

drawLabel = function(params)
  local x = params.x or 0;
  local y = params.y or 0;
  local alpha = params.alpha or 255;
  local maxWidth = params.maxWidth or -1;

  gfx.BeginPath();

  alignText(params.align);

  setFill('dark', alpha * 0.5);
  gfx.DrawLabel(params.label.label, x + 1, y + 1, maxWidth);

  setFill(params.color, alpha);
  gfx.DrawLabel(params.label.label, x, y, maxWidth);
end

drawScrollingLabel = function(params)
  local x = params.x or 0;
  local y = params.y or 0;
  local alpha = params.alpha or 255;
  local scale = params.scale or 1;
  local timer = params.timer or 0;
  local width = params.width or 0;

  local labelX = params.label.w * 1.2;
  local duration = (labelX / 80) * 0.75;
  local phase = math.max((timer % (duration + 1.5)) - 1.5, 0) / duration;

  gfx.Save();

  gfx.BeginPath();

  gfx.Scissor((x + 2) * scale, y * scale, width, params.label.h * 1.25);

  alignText(params.align);

  setFill('dark', alpha * 0.5);
  gfx.DrawLabel(params.label.label, x + 1 - (phase * labelX), y + 1, -1);
  gfx.DrawLabel(
    params.label.label,
    x + 1 - (phase * labelX) + labelX,
    y + 1,
    -1
  );

  setFill(params.color, alpha);
  gfx.DrawLabel(params.label.label, x - (phase * labelX), y, -1);
  gfx.DrawLabel(params.label.label, x - (phase * labelX) + labelX, y, -1);

  gfx.ResetScissor();

  gfx.Restore();
end

drawImage = function(params)
  local scale = params.scale or 1;
  local x = params.x or 0;
  local y = params.y or 0;
  local w = (params.w or params.image.w) * scale;
  local h = (params.h or params.image.h) * scale;

  if (params.centered) then
    x = x - (w / 2);
    y = y - (h / 2);
  end

  gfx.BeginPath();

  if (params.blendOp) then
    gfx.GlobalCompositeOperation(params.blendOp);
  end

  if (params.tint) then
    gfx.SetImageTint(params.tint[1], params.tint[2], params.tint[3]);

    gfx.ImageRect(x, y, w, h, params.image.image, params.alpha or 1, 0);

    gfx.SetImageTint(255, 255, 255);
  else
    gfx.ImageRect(x, y, w, h, params.image.image, params.alpha or 1, 0);
  end

  if (params.stroke) then
    setStroke(params.stroke);

    gfx.Stroke();
  end
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

get = function(tbl, path, default)
  return _.get(tbl, path, default);
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

getSetting = function(key, default)
  local setting = game.GetSkinSetting(key);

  if (setting == nil) then
    return default;
  end

  -- remove random double quote carriage return that get inserted in skin.cfg
  if (type(setting) == 'string') then
    setting = setting:gsub('[%"%\r]', '');
  end

  return setting;
end