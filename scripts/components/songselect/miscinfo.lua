---@class MiscInfoClass
local MiscInfo = {
  -- MiscInfo constructor
  ---@param this MiscInfoClass
  ---@param window Window
  ---@param state SongWheel
  ---@return MiscInfo
  new = function(this, window, state)
    ---@class MiscInfo : MiscInfoClass
    local t = {
      labels = {
        gameplaySettings = makeLabel(
          'med',
          {
            { color = 'norm', text = '[FX-L] + [FX-R]' },
            { color = 'white', text = 'GAMEPLAY SETTINGS' },
          },
          20
        ),
        infoLoaded = makeLabel('med', 'PLAYER INFO LOADED', 20),
        loadInfo = makeLabel(
          'med',
          {
            { color = 'norm', text = '[BT-A]' },
            { color = 'white', text = 'LOAD PLAYER INFO' },
          },
          20
        ),
        vf = makeLabel('med', 'VF', 20),
        vfVal = makeLabel('num', '0', 20),
      },
      state = state,
      timer = 0,
      window = window,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Handles player info loading
  ---@param this MiscInfo
  ---@param dt deltaTime
  handleChange = function(this, dt)
    if (this.state.infoLoaded) then
      this.timer = 5;

      this.state.infoLoaded = false;
    end

    if (this.timer > 0) then this.timer = to0(this.timer, dt, 1); end
  end,

  -- Renders the current MiscInfo
  ---@param this MiscInfo
  ---@param dt deltaTime
  ---@param w number
  ---@param VF number
  render = function(this, dt, w, VF)
    this:handleChange(dt);

    gfx.Save();

    gfx.Translate(
      (this.window.w / 20) - 1,
      this.window.h - (this.window.h / 40) - 14
    );

    if (this.timer > 0) then
      this.labels.infoLoaded:draw({ color = 'white' });
    else
      this.labels.loadInfo:draw({});
    end

    gfx.Translate(w + 2, 0);

    this.labels.vf:draw({ align = 'right' });

    this.labels.vfVal:draw({
      x = -(this.labels.vf.w + 4),
      align = 'right',
      color = 'white',
      text = ('%.3f'):format(VF),
      update = true,
    });

    gfx.Translate((this.window.w / 20) - 4, 0);

    this.labels.gameplaySettings:draw({});

    gfx.Restore();
  end,
};

return MiscInfo;