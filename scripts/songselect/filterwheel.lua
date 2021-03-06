local GridLayout = require('layout/grid');

local allowScroll = false;

local initialY = -1000;

local isSongSelect = true;
local rendererSet = false;

local currentFolder = 1;
local currentLevel = 1;
local previousFolder = 1;

local choosingFolder = true;

local prefixes = {
	'Collection: ',
	'Folder: ',
	'Level: ',
};

local scrollTimers = {};
local timers = {
	folder = 0,
	level = 0,
	scroll = 0,
};

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

local stringReplace = function(str, patternTable, replacement)
  local replaceWith = replacement or '';
	local newStr = str;

	for _, pattern in ipairs(patternTable) do
		newStr = string.gsub(newStr, pattern, replaceWith);
	end

	return string.upper(newStr);
end

local labels = nil;

local layout = nil;

local setLabels = function()
	if (not labels) then
		local newLabel = function(text)
			return New.Label({
				font = 'medium',
				text = text,
				size = 18,
			});
		end

		labels = {
			collection = newLabel('COLLECTION'),
			difficulty = newLabel('DIFFICULTY'),
			fxl = newLabel('[FX-L]'),
			start = newLabel('[START]'),
		};
	end
end

local folders = {
	count = 0,
	labels = {},
	previousFolder = 0,
	timer = 0,
	timers = {},
	viewLimit = 18,
	w = { final = 0, max = 0 },
	h = {	offset = 0, total = 0 },

	setLabels = function(self, folderCount)
		if (folderCount ~= self.count) then
			self.count = 0;
			self.labels = {};
			self.timers = {};
			self.w.final, self.w.max = 0, 0;
			self.h.offset, self.h.total = 0, 0;

			for i, folder in ipairs(filters.folder) do
				self.labels[i] = New.Label({
					font = 'normal',
					text = stringReplace(folder, prefixes),
					size = 24,
				});
				self.timers[folder] = 0;

				local width = self.labels[i].w;

				if (width > self.w.max) then
					local dropdownWidth = layout.dropdown[1].maxWidth;

					if (width > dropdownWidth) then
						self.w.final = dropdownWidth;
					else
						self.w.final = width;
					end

					self.w.max = width;
				end

				if (i <= self.viewLimit) then
					self.h.total = self.h.total + self.labels[i].h + layout.dropdown.padding;
				end

				self.count = self.count + 1;
			end
		end
	end,

	drawFolder = function(self, deltaTime, i, y, key, isSelected)
		local isVisible = true;
	
		if (currentFolder > self.viewLimit) then
			if ((i <= (currentFolder - self.viewLimit)) or (i > currentFolder)) then
				isVisible = false;
			end
		elseif (i > self.viewLimit) then
			isVisible = false;
		end

		if (isVisible) then
			local baseAlpha = (isSelected and 255) or 150;
			local alpha = math.floor(baseAlpha * math.min(timers.folder ^ 2, 1));
			local doesOverflow = self.labels[i].w > layout.dropdown[1].maxWidth;
			local w = (self.w.final + 16) * smoothstep(self.timer);

			if (isSelected) then
				drawRectangle({
					x = -8,
					y = y,
					w = w,
					h = 30,
					alpha = alpha * 0.4,
					color = 'normal',
					fast = true,
				});
			end

			if (allowScroll and doesOverflow) then
				if (isSelected) then
					self.timers[key] = self.timers[key] + deltaTime;
				else
					self.timers[key] = 0;
				end

				drawScrollingLabel({
					x = 0,
					y = y,
					alpha = alpha,
					color = 'white',
					label = self.labels[i],
					scale = scalingFactor,
					timer = self.timers[key],
					width = layout.dropdown[1].maxWidth,
				});
			else
				drawLabel({
					x = 0,
					y = y,
					alpha = alpha,
					color = 'white',
					label = self.labels[i],
				});
			end
		end

		return self.labels[1].h + layout.dropdown.padding;
	end,

	handleChange = function(self)
		local delta = currentFolder - self.viewLimit;

		if (delta >= 1) then
			self.h.offset = -(delta * (self.labels[1].h + layout.dropdown.padding));
		else
			self.h.offset = 0;
		end
	end,

	render = function(self, deltaTime, initialY)
		if (self.previousFolder ~= currentFolder) then
			self.timer = 0;

			self.previousFolder = currentFolder;
		end

		self.timer = math.min(self.timer + (deltaTime * 4), 1);

		local y = 0;

		self:handleChange();

		gfx.Save();

		gfx.Translate(
			layout.dropdown[1].x + layout.dropdown.padding,
			initialY + layout.dropdown.start + self.h.offset
		);

		for i, key in ipairs(filters.folder) do	
			y = y + self:drawFolder(deltaTime, i, y, key, i == currentFolder);
		end

		gfx.Restore();
	end,
};

local levels = {
	labels = nil,
	previousLevel = 0,
	timer = 0,
	w = 0,
	h = 0,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {};

			for i, level in ipairs(filters.level) do
				local current = stringReplace(level, prefixes);
				local font = 'number';
		
				if (current == 'ALL') then
					font = 'normal';
				elseif (current ~= '∞') then
					current = string.format(
						'%02d',
						tonumber(stringReplace(level, prefixes))
					);
				end
	
				self.labels[i] = New.Label({
					font = font,
					text = current,
					size = 24,
				});
	
				local width = self.labels[i].w;
	
				if (width > self.w) then
					self.w = width;
				end
	
				self.h = self.h + self.labels[i].h + (layout.dropdown.padding / 2);
			end
		end
	end,

	drawLevel = function(self, i, y, isSelected)
		local baseAlpha = (isSelected and 255) or 155;
		local alpha = math.floor(baseAlpha * math.min(timers.level ^ 2, 1));
		local w = (self.w + 16) * smoothstep(self.timer);

		if (isSelected) then
			drawRectangle({
				x = -8,
				y = y,
				w = w,
				h = 30,
				alpha = alpha * 0.4,
				color = 'normal',
				fast = true,
			});
		end

		drawLabel({
			x = 0,
			y = y,
			alpha = alpha,
			color = 'white',
			label = self.labels[i],
		});

		return self.labels[i].h + (layout.dropdown.padding / 2);
	end,

	render = function(self, deltaTime, initialY)
		if (self.previousLevel ~= currentLevel) then
			self.timer = 0;

			self.previousLevel = currentLevel;
		end

		self.timer = math.min(self.timer + (deltaTime * 8), 1);

		local y = 0;

		gfx.Save();

		gfx.Translate(
			layout.dropdown[2].x + layout.dropdown.padding,
			initialY + layout.dropdown.start
		);

		for i, _ in ipairs(filters.level) do
			y = y + self:drawLevel(i, y, i == currentLevel);
		end

		gfx.Restore();
	end,
};

local drawCurrentField = function(deltaTime, label, field, displaying, isFolder)
	local x = layout.field[field].x;
	local y = layout.field.y;
	local color;
	local doesOverflow = false;

	if (not label) then return end

	if (isFolder) then
		doesOverflow = label.w > layout.field[1].maxWidth;
	end

	if (displaying) then
		if (choosingFolder and isFolder) then
			color = 'normal';
		elseif ((not choosingFolder) and (not isFolder)) then
			color = 'normal';
		else
			color = 'white';
		end
	else
		color = 'white';
	end

	if (doesOverflow) then
		timers.scroll = timers.scroll + deltaTime;

		drawScrollingLabel({
			x = x,
			y = y,
			alpha = 255,
			color = color,
			label = label,
			scale = scalingFactor,
			timer = timers.scroll,
			width = layout.field[1].maxWidth + (layout.dropdown.padding / 2),
		});
	else
		drawLabel({
			x = x,
			y = y,
			color = color,
			label = label,
		});
	end
end

local drawLabels = function(displaying)
	local collectionPrefix = labels.fxl;
	local difficultyPrefix = labels.fxl;
	local y = (scaledH / 20) - 2;

	if (displaying) then
		if (choosingFolder) then
			difficultyPrefix = labels.start;
		else
			collectionPrefix = labels.start;
		end
	end

	drawLabel({
		x = layout.field[1].x,
		y = y - 1,
		color = 'normal',
		label = collectionPrefix,
	});

	drawLabel({
		x = layout.field[1].x + collectionPrefix.w + 8,
		y = y,
		color = 'white',
		label = labels.collection,
	});

	drawLabel({
		x = layout.field[2].x,
		y = y - 1,
		color = 'normal',
		label = difficultyPrefix,
	});

	drawLabel({
		x = layout.field[2].x + difficultyPrefix.w + 8,
		y = y,
		color = 'white',
		label = labels.difficulty,
	});
end

render = function(deltaTime, displaying)
	if (not rendererSet) then
		isSongSelect = #filters.level == 21;

		rendererSet = true;
	end

	if ((not layout) and rendererSet) then
		layout = GridLayout.New(isSongSelect);
	end

	setLabels();

	gfx.Save();

	setupLayout();

	layout:setSizes(scaledW, scaledH);

	folders:setLabels(#filters.folder);
	levels:setLabels();

	if (currentFolder > #filters.folder) then
		currentFolder = #filters.folder;
	end

	if (previousFolder ~= currentFolder) then
		timers.scroll = 0;

		previousFolder = currentFolder;
	end

	drawLabels(displaying);

	drawCurrentField(deltaTime, folders.labels[currentFolder], 1, displaying, true);
	drawCurrentField(deltaTime, levels.labels[currentLevel], 2, displaying, false);

	if (not displaying) then
		if (choosingFolder and (timers.folder > 0)) then
			timers.folder = math.max(timers.folder - (deltaTime * 6), 0);
		elseif (timers.level > 0) then
			timers.level = math.max(timers.level - (deltaTime * 6), 0);
		end
	
		if ((timers.folder == 0) and (timers.level == 0)) then return end
	else
		if (choosingFolder) then
			allowScroll = true;
			timers.folder = math.min(timers.folder + (deltaTime * 8), 1);

			if (timers.level > 0) then
				timers.level = math.max(timers.level - (deltaTime * 6), 0);
			end
		else
			timers.level = math.min(timers.level + (deltaTime * 8), 1);

			if (timers.folder > 0) then
				timers.folder = math.max(timers.folder - (deltaTime * 6), 0);
			end

			if (timers.folder == 0) then
				allowScroll = false;
			end
		end

		initialY = layout.dropdown.y;
	end

	drawRectangle({
		x = layout.dropdown[1].x,
		y = initialY,
		w = (layout.dropdown.padding * 2) + folders.w.final,
		h = (folders.h.total + layout.dropdown.padding) * timers.folder,
		alpha = 230,
		color = 'dark',
		fast = true,
	});

	drawRectangle({
		x = layout.dropdown[2].x,
		y = initialY,
		w = (layout.dropdown.padding * 2) + levels.w,
		h = (levels.h + (layout.dropdown.padding * 1.5)) * timers.level,
		alpha = 230,
		color = 'dark',
		fast = true,
	});

	folders:render(deltaTime, initialY);

	levels:render(deltaTime, initialY);

	gfx.Restore();
end

set_selection = function(newIndex, selectingFolder)
	if (selectingFolder) then
		currentFolder = newIndex;
	else
		currentLevel = newIndex;
	end
end

set_mode = function(selectingFolder)
	choosingFolder = selectingFolder;
end
