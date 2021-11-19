local Easing = require("common/Easing")

local background = Background.new()

local resX, resY = 0, 0

local introDone = false
local introEasing = Easing.new()
local outroDone = false
local outroEasing = Easing.new()

---@param dt deltaTime
---@param isIntro boolean
local function handleTimers(dt, isIntro)
	local duration = 0.3

	if resY > resX then
		duration = 0.22
	end

	if isIntro then
		introEasing:start(dt, 1, duration)

		introDone = introEasing.value >= 1
	else
		outroEasing:start(dt, 2, duration)
		outroDone = outroEasing.value >= 1
	end
end

---@param dt deltaTime
---@param isIntro boolean
local function drawTransition(dt, isIntro)
	resX, resY = game.GetResolution()

	handleTimers(dt, isIntro)

	gfx.Save()
	gfx.Scissor(resX * outroEasing.value, 0, resX * introEasing.value, resY)
	background:draw()
	gfx.ResetScissor()
	gfx.Restore()
end

---@param dt deltaTime
function render(dt)
	drawTransition(dt, true)

	return introDone
end

---@param dt deltaTime
function render_out(dt)
	drawTransition(dt, false)

	return outroDone
end

function reset()
	introEasing:reset()
	outroEasing:reset()
end
