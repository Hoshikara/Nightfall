local CONSTANTS_CHALWHEEL = require('constants/chalwheel');
local CONSTANTS_SONGWHEEL = require('constants/songwheel');

local GridLayout = require('layout/grid');

local arrowWidth = 12;

local currentSort = 1;

local initialY = -1000;

local isSongSelect = true;
local rendererSet = false;

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
		local currentConstants = (isSongSelect and CONSTANTS_SONGWHEEL.sorts)
			or CONSTANTS_CHALWHEEL.sorts;

		labels = {
			maxWidth = 0,
			maxHeight = 0,
		};

		Font.Normal();

		for index, current in ipairs(currentConstants) do
			labels[index] = {
				name = Label.New(current.name, 24),
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
			+ (((labels[currentSort].direction == 'up') and 0) or 8)
	);

	gfx.BeginPath();
	Fill.Dark(255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'up') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	Fill[color]();
	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[currentSort].direction == 'up') and 10) or -10);
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
			+ (((labels[index].direction == 'up') and 0) or 8)
	);

	gfx.BeginPath();
	Fill.Dark(255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'up') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	Fill[color](alpha);
	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[index].direction == 'up') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();

	return labels[index].name.h + padding;
end

render = function(deltaTime, displaying)
	if (not rendererSet) then
		isSongSelect = #sorts == 12;

		rendererSet = true;
	end

	if (not layout) then
		layout = GridLayout.New(isSongSelect);
	end

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

	local currentConstants = (isSongSelect and CONSTANTS_SONGWHEEL.sorts)
		or CONSTANTS_CHALWHEEL.sorts;
	local sortY = 0;

	for sortIndex, _ in ipairs(currentConstants) do
		local isSelected = sortIndex == currentSort;

		sortY = sortY + drawSortLabel(sortIndex, sortY, isSelected);
	end

	gfx.Restore();
end

set_selection = function(newSort)
  currentSort = newSort;
end