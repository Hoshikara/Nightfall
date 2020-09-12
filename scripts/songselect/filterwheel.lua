local CONSTANTS = require('constants/songwheel');

local allowScroll = false;

local initialY = -1000;

local currentLevel = 1;
local currentFolder = 1;

local choosingFolder = true;

local labelCount = 0;

local prefixes = {
	[1] = 'Collection: ',
	[2] = 'Folder: ',
	[3] = 'Level: '
};
local scrollTimers = {};
local timers = {
	['folder'] = 0,
	['level'] = 0,
	['scroll'] = 0
};

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

setLabels = function(folderCount)
	if (labelCount ~= folderCount) then
		labels = {
			['folder'] = {
				['finalWidth'] = 0,
				['maxWidth'] = 0,
				['maxHeight'] = 0
			},
			['level'] = {
				['maxWidth'] = 0,
				['maxHeight'] = 0
			},
			['timers'] = {}
		};

		labelCount = 0;

		gfx.LoadSkinFont('GothamBook.ttf');

		for index, folder in ipairs(filters.folder) do
			labels['folder'][index] = cacheLabel(stringReplace(folder, prefixes), 24);

			local width = labels['folder'][index]['w'];

			labels['timers'][folder] = 0;

			if (width > labels['folder']['maxWidth']) then
				local dropdownWidth = layout['dropdown'][3]['maxWidth'];

				if (width > dropdownWidth) then
					labels['folder']['finalWidth'] = dropdownWidth;
				else
					labels['folder']['finalWidth'] = width;
				end

				labels['folder']['maxWidth'] = width;
			end

			labels['folder']['maxHeight'] = labels['folder']['maxHeight']
				+ labels['folder'][index]['h']
				+ layout['dropdown']['padding'];

			labelCount = labelCount + 1;
		end

		for index, level in ipairs(filters.level) do
			local currentLabel = stringReplace(level, prefixes);
	
			if (currentLabel ~= 'ALL') then
				gfx.LoadSkinFont('DigitalSerialBold.ttf');

				currentLabel = string.format('%02d', tonumber(stringReplace(level, prefixes)));
			else
				gfx.LoadSkinFont('GothamBook.ttf');
			end

			labels['level'][index] = cacheLabel(currentLabel, 24, 0);

			local width = labels['level'][index]['w'];

			if (width > labels['level']['maxWidth']) then
				labels['level']['maxWidth'] = width;
			end

			labels['level']['maxHeight'] = labels['level']['maxHeight']
				+ labels['level'][index]['h']
				+ (layout['dropdown']['padding'] / 2);
		end
	end
end

drawCurrentField = function(deltaTime, which, index, displaying)
	local x = layout['field'][index]['x'];
	local y = layout['field']['y'];
	local color;

	local isFolder = which == 'folder';
	local current = (isFolder and currentFolder) or currentLevel;
	local doesOverflow = false;

	if (isFolder) then
		doesOverflow = labels[which][current]['w'] > layout['dropdown'][3]['maxWidth'];
	end

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	if (displaying) then
		if (choosingFolder and (which == 'folder')) then
			color = {70, 120, 170, 255};
		elseif ((not choosingFolder) and (which == 'level')) then
			color = {70, 120, 170, 255};
		else
			color = {255, 255, 255, 255};
		end
	else
		color = {255, 255, 255, 255};
	end

	if (doesOverflow) then
		timers['scroll'] = timers['scroll'] + deltaTime;

		drawScrollingLabel(
			timers['scroll'],
			labels[which][current],
			layout['dropdown'][3]['maxWidth'] + (layout['dropdown']['padding'] / 2),
			x,
			y,
			scalingFactor,
			color
		);
	else
		gfx.FillColor(unpack(color));
		labels[which][current]:draw({
			['x'] = x, 
			['y'] = y
		});
	end
end

drawFilterLabel = function(deltaTime, which, index, y, isSelected, key)
	local isFolder = which == 'folder';
	local whichField = ((isFolder) and 3) or 2;

	local alpha = math.floor(255 * math.min(timers[which] ^ 2, 1));
	local padding = layout['dropdown']['padding'];
	local returnPadding = (isFolder and padding) or (padding / 2);
	local x = layout['dropdown'][whichField]['x'] + padding;
	local doesOverflow = labels[which][index]['w'] > layout['dropdown'][3]['maxWidth'];
	local color;

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	if (isSelected) then
		color = {70, 120, 170, alpha};
	else
		color = {255, 255, 255, alpha};
	end

	if (allowScroll and doesOverflow) then
		labels['timers'][key] = labels['timers'][key] + deltaTime;

		drawScrollingLabel(
			labels['timers'][key],
			labels[which][index],
			layout['dropdown'][3]['maxWidth'],
			x,
			y,
			scalingFactor,
			color
		);
	else 
		gfx.FillColor(unpack(color));
		labels[which][index]:draw({
			['x'] = x,
			['y'] = y
		});
	end

	return (labels[which][index]['h'] + returnPadding);
end

render = function(deltaTime, displaying)
	gfx.Save();

	setupLayout();

	layout:setAllSizes();

	setLabels(#filters.folder);

	drawCurrentField(deltaTime, 'level', 2, displaying);
	drawCurrentField(deltaTime, 'folder', 3, displaying);

	if (not displaying) then
		if (choosingFolder and (timers['folder'] > 0)) then
			timers['folder'] = math.max(timers['folder'] - (deltaTime * 6), 0);
		elseif (timers['level'] > 0) then
			timers['level'] = math.max(timers['level'] - (deltaTime * 6), 0);
		end
	
		timers['innerScroll'] = 0;

		if ((timers['folder'] == 0) and (timers['level'] == 0)) then
			gfx.Scale(1 / scalingFactor, 1 / scalingFactor);

			return;
		end
	else
		if (choosingFolder) then
			allowScroll = true;
			timers['folder'] = math.min(timers['folder'] + (deltaTime * 8), 1);

			if (timers['level'] > 0) then
				timers['level'] = math.max(timers['level'] - (deltaTime * 6), 0);
			end
		else
			timers['level'] = math.min(timers['level'] + (deltaTime * 8), 1);

			if (timers['folder'] > 0) then
				timers['folder'] = math.max(timers['folder'] - (deltaTime * 6), 0);
			end

			if (timers['folder'] == 0) then
				allowScroll = false;
				timers['innerScroll'] = 0;
			end
		end

		initialY = layout['dropdown']['y'];
	end

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, 230);
	gfx.Rect(
		layout['dropdown'][3]['x'],
		initialY,
		(layout['dropdown']['padding'] * 2) + labels['folder']['finalWidth'],
		(labels['folder']['maxHeight'] + layout['dropdown']['padding']) * timers['folder']
	);
	gfx.Rect(
		layout['dropdown'][2]['x'],
		initialY,
		(layout['dropdown']['padding'] * 2) + labels['level']['maxWidth'],
		(labels['level']['maxHeight'] + (layout['dropdown']['padding'] * 1.5)) * timers['level']
	);
	gfx.Fill();

	gfx.Translate(0, initialY + layout['dropdown']['start']);

	local folderY = 0;
	local levelY = 0;

	for folderIndex, key in ipairs(filters.folder) do
		local isSelected = folderIndex == currentFolder;

		folderY = folderY + drawFilterLabel(deltaTime, 'folder', folderIndex, folderY, isSelected, key);
	end

	for levelIndex, _ in ipairs(filters.level) do
		local isSelected = levelIndex == currentLevel;

		levelY = levelY + drawFilterLabel(deltaTime, 'level', levelIndex, levelY, isSelected);
	end

	gfx.Restore();
end

set_selection = function(newIndex, selectingFolder)
	if (selectingFolder) then
		currentFolder = newIndex;
	else
		currentLevel = newIndex;
	end
end

set_mode = function(selectingFolder)
  choosingFolder = selectingFolder;
end
