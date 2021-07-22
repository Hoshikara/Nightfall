-- This script is loaded for every screen of the game
-- All of the functions below are available to all of the scripts of the skin

SkinVersion = '1.3.5';

Developer = false;

TagsURL = 'https://api.github.com/repos/Hoshikara/Nightfall/git/refs/tags';

gfx.LoadSkinFont('DFMGM.ttf');

Background = require('common/background');
Image = require('common/image');
Label = require('common/label');
Window = require('common/window');

Constants = require('constants/common');

Colors = Constants.Colors;

local Alignments = Constants.Alignments;

local abs = math.abs;
local cos = math.cos;
local floor = math.floor;
local min = math.min;
local max = math.max;

local BtnEnum = {
	BTA = 0,
	BTB = 1,
	BTC = 2,
	BTD = 3,
	FXL = 4,
	FXR = 5,
	STA = 6,
	BCK = 11,
};

local FontSizeEnum = {
	jp = 24,
	med = 18,
	norm = 24,
	num = 18,
};

red = 0;
green = 0;
blue = 0;

-- Advance list selection with rollover
---@param idx integer # Current item index
---@param total integer # Number of items in the list
---@param step integer # `-1` = backward, `1` = forward
---@return integer
advance = function(idx, total, step) return (((idx - 1) + step) % total) + 1; end

-- Text alignment wrapper function
---@param a? Alignment
alignText = function(a) gfx.TextAlign(Alignments[a] or Alignments.left); end

-- Rectangle drawing wrapper function  
-- Draws `image` if provided
---@param params DrawRectParams
drawRect = function(params)
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

-- Flickers alpha channel  
-- Pulses after flickering if `pt` provided
---@param ft number # flicker timer
---@param pt number # pulse timer
---@param p number # percentage, `0.0` to `1.0`
---@param d number # duration, in seconds
flicker = function(ft, pt, p, d)
	if (ft < 0.26) then return floor(ft * 30) % 2; end

	if (not pt) then return 1; end

	return pulse(pt, p, d);
end

-- Gets the index that corresponds to a `Difficulty` name
---@param jacketPath string
---@param diffIndex integer
---@return integer
getDiffIndex = function(jacketPath, diffIndex)
	if (jacketPath and diffIndex) then
		local path = ((jacketPath):lower()):match('[/\\][^\\/]+$');

		if ((diffIndex == 3) and path) then
			if (path:find('inf')) then
				return 5;
			elseif (path:find('grv')) then
				return 6;
			elseif (path:find('hvn')) then
				return 7;
			elseif (path:find('vvd')) then
				return 8;
			end
		end
	end

	return diffIndex + 1;
end

-- Gets the value of the skin setting by the specified key
---@param key string
---@param default any
---@return any
getSetting = function(key, default)
	local setting = game.GetSkinSetting(key);

	if (setting == nil) then return default; end

	-- remove random double quote carriage return that gets inserted in skin.cfg
	if (type(setting) == 'string') then setting = setting:gsub('[%"%\r]', ''); end

	return setting;
end

-- Font loading wrapper function
---@param f? Font
loadFont = function(f)
	gfx.LoadSkinFont(Constants.Fonts[f] or Constants.Fonts.jp);
end

-- Make color table
---@param r? number
---@param g? number
---@param b? number
---@param pct? number
---@return RGB
makeColor = function(r, g, b, pct)
  r = r or 0;
  g = g or 0;
  b = b or 0;
  pct = pct or 1;

  return {
    min(floor(r * pct), 255),
    min(floor(g * pct), 255),
    min(floor(b * pct), 255),
  };
end

-- Label wrapper function
---@param font Font
---@param text string|LabelMulticolorText
---@param size? integer
---@param color? Color
---@return Label
makeLabel = function(font, text, size, color)
	return Label:new({
		color = color or 'norm',
		font = font,
		size = size or FontSizeEnum[font],
		text = text,
	});
end

-- Checks whether a button is being pressed
---@param btn string # `'BTA' - 'BTD'`, `'FXL' / 'FXR'`, `'STA'`, `'BCK'` 
---@return boolean
pressed = function(btn) return game.GetButton(BtnEnum[btn]); end

-- Pulses alpha channel
---@param t number # timer
---@param p number # percentage, `0.0` to `1.0`
---@param d number # duration, in seconds 
---@return number
pulse = function(t, p, d) return abs(p * cos(t * (1 / d))) + (1 - p); end

-- Reload color scheme when changed in skin settings
reloadColors = function()
	if (not Colors) then return; end

	local r, g, b, _ = game.GetSkinSetting('colorScheme');

	if ((r ~= red) or (g ~= green) or (b ~= blue)) then
		Colors.dark = makeColor(r, g, b, 0.075);
    Colors.light = makeColor(r, g, b, 1.125);
    Colors.med = makeColor(r, g, b, 0.3);
    Colors.norm = makeColor(r, g, b);

		red = r;
		green = g;
		blue = b;
	end
end

-- Fill color wrapper function
---@param c? Color # Default `'norm'`
---@param a? number # Default `255`
setFill = function(c, a)
	a = (a and floor(a)) or 255;
	c = Colors[c] or c or Colors.norm;

	gfx.FillColor(c[1], c[2], c[3], a);
end

-- Stroke style wrapper function
---@param params SetStrokeParams
setStroke = function(params)
	local a = (params.alpha and floor(params.alpha)) or 255;
	local c = Colors[params.color] or params.color or Colors.norm;
	local size = params.size or 1;

	gfx.StrokeColor(c[1], c[2], c[3], a);
	gfx.StrokeWidth(size);
end

-- Smoother interpolation
---@param t number # timer
---@return number
smoothstep = function(t) return t * t * (3 - 2 * t); end

-- Decreases a timer to 0 over `d`
---@param t number # timer
---@param dt deltaTime
---@param d number # duration, in seconds
---@return number
to0 = function(t, dt, d) return max(t - (dt * (1 / d)), 0); end

-- Increases a timer to 1 over `d`
---@param t number # timer
---@param dt deltaTime
---@param d number # duration, in seconds
---@return number
to1 = function(t, dt, d) return min(t + (dt * (1 / d)), 1); end