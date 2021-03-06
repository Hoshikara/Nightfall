-- Global `gameplay` table is available for this script and its related scripts

local JSON = require('lib/json');

local BPMS = require('components/gameplay/bpms');
local Chain = require('components/gameplay/chain');
local Console = require('components/gameplay/console');
local CritBar = require('components/gameplay/critbar');
local Earlate = require('components/gameplay/earlate');
local GaugeBar = require('components/gameplay/gaugebar');
local HitAnimation = require('components/gameplay/hitanimation');
local HitDeltaBar = require('components/gameplay/hitdeltabar');
local LaserAlerts = require('components/gameplay/laseralerts');
local LaserAnimation = require('components/gameplay/laseranimation');
local LaserCursors = require('components/gameplay/lasercursors');
local Outro = require('components/gameplay/outro');
local PracticeInfo = require('components/gameplay/practiceinfo');
local ScoreInfo = require('components/gameplay/scoreinfo');
local Scoreboard = require('components/gameplay/scoreboard');
local SongInfo = require('components/gameplay/songinfo');
local UserInfo = require('components/gameplay/userinfo');

local window = Window:new();

local abs = math.abs;

---@type number
local minCritDelta = getSetting('minCritDelta', 23);
---@type boolean
local showCritDelta = getSetting('showCritDelta', false);

local players = nil;

---@type boolean
local showHitDeltaBar = getSetting('showHitDeltaBar', true);

---@class Gameplay
local state = {
	bpms = nil,
	buttonDelta = 0,
	chain = 0,
	intro = { alpha = 255, offset = 0 },
	isCrit = false,
	isLate = false,
	maxChain = 0,
	score = 0,
	showAdjustments = true,
	timers = {
		alerts = { -1.5, -1.5 },
		chain = 0,
		earlate = 0,
		intro = 2,
		outro = 0,
	},
};

-- Gameplay components
local bpms = BPMS:new(state);
local chain = nil;
local console = Console:new(window, state);
local critBar = CritBar:new(window);
local earlate = nil;
local gaugeBar = nil;
local hitAnimation = HitAnimation:new(window);
local hitDeltaBar = nil;
local laserAlerts = nil;
local laserAnimation = LaserAnimation:new(window);
local laserCursors = LaserCursors:new(window);
local outro = nil;
local practiceInfo = nil;
local scoreInfo = nil;
local scoreboard = nil;
local songInfo = nil;
local userInfo = nil;

local init = true;

local initAll = function()
	chain = Chain:new(window, state);
	earlate = Earlate:new(window, state);
	gaugeBar = GaugeBar:new(window, state);
	hitDeltaBar = HitDeltaBar:new(window);
	laserAlerts = LaserAlerts:new(window, state);
	outro = Outro:new(window);
	scoreInfo = ScoreInfo:new(window, state);
	songInfo = SongInfo:new(window, state);
	userInfo = UserInfo:new(window, state);

	if (gameplay.multiplayer) then scoreboard = Scoreboard:new(window); end

	if (gameplay.practice_setup ~= nil) then
		practiceInfo = PracticeInfo:new(window);
	end

	init = false;
end

-- Translates coordinates to the center of the critical line and applies any rotation from tilt effects
local setupCritTransform = function()
	gfx.ResetTransform();
	gfx.Translate(gameplay.critLine.x, gameplay.critLine.y);
	gfx.Rotate(-gameplay.critLine.rotation);
end

-- Called by the game when a button is pressed
---@param btn integer # `0 = BTA`, `1 = BTB`, `2 = BTC`, `3 = BTD`, `4 = FXL`, `5 = FXR`
---@param rating integer # `0 = Miss`, `1 = Near`, `2 = Crit`, `3 = Idle`
---@param delta integer # delta from 0 of the hit, in milliseconds
button_hit = function(btn, rating, delta)
	if (rating == 1) then
		state.isCrit = false;
		state.buttonDelta = delta;
	elseif (rating == 2) then
		if (showCritDelta) then
			if (abs(delta) >= minCritDelta) then
				state.isCrit = true;
				state.buttonDelta = delta;
				state.timers.earlate = 0.75;
			end
		end
	end

	if (showHitDeltaBar and hitDeltaBar) then
		hitDeltaBar:trigger(btn, rating, delta);
	end

	hitAnimation:trigger(btn, rating);
end

-- Called by the game when a laser slam is hit
---@param len number # Length of the slam relative to the track, sign indicates slam direction
---@param startPos number # The x-coordinate of the slam start, relative to the center of the crit line
---@param endPos number # The x-coordinate of the slam end, relative to the center of the crit line
---@param index integer # Laser index, `0` = left, `1` = right
laser_slam_hit = function(len, startPos, endPos, index)
	laserAnimation:trigger(endPos, index + 1);
end

-- Called by the game after rendering the track and playable objects (buttons and lasers)  
-- Drawn before built-in particle effects
---@param dt deltaTime
render_crit_base = function(dt)
	window:set(true);

	setupCritTransform();

	critBar:render(dt);

	gfx.ResetTransform();
end

-- Called by the game after rendering the base of the crit line  
-- Drawn above built-in particle effects but before the main `render` function
---@param dt deltaTime
render_crit_overlay = function(dt)
	hitAnimation:render(dt);

	laserAnimation:render(dt);

	setupCritTransform();

	if (window.isPortrait) then console:render(dt); end

	laserCursors:render(dt);

	gfx.ResetTransform();
end

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	gfx.ResetTransform();

	window:set();

	bpms:get(dt);

	if (init) then initAll(); end

	if (gameplay.progress == 0) then state.maxChain = 0; end

	if (state.chain > 0) then chain:render(dt); end

	earlate:render(dt);

	gaugeBar:render(dt);

	laserAlerts:render(dt);

	scoreInfo:render();

	songInfo:render(dt);

	if (showHitDeltaBar and (not gameplay.practice_setup)) then
		hitDeltaBar:render(dt);
	end

	if ((not gameplay.multiplayer) and (gameplay.practice_setup == nil)) then
		userInfo:render(dt);
	end

	if (gameplay.multiplayer and players) then scoreboard:render(players); end

	if (gameplay.practice_setup ~= nil) then
		practiceInfo:render();

		state.showAdjustments = not gameplay.practice_setup;
	end
end

-- Called by the game every frame until it returns `true`
---@param dt deltaTime
---@return boolean
render_intro = function(dt)
	if (gameplay.demoMode) then
		state.timers.intro = 0;

		return true;
	end

	if (not pressed('STA')) then
		state.timers.intro = to0(state.timers.intro, dt, 2);

		local t = math.max(state.timers.intro - 1, 0);

		state.intro.alpha = math.floor(255 * (1 - t ^ 1.5));
		state.intro.offset = t ^ 4;
	end

	return state.timers.intro <= 1;
end

-- Called by the game every frame until it returns `true`
---@param dt deltaTime
---@param clearState integer # `0 = Manual exit`, `1 = Failed`, `2 = Cleared`, `3 = Hard Cleared`, `4 = Ultimate Chain`, `5 = Perfect Chain`
---@return boolean, number # The second return value is playback speed during the outro
render_outro = function(dt, clearState)
	if (clearState == 0) then return true; end

	if (clearState > 1) then bpms:save(); end

	state.timers.outro = state.timers.outro + dt;

	if (not gameplay.demoMode) then
		outro:render(dt, clearState);

		return (state.timers.outro > 2), (1 - state.timers.outro);
	end
	
	return state.timers.outro > 2, 1;
end

-- Called by the game when there is an upcoming laser
---@param isRight boolean
laser_alert = function(isRight)
	if (isRight and (state.timers.alerts[2] < -1)) then
		state.timers.alerts[2] = 1;
	elseif (state.timers.alerts[1] < -1) then
		state.timers.alerts[1] = 1;
	end
end

-- Called by the game when there is a near hit
---@param isLate boolean
near_hit = function(isLate)
	state.isLate = isLate;
	state.timers.earlate = 0.75;
end

-- Called by the game to update the current chain
---@param newChain integer
update_combo = function(newChain)
	state.chain = newChain;

	if (state.chain > state.maxChain) then state.maxChain = state.chain; end

	state.timers.chain = 0.75;
end

-- Called by the game to update the current score
update_score = function(newScore) state.score = newScore; end

----------------------------------------
-- MULTIPLAYER
----------------------------------------

-- Called by the game when a multiplayer game is started
init_tcp = function()
	Tcp.SetTopicHandler(
		'game.scoreboard',
		function(data)
			players = {};

			for i, player in ipairs(data.users) do players[i] = player; end
		end
	);
end

-- Called by the game to update multiplayer user information
---@param res table
score_callback = function(res)
	if (res.status ~= 200) then
		error();
	
		return;
	end

	local data = JSON.decode(res.text);

	players = {};

	for i, player in ipairs(data.users) do players[i] = player; end
end

----------------------------------------
-- PRACTICE MODE
----------------------------------------

-- Called by the game when practice is starting
---@param type string # Type of the requirement: `'None'`, `'Score'`, `'Grade'`, `'Miss'`, `'MissAndNear'`, `'Gauge'`
---@param threshold any # Current requirement
---@param desc string # Description of the current requirement
practice_start = function(type, threshold, desc) practiceInfo:start(desc); end

-- Called by the game when a practice run is completed
---@param plays integer # Current count of total runs
---@param passes integer # Current count of successful runs
---@param passed boolean # Whether the run was successful
---@param scoreInfo table #
-- ```
-- {
-- 	goods: integer,
-- 	meanHitDelta: integer,
-- 	meanHitDeltaAbs: integer,
-- 	medianHitDelta: integer,
-- 	medianHitDeltaAbs: integer
-- 	misses: integer,
-- 	perfects: integer,
-- 	score: integer,
-- }
-- ```
practice_end_run = function(plays, passes, passed, scoreInfo)
	practiceInfo:set(passes, plays, scoreInfo);
end

-- Called by the game when practice setup is entered during or after a run
---@param plays integer # Current count of total runs
---@param passes integer # Current count of successful runs
practice_end = function(plays, passes) practiceInfo:set(passes, plays); end