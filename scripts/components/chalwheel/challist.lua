local Cursor = require('components/common/cursor');
local List = require('components/common/list');
local ScoreNumber = require('components/common/scorenumber');
local Scrollbar = require('components/common/scrollbar');

---@class ChalListClass
local ChalList = {
  -- ChalList constructor
  ---@param this ChalListClass
  ---@param window Window
  ---@param state ChalWheel
  ---@param chals ChalCache
  ---@return ChalList
  new = function(this, window, state, chals)
    ---@class ChalList : ChalListClass
    ---@field chals ChalCache
    ---@field state ChalWheel
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      chals = chals,
      cursor = Cursor:new({
        size = 16,
        stroke = 1.5,
        type = 'vertical',
      });
      labels = {
        challenge = makeLabel('med', 'CHALLENGE'),
        currChal = ScoreNumber:new({ digits = 4, size = 18 }),
        gameplaySettings = makeLabel(
          'med',
          {
            { color = 'norm', text = '[FX-L] + [FX-R]' },
            { color = 'white', text = 'GAMEPLAY SETTINGS' },
          },
          20
        ),
        noneFound = makeLabel('norm', 'NO CHALLENGES FOUND', 48),
        of = makeLabel('med', 'OF'),
        totalChals = ScoreNumber:new({ digits = 4, size = 18 }),
      },
      list = List:new(),
      margin = 0,
      scrollbar = Scrollbar:new(),
      state = state,
      window = window,
      x = 0,
      y = 0,
      w = { list = 0, max = 0 },
      h = { item = 0, list = 0 },
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ChalList
  ---@param w number
  ---@param h number
  setSizes = function(this, w, h)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.w.list = this.window.w - (this.window.padding.x * 2);
      else
        this.w.list = this.window.w - ((this.window.padding.x) * 3) - w;
      end

      if (this.window.isPortrait) then
        this.w.max = this.w.list - (this.w.list / 16);

        this.h.list = math.floor(this.w.list * 0.65);
        this.h.item = this.h.list // 5;

        this.x = this.window.padding.x;
        this.y = this.window.padding.y + h + (this.window.padding.y * 3);

        this.state.max = 4;
      else
        this.w.max = this.w.list - (this.w.list / 10);

        this.h.list = math.floor(this.w.list * 1.125);
        this.h.item = this.h.list // 7.5;

        this.x = (this.window.padding.x * 2) + w;
        this.y = this.window.h - this.window.padding.y - this.h.list;

        this.state.max = 6;
      end

      this.margin = (this.h.list - (this.h.item * this.state.max))
        / (this.state.max - 1);

      this.cursor:setSizes({
        x = this.x,
        y = this.y,
        w = this.w.list,
        h = this.h.item,
        margin = this.margin,
      });

      this.list:setSizes({
        max = this.state.max,
        shift = this.h.list + this.margin,
      });

      this.scrollbar:setSizes({
        x = this.window.w - (this.window.w / 40) - 4,
        y = this.y,
        h = this.h.list,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draws the list of challenges
  ---@param this ChalList
  ---@param dt deltaTime
  drawList = function(this, dt)
    local currChal = this.state.currChal;
    local y = 0;

    gfx.Save();

    gfx.Translate(this.x, this.y + this.list.offset);

    for i, chal in ipairs(chalwheel.challenges) do
      y = y + this:drawChal(
        dt,
        y,
        this.chals:get(chal),
        i == currChal,
        this.list:onPage(i)
      );
    end

    gfx.Restore();
  end,

  -- Draws a challange in the list
  ---@param this ChalList
  ---@param dt deltaTime
  ---@param y number
  ---@param chal CachedChal
  ---@param isCurr boolean
  ---@param onPage boolean
  ---@return number
  drawChal = function(this, dt, y, chal, isCurr, onPage)
    local alpha = (isCurr and 255) or 80;
    local x = this.w.list / 20;

    if (this.window.isPortrait) then x = this.w.list / 32; end

    if (not onPage) then
      chal.timer = 0;
    else
      drawRect({
        x = 0,
        y = y,
        w = this.w.list,
        h = this.h.item,
        alpha = 200,
        color = 'dark',
      });
      
      y = y + (this.h.item / 5);

      this.labels.challenge:draw({
        x = x,
        y = y,
        alpha = alpha,
      });

      y = y + (this.labels.challenge.h * 1.25);

      if (chal.title.w > this.w.max) then
        if (isCurr) then
          chal.timer = chal.timer + dt;
        else
          chal.timer = 0;
        end

        chal.title:drawScrolling({
          x = x,
          y = y,
          alpha = alpha,
          color = 'white',
          scale = this.window:getScale(),
          timer = chal.timer,
          width = this.w.max,
        });
      else
        chal.title:draw({
          x = x,
          y = y,
          alpha = alpha,
          color = 'white',
        });
      end
    end

    return this.h.item + this.margin;
  end,

  -- Draws the current chal and total amount of chals
  ---@param this ChalList
  drawAmounts = function(this)
    gfx.Save();

    gfx.Translate(
      this.window.w - (this.window.w / 40) + 16,
      this.window.h - (this.window.h / 40) - 12
    );

    this.labels.currChal:draw({
      x = -(this.labels.of.w + (this.labels.totalChals.w * 2) + 24),
      y = 0,
      align = 'right',
      val = this.state.currChal,
    });

    this.labels.of:draw({
      x = -((this.labels.totalChals.w * 1.25) + 12),
      y = 0,
      align = 'right',
    });

    this.labels.totalChals:draw({
      x = -(this.labels.totalChals.w),
      y = 0,
      align = 'right',
      val = #chalwheel.challenges,
    });

    gfx.Restore();
  end,

  -- Renders the current component
  ---@param this ChalList
  ---@param dt deltaTime
  ---@param w number
  ---@param h number
  render = function(this, dt, w, h)
    this:setSizes(w, h);

    gfx.Save();

    if (#chalwheel.challenges > 0) then
      this.list:handleChange(dt, { watch = this.state.currChal });

      this:drawList(dt);
      
      this.cursor:render(dt, {
        curr = this.state.currChal,
        total = this.state.max,
      });

      if (#chalwheel.challenges > this.state.max) then
        this.scrollbar:render(dt, {
          curr = this.state.currChal,
          total = #chalwheel.challenges
        });
      end

      this:drawAmounts();
    else
      this.labels.noneFound:draw({
        x = this.x + (this.w.list / 2),
        y = this.y + (this.h.list / 2),
        align = 'middle',
        color = 'white',
      });
    end
    
    this.labels.gameplaySettings:draw({
      x = this.x - 2,
      y = this.window.h - (this.window.h / 40) - 14,
    });

    gfx.Restore();
  end,
};

return ChalList;