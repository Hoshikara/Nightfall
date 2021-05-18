-- Global `filters` table is available for this script

local JSONTable = require('common/jsontable');
local Window = require('common/window');

local Grid = require('components/common/grid');
local Scrollbar = require('components/common/scrollbar');

local Prefixes = {
	'Collection: ',
	'Folder: ',
	'Level: ',
};

local window = Window:new();

local grid = nil;

local foldersData = JSONTable:new('folders');
local folderNames = nil;

local floor = math.floor;
local min = math.min;

local allowScroll = false;

local choosingFolder = true;

local currFolder = 1;
local currLevel = 1;
local prevFolder = 1;

local labels = nil;

local timers = {
	folder = 0,
	level = 0,
	scroll = 0,
};

local setLabels = function()
	if (not labels) then
		labels = {
			collection = makeLabel('med', 'COLLECTION'),
			difficulty = makeLabel('med', 'DIFFICULTY'),
			fxl = makeLabel('med', '[FX-L]'),
			start = makeLabel('med', '[START]'),
		};
	end
end

local replace = function(s)
	for _, prefix in ipairs(Prefixes) do s = s:gsub(prefix, ''); end

	return s;
end

local getFolders = function()
	if ((not folderNames) and (getSetting('_songSelect', 'TRUE') == 'TRUE')) then
		folderNames = {};

		for _, folder in ipairs(filters.folder) do
			if (not folder:find('Collection: ')) then
				folderNames[#folderNames + 1] = replace(folder);
			end
		end

		table.insert(folderNames, 2, 'OFFICIAL SOUND VOLTEX CHARTS');

		foldersData:overwrite(folderNames);
	end
end

local folders = {
	cache = { w = 0, h = 0 },
	count = 0,
	currFolder = 0,
	labels = {},
	max = 18,
	scrollbar = Scrollbar:new(),
	timer = 0,
	timers = {},
	w = { final = 0, max = 0 },
	h = { offset = 0, total = 0 },

	setSizes = function(this)
		if ((this.cache.w ~= window.w) or (this.cache.h ~= window.h)) then
			this.scrollbar:setSizes({
				x = grid.dropdown.x[1] + this.w.final + (grid.dropdown.padding * 2),
				h = this.h.total - (grid.dropdown.padding / 1.5),
				y = grid.dropdown.y + grid.dropdown.start,
			});

			this.cache.w = window.w;
			this.cache.h = window.h;
		end
	end,

	setLabels = function(this, count)
		if (this.count ~= count) then
			this.count = 0;
			this.labels = {};
			this.timers = {};
			this.w.final, this.w.max = 0, 0;
			this.h.offset, this.h.total = 0, 0;

			for i, folder in ipairs(filters.folder) do
				this.labels[i] = makeLabel('norm', replace(folder));
				
				this.timers[folder] = 0;

				local w = this.labels[i].w;
				local dropdownW = grid.dropdown.maxWidth;

				if (w > this.w.max) then
					if (w > dropdownW) then
						this.w.final = dropdownW;
					else
						this.w.final = w;
					end

					this.w.max = w;
				end

				if (i <= this.max) then
					this.h.total = this.h.total + this.labels[i].h + grid.dropdown.padding;
				end

				this.count = this.count + 1;
			end
		end
	end,

	drawFolder = function(this, dt, label, i, k, y, isCurr)
		local isVis = true;

		if (currFolder > this.max) then
			if ((i <= (currFolder - this.max)) or (i > currFolder)) then
				isVis = false;
			end
		else
			isVis = (i <= this.max);
		end

		if (isVis) then
			local alpha = floor(((isCurr and 255) or 150) * min(timers.folder ^ 2, 1));
			local doesOverflow = label.w > grid.dropdown.maxWidth;
			local w = (this.w.final + 16) * smoothstep(this.timer);

			if (isCurr) then
				drawRect({
					x = -8,
					y = y,
					w = w,
					h = 30,
					alpha = alpha * 0.4,
					color = 'norm',
					fast = true,
				});
			end

			if (allowScroll and doesOverflow) then
				if (isCurr) then
					this.timers[k] = this.timers[k] + dt;
				else
					this.timers[k] = 0;
				end

				label:drawScrolling({
					x = 0,
					y = y,
					alpha = alpha,
					color = 'white',
					scale = window:getScale(),
					timer = this.timers[k],
					width = grid.dropdown.maxWidth,
				});
			else
				label:draw({
					x = 0,
					y = y,
					alpha = alpha,
					color = 'white',
				});
			end
		end

		return label.h + grid.dropdown.padding;
	end,

	handleChange = function(this, dt)
		if (this.currFolder ~= currFolder) then
			this.timer = 0;

			this.currFolder = currFolder;
		end
		
		this.timer = to1(this.timer, dt, 0.25);

		local delta = this.currFolder - this.max;

		if (delta >= 1) then
			this.h.offset = -(delta * (this.labels[1].h + grid.dropdown.padding));
		else
			this.h.offset = 0;
		end
	end,

	render = function(this, dt)
		this:setSizes();

		this:handleChange(dt);

		local y = 0;
		local s = ((#this.labels > this.max) and 3) or 2;

		gfx.Save();

		drawRect({
			x = grid.dropdown.x[1],
			y = grid.dropdown.y,
			w = (grid.dropdown.padding * s) + this.w.final,
			h = (this.h.total + grid.dropdown.padding) * timers.folder,
			alpha = 240,
			color = 'dark',
			fast = true,
		});

		gfx.Translate(
			grid.dropdown.x[1] + grid.dropdown.padding,
			grid.dropdown.y + grid.dropdown.start + this.h.offset
		);

		for i, k in ipairs(filters.folder) do
			y = y + this:drawFolder(dt, this.labels[i], i, k, y, i == currFolder);
		end

		gfx.Restore();

		if (#this.labels > this.max) then
			this.scrollbar:render(dt, {
				alphaMod = min(timers.folder ^ 2, 1),
				color = 'med',
				curr = currFolder,
				total = #this.labels,
			});
		end
	end,
};

local levels = {
	currLevel = 0,
	labels = nil,
	timer = 0,
	w = 0,
	h = 0,

	setLabels = function(this)
		if (not this.labels) then
			this.labels = {};

			for i, level in ipairs(filters.level) do
				local curr = replace(level);
				local type = 'num';

				if (curr == 'All') then
					type = 'norm';
				elseif (curr ~= '∞') then
					curr = ('%02d'):format(tonumber(curr));
				end

				this.labels[i] = makeLabel(type, curr, 24);

				if (this.labels[i].w > this.w) then
					this.w = this.labels[i].w;
				end
				
				this.h = this.h + this.labels[i].h + (grid.dropdown.padding / 2);
			end
		end
	end,

	drawLevel = function(this, label, y, isCurr)
		local alpha = floor(((isCurr and 255) or 155)
			* min(timers.level ^ 2, 1));
		local w = (this.w + 16) * smoothstep(this.timer);

		if (isCurr) then
			drawRect({
				x = -8,
				y = y,
				w = w,
				h = 30,
				alpha = alpha * 0.4,
				color = 'norm',
				fast = true,
			});
		end

		label:draw({
			x = 0,
			y = y,
			alpha = alpha,
			color = 'white',
		});
		
		return label.h + (grid.dropdown.padding / 2);
	end,

	handleChange = function(this, dt)
		if (this.currLevel ~= currLevel) then
			this.timer = 0;

			this.currLevel = currLevel;
		end

		this.timer = to1(this.timer, dt, 0.125);
	end,

	render = function(this, dt)
		local y = 0;
		
		this:handleChange(dt);

		gfx.Save();

		drawRect({
			x = grid.dropdown.x[2],
			y = grid.dropdown.y,
			w = (grid.dropdown.padding * 2) + this.w,
			h = (this.h + grid.dropdown.padding) * timers.level,
			alpha = 240,
			color = 'dark',
			fast = true,
		});

		gfx.Translate(
			grid.dropdown.x[2] + grid.dropdown.padding,
			grid.dropdown.y + grid.dropdown.start
		);

		for i, _ in ipairs(filters.level) do
			y = y + this:drawLevel(this.labels[i], y, i == currLevel);
		end

		gfx.Restore();
	end,
};

local drawLabels = function(isFiltering)
	local prefixC = labels.fxl;
	local prefixD = labels.fxl;
	local y = grid.label.y;

	if (isFiltering) then
		if (choosingFolder) then
			prefixD = labels.start;
		else
			prefixC = labels.start;
		end
	end

	prefixC:draw({ x = grid.field.x[1], y = y - 1 });
	
	labels.collection:draw({
		x = grid.field.x[1] + prefixC.w + 8,
		y = y,
		color = 'white',
	});

	prefixD:draw({ x = grid.field.x[2], y = y - 1 });

	labels.difficulty:draw({
		x = grid.field.x[2] + prefixD.w + 8,
		y = y,
		color = 'white',
	});
end

local drawCurrField = function(dt, isFiltering, isFolder)
	local color = 'white';
	local label = (isFolder and folders.labels[currFolder])
		or levels.labels[currLevel];

	if (not label) then return; end

	if (isFiltering) then
		if (choosingFolder and isFolder) then
			color = 'norm';
		elseif ((not choosingFolder) and (not isFolder)) then
			color = 'norm';
		end
	end

	if (isFolder and (label.w > grid.field.maxWidth)) then
		timers.scroll = timers.scroll + dt;

		label:drawScrolling({
			x = grid.field.x[1],
			y = grid.field.y,
			color = color,
			scale = window:getScale(),
			timer = timers.scroll,
			width = grid.field.maxWidth + (grid.dropdown.padding / 2),
		});
	else
		label:draw({
			x = grid.field.x[(isFolder and 1) or 2],
			y = grid.field.y,
			color = color,
		});
	end
end

local handleChange = function(dt, isFiltering)
	if (not isFiltering) then
		if (choosingFolder and (timers.folder > 0)) then
			timers.folder = to0(timers.folder, dt, 0.15);
		elseif (timers.level > 0) then
			timers.level = to0(timers.level, dt, 0.15);
		end
	else
		if (choosingFolder) then
			allowScroll = timers.folder > 0;

			timers.folder = to1(timers.folder, dt, 0.125);

			if (timers.level > 0) then timers.level = to0(timers.level, dt, 0.15); end
		else
			allowScroll = timers.level > 0;

			timers.level = to1(timers.level, dt, 0.125);

			if (timers.folder > 0) then
				timers.folder = to0(timers.folder, dt, 0.15);
			end
		end
	end

	if (prevFolder ~= currFolder) then
		timers.scroll = 0;

		prevFolder = currFolder;
	end

	if (filters and filters.folder and (currFolder > #filters.folder)) then
		currFolder = #filters.folder;
	end
end

-- Called by the game every frame
---@param dt deltaTime
---@param isFiltering boolean
render = function(dt, isFiltering)
	game.SetSkinSetting('_filtering', (isFiltering and 'TRUE') or 'FALSE');

	handleChange(dt, isFiltering);

	if (not grid) then
		grid = Grid:new(window, getSetting('_songSelect', 'TRUE') == 'TRUE');
	end

	setLabels();
	
	gfx.Save();

	window:set(false);

	grid:setSizes();

	getFolders();

	folders:setLabels(#filters.folder);
	levels:setLabels();

	drawLabels(isFiltering);

	drawCurrField(dt, isFiltering, true);
	drawCurrField(dt, isFiltering, false);

	if ((timers.folder == 0) and (timers.level == 0)) then return end

	folders:render(dt);
	levels:render(dt);

	gfx.Restore();
end

-- Called by the game when selecting a filter
---@param newIndex integer
---@param isFolder boolean
set_selection = function(newIndex, isFolder)
	if (isFolder) then
		currFolder = newIndex;
	else
		currLevel = newIndex;
	end
end

-- Called by the game when switching between filters
---@param isFolder boolean
set_mode = function(isFolder) choosingFolder = isFolder; end