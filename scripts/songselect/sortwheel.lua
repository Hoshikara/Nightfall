-- Global `sorts` table is available for this script

local Sorts = require('constants/sorts');

local Grid = require('components/common/grid');

local min = math.min;

local window = Window:new();

local grid = nil;

local arrowSize = 12;

local currSort = 1;
local prevSort = 0;

local labels = nil;

local timers = { expand = 0, highlight = 0 };

local setLabels = function()
	if (not labels) then
		labels = {
			fxr = makeLabel('med', '[FX-R]'),
			sort = makeLabel('med', 'SORT'),
			w = 0,
			h = 0,
		};

		for i, sort in ipairs(sorts) do
			local label = Sorts[sort];

			if (not label) then
				label = { name = sort, sub = { '', '' } };
			end

			labels[i] = {
				name = makeLabel('norm', label.name),
				sub = {
					makeLabel('med', label.sub[1], 11),
					makeLabel('med', label.sub[2], 11),
				},
			};

			local subW = labels[i].sub[1].w;

			if (labels[i].sub[2].w > subW) then subW = labels[i].sub[2].w; end

			if ((labels[i].name.w + subW)  > labels.w) then
				labels.w = labels[i].name.w + subW;
			end

			labels.h = labels.h + labels[i].name.h + grid.dropdown.padding;
		end
	end
end

local drawCurrSort = function(isSorting)
	if (currSort > #labels) then currSort = 1; end

	local color = (isSorting and 'norm') or 'white';
	local label = labels[currSort];
	local x = grid.field.x[3];
	local y = grid.field.y;

	labels.fxr:draw({ x = x, y = grid.label.y });

	labels.sort:draw({
		x = x + labels.fxr.w + 8,
		y = grid.label.y,
		color = 'white',
	});

	label.name:draw({
		x = x,
		y = y,
		color = color,
	});

	x = x + label.name.w + 12;
	y = y + 3;

	label.sub[1]:draw({
		x = x,
		y = y,
		color = color,
	});

	label.sub[2]:draw({
		x = x,
		y = y + label.sub[1].h - 1,
		color = color,
	});
end

local drawSort = function(i, y, isCurr)
	local alpha = ((isCurr and 255) or 150) * min(timers.expand ^ 2, 1);
	local label = labels[i];
	local x = grid.dropdown.x[3] + grid.dropdown.padding;
	local w = (labels.w + (arrowSize * 2) + 16) * smoothstep(timers.highlight);

	window:unscale();

	if (isCurr) then
		drawRect({
			x = x - 8,
			y = y,
			w = w,
			h = 30,
			alpha = alpha * 0.4,
			color = 'norm',
			fast = true,
		});
	end

	label.name:draw({
		x = x,
		y = y,
		alpha = alpha,
		color = 'white',
	});

	x = x + label.name.w + 12;
	y = y + 3;

	label.sub[1]:draw({
		x = x,
		y = y,
		alpha = alpha,
		color = 'white',
	});

	label.sub[2]:draw({
		x = x,
		y = y + label.sub[1].h - 1,
		alpha = alpha,
		color = 'white',
	});

	window:scale();

	return label.name.h + grid.dropdown.padding;
end

local handleChange = function(dt, isSorting)
	if (not isSorting) then
		timers.expand = to0(timers.expand, dt, 0.15);
	else
		timers.expand = to1(timers.expand, dt, 0.125);

		if (prevSort ~= currSort) then
			timers.highlight = 0;

			prevSort = currSort;
		end

		timers.highlight = to1(timers.highlight, dt, 0.25);
	end
end

-- Called by the game every frame
---@param dt deltaTime
---@param isSorting boolean
render = function(dt, isSorting)
	game.SetSkinSetting('_sorting', (isSorting and 'TRUE') or 'FALSE');

	handleChange(dt, isSorting);

	if (not grid) then
		grid = Grid:new(window, getSetting('_songSelect', 'TRUE') == 'TRUE');
	end

	setLabels();

	gfx.ForceRender();

	gfx.Save();

	window:set(true);

	grid:setSizes();

	drawCurrSort(isSorting);

	if (timers.expand == 0) then return; end

	window:scale();

	drawRect({
		x = grid.dropdown.x[3],
		y = grid.dropdown.y,
		w = (grid.dropdown.padding * 2) + labels.w + (arrowSize * 2),
		h = (labels.h + grid.dropdown.padding) * timers.expand,
		alpha = 240,
		color = 'dark',
	});

	local y = grid.dropdown.y + grid.dropdown.start;

	for i, _ in ipairs(sorts) do y = y + drawSort(i, y, i == currSort); end

	window:unscale();

	gfx.Restore();
end

-- Called by the game when selecting a filter
---@param newSort integer
set_selection = function(newSort) currSort = newSort; end