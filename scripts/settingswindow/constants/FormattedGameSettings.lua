---@type table<string, table<string, FormattedSetting|string>>
local FormattedGameSettings = {
	["Offsets"] = {
		name = "OFFSETS",
		["Global Offset"] = {
			category = "time",
			description = {
				"OFFSET TO SYNC AUDIO AND VISUALS",
				"INCREASE IF OBJECTS APPEAR TO HIT THE CRITICAL LINE EARLY",
				"DECREASE IF OBJECTS APPEAR TO HIT THE CRITICAL LINE LATE",
			},
			name = "VISUAL OFFSET",
		},
		["Button Input Offset"] = {
			category = "time",
			description = {
				"BUTTON-SPECIFIC OFFSET TO COMPENSATE FOR INPUT DEVICE DELAY",
				"INCREASE IF OBJECTS ARE BEING HIT EARLY",
				"DECREASE IF OBJECTS ARE BEING HIT LATE",
			},
			name = "BUTTON INPUT OFFSET",
		},
		["Laser Input Offset"] = {
			category = "time",
			description = {
				"LASER-SPECIFIC OFFSET TO COMPENSATE FOR INPUT DEVICE DELAY",
			},
			name = "LASER INPUT OFFSET",
		},
		["Song Offset"] = {
			category = "time",
			description = {
				"SONG SPECIFIC OFFSET TO COMPENSATE FOR CHART TIMING ISSUES",
				"INCREASE IF OBJECTS ARE BEING HIT LATE",
				"DECREASE IF OBJECTS ARE BEING HIT EARLY",
			},
			name = "OFFSET FOR CURRENT SONG",
		},
		["Compute Song Offset"] = {
			description = {
				"AUTOMATICALLY COMPUTES THE OFFSET FOR THE CURRENT SONG",
				"USE AT YOUR OWN DISCRETION AS THE COMPUTED VALUE MAY BE INCORRECT",
			},
			name = "AUTO-COMPUTE OFFSET FOR CURRENT SONG",
		},
	},
	["HiSpeed"] = {
		name = "LANE-SPEED",
		["Speed Mod"] = {
			description = {
				"LANE-SPEED CALCULATION MODE",
				"XMOD:  (BASE MULTIPLIER) * BPM = LANE-SPEED THAT VARIES PER CHART",
				"MMOD:  (GAME-ADJUSTED MULTIPLIER) * BPM = TARGET LANE-SPEED (RECOMMENDED)",
				"CMOD:  FUNCTIONALLY SIMILAR TO MMOD BUT IGNORES BPM CHANGES (DO NOT USE)"
			},
			name = "MODE",
			options = {
				"XMOD",
				"MMOD",
				"CMOD",
			},
		},
		["HiSpeed"] = {
			description = {
				"BASE MULTIPLIER USED FOR XMOD"
			},
			name = "BASE MULTIPLIER",
		},
		["ModSpeed"] = {
			category = "laneSpeed",
			description = {
				"TARGET VALUE USED FOR MMOD AND CMOD"
			},
			name = "TARGET VALUE",
		},
	},
	["Game"] = {
		name = "GAMEPLAY",
		["Gauge"] = {
			description = {
				"EFFECTIVE:  0% START, COMPLETE WITH >=70% FOR NORMAL CLEAR",
				"EXCESSIVE:  100% START, COMPLETE WITH >0% FOR HARD CLEAR",
				"PERMISSIVE:  100% START, SIMILAR TO EXCESSIVE BUT LESS PUNISHING",
				"BLASTIVE:  100% START, SIMILAR TO EXCESSIVE BUT WITH ADJUSTABLE PUNISH"
			},
			name = "GAUGE TYPE",
			options = {
				"EFFECTIVE",
				"EXCESSIVE",
				"PERMISSIVE",
				"BLASTIVE",
			},
		},
		["Blastive Rate Level"] = {
			description = {
				"DIFFICULTY LEVEL FOR BLASTIVE GAUGE TYPE",
				"0.50 - 2.00:  NORMAL CLEAR",
				">2.50:  HARD CLEAR"
			},
			name = "BLASTIVE LEVEL",
		},
		["Backup Gauge"] = {
			description = {
				"IF ENABLED, GAUGE TYPE SWITCHES TO EFFECTIVE UPON REACHING 0%",
			},
			isInverted = false,
			name = "BACKUP GAUGE (ARS)",
		},
		["Random"] = {
			description = {
				"IF ENABLED, BT OBJECTS APPEAR RANDOMLY",
				"FX OBJECTS MAY OR MAY NOT APPEAR RANDOMLY",
			},
			isInverted = false,
			name = "RANDOM MODE",
		},
		["Mirror"] = {
			description = {
				"IF ENABLED, ALL OBJECTS ARE MIRRORED HORIZONTALLY",
			},
			isInverted = false,
			name = "MIRROR MODE",
		},
		["Hide Backgrounds"] = {
			isInverted = true,
			name = "BACKGROUNDS",
		},
		["Score Display"] = {
			description = {
				"ADDITIVE:  SCORE STARTS AT 0 (DEFAULT)",
				"SUBTRACTIVE:  SCORE STARTS AT 10,000,000",
				"AVERAGE:  SCORE STARTS AT 10,000,000",
			},
			name = "SCORE DISPLAY MODE",
			options = {
				"ADDITIVE",
				"SUBTRACTIVE",
				"AVERAGE",
			},
		},
		["Autoplay"] = {
			name = "START CURRENT SONG IN AUTOPLAY MODE",
		},
		["Practice"] = {
			name = "START CURRENT SONG IN PRACTICE MODE",
		},
	},
	["Hid/Sud"] = {
		name = "HIDDEN & SUDDEN",
		["Enable Hidden / Sudden"] = {
			isInverted = false,
			name = "STATUS",
		},
		["Hidden Cutoff"] = {
			description = {
				"CUTOFF FROM TRACK START TO TRACK END",
			},
			name = "HIDDEN CUTOFF",
		},
		["Hidden Fade"] = {
			description = {
				"AMOUNT OF FADING FOR THE HIDDEN CUTOFF",
			},
			name = "HIDDEN FADE",
		},
		["Sudden Cutoff"] = {
			description = {
				"CUTOFF FROM TRACK END TO TRACK START",
			},
			name = "SUDDEN CUTOFF",
		},
		["Sudden Fade"] = {
			description = {
				"AMOUNT OF FADING FOR THE SUDDEN CUTOFF",
			},
			name = "SUDDEN FADE",
		},
		["Show Track Cover"] = {
			isInverted = false,
			name = "TRACK COVER",
		},
	},
	["Judgement"] = {
		name = "HIT WINDOWS",
		["Crit Window"] = {
			category = "hitWindow",
			description = {
				"TIMING WINDOW FOR BUTTON CRITICAL JUDGEMENT",
			},
			indicateLower = true,
			name = "CRITICAL WINDOW",
		},
		["Near Window"] = {
			category = "hitWindow",
			description = {
				"TIMING WINDOW FOR BUTTON NEAR JUDGEMENT",
			},
			indicateLower = true,
			name = "NEAR WINDOW",
		},
		["Hold Window"] = {
			category = "hitWindow",
			description = {
				"TIMING WINDOW FOR HOLD JUDGEMENT",
			},
			indicateLower = true,
			name = "HOLD WINDOW",
		},
		["Slam Window"] = {
			category = "hitWindow",
			description = {
				"TIMING WINDOW FOR LASER SLAM JUDGEMENT",
			},
			indicateLower = true,
			name = "SLAM WINDOW",
		},
		["Set to NORMAL"] = {
			name = "SET TO NORMAL VALUES",
		},
		["Set to HARD"] = {
			name = "SET TO HARD VALUES",
		},
	},
}

return FormattedGameSettings

---@class FormattedSetting
---@field category? string
---@field description? string[]
---@field highlight Easing
---@field index integer
---@field isInverted? boolean
---@field name string|Label
---@field options? string[]
---@field value Label
---@field type string
