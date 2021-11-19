local DimmedNumber = require("common/DimmedNumber")
local getCalculatorButtons = require("volforcetarget/helpers/getCalculatorButtons")
local getVfRequirements = require("volforcetarget/helpers/getVfRequirements")

local Clears = {
	"PUC",
	"UC",
	"HARD",
	"NORMAL",
}

---@class VolforceTarget: VolforceTargetBase
local VolforceTarget = {}
VolforceTarget.__index = VolforceTarget

---@param ctx TitlescreenContext
---@param mouse Mouse
---@param window Window
---@return VolforceTarget
function VolforceTarget.new(ctx, mouse, window)
	---@class VolforceTargetBase
	local self = {
		ctx = ctx,
		calculateText = makeLabel("Medium", "CALCULATE", 37, "White"),
		deleteText = makeLabel("Medium", "<", 37, "White"),
		heading = makeLabel("Regular", "VOLFORCE TARGET CALCULATOR", 48, "White"),
		input = "",
		inputText = makeLabel("Number", "0", 34, "White"),
		levelText = makeLabel("Number", "", 22, "White"),
		mouse = mouse,
		numberText = makeLabel("Number", "0", 34, "White"),
		requirements = nil,
		score = DimmedNumber.new({ size = 22 }),
		tableText = makeLabel("Medium", "", 25, "White"),
		targetVolforce = makeLabel("Medium", "TARGET VOLFORCE", 25, "White"),
		window = window,
		windowResized = nil,
		x = 0,
		y = 0,
		w = 968,
		h = 64,
	}

	self.buttons = getCalculatorButtons(self)

	---@diagnostic disable-next-line
	return setmetatable(self, VolforceTarget)
end

function VolforceTarget:setProps()
	if self.windowResized ~= self.window.resized then
		self.x = self.window.paddingX
		self.y = self.window.paddingY
		self.windowResized = self.window.resized
	end
end

function VolforceTarget:draw()
	self:setProps()
	gfx.Save()
	self.heading:draw({
		x = self.window.paddingX - 4,
		y = self.y - 16,
	})
	self:drawCalculator()

	if self.requirements and (#self.requirements[1] > 0) then
		self:drawRequirements(self.requirements)
	end
	gfx.Restore()
end

function VolforceTarget:drawCalculator()
	local color = "Medium"
	local x = self.x
	local y = self.y + 300

	if self.window.isPortrait then
		x = 316
		y = self.y + 64
	end

	drawRect({
		x = x,
		y = y,
		w = 448,
		h = 432,
		alpha = 0.65,
		color = "Black",
	})

	x = x + 16
	y = y + 7

	self.targetVolforce:draw({ x = x, y = y })

	y = y + 41

	drawRect({
		x = x,
		y = y,
		w = 416,
		h = 48,
		color = "Black",
		stroke = { color = "Medium", size = 2 },
	})
	self.inputText:draw({
		x = x + 10,
		y = y + 2,
		text = self.input,
		update = true,
	})

	y = y + 64

	self:drawButtons(x, y)

	y = y + 256

	if self.mouse:clipped(x, y, 416, 48) then
		color = "Standard"
		self.ctx.btnEvent = function()
			if self.input ~= "" then
				self.requirements = getVfRequirements(self.input)

				self:setHeight()
			end
		end
	end

	drawRect({
		x = x,
		y = y,
		w = 416,
		h = 48,
		color = color,
	})

	self.calculateText:draw({
		x = x + (416 * 0.5),
		y = y + (48 * 0.5) - 2,
		align = "CenterMiddle",
	})
end

---@param x number
---@param y number
function VolforceTarget:drawButtons(x, y)
	local ctx = self.ctx
	local mouse = self.mouse
	local numberText = self.numberText
	local w = 128
	local h = 48

	for i, button in ipairs(self.buttons) do
		local color = "Medium"
		local buttonX = x + (((i - 1) % 3) * 144)

		if mouse:clipped(buttonX, y, w, h) then
			color = "Standard"
			ctx.btnEvent = button.event
		end

		drawRect({
			x = buttonX,
			y = y,
			w = w,
			h = h,
			color = color,
		})
		numberText:draw({
			x = buttonX + (w * 0.5),
			y = y + (h * 0.5) - 1,
			align = "CenterMiddle",
			text = button.text,
			update = true,
		})

		if i % 3 == 0 then
			y = y + 64
		end
	end
end

---@param reqs integer[][]
function VolforceTarget:drawRequirements(reqs)
	local levelNum = 20
	local levelText = self.levelText
	local score = self.score
	local x = self.x + 618
	local y = self.y + 64

	if self.window.isPortrait then
		x = self.window.paddingX
		y = y + 464
	end

	self:drawTable(x, y)

	x = x + 15
	y = y + 48

	for i, level in ipairs(reqs) do
		if not level[1] then
			break
		end

		local rowY = y + ((i - 1) * 42)

		if (i % 2) == 1 then
			drawRect({
				x = x + 1,
				y = rowY,
				w = 936,
				h = 42,
				color = "Medium",
			})
		end

		levelText:draw({
			x = x + 16,
			y = rowY + 6,
			text = ("%02d"):format(levelNum),
			update = true,
		})

		for j, value in ipairs(level) do
			score:draw({
				x = x + 144 + ((j - 1) * 198),
				y = rowY + 6,
				value = value,
			})
		end

		levelNum = levelNum - 1
	end

end

---@param x number
---@param y number
function VolforceTarget:drawTable(x, y)
	local tableText = self.tableText

	drawRect({
		x = x,
		y = y,
		w = 968,
		h = self.h,
		alpha = 0.65,
		color = "Black",
	})

	x = x + 30
	y = y + 7

	tableText:draw({
		x = x,
		y = y,
		text = "LEVEL",
		update = true,
	})

	x = x + 128

	for i, clear in ipairs(Clears) do
		tableText:draw({
			x = x + ((i - 1) * 198),
			y = y,
			text = clear,
			update = true,
		})
	end
end

function VolforceTarget:setHeight()
	local height = 64
	local rowHeight = 42

	for _, level in ipairs(self.requirements) do
		if not level[1] then
			break
		end

		height = height + rowHeight
	end

	self.h = height
end

return VolforceTarget
