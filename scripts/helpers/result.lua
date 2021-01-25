local CONSTANTS = require('constants/result');

local getClear = function(current)
  local autoplayed = get(current, 'autoplay', false);
  local clear = get(current, 'badge', 0);
  local gauge = get(current, 'gauge', 0) * 100;
  local type = get(current, 'flags', 0);

  if (autoplayed) then
    return 'AUTO';
  elseif (clear == 0) then
    return 'EXIT'
  elseif (clear <= 5) then
    if ((type ~= 1) and (gauge < 70)) then
      return 'CRASH';
    end

    return CONSTANTS.clears[clear];
  end
end

local getDifficulty = function(current)
  local jacketPath = get(current, 'jacketPath', '');
  local difficulty = get(current, 'difficulty', 0);
  local difficultyIndex = getDifficultyIndex(jacketPath, difficulty);

  return CONSTANTS.difficulties[difficultyIndex];
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
  local displayName = game.GetSkinSetting('displayName') or 'GUEST';
  local playerName = get(current, 'playerName');
  local scoreName = get(current, 'name');

  return string.upper(scoreName or playerName or displayName);
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
      font = 'Normal',
      size = 24,
      value = getClear(current),
    },
    critical = {
      font = 'Number',
      size = 24,
      value = get(current, 'perfects', '-'),
    },
    gauge = {
      font = 'Number',
      size = 24,
      value = getGauge(current),
    },
    grade = {
      font = 'Normal',
      size = 24,
      value = getGrade(current),
    },
    hitWindows = {
      font = 'Number',
      size = 24,
      value = string.format(
        '±%d  /  %d ms',
        get(current, 'hitWindow.perfect', 46),
        get(current, 'hitWindow.good', 92)
      ),
    },
    error = {
      font = 'Number',
      size = 24,
      value = get(current, 'misses', '-'),
    },
    name = {
      font = 'Normal',
      size = 24,
      value = getName(current),
    },
    near = {
      font = 'Number',
      size = 24,
      value = get(current, 'goods', '-'),
    },
    score = get(current, 'score', 0),
    timestamp = {
      font = 'Number',
      size = 24,
      value = getTimestamp(current),
    },
  };
end

local formatScore = function(current)
  local extendedScore = formatHighScore(current);

  extendedScore.early = {
    font = 'Number',
    size = 24,
    value = get(current, 'earlies', '-'),
  };
  extendedScore.late = {
    font = 'Number',
    size = 24,
    value = get(current, 'lates', '-'),
  };
  extendedScore.maxChain = {
    font = 'Number',
    size = 24,
    value = get(current, 'maxCombo', '-'),
  };
  extendedScore.meanDelta = {
    font = 'Number',
    size = 18,
    value = getMeanDelta(current),
  };
  extendedScore.medianDelta = {
    font = 'Number',
    size = 18,
    value = getMedianDelta(current),
  };

  return extendedScore;
end

local formatSongInfo = function(current)
  return {
    artist = {
      font = 'JP',
      size = 30,
      value = string.upper(get(current, 'artist', '-')),
    },
    bpm = {
      font = 'Number',
      size = 24,
      value = get(current, 'bpm', '-'),
    },
    difficulty = {
      font = 'Normal',
      size = 24,
      value = getDifficulty(current),
    },
    duration = {
      font = 'Number',
      size = 24,
      value = getDuration(current),
    },
    effector = {
      font = 'JP',
      size = 24,
      value = string.upper(get(current, 'effector', '-')),
    },
    level = {
      font = 'Number',
      size = 24,
      value = get(current, 'level', '-'),
    },
    title = {
      font = 'JP',
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