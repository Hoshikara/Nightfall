--#region Require

local Easing = require("common/Easing")
local Button = require("common/Button")
local ItemCursor = require("common/ItemCursor")
local makeUpdatePromptButtons = require("titlescreen/helpers/makeUpdatePromptButtons")

--#endregion

---@class UpdatePrompt: UpdatePromptBase
local UpdatePrompt = {}
UpdatePrompt.__index = UpdatePrompt

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return UpdatePrompt
function UpdatePrompt.new(ctx, mouse, window)
	---@class UpdatePromptBase
	local self = {
		alpha = Easing.new(),
		button = Button.new(192, 48),
		buttonX = {},
		buttonY = 0,
		buttons = nil,
		ctx = ctx,
		itemCursor = ItemCursor.new({
			size = 10,
			stroke = 1.5,
			type = "Horizontal",
		}),
		mouse = mouse,
		text = makeLabel("Medium", "GAME UPDATE AVAILABLE", 40),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	}

	---@diagnostic disable-next-line
	return setmetatable(self, UpdatePrompt)
end

---@param dt deltaTime
function UpdatePrompt:draw(dt)
	local ctx = self.ctx

	if not ctx.isLoaded then
		return
	end

	if not self.buttons then
		self.buttons = makeUpdatePromptButtons(ctx)
	end

	self.alpha:start(dt, 3, 0.2)

	local alpha = self.alpha.value
	local buttons = self.buttons
	local btnCount = #buttons

	self:setProps()
	self:drawUpdatePrompt(alpha, buttons)
	self:drawCursor(dt, alpha, btnCount)

	ctx.btnCount = btnCount
end

function UpdatePrompt:setProps()
	if self.windowResized ~= self.window.resized then
		local buttonW = self.button.w
		local buttonH = self.button.h
		local w = 768
		local h = 218
		local x = (self.window.w / 2) - (w / 2)
		local y = (self.window.h / 2) - (h / 2)

		for i = 1, 3 do
			self.buttonX[i] = x + 48 + ((i - 1) * (buttonW + 48))
		end

		self.buttonY = y + h - buttonH - 48
		self.itemCursor:setProps({
			x = self.buttonX[1],
			y = self.buttonY,
			w = buttonW,
			h = buttonH,
			margin = 48,
		})
		self.w = w
		self.h = h
		self.x = x
		self.y = y
		self.windowResized = self.window.resized
	end
end

---@param alpha number
---@param buttons TitlescreenButton[]
function UpdatePrompt:drawUpdatePrompt(alpha, buttons)
	local x = self.x
	local y = self.y

	drawRect({
		x = x,
		y = y,
		w = self.w,
		h = self.h,
		alpha = 0.65 * alpha,
		color = "Black",
	})
	self.text:draw({
		x = x + 47,
		y = y + 34,
		alpha = alpha,
		color = "White",
	})
	self:drawButtons(alpha, buttons)
end

---@param alpha number
---@param buttons TitlescreenButton[]
function UpdatePrompt:drawButtons(alpha, buttons)
	local y = self.buttonY

	for i, button in ipairs(buttons) do
		local isActive = self:isActive(buttons, button)
		local x = self.buttonX[i]

		self:drawButton(x, y, button, i, alpha, isActive)
	end
end

---@param x number
---@param y number
---@param button TitlescreenButton
---@param index integer
---@param alpha number
---@param isActive boolean
function UpdatePrompt:drawButton(x, y, button, index, alpha, isActive)
	local isHovering = self:isHovering(x, y)
	local isModifyingCtx = isHovering or isActive

	if isModifyingCtx then
		self.ctx.currentBtn = index
		self.ctx.btnEvent = button.event
		self.ctx.isClickable = isHovering
	end

	self.button:draw({
		x = x,
		y = y,
		isActive = isModifyingCtx,
	})
	button.text:draw({
		x = x + 20,
		y = y + 7,
		alpha = alpha,
		color = "White",
	})
end

---@param dt deltaTime
---@param alpha number
---@param btnCount integer
function UpdatePrompt:drawCursor(dt, alpha, btnCount)
	self.itemCursor:draw(dt, {
		alphaMod = alpha,
		currentItem = self.ctx.currentBtn,
		totalItems = btnCount,
	})
end

---@param buttons TitlescreenButton[]
---@param button TitlescreenButton
---@return boolean
function UpdatePrompt:isActive(buttons, button)
	if self.ctx.currentBtn > #buttons then
		self.ctx.currentBtn = 1
	end

	local activeButton = buttons[self.ctx.currentBtn]

	return button.event == activeButton.event
end

---@param x number
---@param y number
---@return boolean
function UpdatePrompt:isHovering(x, y)
	return self.mouse:clipped(x, y, self.button.w, self.button.h)
end

return UpdatePrompt
