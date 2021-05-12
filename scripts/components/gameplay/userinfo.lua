---@type string
local scoreDiffPos = getSetting('scoreDiffPos', 'LEFT');
---@type boolean
local showScoreDiff = getSetting('showScoreDiff', false);
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
      diff = {
        large = {
          makeLabel('num', '0', 50),
          makeLabel('num', '0', 50),
          makeLabel('num', '0', 50),
        },
        small = makeLabel('num', '0', 40),
      },
      isAdditive = nil,
      labels = {
        player = makeLabel('med', 'PLAYER'),
        scoreDifference = makeLabel('med', 'SCORE DIFFERENCE'),
      },
      player = makeLabel(
        'norm',
        (gameplay.autoplay and 'AUTOPLAY') or username:upper(),
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
      local w = this.diff.large[1].w * 0.85;

      this.x.base = this.window.w / 80;
      this.y.base = this.window.h / 2.375;

      if (scoreDiffPos == 'LEFT') then
        this.x.diff = 91;
        this.y.diff = 0;
      else
        this.x.diff = (this.window.w / 2) - this.x.base;
        this.y.diff = (this.window.h / 2) - this.y.base;

        if (scoreDiffPos == 'TOP') then
          this.y.diff = this.y.diff - (this.window.h * 0.35);
        elseif (scoreDiffPos == 'MIDDLE') then
          this.y.diff = this.y.diff + (this.window.h * 0.165);
        elseif (scoreDiffPos == 'BOTTOM') then
          this.y.diff = this.y.diff + (this.window.h * 0.35);
        end
      end

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
  ---@param y number
  ---@param alpha number
  drawScoreDiff = function(this, y, alpha)
    y = ((scoreDiffPos == 'LEFT') and y) or this.y.diff;

    local abs = 0;
    local diff = 0;
    local prefix = 'plus';

    if (this.isAdditive) then
      diff = this.state.score - gameplay.scoreReplays[1].currentScore;
    else
      diff = this.state.score - gameplay.scoreReplays[1].maxScore;
    end

    if (diff < 0) then prefix = 'minus'; end

    abs = math.abs(diff);

    local diffStr = ('%08d'):format(abs);
    local numAlpha = {
      (((abs > 1000000) and 255) or 50),
      (((abs > 100000) and 255) or 50),
      (((abs > 10000) and 255) or 50),
      (((abs > 1000) and 255) or 50)
    };

    if (diff ~= 0) then
      this.prefixes[prefix]:draw({
        x = this.x.prefix,
        y = y + (((prefix == 'plus') and 0) or -5),
        align = 'middle',
        alpha = alpha,
        color = ((prefix == 'plus') and 'white') or 'red',
      });
    end

    for i = 1, 3 do
      this.diff.large[i]:draw({
        x = this.x.num[i],
        y = y,
        align = 'middle',
        alpha = numAlpha[i],
        color = 'white',
        text = diffStr:sub(i + 1, i + 1),
        update = true,
      });
    end

    this.diff.small:draw({
      x = this.x.num[4],
      y = y + 4.5,
      align = 'middle',
      alpha = numAlpha[4],
      color = ((prefix == 'plus') and 'norm') or 'red',
      text = diffStr:sub(5, 5),
      update = true,
    });
  end,

  -- Renders the current component
  ---@param this UserInfo
  render = function(this)
    if (this.isAdditive == nil) then
      this.isAdditive = getSetting('_scoreType', 'ADDITIVE') == 'ADDITIVE';
    end

    this:setSizes();

    local alpha = this.state.intro.alpha;
    local y = 0;

    gfx.Save();

    gfx.Translate(
      this.x.base - ((this.window.w / 40) * this.state.intro.offset),
      this.y.base
    );

    this.labels.player:draw({ y = y, alpha = alpha });

    y = y + (this.labels.player.h * 1.125);

    this.player:draw({
      y = y,
      color = 'white',
      alpha = alpha,
    });

    y = y + (this.player.h * 1.75);

    if (showScoreDiff and gameplay.scoreReplays[1]) then
      if (scoreDiffPos == 'LEFT') then
        this.labels.scoreDifference:draw({ y = y, alpha = alpha });

        y = y + (this.labels.scoreDifference.h * 2.5);
      end

      this:drawScoreDiff(y, alpha);
    end

    gfx.Restore();
  end,
};

return UserInfo;