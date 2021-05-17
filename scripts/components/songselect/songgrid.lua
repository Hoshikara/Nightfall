local Cursor = require('components/common/cursor');
local Grid = require('components/common/grid');
local List = require('components/common/list');
local ScoreNumber = require('components/common/scorenumber');
local Scrollbar = require('components/common/scrollbar');

local floor = math.floor;
local min = math.min;

-- Get the current column of the item
---@param i integer
---@return integer
local getCol = function(i) return floor((i - 1) % 3); end

---@class SongGridClass
local SongGrid = {
  -- SongGrid constructor
  ---@param this SongGridClass
  ---@param window Window
  ---@param state SongWheel
  ---@param songs SongCache
  ---@return SongGrid
  new = function(this, window, state, songs)
    ---@class SongGrid : SongGridClass
    ---@field songs SongCache
    ---@field state SongWheel
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      cursor = Cursor:new({
        size = 18,
        stroke = 1.5,
        type = 'grid',
      }),
      grid = Grid:new(window, true),
      labels = {
        currSong = ScoreNumber:new({ digits = 4, size = 18 }),
        grade = makeLabel('med', 'GRADE'),
        noneFound = makeLabel('norm', 'NO SONGS FOUND', 48),
        of = makeLabel('med', 'OF'),
        totalSongs = ScoreNumber:new({ digits = 4, size = 18 }),
      },
      list = List:new(),
      scrollbar = Scrollbar:new(),
      songs = songs,
      state = state,
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this SongGrid
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.grid:setSizes();

      this.cursor:setSizes({
        x = this.grid.x,
        y = this.grid.y,
        w = this.grid.jacketSize,
        h = this.grid.jacketSize,
        margin = this.grid.margin,
      });

      this.list:setSizes({
        max = this.state.max,
        shift = this.grid.h + this.grid.margin,
      });

      this.scrollbar:setSizes({
        x = this.window.w - (this.window.w / 40) - 4,
        y = this.grid.y,
        h = this.grid.h,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the entire song grid
  ---@param this SongGrid
  drawGrid = function(this)
    local currSong = this.state.currSong;
    local y = 0;

    gfx.Save();

    gfx.Translate(this.grid.x, this.grid.y + this.list.offset);

    for i, song in ipairs(songwheel.songs) do
      local cached;

      if (this.list:onPage(i)) then
        cached = this.songs:get(song);
        
        if (cached) then
          cached = cached.diffs[this.state.currDiff] or cached.diffs[1];
        end
      end

      y = y + this:drawJacket(y, getCol(i), cached, i == currSong);
    end

    gfx.Restore();
  end,

  -- Draw a single jacket in the grid
  ---@param this SongGrid
  ---@param y number
  ---@param col number
  ---@param diff table
  ---@param isCurr boolean
  drawJacket = function(this, y, col, diff, isCurr)
    local alpha = (isCurr and 1) or 0.5;
    local fullAlpha = 255 * min(alpha * 1.5, 1);
    local size = this.grid.jacketSize;
    local x = (size + this.grid.margin) * col;

    if (diff) then
      drawRect({
        x = x,
        y = y,
        w = size,
        h = size,
        color = 'black',
      });

      drawRect({
        x = x,
        y = y,
        w = size,
        h = size,
        alpha = alpha,
        image = diff.jacket,
        stroke = {
          color = (isCurr and 'norm') or 'dark',
          size = 2,
        },
      });

      if (diff.best) then
        local labels = diff.best.labels.small;

        if (this.window.isPortrait) then
          labels = diff.best.labels.large;

          drawRect({
            x = x + 12,
            y = y + 12,
            w = 141,
            h = 42,
            alpha = fullAlpha,
            color = 'dark',
          });
  
          labels.best:draw({
            x = x + 20,
            y = y + 15,
            alpha = 255 * alpha,
            color = 'white',
          });
  
          labels[diff.best.place]:draw({
            x = x + 20 + labels.best.w + 12,
            y = y + 15,
            alpha = fullAlpha,
          });
        else
          drawRect({
            x = x + 8,
            y = y + 8,
            w = 98,
            h = 32,
            alpha = fullAlpha,
            color = 'dark',
          });
  
          labels.best:draw({
            x = x + 16,
            y = y + 12,
            alpha = 255 * alpha,
            color = 'white',
          });
  
          labels[diff.best.place]:draw({
            x = x + 16 + labels.best.w + 8,
            y = y + 12,
            alpha = fullAlpha,
          });
        end

      end

      if (diff.grade) then
        drawRect({
          x = x + size - 8 - this.grid.grade.w,
          y = y + size - 8 - this.grid.grade.h,
          w = this.grid.grade.w,
          h = this.grid.grade.h,
          alpha = fullAlpha,
          color = 'dark',
        });

        this.labels.grade:draw({
          x = x + size - this.grid.grade.w,
          y = y + size - 4 - this.grid.grade.h,
          alpha = fullAlpha,
        });

        diff.grade:draw({
          x = x + size - this.grid.grade.w,
          y = y
            + size
            - 4
            - this.grid.grade.h
            + this.labels.grade.h,
          alpha = 255 * alpha,
          color = 'white',
        });
      end
    end

    if (col == 2) then return size + this.grid.margin; end
      
    return 0;
  end,

  -- Draw the current and total song amounts
  ---@param this SongGrid
  drawAmounts = function(this)
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
  end,

  -- Renders the current component
  ---@param this SongGrid
  ---@param dt deltaTime
  render = function(this, dt)
    local songCount = this.state.songCount;

    this:setSizes();

    gfx.Save();

    if (songCount > 0) then
      this.list:handleChange(dt, {
        isPortrait = this.window.isPortrait,
        watch = this.state.currSong
      });

      this:drawGrid();

      this.cursor:render(dt, {
        curr = this.state.currSong,
        total = songCount,
      });

      if (songCount > this.state.max) then
        this.scrollbar:render(dt, {
          curr = this.state.currSong,
          total = songCount,
        });
      end

      this:drawAmounts();
    else
      this.labels.noneFound:draw({
        x = this.grid.x + (this.grid.w / 2),
        y = this.grid.y + (this.grid.h / 2),
        align = 'middle',
        color = 'white',
      });
    end

    gfx.Restore();
  end,
};

return SongGrid;