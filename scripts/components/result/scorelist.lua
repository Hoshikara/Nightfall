local Constants = require('constants/result');

local Cursor = require('components/common/cursor');
local List = require('components/common/list');
local ScoreNumber = require('components/common/scorenumber');
local Scrollbar = require('components/common/scrollbar');

-- Drawing orders
local Orders = {
  sp = {
    {
      'grade',
      'clear',
      'hitWindows',
      'timestamp',
    },
    {
      'gauge',
      'critical',
      'near',
      'error',
    },
  },
  mp = {
    {
      'gauge',
      'critical',
      'near',
      'error',
    },
  },
};

-- Get equal amount of space between labels
---@param order table
---@param labels table
---@param max number
---@return number
local getSpacing = function(order, labels, max)
  local w = 0;

  for _, name in ipairs(order) do w = w + labels[name].w; end

  return (max - w) / (#order - 1);
end

---@class ScoreListClass
local ScoreList = {
  -- ScoreList constructor
  ---@param this ScoreListClass
  ---@param window Window
  ---@param state Result
  ---@return ScoreList
  new = function(this, window, state)
    ---@class ScoreList : ScoreListClass
    local t = {
      cache = { w = 0, h = 0 },
      currScore = 1,
      cursor = Cursor:new({
        size = 20,
        stroke = 2,
        type = 'vertical',
      }),
      labels = {
        currScore = ScoreNumber:new({ digits = 4, size = 18 }),
        of = makeLabel('med', 'OF'),
        select = makeLabel(
          'med',
          {
            { color = 'norm', text = '[FX-L]  /  [FX-R]' },
            { color = 'white', text = 'SELECT SCORE' },
          },
          20
        ),
        totalScores = ScoreNumber:new({ digits = 4, size = 18 }),
      },
      list = List:new(),
      margin = 0,
      max = 4,
      maxWidth = 0,
      padding = { x = 0, y = 0 },
      pressedFXL = false,
      pressedFXR = false,
      scrollbar = Scrollbar:new(),
      state = state,
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = {
        closed = 0,
        list = 0,
        open = 0,
      },
    };

    for k, str in pairs(Constants.stats) do
      t.labels[k] = makeLabel('med', str);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ScoreList
  ---@param w number
  ---@param h number
  setSizes = function(this, w, h)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.x = this.window.padding.x;
        this.y = (this.window.padding.y * 2) + h;

        this.w = this.window.w - (this.window.padding.x * 2);
        this.h.list = this.window.h - h - (this.window.padding.y * 3);
        this.h.closed = this.window.h // 12;
        this.h.open = this.h.closed * 2.125;

        this.max = 3;
      else
        this.x = (this.window.w / 20) + w + (this.window.w / 40);
        this.y = this.window.h / 20;

        this.w = this.window.w - (this.window.w / 10) - w - (this.window.w / 40);
        this.h.list = this.window.h - (this.window.h / 10);
        this.h.closed = this.window.h // 7;
        this.h.open = this.h.closed * 2.125;

        this.max = 4;
      end

      local remaining = this.h.list
        - ((this.h.closed) * (this.max - 1))
        - this.h.open;
      
      this.margin = remaining / (this.max - 1);

      this.padding.x = this.w / 20;
      this.padding.y = this.h.closed / 7.5;

      this.maxWidth = this.w - (this.padding.x * 2);

      this.cursor:setSizes({
        x = this.x,
        y = this.y,
        w = this.w,
        h = this.h.open,
        margin = this.margin,
      });

      this.list:setSizes({
        max = this.max,
        shift = (this.h.list - (this.h.open - this.h.closed)) + this.margin,
      });

      this.scrollbar:setSizes({
        x = this.window.w - (this.window.w / 40) - 4,
        y = this.y,
        h = this.h.list,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the score list
  ---@param this ScoreList
  drawList = function(this)
    local y = 0;

    gfx.Save();

    gfx.Translate(this.x, this.y + this.list.offset);

    for i, score in ipairs(this.state.scores) do
      y = y + this:drawScore(y, score, i == this.currScore, this.list:onPage(i));
    end

    gfx.Restore();
  end,

  -- Draw a single score
  ---@param this ScoreList
  ---@param y number
  ---@param score ResultScore
  ---@param isCurr boolean
  ---@param isVis boolean
  drawScore = function(this, y, score, isCurr, isVis)
    local x = this.padding.x;
    local yTemp = y;
    local h = (isCurr and this.h.open) or this.h.closed;

    y = y + this.padding.y;

    if (isVis) then
      drawRect({
        x = 0,
        y = yTemp,
        w = this.w,
        h = h,
        alpha = 180,
        color = 'dark',
      });

      score.place:draw({
        x = this.w - this.padding.x + 8,
        y = y - 1,
        alpha = 40,
        align = 'right',
      });

      this.labels.score:draw({ x = x + 1, y = y });

      if (isCurr) then
        y = y + (this.labels.score.h * 0.75);
      else
        x = score.score.w + ((this.window.isPortrait and 120) or 96);

        this.labels.clear:draw({ x = x, y = y });

        y = y + (this.labels.score.h * 0.75);

        score.clear:draw({
          x = x,
          y = y + 8,
          color = 'white',
        });

        if (this.state.sp) then
          this.labels.timestamp:draw({
            x = x,
            y = y + (this.labels.score.h * 2.5) + 2,
          });

          score.timestamp:draw({
            x = x,
            y = y + (this.labels.score.h * 3.75) + 2,
            color = 'white',
          });
        else
          this.labels.name:draw({
            x = x,
            y = y + (this.labels.score.h * 2.5) + 2,
          });

          score.name:draw({
            x = x,
            y = y + (this.labels.score.h * 3.75) + 2,
            color = 'white',
          });
        end
      end

      x = this.padding.x;

      score.score:draw({ x = x - 3, y = y });

      if (isCurr) then
        y = y + score.score.h * 1.125;

        if (this.state.sp) then
          local xStat = x;
          local yStat = y + (this.labels.timestamp.h * 1.35);
          local spacing = getSpacing(Orders.sp[1], this.labels, this.maxWidth);

          for _, name in ipairs(Orders.sp[1]) do
            local overflow = 0;

            if (name == 'timestamp') then
              overflow = score[name].w - this.labels[name].w;
            end

            this.labels[name]:draw({ x = xStat - overflow, y = y });

            score[name]:draw({
              x = xStat - overflow,
              y = yStat,
              color = 'white',
            });

            xStat = xStat + this.labels[name].w + spacing;
          end

          y = y + (this.labels.timestamp.h * 2) + (score.timestamp.h * 2);
          
          xStat = x;
          yStat = y + (this.labels.timestamp.h * 1.35);
          spacing = getSpacing(Orders.sp[2], this.labels, this.maxWidth * 0.9375);

          for _, name in ipairs(Orders.sp[2]) do
            this.labels[name]:draw({ x = xStat, y = y });

            score[name]:draw({
              x = xStat,
              y = yStat,
              color = 'white',
            });

            xStat = xStat + this.labels[name].w + spacing;
          end
        else
          this.labels.name:draw({ x = x, y = y });

          score.name:draw({
            x = x,
            y = y + (this.labels.name.h * 1.35),
            color = 'white',
          });

          x = x + (this.labels.name.w * 3.5) + 1;

          this.labels.grade:draw({ x = x, y = y });

          score.grade:draw({
            x = x,
            y = y + (this.labels.grade.h * 1.35),
            color = 'white',
          });

          x = x + (this.labels.grade.w * 2.5);

          this.labels.clear:draw({ x = x, y = y });

          score.clear:draw({
            x = x,
            y = y + (this.labels.clear.h * 1.35),
            color = 'white',
          });

          y = y + (this.labels.name.h * 2) + (score.name.h * 2);

          local xStat = this.padding.x;
          local yStat = y + (this.labels.critical.h * 1.35);
          local spacing = getSpacing(Orders.mp[1], this.labels, this.maxWidth * 0.9);

          for _, name in ipairs(Orders.mp[1]) do
            this.labels[name]:draw({ x = xStat, y = y });

            if (score[name]) then
              score[name]:draw({
                x = xStat,
                y = yStat,
                color ='white',
              });
            end

            xStat = xStat + this.labels[name].w + spacing;
          end
        end
      end
    end

    return h + this.margin;
  end,

  -- Draw the current and total score amounts
  ---@param this ScoreList
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

    this.labels.currScore:draw({
      x = -(this.labels.of.w + (this.labels.totalScores.w * 2) + 24),
      y = 0,
      align = 'right',
      val = this.currScore,
    });

    this.labels.of:draw({
      x = -((this.labels.totalScores.w * 1.25) + 12),
      y = 0,
      align = 'right',
    });

    this.labels.totalScores:draw({
      x = -(this.labels.totalScores.w),
      y = 0,
      align = 'right',
      val = this.state.scoreCount,
    });

    gfx.Restore();
  end,

  -- Handle navigation of the score list
  ---@param this ScoreList
  ---@param dt deltaTime
  handleChange = function(this, dt)
    if (this.state.scoreCount > 1) then
      if (this.currScore ~= this.state.currScore) then
        this.currScore = this.state.currScore;
      end

      if ((not this.pressedFXL) and pressed('FXL')) then
        this.currScore = advance(this.currScore, this.state.scoreCount, -1);
      end

      if ((not this.pressedFXR) and pressed('FXR')) then
        this.currScore = advance(this.currScore, this.state.scoreCount, 1);
      end

      this.pressedFXL = pressed('FXL');
      this.pressedFXR = pressed('FXR');

      this.state.currScore = this.currScore;
    end

    this.list:handleChange(dt, { watch = this.currScore });
  end,

  -- Renders the current component
  ---@param this ScoreList
  ---@param dt deltaTime
  ---@param w number
  ---@param h number
  render = function(this, dt, w, h)
    this:setSizes(w, h);
    
    this:handleChange(dt);

    gfx.Save();

    this:drawList();

    this:drawAmounts();

    this.cursor:render(dt, {
      h = this.h.closed,
      curr = this.currScore,
      total = this.max
    });

    if (this.state.scoreCount > this.max) then
      this.scrollbar:render(dt, {
        curr = this.currScore,
        total = this.state.scoreCount,
      });
    end

    if (this.window.isPortrait) then
      this.labels.select:draw({
        x = this.x,
        y = this.window.h - (this.window.padding.y) + this.labels.select.h - 3,
      });
    else
      this.labels.select:draw({
        x = this.x,
        y = this.window.h - (this.window.h / 20) + this.labels.select.h - 6,
      });
    end

    gfx.Restore();
  end,
};

return ScoreList;