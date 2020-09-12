CONSTANTS = require('constants/songwheel');

local arrowWidth = 12;

local currentSort = 1;

local initialY = -1000;

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

local layout = {
  ['dropdown'] = {
    [1] = {},
    [2] = {},
    [3] = {},
    ['padding'] = 24,
    ['start'] = 0,
    ['y'] = 0
  },
  ['field'] = {
    [1] = {},
    [2] = {},
    [3] = {},
    ['y'] = 0
  },
  ['grid'] = {},
	['labels'] = nil,
	
	setAllSizes = function(self)
		if (not self['labels']) then
			gfx.LoadSkinFont('GothamMedium.ttf');
	
			self['labels'] = {};
	
			for name, str in pairs(CONSTANTS['labels']['grid']) do
				self['labels'][name] = cacheLabel(str, 18);
			end
	
			local tempLabel = cacheLabel('TEMPLABEL', 24);
	
			self['field']['height'] = tempLabel['h'];
			self['labels']['height'] = self['labels']['sort']['h'];
		end
	
		self['jacketSize'] = scaledH / 4;
		self['grid']['gutter'] = self['jacketSize'] / 8;
		self['grid']['size'] = (self['jacketSize'] + self['grid']['gutter']) * 4;
		self['grid']['x'] = scaledW - self['grid']['size'] + (self['grid']['gutter'] * 7);
	
		self['labels']['spacing'] = (self['jacketSize'] * 2) / 3.5;
		self['labels']['x'] = self['grid']['x'];
		self['labels']['y'] = scaledH / 20;
	
		self['field'][1]['x'] = self['labels']['x'] - 4;
		self['field'][2]['x'] = self['field'][1]['x']
			+ self['labels']['sort']['w']
			+ self['labels']['spacing'];
		self['field'][3]['x'] = self['field'][2]['x']
			+ self['labels']['difficulty']['w']
			+ self['labels']['spacing'];
		self['field']['y'] = self['labels']['y'] + (self['labels']['height'] * 1.25);
	
		self['dropdown'][1]['x'] = self['field'][1]['x'] + 2;
		self['dropdown'][2]['x'] = self['field'][2]['x'];
		self['dropdown'][3]['x'] = self['field'][3]['x'];
		self['dropdown'][3]['maxWidth'] = (self['jacketSize'] * 1.65) - (self['dropdown']['padding'] * 2);
		self['dropdown']['start'] = self['dropdown']['padding'] - 7;
		self['dropdown']['y'] = self['field']['y'] + (self['field']['height'] * 1.25);
	end
};

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
				['name'] = cacheLabel(current['name'], 24),
				['direction'] = current['direction']
			};

			if (labels[index]['name']['w'] > labels['maxWidth']) then
				labels['maxWidth'] = labels[index]['name']['w'];
			end

			labels['maxHeight'] = labels['maxHeight']
				+ labels[index]['name']['h']
				+ layout['dropdown']['padding'];
		end
	end
end

drawCurrentSort = function(displaying)
	local x = layout['field'][1]['x'];
	local y = layout['field']['y'];

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	if (displaying) then
		gfx.FillColor(70, 120, 170, 255);
	else
		gfx.FillColor(255, 255, 255, 255);
	end

	labels[currentSort]['name']:draw({
		['x'] = x,
		['y'] = y
	});

	gfx.Save();

	gfx.Translate(
		x + labels[currentSort]['name']['w'] + arrowWidth,
		y 
			+ (labels[currentSort]['name']['h'] / 2)
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

	labels[index]['name']:draw({
		['x'] = x,
		['y'] = y
	});

	gfx.Save();

	gfx.Translate(
		x + labels[index]['name']['w'] + arrowWidth,
		y 
			+ (labels[index]['name']['h'] / 2)
			+ (((labels[index]['direction'] == 'up') and 0) or 8)
	);

	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[index]['direction'] == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();

	return (labels[index]['name']['h'] + padding);
end

render = function(deltaTime, displaying)
	gfx.Save();

	setupLayout();

	layout:setAllSizes();

	setLabels();

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