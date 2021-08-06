local Constants = require('constants/result');

local Mouse = require('common/mouse');

local ScoreNumber = require('components/common/scorenumber');

local Graphs = require('components/result/graphs');

local DeltaMap = {
  critical = 'critIdx',
  error = 'errorIdx',
  near = 'nearIdx',
};

-- Drawing orders
local Orders = {
  player = {
    'volforce',
    'name',
    'timestamp',
  },
  song = {
    'title',
    'artist',
    'effector',
    'difficulty',
  },
  stat = {
    'critical',
    'near',
    'error',
    'maxChain',
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

local showBestDeltas = getSetting('showBestDeltas', true);

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
      jacketSize = 0,
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
      mouse = Mouse:new(window),
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
        this.jacketSize = (this.window.w / 4) - 12;

        this.w = this.window.w - (this.window.padding.x * 2);
        this.h = (this.window.h / 1.75) - (this.window.padding.y * 3);

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
        this.jacketSize = (this.window.w / 7.5) + 2;

        this.w = this.window.w / (1920 / 864);
        this.h = this.window.h - (this.window.padding.y * 2);

        this.x.panel = (this.window.w / 2) - (this.w / 2);
        this.y.panel = this.window.padding.y;

        if ((not this.state.sp) or (this.state.scoreCount > 0)) then
          this.x.panel = this.window.padding.x;
        end

        this.padding.x = this.w / 30;
        this.padding.y = this.h / 24;

        this.state.getRegion = function()
          return (this.x.panel * this.window:getScale()),
            (this.y.panel * this.window:getScale()),
            (this.w * this.window:getScale()),
            (this.h * this.window:getScale());
        end
      end

      this.maxWidth = this.w - (this.padding.x * 2) - (this.padding.x * 1.75) - 4;

      this.x.text[1] = (this.padding.x * 3) + this.jacketSize;
      this.x.text[2] = this.padding.x * 2;
      this.y.text = (this.padding.y * 1.5) + this.jacketSize;

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
    this.graphs.y = y;
    this.graphs.w = this.maxWidth;
    this.graphs.h = this.h - y;

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
    local maxWidth = this.maxWidth - (size + padX);
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

    for _, name in ipairs(Orders.song) do
      this.labels[name]:draw({ x = x, y = y });

      if (name == 'difficulty') then
        this.labels.bpm:draw({ x = x + this.labels.difficulty.w * 2, y = y });
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

        song.bpm:draw({
          x = x + this.labels.difficulty.w * 2,
          y = y,
          color = 'white',
        });
      end

      y = y + (song[name].h * 1.725) + 1;
    end

    gfx.Restore();
  end,

  -- Draw the result stats
  ---@param this ResultPanel
  drawStats = function(this)
    local graphData = this.state.graphData or {};
    local scale = (this.window.isPortrait and 2) or 2.5;
    local stats = this.state.myScore;
    local x = this.x.text[2];
    local y = this.y.text;
    local yTemp = 0;

    gfx.Save();

    gfx.Translate(this.x.panel, this.y.panel);

    this.labels.clear:draw({ x = x, y = y });

    y = y + (this.labels.clear.h * 1.35);

    stats.clear:draw({
      x = x,
      y = y,
      color = 'white',
    });

    y = y + (stats.clear.h * 2);

    this.labels.grade:draw({ x = x, y = y });

    y = y + (this.labels.grade.h * 1.35);

    stats.grade:draw({
      x = x,
      y = y,
      color = 'white',
    });

    x = x + this.labels.grade.w * 2.25;
    yTemp = y;
    y = this.y.text;

    this.labels.score:draw({ x = x, y = y });

    stats.score:draw({ x = x - 7, y = y - 1 });

    if (this.state.upScore) then
      if (not this.upScore) then
        this.upScore = ScoreNumber:new({ size = 30, val = this.state.upScore });
      else
        local xTemp = x - 7 + stats.score.w - this.upScore.w - 6;

        this.upScore:draw({
          x = xTemp,
          y = y + 2,
          color = 'pos',
        });

        this.labels.plus:draw({
          x = xTemp - 24,
          y = y + 2,
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
        local xTemp = x - 7 + stats.score.w - this.downScore.w - 6;

        this.downScore:draw({
          x = xTemp,
          y = y + 2,
          color = 'neg',
        });

        this.labels.minus:draw({
          x = xTemp - 20,
          y = y - 6,
          color = 'neg',
        });
      end
    end

    x = this.x.text[2];
    y = yTemp + (stats.clear.h * scale);

    if (graphData.exScore) then
      this.labels.exScore:draw({ x = this.x.exScore, y = y });

      graphData.exScore:draw({
        x = this.x.exScore,
        y = y + (this.labels.exScore.h * 1.35),
        color = 'white',
      });
    end

    for _, name in ipairs(Orders.player) do
      this.labels[name]:draw({ x = this.x[name], y = y });

      if (name == 'volforce') then
        stats.volforce.val:draw({
          x = this.x.volforce,
          y = y + (this.labels.volforce.h * 1.35),
          color = 'white',
        });

        stats.volforce.increase:draw({
          x = this.x.volforce + stats.volforce.val.w + 8,
          y = y + (this.labels.volforce.h * 1.35) + 4;
        });
      else
        stats[name]:draw({
          x = this.x[name],
          y = y + (this.labels[name].h * 1.35),
          color = 'white',
        });
      end
    end

    local spacing = getSpacing(Orders.song, this.labels, this.maxWidth);

    x = this.x.text[2];
    y = y + (this.labels.clear.h * 1.35) + (stats.clear.h * scale);

    for _, name in ipairs(Orders.stat) do
      if (name == 'critical') then
        this.x.exScore = x;
      elseif (name == 'near') then
        this.x.volforce = x;
      elseif (name == 'error') then
        this.x.name = x;
      else
        this.x.timestamp = x;
      end

      this.labels[name]:draw({ x = x, y = y });

      stats[name]:draw({
        x = x,
        y = y + (this.labels[name].h * 1.35),
        color = 'white',
      });

      if (stats.deltas[name] and showBestDeltas) then
        local allowAction = this.state.sp and (this.state.scoreCount > 0);
        local idx = stats.deltas[DeltaMap[name]];
        local xD = x + 1 + stats[name].w + 8;
        local yD = y + (this.labels[name].h * 1.35) + 4;

        stats.deltas[name]:draw({ x = xD, y = yD });

        if (allowAction and idx and this.mouse:clipped(
          this.x.panel + xD - 4,
          this.y.panel + yD - 2,
          stats.deltas[name].w + 8,
          stats.deltas[name].h + 8
        )) then
          this.state.currScore = idx;
        end
      end

      if (name ~= 'near') then
        drawRect({
          x = x - 8,
          y = y + 5,
          w = 4,
          h = 13,
          color = Colors[name],
        });
      else
        drawRect({
          x = x - 8,
          y = y + 5,
          w = 4,
          h = 13,
          color = Colors.late,
        });

        drawRect({
          x = x - 8,
          y = y + 5,
          w = 4,
          h = 6.5,
          color = Colors.early,
        });
      end

      x = x + this.labels[name].w + spacing;
    end

    y = y + (this.labels.critical.h * 1.35) + (stats.critical.h * 4);

    this:setGraphSizes(y);

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this ResultPanel
  ---@param dt deltaTime
  ---@return number w, number h
  render = function(this, dt)
    this.mouse:update();

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