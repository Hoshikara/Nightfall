local EarlateType = {
  'DELTA',
  'TEXT',
  'TEXT + DELTA',
};

---@param idx integer
---@param max integer
---@return integer
local nextIdx = function(idx, max)
  if ((idx + 1) > max) then return 1; end

  return idx + 1;
end

---@param idx integer
---@param max integer
---@return integer
local prevIdx = function(idx, max)
  if ((idx - 1) < 1) then return max; end

  return idx - 1;
end

---@param val number
---@param min number
---@param max number
---@param step number
---@return number
local stepUp = function(val, min, max, step)
  max = max or 1;
  max = max + (max * 0.025);
  step = step or 0.05;

  if ((val + step) > (max or 1)) then return min or 0; end

  return val + step;
end

---@param val number
---@param min number
---@param max number
---@param step number
---@return number
local stepDown = function(val, min, max, step)
  min = min or 0;
  min = min - (min * 0.025);
  step = step or 0.05;

  if ((val - step) < (min or 0)) then return max or 1; end

  return val - step;
end

local toggleInt = function(int)
  if (int == 0) then return 1; end

  return 0;
end

---@class IngamePreviewClass
local IngamePreview = {
  -- IngamePreview constructor
  ---@param this IngamePreviewClass
  ---@param window Window
  ---@return IngamePreview
  new = function(this, window, mouse, state)
    ---@class IngamePreview : IngamePreviewClass
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      bg = Image:new('preview_bg.png'),
      bgPortrait = Image:new('preview_bg_p.png'),
      btnsMade = false,
      labels = {
        [0] = makeLabel('norm', 'DISABLED', 24, 'neg'),
        [1] = makeLabel('norm', 'ENABLED', 24, 'pos'),
        exit = makeLabel(
          'med',
          {
            { color = 'norm', text = '[START]  /  [BACK]' },
            { color = 'white', text = 'EXIT' },
          },
          20
        ),
        status = makeLabel('norm', 'STATUS'),
      },
      minimized = false,
      mouse = mouse,
      offset = 0,
      padding = { x = 0, y = 0 },
      settingsLoaded = false,
      state = state,
      timers = {
        all = 0,
        box = 0,
        screen = 0,
        text = 0,
      };
      window = window,
      x = {},
      y = {},
      w = 0,
      h = {},
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this IngamePreview
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local scoreDiffX = this.scoreDiff.x;
      local hitDeltaBar = this.hitDeltaBar;
      local w = this.scoreDiff.text[1].w * 0.85;
      
      if (this.window.isPortrait) then
        this.w = this.window.w * 0.6;
        this.h.box = this.window.h * 0.45;
        this.h.screen = this.window.h * 0.625;

        this.y[1] = 0;

        this.offset = this.window.h * 0.125;

        hitDeltaBar.w = this.window.w * 0.495;
        hitDeltaBar.y = this.window.h / 6;
      else
        this.w = this.window.w // 3.3;
        this.h.box = this.window.h // 1.25;
        this.h.screen = this.window.h;

        this.y[1] = this.window.h // 5.75;

        this.offset = 0;

        hitDeltaBar.w = this.window.w / 3;
        hitDeltaBar.y = 28;
      end

      this.padding.x = this.w / 20;
      this.padding.y = this.h.box / 40;

      this.x[1] = this.window.w - this.w;
      this.x[2] = this.x[1] + this.padding.x;
      this.x[3] = this.window.w - (this.w / 6);
      this.x[4] = this.window.w - this.padding.x;

      this.y[2] = this.y[1] + this.padding.y;

      scoreDiffX[1] = -(w * 1.75);
      scoreDiffX[2] = -(w * 0.6);
      scoreDiffX[3] = w * 0.6;
      scoreDiffX[4] = w * 1.75;
      scoreDiffX.prefix = -(w * 2.95);

      hitDeltaBar.x = this.window.w / 2;
      hitDeltaBar.h = 30;

      this:setEarlateType();
    
      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Sets early / late display type
  ---@param this IngamePreview
  setEarlateType = function(this, restoreGap)
    local earlate = this.earlate;

    if (earlate.type == 'TEXT + DELTA') then
      earlate.deltaAlign = 'rightMid';
      earlate.textAlign = 'leftMid';

      if (restoreGap) then earlate.gap = earlate.gapPrev; end
    else
      earlate.deltaAlign = 'middle';
      earlate.textAlign = 'middle';
      earlate.gap = 0;
    end

    game.SetSkinSetting('earlateType', earlate.type);
  end,

  -- Loads the current gameplay settings
  ---@param this IngamePreview
  loadSettings = function(this)
    if (not this.settingsLoaded) then
      local earlate = {
        delta = makeLabel('num', '+0.0 ms', 30),
        deltaAlign = 'middle',
        heading = makeLabel('norm', 'EARLY / LATE', 36),
        status = (getSetting('showEarlate', true) and 1) or 0,
        text = makeLabel('med', 'EARLY', 30),
        textAlign = 'middle',
        type = getSetting('earlateType', 'TEXT'),
        typeIdx = 1,
        typeLabel = makeLabel('norm', 'DISPLAY TYPE'),
        typeLabels = {},
        gap = getSetting('earlateGap', 0.25),
        gapPrev = getSetting('earlateGap', 0.25),
        gapVal = makeLabel('num', '0', 24),
        gapLabel = makeLabel('norm', 'TEXT / OFFSET GAP'),
        xPos = getSetting('earlateX', 0.5),
        xPosLabel = makeLabel('norm', 'X-POSITION'),
        xPosVal = makeLabel('num', '0', 24),
        yPos = getSetting('earlateY', 0.75),
        yPosLabel = makeLabel('norm', 'Y-POSITION'),
        yPosVal = makeLabel('num', '0', 24),
      };

      local hispeed = {
        heading = makeLabel('norm', 'HI-SPEED', 36),
        status = (getSetting('showHispeed', true) and 1) or 0,
        text = makeLabel('num', '800  (8.0)', 30),
        xPos = getSetting('hispeedX', 0.5),
        xPosLabel = makeLabel('norm', 'X-POSITION'),
        xPosVal = makeLabel('num', '0', 24),
        yPos = getSetting('hispeedY', 0.75),
        yPosLabel = makeLabel('norm', 'Y-POSITION'),
        yPosVal = makeLabel('num', '0', 24),
      };

      local hitDeltaBar = {
        heading = makeLabel('norm', 'HIT DELTA BAR', 36),
        status = (getSetting('showHitDeltaBar', true) and 1) or 0,
        scale = getSetting('hitDeltaBarScale', 1.0),
        scaleLabel = makeLabel('norm', 'SCALE'),
        scaleVal = makeLabel('num', '0', 24),
        x = 0,
        y = 0,
        w = 0,
        h = 0,
      };

      local scoreDiff = {
        heading = makeLabel('norm', 'SCORE DIFFERENCE', 36),
        status = (getSetting('showScoreDiff', true) and 1) or 0,
        text = {
          makeLabel('num', '0', 50),
          makeLabel('num', '0', 50),
          makeLabel('num', '0', 50),
          makeLabel('num', '0', 40),
          prefix = makeLabel('num', '+', 36),
        },
        xPos = getSetting('scoreDiffX', 0.05),
        xPosLabel = makeLabel('norm', 'X-POSITION'),
        xPosVal = makeLabel('num', '0', 24),
        yPos = getSetting('scoreDiffY', 0.75),
        yPosLabel = makeLabel('norm', 'Y-POSITION'),
        yPosVal = makeLabel('num', '0', 24),
        x = {},
      };

      for i, str in ipairs(EarlateType) do
        if (str == earlate.type) then earlate.typeIdx = i; end

        earlate.typeLabels[i] = makeLabel('norm', str);
      end

      this.earlate = earlate;
      this.hispeed = hispeed;
      this.hitDeltaBar = hitDeltaBar;
      this.scoreDiff = scoreDiff;

      this.settingsLoaded = true;
    end
  end,

  -- Make the buttons to change settings
  ---@param this IngamePreview
  makeBtns = function(this)
    if (not this.btnsMade) then
      this.minimize = function() this.minimized = not this.minimized; end

      this.earlate.toggle = function()
        this.earlate.status = toggleInt(this.earlate.status);

        game.SetSkinSetting('showEarlate', this.earlate.status);
      end

      this.earlate.xStepUp = function()
        this.earlate.xPos = stepUp(this.earlate.xPos);

        game.SetSkinSetting('earlateX', this.earlate.xPos);
      end

      this.earlate.xStepDown = function()
        this.earlate.xPos = stepDown(this.earlate.xPos);

        game.SetSkinSetting('earlateX', this.earlate.xPos);
      end

      this.earlate.yStepUp = function()
        this.earlate.yPos = stepUp(this.earlate.yPos);

        game.SetSkinSetting('earlateY', this.earlate.yPos);
      end

      this.earlate.yStepDown = function()
        this.earlate.yPos = stepDown(this.earlate.yPos);

        game.SetSkinSetting('earlateY', this.earlate.yPos);
      end

      this.earlate.gapStepUp = function()
        this.earlate.gap = stepUp(this.earlate.gap, 0.25, 1);
        this.earlate.gapPrev = this.earlate.gap;

        game.SetSkinSetting('earlateGap', this.earlate.gap);
      end

      this.earlate.gapStepDown = function()
        this.earlate.gap = stepDown(this.earlate.gap, 0.25, 1);
        this.earlate.gapPrev = this.earlate.gap;

        game.SetSkinSetting('earlateGap', this.earlate.gap);
      end

      this.earlate.nextType = function()
        local prevType = this.earlate.type;

        this.earlate.typeIdx = nextIdx(this.earlate.typeIdx, #this.earlate.typeLabels);

        this.earlate.type = EarlateType[this.earlate.typeIdx];

        this:setEarlateType((prevType ~= 'TEXT + DELTA')
          and (this.earlate.type == 'TEXT + DELTA'));
      end

      this.earlate.prevType = function()
        local prevType = this.earlate.type;

        this.earlate.typeIdx = prevIdx(this.earlate.typeIdx, #this.earlate.typeLabels);

        this.earlate.type = EarlateType[this.earlate.typeIdx];

        this:setEarlateType((prevType ~= 'TEXT + DELTA')
          and (this.earlate.type == 'TEXT + DELTA'));
      end

      this.hispeed.toggle = function()
        this.hispeed.status = toggleInt(this.hispeed.status);

        game.SetSkinSetting('showHispeed', this.hispeed.status);
      end

      this.hispeed.xStepUp = function()
        this.hispeed.xPos = stepUp(this.hispeed.xPos);

        game.SetSkinSetting('hispeedX', this.hispeed.xPos);
      end

      this.hispeed.xStepDown = function()
        this.hispeed.xPos = stepDown(this.hispeed.xPos);

        game.SetSkinSetting('hispeedX', this.hispeed.xPos);
      end

      this.hispeed.yStepUp = function()
        this.hispeed.yPos = stepUp(this.hispeed.yPos);

        game.SetSkinSetting('hispeedY', this.hispeed.yPos);
      end

      this.hispeed.yStepDown = function()
        this.hispeed.yPos = stepDown(this.hispeed.yPos);

        game.SetSkinSetting('hispeedY', this.hispeed.yPos);
      end

      this.scoreDiff.toggle = function()
        this.scoreDiff.status = toggleInt(this.scoreDiff.status);

        game.SetSkinSetting('showScoreDiff', this.scoreDiff.status);
      end

      this.scoreDiff.xStepUp = function()
        this.scoreDiff.xPos = stepUp(this.scoreDiff.xPos);

        game.SetSkinSetting('scoreDiffX', this.scoreDiff.xPos);
      end

      this.scoreDiff.xStepDown = function()
        this.scoreDiff.xPos = stepDown(this.scoreDiff.xPos);

        game.SetSkinSetting('scoreDiffX', this.scoreDiff.xPos);
      end

      this.scoreDiff.yStepUp = function()
        this.scoreDiff.yPos = stepUp(this.scoreDiff.yPos);

        game.SetSkinSetting('scoreDiffY', this.scoreDiff.yPos);
      end

      this.scoreDiff.yStepDown = function()
        this.scoreDiff.yPos = stepDown(this.scoreDiff.yPos);

        game.SetSkinSetting('scoreDiffY', this.scoreDiff.yPos);
      end

      this.hitDeltaBar.toggle = function()
        this.hitDeltaBar.status = toggleInt(this.hitDeltaBar.status);

        game.SetSkinSetting('showHitDeltaBar', this.hitDeltaBar.status);
      end

      this.hitDeltaBar.scaleUp = function()
        this.hitDeltaBar.scale = stepUp(this.hitDeltaBar.scale, 0.50, 2, 0.10);

        game.SetSkinSetting('hitDeltaBarScale', this.hitDeltaBar.scale);
      end

      this.hitDeltaBar.scaleDown = function()
        this.hitDeltaBar.scale = stepDown(this.hitDeltaBar.scale, 0.50, 2.00, 0.10);

        game.SetSkinSetting('hitDeltaBarScale', this.hitDeltaBar.scale);
      end

      this.btnsMade = true;
    end
  end,

  -- Draw arrow button
  ---@param this IngamePreview
  ---@param y number
  ---@param right boolean
  ---@param event function
  ---@param disabled boolean
  drawArrow = function(this, y, right, event, disabled)
    local alpha = 50;
    local x = this.x[4] - 12;

    if (not right) then x = x - 36; end

    y = y + 8;

    if (this.mouse:clipped(x - 6, y - 6, 28, 28) and (not disabled)) then
      this.state.btnEvent = event;

      alpha = 255;
    end

    alpha = alpha * this.timers.text * this.timers.all;

    gfx.Save();

    this.window:scale();

    gfx.BeginPath();
    setFill('white', alpha);

    if (right) then
      gfx.MoveTo(x, y);
      gfx.LineTo(x, y + 16);
      gfx.LineTo(x + 16, y + 8);
      gfx.LineTo(x, y);
      gfx.Fill();
    else
      gfx.MoveTo(x + 16, y);
      gfx.LineTo(x + 16, y + 16);
      gfx.LineTo(x, y + 8);
      gfx.LineTo(x + 16, y);
      gfx.Fill();
    end

    gfx.Restore();
  end,

  -- Draw given setting name, value, and buttons
  ---@param this IngamePreview
  ---@param label Label
  ---@param val Label
  ---@param y number
  ---@param disabled boolean
  ---@param leftEvent function
  ---@param rightEvent function
  ---@param text string|nil
  ---@return number
  drawSetting = function(this, label, val, y, disabled, leftEvent,
                        rightEvent, text)
    local alpha = ((disabled and 50) or 255) * this.timers.text * this.timers.all;
    
    label:draw({
      x = this.x[2],
      y = y,
      alpha = alpha,
      color = 'white',
    });

    val:draw({
      x = this.x[3],
      y = y,
      align = 'right',
      alpha = alpha,
      color = text and 'white',
      text = text,
      update = text,
    });

    this:drawArrow(y, false, leftEvent, disabled);
    this:drawArrow(y, true, rightEvent, disabled);

    return y + (label.h * 1.5);
  end,

  -- Draw gameplay early / late
  ---@param this IngamePreview
  ---@param y number
  ---@return number
  drawEarlate = function(this, y)
    local earlate = this.earlate;
    local disabled = earlate.status == 0;
    local gap = 0;
    local gapDisabled = earlate.type ~= 'TEXT + DELTA';
    local typeLabel = earlate.typeLabels[earlate.typeIdx];
    local x = this.x[2];
    local w = this.window.w;
    local h = this.h.screen;

    gap = w * earlate.gap * ((this.window.isPortrait and 0.4) or 0.25);

    earlate.heading:draw({
      x = x - 2,
      y = y,
      alpha = 255 * this.timers.text * this.timers.all,
    });

    y = y + (earlate.heading.h * 1.5);

    y = this:drawSetting(
      this.labels.status,
      this.labels[earlate.status],
      y,
      false,
      earlate.toggle,
      earlate.toggle
    );

    y = this:drawSetting(
      earlate.xPosLabel,
      earlate.xPosVal,
      y,
      disabled,
      earlate.xStepDown,
      earlate.xStepUp,
      ('%.1f%%'):format(earlate.xPos * 100)
    );

    y = this:drawSetting(
      earlate.yPosLabel,
      earlate.yPosVal,
      y,
      disabled,
      earlate.yStepDown,
      earlate.yStepUp,
      ('%.1f%%'):format(earlate.yPos * 100)
    );

    y = this:drawSetting(
      earlate.gapLabel,
      earlate.gapVal,
      y,
      gapDisabled or disabled,
      earlate.gapStepDown,
      earlate.gapStepUp,
      ('%.1f%%'):format(earlate.gap * 100)
    );

    y = this:drawSetting(
      earlate.typeLabel,
      typeLabel,
      y,
      disabled,
      earlate.prevType,
      earlate.nextType
    );

    this.window:scale();

    drawRect({
      x = x,
      y = y + (earlate.heading.h * 0.75) - 1,
      w = this.w - (this.padding.x * 2) + 16,
      h = 2,
      alpha = 100 * this.timers.text * this.timers.all,
      color = 'norm',
    });

    this.window:unscale();

    if (not disabled) then
      if (earlate.type ~= 'DELTA') then
        earlate.text:draw({
          x = (w * earlate.xPos) - gap,
          y = (h * earlate.yPos) + this.offset + 2,
          align = earlate.textAlign,
          alpha = 100,
          color = { 150, 150, 150 },
        });

        earlate.text:draw({
          x = (w * earlate.xPos) - gap,
          y = (h * earlate.yPos) + this.offset,
          align = earlate.textAlign,
          alpha = 200 * this.timers.all,
          color = Colors.early,
        });
      end

      if (earlate.type ~= 'TEXT') then
        earlate.delta:draw({
          x = (w * earlate.xPos) + gap,
          y = (h * earlate.yPos) + this.offset + 6,
          align = earlate.deltaAlign,
          alpha = 100 * this.timers.all,
          color = { 150, 150, 150 },
        });

        earlate.delta:draw({
          x = (w * earlate.xPos) + gap,
          y = (h * earlate.yPos) + this.offset + 4,
          align = earlate.deltaAlign,
          alpha = 200 * this.timers.all,
          color = Colors.early,
        });
      end
    end

    return y + (earlate.heading.h * 1.5);
  end,

  -- Draw gameplay hi-speed display
  ---@param this IngamePreview
  ---@param y number
  ---@return number
  drawHispeed = function(this, y)
    local hispeed = this.hispeed;
    local disabled = hispeed.status == 0;
    local x = this.x[2];
    local w = this.window.w;
    local h = this.h.screen;

    hispeed.heading:draw({
      x = x - 2,
      y = y,
      alpha = 255 * this.timers.text * this.timers.all,
    });

    y = y + (hispeed.heading.h * 1.5);

    y = this:drawSetting(
      this.labels.status,
      this.labels[hispeed.status],
      y,
      false,
      hispeed.toggle,
      hispeed.toggle
    );

    y = this:drawSetting(
      hispeed.xPosLabel,
      hispeed.xPosVal,
      y,
      disabled,
      hispeed.xStepDown,
      hispeed.xStepUp,
      ('%.1f%%'):format(hispeed.xPos * 100)
    );

    y = this:drawSetting(
      hispeed.yPosLabel,
      hispeed.yPosVal,
      y,
      disabled,
      hispeed.yStepDown,
      hispeed.yStepUp,
      ('%.1f%%'):format(hispeed.yPos * 100)
    );

    this.window:scale();

    drawRect({
      x = x,
      y = y + (hispeed.heading.h * 0.75) - 1,
      w = this.w - (this.padding.x * 2) + 16,
      h = 2,
      alpha = 100 * this.timers.text * this.timers.all,
      color = 'norm',
    });

    this.window:unscale();

    if (not disabled) then
      hispeed.text:draw({
        x = w * hispeed.xPos,
        y = (h * hispeed.yPos) + this.offset,
        align = 'middle',
        alpha = 255 * 0.65 * this.timers.all,
        color = 'white',
      });
    end

    return y + (hispeed.heading.h * 1.5);
  end,

  -- Draw gameplay score difference display
  ---@param this IngamePreview
  ---@param y number
  ---@return number
  drawScoreDiff = function(this, y)
    local scoreDiff = this.scoreDiff;
    local disabled = scoreDiff.status == 0;
    local x = this.x[2];
    local xNum = this.window.w * scoreDiff.xPos;
    local yNum = (this.h.screen * scoreDiff.yPos) + this.offset;

    scoreDiff.heading:draw({
      x = x - 2,
      y = y,
      alpha = 255 * this.timers.text * this.timers.all,
    });

    y = y + (scoreDiff.heading.h * 1.5);

    y = this:drawSetting(
      this.labels.status,
      this.labels[scoreDiff.status],
      y,
      false,
      scoreDiff.toggle,
      scoreDiff.toggle
    );

    y = this:drawSetting(
      scoreDiff.xPosLabel,
      scoreDiff.xPosVal,
      y,
      disabled,
      scoreDiff.xStepDown,
      scoreDiff.xStepUp,
      ('%.1f%%'):format(scoreDiff.xPos * 100)
    );

    y = this:drawSetting(
      scoreDiff.yPosLabel,
      scoreDiff.yPosVal,
      y,
      disabled,
      scoreDiff.yStepDown,
      scoreDiff.yStepUp,
      ('%.1f%%'):format(scoreDiff.yPos * 100)
    );

    this.window:scale();

    drawRect({
      x = x,
      y = y + (scoreDiff.heading.h * 0.75) - 1,
      w = this.w - (this.padding.x * 2) + 16,
      h = 2,
      alpha = 100 * this.timers.text * this.timers.all,
      color = 'norm',
    });

    this.window:unscale();

    if (not disabled) then
      scoreDiff.text.prefix:draw({
        x = xNum + scoreDiff.x.prefix,
        y = yNum,
        alpha = 255 * this.timers.all,
        align = 'middle',
        color = 'white',
      });

      for i, num in ipairs(scoreDiff.text) do
        num:draw({
          x = xNum + scoreDiff.x[i],
          y = yNum + (((i > 3) and 4.5) or 0),
          align = 'middle',
          alpha = (((i < 3) and 50) or 255) * this.timers.all,
          color = ((i < 4) and 'white') or 'pos',
        });
      end
    end

    return y + (scoreDiff.heading.h * 1.5);
  end,

  -- Draw the hit delta bar
  ---@param this IngamePreview
  ---@param y number
  drawHitDeltaBar = function(this, y)
    local hitDeltaBar = this.hitDeltaBar;
    local disabled = hitDeltaBar.status == 0;
    local x = this.x[2];

    hitDeltaBar.heading:draw({
      alpha = 255 * this.timers.text * this.timers.all,
      x = x - 2, 
      y = y,
    });

    y = y + (hitDeltaBar.heading.h * 1.5);

    y = this:drawSetting(
      this.labels.status,
      this.labels[hitDeltaBar.status],
      y,
      false,
      hitDeltaBar.toggle,
      hitDeltaBar.toggle
    );

    y = this:drawSetting(
      hitDeltaBar.scaleLabel,
      hitDeltaBar.scaleVal,
      y,
      disabled,
      hitDeltaBar.scaleDown,
      hitDeltaBar.scaleUp,
      ('%.1f%%'):format(hitDeltaBar.scale * 100)
    );

    if (not disabled) then
      gfx.Save();

      this.window:scale();

      gfx.Translate(hitDeltaBar.x, hitDeltaBar.y);

      gfx.Scale(hitDeltaBar.scale, hitDeltaBar.scale);

      drawRect({
        x = -1.5,
        y = 0,
        w = 3,
        h = hitDeltaBar.h,
        alpha = 200 * this.timers.all,
        color = 'white',
      });
  
      drawRect({
        x = -(hitDeltaBar.w / 4) - 1.5,
        y = 0,
        w = 3,
        h = hitDeltaBar.h,
        alpha = 100 * this.timers.all,
        color = Colors.critical,
      });
  
      drawRect({
        x = (hitDeltaBar.w / 4) - 1.5,
        y = 0,
        w = 3,
        h = hitDeltaBar.h,
        alpha = 100 * this.timers.all,
        color = Colors.critical,
      });
  
      drawRect({
        x = -(hitDeltaBar.w / 2) - 1.5,
        y = 0,
        w = 3,
        h = hitDeltaBar.h,
        alpha = 100 * this.timers.all,
        color = Colors.early,
      });
  
      drawRect({
        x = (hitDeltaBar.w / 2) - 1.5,
        y = 0,
        w = 3,
        h = hitDeltaBar.h,
        alpha = 100 * this.timers.all,
        color = Colors.late,
      });

      this.window:unscale();

      gfx.Restore();
    end
  end,

  -- Draw the button to minimize the window
  ---@param this IngamePreview
  drawMinimizeBtn = function(this)
    local alpha = 100;
    local isClickable = (this.minimized and (this.timers.box == 0))
      or ((not this.minimized) and (this.timers.text == 1));
    local x = this.x[1] + this.w - (this.padding.x * 2) + 4;
    local y = this.y[1] + (this.padding.y / 2) + 9;

    if (isClickable and this.mouse:clipped(x - 5, y, 40, 30)) then
      alpha = 255;

      this.state.btnEvent = this.minimize;
    end

    alpha = alpha * this.timers.all;

    this.window:scale();

    drawRect({
      x = x,
      y = y + 12,
      w = 30,
      h = 6,
      alpha = alpha,
      color = 'norm',
    });

    this.window:unscale();
  end,

  handleTimers = function(this, dt)
    if (this.state.viewingPreview) then
      this.timers.screen = to1(this.timers.screen, dt, 0.125);

      if (this.timers.screen == 1) then
        this.timers.all = to1(this.timers.all, dt, 0.25);
      end

      if (not this.minimized) then
        this.timers.box = to1(this.timers.box, dt, 0.125);
  
        if (this.timers.box == 1) then
          this.timers.text = to1(this.timers.text, dt, 0.125);
        end
      elseif (this.minimized) then
        this.timers.text = to0(this.timers.text, dt, 0.125);
  
        if (this.timers.text == 0) then
          this.timers.box = to0(this.timers.box, dt, 0.125);
        end
      end
    else
      this.timers.all = 0;
      this.timers.screen = 0;
    end
  end,

  -- Renders the current component
  ---@param this IngamePreview
  ---@param dt deltaTime
  render = function(this, dt)
    this:handleTimers(dt);

    if (this.timers.screen == 0) then return; end

    gfx.ForceRender();

    this:loadSettings();

    this:makeBtns();

    this:setSizes();

    local y = this.y[2];

    gfx.Save();

    this.window:scale();

    if (this.window.isPortrait) then
      this.bgPortrait:draw({
        w = this.window.w,
        h = this.window.h,
        alpha = this.timers.screen,
      });
    else
      this.bg:draw({
        w = this.window.w,
        h = this.window.h,
        alpha = this.timers.screen,
      });
    end

    this.window:unscale();

    if (this.window.isPortrait) then
      this.labels.exit:draw({
        x = (this.window.padding.x / 2) + 1,
        y = this.window.padding.y / 2,
        alpha = 255 * this.timers.screen,
      });
    else
      this.labels.exit:draw({
        x = this.window.padding.x,
        y = this.window.h - (this.window.padding.y * 2.5),
        alpha = 255 * this.timers.screen,
      });
    end

    this.window:scale();

    drawRect({
      x = this.x[1],
      y = this.y[1],
      w = this.w,
      h = 80 + ((this.h.box - 80) * this.timers.box),
      alpha = 255 * this.timers.all,
      color = 'dark',
    });

    this.window:unscale();

    y = this:drawEarlate(y);

    y = this:drawHispeed(y);

    y = this:drawScoreDiff(y);

    this:drawHitDeltaBar(y);

    this:drawMinimizeBtn();

    gfx.Restore();
  end,
};

return IngamePreview;