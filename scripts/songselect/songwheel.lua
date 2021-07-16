-- Global `songwheel` table is available for this script and its related scripts

game.LoadSkinSample('click_difficulty');
game.LoadSkinSample('click_song');

local Helpers = require('helpers/songwheel');

local JSONTable = require('common/jsontable');

local MiscInfo = require('components/songselect/miscinfo');
local SongCache = require('components/songselect/songcache');
local SongGrid = require('components/songselect/songgrid');
local SongPanel = require('components/songselect/songpanel');

local window = Window:new();
local background = Background:new(window);

local VF = 0;

local init = true;

---@class SongWheel
local state = {
	currDiff = 1,
	currSong = 1,
	infoLoaded = false,
	max = 9,
	songCount = 0,

	---@param this SongWheel
	watch = function(this)
		local song = songwheel.songs[this.currSong];
		local diff = song and song.difficulties[this.currDiff];

		if (diff) then
			local key = diff.hash or ('%s_%d'):format(song.title, diff.level);

			game.SetSkinSetting('_diffKey', key);
		end

		this.songCount = #songwheel.songs;
	end,
};

-- SongWheel components
local miscInfo = MiscInfo:new(window, state);
local songCache = SongCache:new();
local songGrid = SongGrid:new(window, state, songCache);
local songPanel = SongPanel:new(window, state, songCache);

-- Parses player stats to display on `Player Info` page
local makeStats = function(showNotif)
	local folders = (JSONTable:new('folders')):get();
	local player = JSONTable:new('player');

	if (#folders > 0) then
		local stats = Helpers.getStats(folders);

		if (stats and VF) then
			player:set('stats', stats);
			player:set('VF', VF);

			game.SetSkinSetting('_loadInfo', 'TRUE');

			if (showNotif) then state.infoLoaded = true; end
		end
	end
end

-- Check that all menus are closed
---@return boolean
local menusClosed = function()
	return (getSetting('_filtering', 'FALSE') == 'FALSE')
		and (getSetting('_sorting', 'FALSE') == 'FALSE')
		and (getSetting('_gameSettings', 'FALSE') == 'FALSE')
		and (getSetting('_collections', 'FALSE') == 'FALSE')
		and (not songwheel.searchInputActive);
end

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	if (init) then
		game.SetSkinSetting('_songSelect', 'TRUE');

		init = false;
	end

	if ((not state.infoLoaded) and pressed('BTA') and menusClosed()) then
		makeStats(true);
	end

	if (getSetting('_reloadInfo', 'FALSE') == 'TRUE') then
		makeStats();

		game.SetSkinSetting('_reloadInfo', 'FALSE');
	end

	state:watch();

	window:set();

	gfx.Save();

	background:render();

	songGrid:render(dt);

	local w = songPanel:render(dt);

	miscInfo:render(dt, w, VF);

	gfx.Restore();
end

-- Called by the game when `Page Up` or `Page Down` is pressed  
-- Advances the current song index by the specified amount
---@return integer
get_page_size = function() return state.max; end

-- Called by the game when the current song is changed
---@param newSong integer
set_index = function(newSong)
	if (state.currSong ~= newSong) then game.PlaySample('click_song'); end

	state.currSong = newSong;
end

-- Called by the game when the current difficulty is changed
---@param newDiff integer
set_diff = function(newDiff)
	if (state.currDiff ~= newDiff) then game.PlaySample('click_difficulty'); end

	state.currDiff = newDiff;
end

-- Called by the game when the `songs` table is modified
---@param withAll boolean # `true` if `allSongs`
songs_changed = function(withAll)
	if (not withAll) then return end

	songCache.top = {};

	VF = Helpers.getVF(songCache.top);
end
