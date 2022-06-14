local Image = require("common/Image")

local floor = math.floor
local min = math.min

---@class Background
---@field image Image
---@field imagePortrait Image
---@field tint Color
local Background = {}
Background.__index = Background

---@return Background
function Background.new()
	---@type Background
	local self = {
		blue = 0,
		dim = getSetting("backgroundDim", 0),
		green = 0,
		image = Image.new({ path = "bg" }),
		imagePortrait = Image.new({ path = "bg_portrait" }),
		red = 0,
		tint = { 0, 0, 0 },
		tintBackground = getSetting("tintBackground", true),
	}

	return setmetatable(self, Background)
end

function Background:draw()
	local resX, resY = game.GetResolution()

	self:updateSettings()

	if resY > resX then
		self.imagePortrait:draw({
			x = 0,
			y = 0,
			w = resX,
			h = resY,
			alpha = 1 - self.dim,
			tint = self.tintBackground and self.tint,
		})
	else
		self.image:draw({
			x = 0,
			y = 0,
			w = resX,
			h = resY,
			alpha = 1 - self.dim,
			tint = self.tintBackground and self.tint,
		})
	end
end

function Background:updateSettings()
	local r, g, b, _ = game.GetSkinSetting("colorScheme")

	self.dim = getSetting("backgroundDim", 0)
	self.tintBackground = getSetting("tintBackground", true)

	if (r ~= self.red) or (g ~= self.green) or (b ~= self.blue) then
		self.tint[1] = min(floor((r or 0) * 1.25), 255)
		self.tint[2] = min(floor((g or 0) * 1.25), 255)
		self.tint[3] = min(floor((b or 0) * 1.25), 255)

		self.red = r
		self.green = g
		self.blue = b
	end
end

return Background
