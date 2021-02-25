local CONSTANTS = require('constants/result');

local ScoreNumber = require('common/scorenumber');

local getDateFormat = function()
  local dateFormat = game.GetSkinSetting('dateFormat') or 'DAY-MONTH-YEAR';

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

local getDifficulty = function(current)
  local jacketPath = get(current, 'jacketPath', '');
  local difficulty = get(current, 'difficulty', 0);
  local difficultyIndex = getDifficultyIndex(jacketPath, difficulty);

  return CONSTANTS.difficulties[difficultyIndex];
end

local formatChallengeInfo = function(current)
  local labels = { requirements = {} };
  local player = game.GetSkinSetting('displayName') or 'GUEST';

  loadFont('normal');

  labels.title = New.Label({
    text = string.upper(get(current, 'title', '')),
    size = 36,
  });

  labels.player = New.Label({
    text = string.upper(player),
    size = 24,
  });

  loadFont('medium');

  for requirement in get(current, 'requirement_text', ''):gmatch('[^\n]+') do
    local label =  New.Label({
      text = string.upper(requirement),
      size = 20,
    });

    table.insert(labels.requirements, label);
  end

  if (get(current, 'passed', false)) then
    labels.result = New.Label({ text = 'PASS', size = 24 });
  else
    labels.result = New.Label({ text = 'FAIL', size = 24 });
  end

  loadFont('number');

  labels.completion = New.Label({
    text = string.format('%d%%', get(current, 'avgPercentage', 0)),
    size = 24,
  });

  labels.date = New.Label({
    text = os.date(getDateFormat(), os.time()),
    size = 24,
  });

  return labels;
end

local formatCharts = function(tbl)
  local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);
  local charts = {};

  for i, chart in ipairs(get(tbl, 'charts', {})) do
    local current = { timers = { artist = 0, title = 0 } };

    current.jacket = gfx.LoadImageJob(
      chart.jacketPath,
      jacketFallback,
      1000,
      1000
    );

    loadFont('jp');

    current.title = New.Label({
      text = string.upper(get(chart, 'title', '')),
      scrolling = true,
      size = 36,
    });

    loadFont('normal');

    if (get(chart, 'passed', false)) then
      current.result = New.Label({ text = 'PASS', size = 24 });
    else
      current.result = New.Label({ text = 'FAIL', size = 24 });
    end

    if (get(chart, 'badge', 0) == 0) then
      current.clear = New.Label({ text = 'EXIT', size = 24 });
    else
      current.clear = New.Label({
        text = CONSTANTS.clears[get(chart, 'badge', 1)],
        size = 24,
      });
    end

    current.difficulty = New.Label({ text = getDifficulty(chart), size = 24 });

    current.grade = New.Label({
      text = string.upper(get(chart, 'grade', '')),
      size = 24,
    });

    loadFont('number');

    current.bpm = New.Label({ text = get(chart, 'bpm', ''), size = 24 });

    current.completion = New.Label({
      text = string.format('%d%%', get(chart, 'percent', 0)),
      size = 24,
    });

    if (get(chart, 'gauge_type', get(chart, 'flags', 0)) == 1) then
      current.gauge = New.Label({
        text = string.format(
          '%d%% (H)',
          math.ceil(get(chart, 'gauge', 0) * 100)
        ),
        size = 24,
      });
    else
      current.gauge = New.Label({
        text = string.format(
          '%d%%',
          math.ceil(get(chart, 'gauge', 0) * 100)
        ),
        size = 24,
      });
    end

    current.level = New.Label({
      text = string.format('%02d', get(chart, 'level', 1)),
      size = 24,
    });

    current.critical = New.Label({
      text = get(chart, 'perfects', '-'),
      size = 24,
    });
    current.error = New.Label({
      text = get(chart, 'misses', '-'),
      size = 24,
    });
    current.maxChain = New.Label({
      text = get(chart, 'maxCombo', '-'),
      size = 24,
    });
    current.near = New.Label({
      text = get(chart, 'goods', '-'),
      size = 24,
    });

    current.score = {
      label = ScoreNumber.New({
        isScore = true,
        sizes = { 62, 50 },
      }),
      value = get(chart, 'score', 0),
    };

    charts[i] = current;
  end

  return charts;
end

return {
  formatChallengeInfo = formatChallengeInfo,
  formatCharts = formatCharts,
};