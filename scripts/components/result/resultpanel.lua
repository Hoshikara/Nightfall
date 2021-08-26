local Constants = require('constants/result');

local ScoreNumber = require('components/common/scorenumber');

local Graphs = require('components/result/graphs');

-- Drawing orders
local Orders = {
  left = {
    'clear',
    'name',
  },
  right = {
    'grade',
    'volforce',
  },
  song = {
    'title',
    'artist',
    'effector',
    'difficulty',
    'bpm',
  },
};

---@class ResultPanelClass
local ResultPanel = {
  -- ResultPanel constructor
  ---@param this ResultPanelClass
  ---@param window Window
  ---@param state Result
  ---@return ResultPanel
  new = function(this, window, state)
    ---@class ResultPanel : ResultPanelClass
    ---@field graphs Graphs
    ---@field labels table<string, Label>
    ---@field state Result
    local t = {
      cache = { w = 0, h = 0 },
      jacketSize = 360,
      graphs = Graphs:new(window, state),
      labels = {
        minus = makeLabel('num', '-', 38);
        plus = makeLabel('num', '+', 30);
        screenshot = makeLabel(
          'med',
          {
            { color = 'white', text = 'SCREENSHOT' },
            { color = 'norm', text = '[F12]' },
          },
          20
        ),
        showDetailed = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-A]' },
            { color = 'white', text = 'DETAILED VIEW' },
          },
          20
        ),
        showSimple = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-A]' },
            { color = 'white', text = 'SIMPLE VIEW' },
          },
          20
        ),
      },
      maxWidth = 0,
      padding = { x = 0, y = 0 },
      setGraph = false,
      state = state,
      timers = {
        artist = 0,
        effector = 0,
        title = 0,
      },
      window = window,
      x = {
        exScore = 0,
        name = 0,
        panel = 0,
        text = { 0, 0 },
        timestamp = 0,
        volforce = 0,
      },
      y = { panel = 0, text = 0 },
      w = 0,
      h = 0,
    };

    for name, str in pairs(Constants.song) do
      t.labels[name] = makeLabel('med', str);
    end

    for name, str in pairs(Constants.stats) do
      t.labels[name] = makeLabel('med', str);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ResultPanel
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.w = this.window.w - (this.window.padding.x * 2);
        this.h = (this.window.h / 1.75) - (this.window.padding.y * 2);

        this.x.panel = this.window.padding.x;
        this.y.panel = this.window.padding.y;

        this.padding.x = this.w / 40;
        this.padding.y = this.h / 24;

        this.state.getRegion = function()
          local y = this.window.h - this.h - this.window.padding.y;

          return (this.x.panel * this.window:getScale()),
            (y * this.window:getScale()),
            (this.w * this.window:getScale()),
            (this.h * this.window:getScale());
        end
      else
        this.w = this.window.w / (1920 / 864);
        this.h = this.window.h - (this.window.padding.y * 2);

        this.x.panel = (this.window.w / 2) - (this.w / 2);
        this.y.panel = this.window.padding.y;

        if ((not this.state.sp) or (this.state.scoreCount > 0)) then
          this.x.panel = this.window.padding.x;
        end

        this.padding.x = this.w / 36;
        this.padding.y = this.h / 30;

        this.state.getRegion = function()
          return (this.x.panel * this.window:getScale()),
            (this.y.panel * this.window:getScale()),
            (this.w * this.window:getScale()),
            (this.h * this.window:getScale());
        end
      end

      this.maxWidth = this.w - (this.padding.x * 4);

      this.x.text[1] = (this.padding.x * 3.5) + this.jacketSize;
      this.x.text[2] = this.padding.x * 2;
      this.y.text = (this.padding.y * 1.75) + this.jacketSize;

      if (this.window.isPortrait) then this.y.text = this.y.text - 16; end

      this.graphs.hitStatScale = nil;
      this.graphs.histSet = false;
      this.setGraph = true;

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Sets the sizes for the graphs
  ---@param this ResultPanel
  ---@param y number
  setGraphSizes = function(this, y)
    if (not this.setGraph) then return; end

    this.graphs.x = this.x.panel + (this.padding.x * 2);
    this.graphs.y[1] = this.y.panel + this.y.text + 6;
    this.graphs.y[2] = this.y.panel + y;
    this.graphs.w[1] = this.jacketSize;
    this.graphs.w[2] = this.maxWidth;
    this.graphs.h = this.h - y - this.y.panel;

    this.setGraph = false;
  end,

  -- Draw the info for the chart
  ---@param this ResultPanel
  ---@param dt deltaTime
  drawSongInfo = function(this, dt)
    local padX = this.padding.x;
    local padY = this.padding.y;
    local size = this.jacketSize;
    local song = this.state.song;
    local maxWidth = this.maxWidth - (size + (padX * 1.5));
    local x = this.x.text[1];
    local y = this.padding.y - 5;

    gfx.Save();

    gfx.Translate(this.x.panel, this.y.panel);

    drawRect({
      x = padX * 2,
      y = padY,
      w = size,
      h = size,
      image = song.jacket,
      stroke = { color = 'norm', size = 1.5 },
    });

    if (song.cmod) then
      drawRect({
        x = padX * 2,
        y = padY,
        w = size,
        h = size,
        alpha = 200,
        color = 'black',
        stroke = { color = 'norm', size = 1.5 },
      });

      song.cmod:draw({
        x = (padX * 2) + (size * 0.5),
        y = padY + (size * 0.5) - (song.cmod.h * 0.175),
        align = 'middle',
        color = 'neg',
      });
    end

    for _, name in ipairs(Orders.song) do
      this.labels[name]:draw({ x = x, y = y });

      if (name == 'bpm') then
        this.labels.timestamp:draw({ x = x + 212, y = y });
      end

      y = y + (this.labels[name].h * 1.35);

      if (song[name].w > maxWidth) then
        this.timers[name] = this.timers[name] + dt;

        song[name]:drawScrolling({
          x = x,
          y = y,
          color = 'white',
          scale = this.window:getScale(),
          timer = this.timers[name],
          width = maxWidth,
        });
      else
        song[name]:draw({
          x = x,
          y = y,
          color = 'white',
        });
      end

      if (name == 'difficulty') then
        song.level:draw({
          x = x + song.difficulty.w + 12,
          y = y,
          color = 'white',
        });
      elseif (name == 'bpm') then
        song.timestamp:draw({
          x = x + 212,
          y = y,
          color = 'white',
        });
      end

      y = y + (song[name].h * 2.075) + 1.25;
    end

    gfx.Restore();
  end,

  -- Draw the result stats
  ---@param this ResultPanel
  drawStats = function(this)
    local stats = this.state.myScore;
    local h1 = this.labels.grade.h * 1.35;
    local h2 = stats.grade.h * ((this.window.isPortrait and 1.875) or 2.25);
    local x1 = this.x.text[1];
    local x2 = x1 + 212;
    local y = this.y.text;
    local yLeft = 0;
    local yRight = 0;

    gfx.Save();

    gfx.Translate(this.x.panel, this.y.panel);

    this.labels.score:draw({ x = x1, y = y });

    stats.score:draw({ x = x1 - 3, y = y + 11 });

    if (this.state.upScore) then
      if (not this.upScore) then
        this.upScore = ScoreNumber:new({ size = 30, val = this.state.upScore });
      else
        local xTemp = x1 + stats.score.w - this.upScore.w - 7;

        this.upScore:draw({
          x = xTemp,
          y = y - 3,
          color = 'pos',
        });

        this.labels.plus:draw({
          x = xTemp - 22,
          y = y - 2,
          color = 'white',
        });
      end
    elseif (this.state.downScore) then
      if (not this.downScore) then
        this.downScore = ScoreNumber:new({
          size = 30,
          val = this.state.downScore,
        });
      else
        local xTemp = x1 + stats.score.w - this.downScore.w - 7;

        this.downScore:draw({
          x = xTemp,
          y = y - 3,
          color = 'neg',
        });

        this.labels.minus:draw({
          x = xTemp - 18,
          y = y - 10,
          color = 'neg',
        });
      end
    end

    yLeft = y + stats.score.h + 17;
    yRight = yLeft;

    for _, name in ipairs(Orders.left) do
      this.labels[name]:draw({ x = x1, y = yLeft });

      yLeft = yLeft + h1;

      stats[name]:draw({
        x = x1,
        y = yLeft,
        color = 'white',
      });

      yLeft = yLeft + h2;
    end

    for _, name in ipairs(Orders.right) do
      this.labels[name]:draw({ x = x2, y = yRight });

      yRight = yRight + h1;

      if (name == 'volforce') then
        stats.volforce.val:draw({
          x = x2,
          y = yRight,
          color = 'white',
        });

        stats.volforce.increase:draw({
          x = x2 + stats.volforce.val.w + 8,
          y = yRight + 4;
        });
      else
        stats[name]:draw({
          x = x2,
          y = yRight,
          color = 'white',
        });
      end

      yRight = yRight + h2;
    end

    this:setGraphSizes(yLeft);

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this ResultPanel
  ---@param dt deltaTime
  ---@return number w, number h
  render = function(this, dt)
    this:setSizes();

    gfx.Save();

    drawRect({
      x = this.x.panel,
      y = this.y.panel,
      w = this.w,
      h = this.h,
      alpha = 200,
      color = 'dark',
    });

    this:drawSongInfo(dt);

    this:drawStats();

    this.graphs:render();

    if (this.window.isPortrait) then
      y = this.y.panel - (this.window.padding.y / 1.5);
    else
      y = this.window.h - (this.window.padding.y) + this.labels.showSimple.h - 6;
    end

    if (getSetting('showSimpleGraph', false)) then
      this.labels.showDetailed:draw({ x = this.x.panel - 2, y = y });
    else
      this.labels.showSimple:draw({ x = this.x.panel - 2, y = y });
    end

    this.labels.screenshot:draw({
      x = this.x.panel + this.w,
      y = y,
      align = 'right',
    });

    gfx.Restore();

    return this.w, this.h;
  end,
};

return ResultPanel;