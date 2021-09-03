local ChainColors = {};

local floor = math.floor;

local getColor = function(key)
  local r, g, b, _ = game.GetSkinSetting(key);

  return {
    r or 0,
    g or 0,
    b or 0,
  };
end

ChainColors[0] = getColor('normChainColor');
ChainColors[1] = getColor('UCChainColor');
ChainColors[2] = getColor('PUCChainColor');

-- Gets alpha for chain digits
---@param chain integer
---@param i integer
---@return integer
local getAlpha = function(chain, i)
  if (chain >= (10 ^ (4 - i))) then return 255; end

  return 50;
end

---@class ChainClass
local Chain = {
  -- Chain constructor
  ---@param this ChainClass
  ---@param window Window
  ---@param state Gameplay
  ---@return Chain
  new = function(this, window, state)
    ---@class Chain : ChainClass
    ---@param state Gameplay
    ---@param window Window
    local t = {
      alpha = 0,
      burst = false,
      burstVal = 100,
      cache = { w = 0, h = 0 },
      labels = {
        burst = {},
        chain = makeLabel('med', 'CHAIN', 22),
      },
      scale = 1,
      state = state,
      timer = 0,
      window = window,
      x = {},
      y = 0,
    };

    for i = 1, 4 do
      t.labels[i] = makeLabel('num', '0', 64);
      t.labels.burst[i] = makeLabel('num', '0', 64);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Chain
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      local x = this.window.w / 2;
      local w = this.labels[1].w * 0.85;

      this.x[1] = x - (w * 2);
      this.x[2] = x - (w * 0.675);
      this.x[3] = x + (w * 0.675);
      this.x[4] = x + (w * 2);
      
      if (this.window.isPortrait) then
        this.y = this.window.h - (this.window.h / 2.65);
      else
        this.y = (this.window.h * 0.95) - (this.window.h / 6);
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Renders the current component
  ---@param this Chain
  ---@param dt deltaTime
  render = function(this, dt)
    this.state.timers.chain = to0(this.state.timers.chain, dt, 1);

    if (this.state.timers.chain == 0) then return end

    this:setSizes();

    local chain = this.state.chain;
    local color = ChainColors[gameplay.comboState];

    this.labels.chain:draw({
      x = this.window.w / 2,
      y = this.y - (this.labels.chain.h * 2.25),
      align = 'middle',
      color = color,
    });

    for i = 1, 4 do
      this.labels[i]:draw({
        x = this.x[i],
        y = this.y,
        align = 'middle',
        alpha = getAlpha(chain, i),
        color = color,
        text = floor(chain / (10 ^ (4 - i)) % 10),
        update = true,
      });
    end

    if (gameplay.comboState > 0) then
      if (chain >= this.burstVal) then
        this.burstVal = this.burstVal + 100;

        if (not this.burst) then this.alpha = 1; end

        this.burst = true;
      end

      if (chain < 100) then this.burstVal = 100; end

      if (this.burst and (this.scale < 3)) then
        this.alpha = to0(this.alpha, dt, 0.2);
        this.scale = this.scale + (dt * 6);
      else
        this.alpha = 0;
        this.burst = false;
        this.scale = 1;
      end

      local alpha = 255 * this.alpha;
      local scale = this.scale * 20;
      local size = floor(64 * this.scale);

      for i = 1, 4 do
        this.labels.burst[i]:draw({
          x = this.x[i] - ((2.5 - i) * scale),
          y = this.y,
          align = 'middle',
          alpha = alpha,
          color = color,
          size = size,
          text = floor(chain / (10 ^ (4 - i)) % 10),
          update = true,
        });
      end
    end
  end,
};

return Chain;