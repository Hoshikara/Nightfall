--[[
	Chart Effect Radar Example

	This file should be named "radar.lua"
	Place this file in the same folder as the chart

	Create an entry for each chart difficulty that contains:

	index: Difficulty index,
		Light = 0
		Challenge = 1
		Extended = 2
		Infinite = 3

	level: Self-explanatory

	radar: The radar values for the difficulty, a percentage between 0 and 1
]]--

return {
	{
		index = 2,
		level = 16,
		radar = {
			notes = 0.24,
			peak = 0.34,
			tsumami = 0.24,
			tricky = 1,
			handTrip = 0,
			oneHand = 0.05,
		},
	},
	{
		index = 3,
		level = 18,
		radar = {
			notes = 0.24,
			peak = 0.34,
			tsumami = 0.24,
			tricky = 1,
			handTrip = 0,
			oneHand = 0.05,
		},
	},
}
