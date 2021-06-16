local Clears = require('constants/clears');
local Difficulties = require('constants/difficulties');
local Grades = require('constants/grades');

local JSONTable = require('common/jsontable');

local ScoreNumber = require('components/common/scorenumber');

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local minOffset = getSetting('minOffset', 1);

-- Get the clear name
---@param res result
---@return string
local getClear = function(res)
	if (res.autoplay) then return 'AUTO'; end

  local badge = res.badge or 0;

	if (badge == 0) then return 'EXIT'; end

	local gauge = (res.gauge or 0) * 100;
	local gType = res.gauge_type or res.flags or 0;

  if ((gType ~= 1) and (gauge < 70)) then return 'CRASH'; end

  return Clears[badge].clear;
end

-- Get the date format template string
---@return string
local getDateFormat = function()
  local dateFormat = getSetting('dateFormat', 'DAY-MONTH-YEAR');

  if (dateFormat == 'DAY-MONTH-YEAR') then
    return '%d-%m-%y';
  elseif (dateFormat == 'MONTH-DAY-YEAR') then
    return '%m-%d-%y';
  elseif (dateFormat == 'YEAR-MONTH-DAY') then
    return '%y-%m-%d';
  else
    return '%d-%m-%y';
  end
end

-- Delta value label wrapper function
---@param val number
---@param positive boolean
---@return Label
local deltaLabel = function(val, positive)
	return makeLabel('num', val, 20, (positive and 'norm') or 'red');
end

-- Gets the critical, near, and error deltas relative to the highest/lowest achieved values
---@param res result
---@return table<string, Label>
local getDeltas = function(res)
	if (#res.highScores == 0) then return {}; end

	local crits = nil;
	local errors = nil;
	local nears = nil;

	for _, score in ipairs(res.highScores) do
		local hardFail = ((score.gauge_type or score.flags or 0) == 1)
			and (score.badge == 1);

		if (not hardFail) then
			if (not crits) then crits = score.perfects; end
			if (not errors) then errors = score.misses; end
			if (not nears) then nears = score.goods; end

			if (score.perfects > crits) then crits = score.perfects; end
			if (score.misses < errors) then errors = score.misses; end
			if (score.goods < nears) then nears = score.goods; end
		end
	end

	if ((not crits) or (not errors) or (not nears)) then return {}; end

	return {
		critical = deltaLabel(crits, res.perfects >= crits),
		error = deltaLabel(errors, res.misses <= errors),
		near = deltaLabel(nears, res.goods <= nears),
	};
end

-- Gets the difficulty name
---@param res result
---@return string
local getDiff = function(res)
  local diffIndex = getDiffIndex(res.jacketPath or '', res.difficulty or 0);

  return Difficulties[diffIndex];
end

-- Gets and formats the chart duration
---@param res result
---@return string
local getDuration = function(res)
	local d = res.duration or 0;

  return ('%dm %02d.%01ds'):format(
		d // 60000,
		(d // 1000) % 60,
		(d // 100) % 10
	);
end

-- Gets and formats the ending gauge value
---@param res result
---@return string
local getGauge = function(res)
	local gauge = math.ceil((res.gauge or 0) * 100);
	local gType = res.gauge_type or res.flags or 0;

  if (gType == 1) then return ('%d%% (EXC)'):format(gauge); end

	return ('%d%%'):format(gauge);
end

-- Gets and formats the grade
---@param res result
---@return string
local getGrade = function(res)
  if (not res.grade) then
		local score = res.score or 0;

    for _, curr in ipairs(Grades) do
      if (score >= curr.min) then return curr.grade; end
    end
  end

  return res.grade:upper();
end

-- Gets and formats the mean hit delta
---@param res result
---@return string
local getMeanDelta = function(res)
	if (not res.meanHitDelta) then return '-'; end

	return ('%.1f ms'):format(res.meanHitDelta);
end

-- Gets and formats the median hit delta
---@param res result
---@return string
local getMedianDelta = function(res)
	if (not res.medianHitDelta) then return '-'; end

	return ('%.1f ms'):format(res.medianHitDelta);
end

-- Gets the name for a player's score
---@param res result
---@return string
local getName = function(res)
	local displayName = getSetting('displayName', 'GUEST');

	return (res.name or res.playerName or displayName or 'GUEST'):upper();
end

-- Gets the score index for a player's own score in multiplayer
---@param res result
---@return integer
local getScoreIndex = function(res)
  local uid = res.uid or '';

  for i, score in ipairs(res.highScores) do
		if (uid == score.uid) then return i; end
  end
end

-- Gets and formats a timestamp
---@param res result
local getTimestamp = function(res)
	return os.date(getDateFormat(), res.timestamp or os.time());
end

-- Gets the chart title
---@param res result
---@return string
local getTitle = function(res)
	if (res.playerName and res.realTitle) then return res.realTitle:upper(); end

	return (res.title or ''):upper();
end

-- Filters high scores to only display scores with harder hit windows
---@param scores Score[]
---@return Score[]
local filterScores = function(scores)
	if ((#scores == 0) or (not scores[1].hitWindow)) then return scores; end

	local s = {};

	for _, score in ipairs(scores) do
		if (score.hitWindow.perfect < 46) then s[#s + 1] = score; end
	end

	return s;
end

-- Formats a high score
---@param res result
---@param i integer
---@return ResultScore
local formatHighScore = function(res, i)
	---@class ResultScore
  local s = {
		clear = makeLabel('norm', getClear(res)),
		critical = ScoreNumber:new({
			digits = 5,
			size = 24,
			val = res.perfects or 0,
		}),
		early = makeLabel('num', res.earlies or '-', 24),
		gauge = makeLabel('num', getGauge(res), 24),
		grade = makeLabel('norm', getGrade(res)),
		hitWindows = makeLabel(
			'num',
			('±%d  /  %d ms'):format(
				res.hitWindow and res.hitWindow.perfect or 46,
				res.hitWindow and res.hitWindow.good or 92
			),
			24
		),
		error = ScoreNumber:new({
			digits = 5,
			size = 24,
			val = res.misses or 0,
		}),
		late = makeLabel('num', res.lates or '-', 24),
		maxChain = (res.maxCombo and ScoreNumber:new({
			digits = 5,
			size = 24,
			val = res.maxCombo or 0,
		})) or makeLabel('num', '-', 24),
		name = makeLabel('norm', getName(res)),
		near = ScoreNumber:new({
			digits = 5,
			size = 24,
			val = res.goods or 0,
		}),
		place = makeLabel('num', i, 90),
		score = ScoreNumber:new({ size = (i and 90) or 117, val = res.score or 0 }),
		timestamp = makeLabel('num', getTimestamp(res), 24),
  };

	return s;
end

-- Formats a score
---@param res result
---@return ResultScore
local formatScore = function(res)
  local base = formatHighScore(res);

	base.deltas = getDeltas(res);

  return base;
end

-- Formats song information
---@param res result
---@return ResultSong
local formatSong = function(res)
	local jacket = nil;

	if (res.jacketPath and (res.jacketPath ~= '')) then
		jacket = gfx.LoadImageJob(
			res.jacketPath,
			jacketFallback,
			500,
			500
		);
	end

	---@class ResultSong
  local s = {
		artist = makeLabel('jp', res.artist or '', 28),
		bpm = makeLabel('num', res.bpm or '', 24),
		difficulty = makeLabel('norm', getDiff(res)),
		duration = makeLabel('num', getDuration(res), 24),
		effector = makeLabel('jp', res.effector or '', 24),
		level = makeLabel('num', ('%02d'):format(res.level or 1), 24),
		jacket = jacket,
		name = makeLabel('norm', getName(res)),
		timestamp = makeLabel('num', getTimestamp(res), 24),
		title = makeLabel('jp', getTitle(res), 32),
  };

	return s;
end

-- Parses and formats data for graph display
---@param res result
---@return ResultGraphData
local getGraphData = function(res)
	local duration = res.duration;
	local histogram = {};
	local hoverScale = 10;
	local suggestion = nil;

	local count = 0;
	local data = {};
	local densities = JSONTable:new('densities');
	local hardFail = ((res.gauge_type or res.flags or 0) == 1)
		and (res.badge == 1);
	local idx = 1;
	local ms = 1000;
	local key = getSetting('_diffKey', '');
	local save = true;

	local early = 0;
	local errorEarly = 0;
	local errorLate = 0;
	local late = 0;
	local total = res.perfects + res.goods + res.misses;

	local gaugeSamples = (JSONTable:new('samples')):get();
	local gaugeChange = getSetting('_gaugeChange', '');

	if (duration) then hoverScale = math.max(duration / 10000, 5); end

	if (hardFail) then
		save = false;
	elseif (res.badge == 0) then
		if (res.autoplay) then
			if (res.score < 10000000) then save = false; end
		else
			save = false;
		end
	end

	if (res.noteHitStats and (#res.noteHitStats > 0)) then
		for _, stat in ipairs(res.noteHitStats) do
			if ((stat.rating == 1) or (stat.rating == 2)) then
				if (not histogram[stat.delta]) then histogram[stat.delta] = 0; end

				histogram[stat.delta] = histogram[stat.delta] + 1;
			end

			if (stat.rating == 1) then
				if (stat.delta < 0) then
					early = early + 1;
				else
					late = late + 1;
				end
			elseif (stat.rating == 0) then
				if (stat.delta < 0) then
					errorEarly = errorEarly + 1;
				else
					errorLate = errorLate + 1;
				end
			end

			if (save) then
				if (stat.time < ms) then
					count = count + 1;
				else
					data[idx] = count;

					count = 0;
					idx = idx + 1;
					ms = ms + 1000;
				end
			end
		end
	end

	if (key ~= '') then
		if (save) then
			densities:set(key, data);

			game.SetSkinSetting('_graphMade', 'TRUE');

			save = false;
		end
	end

	errorLate = errorLate + (res.misses - (errorEarly + errorLate));

	if (res.medianHitDelta) then
		local delta = math.floor(res.medianHitDelta);
		local offset = tonumber(getSetting('_songOffset', '0')) + delta;

		if (math.abs(delta) > minOffset) then
			suggestion = {
				text = makeLabel('med', 'RECOMMENDED SONG OFFSET: ', 18),
				offset = makeLabel('num', ('%d ms'):format(offset)),
			};
		end
	end

	---@class ResultGraphData
	local gd = {
		critWindow = (res.hitWindow and res.hitWindow.perfect) or 46,
		counts = {
			critical = res.perfects,
			early = early,
			errorEarly = errorEarly,
			errorLate = errorLate,
			late = late,
			total = total,
		},
		duration = {
			label = makeLabel('num', '0'),
			val = duration or 0,
		},
		gauge = {
			change = (gaugeChange ~= '')
				and (not hardFail)
				and ((res.badge > 0))
				and tonumber(gaugeChange),
			curr = makeLabel('num', '0'),
			samples = ((res.badge > 0)
				and (#gaugeSamples > 0)
				and (not hardFail)
				and gaugeSamples
			) or res.gaugeSamples or {},
			type = res.gauge_type or res.flags or 0,
			val = makeLabel('num', getGauge(res), 24),
		},
		histogram = histogram,
		hitStats = res.noteHitStats,
		hoverScale = hoverScale,
		mean = makeLabel('num', getMeanDelta(res));
		median = makeLabel('num', getMedianDelta(res));
		nearWindow = (res.hitWindow and res.hitWindow.good) or 92,
		suggestion = suggestion,
	};

	return gd;
end

-- Force player info reload if play meets collection criteria  
-- Level >= 10, cleared, grade at least A
---@param res result
local reloadInfo = function(res)
	if ((res.level >= 10) and (res.badge > 1) and (res.score >= 8700000)) then
		game.SetSkinSetting('_reloadInfo', 'TRUE');
	end
end

return {
	filterScores = filterScores,
  formatHighScore = formatHighScore,
  formatScore = formatScore,
  formatSong = formatSong,
	getGraphData = getGraphData,
  getScoreIndex = getScoreIndex,
	reloadInfo = reloadInfo,
};