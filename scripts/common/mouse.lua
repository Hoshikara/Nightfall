---@class MouseClass
local Mouse = {
	-- Mouse constructor
	---@param this MouseClass
	---@param window Window
	---@return Mouse
  new = function(this, window)
		---@class Mouse : MouseClass
		---@field window Window
		local t = {
			window = window,
			x = 0,
			y = 0,
		};

		setmetatable(t, this);
		this.__index = this;

		return t;
  end,

	-- Determine if the mouse is hovering over the specified bounds
	---@param this Mouse
	---@param x number
	---@param y number
	---@param w number
	---@param h number
  clipped = function(this, x, y, w, h)
		local scale = this.window:getScale();

		x = x * scale;
		y = y * scale;
		w = x + (w * scale);
		h = y + (h * scale);

		return (this.x > x) and (this.y > y) and (this.x < w) and (this.y < h);
  end,

	-- Track the current mouse position
	---@param this Mouse
  watch = function(this) this.x, this.y = game.GetMousePos(); end,
};

return Mouse;