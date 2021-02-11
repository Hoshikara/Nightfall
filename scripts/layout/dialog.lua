return {
	cache = { scaledW = 0, scaledH = 0 },
	button = {
		w = 0,
		h = 0,
		x = 0,
		y = 0,
	},
	dialog = {
		w = 0,
		h = 0,
		x = 0,
		y = 0,
	},
	w = {
		inner = 0,
		middle = 0,
		outer = 0,
	},
	h = { outer = 0 },
	x = {
		center = 0,
		middleLeft = 0,
		outerLeft = 0,
		middleRight = 0,
		outerRight = 0,
	},
	y = {
		center = 0,
		top = 0,
		bottom = 0,
	},

	setSizes = function(self, scaledW, scaledH)
		if (not self.images) then
			self.images = {
				dialogBox = New.Image({ path = 'common/dialog.png' }),
				button = New.Image({ path = 'buttons/long.png' }),
				buttonHover = New.Image({ path = 'buttons/long_hover.png' }),
			};
		end
	
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.w.inner = scaledW / (1920 / 446); 
			self.w.middle = scaledW / (1920 / 624);
			self.w.outer = scaledW / (1920 / 800);
			self.h.outer = scaledH / (1080 / 306);
	
			self.x.center = scaledW / 2;
			self.y.center = scaledH / 2;
	
			self.x.innerLeft = self.x.center - (self.w.inner / 2);
			self.x.middleLeft = self.x.center - (self.w.middle / 2);
			self.x.outerLeft = self.x.center - (self.w.outer / 2);
			self.x.innerRight = self.x.center + (self.w.inner / 2);
			self.x.middleRight = self.x.center + (self.w.middle / 2);
			self.x.outerRight = self.x.center + (self.w.outer / 2);
	
			self.y.top = self.y.center - (self.h.outer / 2);
			self.y.bottom = self.y.center + (self.h.outer / 2);
			
			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,
};