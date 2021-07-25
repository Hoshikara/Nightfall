-- Steps value within given bounds
---@param val number
---@param min number
---@param max number
---@param step number
---@return number
local step = function(val, min, max, step)
  val = val + step;

  if (val < min) then val = max; end
  if (val > max) then val = min; end
  if ((val > min) and (val < (min + step))) then val = min; end

  return val;
end

-- Toggles boolean as an integer
---@param int integer
---@return integer
local toggle = function(int)
  if (int == 0) then return 1; end

  return 0;
end

-- Gets the height that the setting's labels take up
---@param settings IngamePreviewSetting[]
---@return number
local getHeight = function(settings)
  return (#settings * 36) + 24;
end

---@param p MakeSettingParams
---@return IngamePreviewSetting
local makeSetting = function(p)
  local t = {
    color = 'white',
    event = nil,
    format = p.format or '%.0f%%',
    multi = p.multi or 100,
    value = getSetting(p.key, p.default or 0);
    valueLabel = nil,
  };

  if (p.label) then t.label = makeLabel('norm', p.label, 24); end

  if (type(t.value) == 'boolean') then
    t.color = (t.value and 'pos') or 'neg';
    t.value = (t.value and 1) or 0;
  end

  if (p.options) then
    t.options = p.options;
    t.valueLabel = makeLabel('norm', t.value, 24);

    for i, str in ipairs(t.options) do
      if (str == t.value) then
        t.idx = i;

        break;
      end
    end

    if (not t.idx) then t.idx = 1; end

    t.event = function(sign)
      t.idx = advance(t.idx, #t.options, sign);
      t.value = t.options[t.idx];
      t.text = t.value;

      game.SetSkinSetting(p.key, t.value);
    end
  elseif (p.step) then
    t.valueLabel = makeLabel('num', (t.format):format(t.value * t.multi), 24);

    t.event = function(sign)
      t.value = step(t.value, p.min, p.max, p.step * sign);

      t.text = (t.format):format(t.value * t.multi);

      game.SetSkinSetting(p.key, t.value);
    end
  else
    t.options = {
      [0] = 'DISABLED',
      [1] = 'ENABLED',
    };
    t.valueLabel = makeLabel('norm', t.options[t.value]);

    t.event = function()
      t.value = toggle(t.value);
      t.text = t.options[t.value];

      if (t.value == 0) then
        t.color = 'neg';
      else
        t.color = 'pos';
      end

      game.SetSkinSetting(p.key, t.value);
    end
  end
  
  return t;
end

---@return IngamePreviewTab
local getEarlate = function()
  local s =  {
    heading = makeLabel('norm', 'EARLY / LATE', 30),
    status = makeSetting({
      default = 1,
      key = 'showEarlate',
      label = 'STATUS',
    }),
    settings = {
      makeSetting({
        default = 'TEXT',
        key = 'earlateType',
        label = 'DISPLAY TYPE',
        options = {
          'DELTA',
          'TEXT',
          'TEXT + DELTA',
        },
      }),
      makeSetting({
        default = 0.4,
        format = '%.0f%%',
        key = 'earlateGap',
        label = 'TEXT / DELTA GAP',
        min = 0.25,
        max = 1.0,
        step = 0.05,
      }),
      makeSetting({
        default = 1.0,
        key = 'earlateOpacity',
        format = '%.0f%%',
        label = 'OPACITY',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
      makeSetting({
        default = 18,
        key = 'earlateHz',
        format = '%d Hz',
        label = 'FLICKER SPEED',
        min = 1,
        max = 24,
        multi = 1,
        step = 1,
      }),
      makeSetting({
        default = 0.5,
        format = '%.0f%%',
        key = 'earlateX',
        label = 'X-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
      makeSetting({
        default = 0.75,
        key = 'earlateY',
        format = '%.0f%%',
        label = 'Y-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
    },
  };

  s.h = getHeight(s.settings);

  return s;
end

---@return IngamePreviewTab
local getHispeed = function()
  local s = {
    heading = makeLabel('norm', 'HI-SPEED', 30),
    status = makeSetting({
      default = 1,
      key = 'showHispeed',
    }),
    settings = {
      makeSetting({
        default = 0,
        key = 'ignoreSpeedChange',
        label = 'IGNORE CHANGE HINT',
      }),
      makeSetting({
        default = 0.5,
        format = '%.0f%%',
        key = 'hispeedX',
        label = 'X-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
      makeSetting({
        default = 0.5,
        key = 'hispeedY',
        format = '%.0f%%',
        label = 'Y-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
    },
    text = {
      makeLabel('num', '800  (8.0)', 30, 'white'),
      makeLabel('num', '>>  900  (9.0)', 30, 'neg')
    },
  };

  s.h = getHeight(s.settings);

  return s;
end

---@return IngamePreviewTab
local getHitDeltaBar = function()
  local s = {
    heading = makeLabel('norm', 'HIT DELTA BAR', 30),
    status = makeSetting({
      default = 1,
      key = 'showHitDeltaBar',
    }),
    settings = {
      makeSetting({
        default = 6.0,
        key = 'hitDecayTime',
        format = '%.2f s',
        label = 'DECAY TIME',
        min = 2.0,
        max = 10.0,
        multi = 1,
        step = 0.5,
      }),
      makeSetting({
        default = 1.0,
        key = 'hitDeltaBarScale',
        format = '%.0f%%',
        label = 'SCALE',
        min = 0.5,
        max = 2.0,
        step = 0.1,
      }),
    },
  };

  s.h = getHeight(s.settings);

  return s;
end

---@return IngamePreviewTab
local getScoreDiff = function()
  local s = {
    heading = makeLabel('norm', 'SCORE DIFFERENCE', 30),
    status = makeSetting({
      default = 1,
      key = 'showScoreDiff',
    }),
    numbers = { 0, 0, 0, 0 },
    settings = {
      makeSetting({
        default = 0.05,
        key = 'scoreDiffDelay',
        format = '%.2f s',
        label = 'UPDATE DELAY',
        min = 0.05,
        max = 1.0,
        multi = 1,
        step = 0.05,
      }),
      makeSetting({
        default = 0.05,
        format = '%.0f%%',
        key = 'scoreDiffX',
        label = 'X-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
      makeSetting({
        default = 0.5,
        key = 'scoreDiffY',
        format = '%.0f%%',
        label = 'Y-POSITION',
        min = 0.0,
        max = 1.0,
        step = 0.05,
      }),
    },
    text = {
      makeLabel('num', '0', 50),
      makeLabel('num', '0', 50),
      makeLabel('num', '0', 50),
      makeLabel('num', '0', 40),
      prefix = makeLabel('num', '+', 36),
    },
    x = {},
  };

  s.h = getHeight(s.settings);

  return s;
end

return {
  getEarlate = getEarlate,
  getHispeed = getHispeed,
  getHitDeltaBar = getHitDeltaBar,
  getScoreDiff = getScoreDiff,
};