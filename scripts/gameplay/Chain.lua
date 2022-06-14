local DimmedNumber = require("common/DimmedNumber")

local getColor = require("common/helpers/getColor")

local ChainColors = {
	[0] = getColor("normalChainColor"),
	[1] = getColor("UcChainColor"),
	[2] = getColor("PucChainColor"),
}

---@class Chain
---@field ctx GameplayContext
---@field isGameplaySettings boolean
---@field number DimmedNumber
---@field scale number
---@field text Label
---@field window Window
local Chain = {}
Chain.__index = Chain

---@param ctx GameplayContext
---@param window Window
---@param isGameplaySettings boolean
---@return Chain
function Chain.new(ctx, window, isGameplaySettings)
	---@type Chain
	local self = {
		ctx = ctx,
		isGameplaySettings = isGameplaySettings,
		number = DimmedNumber.new({ digits = 4, size = 72 }),
		scale = getSetting("chainScale", 1.0),
		text = makeLabel("Medium", "CHAIN"),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
	}

	return setmetatable(self, Chain)
end

---@param dt deltaTime
function Chain:draw(dt)
	if self.isGameplaySettings then
		self:updateProps()
	else
		if (self.ctx.chain == 0) or (self.ctx.chainTimer < 0) then
			return
		end

		self.ctx.chainTimer = self.ctx.chainTimer - dt
	end

	self:setProps()

	local chain = self.ctx.chain
	local color = ChainColors[(gameplay and gameplay.comboState) or 2]

	gfx.Save()
	gfx.Translate(self.x, self.y)
	gfx.Scale(self.scale, self.scale)
	self:drawChain(chain, color)
	gfx.Restore()
end

function Chain:setProps()
	if (self.windowResized ~= self.window.resized) or self.isGameplaySettings then
		self.x = self.window.w * getSetting("chainX", 0.5)

		if self.window.isPortrait then
			self.y = 306 + (self.window.h * 0.6) * getSetting("chainY", 0.0)
		else
			self.y = self.window.h * getSetting("chainY", 0.75)
		end

		self.windowResized = self.window.resized
	end
end

function Chain:updateProps()
	self.opacity = getSetting("chainOpacity", 1.0)
	self.scale = getSetting("chainScale", 1.0)
end

function Chain:drawChain(chain, color)
	self.text:draw({
		x = 0,
		y = -24,
		align = "CenterTop",
		alpha = self.opacity,
		color = color,
	})
	self.number:draw({
		x = -94,
		y = -4,
		alpha = self.opacity,
		color = color,
		spacing = 3,
		value = chain,
	})
end

return Chain
