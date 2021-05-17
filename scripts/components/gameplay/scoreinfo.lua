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
      labels = {
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
    local xChain = -((this.labels.maxChain.w * 1.25) + 4);
    local xLabel = -(this.labels.score.w * 1.675) + 2;
    local xMax = 0;

    if (this.window.isPortrait) then
      xLabel = -(this.labels.score.w * 1.1);
      xMax = (this.labels.maxChain.w * 0.45) + 2;
      xChain = xMax - this.labels.maxChain.w - 56;
    end
    
    gfx.Save();

    gfx.Translate(
      this.x + ((this.window.w / 4) * this.state.intro.offset),
      this.y
    );

    this.labels.score:draw({
      x = xLabel,
      y = -(this.val.h * 0.35) + 4,
      align = 'right',
      alpha = alpha,
    });

    this.val:draw({
      x = -(this.window.w / 4.75) + 1,
      align = 'right',
      alpha = alpha,
      offset = 0,
      val = this.state.score,
    });

    gfx.Translate(-3, this.val.h - 6);

    this.labels.maxChain:draw({
      x = xMax,
      align = 'right',
      alpha = alpha,
      color = 'white',
    });

    this.maxChain:draw({
      x = xChain,
      align = 'right',
      alpha = alpha,
      val = this.state.maxChain,
    });

    gfx.Restore();
  end,
};

return ScoreInfo;