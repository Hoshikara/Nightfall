local _ = {
	['button'] = {
		['w'] = 0,
		['h'] = 0,
		['x'] = 0,
		['y'] = 0
	},
	['dialog'] = {
		['w'] = 0,
		['h'] = 0,
		['x'] = 0,
		['y'] = 0
	},
	['w'] = {
		['inner'] = 0,
		['middle'] = 0,
		['outer'] = 0
	},
	['h'] = {
		['outer'] = 0,
	},
	['x'] = {
		['center'] = 0,
		['middleLeft'] = 0,
		['outerLeft'] = 0,
		['middleRight'] = 0,
		['outerRight'] = 0
	},
	['y'] = {
		['center'] = 0,
		['top'] = 0,
		['bottom'] = 0
	}
};

_.setAllSizes = function(self, scaledW, scaledH)
	if (not self['images']) then
		self['images'] = {
			['dialogBox'] = gfx.CreateSkinImage('dialog.png', 0),
			['button'] = gfx.CreateSkinImage('song_select/button_long.png', 0),
			['buttonHover'] = gfx.CreateSkinImage('song_select/button_long_hover.png', 0)
		};
	end

	self['w']['inner'] = scaledW / (1920 / 446); 
	self['w']['middle'] = scaledW / (1920 / 624);
	self['w']['outer'] = scaledW / (1920 / 800);
	self['h']['outer'] = scaledH / (1080 / 306);

	self['x']['center'] = scaledW / 2;
	self['y']['center'] = scaledH / 2;

	self['x']['innerLeft'] = self['x']['center'] - (self['w']['inner'] / 2);
	self['x']['middleLeft'] = self['x']['center'] - (self['w']['middle'] / 2);
	self['x']['outerLeft'] = self['x']['center'] - (self['w']['outer'] / 2);
	self['x']['innerRight'] = self['x']['center'] + (self['w']['inner'] / 2);
	self['x']['middleRight'] = self['x']['center'] + (self['w']['middle'] / 2);
	self['x']['outerRight'] = self['x']['center'] + (self['w']['outer'] / 2);

	self['y']['top'] = self['y']['center'] - (self['h']['outer'] / 2);
	self['y']['bottom'] = self['y']['center'] + (self['h']['outer'] / 2);

	self['button']['w'], self['button']['h'] = gfx.ImageSize(self['images']['button']);

	self['button']['x'] = self['x']['outerRight'] - self['button']['w'] + 12;

	self['dialog']['w'], self['dialog']['h'] = gfx.ImageSize(self['images']['dialogBox']);

	self['dialog']['x'] = self['x']['center'] - (self['dialog']['w'] / 2);
	self['dialog']['y'] = self['y']['center'] - (self['dialog']['h'] / 2);
end

return _;