-- Global `result` table is available for this script and its related scripts
-- Result stats are available for each chart in the `charts` array instead
-- of in the `result` table itself as they would be for the regular results script

local Helpers = require('helpers/challengeresult');

local window = Window:new(true);

local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

local ChalHeading = require('components/challengeresult/chalheading');
local ChalCharts = require('components/challengeresult/chalcharts');
local Screenshot = require('components/result/screenshot');

---@class ChallengeResult
local state = {
	chal = nil,
	charts = nil,
	shotPath = '',
	shotTimer = 0,
};

-- Challenge Result components
local chalCharts = ChalCharts:new(window, state);
local chalHeading = ChalHeading:new(window, state);
local screenshot = Screenshot:new(state);

-- Called by the game when results screen is entered
result_set = function()
	state.chal = Helpers.formatChallenge(result);

	state.charts = Helpers.formatCharts(result);
end

-- Called by the game every frame
---@param dt deltaTime
---@param scroll number
render = function(dt, scroll)
	window:set();

	if (window.isPortrait) then
		bgPortrait:draw({ w = window.w, h = window.h });
	else
		bg:draw({ w = window.w, h = window.h });
	end

	local h = chalHeading:render(dt);

	chalCharts:render(dt, h);

	screenshot:render(dt);
end

-- Called by the game when `F12` is pressed  
-- Gets the bounding rectangle for a screenshot
---@return integer, integer, integer, integer
get_capture_rect = function() return 0, 0, game.GetResolution(); end

-- Called by the game when `F12` is pressed
---@param path string
screenshot_captured = function(path)
	state.shotPath = path:upper();
	state.shotTimer = 5;
end