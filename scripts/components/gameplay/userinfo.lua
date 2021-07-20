local scoreDiffX = getSetting('scoreDiffX', 0.05);
local scoreDiffY = getSetting('scoreDiffY', 0.50);
local scoreDiffDelay = getSetting('scoreDiffDelay', 0.05);
local showScoreDiff = getSetting('showScoreDiff', true);

---@type string
local username = getSetting('displayName', 'GUEST');

---@class UserInfoClass
local UserInfo = {
  -- UserInfo constructor
  ---@param this UserInfoClass
  ---@param window Window
  ---@param state Gameplay
  ---@return UserInfo
  new = function(this, window, state)
    ---@class UserInfo : UserInfoClass
    ---@field state Gameplay
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      delayTimer = 0,
      diff = 0,
      num = {
        makeLabel('num', '0', 50),
        makeLabel('num', '0', 50),
        makeLabel('num', '0', 50),
        makeLabel('num', '0', 40),
      },
      isAdditive = nil,
      labels = {
        player = makeLabel('med', 'PLAYER'),
      },
      player = makeLabel(
        'norm',
        (gameplay.autoplay and 'AUTOPLAY') or username:upper():sub(1, 9),
        36
      ),
      prefixes = {
        minus = makeLabel('num', '-', 46),
        plus = makeLabel('num', '+', 36),
      },
      state = state,
      timer = 0,
      window = window,
      x = {
        base = 0,
        diff = 0,
        num = {},
        prefix = 0,
      },
      y = { base = 0, diff = 0 },
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this UserInfo
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local w = this.num[1].w * 0.85;

      this.x.base = this.window.w / 80;

      if (this.window.isPortrait) then
        this.y.base = this.window.h / 2.75;
        this.y.diff = ((this.window.h * 0.625) * scoreDiffY)
          + (this.window.h * 0.125);
      else
        this.y.base = this.window.h / 2.375;
        this.y.diff = this.window.h * scoreDiffY;
      end

      this.x.diff = (this.window.w * scoreDiffX) - this.x.base;

      this.x.num[1] = this.x.diff - (w * 1.75);
      this.x.num[2] = this.x.diff - (w * 0.6);
      this.x.num[3] = this.x.diff + (w * 0.6);
      this.x.num[4] = this.x.diff + (w * 1.75);

      this.x.prefix = this.x.diff - (w * 2.95);

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the score difference
  ---@param this UserInfo
  ---@param dt deltaTime
  ---@param alpha number
  drawScoreDiff = function(this, dt, alpha)
    local abs = 0;
    local prefix = 'plus';
    local y = this.y.diff;

    if ((this.delayTimer >= scoreDiffDelay) or (gameplay.progress == 1)) then
      if (this.isAdditive) then
        this.diff = this.state.score - gameplay.scoreReplays[1].currentScore;
      else
        this.diff = this.state.score - gameplay.scoreReplays[1].maxScore;
      end

      this.delayTimer = 0;
    else
      this.delayTimer = this.delayTimer + dt;
    end

    if (this.diff < 0) then prefix = 'minus'; end

    abs = math.abs(this.diff);

    local diffStr = ('%08d'):format(abs);
    local numAlpha = {
      (((abs > 1000000) and 255) or 50),
      (((abs > 100000) and 255) or 50),
      (((abs > 10000) and 255) or 50),
      (((abs > 1000) and 255) or 50)
    };

    if (this.diff ~= 0) then
      this.prefixes[prefix]:draw({
        x = this.x.prefix,
        y = y + (((prefix == 'plus') and 0) or -5),
        align = 'middle',
        alpha = alpha,
        color = ((prefix == 'plus') and 'white') or 'neg',
      });
    end

    for i, num in ipairs(this.num) do
      local offset = ((i > 3) and 4.5) or 0;
      local color = ((i < 4) and 'white')
        or (((prefix == 'plus') and 'pos') or 'neg');

      num:draw({
        x = this.x.num[i],
        y = y + offset,
        align = 'middle',
        alpha = numAlpha[i],
        color = color,
        text = diffStr:sub(i + 1, i + 1),
        update = true,
      });
    end
  end,

  -- Renders the current component
  ---@param this UserInfo
  ---@param dt deltaTime
  render = function(this, dt)
    if (this.isAdditive == nil) then
      this.isAdditive = getSetting('_scoreType', 'ADDITIVE') == 'ADDITIVE';
    end

    this:setSizes();

    local alpha = this.state.intro.alpha;
    local y = this.y.base;

    gfx.Save();

    gfx.Translate(
      this.x.base - ((this.window.w / 40) * this.state.intro.offset),
      0
    );

    this.labels.player:draw({ y = y, alpha = alpha });

    y = y + (this.labels.player.h * 1.125);

    this.player:draw({
      y = y,
      color = 'white',
      alpha = alpha,
    });

    if (showScoreDiff and gameplay.scoreReplays[1]) then
      this:drawScoreDiff(dt, alpha);
    end

    gfx.Restore();
  end,
};

return UserInfo;