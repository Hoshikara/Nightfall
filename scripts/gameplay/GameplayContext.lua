local RatingColors = require("common/constants/RatingColors")

local abs = math.abs
local max = math.max

local showEarlateDeltaOn = getSetting("earlateDelta", "OFF")
local showEarlateTextOn = getSetting("earlateText", "<= NEAR")

---@class GameplayContext: GameplayContextBase
---@field bpmData BpmPoint[]
local GameplayContext = {}
GameplayContext.__index = GameplayContext

---@return GameplayContext
function GameplayContext.new()
	---@class GameplayContextBase
	local self = {
		alertTimers = { -1.5, -1.5 },
		bpmData = nil,
		buttonRatings = {
			errorEarly = 0,
			nearEarly = 0,
			criticalEarly = 0,
			sCritical = 0,
			criticalLate = 0,
			nearLate = 0,
			errorLate = 0,
		},
		chain = 0,
		chainTimer = 0,
		---@type EarlateProps
		earlate = {
			delta = 0,
			deltaColor = RatingColors.SCritical,
			deltaTimer = 0,
			text = "EARLY",
			textColor = RatingColors.Early,
			textTimer = 0,
		},
		exScore = 0,
		introAlpha = 1,
		introOffset = 0,
		introTimer = 2,
		isButton = false,
		isFromSongSelect = getSetting("_isSongSelect", 1) == 1,
		maxChain = 0,
		maxExScore = 0,
		outroTimer = 0,
		score = 0,
		sCritWindow = nil,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, GameplayContext)
end

function GameplayContext:update()
	if gameplay.progress == 0 then
		self.exScore = 0
		self.isButton = false
		self.maxChain = 0
		self.maxExScore = 0
	end
end

---@param delta number
---@param rating rating
function GameplayContext:handleButton(delta, rating)
	if not self.sCritWindow then
		self.sCritWindow = math.floor(gameplay.hitWindow.perfect / 2)
	end

	self.isButton = rating ~= 3

	if self.isButton then
		self.maxExScore = self.maxExScore + 5
	end

	if rating == 0 then
		if delta < 0 then
			self.buttonRatings.errorEarly = self.buttonRatings.errorEarly + 1
		else
			self.buttonRatings.errorLate = self.buttonRatings.errorLate + 1
		end
	elseif rating == 1 then
		self.exScore = self.exScore + 2

		if delta < 0 then
			self.buttonRatings.nearEarly = self.buttonRatings.nearEarly + 1
		else
			self.buttonRatings.nearLate = self.buttonRatings.nearLate + 1
		end

		if showEarlateDeltaOn ~= "OFF" then
			self.earlate.delta = delta
			self.earlate.deltaColor = delta < 0 and RatingColors.Early or RatingColors.Late
			self.earlate.deltaTimer = 0.75
		end

		if showEarlateTextOn ~= "OFF" then
			self.earlate.text = delta < 0 and "EARLY" or "LATE"
			self.earlate.textColor = delta < 0 and RatingColors.Early or RatingColors.Late
			self.earlate.textTimer = 0.75
		end
	elseif rating == 2 then
		local absDelta = abs(delta)
		local sCritHit = absDelta <= self.sCritWindow

		if sCritHit then
			self.exScore = self.exScore + 5

			if delta < 0 then
				self.buttonRatings.sCritical = self.buttonRatings.sCritical + 1
			end
		else
			self.exScore = self.exScore + 4

			if delta < 0 then
				self.buttonRatings.criticalEarly = self.buttonRatings.criticalEarly + 1
			else
				self.buttonRatings.criticalLate = self.buttonRatings.criticalLate + 1
			end
		end

		if showEarlateDeltaOn == "ALL" or (showEarlateDeltaOn == "<= CRITICAL" and not sCritHit) then
			if sCritHit then
				self.earlate.deltaColor = RatingColors.SCritical
			else
				self.earlate.deltaColor = delta < 0 and RatingColors.Early or RatingColors.Late
			end

			self.earlate.delta = delta
			self.earlate.deltaTimer = 0.75
		end

		if showEarlateTextOn == "<= CRITICAL" and not sCritHit then
			self.earlate.text = delta < 0 and "EARLY" or "LATE"
			self.earlate.textColor = delta < 0 and RatingColors.Early or RatingColors.Late
			self.earlate.textTimer = 0.75
		end
	end
end

---@param dt deltaTime
function GameplayContext:handleIntro(dt)
	self.introTimer = max(self.introTimer - (dt / 2), 0)

	local t = max(self.introTimer - 1, 0)

	self.introAlpha = 1 - (t ^ 1.5)
	self.introOffset = t ^ 4
end

---@param newChain integer
function GameplayContext:updateChain(newChain)
	if (newChain > self.chain) and (not self.isButton) then
		self.exScore = self.exScore + 2
	end

	if newChain > self.maxChain then
		self.maxChain = newChain
	end

	if not self.isButton then
		self.maxExScore = self.maxExScore + 2
	end

	self.chain = newChain
	self.chainTimer = 0.75
	self.isButton = false
end

function GameplayContext:updateLaserAlerts(isRight)
	if isRight and (self.alertTimers[2] < -1) then
		self.alertTimers[2] = 1
	elseif self.alertTimers[1] < -1 then
		self.alertTimers[1] = 1
	end
end

function GameplayContext:resetButtonRatings()
	self.buttonRatings.errorEarly = 0
	self.buttonRatings.nearEarly = 0
	self.buttonRatings.criticalEarly = 0
	self.buttonRatings.sCritical = 0
	self.buttonRatings.criticalLate = 0
	self.buttonRatings.nearLate = 0
	self.buttonRatings.errorLate = 0
end

return GameplayContext

---@class EarlateProps
---@field delta number
---@field deltaColor Color
---@field deltaTimer number
---@field text string
---@field textColor Color
---@field textTimer number
