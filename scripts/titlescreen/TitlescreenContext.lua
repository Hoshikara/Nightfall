local Knobs = require("common/Knobs")

local BACK = game.BUTTON_BCK
local START = game.BUTTON_STA

---@class TitlescreenContext: TitlescreenContextBase
local TitlescreenContext = {}
TitlescreenContext.__index = TitlescreenContext

---@return TitlescreenContext
function TitlescreenContext.new(window)
	---@class TitlescreenContextBase
	---@field btnEvent function|nil
	local self = {
		btnCount = 0,
		btnEvent = nil,
		checkForUpdate = true,
		choosingFolder = false,
		currentBtn = 1,
		currentPage = "MainMenu",
		currentTab = 1,
		currentView = "",
		hoveringVersion = false,
		isClickable = false,
		isLoaded = false,
		knobs = Knobs.new(),
		newVersion = false,
		tabCount = 0,
		updateClosed = false,
		window = window,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, TitlescreenContext)
end

function TitlescreenContext:update()
	Colors:update()

	self.btnEvent = nil

	if self.window.isPortrait then
		self.currentBtn = self.knobs:handleRight(self.currentBtn, self.btnCount)
	else
		self.currentBtn = self.knobs:handleLeft(self.currentBtn, self.btnCount)
	end

	if self.choosingFolder
	or (self.currentView == "Charts")
	or (self.currentView == "Top50")
	then
		self.currentTab = self.knobs:handleRight(self.currentTab, self.tabCount)
	end
end

function TitlescreenContext:handleClick()
	if self.isClickable and self.btnEvent then
		self.btnEvent()
	end
end

---@param btn integer
function TitlescreenContext:handleInput(btn)
	if (btn == START) or (btn == BACK) then
		if self.choosingFolder then
			self.choosingFolder = false

			return
		elseif self.currentView == "Charts" then
			self:exitView("PlayerInfo")

			return
		elseif self.currentView ~= "" then
			self:exitView()

			return
		end
	end

	if btn == START then
		if self.btnEvent then
			self.btnEvent()
		end
	elseif btn == BACK then
		if self.currentPage == "PlayOptions" then
			self.currentBtn = 1
			self.currentPage = "MainMenu"
		else
			Menu.Exit()
		end
	end
end

---@param view? string
function TitlescreenContext:exitView(view)
	if view == "UpdatePrompt" then
		self.updateClosed = true
	end

	if view then
		self.currentView = view
	else
		self.currentBtn = 1
		self.currentView = ""
	end
end

return TitlescreenContext
