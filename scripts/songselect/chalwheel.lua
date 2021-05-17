-- Global `chalwheel` table is available for this script and its related scripts

game.LoadSkinSample('click_song');

local Window = require('common/window');

local ChalCache = require('components/chalwheel/chalcache');
local ChalList = require('components/chalwheel/challist');
local ChalPanel = require('components/chalwheel/chalpanel');

local window = Window:new();

local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

local init = true;

---@class ChalWheel
local state = {
  currChal = 1,
  max = 6,
};

-- ChalWheel components
local chalCache = ChalCache:new();
local chalList = ChalList:new(window, state, chalCache);
local chalPanel = ChalPanel:new(window, state, chalCache);

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
  if (init) then
    game.SetSkinSetting('_songSelect', 'FALSE');

    init = false;
  end

  window:set(true);

  gfx.Save();

  if (window.isPortrait) then
		bgPortrait:draw({ w = window.w, h = window.h });
	else
		bg:draw({ w = window.w, h = window.h });
	end

  local w, h = chalPanel:render(dt);

  chalList:render(dt, w, h);

  gfx.Restore();
end

-- Called by the game when the `challenges` table is modified
---@param withAll boolean # `true` if `allChallenges`
challenges_changed = function(withAll) if (not withAll) then return; end end

-- Called by the game when `Page Up` or `Page Down` is pressed  
-- Advances the current challenge index by the specified amount
---@return integer
get_page_size = function() return state.max; end

-- Called by the game when the current challenge is changed
---@param newChal integer
set_index = function(newChal)
  if (state.currChal ~= newChal) then game.PlaySample('click_song'); end

	state.currChal = newChal;
end;