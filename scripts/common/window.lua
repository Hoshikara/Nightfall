---@class WindowClass
local Window = {
  -- Window constructor
  ---@param this WindowClass
  ---@param move? boolean
  ---@return Window
  new = function(this, move)
    ---@class Window : WindowClass
    local t = {
      isPortrait = false,
      padding = { x = 0, y = 0 },
      resX = 0,
      resY = 0,
      sFactor = 1,
      w = 0,
      h = 0,
    };

    if (move) then t.move = { x = 0, y = 0 }; end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Returns the scaling factor of the current window
  ---@param this Window
  ---@return number
  getScale = function(this) return this.sFactor; end,

  -- Undos any scaling currently applied to the drawn elements
  ---@param this Window
  unscale = function(this) gfx.Scale(1 / this.sFactor, 1 / this.sFactor); end,

  -- Scales any proceeding elements by the current scaling factor
  ---@param this Window
  scale = function(this) gfx.Scale(this.sFactor, this.sFactor); end,

  -- Sets the scaling factor, scaled width, and scaled height for the current window
  ---@param this Window
  ---@param dontScale boolean
  set = function(this, dontScale)
    local resX, resY = game.GetResolution();

    if ((this.resX ~= resX) or (this.resY ~= resY)) then
      this.isPortrait = resY > resX;
      this.w = (this.isPortrait and 1080) or 1920;
      this.h = this.w * (resY / resX);
      this.sFactor = resX / this.w;

      if (this.isPortrait) then
        this.padding.x = this.w / 18;
        this.padding.y = this.h / 32;
      else
        this.padding.x = this.w / 20;
        this.padding.y = this.h / 20;
      end

      if (this.move) then
        if (this.sFactor > (resY / this.h)) then
          this.move.x = (resX / (2 * this.sFactor)) - (this.w / 2);
          this.move.y = 0;
        else
          this.move.x = 0;
          this.move.y = (resY / (2 * this.sFactor)) - (this.h / 2);
        end
      end

      this.resX = resX;
      this.resY = resY;
    end

    if (not dontScale) then this:scale(); end
  end,
};

return Window;