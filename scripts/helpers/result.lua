local CONSTANTS = require('constants/result');

local getClear = function(current)
  local autoplayed = get(current, 'autoplay', false);
  local clear = get(current, 'badge', 0);
  local gauge = get(current, 'gauge', 0) * 100;

  if (autoplayed) then
    return 'AUTO';
  elseif (clear == 0) then
    return 'EXIT'
  elseif (clear <= 5) then
    if (gauge < 70) then
      return 'CRASH';
    end

    return CONSTANTS.clears[clear];
  end
end

local getDifficulty = function(current)
  local difficulty = get(current, 'difficulty', 0) + 1;

  return CONSTANTS.difficulties[difficulty];
end

local getDuration = function(current)
  local duration = get(current, 'duration', 0);

  return string.format(
    '%dm %02d.%01ds',
    duration // 60000,
    (duration // 1000) % 60,
    (duration // 100) % 10
  );
end

local getGauge = function(current)
  local type = get(current, 'flags', 0);
  local gauge = get(current, 'gauge', 0) * 100;

  if (type == 1) then
    return string.format('%d%% (H)', math.ceil(gauge));
  end

  return string.format('%d%%', math.ceil(gauge));
end

local getGrade = function(current)
  local grade = get(current, 'grade');

  if (not grade) then
    local score = get(current, 'score', 0);

    for _, breakpoint in ipairs(CONSTANTS.grades) do
      if (score >= breakpoint.minimum) then
        return breakpoint.grade;
      end
    end
  end

  return string.upper(grade);
end

local getMeanDelta = function(current)
  local meanDelta = get(current, 'meanHitDelta');

  return (meanDelta and string.format('%.1f ms', meanDelta)) or '-';
end

local getMedianDelta = function(current)
  local medianDelta = get(current, 'medianHitDelta');

  return (medianDelta and string.format('%.1f ms', medianDelta)) or '-';
end

local getName = function(current)
  local displayName = game.GetSkinSetting('displayName');
  local playerName = get(current, 'playerName');
  local scoreName = get(current, 'name');

  return string.upper(scoreName or playerName or displayName);
end

local getPageBounds = function(viewLimit, totalItems, selected)
  local minimum = 1;
  local maximum = ((totalItems < viewLimit) and totalItems) or viewLimit;
  local pages = {};
  local pageCount = math.ceil(totalItems / viewLimit);

  for i = 1, pageCount do
    pages[i] = {
      lower = minimum,
      upper = maximum,
    };

    minimum = maximum + 1;
    maximum = (((maximum + viewLimit) < totalItems) and (maximum + viewLimit))
      or totalItems;
  end

  for _, bounds in ipairs(pages) do
    if ((selected >= bounds.lower) and (selected <= bounds.upper)) then
      return bounds.lower, bounds.upper;
    end
  end
end

local getScoreIndex = function(current)
  local uid = get(result, 'uid');

  for i, playerScore in ipairs(current.highScores) do
    if (uid == playerScore.uid) then
      return i;
    end
  end
end

local getTimestamp = function(current)
  local format = getDateFormat();
  local timestamp = get(current, 'timestamp', os.time());

  return os.date(format, timestamp);
end

local getTitle = function(current)
  local playerName = get(current, 'playerName');
  local realTitle = get(current, 'realTitle');
  local title = get(current, 'title', '-');

  return (playerName and realTitle and string.upper(realTitle))
    or string.upper(title);
end

local formatHighScore = function(current)
  return {
    clear = {
      font = 'normal',
      size = 24,
      value = getClear(current),
    },
    critical = {
      font = 'number',
      size = 24,
      value = get(current, 'perfects', '-'),
    },
    criticalWindow = {
      font = 'number',
      size = 24,
      value = string.format('%d ms', get(current, 'hitWindow.perfect', 46)),
    },
    gauge = {
      font = 'number',
      size = 24,
      value = getGauge(current),
    },
    grade = {
      font = 'normal',
      size = 24,
      value = getGrade(current),
    },
    error = {
      font = 'number',
      size = 24,
      value = get(current, 'misses', '-'),
    },
    name = {
      font = 'normal',
      size = 24,
      value = getName(current),
    },
    near = {
      font = 'number',
      size = 24,
      value = get(current, 'goods', '-'),
    },
    nearWindow = {
      font = 'number',
      size = 24,
      value = string.format('%d ms', get(current, 'hitWindow.good', 92)),
    },
    score = {
      font = 'number',
      size = { 90, 72 },
      value = string.format('%08d', get(current, 'score', 0)),
    },
    timestamp = {
      font = 'number',
      size = 24,
      value = getTimestamp(current),
    },
  };
end

local formatScore = function(current)
  local extendedScore = formatHighScore(current);

  extendedScore.early = {
    font = 'number',
    size = 24,
    value = get(current, 'earlies', ''),
  };
  extendedScore.late = {
    font = 'number',
    size = 24,
    value = get(current, 'lates', ''),
  };
  extendedScore.maxChain = {
    font = 'number',
    size = 24,
    value = get(current, 'maxCombo', '-'),
  };
  extendedScore.meanDelta = {
    font = 'number',
    size = 18,
    value = getMeanDelta(current),
  };
  extendedScore.medianDelta = {
    font = 'number',
    size = 18,
    value = getMedianDelta(current),
  };

  return extendedScore;
end

local formatSongInfo = function(current)
  return {
    artist = {
      font = 'jp',
      size = 30,
      value = string.upper(get(current, 'artist', '-')),
    },
    bpm = {
      font = 'number',
      size = 24,
      value = get(current, 'bpm', '-'),
    },
    difficulty = {
      font = 'normal',
      size = 24,
      value = getDifficulty(current),
    },
    duration = {
      font = 'number',
      size = 24,
      value = getDuration(current),
    },
    effector = {
      font = 'jp',
      size = 24,
      value = string.upper(get(current, 'effector', '-')),
    },
    level = {
      font = 'number',
      size = 24,
      value = get(current, 'level', '-'),
    },
    title = {
      font = 'jp',
      size = 36,
      value = getTitle(current),
    },
  };
end

return {
  formatHighScore = formatHighScore,
  formatScore = formatScore,
  formatSongInfo = formatSongInfo,
  getScoreIndex = getScoreIndex,
  getPageBounds = getPageBounds,
};