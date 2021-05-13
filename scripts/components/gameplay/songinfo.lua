local Difficulties = require('constants/difficulties');

local Cursor = require('components/common/cursor');

local floor = math.floor;

local hispeedPos = getSetting('hispeedPos', 'BOTTOM');
local ignoreChange = getSetting('ignoreSpeedChange', false);

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

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
        change = makeLabel('num', '0', 24),
        changeStr = '',
        isLower = false,
        label = makeLabel('norm', 'HI-SPEED', 24),
        multi = makeLabel('num', '0', 24),
        val = makeLabel('num', '0', 24),
        valMiddle = makeLabel('num', '0', 30),
        y = 0,
      },
      jacket = nil,
      jacketSize = 135,
      labels = {
        artist = makeLabel('jp', gameplay.artist:upper(), 24),
        level = makeLabel('num', ('%02d'):format(gameplay.level), 18),
        title = makeLabel('jp', gameplay.title:upper(), 30),
      },
      maxWidth = 0,
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

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this SongInfo
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.x = this.window.w / 32;
      this.y = this.window.h / 20;

      if (hispeedPos == 'BOTTOM') then
        this.hispeed.y = this.window.h - (this.window.h / 3.35) - this.y;
      elseif (hispeedPos == 'MIDDLE') then
        this.hispeed.y = this.window.h - (this.window.h / 1.85) - this.y;
      elseif (hispeedPos == 'UPPER') then
        this.hispeed.y = this.window.h - (this.window.h / 1.35) - this.y;
      elseif (hispeedPos == 'UPPER+') then
        this.hispeed.y = this.window.h - (this.window.h / 1.15) - this.y;
      end
      
      this.maxWidth = (this.window.w / 4) - this.jacketSize;

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

        local total = floor(((1 / gameplay.progress) * this.timers.curr) + 0.5);

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
    if ((not this.jacket) or (this.jacket == jacketFallback)) then
      this.jacket = gfx.LoadImageJob(
        gameplay.jacketPath,
        jacketFallback,
        this.jacketSize,
        this.jacketSize
      );
    end

    drawRect({
      w = this.jacketSize,
      h = this.jacketSize,
      image = this.jacket,
      stroke = {
        color = 'norm',
        size = 1,
      },
    });

    this.labels.diff:draw({ x = -2, y = this.jacketSize + 6 });

    this.labels.level:draw({
      x = this.jacketSize + 2,
      y = this.jacketSize + 6,
      align = 'right',
      color = 'white',
    });

    this.cursor:draw({
      x = 0,
      y = 0,
      w = this.jacketSize,
      h = this.jacketSize + (this.labels.diff.h * 1.5),
      alpha = 255,
    });
  end,

  -- Draw the title and artist names
  ---@param this SongInfo
  ---@param dt deltaTime
  ---@param alpha number
  ---@return number x, number y
  drawNames = function(this, dt, alpha)
    local x = this.jacketSize + 28;
    local y = -8;

    if (this.labels.title.w > this.maxWidth) then
      this.timers.title = this.timers.title + dt;
      
      this.labels.title:drawScrolling({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
        scale = this.window:getScale(),
        timer = this.timers.title,
        width = this.maxWidth,
      });
    else
      this.labels.title:draw({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
      });
    end

    y = y + (this.labels.title.h * 1.25);

    if (this.labels.artist.w > this.maxWidth) then
      this.timers.artist = this.timers.artist + dt;
      
      this.labels.artist:drawScrolling({
        x = x + 1,
        y = y,
        alpha = alpha,
        color = 'norm',
        scale = this.window:getScale(),
        timer = this.timers.artist,
        width = this.maxWidth,
      });
    else
      this.labels.artist:draw({
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
    y = y + this.labels.artist.h * 1.75;

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
          floor((this.timers.curr % 60) + 0.5)
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

    return x, y;
  end,

  -- Draw BPM information
  ---@param this SongInfo
  ---@param x number
  ---@param y number
  ---@param alpha number
  drawBPM = function(this, x, y, alpha)
    local xOffset = -64;
    local yOffset = this.bpm.label.h * 1.375;
  
    y = y + (this.labels.artist.h * 1.425);

    this.bpm.val:draw({
      x = x,
      y = y,
      align = 'right',
      alpha = alpha,
      color = 'white',
      text = ('%.0f'):format(gameplay.bpm),
      update = true,
    });

    this.bpm.label:draw({
      x = x + xOffset,
      y = y,
      align = 'right',
      alpha = alpha,
    });

    if (pressed('STA') and this.state.showAdjustments) then
      -- if (pressed('BTB') or pressed('BTC')) then
      if (false) then -- does anyone even use this?
        local which = (pressed('BTB') and 'cutoff') or 'fade';
        local hiddenVal = gameplay.hiddenCutoff * 100;
        local suddenVal = gameplay.suddenCutoff * 100;

        if (which == 'fade') then
          hiddenVal = gameplay.hiddenFade * 100;
          suddenVal = gameplay.suddenFade * 100;
        end

        this.hidden[which].val:draw({
          x = x,
          y = y + yOffset,
          align = 'right',
          alpha = alpha,
          text = ('%.0f%%'):format(hiddenVal),
          update = true,
        });

        this.sudden[which].val:draw({
          x = x,
          y = y + (yOffset * 2),
          align = 'right',
          alpha = alpha,
          text = ('%.0f%%'):format(suddenVal),
          update = true,
        });

        this.hidden[which].label:draw({
          x = x + xOffset,
          y = y + yOffset,
          align = 'right',
          alpha = alpha,
          color = 'white',
        });

        this.sudden[which].label:draw({
          x = x + xOffset,
          y = y + (yOffset * 2),
          align = 'right',
          alpha = alpha,
          color = 'white',
        });
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

        this.hispeed.multi:draw({
          x = x + xOffset,
          y = y + yOffset,
          align = 'right',
          alpha = alpha,
          color = 'white',
          text = ('%.0f  x  %.1f  ='):format(
            gameplay.bpm,
            gameplay.hispeed
          ),
          update = true,
        });

        if (hispeedPos ~= 'OFF') then
          local color = 'white';
          local str = ('%.0f  (%.1f)'):format(
            gameplay.bpm * gameplay.hispeed,
            gameplay.hispeed
          );

          if (this.hispeed.changeStr ~= '') then
            if (not ignoreChange) then
              if (this.hispeed.isLower) then
                color = 'light';
              else
                color = 'red';
              end
              
              str = this.hispeed.changeStr;
            end
          end
        
          this.hispeed.valMiddle:draw({
            x = (this.window.w / 2) - (this.window.w / 32),
            y = this.hispeed.y,
            alpha = alpha * (((color == 'white') and 0.65) or 0.9),
            align = 'middle',
            color = color,
            text = str,
            update = true,
          });
        end
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
      color = (this.hispeed.isLower and 'light') or 'red',
      text = bpmChange,
      update = true,
    });

    this.hispeed.change:draw({
      x = x + 16,
      y = y + yOffset,
      align = 'left',
      alpha = alpha,
      color = (this.hispeed.isLower and 'light') or 'red',
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

    this:drawBPM(x - 1, y, alpha);

    gfx.Restore();
  end,
};

return SongInfo;