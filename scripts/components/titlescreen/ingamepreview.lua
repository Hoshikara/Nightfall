local Tabs = require('helpers/ingamepreview');

local Earlate = require('components/gameplay/earlate');
local HitAnimation = require('components/gameplay/hitanimation');
local HitDeltaBar = require('components/gameplay/hitdeltabar');

local EnabledColor = { 255, 205, 0 };

local TabNames = {
  'earlate',
  'hitAnim',
  'hitDeltaBar',
  'laneSpeed',
  'scoreDiff',
};

local rand = math.random;

---@class IngamePreviewClass
local IngamePreview = {
  -- IngamePreview constructor
  ---@param this IngamePreviewClass
  ---@param window Window
  ---@param mouse Mouse
  ---@param state Titlescreen
  ---@return IngamePreview
  new = function(this, window, mouse, state)
    ---@class IngamePreview : IngamePreviewClass
    ---@field mouse Mouse
    ---@field state Titlescreen
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      currTab = '',
      bg = Image:new('preview_bg.png'),
      bgPortrait = Image:new('preview_bg_p.png'),
      labels = {
        exit = makeLabel(
          'med',
          {
            { color = 'norm', text = '[START]  /  [BACK]' },
            { color = 'white', text = 'EXIT' },
          },
          20
        ),
        heading = makeLabel('norm', 'SETTINGS', 48),
      },
      mouse = mouse,
      offset = 0,
      padding = { x = 24, y = 36 },
      settingsLoaded = false,
      shift = 0,
      sideClosed = false,
      state = state,
      timers = {
        hit = 0,
        hitAnim = 0,
        numbers = 0,
        side = 1,
        tabs = {},
      };
      window = window,
      x = {},
      y = {},
      w = 0,
      h = {},
    };

    for _, name in ipairs(TabNames) do t.timers.tabs[name] = 0; end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this IngamePreview
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local scoreDiffX = this.tabs.scoreDiff.x;
      local w = this.tabs.scoreDiff.text[1].w * 0.85;
      
      if (this.window.isPortrait) then
        this.w = this.window.w;
        this.h.screen = this.window.h * 0.625;

        this.offset = this.window.h * 0.125;

        this.y[1] = this.window.h - (this.window.h * 0.2925);
      else
        this.w = this.window.w // 3;
        this.h.screen = this.window.h;

        this.offset = 0;

        this.y[1] = 0;
      end

      this.x[1] = this.window.w - this.w;
      this.x[2] = this.x[1] + this.padding.x;
      this.x[3] = this.x[2] + this.padding.x + 14;
      this.x[4] = this.window.w - this.padding.x;

      this.y[2] = this.y[1] + this.padding.y * 2.25;

      scoreDiffX[1] = -(w * 1.75);
      scoreDiffX[2] = -(w * 0.6);
      scoreDiffX[3] = w * 0.6;
      scoreDiffX[4] = w * 1.75;
      scoreDiffX.prefix = -(w * 2.95);
    
      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Loads the current gameplay settings
  ---@param this IngamePreview
  loadSettings = function(this)
    if (not this.tabs) then
      local earlate = Tabs.getEarlate();
      local hitAnim = Tabs.getHitAnim();
      local hitDeltaBar = Tabs.getHitDeltaBar();
      local laneSpeed = Tabs.getLaneSpeed();
      local scoreDiff = Tabs.getScoreDiff();

      earlate.component = Earlate:new(this.window, {
        buttonDelta = 1,
        timers = { earlate = 1 },
      });

      earlate.render = function(dt) earlate.component:render(dt, true); end

      hitAnim.component = HitAnimation:new(this.window);

      hitAnim.render = function(dt)
        this.timers.hitAnim = this.timers.hitAnim + dt;

        if (this.timers.hitAnim >= 0.5) then
          hitAnim.component:trigger(0, 1);
          hitAnim.component:trigger(1, 2);
        
          this.timers.hitAnim = 0;
        end

        gfx.Save();

        hitAnim.component:render(dt, true);

        gfx.Restore();
      end

      hitDeltaBar.component = HitDeltaBar:new(this.window);

      hitDeltaBar.render = function(dt)
        this.timers.hit = this.timers.hit + dt;
  
        if (this.timers.hit >= 0.05) then
          hitDeltaBar.component:trigger(rand(0, 5), 2, rand(-46, 46));
        
          this.timers.hit = 0;
        end
  
        gfx.Save();
  
        this.window:scale();
  
        hitDeltaBar.component:render(dt, true);
        
        gfx.Restore();
      end

      laneSpeed.render = function(dt)
        local ignore = laneSpeed.settings[1].value == 1;
        local w = this.window.w;
        local h = this.h.screen;
  
        laneSpeed.text[(ignore and 1) or 2]:draw({
          x = w * laneSpeed.settings[2].value,
          y = (h * laneSpeed.settings[3].value) + this.offset,
          align = 'middle',
          alpha = 255 * 0.65,
        });
      end

      scoreDiff.render = function(dt)
        local delay = scoreDiff.settings[1].value;
        local x = this.window.w * scoreDiff.settings[2].value;
        local y = (this.h.screen * scoreDiff.settings[3].value) + this.offset;
  
        this.timers.numbers = this.timers.numbers + dt;
  
        if (this.timers.numbers >= delay) then
          for i, _ in ipairs(scoreDiff.numbers) do
            scoreDiff.numbers[i] = rand(1, 9);
          end
  
          this.timers.numbers = 0;
        end
  
        scoreDiff.text.prefix:draw({
          x = x + scoreDiff.x.prefix,
          y = y,
          align = 'middle',
          color = 'white',
        });
  
        for i, num in ipairs(scoreDiff.text) do
          num:draw({
            x = x + scoreDiff.x[i],
            y = y + (((i > 3) and 4.5) or 0),
            align = 'middle',
            color = ((i < 4) and 'white') or 'pos',
            text = scoreDiff.numbers[i],
            update = true,
          });
        end
      end

      this.tabs = {
        earlate = earlate,
        hitAnim = hitAnim,
        hitDeltaBar = hitDeltaBar,
        laneSpeed = laneSpeed,
        scoreDiff = scoreDiff,
      };
    end
  end,

  -- Draws an arrow button
  ---@param this IngamePreview
  ---@param y number
  ---@param right boolean
  ---@param event function
  ---@param timer number
  ---@param enabled boolean
  ---@param expanded boolean
  drawArrow = function(this, y, right, event, timer, enabled, expanded)
    local alpha = 50;
    local x = this.x[4] - 4 + this.shift;

    if (not right) then x = x - 36; end

    y = y + 7;

    if (enabled and expanded and this.mouse:clipped(x - 6, y - 6, 28, 28)) then
      this.state.btnEvent = function() event((right and 1) or -1); end

      alpha = 255;
    end

    alpha = alpha * timer;

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

  -- Draws the button to expand/collapse the tab
  ---@param this IngamePreview
  ---@param y number
  ---@param tabName string
  ---@param expanded boolean
  drawExpandBtn = function(this, y, tabName, expanded)
    local alpha = 100;
    local x = this.x[4] - 16 + this.shift;

    y = y + 14;

    if (this.mouse:clipped(x - 6, y - 6, 36, 36)) then
      this.state.btnEvent = function()
        if (expanded) then
          this.currTab = '';
        else
          this.currTab = tabName;
        end
      end

      alpha = 255;
    end

    y = y + 4;

    gfx.Save();

    this.window:scale();

    setFill('norm', alpha);

    if (expanded) then
      gfx.BeginPath();
      gfx.MoveTo(x, y + 15);
      gfx.LineTo(x + 12, y);
      gfx.LineTo(x + 24, y + 15);
      gfx.ClosePath();
      gfx.Fill();
    else
      gfx.BeginPath();
      gfx.MoveTo(x, y);
      gfx.LineTo(x + 12, y + 15);
      gfx.LineTo(x + 24, y);
      gfx.ClosePath();
      gfx.Fill();
    end

    gfx.Restore();
  end,

  -- Draws the given setting
  ---@param this IngamePreview
  ---@param setting IngamePreviewSetting
  ---@param y number
  ---@param timer number
  ---@param enabled boolean
  ---@param expanded boolean
  ---@return number
  drawSetting = function(this, setting, y, timer, enabled, expanded)
    local alpha = ((enabled and 255) or 50) * timer;

    setting.label:draw({
      x = this.x[3] + this.shift,
      y = y,
      alpha = alpha,
      color = 'white',
    });

    setting.valueLabel:draw({
      x = this.x[4] - 56 + this.shift,
      y = y,
      align = 'right',
      alpha = alpha,
      color = setting.color,
      text = setting.text,
      update = true,
    });

    this:drawArrow(y, false, setting.event, timer, enabled, expanded);
    this:drawArrow(y, true, setting.event, timer, enabled, expanded);

    return y + 36;
  end,

  -- Draws the setting's toggle button
  ---@param setting IngamePreviewSetting
  ---@param y number
  ---@param enabled boolean
  drawToggleBtn = function(this, setting, y, enabled)
    local alpha = (enabled and 255) or 0;
    local x = this.x[2] + this.shift;

    if (this.mouse:clipped(x + 2, y + 12, 24, 24)) then
      this.state.btnEvent = setting.event;
    end

    gfx.Save();

    this.window:scale();

    drawRect({
      x = x + 2,
      y = y + 12,
      w = 23,
      h = 23,
      alpha = alpha,
      color = EnabledColor,
      stroke = {
        alpha = 255,
        color = 'norm',
        size = 2,
      },
    });

    gfx.Restore();
  end,

  -- Draws a tab and its corresponding component
  ---@param this IngamePreview
  ---@param dt deltaTime
  ---@param tab IngamePreviewTab
  ---@param timer number
  ---@param expanded boolean
  ---@param y number
  ---@return number
  drawTab = function(this, dt, tab, timer, expanded, name, y)
    local enabled = tab.status.value == 1;
    local x = this.x[2] + this.shift;
    local yReturn = y + 48 + (tab.h * timer);

    this:drawExpandBtn(y, name, expanded);
    this:drawToggleBtn(tab.status, y, enabled);

    tab.heading:draw({
      x = x + 36,
      y = y + 4,
      color = (expanded and 'norm') or 'white',
    });

    y = y + (tab.heading.h * 1.75);

    for _, setting in ipairs(tab.settings) do
      y = this:drawSetting(setting, y, timer, enabled, expanded);
    end

    this.window:scale();

    drawRect({
      x = this.x[1] + this.shift,
      y = yReturn,
      w = this.w,
      h = 2,
      color = 'med',
    });

    this.window:unscale();

    if (enabled) then tab.render(dt); end

    return yReturn;
  end,

  -- Draws the hamburger menu button
  ---@param this IngamePreview
  drawHamburger = function(this)
    local x = this.window.w - (this.padding.x * 0.75) - 52;
    local y = this.y[1] + this.padding.y - 10;

    if (this.mouse:clipped(x, y - 10, 52, 48)) then
      this.state.btnEvent = function()
        this.sideClosed = not this.sideClosed;
      end
    end

    drawRect({
      x = x,
      y = y - 10,
      w = 52,
      h = 48,
      color = 'dark',
      fast = true,
    });

    for i = 0, 2 do
      drawRect({
        x = x + 8,
        y = y + (i * 12),
        w = 36,
        h = 3,
        fast = true,
      });
    end
  end,

  -- Handles animations from user input
  ---@param this IngamePreview
  ---@param dt deltaTime
  handleTimers = function(this, dt)
    local timers = this.timers;

    if (this.sideClosed) then
      timers.side = to1(timers.side, dt, 0.167);
    else
      timers.side = to0(timers.side, dt, 0.167);
    end

    this.shift = this.w * timers.side;

    for name, _ in pairs(timers.tabs) do
      if (name == this.currTab) then
        timers.tabs[name] = to1(timers.tabs[name], dt, 0.125);
      elseif (name ~= this.currTab) then
        timers.tabs[name] = to0(timers.tabs[name], dt, 0.125);
      end
    end
  end,

  -- Renders the current component
  ---@param this IngamePreview
  ---@param dt deltaTime
  render = function(this, dt)
    this:handleTimers(dt);

    gfx.ForceRender();

    this:loadSettings();

    this:setSizes();

    local currTab = this.currTab;
    local y = this.y[2];

    gfx.Save();

    this.window:scale();

    ((this.window.isPortrait and this.bgPortrait) or (this.bg)):draw({
      w = this.window.w,
      h = this.window.h,
    });

    this.window:unscale();

    if (this.window.isPortrait) then
      this.labels.exit:draw({
        x = (this.window.padding.x / 2) + 1,
        y = this.window.padding.y / 2,
      });
    else
      this.labels.exit:draw({
        x = this.window.padding.x,
        y = this.window.h - (this.window.padding.y * 2.5),
      });
    end

    this.window:scale();

    drawRect({
      x = this.x[1] + this.shift,
      y = this.y[1],
      w = this.w,
      h = this.window.h,
      color = 'dark',
    });

    drawRect({
      x = this.x[1] + this.shift,
      y = this.y[1],
      w = this.w,
      h = 80,
      color = 'med',
    });

    this.window:unscale();

    this.labels.heading:draw({
      x = this.x[2] - 2 + this.shift,
      y = this.y[1] + 11,
      color = 'white',
    });

    for _, name in ipairs(TabNames) do
      y = this:drawTab(
        dt,
        this.tabs[name],
        this.timers.tabs[name],
        currTab == name,
        name,
        y
      );
    end

    this:drawHamburger();

    gfx.Restore();
  end,
};

return IngamePreview;