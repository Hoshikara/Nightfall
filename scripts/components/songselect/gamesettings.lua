local DialogBox = require('components/common/dialogbox');
local Scrollbar = require('components/common/scrollbar');

local max = math.max;

local dialogBox = DialogBox:new();

return {
  new = function(this, t)
    t.cache = { w = 0, h = 0 };
    t.max = 7;
    t.offset = 0;
    t.scrollbar = Scrollbar:new();
  
    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local key = this.state:gsub(this.state.settings[1].name);
      local settings = this.settings[this.state.tab.name];

      dialogBox:setSizes(this.window.w, this.window.h, this.window.isPortrait);

      this.scrollbar:setSizes({
        x = dialogBox.x.middleLeft - 36,
        y = dialogBox.y.top + (this.tabs[this.state.tab.name].h / 1.75);
        h = (settings[key].name.h * 1.685) * this.max,
      });
      
      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  drawSettings = function(this, dt, timer)
    local index = this.state.setting.index;
    local settings = this.settings[this.state.tab.name];
    local x = dialogBox.x.middleLeft;
    local y = dialogBox.y.top
      + (this.tabs[this.state.tab.name].h / 1.75)
      + this.offset;
    local w = (dialogBox.w.middle + 16) * smoothstep(this.timer);

    if (#this.state.settings > this.max) then
      this.scrollbar:render(dt, {
        alphaMod = timer,
        color = 'med',
        curr = index,
        total = #this.state.settings,
      });
    end

    for i, baseSetting in ipairs(this.state.settings) do
      local setting = settings[this.state:gsub(baseSetting.name)];
      local isCurr = i == index;
      local alpha = (isCurr and (255 * timer)) or (125 * timer);

      if (((index > this.max) and (i <= (index - this.max)))
        or (i > max(this.max, index))
      ) then
        alpha = 0;
      end

      if (isCurr) then
        gfx.Save();

        this.window:scale();

        drawRect({
          x = dialogBox.x.middleLeft - 8,
          y = y,
          w = w,
          h = 30,
          alpha = alpha * 0.4,
          color = 'norm',
        });

        gfx.Restore();
      end

      if (setting) then
        setting.name:draw({
          x = x,
          y = y,
          alpha = alpha,
          color = 'white',
        });

        this:drawValue(y, alpha, baseSetting, isCurr, setting);

        y = y + (setting.name.h * 1.75);
      else
        y = y + 64;
      end
    end
  end,

  drawValue = function(this, y, alpha, base, isCurr, setting)
    local min, max = false, false;
    local params = {
      x = dialogBox.x.middleRight,
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
        if (setting.special == 'TIME WINDOW') then
          setting.value:update({ text = ('±%d ms'):format(base.value) });

          if (base.value < base.max) then params.color = 'neg'; end
        elseif ((setting.special == 'TIME')
          or (base.name:upper()):find('OFFSET')
        ) then
          setting.value:update({ text = ('%d ms'):format(base.value) });
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
          params.color = 'neg';
        else
          params.color = 'pos';
        end
      end

      if (value) then
        value:draw(params);
      elseif (setting and setting.value and setting.value.draw) then
        setting.value:draw(params);
      end
    end

    if (isCurr and (setting.type ~= 'BUTTON')) then
      this.state:drawArrows(dialogBox.x.middleRight, y, min, max);
    end
  end,

  drawNavigation = function(this, timer)
    local alpha = 255 * timer;
    local x1 = dialogBox.x.middleLeft;
    local x2 = dialogBox.x.outerRight;
    local y = dialogBox.y.bottom + 12;

    this.controls.fxl:draw({
      x = x1;
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
  end,

  handleChange = function(this, dt)
    if (this.currSetting ~= this.state.setting.index) then
      this.timer = 0;

      this.currSetting = this.state.setting.index;
    end

    this.timer = to1(this.timer, dt, 0.2);
    
    if (this.state.setting.index > this.max) then
      local key = this.state:gsub(this.state.settings[1].name);
      local settings = this.settings[this.state.tab.name];

      this.offset =  (settings[key].name.h * 1.75)
        * (this.state.setting.index - this.max)
        * -1;
    else
      this.offset = 0;
    end 
  end,

  render = function(this, dt, timer)
    local heading = this.tabs[this.state.tab.name];

    this:setSizes();

    this:handleChange(dt);

    gfx.ForceRender();

    gfx.Save();

    this.window:scale();

    dialogBox:draw({
      x = this.window.w / 2,
      y = this.window.h / 2,
      alpha = timer,
      centered = true,
    });

    gfx.Restore();

    heading:draw({
      x = dialogBox.x.outerLeft - 2,
      y = dialogBox.y.top - (heading.h * 0.925),
      alpha = 255 * timer,
    });

    this:drawSettings(dt, timer);

    this:drawNavigation(timer);
  end,
};