local ScoreNumber = require('components/common/scorenumber');

---@class PracticeInfoClass
local PracticeInfo = {
  -- PracticeInfo constructor
  ---@param this PracticeInfoClass
  ---@param window Window
  ---@return PracticeInfo
  new = function(this, window)
    ---@class PracticeInfo : PracticeInfoClass
    ---@field window Window
    local t = {
      isPracticing = false,
      hitDelta = {
        prefix = makeLabel('num', '±', 24),
        mean = makeLabel('num', '0', 24),
        meanAbs = makeLabel('num', '0', 24),
      },
      labels = {
        hitDelta = makeLabel('med', 'MEAN HIT DELTA'),
        misses = makeLabel('med', 'MISSES'),
        mission = makeLabel('med', 'MISSION'),
        nears = makeLabel('med', 'NEARS'),
        passRate = makeLabel('med', 'PASS RATE', 24),
        prevPlay = makeLabel('med', 'PREVIOUS PLAY', 24),
        score = makeLabel('med', 'SCORE'),
      },
      misses = makeLabel('num', '0', 24),
      mission = makeLabel('norm', ''),
      nears = makeLabel('num', '0', 24),
      passRate = {
        ratio = makeLabel('num', '0', 24),
        value = makeLabel('num', '0', 24),
      },
      plays = 0,
      score = ScoreNumber:new({ size = 46 }),
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Update the practice info
  ---@param this PracticeInfo
  ---@param passes integer
  ---@param plays integer
  ---@param info table #
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
  set = function(this, passes, plays, info)
    this.plays = plays;

    if (info) then
      this.hitDelta.mean:update({
        text = ('%.1f'):format(info.meanHitDelta)
      });
      this.hitDelta.meanAbs:update({
        text = ('%.1f ms'):format(info.meanHitDeltaAbs)
      });

      this.misses:update({ text = info.misses });
      this.nears:update({ text = info.goods });

      this.passRate.ratio:update({
        text = ('%d / %d'):format(passes, plays)
      });
      this.passRate.value:update({
        text = ('%.1f%%'):format((passes / plays) * 100)
      });

      this.score.val = info.score;
    else
      this.isPracticing = false;
    end
  end,

  -- Update practice status
  ---@param this PracticeInfo
  ---@param desc string
  start = function(this, desc)
    this.isPracticing = true;

    this.mission:update({ text = desc:upper() });
  end,

  -- Renders the current component
  ---@param this PracticeInfo
  render = function(this)
    if (not this.isPracticing) then return; end

    local y = 0;

    gfx.Save();

    gfx.Translate(this.window.w / 100, this.window.h / 3);

    this.labels.mission:draw({ y = y });

    y = y + this.labels.mission.h * 1.35;

    this.mission:draw({
      y = y,
      color = 'white',
      maxWidth = this.window.w / 4,
    });

    if (this.plays > 0) then
      y = y + (this.mission.h * 3);

      this.labels.prevPlay:draw({ x = 1, y = y });

      y = y + (this.labels.prevPlay.h * 1.5);

      this.labels.score:draw({ x = 1, y = y });

      y = y + this.labels.score.h;

      this.score:draw({ x = -1, y = y });

      y = y + (this.score.h * 1.35);

      this.labels.nears:draw({ y = y });
      this.labels.misses:draw({ x = this.labels.nears.w * 2, y = y });

      y = y + (this.labels.nears.h * 1.35);

      this.nears:draw({ y = y, color = 'white' });
      this.misses:draw({
        x = this.labels.nears.w * 2,
        y = y,
        color = 'white',
      });

      y = y + (this.score.h * 0.75);

      this.labels.hitDelta:draw({ y = y });

      y = y + (this.labels.hitDelta.h * 1.35);

      this.hitDelta.mean:draw({ y = y, color = 'white' });
      this.hitDelta.prefix:draw({ x = this.hitDelta.mean.w + 10, y = y });
      this.hitDelta.meanAbs:draw({
        x = this.hitDelta.mean.w + 10 + this.hitDelta.prefix.w + 8,
        y = y,
        color = 'white',
      });

      y = y + (this.mission.h * 3);

      this.labels.passRate:draw({ y = y });

      y = y + (this.labels.passRate.h * 1.5);

      this.passRate.value:draw({ y = y, color = 'white' });
      this.passRate.ratio:draw({ x = this.passRate.value.w + 16, y = y });
    end

    gfx.Restore();
  end,
};

return PracticeInfo;