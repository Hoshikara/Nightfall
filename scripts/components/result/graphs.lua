local Mouse = require('common/mouse');

local ScoreNumber = require('components/common/scorenumber');

-- Hit rating colors
local Colors = {
  [0] = { 205, 0, 0 },
  [2] = { 255, 235, 100 },
  critical = { 255, 235, 100 },
  effFail = { 20, 120, 240 },
  effPass = { 220, 20, 140 },
  excPass = { 240, 80, 40 },
  excWarn = { 220, 100, 20 },
  near = { 255, 105, 255 },
  early = { 255, 105, 255 },
  errorEarly = { 205, 0, 0 },
  errorLate = { 205, 0, 0 },
  late = { 105, 205, 255 },
};

-- Button letters
local Lanes = {
  [0] = 'A',
  [1] = 'B',
  [2] = 'C',
  [3] = 'D',
  [4] = 'L',
  [5] = 'R',
};

-- Graph drawing orders
local Orders = {
  bottom = {
    'critWindow',
    'nearWindow',
  },
  top = {
    'errorEarly',
    'early',
    'critical',
    'late',
    'errorLate',
  },
};

local floor = math.floor;
local max = math.max;
local min = math.min;

local suggestOffset = getSetting('suggestOffset', true);

---@class GraphsClass
local Graphs = {
  -- Graphs constructor
  ---@param this GraphsClass
  ---@param window Window
  ---@param state Result
  ---@return Graphs
  new = function(this, window, state)
    ---@class Graphs : GraphsClass
    ---@field data ResultGraphData
    ---@field mouse Mouse
    ---@field state Result
    ---@field window Window
    local t = {
      counts = {
        critical = ScoreNumber:new({ digits = 5, size = 20 }),
        early = ScoreNumber:new({ digits = 5, size = 20 }),
        errorEarly = ScoreNumber:new({ digits = 5, size = 20 }),
        errorLate = ScoreNumber:new({ digits = 5, size = 20 }),
        late = ScoreNumber:new({ digits = 5, size = 20 }),
      },
      buttons = {},
      data = nil,
      histSet = false,
      hitStatScale = nil,
      labels = {
        critical = makeLabel('med', 'CRITICAL', 20),
        early = makeLabel('med', 'EARLY', 20),
        errorEarly = makeLabel('med', 'ERROR', 20),
        errorLate = makeLabel('med', 'ERROR', 20),
        late = makeLabel('med', 'LATE', 20),
        mean = makeLabel('med', 'MEAN'),
        median = makeLabel('med', 'MEDIAN'),
      },
      mode = 0,
      mouse = Mouse:new(window),
      state = state,
      window = window,
      x = 0,
      y = { b = 0, t = 0 },
      w = { b = 0, t = 0 },
      h = { b = 0, t = 0 },
    };

    for btn, letter in pairs(Lanes) do
      t.buttons[btn] = makeLabel('med', letter, 18);
    end

    setmetatable(t, this);
    this.__index = this;
    
    return t;
  end,

  -- Draws the top graph: hit counts
  ---@param this Graphs
  drawTop = function(this)
    local counts = this.data.counts;
    local x = this.x;
    local y = this.y.t - 6;
    local w = this.w.t;
    local wCount = this.counts.critical.w + 12;
    local wLabel = this.labels.critical.w + 12;
    local wBar = w - wCount - wLabel;

    for _, name in ipairs(Orders.top) do
      if (name == 'total') then return; end

      drawRect({
        x = x - 8,
        y = y + 7,
        w = 4,
        h = 14,
        color = Colors[name],
      });

      this.labels[name]:draw({ x = x, y = y });

      this.counts[name]:draw({
        x = x + wLabel,
        y = y,
        color = 'white',
        val = counts[name],
      });

      drawRect({
        x = x + wLabel + wCount,
        y = y + 6,
        w = wBar,
        h = 15,
        alpha = 100,
        color = 'med',
      });

      drawRect({
        x = x + wLabel + wCount,
        y = y + 6,
        w = wBar * (counts[name] / counts.total),
        h = 15,
        color = 'norm',
      });

      y = y + (this.labels[name].h * 1.5);
    end
  end,

  -- Draws the bottom graphs: gauge, hit stat, and hit histogram
  ---@param this Graphs
  drawBottom = function(this)
    local x = this.x;
    local y = this.y.b;
    local w = this.w.b;
    local h = this.h.b;

    drawRect({
      x = x,
      y = y,
      w = w,
      h = h,
      alpha = 180,
      color = 'dark',
    });

    this:drawLines(x, y, w, h);

    this:drawLeft(x, y, w * 0.75, h);

    this:drawRight(x + (w * 0.75), y, w * 0.25, h);
  end,

  -- Draws the scale indicator lines
  ---@param this Graphs
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  drawLines = function(this, x, y, w, h)
    local critWindow = this.data.critWindow;
    local nearWindow = this.data.nearWindow;

    if (not this.labels.critWindow) then
      this.labels.critWindow = {
        neg = makeLabel('num', ('-%d'):format(critWindow), 18),
        pos = makeLabel('num', ('+%d'):format(critWindow), 18),
      };

      this.labels.nearWindow = {
        neg = makeLabel('num', ('-%d'):format(nearWindow), 18),
        pos = makeLabel('num', ('+%d'):format(nearWindow), 18),
      };
    end

    if (not this.hitStatScale) then
      this.hitStatScale = (h / 2) / (nearWindow * 1.10);
    end

    y = y + (h / 2);

    gfx.BeginPath();
    setStroke({
      alpha = 150,
      color = 'white',
      stroke = 1,
    });
    gfx.MoveTo(x, y);
    gfx.LineTo(x + w, y);
    gfx.Stroke();

    for _, name in ipairs(Orders.bottom) do
      local color = ((name == 'critWindow') and Colors.critical) or Colors.early;
      local window = (((name == 'critWindow') and critWindow) or nearWindow)
        * this.hitStatScale;

      setStroke({
        alpha = 80,
        color = color,
        stroke = 1,
      });

      gfx.BeginPath();
      gfx.MoveTo(x, y - window);
      gfx.LineTo(x + w, y - window);
      gfx.Stroke();

      this.labels[name].neg:draw({
        x = x + w - 2,
        y = y - window - 13,
        align = 'right',
        color = color,
      });

      color = ((name == 'critWindow') and Colors.critical) or Colors.late;

      setStroke({
        alpha = 80,
        color = color,
        stroke = 1,
      });

      gfx.BeginPath();
      gfx.MoveTo(x, y + window);
      gfx.LineTo(x + w, y + window);
      gfx.Stroke();

      this.labels[name].pos:draw({
        x = x + w - 2,
        y = y + window - 11,
        align = 'right',
        color = color,
      });
    end
  end,

  -- Draw the left graphs: hit stat and gauge
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  drawLeft = function(this, x, y, w, h)
    local xMouse = (this.mouse.x / this.window:getScale()) - this.window.move.x;
    local yMouse = (this.mouse.y / this.window:getScale()) - this.window.move.y;
    local isHovering = (x <= xMouse)
      and (y <= yMouse)
      and (xMouse <= x + w)
      and (yMouse <= y + h);
    local currTime = this.data.duration.val;
    local focus = 0;
    local scale = 1;

    if (isHovering) then
      focus = xMouse - x;
      scale = this.data.hoverScale;
      currTime = this.data.duration.val * (focus / w);

      gfx.BeginPath();
      setStroke({
        alpha = 150,
        color = 'white',
        size = 1,
      });
      gfx.MoveTo(xMouse, y);
      gfx.LineTo(xMouse, y + h);
      gfx.Stroke();
    end
    
    if (this.data.hitStats) then this:drawHitGraph(x, y, w, h, focus, scale); end

    if (#this.data.gauge.samples > 1) then
      if (scale == 1) then
        this:drawGaugeGraph(x, y + 2, w, h - 2, 255);
      else
        this:drawGaugeGraph(x, y + 2, w, h - 2, 50, focus, scale);
        this:drawGaugeGraph(x, y + 2, w, h - 2, 255);

        local samples = this.data.gauge.samples;
        local i = floor(1 + (#samples / w)
          * (((xMouse - x - focus) / scale) + focus));

        i = max(1, min(#samples, i));

        local yGauge = h  - (h * samples[i]);

        gfx.BeginPath();
        setFill('white', 150);
        gfx.Circle(xMouse, y + yGauge, 4);
        gfx.Fill();

        this.data.gauge.curr:draw({
          x = xMouse + 8,
          y = y + yGauge - 12,
          color = 'white',
          text = ('%d%%'):format(floor(samples[i] * 100)),
          update = true,
        });
      end

      this.data.gauge.val:draw({
        x = x + w + 5,
        y = y,
        color = 'white',
      });
    end

    this.data.duration.label:draw({
      x = x + w + 5,
      y = y + h - this.data.duration.label.h - 4,
      color = 'white',
      text = ('%02d:%02d'):format(currTime // 60000, (currTime // 1000) % 60),
      update = true,
    });
  end,

  -- Draw the right graph: hit histogram
  ---@param this Graphs
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  drawRight = function(this, x, y, w, h)
    if (not this.hitStatScale) then this.hitStatScale = 1; end

    local histogram = this.data.histogram;
    local scale = this.hitStatScale;
    local max = floor(h / 2 / scale);
    local mode = this.mode;

    if (not this.histSet) then
      local m = 0;

      for i = (-max - 1), (max + 1) do
        if (not histogram[i]) then histogram[i] = 0; end
      end

      for i = -max, max do
        local count = histogram[i - 1] + (histogram[i] * 2) + histogram[i + 1];

        if (count > m) then m = count; end
      end

      mode = m;
      this.mode = m;
      this.histSet = true;
    end
    
    gfx.BeginPath();
    setStroke({ color = 'norm', size = 1.5 });
    gfx.MoveTo(x, y);

    for i = -max, max do
      local count = histogram[i - 1] + (histogram[i] * 2) + histogram[i + 1];

      gfx.LineTo(x + (w * (count / mode)), y + (h / 2) + (i * scale));
    end

    gfx.LineTo(x, y + h);
    gfx.Stroke();
  end,

  -- Draws the hit stat graph
  ---@param this Graphs
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param focus number
  ---@param scale number
  drawHitGraph = function(this, x, y, w, h, focus, scale)
    focus = focus or 0;
    scale = scale or 1;

    if (not this.hitStatScale) then this.hitStatScale = 1; end

    local hitStatScale = this.hitStatScale;
    local hovering = this.mouse:clipped(x, y, w, h);

    for _, stat in ipairs(this.data.hitStats) do
      local color = Colors[stat.rating];
      local xStat = (((stat.timeFrac * w) - focus) * scale) + focus;

      if (stat.rating == 1) then
        if (stat.delta < 0) then
          color = Colors.early;
        else
          color = Colors.late;
        end
      end

      if (xStat >= 0) then
        if (xStat > w) then break; end

        local yStat = (h / 2) + (stat.delta * hitStatScale) - 1;

        if (yStat < 0) then
          yStat = 6;
        elseif (yStat > h) then
          yStat = h - 12;
        end

        if (hovering) then
          this.buttons[stat.lane]:draw({
            x = x + xStat - 4,
            y = y + yStat - 2,
            align = 'middle',
            alpha = 180,
            color = color,
          });
        else
          gfx.BeginPath();
          setFill(color, 180);
          gfx.Circle(x + xStat - 2, y + yStat + 1, 4);
          gfx.Fill();
        end
      end
    end
  end,

  -- Draws the gauge graph
  ---@param this Graphs
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param a number
  ---@param focus number
  ---@param scale number
  drawGaugeGraph = function(this, x, y, w, h, a, focus, scale)
    focus = focus or 0;
    scale = scale or 1;

    local samples = this.data.gauge.samples;

    if (#samples == 0) then return; end

    local leftIndex = floor((#samples / w) * ((-focus / scale) + focus));

    leftIndex = max(1, min(#samples, leftIndex));

    gfx.BeginPath();
    gfx.StrokeWidth(2);
    gfx.MoveTo(x, y + h - (h * samples[leftIndex]));

    for i = (leftIndex + 1), #samples do
      local xSample = (i * w) / #samples;

      xSample = (xSample - focus) * scale + focus;

      if (xSample > w) then break; end

      gfx.LineTo(x + xSample, y + h - (h * samples[i]) - 1);
    end
    
    if (this.data.gauge.type == 1) then
      local c = Colors.excPass;
      gfx.StrokeColor(c[1], c[2], c[3], a);
      gfx.Stroke();
    else
      local c1 = Colors.effFail;
      local c2 = Colors.effPass;

      gfx.Scissor(x, y + (h * 0.3) - 2, w, (h * 0.7) + 2);
      gfx.StrokeColor(c1[1], c1[2], c1[3], a);
      gfx.Stroke();
      gfx.ResetScissor();

      gfx.Scissor(x, y - 2, w, (h * 0.3) + 2);
      gfx.StrokeColor(c2[1], c2[2], c2[3], a);
      gfx.Stroke();
      gfx.ResetScissor();

      if (this.data.gauge.change) then
        local c3 = Colors.excPass;
        local excessive = w * (this.data.gauge.change / 256);

        gfx.Scissor(x, y - 2, (excessive - focus) * scale + focus, h + 2);
        gfx.StrokeColor(c3[1], c3[2], c3[3], a);
        gfx.Stroke();
        gfx.ResetScissor();
      end
    end
  end,

  -- Draw the mean/median deltas and offset suggestion
  ---@param this Graphs
  drawDeltas = function(this)
    local x = this.x;
    local y = this.y.b + this.h.b + 14;

    if (this.data.suggestion and suggestOffset) then
      this.data.suggestion.text:draw({ x = x, y = y });

      this.data.suggestion.offset:draw({
        x = x + this.data.suggestion.text.w + 8,
        y = y,
        color = 'white',
      });
    end

    x = x + this.w.b;
    y = y - 12;

    this.data.mean:draw({
      x = x,
      y = y,
      align = 'right',
      color = 'white',
    });

    this.labels.mean:draw({
      x = x - this.data.mean.w - 8,
      y = y,
      align = 'right',
    });

    y = y + (this.labels.mean.h * 1.35);

    this.data.median:draw({
      x = x,
      y = y,
      align = 'right',
      color = 'white',
    });

    this.labels.median:draw({
      x = x - this.data.median.w - 8,
      y = y,
      align = 'right',
    });
  end,

  -- Renders the current component
  render = function(this)
    if (not this.state.graphData) then return; end

    if (not this.data) then this.data = this.state.graphData; end

    this.mouse:watch();

    gfx.Save();

    this:drawTop();

    this:drawBottom();

    this:drawDeltas();

    gfx.Restore();
  end,
};

return Graphs;