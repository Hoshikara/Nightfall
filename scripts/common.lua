-- This script is loaded for every screen of the game
-- All of the functions below are available to all of the scripts of the skin

SkinVersion = '1.2.4';

gfx.LoadSkinFont('DFMGM.ttf');

Image = require('common/image');
Label = require('common/label');
Window = require('common/window');

local Constants = require('constants/common');
local Alignments = Constants.Alignments;
local Colors = Constants.Colors;

local abs = math.abs;
local cos = math.cos;
local floor = math.floor;
local min = math.min;
local max = math.max;

local btnMap = {
	BTA = 0,
	BTB = 1,
	BTC = 2,
	BTD = 3,
	FXL = 4,
	FXR = 5,
	STA = 6,
	BCK = 11,
};

local fontMap = {
	jp = 24,
	med = 18,
	norm = 24,
	num = 18,
};

-- Text alignment wrapper function
---@param a? string # `'center'`, `'left'`, `'middle'`, `'right'`
alignText = function(a) gfx.TextAlign(Alignments[a] or Alignments.left); end

-- Rectangle drawing wrapper function  
-- Draws `image` if provided
---@param params table #
-- ```
-- {
-- 	x: number = 0,
-- 	y: number = 0,
-- 	w: number = 1000,
-- 	h: number = 1000,
-- 	alpha?: number
-- 	blendOp?: integer,
-- 	centered?: boolean,
-- 	color?: string|table,
-- 	fast?: boolean,
-- 	image?: any,
-- 	scale: number = 1,
-- 	stroke?: table,
-- 	tint?: table
-- }
-- ```
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
---@param f string # `'bold'`, `'jp'`, `'med'`, `'mono'`, `'norm'`, `'num'`
loadFont = function(f)
	gfx.LoadSkinFont(Constants.Fonts[f] or Constants.Fonts.jp);
end

-- Label wrapper function
---@param font string # `'jp'`, `'med'`, `'norm'`, `'num'`
---@param text string | table # string |
-- ```
-- { color: string, text: string }
-- ```
---@param size? integer
---@param color? string | table # `'black'`, `'dark'`, `'med'`, `'light'`, `'norm'`, `'red'`, `'white'` or `{ r: integer, g: integer, b: integer }`
---@return Label
makeLabel = function(font, text, size, color)
	return Label:new({
		color = color or 'norm',
		font = font,
		size = size or fontMap[font],
		text = text,
	});
end

-- Check whether a button is being pressed
---@param btn string # `'BTA' - 'BTD'`, `'FXL' / 'FXR'`, `'STA'`, `'BCK'` 
pressed = function(btn) return game.GetButton(btnMap[btn]); end

-- Pulses alpha channel
---@param t number # timer
---@param p number # percentage, `0.0` to `1.0`
---@param d number # duration, in seconds 
pulse = function(t, p, d) return abs(p * cos(t * (1 / d))) + (1 - p); end

-- Fill color wrapper function
---@param c? string | table # `'black'`, `'dark'`, `'med'`, `'light'`, `'norm'`, `'red'`, `'white'` or `{ r: intger, g: integer, b: integer }`
---@param a? number # = 255
setFill = function(c, a)
	a = (a and floor(a)) or 255;
	c = Colors[c] or c or Colors.norm;

	gfx.FillColor(c[1], c[2], c[3], a);
end

-- Stroke style wrapper function
---@param params table #
-- ```
-- {
-- 	alpha: integer = 255,
-- 	color: string|table = 'norm' = { 60, 110, 160 },
-- 	size: integer = 1,
-- }
-- ```
setStroke = function(params)
	local a = (params.alpha and floor(params.alpha)) or 255;
	local c = Colors[params.color] or params.color or Colors.norm;
	local size = params.size or 1;

	gfx.StrokeColor(c[1], c[2], c[3], a);
	gfx.StrokeWidth(size);
end

-- Smoother interpolation
---@param t number # timer
smoothstep = function(t) return t * t * (3 - 2 * t); end

-- Decreases a timer to 0
---@param t number # timer
---@param dt deltaTime
---@param d number # duration, in seconds
---@return number
to0 = function(t, dt, d) return max(t - (dt * (1 / d)), 0); end

-- Increases a timer to 1
---@param t number # timer
---@param dt deltaTime
---@param d number # duration, in seconds
---@return number
to1 = function(t, dt, d) return min(t + (dt * (1 / d)), 1); end