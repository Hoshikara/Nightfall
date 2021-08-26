local Constants = require('constants/challengeresult');

-- Stat drawing orders
local Orders = {
  bottom = {
    'critical',
    'near',
    'error',
    'maxChain',
  },
  middle = {
    'result',
    'completion',
    'gauge',
    'grade',
    'clear',
  },
  top = {
    'grade',
    'clear',
    'gauge',
  },
};

---@class ChalChartsClass
local ChalCharts = {
  -- ChalCharts constructor
  ---@param this ChalChartsClass
  ---@param window Window
  ---@param state ChallengeResult
  ---@return ChalCharts
  new = function(this, window, state)
    ---@class ChalCharts : ChalChartsClass
    ---@field labels table<string, Label>
    ---@field state ChallengeResult
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      labels = {},
      jacketSize = 0,
      padding = {
        col = { x = 0, y = 0 },
        x = 0,
        y = 0,
      },
      state = state,
      timer = 0,
      window = window,
      x = 0,
      y = 0,
      w = {
        base = 0,
        col = { base = 0, max = 0 },
      },
      h = 0,
    };

    for name, str in pairs(Constants.charts) do
      t.labels[name] = makeLabel('med', str);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ChalCharts
  setSizes = function(this, h)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.x = this.window.padding.x;
      
      this.w.base = this.window.w - (this.window.padding.x * 2);

      if (this.window.isPortrait) then
        this.h = this.window.h - h - (this.window.padding.y * 3);

        this.y = (this.window.padding.y * 2) + h;

        this.padding.y = this.h / 36;
      else
        this.h = this.window.h
          - h
          - (this.window.padding.y * 2)
          - (this.window.padding.y / 2);

        this.y = (this.window.h / 2.625)
          + ((this.window.padding.y * 2) - (this.window.padding.y / 2));

        this.padding.y = this.h / 13;
      end

      this.padding.x = this.w.base / 30;

      if (this.window.isPortrait) then
        this.w.col.base = (this.h - (this.padding.y * 4)) / 3;

        this.jacketSize = (this.w.col.base // 1.85) + 7;

        this.w.col.max = this.w.base - (this.padding.x / 2);
      else
        this.w.col.base = (this.w.base - (this.padding.x * 6)) / 3;
        this.w.col.max = this.w.col.base;
        
        this.jacketSize = this.w.col.base // 3;
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Get equal spacing between stat labels
  ---@param this ChalCharts
  ---@param order string[]
  getSpacing = function(this, order)
		local w = 0;

		for _, name in ipairs(order) do w = w + this.labels[name].w; end

		return (this.w.col.max - w) / (#order - 1);
	end,

  -- Draw the challenge charts
  ---@param this ChalCharts
  ---@param dt deltaTime
  drawCharts = function(this, dt)
    local charts = this.state.charts;
    local isPortrait = this.window.isPortrait;
    local size = this.jacketSize;
    local x = this.x + this.padding.x;
    local yTemp = this.y + this.padding.y;
    
    for i = 1, math.min(3, #charts) do
      ---@type ChalChart
      local chart = charts[i];
      local xTemp = x + size + (this.padding.x / 2);
      local y = this.y + this.padding.y;

      if (isPortrait) then
        xTemp = xTemp + (this.padding.x / 2);
        y = yTemp;
      end

      drawRect({
        x = x,
        y = y,
        w = size,
        h = size,
        image = chart.jacket,
        stroke = { color = 'norm', size = 1 },
      });

      if (chart.cmod) then
        drawRect({
          x = x,
          y = y,
          w = size,
          h = size,
          alpha = 200,
          color = 'black',
          stroke = { color = 'norm', size = 1 },
        });

        chart.cmod:draw({
          x = x + (size * 0.5),
          y = y + (size * 0.5) - (chart.cmod.h * 0.175),
          align = 'middle',
          color = 'neg',
        });
      end

      if (isPortrait) then
        local maxWidth = this.w.col.max - size - (this.padding.x * 3);

        this.labels.title:draw({ x = xTemp, y = y - 5 });

        y = y + (this.labels.title.h * 1.35) - 5;

        if (chart.title.w > maxWidth) then
          chart.timer = chart.timer + dt;
          
          chart.title:drawScrolling({
            x = xTemp,
            y = y,
            color = 'white',
            scale = this.window:getScale(),
            timer = chart.timer,
            width = maxWidth,
          });
        else
          chart.title:draw({
            x = xTemp,
            y = y,
            color = 'white',
          });
        end

        y = y + (chart.title.h * 1.5);
        
        this.labels.difficulty:draw({ x = xTemp, y = y });

        this.labels.bpm:draw({
          x = xTemp + (this.labels.difficulty.w * 2.05),
          y = y,
        });

        y = y + (this.labels.difficulty.h * 1.35);

        chart.difficulty:draw({
          x = xTemp,
          y = y,
          color = 'white',
        });

        chart.level:draw({
          x = xTemp + (chart.difficulty.w + 8),
          y = y,
          color = 'white',
        });

        chart.bpm:draw({
          x = xTemp + (this.labels.difficulty.w * 2.05),
          y = y,
          color = 'white',
        });

        y = y + (chart.difficulty.h * 1.75);
      else
        this.labels.result:draw({ x = xTemp, y = y - 5 });

        this.labels.completion:draw({
          x = xTemp + (this.padding.x * 2.75),
          y = y - 5,
        });

        y = y + (this.labels.result.h * 1.35) - 5;

        chart.result:draw({
          x = xTemp,
          y = y,
          color = 'white',
        });

        chart.completion:draw({
          x = xTemp + (this.padding.x * 2.75),
          y = y,
          color = 'white',
        });

        y = y + (chart.completion.h * 2);
      end

      this.labels.score:draw({ x = xTemp, y = y + 4 });

      y = y + this.labels.score.h;

      chart.score:draw({ x = xTemp - 3, y = y });

      if (isPortrait) then
        y = yTemp + size + (this.padding.y * 0.25);
      else
        y = this.y + this.padding.y + size + (this.padding.y / 2);
      end

      if (isPortrait) then
        y = y + (this.padding.y / 2);

        for j, name in ipairs(Orders.middle) do
          local xTop = x + (((j - 1) * 5.55) * this.padding.x);

          this.labels[name]:draw({
            x = xTop,
            y = y,
          });

          chart[name]:draw({
            x = xTop,
            y = y + (this.labels[name].h * 1.35),
            color = 'white',
          });
        end

        y = y + (this.labels.grade.h * 1.35) + (chart.grade.h * 2);
      else
        this.labels.title:draw({ x = x, y = y });

        y = y + (this.labels.title.h * 1.35);

        if (chart.title.w > this.w.col.max) then
          chart.timer = chart.timer + dt;
          
          chart.title:drawScrolling({
            x = x,
            y = y,
            color = 'white',
            scale = this.window:getScale(),
            timer = chart.timer,
            width = this.w.col.max,
          });
        else
          chart.title:draw({
            x = x,
            y = y,
            color = 'white',
          });
        end

        y = y + (chart.title.h * 1.75);
        
        this.labels.difficulty:draw({ x = x, y = y });

        this.labels.bpm:draw({
          x = x + (this.labels.difficulty.w * 2.05),
          y = y,
        });

        y = y + (this.labels.difficulty.h * 1.35);

        chart.difficulty:draw({
          x = x,
          y = y,
          color = 'white',
        });

        chart.level:draw({
          x = x + (chart.difficulty.w + 8),
          y = y,
          color = 'white',
        });

        chart.bpm:draw({
          x = x + (this.labels.difficulty.w * 2.05),
          y = y,
          color = 'white',
        });

        y = y + (chart.difficulty.h * 2);

        for j, name in ipairs(Orders.top) do
          local xTop = x + (((j - 1) * 2.825) * this.padding.x);

          this.labels[name]:draw({
            x = xTop,
            y = y,
          });

          chart[name]:draw({
            x = xTop,
            y = y + (this.labels[name].h * 1.35),
            color = 'white',
          });
        end

        y = y + (this.labels.grade.h * 1.35) + (chart.grade.h * 2);
      end

      xTemp = x;

      local spacing = this:getSpacing(Orders.bottom);

      if (isPortrait) then spacing = spacing * 0.8; end

      for _, name in ipairs(Orders.bottom) do
        this.labels[name]:draw({ x = xTemp, y = y });

        chart[name]:draw({
          x = xTemp,
          y = y + (this.labels[name].h * 1.35),
          color = 'white',
        });

        xTemp = xTemp + this.labels[name].w + spacing;
      end

      if (i ~= math.min(3, #charts)) then
        if (isPortrait) then
          drawRect({
            x = this.x + this.padding.x - 1,
            y = yTemp + this.w.col.base - 1,
            w = this.w.base - (this.padding.x * 2),
            h = 2,
            alpha = 100,
            color = 'norm',
          });
        else
          drawRect({
            x = x + this.w.col.base + this.padding.x,
            y = this.y + this.padding.y,
            w = 2,
            h = this.h - (this.padding.y * 2),
            alpha = 100,
            color = 'norm',
          });
        end
			end

      if (isPortrait) then
        yTemp = yTemp + this.w.col.base + this.padding.y;
      else
        x = x + this.w.col.base + (this.padding.x * 2);
      end
    end
  end,

  -- Renders the current component
  ---@param this ChalCharts
  ---@param dt deltaTime
  ---@param h number
  render = function(this, dt, h)
    this:setSizes(h);

    gfx.Save();

    drawRect({
      x = this.x,
      y = this.y,
      w = this.w.base,
      h = this.h,
      alpha = 200,
      color = 'dark',
    });

    this:drawCharts(dt);

    gfx.Restore();
  end,
};

return ChalCharts;