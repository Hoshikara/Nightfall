local advanceSelection = require("common/helpers/advanceSelection")

---@param text string
---@return function
local function makeEvent(text)
	return function()
		menu.Confirm(text or "")
	end
end

---@class CollectionsWindowContext: CollectionsWindowContextBase
local CollectionsWindowContext = {}
CollectionsWindowContext.__index = CollectionsWindowContext

---@return CollectionsWindowContext
function CollectionsWindowContext.new()
	---@class CollectionsWindowContextBase
	---@field options CollectionsWindowOption[]
	local self = {
		currentOption = 1,
		numOptions = 1,
		options = {},
	}

	---@diagnostic disable-next-line
	return setmetatable(self, CollectionsWindowContext)
end

function CollectionsWindowContext:update()
	self.currentOption = 1
	self.options = {}

	local options = self.options

	if #dialog.collections == 0 then
		options[1] = {
			event = makeEvent("FAVOURITES"),
			text = makeLabel("Medium", "ADD TO FAVOURITES"),
		}
	end

	for i, collection in ipairs(dialog.collections) do
		options[i] = {
			event = makeEvent(collection.name),
			text = makeLabel(
				"Medium",
				((collection.exists and "REMOVE FROM %s") or ("ADD TO %s")):format(collection.name)
			)
		}
	end

	options[#options + 1] = {
		event = menu.ChangeState,
		text = makeLabel("Medium", "CREATE NEW COLLECTION"),
	}
	options[#options + 1] = {
		event = menu.Cancel,
		text = makeLabel("Medium", "EXIT"),
	}

	self.numOptions = #options
end

---@param btn integer
function CollectionsWindowContext:handleButton(btn)
	if btn == game.BUTTON_BCK then
		menu.Cancel()
	elseif btn == game.BUTTON_STA then
		self.options[self.currentOption].event()
	end
end

---@param step integer
function CollectionsWindowContext:selectOption(step)
	self.currentOption = advanceSelection(self.currentOption, #self.options, step)
end

return CollectionsWindowContext

---@class CollectionsWindowOption
---@field event function
---@field text Label
