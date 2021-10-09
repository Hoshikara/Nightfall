local JSONTable = require('common/jsontable');

local GaugeColors = {
  blastPass = { 120, 120, 200 },
  blastWarn = { 100, 80, 160 },
  effFail = { 20, 120, 240 },
  effPass = { 220, 20, 140 },
  excPass = { 240, 80, 40 },
  excWarn = { 240, 20, 10 },
};

local abs = math.abs;
local cos = math.cos;
local floor = math.floor;

local sampleInterval = 1 / 255;

---@class GaugeBarClass
local GaugeBar = {
  -- GaugeBar constructor
  ---@param this GaugeBarClass
  ---@param window Window
  ---@param state Gameplay
  ---@return GaugeBar
  new = function(this, window, state)
    ---@class GaugeBar : GaugeBarClass
    ---@field labels table<string, Label>
    ---@field state Gameplay
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      gaugeType = nil,
      labels = {
        ars = makeLabel('norm', 'EXCESSIVE RATE + ARS'),
        blastive = makeLabel('norm', 'BLASTIVE RATE'),
        blastiveLevel = makeLabel('num', '0', 24),
        effective = makeLabel('norm', 'EFFECTIVE RATE'),
        excessive = makeLabel('norm', 'EXCESSIVE RATE'),
        pct = makeLabel('num', '0', 24),
        permissive = makeLabel('norm', 'PERMISSIVE RATE'),
      },
      sampleIdx = 1,
      sampleJSON = JSONTable:new('samples'),
      sampleProg = 0,
      sampleSaved = false,
      samples = {},
      saveChange = true,
      state = state,
      timer = 0,
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this GaugeBar
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.x = this.window.w - (this.window.w / 14);
        this.y = this.window.h / 3.3;
        this.h = this.window.h / 3.5;
      else
        this.x = this.window.w - (this.window.w / 6.5);
        this.y = this.window.h / 3.5;
        this.h = this.window.h / 2;
      end

      this.w = 20;

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Gathers gauge samples and change (ARS) time
  ---@param this GaugeBar
  ---@param gaugeType integer
  ---@param gaugeVal number
  gatherData = function(this, gaugeType, gaugeVal)
    if (gameplay.progress == 0) then
      game.SetSkinSetting('_gaugeChange', '');

      this.gaugeType = nil;
      this.saveChange = true;

      this.samples = {};
      this.sampleIdx = 1;
      this.sampleProg = 0;
    end

    if (not this.gaugeType) then this.gaugeType = gaugeType; end

    if ((this.gaugeType ~= 0) and (gaugeType == 0) and this.saveChange) then
      game.SetSkinSetting(
        '_gaugeChange',
        tostring(math.max(0, this.sampleIdx - 1))
      );

      this.saveChange = false;
    end

    if (gameplay.progress >= this.sampleProg) then
      this.samples[this.sampleIdx] = gaugeVal;
      this.sampleIdx = this.sampleIdx + 1;
      this.sampleProg = this.sampleProg + sampleInterval;
    end

    if ((gameplay.progress == 1) and (not this.sampleSaved)) then
      this.sampleJSON:overwrite(this.samples);

      this.sampleSaved = true;
    end
  end,

  -- Renders the current component
  ---@param this GaugeBar
  ---@param dt deltaTime
  render = function(this, dt)
    this:setSizes();

    local alpha = this.state.intro.alpha;
    local ars = getSetting('_arsEnabled', 'false') == 'true';
    local color = GaugeColors.effFail;
    local gauge = { type = 0, val = 0 };
    local gaugeAlpha = 255;

    -- Backwards compatibility
    if (gameplay.gaugeType) then
      gauge.type = gameplay.gaugeType;
      gauge.val = gameplay.gauge;
    else
    	gauge.type = gameplay.gauge.type;
      gauge.val = gameplay.gauge.value;
    end

    this:gatherData(gauge.type, gauge.val);

    if (gauge.type == 0) then
      if (gauge.val < 0.7) then
        color = GaugeColors.effFail;
      else
        color = GaugeColors.effPass;
      end
    else
      if (gauge.val < 0.3) then
        this.timer = this.timer + dt;
        
        if (gauge.type == 3) then
          color = GaugeColors.blastWarn;
        else
          color = GaugeColors.excWarn;
        end

        gaugeAlpha = abs(255 * cos(this.timer * 12));
      else
        if (gauge.type == 3) then
          color = GaugeColors.blastPass;
        else
          color = GaugeColors.excPass;
        end
      end
    end

    gfx.Save();

    gfx.Translate(
      this.x,
      this.y - ((this.window.h / 8) * this.state.intro.offset)
    );

    drawRect({
      w = this.w,
      h = this.h,
      alpha = 255,
      color = 'black',
    });

    drawRect({
      y = this.h,
      w = this.w,
      h = -(this.h * gauge.val),
      alpha = gaugeAlpha,
      color = color,
    });

    drawRect({
      w = this.w,
      h = this.h,
      alpha = 0,
      color = 'black',
      stroke = {
        alpha = alpha,
        color = 'white',
        size = 2,
      },
    });

    drawRect({
      y = ((gauge.type == 0) and (this.h * 0.3)) or (this.h * 0.7),
      w = this.w,
      h = 3,
      alpha = alpha,
      color = 'white',
    });

    this.labels.pct:draw({
      x = -6,
      y = this.h - (this.h * gauge.val) - 14,
      align = 'right',
      alpha = alpha,
      color = 'white',
      text = ('%.1f%%'):format(gauge.val * 100),
      update = true,
    });

    if (gauge.type == 3) then
      local blastiveLevel = 0;

      if (not gameplay.gaugeType) then
        blastiveLevel = gameplay.gauge.options * 0.5;
      end

      this.labels.blastiveLevel:draw({
        x = this.w + 6,
        y = this.h - this.labels.blastiveLevel.h + 5,
        alpha = alpha,
        color = 'white',
        text = ('%.1f'):format(blastiveLevel),
        update = true,
      });
    end

    gfx.BeginPath();

    gfx.Rotate(90);

    if (gauge.type == 1) then
      ((ars and this.labels.ars) or this.labels.excessive):draw({
        x = -3,
        y = -this.labels.excessive.h - 29,
        alpha = alpha,
        color = 'white',
      });
    elseif (gauge.type == 2) then
      this.labels.permissive:draw({
        x = -3,
        y = -this.labels.permissive.h - 29,
        alpha = alpha,
        color = 'white',
      });
    elseif (gauge.type == 3) then
      this.labels.blastive:draw({
        x = -3,
        y = -this.labels.blastive.h - 29,
        alpha = alpha,
        color = 'white',
      });
    else
      this.labels.effective:draw({
        x = this.h + 1,
        y = -this.labels.effective.h - 29,
        align = 'right',
        alpha = alpha,
        color = 'white',
      });
    end

    gfx.Rotate(-90);

    gfx.Restore();
  end,
};

return GaugeBar;
