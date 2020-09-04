CONSTANTS = require('constants/songwheel');
layout = require('layout/grid');

local arrowWidth = 12;

local currentSort = 1;

local initialY = -1000;

local labelAlpha = 1;

local mousePosX = 0;
local mousePosY = 0;

local timer = 0;

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;

  gfx.Scale(scalingFactor, scalingFactor);
end

local labels = nil;

setLabels = function()
	if (not labels) then
		labels = {
			['maxWidth'] = 0,
			['maxHeight'] = 0
		};

		gfx.LoadSkinFont('GothamBook.ttf');

		for index, current in ipairs(CONSTANTS['sorts']) do
			labels[index] = {
				['name'] = gfx.CreateLabel(current['name'], 24, 0),
				['direction'] = current['direction']
			};

			if (getLabelInfo(labels[index]['name'])['w'] > labels['maxWidth']) then
				labels['maxWidth'] = getLabelInfo(labels[index]['name'])['w'];
			end

			labels['maxHeight'] = labels['maxHeight']
				+ getLabelInfo(labels[index]['name'])['h']
				+ layout['dropdown']['padding']
		end
	end
end

drawCurrentSort = function(displaying)
	local x = layout['field'][1]['x'];
	local y = layout['field']['y'];

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	if (displaying) then
		gfx.FillColor(70, 120, 170, math.floor(255 * labelAlpha));
	else
		gfx.FillColor(255, 255, 255, math.floor(255 * labelAlpha));
	end

	gfx.DrawLabel(labels[currentSort]['name'], x, y);

	gfx.Save();

	gfx.Translate(
		x + getLabelInfo(labels[currentSort]['name'])['w'] + arrowWidth,
		y 
			+ (getLabelInfo(labels[currentSort]['name'])['h'] / 2)
			+ (((labels[currentSort]['direction'] == 'up') and 0) or 8)
	);

	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[currentSort]['direction'] == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();
end

drawSortLabel = function(index, y, isSelected)
	local alpha = math.floor(255 * math.min(timer ^ 2, 1));
	local padding = layout['dropdown']['padding'];
	local x = layout['dropdown'][1]['x'] + padding;

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	if (isSelected) then
		gfx.FillColor(70, 120, 170, alpha);
	else
		gfx.FillColor(255, 255, 255, alpha);
	end

	gfx.DrawLabel(labels[index]['name'], x, y);

	gfx.Save();

	gfx.Translate(
		x + getLabelInfo(labels[index]['name'])['w'] + arrowWidth,
		y 
			+ (getLabelInfo(labels[index]['name'])['h'] / 2)
			+ (((labels[index]['direction'] == 'up') and 0) or 8)
	);

	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[index]['direction'] == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();

	return (getLabelInfo(labels[index]['name'])['h'] + padding);
end

render = function(deltaTime, displaying)
	gfx.Save();

	setupLayout();

	layout:setAllSizes(scaledW, scaledH);

	setLabels();

	labelAlpha = 1;

	mousePosX, mousePosY = game.GetMousePos();

	if (mouseClipped(
		mousePosX,
		mousePosY,
		0,
		scaledH - (scaledH / 20) - 10,
		scaledW / 20,
		(scaledH / 20) + 10,
		scalingFactor
	)) then
		labelAlpha = 0.1;
	end

	drawCurrentSort(displaying);

	if (not displaying) then
		if (timer > 0) then
			timer = math.max(timer - (deltaTime * 6), 0);
		end

		if (timer == 0) then
			return;
		end
	else
		timer = math.min(timer + (deltaTime * 8), 1);

		initialY = layout['dropdown']['y'];
	end

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, 230);
	gfx.Rect(
		layout['dropdown'][1]['x'],
		initialY,
		(layout['dropdown']['padding'] * 2) + labels['maxWidth'] + (arrowWidth * 2),
		(labels['maxHeight'] + layout['dropdown']['padding']) * timer
	);
	gfx.Fill();

	gfx.Translate(0, initialY + layout['dropdown']['start']);

	local sortY = 0;

	for sortIndex, _ in ipairs(CONSTANTS['sorts']) do
		local isSelected = sortIndex == currentSort;

		sortY = sortY + drawSortLabel(sortIndex, sortY, isSelected);
	end

	gfx.Restore();
end

set_selection = function(newSort)
  currentSort = newSort;
end