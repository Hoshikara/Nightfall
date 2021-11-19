--#region Require

local Grid = require("common/Grid")
local DropdownMenu = require("songselect/DropdownMenu")
local getFolders = require("songselect/helpers/getFolders")

--#endregion

local window = Window.new()
local grid = Grid.new(window)

local choosingFolder = true
local currentLevel = 1
local currentFolder = 1

local folderDropdownMenu = DropdownMenu.new(window, {
	altControl = "START",
	control = "FX-L",
	font = "Medium",
	isLong = true,
	name = "FOLDER FILTER",
})

local levelDropdownMenu = DropdownMenu.new(window, {
	altControl = "START",
	control = "FX-L",
	font = "Number",
	fontSize = 26,
	name = "LEVEL FILTER",
})

---@param dt deltaTime
---@param isFiltering boolean
function render(dt, isFiltering)
	local y = 0

	game.SetSkinSetting("_isFiltering", 1)
	getFolders()
	grid:setProps()

	gfx.Save()
	window:update()

	if window.isPortrait then
		y = grid.y - 94
	else
		y = window.headerY
	end

	folderDropdownMenu:draw(dt, {
		x = grid.x,
		y = y,
		currentItem = currentFolder,
		currentItemOffset = -12,
		isOpen = isFiltering and choosingFolder,
		items = filters.folder,
		maxWidthCurrent = grid.jacketSize,
		maxWidthItems = grid.w,
		showAltControl = isFiltering and (not choosingFolder),
	})
	levelDropdownMenu:draw(dt, {
		x = grid.x + grid.jacketSize + grid.margin,
		y = y,
		currentItem = currentLevel,
		currentItemOffset = ((currentLevel > 1) and -7) or -12,
		isOpen = isFiltering and (not choosingFolder),
		items = filters.level,
		itemOffset = 5,
		showAltControl = isFiltering and choosingFolder,
	})
	gfx.Restore()
end

---@param newItem integer
---@param isFolder boolean
function set_selection(newItem, isFolder)
	if isFolder then
		currentFolder = newItem
	else
		currentLevel = newItem
	end
end

---@param isFolder boolean
function set_mode(isFolder)
	choosingFolder = isFolder
end
