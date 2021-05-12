-- Global `result` table is available for this script and its related scripts

local Helpers = require('helpers/result');

local Window = require('common/window');

local ResultPanel = require('components/result/resultpanel');
local ScoreList = require('components/result/scorelist');
local Screenshot = require('components/result/screenshot');

local window = Window:new(true);

local bg = Image:new('bg.png');

local shotRegion = getSetting('screenshotRegion', 'PANEL');
local showHardScores = getSetting('showHardScores', false);

---@class Result
---@field scores ResultScore[]
local state = {
	currScore = 1,
	jacket = nil,
	myScore = nil,
	scores = {},
	scoreCount = 0,
	shotPath = '',
	shotTimer = 0,
	song = nil,
	sp = true,
	upScore = nil,
};

-- Result components
local resultPanel = ResultPanel:new(window, state);
local scoreList = ScoreList:new(window, state);
local screenshot = Screenshot:new(state);

-- Called by the game when results screen is entered or when the viewed score is changed for multiplayer
result_set = function()
	local count = 0;

	state.scores = {};
	state.sp = result.uid == nil;

	if (not state.song) then state.song = Helpers.formatSong(result); end

	if (state.sp and showHardScores) then
		result.highScores = Helpers.filterScores(result.highScores);
	end

	if (not state.myScore) then state.myScore = Helpers.formatScore(result); end

	if (state.sp or result.isSelf) then
		if (#result.highScores > 0) then
			if (result.score > result.highScores[1].score) then
				state.upScore = result.score - result.highScores[1].score;
			end
		end

		state.graphData = Helpers.getGraphData(result);
	end

	for i, score in ipairs(result.highScores) do
		state.scores[i] = Helpers.formatHighScore(score, i);

		count = count + 1;
	end

	state.scoreCount = count;
end

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	window:set(true);

	bg:draw({ w = window.w, h = window.h });

	local w = resultPanel:render(dt);

	if (state.scoreCount > 0) then scoreList:render(dt, w); end

	screenshot:render(dt);
end

-- Called by the game when `F12` is pressed  
-- Gets the bounding rectangle for a screenshot
---@return integer, integer, integer, integer
get_capture_rect = function()
	if (shotRegion == 'FULLSCREEN') then return 0, 0, game.GetResolution(); end

	return state.getRegion();
end

-- Called by the game when `F12` is pressed
---@param path string
screenshot_captured = function(path)
	state.shotPath = path:upper();
	state.shotTimer = 5;
end