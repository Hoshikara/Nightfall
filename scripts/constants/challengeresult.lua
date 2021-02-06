local CONSTANTS = {
  challengeHeading = {
    challenge = 'CHALLENGE',
    completion = 'COMPLETION',
    date = 'DATE',
    player = 'PLAYER',
    requirements = 'REQUIREMENTS',
    result = 'RESULT',
  },
  chartsPanel = {
    bpm = 'BPM',
    clear = 'CLEAR',
    completion = 'COMPLETION',
    critical = 'CRITICAL',
    difficulty = 'DIFFICULTY',
    error = 'ERROR',
    gauge = 'GAUGE',
    grade = 'GRADE',
    maxChain = 'MAX CHAIN',
    near = 'NEAR',
    result = 'RESULT',
    score = 'SCORE',
    title = 'TITLE',
  },
};

local generate = function(whichStrings)
  local labels = {};

  Font.Medium();

  for key, name in pairs(CONSTANTS[whichStrings]) do
    labels[key] = New.Label({ text = name, size = 18 });
  end

  return labels;
end

return { generate = generate };