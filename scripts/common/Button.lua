---@class Button: ButtonBase
local Button = {}
Button.__index = Button

---@param w number
---@param h number
---@return Button
function Button.new(w, h)
	---@class ButtonBase
	local self = { w = w or 0, h = h or 0 }

	---@diagnostic disable-next-line
	return setmetatable(self, Button)
end

---@param params Button.draw.params
function Button:draw(params)
	drawRect({
		x = params.x,
		y = params.y,
		w = self.w,
		h = self.h,
		alpha = 0.4 * (params.alpha or 1),
		color = "Black",
		stroke = {
			alpha = params.alpha,
			color = (params.isActive and "Standard") or "Medium",
			size = 1.5,
		},
	})
end

return Button

---@class Button.draw.params
---@field x? number
---@field y? number
---@field alpha? number
---@field isActive? boolean
