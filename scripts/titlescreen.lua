local JSON = require('lib/json');

local JSONTable = require('common/jsontable');
local Knobs = require('common/knobs');
local Mouse = require('common/mouse');

local Buttons = require('components/titlescreen/buttons');
local Controls = require('components/titlescreen/controls');
local IngamePreview = require('components/titlescreen/ingamepreview');
local PlayerInfo = require('components/titlescreen/playerinfo');
local Title = require('components/titlescreen/title');
local UpdatePrompt = require('components/titlescreen/updateprompt');

local window = Window:new();
local background = Background:new(window);
local mouse = Mouse:new(window);

local playerData = JSONTable:new('player');
local player = playerData:get();

local checkTags = true;

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
	hoveringVersion = false,
	isClickable = false,
	loaded = false,
	newVersion = false,
	player = player,
	promptUpdate = false,
	refreshInfo = false,
	samplePlayed = false,
	viewingControls = false,
	viewingCharts = false,
	viewingInfo = false,
	viewingPreview = false,

	set = function(this, newState)
		for k, v in pairs(newState) do this[k] = v; end
	end,
};

-- Titlescreen components
local controls = Controls:new(window, mouse, state);
local buttons = Buttons:new(window, mouse, state);
local knobs = Knobs:new(state);
local ingamePreview = IngamePreview:new(window, mouse, state);
local playerInfo = PlayerInfo:new(window, mouse, state);
local title = Title:new(window, mouse, state);
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

-- Checks if there is a new skin version based on tags
---@param res HttpResponse
local tagsCallback = function(res)
	if (res and res.status and (res.status == 200)) then
		local body = JSON.decode(res.text or {});

		if (not body.message) then
			local ref = body[#body] and body[#body].ref or '';
			local version = ref:gsub('refs/tags/', '');

			if (SkinVersion ~= version) then state.newVersion = true; end
		end
	end
end

-- Gets list of tags for Nightfall repo
Http.GetAsync(
	'https://api.github.com/repos/Hoshikara/Nightfall/git/refs/tags',
	{ ['user-agent'] = 'unnamed-sdvx-clone' },
	tagsCallback
);

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	reloadColors();

	mouse:update();
	
	knobs:handleChange('btnCount', 'currBtn');

	state.btnEvent = nil;

	gfx.Save();

	window:set();

	background:render();

	buttons:render(dt);

	title:render(dt);

	if (state.loaded and checkTags) then
		Http.GetAsync(
		'https://api.github.com/repos/Hoshikara/Nightfall/git/refs/tags',
		{ ['user-agent'] = 'unnamed-sdvx-clone' },
		tagsCallback
		);

		checkTags = false;
	end

	if (state.loaded and state.promptUpdate) then updatePrompt:render(dt); end

	if (state.viewingControls) then controls:render(dt); end

	if (state.viewingInfo) then
		getInfo();

		gfx.ForceRender();

		playerInfo:render(dt);
	end

	if (state.viewingPreview) then ingamePreview:render(dt); end

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
		elseif (state.viewingPreview) then
			state:set({ currBtn = 1, viewingPreview = false });
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
		elseif (state.viewingPreview) then
			state:set({ currBtn = 1, viewingPreview = false });
		elseif (state.promptUpdate) then
			state:set({ currBtn = 1, promptUpdate = false });
		elseif (state.currPage == 'playOptions') then
			state:set({ currBtn = 1, currPage = 'mainMenu' });
		else
			Menu.Exit();
		end
	end
end