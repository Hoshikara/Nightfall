--#region Require

local Grid = require("common/Grid")
local DropdownMenu = require("songselect/DropdownMenu")
local SortItem = require("songselect/SortItem")

--#endregion

local window = Window.new()
local grid = Grid.new(window)

local currentSort = 1

local sortMenu = DropdownMenu.new(window, { control = "FX-R", name = "SORTING MODE" })

---@param items string[]
function DropdownMenu:makeItems(items)
  if self.totalItems ~= #items then
    local maxItems = self.pageItemCount
    local totalItems = 0
    local w = 0
    local h = 0

    self:resetProps()

    for i, item in ipairs(items) do
      self.items[i] = SortItem.new(item)

      if self.items[i].w > w then
        w = self.items[i].w
      end

      if i <= maxItems then
        h = h + 44
      end

      totalItems = totalItems + 1
    end

    self.totalItems = totalItems
    self.w = w + 28
    self.h = h
  end
end

---@param dt deltaTime
---@param isSorting boolean
function render(dt, isSorting)
  local y = 0

  game.SetSkinSetting("_isSorting", 1)
  grid:setProps()

	gfx.Save()
	window:update()

  if window.isPortrait then
		y = grid.y - 94
	else
		y = window.headerY
	end

	sortMenu:draw(dt, {
		x = grid.x + ((grid.jacketSize + grid.margin) * 2),
		y = y,
		currentItem = currentSort,
		currentItemOffset = -12,
		isOpen = isSorting,
		items = sorts,
	})
	gfx.Restore()
end

---@param newSort integer
function set_selection(newSort)
  currentSort = newSort
end
