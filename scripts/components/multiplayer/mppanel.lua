game.LoadSkinSample('click_difficulty');
game.LoadSkinSample('click_song');

local JSON = require('lib/json');

local Difficulties = require('constants/difficulties');
local Labels = require('constants/songwheel');

local Button = require('components/common/button');
local Cursor = require('components/common/cursor');

local Order = {
  'title',
  'artist',
  'effector',
  'bpm',
};

local fallback = gfx.CreateSkinImage('loading.png', 0);

local getDiff = function(diffs, i)
  local index = nil;

  for j, diff in ipairs(diffs) do
    if ((diff.difficulty + 1) == i) then index = j; end
  end

  return diffs[index];
end

local toggleRotate = function()
  Tcp.SendLine(JSON.encode({ topic = 'room.option.rotation.toggle' }));
end

---@class MpPanelClass
local MpPanel = {
  -- MpPanel constructor
  ---@param this MpPanelClass
  ---@param window Window
  ---@param mouse Mouse
  ---@param state Multiplayer
  ---@param constants table
  ---@return MpPanel
  new = function(this, window, mouse, state, constants)
    ---@class MpPanel : MpPanelClass
    ---@field window Window
    local t = {
      btn = { x = 0, y = {} },
      buttons = {
        med = Button:new(355, 50),
        norm = Button:new(198, 50),
      },
      cache = { w = 0, h = 0 },
      currDiff = 1,
      cursor = Cursor:new({
        size = 12,
        stroke = 1.5,
        type = 'vertical',
      }),
      cursorIdx = 0,
      diffs = {},
      info = {
        artist = makeLabel('jp', '', 30),
        bpm = makeLabel('num', '', 24),
        effector = makeLabel('jp', '', 24),
        title = makeLabel('jp', '', 36),
      },
      innerWidth = 0,
      jacketSize = 0,
      mouse = mouse,
      labels = {},
      levels = {},
      padding = {
        x = { double = 0, full = 0 },
        y = { double = 0, full = 0 },
      },
      song = nil,
      state = state,
      timers = {
        artist = 0,
        effector = 0,
        title = 0,
      },
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = 0,
    };

    for name, str in pairs(constants) do
      t.labels[name] = makeLabel('med', str);
    end

    for i, diff in ipairs(Difficulties) do
      t.diffs[i] = makeLabel('med', diff);
    end

    for name, str in pairs(Labels) do
      t.labels[name] = makeLabel('med', str);
    end

    for i = 1, 4 do t.levels[i] = makeLabel('num', '00') end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this MpPanel
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.jacketSize = this.window.w // 4.75;

        this.buttons.norm.w = this.jacketSize;

        this.w = this.window.w - (this.window.padding.x * 2);
        this.h = this.window.h // 2.9;

        this.padding.x.full = this.w / 36;
        this.padding.y.full = this.h / 18;
      else
        this.jacketSize = this.window.w // 5;

        this.buttons.norm.w = 198;

        this.w = this.window.w / (1920 / 748);
        this.h = this.window.h - (this.window.padding.y * 2);

        this.padding.x.full = this.w / 24;
        this.padding.y.full = this.h / 20;
      end

      this.x = this.window.padding.x;
      this.y = this.window.padding.y;
      this.middle = this.w / 2;

      this.padding.x.double = this.padding.x.full * 2;
      this.padding.y.double = this.padding.y.full * 2;

      this.innerWidth = this.w - (this.padding.x.double * 2);

      if (this.window.isPortrait) then
        this.btn.x = this.x
          + this.w
          - this.padding.x.double
          - this.buttons.med.w
          + 4;
        this.btn.y[1] = this.y + this.h - (this.padding.y.double * 2.5) - 4;
        this.btn.y[2] = this.btn.y[1] + (this.buttons.med.h * 1.5);

        this.cursor:setSizes({
          x = this.x + this.padding.x.full + 23,
          y = this.y
            + this.jacketSize
            + this.padding.y.double
            + this.labels.difficulty.h
            - 6,
          w = this.jacketSize + 5,
          h = this.buttons.norm.h,
          margin = this.buttons.norm.h * 0.75,
        });
      else
        this.btn.x = this.x + this.padding.x.double - 4;
        this.btn.y[1] = this.y + this.h - (this.padding.y.double * 2.5) + 24;
        this.btn.y[2] = this.btn.y[1] + (this.buttons.med.h * 1.5);

        this.cursor:setSizes({
          x = this.x
            + this.padding.x.double
            + this.jacketSize
            + this.padding.x.full
            + 16,
          y = this.y
            + this.padding.y.double
            + this.labels.difficulty.h
            - 32,
          w = this.buttons.norm.w,
          h = this.buttons.norm.h,
          margin = this.buttons.norm.h * 0.925,
        });
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the chart jacket
  ---@param this MpPanel
  drawJacket = function(this)
    local lobby = this.state.lobby;

    if ((not lobby.jacket) or (lobby.jacket == fallback)) then
      lobby.jacket = gfx.LoadImageJob(
        this.song.jacketPath,
        fallback,
        this.jacketSize,
        this.jacketSize
      );
    end

    drawRect({
      x = this.padding.x.double,
      y = this.padding.y.full,
      w = this.jacketSize,
      h = this.jacketSize,
      image = lobby.jacket,
      stroke = { color = 'norm', size = 2 },
    });
  end,

  -- Draw the chart diffs
  ---@param this MpPanel
  ---@param y number
  ---@param diff table
  ---@param isCurr boolean
  drawDiff = function(this, y, i, diff, isCurr)
    local scale = 0.925;
    local x = this.padding.x.double + this.jacketSize + this.padding.x.full + 16;

    if (this.window.isPortrait) then
      scale = 0.75;
      x = this.padding.x.double - 1;
      w = this.jacketSize + 14;
    end

    this.buttons.norm:render({
      x = x,
      y = y,
      accentAlpha = (isCurr and 1) or 0.3,
    });

    if (diff) then
      local j = getDiffIndex(diff.jacketPath, diff.difficulty);

      this.diffs[j]:draw({
        x = x + 24,
        y = y + (this.buttons.norm.h * 0.5) - 12,
        alpha = 255 * ((isCurr and 1) or 0.2),
        color = 'white',
      });

      this.levels[i]:draw({
        x = x + this.buttons.norm.w - 24,
        y = y + (this.buttons.norm.h * 0.5) - 12,
        align = 'right',
        alpha = 255 * ((isCurr and 1) or 0.2),
        color = 'white',
        text = ('%02d'):format(diff.level),
        update = true,
      });
    end

    return this.buttons.norm.h + (this.buttons.norm.h * scale);
  end,

  -- Draw the chart info
  ---@param this MpPanel
  ---@param dt deltaTime
  drawInfo = function(this, dt)
    local multi = (this.window.isPortrait and 1.9) or 1;
    local x = this.padding.x.double;
    local y = (this.padding.y.double * 0.75) + this.jacketSize;

    if (this.window.isPortrait) then
      x = (this.padding.x.double * 2) + this.jacketSize;
      y = this.padding.y.full - 5;
    end

    for _, name in ipairs(Order) do
      local label = this.info[name];
      local text = this.song[name];

      if (name ~= 'bpm') then text = text:upper(); end

      label:update({ text = text });

      this.labels[name]:draw({ x = x, y = y });

      if ((label.w > this.innerWidth) and this.timers[name]) then
        this.timers[name] = this.timers[name] + dt;

        label:drawScrolling({
          x = x,
          y = y + (this.labels[name].h * 1.35),
          color = 'white',
          scale = this.window:getScale(),
          timer = this.timers[name],
          width = this.innerWidth,
        });
      else
        label:draw({
          x = x,
          y = y + (this.labels[name].h * 1.35),
          color = 'white',
        });
      end

      y = y
        + (this.labels[name].h * 1.35)
        + (label.h * multi)
        + ((this.padding.y.full / 4) * 1.35);
    end
  end,

  -- Draw the lobby control buttons
  ---@param this MpPanel
  drawBtns = function(this)
    local event = function() end;
    local altLabel = nil;
    local isClickable = true;
    local label = '';
    local labelOffset = (this.buttons.med.h * 0.5) - 12;
    local lobby = this.state.lobby;
    local user = this.state.user;
    local topHover = this.mouse:clipped(
      this.btn.x,
      this.btn.y[1],
      this.buttons.med.w,
      this.buttons.med.h
    );
    local botHover = this.mouse:clipped(
      this.btn.x,
      this.btn.y[2],
      this.buttons.med.w,
      this.buttons.med.h
    );
    local x = this.btn.x + 24;

    if (lobby.starting) then
      label = 'starting';

      return;
    else
      if (lobby.host == user.id) then
        if ((not this.song) or (not this.song.self_picked)) then
          event = this.state.selectSong;
          label = 'select';
        elseif (user.ready) then
          if (lobby.ready) then
            event = this.state.startGame;
            label = 'start';
          else
            event = this.state.selectSong;
            altLabel = 'select';
            label = 'notReady';
          end
        else
          event = this.state.readyUp;
          label = 'ready';
        end
      elseif (not lobby.host) then
        isClickable = false;
        label = 'inProgress';
      elseif (lobby.missingSong) then
        isClickable = false;
        label = 'missing';
      elseif (this.song) then
        event = this.state.readyUp;
        label = (user.ready and 'cancel') or 'ready';
      else
        isClickable = false;
        label = 'selecting';
      end
    end

    gfx.Save();

    if (isClickable and topHover) then
      this.state.btnEvent = event;
      label = altLabel or label;
    end

    this.buttons.med:render({
      x = this.btn.x,
      y = this.btn.y[1],
      accentAlpha = (isClickable and topHover and 1) or 0.3,
    });

    this.labels[label]:draw({
      x = x;
      y = this.btn.y[1] + labelOffset,
      alpha = ((isClickable and topHover) and 255) or 150,
      color = 'white',
    });

    if (isClickable and botHover) then
      this.state.btnEvent = mpScreen.OpenSettings;
    end

    this.buttons.med:render({
      x = this.btn.x,
      y = this.btn.y[2],
      accentAlpha = (isClickable and botHover and 1) or 0.3,
    });

    this.labels.settings:draw({
      x = x;
      y = this.btn.y[2] + labelOffset,
      alpha = (botHover and 255) or 150,
      color = 'white',
    });

    gfx.Restore();
  end,

  -- Draw the radio button for a toggle
  ---@param this MpPanel
  ---@param x number
  ---@param y number
  ---@param a number
  ---@param enabled boolean
  ---@param event function
  ---@param isClickable boolean
  drawRadio = function(this, x, y, a, enabled, event, isClickable)
    drawRect({
      x = x,
      y = y,
      w = 24,
      h = 24,
      alpha = 255 * a,
      color = (enabled and { 255, 205, 0 }) or 'dark',
      stroke = {
        alpha = 255 * a,
        color = 'norm',
        size = (enabled and 2) or 1,
      },
    });

    if (isClickable and this.mouse:clipped(x, y, 24, 24)) then
      this.state.btnEvent = event;
    end
  end,

  -- Draw the lobby toggles
  ---@param this MpPanel
  drawToggles = function(this)
    local lobby = this.state.lobby;
    local offset = (this.window.isPortrait and 230) or 124;
    local x = this.x + 1;
    local y = this.window.h - (this.window.h / 40) - 12;

    if (this.window.isPortrait) then
      y = this.y + this.h + (this.window.padding.y / 3);
    end

    gfx.Save();
    
    this:drawRadio(
      x,
      y,
      1,
      lobby.hard,
      this.state.toggleHard,
      not lobby.starting
    );

    this.labels.hard:draw({
      x = x + 32,
      y = y,
      color = 'white',
    });

    x = x + 32 + this.labels.hard.w + offset;

    this:drawRadio(
      x,
      y,
      1,
      lobby.mirror,
      this.state.toggleMirror,
      not lobby.starting
    );

    this.labels.mirror:draw({
      x = x + 32,
      y = y,
      color = 'white',
    });

    x = x + 32 + this.labels.mirror.w + offset;

    this:drawRadio(
      x,
      y,
      1,
      lobby.rotate,
      toggleRotate,
      (not lobby.starting) and (lobby.host == this.state.user.id)
    );

    this.labels.rotate:draw({
      x = x + 32,
      y = y,
      color = 'white',
    });

    gfx.Restore();
  end,

  -- Draw the song panel
  ---@param this MpPanel
  ---@param dt deltaTime
  drawPanel = function(this, dt)
    local x = this.padding.x.double + this.jacketSize + this.padding.x.full + 15;
    local y = this.padding.y.double + this.labels.difficulty.h - 32;
    local yLabel = this.padding.y.full - 5;

    if (this.window.isPortrait) then
      x = this.padding.x.double - 3;
      y = (this.padding.y.full * 2)
        + this.jacketSize
        + this.labels.difficulty.h
        - 7;
      yLabel = (this.padding.y.full * 2) + this.jacketSize - 24;
    end

    drawRect({
      x = this.x,
      y = this.y,
      w = this.w,
      h = this.h,
      alpha = 200,
      color = 'dark',
    });

    gfx.Save();

    gfx.Translate(this.x, this.y);

    if (this.song) then
      this:drawJacket();

      this:drawInfo(dt);

      this.labels.difficulty:draw({
        x = x,
        y = yLabel,
        color = 'norm',
      });

      for i = 1, 4 do
        local currDiff = getDiff(this.song.all_difficulties, i);
        local isCurr = this.song.difficulty == (i - 1);
  
        if (isCurr) then this.cursorIdx = i; end
  
        y = y + this:drawDiff(y, i, currDiff, isCurr);
      end
    end

    gfx.Restore();

    this:drawBtns();
  end,

  -- Reset the scroll timers
  ---@param this MpPanel
  resetTimers = function(this)
    this.timers.artist = 0;
    this.timers.effector = 0;
    this.timers.title = 0;
  end,

  -- Handle song or difficulty changes
  ---@param this MpPanel
  handleChange = function(this)
    if (not selected_song) then return; end

      if (this.song ~= selected_song) then
        game.PlaySample('click_song');

        this:resetTimers();

        this.state.lobby.jacket = nil;

        this.song = selected_song;
      end

      if (this.currDiff ~= selected_song.difficulty) then
        game.PlaySample('click_difficulty');

        this:resetTimers();

        this.currDiff = selected_song.difficulty;
      end
  end,

  -- Renders the current component
  ---@param this MpPanel
  ---@param dt deltaTime
  ---@return number w, number h
  render = function(this, dt)
    this:setSizes();

    this:handleChange();

    gfx.Save();

    this:drawPanel(dt);

    if (this.song) then
      this.cursor:render(dt, { curr = this.cursorIdx, total = 4 });
    end

    this:drawToggles();

    gfx.Restore();
    
    return this.w, this.h;
  end,
};

return MpPanel;