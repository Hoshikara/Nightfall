local floor = math.floor;
local min = math.min;

---@class BackgroundClass
local Background = {
  -- Background constructor
  ---@param this BackgroundClass
  ---@param window Window
  ---@return Background
  new = function(this, window)
    ---@class Background : BackgroundClass
    ---@field window Window
    local t = {
      bg = Image:new('bg.png'),
      bgPortrait = Image:new('bg_p.png'),
      blue = 0,
      red = 0,
      green = 0,
      window = window or {
        isPortrait = false,
        w = 0,
        h = 0,
      },
      r = 0,
      g = 0,
      b = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this Background
  ---@param p BackgroundRenderParams
  render = function(this, p)
    p = p or {};

    local r, g, b, _ = game.GetSkinSetting('colorScheme');

    if ((r ~= this.red) or (g ~= this.green) or (b ~= this.blue)) then
      this.r = min(floor((r or 0) * 1.25), 255);
      this.g = min(floor((g or 0) * 1.25), 255);
      this.b = min(floor((b or 0) * 1.25), 255);

      this.red = r;
      this.green = g;
      this.blue = b;
    end

    ((this.window.isPortrait and this.bgPortrait) or this.bg):draw({
      x = p.x or 0,
      y = p.y or 0,
      w = p.w or this.window.w,
      h = p.h or this.window.h,
      centered = p.centered,
      tint = { this.r, this.g, this.b },
    });
  end,
};

return Background;