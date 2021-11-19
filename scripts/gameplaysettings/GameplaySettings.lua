--#region Require

local Easing = require("common/Easing")
local GameplaySettingsTabs = require("gameplaysettings/constants/GameplaySettingsTabs")
local Image = require("common/Image")
local Chain = require("gameplay/Chain")
local Earlate = require("gameplay/Earlate")
local GaugeBar = require("gameplay/GaugeBar")
local HitAnimations = require("gameplay/HitAnimations")
local HitDeltaBar = require("gameplay/HitDeltaBar")
local LaneSpeed = require("gameplay/LaneSpeed")
local LaserAnimations = require("gameplay/LaserAnimations")
local LaserCursors = require("gameplay/LaserCursors")
local PlayerCard = require("gameplay/PlayerCard")
local ScoreDifference = require("gameplay/ScoreDifference")

--#endregion

local TabNames = {
	"chain",
	"earlate",
	"gaugeBar",
	"hitAnimations",
	"hitDeltaBar",
	"laneSpeed",
	"playerCard",
	"scoreDifference",
}

---@class GameplaySettings: GameplaySettingsBase
local GameplaySettings = {}
GameplaySettings.__index = GameplaySettings

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return GameplaySettings
function GameplaySettings.new(ctx, mouse, window)
	---@class GameplaySettingsBase
	local self = {
		bg = Image.new({ path = "settings_bg" }),
		bgPortrait = Image.new({ path = "settings_bg_portrait" }),
		ctx = ctx,
		currentTab = TabNames[1],
		heading = makeLabel("Medium", "OPTIONS", 36),
		mouse = mouse,
		offsetX = 0,
		sideClosed = false,
		sideShift = Easing.new(1),
		tabs = nil,
		tabEasings = {},
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 720,
		h = 480,
	}

	for _, name in ipairs(TabNames) do
		self.tabEasings[name] = Easing.new()
	end

	---@diagnostic disable-next-line
	return setmetatable(self, GameplaySettings)
end

---@param dt deltaTime
function GameplaySettings:draw(dt)
	if not self.tabs then
		self:makeTabs()
	end

	self:setProps()

	local currentTab = self.currentTab
	local window = self.window
	local x = self.x + self.offsetX
	local y = self.y

	self:handleTimers(dt, currentTab, window)

	gfx.Save()
	self:drawDim(window)
	self:drawBackground(window)
	self:drawComponents(dt)
	self:drawWindow(x, y)
	self.heading:draw({
		x = x + 277,
		y = y + 11,
		color = "White",
	})
	self:drawTabs(x, y, currentTab)
	self:drawHamburgerButton(y)
	gfx.Restore()
end

function GameplaySettings:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = self.window.w - self.w
		self.y = (self.window.isPortrait and 1440) or 0
		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
---@param currentTab string
---@param window Window
function GameplaySettings:handleTimers(dt, currentTab, window)
	local tabEasings = self.tabEasings

	if self.sideClosed then
		self.sideShift:start(dt, 1, 0.16)
	else
		self.sideShift:stop(dt, 2, 0.16)
	end

	self.offsetX = (self.w + (window.shiftX / window.scaleFactor)) * self.sideShift.value

	for _, name in ipairs(TabNames) do
		if name == currentTab then
			tabEasings[name]:start(dt, 3, 0.16)
		else
			tabEasings[name]:stop(dt, 3, 0.16)
		end
	end
end

---@param window Window
function GameplaySettings:drawDim(window)
	-- This will cover up the main background for ultrawide resolutions
	local scale = window.scaleFactor

	drawRect({
		x = -window.shiftX / scale,
		y = -window.shiftY / scale,
		w = window.resX / scale,
		h = window.resY / scale,
		color = "Black",
	})
end

---@param window Window
function GameplaySettings:drawBackground(window)
	if window.isPortrait then
		self.bgPortrait:draw({ w = window.w, h = window.h })
	else
		self.bg:draw({ w = window.w, h = window.h })
	end
end

---@param  dt deltaTime
function GameplaySettings:drawComponents(dt)
	for _, tab in pairs(self.tabs) do
		if tab.settings[1].value == 1 then
			tab.draw(dt)
		end
	end
end

---@param x number
---@param y number
function GameplaySettings:drawWindow(x, y)
	-- This first one is to cover the gauge pct label on landscape orientation
	drawRect({
		x = x + 2,
		y = y + 2,
		w = 540,
		h = self.h - 4,
		alpha = 1.0,
		color = "Black",
		isFast = true,
	})
	drawRect({
		x = x + 1,
		y = y + 1,
		w = self.w - 2,
		h = self.h - 2,
		alpha = 1.0,
		color = "Black",
		stroke = { color = "Medium", size = 2 },
	})
	drawRect({
		x = x,
		y = y,
		w = 260,
		h = self.h,
		alpha = 1,
		color = "Medium",
		isFast = true,
	})
end

---@param x number
---@param y1 number
---@param currentTab string
function GameplaySettings:drawTabs(x, y1, currentTab)
	local tabs = self.tabs
	local tabEasings = self.tabEasings
	local y2 = y1 + 79

	y1 = y1 + 20

	for _, name in ipairs(TabNames) do
		self:drawTab(x, y1, tabEasings[name].value, tabs[name], name)

		if name == currentTab then
			local isEnabled = tabs[name].settings[1].value == 1

			for i, setting in ipairs(tabs[name].settings) do
				self:drawSetting(x + 278, y2, isEnabled, i == 1, setting)

				y2 = y2 + 40
			end
		end

		y1 = y1 + 40
	end
end

---@param x number
---@param y number
---@param tab GameplaySettingTab
---@param tabName string
function GameplaySettings:drawTab(x, y, easing, tab, tabName)
	if self.mouse:clipped(x + 20, y, 220, 32) then
		self.ctx.btnEvent = function()
			self.currentTab = tabName
		end
	end

	drawRect({
		x = x + 20,
		y = y,
		w = 220 * easing,
		h = 32,
		color = "Black",
		alpha = 0.4,
		isFast = true,
	})
	tab.heading:draw({
		x = x + 26,
		y = y - 1,
		color = "White",
	})
end

---@param x1 number
---@param y number
---@param isEnabled boolean
---@param isEnableSetting boolean
---@param setting GameplaySetting
function GameplaySettings:drawSetting(x1, y, isEnabled, isEnableSetting, setting)
	local alpha = (((isEnabled or isEnableSetting) and 1) or 0.4)
	local x2 = x1 + 404

	setting.name:draw({
		x = x1,
		y = y,
		alpha = alpha,
		color = "White",
	})
	setting.valueLabel:draw({
		x = x2 - 51,
		y = y + setting.offsetY,
		align = "RightTop",
		alpha = alpha,
		color = setting.color,
		text = setting.text,
		update = true,
	})

	self:drawArrow(x2, y, setting.event, isEnabled, isEnableSetting, false)
	self:drawArrow(x2, y, setting.event, isEnabled, isEnableSetting, true)
end

---@param x number
---@param y number
---@param event function
---@param isEnabled boolean
---@param isEnableSetting boolean
---@param isRight boolean
function GameplaySettings:drawArrow(x, y, event, isEnabled, isEnableSetting, isRight)
	local alpha = 0.4

	if not isRight then
		x = x - 32
	end

	y = y + 7

	if (isEnabled or isEnableSetting) and self.mouse:clipped(x - 6, y, 28, 28) then
		self.ctx.btnEvent = function()
			event((isRight and 1) or -1)
		end

		alpha = 1
	end

	y = y + 2

	gfx.BeginPath()
	setColor("White", alpha)

	if isRight then
		gfx.MoveTo(x, y)
		gfx.LineTo(x, y + 16)
		gfx.LineTo(x + 16, y + 8)
		gfx.LineTo(x, y)
		gfx.ClosePath()
	else
		gfx.MoveTo(x + 16, y)
		gfx.LineTo(x + 16, y + 16)
		gfx.LineTo(x, y + 8)
		gfx.LineTo(x + 16, y)
		gfx.ClosePath()
	end

	gfx.Fill()
end

---@param y number
function GameplaySettings:drawHamburgerButton(y)
	local x = self.x + self.w - 64

	y = y + 12

	if self.mouse:clipped(x, y, 48, 48) then
		self.ctx.btnEvent = function()
			self.sideClosed = not self.sideClosed
		end
	end

	drawRect({
		x = x,
		y = y,
		w = 48,
		h = 48,
		alpha = 0.8,
		color = "Dark",
		isFast = true,
	})

	for i = 0, 2 do
		drawRect({
			x = x + 8,
			y = y + 10 + (i * 12),
			w = 32,
			h = 3,
			alpha = 0.8,
			color = "Standard",
			isFast = true,
		})
	end
end

function GameplaySettings:makeTabs()
	local chain = GameplaySettingsTabs.Chain
	local earlate = GameplaySettingsTabs.Earlate
	local gaugeBar = GameplaySettingsTabs.GaugeBar
	local hitAnimations = GameplaySettingsTabs.HitAnimations
	local hitDeltaBar = GameplaySettingsTabs.HitDeltaBar
	local laneSpeed = GameplaySettingsTabs.LaneSpeed
	local playerCard = GameplaySettingsTabs.PlayerCard
	local scoreDifference = GameplaySettingsTabs.ScoreDifference
	local window = self.window

	chain.component = Chain.new({ chain = 9009 }, window, true)
	chain.draw = function(dt)
		chain.component:draw(dt)
	end

	earlate.component = Earlate.new({}, window, true)
	earlate.draw = function(dt)
		earlate.component:draw(dt)
	end

	gaugeBar.component = GaugeBar.new(
		{ introAlpha = 1, introOffset = 0 },
		window,
		true
	)
	gaugeBar.draw = function(dt)
		gaugeBar.component:draw(dt)
	end

	hitAnimations.component1 = HitAnimations.new({}, window, true)
	hitAnimations.component2 = LaserAnimations.new(window, true)
	hitAnimations.component3 = LaserCursors.new(window, true)
	hitAnimations.draw = function(dt)
		gfx.Save()
		self.window:unscale()
		hitAnimations.component1:draw(dt)
		hitAnimations.component2:draw(dt)
		hitAnimations.component3:draw(dt)
		gfx.Restore()
	end

	hitDeltaBar.component = HitDeltaBar.new(window, true)
	hitDeltaBar.draw = function(dt)
		hitDeltaBar.component:draw(dt)
	end

	laneSpeed.component = LaneSpeed.new(window, true)
	laneSpeed.draw = function()
		laneSpeed.component:draw()
	end

	playerCard.component = PlayerCard.new(
		{ introAlpha = 1, introOffset = 0 },
		window,
		true
	)
	playerCard.draw = function()
		playerCard.component:draw()
	end

	scoreDifference.component = ScoreDifference.new({}, window, true)
	scoreDifference.draw = function(dt)
		scoreDifference.component:draw(dt)
	end

	self.tabs = {
		chain = chain,
		earlate = earlate,
		gaugeBar = gaugeBar,
		hitAnimations = hitAnimations,
		hitDeltaBar = hitDeltaBar,
		laneSpeed = laneSpeed,
		playerCard = playerCard,
		scoreDifference = scoreDifference,
	}
end

return GameplaySettings
