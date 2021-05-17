---@class GridClass
local Grid = {
  -- Grid constructor
  ---@param this GridClass
  ---@param window Window
  ---@param isSongSelect boolean
  ---@return Grid
  new = function(this, window, isSongSelect)
    ---@class Grid : GridClass
    local t = {
      cache = { w = 0, h = 0 },
      dropdown = {
        maxWidth = 0,
        padding = 24,
        start = 0,
        x = {},
        y = 0,
      },
      field = {
        maxWidth = 0,
        x = {},
        y = 0,
        h = 0,
      },
      grade = { w = 0, h = 0 },
      label = makeLabel('norm', 'TEXT'),
      jacketSize = 0,
      margin = 0,
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = 0,
    };

    if (isSongSelect) then
      t.panel = Image:new('common/panel.png');
    else
      t.panel = Image:new('common/panel_wide.png');
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Grid
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.w = this.window.w - (this.window.padding.x * 2);
        
        this.x = this.window.padding.x;
      else
        this.w = this.window.w - (this.window.padding.x * 3) - this.panel.w;

        this.x = (this.window.w / 10) + this.panel.w;
      end

      this.h = this.w;

      this.jacketSize = this.w / 3.3;
      this.margin = (this.w - (this.jacketSize * 3)) / 2;

      this.y = this.window.h - this.window.padding.y - this.h;

      this.grade.w = (this.jacketSize // 2.2);
      this.grade.h = (this.jacketSize // 4);

      this.field.maxWidth = (this.jacketSize * 1.65)
        - (this.dropdown.padding * 2);
      this.field.x[1] = this.x - 1;
      this.field.x[2] = this.field.x[1]
				+ (this.jacketSize * 1.5)
				+ this.margin;
      this.field.x[3] = this.field.x[2] + (this.jacketSize * 0.9);

      this.dropdown.maxWidth = (this.jacketSize * 3)
        + (this.margin * 2)
        - (this.dropdown.padding * 2);
      this.dropdown.start = this.dropdown.padding - 7;
      this.dropdown.x[1] = this.field.x[1];
      this.dropdown.x[2] = this.field.x[2];
      this.dropdown.x[3] = this.field.x[3];

      if (this.window.isPortrait) then
        if (getSetting('_songSelect', 'FALSE') == 'TRUE') then
          this.label.y = this.y - (this.window.padding.y * 1.5);
          this.field.y = this.label.y + this.label.h;
          this.dropdown.y = this.field.y + (this.label.h * 1.35);
        else
          this.label.y = this.y + (this.window.padding.y * 3.5);
          this.field.y = this.label.y + this.label.h;
          this.dropdown.y = this.field.y + (this.label.h * 1.35);
        end
      else
        this.field.y = this.window.padding.y + this.label.h;
        this.label.y = this.window.padding.y - 2;
        this.dropdown.y = this.field.y + (this.label.h * 1.35);
      end

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,
};

return Grid;