---@type table<string, table<string, FormattedSetting|string>>
local FormattedPracticeSettings = {
	["Main"] = {
		name = "GENERAL",
		["Set the start point to here"] = {
			name = "USE CURRENT TIME AS STARTING POINT",
		},
		["Set the end point to here"] = {
			name = "USE CURRENT TIME AS ENDING POINT",
		},
		["Loop on success"] = {
			isInverted = false,
			name = "AUTO-RESTART AFTER PASS",
		},
		["Loop on fail"] = {
			isInverted = false,
			name = "AUTO-RESTART AFTER FAIL",
		},
		["Playback speed"] = {
			category = "percentage",
			name = "SONG SPEED",
		},
		["Enable navigation inputs for the setup"] = {
			isInverted = false,
			name = "USE CONTROLLER INPUTS FOR SETUP",
		},
		["Start practice"] = {
			name = "START PRACTICE",
		},
		["Exit"] = {
			name = "EXIT PRACTICE MODE",
		},
	},
	["Looping"] = {
		name = "LOOP POINTS",
		["Set the start point to here"] = {
			name = "USE CURRENT TIME AS STARTING POINT",
		},
		["- in measure no."] = {
			name = "\tMEASURE",
		},
		["- in milliseconds"] = {
			category = "time",
			name = "\tTIME",
		},
		["Set the end point to here"] = {
			name = "USE CURRENT TIME AS ENDING POINT",
		},
		["Clear the start point"] = {
			name = "RESET STARTING POINT",
		},
		["Clear the end point"] = {
			name = "RESET ENDING POINT",
		},
	},
	["LoopControl"] = {
		name = "LOOP SETTINGS",
		["Loop on success"] = {
			isInverted = false,
			name = "AUTO-RESTART AFTER PASS",
		},
		["Loop on fail"] = {
			isInverted = false,
			name = "AUTO-RESTART AFTER FAIL",
		},
		["Increase speed on success"] = {
			isInverted = false,
			name = "AUTO-INCREASE SONG SPEED AFTER PASS",
		},
		["Decrease speed on fail"] = {
			isInverted = false,
			name = "AUTO-DECREASE SONG SPEED AFTER FAIL",
		},
		["Set maximum amount of rewinding on fail"] = {
			isInverted = false,
			name = "AUTO-REWIND BY MEASURES ON FAIL",
		},
		["- increment"] = {
			category = "percentage",
			name = "\tSONG SPEED INCREASE INCREMENT",
		},
		["- decrement"] = {
			category = "percentage",
			name = "\tSONG SPEED DECREASE DECREMENT",
		},
		["- required streaks"] = {
			name = "\tPASS STREAK REQUIREMENT",
		},
		["- minimum speed"] = {
			category = "percentage",
			name = "\tMINIMUM SONG SPEED",
		},
		["- amount in # of measures"] = {
			name = "\tMEASURES",
		},
	},
	["Mission"] = {
		name = "MISSION SETTINGS",
		["Fail condition"] = {
			name = "FAIL CONDITION",
			options = {
				"NONE",
				"SCORE",
				"GRADE",
				"MISS",
				"MISS AND NEAR",
				"GAUGE",
			},
		},
		["Score less than"] = {
			name = "SCORE CANNOT FALL BELOW",
		},
		["Grade less than"] = {
			name = "GRADE CANNOT FALL BELOW",
			options = {
				"D",
				"C",
				"B",
				"A",
				"A+",
				"AA",
				"AA+",
				"AAA",
				"AAA+",
				"S",
				"995",
				"998",
				"999",
				"PUC",
			},
		},
		["Miss more than"] = {
			name = "MISS COUNT CANNOT EXCEED",
		},
		["Miss+Near more than"] = {
			name = "MISS AND NEAR COUNT CANNOT EXCEED",
		},
		["Gauge less than"] = {
			category = "percentage",
			name = "GAUGE CANNOT FALL BELOW",
		},
	},
	["Settings"] = {
		name = "SETTINGS",
		["Global offset"] = {
			category = "time",
			name = "VISUAL OFFSET",
		},
		["Chart offset"] = {
			category = "time",
			name = "OFFSET FOR CURRENT SONG",
		},
		["Temporary offset"] = {
			category = "time",
			name = "TEMPORARY OFFSET FOR CURRENT SONG",
		},
		["Lead-in time for practices"] = {
			category = "time",
			name = "LEAD-IN TIME",
		},
		["Enable navigation inputs for the setup"] = {
			isInverted = false,
			name = "USE CONTROLLER INPUTS FOR SETUP",
		},
		["Revert to the setup after the result is shown"] = {
			isInverted = false,
			name = "RETURN TO PRACTICE MODE AFTER RESULTS",
		},
		["Adjust HiSpeed for playback speeds lower than x1.0"] = {
			isInverted = false,
			name = "ADJUST LANE-SPEED FOR <100% SONG SPEED",
		},
		["Adjust HiSpeed for playback speeds higher than x1.0"] = {
			isInverted = false,
			name = "ADJUST LANE-SPEED FOR >100% SONG SPEED",
		},
	},
}

return FormattedPracticeSettings
