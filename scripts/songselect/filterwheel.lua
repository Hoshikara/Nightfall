local CONSTANTS_CHALWHEEL = require('constants/chalwheel');
local CONSTANTS_SONGWHEEL = require('constants/songwheel');

local GridLayout = require('layout/grid');

local allowScroll = false;

local initialY = -1000;

local isSongSelect = true;
local rendererSet = false;

local currentFolder = game.GetSkinSetting('cachedFolder') or 1;
local currentLevel = game.GetSkinSetting('cachedLevel') or 1;

local choosingFolder = true;

local labelCount = 0;

local prefixes = {
	'Collection: ',
	'Folder: ',
	'Level: ',
};
local scrollTimers = {};
local timers = {
	folder = 0,
	level = 0,
	scroll = 0,
};

local cache = { resX = 0, resY = 0 };

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();

  if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
    scaledW = 1920;
    scaledH = scaledW * (resY / resX);
		scalingFactor = resX / scaledW;
		
		gfx.Scale(scalingFactor, scalingFactor);

    cache.resX = resX;
		cache.resY = resY;
	end
end

local layout = nil;

local labels = nil;

setLabels = function(folderCount)
	if (labelCount ~= folderCount) then
		labels = {
			folder = {
				finalWidth = 0,
				maxWidth = 0,
				maxHeight = 0,
			},
			level = {
				maxWidth = 0,
				maxHeight = 0,
			},
			timers = {},
		};

		labelCount = 0;

		Font.Normal();

		for index, folder in ipairs(filters.folder) do
			labels.folder[index] = Label.New(stringReplace(folder, prefixes), 24);

			local width = labels.folder[index].w;

			labels.timers[folder] = 0;

			if (width > labels.folder.maxWidth) then
				local dropdownWidth = layout.dropdown[1].maxWidth;

				if (width > dropdownWidth) then
					labels.folder.finalWidth = dropdownWidth;
				else
					labels.folder.finalWidth = width;
				end

				labels.folder.maxWidth = width;
			end

			labels.folder.maxHeight = labels.folder.maxHeight
				+ labels.folder[index].h
				+ layout.dropdown.padding;

			labelCount = labelCount + 1;
		end

		for index, level in ipairs(filters.level) do
			local currentLabel = stringReplace(level, prefixes);
	
			if (currentLabel == 'ALL') then
				Font.Normal();
			elseif (currentLabel == '∞') then
				Font.Number();
			else
				Font.Number();

				currentLabel = string.format('%02d', tonumber(stringReplace(level, prefixes)));
			end

			labels.level[index] = Label.New(currentLabel, 24, 0);

			local width = labels.level[index].w;

			if (width > labels.level.maxWidth) then
				labels.level.maxWidth = width;
			end

			labels.level.maxHeight = labels.level.maxHeight
				+ labels.level[index].h
				+ (layout.dropdown.padding / 2);
		end
	end
end

drawCurrentField = function(deltaTime, which, index, displaying)
	local x = layout.field[index].x;
	local y = layout.field.y;
	local color;

	local isFolder = which == 'folder';
	local current = (isFolder and currentFolder) or currentLevel;
	local doesOverflow = false;

	if ((not labels[which]) or (not labels[which][current])) then return end

	if (isFolder) then
		doesOverflow = labels[which][current].w > layout.field[1].maxWidth;
	end

	gfx.BeginPath();
	FontAlign.Left();

	if (displaying) then
		if (choosingFolder and (which == 'folder')) then
			color = 'Normal';
		elseif ((not choosingFolder) and (which == 'level')) then
			color = 'Normal';
		else
			color = 'White';
		end
	else
		color = 'White';
	end

	if (doesOverflow) then
		timers.scroll = timers.scroll + deltaTime;

		drawScrollingLabel(
			timers.scroll,
			labels[which][current],
			layout.field[1].maxWidth + (layout.dropdown.padding / 2),
			x,
			y,
			scalingFactor,
			color,
			255
		);
	else
		labels[which][current]:draw({
			x = x,
			y = y,
			color = color,
		});
	end
end

drawFilterLabel = function(deltaTime, which, index, y, isSelected, key)
	local isFolder = which == 'folder';
	local whichField = ((isFolder) and 1) or 2;

	local alpha = math.floor(255 * math.min(timers[which] ^ 2, 1));
	local padding = layout.dropdown.padding;
	local returnPadding = (isFolder and padding) or (padding / 2);
	local x = layout.dropdown[whichField].x + padding;
	local doesOverflow = labels[which][index].w > layout.dropdown[1].maxWidth;
	local color;

	gfx.BeginPath();
	FontAlign.Left();

	if (isSelected) then
		color = 'Normal';
	else
		color = 'White';
	end

	if (allowScroll and doesOverflow) then
		labels.timers[key] = labels.timers[key] + deltaTime;

		drawScrollingLabel(
			labels.timers[key],
			labels[which][index],
			layout.dropdown[1].maxWidth,
			x,
			y,
			scalingFactor,
			color,
			alpha
		);
	else 
		labels[which][index]:draw({
			x = x,
			y = y,
			a = alpha,
			color = color,
		});
	end

	return labels[which][index].h + returnPadding;
end

render = function(deltaTime, displaying)
	if (not rendererSet) then
		isSongSelect = #filters.level == 21;

		rendererSet = true;
	end

	if (not layout) then
		layout = GridLayout.New(isSongSelect);
	end

	gfx.Save();

	setupLayout();

	layout:setSizes(scaledW, scaledH);

	setLabels(#filters.folder);

	if (currentFolder > #filters.folder) then
		currentFolder = currentFolder - (currentFolder - #filters.folder);

		game.SetSkinSetting('cachedFolder', currentFolder);
	end

	drawCurrentField(deltaTime, 'folder', 1, displaying);
	drawCurrentField(deltaTime, 'level', 2, displaying);

	if (not displaying) then
		if (choosingFolder and (timers.folder > 0)) then
			timers.folder = math.max(timers.folder- (deltaTime * 6), 0);
		elseif (timers.level > 0) then
			timers.level = math.max(timers.level - (deltaTime * 6), 0);
		end
	
		if ((timers.folder == 0) and (timers.level == 0)) then return end
	else
		if (choosingFolder) then
			allowScroll = true;
			timers.folder = math.min(timers.folder + (deltaTime * 8), 1);

			if (timers.level > 0) then
				timers.level = math.max(timers.level - (deltaTime * 6), 0);
			end
		else
			timers.level = math.min(timers.level + (deltaTime * 8), 1);

			if (timers.folder > 0) then
				timers.folder = math.max(timers.folder - (deltaTime * 6), 0);
			end

			if (timers.folder == 0) then
				allowScroll = false;
			end
		end

		initialY = layout.dropdown.y;
	end

	gfx.BeginPath();
	Fill.Dark(230);
	gfx.FastRect(
		layout.dropdown[1].x,
		initialY,
		(layout.dropdown.padding * 2) + labels.folder.finalWidth,
		(labels.folder.maxHeight + layout.dropdown.padding) * timers.folder
	);
	gfx.FastRect(
		layout.dropdown[2].x,
		initialY,
		(layout.dropdown.padding * 2) + labels.level.maxWidth,
		(labels.level.maxHeight + (layout.dropdown.padding * 1.5)) * timers.level
	);
	gfx.Fill();

	gfx.Translate(0, initialY + layout.dropdown.start);

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

		game.SetSkinSetting('cachedFolder', newIndex);
	else
		currentLevel = newIndex;

		game.SetSkinSetting('cachedLevel', newIndex);
	end
end

set_mode = function(selectingFolder)
	choosingFolder = selectingFolder;
end
