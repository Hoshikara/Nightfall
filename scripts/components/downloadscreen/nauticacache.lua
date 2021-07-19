local Jackets = require('helpers/jackets');

---@class NauticaCacheClass
local NauticaCache = {
  -- NauticaCache constructor
  ---@param this NauticaCacheClass
  ---@return NauticaCache
  new = function(this)
    ---@class NauticaCache : NauticaCacheClass
    local t = { songs = {} };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Format the song's difficulties
  ---@param this NauticaCache
  ---@param diffs NauticaChart[]
  ---@return CachedNauticaDiff[]
  makeDiffs = function(this, diffs)
    local d = {};

    for i, curr in ipairs(diffs) do
      ---@class CachedNauticaDiff
      ---@field jacket_url string
      local diff = {
        diffIdx = curr.difficulty or 1,
        effector = makeLabel(
          'jp',
          ('BY %s'):format((curr.effector or ''):upper())
        ),
        level = makeLabel('num', ('%02d'):format(curr.level or 0), 24),
        timer = 0,
      };

      d[i] = diff;
    end

    return d;
  end,

  -- Get or create a cached version of the song
  ---@param this NauticaCache
  ---@param song NauticaSong
  ---@return CachedNauticaSong|nil
  get = function(this, song)
    if (not song) then return; end

    if (not this.songs[song.id]) then
      ---@class CachedNauticaSong
      local cached = {
        artist = makeLabel('jp', song.artist, 30),
        date = makeLabel('num', song.updated_at, 24),
        diffs = this:makeDiffs(song.charts or {}),
        jacket_url = song.jacket_url or '',
        status = nil,
        timer = 0,
        title = makeLabel('jp', song.title, 36),
        uploader = makeLabel('jp', (song.user and song.user.name) or ''),
      };

      this.songs[song.id] = cached;
    else
      this.songs[song.id].status = song.status;

      Jackets.load({ this.songs[song.id] });
    end

    return this.songs[song.id];
  end,
};

return NauticaCache;