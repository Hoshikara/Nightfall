local CollectionsWindowContext = require("collectionswindow/CollectionsWindowContext")
local CollectionsWindow = require("collectionswindow/CollectionsWindow")

local window = Window.new()

local context = CollectionsWindowContext.new()
local collectionsWindow = CollectionsWindow.new(context, window)

---@param dt deltaTime
---@return boolean
function render(dt)
	game.SetSkinSetting("_managingCollections", ((not dialog.closing) and 1) or 0)
	game.SetSkinSetting("_isViewingTop50", 0)

	gfx.Save()
	window:update()
	collectionsWindow:draw(dt)
	gfx.Restore()

	return not (dialog.closing and (collectionsWindow.shift.value == 0))
end

---@param step integer
function advance_selection(step)
	context:selectOption(step)
end

---@param btn integer
function button_pressed(btn)
	context:handleButton(btn)
end

function open()
	context:update()
end
