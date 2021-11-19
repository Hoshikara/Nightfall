local Buttons = {
	BTA = 0,
	BTB = 1,
	BTC = 2,
	BTD = 3,
	FXL = 4,
	FXR = 5,
	STA = 6,
	BCK = 11,
}

---@param btn string
---@return boolean
local function didPress(btn)
	return game.GetButton(Buttons[btn])
end

return didPress
