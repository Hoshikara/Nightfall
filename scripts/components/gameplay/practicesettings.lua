local showControls = getSetting('showPracticeControls', true);
local showSteps = getSetting('showPracticeSetup', true);

return {
  new = function(this, t)
    local PracticeSteps = require('constants/practicesteps');

    t.cache = { w = 0, h = 0 };
    t.currSetting = 0;
    t.timer = 0;
    t.x = {
      left = { 0, 0 },
      right = 0,
      panel = { 0, 0 },
    };
    t.y = {
      panel = { 0, 0 },
      navigation = 0,
    };
    t.w = 0;
    t.h = 0;

    t.controls.backesc = makeLabel('med', '[BACK]  /  [ESC]', 20);
    t.controls.fxlfxr = makeLabel('med', '[FX-L]  +  [FX-R]', 20);
    t.controls.fxlorfxr = makeLabel('med', '[FX-L]  /  [FX-R]', 20);
    t.controls.knobl = makeLabel('med', '[KNOB-L]', 20);
    t.controls.knobr = makeLabel('med', '[KNOB-R]', 20);

    t.details = {
      close = makeLabel('med', 'CLOSE SETTINGS WINDOW', 20),
      open = makeLabel('med', 'OPEN SETTINGS WINDOW', 20),
      playpause = makeLabel('med', 'PLAY  /  PAUSE', 20),
      scrubfast = makeLabel('med', 'SCRUB THROUGH SONG (FAST)', 20),
      scrubslow = makeLabel('med', 'SCRUB THROUGH SONG (SLOW)', 20),
    };

    t.setup = {
      disable = makeLabel(
        'med',
        'THIS WINDOW CAN BE DISABLED IN SKIN SETTINGS',
        20
      ),
      heading = makeLabel('norm', 'SETUP INSTRUCTIONS', 48),
      steps = {},
    };

    for i, step in ipairs(PracticeSteps) do
      t.setup.steps[i] = makeLabel('norm', step);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.w = this.window.w * 0.7;
        this.h = this.window.h * 0.325;

        this.x.panel[1] = 0;
        this.x.panel[2] = 0;

        this.y.panel[1] = this.window.h / 4;
        this.y.panel[2] = this.y.panel[1] + this.h + this.window.padding.y;

        this.x.left[1] = this.window.w / 60;
        this.x.left[2] = this.w - (this.x.left[1] * 4);

        this.x.right = this.x.panel[2] + this.window.w / 60;
      else
        this.w = this.window.w / 2.4;
        this.h = this.window.h / 1.8;

        this.x.panel[1] = 0;
        this.x.panel[2] = this.window.w - this.w;

        this.y.panel[1] = this.window.h / 4.25;
        this.y.panel[2] = this.window.h / 4.25;

        this.x.left[1] = this.window.w / 100;
        this.x.left[2] = this.w - (this.x.left[1] * 4);

        this.x.right = this.x.panel[2] + this.window.w / 100;
      end

      this.y.navigation = this.y.panel[1] + this.h - 48;

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  drawSettings = function(this, timer)
    local settings = this.settings[this.state.tab.name];
    local y = this.y.panel[1] + (this.tabs[this.state.tab.name].h * 1.75);
    local w = (this.w - (this.x.left[1] * 4) - 2) * smoothstep(this.timer);

    for i, baseSetting in ipairs(this.state.settings) do
      local setting = settings[this.state:gsub(baseSetting.name)];
      local isCurr = i == this.state.setting.index;
      local alpha = (isCurr and (255 * timer)) or (125 * timer);
      local x = this.x.left[1] + ((setting.indent and 24) or 0);

      if (isCurr) then
        drawRect({
          x = this.x.left[1] - 8,
          y = y,
          w = w,
          h = 30,
          alpha = alpha * 0.4,
          color = 'norm',
        });
      end
      
      setting.name:draw({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
      });

      this:drawValue(y, alpha, baseSetting, isCurr, setting);

      y = y + (setting.name.h * 1.75);
    end
  end,

  drawValue = function(this, y, alpha, base, isCurr, setting)
    local min, max = false, false;
    local params = {
      x = this.x.left[2],
      y = y,
      align = 'right',
      alpha = alpha,
      color = 'white',
    };
    local value;

    if ((setting.type == 'BUTTON') and (not base.value)) then
      if (isCurr) then this.controls.start:draw(params); end
    else
      if (setting.type == 'INT') then
        if ((setting.special == 'TIME')
          or (base.name:upper()):find('OFFSET')
        ) then
          setting.value:update({ text = ('%d ms'):format(base.value) });
        elseif (setting.special == 'PERCENTAGE') then
          setting.value:update({ text = ('%d%%'):format(base.value) });
        else
          setting.value:update({ text = tostring(base.value) });  
        end

        min = base.value == base.min;
        max = base.value == base.max;
      elseif (setting.type == 'FLOAT') then
        if (base.max <= 1) then
          setting.value:update({ text = ('%.f%%'):format(base.value * 100) });
        else
          setting.value:update({ text = ('%.2f'):format(base.value) });
        end

        min = base.value == base.min;
        max = base.value == base.max;
      elseif (setting.type == 'ENUM') then
        value = setting.value[base.value];
      elseif (setting.type == 'TOGGLE') then
        value = setting.value[tostring(base.value)];

        if (value.text and (value.text == 'DISABLED')) then
          params.color = 'red';
        else
          params.color = 'norm';
        end
      end

      if (value) then
        value:draw(params);
      else
        setting.value:draw(params);
      end
    end

    if (isCurr and (setting.type ~= 'BUTTON')) then
      this.state:drawArrows(this.x.left[2], y, min, max);
    end
  end,

  drawNavigation = function(this, timer)
    local alpha = 255 * timer;
    local which = (SettingsDiag.tabs[1].settings[5].value and 'fxlfxr')
      or 'backesc';
    local x1 = this.x.left[1];
    local x2 = this.x.left[2]+ 56;
    local y = this.y.navigation - (this.controls.fxl.h * 1.875);

    this.controls.fxl:draw({
      x = x1,
      y = y - 1,
      alpha = alpha,
    });

    this.pages[this.state.tab.prev]:draw({
      x = x1 + this.controls.fxl.w + 8,
      y = y,
      alpha = alpha,
      color = 'white',
    });

    this.pages[this.state.tab.next]:draw({
      x = x2,
      y = y,
      align = 'right',
      alpha = alpha,
      color = 'white',
    });

    this.controls.fxr:draw({
      x = x2 - this.pages[this.state.tab.next].w - 8,
      y = y - 1,
      align = 'right',
      alpha = alpha,
    });

    this.controls[which]:draw({
      x = x1,
      y = this.y.navigation - 1,
      alpha = alpha,
    });

    this.details.close:draw({
      x = x1 + this.controls[which].w + 8,
      y = this.y.navigation - 1,
      alpha = alpha,
      color = 'white',
    });
  end,

  drawControls = function(this)
    local x = this.x.left[1];
    local y = this.y.panel[1] - 16;

    this.controls.knobl:draw({ x = x, y = y - 1 });

    this.details.scrubslow:draw({
      x = x + this.controls.knobl.w + 8,
      y = y,
      color = 'white',
    });

    y = y + (this.controls.knobl.h * 1.5);

    this.controls.knobr:draw({ x = x, y = y - 1 });

    this.details.scrubfast:draw({
      x = x + this.controls.knobr.w + 8,
      y = y,
      color = 'white',
    });

    y = y + (this.controls.knobr.h * 1.5);

    this.controls.fxlorfxr:draw({ x = x, y = y - 1 });

    this.details.playpause:draw({
      x = x + this.controls.fxlorfxr.w + 8,
      y = y,
      color = 'white',
    });

    y = y +  (this.controls.fxlorfxr.h * 1.5);

    this.controls.backesc:draw({ x = x, y = y - 1 });

    this.details.open:draw({
      x = x + this.controls.backesc.w + 8,
      y = y,
      color = 'white',
    });
  end,

  drawSteps = function(this, timer)
    local alpha = 255 * timer;
    local x = this.x.right;
    local y = this.y.panel[2] + (this.setup.heading.h * 1.75);

    drawRect({
      x = this.x.panel[2],
      y = this.y.panel[2],
      w = this.w * 2,
      h = this.h,
      alpha = 230 * timer,
      color = 'black',
      fast = true,
    });

    this.setup.heading:draw({
      x = x - 2,
      y = this.y.panel[2] + ((this.window.isPortrait and 8) or 0),
      alpha = alpha,
    });

    for _, step in ipairs(this.setup.steps) do
      step:draw({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
      });

      y = y + (step.h * 2);
    end

    if (this.window.isPortrait) then
      this.setup.disable:draw({
        x = x,
        y = this.y.navigation + this.h + 56,
        alpha = alpha,
      });
    else
      this.setup.disable:draw({
        x = x,
        y = this.y.navigation,
        alpha = alpha,
      });
    end
  end,

  handleChange = function(this, dt)
    if (this.currSetting ~= this.state.setting.index) then
      this.timer = 0;

      this.currSetting = this.state.setting.index;
    end

    this.timer = to1(this.timer, dt, 0.2);
  end,

  render = function(this, dt, displaying, timer)
    local heading = this.tabs[this.state.tab.name];

    this:setSizes();

    this:handleChange(dt);

    gfx.Save();

    drawRect({
      x = this.x.left[1],
      y = this.y.panel[1],
      w = this.w,
      h = this.h,
      alpha = 230 * timer,
      color = 'black',
    });

    heading:draw({
      x = this.x.left[1] - 2,
      y = this.y.panel[1],
      alpha = 255 * timer,
    });

    this:drawSettings(timer);

    this:drawNavigation(timer);

    if (showControls and (not displaying)) then this:drawControls(); end

    if (showSteps) then this:drawSteps(timer); end

    gfx.Restore();
  end,
};