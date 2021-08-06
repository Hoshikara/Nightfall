local Button = require('components/common/button');
local Cursor = require('components/common/cursor');
local List = require('components/common/list');
local ScoreNumber = require('components/common/scorenumber');
local Scrollbar = require('components/common/scrollbar');
local Spinner = require('components/common/spinner');

local Labels = {
  artist = 'ARTIST',
  date = 'DATE',
  title = 'TITLE',
  uploader = 'UPLOADER',
};

local Order = {
  'title',
  'artist',
  'uploader',
  'date',
};

-- Gets the difficulty within range 1-4
---@param diffs CachedNauticaDiff[]
---@param i integer
---@return CachedNauticaDiff
local getDiff = function(diffs, i)
  local index = nil;

  for j, diff in ipairs(diffs) do
    if ((diff.diffIdx) == i) then index = j; end
  end

  return diffs[index];
end

---@class NauticaListClass
local NauticaList = {
  -- NauticaList constructor
  ---@param this NauticaListClass
  ---@param window Window
  ---@param state DownloadScreen
  ---@param songs NauticaCache
  ---@return NauticaList
  new = function(this, window, state, songs)
    ---@class NauticaList : NauticaListClass
    ---@field state DownloadScreen
    ---@field window Window
    local t = {
      button = Button:new(512, 50),
      cache = { w = 0, h = 0 },
      cursor = Cursor:new({
        size = 20,
        stroke = 2,
        type = 'vertical',
      }),
      jacketSize = 0,
      labels = {
        blacklist = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-B]' },
            { color = 'white', text = 'BLACKLIST UPLOADER' },
          },
          20
        ),
        currSong = ScoreNumber:new({ digits = 4, size = 18 }),
        download = makeLabel(
          'med',
          {
            { color = 'norm', text = '[START]' },
            { color = 'white', text = 'DOWNLOAD SONG' },
          },
          20
        ),
        fetching = makeLabel('med', 'FETCHING SONGS', 20),
        nautica = makeLabel(
          'med',
          {
            { color = 'white', text = 'HTTPS://KSM.DEV/' },
            { color = 'norm', text = '@' },
            { color = 'white', text = 'NAUTICA' },
          },
          20
        ),
        of = makeLabel('med', 'OF'),
        preview = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-A]' },
            { color = 'white', text = 'PREVIEW SONG' },
          },
          20
        ),
        select = makeLabel(
          'med',
          {
            { color = 'norm', text = '[START]' },
            { color = 'white', text = 'SELECT LEVEL' },
          },
          20
        ),
        totalSongs = ScoreNumber:new({ digits = 4, size = 18 }),
      },
      loadingSpinner = Spinner:new(),
      list = List:new(),
      margin = 0,
      max = 3,
      maxWidth = 0,
      padding = { x = 24, y = 24 },
      scrollbar = Scrollbar:new(),
      songs = songs,
      spinner = Spinner:new({
        color = 'norm',
        size = 32,
        thickness = 5,
      }),
      state = state,
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = { card = 0, list = 0 },
    };

    for name, str in pairs(Labels) do t.labels[name] = makeLabel('med', str); end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this NauticaList
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.jacketSize = 248;

        this.w = this.window.w - (this.window.padding.x * 2);
        this.h.card = 528;
        this.h.list = this.window.h - (this.window.padding.y * 4);

        this.x = this.window.padding.x;
        this.y = this.window.padding.y * 3;

        this.button.w = this.w - (this.padding.x * 2);
        this.button.h = 44;

        this.maxWidth = this.w - this.jacketSize - (this.padding.x * 3);
      else
        this.jacketSize = 248;

        this.w = 1536;
        this.h.card = 296;
        this.h.list = this.window.h - (this.window.padding.y * 2);

        this.x = this.window.w - this.window.padding.x - this.w;
        this.y = this.window.padding.y;

        this.button.w = 512;
        this.button.h = 50;

        this.maxWidth = this.w
          - this.jacketSize
          - this.button.w
          - (this.padding.x * 4);
      end

      this.margin = (this.h.list - (this.h.card * this.max)) / (this.max - 1);

      this.cursor:setSizes({
        x = this.x,
        y = this.y,
        w = this.w,
        h = this.h.card,
        margin = this.margin,
      });

      this.list:setSizes({ max = this.max, shift = this.h.list + this.margin });

      this.scrollbar:setSizes({
        x = this.window.w - (this.window.w / 40) - 4,
        y = this.y,
        h = this.h.list,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw a diff button
  ---@param this NauticaList
  ---@param dt deltaTime
  ---@param x number
  ---@param y number
  ---@param alpha number
  ---@param diff CachedNauticaDiff
  ---@param isCurr boolean
  drawDiff = function(this, dt, x, y, alpha, diff, isCurr)
    local yText = y + (this.button.h * 0.5) - 15;

    this.button:render({
      x = x,
      y = y,
      accentAlpha = ((diff and 1) or 0.3) * (alpha / 255),
      alpha = (alpha / 255),
    });

    if (diff) then
      local maxWidth = this.button.w - diff.level.w - 60;

      diff.level:draw({
        x = x + 24,
        y = yText,
        alpha = alpha,
        color = 'white',
      });

      if (diff.effector.w > maxWidth) then
        if (isCurr) then
          diff.timer = diff.timer + dt;
        else
          diff.timer = 0;
        end

        diff.effector:drawScrolling({
          x = x + 24 + diff.level.w + 12,
          y = yText + 1,
          alpha = alpha,
          color = 'white',
          scale = this.window:getScale(),
          timer = diff.timer,
          width = maxWidth,
        });
      else
        diff.effector:draw({
          x = x + 24 + diff.level.w + 12,
          y = yText + 1,
          alpha = alpha,
          color = 'white',
        });
      end
    end
  end,

  -- Draw control hints and current songs
  ---@param this NauticaList
  drawFooter = function(this)
    local isPortrait = this.window.isPortrait;
    local x = this.window.padding.x;
    local y = this.y - (this.window.padding.y * 0.5) - 14;

    if (not isPortrait) then
      y = this.window.h - (this.window.padding.y * 0.5) - 14;
    end

    if (this.state.action == 'BROWSING') then
      this.labels.download:draw({ x = x, y = y });
    else
      this.labels.select:draw({ x = x, y = y });
    end

    if (isPortrait) then
      y = this.window.h - (this.window.padding.y * 0.5) - 14;
    else
      x = x + (this.window.w * 0.325);
    end

    this.labels.preview:draw({ x = x, y = y });

    if (isPortrait) then
      x = x + (this.window.w * 0.3625) - 4;
    else
      x = this.window.w - this.window.padding.x - this.padding.x - this.button.w;
    end

    this.labels.blacklist:draw({ x = x, y = y });

    if (this.state.songCount > 0) then
      gfx.Save();

      if (this.window.isPortrait) then
        gfx.Translate(
          this.window.w - (this.window.padding.x / 2) + 20,
          this.window.h - (this.window.padding.y / 2) - 10
        );
      else
        gfx.Translate(
          this.window.w - (this.window.padding.x / 2) + 16,
          this.window.h - (this.window.padding.y / 2) - 12
        );
      end

      this.labels.currSong:draw({
        x = -(this.labels.of.w + (this.labels.totalSongs.w * 2) + 24),
        y = 0,
        align = 'right',
        val = this.state.currSong,
      });

      this.labels.of:draw({
        x = -((this.labels.totalSongs.w * 1.25) + 12),
        y = 0,
        align = 'right',
      });

      this.labels.totalSongs:draw({
        x = -(this.labels.totalSongs.w),
        y = 0,
        align = 'right',
        val = this.state.songCount,
      });

      gfx.Restore();
    end
  end,

  -- Draw the song list
  ---@param this NauticaList
  ---@param dt deltaTime
  drawList = function(this, dt)
    local currSong = this.state.currSong;
    local y = 0;

    gfx.Save();

    gfx.Translate(this.x, this.y + this.list.offset);

    for i, song in ipairs(this.state.songs) do
      local cached;

      if (this.list:onPage(i)) then cached = this.songs:get(song); end

      y = y + this:drawSong(dt, y, cached, i == currSong);
    end

    gfx.Restore();
  end,

  -- Draw a single song
  ---@param this NauticaList
  ---@param dt deltaTime
  ---@param y number
  ---@param song CachedNauticaSong
  ---@param isCurr boolean
  drawSong = function(this, dt, y, song, isCurr)
    local alpha = 255;
    local isPortrait = this.window.isPortrait;
    local x = this.padding.x;
    local yTemp = y;

    y = y + this.padding.y;

    if (song) then
      drawRect({
        x = 0,
        y = yTemp,
        w = this.w,
        h = this.h.card,
        alpha = 200,
        color = 'dark',
      });

      drawRect({
        x = x,
        y = y,
        w = this.jacketSize,
        h = this.jacketSize,
        image = song.jacket,
        stroke = { color = 'norm', size = 1.5 },
      });

      if (song.status) then
        this:drawStatus(dt, x, y, song.status);

        if (song.status == 'DOWNLOADED') then alpha = 100; end
      end

      x = x + this.jacketSize + this.padding.x;
      y = y - 6;

      for _, name in ipairs(Order) do
        this.labels[name]:draw({
          alpha = alpha,
          x = x,
          y = y,
        });

        if (song[name].w > this.maxWidth) then
          if (isCurr) then
            song.timer = song.timer + dt;
          else
            song.timer = 0;
          end

          song[name]:drawScrolling({
            x = x,
            y = y + (this.labels[name].h * 1.35),
            alpha = alpha,
            color = 'white',
            scale = this.window:getScale(),
            timer = song.timer,
            width = this.maxWidth,
          });
        else
          song[name]:draw({
            x = x,
            y = y + (this.labels[name].h * 1.35),
            alpha = alpha,
            color = 'white',
          });
        end

        y = y + (this.labels[name].h * 1.35) + (song[name].h * 1.5) + 1;
      end

      x = this.w - this.padding.x - this.button.w;

      if (isPortrait) then
        y = yTemp + this.padding.y + this.jacketSize + 24;
      else
        y = yTemp + this.padding.y;
      end

      for i = 1, 4 do
        local diff = getDiff(song.diffs, i);

        this:drawDiff(dt, x, y, alpha, diff, isCurr);

        y = y + this.button.h + ((isPortrait and 10) or 16);
      end
    end

    return this.h.card + this.margin;
  end,

  -- Draw the current song status
  ---@param this NauticaList
  ---@param dt deltaTime
  ---@param x number
  ---@param y number
  ---@param status string|nil # 'DOWNLOADING', 'DOWNLOADED', 'PREVIEWING'
  drawStatus = function(this, dt, x, y, status)
    local size = this.jacketSize;
    local xCenter = x + (size * 0.5);
    local yCenter = y + (size * 0.5);

    drawRect({
      x = x,
      y = y,
      w = size,
      h = size,
      alpha = 200,
      color = 'black',
      stroke = { color = 'med', size = 1.5 },
    });

    if (status == 'DOWNLOADING') then
      this.spinner:render(dt, xCenter, yCenter);
    elseif (status == 'DOWNLOADED') then
      gfx.BeginPath();
      setFill('norm');
      gfx.MoveTo(xCenter - 12, yCenter + 27);
      gfx.LineTo(xCenter - 32, yCenter + 6);
      gfx.LineTo(xCenter - 26, yCenter);
      gfx.LineTo(xCenter - 11, yCenter + 14);
      gfx.LineTo(xCenter + 26, yCenter - 24);
      gfx.LineTo(xCenter + 32, yCenter - 18);
      gfx.ClosePath();
      gfx.Fill();
    elseif (status == 'PREVIEWING') then
      gfx.BeginPath();
      setFill('norm');
      gfx.MoveTo(xCenter + 32, yCenter);
      gfx.LineTo(xCenter - 32, yCenter - 32);
      gfx.LineTo(xCenter - 32, yCenter + 32);
      gfx.ClosePath();
      gfx.Fill();
    end 
  end,

  -- Handle user input
  ---@param this NauticaList
  ---@param dt deltaTime
  handleChange = function(this, dt)
    this.list:handleChange(dt, {
      isPortrait = this.window.isPortrait,
      watch = this.state.currSong
    });
  end,

  -- Renders the current component
  ---@param this NauticaList
  ---@param dt deltaTime
  render = function(this, dt)
    this:setSizes();

    local x = this.x + this.w;
    local y = this.window.padding.y * 0.25;

    if (this.window.isPortrait) then
      y = this.y - (this.window.padding.y * 0.5) - 14;
    end

    this:handleChange(dt);

    gfx.Save();

    if (this.state.loading) then
      this.labels.fetching:draw({
        x = x,
        y = y,
        align = 'right',
        color = 'white',
      });

      this.loadingSpinner:render(dt, x - this.labels.fetching.w - 21, y + 13);
    else
      this.labels.nautica:draw({
        x = x,
        y = y,
        align = 'right',
      });
    end

    if (this.state.songCount > 0) then
      this:drawList(dt);

      this.cursor:render(dt, { curr = this.state.currSong, total = this.max });

      if (this.state.songCount > this.max) then
        this.scrollbar:render(dt, {
          curr = this.state.currSong,
          total = this.state.songCount,
        });
      end

      this:drawFooter();
    end

    gfx.Restore();
  end,
};

return NauticaList;