local Helpers = require('helpers/songwheel');

local Clears = require('constants/clears');
local Difficulties = require('constants/difficulties');
local Grades = require('constants/grades');

local JSONTable = require('common/jsontable');

local ScoreNumber = require('components/common/scorenumber');

local jacketFallback = gfx.CreateSkinImage('loading.png', 0);

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
	return makeLabel('num', val, 20, (positive and 'pos') or 'neg');
end

-- Gets the critical, near, and error deltas relative to the highest/lowest achieved values
---@param res result
---@return table
local getDeltas = function(res)
	if (#res.highScores == 0) then return {}; end

	local crits = nil;
	local critIdx = nil;
	local errors = nil;
	local errorIdx = nil;
	local nears = nil;
	local nearIdx = nil;

	for i, score in ipairs(res.highScores) do
		local hardFail = ((score.gauge_type or score.flags or 0) == 1)
			and (score.badge == 1);

		if (not hardFail) then
			if (not crits) then
				crits = score.perfects;
				critIdx = i;
			end

			if (not errors) then
				errors = score.misses;
				errorIdx = i;
			end

			if (not nears) then
				nears = score.goods;
				nearIdx = i;
			end

			if (score.perfects > crits) then
				crits = score.perfects;
				critIdx = i;
			end

			if (score.misses < errors) then
				errors = score.misses;
				errorIdx = i;
			end

			if (score.goods < nears) then
				nears = score.goods;
				nearIdx = i;
			end
		end
	end

	if ((not crits) or (not errors) or (not nears)) then return {}; end

	return {
		critical = deltaLabel(crits, res.perfects >= crits),
		critIdx = critIdx,
		error = deltaLabel(errors, res.misses <= errors),
		errorIdx = errorIdx,
		near = deltaLabel(nears, res.goods <= nears),
		nearIdx = nearIdx,
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
---@param unlabled boolean
---@return string
local getGauge = function(res, unlabled)
	local gauge = math.ceil((res.gauge or 0) * 100);
	local gType = res.gauge_type or res.flags or 0;

	if (not unlabled) then
		if (gType == 1) then
			return ('%d%% (EXC)'):format(gauge);
		elseif (gType == 2) then
			return ('%d%% (PMS)'):format(gauge);
		elseif (gType == 3) then
			return ('%d%% (BLS)'):format(gauge);
		end
	end

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

	return (res.name or res.playerName or displayName or 'GUEST'):upper():sub(1, 9);
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

-- Gets player volforce and increase if any
---@param res result
---@return ResultVF
local getVF = function(res)
	local increase = '';
	local minVF = getSetting('_minVF', 0);
	local playVF = Helpers.calcVF({
		jacketPath = res.jacketPath,
		level = res.level,
		scores = { { score = res.score } },
		topBadge = res.badge,
	});
	local playerVF = getSetting('_VF', 0);

	if (playVF > minVF) then
		increase = playVF - minVF;

		playerVF = playerVF + increase;

		increase = makeLabel(
			'num',
			{
				{ color = 'norm', text = '+' },
				{ color = 'white', text = ('%.3f'):format(increase) },
			},
			20
		);
	else
		increase = makeLabel('num', '', 20);
	end

	---@class ResultVF
	local v = {
		increase = increase,
		val = makeLabel('num', ('%.3f'):format(playerVF), 24),
	};

	return v;
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
		volforce = getVF(res),
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
		title = makeLabel('jp', getTitle(res), 32),
  };

	return s;
end

-- Gets data used for gauge graphs
---@param res result
---@return GaugeData
local getGaugeData = function(res)
	local blastiveLevel = getSetting('_blastiveLevel', '');
	local change = getSetting('_gaugeChange', '');
	local rate;
	local samples = (JSONTable:new('samples')):get();
	local type = res.gauge_type or res.flags or 0;
	local hardFail = (type == 1) and (res.badge == 1);

	if (type == 1) then
		rate = makeLabel('med', 'EXCESSIVE RATE', 20);
	elseif (type == 2) then
		rate = makeLabel('med', 'PERMISSIVE RATE', 20);
	elseif (type == 3) then
		rate = makeLabel(
			'med',
			('BLASTIVE RATE - %s'):format(tostring(blastiveLevel)),
			20
		);
	else
		rate = makeLabel('med', 'EFFECTIVE RATE', 20);
	end

	---@class GaugeData
	local g = {
		blastiveLevel = (type == 3)
			and (blastiveLevel ~= '')
			and makeLabel('num', blastiveLevel, 24),
		change = (change ~= '')
			and (not hardFail)
			and (res.badge > 0)
			and tonumber(change),
		curr = makeLabel('num', '0'),
		rate = rate,
		rawVal = res.gauge or 0,
		samples = ((res.badge > 0)
			and (#samples > 0)
			and (not hardFail)
			and samples
		) or res.gaugeSamples or {},
		type = type,
		unlabledVal = makeLabel('num', getGauge(res, true), 20),
		val = makeLabel('num', getGauge(res), 24),
	};

	return g;
end

-- Gets simple graph hit counts
---@param res result
---@return HitCounts, ScoreNumber
local getHitCounts = function(res)
	local hitStats = res.noteHitStats or {};
	local sCritWindow = ((res.hitWindow and res.hitWindow.perfect) or 46) * 0.5;
	local total = res.perfects + res.goods + res.misses;

	local errorEarly = 0;
	local early = 0;
	local criticalEarly = 0;
	local sCritical = 0;
	local criticalLate = 0;
	local late = 0;
	local errorLate = 0;

	local sCritBtn = 0;

	if (hitStats and (#hitStats > 0)) then
		for _, stat in ipairs(res.noteHitStats) do
			if (stat.rating == 2) then
				if (stat.delta < -sCritWindow) then
					criticalEarly = criticalEarly + 1;
				elseif (stat.delta > sCritWindow) then
					criticalLate = criticalLate + 1;
				else
					sCritBtn = sCritBtn + 1;
				end
			elseif (stat.rating == 1) then
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
		end
	end

	errorLate = errorLate + (res.misses - (errorEarly + errorLate));
	sCritical = res.perfects - (criticalEarly + criticalLate);

	-- https://bemaniwiki.com/index.php?SOUND%20VOLTEX%20EXCEED%20GEAR#hardware_Vm
	local exScore = (sCritBtn * 5)
		+ ((criticalEarly + criticalLate) * 4)
		+ (res.goods * 2)
		+ ((sCritical - sCritBtn) * 2);

	---@class HitCounts
	local c = {
		errorEarly = errorEarly,
		early = early,
		criticalEarly = criticalEarly,
		sCritical = sCritical,
		criticalLate = criticalLate,
		late = late,
		errorLate = errorLate,
		total = total,
	};

	return c, ScoreNumber:new({
		digits = 5,
		size = 24,
		val = exScore,
	});
end

-- Parses and formats data for graph display
---@param res result
---@return ResultGraphData
local getGraphData = function(res)
	local gaugeData = getGaugeData(res);
	local hitCounts, exScore = getHitCounts(res);

	local duration = res.duration;
	local histogram = {};
	local hoverScale = 10;
	local suggestion = nil;

	local count = 0;
	local data = {};
	local densities = JSONTable:new('densities');
	local hardFail = (gaugeData.type == 1) and (res.badge == 1);
	local idx = 1;
	local ms = 1000;
	local key = getSetting('_diffKey', '');
	local save = true;

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
		counts = hitCounts,
		duration = {
			label = makeLabel('num', '0', 20),
			val = duration or 0,
		},
		exScore = exScore,
		gauge = gaugeData,
		histogram = histogram,
		hitStats = res.noteHitStats,
		hoverScale = hoverScale,
		mean = makeLabel('num', getMeanDelta(res));
		median = makeLabel('num', getMedianDelta(res));
		nearWindow = (res.hitWindow and res.hitWindow.good) or 92,
		sCritWindow = ((res.hitWindow and res.hitWindow.perfect) or 46) * 0.5,
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