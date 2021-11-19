---@class ControlLabel: ControlLabelBase
local ControlLabel = {}
ControlLabel.__index = ControlLabel

---@param control string
---@param text string
---@param altControl? string
---@return ControlLabel
function ControlLabel.new(control, text, altControl, altText)
	---@class ControlLabelBase
	local self = {
		altControl = altControl and makeLabel("SemiBold", altControl or "", 14),
		altText = altText and makeLabel("SemiBold", altText),
		control = makeLabel("SemiBold", control or "", 14),
		text = makeLabel("SemiBold", text or ""),
	}

	self.w = self.control.w + self.text.w + 28

	---@diagnostic disable-next-line
	return setmetatable(self, ControlLabel)
end

---@param x number
---@param y number
---@param alpha? number
---@param showAlt? boolean
function ControlLabel:draw(x, y, alpha, showAlt)
	local control = (showAlt and self.altControl) or self.control
	local text = (showAlt and self.altText) or self.text
	local w = control.w
	local h = control.h

	alpha = alpha or 1

	drawRect({
		x = x,
		y = y,
		w = w + 13,
		h = h + 3,
		alpha = alpha * 0.8,
		color = "Black",
		radius = 3,
		stroke = {
			color = "Medium",
			size = 1,
		},
	})
	control:draw({
		x = x + 6,
		y = y + 1,
		alpha = alpha,
		color = "Standard",
	})
	text:draw({
		x = x + w + 20,
		y = y - 3,
		alpha = alpha,
		color = "White",
	})
end

return ControlLabel
