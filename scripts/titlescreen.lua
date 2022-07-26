--#region Require

local ControlLabel = require("common/ControlLabel")
local Mouse = require("common/Mouse")
local Buttons = require("titlescreen/Buttons")
local TitlescreenContext = require("titlescreen/TitlescreenContext")
local Title = require("titlescreen/Title")
local UpdatePrompt = require("titlescreen/UpdatePrompt")
local GameplaySettings = require("gameplaysettings/GameplaySettings")
local PlayerInfo = require("playerinfo/PlayerInfo")

--#endregion

local window = Window.new()
local background = Background.new()
local mouse = Mouse.new(window)

--#region Components

local context = TitlescreenContext.new(window)
local buttons = Buttons.new(context, mouse, window)
local gameplaySettings = GameplaySettings.new(context, mouse, window)
local playerInfo = PlayerInfo.new(context, mouse, window)
local title = Title.new(context, mouse, window)
local updatePrompt = UpdatePrompt.new(context, mouse, window)

local mainMenuControl = ControlLabel.new("BACK", "MAIN MENU")
local mainMenuControlY = 0

--#endregion

---@param dt deltaTime
function render(dt)
	context:update()
	mouse:update()

	gfx.Save()
	background:draw()
	window:update()
	buttons:draw(dt)
	title:draw(dt)

	mainMenuControlY = window.footerY

	if context.currentView == "UpdatePrompt" then
		updatePrompt:draw(dt)
	elseif context.currentView == "GameplaySettings" then
		gameplaySettings:draw(dt)

		if window.isPortrait then
			mainMenuControlY = window.headerY
		end
	elseif (context.currentView == "PlayerInfo")
	or (context.currentView == "Charts")
	or (context.currentView == "Top50")
	then
		playerInfo:draw(dt)
	end

	if (context.currentView ~= "UpdatePrompt")
	and (context.currentPage ~= "MainMenu")
	then
		mainMenuControl:draw(window.paddingX, mainMenuControlY)
	end

	gfx.Restore()
end

---@param btn integer
function mouse_pressed(btn)
	context:handleClick()

	return 0
end

---@param btn integer
function button_pressed(btn)
	context:handleInput(btn)
end
