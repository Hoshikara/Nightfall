game.LoadSkinSample('click_difficulty');
game.LoadSkinSample('click_song');

local JSON = require('lib/json');

local Difficulties = require('constants/difficulties');
local Labels = require('constants/songwheel');

local Cursor = require('components/common/cursor');

local Order = {
  'title',
  'artist',
  'effector',
  'bpm',
};

local fallback = gfx.CreateSkinImage('common/loading.png', 0);

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

---@class PanelClass
local Panel = {
  -- Panel constructor
  ---@param this PanelClass
  ---@param window Window
  ---@param mouse Mouse
  ---@param state Multiplayer
  ---@param constants table
  ---@return Panel
  new = function(this, window, mouse, state, constants)
    ---@class Panel : PanelClass
    ---@field window Window
    local t = {
      btn = { x = 0, y = {} },
      cache = { w = 0, h = 0 },
      currDiff = 1,
      cursor = Cursor:new({
        size = 12,
        stroke = 1.5,
        type = 'vertical',
      }),
      cursorIdx = 0,
      diffs = {},
      images = {
        btn = Image:new('buttons/short.png'),
        btnH = Image:new('buttons/short_hover.png'),
        btnMed = Image:new('buttons/medium.png'),
        btnMedH = Image:new('buttons/medium_hover.png'),
        panel = Image:new('common/panel.png'),
      },
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
  ---@param this Panel
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.jacketSize = this.window.w / 5;

      this.w = this.window.w / (1920 / this.images.panel.w);
      this.h = this.window.h - (this.window.h / 10);
      this.x = this.window.w / 20;
      this.y = this.window.h / 20;
      this.middle = this.w / 2;

      this.padding.x.full = this.w / 20;
      this.padding.x.double = this.padding.x.full * 2;

      this.padding.y.full = this.h / 20;
      this.padding.y.double = this.padding.y.full * 2;

      this.innerWidth = this.w - (this.padding.x.double * 2);

      this.btn.x = this.x + this.padding.x.double - 4;
      this.btn.y[1] = this.y + this.h - (this.padding.y.double * 2.5) + 24;
      this.btn.y[2] = this.btn.y[1] + (this.images.btn.h * 1.5);

      this.cursor:setSizes({
        x = this.x
          + this.padding.x.double
          + this.jacketSize
          + this.padding.x.full
          + 8,
        y = this.y
          + this.padding.y.double
          + this.labels.difficulty.h
          - 20,
        w = this.images.btn.w - 8,
        h = this.images.btn.h - 8,
        margin = (this.images.btn.h / 2.5) + 8,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the chart jacket
  ---@param this Panel
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
  ---@param this Panel
  ---@param y number
  ---@param diff table
  ---@param isCurr boolean
  drawDiff = function(this, y, i, diff, isCurr)
    local x = this.padding.x.double + this.jacketSize + this.padding.x.full + 4;

    if (isCurr) then
      this.images.btnH:draw({ x = x, y = y });
    else
      this.images.btn:draw({
        x = x,
        y = y,
        alpha = 0.45,
      });
    end

    if (diff) then
      local j = getDiffIndex(diff.jacketPath, diff.difficulty);

      this.diffs[j]:draw({
        x = x + (this.images.btn.w / 7),
        y = y + (this.images.btn.h / 2) - 12,
        alpha = 255 * ((isCurr and 1) or 0.2),
        color = 'white',
      });

      this.levels[i]:draw({
        x = x + this.images.btn.w - (this.images.btn.w / 7),
        y = y + (this.images.btn.h / 2) - 12,
        align = 'right',
        alpha = 255 * ((isCurr and 1) or 0.2),
        color = 'white',
        text = ('%02d'):format(diff.level),
        update = true,
      });
    end

    return this.images.btn.h + (this.images.btn.h / 2.5);
  end,

  -- Draw the chart info
  ---@param this Panel
  ---@param dt deltaTime
  drawInfo = function(this, dt)
    local x = this.padding.x.double;
    local y = (this.padding.y.double * 0.75) + this.jacketSize;

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
        + label.h
        + ((this.padding.y.full / 4) * 1.35);
    end
  end,

  -- Draw the lobby control buttons
  ---@param this Panel
  drawBtns = function(this)
    local event = function() end;
    local isClickable = true;
    local label = '';
    local labelOffset = (this.images.btnMed.h / 2) - 12;
    local lobby = this.state.lobby;
    local user = this.state.user;
    local topHover = this.mouse:clipped(
      this.btn.x,
      this.btn.y[1],
      this.images.btnMed.w,
      this.images.btnMed.h
    );
    local botHover = this.mouse:clipped(
      this.btn.x,
      this.btn.y[2],
      this.images.btnMed.w,
      this.images.btnMed.h
    );
    local x = this.btn.x + (this.images.btnMed.w / 10);

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

      this.images.btnMedH:draw({ x = this.btn.x, y = this.btn.y[1] });
    else
      this.images.btnMed:draw({
        x = this.btn.x,
        y = this.btn.y[1],
        alpha = 0.75,
      });
    end

    this.labels[label]:draw({
      x = x;
      y = this.btn.y[1] + labelOffset,
      alpha = ((isClickable and topHover) and 255) or 150,
      color = 'white',
    });

    if (isClickable and botHover) then
      this.state.btnEvent = mpScreen.OpenSettings;

      this.images.btnMedH:draw({ x = this.btn.x, y = this.btn.y[2] });
    else
      this.images.btnMed:draw({
        x = this.btn.x,
        y = this.btn.y[2],
        alpha = 0.75,
      });
    end

    this.labels.settings:draw({
      x = x;
      y = this.btn.y[2] + labelOffset,
      alpha = (botHover and 255) or 150,
      color = 'white',
    });

    gfx.Restore();
  end,

  -- Draw the radio button for a toggle
  ---@param this Panel
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
      color = (enabled and { 255, 205, 0}) or 'dark',
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
  ---@param this Panel
  drawToggles = function(this)
    local lobby = this.state.lobby;
    local x = this.x + 1;
    local y = this.window.h - (this.window.h / 40) - 12;

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

    x = x + 32 + this.labels.hard.w + 124;

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

    x = x + 32 + this.labels.mirror.w + 124;

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
  ---@param this Panel
  ---@param dt deltaTime
  drawPanel = function(this, dt)
    local y = this.padding.y.double + this.labels.difficulty.h - 24;

    this.images.panel:draw({
      x = this.x,
      y = this.y,
      w = this.w,
      h = this.h,
      alpha = 0.5,
    });

    gfx.Save();

    gfx.Translate(this.x, this.y);

    if (this.song) then
      this:drawJacket();

      this:drawInfo(dt);

      this.labels.difficulty:draw({
        x = this.padding.x.double
          + this.jacketSize
          + this.padding.x.full
          + 7,
        y = this.padding.y.full - 5,
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
  ---@param this Panel
  resetTimers = function(this)
    this.timers.artist = 0;
    this.timers.effector = 0;
    this.timers.title = 0;
  end,

  -- Handle song or difficulty changes
  ---@param this Panel
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
  ---@param this Panel
  ---@param dt deltaTime
  ---@return number
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
    
    return this.w;
  end,
};

return Panel;