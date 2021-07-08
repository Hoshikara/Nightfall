local Constants = require('constants/playerinfo');

local ScoreNumber = require('components/common/scorenumber');

local Clears = Constants.clears;
local Grades = Constants.grades;
local Scores = Constants.scores;

---@type string[]
local ScoreStatNames = {
  'min',
  'max',
  'avg',
};

-- Get percentage string
---@param n integer
---@param d integer
---@return string
local getPct = function(n, d)
	if (d == 0) then return ('%.2f%%'):format(0); end

	return ('%.2f%%'):format((n / d) * 100);
end

-- Number label helper
---@param val number
---@return Label
local numLabel = function(val)
	if ((type(val) == 'number') and (val == 0)) then val = '-'; end

	return makeLabel('num', val, 30);
end

-- Format level clear/grade stats
---@param levels table<string, Level>
---@param folder string
---@param clears boolean
---@return PlayerStatsTable
local makeStats = function(levels, folder, clears)
	local Cats = (clears and Clears) or Grades;

	local alias = (clears and 'clears') or 'grades';
  local overall = 0;
	local total = 0;
	local totalsAlias = (clears and 'clearTotals') or 'gradeTotals';
	---@class PlayerStatsTable
	local t = {
		hovered = {
			completed = nil,
			pct = nil,
			row = 0,
			timer = 0,
		},
	};

  for _, cat in ipairs(Cats) do
		t[cat] = {
			charts = {},
			total = 0,
			label = makeLabel('med', cat, 24),
		};

		for level, curr in pairs(levels) do
			local charts = {};
			local completed = curr[alias][cat][folder].total;
			local diffTotal = curr.diffTotals[folder].total;

			for i, chart in ipairs(curr[alias][cat][folder].charts) do
				charts[i] = {
					artist = makeLabel('jp', chart.artist),
					score = ScoreNumber:new({ size = 24, val = chart.score }),
					title = makeLabel('jp', chart.title),
				};

				t[cat].charts[#t[cat].charts + 1] = {
					artist = makeLabel('jp', chart.artist),
					score = ScoreNumber:new({ size = 24, val = chart.score }),
					title = makeLabel('jp', chart.title),
				};
			end

			t[cat].total = t[cat].total + completed;

			t[cat][level] = {
				completed = numLabel(completed),
				charts = charts,
				alpha = 255,
				hoverable = completed > 0,
				key = ('%s%s'):format(cat, level),
				pct = numLabel(getPct(completed, diffTotal)),
				row = tonumber(level),
			};

			if (not t[level]) then
				local levelCompleted = curr[totalsAlias][folder].total;

				t[level] = {
					completed = numLabel(levelCompleted),
					pct = numLabel(getPct(levelCompleted, diffTotal)),
					total = numLabel(('/  %d'):format(diffTotal)),
				};

				total = total + diffTotal;
			end
		end
	end

  for _, cat in ipairs(Cats) do
		local catTotal = t[cat].total;

		t[cat].completed = numLabel(catTotal);

		overall = overall + catTotal;

		t[cat]['21'] = {
			alpha = 255,
			charts = t[cat].charts,
			completed = numLabel(catTotal),
			hoverable = catTotal > 0,
			key = ('%s%s'):format(cat, '21'),
			pct = numLabel(getPct(catTotal, total)),
		};
	end

	t['21'] = {
		completed = numLabel(overall),
		pct = numLabel(getPct(overall, total)),
		total = numLabel(('/  %d'):format(total)),
	};

  return t;
end

-- Formats level stats
---@param levels table<string, Level>
---@param folder string
---@return PlayerStatsTable clears, PlayerStatsTable grades, PlayerScoreStats
local makeAllStats = function(levels, folder)
	folder = folder or 'All';

	local c = makeStats(levels, folder, true);
	local g = makeStats(levels, folder, false);
  ---@class PlayerScoreStats
	local s = {};

	for i, score in ipairs(Scores) do
		s[score] = { label = makeLabel('med', score, 24) };

		for level, curr in pairs(levels) do
			local val = curr.scoreStats[folder][ScoreStatNames[i]];

			if (val == 0) then
				s[score][level] = makeLabel('num', '-', 40);
			else
				s[score][level] = ScoreNumber:new({
					size = 40,
					val = curr.scoreStats[folder][ScoreStatNames[i]],
				});
			end
		end
	end

	return c, g, s;
end

local makeTopPlay = function(i, play, best)
	---@class TopPlayFormatted
	local p = {
		bpm = makeLabel('num', play.bpm, 24),
		clear = makeLabel('norm', play.clear, (best and 24) or 36),
		difficulty = makeLabel('norm', play.difficulty),
		grade = makeLabel('norm', play.grade, (best and 24) or 36),
		jacketPath = play.jacketPath,
		level = makeLabel('num', play.level, 24),
		place = makeLabel('num', i, 36),
		score = ScoreNumber:new({ size = (best and 110) or 84, val = play.score }),
		title = makeLabel('jp', play.title, (best and 24) or 30),
		VF = makeLabel('num', play.VF, 24),
	};

	if (best) then
		p.artist = makeLabel('jp', play.artist, 30);
		p.effector = makeLabel('jp', play.effector, 24);
		p.timestamp = makeLabel('num', play.timestamp, 24);
	end

	return p;
end

-- Format top 50 plays
---@param top50 TopPlay[]
---@return TopPlayFormatted, TopPlayFormatted[]
local makeTop50 = function(top50)
	local best = nil;
	local t = {};
	
	for i, play in ipairs(top50) do
		if (not best) then best = makeTopPlay(i, play, true); end

		t[i] = makeTopPlay(i, play);
	end

	return best, t;
end

return {
	makeAllStats = makeAllStats,
	makeTop50 = makeTop50,
};