local function viewUpdate()
	local updateURL = game.UpdateAvailable()

	if updateURL then
		if package.config:sub(1, 1) == "\\" then
			os.execute("start " .. updateURL)
		else
			os.execute("xdg-open " .. updateURL)
		end
	end
end

---@param ctx TitlescreenContext
---@return TitlescreenButton[]
local function makeUpdatePromptButtons(ctx)
	return {
		{
			event = Menu.Update,
			text = makeLabel("Medium", "UPDATE"),
		},
		{
			event = viewUpdate,
			text = makeLabel("Medium", "VIEW"),
		},
		{
			event = function()
				ctx.currentBtn = 1
				ctx.currentPage = "MainMenu"
				ctx.currentView = ""
				ctx.updateClosed = true
			end,
			text = makeLabel("Medium", "CLOSE"),
		},
	}
end

return makeUpdatePromptButtons
