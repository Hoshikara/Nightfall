local ScoreNumber = require('components/common/scorenumber');

---@class ScoreInfoClass
local ScoreInfo = {
  -- ScoreInfo constructor
  ---@param this ScoreInfoClass
  ---@param window Window
  ---@param state Gameplay
  ---@return ScoreInfo
  new = function(this, window, state)
    ---@class ScoreInfo : ScoreInfoClass
    ---@field state Gameplay
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      exScore = ScoreNumber:new({ digits = 5, size = 24 }),
      labels = {
        exScore = makeLabel('norm', 'EX'),
        maxChain = makeLabel('norm', 'MAXIMUM CHAIN'),
        score = makeLabel('norm', 'SCORE', 48),
      },
      maxChain = ScoreNumber:new({ digits = 4, size = 24 }),
      state = state,
      val = ScoreNumber:new({ size = 100 }),
      window = window,
      x = 0,
      y = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ScoreInfo
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.x = this.window.w - (this.window.w / 9) - 5;
        this.y = this.window.h / 5;

        this.labels.score = makeLabel('norm', 'SCORE', 36);
        this.val = ScoreNumber:new({ size = 80 });
      else
        this.x = this.window.w - (this.window.w / 36);
        this.y = this.window.h / 14;

        this.labels.score = makeLabel('norm', 'SCORE', 48);
        this.val = ScoreNumber:new({ size = 100 });
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Renders the current component
  ---@param this ScoreInfo
  render = function(this)
    this:setSizes();

    local alpha = this.state.intro.alpha;
    local isPortrait = this.window.isPortrait;
    
    gfx.Save();

    gfx.Translate(
      this.x + ((this.window.w / 4) * this.state.intro.offset),
      this.y
    );

    this.labels.score:draw({
      x = (isPortrait and -144) or -289,
      y = (isPortrait and -29) or -37,
      align = 'right',
      alpha = alpha,
    });

    this.val:draw({
      x = (isPortrait and -226) or -403,
      align = 'right',
      alpha = alpha,
      offset = 0,
      val = this.state.score,
    });

    this.labels.exScore:draw({
      x = (isPortrait and 5) or -93,
      y = y,
      align = 'right',
      alpha = alpha,
    });

    this.exScore:draw({
      x = (isPortrait and 31) or -67,
      y = y,
      align = 'right',
      alpha = alpha,
      color = 'white',
      val = this.state.exScore,
    });

    gfx.Translate(-3, this.val.h - 6);

    this.labels.maxChain:draw({
      x = (isPortrait and 98) or 0,
      align = 'right',
      alpha = alpha,
      color = 'white',
    });

    this.maxChain:draw({
      x = (isPortrait and -171) or -269,
      align = 'right',
      alpha = alpha,
      val = this.state.maxChain,
    });

    gfx.Restore();
  end,
};

return ScoreInfo;