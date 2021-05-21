local Clears = require('constants/clears');
local Difficulties = require('constants/difficulties');
local Grades = require('constants/grades');

local Official = "OFFICIAL SOUND VOLTEX CHARTS";
local SDVX = "SDVX";
local SoundVoltex = "SOUND VOLTEX";

local ceil = math.ceil;
local floor = math.floor;

-- Checks if a chart or difficulty is "official" (inside a convert folder)
---@param path string
---@return boolean
local isOfficial = function(path)
  if (not path) then return false; end

  path = path:upper();

  return path:find(SDVX) or path:find(SoundVoltex);
end

local calcVF = function(diff)
  if (not isOfficial(diff.jacketPath)) then return 0; end

  if (#diff.scores < 1) then return 0; end

  local cRate = Clears[diff.topBadge] and Clears[diff.topBadge].rate;
  local gRate = 0;
  local level = diff.level;
  local score = diff.scores[1] and diff.scores[1].score;

  if (not (cRate and level and score)) then return 0; end

  for _, curr in ipairs(Grades) do
    if (score >= curr.min) then gRate = curr.rate; break; end
  end

  -- level * (score / 10 million) * (grade rate) * (clear rate) * 2
  -- truncated after first decimal place
  -- https://bemaniwiki.com/index.php?SOUND%20VOLTEX%20EXCEED%20GEAR/VOLFORCE#calc
  return floor(level * (score / 10000000) * gRate * cRate * 2 * 10) / 10;
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

-- Gets the grade for a score
---@param score integer
---@return string
local getGrade = function(score)
	for _, curr in ipairs(Grades) do
		if (score >= curr.min) then return curr.grade; end;
	end

	return '';
end

-- Formats gets necessary info for a diff
---@param diff Difficulty
---@return TopPlay
local formatDiff = function(diff)
  ---@class TopPlay
  local p = {
    bpm = diff.bpm,
    clear = Clears[diff.topBadge].clear,
    difficulty = Difficulties[getDiffIndex(diff.jacketPath, diff.difficulty)],
    grade = getGrade(diff.scores[1].score),
    jacketPath = diff.jacketPath,
    level = ('%02d'):format(diff.level),
    score = diff.scores[1].score,
    title = diff.title,
    VF = ('%.3f'):format(diff.VF / 100),
  };

  if (diff.artist) then
    p.artist = diff.artist;
    p.effector = diff.effector;
    p.timestamp = os.date(getDateFormat(), diff.scores[1].timestamp);
  end
  
  return p;
end

-- Sorts and formats top 50 plays
---@param top50 Difficulty[]
---@return TopPlay[]
local formatTop50 = function(top50)
  table.sort(top50, function(l, r)
    if (l.VF == r.VF) then return (l.scores[1].score > r.scores[1].score); end

    return (l.VF > r.VF);
  end);

  local t = {};

  for i, diff in ipairs(top50) do
    if (diff.VF == 0) then break; end

    if (i > 1) then
      diff.artist = nil;
      diff.effector = nil;
      diff.timestamp = nil;
    end

    t[i] = formatDiff(diff);

    if (i == 50) then break; end
  end

  return t;
end

-- Creates level tables, indexed by string of level
---@param folders string[]
---@return table<string, Level>
local makeLevels = function(folders)
	local l = {};

	for i = 10, 20 do
		local k = tostring(i);

		l[k] = {
			clears = {},
      clearTotals = {},
      diffTotals = {},
			grades = {},
      gradeTotals = {},
			scoreStats = {},
		};

		local clears = l[k].clears;
    local clearTotals = l[k].clearTotals;
    local diffTotals = l[k].diffTotals;
		local grades = l[k].grades;
    local gradeTotals = l[k].gradeTotals;
    local scoreStats = l[k].scoreStats;

		for _, curr in ipairs(Clears) do
      if (curr.clear ~= 'PLAYED') then
        clears[curr.clear] = {};

        local currClear = clears[curr.clear];

        for __, name in ipairs(folders) do
          currClear[name] = { charts = {}, total = 0 };
        end
      end
		end

		for _, curr in ipairs(Grades) do
			if (curr.grade == 'B') then break; end

			grades[curr.grade] = {};

			local currGrade = grades[curr.grade];

			for __, name in ipairs(folders) do
				currGrade[name] = { charts = {}, total = 0 };
			end
		end

		for _, name in ipairs(folders) do
			clearTotals[name] = { total = 0 };
      diffTotals[name] = { total = 0 };
			gradeTotals[name] = { total = 0 };
      scoreStats[name] = {
				avg = 0,
				count = 0,
				min = 0,
				max = 0,
				total = 0,
			};
		end
	end

	return l;
end

-- Update the given score stats
---@param scoreStats ScoreStats
---@param score integer
local updateScores = function(scoreStats, score)
  if (not scoreStats) then return; end

	scoreStats.count = scoreStats.count + 1;
	scoreStats.total = scoreStats.total + (score / 10000);

	if ((score < scoreStats.min) or (scoreStats.min == 0)) then
		scoreStats.min = score;
	end

	if ((score > scoreStats.max) or (scoreStats.max == 0)) then
		scoreStats.max = score;
	end
end

-- Update the given category
---@param cat table<string, FolderStats>
---@param folder string # Folder name
---@param updateAll boolean
---@param artist string
---@param title string
local updateCat = function(cat, folder, updateAll, artist, title)
  if (not cat[folder]) then return; end

  cat[folder].total = cat[folder].total + 1;

  if (updateAll) then cat.All.total = cat.All.total + 1; end

  if (artist and title) then
    cat[folder].charts[#cat[folder].charts + 1] = {
      artist = artist,
      title = title,
    };

    if (updateAll) then
      cat.All.charts[#cat.All.charts + 1] = {
        artist = artist,
        title = title,
      };
    end
  end
end

-- Gets total VF from top 50 scores
---@param topScores table
---@return number, BestPlay
local getVF = function(topScores)
  local diffs = {};
  local VF = 0;

  for i, song in ipairs(songwheel.allSongs) do
    for _, diff in ipairs(song.difficulties) do
      diff.songIndex = i;
      diff.score = (diff.scores[1] and diff.scores[1].score) or 0;
      diff.VF = calcVF(diff);

      diffs[#diffs + 1] = diff;
    end
  end

  table.sort(diffs, function(l, r)
    if (l.VF == r.VF) then return (l.score > r.score); end

    return (l.VF > r.VF);
  end);

  for i, diff in ipairs(diffs) do
    if (diff.VF > 0) then
      if (i <= 20) then
        topScores[diff.id] = '20';
      else
        topScores[diff.id] = '50';
      end

      VF = VF + diff.VF;
    end
    
    if (i == 50) then break; end
  end

  return VF / 100;
end

-- Parses player stats
---@param folders string[]
---@return PlayerStats
local getStats = function(folders)
  local folder = '';
  local levels = makeLevels(folders);
  local official = false;
  local playCount = 0;
  local top50 = {};

  for _, song in ipairs(songwheel.allSongs) do
    for __, name in ipairs(folders) do
      if (song.path:find(name)) then folder = name; end
    end

    official = isOfficial(song.path);
    
    for ___, diff in ipairs(song.difficulties) do
      local level = levels[tostring(diff.level)];

      if (official and diff.scores[1]) then
        diff.artist = song.artist;
        diff.bpm = song.bpm;
        diff.title = song.title;
        diff.VF = calcVF(diff);

        top50[#top50 + 1] = diff;
      end
  
      if (level) then
        playCount = playCount + #diff.scores;

        if (diff.topBadge > 1) then
          local score = diff.scores[1].score;
          local clear = level.clears[Clears[diff.topBadge].clear];

          updateCat(clear, folder, true, song.artist, song.title);
          updateCat(level.clearTotals, folder, true);

          if (official) then
            updateCat(clear, Official, false, song.artist, song.title);
            updateCat(level.clearTotals, Official, false);
          end

          if (score >= 8700000) then
            local grade = level.grades[getGrade(score)];

            updateCat(grade, folder, true, song.artist, song.title);
            updateCat(level.gradeTotals, folder, true);
            updateScores(level.scoreStats[folder], score);

            if (official) then
              updateCat(grade, Official, false, song.artist, song.title);
              updateCat(level.gradeTotals, Official, false);
              updateScores(level.scoreStats[Official], score);
            end

            updateScores(level.scoreStats.All, score);
          end
        end

        updateCat(level.diffTotals, folder, true);

        if (official) then
          updateCat(level.diffTotals, Official, false);
        end
      end
    end
  end

  for _, level in pairs(levels) do
    for __, name in ipairs(folders) do
      local scoreStats = level.scoreStats[name];

      if (scoreStats.count > 0) then
        scoreStats.avg = ceil((scoreStats.total / scoreStats.count) * 10000);
      end
    end
  end

  return {
    folders = folders,
    levels = levels,
    playCount = playCount,
    songCount = #songwheel.allSongs,
    top50 = formatTop50(top50),
  };
end

return {
  getStats = getStats,
  getVF = getVF
};