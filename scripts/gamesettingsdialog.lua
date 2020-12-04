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

generateLabels = function(constants)
	Font.Medium();

	local labels = {
		controls = {
			fxl = Label.New('[FX-L]', 20),
			fxr = Label.New('[FX-R]', 20),
			start = Label.New('[START]', 24),
		},
		navigation = {},
		settings = {},
		tabs = {},
	};

	for tabIndex, currentTab in ipairs(SettingsDiag.tabs) do
		local tabName = get(currentTab, 'name', '');
		local tabConstants = constants[tabName];
		local formattedTab = string.upper(tabName);

		if (tabConstants) then
			formattedTab = tabConstants.name;
		end

		Font.Medium();

		labels.navigation[tabName] = Label.New(formattedTab, 20);

		Font.Normal();

		labels.tabs[tabName] = Label.New(formattedTab, 48);

		labels.settings[tabName] = {};

		for settingIndex, currentSetting in ipairs(currentTab.settings) do
			local settingType = string.upper(get(currentSetting, 'type', ''));
			local settingName = string.gsub(
				get(currentSetting, 'name', ''),
				' %((.*)%)',
				''
			);
			local settingConstants = {};

			if (tabConstants) then
				settingConstants = tabConstants[settingName];
			end

			local formattedSetting = get(
				settingConstants,
				'name',
				string.upper(settingName)
			);

			local tempTable = {
				indent = get(settingConstants, 'indent', false),
				name = Label.New(formattedSetting, 24),
				special = get(settingConstants, 'special', ''),
				type = settingType,
			};

			if (settingType == 'INT') then
				tempTable.value = Label.New('', 24);
			elseif (settingType == 'FLOAT') then
				tempTable.value = Label.New('t', 24);
			elseif (settingType == 'ENUM') then
				local options = get(currentSetting, 'options', {});

				if (settingConstants.name) then
					options = settingConstants.options;
				end

				tempTable.value = {};

				for optionIndex, currentOption in ipairs(options) do
					tempTable.value[optionIndex] = Label.New(currentOption, 24);
				end
			elseif (settingType == 'TOGGLE') then
				if (settingConstants.name) then
					if (settingConstants.invert) then
						tempTable.value = {
							['true'] = Label.New('DISABLED', 24),
							['false'] = Label.New('ENABLED', 24),
						};
					else
						tempTable.value = {
							['true'] = Label.New('ENABLED', 24),
							['false'] = Label.New('DISABLED', 24),
						};
					end
				else
					tempTable.value = {
						['true'] = Label.New('TRUE', 24),
						['false'] = Label.New('FALSE', 24),
					};
				end
			end
			
			labels.settings[tabName][settingName] = tempTable;
		end
	end

	return labels;
end

local current = {
	setting = { index = 0, name = '' },
	settings = {},
	tab = {
		index = 0,
		name = '',
		next = '',
		previous = '',
	},

	update = function(self)
		self.setting.index = SettingsDiag.currentSetting;
		self.tab.index = SettingsDiag.currentTab;

		self.settings = SettingsDiag.tabs[self.tab.index].settings;

		self.setting.name = string.gsub(
			self.settings[self.setting.index].name,
			' %((.*)%)',
			''
		);
		self.tab.name = SettingsDiag.tabs[self.tab.index].name;

		if ((self.tab.index + 1) > #SettingsDiag.tabs) then
			self.tab.next = SettingsDiag.tabs[1].name;
		else
			self.tab.next = SettingsDiag.tabs[self.tab.index + 1].name;
		end

		if ((self.tab.index - 1) < 1) then
			self.tab.previous = SettingsDiag.tabs[#SettingsDiag.tabs].name;
		else
			self.tab.previous = SettingsDiag.tabs[self.tab.index - 1].name;
		end
	end
};

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
			self.labels = generateLabels(GAMEPLAY_CONSTANTS.settings);
		end
	end,

	drawHeading = function(self)
		local label = self.labels.tabs[current.tab.name];
	
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
		local labels = self.labels.settings[current.tab.name];

		local y = self.layout.info.y + (self.labels.tabs[current.tab.name].h * 1.75);

		for i, rawSetting in ipairs(current.settings) do
			local setting = labels[string.gsub(
				rawSetting.name,
				' %((.*)%)',
				''
			)];
			local isSelected = i == current.setting.index;
			local x = (setting.indent and (self.layout.info.x1 + 24))
				or self.layout.info.x1;
			local alpha = (isSelected and (255 * timer)) or (50 * timer);

			gfx.BeginPath();
			FontAlign.Left();

			setting.name:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});

			self:drawSettingValue(y, setting, rawSetting, isSelected, alpha);

			y = y + (setting.name.h * 1.75);
		end
	end,

	drawSettingValue = function(self, y, setting, rawSetting, isSelected, alpha)
		local isOffset = string.find(string.upper(rawSetting.name), 'OFFSET') ~= nil;
		local minBounded, maxBounded = false;
		local params = {
			x = self.layout.info.x2,
			y = y,
			a = alpha,
			color = 'White',
		};

		gfx.BeginPath();
		FontAlign.Right();

		if ((setting.type == 'BUTTON') and (not rawSetting.value)) then
			if (isSelected) then
				self.labels.controls.start:draw({
					x = self.layout.info.x2,
					y = y,
					a = 255 * timer,
					color = 'Normal',
				});
			end
		elseif (setting.type == 'INT') then
			Font.Number();

			if ((setting.special == 'TIME') or isOffset) then
				setting.value:update({
					new = string.format('%s ms', tostring(rawSetting.value)),
				});
			elseif (setting.special == 'PERCENTAGE') then
				setting.value:update({
					new = string.format('%s%%', tostring(rawSetting.value)),
				});
			else
				setting.value:update({ new = tostring(rawSetting.value) });
			end

			setting.value:draw(params);

			minBounded, maxBounded = rawSetting.value == rawSetting.min,
				rawSetting.value == rawSetting.max;
		elseif (setting.type == 'FLOAT') then
			local formatted;

			Font.Number();

			if (setting.max <= 1) then
				formatted = string.format('%.f%%', (rawSetting.value * 100));
			else
				formatted = string.format('%.2f', rawSetting.value);
			end

			setting.value:update({ new = formatted });

			setting.value:draw(params);

			minBounded, maxBounded = rawSetting.value == rawSetting.min,
				rawSetting.value == rawSetting.max;
		elseif (setting.type == 'ENUM') then
			Font.Normal();

			setting.value[rawSetting.value]:draw(params);
		elseif (setting.type == 'TOGGLE') then
			Font.Normal();

			setting.value[tostring(rawSetting.value)]:draw(params);
		end

		if (isSelected and (setting.type ~= 'BUTTON')) then
			drawArrows(self.layout.info.x2, y, minBounded, maxBounded);
		end
	end,

	drawNavigation = function(self)
		local x1 = self.layout.info.x1;
		local x2 = self.layout.info.x2 + 56;
		local y = self.layout.navigation.y;
	
		gfx.BeginPath();
	
		FontAlign.Left();

		self.labels.controls.fxl:draw({
			x = x1,
			y = y - 1,
			a = 255 * timer,
			color = 'Normal',
		});

		self.labels.navigation[current.tab.previous]:draw({
			x = x1 + self.labels.controls.fxl.w + 8,
			y = y,
			a = 255 * timer,
			color = 'White',
		});

		FontAlign.Right();

		self.labels.navigation[current.tab.next]:draw({
			x = x2,
			y = y,
			a = 255 * timer,
			color = 'White',
		});

		self.labels.controls.fxr:draw({
			x = x2 - self.labels.navigation[current.tab.next].w - 8,
			y = y - 1,
			a = 255 * timer,
			color = 'Normal',
		});
	end,

	render = function(self)
		self:setSizes();

		self:setLabels();

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
			self.labels = generateLabels(SONG_SELECT_CONSTANTS.settings);
		end
	end,

	drawHeading = function(self)
		local label = self.labels.tabs[current.tab.name];
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
		local labels = self.labels.settings[current.tab.name];

		local x = layout.x.middleLeft;
		local y = layout.y.top + (self.labels.tabs[current.tab.name].h / 1.75);

		for i, rawSetting in ipairs(current.settings) do
			local setting = labels[string.gsub(
				rawSetting.name,
				' %((.*)%)',
				''
			)];
			local isSelected = i == current.setting.index;
			local alpha = (isSelected and (255 * timer)) or (50 * timer);

			gfx.BeginPath();
			FontAlign.Left();

			setting.name:draw({
				x = x,
				y = y,
				a = alpha,
				color = 'White',
			});

			self:drawSettingValue(y, setting, rawSetting, isSelected, alpha);

			y = y + (setting.name.h * 1.75);
		end
	end,

	drawSettingValue = function(self, y, setting, rawSetting, isSelected, alpha)
		local isOffset = string.find(string.upper(rawSetting.name), 'OFFSET') ~= nil;
		local minBounded, maxBounded = false, false;
		local params = {
			x = layout.x.middleRight,
			y = y,
			a = alpha,
			color = 'White',
		};

		gfx.BeginPath();
		FontAlign.Right();

		if ((setting.type == 'BUTTON') and (not rawSetting.value)) then
			if (isSelected) then
				self.labels.controls.start:draw({
					x = layout.x.middleRight,
					y = y,
					a = alpha,
					color = 'Normal',
				});
			end
		elseif (setting.type == 'INT') then
			Font.Number();

			if (setting.special == 'TIME WINDOW') then
				setting.value:update({
					new = string.format('±%s ms', tostring(rawSetting.value)),
				});
			elseif ((setting.special == 'TIME') or isOffset) then
				setting.value:update({
					new = string.format('%s ms', tostring(rawSetting.value)),
				});
			else
				setting.value:update({ new = tostring(rawSetting.value) });
			end

			setting.value:draw(params);

			minBounded, maxBounded = rawSetting.value == rawSetting.min,
				rawSetting.value == rawSetting.max;
		elseif (setting.type == 'FLOAT') then
			local formatted;

			Font.Number();

			if (rawSetting.max <= 1) then
				formatted = string.format('%.f%%', (rawSetting.value * 100));
			else
				formatted = string.format('%.2f', rawSetting.value);
			end

			setting.value:update({ new = formatted });

			setting.value:draw(params);

			minBounded, maxBounded = rawSetting.value == rawSetting.min,
				rawSetting.value == rawSetting.max;
		elseif (setting.type == 'ENUM') then
			Font.Normal();

			setting.value[rawSetting.value]:draw(params);
		elseif (setting.type == 'TOGGLE') then
			Font.Normal();

			setting.value[tostring(rawSetting.value)]:draw(params);
		end

		if (isSelected and (setting.type ~= 'BUTTON')) then
			drawArrows(layout.x.middleRight, y, minBounded, maxBounded);
		end
	end,

	drawNavigation = function(self)
		local alpha = 255 * timer;
		local x1 = layout.x.middleLeft;
		local x2 = layout.x.outerRight;
		local y = layout.y.bottom + 12;

		gfx.BeginPath();

		FontAlign.Left();
	
		self.labels.controls.fxl:draw({
			x = x1,
			y = y - 1,
			a = alpha,
			color = 'Normal',
		});

		self.labels.navigation[current.tab.previous]:draw({
			x = x1 + self.labels.controls.fxr.w + 8,
			y = y,
			a = alpha,
			color = 'White',
		});
	
		FontAlign.Right();

		self.labels.navigation[current.tab.next]:draw({
			x = x2,
			y = y,
			a = alpha,
			color = 'White',
		});

		self.labels.controls.fxr:draw({
			x = x2 - self.labels.navigation[current.tab.next].w - 8,
			y = y - 1,
			a = alpha,
			color = 'Normal',
		});
	end,
	
	render = function(self, deltaTime, displaying)
		self:setLabels();

		layout:setSizes(scaledW, scaledH);

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

	current:update();

	if (SettingsDiag.tabs[1].name == 'Main') then
		practiceModeDialog:render();
	elseif (SettingsDiag.tabs[1].name == 'Offsets') then
		songSelectDialog:render(deltaTime, displaying);
	end

	gfx.Restore();
end
