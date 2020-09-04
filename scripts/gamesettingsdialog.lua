CONSTANTS = require('constants/songwheel');
layout = require('layout/dialog');

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
end

local labels = nil;

setLabels = function()
	if (not labels) then
		labels = {
			['navigation'] = {},
			['settings'] = {},
			['tabs'] = {}
		};

		gfx.LoadSkinFont('GothamMedium.ttf');
		labels['fxl'] = gfx.CreateLabel('[FX-L]', 20, 0);
		labels['fxr'] = gfx.CreateLabel('[FX-R]', 20, 0);
		labels['start'] = gfx.CreateLabel('[START]', 24, 0);

		for index, tab in ipairs(CONSTANTS['tabs']) do
			gfx.LoadSkinFont('GothamMedium.ttf');
			labels['navigation'][index] = gfx.CreateLabel(tab, 20, 0);

			gfx.LoadSkinFont('GothamBook.ttf');
			labels['tabs'][index] = gfx.CreateLabel(tab, 48, 0);
		end

		gfx.LoadSkinFont('GothamBook.ttf');
		labels['ms'] = gfx.CreateLabel('MS', 24, 0);

		for index, tab in ipairs(CONSTANTS['settings']) do
			labels['settings'][index] = {};

			for settingIndex, setting in pairs(tab) do
				labels['settings'][index][settingIndex] = {
					['label'] = gfx.CreateLabel(setting['label'], 24, 0)
				};

				if (setting['values']) then
					labels['settings'][index][settingIndex]['values'] = {};

					for valueIndex, value in ipairs(setting['values']) do
						labels['settings'][index][settingIndex]['values'][valueIndex] = gfx.CreateLabel(value, 24, 0);
					end
				end
			end
		end
	end
end

drawArrows = function(initialX, initialY, minBounded, maxBounded);
	local x1 = initialX + 28;
	local x2 = initialX + 44;
	local y = initialY + 10;

	gfx.Save();

	gfx.Scale(scalingFactor, scalingFactor);

	gfx.BeginPath();

	if (minBounded) then
		gfx.FillColor(255, 255, 255, math.floor(50 * timer));
	else
		gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	end

	gfx.MoveTo(x1, y);
	gfx.LineTo(x1, y + 12);
	gfx.LineTo(x1 - 10, y + 6)
	gfx.LineTo(x1, y);
	
	gfx.Fill();

	gfx.BeginPath();

	if (maxBounded) then
		gfx.FillColor(255, 255, 255, math.floor(50 * timer));
	else
		gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	end

	gfx.MoveTo(x2, y);
	gfx.LineTo(x2, y + 12);
	gfx.LineTo(x2 + 10, y + 6)
	gfx.LineTo(x2, y);

	gfx.Fill();

	gfx.Restore();
end

drawNavigation = function()
	local currentTab = SettingsDiag.currentTab;

	local next = (((currentTab + 1) <= 5) and (currentTab + 1)) or 1;
	local nextLabel = labels['navigation'][next];

	local previous = (((currentTab - 1) >= 1) and (currentTab - 1)) or 5;
	local previousLabel = labels['navigation'][previous];

	local x1 = layout['x']['innerLeft'];
	local x2 = layout['x']['outerRight'];
	local y = layout['y']['bottom'] + 12;

	gfx.BeginPath();

	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	gfx.DrawLabel(previousLabel, x1, y);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	gfx.DrawLabel(labels['fxr'], x2 + 8, y - 1);

	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	gfx.DrawLabel(nextLabel, x2, y);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	gfx.DrawLabel(labels['fxl'], x1 - 8, y - 1);
end

drawHeading = function()
	local label = labels['tabs'][SettingsDiag.currentTab];
	local x = layout['x']['outerLeft'] - 2;
	local y = layout['y']['top'] - (getLabelInfo(label)['h'] / 1.25);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	gfx.DrawLabel(label, x, y);
end

drawSettings = function()
	local currentSetting = SettingsDiag.currentSetting;
	local currentTab = SettingsDiag.currentTab;
	local settings = SettingsDiag.tabs[currentTab].settings;
	local settingLabels = labels['settings'][currentTab];

	local x = layout['x']['middleLeft'];
	local y = layout['y']['top'] + (getLabelInfo(labels['tabs'][currentTab])['h'] / 1.75);

	for index, setting in ipairs(settings) do
		local isSelected = currentSetting == index;
		gfx.BeginPath();
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

		if (isSelected) then
			gfx.FillColor(255, 255, 255, math.floor(255 * timer));
		else
			gfx.FillColor(255, 255, 255, math.floor(50 * timer));
		end

		gfx.DrawLabel(settingLabels[index]['label'], x, y);

		if (setting.value ~= nil) then
			drawSettingValue(setting, labels['settings'][currentTab][index]['values'], y, isSelected);
		elseif ((not setting.value) and isSelected) then
			gfx.BeginPath();
			gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
			gfx.FillColor(60, 110, 160, math.floor(255 * timer));
			gfx.DrawLabel(labels['start'], layout['x']['middleRight'], y);
		end

		y = y + (getLabelInfo(settingLabels[index]['label'])['h'] * 1.75);
	end
end

drawSettingValue = function(setting, values, y, isSelected)
	local x = layout['x']['middleRight'];

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
	
	if (isSelected) then
		gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	else
		gfx.FillColor(255, 255, 255, math.floor(50 * timer));
	end

	if (setting.type == 'int') then
		gfx.LoadSkinFont('DigitalSerialBold.ttf');
	
		gfx.UpdateLabel(values[1], tostring(setting.value), 24, 0);

		gfx.DrawLabel(labels['ms'], x, y);
		gfx.DrawLabel(values[1], x - getLabelInfo(labels['ms'])['w'] - 12, y);

		if (isSelected) then
			drawArrows(x, y, setting.value == setting.min, setting.value == setting.max);
		end
	elseif (setting.type == 'float') then
		local formatted;

		gfx.LoadSkinFont('DigitalSerialBold.ttf');

		if (setting.max <= 1) then
			formatted = string.format('%.f%%', (setting.value * 100));
		else
			formatted = string.format('%.2f', setting.value);
		end

		gfx.UpdateLabel(values[1], formatted, 24, 0);

		gfx.DrawLabel(values[1], x, y);

		if (isSelected) then
			drawArrows(x, y, setting.value == setting.min, setting.value == setting.max);
		end
	elseif (setting.type == 'enum') then
		gfx.DrawLabel(values[setting.value], x, y);

		if (isSelected) then
			drawArrows(x, y, false, false);
		end
	else
		if (setting.value == false) then
			gfx.DrawLabel(values[1], x, y);
		elseif (setting.value == true) then
			gfx.DrawLabel(values[2], x, y);
		end

		if (isSelected) then
			drawArrows(x, y, false, false);
		end
	end
end

render = function(deltaTime, displaying)
	-- TODO: skin this dialog for Practice Mode
	if (SettingsDiag.tabs[1].name == 'Main') then return end

	gfx.Save();

	setupLayout();

	layout:setAllSizes(scaledW, scaledH);

	setLabels();

	gfx.ForceRender();

	if ((timer > 0) and (not displaying)) then
		timer = math.max(timer - (deltaTime * 6), 0);

		if (timer == 0) then
			return;
		end
	end

	if (displaying) then
		timer = math.min(timer + (deltaTime * 8), 1);
	end

	gfx.Save();

	gfx.Scale(scalingFactor, scalingFactor);

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

	gfx.Restore();

	drawHeading();

	drawSettings();

	drawNavigation();

	gfx.Restore();
end