---@class NauticaSidebarClass
local NauticaSidebar = {
  -- NauticaSidebar constructor
  ---@param this NauticaSidebarClass
  ---@param window Window
  ---@param state DownloadScreen
  ---@return NauticaSidebar
  new = function(this, window, state)
    ---@class NauticaSidebar : NauticaSidebarClass
    ---@field state DownloadScreen
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      labels = {
        filter = makeLabel(
          'med',
          {
            { color = 'norm', text = '[FX-R]' },
            { color = 'white', text = 'FILTER' },
          },
          20
        ),
        oldest = makeLabel('norm', 'OLDEST'),
        sort = makeLabel(
          'med',
          {
            { color = 'norm', text = '[FX-L]' },
            { color = 'white', text = 'SORT' },
          },
          20
        ),
        uploaded = makeLabel('norm', 'NEWEST'),
      },
      levels = {},
      state = state,
      window = window,
    };

    for i = 1, 20 do t.levels[i] = makeLabel('num', ('%02d'):format(i), 24); end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Draw the current sort
  ---@param this NauticaSidebar
  ---@param y number
  drawSort = function(this, y)
    local x = this.window.padding.x;

    this.labels.sort:draw({ x = x, y = y });

    this.labels[this.state.sort]:draw({
      x = x,
      y = y + (this.labels.sort.h * 1.35),
      color = 'white',
    });

    if (this.window.isPortrait) then return y; end

    return y
      + this.labels.sort.h
      + this.labels[this.state.sort].h
      + this.window.padding.y;
  end,

  -- Draw the current filter
  ---@param this NauticaSidebar
  ---@param y number
  drawFilter = function(this, y)
    local currLevel = this.state.currLevel;
    local filtering = this.state.action == 'FILTERING';
    local filtered = this.state.filtered;
    local isPortrait = this.window.isPortrait;
    local levels = this.state.levels;
    local x = this.window.padding.x * ((isPortrait and 3.5) or 1);
    local xShift = (isPortrait and 1) or 0;
    local yShift = (isPortrait and 0) or 1;
    local xArrow = x - 25;
    local yArrow = y - 3;

    this.labels.filter:draw({ x = x, y = y });

    y = y + (this.labels.filter.h * 1.35);

    for i, level in ipairs(this.levels) do
      local alpha = 100;

      if (filtering or filtered) then
        if (levels[i]) then alpha = 255; end
      elseif (not filtered) then
        alpha = 255;
      end

      level:draw({
        x = x,
        y = y,
        alpha = alpha,
        color = 'white',
      });

      x = x + ((level.w * 1.2825) * xShift);
      y = y + ((level.h * 1.55) * yShift);
    end

    if (filtering) then
      gfx.Save();

      if (isPortrait) then
        gfx.Translate(
          xArrow + ((this.levels[1].w * 1.2825) * currLevel),
          y + this.levels[1].h + 8
        );

        gfx.BeginPath();
        setFill('dark', 125);
        gfx.MoveTo(1, 1);
        gfx.LineTo(-5, 13);
        gfx.LineTo(7, 13);
        gfx.ClosePath();
        gfx.Fill();

        gfx.BeginPath();
        setFill('white');
        gfx.MoveTo(0, 0);
        gfx.LineTo(-6, 12);
        gfx.LineTo(6, 12);
        gfx.ClosePath();
        gfx.Fill();
      else
        gfx.Translate(x - 8, yArrow + ((this.levels[1].h * 1.55) * currLevel));

        gfx.BeginPath();
        setFill('dark', 125);
        gfx.MoveTo(1, 1);
        gfx.LineTo(-11, -5);
        gfx.LineTo(-11, 7);
        gfx.ClosePath();
        gfx.Fill();

        gfx.BeginPath();
        setFill('white');
        gfx.MoveTo(0, 0);
        gfx.LineTo(-12, -6);
        gfx.LineTo(-12, 6);
        gfx.ClosePath();
        gfx.Fill();
      end

      gfx.Restore();
    end
  end,

  -- Renders the current component
  ---@param this NauticaSidebar
  render = function(this)
    local y = this.window.padding.y - 6;

    gfx.Save();

    y = this:drawSort(y);

    this:drawFilter(y);

    gfx.Restore();
  end,
};

return NauticaSidebar;