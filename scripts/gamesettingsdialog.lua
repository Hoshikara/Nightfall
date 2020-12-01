local GAMEPLAY_CONSTANTS = require('constants/gameplay')
local SONG_SELECT_CONSTANTS = require('constants/songwheel');

local controls = require('songselect/controls');
local layout = require('layout/dialog');

local controlsShortcut = game.GetSkinSetting('controlsShortcut') or false;

local timer = 0;

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

    cache.resX = resX;
    cache.resY = resY;
  end
end

confirmLabelAmount = function(tabs)
	local tabCount = 0;
	local settingCount = 0;

	local tabLabelCount = 0;
	local settingLabelCount = 0;

	for _, tab in ipairs(SettingsDiag.tabs) do
		tabCount = tabCount + 1;

		for _, setting in ipairs(tab.settings) do
			settingCount = settingCount + 1;
		end
	end

	for _, tab in ipairs(tabs) do
		tabLabelCount = tabLabelCount + 1;

		for _, settings in ipairs(tab) do
			settingLabelCount = settingLabelCount + 1;
		end
	end

	return ((tabCount == tabLabelCount) and (settingCount == settingLabelCount));
end

generateLabels = function(constants)
	local labels = {};

	labels = {
		navigation = {},
		settings = {},
		tabs = {}
	};

	Font.Medium();
	labels.fxl = Label.New('[FX-L]', 20);
	labels.fxr = Label.New('[FX-R]', 20);
	labels.start = Label.New('[START]', 24);

	for index, tab in ipairs(constants.tabs) do
		Font.Medium();
		labels.navigation[index] = Label.New(tab, 20);

		Font.Normal();
		labels.tabs[index] = Label.New(tab, 48);
	end

	Font.Normal();

	for tabIndex, currentTab in ipairs(SettingsDiag.tabs) do
		labels.settings[tabIndex] = {};

		for settingIndex, currentSetting in ipairs(currentTab.settings) do
			local setting = constants.settings[tabIndex][settingIndex];

			if (setting == nil) then
				setting = {
					label = string.upper(currentSetting.name),
				};
			end

			labels.settings[tabIndex][settingIndex] = {
				label = Label.New(setting.label, 24),
				indent = (setting.indent and true) or false,
			};

			if ((currentSetting.value ~= nil) and setting.values) then
				labels.settings[tabIndex][settingIndex].values = {};

				for key, currentValue in pairs(setting.values) do
					if (key == 'type') then
						labels.settings[tabIndex][settingIndex].values[key] = currentValue;
					else 
						labels.settings[tabIndex][settingIndex].values[key] = Label.New(currentValue, 24);
					end
				end
			end
		end
	end

	return labels;
end

drawArrows = function(initialX, initialY, minBounded, maxBounded);
	local x1 = initialX + 28;
	local x2 = initialX + 44;
	local y = initialY + 10;

	gfx.Save();

	if (SettingsDiag.tabs[1].name == 'Offsets') then
		gfx.Scale(scalingFactor, scalingFactor);
	end

	gfx.BeginPath();

	if (minBounded) then
		Fill.Dark(25 * timer);
	else
		Fill.Dark(125 * timer);
	end

	gfx.MoveTo(x1 + 1, y + 1);
	gfx.LineTo(x1 + 1, y + 13);
	gfx.LineTo(x1 - 9, y + 7)
	gfx.LineTo(x1 + 1, y + 1);
	
	gfx.Fill();

	gfx.BeginPath();

	if (minBounded) then
		Fill.White(50 * timer);
	else
		Fill.White(255 * timer);
	end

	gfx.MoveTo(x1, y);
	gfx.LineTo(x1, y + 12);
	gfx.LineTo(x1 - 10, y + 6)
	gfx.LineTo(x1, y);
	
	gfx.Fill();


	gfx.BeginPath();

	if (maxBounded) then
		Fill.Dark(25 * timer);
	else
		Fill.Dark(125 * timer);
	end

	gfx.MoveTo(x2 + 1, y + 1);
	gfx.LineTo(x2 + 1, y + 13);
	gfx.LineTo(x2 + 11, y + 7)
	gfx.LineTo(x2 + 1, y + 1);

	gfx.Fill();

	gfx.BeginPath();

	if (maxBounded) then
		Fill.White(50 * timer);
	else
		Fill.White(255 * timer);
	end

	gfx.MoveTo(x2, y);
	gfx.LineTo(x2, y + 12);
	gfx.LineTo(x2 + 10, y + 6)
	gfx.LineTo(x2, y);

	gfx.Fill();

	gfx.Restore();
end

local practiceModeDialog = {
	cache = { scaledW = 0, scaledH = 0 },	
	layout = {
		info = {
			x1 = 0,
			x2 = 0,
			y = 0,
		},
		navigation = { y = 0 },
		panel = {
			w = 0,
			h = 0,
			x = 0,
			y = 0,
		},
	},
	labels = nil,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.layout.panel.w = scaledW / 2.4;
			self.layout.panel.h = scaledH / 1.925;
			self.layout.panel.x = 0;
			self.layout.panel.y = scaledH / 4.25;

			self.layout.info.x1 = scaledW / 100;
			self.layout.info.x2 = self.layout.panel.w - (self.layout.info.x1 * 4);
			self.layout.info.y = scaledH / 4.1;

			self.layout.navigation.y = self.layout.panel.y + self.layout.panel.h - 48;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = generateLabels(GAMEPLAY_CONSTANTS);
		end
	end,

	drawHeading = function(self)
		local label = self.labels.tabs[SettingsDiag.currentTab];
	
		gfx.BeginPath();
		FontAlign.Left();
		Font.Normal();
		label:draw({
			x = self.layout.info.x1 - 2,
			y = self.layout.info.y,
			a = 255 * timer,
			color = 'Normal',
		});
	end,

	drawSettings = function(self)
		local currentSetting = SettingsDiag.currentSetting;
		local currentTab = SettingsDiag.currentTab;
		local settings = SettingsDiag.tabs[currentTab].settings;
		local settingLabels = self.labels.settings[currentTab];
	
		local y = self.layout.info.y + (self.labels.tabs[SettingsDiag.currentTab].h * 1.75);
	
		for index, setting in ipairs(settings) do
			local isSelected = currentSetting == index;
			local values = settingLabels[index].values;
			local x = (settingLabels[index].indent and (self.layout.info.x1 + 24)) or self.layout.info.x1;
	
			gfx.BeginPath();
			FontAlign.Left();
	
			settingLabels[index].label:draw({
				x = x,
				y = y,
				a = (isSelected and (255 * timer)) or (50 * timer),
				color = 'White',
			});
	
			if ((setting.value ~= nil) and values) then
				self:drawSettingValue(setting, values, y, isSelected);
			elseif ((setting.value == nil) and isSelected) then
				gfx.BeginPath();
				FontAlign.Right();
				self.labels.start:draw({
					x = self.layout.info.x2,
					y = y - 1,
					a = 255 * timer,
					color = 'Normal',
				});
			end
	
			y = y + (settingLabels[index].label.h * 1.75);
		end
	end,

	drawSettingValue = function(self, setting, values, y, isSelected)
		local alpha = (isSelected and (255 * timer)) or (50 * timer);
		local x = self.layout.info.x2;
	
		gfx.BeginPath();
		FontAlign.Right();
		
		if (setting.type == 'int') then
			Font.Number();
	
			if (values.type) then
				if (values.type == 'TIME') then
					values.value:update({ new = string.format('%s ms', tostring(setting.value)) });

					values.value:draw({
						x = x,
						y = y,
						a = alpha,
						color = 'White',
					});
				elseif (values.type == 'PERCENTAGE') then
					values.value:update({ new = string.format('%s%%', tostring(setting.value)) });

					values.value:draw({
						x = x,
						y = y,
						a = alpha,
						color = 'White',
					});
				end
			else
				values.value:update({ new = tostring(setting.value) });

				values.value:draw({
					x = x,
					y = y,
					a = alpha,
					color = 'White',
				});
			end
	
			if (isSelected) then
				drawArrows(x, y, setting.value == setting.min, setting.value == setting.max);
			end
		elseif (setting.type == 'float') then
			local formatted;
	
			Font.Number();
	
			if (setting.max <= 1) then
				formatted = string.format('%.f%%', (setting.value * 100));
			else
				formatted = string.format('%.2f', setting.value);
			end
	
			values.value:update({ new = formatted });
	
			values.value:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, setting.value == setting.min, setting.value == setting.max);
			end
		elseif (setting.type == 'enum') then
			Font.Normal();

			values[setting.value]:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, false, false);
			end
		elseif (setting.type == 'toggle') then
			Font.Normal();

			values[tostring(setting.value)]:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, false, false);
			end
		end
	end,

	drawNavigation = function(self)
		local currentTab = SettingsDiag.currentTab;
	
		local next = (((currentTab + 1) <= 5) and (currentTab + 1)) or 1;
		local nextLabel = self.labels.navigation[next];
	
		local previous = (((currentTab - 1) >= 1) and (currentTab - 1)) or 5;
		local previousLabel = self.labels.navigation[previous];
	
		local x1 = self.layout.info.x1;
		local x2 = self.layout.info.x2 + 56;
		local y = self.layout.navigation.y;
	
		gfx.BeginPath();
	
		FontAlign.Left();
		self.labels.fxl:draw({
			x = x1,
			y = y - 1,
			a = 255 * timer,
			color = 'Normal',
		});

		previousLabel:draw({
			x = x1 + self.labels.fxl.w + 8,
			y = y,
			a = 255 * timer,
			color = 'White',
		});

		FontAlign.Right();
		nextLabel:draw({
			x = x2,
			y = y,
			a = 255 * timer,
			color = 'White',
		});

		self.labels.fxr:draw({
			x = x2 - nextLabel.w - 8,
			y = y - 1,
			a = 255 * timer,
			color = 'Normal',
		});
	end,

	render = function(self)
		self:setSizes();

		self:setLabels();

		if (not confirmLabelAmount(self.labels.settings)) then
			drawErrorPrompt('Invalid label amount in gamesettingsdialog.lua');
			
			return;
		end

		gfx.Save();

		gfx.BeginPath();
		Fill.Black(230 * timer);
		gfx.Rect(
			self.layout.panel.x,
			self.layout.panel.y,
			self.layout.panel.w,
			self.layout.panel.h
		);
		gfx.Fill();

		self:drawHeading();

		self:drawSettings();

		self:drawNavigation();

		gfx.Restore();
	end
};

local songSelectDialog = {
	labels = nil,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = generateLabels(SONG_SELECT_CONSTANTS);
		end
	end,

	drawNavigation = function(self)
		local currentTab = SettingsDiag.currentTab;
	
		local next = (((currentTab + 1) <= 5) and (currentTab + 1)) or 1;
		local nextLabel = self.labels.navigation[next];
	
		local previous = (((currentTab - 1) >= 1) and (currentTab - 1)) or 5;
		local previousLabel = self.labels.navigation[previous];
	
		local alpha = 255 * timer;
		local x1 = layout.x.middleLeft;
		local x2 = layout.x.outerRight;
		local y = layout.y.bottom + 12;
	
		gfx.BeginPath();

		FontAlign.Left();
	
		self.labels.fxl:draw({
			x = x1,
			y = y - 1,
			a = alpha,
			color = 'Normal',
		});

		previousLabel:draw({
			x = x1 + self.labels.fxr.w + 8,
			y = y,
			a = alpha,
			color = 'White',
		});
	
		FontAlign.Right();

		nextLabel:draw({
			x = x2,
			y = y,
			a = alpha,
			color = 'White',
		});

		self.labels.fxr:draw({
			x = x2 - nextLabel.w - 8,
			y = y - 1,
			a = alpha,
			color = 'Normal',
		});
	end,

	drawHeading = function(self)
		local label = self.labels.tabs[SettingsDiag.currentTab];
		local x = layout.x.outerLeft - 2;
		local y = layout.y.top - (label.h / 1.25);
	
		gfx.BeginPath();
		FontAlign.Left();
		label:draw({
			x = x,
			y = y,
			a = 255 * timer,
			color = 'Normal',
		});
	end,

	drawSettings = function(self)
		local currentSetting = SettingsDiag.currentSetting;
		local currentTab = SettingsDiag.currentTab;
		local settings = SettingsDiag.tabs[currentTab].settings;
		local settingLabels = self.labels.settings[currentTab];
	
		local x = layout.x.middleLeft;
		local y = layout.y.top + (self.labels.tabs[currentTab].h / 1.75);
	
		for index, setting in ipairs(settings) do
			local isSelected = currentSetting == index;
			local values = settingLabels[index].values;
	
			gfx.BeginPath();
			FontAlign.Left();
	
			settingLabels[index].label:draw({
				x = x,
				y = y,
				a = (isSelected and (255 * timer)) or (50 * timer),
				color = 'White',
			});
	
			if ((setting.value ~= nil) and values) then
				self:drawSettingValue(setting, values, y, isSelected);
			elseif ((setting.value == nil) and isSelected) then
				gfx.BeginPath();
				FontAlign.Right();
				self.labels.start:draw({
					x = layout.x.middleRight,
					y = y,
					a = 255 * timer,
					color = 'Normal',
				});
			end
	
			y = y + (settingLabels[index].label.h * 1.75);
		end
	end,
	
	drawSettingValue = function(self, setting, values, y, isSelected)
		local alpha = (isSelected and (255 * timer)) or (50 * timer);
		local x = layout.x.middleRight;
	
		gfx.BeginPath();
		FontAlign.Right();
		
		if (setting.type == 'int') then
			Font.Number();

			if (get(values, 'type', '') == 'WINDOW') then
				values.value:update({
					new = string.format('±%s ms', tostring(setting.value)),
				});
			else
				values.value:update({
					new = string.format('%s ms', tostring(setting.value)),
				});
			end
	
			values.value:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, setting.value == setting.min, setting.value == setting.max );
			end
		elseif (setting.type == 'float') then
			local formatted;
	
			Font.Number();
	
			if (setting.max <= 1) then
				formatted = string.format('%.f%%', (setting.value * 100));
			else
				formatted = string.format('%.2f', setting.value);
			end
	
			values.value:update({ new = formatted });
	
			values.value:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, setting.value == setting.min, setting.value == setting.max );
			end
		elseif (setting.type == 'enum') then
			Font.Normal();

			values[setting.value]:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, false, false);
			end
		elseif (setting.type == 'toggle') then
			Font.Normal();

			values[tostring(setting.value)]:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});
	
			if (isSelected) then
				drawArrows(x, y, false, false);
			end
		end
	end,

	render = function(self, deltaTime, displaying)
		layout:setSizes(scaledW, scaledH);

		self:setLabels();

		if (not confirmLabelAmount(self['labels']['settings'])) then
			drawErrorPrompt('Invalid label amount in gamesettingsdialog.lua');
			
			return;
		end

		gfx.ForceRender();

		if (controlsShortcut) then
			controls:render(deltaTime, displaying, scaledW, scaledH);
		end

		gfx.Save();

		gfx.Scale(scalingFactor, scalingFactor);

		layout.images.dialogBox:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			a = timer,
			centered = true
		});
		
		gfx.Restore();

		self:drawHeading();

		self:drawSettings();

		self:drawNavigation();
	end
};

render = function(deltaTime, displaying)
	gfx.Save();

	setupLayout();

	if ((timer > 0) and (not displaying)) then
		timer = math.max(timer - (deltaTime * 6), 0);

		if (timer == 0) then
			return;
		end
	end

	if (displaying) then
		timer = math.min(timer + (deltaTime * 8), 1);
	end

	if (SettingsDiag.tabs[1].name == 'Main') then
		practiceModeDialog:render();
	elseif (SettingsDiag.tabs[1].name == 'Offsets') then
		songSelectDialog:render(deltaTime, displaying);
	end

	gfx.Restore();
end
