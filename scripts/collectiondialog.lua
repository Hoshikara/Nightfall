buttonCursor = require('songselect/cursor');
layout = require('layout/dialog');

menuOptions = {};
selectedIndex = 0;

local buttonScrollTimer = 0;

local cursor = {
	['alpha'] = 0,
	['offset'] = 0,
	['timer'] = 0
};

local artist = nil;
local title = nil;

local timer = 0;
local timers = {
	['artist'] = 0,
	['button'] = 0,
	['cursor'] = 0,
	['title'] = 0
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

local labels = nil;

setLabels = function()
	if (not labels) then
		gfx.LoadSkinFont('GothamMedium.ttf');

		labels = {
			['artist'] = gfx.CreateLabel('ARTIST', 18, 0),
			['collectionName'] = gfx.CreateLabel('COLLECTION NAME', 18, 0),
			['confirm'] = gfx.CreateLabel('CONFIRM', 18, 0),
			['enter'] = gfx.CreateLabel('[ENTER]', 18, 0),
			['title'] = gfx.CreateLabel('TITLE', 18, 0)
		};

		gfx.LoadSkinFont('DFMGM.ttf');

		labels['input'] = gfx.CreateLabel('', 28, 0);
	end
end

drawArrows = function()
	local noHigher = selectedIndex == 0;
	local noLower = (selectedIndex + 1) == #menuOptions;
	local x = layout['x']['center'] - 36;
	local y1 = layout['y']['center'] + 29;
	local y2 = layout['y']['center'] + 45;

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, math.floor(timer * ((noHigher and 50) or 255)));
	gfx.MoveTo(x, y1);
	gfx.LineTo(x - 12, y1);
	gfx.LineTo(x - 6, y1 - 10);
	gfx.LineTo(x, y1);
	gfx.Fill();

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, math.floor(timer * ((noLower and 50) or 255)));
	gfx.MoveTo(x, y2);
	gfx.LineTo(x - 12, y2);
	gfx.LineTo(x - 6, y2 + 10);
	gfx.LineTo(x , y2);
	gfx.Fill();
end

drawButton = function(deltaTime, label, isSelected, y)
	if ((y < layout['y']['center']) or (y > layout['y']['bottom'])) then return end;

	local alpha = math.floor(((isSelected and 255) or 50) * timer);
	local labelH = getLabelInfo(label)['h'];

	if (isSelected) then
		gfx.ImageRect(
			layout['button']['x'],
			y,
			layout['button']['w'],
			layout['button']['h'],
			layout['images']['buttonHover'],
			timer,
			0
		);
	else
		gfx.ImageRect(
			layout['button']['x'],
			y,
			layout['button']['w'],
			layout['button']['h'],
			layout['images']['button'],
			(0.45 * timer),
			0
		);
	end

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);
	
	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(255, 255, 255, alpha);

	if (getLabelInfo(label)['w'] > (layout['button']['w'] - 90)) then
		buttonScrollTimer = buttonScrollTimer + deltaTime;

		drawScrollingLabel(
			buttonScrollTimer,
			label,
			(layout['button']['w'] - 90),
			labelH,
			layout['button']['x'] + 43,
			y + labelH + 8,
			scalingFactor,
			1,
			{255, 255, 255, alpha}
		);
	else
		gfx.DrawLabel(label, layout['button']['x'] + 43, y + labelH + 8);
	end

	gfx.Restore();
end

drawInput = function()
	local x = layout['x']['middleLeft'];
	local y = layout['y']['center'] + (layout['h']['outer'] / 10);
	local labelY = layout['y']['center'] + (layout['h']['outer'] / 10);

	y = y + (getLabelInfo(labels['collectionName'])['h'] * 2);

	cursor['offset'] = math.min(
		getLabelInfo(labels['input'])['w'] + 2,
		layout['w']['middle'] - 20
	);

	gfx.BeginPath();
	gfx.FillColor(16, 32, 48, math.floor(100 * timer));
	gfx.Rect(
		x,
		y,
		layout['w']['middle'],
		layout['h']['outer'] / 6
	);
	gfx.Fill();

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, math.floor(255 * cursor['alpha']));
	gfx.Rect(
		x + 8 + cursor['offset'],
		y + 10,
		2,
		(layout['h']['outer'] / 6) - 20
	);
	gfx.Fill();

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);

	gfx.LoadSkinFont('DFMGM.ttf');
	gfx.UpdateLabel(labels['input'], string.upper(dialog.newName), 28, 0);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	gfx.DrawLabel(labels['collectionName'], layout['x']['middleLeft'], labelY);

	labelY = labelY + (getLabelInfo(labels['collectionName'])['h'] * 2);

	gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	gfx.DrawLabel(labels['input'], x + 8, labelY + 7, layout['w']['middle'] - 22);

	labelY = labelY + (layout['h']['outer'] / 6);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	gfx.DrawLabel(
		labels['confirm'],
		layout['x']['middleRight'] + 2,
		labelY + getLabelInfo(labels['confirm'])['h']
	);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	gfx.DrawLabel(
		labels['enter'],
		layout['x']['middleRight'] - getLabelInfo(labels['enter'])['w'] - 16,
		labelY + getLabelInfo(labels['enter'])['h']
	);

	gfx.Restore();
end

drawSongInfo = function(deltaTime)
	local alpha = math.floor(255 * timer);
	local maxWidth = layout['w']['outer'] - (176 / 2);
	local x = layout['x']['outerLeft'];
	local y = layout['y']['top'] - 12;

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(60, 110, 160, alpha);
	gfx.DrawLabel(labels['title'], x, y);

	y = y + (getLabelInfo(labels['title'])['h'] * 1.25);

	if (getLabelInfo(title)['w'] > maxWidth) then
		timers['title'] = timers['title'] + deltaTime;

		drawScrollingLabel(
			timers['title'],
			title,
			maxWidth,
			getLabelInfo(title)['h'],
			x + 2,
			y,
			scalingFactor,
			1,
			{255, 255, 255, alpha}
		);
	else
		gfx.FillColor(255, 255, 255, alpha);
		gfx.DrawLabel(title, x, y);
	end

	y = y + (getLabelInfo(title)['h'] * 1.5);

	gfx.FillColor(60, 110, 160, alpha);
	gfx.DrawLabel(labels['artist'], x, y);

	y = y + (getLabelInfo(labels['artist'])['h'] * 1.5);
	
	if (getLabelInfo(artist)['w'] > maxWidth) then
		timers['artist'] = timers['artist'] + deltaTime;

		drawScrollingLabel(
			timers['artist'],
			artist,
			maxWidth,
			getLabelInfo(artist)['h'],
			x + 2,
			y,
			scalingFactor,
			1,
			{255, 255, 255, alpha}
		);
	else
		gfx.FillColor(255, 255, 255, alpha);
		gfx.DrawLabel(artist, x, y);
	end

	gfx.Restore();
end

open = function()
	initialIndex = 1;
	menuOptions = {};
	selectedIndex = 0;

	gfx.LoadSkinFont('GothamMedium.ttf');

	if (#dialog.collections == 0) then
		menuOptions[initialIndex] = {
			['action'] = createCollection('FAVOURITES'),
			['label'] = gfx.CreateLabel('ADD TO FAVOURITES', 18, 0)
		};
	end

	for i, collection in ipairs(dialog.collections) do
		local currentName =
			(collection.exists and string.format('REMOVE FROM %s', string.upper(collection.name)))
			or string.format('ADD TO %s', string.upper(collection.name));

		menuOptions[i] = {
			['action'] = createCollection(collection.name),
			['label'] = gfx.CreateLabel(currentName, 18, 0)
		};
	end

	table.insert(menuOptions, {
		['action'] = menu.ChangeState,
		['label'] = gfx.CreateLabel('CREATE COLLECTION', 18, 0)
	});
	table.insert(menuOptions, {
		['action'] = menu.Cancel,
		['label'] = gfx.CreateLabel('CLOSE', 18, 0)
	});

	gfx.LoadSkinFont('DFMGM.ttf');
	artist = gfx.CreateLabel(string.upper(dialog.artist), 28, 0);
	title = gfx.CreateLabel(string.upper(dialog.title), 36, 0);
end

render = function(deltaTime)
	gfx.Save();

	setupLayout();

	layout:setAllSizes(scaledW, scaledH);

	setLabels();

	if (dialog.closing) then
		timer = math.max(timer - (deltaTime * 6), 0);
	else
		timer = math.min(timer + (deltaTime * 8), 1);
	end

	cursor['timer'] = cursor['timer'] + deltaTime;
	cursor['alpha'] = timer * (math.abs(0.8 * math.cos(cursor['timer'] * 5)) + 0.2);

	gfx.BeginPath();
	gfx.ImageRect(
		layout['dialog']['x'],
		layout['dialog']['y'],
		layout['dialog']['w'],
		layout['dialog']['h'],
		layout['images']['dialogBox'],
		timer,
		0
	);

	drawSongInfo(deltaTime);

	if (dialog.isTextEntry) then
		drawInput();
	else
		local y = layout['y']['center'];
		local nextY = layout['button']['h'] * 1.25;
		
		for i, option in ipairs(menuOptions) do
			local buttonY = y + nextY * ((i - 1) - selectedIndex);
			local isSelected = (i - 1) == selectedIndex;

			drawButton(deltaTime, option['label'], isSelected, buttonY);
		end

		buttonCursor:drawDifficultyCursor(
			layout['button']['x'],
			layout['y']['center'],
			427,
			74,
			4,
			cursor['alpha']
		);

		drawArrows();
	end

	gfx.Restore();

	if ((dialog.closing == true) and (timer <= 0)) then
		return false;
	else
		return true;
	end
end

advance_selection = function(value)
  selectedIndex = (selectedIndex + value) % #menuOptions;
end

button_pressed = function(button)
	if (button == game.BUTTON_BCK) then
		menu.Cancel();
	elseif button == game.BUTTON_STA then
		menuOptions[selectedIndex + 1]['action']();
	end
end

createCollection = function(name)
	return function()
		menu.Confirm(name);
	end
end