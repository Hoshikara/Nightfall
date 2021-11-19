--#region Require

local Easing = require("common/Easing")
local Button = require("common/Button")
local ItemCursor = require("common/ItemCursor")
local makeTitlescreenButtons = require("titlescreen/helpers/makeTitlescreenButtons")

--#endregion

---@class Buttons: ButtonsBase
local Buttons = {}
Buttons.__index = Buttons

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return Buttons
function Buttons.new(ctx, mouse, window)
	---@class ButtonsBase
	local self = {
		alpha = Easing.new(),
		allowAction = 1,
		button = Button.new(288, 48),
		buttons = nil,
		ctx = ctx,
		currentPage = "MainMenu",
		itemCursor = ItemCursor.new({
			size = 12,
			stroke = 1.5,
			type = "Horizontal",
		}),
		margin = 0,
		mouse = mouse,
		window = window,
		windowResized = nil,
		x = {},
		y = {},
	}

	---@diagnostic disable-next-line
	return setmetatable(self, Buttons)
end

---@param dt deltaTime
function Buttons:draw(dt)
	if (not self.ctx.isLoaded) or (self.ctx.currentView ~= "") then
		return
	end

	if not self.buttons then
		self.buttons = makeTitlescreenButtons(self.ctx)
	end

	local buttons = self.buttons[self.currentPage]
	local btnCount = #buttons
	local isNavigable = self:isNavigable()

	self:setProps()
	self:updateAlpha(dt)
	self:drawButtons(buttons, isNavigable)

	if isNavigable then
		self:drawCursor(dt, btnCount)
	end

	self.ctx.btnCount = btnCount
end

function Buttons:setProps()
	if self.windowResized ~= self.window.resized then
		local margin = 80
		local x = self.window.paddingX
		local y = self.window.h - (self.window.paddingY * 4) - self.button.h
		local w = self.button.w
		local h = self.button.h

		if self.window.isPortrait then
			margin = 120
			x = x * 1.5
			y = self.window.paddingY * 10
		end

		self.x[1] = x
		self.y[1] = y

		if self.window.isPortrait then
			self.itemCursor.type = "Vertical"

			for i = 2, 6 do
				y = y + h + margin

				self.y[i] = y
			end
		else
			self.itemCursor.type = "Horizontal"

			for i = 2, 6 do
				x = x + w + margin

				self.x[i] = x
			end
		end

		self.itemCursor:setProps({
			x = self.x[1],
			y = self.y[1],
			w = w,
			h = h,
			margin = margin,
		})
		self.windowResized = self.window.resized
	end
end

---@param dt deltaTime
function Buttons:updateAlpha(dt)
	local alpha = self.alpha

	if self.ctx.currentPage == "MainMenu" then
		if self.currentPage == "PlayOptions" then
			alpha:stop(dt, 3, 0.14)

			if alpha.value == 0 then
				self.currentPage = "MainMenu"
			end
		else
			alpha:start(dt, 3, 0.14)
		end
	elseif self.ctx.currentPage == "PlayOptions" then
		if self.currentPage == "MainMenu" then
			alpha:stop(dt, 3, 0.14)

			if alpha.value == 0 then
				self.currentPage = "PlayOptions"
			end
		else
			alpha:start(dt, 3, 0.14)
		end
	end

	self.allowAction = alpha.value == 1
end

---@param buttons TitlescreenButton[]
---@param isNavigable boolean
function Buttons:drawButtons(buttons, isNavigable)
	local alpha = self.alpha.value
	local isActionable = isNavigable and self.allowAction

	for i, button in ipairs(buttons) do
		local isActive = self:isActive(buttons, button, isNavigable)

		self:drawButton(alpha, button, i, isActionable, isActive)
	end
end

---@param alpha number
---@param button TitlescreenButton
---@param index integer
---@param isActionable boolean
---@param isActive boolean
function Buttons:drawButton(alpha, button, index, isActionable, isActive)
	local x = self.x[index]
	local y = self.y[1]

	if self.window.isPortrait then
		x = self.x[1]
		y = self.y[index]
	end

	local isHovering = self:isHovering(x, y)
	local isModifyingCtx = isActionable and (isHovering or isActive)

	if isModifyingCtx then
		self.ctx.currentBtn = index
		self.ctx.btnEvent = button.event
		self.ctx.isClickable = isHovering
	end

	self.button:draw({
		x = x,
		y = y,
		alpha = alpha,
		isActive = isModifyingCtx,
	})
	button.text:draw({
		x = x + 15,
		y = y + 7,
		alpha = alpha,
		color = "White",
	})
end

---@param dt deltaTime
---@param btnCount integer
function Buttons:drawCursor(dt, btnCount)
	self.itemCursor:draw(dt, {
		alphaMod = self.alpha.value,
		currentItem = self.ctx.currentBtn,
		totalItems = btnCount,
	})
end

---@param buttons TitlescreenButton[]
---@param button TitlescreenButton
---@param isNavigable boolean
---@return boolean
function Buttons:isActive(buttons, button, isNavigable)
	local activeButton = buttons[self.ctx.currentBtn]

	return button.event == (isNavigable and activeButton.event)
end

---@param x number
---@param y number
---@return boolean
function Buttons:isHovering(x, y)
	return self.mouse:clipped(x, y, self.button.w, self.button.h)
end

---@return boolean
function Buttons:isNavigable()
	local ctx = self.ctx

	return ctx.isLoaded and (ctx.currentView == "") and (not ctx.hoveringVersion)
end

return Buttons

---@class TitlescreenButton
---@field event function
---@field text Label
