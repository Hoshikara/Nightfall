---@diagnostic disable

-- Global song table available here
-- song = {
--   "illustrator": "いそにん",
--   "level": 13,
--   "bpm": "159-212",
--   "title": "refluxio",
--   "jacket": 77,
--   "effector": "電撃ロブスター＆ロイヤルクラッカー",
--   "artist": "Juggernaut.",
--   "difficulty": 1
-- }

local DifficultyNames = require("common/constants/DifficultyNames")
local Easing = require("common/Easing")

local window = Window.new()
local background = Background.new()
local isPortrait = false

local introDone = false
local introEasing = Easing.new()
local outroDone = false
local outroEasing = Easing.new()
local staticTimer = 0

local jacket = nil
local jacketFallback = gfx.CreateSkinImage("loading.png", 0)
local jacketSize = 484

local title = makeLabel("JP", "", 42, "White")
local artist = makeLabel("JP", "", 28)
local jpText1 = makeLabel("JP", "", 25, "White")
local jpText2 = makeLabel("JP", "", 25, "White")
local mediumText = makeLabel("Medium", "", 32)
local numberText = makeLabel("Number", "", 28, "White")

---@param dt deltaTime
---@param isIntro boolean
local function handleTimers(dt, isIntro)
	local duration = 0.3

	if window.h > window.w then
		duration = 0.22
	end

	if isIntro then
		introEasing:start(dt, 1, duration)

		if introEasing.value >= 1 then
			staticTimer = staticTimer + dt
		end

		introDone = staticTimer >= 1
	else
		outroEasing:start(dt, 2, duration)
		outroDone = outroEasing.value >= 1
	end
end

---@param dt deltaTime
---@param isIntro boolean
local function drawTransition(dt, isIntro)
	gfx.Save()
	window:update()

	local w, h = window.w, window.h
	local isPortrait = window.isPortrait
	local x = (isPortrait and (window.paddingX + 242)) or ((w * 0.5) - 294)
	local y = (isPortrait and ((h * 0.5) - 190)) or (h * 0.5)

	handleTimers(dt, isIntro)

	gfx.Scissor(w * outroEasing.value, 0, w * introEasing.value, h)
	window:unscale()
	background:draw()
	window:scale()
	drawRect({
		x = x,
		y = y,
		w = jacketSize,
		h = jacketSize,
		image = jacket,
		isCentered = true,
		stroke = { color = "Medium", size = 3 },
	})
	drawChartInfo(x, y, isPortrait)
	gfx.ResetScissor()
	gfx.Restore()
end

---@param x number
---@param y number
---@param isPortrait boolean
function drawChartInfo(x, y, isPortrait)
	if isPortrait then
		x = window.paddingX - 3
		y = 1082
	else
		x = x + 319
		y = y - 166
	end

	title:draw({
		x = x,
		y = y,
		maxWidth = (isPortrait and 968) or 852,
		text = song.title,
		update = true,
	})
	artist:draw({
		x = x + 1,
		y = y + 57,
		maxWidth = (isPortrait and 968) or 852,
		text = song.artist,
		update = true,
	})
	numberText:draw({
		x = x,
		y = y + 98,
		text = song.bpm,
		update = true,
	})
	mediumText:draw({
		x = x + numberText.w + 12,
		y = y + 94,
		text = "BPM",
		update = true,
	})

	y = y + 194

	mediumText:draw({
		x = x + 1,
		y = y,
		color = "White",
		text = DifficultyNames:get("", song.difficulty),
		update = true,
	})
	numberText:draw({
		x = x + mediumText.w + 14,
		y = y + 4,
		text = ("%02d"):format(song.level),
		update = true,
	})
	mediumText:draw({
		x = x + 1,
		y = y + 40,
		color = "Standard",
		text = "EFFECTED BY",
		update = true,
	})
	jpText1:draw({
		x = x + 1 + mediumText.w + 14,
		y = y + 46,
		maxWidth = (isPortrait and 768) or 670,
		text = song.effector or "-",
		update = true,
	})
	mediumText:draw({
		x = x + 1,
		y = y + 80,
		color = "Standard",
		text = "ILLUSTRATED BY",
		update = true,
	})
	jpText2:draw({
		x = x + 1 + mediumText.w + 14,
		y = y + 86,
		maxWidth = (isPortrait and 742) or 628,
		text = song.illustrator or "-",
		update = true,
	})
end

---@param dt deltaTime
---@return boolean
function render(dt)
	if not jacket then
		Colors:update()

		jacket = ((song.jacket == 0) and jacketFallback) or song.jacket
	end

	game.SetSkinSetting("_isViewingTop50", 0)
	drawTransition(dt, true)

	return introDone
end

---@param dt deltaTime
---@return boolean
function render_out(dt)
	drawTransition(dt, false)

	return outroDone
end

function reset()
	jacket = nil
	staticTimer = 0

	introEasing:reset()
	outroEasing:reset()
end
