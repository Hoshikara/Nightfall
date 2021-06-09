local abs = math.abs;
local sin = math.sin;

---@class ConsoleClass
local Console = {
  -- Console constructor
  ---@param this ConsoleClass
  ---@param state Gameplay
  ---@param window Window
  ---@return Console
  new = function(this, window, state)
    ---@class Console : ConsoleClass
    ---@field window Window
    ---@field state Gameplay
    local t = {
      btns = {},
      console = Image:new('gameplay/console/console.png'),
      knobs = {},
      state = state,
      window = window,
    };

    for i = 1, 6 do
      t.btns[i] = {
        img = Image:new(('gameplay/console/btn_%d.png'):format(i)),
        timer = 0,
      };
    end

    for i = 1, 2 do
      local side = ((i == 1) and 'l') or 'r';

      t.knobs[i] = {
        alert = Image:new(('gameplay/console/knob_%s.png'):format(side)),
        alertTimer = 0,
        ring = Image:new(('gameplay/console/ring_%s.png'):format(side)),
        ringTimer = 0,
      };
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Renders the current component
  ---@param this Console
  ---@param dt deltaTime
  render = function(this, dt)
    local center = this.window.resX / 2;
    local y = this.console.h * 0.5;

    gfx.Save();

    gfx.Translate((center - gameplay.critLine.x) * (5 / 6), 0);

    this.window:scale();

    this.console:draw({ y = y, centered = true });

    for i, btn in ipairs(this.btns) do
      if (game.GetButton(i - 1)) then
        btn.timer = btn.timer + dt * 10 * 3.14 * 2;
      else
        btn.timer = 0;
      end

      if (btn.timer ~= 0) then
        btn.img:draw({
          y = y,
          alpha = ((sin(btn.timer) * 0.5) + 0.5) * 0.5 + 0.1,
          blendOp = 8,
          centered = true,
        });
      end
    end

    for i, knob in ipairs(this.knobs) do
      local active = gameplay.laserActive[i];
      local left = i == 1;

      if ((this.state.timers.alerts[i] > -1.5) and (not active)) then
        knob.alertTimer = knob.alertTimer + dt;
      else
        knob.alertTimer = 0;
      end

      gfx.Save();

      gfx.Translate((left and -488) or 350, 16);

      if (knob.alertTimer ~= 0) then
        knob.alert:draw({
          alpha = 0.2 + (0.4 * abs(sin(knob.alertTimer * 28))),
          blendOp = 8,
        });
      end

      gfx.Translate((left and 64) or 74, 40);

      if (active) then
        knob.ringTimer = knob.ringTimer + (dt * 100);

        knob.ring:draw({
          alpha = 0.4,
          blendOp = 8,
          centered = true,
          scale = 0.5 + (0.5 * (knob.ringTimer / 12) % 1),
        });
      end

      gfx.Restore();
    end

    gfx.Restore();
  end,
};

return Console;