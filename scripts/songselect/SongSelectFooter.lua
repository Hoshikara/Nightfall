local ControlLabel = require("common/ControlLabel")

---@class SongSelectFooter: SongSelectFooterBase
local SongSelectFooter = {}
SongSelectFooter.__index = SongSelectFooter

---@param ctx SongSelectContext
---@param window Window
---@return SongSelectFooter
function SongSelectFooter.new(ctx, window)
	---@class SongSelectFooterBase
	local self = {
		ctx = ctx,
		openCollectionsControl = ControlLabel.new("BT-B + BT-C", "OPEN COLLECTIONS"),
		openGameSettingsControl = ControlLabel.new("FX-L + FX-R", "OPEN GAME SETTINGS"),
		viewScoresControl = ControlLabel.new("BT-D", "VIEW SCORES"),
		viewTop50Control = ControlLabel.new("BT-A", "VIEW TOP 50"),
		window = window,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, SongSelectFooter)
end

function SongSelectFooter:draw()
	if self.ctx.viewingTop50 then
		return
	end

	local offset = 612
	local x = self.window.paddingX
	local y = self.window.footerY

	if self.window.isPortrait then
		self.openGameSettingsControl:draw(x, y)
		self.openCollectionsControl:draw(x + 336, y)

		offset = 812
		y = 30
	else
		self.openGameSettingsControl:draw((x * 2) + 768, y)
		self.openCollectionsControl:draw((x * 2) + 1084, y)
	end

	self.viewTop50Control:draw(x, y)
	self.viewScoresControl:draw(x + offset, y)
end

return SongSelectFooter
