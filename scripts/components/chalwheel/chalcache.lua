local Clears = require('constants/clears');
local Difficulties = require('constants/difficulties');

local Jackets = require('helpers/jackets');

-- Formats the requirements of the provided chal
---@param chal Challenge
---@return CachedChalReq[]
local getReqs = function(chal)
  local reqs = {};
  
  for req in chal.requirement_text:gmatch('[^\n]+') do
    ---@class CachedChalReq
    local r = {
      text = makeLabel('norm', req),
      timer = 0,
    };

    reqs[#reqs + 1] = r;
  end

  return reqs;
end

---@class ChalCacheClass
local ChalCache = {
  -- ChalCache constructor
  ---@param this ChalCacheClass
  ---@return ChalCache
  new = function(this)
    ---@class ChalCache : ChalCacheClass
    local t = {
      diffs = {},
      chals = {},
      clears = {},
    };

    for i, curr in ipairs(Clears) do
      t.clears[i] = makeLabel('norm', curr.clear, 30);
    end

    for i, diff in ipairs(Difficulties) do
      t.diffs[i] = makeLabel('norm', diff);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Prevent stale data when challenges are changed or a challenge is set
  ---@param this ChalCache
  ---@param chal Challenge
  ---@param cached CachedChal
  checkStats = function(this, chal, cached)
    if (chal.topBadge == 0) then return; end

    cached.pct:update({
      text = ('%d%%'):format(math.max(0, ((chal.bestScore - 8000000) // 10000)))
    });
    cached.clear = this.clears[chal.topBadge];
    cached.grade:update({ text = chal.grade });
  end,

  -- Formats the challenge's charts
  ---@param this ChalCache
  ---@param charts Chart[]
  ---@return CachedChart[]
  makeCharts = function(this, charts)
    local c = {};
  
    for i, curr in ipairs(charts) do
      ---@class CachedChart
      local chart = {
        bpm = makeLabel('num', curr.bpm, 24),
        diff = this.diffs[getDiffIndex(curr.jacketPath, curr.difficulty)],
        jacketPath = curr.jacketPath,
        level = makeLabel('num', ('%02d'):format(curr.level), 24),
        timer = 0,
        title = makeLabel('jp', curr.title, 28),
      };

      c[i] = chart;
    end
    
    return c;
  end,

  -- Gets or create a cached version of the challenge
  ---@param this ChalCache
  ---@param chal Challenge
  ---@return CachedChal|nil
  get = function(this, chal)
    if (not chal) then return; end

    if (not this.chals[chal.id]) then
      ---@class CachedChal
      ---@field reqs Label[]
      local cachedChal = {
        charts = this:makeCharts(chal.charts),
        clear = this.clears[chal.topBadge],
        grade = makeLabel('norm', chal.grade or '', 30),
        missing = chal.missing_chart,
        pct = makeLabel('num', '0%', 30),
        reqs = getReqs(chal),
        timer = 0,
        title = makeLabel('jp', chal.title, 36),
      };

      this.chals[chal.id] = cachedChal;
    else
      this:checkStats(chal, this.chals[chal.id]);
      
      Jackets.load(this.chals[chal.id].charts);
    end

    return this.chals[chal.id];
  end,
};

return ChalCache;