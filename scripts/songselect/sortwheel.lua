CONSTANTS = require('constants/songwheel');

local arrowWidth = 12;

local currentSort = 1;

local initialY = -1000;

local timer = 0;

local cache = { resX = 0, resY = 0 };

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();

  if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
    scaledW = 1920;
    scaledH = scaledW * (resY / resX);
    scalingFactor = resX / scaledW;

    cache.resX = resX;
    cache.resY = resY;
  end

  gfx.Scale(scalingFactor, scalingFactor);
end

local layout = {
	cache = { scaledW = 0, scaledH = 0 },
  dropdown = {
    [1] = {},
    [2] = {},
    [3] = {},
    padding = 24,
    start = 0,
    y = 0,
  },
  field = {
    [1] = {},
    [2] = {},
    [3] = {},
    y = 0,
  },
  grid = {},
	labels = nil,
	
	setAllSizes = function(self)
		if (not self.labels) then
			self.labels = {};
	
			font.medium();
			for name, str in pairs(CONSTANTS.labels.grid) do
				self.labels[name] = cacheLabel(str, 18);
			end
	
			local tempLabel = cacheLabel('TEMPLABEL', 24);
	
			self.field.height = tempLabel.h;
			self.labels.height = self.labels.sort.h;
		end
	
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.jacketSize = scaledH / 4;
			self.grid.gutter = self.jacketSize / 8;
			self.grid.size = (self.jacketSize + self.grid.gutter) * 4;
			self.grid.x = scaledW - self.grid.size + (self.grid.gutter * 7);
		
			self.labels.x = {
				self.grid.x,
				(self.jacketSize * 1.5) + self.grid.gutter,
				(self.jacketSize / 2) + self.grid.gutter
			};
			self.labels.y = scaledH / 20;
		
			self.field[1].x = self.labels.x[1] - 4;
			self.field[2].x = self.field[1].x + (self.jacketSize * 1.5) + self.grid.gutter;
			self.field[3].x = self.field[2].x + (((self.jacketSize * 1.5) + self.grid.gutter) / 2);
			self.field[1].maxWidth = (self.jacketSize * 1.65)	- (self.dropdown.padding * 2);
			self.field.y = self.labels.y + (self.labels.height * 1.25);
		
			self.dropdown[1].x = self.field[1].x + 2;
			self.dropdown[2].x = self.field[2].x;
			self.dropdown[3].x = self.field[3].x;
			self.dropdown[1].maxWidth = (self.jacketSize * 3)
				+ (self.grid.gutter * 2)
				- (self.dropdown.padding * 2);
			self.dropdown.start = self.dropdown.padding - 7;
			self.dropdown.y = self.field.y + (self.field.height * 1.25);
			
			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,
};

local labels = nil;

setLabels = function()
	if (not labels) then
		labels = {
			maxWidth = 0,
			maxHeight = 0,
		};

		font.normal();

		for index, current in ipairs(CONSTANTS.sorts) do
			labels[index] = {
				name = cacheLabel(current.name, 24),
				direction = current.direction
			};

			if (labels[index].name.w > labels.maxWidth) then
				labels.maxWidth = labels[index].name.w;
			end

			labels.maxHeight = labels.maxHeight + labels[index].name.h + layout.dropdown.padding;
		end
	end
end

drawCurrentSort = function(displaying)
	local x = layout.field[3].x;
	local y = layout.field.y;

	gfx.BeginPath();
	align.left();

	if (displaying) then
		fill.normal();
	else
		fill.white();
	end

	labels[currentSort].name:draw({ x = x, y = y });

	gfx.Save();

	gfx.Translate(
		x + labels[currentSort].name.w + arrowWidth,
		y 
			+ (labels[currentSort].name.h / 2)
			+ (((labels[currentSort].direction == 'up') and 0) or 8)
	);

	gfx.BeginPath();

	if (displaying) then
		fill.normal();
	else
		fill.white();
	end

	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[currentSort].direction == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();
end

drawSortLabel = function(index, y, isSelected)
	local alpha = math.floor(255 * math.min(timer ^ 2, 1));
	local padding = layout.dropdown.padding;
	local x = layout.dropdown[3].x + padding;

	gfx.BeginPath();
	align.left();

	if (isSelected) then
		fill.normal(alpha);
	else
		fill.white(alpha);
	end

	labels[index].name:draw({ x = x, y = y });

	gfx.Save();

	gfx.Translate(
		x + labels[index].name.w + arrowWidth,
		y 
			+ (labels[index].name.h / 2)
			+ (((labels[index].direction == 'up') and 0) or 8)
	);

	gfx.BeginPath();

	if (isSelected) then
		fill.normal(alpha);
	else
		fill.white(alpha);
	end

	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[index].direction == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();

	return labels[index].name.h + padding;
end

render = function(deltaTime, displaying)
	gfx.Save();

	setupLayout();

	layout:setAllSizes();

	setLabels();

	drawCurrentSort(displaying);

	if (not displaying) then
		if (timer > 0) then
			timer = math.max(timer - (deltaTime * 6), 0);
		end

		if (timer == 0) then
			return;
		end
	else
		timer = math.min(timer + (deltaTime * 8), 1);

		initialY = layout.dropdown.y;
	end

	gfx.BeginPath();
	fill.black(230);
	gfx.Rect(
		layout.dropdown[3].x,
		initialY,
		(layout.dropdown.padding * 2) + labels.maxWidth + (arrowWidth * 2),
		(labels.maxHeight + layout.dropdown.padding) * timer
	);
	gfx.Fill();

	gfx.Translate(0, initialY + layout.dropdown.start);

	local sortY = 0;

	for sortIndex, _ in ipairs(CONSTANTS.sorts) do
		local isSelected = sortIndex == currentSort;

		sortY = sortY + drawSortLabel(sortIndex, sortY, isSelected);
	end

	gfx.Restore();
end

set_selection = function(newSort)
  currentSort = newSort;
end