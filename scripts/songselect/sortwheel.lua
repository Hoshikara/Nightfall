local CONSTANTS = require('constants/songwheel');

local GridLayout = require('layout/grid');

local arrowWidth = 12;

local currentSort = 1;

local initialY = -1000;

local previousSort = 0;

local timer = 0;
local highlightTimer = 0;

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

		for i, sort in ipairs(sorts) do
			local label = CONSTANTS.sorts[sort];

			if (not label) then
				label = {
					name = string.upper(sort);
					direction = (((i % 2) == 0) and 'DOWN') or 'UP',
				};
			end

			labels[i] = {
				name = New.Label({
					font = 'normal',
					text = label.name,
					size = 24,
				}),
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
	
	local color = (displaying and 'normal') or 'white';
	local x = layout.field[3].x;
	local y = layout.field.y;

	drawLabel({
		x = x,
		y = y,
		color = color,
		label = labels[currentSort].name,
	});

	gfx.Save();

	gfx.Translate(
		x + labels[currentSort].name.w + arrowWidth,
		y 
			+ (labels[currentSort].name.h / 2)
			+ (((labels[currentSort].direction == 'UP') and 0) or 8)
	);

	gfx.BeginPath();
	setFill('dark', 255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'UP') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	setFill(color);
	gfx.MoveTo(0, 0);
	gfx.LineTo(arrowWidth, 0);
	gfx.LineTo((arrowWidth / 2), ((labels[currentSort].direction == 'UP') and 10) or -10);
	gfx.LineTo(0, 0);
	gfx.Fill();

	gfx.Restore();
end

drawSortLabel = function(index, y, isSelected)
	local baseAlpha = (isSelected and 255) or 150;
	local alpha = math.floor(baseAlpha * math.min(timer ^ 2, 1));
	local padding = layout.dropdown.padding;
	local x = layout.dropdown[3].x + padding;
	local w = (labels.maxWidth + (arrowWidth * 2) + 16)
		* smoothstep(highlightTimer);
	
	if (isSelected) then
		drawRectangle({
			x = x - 8,
			y = y,
			w = w,
			h = 30,
			alpha = alpha * 0.4,
			color = 'normal',
			fast = true,
		});
	end

	drawLabel({
		x = x,
		y = y,
		alpha = alpha,
		color = 'white',
		label = labels[index].name,
	});

	gfx.Save();

	gfx.Translate(
		x + labels[index].name.w + arrowWidth,
		y 
			+ (labels[index].name.h / 2)
			+ (((labels[index].direction == 'UP') and 0) or 8)
	);

	gfx.BeginPath();
	setFill('dark', 255 * 0.5);
	gfx.MoveTo(1, 1);
	gfx.LineTo(arrowWidth + 1, 1);
	gfx.LineTo(
		(arrowWidth / 2) + 1,
		((labels[currentSort].direction == 'UP') and 11) or -9
	);
	gfx.LineTo(1, 1);
	gfx.Fill();

	gfx.BeginPath();
	setFill('white', alpha);
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

		if (previousSort ~= currentSort) then
			highlightTimer = 0;

			previousSort = currentSort;
		end

		highlightTimer = math.min(highlightTimer + (deltaTime * 4), 1);

		initialY = layout.dropdown.y;
	end

	drawRectangle({
		x = layout.dropdown[3].x,
		y = initialY,
		w = (layout.dropdown.padding * 2) + labels.maxWidth + (arrowWidth * 2),
		h = (labels.maxHeight + layout.dropdown.padding) * timer,
		alpha = 230,
		color = 'dark',
	});

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