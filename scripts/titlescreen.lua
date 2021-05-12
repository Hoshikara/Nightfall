local JSONTable = require('common/jsontable');
local Knobs = require('common/knobs');
local Mouse = require('common/mouse');
local Window = require('common/window');

local Buttons = require('components/titlescreen/buttons');
local Controls = require('components/titlescreen/controls');
local PlayerInfo = require('components/titlescreen/playerinfo');
local Title = require('components/titlescreen/title');
local UpdatePrompt = require('components/titlescreen/updateprompt');

local window = Window:new();
local mouse = Mouse:new(window);

local playerData = JSONTable:new('player');
local player = playerData:get();

local bg = Image:new('bg.png');

---@class Titlescreen
---@field player Player
local state = {
	btnCount = 0,
	btnEvent = nil,
	checkedUpdate = false,
	choosingFolder = false,
	currBtn = 1,
	currPage = 'mainMenu',
	hasInfo = player.stats ~= nil,
	isClickable = false,
	loaded = false,
	player = player,
	promptUpdate = false,
	refreshInfo = false,
	samplePlayed = false,
	viewingControls = false,
	viewingCharts = false,
	viewingInfo = false,

	set = function(this, newState)
		for k, v in pairs(newState) do this[k] = v; end
	end,
};

-- Titlescreen components
local controls = Controls:new(window, mouse, state);
local buttons = Buttons:new(window, mouse, state);
local knobs = Knobs:new(state);
local playerInfo = PlayerInfo:new(window, mouse, state);
local title = Title:new(window, state);
local updatePrompt = UpdatePrompt:new(window, mouse, state);

local getInfo = function()
	if (getSetting('_loadInfo', 'FALSE') == 'TRUE') then
		player = playerData:get(true);

		if (player.stats) then
			state.hasInfo = true;
			state.player = player;
			state.refreshInfo = true;

			game.SetSkinSetting('_loadInfo', 'FALSE');
		end
	end
end
local debug = require('common/debug');
-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	mouse:watch();
	
	knobs:handleChange('btnCount', 'currBtn');

	state.btnEvent = nil;

	gfx.Save();

	window:set(true);

	bg:draw({ w = window.w, h = window.h });

	title:render(dt);

	buttons:render(dt);

	if (state.loaded and state.promptUpdate) then updatePrompt:render(dt); end

	if (state.viewingControls) then controls:render(dt); end

	if (state.viewingInfo) then
		getInfo();

		playerInfo:render(dt);
	end

	-- debug({
	-- 	count=playerInfo.count,
	-- 	viewingTop50 = playerInfo.viewingTop50,
	-- 	page = playerInfo.top50Page,
	-- 	pages = playerInfo.top50Pages,
	-- 	offset = playerInfo.list.offset
	-- })

	gfx.Restore();
end

-- Called by the game when the mouse is pressed
---@param btn integer
mouse_pressed = function(btn)
	if (state.isClickable and state.btnEvent) then state.btnEvent(); end

	return 0;
end

-- Called by the game when a (gamepad) button is pressed
---@param btn integer
button_pressed = function(btn)
	if (btn == game.BUTTON_STA) then 
		if (state.viewingControls) then
			state:set({ currBtn = 1, viewingControls = false });
		elseif (state.choosingFolder) then
			state.choosingFolder = false;

			playerInfo:toggleSelection();
		elseif (state.viewingCharts) then
			state.viewingCharts = false;
		elseif (state.viewingInfo) then
			state:set({ currBtn = 1, viewingInfo = false });
		elseif (state.btnEvent) then
			state.btnEvent();
		end
	elseif (btn == game.BUTTON_BCK) then
		if (state.choosingFolder) then
			state.choosingFolder = false;

			playerInfo:toggleSelection();
		elseif (state.viewingCharts) then
			state.viewingCharts = false;
		elseif (state.viewingControls) then
			state:set({ currBtn = 1, viewingControls = false });
		elseif (state.viewingInfo) then
			state:set({ currBtn = 1, viewingInfo = false });
		elseif (state.promptUpdate) then
			state:set({ currBtn = 1, promptUpdate = false });
		elseif (state.currPage == 'playOptions') then
			state:set({ currBtn = 1, currPage = 'mainMenu' });
		else
			Menu.Exit();
		end
	end
end