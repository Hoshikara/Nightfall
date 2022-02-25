--#region Require

local ResultsContext = require("results/ResultsContext")
local ResultsPanel = require("results/ResultsPanel")
local ResultsScoreList = require("results/ResultsScoreList")

--#endregion

local window = Window.new()
local background = Background.new()

local screenshotRegion = getSetting("screenshotRegion", "PANEL")

--#region Components

local context = ResultsContext.new()
local resultsPanel = ResultsPanel.new(context, window)
local resultsScoreList = ResultsScoreList.new(context, window)

--#endregion

function result_set()
	context:set(result)
end

---@param dt deltaTime
function render(dt)
	context:update()
	gfx.Save()
	background:draw()
	window:update()
	resultsPanel:draw(dt)
	resultsScoreList:draw(dt)
	gfx.Restore()
end

function get_capture_rect()
	if (screenshotRegion == "FULLSCREEN") or (not context.getPanelRegion) then
		return 0, 0, game.GetResolution()	
	end

	return context.getPanelRegion()
end

---@param path string
function screenshot_captured(path)
	context:handleScreenshot(path)
end
