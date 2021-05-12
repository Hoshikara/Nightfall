local Clears = require('constants/clears');
local Grades = require('constants/grades');

local Jackets = require('helpers/jackets');

local JSONTable = require('common/jsontable');

---@class SongCacheClass
local SongCache = {
  -- SongCache constructor
  ---@param this SongCacheClass
  ---@return SongCache
  new = function(this)
    ---@class SongCache : SongCacheClass
    local t = {
      ---@type table<integer, string>
      best = {},
      clears = {},
      densities = JSONTable:new('densities'),
      grades = {},
      labels = {
        best = {
          large = {
            ['20'] = makeLabel('num', '20', 28),
            ['50'] = makeLabel('num', '50', 28),
            best = makeLabel('med', 'BEST', 28),
          },
          small = {
            ['20'] = makeLabel('num', '20'),
            ['50'] = makeLabel('num', '50'),
            best = makeLabel('med', 'BEST'),
          },
        },
      },
      songs = {},
    };

    for i, curr in ipairs(Clears) do
      t.clears[i] = makeLabel('norm', curr.clear, 36);
    end

    for i, curr in ipairs(Grades) do
      t.grades[i] = {
        min = curr.min,
        label = makeLabel('norm', curr.grade, 36),
      };
    end

    setmetatable(t, this);
    this.__index = this;
  
    return t;
  end,

  -- Gets the label and place for a chart of the best 50
  ---@param id integer # difficulty id
  ---@param this SongCache
  getBest = function(this, id)
    if (this.best[id]) then
      return { labels = this.labels.best, place = this.best[id] };
    end
  end,

  -- Gets the grade for a play
  ---@param this SongCache
  ---@return Label|nil
  ---@param score Score
  getGrade = function(this, score)
    if (not score) then return; end

    local highScore = score.score or 0;

    for _, grade in pairs(this.grades) do
      if (highScore >= grade.min) then return grade.label; end
    end
  end,
  
  -- Prevent stale data when songs are changed or a new score is set
  ---@param this SongCache
  ---@param song Song
  ---@param cached CachedSong
  checkDiffs = function(this, song, cached)
    if (song.difficulties[1] and cached.diffs[1]) then
      if ((song.difficulties[1].difficulty ~= cached.diffs[1].diff)
        or (#song.difficulties ~= #cached.diffs)
      ) then 
        cached.diffs = this:makeDiffs(song);
      else
        for i, diff in ipairs(song.difficulties) do
          if (diff.topBadge ~= 0) then
            cached.diffs[i].clear = this.clears[diff.topBadge];
            cached.diffs[i].grade = this:getGrade(diff.scores[1]);
            cached.diffs[i].highScore = (diff.scores[1]
              and diff.scores[1].score)
              or 0;

            if (getSetting('_graphMade', 'FALSE') == 'TRUE') then
              local key = diff.hash or ('%s_%d'):format(song.title, diff.level);
              local densityData = this.densities:get(true, key);
          
              if (densityData) then
                cached.diffs[i].densityData = densityData;
  
                game.SetSkinSetting('_graphMade', 'FALSE');
              end
            end
          end
        end
      end
    end
  end,

  -- Format the chart's difficulties
  ---@param this SongCache
  ---@param song Song
  ---@return CachedDiff[]
  makeDiffs = function(this, song)
    local d = {};
  
    for i, curr in ipairs(song.difficulties) do
      local key = curr.hash or ('%s_%d'):format(song.title, curr.level);

      ---@class CachedDiff
      local diff = {
        best = this:getBest(curr.id),
        clear = this.clears[curr.topBadge],
        densityData = this.densities:get(false, key),
        diff = curr.difficulty,
        effector = makeLabel('jp', curr.effector),
        grade = this:getGrade(curr.scores[1]),
        highScore = (curr.scores[1] and curr.scores[1].score) or 0,
        jacketPath = curr.jacketPath,
        level = makeLabel('num', ('%02d'):format(curr.level)),
      };

      d[i] = diff;
    end
  
    return d;
  end,

  -- Get or create a cached version of the song
  ---@param this SongCache
  ---@param song Song
  ---@return CachedSong|nil
  get = function(this, song)
    if (not song) then return; end

    if (not this.songs[song.id]) then
      ---@class CachedSong
      local cachedSong = {
        artist = makeLabel('jp', song.artist, 30),
        bpm = makeLabel('num', song.bpm, 24),
        diffs = this:makeDiffs(song),
        title = makeLabel('jp', song.title, 36),
      };

      this.songs[song.id] = cachedSong;
    else
      this:checkDiffs(song, this.songs[song.id]);

      Jackets.load(this.songs[song.id].diffs);
    end

    return this.songs[song.id];
  end,
};

return SongCache;