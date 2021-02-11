local CONSTANTS = require('constants/songwheel');

local GridLayout = require('layout/grid');

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
		
		gfx.Scale(scalingFactor, scalingFactor);

    cache.resX = resX;
		cache.resY = resY;
	end
end

local layout = nil;

local labels = nil;

setLabels = function()
	if (not labels) then
		labels = {
			maxWidth = 0,
			maxHeight = 0,
		};

		Font.Normal();

		for i, sort in ipairs(sorts) do
			local label = CONSTANTS.sorts[sort];

			if (not label) then
				label = {
					name = string.upper(sort);
					direction = (((i % 2) == 0) and 'DOWN') or 'UP',
				};
			end

			labels[i] = {
				name = New.Label({ text = label.name, size = 24 }),
				direction = label.direction,
			};

			if (labels[i].name.w > labels.maxWidth) then
				labels.maxWidth = labels[i].name.w;
			end

			labels.maxHeight = labels.maxHeight
				+ labels[i].name.h
				+ layout.dropdown.padding;
		end
	end
end

drawCurrentSort = function(displaying)
	if (currentSort > #labels) then
		currentSort = 1;
	end
	
	local color = (displaying and 'Normal') or 'White';
	local x = layout.field[3].x;
	local y = layout.field.y;

	gfx.BeginPath();
	FontAlign.Left();

	labels[currentSort].name:draw({
		x = x,
		y = y,
		color = color,
	});

	gfx.Save();

	gfx.Translate(
		x + labels[currentSort].name.w + arrowWidth,
		y 
			+ (labels[currentSort].name.h / 2)
			+ (((labels[currentSort].direction == 'UP') and 0) or 8)
	);

	gfx.BeginPath();
	Fill.Dark(255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'UP') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	Fill[color]();
	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[currentSort].direction == 'UP') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();
end

drawSortLabel = function(index, y, isSelected)
	local alpha = math.floor(255 * math.min(timer ^ 2, 1));
	local color = (isSelected and 'Normal') or 'White';
	local padding = layout.dropdown.padding;
	local x = layout.dropdown[3].x + padding;

	gfx.BeginPath();
	FontAlign.Left();

	labels[index].name:draw({
		x = x,
		y = y,
		a = alpha,
		color = color,
	});

	gfx.Save();

	gfx.Translate(
		x + labels[index].name.w + arrowWidth,
		y 
			+ (labels[index].name.h / 2)
			+ (((labels[index].direction == 'UP') and 0) or 8)
	);

	gfx.BeginPath();
	Fill.Dark(255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'UP') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	Fill[color](alpha);
	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[index].direction == 'UP') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();

	return labels[index].name.h + padding;
end

render = function(deltaTime, displaying)
	if ((not layout) and sorts) then
		-- sortwheel is rendered by songwheel and chalwheel, but there's no good
		-- way to determine which of the two is rendering it besides checking
		-- the amount of sorts available
		layout = GridLayout.New(#sorts > 8);
	end

	if (not layout) then return end

	gfx.Save();

	setupLayout();

	layout:setSizes(scaledW, scaledH);

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
	Fill.Dark(230);
	gfx.Rect(
		layout.dropdown[3].x,
		initialY,
		(layout.dropdown.padding * 2) + labels.maxWidth + (arrowWidth * 2),
		(labels.maxHeight + layout.dropdown.padding) * timer
	);
	gfx.Fill();

	gfx.Translate(0, initialY + layout.dropdown.start);

	local sortY = 0;

	for sortIndex, _ in ipairs(sorts) do
		local isSelected = sortIndex == currentSort;

		sortY = sortY + drawSortLabel(sortIndex, sortY, isSelected);
	end

	gfx.Restore();
end

set_selection = function(newSort)
  currentSort = newSort;
end