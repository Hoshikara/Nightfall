return {
	['Main'] = {
		name = 'GENERAL',
		['Set the start point to here'] = {
			name = 'USE CURRENT TIME AS START POINT',
		},
		['Set the end point to here'] = {
			name = 'USE CURRENT TIME AS END POINT',
		},
		['Loop on success'] = {
			invert = false,
			name = 'AUTO-RESTART ON PASS',
		},
		['Loop on fail'] = {
			invert = false,
			name = 'AUTO-RESTART ON FAIL',
		},
		['Enable navigation inputs for the setup'] = {
			invert = false,
			name = 'CONTROLLER INPUTS FOR SETUP',
		},
		['Playback speed'] = {
			name = 'SONG SPEED',
			special = 'PERCENTAGE',
		},
		['Start practice'] = { name = 'BEGIN PRACTICE' },
		['Exit'] = { name = 'EXIT' },
	},
	['Looping'] = {
		name = 'LOOP CONTROL',
		['Set the start point to here'] = { name = 'SET START POINT' },
		['- in measure no.'] = {
			indent = true,
			name = 'MEASURE'
		},
		['- in milliseconds'] = {
			indent = true,
			name = 'TIME',
			special = 'TIME',
		},
		['Set the end point to here'] = { name = 'SET END POINT' },
		['Clear the start point'] = { name = 'CLEAR START POINT' },
		['Clear the end point'] = { name = 'CLEAR END POINT' },
	},
	['LoopControl'] = {
		name = 'LOOP SETTINGS',
		['Loop on success'] = {
			invert = false,
			name = 'AUTO-RESTART ON PASS',
		},
		['Loop on fail'] = {
			invert = false,
			name = 'AUTO-RESTART ON FAIL',
		},
		['Increase speed on success'] = {
			invert = false,
			name = 'AUTO-INCREASE SONG SPEED ON PASS',
		},
		['- increment'] = {
			indent = true,
			name = 'SONG SPEED INCREASE INCREMENT',
			special = 'PERCENTAGE',
		},
		['- required streakes'] = {
			indent = true,
			name = 'PASS STREAK REQUIREMENT',
		},
		['Decrease speed on fail'] = {
			invert = false,
			name = 'AUTO-DECREASE SONG SPEED ON FAIL',
		},
		['- decrement'] = {
			indent = true,
			name = 'SONG SPEED DECREASE DECREMENT',
			special = 'PERCENTAGE',
		},
		['- minimum speed'] = {
			indent = true,
			name = 'MINIMUM SONG SPEED',
			special = 'PERCENTAGE',
		},
		['Set maximum amount of rewinding on fail'] = {
			invert = false,
			name = 'AUTO-REWIND BY MEASURES ON FAIL',
		},
		['- amount in # of measures'] = {
			indent = true,
			name = 'MEASURES',
		},
	},
	['Mission'] = {
		name = 'MISSION SETTINGS',
		['Fail condition'] = {
			name = 'FAIL CONDITION',
			options = {
				'NONE',
				'SCORE',
				'GRADE',
				'MISS',
				'MISS AND NEAR',
				'GAUGE',
			},
		},
		['Score less than'] = { name = 'SCORE CANNOT FALL BELOW' },
		['Grade less than'] = {
			name = 'GRADE CANNOT FALL BELOW',
			options = {
				'D',
				'C',
				'B',
				'A',
				'A+',
				'AA',
				'AA+',
				'AAA',
				'AAA+',
				'S',
				'995',
				'998',
				'999',
				'PUC',
			},
		},
		['Miss more than'] = { name = 'MISS COUNT CANNOT EXCEED' },
		['Miss+Near more than'] = { name = 'MISS AND NEAR COUNT CANNOT EXCEED' },
		['Gauge less than'] = {
			name = 'GAUGE CANNOT FALL BELOW',
			special = 'PERCENTAGE'
		},
	},
	['Settings'] = {
		name = 'SETTINGS',
		['Global offset'] = {
			name = 'GLOBAL OFFSET',
			special = 'TIME',
		},
		['Chart offset'] = {
			name = 'CURRENT SONG OFFSET',
			special = 'TIME',
		},
		['Temporary offset'] = {
			name = 'TEMPORARY SONG OFFSET',
			special = 'TIME',
		},
		['Lead-in time for practices'] = {
			name = 'LEAD-IN TIME',
			special = 'TIME',
		},
		['Enable navigation inputs for the setup'] = {
			invert = false,
			name = 'CONTROLLER INPUTS FOR SETUP',
		},
		['Revert to the setup after the result is shown'] = {
			invert = false,
			name = 'AUTO-RETURN TO SETUP AFTER RESULTS',
		},
	},
};