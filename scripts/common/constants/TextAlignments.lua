---@type table<string, integer>
local TextAlignments = {
	CenterTop = 10,
	CenterMiddle = 18,
	CenterBottom = 34,
	LeftTop = 9,
	LeftMiddle = 17,
	LeftBottom = 33,
	RightTop = 12,
	RightMiddle = 20,
	RightBottom = 36,
}

---@param alignment string|integer
---@diagnostic disable-next-line
function TextAlignments:align(alignment)
	gfx.TextAlign(self[alignment] or self.LeftTop)
end

return TextAlignments
