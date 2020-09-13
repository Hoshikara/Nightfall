local CONSTANTS = require('constants/songwheel');

local controls = require('songselect/controls');
local layout = require('layout/dialog');

local pressedBTA = false;

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
		labels['fxl'] = cacheLabel('[FX-L]', 20);
		labels['fxr'] = cacheLabel('[FX-R]', 20);
		labels['start'] = cacheLabel('[START]', 24);

		for index, tab in ipairs(CONSTANTS['tabs']) do
			gfx.LoadSkinFont('GothamMedium.ttf');
			labels['navigation'][index] = cacheLabel(tab, 20);

			gfx.LoadSkinFont('GothamBook.ttf');
			labels['tabs'][index] = cacheLabel(tab, 48);
		end

		gfx.LoadSkinFont('GothamBook.ttf');
		labels['ms'] = cacheLabel('MS', 24);

		for tabIndex, currentTab in ipairs(SettingsDiag.tabs) do
			labels['settings'][tabIndex] = {};

			for settingIndex, currentSetting in ipairs(currentTab.settings) do
				local setting = CONSTANTS['settings'][tabIndex][settingIndex];

				labels['settings'][tabIndex][settingIndex] = {
					['label'] = cacheLabel(setting['label'], 24);
				};

				if ((currentSetting.value ~= nil) and setting['values']) then
					labels['settings'][tabIndex][settingIndex]['values'] = {};

					for valueIndex, currentValue in ipairs(setting['values']) do
						labels['settings'][tabIndex][settingIndex]['values'][valueIndex] = cacheLabel(currentValue, 24);
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
	previousLabel:draw({
		['x'] = x1,
		['y'] = y
	});
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	labels['fxr']:draw({
		['x'] = x2 + 8,
		['y'] = y - 1
	});

	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(255, 255, 255, math.floor(255 * timer));
	nextLabel:draw({
		['x'] = x2, 
		['y'] = y
	});
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	labels['fxl']:draw({
		['x'] = x1 - 8,
		['y'] = y - 1
	});
end

drawHeading = function()
	local label = labels['tabs'][SettingsDiag.currentTab];
	local x = layout['x']['outerLeft'] - 2;
	local y = layout['y']['top'] - (label['h'] / 1.25);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.FillColor(60, 110, 160, math.floor(255 * timer));
	label:draw({
		['x'] = x,
		['y'] = y
	});
end

drawSettings = function()
	local currentSetting = SettingsDiag.currentSetting;
	local currentTab = SettingsDiag.currentTab;
	local settings = SettingsDiag.tabs[currentTab].settings;
	local settingLabels = labels['settings'][currentTab];

	local x = layout['x']['middleLeft'];
	local y = layout['y']['top'] + (labels['tabs'][currentTab]['h'] / 1.75);

	for index, setting in ipairs(settings) do
		local isSelected = currentSetting == index;
		local values = settingLabels[index]['values'];

		gfx.BeginPath();
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

		if (isSelected) then
			gfx.FillColor(255, 255, 255, math.floor(255 * timer));
		else
			gfx.FillColor(255, 255, 255, math.floor(50 * timer));
		end

		settingLabels[index]['label']:draw({
			['x'] = x,
			['y'] = y
		});

		if ((setting.value ~= nil) and values) then
			drawSettingValue(setting, values, y, isSelected);
		elseif ((setting.value == nil) and isSelected) then
			gfx.BeginPath();
			gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
			gfx.FillColor(60, 110, 160, math.floor(255 * timer));
			labels['start']:draw({
				['x'] = layout['x']['middleRight'],
				['y'] = y
			});
		end

		y = y + (settingLabels[index]['label']['h'] * 1.75);
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
		values[1]:update({ ['new'] = tostring(setting.value) });

		labels['ms']:draw({
			['x'] = x,
			['y'] = y
		});
		values[1]:draw({
			['x'] = x - labels['ms']['w'] - 12,
			['y'] = y
		});

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

		values[1]:update({ ['new'] = formatted });

		values[1]:draw({
			['x'] = x,
			['y'] = y
		});

		if (isSelected) then
			drawArrows(x, y, setting.value == setting.min, setting.value == setting.max);
		end
	elseif (setting.type == 'enum') then
		values[setting.value]:draw({
			['x'] = x,
			['y'] = y
		});

		if (isSelected) then
			drawArrows(x, y, false, false);
		end
	elseif (setting.type == 'toggle') then
		if (setting.value == false) then
			values[1]:draw({
				['x'] = x,
				['y'] = y
			});
		elseif (setting.value == true) then
			values[2]:draw({
				['x'] = x,
				['y'] = y
			});
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

	controls:render(deltaTime, displaying, scaledW, scaledH);

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

	layout['images']['dialogBox']:draw({
		['x'] = scaledW / 2,
		['y'] = scaledH / 2,
		['a'] = timer,
		['centered'] = true
	});
	
	gfx.Restore();

	drawHeading();

	drawSettings();

	drawNavigation();

	gfx.Restore();
end