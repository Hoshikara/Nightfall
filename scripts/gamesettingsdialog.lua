local GAMEPLAY_CONSTANTS = require('constants/gameplay')
local SONG_SELECT_CONSTANTS = require('constants/songwheel');

local controls = require('songselect/controls');
local layout = require('layout/dialog');

local controlsShortcut = getSetting('controlsShortcut', false);

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
	local labels = {
		controls = {
			fxl = New.Label({
				font = 'medium',
				text = '[FX-L]',
				size = 20,
			}),
			fxr = New.Label({
				font = 'medium',
				text = '[FX-R]',
				size = 20,
			}),
			start = New.Label({
				font = 'medium',
				text = '[START]',
				size = 24,
			}),
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

		labels.navigation[tabName] = New.Label({
			font = 'medium',
			text = formattedTab,
			size = 20,
		});

		labels.tabs[tabName] = New.Label({
			font = 'normal',
			text = formattedTab,
			size = 48,
		});

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
				name = New.Label({
					font = 'normal',
					text = formattedSetting,
					size = 24,
				}),
				special = get(settingConstants, 'special', ''),
				type = settingType,
			};

			if (settingType == 'INT') then
				tempTable.value = New.Label({
					font = 'number',
					text = '',
					size = 24,
				});
			elseif (settingType == 'FLOAT') then
				tempTable.value = New.Label({
					font = 'number',
					text = '',
					size = 24,
				});
			elseif (settingType == 'ENUM') then
				local options = get(currentSetting, 'options', {});

				if (settingConstants.name) then
					options = settingConstants.options;
				end

				tempTable.value = {};

				for optionIndex, currentOption in ipairs(options) do
					tempTable.value[optionIndex] = New.Label({
						font = 'normal',
						text = currentOption,
						size = 24,
					});
				end
			elseif (settingType == 'TOGGLE') then
				if (settingConstants.name) then
					if (settingConstants.invert) then
						tempTable.value = {
							['true'] = New.Label({
								font = 'normal',
								text = 'DISABLED',
								size = 24,
							}),
							['false'] = New.Label({
								font = 'normal',
								text = 'ENABLED',
								size = 24,
							}),
						};
					else
						tempTable.value = {
							['true'] = New.Label({
								font = 'normal',
								text = 'ENABLED',
								size = 24,
							}),
							['false'] = New.Label({
								font = 'normal',
								text = 'DISABLED',
								size = 24,
							}),
						};
					end
				else
					tempTable.value = {
						['true'] = New.Label({
							font = 'normal',
							text = 'TRUE',
							size = 24,
						}),
						['false'] = New.Label({
							font = 'normal',
							text = 'FALSE',
							size = 24,
						}),
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
		setFill('dark', 25 * timer);
	else
		setFill('dark', 125 * timer);
	end

	gfx.MoveTo(x1 + 1, y + 1);
	gfx.LineTo(x1 + 1, y + 13);
	gfx.LineTo(x1 - 9, y + 7)
	gfx.LineTo(x1 + 1, y + 1);
	
	gfx.Fill();

	gfx.BeginPath();

	if (minBounded) then
		setFill('white', 50 * timer);
	else
		setFill('white', 255 * timer);
	end

	gfx.MoveTo(x1, y);
	gfx.LineTo(x1, y + 12);
	gfx.LineTo(x1 - 10, y + 6)
	gfx.LineTo(x1, y);
	
	gfx.Fill();

	gfx.BeginPath();

	if (maxBounded) then
		setFill('dark', 25 * timer);
	else
		setFill('dark', 125 * timer);
	end

	gfx.MoveTo(x2 + 1, y + 1);
	gfx.LineTo(x2 + 1, y + 13);
	gfx.LineTo(x2 + 11, y + 7)
	gfx.LineTo(x2 + 1, y + 1);

	gfx.Fill();

	gfx.BeginPath();

	if (maxBounded) then
		setFill('white', 50 * timer);
	else
		setFill('white', 255 * timer);
	end

	gfx.MoveTo(x2, y);
	gfx.LineTo(x2, y + 12);
	gfx.LineTo(x2 + 10, y + 6)
	gfx.LineTo(x2, y);

	gfx.Fill();

	gfx.Restore();
end

drawArrow = function(initialX, initialY, direction)
	local x = initialX - 48;
	local y = initialY + 26;

	gfx.Save();

	gfx.Scale(scalingFactor, scalingFactor);

	gfx.BeginPath();

	setFill('white', 255 * timer);

	if (direction == 'UP') then
		gfx.MoveTo(x, y);
		gfx.LineTo(x + 24, y);
		gfx.LineTo(x + 12, y - 20);
		gfx.LineTo(x, y);	
	elseif (direction == 'DOWN') then
		gfx.MoveTo(x, y);
		gfx.LineTo(x + 24, y);
		gfx.LineTo(x + 12, y + 20);
		gfx.LineTo(x, y);
	end

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
	previousSetting = 0,
	timer = 0,

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
		drawLabel({
			x = self.layout.info.x1 - 2,
			y = self.layout.info.y,
			alpha = 255 * timer,
			color = 'normal',
			label = self.labels.tabs[current.tab.name],
		});
	end,

	drawSettings = function(self, deltaTime)
		if (current.setting.index ~= previousSetting) then
			self.timer = 0;

			previousSetting = current.setting.index;
		end

		self.timer = math.min(self.timer + (deltaTime * 4), 1);

		local labels = self.labels.settings[current.tab.name];

		local y = self.layout.info.y + (self.labels.tabs[current.tab.name].h * 1.75);
		local w = (self.layout.panel.w - (self.layout.info.x1 * 4) - 2)
			* smoothstep(self.timer);

		for i, rawSetting in ipairs(current.settings) do
			local setting = labels[string.gsub(
				rawSetting.name,
				' %((.*)%)',
				''
			)];
			local isSelected = i == current.setting.index;
			local x = (setting.indent and (self.layout.info.x1 + 24))
				or self.layout.info.x1;
			local alpha = (isSelected and (255 * timer)) or (125 * timer);

			if (isSelected) then
				drawRectangle({
					x = self.layout.info.x1 - 8,
					y = y,
					w = w,
					h = 30,
					alpha = alpha * 0.4,
					color = 'normal',
				});
			end

			drawLabel({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
				label = setting.name,p
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
			align = 'right',
			alpha = alpha,
			color = 'white',
		};

		if ((setting.type == 'BUTTON') and (not rawSetting.value)) then
			if (isSelected) then
				drawLabel({
					x = self.layout.info.x2,
					y = y,
					align = 'right',
					alpha = 255 * timer,
					color = 'white',
					label = self.labels.controls.start,
				});
			end
		else
			if (setting.type == 'INT') then
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

				params.label = setting.value;

				minBounded, maxBounded = rawSetting.value == rawSetting.min,
					rawSetting.value == rawSetting.max;
			elseif (setting.type == 'FLOAT') then
				local formatted;

				if (setting.max <= 1) then
					formatted = string.format('%.f%%', (rawSetting.value * 100));
				else
					formatted = string.format('%.2f', rawSetting.value);
				end

				setting.value:update({ new = formatted });

				params.label = setting.value;

				minBounded, maxBounded = rawSetting.value == rawSetting.min,
					rawSetting.value == rawSetting.max;
			elseif (setting.type == 'ENUM') then
				params.label = setting.value[rawSetting.value];
			elseif (setting.type == 'TOGGLE') then
				local boolString = tostring(rawSetting.value);
				local settingText = setting.value[boolString].text or '';

				if (settingText == 'DISABLED') then
					params.color = 'red';
				else
					params.color = 'normal';
				end

				params.label = setting.value[boolString];
			end

			drawLabel(params);
		end

		if (isSelected and (setting.type ~= 'BUTTON')) then
			drawArrows(self.layout.info.x2, y, minBounded, maxBounded);
		end
	end,

	drawNavigation = function(self)
		local x1 = self.layout.info.x1;
		local x2 = self.layout.info.x2 + 56;
		local y = self.layout.navigation.y;
	
		drawLabel({
			x = x1,
			y = y - 1,
			alpha = 255 * timer,
			color = 'normal',
			label = self.labels.controls.fxl,
		});

		drawLabel({
			x = x1 + self.labels.controls.fxl.w + 8,
			y = y,
			alpha = 255 * timer,
			color = 'white',
			label = self.labels.navigation[current.tab.previous],
		});

		drawLabel({
			x = x2,
			y = y,
			align = 'right',
			alpha = 255 * timer,
			color = 'white',
			label = self.labels.navigation[current.tab.next],
		});

		drawLabel({
			x = x2 - self.labels.navigation[current.tab.next].w - 8,
			y = y - 1,
			align = 'right',
			alpha = 255 * timer,
			color = 'normal',
			label = self.labels.controls.fxr,
		});
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		gfx.Save();

		drawRectangle({
			x = self.layout.panel.x,
			y = self.layout.panel.y,
			w = self.layout.panel.w,
			h = self.layout.panel.h,
			alpha = 230 * timer,
			color = 'black',
		});

		self:drawHeading();

		self:drawSettings(deltaTime);

		self:drawNavigation();

		gfx.Restore();
	end
};

local songSelectDialog = {
	labels = nil,
	previousSetting = 0,
	timer = 0,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = generateLabels(SONG_SELECT_CONSTANTS.settings);
		end
	end,

	drawHeading = function(self)
		local label = self.labels.tabs[current.tab.name];
		local x = layout.x.outerLeft - 2;
		local y = layout.y.top - (label.h / 1.25);
	
		drawLabel({
			x = x,
			y = y,
			alpha = 255 * timer,
			color = 'normal',
			label = label,
		});
	end,

	drawSettings = function(self, deltaTime)
		if (current.setting.index ~= previousSetting) then
			self.timer = 0;

			previousSetting = current.setting.index;
		end

		self.timer = math.min(self.timer + (deltaTime * 4), 1);

		local labels = self.labels.settings[current.tab.name];

		local offset = 0;
		local x = layout.x.middleLeft;
		local y = layout.y.top + (self.labels.tabs[current.tab.name].h / 1.75);
		local w = (layout.w.middle + 16) * smoothstep(self.timer); 

		if (current.setting.index > 7) then
			offset = (labels[string.gsub(
					current.settings[1].name,
					' %((.*)%)',
					''
				)].name.h * 1.75)
				* (current.setting.index - 7);
		end

		if (#current.settings > 7) then
			if (current.setting.index < 8) then
				drawArrow(
					layout.x.middleLeft,
					layout.y.bottom - ((self.labels.tabs[current.tab.name].h / 1.75) * 2.25),
					'DOWN'
				);
			else
				drawArrow(
					layout.x.middleLeft,
					layout.y.top + (self.labels.tabs[current.tab.name].h / 1.75),
					'UP'
				);
			end
		end

		y = y - offset;

		for i, rawSetting in ipairs(current.settings) do
			local setting = labels[string.gsub(
				rawSetting.name,
				' %((.*)%)',
				''
			)];
			local isSelected = i == current.setting.index;
			local alpha = (isSelected and (255 * timer)) or (125 * timer);

			if (((current.setting.index > 7) and (i <= (current.setting.index - 7)))
				or ((not isSelected) and (i > 7))
			) then
				alpha = 0;
			end

			if (isSelected) then
				gfx.Save();

				gfx.Scale(scalingFactor, scalingFactor);

				drawRectangle({
					x = (layout.x.middleLeft - 8),
					y = y,
					w = w,
					h = 30,
					alpha = alpha * 0.4,
					color = 'normal',
				});

				gfx.Restore();
			end

			drawLabel({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
				label = setting.name,
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
			align = 'right',
			alpha = alpha,
			color = 'white',
		};

		if ((setting.type == 'BUTTON') and (not rawSetting.value)) then
			if (isSelected) then
				drawLabel({
					x = layout.x.middleRight,
					y = y,
					align = 'right',
					alpha = alpha,
					color = 'white',
					label = self.labels.controls.start,
				});
			end
		else
			if (setting.type == 'INT') then
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

				params.label = setting.value;

				minBounded, maxBounded = rawSetting.value == rawSetting.min,
					rawSetting.value == rawSetting.max;
			elseif (setting.type == 'FLOAT') then
				local formatted;

				if (rawSetting.max <= 1) then
					formatted = string.format('%.f%%', (rawSetting.value * 100));
				else
					formatted = string.format('%.2f', rawSetting.value);
				end

				setting.value:update({ new = formatted });

				params.label = setting.value;

				minBounded, maxBounded = rawSetting.value == rawSetting.min,
					rawSetting.value == rawSetting.max;
			elseif (setting.type == 'ENUM') then
				params.label = setting.value[rawSetting.value];
			elseif (setting.type == 'TOGGLE') then
				local boolString = tostring(rawSetting.value);
				local settingText = setting.value[boolString].text or '';

				if (settingText == 'DISABLED') then
					params.color = 'red';
				else
					params.color = 'normal';
				end

				params.label = setting.value[boolString];
			end

			drawLabel(params);
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

		drawLabel({
			x = x1,
			y = y - 1,
			alpha = alpha,
			color = 'normal',
			label = self.labels.controls.fxl,
		});

		drawLabel({
			x = x1 + self.labels.controls.fxr.w + 8,
			y = y,
			alpha = alpha,
			color = 'white',
			label = self.labels.navigation[current.tab.previous],
		});
	
		drawLabel({
			x = x2,
			y = y,
			align = 'right',
			alpha = alpha,
			color = 'white',
			label = self.labels.navigation[current.tab.next],
		});

		drawLabel({
			x = x2 - self.labels.navigation[current.tab.next].w - 8,
			y = y - 1,
			align = 'right',
			alpha = alpha,
			color = 'normal',
			label = self.labels.controls.fxr,
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

		drawImage({
			x = scaledW / 2,
			y = scaledH / 2,
			alpha = timer,
			centered = true,
			image = layout.images.dialogBox,
		});
		
		gfx.Restore();

		self:drawHeading();

		self:drawSettings(deltaTime);

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
		practiceModeDialog:render(deltaTime);
	elseif (SettingsDiag.tabs[1].name == 'Offsets') then
		songSelectDialog:render(deltaTime, displaying);
	end

	gfx.Restore();
end
