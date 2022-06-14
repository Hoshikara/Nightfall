--#region Require

local Easing = require("common/Easing")
local GameplaySettingsTabs = require("gameplaysettings/constants/GameplaySettingsTabs")
local Image = require("common/Image")
local Earlate = require("gameplay/Earlate")
local Chain = require("gameplay/Chain")
local HitAnimations = require("gameplay/HitAnimations")
local HitDeltaBar = require("gameplay/HitDeltaBar")
local LaneSpeed = require("gameplay/LaneSpeed")
local LaserAnimations = require("gameplay/LaserAnimations")
local LaserCursors = require("gameplay/LaserCursors")
local PlayerCard = require("gameplay/PlayerCard")
local ScoreDifference = require("gameplay/ScoreDifference")

--#endregion

local EnabledColor = { 255, 205, 0 }

local TabNames = {
	"chain",
	"earlate",
	"hitAnimations",
	"hitDeltaBar",
	"laneSpeed",
	"playerCard",
	"scoreDifference",
}

---@class GameplaySettings
---@field bg Image
---@field bgPortrait Image
---@field ctx TitlescreenContext
---@field heading Label
---@field mouse Mouse
---@field sideShift Easing
---@field tabShifts table<string, Easing>
---@field window Window
local GameplaySettings = {}
GameplaySettings.__index = GameplaySettings

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return GameplaySettings
function GameplaySettings.new(ctx, mouse, window)
	---@type GameplaySettings
	local self = {
		bg = Image.new({ path = "settings_bg" }),
		bgPortrait = Image.new({ path = "settings_bg_portrait" }),
		ctx = ctx,
		currentTab = "",
		heading = makeLabel("Medium", "GAMEPLAY SETTINGS", 48),
		mouse = mouse,
		offsetX = 0,
		offsetY = 0,
		sideClosed = false,
		sideShift = Easing.new(1),
		tabs = nil,
		tabShifts = {},
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	for _, name in ipairs(TabNames) do
		self.tabShifts[name] = Easing.new()
	end

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
	self:drawWindow(x, y)
	self.heading:draw({
		x = x + 21,
		y = y + 8,
		color = "White",
	})
	self:drawTabs(dt, x, y, currentTab)
	self:drawHamburgerButton(y)
	gfx.Restore()
end

function GameplaySettings:setProps()
	if self.windowResized ~= self.window.resized then
		if self.window.isPortrait then
			self.offsetY = 0
			self.y = 1350
			self.w = 1080
			self.h = 720
		else
			self.offsetY = 0
			self.y = 0
			self.w = 640
			self.h = 720
		end

		self.x = self.window.w - self.w
		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
---@param currentTab string
---@param window Window
function GameplaySettings:handleTimers(dt, currentTab, window)
	local tabShifts = self.tabShifts

	if self.sideClosed then
		self.sideShift:start(dt, 1, 0.16)
	else
		self.sideShift:stop(dt, 2, 0.16)
	end

	self.offsetX = (self.w + (window.shiftX / window.scaleFactor)) * self.sideShift.value

	for _, name in ipairs(TabNames) do
		if name == currentTab then
			tabShifts[name]:start(dt, 3, 0.16)
		else
			tabShifts[name]:stop(dt, 3, 0.16)
		end
	end
end

---@param window Window
function GameplaySettings:drawDim(window)
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

---@param x number
---@param y number
function GameplaySettings:drawWindow(x, y)
	drawRect({
		x = x + 1,
		y = y + 1,
		w = self.w - 2,
		h = self.h - 2,
		alpha = 0.95,
		color = "Black",
		stroke = { color = "Medium", size = 2 },
	})
	drawRect({
		x = x,
		y = y,
		w = self.w,
		h = 80,
		alpha = 1,
		color = "Medium",
	})
end

---@param dt deltaTime
---@param x1 number
---@param y number
---@param currentTab string
function GameplaySettings:drawTabs(dt, x1, y, currentTab)
	local tabs = self.tabs
	local tabShifts = self.tabShifts
	local x2 = x1 + self.w - 24
	local w = self.w

	y = y + 80

	for _, name in ipairs(TabNames) do
		y = self:drawTab(dt, x1, x2, y, w, tabs[name], tabShifts[name].value, currentTab == name, name)
	end
end

---@param dt deltaTime
---@param x1 number
---@param x2 number
---@param y number
---@param w number
---@param tab GameplaySettingTab
---@param shift number
---@param isExpanded boolean
---@param tabName string
function GameplaySettings:drawTab(dt, x1, x2, y, w, tab, shift, isExpanded, tabName)
	local isEnabled = tab.status.value == 1
	local returnY = y + 58 + (tab.height * shift)

	x1 = x1 + 24

	self:drawToggleBtn(x1, y, isEnabled, tab.status)
	tab.heading:draw({
		x = x1 + 39,
		y = y + 2,
		color = (isExpanded and "Standard") or "White",
	})
	self:drawExpandBtn(x2, y, isExpanded, tabName)

	x1 = x1 + 40
	y = y + 47

	for _, setting in ipairs(tab.settings) do
		y = self:drawSetting(x1, x2, y, setting, shift, isEnabled, isExpanded)
	end

	drawRect({
		x = x1 - 63,
		y = returnY,
		w = w,
		h = 2,
		alpha = 0.95,
		color = "Medium",
	})

	if isEnabled then
		tab.draw(dt)
	end

	return returnY
end

---@param x number
---@param y number
---@param isExpanded boolean
---@param tabName string
function GameplaySettings:drawExpandBtn(x, y, isExpanded, tabName)
	local alpha = 0.4

	x = x - 24
	y = y + 17

	if self.mouse:clipped(x - 4, y - 4, 32, 32) then
		self.ctx.btnEvent = function()
			if isExpanded then
				self.currentTab = ""
			else
				self.currentTab = tabName
			end
		end

		alpha = 1
	end

	y = y + 5

	setColor("Standard", alpha)

	gfx.BeginPath()

	if isExpanded then
		gfx.MoveTo(x, y + 15)
		gfx.LineTo(x + 12, y)
		gfx.LineTo(x + 24, y + 15)
		gfx.ClosePath()
	else
		gfx.MoveTo(x, y)
		gfx.LineTo(x + 12, y + 15)
		gfx.LineTo(x + 24, y)
		gfx.ClosePath()
	end

	gfx.Fill()
end

---@param x number
---@param y number
---@param isEnabled boolean
---@param toggleSetting GameplaySetting
function GameplaySettings:drawToggleBtn(x, y, isEnabled, toggleSetting)
	local alpha = (isEnabled and 1) or 0

	if self.mouse:clipped(x + 1, y + 17, 24, 24) then
		self.ctx.btnEvent = toggleSetting.event
	end

	drawRect({
		x = x + 1,
		y = y + 17,
		w = 24,
		h = 24,
		alpha = alpha,
		color = EnabledColor,
		stroke = {
			alpha = 150,
			color = "Standard",
			size = 2,
		},
	})
end

---@param x1 number
---@param x2 number
---@param y number
---@param setting GameplaySetting
---@param shift number
---@param isEnabled boolean
---@param isExpanded boolean
function GameplaySettings:drawSetting(x1, x2, y, setting, shift, isEnabled,
                                      isExpanded)
	local alpha = ((isEnabled and 1) or 0.2) * shift

	x2 = x2 - 16

	setting.name:draw({
		x = x1,
		y = y,
		alpha = alpha,
		color = "White",
	})
	setting.valueLabel:draw({
		x = x2 - 48,
		y = y + setting.offsetY,
		align = "RightTop",
		alpha = alpha,
		color = setting.color,
		text = setting.text,
		update = true,
	})

	self:drawArrow(x2, y, setting.event, shift, isEnabled, isExpanded)
	self:drawArrow(x2, y, setting.event, shift, isEnabled, isExpanded, true)

	return y + 35
end

---@param x number
---@param y number
---@param event function
---@param shift number
---@param isEnabled boolean
---@param isExpanded boolean
---@param isRight? boolean
function GameplaySettings:drawArrow(x, y, event, shift, isEnabled, isExpanded, isRight)
	local alpha = 0.2

	if not isRight then
		x = x - 32
	end

	y = y + 7

	if isEnabled and isExpanded and self.mouse:clipped(x - 6, y, 28, 28) then
		self.ctx.btnEvent = function()
			event((isRight and 1) or -1)
		end

		alpha = 1
	end

	alpha = alpha * shift
	y = y + 5

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

	y = y + 16

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
		hitAnimations = hitAnimations,
		hitDeltaBar = hitDeltaBar,
		laneSpeed = laneSpeed,
		playerCard = playerCard,
		scoreDifference = scoreDifference,
	}
end

return GameplaySettings
