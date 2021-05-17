local Labels = require('constants/chalwheel');

local Scrollbar = require('components/common/scrollbar');
local SearchBar = require('components/common/searchbar');

-- Stat drawing order
---@type string[]
local Order = {
  'pct',
  'grade',
  'clear',
};

-- Get the current page of the charts
local getPage = function(curr, limit)
  return math.floor((curr - 1) / limit) + 1;
end

---@class ChalPanelClass
local ChalPanel = {
  -- ChalPanel constructor
  ---@param window Window
  ---@param state ChalWheel
  ---@param chals ChalCache
  ---@return ChalPanel
  new = function(this, window, state, chals)
    ---@class ChalPanel : ChalPanelClass
    ---@field chals ChalCache
    ---@field labels table<string, Label>
    ---@field state ChalWheel
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      chals = chals,
      charts = 3,
      chartPages = 1,
      currChal = 0,
      currPage = 1,
      endingChart = 3,
      jacketSize = 0,
      labels = {
        missing = makeLabel('norm', 'MISSING REQUIRED CHARTS', 36),
        scroll = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-A]' },
            { color = 'white', text = 'SCROLL CHARTS' },
          },
          20
        ),
      },
      padding = {
        x = { double = 0, full = 0 },
        y = { double = 0, full = 0 },
      },
      panel = Image:new('common/panel_wide.png'),
      pressedBTA = false,
      scrollbar = Scrollbar:new(),
      searchBar = SearchBar:new(),
      startingChart = 1,
      state = state,
      timers = { chart = 0, title = 0 },
      window = window,
      x = 0,
      y = 0,
      w = {
        inner = 0,
        max = 0,
        panel = 0,
      },
      h = 0,
    };

    for name, str in pairs(Labels) do
      t.labels[name] = makeLabel('med', str);
    end

    setmetatable(t, this);
    this.__index = this;
    
    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ChalPanel
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then

      this.x = this.window.padding.x;
      this.y = this.window.padding.y;

      if (this.window.isPortrait) then
        this.jacketSize = this.window.w // 9.75;

        this.w.panel = this.window.w - (this.window.padding.x * 2);
        this.h = this.window.h / 2;

        this.padding.x.full = this.w.panel / 36;
      else
        this.jacketSize = this.window.w // 17.25;

        this.w.panel = this.window.w / (1920 / this.panel.w);  
        this.h = this.window.h - (this.window.h / 10);

        this.padding.x.full = this.w.panel / 32;
      end

      this.padding.x.double = this.padding.x.full * 2;

      this.padding.y.full = this.h / 24;
      this.padding.y.double = this.padding.y.full * 2;

      this.w.inner = this.w.panel - (this.padding.x.double * 2);
      this.w.max = this.w.inner - this.jacketSize - this.padding.x.full;

      this.scrollbar:setSizes({
        x = this.x + this.w.panel - this.padding.x.full,
        y = this.y + this.padding.y.full,
        h = (this.jacketSize * 3) + (this.padding.y.full * 2), 
      });

      if (this.window.isPortrait) then
        this.searchBar:setSizes({
          x = this.x - 8,
          y = this.y + this.h + (this.window.padding.y / 3) + 2,
          w = this.w.panel + 8,
          h = this.window.padding.y * 0.8,
        });
      else
        this.searchBar:setSizes({
          x = this.x - 2,
          y = this.y / 2,
          w = this.w.panel + 3,
          h = this.window.h / 22,
        });
      end
      
      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draws the current panel
  ---@param this ChalPanel
  ---@param dt deltaTime
  drawPanel = function(this, dt)
    local cached = this.chals:get(chalwheel.challenges[this.currChal]);
    local y = 0;

    this.panel:draw({
      x = this.x,
      y = this.y,
      w = this.w.panel,
      h = this.h,
      alpha = 0.75,
    });

    if (not cached) then return; end

    gfx.Save();

    gfx.Translate(this.x + this.padding.x.double, this.y + this.padding.y.full);

    if (cached.missing) then
      this.labels.missing:draw({
        x = -2,
        y = y,
        color = 'red',
      });

      y = y + (this.labels.missing.h * 0.5) + this.padding.y.full;
    else
      y = this:drawCharts(dt, y, cached.charts);
    end

    y = this:drawInfo(dt, y, cached);

    if (cached.clear) then this:drawRes(y, cached); end

    gfx.Restore();
  end,

  -- Draws the charts of the current chal
  ---@param this ChalPanel
  ---@param dt deltaTime
  ---@param y number
  ---@param charts CachedChart[]
  drawCharts = function(this, dt, y, charts)
    local x = 2 + this.jacketSize + this.padding.x.full;

    for i = this.startingChart, this.endingChart do
      local chart = charts[i];

      if (not chart) then
        return y
          + (this.jacketSize + this.padding.y.full)
          * (this.endingChart - i + 1);
      end

      local yTemp = y;

      drawRect({
        x = 2,
        y = y,
        w = this.jacketSize,
        h = this.jacketSize,
        image = chart.jacket,
        stroke = { color = 'norm', size = 1 },
      });

      y = y - 6;

      this.labels.title:draw({ x = x, y = y });

      y = y + (this.labels.title.h * 1.25);

      if (chart.title.w > this.w.max) then
        this.timers.chart = this.timers.chart + dt;

        chart.title:drawScrolling({
          x = x,
          y = y,
          color = 'white',
          scale = this.window:getScale(),
          timer = this.timers.chart,
          width = this.w.max
        });
      else
        chart.title:draw({
          x = x,
          y = y,
          color = 'white',
        });
      end

      y = y + (chart.title.h * 1.75);

      this.labels.diff:draw({ x = x, y = y });

      this.labels.bpm:draw({ x = (x + this.labels.diff.w * 2.25), y = y });

      y = y + this.labels.diff.h * 1.25;

      chart.diff:draw({
        x = x,
        y = y,
        color = 'white',
      });

      chart.level:draw({
        x = x + chart.diff.w + 8,
        y = y,
        color = 'white',
      });

      chart.bpm:draw({
        x = (x + this.labels.diff.w * 2.25),
        y = y,
        color = 'white',
      });

      if (i == this.endingChart) then
        y = yTemp + this.jacketSize + this.padding.y.full;
        
        break;
      end

      if ((((this.endingChart - i) % 3) ~= 0) and (charts[i + 1])) then
        drawRect({
          x = 1,
          y = yTemp + this.jacketSize + (this.padding.y.full / 2) - 1,
          w = this.w.inner,
          h = 2,
          alpha = 100,
          color = 'norm',
        });
      end

      y = yTemp + this.jacketSize + this.padding.y.full;
    end

    return y;
  end,

  -- Draws the info of the current challenge
  ---@param this ChalPanel
  ---@param dt deltaTime
  ---@param y number
  ---@param chal CachedChal
  drawInfo = function(this, dt, y, chal)
    this.labels.challenge:draw({ y = y });

    y = y + (this.labels.challenge.h * 1.25);

    if (chal.title.w > this.w.inner) then
      this.timers.title = this.timers.title + dt;

      chal.title:drawScrolling({
        x = 0,
        y = y,
        color = 'white',
        scale = this.window:getScale(),
        timer = this.timers.title,
        width = this.w.inner,
      });
    else
      chal.title:draw({ y = y, color = 'white' });
    end

    y = y + (chal.title.h * 1.75);

    this.labels.reqs:draw({ y = y });

    y = y + (this.labels.reqs.h * 1.35);

    for i, req in ipairs(chal.reqs) do
      req:draw({ y = y, color = 'white' });

      y = y + (req.h * 1.75);

      if (i == 6) then break; end
    end
    
    return y + 12;
  end,

  -- Draws the results of the current chal
  ---@param this ChalPanel
  ---@param y number
  ---@param chal CachedChal
  drawRes = function(this, y, chal)
    local offset = (this.labels.grade.w * 1.5);
    local x = 0;

    for _, name in ipairs(Order) do
      this.labels[name]:draw({ x = x, y = y });

      chal[name]:draw({
        x = x,
        y = y + (this.labels[name].h * 1.35),
        color = 'white',
      });

      x = x + offset + this.labels[name].w;
    end
  end,

  -- Sets current charts being displayed
  ---@param this ChalPanel
  handleChange = function(this)
    if (this.currChal ~= this.state.currChal) then
      local cached = this.chals:get(chalwheel.challenges[this.state.currChal]);

      this.timers.chart = 0;
      this.timers.title = 0;

      if (cached) then
        this.startingChart = 1;
        this.endingChart = math.min(#cached.charts, 3);

        this.charts = #cached.charts;
      end

      this.currChal = this.state.currChal;
    end

    if (this.charts and (this.charts > 3)) then
      if ((not this.pressedBTA) and pressed('BTA')) then
        if ((this.startingChart + 3) > this.charts) then
          this.startingChart = 1;
          this.endingChart = 3;
        else
          this.startingChart = this.startingChart + 3;
          this.endingChart = this.endingChart + 3;
        end

        this.currPage = getPage(this.startingChart, 3);
      end

      this.chartPages = math.ceil(this.charts / 3);
    end

    this.pressedBTA = pressed('BTA');
  end,

  -- Render ChalPanel
  ---@param this ChalPanel
  ---@param dt deltaTime
  ---@return number
  render = function(this, dt)
    this:setSizes();

    this:handleChange();

    gfx.Save();

    this:drawPanel(dt);

    if (this.charts and (this.charts > 3)) then
      this.scrollbar:render(dt, {
        color = 'med',
        curr = this.currPage,
        total = this.chartPages,
      });

      this.labels.scroll:draw({
        x = this.x - 1,
        y = this.window.h - (this.window.h / 40) - 14,
      });
    end

    this.searchBar:render(dt, {
      input = chalwheel.searchText,
      isActive = chalwheel.searchInputActive,
    });

    gfx.Restore();

    return this.w.panel, this.h;
  end,
};

return ChalPanel;