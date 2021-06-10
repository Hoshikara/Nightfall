local Colors = {
  RED = 'r',
  GREEN = 'g',
  BLUE = 'b',
  YELLOW = 'y',
};

local abs = math.abs;
local sin = math.sin;

local colL = Colors[getSetting('leftColor', 'BLUE')];
local colR = Colors[getSetting('rightColor', 'RED')];

---@class LaserCursorsClass
local LaserCursors = {
  -- LaserCursors constructor
  ---@param this LaserCursorsClass
  ---@param window Window
  ---@return LaserCursors
  new = function(this, window)
    ---@class LaserCursors : LaserCursorsClass
    ---@field window Window
    local t = {
      tails = {
        Image:new(('gameplay/laser_cursors/tail_%s.png'):format(colL)),
        Image:new(('gameplay/laser_cursors/tail_%s.png'):format(colR)),
      },
      fill = Image:new('gameplay/laser_cursors/fill.png'),
      overlay = Image:new('gameplay/laser_cursors/overlay.png'),
      timer = 0,
      window = window,
    };

    t.h = t.overlay.h * 1.15;

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this LaserCursors
  ---@param dt deltaTime
  render = function(this, dt)
    local scale = this.window:getScale();
    local h = this.h;

    this.timer = this.timer + dt;

    for i, tail in ipairs(this.tails) do
      local curr = gameplay.critLine.cursors[i - 1];
      local r, g, b = game.GetLaserColor(i - 1);

      gfx.SkewX(curr.skew);

      if (gameplay.laserActive[i]) then
        tail:draw({
          x = curr.pos,
          y = 108 * scale,
          blendOp = 8,
          centered = true,
          scale = 0.55 * scale,
        });
      end

      this.fill:draw({
        x = curr.pos,
        h = h,
        alpha = curr.alpha * (0.4 * abs(sin(this.timer * 40))),
        blendOp = 8,
        centered = true;
        scale = 0.425 * scale,
        tint = { r, g, b },
      });

      this.fill:draw({
        x = curr.pos,
        h = h,
        alpha = curr.alpha * 0.6,
        centered = true;
        scale = 0.425 * scale,
        tint = { r, g, b },
      });
  
      this.overlay:draw({
        x = curr.pos,
        h = h,
        alpha = curr.alpha,
        centered = true,
        scale = 0.425 * scale,
      });

      gfx.SkewX(-curr.skew);
    end
  end,
};

return LaserCursors;

