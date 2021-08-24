local Difficulties = require('constants/difficulties');

local Cursor = require('components/common/cursor');

local Green = { 120, 240, 80 };

local floor = math.floor;

local hispeedX = getSetting('hispeedX', 0.5);
local hispeedY = getSetting('hispeedY', 0.5);
local showHispeed = getSetting('showHispeed', true);

local ignoreChange = getSetting('ignoreSpeedChange', false);

local jacketFallback = gfx.CreateSkinImage('loading.png', 0);

---@class SongInfoClass
local SongInfo = {
  -- SongInfo constructor
  ---@param this SongInfoClass
  ---@param window Window
  ---@param state Gameplay
  ---@return SongInfo
  new = function(this, window, state)
    ---@class SongInfo : SongInfoClass
    ---@field state Gameplay
    ---@field window Window
  	local t = {
    	bpm = {
        change = makeLabel('num', '0', 24),
        idx = 1,
        label = makeLabel('norm', 'BPM', 24),
        val = makeLabel('num', '0', 24),
      },
      cache = { w = 0, h = 0 },
      cursor = Cursor:new({ size = 12, stroke = 1.5 }, true),
      hidden = {
        cutoff = {
          label = makeLabel('norm', 'HIDDEN CUTOFF', 24),
          val = makeLabel('num', '0', 24),
        },
        fade = {
          label = makeLabel('norm', 'HIDDEN FADE', 24),
          val = makeLabel('num', '0', 24),
        },
      },
      hispeed = {
        adjust = {
          bpm = makeLabel('num', '0', 24),
          equals = makeLabel('num', '=', 24),
          multi = makeLabel('num', '0', 24),
          x = makeLabel('num', 'x', 24),
        },
        change = makeLabel('num', '0', 24),
        changeStr = '',
        isLower = false,
        label = makeLabel('norm', 'HI-SPEED', 24),
        val = makeLabel('num', '0', 24),
        valMiddle = makeLabel('num', '0', 30),
        y = 0,
      },
      jacket = nil,
      jacketSize = 135,
      labels = {
        artist = makeLabel('jp', gameplay.artist:upper(), 24),
        artistLg = makeLabel('jp', gameplay.artist:upper(), 30),
        level = makeLabel('num', ('%02d'):format(gameplay.level), 18),
        levelLg = makeLabel('num', ('%02d'):format(gameplay.level), 24),
        title = makeLabel('jp', gameplay.title:upper(), 30),
        titleLg = makeLabel('jp', gameplay.title:upper(), 36),
      },
      maxWidth = 0,
      playbackSpeed = makeLabel('num', '0', 24),
      state = state,
      sudden = {
        cutoff = {
          label = makeLabel('norm', 'SUDDEN CUTOFF', 24),
          val = makeLabel('num', '0', 24),
        },
        fade = {
          label = makeLabel('norm', 'SUDDEN FADE', 24),
          val = makeLabel('num', '0', 24),
        },
      },
      time = {
        curr = makeLabel('num', '00:00', 24),
        next = 0,
        total = makeLabel('num', '/ 00:00', 24),
        totalVal = '/ 00:00',
      },
      timers = {
        artist = 0,
        curr = 0,
        title = 0,
        total = 0,
      },
      window = window,
      x = 0,
      y = 0,
    };

    local diffIndex = getDiffIndex(gameplay.jacketPath, gameplay.difficulty);

    t.labels.diff = makeLabel('med', Difficulties[diffIndex], 18);
    t.labels.diffLg = makeLabel('med', Difficulties[diffIndex], 24);

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this SongInfo
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.x = this.window.w / 32;

      if (this.window.isPortrait) then
        this.jacketSize = 208;
        this.maxWidth = this.window.w - (this.window.w / 16) - 28 - this.jacketSize;

        this.y = this.window.h / 14;

        this.hispeed.y = ((this.window.h * 0.625) * hispeedY)
          + (this.window.h * 0.125)
          - this.y;
      else
        this.jacketSize = 135;
        this.maxWidth = (this.window.w / 4) - this.jacketSize;

        this.y = this.window.h / 20;

        this.hispeed.y = (this.window.h * hispeedY) - this.y;
      end

      this.hispeed.x = (this.window.w * hispeedX) - this.x;

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Update the current and total chart length
  ---@param this SongInfo
  ---@param dt deltaTime
  updateTime = function(this, dt)
    if (gameplay.practice_setup == nil) then
      if ((gameplay.progress > 0) and (gameplay.progress < 1)) then
        this.timers.curr = this.timers.curr + dt;

        local total = floor(((1 / gameplay.progress) * this.timers.curr));

        if (this.timers.total ~= total) then
          this.time.totalVal = ('/ %02d:%02d'):format(
            floor(total / 60),
            floor(total % 60)
          );

          this.timers.total = total;
        end
      elseif (gameplay.progress == 0) then
        this.timers.curr = 0;
      end
    end
  end,

  -- Draw the jacket and difficulty
  ---@param this SongInfo
  drawJacket = function(this)
    local isPortrait = this.window.isPortrait;
    local size = this.jacketSize;

    if ((not this.jacket) or (this.jacket == jacketFallback)) then
      this.jacket = gfx.LoadImageJob(
        gameplay.jacketPath,
        jacketFallback,
        size,
        size
      );
    end

    drawRect({
      w = size,
      h = size,
      image = this.jacket,
      stroke = {
        color = 'norm',
        size = 1,
      },
    });

    if (isPortrait) then
      this.labels.diffLg:draw({ x = -2, y = size + 6 });

      this.labels.levelLg:draw({
        x = size + 2,
        y = size + 6,
        align = 'right',
        color = 'white',
      });
    else
      this.labels.diff:draw({ x = -2, y = size + 6 });

      this.labels.level:draw({
        x = size + 2,
        y = size + 6,
        align = 'right',
        color = 'white',
      });
    end

    this.cursor:draw({
      x = 0,
      y = 0,
      w = size,
      h = size + (this.labels.diff.h * 1.5),
      alpha = 255,
      size = (this.window.isPortrait and 16) or 12,
    });
  end,

  -- Draw the title and artist names
  ---@param this SongInfo
  ---@param dt deltaTime
  ---@param alpha number
  ---@return number x, number y
  drawNames = function(this, dt, alpha)
    local artist = this.labels.artist;
    local title = this.labels.title;
    local x = this.jacketSize + 28;
    local y = -8;

    if (this.window.isPortrait) then
      artist = this.labels.artistLg;
      title = this.labels.titleLg;
    end

    if (title.w > this.maxWidth) then
      this.timers.title = this.timers.title + dt;
      
      title:drawScrolling({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
        scale = this.window:getScale(),
        timer = this.timers.title,
        width = this.maxWidth,
      });
    else
      title:draw({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
      });
    end

    y = y + (title.h * 1.25);

    if (artist.w > this.maxWidth) then
      this.timers.artist = this.timers.artist + dt;
      
      artist:drawScrolling({
        x = x + 1,
        y = y,
        alpha = alpha,
        color = 'norm',
        scale = this.window:getScale(),
        timer = this.timers.artist,
        width = this.maxWidth,
      });
    else
      artist:draw({
        x = x + 1,
        y = y,
        alpha = alpha,
        color = 'norm',
      });
    end

    return x, y;
  end,

  -- Draw the chart progress bar
  ---@param this SongInfo
  ---@param x number
  ---@param y number
  ---@param alpha number
  ---@return number x, number y
  drawProgress = function(this, x, y, alpha)
    x = x + 1;

    if (this.window.isPortrait) then
      y = y + (this.labels.artistLg.h * 1.75);
    else
      y = y + (this.labels.artist.h * 1.75);
    end

    drawRect({
      x = x,
      y = y - 2,
      w = this.maxWidth,
      h = 26,
      alpha = alpha / 5,
      color = 'white',
    });

    drawRect({
      x = x,
      y = y - 2,
      w = this.maxWidth * gameplay.progress,
      h = 26,
      alpha = alpha,
      color = 'norm',
    });

    x = x + this.maxWidth + 2;
    
    if (gameplay.practice_setup == nil) then
      this.time.curr:draw({
        x = x - 5 - this.time.total.w - 8,
        y = y - 4,
        align = 'right',
        alpha = alpha,
        color = 'white',
        text = ('%02d:%02d'):format(
          floor(this.timers.curr / 60),
          floor((this.timers.curr % 60))
        ),
        update = true,
      });

      this.time.total:draw({
        x = x - 5,
        y = y - 4,
        align = 'right',
        alpha = alpha,
        color = 'white',
        text = this.time.totalVal,
        update = true,
      });
    end

    if (this.window.isPortrait) then
      x = x - this.maxWidth - (this.window.w / 20) + 30;
      y = y + this.jacketSize - 12;
    end

    return x, y;
  end,

  -- Draw BPM information
  ---@param this SongInfo
  ---@param x number
  ---@param y number
  ---@param alpha number
  drawBPM = function(this, x, y, alpha)
    local bpm = gameplay.bpm;
    local playbackSpeed = gameplay.playbackSpeed or 1;
    local playbackText = '';
    local xOffset = -72;
    local yOffset = this.bpm.label.h * 1.375;
  
    y = y + (this.labels.artist.h * 1.425);

    if (playbackSpeed < 1) then
      bpm = floor(bpm * playbackSpeed);
      playbackText = ('- %d%%'):format(floor((playbackSpeed * 100) + 0.5));
    end

    this.playbackSpeed:draw({
      x = x + 8,
      y = y,
      align = 'left',
      alpha = alpha,
      color = 'white',
      text = playbackText,
      update = true,
    });

    this.bpm.val:draw({
      x = x,
      y = y,
      align = 'right',
      alpha = alpha,
      color = 'white',
      text = ('%.0f'):format(bpm),
      update = true,
    });

    this.bpm.label:draw({
      x = x + xOffset,
      y = y,
      align = 'right',
      alpha = alpha,
    });

    if (pressed('STA') and this.state.showAdjustments) then
      local adjust = this.hispeed.adjust;
      local hispeedColor = Green;
      local multiColor = 'white';
      local xTemp = x + xOffset;
      local yTemp = y + yOffset;

      if (gameplay.hispeedAdjust and (gameplay.hispeedAdjust == 1)) then
        hispeedColor = 'white';
        multiColor = Green;
      end

      this.hispeed.val:draw({
        x = x,
        y = y + yOffset,
        align = 'right',
        alpha = alpha,
        color = hispeedColor,
        text = ('%.0f'):format(gameplay.bpm * gameplay.hispeed),
        update = true,
      });

      adjust.equals:draw({
        x = xTemp,
        y = yTemp,
        align = 'right',
        alpha = alpha,
        color = 'white',
      });

      xTemp = xTemp - adjust.equals.w - 12;

      adjust.multi:draw({
        x = xTemp,
        y = yTemp,
        align = 'right',
        alpha = alpha,
        color = multiColor,
        text = ('%.1f'):format(gameplay.hispeed),
        update = true,
      });

      xTemp = xTemp - adjust.multi.w - 12;

      adjust.x:draw({
        x = xTemp,
        y = yTemp,
        align = 'right',
        alpha = alpha,
        color = 'white',
      });

      xTemp = xTemp - adjust.x.w - 12;

      adjust.bpm:draw({
        x = xTemp,
        y = yTemp,
        align = 'right',
        alpha = alpha,
        color = 'white',
        text = ('%.0f'):format(gameplay.bpm),
        update = true,
      });

      if (showHispeed) then
        local color = 'white';
        local str = ('%.0f  (%.1f)'):format(
          gameplay.bpm * gameplay.hispeed,
          gameplay.hispeed
        );

        if (this.hispeed.changeStr ~= '') then
          if (not ignoreChange) then
            if (this.hispeed.isLower) then
              color = 'pos';
            else
              color = 'neg';
            end
            
            str = this.hispeed.changeStr;
          end
        end
      
        this.hispeed.valMiddle:draw({
          x = this.hispeed.x,
          y = this.hispeed.y,
          alpha = alpha * (((color == 'white') and 0.65) or 0.9),
          align = 'middle',
          color = color,
          text = str,
          update = true,
        });
      end
    else
      this.hispeed.val:draw({
        x = x,
        y = y + yOffset,
        align = 'right',
        alpha = alpha,
        color = 'white',
        text = ('%.0f'):format(gameplay.bpm * gameplay.hispeed),
        update = true,
      });

      this.hispeed.label:draw({
        x = x + xOffset,
        y = y + yOffset,
        align = 'right',
        alpha = alpha,
      });
    end

    if (this.state.bpms) then this:drawChange(x, y, yOffset); end
  end,

  -- Draw BPM and Hi-Speed change indicators
  ---@param this SongInfo
  ---@param x number
  ---@param y number
  ---@param yOffset number
  drawChange = function(this, x, y, yOffset)
    local curr = this.state.bpms[this.bpm.idx];

    if (not curr) then return; end

    if (gameplay.progress == 0) then
      this.bpm.idx = 1;
      this.time.next = 0;
    end

    local bpmChange = '';
    local hiSpeedChange = '';
    local next = this.state.bpms[this.bpm.idx + 1];

    this.hispeed.changeStr = '';
    this.hispeed.isLower = false;
    
    if (next) then
      this.time.next = math.min(curr.time + 2.5, next.time);
    else
      this.time.next = curr.time + 2.5;
    end

    if (this.timers.curr >= curr.time) then
      this.hispeed.isLower = curr.bpm < gameplay.bpm;
      bpmChange = ('>>  %.0f'):format(curr.bpm);
      hiSpeedChange = ('>>  %.0f'):format(curr.bpm * gameplay.hispeed);
      this.hispeed.changeStr = ('>>  %.0f  (%.1f)'):format(
        curr.bpm * gameplay.hispeed,
        gameplay.hispeed
      );

      if (this.timers.curr >= this.time.next) then
        this.bpm.idx = this.bpm.idx + 1;
      end
    end

    this.bpm.change:draw({
      x = x + 16,
      y = y,
      align = 'left',
      alpha = alpha,
      color = (this.hispeed.isLower and 'pos') or 'neg',
      text = bpmChange,
      update = true,
    });

    this.hispeed.change:draw({
      x = x + 16,
      y = y + yOffset,
      align = 'left',
      alpha = alpha,
      color = (this.hispeed.isLower and 'pos') or 'neg',
      text = hiSpeedChange,
      update = true,
    });
  end,

  -- Renders the current component
  ---@param this SongInfo
  ---@param dt deltaTime
  render = function(this, dt)
    this:setSizes();

    this:updateTime(dt);

    gfx.Save();

    gfx.Translate(
      this.x - ((this.window.w / 4) * this.state.intro.offset),
      this.y
    );

    this:drawJacket();

    local alpha = this.state.intro.alpha;
    local x, y = this:drawNames(dt, alpha);

    x, y = this:drawProgress(x, y, alpha);

    if (not gameplay.practice_setup) then this:drawBPM(x - 1, y, alpha); end

    gfx.Restore();
  end,
};

return SongInfo;