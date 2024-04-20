---@diagnostic disable: need-check-nil, undefined-field

game.LoadSkinSample("tick_bt")
game.LoadSkinSample("tick_fx")

--#region Require

local BpmData = require("gameplay/BpmData")
local Chain = require("gameplay/Chain")
local Console = require("gameplay/Console")
local CritBar = require("gameplay/CritBar")
local Earlate = require("gameplay/Earlate")
local GameplayContext = require("gameplay/GameplayContext")
local GaugeBar = require("gameplay/GaugeBar")
local HitAnimations = require("gameplay/HitAnimations")
local HitDeltaBar = require("gameplay/HitDeltaBar")
local LaserAlerts = require("gameplay/LaserAlerts")
local LaserAnimations = require("gameplay/LaserAnimations")
local LaserCursors = require("gameplay/LaserCursors")
local PlayerCard = require("gameplay/PlayerCard")
local PracticeInfo = require("gameplay/PracticeInfo")
local ScoreDifference = require("gameplay/ScoreDifference")
local ScoreInfo = require("gameplay/ScoreInfo")
local SongInfo = require("gameplay/SongInfo")
local didPress = require("common/helpers/didPress")

--#endregion

local window = Window.new()

local assistTickEnabled = getSetting("assistTick", false)
local earlateEnabled = getSetting("showEarlate", true)
local gaugeBarEnabled = getSetting("showGaugeBar", true)
local hitAnimationsEnabled = getSetting("showHitAnimations", true)
local hitDeltaBarEnabled = getSetting("showHitDeltaBar", true)
local playerCardEnabled = getSetting("showPlayerCard", true)
local scoreDifferenceEnabled = getSetting("showScoreDifference", true)

local autoplayText = nil

local abs = math.abs

--#region Components

local context = GameplayContext.new()
local bpmData = BpmData.new(context)
local chain = nil
local console = Console.new(context, window)
local critBar = CritBar.new(window)
---@type Earlate
local earlate = nil
local gaugeBar = nil
---@type HitAnimations
local hitAnimations = hitAnimationsEnabled and HitAnimations.new(context, window)
---@type HitDeltaBar
local hitDeltaBar = nil
local laserAlerts = nil
---@type LaserAnimations
local laserAnimations = hitAnimationsEnabled and LaserAnimations.new(window)
local laserCursors = LaserCursors.new(window)
local playerCard = nil
local practiceInfo = nil
---@type ScoreDifference
local scoreDifference = nil
local scoreInfo = nil
local songInfo = nil

--#endregion

local init = true

local function initAll()
	chain = Chain.new(context, window)
	earlate = earlateEnabled and Earlate.new(context, window)
	gaugeBar = gaugeBarEnabled and GaugeBar.new(context, window)
	hitDeltaBar = hitDeltaBarEnabled and HitDeltaBar.new(window)
	laserAlerts = LaserAlerts.new(context, window)
	playerCard = PlayerCard.new(context, window)
	scoreDifference = scoreDifferenceEnabled and ScoreDifference.new(context, window)
	scoreInfo = ScoreInfo.new(context, window)
	songInfo = SongInfo.new(context, window)

	if gameplay.practice_setup ~= nil then
		practiceInfo = PracticeInfo.new(context, window)
	end

	autoplayText = makeLabel("Medium", "AUTOPLAY", 48)

	init = false
end

local function setupCritTransform()
	gfx.ResetTransform()
	gfx.Translate(gameplay.critLine.x, gameplay.critLine.y)
	gfx.Rotate(-gameplay.critLine.rotation)
end

---@param btn integer
---@param rating rating
---@param delta integer
---@return integer, integer, integer # r, g, b used as `color` for `sprite.fs`
function button_hit(btn, rating, delta)
	context:handleButton(delta, rating)

	if assistTickEnabled and (rating ~= 3) then
		if btn < 4 then
			game.PlaySample("tick_bt")
		else
			game.PlaySample("tick_fx")
		end
	end

	if hitAnimationsEnabled then
		hitAnimations:enqueueHit(btn, delta, rating)
	end

	if hitDeltaBarEnabled and (not gameplay.autoplay) then
		hitDeltaBar:enqueueHit(btn, delta, rating)
	end

	-- r values here correspond to each state of the `scorehit` texture
	if rating == 3 then
		return 150, 0, 0
	elseif rating == 2 then
		if abs(delta) <= context.sCritWindow then
			return 100, 0, 0
		end

		return 200, 0, 0
	elseif rating == 1 then
		return 50, 0, 0
	end

	return 0, 0, 0
end

---@param length number
---@param startPos number
---@param endPos number
---@param index integer
function laser_slam_hit(length, startPos, endPos, index)
	if hitAnimationsEnabled then
		laserAnimations:enqueueSlamHit(index, endPos)
	end
end

---@param dt deltaTime
function render_crit_base(dt)
	window:update(true)
	setupCritTransform()
	critBar:draw(dt)
	gfx.ResetTransform()
end

---@param dt deltaTime
function render_crit_overlay(dt)
	if hitAnimationsEnabled then
		hitAnimations:draw(dt)
		laserAnimations:draw(dt)
	end

	setupCritTransform()

	if window.isPortrait then
		console:draw(dt)
	end

	laserCursors:draw(dt)
end

---@param dt deltaTime
function render(dt)
	if init then
		initAll()
	end

	bpmData:collect(dt)
	context:update()

	gfx.ResetTransform()
	window:update()
	chain:draw(dt)

	if gaugeBarEnabled then
		gaugeBar:draw(dt)
	end

	laserAlerts:draw(dt)
	scoreInfo:draw()
	songInfo:draw(dt)

	if scoreDifferenceEnabled then
		scoreDifference:draw(dt)
	end

	if gameplay.autoplay then
		autoplayText:draw({
			x = window.w / 2,
			y = (window.isPortrait and 290) or 0,
			align = "CenterTop",
			alpha = context.introAlpha,
			color = "White",
		})

		if gameplay.practice_setup ~= nil then
			practiceInfo:drawControls()
		end
	else
		if earlateEnabled then
			earlate:draw(dt)
		end

		if hitDeltaBarEnabled then
			hitDeltaBar:draw(dt)
		end

		if playerCardEnabled
			and (not gameplay.multiplayer)
			and (gameplay.practice_setup == nil)
		then
			playerCard:draw()
		end

		if gameplay.practice_setup ~= nil then
			practiceInfo:draw()
		end
	end
end

---@param dt deltaTime
function render_intro(dt)
	if gameplay.demoMode then
		context.introAlpha = 0

		return true
	end

	if not didPress("STA") then
		context:handleIntro(dt)
	end

	return context.introTimer <= 1
end

---@param dt deltaTime
---@param clearState integer
function render_outro(dt, clearState)
	if clearState == 0 then
		return true
	end

	if clearState > 1 then
		bpmData:save()
	end

	context.outroTimer = context.outroTimer + dt

	if not gameplay.demoMode then
		return context.outroTimer > 2, 1 - context.outroTimer
	end

	return context.outroTimer > 2, 1
end

---@param isRight boolean
function laser_alert(isRight)
	context:updateLaserAlerts(isRight)
end

---@param isLate boolean
function near_hit(isLate)
	context.earlateTimer = 0.75
end

---@param newChain integer
function update_combo(newChain)
	context:updateChain(newChain)
end

---@param newScore integer
function update_score(newScore)
	context.score = newScore
end

---@param type string
---@param missionThreshold any
---@param mission string
function practice_start(type, missionThreshold, mission)
	practiceInfo:start(mission)
end

---@param playCount integer
---@param passCount integer
---@param didPass boolean
---@param practiceScoreInfo PracticeScoreInfo
function practice_end_run(playCount, passCount, didPass, practiceScoreInfo)
	practiceInfo:set(playCount, passCount, practiceScoreInfo)
end

---@param playCount integer
---@param passCount integer
function practice_end(playCount, passCount)
	practiceInfo:set(passCount, playCount)
end
