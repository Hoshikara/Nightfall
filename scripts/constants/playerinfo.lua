return {
	---@type string []
	clears = {
		'PUC',
		'UC',
		'HARD',
		'NORMAL',
	},
	---@type string[]
	grades = {
		'S',
		'AAA+',
		'AAA',
		'AA+',
		'AA',
		'A+',
		'A',
	},
	---@type table<string, string>
	labels = {
		artist = 'ARTIST',
		bestPlay = 'BEST PLAY',
		category = 'CATEGORY',
		close = {
			{ color = 'norm', text = '[START]  /  [ESC]' },
			{ color = 'white', text = 'EXIT' },
		},
		completed = 'COMPLETED',
		level = 'LEVEL',
		title = 'TITLE',
		total = 'TOTAL',
		totals = 'TOTALS',
	},
	---@type string[]
	pages = {
		'OVERVIEW',
		'CLEARS',
		'GRADES',
		'SCORES',
		'TOP 50',
	},
	---@type string[]
	scores = {
		'MINIMUM',
		'MAXIMUM',
		'AVERAGE',
	},
};