local floor = math.floor;
local min = math.min;

---@class SearchBarClass
local SearchBar = {
  -- SearchBar constructor
  ---@param this SearchBarClass
  ---@return SearchBar
  new = function(this)
    ---@class SearchBar : SearchBarClass
    local t = {
      labels = {
        input = makeLabel('jp', '', 24),
        search = makeLabel(
          'med',
          {
            { color = 'norm', text = '[TAB]' },
            { color = 'white', text = 'SEARCH' },
          }
        ),
      },
      timers = { cursor = 0, fade = 0 },
      x = 0,
      y = 0,
      w = 0,
      h = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this SearchBar
  ---@param params table #
  -- ```
  -- {
  --   x: number = 0,
  --   y: number = 0,
  --   w: number = 0,
  --   h: number = 0,
  -- }
  -- ```
  setSizes = function(this, params)
    this.x = params.x or 0;
    this.y = params.y or 0;
    this.w = params.w or 0;
    this.h = params.h or 0;
  end,

  -- Renders the current component
  ---@param this SearchBar
  ---@param dt deltaTime
  ---@param params table #
  -- ```
  -- {
  --   input: string = '',
  --   isActive: boolean = false,
  -- }
  -- ```
  render = function(this, dt, params)
    local input = params.input or '';
    local isActive = params.isActive or false;
    local shouldShow = (input:len() > 0) or isActive;

    if (shouldShow) then
      this.timers.cursor = this.timers.cursor + dt;
      this.timers.fade = to1(this.timers.fade, dt, 0.17);
    elseif ((not shouldShow) and (this.timers.fade > 0)) then
      this.timers.cursor = 0;
      this.timers.fade = to0(this.timers.fade, dt, 0.17);
    end

    local alpha = floor(255 * min(this.timers.fade * 2, 1));
    local cursorAlpha = 0;

    if (isActive) then cursorAlpha = pulse(this.timers.cursor, 1, 0.2); end

    local cursorOffset = min(this.labels.input.w + 2, this.w - 24);

    gfx.Save();

    drawRect({
      x = this.x + 2,
      y = this.y - 6,
      w = (this.w - 3) * this.timers.fade,
      h = this.h + 12,
      color = 'dark',
      fast = true,
    });

    if (isActive) then
      drawRect({
        x = this.x + 2,
        y = this.y - 6,
        w = (this.w - 3) * this.timers.fade,
        h = this.h + 12,
        alpha = 0,
        color = 'black',
        stroke = {
          alpha = alpha,
          color = 'norm',
          size = 2,
        },
      });
    end

    this.labels.search:draw({ x = this.x + 7, y = this.y - 4 });

    if (shouldShow) then
      drawRect({
        x = this.x + 8 + cursorOffset,
        y = this.y + (this.h / 2) - 3,
        w = 2,
        h = 28,
        alpha = 255 * cursorAlpha,
        color = 'white',
        fast = true,
      });

      this.labels.input:draw({
        x = this.x + 8,
        y = this.y + 20,
        color = 'white',
        maxWidth = this.w - 24,
        text = input:upper(),
        update = true,
      });
    end

    gfx.Restore();
  end,
};

return SearchBar;