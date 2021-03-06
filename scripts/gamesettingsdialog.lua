-- Global `SettingsDiag` table is available for this script and its related scripts

local GameSettings = require('components/songselect/gamesettings');
local PracticeSettings = require('components/gameplay/practicesettings');

local makeParser = require('helpers/gamesettings');

local window = Window:new();

local timer = 0;

---@class GameSettingsDialog
local state = {
	isSongSelect = true,
	setting = { index = 0, name = '' },
	settings = {},
	tab = {
		index = 0,
		name = '',
		next = '',
		prev = '',
	},

	-- Draw directional arrows for settings
	---@param this GameSettingsDialog
	---@param x number
	---@param y number
	---@param min number
	---@param max number
	drawArrows = function(this, x, y, min, max)
		local x1 = x + 28;
		local x2 = x + 44;
		
		y = y + 10;

		gfx.Save();

		if (this.isSongSelect) then window:scale(); end

		gfx.BeginPath();

		if (min) then
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

		if (min) then
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

		if (max) then
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

		if (max) then
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
	end,

	-- Remove parentheses and anything inside them
	---@param this GameSettingsDialog
	---@param str string
	---@return string
	gsub = function(this, str) return str:gsub(' %((.*)%)', ''); end,

	-- Update the current state
	---@param this GameSettingsDialog
	update = function(this)
		this.isSongSelect = SettingsDiag.tabs[1].name ~= 'Main';

		this.setting.index = SettingsDiag.currentSetting;
		this.tab.index = SettingsDiag.currentTab;

		this.settings = SettingsDiag.tabs[this.tab.index].settings;

		this.setting.name = this:gsub(this.settings[this.setting.index].name);
		this.tab.name = SettingsDiag.tabs[this.tab.index].name;

		if ((this.tab.index + 1) > #SettingsDiag.tabs) then
			this.tab.next = SettingsDiag.tabs[1].name;
		else
			this.tab.next = SettingsDiag.tabs[this.tab.index + 1].name;
		end

		if ((this.tab.index - 1) < 1) then
			this.tab.prev = SettingsDiag.tabs[#SettingsDiag.tabs].name;
		else
			this.tab.prev = SettingsDiag.tabs[this.tab.index - 1].name;
		end
	end,
};

local arsEnabled = makeParser('Offsets', 'false', 'Game', 'Backup Gauge');
local blastiveLevel = makeParser('Offsets', 0.5, 'Game', 'Blastive Rate Level');
local playbackSpeed = makeParser('Main', '1', 'Main', 'Playback speed (%)');
local scoreType = makeParser('Offsets', 'ADDITIVE', 'Game', 'Score Display');
local songOffset = makeParser('Offsets', '0', 'Offsets', 'Song Offset');

-- Make the base table to be used in the game settings or practice mode windows
---@param Constants table
---@return SettingsTable
local makeSettings = function(Constants)
	---@class SettingsTable
	local s = {
		controls = {
			fxl = makeLabel('med', '[FX-L]', 20),
			fxr = makeLabel('med', '[FX-R]', 20),
			start = makeLabel('med', '[START]', 20),
		},
		currSetting = 0,
		pages = {},
		settings = {},
		state = state,
		tabs = {},
		window = window,
		timer = 0,
	};

	for _, currTab in ipairs(SettingsDiag.tabs) do
		local tKey = currTab.name or '';
		local tConstants = Constants[tKey];
		local tName = (tConstants and tConstants.name) or tKey:upper();
		
		s.pages[tKey] = makeLabel('med', tName, 20);
		s.tabs[tKey] = makeLabel('norm', tName, 48);

		s.settings[tKey] = {};

		-- TODO: find a better way to do this
		if ((tKey == 'Game')
			and (currTab.settings[1].options and (#currTab.settings[1].options > 2))
			and (currTab.settings[1].value and (currTab.settings[1].value ~= 4))
		) then
			table.insert(currTab.settings, 2, {
				name = 'Blastive Rate Level',
				type = 'float',
			});
		end

		for __, currSetting in ipairs(currTab.settings) do
			local sKey = (currSetting.name or ''):gsub(' %((.*)%)', '');
			local sType = (currSetting.type or ''):upper();
			local sConstants = (tConstants and tConstants[sKey]) or {};
			local sName = sConstants.name or sKey:upper();

			local temp = {
				indent = sConstants.indent or false,
				name = makeLabel('norm', sName),
				special = sConstants.special or '',
				type = sType,
			};
		
			if (sType == 'INT') then
				temp.value = makeLabel('num', '0', 24);
			elseif (sType == 'FLOAT') then
				temp.value = makeLabel('num', '0', 24);
			elseif (sType == 'ENUM') then
				local opts = (sConstants.name and sConstants.options)
					or currSetting.options
					or {};

				temp.value = {};

				for i, currOpt in ipairs(opts) do
					temp.value[i] = makeLabel('norm', currOpt);
				end
			elseif (sType == 'TOGGLE') then
				if (sConstants.name) then
					if (sConstants.invert) then
						temp.value = {
							['true'] = makeLabel('norm', 'DISABLED'),
							['false'] = makeLabel('norm', 'ENABLED'),
						};
					else
						temp.value = {
							['true'] = makeLabel('norm', 'ENABLED'),
							['false'] = makeLabel('norm', 'DISABLED'),
						};
					end
				else
					temp.value = {
						['true'] = makeLabel('norm', 'TRUE'),
						['false'] = makeLabel('norm', 'FALSE'),
					};
				end
			end

			s.settings[tKey][sKey] = temp;
		end
	end

	return s;
end

local gameSettings = nil;
local hasBlastive = nil;
local practiceSettings = nil;

-- Called by the game every frame
---@param dt deltaTime
---@param displaying boolean
render = function(dt, displaying)
	if (hasBlastive == nil) then
		local gameTab = SettingsDiag.tabs[3] or { name = '', settings = {} };

		hasBlastive = (gameTab.name == 'Game')
			and gameTab.settings[1]
			and gameTab.settings[1].options
			and (#gameTab.settings[1].options > 2);
	end

	if (hasBlastive) then
		game.SetSkinSetting('_blastiveLevel', blastiveLevel:get());
	end

	game.SetSkinSetting('_arsEnabled', tostring(arsEnabled:get()));
	game.SetSkinSetting('_gameSettings', (displaying and 'TRUE') or 'FALSE');
	game.SetSkinSetting('_playbackSpeed', tostring(playbackSpeed:get()));
	game.SetSkinSetting('_scoreType', scoreType:get():upper());
	game.SetSkinSetting('_songOffset', tostring(songOffset:get()));

	if (displaying) then timer = to1(timer, dt, 0.125); end

	if ((timer > 0) and (not displaying)) then
		timer = to0(timer, dt, 0.167);
	end

	if (timer == 0) then return; end

	state:update();

	gfx.Save();

	window:set(true);

	if (state.isSongSelect) then
		if (not gameSettings) then
			local Constants = require('constants/gamesettings');

			gameSettings = GameSettings:new(makeSettings(Constants));
		else
			gameSettings:render(dt, timer);
		end
	else
		if (not practiceSettings) then
			local Constants = require('constants/practicesettings');

			practiceSettings = PracticeSettings:new(makeSettings(Constants));
		else
			practiceSettings:render(dt, displaying, timer);
		end
	end

	gfx.Restore();
end
