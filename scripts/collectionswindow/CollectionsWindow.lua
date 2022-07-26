local Button = require("common/Button")
local ControlLabel = require("common/ControlLabel")
local Easing = require("common/Easing")
local ItemCursor = require("common/ItemCursor")
local List = require("common/List")
local Scrollbar = require("common/Scrollbar")

---@class CollectionsWindow: CollectionsWindowBase
local CollectionsWindow = {}
CollectionsWindow.__index = CollectionsWindow

---@param ctx CollectionsWindowContext
---@param window Window
---@return CollectionsWindow
function CollectionsWindow.new(ctx, window)
	---@class CollectionsWindowBase
	local self = {
		button = Button.new(672 + 32, 48),
		cancelControl = ControlLabel.new("BACK", "CANCEL"),
		createCollectionControl = ControlLabel.new("START", "CREATE COLLECTION"),
		ctx = ctx,
		exitControl = ControlLabel.new("BACK", "EXIT"),
		heading = makeLabel("Medium", "COLLECTIONS", 48),
		itemCursor = ItemCursor.new({
			size = 10,
			stroke = 1.5,
			type = "Vertical",
		}),
		list = List.new(),
		margin = 32,
		navigationControl = ControlLabel.new("KNOB / UP / DOWN", "SELECT OPTION"),
		pageItemCount = 6,
		scrollbar = Scrollbar.new(),
		shift = Easing.new(),
		shiftValue = 0,
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 808,
		h = 640,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, CollectionsWindow)
end

---@param dt deltaTime
function CollectionsWindow:draw(dt)
	self:setProps()
	self:handleShift(dt)
	self:drawDim()
	gfx.Translate(self.x + (self.shiftValue * self.shift.value), self.y)
	self:drawWindow(dt)
	self:handleList(dt)
	self:drawControls()
end

function CollectionsWindow:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = -self.w - self.window.shiftX
		self.y = (self.window.h / 2) - (self.h / 2)
		self.itemCursor:setProps({
			x = 32,
			y = 96,
			w = self.button.w,
			h = self.button.h,
			margin = self.margin,
		})
		self.list:setProps({
			pageItemCount = self.pageItemCount,
			pageSize = (self.pageItemCount * (self.button.h + self.margin)),
		})
		self.scrollbar:setProps({
			x = 768,
			y = 96,
			h = 448,
			pageItemCount = self.pageItemCount,
		})
		self.shiftValue = self.w + self.window.shiftX + (self.window.w / 2) - (self.w / 2)

		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
function CollectionsWindow:handleShift(dt)
	if dialog.closing then
		self.shift:stop(dt, 3, 0.2)
	else
		self.shift:start(dt, 3, 0.2)
	end
end

---@param dt deltaTime
function CollectionsWindow:handleList(dt)
	local params = {
		currentItem = self.ctx.currentOption,
		totalItems = self.ctx.numOptions,
	}

	self.itemCursor:draw(dt, params)
	self.list:update(dt, params)

	if self.ctx.numOptions > self.pageItemCount then
		self.scrollbar:draw(dt, params)
	end
end

function CollectionsWindow:drawDim()
	local window = self.window
	local scale = window.scaleFactor

	drawRect({
		x = -window.shiftX / scale,
		y = -window.shiftY / scale,
		w = window.resX / scale,
		h = window.resY / scale,
		alpha = self.shift.value * 0.4,
		color = "Black",
	})
end

---@param dt deltaTime
function CollectionsWindow:drawWindow(dt)
	drawRect({
		w = self.w,
		h = self.h,
		alpha = 0.95,
		color = "Black",
		stroke = { color = "Medium", size = 2 },
	})

	self.heading:draw({
		x = 28,
		y = 15,
		color = "White",
	})

	self:drawOptions(dt)
end

---@param dt deltaTime
function CollectionsWindow:drawOptions(dt)
	local currentOption = self.ctx.currentOption
	local list = self.list
	local margin = self.margin
	local options = self.ctx.options
	local x = 32
	local y = 96 + list.offset
	local h = self.button.h

	for i, option in ipairs(options) do
		if list:isOnPage(i) then
			self:drawOption(x, y, option.text, i == currentOption)
		end

		y = y + h + margin
	end
end

---@param x number
---@param y number
---@param text Label
---@param isCurrent boolean
function CollectionsWindow:drawOption(x, y, text, isCurrent)
	self.button:draw({
		x = x,
		y = y,
		isActive = isCurrent,
	})
	text:draw({
		x = x + 15,
		y = y + 7,
		color = "White",
	})
end

function CollectionsWindow:drawControls()
	local x = 33
	local y = 587

	if dialog.isTextEntry then
		self.createCollectionControl:draw(x, y)
		self.cancelControl:draw(x + 253, y)
	else
		self.navigationControl:draw(x, y)
		self.exitControl:draw(x + 282, y)
	end
end

return CollectionsWindow
