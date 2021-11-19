local Image = require("common/Image")

local abs = math.abs
local sin = math.sin

---@class Console: ConsoleBase
local Console = {}
Console.__index = Console

---@param ctx GameplayContext
---@param window Window
---@return Console
function Console.new(ctx, window)
	---@class ConsoleBase
	local self = {
		base = Image.new({ path = "gameplay/console/base" }),
		buttons = {},
		ctx = ctx,
		knobs = {},
		window = window,
	}

	for i = 1, 6 do
		self.buttons[i] = {
			overlay = Image.new({ path = ("gameplay/console/button_%d"):format(i) }),
			timer = 0,
		}
	end

	for i = 1, 2 do
		self.knobs[i] = {
			glow = Image.new({ path = ("gameplay/console/glow_%d"):format(i) }),
			glowTimer = 0,
			ring = Image.new({ path = ("gameplay/console/ring_%d"):format(i) }),
			ringTimer = 0,
		}
	end

	---@diagnostic disable-next-line
	return setmetatable(self, Console)
end

---@param dt deltaTime
function Console:draw(dt)
	local y = self.base.h * 0.5

	gfx.Save()
	gfx.Translate(((self.window.resX / 2) - gameplay.critLine.x) * (5 / 6), 0)
	self.window:scale()
	self.base:draw({ y = y, isCentered = true })
	self:drawButtons(dt, y)
	self:drawKnobs(dt, y)
	gfx.Restore()
end

---@param dt deltaTime
---@param y number
function Console:drawButtons(dt, y)
	for i, button in ipairs(self.buttons) do
		if game.GetButton(i - 1) then
			button.timer = button.timer + dt * 10 * 3.14 * 2
		else
			button.timer = 0
		end

		if button.timer ~= 0 then
			button.overlay:draw({
				y = y,
				alpha = ((sin(button.timer) * 0.5) + 0.5) * 0.5 + 0.1,
				blendOp = 8,
				isCentered = true,
			})
		end
	end
end

---@param dt deltaTime
---@param y number
function Console:drawKnobs(dt, y)
	for i, knob in ipairs(self.knobs) do
		local isActive = gameplay.laserActive[i]
		local isLeft = i == 1

		if (self.ctx.alertTimers[i] > -1.5) and (not isActive) then
			knob.glowTimer = knob.glowTimer + dt
		else
			knob.glowTimer = 0
		end

		gfx.Save()
		gfx.Translate((isLeft and -488) or 350, 16)

		if knob.glowTimer ~= 0 then
			knob.glow:draw({
				alpha = 0.2 + (0.4 * abs(sin(knob.glowTimer * 28))),
				blendOp = 8,
			})
		end

		gfx.Translate((isLeft and 64) or 74, 40)

		if isActive then
			knob.ringTimer = knob.ringTimer + (dt * 100)

			knob.ring:draw({
				alpha = 0.4,
				blendOp = 8,
				isCentered = true,
				scale = 0.5 + (0.5 * (knob.ringTimer / 12) % 1),
			})
		end

		gfx.Restore()
	end
end

return Console
